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
    app.post('/myReviews', async (req, res) => {
        const conn = await pool.getConnection(vals);
        let userKakaoId = req.body.user_kakao_id;
        let courseIdx = req.body.course_idx;
        console.log('myReviews: userKakaoId : ', userKakaoId);
        console.log('myReviews: courseIdx ', courseIdx);
        const findUserQuery = `SELECT * FROM user WHERE user_id = ?`
        const user = await conn.execute(findUserQuery, [userKakaoId]);
        const userIdx = user[0].at(0).idx;
        let myReviews = [];
        if (courseIdx == 0) {
            const findMyReviewsQuery = `SELECT * FROM review WHERE user_idx = ?`
            myReviews = await conn.execute(findMyReviewsQuery, [userIdx]);
        }
        else {
            const findMyReviewsQuery = `SELECT * FROM review WHERE user_idx = ? AND course_idx = ?`
            myReviews = await conn.execute(findMyReviewsQuery, [userIdx, courseIdx]);
            conn.release();
        }

        if (myReviews[0].lenght == 0) res.end({});
        else {
            let reviewArr = [];

            for (let review of myReviews[0]) {
                const findCourseNameQuery = `SELECT * FROM course WHERE idx = ?`;
                let c = await conn.execute(findCourseNameQuery, [review.course_idx]);
                const courseName = c[0].at(0).course_name;
                review.course_name = courseName;
                reviewArr.push(review);
            }
            conn.release();
            res.send(reviewArr);
        }
        res.end();
    });
}
