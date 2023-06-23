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
  app.post('/courseComplete', async (req, res) => {
    const userKakaoId = req.body.user_kakao_id;
    const userAccessToken = req.body.user_access_token;
    console.log('Course Completed: userKakaoId: ', userKakaoId);
    console.log('Course Completed: userAccessToken: ', userAccessToken);
    const conn = await pool.getConnection(vals);
    const userId = await getUserKakaoId(userAccessToken);
    if (userId != userKakaoId) {
      res.status(500).send({ 'result': 'failed' });
      res.end();
      console.log('dfdsfe');
      console.log(userId.toString());
      console.log(userKakaoId);

    } else {
      const findUserIdxQuery = `
      SELECT *
      FROM user
      WHERE user_id = ?;`;
      const user = await conn.execute(findUserIdxQuery, [userKakaoId]);
      const userIdx = user[0].at(0).idx;
      const courseCompleteQuery = `
        UPDATE progress
        SET is_completed = 1, end_time = NOW()
        WHERE user_idx = ? AND is_completed = 0;`;
      await conn.execute(courseCompleteQuery, [userIdx]);
      conn.release();
      res.status(200).send({ 'resutlt': 'sssssucceded' });
      res.end();
    }
  });
};

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