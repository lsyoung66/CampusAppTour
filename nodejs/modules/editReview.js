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
    app.post('/editReview', async (req, res) => {
        const userKakaoId = req.body.user_kakao_id;
        const userAccessToken = req.body.user_access_token;
        const reviewIdx = req.body.review_idx;
        const reviewContent = req.body.review_content;
        console.log('editReview: userKakaoId: ', userKakaoId);
        console.log('editReview: userAccessToken:', userAccessToken);
        console.log('editReview: reviewIdx: ', reviewIdx);
        console.log('editReview: newContent: ', reviewContent);
        const conn = await pool.getConnection(vals);

        const userId = await getUserKakaoId(userAccessToken);

        if (userId.toString() != userKakaoId.toString()) { res.status(500).send({'result':'edit review failed'}); res.end(); }
        else {
            const editReviewQuery = `UPDATE review SET review_content = ? WHERE idx = ?`;
            await conn.execute(editReviewQuery, [reviewContent, reviewIdx]);
            res.status(200).send({'result':'edit review succeded'}); res.end();
        }
        conn.release();
        res.end();
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