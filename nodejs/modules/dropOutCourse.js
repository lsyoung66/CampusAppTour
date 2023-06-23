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
    app.post('/dropOutCourse', async (req, res) => {
        const userKakaoId = req.body.user_kakao_id;
        const userAccessToken = req.body.user_access_token;
        console.log('dropOutCourse: userKakaoId: ', userKakaoId);
        console.log('dropOutCourse: userAccessToken:', userAccessToken);
        
        const conn = await pool.getConnection(vals);

        const userId = await getUserKakaoId(userAccessToken);

        const findUserQuery = `SELECT * FROM user WHERE user_id = ?`;
        const user = await conn.execute(findUserQuery, [userKakaoId]);
        const userIdx = user[0].at(0).idx;

        const findProgressQuery = `SELECT * FROM progress
        WHERE user_idx = ?
        ORDER BY idx DESC
        LIMIT 1`;
        const progress = await conn.execute(findProgressQuery, [userIdx]);
        const progressIdx = progress[0].at(0).idx;
        console.log('progressIdx :' , progressIdx);

        if (userId.toString() != userKakaoId.toString()) { conn.release(); res.status(500).send({'result':'dropOut course failed'}); res.end(); }
        else {
            const deleteCompletedCourseQuery = `DELETE FROM spot_completed WHERE progress_idx = ?`;
            await conn.execute(deleteCompletedCourseQuery, [progressIdx]);
            const deleteProgressQuery = `DELETE FROM progress WHERE idx = ?`;
            await conn.execute(deleteProgressQuery, [progressIdx]);
            conn.release();
            res.status(200).send({'resutlt':'dropOut course succeded'}); res.end();
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