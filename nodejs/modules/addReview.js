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
    app.post('/addReview', async (req, res) => {
        const reviewTitle = req.body.review_title;
        const reviewContent = req.body.review_content;
        const reviewGrade = req.body.review_grade;
        const userAccessToken = req.body.user_access_Token;
        const userKakaoId = req.body.user_kakao_id;
        const conn = await pool.getConnection(vals);

        const findUserQuery = `SELECT * FROM user WHERE user_id = ? `;
        const user = await conn.execute(findUserQuery, [userKakaoId]);
        const userIdx = user[0].at(0).idx;

        const findProgressQuery = `SELECT * FROM progress WHERE user_idx = ? AND is_completed = 0`;
        const progress = await conn.execute(findProgressQuery, [userIdx]);
        const courseIdx = progress[0].at(0).course_idx;

        console.log('addReview: reviewTitle: ', reviewTitle);
        console.log('addReview: reviewContent:', reviewContent);
        console.log('addReview: grade: ', reviewGrade);
        console.log('addReview: course_idx: ', courseIdx);
        console.log('addReview: user_idx: ', userIdx);
        console.log('addReview: user_access_token: ', userAccessToken);
        console.log('addReview: user_kakao_id: ', userKakaoId);


        const userId = await getUserKakaoId(userAccessToken);


        if (userId !=  userKakaoId.toString()) {
            res.status(500).send({ 'addReview': 'add review failed' }); res.end();
        } else {
            const addReviewQuery = 'INSERT INTO review (review_title, review_content, grade, course_idx, user_idx) VALUES (?, ?, ?, ?, ?)';
            await conn.execute(addReviewQuery, [reviewTitle, reviewContent, reviewGrade, courseIdx.toString(), userIdx.toString()]);
            res.status(200).send({ 'addReview': 'add review success' });
            res.end();
        }
        conn.release();
    });
   
}

async function getUserKakaoId(access_token) {
    return fetch("https://kapi.kakao.com/v2/user/me", {
        method: "GET",
        headers: {
            "Authorization": "Bearer " + access_token
        }
    })
        .then(response => {
            if (!response.ok) {
                throw new Error("HTTP error " + response.status);
            }
            return response.json();
        })
        .then(json => json.id)
        .catch(error => console.error(error));
}