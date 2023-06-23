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
    app.post('/login', async (req, res) => {
        const userEmail = req.body.user_email;
        const userNickname = req.body.user_nickname;
        const userKakaoId = req.body.user_kakao_id;
        console.log(userEmail);
        console.log(userNickname);
        console.log(userKakaoId);
        const conn = await pool.getConnection(vals);
        const query = `SELECT * FROM user WHERE user_id = ?`;
        let user = await conn.execute(query, [userKakaoId]);
        if (user[0].length == 0) {
            console.log("신규회원, 가입진행");
            const joinQuery = `INSERT INTO user (user_id, user_nickname, user_email) VALUES (?, ?, ?);`;
            await conn.execute(joinQuery, [userKakaoId, userNickname, userEmail]);
            res.status(200).send({'isNewMember': '신규회원, 회원가입 진행'}); 
        }
        else {
            console.log("가입된 회원, 로그인 진행");
            res.status(200).send({'isNewMember': '가입된 회원, 로그인 진행'});
        }
        conn.release();

    });
}

async function getUserKakaoId(access_token) {
    fetch("https://kapi.kakao.com/v2/user/me", {
        method: "GET",
        headers: {
            "Authorization": "Bearer ${access_token}"
        }
    })
        .then(response => {
            if (!response.ok) {
                throw new Error("HTTP error " + response.status);
            }
            console.log(response);
            return response.json();
        })
        .then(json => console.log(json))
        .catch(error => console.error(error));
}