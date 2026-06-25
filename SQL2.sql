-- 实验二 SQL练习1 完整脚本（修正版）
-- 功能：采油厂油水井作业成本管理系统建库、建表、数据插入、修改、删除及撤销演示

-- 1. 重建数据库
IF EXISTS(SELECT * FROM sys.databases WHERE name='zyxt')
    DROP DATABASE zyxt;
CREATE DATABASE zyxt;
GO

USE zyxt;
GO

-- 2. 删除可能存在的旧表（保证脚本可重复执行）
IF OBJECT_ID('材料费表','U') IS NOT NULL DROP TABLE 材料费表;
IF OBJECT_ID('作业项目表','U') IS NOT NULL DROP TABLE 作业项目表;
IF OBJECT_ID('油水井表','U') IS NOT NULL DROP TABLE 油水井表;
IF OBJECT_ID('单位代码表','U') IS NOT NULL DROP TABLE 单位代码表;
IF OBJECT_ID('施工单位表','U') IS NOT NULL DROP TABLE 施工单位表;
IF OBJECT_ID('物码表','U') IS NOT NULL DROP TABLE 物码表;
GO

-- 3. 创建基础表
CREATE TABLE 单位代码表(
    单位代码 CHAR(10) PRIMARY KEY,
    单位名称 NVARCHAR(50) NOT NULL
);
GO

CREATE TABLE 油水井表(
    井号 CHAR(10) PRIMARY KEY,
    井别 CHAR(4) NOT NULL,
    单位代码 CHAR(10) NOT NULL
);
GO

CREATE TABLE 施工单位表(
    施工单位名称 NVARCHAR(50) PRIMARY KEY
);
GO

CREATE TABLE 物码表(
    物码 CHAR(10) PRIMARY KEY,
    名称规格 NVARCHAR(50) NOT NULL,
    计量单位 CHAR(10) NOT NULL
);
GO

-- 4. 创建业务表（核心表）
-- 作业项目表：结算字段和入账字段允许NULL，适应不同业务阶段
CREATE TABLE 作业项目表(
    单据号 CHAR(20) PRIMARY KEY,
    预算单位 CHAR(10) NOT NULL,
    井号 CHAR(10) NOT NULL,
    预算金额 MONEY NOT NULL,
    预算人 NVARCHAR(20) NOT NULL,
    预算日期 DATE NOT NULL,
    开工日期 DATE NULL,
    完工日期 DATE NULL,
    施工单位 NVARCHAR(50) NULL,
    施工内容 NVARCHAR(100) NULL,
    材料费 MONEY NULL,
    人工费 MONEY NULL,
    设备费 MONEY NULL,
    其它费用 MONEY NULL,
    结算金额 MONEY NULL,
    结算人 NVARCHAR(20) NULL,
    结算日期 DATE NULL,
    入账金额 MONEY NULL,
    入账人 NVARCHAR(20) NULL,
    入账日期 DATE NULL
);
GO
SELECT *FROM 作业项目表;
CREATE TABLE 材料费表(
    单据号 CHAR(20) NOT NULL,
    物码 CHAR(10) NOT NULL,
    消耗数量 INT NOT NULL,
    单价 MONEY NOT NULL,
    PRIMARY KEY(单据号,物码)
);
GO

-- 5. 插入基础数据
INSERT INTO 单位代码表(单位代码,单位名称) VALUES
('1122','采油厂'),
('112201','采油一矿'),
('112202','采油二矿'),
('112201001','采油一矿一队'),
('112201002','采油一矿二队'),
('112201003','采油一矿三队'),
('112202001','采油二矿一队'),
('112202002','采油二矿二队');
GO

INSERT INTO 油水井表(井号,井别,单位代码) VALUES
('y001','油井','112201001'),
('y002','油井','112201001'),
('y003','油井','112201002'),
('s001','水井','112201002'),
('y004','油井','112201003'),
('s002','水井','112202001'),
('s003','水井','112202001'),
('y005','油井','112202002');
GO

INSERT INTO 施工单位表(施工单位名称) VALUES
('作业公司作业一队'),
('作业公司作业二队'),
('作业公司作业三队');
GO

INSERT INTO 物码表(物码,名称规格,计量单位) VALUES
('wm001','材料一','吨'),
('wm002','材料二','米'),
('wm003','材料三','桶'),
('wm004','材料四','袋');
GO

-- 6. 插入作业项目数据（5条记录，严格匹配实验要求）
-- 6.1 zy2018001（预算+结算+入账）
INSERT INTO 作业项目表 VALUES
('zy2018001','112201001','y001',10000.00,'张三','2018-05-01',
 '2018-05-04','2018-05-25','作业公司作业一队','堵漏',7000.00,
 2500.00,1000.00,1400.00,11900.00,'李四','2018-05-26',
 11900.00,'王五','2018-05-28');

-- 6.2 zy2018002（预算+结算+入账）
INSERT INTO 作业项目表 VALUES
('zy2018002','112201002','y003',11000.00,'张三','2018-05-01',
 '2018-05-04','2018-05-23','作业公司作业二队','检泵',6000.00,
 1500.00,1000.00,2400.00,10900.00,'李四','2018-05-26',
 10900.00,'王五','2018-05-28');

-- 6.3 zy2018003（预算+结算+入账）
INSERT INTO 作业项目表 VALUES
('zy2018003','112201002','s001',10400.00,'张三','2018-05-01',
 '2018-05-06','2018-05-23','作业公司作业二队','调剖',6500.00,
 2000.00,500.00,1400.00,10400.00,'李四','2018-05-26',
 10400.00,'王五','2018-05-28');

-- 6.4 zy2018004（预算+结算+入账）
INSERT INTO 作业项目表 VALUES
('zy2018004','112202001','s002',12000.00,'张三','2018-05-01',
 '2018-05-04','2018-05-24','作业公司作业三队','解堵',6000.00,
 2000.00,1000.00,1600.00,10600.00,'李四','2018-05-26',
 10600.00,'赵六','2018-05-28');

-- 6.5 zy2018005（仅预算+结算，未入账）
INSERT INTO 作业项目表 VALUES
('zy2018005','112202002','y005',12000.00,'张三','2018-05-01',
 '2018-05-04','2018-05-28','作业公司作业三队','防砂',7000.00,
 1000.00,2000.00,1300.00,11300.00,'李四','2018-06-01',
 NULL, NULL, NULL);   -- 入账信息全部置空，表示未入账
GO

-- 7. 插入材料费明细（单价均为10元，数量=金额/10）
-- zy2018001
INSERT INTO 材料费表 VALUES
('zy2018001','wm001',200,10),
('zy2018001','wm002',200,10),
('zy2018001','wm003',200,10),
('zy2018001','wm004',100,10);

-- zy2018002 (材料一、二、三)
INSERT INTO 材料费表 VALUES
('zy2018002','wm001',200,10),
('zy2018002','wm002',200,10),
('zy2018002','wm003',200,10);

-- zy2018003 (材料一、二、三，其中三2500→250个)
INSERT INTO 材料费表 VALUES
('zy2018003','wm001',200,10),
('zy2018003','wm002',200,10),
('zy2018003','wm003',250,10);

-- zy2018004 (材料一、二、四)
INSERT INTO 材料费表 VALUES
('zy2018004','wm001',200,10),
('zy2018004','wm002',200,10),
('zy2018004','wm004',200,10);

-- zy2018005 (材料一、二、四，其中四3000→300个)
INSERT INTO 材料费表 VALUES
('zy2018005','wm001',200,10),
('zy2018005','wm002',200,10),
('zy2018005','wm004',300,10);
GO

-- 8. 查询验证基础数据（可选）
SELECT '单位代码表' AS 表名, * FROM 单位代码表;
SELECT '油水井表', * FROM 油水井表;
SELECT '施工单位表', * FROM 施工单位表;
SELECT '物码表', * FROM 物码表;
SELECT '作业项目表（全部）', * FROM 作业项目表;
SELECT '材料费表', * FROM 材料费表;
GO

-- 9. 实验操作（修改、删除及撤销）
-- 9.1 显示操作前 zy2018004 的数据
PRINT '操作前 zy2018004 的人工费和结算金额：';
SELECT 单据号, 人工费, 结算金额 FROM 作业项目表 WHERE 单据号='zy2018004';

-- 9.2 开启事务，执行修改和删除，再回滚，演示“撤销”
BEGIN TRANSACTION;

    -- (1) 将 zy2018004 的人工费和结算金额增加200
    UPDATE 作业项目表
    SET 人工费 = 人工费 + 200,
        结算金额 = 结算金额 + 200
    WHERE 单据号 = 'zy2018004';

    -- 显示修改后结果
    PRINT '修改后（事务内）zy2018004：';
    SELECT 单据号, 人工费, 结算金额 FROM 作业项目表 WHERE 单据号='zy2018004';

    -- (2) 删除已经结算但未入账的项目（结算金额不为NULL且入账金额为NULL）
    DELETE FROM 作业项目表
    WHERE 结算金额 IS NOT NULL AND 入账金额 IS NULL;

    -- 显示删除后全部记录
    PRINT '删除已结算未入账项目后（事务内）作业项目表全部记录：';
    SELECT * FROM 作业项目表;

-- 9.3 回滚事务，撤销以上修改和删除
ROLLBACK TRANSACTION;
PRINT '回滚事务后，数据恢复原状：';
SELECT * FROM 作业项目表;
GO

-- 10. 最终数据校验
PRINT '最终作业项目表数据：';
SELECT * FROM 作业项目表;
PRINT '最终材料费表数据：';
SELECT * FROM 材料费表;
GO-------------------
USE zyxt;
GO

SELECT * FROM 作业项目表;
GO
IF NOT EXISTS(SELECT *FROM  SYS.INDEXES WHERE NAME='IX_作业项目表_预算日期')
BEGIN
CREATE INDEX IX_作业项目表_预算日期
ON 作业项目表(预算日期);
END;
IF NOT EXISTS(SELECT* FROM SYS.INDEXES WHERE NAME='IX_作业项目表_结算日期')
BEGIN 
CREATE INDEX IX_作业项目表_结算日期 
ON 作业项目表(结算日期);
END;
IF NOT EXISTS(SELECT *FROM SYS.INDEXES WHERE NAME='IX_作业项目表_入账日期')
BEGIN
CREATE INDEX IX_作业项目表_入账日期
ON 作业项目表(入账日期);
END;
GO
-----------------
--⑴ 采油一矿二队2018-5-1到2018-5-28有哪些项目完成了预算，列出相应明细。
SELECT 单据号, 预算单位, 井号, 预算金额, 预算人, 预算日期 FROM 作业项目表 WHERE 预算单位='112201002' AND 预算日期>='2018-05-1' AND 预算日期<'2018-05-29';
--⑵ 采油一矿二队2018-5-1到2018-5-28有哪些项目完成了结算，列出相应明细。
SELECT *FROM 作业项目表 WHERE 预算单位='112201002' AND 结算日期>='2018-05-1' AND 结算日期<'2018-05-29';
--⑶ 采油一矿二队2018-5-1到2018-5-28有哪些项目完成了结算，列出相应的材料费消耗明细。
SELECT ZY.单据号 AS 单据号,
       ZY.施工内容 AS 施工内容,
       WM.名称规格 AS 材料名称,
       CL.消耗数量 AS 消耗数量,
       CL.单价 AS 单价,
       CL.消耗数量 * CL.单价 AS 金额
FROM 作业项目表 AS ZY
JOIN 材料费表 AS CL ON ZY.单据号 = CL.单据号
JOIN 物码表 AS WM ON CL.物码 = WM.物码
WHERE 预算单位 = '112201002'
  AND 结算日期 >= '2018-05-01'
  AND 结算日期 < '2018-05-29';
  --⑷ 采油一矿二队2018-5-1到2018-5-28有哪些项目完成了入账，列出相应明细。
SELECT 单据号, 预算单位, 井号, 入账金额, 入账人, 入账日期 FROM 作业项目表 WHERE 预算单位='112201002' AND 入账日期>='2018-5-1' AND 入账日期<'2018-5-29';
--⑸ 列出采油一矿二队2018-5-1到2018-5-28总的预算金额。
SELECT SUM(预算金额)AS 总的预算金额 FROM 作业项目表 WHERE 预算单位='112201002' AND 预算日期>='2018-05-1' AND 预算日期<'2018-05-29';

--⑹ 列出采油一矿二队2018-5-1到2018-5-28总的结算金额
SELECT SUM(结算金额)AS 总的结算金额 FROM 作业项目表 WHERE 预算单位='112201002' AND 结算日期>='2018-05-1' AND 结算日期<'2018-05-29';

--⑺ 列出采油一矿二队2018-5-1到2018-5-28总的入账金额。
SELECT SUM(入账金额)AS 总的入账金额 FROM 作业项目表 WHERE 预算单位='112201002' AND 入账日期>='2018-05-1' AND 入账日期<'2018-05-29';

--⑻ 列出采油一矿2018-5-1到2018-5-28总的入账金额。
SELECT SUM(入账金额) AS 总入账金额
FROM 作业项目表
WHERE 预算单位 LIKE '112201%'
  AND 入账日期 >= '2018-05-01'
  AND 入账日期 < '2018-05-29';
  --⑼ 有哪些人员参与了入账操作。
SELECT DISTINCT 入账人 FROM 作业项目表 WHERE 入账人 IS NOT NULL
--⑽ 列出2018-5-1到2018-5-28进行了结算但未入账的项目。
SELECT * FROM 作业项目表 WHERE  结算日期>='2018-05-1' AND 结算日期<'2018-05-29' AND 入账日期>'2018-05-29'
--⑾ 列出采油一矿二队的所有项目，按入账金额从高到低排列。
SELECT 单据号, 预算单位, 井号, 入账金额 FROM 作业项目表 WHERE  预算单位='112201002' ORDER BY 入账金额 DESC;
--⑿ 列出有哪些施工单位实施了项目，并计算各单位所有项目结算金额总和。
SELECT 施工单位,SUM(结算金额) AS 结算金额总和 FROM 作业项目表 GROUP BY 施工单位;
--⒀ 找出消耗了材料三且消耗超过了2000元的项目，列出相应消耗明细(利用子查询)。
SELECT 材料费表.单据号,材料费表.物码,消耗数量,单价 FROM 作业项目表 JOIN 材料费表 ON 作业项目表.单据号 = 材料费表.单据号 JOIN 物码表
ON 材料费表.物码 = 物码表.物码 WHERE 名称规格 ='材料三' AND 消耗数量 *单价 >2000;
--⒁ 作业公司二队参与了哪些项目。
SELECT 单据号, 井号, 施工单位 FROM 作业项目表 WHERE 施工单位='作业公司作业二队';
--⒂ 作业公司一队和二队参与了哪些项目（利用union）。
SELECT 单据号, 井号, 施工单位
FROM 作业项目表
WHERE 施工单位 = '作业公司作业一队'
UNION
SELECT 单据号, 井号, 施工单位
FROM 作业项目表
WHERE 施工单位 = '作业公司作业二队'
ORDER BY 施工单位, 单据号;
--⒃ 采油一矿的油井是哪些作业队参与施工的。
SELECT DISTINCT 施工单位
FROM 作业项目表
WHERE 预算单位 LIKE '112201%'   -- 采油一矿及其下属队
  AND 井号 LIKE 'y%';           -- 油井（以 y 开头）


---------------------------------------------------------------------------------
--1.2
GO
DROP INDEX IF EXISTS IX_作业项目表_预算日期 ON 作业项目表
DROP INDEX IF EXISTS  IX_作业项目表_结算日期 ON 作业项目表
DROP INDEX IF EXISTS  IX_作业项目表_入账日期 ON 作业项目表
GO

----------------------------------------------------
-- 3.1 建立数据表：施工单位月度结算表
IF OBJECT_ID('施工单位月度结算表','U') IS NOT NULL
    DROP TABLE 施工单位月度结算表;
GO

CREATE TABLE 施工单位月度结算表(
    施工单位 NVARCHAR(50) NOT NULL,
    年月 CHAR(6) NOT NULL,
    结算金额 MONEY NOT NULL,
    PRIMARY KEY(施工单位, 年月)
);
GO

-- 3.2 用子查询插入各施工单位每月结算金额总和
INSERT INTO 施工单位月度结算表(施工单位, 年月, 结算金额)
SELECT 施工单位,
       CONVERT(CHAR(6), 结算日期, 112) AS 年月,
       SUM(结算金额) AS 结算金额总和
FROM 作业项目表
WHERE 结算日期 IS NOT NULL
GROUP BY 施工单位, CONVERT(CHAR(6), 结算日期, 112);
GO

-- 查看插入结果
SELECT * FROM 施工单位月度结算表;
GO

-- 3.3 带子查询的修改：将采油一矿油井作业项目的结算人改为“李兵”
-- 子查询：筛选采油一矿（单位代码以112201开头）且井号为油井（以'y'开头）的单据号
UPDATE 作业项目表
SET 结算人 = '李兵'
WHERE 单据号 IN (
    SELECT 单据号
    FROM 作业项目表
    WHERE 预算单位 LIKE '112201%'
      AND 井号 LIKE 'y%'
);
GO

-- 验证修改结果
SELECT 单据号, 预算单位, 井号, 结算人
FROM 作业项目表
WHERE 预算单位 LIKE '112201%' AND 井号 LIKE 'y%';
GO

-- 3.4 带子查询的删除：删除采油一矿油井作业项目
DELETE FROM 作业项目表
WHERE 单据号 IN (
    SELECT 单据号
    FROM 作业项目表
    WHERE 预算单位 LIKE '112201%'
      AND 井号 LIKE 'y%'
);
GO

-- 查看删除后的作业项目表
SELECT * FROM 作业项目表;
GO

-- 3.5 撤销上述两个操作（修改和删除）
-- 注意：由于前面操作已真实修改/删除了数据，这里用事务包裹重新演示，最后回滚
-- 首先恢复被删除的数据（重新插入）
INSERT INTO 作业项目表 VALUES
('zy2018001','112201001','y001',10000.00,'张三','2018-05-01',
 '2018-05-04','2018-05-25','作业公司作业一队','堵漏',7000.00,
 2500.00,1000.00,1400.00,11900.00,'李四','2018-05-26',
 11900.00,'王五','2018-05-28'),
('zy2018002','112201002','y003',11000.00,'张三','2018-05-01',
 '2018-05-04','2018-05-23','作业公司作业二队','检泵',6000.00,
 1500.00,1000.00,2400.00,10900.00,'李四','2018-05-26',
 10900.00,'王五','2018-05-28');
GO

-- 开启事务，执行修改和删除，然后回滚（撤销）
BEGIN TRANSACTION;

    -- 修改结算人
    UPDATE 作业项目表
    SET 结算人 = '李兵'
    WHERE 单据号 IN (
        SELECT 单据号
        FROM 作业项目表
        WHERE 预算单位 LIKE '112201%'
          AND 井号 LIKE 'y%'
    );

    -- 删除记录
    DELETE FROM 作业项目表
    WHERE 单据号 IN (
        SELECT 单据号
        FROM 作业项目表
        WHERE 预算单位 LIKE '112201%'
          AND 井号 LIKE 'y%'
    );

    -- 查看事务内的结果（此时修改和删除已生效）
    SELECT '事务内数据' AS 说明, * FROM 作业项目表;

ROLLBACK TRANSACTION;   -- 回滚，撤销所有修改和删除

-- 验证回滚后数据已恢复
SELECT '回滚后数据' AS 说明, * FROM 作业项目表;
GO




--4.11
ALTER TABLE 施工单位月度结算表 ADD 备注 VARCHAR(20);
SELECT *FROM 施工单位月度结算表;
--4.12
ALTER TABLE 施工单位月度结算表 ADD CONSTRAINT K_施工结算 PRIMARY KEY  (施工单位);
INSERT INTO 施工单位月度结算表(施工单位, 年月, 结算金额) 
SELECT 施工单位, 
CONVERT(CHAR(6), 结算日期, 112) AS 年月, 
SUM(结算金额) AS 结算金额总和 
FROM 作业项目表 
WHERE 结算日期 IS NOT NULL 
GROUP BY 施工单位, CONVERT(CHAR(6), 结算日期, 112); 
GO
--4.13 删除表中数据 
DELETE FROM 施工单位月度结算表 ;
SELECT *FROM 施工单位月度结算表;
--4.13 删除表 
DROP  TABLE 施工单位月度结算表 ;


--4.21

 ALTER TABLE 单位代码表 ADD CONSTRAINT  K_单位代码表 PRIMARY KEY (单位代码);
 ALTER TABLE 油水井表 ADD CONSTRAINT K_油水井表 PRIMARY KEY (井号);
 ALTER TABLE 施工单位表 ADD CONSTRAINT K_施工单位表 PRIMARY KEY(施工单位名称);
 ALTER TABLE 物码表 ADD CONSTRAINT K_物码表 PRIMARY KEY (物码);
 ALTER TABLE 作业项目表 ADD CONSTRAINT K_作业项目表 PRIMARY KEY(单据号);
 ALTER TABLE 材料费表 ADD CONSTRAINT K_材料费表 PRIMARY KEY(单据号,物码);
 --1
 insert  into  材料费表  values('zy2018001','wm004',100,10)
--4.21
 insert  into  材料费表  values('zy2018002',NULL,200,10)

 --4.22

  BEGIN TRANSACTION;

 INSERT INTO 油水井表 VALUES('y007','油井','112203002');
 SELECT *FROM 材料费表 ;
 --DELETE FROM 油水井表 WHERE 井号='y007';
 --2
 insert  into  材料费表  values('zy2018007','wm006',100,10)
 SELECT *FROM 材料费表;
 --DELETE 材料费表 WHERE 单据号='ZY2018007';
 --3
 UPDATE 作业项目表 SET 施工单位 ='作业公司作业五队' WHERE 单据号='zy2018001';
 SELECT *FROM 作业项目表;
 --4
  DELETE FROM 单位代码表 WHERE 单位代码='112202002' AND 单位名称='采油二矿二队';
   SELECT *FROM 单位代码表;
 --5

UPDATE 物码表 SET 物码 = 'wm04' WHERE 物码 = 'wm004';
 SELECT *FROM 物码表;
 --6
 ROLLBACK;

 --4.23
 BEGIN TRANSACTION;
-- 1
ALTER TABLE 单位代码表 ALTER COLUMN 单位名称 VARCHAR(50) NOT NULL;
ALTER TABLE 单位代码表 ADD CONSTRAINT uq_单位名称 UNIQUE (单位名称);
--2
ALTER TABLE 油水井表 ADD CHECK (井别 IN('油井' ,'水井'));
--3
ALTER TABLE 物码表 ALTER COLUMN 名称规格 NVARCHAR (50) NOT NULL;
ALTER TABLE 物码表 ADD CONSTRAINT UQ_名称规格 UNIQUE(名称规格);
ALTER TABLE 物码表 ALTER COLUMN 计量单位 CHAR(10) NOT NULL;

--4
ALTER TABLE 材料费表 ALTER COLUMN 消耗数量 INT NOT NULL ;
ALTER TABLE 材料费表 ALTER COLUMN 单据号 MONEY NOT NULL;
--5
-- 1. 金额非负约束
ALTER TABLE 作业项目表
ADD CONSTRAINT CK_预算金额_非负 CHECK (预算金额 >= 0);

ALTER TABLE 作业项目表
ADD CONSTRAINT CK_材料费_非负 CHECK (材料费 >= 0);

ALTER TABLE 作业项目表
ADD CONSTRAINT CK_人工费_非负 CHECK (人工费 >= 0);

ALTER TABLE 作业项目表
ADD CONSTRAINT CK_设备费_非负 CHECK (设备费 >= 0);

ALTER TABLE 作业项目表
ADD CONSTRAINT CK_其它费用_非负 CHECK (其它费用 >= 0);

ALTER TABLE 作业项目表
ADD CONSTRAINT CK_结算金额_非负 CHECK (结算金额 >= 0);

ALTER TABLE 作业项目表
ADD CONSTRAINT CK_入账金额_非负 CHECK (入账金额 IS NULL OR 入账金额 >= 0);

-- 2. 日期顺序约束
ALTER TABLE 作业项目表
ADD CONSTRAINT CK_开工完工日期 CHECK (开工日期 <= 完工日期);

ALTER TABLE 作业项目表
ADD CONSTRAINT CK_预算开工日期 CHECK (预算日期 <= 开工日期);

ALTER TABLE 作业项目表
ADD CONSTRAINT CK_结算完工日期 CHECK (结算日期 >= 完工日期);

ALTER TABLE 作业项目表
ADD CONSTRAINT CK_入账结算日期 CHECK (入账日期 IS NULL OR 入账日期 >= 结算日期);

-- 3. 结算金额 = 各项费用之和
ALTER TABLE 作业项目表
ADD CONSTRAINT CK_结算金额合计 CHECK (结算金额 = 材料费 + 人工费 + 设备费 + 其它费用);

-- 4. 入账信息一致性（有入账金额时，入账人和入账日期必填）
ALTER TABLE 作业项目表
ADD CONSTRAINT CK_入账信息完整 CHECK 
    ((入账金额 IS NULL AND 入账人 IS NULL AND 入账日期 IS NULL)
     OR
     (入账金额 IS NOT NULL AND 入账人 IS NOT NULL AND 入账日期 IS NOT NULL));
 ROLLBACK;

 --4.3
 GO
CREATE VIEW V_作业项目表_材料费表 AS
SELECT 
    A.*,
    B.单据号 AS 材料费单据号,   -- 重名列起别名
    B.物码,
    B.消耗数量,
    B.单价
FROM 作业项目表 A
LEFT JOIN 材料费表 B ON A.单据号 = B.单据号;
GO
--视图的本质是一个查询表，本质就是说我在已有的表的基础上，构造一个具有一定条件的查询表，
--此表没有物理地址只有逻辑地址，本质是中间索引

--3.2材料费单价超过100的记录
SELECT 
    单据号,
    井号,
    施工内容,
    物码,
    消耗数量,
    单价
FROM V_作业项目表_材料费表
WHERE 
  单价 > 1;
  --3.2按预算单位汇总材料消耗总金额，并筛选总金额大于500的单位
  SELECT 
    预算单位,
    SUM(消耗数量 * 单价) AS 材料消耗总额
FROM V_作业项目表_材料费表
WHERE 材料费单据号 IS NOT NULL   -- 仅统计有材料费明细的作业
GROUP BY 预算单位
HAVING SUM(消耗数量 * 单价) > 500;
--3
GO
CREATE VIEW V_作业项目预算状态 AS
SELECT 
    单据号,
    预算单位,
    井号,
    预算金额,
    预算人,
    预算日期
FROM 作业项目表;
GO
BEGIN TRANSACTION 
INSERT INTO V_作业项目预算状态 
VALUES ('zy2018008', '112202002', 'y005', 10000, N'张三', '2018-07-02');
SELECT * FROM 作业项目表 WHERE 单据号 = 'zy2018008';
ROLLBACK
PRINT '========== 1. 事务处理练习 ==========';
-- 将五条插入语句作为一个事务，全部成功则提交，否则回滚并报错
BEGIN TRY
    BEGIN TRANSACTION;

    -- ① 插入作业项目表
    INSERT INTO 作业项目表 VALUES(
        'zy2018006','112202002','y005',
        10000,'张三', '2018-07-01', '2018-07-04', '2018-07-25',
        '作业公司作业一队', '堵漏', 7000, 2500, 1000, 1400, 11900,
        '李四', '2018-07-26', 11900, '王五', '2018-07-28'
    );

    -- ②~⑤ 插入材料费明细
    INSERT INTO 材料费表 VALUES('zy2018006','wm001',200,10);
    INSERT INTO 材料费表 VALUES('zy2018006','wm002',200,10);
    INSERT INTO 材料费表 VALUES('zy2018006','wm003',200,10);
    INSERT INTO 材料费表 VALUES('zy2018006','wm004',100,10);

    COMMIT TRANSACTION;
    PRINT '事务提交成功：五条记录全部插入。';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT '事务回滚，错误信息：' + ERROR_MESSAGE();
END CATCH;
GO

-- 验证事务结果
SELECT * FROM 作业项目表 WHERE 单据号 = 'zy2018006';
SELECT * FROM 材料费表 WHERE 单据号 = 'zy2018006';
GO







PRINT '========== 2. 游标练习 ==========';
-- 定义游标，存放作业项目表全部行，并打印表头和数据
DECLARE cur_作业项目 CURSOR FOR
    SELECT 单据号, 预算单位, 井号, 预算金额, 预算人, 预算日期,
           开工日期, 完工日期, 施工单位, 施工内容,
           材料费, 人工费, 设备费, 其它费用, 结算金额,
           结算人, 结算日期, 入账金额, 入账人, 入账日期
    FROM 作业项目表;

DECLARE @单据号 CHAR(20), @预算单位 CHAR(10), @井号 CHAR(10),
        @预算金额 MONEY, @预算人 NVARCHAR(20), @预算日期 DATE,
        @开工日期 DATE, @完工日期 DATE, @施工单位 NVARCHAR(50),
        @施工内容 NVARCHAR(100), @材料费 MONEY, @人工费 MONEY,
        @设备费 MONEY, @其它费用 MONEY, @结算金额 MONEY,
        @结算人 NVARCHAR(20), @结算日期 DATE,
        @入账金额 MONEY, @入账人 NVARCHAR(20), @入账日期 DATE;

-- 打印表头
PRINT '单据号 预算单位 井号 预算金额 预算人 预算日期 开工日期 完工日期 施工单位 施工内容 材料费 人工费 设备费 其它费用 结算金额 结算人 结算日期 入账金额 入账人 入账日期';

OPEN cur_作业项目;
FETCH NEXT FROM cur_作业项目 INTO
    @单据号, @预算单位, @井号, @预算金额, @预算人, @预算日期,
    @开工日期, @完工日期, @施工单位, @施工内容,
    @材料费, @人工费, @设备费, @其它费用, @结算金额,
    @结算人, @结算日期, @入账金额, @入账人, @入账日期;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT CONCAT(@单据号, ' ', @预算单位, ' ', @井号, ' ',
                 @预算金额, ' ', @预算人, ' ', @预算日期, ' ',
                 @开工日期, ' ', @完工日期, ' ', @施工单位, ' ',
                 @施工内容, ' ', @材料费, ' ', @人工费, ' ',
                 @设备费, ' ', @其它费用, ' ', @结算金额, ' ',
                 @结算人, ' ', @结算日期, ' ',
                 @入账金额, ' ', @入账人, ' ', @入账日期);

    FETCH NEXT FROM cur_作业项目 INTO
        @单据号, @预算单位, @井号, @预算金额, @预算人, @预算日期,
        @开工日期, @完工日期, @施工单位, @施工内容,
        @材料费, @人工费, @设备费, @其它费用, @结算金额,
        @结算人, @结算日期, @入账金额, @入账人, @入账日期;
END;

CLOSE cur_作业项目;
DEALLOCATE cur_作业项目;
GO



PRINT '========== 3. 存储过程 ==========';
-- 创建存储过程，输入单位代码、起始日期、结束日期，输出成本运行情况
IF OBJECT_ID('usp_成本运行情况','P') IS NOT NULL
    DROP PROCEDURE usp_成本运行情况;
GO

CREATE PROCEDURE usp_成本运行情况
    @单位代码 CHAR(10),
    @起始日期 DATE,
    @结束日期 DATE
AS
BEGIN
    -- 查询符合条件的数据：预算单位 LIKE 单位代码%（支持采油厂/矿/队）
    DECLARE @预算金额 MONEY, @结算金额 MONEY, @入账金额 MONEY,
            @未结算金额 MONEY, @未入账金额 MONEY;

    SELECT @预算金额 = SUM(预算金额),
           @结算金额 = SUM(结算金额),
           @入账金额 = SUM(入账金额)
    FROM 作业项目表
    WHERE 预算单位 LIKE @单位代码 + '%'
      AND 预算日期 >= @起始日期
      AND 预算日期 < DATEADD(DAY, 1, @结束日期);   -- 包含结束日期当天

    -- 处理 NULL
    SET @预算金额 = ISNULL(@预算金额, 0);
    SET @结算金额 = ISNULL(@结算金额, 0);
    SET @入账金额 = ISNULL(@入账金额, 0);
    SET @未结算金额 = @预算金额 - @结算金额;
    SET @未入账金额 = @结算金额 - @入账金额;

    -- 输出格式
    PRINT CONCAT('**', @单位代码, ' ', @起始日期, '---', @结束日期, '成本运行情况');
    PRINT '预算金额  结算金额  入账金额  未结算金额  未入账金额';
    PRINT CONCAT(@预算金额, ' ', @结算金额, ' ', @入账金额, ' ', @未结算金额, ' ', @未入账金额);
END;
GO

-- 执行存储过程（三种情况）
PRINT '--- 采油厂 ---';
EXEC usp_成本运行情况 '1122', '2018-05-01', '2018-05-28';

PRINT '--- 采油一矿 ---';
EXEC usp_成本运行情况 '112201', '2018-05-01', '2018-05-28';

PRINT '--- 采油一矿一队 ---';
EXEC usp_成本运行情况 '112201001', '2018-05-01', '2018-05-28';
GO



PRINT '========== 4. 触发器 ==========';
GO

-- 4.1 INSERT 触发器：自动计算结算金额
CREATE TRIGGER trg_作业项目_INSERT
ON 作业项目表
AFTER INSERT
AS
BEGIN
    UPDATE 作业项目表
    SET 结算金额 = i.材料费 + i.人工费 + i.设备费 + i.其它费用
    FROM 作业项目表 zy
    INNER JOIN inserted i ON zy.单据号 = i.单据号
    WHERE i.结算金额 IS NULL OR i.结算金额 <> (i.材料费 + i.人工费 + i.设备费 + i.其它费用);
END;
SELECT * FROM 作业项目表

CREATE TRIGGER trg_作业项目_UPDATE
ON 作业项目表
AFTER UPDATE
AS
BEGIN
    IF UPDATE(材料费) OR UPDATE(人工费) OR UPDATE(设备费) OR UPDATE(其它费用)
    BEGIN
        UPDATE 作业项目表
        SET 结算金额 = i.材料费 + i.人工费 + i.设备费 + i.其它费用
        FROM 作业项目表 zy
        INNER JOIN inserted i ON zy.单据号 = i.单据号;
    END;
END;
GO
SELECT * FROM 作业项目表



-- 4.3 DELETE 触发器：级联删除材料费表中对应的明细
CREATE TRIGGER trg_作业项目_DELETE
ON 作业项目表
AFTER DELETE
AS
BEGIN
    DELETE FROM 材料费表
    WHERE 单据号 IN (SELECT 单据号 FROM deleted);
END;
GO

-- 4.4 验证触发器
PRINT '--- 验证 INSERT 触发器 ---';
-- 插入一条测试记录（不提供结算金额，触发器应自动计算）
INSERT INTO 作业项目表(单据号, 预算单位, 井号, 预算金额, 预算人, 预算日期,
                        开工日期, 完工日期, 施工单位, 施工内容,
                        材料费, 人工费, 设备费, 其它费用,
                        结算人, 结算日期)
VALUES('zy2018010','112201001','y001',10000,'测试','2018-06-01',
       '2018-06-02','2018-06-03','作业公司作业一队','测试触发',
       5000,2000,1000,1000,
       '李兵','2018-06-04');
SELECT 单据号, 材料费, 人工费, 设备费, 其它费用, 结算金额
FROM 作业项目表 WHERE 单据号 = 'zy2018010';
-- 结算金额应等于 5000+2000+1000+1000 = 9000

PRINT '--- 验证 UPDATE 触发器 ---';
UPDATE 作业项目表 SET 材料费 = 6000 WHERE 单据号 = 'zy2018010';
SELECT 单据号, 材料费, 人工费, 设备费, 其它费用, 结算金额
FROM 作业项目表 WHERE 单据号 = 'zy2018010';
-- 结算金额应自动变为 6000+2000+1000+1000 = 10000

PRINT '--- 验证 DELETE 触发器 ---';
-- 先为 zy2018010 添加几条材料费明细
INSERT INTO 材料费表 VALUES('zy2018010','wm001',100,10);
INSERT INTO 材料费表 VALUES('zy2018010','wm002',200,10);
DELETE FROM 作业项目表 WHERE 单据号 = 'zy2018010';
-- 材料费表中对应记录应被自动删除
SELECT * FROM 材料费表 WHERE 单据号 = 'zy2018010';
-- 应返回空结果集

PRINT '========== 实验四全部操作完成 ==========';