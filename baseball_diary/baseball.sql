-- 계정 생성 (DBA 권한 있는 계정에서 실행)
ALTER SESSION SET "_ORACLE_SCRIPT"=true;
CREATE USER sohee IDENTIFIED BY sohee;
GRANT CONNECT, RESOURCE TO sohee;
GRANT UNLIMITED TABLESPACE to sohee;

/*
    회원 테이블
    ID, PW, 닉네임, 응원팀, 활성화여부, 등록일자, 수정일자
*/
CREATE TABLE tb_mem (
     mem_id VARCHAR2(50) PRIMARY KEY
    ,mem_pw VARCHAR2(1000) NOT NULL
    ,mem_nm VARCHAR2(100) NOT NULL 
    ,kbo_team VARCHAR2(20) DEFAULT 'ALL'
    ,use_yn VARCHAR2(1) DEFAULT 'Y'
    ,update_dt DATE DEFAULT SYSDATE
    ,create_dt DATE DEFAULT SYSDATE
);
--DROP TABLE tb_mem;
SELECT * FROM tb_mem;
--DELETE tb_mem WHERE mem_id='admin';
UPDATE tb_mem SET kbo_team = 'ALL' WHERE mem_id='admin';

SELECT mem_id
     , mem_nm
     , mem_pw
     , kbo_team
FROM tb_mem
WHERE use_yn = 'Y'
AND   mem_id = 'admin';

INSERT INTO tb_mem(mem_id, mem_pw, mem_nm)
VALUES('admin', 'admin', '관리자');

--DELETE FROM tb_mem WHERE mem_id='admin';

SELECT RPAD(' ', 4) || 'private ' || 
   CASE 
   WHEN A.DATA_TYPE = 'VARCHAR2' THEN 'String'
   WHEN A.DATA_TYPE = 'NUMBER' THEN 'int'
   WHEN A.DATA_TYPE = 'FLOAT' THEN 'Float'
   WHEN A.DATA_TYPE = 'CHAR' AND A.DATA_LENGTH > 1 THEN 'String'
   WHEN A.DATA_TYPE = 'DATE' THEN 'String'
   ELSE 'Object'
   END ||
   ' ' || 
   CONCAT
   (
    LOWER(SUBSTR(B.COLUMN_NAME, 1, 1)), 
    SUBSTR(REGEXP_REPLACE(INITCAP(B.COLUMN_NAME), ' |_'), 2)
   ) || CHR(59) || CHR(13) as alis
FROM   ALL_TAB_COLUMNS A
     , ALL_COL_COMMENTS B
WHERE  A.TABLE_NAME = B.TABLE_NAME
AND    A.COLUMN_NAME = B.COLUMN_NAME
AND    A.OWNER = 'SOHEE'
AND    B.OWNER = 'SOHEE'
AND    A.TABLE_NAME = 'TB_DIARY'
ORDER BY A.COLUMN_ID;

/*
    KBO 경기 일정 테이블
    날짜 및 경기시간, 홈팀, 홈팀점수, 원정팀, 원정팀점수, 경기장소, 비고(ex.우천취소 여부)
    => 계층쿼리로??
    혹은 그냥 데이터를 한 테이블에 넣기... <- 이쪽이 훨씬 간편할듯
    샘플데이터 : 2023, 2024
*/
CREATE TABLE tb_kbo (
     game_day DATE
    ,away_team VARCHAR2(20)
    ,away_team_score VARCHAR2(5) DEFAULT '-'
    ,home_team VARCHAR2(20)
    ,home_team_score VARCHAR2(5) DEFAULT '-'
    ,game_space VARCHAR2(10)
    ,game_note VARCHAR2(20) DEFAULT '-'
);

--DROP TABLE tb_kbo;

ALTER TABLE tb_kbo ADD CONSTRAINT pk_kbo PRIMARY KEY(game_day, home_team);

SELECT * FROM tb_kbo
ORDER BY game_day;

--CREATE FUNCTION is_date(p_string VARCHAR2, p_format VARCHAR2)
--    RETURN NUMBER 
--IS
--    v_date DATE;
--BEGIN
--    v_date := TO_DATE(p_string, p_format);    
--    RETURN 1;   
--    
--EXCEPTION
--    WHEN OTHERS THEN
--        RETURN 0;
--END;
--
--SELECT is_date('2024-01-12', 'YYYY-MM-DD')
--  FROM DUAL;

--DROP FUNCTION is_date;

SELECT VALIDATE_CONVERSION('2024-09-30' AS DATE, 'YYYY-MM-DD')
  FROM DUAL;

SELECT *
FROM tb_kbo
WHERE TO_CHAR(game_day,'YYYY-MM-DD') = '2024-03-23';

commit;
/*
INSERT INTO tb_kbo(game_day, home_team, home_team_score
                ,away_team, away_team_score, game_space, game_note)
VALUES(?, ?, ?, ?, ?, ?, ?, ?);
*/



CREATE TABLE tb_game
AS
SELECT game_day
    ,  yymm as gamedate
    ,  home as hcode
    ,  away_team
    ,  home_team
    ,  home_team_score
    ,  game_space
    ,  game_note
FROM (
  SELECT     game_day
            ,TO_CHAR(game_day,'YYYYMMDD') as yymm
            ,CASE WHEN away_team = 'LG' THEN 'LG'
                  WHEN away_team = 'KT' THEN 'KT'
                  WHEN away_team = 'SSG' THEN 'SK'
                  WHEN away_team = 'NC' THEN 'NC'
                  WHEN away_team = '두산' THEN 'OB'
                  WHEN away_team = 'KIA' THEN 'HT'
                  WHEN away_team = '롯데' THEN 'LT'
                  WHEN away_team = '삼성' THEN 'SS'
                  WHEN away_team = '한화' THEN 'HH'
                  WHEN away_team = '키움' THEN 'WO'
              END as away
             ,CASE WHEN home_team = 'LG' THEN 'LG'
                  WHEN home_team = 'KT' THEN 'KT'
                  WHEN home_team = 'SSG' THEN 'SK'
                  WHEN home_team = 'NC' THEN 'NC'
                  WHEN home_team = '두산' THEN 'OB'
                  WHEN home_team = 'KIA' THEN 'HT'
                  WHEN home_team = '롯데' THEN 'LT'
                  WHEN home_team = '삼성' THEN 'SS'
                  WHEN home_team = '한화' THEN 'HH'
                  WHEN home_team = '키움' THEN 'WO'
             END as home
             , TO_CHAR(game_day,'YYYY') AS yy
            ,away_team
            ,away_team_score
            ,home_team
            ,home_team_score
            ,game_space
            ,game_note
            ,CASE WHEN COUNT(*) OVER(PARTITION BY away_team||home_team) >1 THEN TO_CHAR(ROW_NUMBER() OVER(PARTITION BY away_team||home_team ORDER BY game_day ASC))  
             ELSE '0' END  as cnt
   FROM tb_kbo
   ORDER BY game_day
   );
--DROP TABLE tb_game;
ALTER TABLE tb_game ADD CONSTRAINT pk_game PRIMARY KEY(game_day, hcode);
ALTER TABLE tb_game ADD CONSTRAINT fk_game 
FOREIGN KEY(game_day, home_team) REFERENCES tb_kbo(game_day, home_team);

SELECT * 
FROM tb_game
WHERE TO_CHAR(game_day,'YYYY-MM-DD') = '2024-09-28';
WHERE code='20240928HTLT02024';

/*
    다이어리 데이터 테이블
    작성자ID, 날짜 및 경기시간, 제목, 내용, 활성화여부, 작성일, 수정일
    (고민중...),선발투수, 1번타자, 2번타자, 3번타자, ..., 9번타자
*/
CREATE TABLE tb_diary (
     mem_id VARCHAR2(50)
    ,diary_no NUMBER GENERATED ALWAYS AS IDENTITY -- 자동 증가 컬럼
    ,game_day DATE
    ,code VARCHAR2(100)
    ,diary_title VARCHAR2(1000)
    ,diary_content VARCHAR2(4000)
    ,use_yn VARCHAR2(1) DEFAULT 'Y'
    ,update_dt DATE DEFAULT SYSDATE
    ,create_dt DATE DEFAULT SYSDATE
);
--DROP TABLE tb_diary;
ALTER TABLE tb_diary ADD CONSTRAINT fk_diary FOREIGN KEY(mem_id) REFERENCES tb_mem (mem_id);
--ALTER TABLE tb_diary ADD CONSTRAINT fk2_diary 
--FOREIGN KEY(game_day, hcode) REFERENCES tb_game(game_day, hcode);

INSERT INTO tb_diary(mem_id, game_day, code, diary_title, diary_content)
VALUES ('admin', TO_DATE('2024.09.28 17:00', 'YYYY.MM.DD HH24:MI'), '20240928HTLT02024', '테스트', '테스트 글입니다.');
INSERT INTO tb_diary(mem_id, game_day, code, diary_title, diary_content)
VALUES ('admin', TO_DATE('2024-09-30 18:30', 'YYYY-MM-DD HH24:MI'), '20240930NCHT02024', '0930제목', '0930내용');

SELECT * FROM tb_diary;

-- 다이어리 목록 조회
SELECT b.mem_id
     , a.diary_no
     , a.game_day
     , a.diary_title
     , a.create_dt
     , a.update_dt
FROM tb_diary a, tb_mem b
WHERE a.mem_id = b.mem_id
AND   a.use_yn = 'Y'
AND   b.mem_id = 'admin';

-- 다이어리 내용 조회
SELECT b.mem_id
     , a.diary_no
     , a.game_day
     , a.code
     , a.diary_title
     , a.diary_content
     , a.update_dt
FROM tb_diary a, tb_mem b
WHERE a.mem_id = b.mem_id
AND   a.use_yn = 'Y'
AND   b.mem_id = 'admin';

-- 다이어리 수정
UPDATE tb_diary
SET diary_title = 'bbbb'
   ,diary_content = 'bbbb'
WHERE diary_no = 3;

--DELETE tb_diary WHERE diary_no = 21;

commit;

--20240901 HTSS 02024
	SELECT 	 game_day
            ,TO_CHAR(game_day,'YYYYMMDD')  || 
             CASE WHEN away_team = 'LG' THEN 'LG'
                  WHEN away_team = 'KT' THEN 'KT'
                  WHEN away_team = 'SSG' THEN 'SK'
                  WHEN away_team = 'NC' THEN 'NC'
                  WHEN away_team = '두산' THEN 'OB'
                  WHEN away_team = 'KIA' THEN 'HT'
                  WHEN away_team = '롯데' THEN 'LT'
                  WHEN away_team = '삼성' THEN 'SS'
                  WHEN away_team = '한화' THEN 'HH'
                  WHEN away_team = '키움' THEN 'WO'
             END ||
             CASE WHEN home_team = 'LG' THEN 'LG'
                  WHEN home_team = 'KT' THEN 'KT'
                  WHEN home_team = 'SSG' THEN 'SK'
                  WHEN home_team = 'NC' THEN 'NC'
                  WHEN home_team = '두산' THEN 'OB'
                  WHEN home_team = 'KIA' THEN 'HT'
                  WHEN home_team = '롯데' THEN 'LT'
                  WHEN home_team = '삼성' THEN 'SS'
                  WHEN home_team = '한화' THEN 'HH'
                  WHEN home_team = '키움' THEN 'WO'
             END || 
             '0'|| TO_CHAR(game_day,'YYYY') AS code
            ,away_team
            ,away_team_score
            ,home_team
            ,home_team_score
            ,game_space
            ,game_note
	FROM tb_kbo
	WHERE TO_CHAR(game_day,'YYYY-MM-DD') = '2024-09-21';
    
SELECT game_day
    ,  yymm || away ||home || cnt || yy  as code
    ,  home as hcode
    ,  away_team
    ,  home_team
    ,  home_team_score
    ,  game_space
    ,  game_note
FROM (
  SELECT     game_day
            ,TO_CHAR(game_day,'YYYYMMDD') as yymm
            ,CASE WHEN away_team = 'LG' THEN 'LG'
                  WHEN away_team = 'KT' THEN 'KT'
                  WHEN away_team = 'SSG' THEN 'SK'
                  WHEN away_team = 'NC' THEN 'NC'
                  WHEN away_team = '두산' THEN 'OB'
                  WHEN away_team = 'KIA' THEN 'HT'
                  WHEN away_team = '롯데' THEN 'LT'
                  WHEN away_team = '삼성' THEN 'SS'
                  WHEN away_team = '한화' THEN 'HH'
                  WHEN away_team = '키움' THEN 'WO'
              END as away
             ,CASE WHEN home_team = 'LG' THEN 'LG'
                  WHEN home_team = 'KT' THEN 'KT'
                  WHEN home_team = 'SSG' THEN 'SK'
                  WHEN home_team = 'NC' THEN 'NC'
                  WHEN home_team = '두산' THEN 'OB'
                  WHEN home_team = 'KIA' THEN 'HT'
                  WHEN home_team = '롯데' THEN 'LT'
                  WHEN home_team = '삼성' THEN 'SS'
                  WHEN home_team = '한화' THEN 'HH'
                  WHEN home_team = '키움' THEN 'WO'
             END as home
             , TO_CHAR(game_day,'YYYY') AS yy
            ,away_team
            ,away_team_score
            ,home_team
            ,home_team_score
            ,game_space
            ,game_note
            ,CASE WHEN COUNT(*) OVER(PARTITION BY away_team||home_team) >1 THEN TO_CHAR(ROW_NUMBER() OVER(PARTITION BY away_team||home_team ORDER BY game_day ASC))  
             ELSE '0' END  as cnt
   FROM tb_kbo
   WHERE TO_CHAR(game_day,'YYYY-MM-DD') = '2024-09-21'
   );
