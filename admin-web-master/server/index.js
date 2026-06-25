import express from 'express';
import cors from 'cors';
import sql from 'mssql';

const app = express();
const PORT = 8080;

app.use(cors());
app.use(express.json());

// SQL Server 配置
const dbConfig = {
  server: 'localhost',
  port: 1433,
  database: 'zyxt',
  options: {
    encrypt: false,
    trustServerCertificate: true,
    enableArithAbort: true
  },
  authentication: {
    type: 'default',
    options: {
      userName: 'zyxt_user',
      password: 'zyxt123456'
    }
  }
};

// 连接池
let pool;

async function getPool() {
  if (!pool) {
    pool = await sql.connect(dbConfig);
  }
  return pool;
}

// 测试连接
async function testConnection() {
  try {
    const p = await getPool();
    console.log('SQL Server 连接成功');
    const result = await p.request().query('SELECT @@VERSION as version');
    console.log('数据库版本:', result.recordset[0].version.substring(0, 50));
  } catch (err) {
    console.error('数据库连接失败:', err.message);
  }
}

// 通用响应格式
const success = (data, message = '操作成功') => ({ code: 200, message, data });
const error = (message = '操作失败', code = 500) => ({ code, message, data: null });

// ==================== 登录接口 ====================
app.post('/admin/login', async (req, res) => {
  const { username, password } = req.body;
  if (username === 'admin' && password === 'password') {
    res.json(success({ token: 'Bearer admin-token', username, icon: '', roles: ['admin'] }));
  } else {
    res.json(error('账号或密码错误', 401));
  }
});

app.get('/admin/info', async (req, res) => {
  res.json(success({ username: 'admin', icon: '', roles: ['admin'] }));
});

// ==================== 单位代码表 API ====================
app.get('/dwdm/list', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query('SELECT * FROM 单位代码表 ORDER BY 单位代码');
    res.json(success(result.recordset));
  } catch (err) {
    res.json(error(err.message));
  }
});

app.get('/dwdm/listAll', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query('SELECT * FROM 单位代码表 ORDER BY 单位代码');
    res.json(success(result.recordset));
  } catch (err) {
    res.json(error(err.message));
  }
});

app.post('/dwdm', async (req, res) => {
  try {
    const pool = await getPool();
    const { 单位代码, 单位名称 } = req.body;
    await pool.request()
      .input('单位代码', sql.Char(10), 单位代码)
      .input('单位名称', sql.NVarChar(50), 单位名称)
      .query('INSERT INTO 单位代码表(单位代码,单位名称) VALUES(@单位代码,@单位名称)');
    res.json(success(null));
  } catch (err) {
    res.json(error(err.message));
  }
});

app.put('/dwdm/:code', async (req, res) => {
  try {
    const pool = await getPool();
    const { 单位名称 } = req.body;
    await pool.request()
      .input('单位代码', sql.Char(10), req.params.code)
      .input('单位名称', sql.NVarChar(50), 单位名称)
      .query('UPDATE 单位代码表 SET 单位名称=@单位名称 WHERE 单位代码=@单位代码');
    res.json(success(null));
  } catch (err) {
    res.json(error(err.message));
  }
});

app.delete('/dwdm/:code', async (req, res) => {
  try {
    const pool = await getPool();
    await pool.request()
      .input('单位代码', sql.Char(10), req.params.code)
      .query('DELETE FROM 单位代码表 WHERE 单位代码=@单位代码');
    res.json(success(null));
  } catch (err) {
    res.json(error(err.message));
  }
});

// ==================== 油水井表 API ====================
app.get('/ysj/list', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query('SELECT * FROM 油水井表 ORDER BY 井号');
    res.json(success(result.recordset));
  } catch (err) {
    res.json(error(err.message));
  }
});

app.get('/ysj/listAll', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query('SELECT 井号,井别,单位代码 FROM 油水井表 ORDER BY 井号');
    res.json(success(result.recordset));
  } catch (err) {
    res.json(error(err.message));
  }
});

app.post('/ysj', async (req, res) => {
  try {
    const pool = await getPool();
    const { 井号, 井别, 单位代码 } = req.body;
    await pool.request()
      .input('井号', sql.Char(10), 井号)
      .input('井别', sql.Char(4), 井别)
      .input('单位代码', sql.Char(10), 单位代码)
      .query('INSERT INTO 油水井表(井号,井别,单位代码) VALUES(@井号,@井别,@单位代码)');
    res.json(success(null));
  } catch (err) {
    res.json(error(err.message));
  }
});

app.put('/ysj/:id', async (req, res) => {
  try {
    const pool = await getPool();
    const { 井别, 单位代码 } = req.body;
    await pool.request()
      .input('井号', sql.Char(10), req.params.id)
      .input('井别', sql.Char(4), 井别)
      .input('单位代码', sql.Char(10), 单位代码)
      .query('UPDATE 油水井表 SET 井别=@井别,单位代码=@单位代码 WHERE 井号=@井号');
    res.json(success(null));
  } catch (err) {
    res.json(error(err.message));
  }
});

app.delete('/ysj/:id', async (req, res) => {
  try {
    const pool = await getPool();
    await pool.request()
      .input('井号', sql.Char(10), req.params.id)
      .query('DELETE FROM 油水井表 WHERE 井号=@井号');
    res.json(success(null));
  } catch (err) {
    res.json(error(err.message));
  }
});

// ==================== 施工单位表 API ====================
app.get('/sgdw/list', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query('SELECT * FROM 施工单位表 ORDER BY 施工单位名称');
    res.json(success(result.recordset));
  } catch (err) {
    res.json(error(err.message));
  }
});

app.get('/sgdw/listAll', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query('SELECT 施工单位名称 FROM 施工单位表 ORDER BY 施工单位名称');
    res.json(success(result.recordset));
  } catch (err) {
    res.json(error(err.message));
  }
});

app.post('/sgdw', async (req, res) => {
  try {
    const pool = await getPool();
    const { 施工单位名称 } = req.body;
    await pool.request()
      .input('施工单位名称', sql.NVarChar(50), 施工单位名称)
      .query('INSERT INTO 施工单位表(施工单位名称) VALUES(@施工单位名称)');
    res.json(success(null));
  } catch (err) {
    res.json(error(err.message));
  }
});

app.put('/sgdw/:name', async (req, res) => {
  try {
    const pool = await getPool();
    const { 施工单位名称 } = req.body;
    await pool.request()
      .input('旧名称', sql.NVarChar(50), req.params.name)
      .input('新名称', sql.NVarChar(50), 施工单位名称)
      .query('UPDATE 施工单位表 SET 施工单位名称=@新名称 WHERE 施工单位名称=@旧名称');
    res.json(success(null));
  } catch (err) {
    res.json(error(err.message));
  }
});

app.delete('/sgdw/:name', async (req, res) => {
  try {
    const pool = await getPool();
    await pool.request()
      .input('施工单位名称', sql.NVarChar(50), req.params.name)
      .query('DELETE FROM 施工单位表 WHERE 施工单位名称=@施工单位名称');
    res.json(success(null));
  } catch (err) {
    res.json(error(err.message));
  }
});

// ==================== 物码表 API ====================
app.get('/wm/list', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query('SELECT * FROM 物码表 ORDER BY 物码');
    res.json(success(result.recordset));
  } catch (err) {
    res.json(error(err.message));
  }
});

app.get('/wm/listAll', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query('SELECT 物码,名称规格,计量单位 FROM 物码表 ORDER BY 物码');
    res.json(success(result.recordset));
  } catch (err) {
    res.json(error(err.message));
  }
});

app.post('/wm', async (req, res) => {
  try {
    const pool = await getPool();
    const { 物码, 名称规格, 计量单位 } = req.body;
    await pool.request()
      .input('物码', sql.Char(10), 物码)
      .input('名称规格', sql.NVarChar(50), 名称规格)
      .input('计量单位', sql.Char(10), 计量单位)
      .query('INSERT INTO 物码表(物码,名称规格,计量单位) VALUES(@物码,@名称规格,@计量单位)');
    res.json(success(null));
  } catch (err) {
    res.json(error(err.message));
  }
});

app.put('/wm/:code', async (req, res) => {
  try {
    const pool = await getPool();
    const { 名称规格, 计量单位 } = req.body;
    await pool.request()
      .input('物码', sql.Char(10), req.params.code)
      .input('名称规格', sql.NVarChar(50), 名称规格)
      .input('计量单位', sql.Char(10), 计量单位)
      .query('UPDATE 物码表 SET 名称规格=@名称规格,计量单位=@计量单位 WHERE 物码=@物码');
    res.json(success(null));
  } catch (err) {
    res.json(error(err.message));
  }
});

app.delete('/wm/:code', async (req, res) => {
  try {
    const pool = await getPool();
    await pool.request()
      .input('物码', sql.Char(10), req.params.code)
      .query('DELETE FROM 物码表 WHERE 物码=@物码');
    res.json(success(null));
  } catch (err) {
    res.json(error(err.message));
  }
});

// ==================== 作业项目表 API ====================
app.get('/zyxm/list', async (req, res) => {
  try {
    const pool = await getPool();
    const { pageNum = 1, pageSize = 10, 单据号, 预算单位, 井号, 施工单位 } = req.query;

    let query = 'SELECT * FROM 作业项目表 WHERE 1=1';
    const request = pool.request();

    if (单据号) {
      query += ' AND 单据号 LIKE @单据号';
      request.input('单据号', sql.NVarChar, `%${单据号}%`);
    }
    if (预算单位) {
      query += ' AND 预算单位 LIKE @预算单位';
      request.input('预算单位', sql.NVarChar, `%${预算单位}%`);
    }
    if (井号) {
      query += ' AND 井号 LIKE @井号';
      request.input('井号', sql.NVarChar, `%${井号}%`);
    }
    if (施工单位) {
      query += ' AND 施工单位 LIKE @施工单位';
      request.input('施工单位', sql.NVarChar, `%${施工单位}%`);
    }

    query += ' ORDER BY 预算日期 DESC';

    const result = await request.query(query);
    const total = result.recordset.length;
    const start = (parseInt(pageNum) - 1) * parseInt(pageSize);
    const records = result.recordset.slice(start, start + parseInt(pageSize));

    res.json(success({ list: records, total, pageNum: parseInt(pageNum), pageSize: parseInt(pageSize) }));
  } catch (err) {
    res.json(error(err.message));
  }
});

// 作业项目综合查询（多条件）— 必须在 /zyxm/:id 之前注册，避免被动态路由吞掉
app.get('/zyxm/search', async (req, res) => {
  try {
    const pool = await getPool();
    const { 单据号, 预算单位, 井号, 施工单位, 项目状态, 开始日期, 结束日期, 超支, 关键字 } = req.query;
    let q = `
      SELECT z.*,
        CASE WHEN z.结算金额 IS NOT NULL AND z.预算金额 IS NOT NULL AND z.结算金额>z.预算金额
             THEN 1 ELSE 0 END AS 超支
      FROM 作业项目表 z WHERE 1=1
    `;
    const r = pool.request();
    if (单据号)   { q += ' AND z.单据号=@单据号';   r.input('单据号',   sql.Char(20),  单据号); }
    if (预算单位) { q += ' AND z.预算单位=@预算单位'; r.input('预算单位', sql.Char(10),  预算单位); }
    if (井号)     { q += ' AND z.井号=@井号';       r.input('井号',     sql.Char(10),  井号); }
    if (施工单位) { q += ' AND z.施工单位=@施工单位'; r.input('施工单位', sql.NVarChar(50), 施工单位); }
    if (项目状态) { q += ' AND z.项目状态=@项目状态'; r.input('项目状态', sql.NVarChar(10), 项目状态); }
    if (开始日期) { q += ' AND z.预算日期>=@开始日期'; r.input('开始日期', sql.Date, 开始日期); }
    if (结束日期) { q += ' AND z.预算日期<=@结束日期'; r.input('结束日期', sql.Date, 结束日期); }
    if (超支 === '1') q += ' AND z.结算金额 IS NOT NULL AND z.预算金额 IS NOT NULL AND z.结算金额>z.预算金额';
    if (关键字) {
      q += ' AND (z.单据号 LIKE @kw OR z.井号 LIKE @kw OR z.施工单位 LIKE @kw OR z.施工内容 LIKE @kw)';
      r.input('kw', sql.NVarChar, '%' + 关键字 + '%');
    }
    q += ' ORDER BY z.预算日期 DESC, z.单据号';
    const result = await r.query(q);
    res.json(success(result.recordset));
  } catch (err) { res.json(error(err.message)); }
});

app.get('/zyxm/:id', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('单据号', sql.Char(20), req.params.id)
      .query('SELECT * FROM 作业项目表 WHERE 单据号=@单据号');
    res.json(success(result.recordset[0]));
  } catch (err) {
    res.json(error(err.message));
  }
});

app.post('/zyxm', async (req, res) => {
  try {
    const pool = await getPool();
    const d = req.body;
    await pool.request()
      .input('单据号', sql.Char(20), d.单据号)
      .input('预算单位', sql.Char(10), d.预算单位)
      .input('井号', sql.Char(10), d.井号)
      .input('预算金额', sql.Money, d.预算金额)
      .input('预算人', sql.NVarChar(20), d.预算人)
      .input('预算日期', sql.Date, d.预算日期)
      .input('开工日期', sql.Date, d.开工日期 || null)
      .input('完工日期', sql.Date, d.完工日期 || null)
      .input('施工单位', sql.NVarChar(50), d.施工单位 || null)
      .input('施工内容', sql.NVarChar(100), d.施工内容 || null)
      .input('材料费', sql.Money, d.材料费 || null)
      .input('人工费', sql.Money, d.人工费 || null)
      .input('设备费', sql.Money, d.设备费 || null)
      .input('其它费用', sql.Money, d.其它费用 || null)
      .input('结算金额', sql.Money, d.结算金额 || null)
      .input('结算人', sql.NVarChar(20), d.结算人 || null)
      .input('结算日期', sql.Date, d.结算日期 || null)
      .input('入账金额', sql.Money, d.入账金额 || null)
      .input('入账人', sql.NVarChar(20), d.入账人 || null)
      .input('入账日期', sql.Date, d.入账日期 || null)
      .query(`INSERT INTO 作业项目表(单据号,预算单位,井号,预算金额,预算人,预算日期,开工日期,完工日期,施工单位,施工内容,材料费,人工费,设备费,其它费用,结算金额,结算人,结算日期,入账金额,入账人,入账日期) 
              VALUES(@单据号,@预算单位,@井号,@预算金额,@预算人,@预算日期,@开工日期,@完工日期,@施工单位,@施工内容,@材料费,@人工费,@设备费,@其它费用,@结算金额,@结算人,@结算日期,@入账金额,@入账人,@入账日期)`);
    res.json(success(null));
  } catch (err) {
    res.json(error(err.message));
  }
});

app.put('/zyxm/:id', async (req, res) => {
  try {
    const pool = await getPool();
    const d = req.body;
    await pool.request()
      .input('单据号', sql.Char(20), req.params.id)
      .input('预算单位', sql.Char(10), d.预算单位)
      .input('井号', sql.Char(10), d.井号)
      .input('预算金额', sql.Money, d.预算金额)
      .input('预算人', sql.NVarChar(20), d.预算人)
      .input('预算日期', sql.Date, d.预算日期)
      .input('开工日期', sql.Date, d.开工日期 || null)
      .input('完工日期', sql.Date, d.完工日期 || null)
      .input('施工单位', sql.NVarChar(50), d.施工单位 || null)
      .input('施工内容', sql.NVarChar(100), d.施工内容 || null)
      .input('材料费', sql.Money, d.材料费 || null)
      .input('人工费', sql.Money, d.人工费 || null)
      .input('设备费', sql.Money, d.设备费 || null)
      .input('其它费用', sql.Money, d.其它费用 || null)
      .input('结算金额', sql.Money, d.结算金额 || null)
      .input('结算人', sql.NVarChar(20), d.结算人 || null)
      .input('结算日期', sql.Date, d.结算日期 || null)
      .input('入账金额', sql.Money, d.入账金额 || null)
      .input('入账人', sql.NVarChar(20), d.入账人 || null)
      .input('入账日期', sql.Date, d.入账日期 || null)
      .query(`UPDATE 作业项目表 SET 预算单位=@预算单位,井号=@井号,预算金额=@预算金额,预算人=@预算人,预算日期=@预算日期,
              开工日期=@开工日期,完工日期=@完工日期,施工单位=@施工单位,施工内容=@施工内容,材料费=@材料费,人工费=@人工费,
              设备费=@设备费,其它费用=@其它费用,结算金额=@结算金额,结算人=@结算人,结算日期=@结算日期,
              入账金额=@入账金额,入账人=@入账人,入账日期=@入账日期 WHERE 单据号=@单据号`);
    res.json(success(null));
  } catch (err) {
    res.json(error(err.message));
  }
});

app.delete('/zyxm/:id', async (req, res) => {
  try {
    const pool = await getPool();
    await pool.request()
      .input('单据号', sql.Char(20), req.params.id)
      .query('DELETE FROM 作业项目表 WHERE 单据号=@单据号');
    res.json(success(null));
  } catch (err) {
    res.json(error(err.message));
  }
});

// ==================== 材料费表 API ====================
app.get('/clf/list', async (req, res) => {
  try {
    const pool = await getPool();
    const { 单据号 } = req.query;
    let sql = `SELECT A.*, B.名称规格, B.计量单位 FROM 材料费表 A LEFT JOIN 物码表 B ON A.物码=B.物码 WHERE 1=1`;
    const request = pool.request();
    
    if (单据号) {
      sql += ' AND A.单据号=@单据号';
      request.input('单据号', sql.Char(20), 单据号);
    }
    
    sql += ' ORDER BY A.单据号, A.物码';
    const result = await request.query(sql);
    res.json(success(result.recordset));
  } catch (err) {
    res.json(error(err.message));
  }
});

app.post('/clf', async (req, res) => {
  try {
    const pool = await getPool();
    const { 单据号, 物码, 消耗数量, 单价 } = req.body;
    await pool.request()
      .input('单据号', sql.Char(20), 单据号)
      .input('物码', sql.Char(10), 物码)
      .input('消耗数量', sql.Int, 消耗数量)
      .input('单价', sql.Money, 单价)
      .query('INSERT INTO 材料费表(单据号,物码,消耗数量,单价) VALUES(@单据号,@物码,@消耗数量,@单价)');
    res.json(success(null));
  } catch (err) {
    res.json(error(err.message));
  }
});

app.put('/clf', async (req, res) => {
  try {
    const pool = await getPool();
    const { 单据号, 物码, 消耗数量, 单价 } = req.body;
    await pool.request()
      .input('单据号', sql.Char(20), 单据号)
      .input('物码', sql.Char(10), 物码)
      .input('消耗数量', sql.Int, 消耗数量)
      .input('单价', sql.Money, 单价)
      .query('UPDATE 材料费表 SET 消耗数量=@消耗数量,单价=@单价 WHERE 单据号=@单据号 AND 物码=@物码');
    res.json(success(null));
  } catch (err) {
    res.json(error(err.message));
  }
});

app.delete('/clf', async (req, res) => {
  try {
    const pool = await getPool();
    const { 单据号, 物码 } = req.body;
    await pool.request()
      .input('单据号', sql.Char(20), 单据号)
      .input('物码', sql.Char(10), 物码)
      .query('DELETE FROM 材料费表 WHERE 单据号=@单据号 AND 物码=@物码');
    res.json(success(null));
  } catch (err) {
    res.json(error(err.message));
  }
});

// ==================== 统计查询 API ====================
app.get('/tj/summary', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT 
        (SELECT COUNT(*) FROM 作业项目表) AS totalProjects,
        (SELECT SUM(预算金额) FROM 作业项目表) AS totalBudget,
        (SELECT SUM(结算金额) FROM 作业项目表 WHERE 结算金额 IS NOT NULL) AS totalSettlement,
        (SELECT SUM(入账金额) FROM 作业项目表 WHERE 入账金额 IS NOT NULL) AS totalAccount,
        (SELECT COUNT(*) FROM 油水井表) AS wellCount,
        (SELECT COUNT(*) FROM 施工单位表) AS contractorCount
    `);
    res.json(success(result.recordset[0]));
  } catch (err) {
    res.json(error(err.message));
  }
});

app.get('/tj/byUnit', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT 预算单位, 
             COUNT(*) AS 项目数,
             SUM(预算金额) AS 预算总额,
             SUM(ISNULL(结算金额,0)) AS 结算总额,
             SUM(ISNULL(入账金额,0)) AS 入账总额
      FROM 作业项目表 
      GROUP BY 预算单位 
      ORDER BY 预算单位
    `);
    res.json(success(result.recordset));
  } catch (err) {
    res.json(error(err.message));
  }
});

app.get('/tj/byContractor', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT 施工单位, 
             COUNT(*) AS 项目数,
             SUM(ISNULL(结算金额,0)) AS 结算总额
      FROM 作业项目表 
      WHERE 施工单位 IS NOT NULL
      GROUP BY 施工单位 
      ORDER BY 结算总额 DESC
    `);
    res.json(success(result.recordset));
  } catch (err) {
    res.json(error(err.message));
  }
});

// 启动服务
app.listen(PORT, async () => {
  console.log(`服务器启动成功，端口: ${PORT}`);
  await testConnection();
});

// ==================== 数据库元信息 API ====================
app.get('/meta/tables', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT 
        t.name AS tableName,
        CAST(ISNULL(p.rows, 0) AS INT) AS [rowCount],
        CAST(ISNULL(SUM(a.total_pages) * 8 / 1024.0, 0) AS FLOAT) AS sizeMb
      FROM sys.tables t
      LEFT JOIN sys.indexes i ON t.object_id = i.object_id
      LEFT JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
      LEFT JOIN sys.allocation_units a ON p.partition_id = a.container_id
      WHERE t.is_ms_shipped = 0
      GROUP BY t.name, p.rows
      ORDER BY t.name
    `);
    res.json(success(result.recordset));
  } catch (err) {
    res.json(error(err.message));
  }
});

app.get('/meta/tables/:name', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('tableName', sql.NVarChar(128), req.params.name)
      .query(`
        SELECT 
          c.name AS columnName,
          TYPE_NAME(c.user_type_id) AS dataType,
          c.max_length AS maxLength,
          c.is_nullable AS isNullable,
          ISNULL(dc.definition, '') AS defaultValue,
          c.is_identity AS isIdentity
        FROM sys.columns c
        LEFT JOIN sys.default_constraints dc 
          ON c.object_id = dc.parent_object_id AND c.column_id = dc.parent_column_id
        WHERE c.object_id = OBJECT_ID(@tableName)
        ORDER BY c.column_id
      `);
    res.json(success(result.recordset));
  } catch (err) {
    res.json(error(err.message));
  }
});

app.get('/meta/constraints', async (req, res) => {
  try {
    const pool = await getPool();

    const pk = await pool.request().query(`
      SELECT 
        i.name AS constraintName,
        OBJECT_NAME(i.object_id) AS tableName,
        STRING_AGG(c.name, ', ') AS columnName
      FROM sys.indexes i
      INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
      INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
      INNER JOIN sys.tables t ON i.object_id = t.object_id
      WHERE i.is_primary_key = 1 AND t.is_ms_shipped = 0
      GROUP BY i.name, OBJECT_NAME(i.object_id)
      ORDER BY OBJECT_NAME(i.object_id)
    `);

    const fk = await pool.request().query(`
      SELECT 
        fk.name AS constraintName,
        OBJECT_NAME(fk.parent_object_id) AS tableName,
        c1.name AS columnName,
        OBJECT_NAME(fk.referenced_object_id) AS referencedTable,
        c2.name AS referencedColumn
      FROM sys.foreign_keys fk
      INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
      INNER JOIN sys.columns c1 ON fkc.parent_object_id = c1.object_id AND fkc.parent_column_id = c1.column_id
      INNER JOIN sys.columns c2 ON fkc.referenced_object_id = c2.object_id AND fkc.referenced_column_id = c2.column_id
      INNER JOIN sys.tables t ON fk.parent_object_id = t.object_id
      WHERE t.is_ms_shipped = 0
      ORDER BY OBJECT_NAME(fk.parent_object_id)
    `);

    const uq = await pool.request().query(`
      SELECT 
        i.name AS constraintName,
        OBJECT_NAME(i.object_id) AS tableName,
        STRING_AGG(c.name, ', ') AS columnName
      FROM sys.indexes i
      INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
      INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
      INNER JOIN sys.tables t ON i.object_id = t.object_id
      WHERE i.is_unique = 1 AND i.is_primary_key = 0 AND t.is_ms_shipped = 0
      GROUP BY i.name, OBJECT_NAME(i.object_id)
      ORDER BY OBJECT_NAME(i.object_id)
    `);

    const ck = await pool.request().query(`
      SELECT 
        cc.name AS constraintName,
        OBJECT_NAME(cc.parent_object_id) AS tableName,
        cc.definition AS definitionText
      FROM sys.check_constraints cc
      INNER JOIN sys.tables t ON cc.parent_object_id = t.object_id
      WHERE t.is_ms_shipped = 0
      ORDER BY OBJECT_NAME(cc.parent_object_id)
    `);

    const df = await pool.request().query(`
      SELECT 
        dc.name AS constraintName,
        OBJECT_NAME(dc.parent_object_id) AS tableName,
        c.name AS columnName,
        dc.definition AS definitionText
      FROM sys.default_constraints dc
      INNER JOIN sys.columns c ON dc.parent_object_id = c.object_id AND dc.parent_column_id = c.column_id
      INNER JOIN sys.tables t ON dc.parent_object_id = t.object_id
      WHERE t.is_ms_shipped = 0
      ORDER BY OBJECT_NAME(dc.parent_object_id)
    `);

    res.json(success({
      primaryKey: pk.recordset,
      foreignKey: fk.recordset,
      unique: uq.recordset,
      check: ck.recordset,
      default: df.recordset,
    }));
  } catch (err) {
    res.json(error(err.message));
  }
});

app.get('/meta/overview', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT 
        (SELECT COUNT(*) FROM sys.tables WHERE is_ms_shipped = 0) AS tableCount,
        (SELECT COUNT(*) FROM sys.columns c 
         JOIN sys.tables t ON c.object_id = t.object_id 
         WHERE t.is_ms_shipped = 0) AS columnCount,
        CAST((SELECT ISNULL(SUM(p.rows), 0) FROM sys.partitions p 
         JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
         JOIN sys.tables t ON i.object_id = t.object_id
         WHERE t.is_ms_shipped = 0 AND i.index_id IN (0, 1)) AS INT) AS totalRows,
        CAST((SELECT ISNULL(SUM(a.total_pages) * 8 / 1024.0, 0) 
         FROM sys.allocation_units a 
         JOIN sys.partitions p ON a.container_id = p.partition_id
         JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
         JOIN sys.tables t ON i.object_id = t.object_id
         WHERE t.is_ms_shipped = 0) AS FLOAT) AS totalSizeMb,
        (SELECT COUNT(*) FROM sys.foreign_keys fk 
         JOIN sys.tables t ON fk.parent_object_id = t.object_id 
         WHERE t.is_ms_shipped = 0) AS fkCount,
        (SELECT COUNT(*) FROM sys.indexes i JOIN sys.tables t ON i.object_id = t.object_id
         WHERE i.is_primary_key = 1 AND t.is_ms_shipped = 0) AS pkCount
    `);
    res.json(success(result.recordset[0]));
  } catch (err) {
    res.json(error(err.message));
  }
});

// =============================================================
// 系统重构：业务增强 API
// =============================================================

// 仪表盘总览
app.get('/dash/overview', async (req, res) => {
  try {
    const pool = await getPool();
    const r = await pool.request().query(`
      SELECT
        (SELECT COUNT(*) FROM 作业项目表) AS totalProjects,
        (SELECT ISNULL(SUM(预算金额),0) FROM 作业项目表) AS totalBudget,
        (SELECT ISNULL(SUM(结算金额),0) FROM 作业项目表 WHERE 结算金额 IS NOT NULL) AS totalSettlement,
        (SELECT ISNULL(SUM(入账金额),0) FROM 作业项目表 WHERE 入账金额 IS NOT NULL) AS totalAccount,
        (SELECT COUNT(*) FROM 作业项目表 WHERE 项目状态=N'已预算') AS cntBudget,
        (SELECT COUNT(*) FROM 作业项目表 WHERE 项目状态=N'施工中') AS cntConstruction,
        (SELECT COUNT(*) FROM 作业项目表 WHERE 项目状态=N'已完工') AS cntDone,
        (SELECT COUNT(*) FROM 作业项目表 WHERE 项目状态=N'已结算') AS cntSettled,
        (SELECT COUNT(*) FROM 作业项目表 WHERE 项目状态=N'已入账') AS cntAccounted,
        (SELECT COUNT(*) FROM 作业项目表 WHERE 结算金额 IS NOT NULL AND 预算金额 IS NOT NULL AND 结算金额>预算金额) AS cntOverBudget,
        (SELECT COUNT(*) FROM 油水井表) AS wellCount,
        (SELECT COUNT(*) FROM 单位代码表) AS unitCount,
        (SELECT COUNT(*) FROM 施工单位表) AS contractorCount,
        (SELECT COUNT(*) FROM 物码表) AS materialCount
    `);
    res.json(success(r.recordset[0]));
  } catch (err) { res.json(error(err.message)); }
});

// 月度成本趋势（最近 12 个月）
app.get('/dash/trend', async (req, res) => {
  try {
    const pool = await getPool();
    const r = await pool.request().query(`
      WITH 月 AS (
        SELECT TOP 12
          FORMAT(DATEADD(MONTH, -n, GETDATE()),'yyyy-MM') AS 月份
        FROM (VALUES(0),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11)) t(n)
        ORDER BY n
      )
      SELECT m.月份,
             ISNULL(SUM(预算金额),0) AS 预算,
             ISNULL(SUM(结算金额),0) AS 结算,
             ISNULL(SUM(入账金额),0) AS 入账
      FROM 月 m
      LEFT JOIN 作业项目表 z
        ON FORMAT(ISNULL(z.结算日期,z.预算日期),'yyyy-MM') = m.月份
      GROUP BY m.月份
      ORDER BY m.月份;
    `);
    res.json(success(r.recordset));
  } catch (err) { res.json(error(err.message)); }
});

// 状态分布（饼图）
app.get('/dash/statusPie', async (req, res) => {
  try {
    const pool = await getPool();
    const r = await pool.request().query(`
      SELECT 项目状态 AS name, COUNT(*) AS value
      FROM 作业项目表 GROUP BY 项目状态 ORDER BY 项目状态;
    `);
    res.json(success(r.recordset));
  } catch (err) { res.json(error(err.message)); }
});

// 各单位成本占比
app.get('/dash/unitPie', async (req, res) => {
  try {
    const pool = await getPool();
    const r = await pool.request().query(`
      SELECT d.单位名称 AS name, ISNULL(SUM(z.预算金额),0) AS value
      FROM 单位代码表 d
      LEFT JOIN 作业项目表 z ON z.预算单位 = d.单位代码
      GROUP BY d.单位代码, d.单位名称
      ORDER BY value DESC;
    `);
    res.json(success(r.recordset));
  } catch (err) { res.json(error(err.message)); }
});

// 状态流转
app.post('/zyxm/:id/status', async (req, res) => {
  try {
    const pool = await getPool();
    const { 项目状态, 开工日期, 完工日期, 结算金额, 结算人, 结算日期, 入账金额, 入账人, 入账日期 } = req.body;
    const r = pool.request().input('单据号', sql.Char(20), req.params.id);
    const sets = [];
    if (项目状态)   { sets.push('项目状态=@项目状态'); r.input('项目状态', sql.NVarChar(10), 项目状态); }
    if (开工日期 !== undefined) { sets.push('开工日期=@开工日期'); r.input('开工日期', sql.Date, 开工日期 || null); }
    if (完工日期 !== undefined) { sets.push('完工日期=@完工日期'); r.input('完工日期', sql.Date, 完工日期 || null); }
    if (结算金额 !== undefined) { sets.push('结算金额=@结算金额'); r.input('结算金额', sql.Money, 结算金额 || null); }
    if (结算人   !== undefined) { sets.push('结算人=@结算人');     r.input('结算人',   sql.NVarChar(20), 结算人 || null); }
    if (结算日期 !== undefined) { sets.push('结算日期=@结算日期'); r.input('结算日期', sql.Date, 结算日期 || null); }
    if (入账金额 !== undefined) { sets.push('入账金额=@入账金额'); r.input('入账金额', sql.Money, 入账金额 || null); }
    if (入账人   !== undefined) { sets.push('入账人=@入账人');     r.input('入账人',   sql.NVarChar(20), 入账人 || null); }
    if (入账日期 !== undefined) { sets.push('入账日期=@入账日期'); r.input('入账日期', sql.Date, 入账日期 || null); }
    if (!sets.length) return res.json(error('无可更新字段'));
    await r.query('UPDATE 作业项目表 SET ' + sets.join(',') + ' WHERE 单据号=@单据号');
    res.json(success(null));
  } catch (err) { res.json(error(err.message)); }
});

// 状态码选项
app.get('/util/statusOptions', async (req, res) => {
  res.json(success(['已预算','施工中','已完工','已结算','已入账']));
});

// ==================== 统计增强 API ====================
app.get('/tj/costRun', async (req, res) => {
  try {
    const pool = await getPool();
    const r = await pool.request().query(`
      SELECT d.单位代码, d.单位名称, v.*
      FROM v_成本运行情况 v JOIN 单位代码表 d ON v.预算单位 = d.单位代码
      ORDER BY d.单位代码;
    `);
    res.json(success(r.recordset));
  } catch (err) { res.json(error(err.message)); }
});

app.get('/tj/costRunProc', async (req, res) => {
  try {
    const pool = await getPool();
    const { 单位代码, 起始日期, 结束日期 } = req.query;
    const r = pool.request()
      .input('单位代码', sql.NVarChar(20), 单位代码 || '')
      .input('起始日期', sql.Date, 起始日期 || '1900-01-01')
      .input('结束日期', sql.Date, 结束日期 || '9999-12-31');
    const result = await r.execute('usp_成本运行情况');
    // mssql 返回多个 resultSets
    const records = result.recordsets && result.recordsets[0] ? result.recordsets[0] : [];
    // 第二个 recordset 是 PRINT 输出，我们只返回数据
    res.json(success(records));
  } catch (err) { res.json(error(err.message)); }
});

app.get('/tj/monthly', async (req, res) => {
  try {
    const pool = await getPool();
    const { 年份 = new Date().getFullYear() } = req.query;
    const r = await pool.request()
      .input('年份', sql.Int, parseInt(年份))
      .query('EXEC usp_月度结算统计 @年份');
    res.json(success(r.recordset));
  } catch (err) { res.json(error(err.message)); }
});

app.get('/tj/costStructure', async (req, res) => {
  try {
    const pool = await getPool();
    const { 起始日期 = '1900-01-01', 结束日期 = '9999-12-31' } = req.query;
    const r = await pool.request()
      .input('起始日期', sql.Date, 起始日期)
      .input('结束日期', sql.Date, 结束日期)
      .query('EXEC usp_成本构成分析 @起始日期, @结束日期');
    res.json(success(r.recordset));
  } catch (err) { res.json(error(err.message)); }
});

app.get('/tj/overBudget', async (req, res) => {
  try {
    const pool = await getPool();
    const r = await pool.request().query('EXEC usp_预算超支项目');
    res.json(success(r.recordset));
  } catch (err) { res.json(error(err.message)); }
});

app.get('/tj/anomalies', async (req, res) => {
  try {
    const pool = await getPool();
    const r = await pool.request().query(`
      SELECT * FROM v_异常项目
      WHERE 异常类型<>N'正常'
      ORDER BY 异常类型, 单据号;
    `);
    res.json(success(r.recordset));
  } catch (err) { res.json(error(err.message)); }
});

// ==================== 操作日志 API ====================
app.get('/log/list', async (req, res) => {
  try {
    const pool = await getPool();
    const { 操作类型, 对象表, 开始日期, 结束日期, 关键字, pageNum = 1, pageSize = 20 } = req.query;
    let q = 'SELECT * FROM 操作日志表 WHERE 1=1';
    const r = pool.request();
    if (操作类型) { q += ' AND 操作类型=@操作类型'; r.input('操作类型', sql.NVarChar(10), 操作类型); }
    if (对象表)   { q += ' AND 对象表=@对象表';     r.input('对象表',   sql.NVarChar(50), 对象表); }
    if (开始日期) { q += ' AND 操作时间>=@开始日期'; r.input('开始日期', sql.DateTime2, 开始日期); }
    if (结束日期) { q += ' AND 操作时间<=@结束日期'; r.input('结束日期', sql.DateTime2, 结束日期); }
    if (关键字) {
      q += ' AND (操作摘要 LIKE @kw OR 对象主键 LIKE @kw OR 操作人 LIKE @kw)';
      r.input('kw', sql.NVarChar, '%' + 关键字 + '%');
    }
    const totalR = await r.query(q.replace('SELECT *', 'SELECT COUNT(*) AS cnt'));
    const total = totalR.recordset[0].cnt;
    const start = (parseInt(pageNum) - 1) * parseInt(pageSize);
    const recordsR = await r.query(q + ` ORDER BY 日志ID DESC OFFSET ${start} ROWS FETCH NEXT ${parseInt(pageSize)} ROWS ONLY`);
    res.json(success({ list: recordsR.recordset, total, pageNum: parseInt(pageNum), pageSize: parseInt(pageSize) }));
  } catch (err) { res.json(error(err.message)); }
});

// ==================== 材料费 增强 API ====================
app.get('/clf/aggregateByProject', async (req, res) => {
  try {
    const pool = await getPool();
    const r = await pool.request().query(`
      SELECT c.单据号, z.预算单位, z.井号, z.施工单位,
             COUNT(*) AS 物料种数,
             SUM(c.消耗数量*c.单价) AS 材料费合计
      FROM 材料费表 c JOIN 作业项目表 z ON c.单据号=z.单据号
      GROUP BY c.单据号, z.预算单位, z.井号, z.施工单位
      ORDER BY 材料费合计 DESC;
    `);
    res.json(success(r.recordset));
  } catch (err) { res.json(error(err.message)); }
});

app.get('/clf/aggregateByMaterial', async (req, res) => {
  try {
    const pool = await getPool();
    const r = await pool.request().query(`
      SELECT c.物码, w.名称规格, w.计量单位,
             SUM(c.消耗数量) AS 消耗总量,
             AVG(c.单价)     AS 平均单价,
             SUM(c.消耗数量*c.单价) AS 总金额
      FROM 材料费表 c JOIN 物码表 w ON c.物码=w.物码
      GROUP BY c.物码, w.名称规格, w.计量单位
      ORDER BY 总金额 DESC;
    `);
    res.json(success(r.recordset));
  } catch (err) { res.json(error(err.message)); }
});

app.get('/clf/projectsOfMaterial/:wm', async (req, res) => {
  try {
    const pool = await getPool();
    const r = await pool.request()
      .input('wm', sql.Char(10), req.params.wm)
      .query(`
        SELECT c.单据号, z.预算单位, z.井号, z.施工单位,
               z.项目状态, c.消耗数量, c.单价, c.消耗数量*c.单价 AS 金额
        FROM 材料费表 c JOIN 作业项目表 z ON c.单据号=z.单据号
        WHERE c.物码=@wm
        ORDER BY 金额 DESC;
      `);
    res.json(success(r.recordset));
  } catch (err) { res.json(error(err.message)); }
});

app.get('/clf/byProject/:id', async (req, res) => {
  try {
    const pool = await getPool();
    const r = await pool.request()
      .input('id', sql.Char(20), req.params.id)
      .query(`
        SELECT c.*, w.名称规格, w.计量单位, c.消耗数量*c.单价 AS 金额
        FROM 材料费表 c JOIN 物码表 w ON c.物码=w.物码
        WHERE c.单据号=@id
        ORDER BY c.物码;
      `);
    res.json(success(r.recordset));
  } catch (err) { res.json(error(err.message)); }
});

app.get('/clf/overMaterial', async (req, res) => {
  try {
    const pool = await getPool();
    const { 阈值 = 2000 } = req.query;
    const r = await pool.request()
      .input('阈值', sql.Money, parseFloat(阈值))
      .query(`
        SELECT c.单据号, c.物码, w.名称规格,
               c.消耗数量, c.单价, c.消耗数量*c.单价 AS 金额
        FROM 材料费表 c JOIN 物码表 w ON c.物码=w.物码
        WHERE c.消耗数量*c.单价 > @阈值
        ORDER BY 金额 DESC;
      `);
    res.json(success(r.recordset));
  } catch (err) { res.json(error(err.message)); }
});

// ==================== 基础档案 树形 ====================
app.get('/dwdm/tree', async (req, res) => {
  try {
    const pool = await getPool();
    const r = await pool.request().query(`
      SELECT 单位代码, 单位名称,
        LEFT(单位代码, LEN(单位代码)-2) AS 父代码
      FROM 单位代码表
      ORDER BY 单位代码;
    `);
    res.json(success(r.recordset));
  } catch (err) { res.json(error(err.message)); }
});

