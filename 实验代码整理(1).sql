USE master;
GO

-- 创建数据库
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'zyxt')
CREATE DATABASE zyxt;
GO

USE zyxt;
GO

-- ====================== 实验1：建表 + 插入数据 ======================
--单位代码表
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = N'单位代码表' AND schema_id = SCHEMA_ID('dbo'))
CREATE TABLE dbo.单位代码表
(
    单位代码 CHAR(10) PRIMARY KEY,
    单位名称 VARCHAR(50) NOT NULL UNIQUE
);
GO

--油水井表
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = N'油水井表' AND schema_id = SCHEMA_ID('dbo'))
CREATE TABLE dbo.油水井表
(
    井号 CHAR(4) PRIMARY KEY,
    井别 VARCHAR(10) NOT NULL CHECK (井别 IN ('油井', '水井')),
    单位代码 CHAR(10) NOT NULL,
    FOREIGN KEY (单位代码) REFERENCES dbo.单位代码表(单位代码)
);
GO

--施工单位表
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = N'施工单位表' AND schema_id = SCHEMA_ID('dbo'))
CREATE TABLE dbo.施工单位表
(
    施工单位名称 VARCHAR(50) PRIMARY KEY
);
GO

--物码表
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = N'物码表' AND schema_id = SCHEMA_ID('dbo'))
CREATE TABLE dbo.物码表
(
    物码 CHAR(5) PRIMARY KEY,
    名称规格 VARCHAR(20) NOT NULL UNIQUE,
    计量单位 VARCHAR(10) NOT NULL
);
GO

--作业项目表
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = N'作业项目表' AND schema_id = SCHEMA_ID('dbo'))
CREATE TABLE dbo.作业项目表
(
    单据号 CHAR(10) PRIMARY KEY,
    预算单位 CHAR(10) NOT NULL,
    井号 CHAR(4) NOT NULL,
    预算金额 MONEY NOT NULL CHECK (预算金额 >= 0),
    预算人 VARCHAR(20) NOT NULL,
    预算日期 DATE NOT NULL,
    开工日期 DATE NOT NULL,
    完工日期 DATE NOT NULL,
    施工单位 VARCHAR(50) NOT NULL,
    施工内容 VARCHAR(50) NOT NULL,
    材料费 MONEY NOT NULL CHECK (材料费 >= 0),
    人工费 MONEY NOT NULL CHECK (人工费 >= 0),
    设备费 MONEY NOT NULL CHECK (设备费 >= 0),
    其它费用 MONEY NOT NULL CHECK (其它费用 >= 0),
    结算金额 MONEY CHECK (结算金额 >= 0),
    结算人 VARCHAR(20),
    结算日期 DATE,
    入账金额 MONEY CHECK (入账金额 >= 0),
    入账人 VARCHAR(20),
    入账日期 DATE,
    FOREIGN KEY (预算单位) REFERENCES dbo.单位代码表(单位代码),
    FOREIGN KEY (井号) REFERENCES dbo.油水井表(井号),
    FOREIGN KEY (施工单位) REFERENCES dbo.施工单位表(施工单位名称),
    CHECK (开工日期 <= 完工日期)
);
GO

--材料费表
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = N'材料费表' AND schema_id = SCHEMA_ID('dbo'))
CREATE TABLE dbo.材料费表
(
    单据号 CHAR(10) NOT NULL,
    物码 CHAR(5) NOT NULL,
    消耗数量 INT NOT NULL CHECK (消耗数量 > 0),
    单价 MONEY NOT NULL CHECK (单价 > 0),
    PRIMARY KEY (单据号, 物码),
    FOREIGN KEY (单据号) REFERENCES dbo.作业项目表(单据号),
    FOREIGN KEY (物码) REFERENCES dbo.物码表(物码)
);
GO

-- 插入基础字典数据
INSERT INTO dbo.单位代码表(单位代码, 单位名称)
VALUES
('1122', '采油厂'),
('112201', '采油一矿'),
('112202', '采油二矿'),
('112201001', '采油一矿一队'),
('112201002', '采油一矿二队'),
('112201003', '采油一矿三队'),
('112202001', '采油二矿一队'),
('112202002', '采油二矿二队');
GO

INSERT INTO dbo.油水井表(井号, 井别, 单位代码)
VALUES
('y001', '油井', '112201001'),
('y002', '油井', '112201001'),
('y003', '油井', '112201002'),
('s001', '水井', '112201002'),
('y004', '油井', '112201003'),
('s002', '水井', '112202001'),
('s003', '水井', '112202001'),
('y005', '油井', '112202002');
GO

INSERT INTO dbo.施工单位表(施工单位名称)
VALUES
('作业公司作业一队'),
('作业公司作业二队'),
('作业公司作业三队');
GO

INSERT INTO dbo.物码表(物码, 名称规格, 计量单位)
VALUES
('wm001', '材料一', '吨'),
('wm002', '材料二', '米'),
('wm003', '材料三', '桶'),
('wm004', '材料四', '袋');
GO

-- 作业单据业务数据
INSERT INTO dbo.作业项目表
(单据号, 预算单位, 井号, 预算金额, 预算人, 预算日期, 开工日期, 完工日期,
施工单位, 施工内容, 材料费, 人工费, 设备费, 其它费用, 结算金额,
结算人, 结算日期, 入账金额, 入账人, 入账日期)
VALUES
('zy2018001', '112201001', 'y001', 10000.00, '张三', '2018-05-01', '2018-05-04', '2018-05-25',
'作业公司作业一队', '堵漏', 7000.00, 2500.00, 1000.00, 1400.00, 11900.00,
'李四', '2018-05-26', 11900.00, '王五', '2018-05-28'),

('zy2018002', '112201002', 'y003', 11000.00, '张三', '2018-05-01', '2018-05-04', '2018-05-23',
'作业公司作业二队', '检泵', 6000.00, 1500.00, 1000.00, 2400.00, 10900.00,
'李四', '2018-05-26', 10900.00, '王五', '2018-05-28'),

('zy2018003', '112201002', 's001', 10500.00, '张三', '2018-05-01', '2018-05-06', '2018-05-23',
'作业公司作业二队', '调剖', 6500.00, 2000.00, 500.00, 1400.00, 10400.00,
'李四', '2018-05-26', 10400.00, '王五', '2018-05-28'),

('zy2018004', '112202001', 's002', 12000.00, '张三', '2018-05-01', '2018-05-04', '2018-05-24',
'作业公司作业三队', '解堵', 6000.00, 2000.00, 1000.00, 1600.00, 10600.00,
'李四', '2018-05-26', 10600.00, '赵六', '2018-05-28'),

('zy2018005', '112202002', 'y005', 12000.00, '张三', '2018-05-01', '2018-05-04', '2018-05-28',
'作业公司作业三队', '防砂', 7000.00, 1000.00, 2000.00, 1300.00, 11300.00,
'李四', '2018-06-01', NULL, NULL, NULL);
GO

-- 材料费数据
INSERT INTO dbo.材料费表(单据号, 物码, 消耗数量, 单价)
VALUES
('zy2018001', 'wm001', 200, 10),
('zy2018001', 'wm002', 200, 10),
('zy2018001', 'wm003', 200, 10),
('zy2018001', 'wm004', 100, 10),

('zy2018002', 'wm001', 200, 10),
('zy2018002', 'wm002', 200, 10),
('zy2018002', 'wm003', 200, 10),

('zy2018003', 'wm001', 200, 10),
('zy2018003', 'wm002', 200, 10),
('zy2018003', 'wm003', 250, 10),

('zy2018004', 'wm001', 200, 10),
('zy2018004', 'wm002', 200, 10),
('zy2018004', 'wm004', 200, 10),

('zy2018005', 'wm001', 200, 10),
('zy2018005', 'wm002', 200, 10),
('zy2018005', 'wm004', 300, 10);
GO

-- ====================== 实验2：索引 ======================

-- 作业项目表：预算日期索引
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'IX_作业表_预算日期' AND object_id = OBJECT_ID(N'dbo.作业表'))
CREATE INDEX IX_作业表_预算日期 ON dbo.作业项目表(预算日期);
GO

-- 作业项目表：结算日期索引
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'IX_作业表_结算日期' AND object_id = OBJECT_ID(N'dbo.作业表'))
CREATE INDEX IX_作业表_结算日期 ON dbo.作业项目表(结算日期);
GO

-- 作业项目表：入账日期索引
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'IX_作业表_入账日期' AND object_id = OBJECT_ID(N'dbo.作业表'))
CREATE INDEX IX_作业表_入账日期 ON dbo.作业项目表(入账日期);
GO


-- ====================== 实验3：视图 ======================

-- 视图：作业项目表 + 材料费表 所有列
CREATE OR ALTER VIEW dbo.v_作业材料明细
AS
SELECT
    j.*,
    c.物码,
    c.消耗数量,
    c.单价
FROM dbo.作业项目表 j
JOIN dbo.材料费表 c
ON j.单据号 = c.单据号;
GO

-- 视图：预算状态
CREATE OR ALTER VIEW dbo.v_预算信息
AS
SELECT
    单据号,
    预算单位,
    井号,
    预算金额,
    预算人,
    预算日期
FROM dbo.作业项目表;
GO

--视图：采油一矿作业项目（后续使用）
CREATE OR ALTER VIEW dbo.v_采油一矿作业项目
AS
SELECT
    j.单据号,
    y.单位名称,
    j.井号,
    j.施工内容,
    j.预算金额,
    j.结算金额,
    j.入账金额,
    j.预算日期,
    j.结算日期,
    j.入账日期
FROM dbo.作业项目表 j
JOIN dbo.单位代码表 y
    ON j.预算单位 = y.单位代码
WHERE j.预算单位 LIKE '112201%';
GO

-- ====================== 实验4：事务 + 游标 + 存储过程 + 三大业务触发器 ======================

--事务
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    -- 1. 作业项目表
    INSERT INTO dbo.[作业项目表]
    (单据号,预算单位,井号,预算金额,预算人,预算日期,开工日期,
    完工日期,施工单位,施工内容,材料费,人工费,设备费,其它费用,
    结算金额,结算人,结算日期,入账金额,入账人,入账日期)
    VALUES
    ('zy2018006','112202002','y005',10000,N'张三','2018-07-01',
    '2018-07-04','2018-07-25',N'作业公司作业一队',N'堵漏',7000,2500,1000,
    1400,11900,N'李四','2018-07-26',11900,N'王五','2018-07-28');

    -- 2. 材料费表
    INSERT INTO dbo.[材料费表]
    (单据号,物码,消耗数量,单价)
    VALUES
    ('zy2018006','wm001',200,10);

    INSERT INTO dbo.[材料费表]
    (单据号,物码,消耗数量,单价)
    VALUES
    ('zy2018006','wm002',200,10);

    INSERT INTO dbo.[材料费表]
    (单据号,物码,消耗数量,单价)
    VALUES
    ('zy2018006','wm003',200,10);

    INSERT INTO dbo.[材料费表]
    (单据号,物码,消耗数量,单价)
    VALUES
    ('zy2018006','wm004',100,10);

    COMMIT TRAN;
    PRINT N'事务提交成功。';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;

    PRINT N'事务执行失败，已回滚。';
    PRINT ERROR_MESSAGE();
END CATCH

--游标
-- 1. 声明接收数据的变量
DECLARE
    @单据号 NVARCHAR(50),
    @预算单位 NVARCHAR(50),
    @井号 NVARCHAR(20),
    @预算金额 DECIMAL(18,2),
    @预算人 NVARCHAR(20),
    @预算日期 DATE,
    @开工日期 DATE,
    @完工日期 DATE,
    @施工单位 NVARCHAR(50),
    @施工内容 NVARCHAR(100),
    @材料费 DECIMAL(18,2),
    @人工费 DECIMAL(18,2),
    @设备费 DECIMAL(18,2),
    @其它费用 DECIMAL(18,2),
    @结算金额 DECIMAL(18,2),
    @结算人 NVARCHAR(20),
    @结算日期 DATE,
    @入账金额 DECIMAL(18,2),
    @入账人 NVARCHAR(20),
    @入账日期 DATE;

-- 2. 定义游标
DECLARE cur_作业项目 CURSOR LOCAL FAST_FORWARD FOR
SELECT 
    单据号,预算单位,井号,预算金额,预算人,预算日期,
    开工日期,完工日期,施工单位,施工内容,材料费,人工费,
    设备费,其它费用,结算金额,结算人,结算日期,
    入账金额,入账人,入账日期
FROM dbo.[作业项目表];

-- 3. 打开游标
OPEN cur_作业项目;

-- 4. 读取第一行数据
FETCH NEXT FROM cur_作业项目 INTO
    @单据号,@预算单位,@井号,@预算金额,@预算人,@预算日期,
    @开工日期,@完工日期,@施工单位,@施工内容,@材料费,@人工费,
    @设备费,@其它费用,@结算金额,@结算人,@结算日期,
    @入账金额,@入账人,@入账日期;

-- 5. 先打印表头
PRINT N'单据号       预算单位     井号   预算金额   预算人  预算日期'     
      +N'    开工日期      完工日期       施工单位      施工内容   材料费   人工费    设备费'       
      +N'    其它费用   结算金额  结算人   结算日期   入账金额    入账人  入账日期';
-- 6. 循环读取并打印数据
WHILE @@FETCH_STATUS = 0
BEGIN
     PRINT CONCAT(
        ISNULL(@单据号, 'NULL'), '  ',
        ISNULL(@预算单位, 'NULL'), '  ',
        ISNULL(@井号, 'NULL'), '  ',
        ISNULL(CAST(@预算金额 AS VARCHAR), 'NULL'), '  ',
        ISNULL(@预算人, 'NULL'), '  ',
        ISNULL(CONVERT(VARCHAR, @预算日期, 23), 'NULL'), '  ',
        ISNULL(CONVERT(VARCHAR, @开工日期, 23), 'NULL'), '  ',
        ISNULL(CONVERT(VARCHAR, @完工日期, 23), 'NULL'), '  ',
        ISNULL(@施工单位, 'NULL'), '  ',
        ISNULL(@施工内容, 'NULL'), '     ',
        ISNULL(CAST(@材料费 AS VARCHAR), 'NULL'), '  ',
        ISNULL(CAST(@人工费 AS VARCHAR), 'NULL'), '  ',
        ISNULL(CAST(@设备费 AS VARCHAR), 'NULL'), '  ',
        ISNULL(CAST(@其它费用 AS VARCHAR), 'NULL'), '  ',
        ISNULL(CAST(@结算金额 AS VARCHAR), 'NULL'), '  ',
        ISNULL(@结算人, 'NULL'), '  ',
        ISNULL(CONVERT(VARCHAR, @结算日期, 23), 'NULL'), '  ',
        ISNULL(CAST(@入账金额 AS VARCHAR), 'NULL'), '  ',
        ISNULL(@入账人, 'NULL'), '  ',
        ISNULL(CONVERT(VARCHAR, @入账日期, 23), 'NULL')
    );


    -- 读取下一行
    FETCH NEXT FROM cur_作业项目 INTO
        @单据号,@预算单位,@井号,@预算金额,@预算人,@预算日期,
        @开工日期,@完工日期,@施工单位,@施工内容,@材料费,@人工费,
        @设备费,@其它费用,@结算金额,@结算人,@结算日期,
        @入账金额,@入账人,@入账日期;
END

-- 7. 关闭并释放游标
CLOSE cur_作业项目;
DEALLOCATE cur_作业项目;
GO

-- 报表存储过程
CREATE OR ALTER PROCEDURE dbo.usp_成本运行情况
    @单位代码 NVARCHAR(20),
    @起始日期 DATE,
    @结束日期 DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- 声明变量
    DECLARE @预算金额 DECIMAL(18,2) = 0;
    DECLARE @结算金额 DECIMAL(18,2) = 0;
    DECLARE @入账金额 DECIMAL(18,2) = 0;
    DECLARE @未结算金额 DECIMAL(18,2);
    DECLARE @未入账金额 DECIMAL(18,2);
    DECLARE @标题 NVARCHAR(200);

    -- 1. 按单位代码前缀匹配所有下级单位，统计金额
    SELECT 
        @预算金额 = ISNULL(SUM(预算金额), 0),
        @结算金额 = ISNULL(SUM(结算金额), 0),
        @入账金额 = ISNULL(SUM(入账金额), 0)
    FROM dbo.[作业项目表]
    WHERE 预算单位 LIKE @单位代码 + N'%'
      AND 预算日期 BETWEEN @起始日期 AND @结束日期;

    -- 2. 判断是否有数据
    IF @预算金额 = 0 AND @结算金额 = 0 AND @入账金额 = 0
    BEGIN
        PRINT N'错误：该单位代码下没有找到任何数据！';
        RETURN;
    END

    -- 3. 计算衍生金额
    SET @未结算金额 = @预算金额 - @结算金额;
    SET @未入账金额 = @结算金额 - @入账金额;

    -- 4. 生成标题
    SET @标题 = @单位代码 + N'单位' 
                + CONVERT(NVARCHAR, @起始日期, 23) + N'时间---' 
                + CONVERT(NVARCHAR, @结束日期, 23) + N'时间成本运行情况';

    -- 5. 输出
    PRINT @标题;
    PRINT N'预算金额    结算金额    入账金额    未结算金额    未入账金额';
    PRINT 
        FORMAT(@预算金额, '0.00') + '   ' +
        FORMAT(@结算金额, '0.00') + '   ' +
        FORMAT(@入账金额, '0.00') + '   ' +
        FORMAT(@未结算金额, '0.00') + '   ' +
        FORMAT(@未入账金额, '0.00');
END
GO

-- 报表存储过程
CREATE OR ALTER PROC dbo.usp_成本运行情况
@单位代码 NVARCHAR(20),
@起始日期 DATE,
@结束日期 DATE
AS
BEGIN
SET NOCOUNT ON;
DECLARE @预算 MONEY=0,@结算 MONEY=0,@入账 MONEY=0,@未结算 MONEY,@未入账 MONEY;
SELECT @预算=ISNULL(SUM(预算金额),0),@结算=ISNULL(SUM(结算金额),0),@入账=ISNULL(SUM(入账金额),0)
FROM dbo.作业项目表
WHERE 预算单位 LIKE @单位代码+'%' AND 预算日期 BETWEEN @起始日期 AND @结束日期;
IF @预算=0 AND @结算=0 AND @入账=0
BEGIN PRINT N'无匹配业务数据';RETURN;END
SET @未结算=@预算-@结算;
SET @未入账=@结算-@入账;
PRINT CONCAT('预算：',FORMAT(@预算,'0.00'),' 结算：',FORMAT(@结算,'0.00'),' 入账：',FORMAT(@入账,'0.00'),' 未结算：',FORMAT(@未结算,'0.00'),' 未入账：',FORMAT(@未入账,'0.00'));
END
GO

-- 触发器1：新增作业自动计算结算金额
IF EXISTS (SELECT * FROM sys.triggers WHERE name = N'tri_作业_插入算结算' AND parent_id = OBJECT_ID(N'dbo.作业项目表'))
BEGIN
    DROP TRIGGER dbo.tri_作业_插入算结算;
END
GO
CREATE TRIGGER dbo.tri_作业_插入算结算
ON dbo.作业项目表
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE t
    SET t.结算金额
        = ISNULL(t.材料费, 0)
        + ISNULL(t.人工费, 0)
        + ISNULL(t.设备费, 0)
        + ISNULL(t.其它费用, 0)
    FROM dbo.作业项目表 t
    INNER JOIN inserted i ON t.单据号 = i.单据号;
END
GO

-- 触发器2：修改成本自动重算结算金额
IF EXISTS (SELECT * FROM sys.triggers WHERE name = N'tri_作业_更新算结算' AND parent_id = OBJECT_ID(N'dbo.作业项目表'))
BEGIN
    DROP TRIGGER dbo.tri_作业_更新算结算;
END
GO
CREATE TRIGGER dbo.tri_作业_更新算结算
ON dbo.作业项目表
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    -- 材料费/人工费/设备费/其它费用发生变化时才重算
    IF UPDATE(材料费)
        OR UPDATE(人工费)
        OR UPDATE(设备费)
        OR UPDATE(其它费用)
    BEGIN
        UPDATE t
        SET t.结算金额
            = ISNULL(t.材料费, 0)
            + ISNULL(t.人工费, 0)
            + ISNULL(t.设备费, 0)
            + ISNULL(t.其它费用, 0)
        FROM dbo.作业项目表 t
        INNER JOIN inserted i
            ON t.单据号 = i.单据号;
    END
END
GO

-- 触发器3：删除作业级联删除材料明细
IF EXISTS (SELECT * FROM sys.triggers WHERE name = N'tri_作业_删除级联明细' AND parent_id = OBJECT_ID(N'dbo.作业项目表'))
BEGIN
    DROP TRIGGER dbo.tri_作业_删除级联明细;
END
GO
CREATE TRIGGER dbo.tri_作业_删除级联明细
ON dbo.作业项目表
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- 1. 先删子表
    DELETE mat
    FROM dbo.材料费表 mat
    INNER JOIN deleted d
        ON mat.单据号 = d.单据号;
    -- 2. 再删主表
    DELETE job
    FROM dbo.作业项目表 job
    INNER JOIN deleted d
        ON job.单据号 = d.单据号;
END
GO

-- ====================== 实验5：安全（登录、用户、角色、权限） ======================
USE master;
GO
IF SUSER_ID(N'login_backend') IS NULL
CREATE LOGIN login_backend
WITH PASSWORD = 'Back@2026', CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;
GO

USE zyxt;
GO
IF USER_ID(N'user_backend') IS NULL
CREATE USER user_backend
FOR LOGIN login_backend
WITH DEFAULT_SCHEMA = dbo;
GO

IF DATABASE_PRINCIPAL_ID(N'role_op') IS NULL
CREATE ROLE role_op;
GO
ALTER ROLE role_op ADD MEMBER user_backend;

-- dbo架构批量授权
GRANT SELECT, INSERT, UPDATE ON SCHEMA::dbo TO role_op;
GO

DENY DELETE ON SCHEMA::dbo TO role_op;
DENY ALTER ON SCHEMA::dbo TO role_op;
GO

DENY SELECT ON OBJECT::dbo.作业项目表 TO user_backend;
GRANT SELECT ON OBJECT::dbo.v_采油一矿作业项目 TO user_backend;
GRANT EXECUTE ON OBJECT::dbo.usp_成本运行情况 TO user_backend;
GO

-- 时段限制安全触发器
IF EXISTS (SELECT * FROM sys.triggers WHERE name = N'tri_作业_时段限制更新' AND parent_id = OBJECT_ID(N'dbo.作业项目表'))
BEGIN
    DROP TRIGGER dbo.tri_作业_时段限制更新;
END
GO
CREATE TRIGGER dbo.tri_作业_时段限制更新
ON dbo.作业项目表
AFTER UPDATE
AS
BEGIN
    DECLARE @当前时间 TIME = CONVERT(TIME, SYSDATETIME());
    IF @当前时间 < '08:00' OR @当前时间 > '18:00'
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50001, N'仅8:00-18:00允许修改作业数据', 1;
    END
END
GO

-- 权限测试
EXECUTE AS USER = 'user_backend';
SELECT * FROM dbo.v_采油一矿作业项目;
REVERT;
GO

-- =============================================
-- 【完整清除脚本】
/*
USE master;
GO
ALTER DATABASE zyxt SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
USE zyxt;
GO

-- 删除触发器
DROP TRIGGER IF EXISTS
dbo.tri_作业_插入算结算,
dbo.tri_作业_更新算结算,
dbo.tri_作业_删除级联明细,
dbo.tri_作业_时段限制更新;
GO

-- 删除存储过程
DROP PROC IF EXISTS dbo.usp_成本运行情况;
GO

-- 删除视图
DROP VIEW IF EXISTS dbo.v_作业材料明细, dbo.v_预算信息, dbo.v_采油一矿作业项目;
GO

-- 删除表
DROP TABLE IF EXISTS dbo.材料消耗明细表,dbo.作业项目表,dbo.物码表,dbo.施工单位表,dbo.油水井表,dbo.单位代码表;
GO

-- 删除角色、用户
DROP ROLE IF EXISTS role_op;
DROP USER IF EXISTS user_backend;
GO

USE master;
DROP LOGIN IF EXISTS login_backend;
DROP DATABASE IF EXISTS zyxt;
GO
*/