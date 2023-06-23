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
    app.post('/deleteReview', async (req, res) => {
        const userKakaoId = req.body.user_kakao_id;
        const userAccessToken = req.body.user_access_token;
        const reviewIdx = req.body.review_idx;
        console.log('deleteReview: userKakaoId: ', userKakaoId);
        console.log('deleteReview: userAccessToken:', userAccessToken);
        console.log('deleteReview: reviewIdx: ', reviewIdx);
        const conn = await pool.getConnection(vals);

        const userId = await getUserKakaoId(userAccessToken);

        if (userId.toString() != userKakaoId.toString()) { res.status(500).send({'result':'delete review failed'}); res.end(); }
        else {
            const deleteReviewQuery = `DELETE FROM review WHERE idx = ?`;
            await conn.execute(deleteReviewQuery, [reviewIdx]);
            conn.release();
            res.status(200).send({'resutlt':'delete review succeded'}); res.end();
        }
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