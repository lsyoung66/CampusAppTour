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
    app.post('/myCourseProgress', async (req, res) => {
        console.log('getMyCourseProgress Called');
        const conn = await pool.getConnection(vals);
        let userKakaoId = req.body.user_kakao_id;
        let courseIdx = req.body.course_idx;
        console.log('myCourseProgress: userKakaoId : ', userKakaoId);
        const findUserIdxQuery = `SELECT * FROM user WHERE user_id = ?`
        const user = await conn.execute(findUserIdxQuery, [userKakaoId]);
        console.log(user[0]);
        const userIdx = user[0].at(0).idx;
        const findProgressIdxQuery = `SELECT * FROM progress WHERE user_idx = ? AND course_idx = ?`
        const progress = await conn.execute(findProgressIdxQuery, [userIdx, courseIdx]);
        if (progress[0].lenght == 0) res.end({});
        else {
            const progressIdx = progress[0].at(0).idx;
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

            for(let spotItem of completedSpots[0]){
                let spotIdx = spotItem.idx;
                const findSpotQeury = `SELECT * from spot WHERE idx = ?`;
                const spot = await conn.execute(findSpotQeury, [spotIdx]);
                spotArr.push(spot[0].at(0));
            }

            retArr.push('progress',{'spots_in_course':spotsInCourse, 'spots_completed':  completedSpotsNum, 'course_name': courseName, 'is_completed': progress[0].at(0).is_completed});
            retArr.push('spots_in_course', spotsInCourseArr);
            retArr.push('spots_completed', spotArr);

            conn.release();
            res.send(retArr);
        }
        res.end();
    });
}
