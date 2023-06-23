const mariadb = require('mariadb');
const vals = require('./config/consts.js');
const mysql = require('mysql2/promise');

async function createUserTable() {
  const connection = await mysql.createConnection({
    host: vals.DBHost,
    port: vals.DBPort,
    user: vals.DBUser,
    password: vals.DBPass,
    connectionLimit: 5
  });

  try {
    await connection.query("USE campus_app_tour;");
    await connection.query(`
      CREATE TABLE user (
        idx INT AUTO_INCREMENT PRIMARY KEY,
        user_id VARCHAR(50) NOT NULL,
        user_nickname VARCHAR(50) NOT NULL,
        user_email VARCHAR(100) UNIQUE NOT NULL,
      )
    `);
    console.log('user table created successfully');
  } catch (err) {
    console.error(err);
  } finally {
    connection.end();
  }
}

async function createCourseTable() {
  const connection = await mysql.createConnection({
    host: vals.DBHost,
    port: vals.DBPort,
    user: vals.DBUser,
    password: vals.DBPass,
    connectionLimit: 5,
  });

  try {
    await connection.query("USE campus_app_tour;");
    await connection.query(`
      CREATE TABLE course (
        idx INT AUTO_INCREMENT PRIMARY KEY,
        course_name VARCHAR(50) NOT NULL,
        course_description TEXT
      )
    `);
    await connection.query(`
    INSERT INTO course (course_name)
VALUES 
  ('A'),
  ('B'),
  ('C');
    `);
    console.log('course table created successfully');
  } catch (err) {
    console.error(err);
  } finally {
    connection.end();
  }
}

async function createSpotTable() {
  const connection = await mysql.createConnection({
    host: vals.DBHost,
    port: vals.DBPort,
    user: vals.DBUser,
    password: vals.DBPass,
    connectionLimit: 5,
  });

  try {
    await connection.query("USE campus_app_tour;");
    await connection.query(`
      CREATE TABLE spot (
        idx INT AUTO_INCREMENT PRIMARY KEY,
        course_idx INT NOT NULL,
        spot_name VARCHAR(50) NOT NULL,
        spot_coordinate POINT NOT NULL,
        spot_image TEXT,
        spot_description TEXT,
        FOREIGN KEY (course_idx) REFERENCES course(idx) ON UPDATE CASCADE ON DELETE CASCADE
      )
    `);
    await connection.query(`
    INSERT INTO spot (course_idx, spot_name, spot_coordinate, spot_image, spot_description) 
VALUES
    ('1', '성모상', POINT(35.9105, 128.8081), '/resources/images/dcu.png', ''),
    ('1', '대가대조형물', POINT(35.9103, 128.8083), '/resources/images/dcu.png', ''),
    ('1', '김종복미술관', POINT(35.909, 128.8075), '/resources/images/dcu.png', ''),
    ('1', '기숙사분수대', POINT(35.9078, 128.8078), '/resources/images/sculpturePark.png', ''),
    ('2', '100주년 기념광장', POINT(35.9108, 128.8101), '/resources/images/dcu.png', ''),
    ('2', '잔디광장', POINT(35.9122, 128.8099), '/resources/images/dcu.png', ''),
    ('2', '전석재 몬시뇰 동상', POINT(35.9105, 128.8114), '/resources/images/seokjae.png', ''),
    ('2', '박물관', POINT(35.9102, 128.8115), '/resources/images/dcu.png', ''),
    ('2', '희망의 예수상', POINT(35.9095, 128.8098), '/resources/images/jesusStatue.png', ''),
    ('3', '치유광장', POINT(35.9115, 128.8089), '/resources/images/dcu.png', ''),
    ('3', '체리로드', POINT(35.912, 128.8089), '/resources/images/dcu.png', ''),
    ('3', '은행나무길', POINT(35.9138, 128.8084), '/resources/images/dcu.png', ''),
    ('3', '스트로마톨라이트', POINT(35.9148, 128.8083), '/resources/images/dcu.png', ''),
    ('3', '안중근 의사 동상', POINT(35.9126, 128.8066), '/resources/images/junggeun.png', '');
    `);
    console.log('spot table created successfully');
  } catch (err) {
    console.error(err);
  } finally {
    connection.end();
  }
}

async function createProgressTable() {
  const connection = await mysql.createConnection({
    host: vals.DBHost,
    port: vals.DBPort,
    user: vals.DBUser,
    password: vals.DBPass,
    connectionLimit: 5,
  });

  try {
    await connection.query("USE campus_app_tour;");
    await connection.query(`
      CREATE TABLE progress (
        idx INT AUTO_INCREMENT PRIMARY KEY,
        course_idx INT NOT NULL,
        user_idx INT NOT NULL,
        spot_completed TEXT,
        is_completed TINYINT(1) DEFAULT 0,
        start_time DATETIME NOT NULL,
        end_time DATETIME,
        FOREIGN KEY (course_idx) REFERENCES course(idx) ON UPDATE CASCADE ON DELETE CASCADE,
        FOREIGN KEY (user_idx) REFERENCES user(idx) ON UPDATE CASCADE ON DELETE CASCADE
      )
    `);
    console.log('progress table created successfully');
  } catch (err) {
    console.error(err);
  } finally {
    connection.end();
  }
}

async function createReviewTable() {
  const connection = await mysql.createConnection({
    host: vals.DBHost,
    port: vals.DBPort,
    user: vals.DBUser,
    password: vals.DBPass,
    connectionLimit: 5,
  });

  try {
    await connection.query("USE campus_app_tour;");
    await connection.query(`
  CREATE TABLE review (
    idx INT AUTO_INCREMENT PRIMARY KEY,
    review_title VARCHAR(50),
    review_content TEXT NOT NULL,
    grade FLOAT NOT NULL,
    course_idx INT NOT NULL,
    user_idx INT NOT NULL,
    FOREIGN KEY (course_idx) REFERENCES course(idx) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (user_idx) REFERENCES user(idx) ON UPDATE CASCADE ON DELETE CASCADE
  )
`);
    console.log('review table created successfully');
  } catch (err) {
    console.error(err);
  } finally {
    connection.end();
  }
}

async function createSpotCompletedTable() {
  const connection = await mysql.createConnection({
    host: vals.DBHost,
    port: vals.DBPort,
    user: vals.DBUser,
    password: vals.DBPass,
    connectionLimit: 5,
  });

  try {
    await connection.query("USE campus_app_tour;");
    await connection.query(`
    CREATE TABLE spot_completed (
      idx INT AUTO_INCREMENT PRIMARY KEY,
      progress_idx INT(11) DEFAULT NULL,
      spot_idx INT(11) DEFAULT NULL,
      KEY progress_idx (progress_idx),
      KEY spot_idx (spot_idx)
    );
`);
    console.log('review table created successfully');
  } catch (err) {
    console.error(err);
  } finally {
    connection.end();
  }
}



// createUserTable();
// createCourseTable();
// createSpotTable();
// createProgressTable();
// createReviewTable();
// createSpotCompletedTable();
