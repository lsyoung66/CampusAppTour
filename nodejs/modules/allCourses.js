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
    app.post('/allCourses', async (req, res) => {
        const conn = await pool.getConnection(vals);
        let userKakaoId = req.body.user_kakao_id;
        console.log('myReviews: userKakaoId : ', userKakaoId);
        let userIdx = null;

        if(userKakaoId != ""){
        const findUserQuery = `SELECT * FROM user WHERE user_id = ?`
        const user = await conn.execute(findUserQuery, [userKakaoId]);
        userIdx = user[0].at(0).idx;
        }


        let retArr = [];
       
        
        const coursesQuery = `SELECT * FROM course`;
        let courses = await conn.execute(coursesQuery);
        for (let course of courses[0]){
            const findCourseSpotsQuery = `SELECT * FROM spot WHERE course_idx = ?`;
            const spots = await conn.execute(findCourseSpotsQuery, [course.idx]);
            let isCompleted = false;
            if(userKakaoId != ""){
                const findUserProgressQuery = `SELECT * FROM progress WHERE user_idx =? AND course_idx = ? AND is_completed = 1`;
                const userP = await conn.execute(findUserProgressQuery, [userIdx, course.idx]);
                if(userP[0].length != 0){
                    isCompleted = true;
                }
            }
            let coordinates = [];
            for(let spot of spots[0]){
                coordinates.push(spot.spot_coordinate);
            }
            let courseCoordinate = calculateCenter(coordinates);
            course.courseCoordinate = courseCoordinate;
            course.isCompleted = isCompleted;
            retArr.push(course);

        }

        console.log(retArr);

        

        conn.release();
        res.status(200).send(retArr); res.end();
    });
}

function calculateCenter(coordinates) {
    if (coordinates.length === 0) {
      return null; // 좌표가 없는 경우 null 반환
    }
  
    let sumX = 0;
    let sumY = 0;
  
    for (let i = 0; i < coordinates.length; i++) {
      sumX += coordinates[i].x;
      sumY += coordinates[i].y;
    }
  
    const centerX = (sumX / coordinates.length).toFixed(4); // 소수점 네 자릿수까지 계산
    const centerY = (sumY / coordinates.length).toFixed(4); // 소수점 네 자릿수까지 계산
  
    return { x: parseFloat(centerX), y: parseFloat(centerY) }; // 중심값 반환
  }