﻿-- =============================================
-- 系统重构：业务增强对象
-- 在原 zyxt 库上叠加新对象，不破坏现有表结构
-- =============================================

USE zyxt;
GO

-- 1) 给 作业项目表 增加「项目状态」字段（已预算 / 施工中 / 已完工 / 已结算 / 已入账）
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.作业项目表') AND name = N'项目状态'
)
ALTER TABLE dbo.作业项目表 ADD 项目状态 NVARCHAR(10) NOT NULL
    CONSTRAINT DF_作业项目表_项目状态 DEFAULT N'已预算'
    CONSTRAINT CK_作业项目表_项目状态 CHECK (项目状态 IN (N'已预算',N'施工中',N'已完工',N'已结算',N'已入账'));
GO

-- 入账信息一致性：要么三字段都填，要么都不填
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = N'CK_作业项目表_入账一致'
)
ALTER TABLE dbo.作业项目表
ADD CONSTRAINT CK_作业项目表_入账一致 CHECK (
    (入账金额 IS NULL AND 入账人 IS NULL AND 入账日期 IS NULL)
    OR (入账金额 IS NOT NULL AND 入账人 IS NOT NULL AND 入账日期 IS NOT NULL)
);
GO

-- 结算信息一致性
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = N'CK_作业项目表_结算一致'
)
ALTER TABLE dbo.作业项目表
ADD CONSTRAINT CK_作业项目表_结算一致 CHECK (
    (结算金额 IS NULL AND 结算人 IS NULL AND 结算日期 IS NULL)
    OR (结算金额 IS NOT NULL AND (结算人 IS NOT NULL OR 结算日期 IS NOT NULL))
);
GO

-- 日期顺序：预算日期 ≤ 开工日期 ≤ 完工日期 ≤ 结算日期 ≤ 入账日期
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = N'CK_作业项目表_日期顺序'
)
ALTER TABLE dbo.作业项目表
ADD CONSTRAINT CK_作业项目表_日期顺序 CHECK (
    (开工日期 IS NULL OR 预算日期 IS NULL OR 预算日期 <= 开工日期)
    AND (完工日期 IS NULL OR 开工日期 IS NULL OR 开工日期 <= 完工日期)
    AND (结算日期 IS NULL OR 完工日期 IS NULL OR 完工日期 <= 结算日期)
    AND (入账日期 IS NULL OR 结算日期 IS NULL OR 结算日期 <= 入账日期)
);
GO

-- 2) 操作日志表
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = N'操作日志表' AND schema_id = SCHEMA_ID('dbo'))
CREATE TABLE dbo.操作日志表
(
    日志ID     INT IDENTITY(1,1) PRIMARY KEY,
    操作时间   DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    操作人     NVARCHAR(20) NOT NULL DEFAULT N'system',
    操作类型   NVARCHAR(10) NOT NULL,   -- 新增/修改/删除/查询
    对象表     NVARCHAR(50) NOT NULL,
    对象主键   NVARCHAR(50) NULL,
    操作摘要   NVARCHAR(500) NULL
);
CREATE INDEX IX_操作日志表_时间 ON dbo.操作日志表(操作时间 DESC);
CREATE INDEX IX_操作日志表_表   ON dbo.操作日志表(对象表, 操作时间 DESC);
GO

-- 3) 预算超支触发器：写入 操作日志表 + 不阻断（仅记录）
IF EXISTS (SELECT * FROM sys.triggers WHERE name = N'tri_作业项目_操作日志')
    DROP TRIGGER dbo.tri_作业项目_操作日志;
GO
CREATE TRIGGER dbo.tri_作业项目_操作日志
ON dbo.作业项目表
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
        INSERT INTO dbo.操作日志表(操作类型,对象表,对象主键,操作摘要)
        SELECT N'新增', N'作业项目表', i.单据号,
               N'项目【'+ISNULL(i.单据号,'')+N'】预算金额 '+FORMAT(i.预算金额,'0.00')
        FROM inserted i;
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
        INSERT INTO dbo.操作日志表(操作类型,对象表,对象主键,操作摘要)
        SELECT N'修改', N'作业项目表', i.单据号,
               N'项目【'+i.单据号+N'】状态变为 '+i.项目状态
        FROM inserted i;
    IF NOT EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
        INSERT INTO dbo.操作日志表(操作类型,对象表,对象主键,操作摘要)
        SELECT N'删除', N'作业项目表', d.单据号,
               N'项目【'+d.单据号+N'】及材料明细级联删除'
        FROM deleted d;
END
GO

-- 4) 预算超支存储过程：列出 结算金额 > 预算金额 的项目
IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'usp_预算超支项目')
    DROP PROCEDURE dbo.usp_预算超支项目;
GO
CREATE PROCEDURE dbo.usp_预算超支项目
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        单据号, 预算单位, 井号, 施工单位, 施工内容,
        预算金额, 结算金额,
        结算金额 - 预算金额 AS 超支金额,
        CAST((结算金额 - 预算金额) * 100.0 / 预算金额 AS DECIMAL(8,2)) AS 超支比例_pct
    FROM dbo.作业项目表
    WHERE 结算金额 IS NOT NULL AND 预算金额 IS NOT NULL
      AND 结算金额 > 预算金额
    ORDER BY 超支金额 DESC;
END
GO

-- 5) 月度结算统计存储过程
IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'usp_月度结算统计')
    DROP PROCEDURE dbo.usp_月度结算统计;
GO
CREATE PROCEDURE dbo.usp_月度结算统计
    @年份 INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        YEAR(结算日期) AS 年,
        MONTH(结算日期) AS 月,
        预算单位,
        COUNT(*) AS 项目数,
        SUM(预算金额) AS 预算总额,
        SUM(结算金额) AS 结算总额,
        SUM(入账金额) AS 入账总额,
        SUM(ISNULL(结算金额,0) - ISNULL(预算金额,0)) AS 差额
    FROM dbo.作业项目表
    WHERE 结算日期 IS NOT NULL AND YEAR(结算日期) = @年份
    GROUP BY YEAR(结算日期), MONTH(结算日期), 预算单位
    ORDER BY 年, 月, 预算单位;
END
GO

-- 6) 成本构成分析存储过程
IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'usp_成本构成分析')
    DROP PROCEDURE dbo.usp_成本构成分析;
GO
CREATE PROCEDURE dbo.usp_成本构成分析
    @起始日期 DATE,
    @结束日期 DATE
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        预算单位,
        SUM(材料费) AS 材料费,
        SUM(人工费) AS 人工费,
        SUM(设备费) AS 设备费,
        SUM(其它费用) AS 其它费用,
        SUM(材料费+人工费+设备费+其它费用) AS 总成本
    FROM dbo.作业项目表
    WHERE 预算日期 BETWEEN @起始日期 AND @结束日期
    GROUP BY 预算单位
    ORDER BY 预算单位;
END
GO

-- 7) 视图：异常项目（已结算未入账 / 已完工未结算 / 预算超支）
IF OBJECT_ID('dbo.v_异常项目', 'V') IS NOT NULL DROP VIEW dbo.v_异常项目;
GO
CREATE VIEW dbo.v_异常项目
AS
SELECT
    单据号, 预算单位, 井号, 项目状态,
    预算金额, 结算金额, 入账金额,
    CASE
        WHEN 结算金额 IS NOT NULL AND 入账金额 IS NULL THEN N'已结算未入账'
        WHEN 完工日期 IS NOT NULL AND 结算金额 IS NULL THEN N'已完工未结算'
        WHEN 结算金额 IS NOT NULL AND 预算金额 IS NOT NULL AND 结算金额 > 预算金额 THEN N'预算超支'
        ELSE N'正常'
    END AS 异常类型
FROM dbo.作业项目表;
GO

-- 8) 视图：成本运行（按单位、含未结算/未入账金额）
IF OBJECT_ID('dbo.v_成本运行情况', 'V') IS NOT NULL DROP VIEW dbo.v_成本运行情况;
GO
CREATE VIEW dbo.v_成本运行情况
AS
SELECT
    预算单位,
    COUNT(*) AS 项目数,
    SUM(预算金额) AS 预算总额,
    SUM(ISNULL(结算金额,0)) AS 结算总额,
    SUM(ISNULL(入账金额,0)) AS 入账总额,
    SUM(预算金额) - SUM(ISNULL(结算金额,0)) AS 未结算金额,
    SUM(ISNULL(结算金额,0)) - SUM(ISNULL(入账金额,0)) AS 未入账金额
FROM dbo.作业项目表
GROUP BY 预算单位;
GO

-- 9) 触发器：超支预警（写到日志表，由前端读取并高亮）
IF EXISTS (SELECT * FROM sys.triggers WHERE name = N'tri_作业项目_超支预警')
    DROP TRIGGER dbo.tri_作业项目_超支预警;
GO
CREATE TRIGGER dbo.tri_作业项目_超支预警
ON dbo.作业项目表
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.操作日志表(操作类型,对象表,对象主键,操作摘要)
    SELECT N'预警', N'作业项目表', i.单据号,
           N'⚠ 项目【'+i.单据号+N'】结算金额 '+FORMAT(i.结算金额,'0.00')
           +N' 超出预算 '+FORMAT(i.预算金额,'0.00')
           +N'，超支 '+FORMAT(i.结算金额-i.预算金额,'0.00')
    FROM inserted i
    WHERE i.结算金额 IS NOT NULL AND i.预算金额 IS NOT NULL
      AND i.结算金额 > i.预算金额;
END
GO

-- 10) 自动状态流转触发器
IF EXISTS (SELECT * FROM sys.triggers WHERE name = N'tri_作业项目_状态自动流转')
    DROP TRIGGER dbo.tri_作业项目_状态自动流转;
GO
CREATE TRIGGER dbo.tri_作业项目_状态自动流转
ON dbo.作业项目表
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE t
    SET t.项目状态 = CASE
        WHEN i.入账日期 IS NOT NULL         THEN N'已入账'
        WHEN i.结算日期 IS NOT NULL         THEN N'已结算'
        WHEN i.完工日期 IS NOT NULL         THEN N'已完工'
        WHEN i.开工日期 IS NOT NULL         THEN N'施工中'
        ELSE N'已预算'
    END
    FROM dbo.作业项目表 t
    INNER JOIN inserted i ON t.单据号 = i.单据号
    INNER JOIN deleted  d ON d.单据号 = i.单据号
    WHERE (ISNULL(i.开工日期,'1900-01-01') <> ISNULL(d.开工日期,'1900-01-01'))
       OR (ISNULL(i.完工日期,'1900-01-01') <> ISNULL(d.完工日期,'1900-01-01'))
       OR (ISNULL(i.结算日期,'1900-01-01') <> ISNULL(d.结算日期,'1900-01-01'))
       OR (ISNULL(i.入账日期,'1900-01-01') <> ISNULL(d.入账日期,'1900-01-01'));
END
GO

PRINT '=== 数据库增强完成 ===';
GO
