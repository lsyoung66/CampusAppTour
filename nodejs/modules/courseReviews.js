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
    app.post('/courseReviews', async (req, res) => {
        const conn = await pool.getConnection(vals);
        let courseName = req.body.course_name;
        console.log('courseReviews: courseName : ', courseName);

        const findCourseQuery = `SELECT * FROM course WHERE course_name = ?`;
        const course = await conn.execute(findCourseQuery, [courseName]);
        const courseIdx = course[0].at(0).idx;
        console.log(courseIdx);

        const findReviewQuery = `SELECT * FROM review WHERE course_idx = ?`
        const rev = await conn.execute(findReviewQuery, [courseIdx]);
        const reviews = rev[0];

        conn.release();
        res.send(reviews);
        res.end();
    });
}
