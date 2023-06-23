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
    app.post('/spotComplete', async (req, res) => {
        const userKakaoId = req.body.user_kakao_id;
        const userAccessToken = req.body.user_access_token;
        const spotIdx = req.body.spot_idx;
        console.log("spot completed user id : ", userKakaoId);
        console.log("userAccessToken : ", userAccessToken);
        console.log("completed spot idx: ", spotIdx);
        const conn = await pool.getConnection(vals);
        const query = `SELECT * FROM user WHERE user_id = ?`;
        let [user] = await conn.execute(query, [userKakaoId]);
        console.log(user[0]);
        if (user[0].length != 0 && userAccessToken) {
            const kakaoId = await getUserKakaoId(userAccessToken);
            if (kakaoId.toString() == userKakaoId) {
                console.log("spotComplete : 유저 인증 성공");
                let userIdx = user[0].idx;
                const findUserProgressQuery = `SELECT * FROM progress WHERE user_idx = ? AND is_completed=0`;
                let progress = await conn.execute(findUserProgressQuery, [userIdx]);
                let progressIdx = progress[0].at(0).idx;

                const insertCompletedSoptQuery = `INSERT INTO spot_completed (progress_idx, spot_idx) VALUES (?,?)`;
                await conn.execute(insertCompletedSoptQuery, [progressIdx, spotIdx]);
                res.send({ "isSuccess": true })
                conn.release();
            }
            else{
                console.log("유저 인증 안됨");
                res.send({ "isSuccess": true })
                conn.release();
            }
        }
        else {
            console.log("사용자 찾을 수 없음.");
            res.send({ "isSuccess": false })
            conn.release();
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