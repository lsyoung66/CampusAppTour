const express = require('express');
const router = express.Router();
const mysql = require('mysql2/promise');
const vals = require('../db/config/consts.js');
const pool = mysql.createPool({
    host: vals.DBHost,
    port: vals.DBPort,
    user: vals.DBUser,
    password: vals.DBPass,
    database: 'campus_app_tour',
    connectionLimit: 5,
  });

router.get('/:name/spots', async (req, res) => {
  const name = req.params.name;
  const conn = await pool.getConnection(vals);
  const courseIdxQuery = `SELECT idx FROM course WHERE course_name = ?`;
  const [rows] = await conn.execute(courseIdxQuery, [name]);
  const courseIdx = rows[0].idx;
  const spotQuery = `SELECT spot_name FROM spot WHERE course_idx = ?`;
  const [spotRows] = await conn.execute(spotQuery, [courseIdx]);
  const spots = spotRows.map((row) => row.spot_name);
  console.log(name, spots)
  res.status(200).send(spots);
  conn.release();
});

module.exports = router;