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
    ,kbo_team VARCHAR2(20) DEFAULT '응원팀 없음'
    ,use_yn VARCHAR2(1) DEFAULT 'Y'
    ,update_dt DATE DEFAULT SYSDATE
    ,create_dt DATE DEFAULT SYSDATE
);
DROP TABLE tb_mem;
SELECT * FROM tb_mem;

INSERT INTO tb_mem(mem_id, mem_pw, mem_nm)
VALUES('admin', 'admin', '관리자');

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
AND    A.TABLE_NAME = 'TB_KBO'
ORDER BY A.COLUMN_ID;

/*
    KBO 경기 일정 테이블
    날짜 및 경기시간, 홈팀, 홈팀점수, 원정팀, 원정팀점수, 경기장소, 비고(ex.우천취소 여부)
    => 계층쿼리로??
    혹은 그냥 데이터를 한 테이블에 넣기... <- 이쪽이 훨씬 간편할듯
    샘플데이터 : 2023, 2024 두 시즌만!
*/
CREATE TABLE tb_kbo (
     game_day DATE
    ,home_team VARCHAR2(20)
    ,home_team_score VARCHAR2(5) DEFAULT '-'
    ,away_team VARCHAR2(20)
    ,away_team_score VARCHAR2(5) DEFAULT '-'
    ,game_space VARCHAR2(10)
    ,game_note VARCHAR2(20) DEFAULT '-'
);
SELECT * FROM tb_kbo;
commit;
/*
INSERT INTO tb_kbo(game_day, home_team, home_team_score
                ,away_team, away_team_score, game_space, game_note)
VALUES(?, ?, ?, ?, ?, ?, ?, ?);
*/

/*
    KBO 경기별 라인업 테이블
    날짜, 홈팀, 원정팀
*/
CREATE TABLE tb_lineup (
     game_day DATE
    ,home_team VARCHAR2(20)
    ,away_team VARCHAR2(20)
);






