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
    app.post('/withdrawal', async (req, res) => {
        const userKakaoId = req.body.user_kakao_id;
        const userAccessToken = req.body.user_access_token;
        console.log("KakaoId to delete : ", userKakaoId);
        console.log("userAccessToken : ", userAccessToken);
        const conn = await pool.getConnection(vals);
        const query = `SELECT * FROM user WHERE user_id = ?`;
        let [user] = await conn.execute(query, [userKakaoId]);
        console.log(user[0]);
        if (user[0].length != 0 && userAccessToken) {
            const kakaoId = await getUserKakaoId(userAccessToken);
            console.log("user Kakao Id : ", kakaoId);
            if (kakaoId.toString() == userKakaoId) {
                let userIdx = user[0].idx;
                const findUserProgressQuery = `SELECT * FROM progress WHERE user_idx = ?`;
                let progress = await conn.execute(findUserProgressQuery, [userIdx]);
                let progressIdx = progress[0].at(0).idx;
                console.log('progressIdx : ', progressIdx);
                const deleteUserReviewQuery = `DELETE FROM review WHERE user_idx = ?`;
                const deleteUserSpotsQuery = `DELETE FROM spot_completed WHERE progress_idx = ?`;
                const deleteUserProgressQuery = `DELETE FROM progress WHERE user_idx = ?`;
                await conn.execute(deleteUserReviewQuery, [userIdx]);
                await conn.execute(deleteUserSpotsQuery, [progressIdx]);
                await conn.execute(deleteUserProgressQuery, [userIdx]);

                const withdrawalQuery = `DELETE FROM user WHERE user_id = ?`;
                await conn.execute(withdrawalQuery, [userKakaoId]);
                console.log("kakao_id : " + userKakaoId + " 삭제");
                res.send({ "isSuccess": true })
            }
            else{
                console.log("유저 인증 안됨");
                res.send({ "isSuccess": true })
            }
        }
        else {
            console.log("사용자 찾을 수 없음.");
            res.send({ "isSuccess": false })
        }

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