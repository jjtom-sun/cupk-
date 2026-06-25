﻿﻿﻿﻿﻿-- =============================================
-- 添加外键约束 (基于 SQLQuery(1).sql 中的设计)
-- 字典表(单位/井/施工单位/物码)使用 NO ACTION 防止误删
-- 材料费表.单据号 使用 CASCADE 自动级联清理明细
-- 作业项目表.施工单位 使用 SET NULL (该列允许 NULL)
-- =============================================

USE zyxt;
GO

-- 1) 油水井表.单位代码 -> 单位代码表.单位代码
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_油水井表_单位代码')
ALTER TABLE dbo.油水井表
ADD CONSTRAINT FK_油水井表_单位代码
FOREIGN KEY (单位代码) REFERENCES dbo.单位代码表(单位代码)
ON UPDATE NO ACTION ON DELETE NO ACTION;
GO

-- 2) 作业项目表.预算单位 -> 单位代码表.单位代码
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_作业项目表_预算单位')
ALTER TABLE dbo.作业项目表
ADD CONSTRAINT FK_作业项目表_预算单位
FOREIGN KEY (预算单位) REFERENCES dbo.单位代码表(单位代码)
ON UPDATE NO ACTION ON DELETE NO ACTION;
GO

-- 3) 作业项目表.井号 -> 油水井表.井号
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_作业项目表_井号')
ALTER TABLE dbo.作业项目表
ADD CONSTRAINT FK_作业项目表_井号
FOREIGN KEY (井号) REFERENCES dbo.油水井表(井号)
ON UPDATE NO ACTION ON DELETE NO ACTION;
GO

-- 4) 作业项目表.施工单位 -> 施工单位表.施工单位名称  (列允许 NULL,使用 SET NULL)
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_作业项目表_施工单位')
ALTER TABLE dbo.作业项目表
ADD CONSTRAINT FK_作业项目表_施工单位
FOREIGN KEY (施工单位) REFERENCES dbo.施工单位表(施工单位名称)
ON UPDATE CASCADE ON DELETE SET NULL;
GO

-- 5) 材料费表.单据号 -> 作业项目表.单据号  (级联删除明细)
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_材料费表_单据号')
ALTER TABLE dbo.材料费表
ADD CONSTRAINT FK_材料费表_单据号
FOREIGN KEY (单据号) REFERENCES dbo.作业项目表(单据号)
ON UPDATE CASCADE ON DELETE CASCADE;
GO

-- 6) 材料费表.物码 -> 物码表.物码
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_材料费表_物码')
ALTER TABLE dbo.材料费表
ADD CONSTRAINT FK_材料费表_物码
FOREIGN KEY (物码) REFERENCES dbo.物码表(物码)
ON UPDATE NO ACTION ON DELETE NO ACTION;
GO

-- 验证
SELECT
    fk.name AS FK_NAME,
    OBJECT_NAME(fk.parent_object_id) AS F_TABLE,
    c1.name AS F_COL,
    OBJECT_NAME(fk.referenced_object_id) AS R_TABLE,
    c2.name AS R_COL,
    fk.delete_referential_action_desc AS ON_DELETE,
    fk.update_referential_action_desc AS ON_UPDATE
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
JOIN sys.columns c1 ON fkc.parent_object_id = c1.object_id AND fkc.parent_column_id = c1.column_id
JOIN sys.columns c2 ON fkc.referenced_object_id = c2.object_id AND fkc.referenced_column_id = c2.column_id
ORDER BY F_TABLE;
GO
