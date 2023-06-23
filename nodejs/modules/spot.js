const express = require('express');
const router = express.Router();
const mysql = require('mysql2/promise');
const vals = require('../db/config/consts.js');
const bodyParser = require('body-parser');

const pool = mysql.createPool({
    host: vals.DBHost,
    port: vals.DBPort,
    user: vals.DBUser,
    password: vals.DBPass,
    database: 'campus_app_tour',
    connectionLimit: 5,
});


module.exports = (app) => {
    app.use(bodyParser.json());
    app.use(bodyParser.urlencoded({ extended: true }));
    app.post('/spot', async (req, res) => {
        console.log('SpotInfo Called');
        const conn = await pool.getConnection(vals);
        let spotName = req.body.spot_name;
        console.log('getSpot: spotNmae : ', spotName);
        const findSpotQuery = `SELECT * FROM spot WHERE spot_name = ?`
        const spot = await conn.execute(findSpotQuery, [spotName]);
        console.log(spot[0].at(0));

        conn.release();
        res.send(spot[0].at(0));
        res.end();
    });
}
