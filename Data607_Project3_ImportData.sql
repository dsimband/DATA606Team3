

CREATE SCHEMA `DATA607`;
CREATE SCHEMA `staging_db`;


use staging_db;



---------------------------------------------------------------------------------------
------             Create and Popualate Staging Tables
---------------------------------------------------------------------------------------



DROP TABLE IF EXISTS JobOpeningsStage;



CREATE TABLE JobOpeningsStage (
job_id			int,
experience		varchar(40),
job_type      varchar(40),
location		varchar(120),
min_salary		int,
max_salary		int,
company_id		int,
skill			varchar(40),
skill_id		varchar(40)
);



LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\job_opening_skills.csv'
INTO TABLE JobOpeningsStage
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

# ------------------------------------------------------------





select * from JobOpeningsStage;




--------------------------------------------------------------------

DROP TABLE IF EXISTS JobSeekersStage;

# id	gender	age	location	degree	major	title	industry	DS	skill


CREATE TABLE JobSeekersStage (
resp_id		int,
gender		char(120),
age		char(20),
location	varchar(140),
education	varchar(120),
major	varchar(120),
title	varchar(120),
industry	varchar(120),
dataScientist	varchar(120),
skill	varchar(120)
);





LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\job_seeker_skills.csv'
INTO TABLE JobSeekersStage
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


--  delete  from JobSeekersStage;


UPDATE staging_db.JobSeekersStage set skill = replace(skill,'\r','');

# ----------------------------------------------------------------------------------------------
#      NOTE : The below data munging is temporary. We want to fix the skill sets.
# ----------------------------------------------------------------------------------------------
select title, count(*) from staging_db.JobSeekersStage group by title;
select gender, count(*) from JobSeekersStage group by gender;
select skill, count(*) from JobSeekersStage group by skill;
update JobSeekersStage set gender="NA" where gender not in ('Male','Female');

#   Java,Python,SQL,Javascript/Typescript,C#/.NET,R,MATLAB,C/C++,Visual Basic/VBA,Bash,Scala,PHP,SAS/STATA
update JobSeekersStage set skill="C#" where skill = "C#/.NET";
update JobSeekersStage set skill="Java" where skill like 'Javascript%';
update JobSeekersStage set skill='Predictive Analytics'  where skill like '%VBA%';
update JobSeekersStage set skill="C++" where skill like '%C++%';
update JobSeekersStage set skill="ML" where skill like 'Ruby%';
update JobSeekersStage set skill="ML" where skill like 'Go%';
update JobSeekersStage set skill="ML" where skill like 'Julia%';
update JobSeekersStage set skill="OTHER" where skill not in ("ML","C#","Java",'Predictive Analytics',"C++","SQL","R", "MATLAB");


update JobOpeningsStage set skill='Java' where skill='hadoop';
update JobOpeningsStage set skill='SQL' where skill='sql';
update JobOpeningsStage set skill='Python' where skill='python';
update JobOpeningsStage set skill='R' where skill='r';
update JobOpeningsStage set skill='MATLAB' where skill='matlab';
update JobOpeningsStage set skill='ML' where skill='machine learning';
update JobOpeningsStage set skill='ML' where skill='machine learning engineer';
update JobOpeningsStage set skill='Predictive Analytics' where skill='predictive analytics';
update JobOpeningsStage set skill='C#' where skill='team leading';

# ----------------------------------------------------------------------------------------------

select skill, count(*) from JobOpeningsStage where skill in ('SQL','Python','R','MATLAB', 'ML') GROUP BY skill;

select skill, count(*) from JobOpeningsStage group by skill;

update JobOpeningsStage set skill="OTHER" where skill not in ("ML","C#","Java",'Predictive Analytics',"C++","SQL","R", "MATLAB");

update JobSeekersStage set skill="OTHER" where skill not in ("ML","C#","Java",'Predictive Analytics',"C++","SQL","R", "MATLAB");

-- select * from JobSeekers;

---------------------------------------------------------------------------------------


use Data607;




---------------------------------------------------------------------------------------
------             Create and Popualate Reference Tables
---------------------------------------------------------------------------------------

DROP TABLE IF EXISTS SkillReference;

CREATE TABLE SkillReference (
id			int  not null AUTO_INCREMENT primary key,
short_description	varchar(40),
long_description	varchar(200)
);

create unique INDEX skils_reference_i0 on SkillReference(id);

delete from SkillReference;

insert SkillReference (short_description, long_description)
     select distinct skill, ' ' from staging_db.JobOpeningsStage
     union
     select distinct skill, ' ' from staging_db.JobSeekersStage;


    
 select * from SkillReference;
 
 
   



---------------------------------------------------------------------------------------    


DROP TABLE IF EXISTS LocationReference;

delete from LocationReference;

CREATE TABLE LocationReference (
id			int  not null AUTO_INCREMENT primary key,
short_description	varchar(60),
long_description	varchar(200)
);

create unique INDEX location_reference_i0 on LocationReference(id);


insert LocationReference (short_description, long_description)
	 select distinct location, ' ' from staging_db.JobOpeningsStage
     union
     select distinct location, ' ' from staging_db.JobSeekersStage;
     

update LocationReference 
	set long_description="Southeastern India Large Technology Parks" 
    where short_description="Pune";

select * from LocationReference;





---------------------------------------------------------------------------------------    


DROP TABLE IF EXISTS EducationLevelReference;

delete from EducationLevelReference;

CREATE TABLE EducationLevelReference (
id			int  not null AUTO_INCREMENT primary key,
short_description	varchar(240),
long_description	varchar(200)
);

create unique INDEX educationLevel_reference_i0 on EducationLevelReference(id);

insert EducationLevelReference (short_description, long_description)
	select distinct education, " " from staging_db.JobSeekersStage;


select * from EducationLevelReference;





---------------------------------------------------------------------------------------    

DROP TABLE IF EXISTS IndustryReference;

delete from IndustryReference;

CREATE TABLE IndustryReference	 (
id			int  not null AUTO_INCREMENT primary key,
short_description	varchar(120),
long_description	varchar(200)
);

create unique INDEX industry_reference_i0 on IndustryReference(id);

insert IndustryReference (short_description, long_description)
	select distinct industry, " " from staging_db.JobSeekersStage;


select * from IndustryReference;




---------------------------------------------------------------------------------------    


DROP TABLE IF EXISTS MajorReference;

CREATE TABLE MajorReference	 (
id			int  not null AUTO_INCREMENT primary key,
short_description	varchar(120),
long_description	varchar(200)
);


create unique INDEX major_reference_i0 on MajorReference(id);

insert MajorReference (short_description, long_description)
	select distinct major, " " from staging_db.JobSeekersStage;


select * from MajorReference;


---------------------------------------------------------------------------------------    


DROP TABLE IF EXISTS TitleReference;

CREATE TABLE TitleReference	 (
id			int  not null AUTO_INCREMENT primary key,
short_description	varchar(120),
long_description	varchar(200)
);

delete  from TitleReference;

create unique INDEX title_reference_i0 on TitleReference(id);

insert TitleReference (short_description, long_description)
	select distinct title, " " from staging_db.JobSeekersStage;



select * from TitleReference;





------------------------------------------------

-- not sure this helps

DROP TABLE IF EXISTS SalaryRangeReference;

CREATE TABLE SalaryRangeReference	 (
min			int,
max			int,
short_description	varchar(20),
long_description	varchar(200),
 PRIMARY KEY(min,max)
);

create unique INDEX title_reference_i0 on SalaryRangeReference(min,max);

insert SalaryRangeReference (min,max,short_description,long_description)
	select distinct min_salary, max_salary, " ", " " from staging_db.JobOpeningsStage;


select * from SalaryRangeReference;






---------------------------------------------------------









---------------------------------------------------------------------------------------    
-------                  Create and Popualate Data Tables
---------------------------------------------------------------------------------------    

/* 
	Create Data Tables :
		JobSalaries
		JobLocation
		JobSeekers
		JobSeekerSkills				

*/




-- not sure this helps

DROP TABLE IF EXISTS JobSalary;


CREATE TABLE JobSalary	 (
id			int primary key,
min			int,
max			int
);


insert JobSalary 
	select distinct job_id, min_salary, max_salary  from staging_db.JobOpeningsStage;


select * from JobSalary;




---------------------------------------------------------------------------------------

DROP TABLE IF EXISTS JobLocation;

delete from JobLocation;

CREATE TABLE JobLocation (
id				int,     -- not unique
location_id		int
);

insert JobLocation (id, location_id)
	select distinct a.job_id, b.id  from staging_db.JobOpeningsStage a, LocationReference b where a.location=b.short_description;

select * from JobLocation;

---------------------------------------------------------------------------------------

DROP TABLE IF EXISTS JobRequirements;

CREATE TABLE JobRequirements (
id			    int,  -- not unique
skill_id		int
);

delete from JobRequirements;


insert JobRequirements (id, skill_id)
	select distinct a.job_id, b.id  from staging_db.JobOpeningsStage a, SkillReference b where a.skill=b.short_description;

select * from JobRequirements;



-----------------------------------------------------------------------------------------


DROP TABLE IF EXISTS JobSeekerSkills;


delete from  JobSeekerSkills;

CREATE TABLE JobSeekerSkills (
id			    int,  -- not unique
skill_id		int,
 PRIMARY KEY(id,skill_id)
);



insert JobSeekerSkills (id, skill_id)
    select distinct a.resp_id, b.id  from staging_db.JobSeekersStage a, SkillReference b where a.skill=b.short_description;

select * from JobSeekerSkills;


----------------------------------------------------------------------------------------------------------------------



DROP TABLE IF EXISTS JobSeeker;

CREATE TABLE JobSeeker (
id			int primary key,  
location_id		int,
education_level_id	integer,
major_id		integer,
title_id		integer,
industry_id		integer,
p_skill_id		int,
data_scientist   int
);

delete from JobSeeker;
 

 insert JobSeeker 
(id, location_id, education_level_id, major_id, title_id, industry_id, p_skill_id, data_scientist)
	select
		distinct
			a.resp_id, f.id, b.id, c.id, d.id, e.id, g.id, case when a.dataScientist='Yes' then 1 else 0 end
		from
			staging_db.JobSeekersStage a,
            EducationLevelReference b,
            MajorReference c,
            TitleReference d,
            IndustryReference e,
            LocationReference f,
            SkillReference g
		where
			a.education=b.short_description and
			a.major=c.short_description and
			a.title=d.short_description and
			a.industry=e.short_description and
            a.skill=g.short_description and
            a.location=f.short_description;
       
     
-- select * from JobSeeker; 
-- select * from MajorReference;
-- select * from staging_db.JobSeekersStage; 
   

       
       
       select  
			a.id as JobSeeker, 
			b.short_description as EducationLevel,
            c.short_description as Major,
            d.short_description as Title,
            e.short_description as Industry
		from 
		JobSeeker a,
        EducationLevelReference b,
            MajorReference c,
            TitleReference d,
            IndustryReference e
       where
			a.education_level_id=b.id and
			a.major_id=c.id and
			a.title_id=d.id and
			a.industry_id=e.id;
            
            
            
            select b.id, count(*)  from JobSeekerSkills a, JobRequirements b where a.skill_id=b.skill_id group by b.id;
            
            select * from JobRequirements where id=3;
            
            select * from JobSeekerSkills where skill_id in (56,57,53,54);
            
            select count(*) from JobSeekerSkills;   -- 94
            select count(*) from JobRequirements;   -- 28
            
select skill_id, count(*) from JobSeekerSkills group by skill_id;

select * from SkillReference;


--- distribution of skill sets by JobSeekers
select r.short_description,  count(*) from JobSeekerSkills s, SkillReference r where s.skill_id=r.id group by skill_id;


use DATA607;





--- distribution of skill sets by JobOpeningss
select r.short_description as skill,  count(*) as count from JobRequirements s, SkillReference r where s.skill_id=r.id group by skill_id;


select * from JobRequirements;




--- distribution of location by JobSeeker
select r.short_description as location,  count(*) as count from JobSeeker s, LocationReference r where s.location_id=r.id group by location_id;



--- distribution of title by JobSeeker
select r.short_description as title,  count(*) as count from JobSeeker s, TitleReference r where s.title_id=r.id group by title_id;


--- distribution of major by JobSeeker
select r.short_description as major,  count(*) as count from JobSeeker s, MajorReference r where s.major_id=r.id group by major_id;

select gender, count(*) from JobSeeker group by gender;

--- distribution of major by DataScientist
select data_scientist,  count(*) as count from JobSeeker  group by data_scientist;



select r.short_description as skill,  count(*) as count from JobSeekerSkills s, SkillReference r where s.skill_id=r.id group by skill_id;


select * from JobSeekerSkills;
select * from SkillReference;


select * from JobRequirements;

select * from JobOpenings;

select * from LocationReference;
select * from IndustryReference;
select * from MajorReference;
 select * from TitleReference;
select * from EducationLevelReference;



select * from JobSalaries;
select * from JobLocation;
select * from JobSeekers;
select * from JobSeekerSkills;		
            
