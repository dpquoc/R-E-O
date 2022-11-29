-- BEGIN

-- FOR c IN (SELECT table_name FROM user_tables) LOOP
-- EXECUTE IMMEDIATE ('DROP TABLE "' || c.table_name || '" CASCADE CONSTRAINTS');
-- END LOOP;

-- FOR s IN (SELECT sequence_name FROM user_sequences) LOOP
-- EXECUTE IMMEDIATE ('DROP SEQUENCE ' || s.sequence_name);
-- END LOOP;

-- FOR f IN (SELECT function_name FROM user_functions) LOOP
-- EXECUTE IMMEDIATE ('DROP FUNCTION ' || f.function_name);
-- END LOOP;

-- FOR f IN (SELECT type_name FROM user_types) LOOP
-- EXECUTE IMMEDIATE ('DROP type ' || f.type_name);
-- END LOOP;

-- END;

ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'DD/MM/YYYY HH24:MI';
CREATE TABLE    Company
(   
    cnumber        CHAR(4)  PRIMARY KEY,
    cname          VARCHAR(30) NOT NULL,
    phone          DECIMAL(11) UNIQUE NOT NULL,
    edate          DATE,
    address        VARCHAR(30),
    CONSTRAINT     fm_com_cnumber          CHECK (REGEXP_LIKE (cnumber, 'C\d{3}')),
    CONSTRAINT     fm_com_phone            CHECK (REGEXP_LIKE(phone, '84\d{9}'))
);

CREATE TABLE    Person
(
    ssn            VARCHAR(12) PRIMARY KEY,
    fname          VARCHAR(30),
    lname          VARCHAR(30),
    phone          DECIMAL(11) UNIQUE NOT NULL,
    address        VARCHAR(30),
    CONSTRAINT     fm_per_phone            CHECK (REGEXP_LIKE(phone, '84\d{9}')),
    CONSTRAINT     fm_per_ssn              CHECK (REGEXP_LIKE(ssn, '\d{12}'))
);

CREATE TABLE    Trainee
(
    ssn            VARCHAR(12) PRIMARY KEY,
    dob            DATE,
    photo          VARCHAR(50),
    company_id     CHAR(4),
    CONSTRAINT  fk_trn_per_ssn          FOREIGN KEY (ssn)
                                        REFERENCES Person (ssn)
                                        ON DELETE CASCADE,   
    CONSTRAINT  fk_trn_com_company_id   FOREIGN KEY (company_id) 
                                        REFERENCES Company (cnumber) 
                                        ON DELETE SET NULL 
);

CREATE TABLE    MC
(
    ssn             VARCHAR(12) PRIMARY KEY,
    CONSTRAINT  fk_mc_per_ssn           FOREIGN KEY (ssn)
                                        REFERENCES Person (ssn)
                                        ON DELETE CASCADE  
);

CREATE TABLE    Mentor
(
    ssn            VARCHAR(12) PRIMARY KEY,
    CONSTRAINT  fk_mtr_per_ssn          FOREIGN KEY (ssn)
                                        REFERENCES Person (ssn)
                                        ON DELETE CASCADE  
);

CREATE TABLE    InvitedGuest
(
    guest_ID        INT PRIMARY KEY
);
CREATE SEQUENCE gue_seq START WITH 1;
CREATE OR REPLACE TRIGGER gue_trig 
BEFORE INSERT ON InvitedGuest 
FOR EACH ROW
BEGIN
  :NEW.guest_ID := :NEW.guest_ID || gue_seq.NEXTVAL;
END;
/


CREATE TABLE    Singer
(  
    ssn             VARCHAR(12) PRIMARY KEY,
    guest_ID        INT,
    CONSTRAINT  fk_sgr_mtr_ssn          FOREIGN KEY (ssn)
                                        REFERENCES Mentor (ssn)
                                        ON DELETE CASCADE,
    CONSTRAINT  fk_sgr_gue_guest_ID     FOREIGN KEY (guest_ID)
                                        REFERENCES InvitedGuest (guest_ID)
                                        ON DELETE SET NULL
);


CREATE TABLE SingerSignatureSong
(
    ssn             VARCHAR(12),
    song_name       VARCHAR(30),
    CONSTRAINT  fk_sss_sgr_ssn          FOREIGN KEY (ssn)
                                        REFERENCES Singer (ssn)
                                        ON DELETE CASCADE,
    CONSTRAINT  pk_SingerSignatureSong  PRIMARY KEY (ssn, song_name)                
);

CREATE TABLE    Song
(
    snumber         VARCHAR(15) PRIMARY KEY, 
    release_year    DECIMAL(4),
    sname           VARCHAR(30) NOT NULL UNIQUE,
    singer_ssn_first_performed     VARCHAR(12),
    CONSTRAINT  fk_sng_sgr_ssn          FOREIGN KEY (singer_ssn_first_performed)
                                        REFERENCES Singer (ssn)
                                        ON DELETE SET NULL
);
CREATE SEQUENCE sng_seq START WITH 1;
CREATE OR REPLACE TRIGGER sng_trig 
BEFORE INSERT ON Song 
FOR EACH ROW
BEGIN
  :NEW.snumber := 'S' || to_char(sng_seq.NEXTVAL);
END;
/

CREATE TABLE    ThemeSong
(
    song_ID         VARCHAR(15) PRIMARY KEY,
    CONSTRAINT  fk_ths_sng_song_ID      FOREIGN KEY (song_ID)
                                        REFERENCES Song (snumber)
                                        ON DELETE CASCADE 
);

CREATE TABLE    SongWriter
(
    ssn            VARCHAR(12) PRIMARY KEY,
    CONSTRAINT  fk_swr_mtr_ssn          FOREIGN KEY (ssn)
                                        REFERENCES Mentor (ssn)
                                        ON DELETE CASCADE 
);

CREATE TABLE    SongComposedBy 
(
    song_ID         VARCHAR(15),
    composer_ssn             VARCHAR(12),
    CONSTRAINT  fk_scb_sng_song_ID      FOREIGN KEY (song_ID)
                                        REFERENCES Song (snumber)
                                        ON DELETE CASCADE,
    CONSTRAINT  fk_scb_swt_composer_SSN FOREIGN KEY (composer_SSN)
                                        REFERENCES SongWriter (ssn)
                                        ON DELETE CASCADE, 
    CONSTRAINT  pk_SongComposedBy       PRIMARY KEY (song_ID, composer_SSN)
);

CREATE TABLE    Producer
(
    ssn            VARCHAR(12) PRIMARY KEY,
    CONSTRAINT  fk_pdc_mtr_ssn          FOREIGN KEY (ssn)
                                        REFERENCES Mentor (ssn)
                                        ON DELETE CASCADE
);

CREATE TABLE    ProducerProgram
(
    ssn             VARCHAR(12),
    program_name    VARCHAR(30),
    CONSTRAINT  fk_ppg_pdc_ssn          FOREIGN KEY (ssn)
                                        REFERENCES Producer (ssn)
                                        ON DELETE CASCADE,
    CONSTRAINT  pk_ProducerProgram      PRIMARY KEY (ssn, program_name)                                 
);

CREATE TABLE    Season
(
    syear           DECIMAL(4) PRIMARY KEY,
    slocation       VARCHAR(30),
    themesong_ID    VARCHAR(15),
    ssn             VARCHAR(12),
    CONSTRAINT  fk_ss_ths_themesong_ID  FOREIGN KEY (themesong_ID)
                                        REFERENCES ThemeSong (song_ID)
                                        ON DELETE SET NULL,
    CONSTRAINT  fk_ss_mc_ssn            FOREIGN KEY (ssn)
                                        REFERENCES MC (ssn)
                                        ON DELETE SET NULL                                
);

CREATE TABLE    SeasonMentor
(
    syear           DECIMAL(4),
    ssn_mentor      VARCHAR(12),
    CONSTRAINT  fk_ssm_ss_year          FOREIGN KEY (syear)
                                        REFERENCES Season (syear)
                                        ON DELETE CASCADE,
    CONSTRAINT  fk_ssm_mtr_syear        FOREIGN KEY (ssn_mentor)
                                        REFERENCES Mentor (ssn)
                                        ON DELETE CASCADE,                              
    CONSTRAINT  pk_SeasonMentor         PRIMARY KEY (syear, ssn_mentor)                              
);

CREATE TABLE    SeasonTrainee  
(
    syear           DECIMAL(4),
    ssn_trainee     VARCHAR(12),
    CONSTRAINT  fk_sst_ss_year          FOREIGN KEY (syear)
                                        REFERENCES Season (syear)
                                        ON DELETE CASCADE,
    CONSTRAINT  fk_sst_trn_syear        FOREIGN KEY (ssn_trainee)
                                        REFERENCES Trainee (ssn)
                                        ON DELETE CASCADE,                            
    CONSTRAINT  pk_SeasonTrainee        PRIMARY KEY (syear, ssn_trainee)                              
);

CREATE TABLE    MentorValuateTrainee
(
    syear           DECIMAL(4),
    ssn_trainee     VARCHAR(12),
    ssn_mentor      VARCHAR(12),
    score           INT,
    CONSTRAINT  fk_mvt_ss_syear         FOREIGN KEY (syear)
                                        REFERENCES Season (syear)
                                        ON DELETE CASCADE,
    CONSTRAINT  fk_mvt_mtr_syear        FOREIGN KEY (ssn_mentor)
                                        REFERENCES Mentor (ssn)
                                        ON DELETE CASCADE,   
    CONSTRAINT  fk_mvt_trn_syear        FOREIGN KEY (ssn_trainee)
                                        REFERENCES Trainee (ssn)
                                        ON DELETE CASCADE,  
    CONSTRAINT  fm_mvt_score            CHECK (score BETWEEN 1 and 100),
    CONSTRAINT  pk_MentorValuateTrainee PRIMARY KEY (syear, ssn_mentor, ssn_trainee) 
);

CREATE TABLE    Episode
(
    eyear           DECIMAL(4),
    eno             INT,
    ename           VARCHAR(50),
    datetime        TIMESTAMP,
    eduration       INT,
    CONSTRAINT  fm_ep_eno            CHECK (eno BETWEEN 1 and 5),
    CONSTRAINT  fk_ep_ss_year           FOREIGN KEY (eyear)
                                        REFERENCES Season (syear)
                                        ON DELETE CASCADE,
    CONSTRAINT  pk_Episode              PRIMARY KEY (eyear, eno)
);

CREATE TABLE    Stage
(
    syear           DECIMAL(4),
    ep_no           INT,
    stage_no        INT,
    is_group        CHAR(1),
    skill           INT,
    total_vote      INT,
    song_ID         VARCHAR(15),
    CONSTRAINT  fk_stg_ep_year          FOREIGN KEY (syear, ep_no)
                                        REFERENCES Episode (eyear, eno)
                                        ON DELETE CASCADE,
    CONSTRAINT  fm_stg_is_group         CHECK (is_group = 'y' or is_group = 'n'),
    CONSTRAINT  fm_stg_skill            CHECK (skill BETWEEN 1 and 4),
    CONSTRAINT  fm_stg_ep_no            CHECK (ep_no BETWEEN 1 and 5),
    CONSTRAINT  fk_stg_sng_song_ID      FOREIGN KEY (song_ID)
                                        REFERENCES Song (snumber)
                                        ON DELETE SET NULL,
    CONSTRAINT  pk_Stage                PRIMARY KEY (syear, ep_no, stage_no)
);

CREATE TABLE    StageIncludeTrainee
(
    syear           DECIMAL(4),
    ep_no           INT,
    stage_no        INT,
    ssn_trainee     VARCHAR(12),
    srole           INT,
    no_of_votes     INT,
    CONSTRAINT  fk_sit_stg_year         FOREIGN KEY (syear, ep_no, stage_no)
                                        REFERENCES Stage (syear, ep_no, stage_no)
                                        ON DELETE CASCADE,
    CONSTRAINT  fk_sit_trn_ssn_trainee  FOREIGN KEY (ssn_trainee)
                                        REFERENCES Trainee (ssn)
                                        ON DELETE CASCADE,
    CONSTRAINT  fm_sit_srole            CHECK (srole BETWEEN 1 and 3),
    CONSTRAINT  fm_sit_ep_no            CHECK (ep_no BETWEEN 1 and 5),
    CONSTRAINT  fm_sit_no_of_votes      CHECK (no_of_votes BETWEEN 0 and 500),
    CONSTRAINT  pk_StageIncludeTrainee  PRIMARY KEY (syear, ep_no, stage_no, ssn_trainee)
);


CREATE TABLE    GGroup 
(
    gname           VARCHAR(15) PRIMARY KEY,
    no_of_member    INT,
    guest_ID        INT,
    CONSTRAINT  fm_gr_no_of_member      CHECK (no_of_member BETWEEN 1 and 20),
    CONSTRAINT  fk_gr_gue_guest_ID      FOREIGN KEY (guest_ID)
                                        REFERENCES InvitedGuest (guest_ID)
                                        ON DELETE SET NULL
);

CREATE TABLE    GroupSignatureSong 
(
    gname           VARCHAR(15),
    song_name       VARCHAR(30),
    CONSTRAINT  fk_gss_gr_gname         FOREIGN KEY (gname)
                                        REFERENCES GGroup (gname)
                                        ON DELETE CASCADE,
    CONSTRAINT  pk_GroupSignatureSong   PRIMARY KEY (gname, song_name)             
);

CREATE TABLE GuestSupportStage
(
    guest_ID        INT,
    syear           DECIMAL(4),
    ep_no           INT,
    stage_no        INT,
    CONSTRAINT  fk_gss_gue_guest_ID     FOREIGN KEY (guest_ID)
                                        REFERENCES InvitedGuest (guest_ID)
                                        ON DELETE CASCADE,
    CONSTRAINT  fk_gss_stg_year         FOREIGN KEY (syear, ep_no, stage_no)
                                        REFERENCES Stage (syear, ep_no, stage_no)
                                        ON DELETE CASCADE,
    CONSTRAINT  pk_GuestSupportStage    PRIMARY KEY (syear, ep_no, stage_no)
);






























CREATE OR REPLACE TRIGGER most_3_seasions 
BEFORE
INSERT OR UPDATE OF SSN_TRAINEE ON SeasonTrainee
FOR EACH ROW
DECLARE
    CURSOR cur is select ssn_trainee from seasontrainee;
    tmp seasontrainee.ssn_trainee%type;
    c int :=0;
BEGIN
    FOR item in cur LOOP
    if item.ssn_trainee= :new.ssn_trainee then
    c:=c+1;
    end if;
    if c>2 then 
    raise_application_error(-20000, 'The input is wrong! This trainee joined 3 seasions!');
    end if;
    END LOOP;
END;
/
--test trigger1.1.a
-- insert into Season values (2020, 'Bac lieu', 'S1', '854860566018');
-- insert into Season values (2019, 'Bac lieu', 'S1', '854860566018');
-- insert into Season values (2018, 'Can Tho', 'S1', '854860566018');
-- insert into SeasonTrainee values (2020,'996730324052');
-- insert into SeasonTrainee values (2019,'996730324052');
-- insert into SeasonTrainee values (2018,'996730324052');
--print "The input wrong! This trainee joined 3 seasion"
--------------------------------------------------------------------------------


--trigger 1.1.b-----------------------------------------------------------------
CREATE OR REPLACE TRIGGER joined_debutnight
BEFORE
INSERT OR UPDATE OF SSN_TRAINEE ON SeasonTrainee
FOR EACH ROW
DECLARE
        c int;
BEGIN
    SELECT  count(*) into c
    FROM stageincludetrainee
    where ep_no=5 and ssn_trainee= :new.ssn_trainee;
    if(c>0) then 
        raise_application_error(-20000, 'The input is wrong! This trainee joined at the last episode of another seasion!'); 
    end if;
END;
/
--test joined_debutnight
--638255538685 join debut at 2021
-- insert into SeasonTrainee values (2020,'325480102130'); --insert success
-- insert into SeasonTrainee values (2020,'638255538685'); 
--print "The input wrong! This trainee joined at the last episode of another seasion!"
--------------------------------------------------------------------------------




--trigger 2---------------------------------------------------------------------
SET SERVEROUTPUT ON;
CREATE OR REPLACE TRIGGER total_vote
AFTER
INSERT OR UPDATE OR DELETE ON StageIncludeTrainee 
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        UPDATE Stage
        SET total_vote =(total_vote + :new.no_of_votes)
        WHERE syear = :new.syear AND ep_No = :new.ep_No AND stage_No = :new.stage_No;
    ELSIF UPDATING THEN
        UPDATE Stage
        SET total_vote = total_vote - :old.no_of_votes + :new.no_of_votes
        WHERE syear = :new.syear AND ep_No = :new.ep_No AND stage_No = :new.stage_No;
     ELSE
        UPDATE Stage
        SET total_vote = total_vote - :old.no_of_votes
        WHERE syear = :old.syear AND ep_No = :old.ep_No AND stage_No = :old.stage_No;
     END IF;
END;
/
--test trigger 2
-- insert into stageincludetrainee values(2021,2,1,'009627907950',1,1);
-- insert into stageincludetrainee values(2021,2,2,'049253761330',1,1);
--------------------------------------------------------------------------------




--support for function_1
CREATE OR REPLACE TYPE a_winner as object(
    ssn VARCHAR(12),
    num_of_vote INT
);
/
CREATE OR REPLACE TYPE winners_table as table of a_winner;
/
--Function_1: print list of trainees come to the next episode-------------------
CREATE OR REPLACE FUNCTION winnersThisEpisode (y IN NUMBER, ep IN NUMBER)
RETURN winners_table AS res winners_table;
BEGIN
    IF ep = 1 THEN
        SELECT a_winner(SSN_trainee, score)
        BULK COLLECT INTO res
        FROM(
            SELECT *
            FROM (
                SELECT SSN_trainee, AVG(score) score
                FROM MentorValuateTrainee
                WHERE syear = y
                GROUP BY SSN_trainee
                ORDER BY score DESC
            )
            WHERE ROWNUM <= 30
        );
        
    ELSIF ep = 2 OR ep = 4 THEN
        SELECT a_winner(SSN_trainee, no_of_votes)
        BULK COLLECT INTO res
        FROM(
            SELECT *
            FROM (
                SELECT SSN_trainee, SUM(no_of_votes) no_of_votes
                FROM StageIncludeTrainee
                WHERE StageIncludeTrainee.syear = y AND StageIncludeTrainee.ep_No = ep
                GROUP BY SSN_trainee
                ORDER BY no_of_votes DESC
            )
            WHERE ROWNUM <= 40/ep
        );
        
        
    
    ELSIF ep = 3 THEN
        SELECT a_winner(SSN_trainee, no_of_votes)
        BULK COLLECT INTO res
        FROM(
            SELECT SSN_trainee , no_of_votes
            FROM (
                SELECT StageIncludeTrainee.stage_No, StageIncludeTrainee.SSN_trainee, StageIncludeTrainee.no_of_votes, rankInPair,
                        ROW_NUMBER() OVER(PARTITION BY StageIncludeTrainee.stage_No ORDER BY StageIncludeTrainee.no_of_votes DESC) rankInGroup
                FROM StageIncludeTrainee
                LEFT JOIN
                (
                    SELECT stage_No , total_vote, song_ID , ROW_NUMBER() OVER(PARTITION BY song_ID ORDER BY total_vote) rankInPair
                    FROM Stage
                    WHERE syear = Y AND ep_No = 3
                    ORDER BY song_ID DESC , total_vote DESC
                ) tmp
                ON StageIncludeTrainee.stage_No = tmp.stage_No
                WHERE StageIncludeTrainee.syear = Y AND StageIncludeTrainee.ep_No = 3
            )
            WHERE rankInPair = 1 OR rankInGroup BETWEEN 1 AND 3
            ORDER BY no_of_votes DESC
        );
        
    ELSE
        SELECT a_winner(SSN_trainee, no_of_votes)
        BULK COLLECT INTO res
        FROM(
            SELECT *
            FROM (
                SELECT SSN_trainee, SUM(no_of_votes) no_of_votes
                FROM StageIncludeTrainee
                WHERE StageIncludeTrainee.syear = y AND StageIncludeTrainee.ep_No = ep
                GROUP BY SSN_trainee
                ORDER BY no_of_votes DESC
            )
            WHERE ROWNUM <= 5
        );
    END IF;

  RETURN res;
END winnersThisEpisode;
/
SET SERVEROUTPUT ON;
create or replace procedure pr(y IN NUMBER, ep IN NUMBER)  is  
begin
    DBMS_OUTPUT.PUT_LINE('             '||'SSN' || '             '||'Num of votes/ avg score');
    FOR SR IN (SELECT  * FROM TABLE(winnersThisEpisode (y, ep)))
    LOOP DBMS_OUTPUT.PUT_LINE(SR.SSN || '          '||SR.num_of_vote);
    END LOOP;
end pr;
/
--EXEC PR(2021,5);
--------------------------------------------------------------------------------
--support for function2
CREATE OR REPLACE TYPE t_record as object(
    ep_no number(1),
    no_of_votes INT
);
/
CREATE OR REPLACE TYPE t_table as table of t_record;
/
--Function2 retrive the result of a trainee in a season-------------------------
CREATE OR REPLACE FUNCTION sum_vote(y IN NUMBER, SSN IN NUMBER)
RETURN t_table as v_ret t_table;
                  come_ep int;
BEGIN
    v_ret:=t_table();
    v_ret.extend;
    SELECT t_record(ep_no,no_of_votes) into v_ret(v_ret.count)
    FROM( 
        SELECT 1 EP_NO, avg(SCORE) NO_OF_VOTES
        FROM MENTORVALUATETRAINEE
        WHERE Y=mentorvaluatetrainee.SYEAR AND SSN=mentorvaluatetrainee.ssn_trainee
        GROUP BY SSN_TRAINEE
        )
    ;
    
    SELECT count(*) INTO come_ep
    FROM stageincludetrainee
    WHERE y=syear and ssn = ssn_trainee;
    
    IF COME_EP =1 THEN 
        FOR k in 2..5 LOOP
        v_ret.extend;
        v_ret(v_ret.count):=t_record(k,'');
        END LOOP;
    ELSIF COME_EP=2 THEN
        v_ret.extend;
        SELECT  t_record(ep_no, no_of_votes) into v_ret(2)
        FROM
        ( 
            SELECT 2 EP_NO, sum(no_of_votes) no_of_votes
            FROM stageincludetrainee
            WHERE Y=STAGEINCLUDETRAINEE.SYEAR AND SSN=STAGEINCLUDETRAINEE.ssn_trainee AND STAGEINCLUDETRAINEE.EP_NO=2
            GROUP BY SSN_TRAINEE
        )
        ;
        FOR k in 3..5 LOOP
        v_ret.extend;
        v_ret(v_ret.count):=t_record(k,'');
        END LOOP;
    ELSIF COME_EP <5 THEN
        FOR k in 2..COME_EP LOOP
            v_ret.extend;
            SELECT  t_record(ep_no, no_of_votes) into v_ret(k)
            FROM
            ( 
                SELECT k EP_NO, sum(no_of_votes) no_of_votes
                FROM stageincludetrainee
                WHERE Y=STAGEINCLUDETRAINEE.SYEAR AND SSN=STAGEINCLUDETRAINEE.ssn_trainee AND STAGEINCLUDETRAINEE.EP_NO=k
                GROUP BY SSN_TRAINEE
            )
            ;
        END LOOP;
        FOR k in (COME_EP+1)..5 LOOP
            v_ret.extend;
            v_ret(v_ret.count):=t_record(k,'');
        END LOOP;
    ELSE
        for k in 2..5 loop
        v_ret.extend;
        SELECT  t_record(ep_no, no_of_votes) into v_ret(k)
        FROM
        ( 
            SELECT k EP_NO, sum(no_of_votes) no_of_votes
            FROM stageincludetrainee
            WHERE Y=STAGEINCLUDETRAINEE.SYEAR AND SSN=STAGEINCLUDETRAINEE.ssn_trainee AND STAGEINCLUDETRAINEE.EP_NO=k
            GROUP BY SSN_TRAINEE
        )
        ;
        
        END LOOP;
    END IF;
    RETURN v_ret;   
END sum_vote;
--select * from table(sum_vote(2021,'164287459396'))
/














































ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'DD/MM/YYYY HH24:MI';

insert into company values ('C465', 'Eco Focus', '84689057548', '23/07/2008','Dong Xoai, Binh Phuoc');
insert into company values ('C932', 'Innovation Arch', '84834529264', '15/03/2013', 'Pleiku, Gia Lai');
insert into company values ('C423', 'Strat Security', '84934691643', '07/04/2002', 'Thanh pho Hoa Binh, Hoa Binh');
insert into company values ('C254', 'Inspire Fitness Co', '84937586705', '30/10/2008', 'Thanh Pho Hoi An, Quang Nam');

insert into Person (ssn, fname, lname, phone, address) values ('854860566018', 'Cal', 'Bartoleyn', '84192018400', '28964 Reindahl Road');
insert into Person (ssn, fname, lname, phone, address) values ('403182588436', 'Patti', 'Cestard', '84752117782', '8 Dahle Trail');
insert into Person (ssn, fname, lname, phone, address) values ('184968201267', 'Cortie', 'Thurley', '84147065460', '0589 Boyd Hill');
insert into Person (ssn, fname, lname, phone, address) values ('239843063885', 'Jean', 'Dumbreck', '84615390874', '44474 Prairie Rose Terrace');
insert into Person (ssn, fname, lname, phone, address) values ('086299707329', 'Sebastiano', 'Mell', '84712758905', '38 Fair Oaks Trail');
insert into Person (ssn, fname, lname, phone, address) values ('996730324052', 'Pascale', 'Beric', '84356635584', '4 Prairieview Avenue');
insert into Person (ssn, fname, lname, phone, address) values ('118459356212', 'North', 'Ginnaly', '84236929862', '3534 Surrey Junction');
insert into Person (ssn, fname, lname, phone, address) values ('529511218687', 'Tedda', 'Endle', '84866571697', '6187 Ramsey Pass');
insert into Person (ssn, fname, lname, phone, address) values ('164287459396', 'Lynsey', 'Flahy', '84407657166', '3123 Corben Terrace');
insert into Person (ssn, fname, lname, phone, address) values ('844687021716', 'Krishna', 'Jago', '84184933061', '9 Dunning Center');
insert into Person (ssn, fname, lname, phone, address) values ('612403510769', 'Marshal', 'McArd', '84127587951', '5 Dovetail Point');
insert into Person (ssn, fname, lname, phone, address) values ('267112162640', 'Mallory', 'Greenrodd', '84316063070', '608 Burning Wood Junction');
insert into Person (ssn, fname, lname, phone, address) values ('202017566494', 'Cyndi', 'Hadaway', '84301610594', '1949 Westend Parkway');
insert into Person (ssn, fname, lname, phone, address) values ('053796327184', 'Adelina', 'Annis', '84343642341', '8811 Pennsylvania Avenue');
insert into Person (ssn, fname, lname, phone, address) values ('439743433939', 'Hilda', 'Goodricke', '84962172155', '109 Cambridge Place');
insert into Person (ssn, fname, lname, phone, address) values ('079496761933', 'Inglis', 'Parkins', '84208469203', '02540 6th Circle');
insert into Person (ssn, fname, lname, phone, address) values ('829510745846', 'Gena', 'Frankel', '84144250239', '349 Harbort Road');
insert into Person (ssn, fname, lname, phone, address) values ('351008093214', 'Cathrin', 'Jordon', '84802302528', '639 Mockingbird Place');
insert into Person (ssn, fname, lname, phone, address) values ('286576417983', 'Donny', 'Hedney', '84000406230', '968 Daystar Trail');
insert into Person (ssn, fname, lname, phone, address) values ('561431834647', 'Carlee', 'Elia', '84636128578', '88874 Tennessee Drive');
insert into Person (ssn, fname, lname, phone, address) values ('819499566621', 'Ginevra', 'Yakob', '84308244150', '3458 Kennedy Court');
insert into Person (ssn, fname, lname, phone, address) values ('658532596000', 'Missie', 'Leng', '84034114392', '35 Moulton Avenue');
insert into Person (ssn, fname, lname, phone, address) values ('325480102130', 'Lawry', 'MacCome', '84961059457', '7 Crescent Oaks Place');
insert into Person (ssn, fname, lname, phone, address) values ('484259653727', 'Binnie', 'Wittey', '84566881313', '80648 Farwell Way');
insert into Person (ssn, fname, lname, phone, address) values ('049253761330', 'Eduino', 'Mateiko', '84447671120', '91218 Ridge Oak Pass');
insert into Person (ssn, fname, lname, phone, address) values ('900031544666', 'Riobard', 'Mayho', '84438131494', '91046 Cody Point');
insert into Person (ssn, fname, lname, phone, address) values ('099140063202', 'Clarissa', 'Gommey', '84160021121', '66500 Sunnyside Circle');
insert into Person (ssn, fname, lname, phone, address) values ('875739166533', 'Charleen', 'Child', '84609613500', '475 Loeprich Point');
insert into Person (ssn, fname, lname, phone, address) values ('659008228930', 'Libby', 'Brownill', '84235227025', '5 Mcguire Court');
insert into Person (ssn, fname, lname, phone, address) values ('110581129953', 'Clarette', 'Spata', '84974688878', '19662 Comanche Center');
insert into Person (ssn, fname, lname, phone, address) values ('009627907950', 'Elset', 'McShirrie', '84488339451', '2512 Meadow Ridge Trail');
insert into Person (ssn, fname, lname, phone, address) values ('404424240431', 'Mitzi', 'Sutherns', '84081841475', '61637 International Pass');
insert into Person (ssn, fname, lname, phone, address) values ('927515078560', 'Erminie', 'Larderot', '84147090681', '44919 Cherokee Circle');
insert into Person (ssn, fname, lname, phone, address) values ('218368804861', 'Edik', 'Bushrod', '84081230076', '61806 Stephen Pass');
insert into Person (ssn, fname, lname, phone, address) values ('469123343905', 'Osbert', 'Duffin', '84934357834', '5558 Anderson Hill');
insert into Person (ssn, fname, lname, phone, address) values ('324760934033', 'Greggory', 'Roder', '84276457648', '4220 Hazelcrest Park');
insert into Person (ssn, fname, lname, phone, address) values ('576236976840', 'Mersey', 'Slorach', '84278616102', '97 Manitowish Way');
insert into Person (ssn, fname, lname, phone, address) values ('676163562912', 'Steffie', 'Scyner', '84885272444', '812 Scofield Trail');
insert into Person (ssn, fname, lname, phone, address) values ('430693807644', 'Dwight', 'Codd', '84594769597', '09886 Beilfuss Drive');
insert into Person (ssn, fname, lname, phone, address) values ('206251664438', 'Barbie', 'Thomel', '84893847859', '03221 Clove Point');
insert into Person (ssn, fname, lname, phone, address) values ('786164962370', 'Jarad', 'Priddle', '84067767278', '4567 Stuart Point');
insert into Person (ssn, fname, lname, phone, address) values ('942244652860', 'Fabio', 'Ellacombe', '84417247595', '4014 Jenna Point');
insert into Person (ssn, fname, lname, phone, address) values ('672691285744', 'Ianthe', 'Ickovic', '84222495283', '0464 Stephen Terrace');
insert into Person (ssn, fname, lname, phone, address) values ('172638933387', 'Prent', 'Haestier', '84819018740', '06 Mariners Cove Park');
insert into Person (ssn, fname, lname, phone, address) values ('304688803531', 'Ileana', 'MacAllaster', '84963745632', '6 Manley Trail');
insert into Person (ssn, fname, lname, phone, address) values ('866280004328', 'Doreen', 'Pennicard', '84236900262', '65165 Butternut Way');
insert into Person (ssn, fname, lname, phone, address) values ('220156814586', 'Wyatan', 'Halse', '84595987124', '5729 Spaight Lane');
insert into Person (ssn, fname, lname, phone, address) values ('294410326371', 'Violette', 'Muldrew', '84434337880', '3 Dorton Parkway');
insert into Person (ssn, fname, lname, phone, address) values ('187794991025', 'Matthus', 'Cheale', '84036797475', '16 Corscot Road');
insert into Person (ssn, fname, lname, phone, address) values ('199684642337', 'Mella', 'Yarker', '84426187161', '317 Victoria Street');
insert into Person (ssn, fname, lname, phone, address) values ('819394503449', 'Rosemaria', 'Hewins', '84334103687', '93829 Basil Park');
insert into Person (ssn, fname, lname, phone, address) values ('638255538685', 'Cornall', 'Emmanuele', '84119275638', '887 Starling Place');
insert into Person (ssn, fname, lname, phone, address) values ('147513211437', 'Therese', 'Spenton', '84573071641', '47 Lyons Parkway');
insert into Person (ssn, fname, lname, phone, address) values ('315377723665', 'Eugenius', 'Templeman', '84101320623', '520 Rutledge Trail');
insert into Person (ssn, fname, lname, phone, address) values ('334756218587', 'Ashia', 'Berendsen', '84008011359', '8 Kinsman Plaza');


insert into Trainee (ssn, dob, photo, company_id) values ('996730324052', '18/04/2001', 'http://dummyimage.com/142x100.png/ff4444/ffffff', 'C254');
insert into Trainee (ssn, dob, photo, company_id) values ('118459356212', '09/07/2002', 'http://dummyimage.com/180x100.png/5fa2dd/ffffff', 'C423');
insert into Trainee (ssn, dob, photo, company_id) values ('529511218687', '09/03/2001', 'http://dummyimage.com/156x100.png/5fa2dd/ffffff', 'C423');
insert into Trainee (ssn, dob, photo, company_id) values ('164287459396', '19/10/2002', 'http://dummyimage.com/123x100.png/dddddd/000000', 'C932');
insert into Trainee (ssn, dob, photo, company_id) values ('844687021716', '02/05/2000', 'http://dummyimage.com/110x100.png/5fa2dd/ffffff', 'C465');
insert into Trainee (ssn, dob, photo, company_id) values ('612403510769', '09/01/2003', 'http://dummyimage.com/150x100.png/dddddd/000000', 'C254');
insert into Trainee (ssn, dob, photo, company_id) values ('267112162640', '29/09/2000', 'http://dummyimage.com/151x100.png/5fa2dd/ffffff', 'C465');
insert into Trainee (ssn, dob, photo, company_id) values ('202017566494', '23/06/2001', 'http://dummyimage.com/221x100.png/dddddd/000000', 'C254');
insert into Trainee (ssn, dob, photo, company_id) values ('053796327184', '07/03/2003', 'http://dummyimage.com/239x100.png/dddddd/000000', 'C254');
insert into Trainee (ssn, dob, photo, company_id) values ('439743433939', '23/10/2001', 'http://dummyimage.com/214x100.png/cc0000/ffffff', 'C423');
insert into Trainee (ssn, dob, photo, company_id) values ('079496761933', '09/03/2000', 'http://dummyimage.com/191x100.png/dddddd/000000', 'C465');
insert into Trainee (ssn, dob, photo, company_id) values ('829510745846', '30/08/2003', 'http://dummyimage.com/138x100.png/dddddd/000000', 'C254');
insert into Trainee (ssn, dob, photo, company_id) values ('351008093214', '15/12/2000', 'http://dummyimage.com/224x100.png/5fa2dd/ffffff', 'C254');
insert into Trainee (ssn, dob, photo, company_id) values ('286576417983', '17/08/2002', 'http://dummyimage.com/149x100.png/ff4444/ffffff', 'C254');
insert into Trainee (ssn, dob, photo, company_id) values ('561431834647', '23/05/2003', 'http://dummyimage.com/203x100.png/dddddd/000000', 'C465');
insert into Trainee (ssn, dob, photo, company_id) values ('819499566621', '17/09/2001', 'http://dummyimage.com/138x100.png/cc0000/ffffff', 'C254');
insert into Trainee (ssn, dob, photo, company_id) values ('658532596000', '22/03/2000', 'http://dummyimage.com/169x100.png/cc0000/ffffff', 'C932');
insert into Trainee (ssn, dob, photo, company_id) values ('325480102130', '29/09/2000', 'http://dummyimage.com/222x100.png/cc0000/ffffff', 'C254');
insert into Trainee (ssn, dob, photo, company_id) values ('484259653727', '10/04/2001', 'http://dummyimage.com/203x100.png/ff4444/ffffff', 'C423');
insert into Trainee (ssn, dob, photo, company_id) values ('049253761330', '19/02/2002', 'http://dummyimage.com/197x100.png/cc0000/ffffff', 'C423');
insert into Trainee (ssn, dob, photo, company_id) values ('900031544666', '04/04/2001', 'http://dummyimage.com/227x100.png/cc0000/ffffff', 'C465');
insert into Trainee (ssn, dob, photo, company_id) values ('099140063202', '20/08/2003', 'http://dummyimage.com/117x100.png/cc0000/ffffff', 'C423');
insert into Trainee (ssn, dob, photo, company_id) values ('875739166533', '01/05/2000', 'http://dummyimage.com/227x100.png/dddddd/000000', 'C254');
insert into Trainee (ssn, dob, photo, company_id) values ('659008228930', '12/05/2002', 'http://dummyimage.com/213x100.png/ff4444/ffffff', 'C423');
insert into Trainee (ssn, dob, photo, company_id) values ('110581129953', '27/03/2000', 'http://dummyimage.com/213x100.png/5fa2dd/ffffff', 'C465');
insert into Trainee (ssn, dob, photo, company_id) values ('009627907950', '10/03/2002', 'http://dummyimage.com/203x100.png/5fa2dd/ffffff', 'C423');
insert into Trainee (ssn, dob, photo, company_id) values ('404424240431', '09/03/2002', 'http://dummyimage.com/212x100.png/5fa2dd/ffffff', 'C423');
insert into Trainee (ssn, dob, photo, company_id) values ('927515078560', '21/09/2002', 'http://dummyimage.com/233x100.png/dddddd/000000', 'C465');
insert into Trainee (ssn, dob, photo, company_id) values ('218368804861', '14/10/2001', 'http://dummyimage.com/188x100.png/5fa2dd/ffffff', 'C932');
insert into Trainee (ssn, dob, photo, company_id) values ('469123343905', '20/06/2002', 'http://dummyimage.com/109x100.png/ff4444/ffffff', 'C254');
insert into Trainee (ssn, dob, photo, company_id) values ('324760934033', '18/06/2002', 'http://dummyimage.com/185x100.png/dddddd/000000', 'C254');
insert into Trainee (ssn, dob, photo, company_id) values ('576236976840', '07/04/2003', 'http://dummyimage.com/140x100.png/cc0000/ffffff', 'C932');
insert into Trainee (ssn, dob, photo, company_id) values ('676163562912', '18/02/2002', 'http://dummyimage.com/116x100.png/5fa2dd/ffffff', 'C254');
insert into Trainee (ssn, dob, photo, company_id) values ('430693807644', '27/03/2002', 'http://dummyimage.com/234x100.png/5fa2dd/ffffff', 'C465');
insert into Trainee (ssn, dob, photo, company_id) values ('206251664438', '26/02/2002', 'http://dummyimage.com/161x100.png/5fa2dd/ffffff', 'C465');
insert into Trainee (ssn, dob, photo, company_id) values ('786164962370', '06/05/2002', 'http://dummyimage.com/146x100.png/dddddd/000000', 'C932');
insert into Trainee (ssn, dob, photo, company_id) values ('942244652860', '14/11/2002', 'http://dummyimage.com/106x100.png/5fa2dd/ffffff', 'C254');
insert into Trainee (ssn, dob, photo, company_id) values ('672691285744', '21/02/2003', 'http://dummyimage.com/210x100.png/dddddd/000000', 'C254');
insert into Trainee (ssn, dob, photo, company_id) values ('172638933387', '24/05/2002', 'http://dummyimage.com/203x100.png/5fa2dd/ffffff', 'C254');
insert into Trainee (ssn, dob, photo, company_id) values ('304688803531', '06/06/2003', 'http://dummyimage.com/243x100.png/cc0000/ffffff', 'C423');
insert into Trainee (ssn, dob, photo, company_id) values ('866280004328', '12/10/2003', 'http://dummyimage.com/119x100.png/ff4444/ffffff', 'C423');
insert into Trainee (ssn, dob, photo, company_id) values ('220156814586', '14/07/2002', 'http://dummyimage.com/244x100.png/dddddd/000000', 'C254');
insert into Trainee (ssn, dob, photo, company_id) values ('294410326371', '13/05/2002', 'http://dummyimage.com/227x100.png/5fa2dd/ffffff', 'C254');
insert into Trainee (ssn, dob, photo, company_id) values ('187794991025', '21/09/2003', 'http://dummyimage.com/146x100.png/cc0000/ffffff', 'C254');
insert into Trainee (ssn, dob, photo, company_id) values ('199684642337', '14/12/2003', 'http://dummyimage.com/213x100.png/cc0000/ffffff', 'C254');
insert into Trainee (ssn, dob, photo, company_id) values ('819394503449', '05/09/2002', 'http://dummyimage.com/237x100.png/ff4444/ffffff', 'C465');
insert into Trainee (ssn, dob, photo, company_id) values ('638255538685', '23/06/2003', 'http://dummyimage.com/136x100.png/ff4444/ffffff', 'C465');
insert into Trainee (ssn, dob, photo, company_id) values ('147513211437', '19/11/2003', 'http://dummyimage.com/149x100.png/5fa2dd/ffffff', 'C423');
insert into Trainee (ssn, dob, photo, company_id) values ('315377723665', '15/07/2003', 'http://dummyimage.com/163x100.png/5fa2dd/ffffff', 'C465');
insert into Trainee (ssn, dob, photo, company_id) values ('334756218587', '10/07/2002', 'http://dummyimage.com/231x100.png/ff4444/ffffff', 'C932');

insert into MC     values ('854860566018');
insert into Mentor values ('403182588436');
insert into Mentor values ('184968201267');
insert into Mentor values ('239843063885');
insert into Mentor values ('086299707329');

insert into InvitedGuest values ('');
insert into InvitedGuest values ('');
insert into InvitedGuest values ('');
insert into InvitedGuest values ('');


insert into Singer values ('403182588436', 1);
insert into Singer values ('184968201267', 2);


insert into SingerSignatureSong values ('403182588436', 'Dem giot sau roi');
insert into SingerSignatureSong values ('403182588436', 'Tim em dem giang sinh');
insert into SingerSignatureSong values ('184968201267', 'Chuot yeu gao');

insert into Song values ('', 2021, 'Just in Love', null);
insert into Song values ('', 2003, 'Allafunksesimilia', null);
insert into Song values ('', 2006, 'Ghost', null);
insert into Song values ('', 2015, 'Soldier Song', null);
insert into Song values ('', 2020, 'Something About Rain', null);
insert into Song values ('', 2016, 'Sinking Feeling', null);
insert into Song values ('', 2015, 'Olden voices ', null);
insert into Song values ('', 2021, 'Red Cola', null);
insert into Song values ('', 2018, 'Breathe Easy Friend', null);
insert into Song values ('', 2018, 'Favourite Copy', null);
insert into Song values ('', 2012, 'White Minutes', null);
insert into Song values ('', 1996, 'Void Of Suite', null);
insert into Song values ('', 2000, 'Slack Off Night', null);

insert into ThemeSong values ('S1');

insert into SongWriter values ('239843063885');

insert into SongComposedBy values ('S1', '239843063885');

insert into Producer values ('086299707329');

insert into ProducerProgram values ('086299707329', 'Master of Illusion');
insert into ProducerProgram values ('086299707329', 'Bewitching Dance');

insert into Season values (2021, 'Quan 10, Ho Chi Minh', 'S1', '854860566018');

insert into SeasonMentor values (2021, '403182588436');
insert into SeasonMentor values (2021, '184968201267');
insert into SeasonMentor values (2021, '239843063885');
insert into SeasonMentor values (2021, '086299707329');


insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'996730324052');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'118459356212');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'529511218687');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'164287459396');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'844687021716');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'612403510769');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'267112162640');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'202017566494');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'053796327184');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'439743433939');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'079496761933');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'829510745846');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'351008093214');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'286576417983');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'561431834647');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'819499566621');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'658532596000');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'325480102130');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'484259653727');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'049253761330');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'900031544666');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'099140063202');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'875739166533');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'659008228930');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'110581129953');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'009627907950');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'404424240431');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'927515078560');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'218368804861');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'469123343905');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'324760934033');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'576236976840');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'676163562912');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'430693807644');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'206251664438');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'786164962370');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'942244652860');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'672691285744');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'172638933387');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'304688803531');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'866280004328');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'220156814586');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'294410326371');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'187794991025');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'199684642337');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'819394503449');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'638255538685');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'147513211437');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'315377723665');
insert into SeasonTrainee (SYEAR, ssn_trainee) values (2021,'334756218587');

insert into MentorValuateTrainee(syear, ssn_trainee, ssn_mentor, score)
select 2021, Trainee.ssn, Mentor.ssn, dbms_random.value(1,100)
from Trainee, Mentor;

insert into Episode values (2021, 1, 'BAI HAT CHU DE', '1/10/2021 19:00', 270);
insert into Episode values (2021, 2, 'DANH GIA KY NANG', '2/10/2021 19:00', 180);
insert into Episode values (2021, 3, 'THI DAU NHOM', '3/10/2021 19:00', 90);
insert into Episode values (2021, 4, 'KHACH MOI', '4/10/2021 19:00', 120);
insert into Episode values (2021, 5, 'CHUNG KET', '5/10/2021 19:00', 180);

insert into Stage values (2021, 1, 1, 'n', 4, 0, 'S8');

insert into StageIncludeTrainee (syear, ep_no, stage_no, ssn_trainee, srole, no_of_votes)
select syear, ep_no, stage_no, ssn, 1, null
from Stage, Trainee
where Stage.ep_no = 1;

insert into Stage values (2021, 2, 1, 'y', 1, 0, 'S2');
insert into Stage values (2021, 2, 2, 'y', 2, 0, 'S3');
insert into Stage values (2021, 2, 3, 'y', 3, 0, 'S4');
insert into Stage values (2021, 2, 4, 'y', 1, 0, 'S5');
insert into Stage values (2021, 2, 5, 'y', 2, 0, 'S6');
insert into Stage values (2021, 2, 6, 'y', 3, 0, 'S7');

create sequence ep2_seq start with 1 maxvalue 6 cycle cache 4;
insert into StageIncludeTrainee (syear, ep_no, stage_no, ssn_trainee, srole, no_of_votes)
select syear, ep_no, ep2_seq.NEXTVAl, ssn, 1, dbms_random.value(0,500)
from Stage, Trainee t
where Stage.ep_no = 2 and Stage.stage_no = 1 and exists (
    select * from (
        select * from (
            select ssn, sum(score) 
            from  Trainee t, MentorValuateTrainee m
            where ssn = m.ssn_trainee
            group by ssn
            order by sum(score) DESC
        ) where rownum <= 30
    ) where ssn = t.ssn 
);
BEGIN
FOR counter IN 1 .. 6 LOOP  
    update StageIncludeTrainee set srole = 2 where (syear, ep_no, stage_no, ssn_trainee) in
        (select syear, ep_no, stage_no, ssn_trainee from ( select * from StageIncludeTrainee 
            where ep_no = 2 and stage_no = counter and srole = 1
            order by dbms_random.value ) where rownum = 1);
    update StageIncludeTrainee set srole = 3 where (syear, ep_no, stage_no, ssn_trainee) in
        (select syear, ep_no, stage_no, ssn_trainee from ( select * from StageIncludeTrainee 
            where ep_no = 2 and stage_no = counter and srole = 1
            order by dbms_random.value ) where rownum = 1);
END LOOP;        
END;
/
insert into Stage values (2021, 3, 1, 'y', 4, 0, 'S8');
insert into Stage values (2021, 3, 2, 'y', 4, 0, 'S9');
insert into Stage values (2021, 3, 3, 'y', 4, 0, 'S8');
insert into Stage values (2021, 3, 4, 'y', 4, 0, 'S9');

create sequence ep3_seq start with 1 maxvalue 4 cycle nocache;
insert into StageIncludeTrainee (syear, ep_no, stage_no, ssn_trainee, srole, no_of_votes)
select syear, 3, ep3_seq.NEXTVAl, ssn_trainee, 1, dbms_random.value(0,500)
from StageIncludeTrainee t
where t.ep_no = 2 and exists (
    select * from (
        select * from (
            select ssn_trainee
            from  StageIncludeTrainee i
            where i.ep_no = 2
            order by i.no_of_votes DESC
        ) where rownum <= 20
    ) where ssn_trainee = t.ssn_trainee 
);
BEGIN
FOR counter IN 1 .. 4 LOOP  
    update StageIncludeTrainee set srole = 2 where (syear, ep_no, stage_no, ssn_trainee) in
        (select syear, ep_no, stage_no, ssn_trainee from ( select * from StageIncludeTrainee 
            where ep_no = 3 and stage_no = counter and srole = 1
            order by dbms_random.value ) where rownum = 1);
    update StageIncludeTrainee set srole = 3 where (syear, ep_no, stage_no, ssn_trainee) in
        (select syear, ep_no, stage_no, ssn_trainee from ( select * from StageIncludeTrainee 
            where ep_no = 3 and stage_no = counter and srole = 1
            order by dbms_random.value ) where rownum = 1);
END LOOP;        
END;
/
insert into Stage values (2021, 4, 1, 'y', 4, 0, 'S10');
insert into Stage values (2021, 4, 2, 'y', 4, 0, 'S11');
insert into Stage values (2021, 4, 3, 'y', 4, 0, 'S12');
insert into Stage values (2021, 4, 4, 'y', 4, 0, 'S13');

insert into GGroup values ('The Nerd Herd', 5, 3);
insert into GGroup values ('Tech Turtles', 2, 4);

insert into GroupSignatureSong values ('The Nerd Herd', 'Ghost');
insert into GroupSignatureSong values ('The Nerd Herd', 'Soldier Song');
insert into GroupSignatureSong values ('Tech Turtles', 'Discover Soul');

insert into GuestSupportStage values ( 1, 2021, 4, 4);
insert into GuestSupportStage values ( 2, 2021, 4, 1);
insert into GuestSupportStage values ( 3, 2021, 4, 2);
insert into GuestSupportStage values ( 4, 2021, 4, 3);

create sequence ep4_seq start with 1 maxvalue 4 cycle nocache;
insert into StageIncludeTrainee (syear, ep_no, stage_no, ssn_trainee, srole, no_of_votes)
select syear, 4, ep4_seq.NEXTVAl, ssn_trainee, 1, dbms_random.value(0,500)
from StageIncludeTrainee t
where t.ep_no = 3 and not exists (
    select * from
        (select e.*, rownum rn from
            (select ssn_trainee, no_of_votes, d.stage_no from StageIncludeTrainee s,
                (select c.*, rownum rn from
                    (select a.stage_no as stage_no, a.votesum as votesum, song_id
                    from  (select stage_no, sum(no_of_votes) as votesum from StageIncludeTrainee s 
                    where s.ep_no = 3 group by stage_no) a
                    , (select stage_no, song_id from Stage s where s.ep_no = 3) b
                    where a.stage_no = b.stage_no order by song_id, votesum) c) d
            where  s.ep_no = 3 and s.stage_no = d.stage_no and mod(rn,2) = 1
            order by stage_no, no_of_votes) e) f
    where (mod(rn, 5) = 1 or mod(rn,5) = 2) and t.ssn_trainee = f.ssn_trainee
);

BEGIN
FOR counter IN 1 .. 4 LOOP  
    update StageIncludeTrainee set srole = 2 where (syear, ep_no, stage_no, ssn_trainee) in
        (select syear, ep_no, stage_no, ssn_trainee from ( select * from StageIncludeTrainee 
            where ep_no = 4 and stage_no = counter and srole = 1
            order by dbms_random.value ) where rownum = 1);
    update StageIncludeTrainee set srole = 3 where (syear, ep_no, stage_no, ssn_trainee) in
        (select syear, ep_no, stage_no, ssn_trainee from ( select * from StageIncludeTrainee 
            where ep_no = 4 and stage_no = counter and srole = 1
            order by dbms_random.value ) where rownum = 1);
END LOOP;        
END;
/

insert into Stage values (2021, 5, 1, 'y', 4, 0, 'S2');
insert into Stage values (2021, 5, 2, 'y', 4, 0, 'S3');
insert into Stage values (2021, 5, 3, 'n', 4, 0, 'S4');
insert into Stage values (2021, 5, 4, 'n', 4, 0, 'S5');
insert into Stage values (2021, 5, 5, 'n', 4, 0, 'S6');
insert into Stage values (2021, 5, 6, 'n', 4, 0, 'S7');
insert into Stage values (2021, 5, 7, 'n', 4, 0, 'S8');
insert into Stage values (2021, 5, 8, 'n', 4, 0, 'S9');
insert into Stage values (2021, 5, 9, 'n', 4, 0, 'S10');
insert into Stage values (2021, 5, 10, 'n', 4, 0, 'S11');
insert into Stage values (2021, 5, 11, 'n', 4, 0, 'S12');
insert into Stage values (2021, 5, 12, 'n', 4, 0, 'S13');


create sequence ep5_seq start with 3 minvalue 3 maxvalue 12 cycle nocache;
insert into StageIncludeTrainee (syear, ep_no, stage_no, ssn_trainee, srole, no_of_votes)
select syear, 5, ep5_seq.NEXTVAl, ssn_trainee, 1, dbms_random.value(0,500)
from StageIncludeTrainee t
where t.ep_no = 4 and exists (
    select * from (
        select * from (
            select ssn_trainee
            from  StageIncludeTrainee i
            where i.ep_no = 4
            order by i.no_of_votes DESC
        ) where rownum <= 10
    ) where ssn_trainee = t.ssn_trainee 
);

create sequence ep5_seq2 start with 1 maxvalue 2 cycle nocache;
insert into StageIncludeTrainee (syear, ep_no, stage_no, ssn_trainee, srole, no_of_votes)
select syear, 5, ep5_seq2.NEXTVAl, ssn_trainee, 1, dbms_random.value(0,500)
from StageIncludeTrainee t
where t.ep_no = 4 and exists (
    select * from (
        select * from (
            select ssn_trainee
            from  StageIncludeTrainee i
            where i.ep_no = 4
            order by i.no_of_votes DESC
        ) where rownum <= 10
    ) where ssn_trainee = t.ssn_trainee 
);
        
BEGIN
FOR counter IN 1 .. 2 LOOP  
    update StageIncludeTrainee set srole = 2 where (syear, ep_no, stage_no, ssn_trainee) in
        (select syear, ep_no, stage_no, ssn_trainee from ( select * from StageIncludeTrainee 
            where ep_no = 5 and stage_no = counter and srole = 1
            order by dbms_random.value ) where rownum = 1);
    update StageIncludeTrainee set srole = 3 where (syear, ep_no, stage_no, ssn_trainee) in
        (select syear, ep_no, stage_no, ssn_trainee from ( select * from StageIncludeTrainee 
            where ep_no = 5 and stage_no = counter and srole = 1
            order by dbms_random.value ) where rownum = 1);
END LOOP;        
END;            
/
///////////////////lay ket qua////////////////////
--        select * from (
--            select ssn_trainee, sum(no_of_votes)
--            from  StageIncludeTrainee
--            where ep_no = 5
--            group by ssn_trainee
--            order by sum(no_of_votes) DESC
--        ) where rownum <= 5
--            
--            



--trigger 3.1-------------------------------------------------------------------
CREATE OR REPLACE TRIGGER one_group_e234
BEFORE
INSERT OR UPDATE ON StageIncludeTrainee
FOR EACH ROW
DECLARE c INT;
BEGIN
     IF :new.ep_No != 5 THEN
         SELECT count(SSN_trainee) INTO c
         FROM StageIncludeTrainee
         WHERE syear = :new.syear AND ep_No = :new.ep_No AND SSN_trainee = :new.SSN_trainee;
         IF c > 0 THEN
             raise_application_error(-20999, 'This trainee already has a group in this episode');
         END IF;
     END IF;
END;
/
--test
-- insert into stageincludetrainee values(2021,2,2,'009627907950',1,1);            --khac nhom nhung trung role thi sao

-- insert into Episode values (2020, 3, 'THI DAU NHOM', '3/10/2021 19:00', 90);
-- insert into stage               values(2020,3,1,'y',2,0,'S3');
-- insert into stageincludetrainee values(2020,3,1,'325480102130',1,1);             --tham gia tap cao hon cho phep
-- insert into stageincludetrainee values(2020,3,2,'325480102130',1,1);
--print This trainee already has a stage in this episode
                                                                                --nam cua tap khhac voi nam trong timestamp
                                                                                
--------------------------------------------------------------------------------

--trigger 3.2-------------------------------------------------------------------

CREATE OR REPLACE TRIGGER two_ep_5
BEFORE
INSERT OR UPDATE ON StageIncludeTrainee
FOR EACH ROW
DECLARE c INT; inGroup CHAR(1);
        N INT;
BEGIN
     IF :new.ep_No = 5 THEN
         SELECT is_group INTO inGroup
         FROM Stage
         WHERE syear = :new.syear AND ep_No = :new.ep_No AND stage_No = :new.stage_No;
         IF inGroup = 'n' THEN
             SELECT COUNT(SSN_trainee) INTO c
             FROM StageIncludeTrainee
             WHERE syear = :new.syear AND ep_No = :new.ep_No AND stage_No = :new.stage_No;
             IF c > 0 THEN raise_application_error(-20999, 'This stage already has a trainee, it can not have two trainee in a individual stage'); END IF;
            
             SELECT COUNT(Stage_NO) INTO c
             FROM StageIncludeTrainee
             WHERE syear = :new.syear AND ep_No = :new.ep_No AND SSN_trainee = :new.SSN_trainee;
             
             IF c = 2 THEN raise_application_error(-20999, 'This trainee joined at both'); END IF;
             IF C=1 THEN
                        SELECT STAGE_NO INTO N
                        FROM STAGEINCLUDETRAINEE
                        WHERE syear = :new.syear AND ep_No = :new.ep_No AND SSN_trainee = :new.SSN_trainee;
            
                         SELECT IS_GROUP INTO INGROUP
                         FROM STAGE
                         WHERE SYEAR=:NEW.SYEAR AND EP_NO=:NEW.EP_NO AND STAGE_NO=N;
             
             IF INGROUP = 'n' THEN raise_application_error(-20999, 'This trainee has already joined a individual stage stage, so he/she can not join another individual stage'); END IF;
             
             END IF;
             
         ELSE
             SELECT COUNT(SSN_trainee) INTO c
             FROM StageIncludeTrainee
             WHERE syear = :new.syear AND ep_No = :new.ep_No AND stage_No = :new.stage_No;
             IF c = 5 THEN raise_application_error(-20999, 'This group has maximum 5 trainees'); END IF;
             SELECT COUNT(Stage_NO) INTO c
             FROM StageIncludeTrainee
             WHERE syear = :new.syear AND ep_No = :new.ep_No AND SSN_trainee = :new.SSN_trainee;
             
             IF c >= 2 THEN raise_application_error(-20999, 'This trainee has done'); END IF;
             IF C=1 THEN
                        SELECT STAGE_NO INTO N
                        FROM STAGEINCLUDETRAINEE
                        WHERE syear = :new.syear AND ep_No = :new.ep_No AND SSN_trainee = :new.SSN_trainee;
            
                          SELECT IS_GROUP INTO INGROUP
                         FROM STAGE
                         WHERE SYEAR=:NEW.SYEAR AND EP_NO=:NEW.EP_NO AND STAGE_NO=N;
             
             IF INGROUP = 'y' THEN raise_application_error(-20999, 'This trainee has joined another group'); END IF;
             
             END IF;
                    
         END IF;
         
     END IF;
END;
/
--test--
-- insert into Episode             values (2020, 5, 'CHUNG KET', '5/10/2021 19:00', 90);
-- insert into stage               values (2020, 5, 1, 'y', 2, 0, 'S5');               --SKILL 2,5 MOI NH�U, C�N L?I 4
-- insert into stage               values (2020, 5, 2, 'n', 2, 0, 'S5');
-- insert into stage               values (2020, 5, 3, 'n', 2, 0, 'S5');
-- insert into stage               values (2020, 5, 4, 'y', 2, 0, 'S5');
-- insert into stageincludetrainee values (2020, 5, 2, '325480102130', 1, 1);
-- insert into stageincludetrainee values (2020, 5, 4, '325480102130', 1, 1);

-- insert into stageincludetrainee values (2020, 5, 4, '996730324052', 1, 1);
-- insert into stageincludetrainee values (2020, 5, 4, '118459356212', 1, 1);
-- insert into stageincludetrainee values (2020, 5, 4, '529511218687', 1, 1);
-- insert into stageincludetrainee values (2020, 5, 4, '164287459396', 1, 1);
-- insert into stageincludetrainee values (2020, 5, 4, '844687021716', 1, 1);
--------------------------------------------------------------------------------

