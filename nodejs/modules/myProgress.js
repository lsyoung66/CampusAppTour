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
    app.post('/myProgress', async (req, res) => {
        console.log('getMyProgress Called');
        const conn = await pool.getConnection(vals);
        let userKakaoId = req.body.user_kakao_id;
        console.log('myProgress: userKakaoId : ', userKakaoId);
        const findUserIdxQuery = `SELECT * FROM user WHERE user_id = ?`
        const user = await conn.execute(findUserIdxQuery, [userKakaoId]);
        console.log(user[0]);
        const userIdx = user[0].at(0).idx;
        const findProgressIdxQuery = `
        SELECT * FROM progress WHERE user_idx = ? AND is_completed = 0`;
        const progress = await conn.execute(findProgressIdxQuery, [userIdx]);

        if (progress[0].length == 0) { conn.release(); res.send({}); return; }
        else {
            const progressIdx = progress[0].at(0).idx;
            console.log("progressIdx : " + progressIdx);
            const courseIdx = progress[0].at(0).course_idx;
            const findSpotsQuery = `SELECT * from spot WHERE course_idx = ?`;
            const findCourseQuery = `SELECT * from course WHERE idx = ?`;
            const course = await conn.execute(findCourseQuery, [courseIdx]);
            const courseName = course[0].at(0).course_name;
            const sopts = await conn.execute(findSpotsQuery, [courseIdx]);
            const spotsInCourseArr = sopts[0];
            const spotsInCourse = spotsInCourseArr.length;

            console.log('spot in course:', spotsInCourse);
            const findCompletedSpot = `SELECT * from spot_completed WHERE progress_idx = ?`;
            const completedSpots = await conn.execute(findCompletedSpot, [progressIdx]);

            const completedSpotsArr = completedSpots[0];
            const completedSpotsNum = completedSpotsArr.length;

            let spotArr = [];

            let retArr = [];

            for (let completed_spotItem of completedSpotsArr) {
                let spotIdx = completed_spotItem.spot_idx;
                const findSpotQeury = `SELECT * from spot WHERE idx = ?`;
                const spot = await conn.execute(findSpotQeury, [spotIdx]);
                spotArr.push(spot[0].at(0));
            }

            retArr.push({ 'progress': { 'spots_in_course': spotsInCourse, 'spots_completed': completedSpotsNum, 'course_name': courseName } });
            retArr.push({ 'spots_in_course': spotsInCourseArr });
            retArr.push({ 'spots_completed': spotArr });

            conn.release();
            res.send(retArr);
        }
        res.end();
    });
}
