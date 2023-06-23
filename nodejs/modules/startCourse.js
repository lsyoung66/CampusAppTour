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
    app.post('/startCourse', async (req, res) => {
        const userKakaoId = req.body.user_kakao_id;
        const userAccessToken = req.body.user_access_token;
        const courseName = extractEnglishLetters(req.body.course_name);
        console.log('startCourse: userKakaoId: ', userKakaoId);
        console.log('startCourse: userAccessToken:', userAccessToken);
        console.log('startCourse: courseName:', courseName);
        const conn = await pool.getConnection(vals);
        const findUserQuery = `SELECT * FROM user WHERE user_id = ?`
        const user = await conn.execute(findUserQuery, [userKakaoId]);
        const userIdx = user[0].at(0).idx;

        const userId = await getUserKakaoId(userAccessToken);

        const findUserProgressQuery = `SELECT * FROM progress WHERE user_idx = ? AND is_completed = 0`;
        const userProgress = await conn.execute(findUserProgressQuery, [userIdx]);
        if(userProgress[0].length != 0) {
            console.log("진행중인 코스 있음");
            res.status(500).send({'result' : '이미 진행중인 코스 있음'});
            conn.release();
            return;
        }
        

        if (userId.toString() != userKakaoId.toString()) { res.status(500).end(); }
        else {
            const findCourseQuery = `SELECT * FROM course WHERE course_name = ?`
            let course = await conn.execute(findCourseQuery, [courseName]);
            let courseIdx = 0;
            if(course[0].length != 0) {courseIdx = course[0].at(0).idx;}
            else {res.status(500).send({'result' : 'bad request'}); return; }
            console.log('courseName' + courseName + '. Idx = ' + courseIdx);
            const startCourseQuery = `INSERT INTO progress (course_idx, user_idx, is_completed, start_time) VALUES (? , ? ,? , NOW())`
            await conn.execute(startCourseQuery, [courseIdx, userIdx, 0]);
            conn.release();
            res.status(200).send({'result':'start Course succeded'});
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

function extractEnglishLetters(str) {
    // 영어 알파벳 소문자(a-z)와 대문자(A-Z)를 추출하는 정규식
    const regex = /[a-zA-Z]/g;
    
    // 문자열에서 정규식과 일치하는 모든 영어 문자 추출
    const englishLetters = str.match(regex);
    
    // 추출된 영어 문자들을 합쳐서 반환
    return englishLetters ? englishLetters.join('') : '';
  }

  function getCurrentDateTime() {
    const now = new Date();
    
    // 날짜와 시간을 YYYY-MM-DD HH:MM:SS 형식으로 변환
    const formattedDateTime = now.toISOString().slice(0, 19).replace('T', ' ');
    
    return formattedDateTime;
  }