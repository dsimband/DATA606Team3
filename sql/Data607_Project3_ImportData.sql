

CREATE SCHEMA `DATA607`;
CREATE SCHEMA `staging_db`;


use staging_db;



---------------------------------------------------------------------------------------
------             Create and Popualate Staging Tables
---------------------------------------------------------------------------------------


DROP TABLE IF EXISTS JobOpenings;

CREATE TABLE JobOpenings (
job_id			int,
min_experience		int,
max_experience		int,
skill			varchar(40),
location		varchar(40),
min_salary		int,
max_salary		int,
company_id		int
);



LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\JobOpenings.csv'
INTO TABLE JobOpenings
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


select * from JobOpenings;





--------------------------------------------------------------------

DROP TABLE IF EXISTS JobSeekers;

CREATE TABLE JobSeekers (
resp_id		int,
gender		char(1),
age		int,
location	varchar(40),
education	varchar(40),
major	varchar(40),
title	varchar(40),
industry	varchar(40),
experience	varchar(40),
dataScientist	varchar(40),
primarySkill	varchar(40),
skill		varchar(40)
);





LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\JobSeekers.csv'
INTO TABLE JobSeekers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;




-- select * from JobSeekers;

---------------------------------------------------------------------------------------


use Data607;




---------------------------------------------------------------------------------------
------             Create and Popualate Reference Tables
---------------------------------------------------------------------------------------

DROP TABLE IF EXISTS SkillReference;

CREATE TABLE SkillReference (
id			int  not null AUTO_INCREMENT primary key,
short_description	varchar(20),
long_description	varchar(200)
);

create unique INDEX skils_reference_i0 on SkillReference(id);


insert SkillReference (short_description, long_description)
	select distinct skill, " " from staging_db.JobOpenings;
    
 select * from SkillReference;
    



---------------------------------------------------------------------------------------    


DROP TABLE IF EXISTS LocationReference;

CREATE TABLE LocationReference (
id			int  not null AUTO_INCREMENT primary key,
short_description	varchar(20),
long_description	varchar(200)
);

create unique INDEX location_reference_i0 on LocationReference(id);


insert LocationReference (short_description, long_description)
	select distinct location, " " from staging_db.JobOpenings;

update LocationReference 
	set long_description="Southeastern India Large Technology Parks" 
    where short_description="Pune";

select * from LocationReference;





---------------------------------------------------------------------------------------    


DROP TABLE IF EXISTS EducationLevelReference;

CREATE TABLE EducationLevelReference (
id			int  not null AUTO_INCREMENT primary key,
short_description	varchar(20),
long_description	varchar(200)
);

create unique INDEX educationLevel_reference_i0 on EducationLevelReference(id);

insert EducationLevelReference (short_description, long_description)
	select distinct education, " " from staging_db.JobSeekers;


select * from EducationLevelReference;







---------------------------------------------------------------------------------------    

DROP TABLE IF EXISTS IndustryReference;

CREATE TABLE IndustryReference	 (
id			int  not null AUTO_INCREMENT primary key,
short_description	varchar(20),
long_description	varchar(200)
);

create unique INDEX industry_reference_i0 on IndustryReference(id);

insert IndustryReference (short_description, long_description)
	select distinct industry, " " from staging_db.JobSeekers;


select * from IndustryReference;




---------------------------------------------------------------------------------------    


DROP TABLE IF EXISTS MajorReference;

CREATE TABLE MajorReference	 (
id			int  not null AUTO_INCREMENT primary key,
short_description	varchar(20),
long_description	varchar(200)
);


create unique INDEX major_reference_i0 on MajorReference(id);

insert MajorReference (short_description, long_description)
	select distinct major, " " from staging_db.JobSeekers;


select * from MajorReference;


---------------------------------------------------------------------------------------    


DROP TABLE IF EXISTS TitleReference;

CREATE TABLE TitleReference	 (
id			int  not null AUTO_INCREMENT primary key,
short_description	varchar(20),
long_description	varchar(200)
);


create unique INDEX title_reference_i0 on TitleReference(id);

insert TitleReference (short_description, long_description)
	select distinct industry, " " from staging_db.JobSeekers;


select * from TitleReference;





------------------------------------------------


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
	select distinct min_salary, max_salary, " ", " " from staging_db.JobOpenings;


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





DROP TABLE IF EXISTS JobSalary;


CREATE TABLE JobSalary	 (
id			int primary key,
min			int,
max			int
);


insert JobSalary 
	select distinct job_id, min_salary, max_salary  from staging_db.JobOpenings;


select * from JobSalary;




---------------------------------------------------------------------------------------

DROP TABLE IF EXISTS JobLocation;

CREATE TABLE JobLocation	 (
id				int,     -- not unique
location_id		int
);

insert JobLocation (id, location_id)
	select distinct a.job_id, b.id  from staging_db.JobOpenings a, LocationReference b where a.location=b.short_description;

select * from JobLocation;

---------------------------------------------------------------------------------------

DROP TABLE IF EXISTS JobRequirements;

CREATE TABLE JobRequirements (
id			    int,  -- not unique
skill_id		int
);


insert JobRequirements (id, skill_id)
	select distinct a.job_id, b.id  from staging_db.JobOpenings a, SkillReference b where a.skill=b.short_description;

select * from JobRequirements;



-----------------------------------------------------------------------------------------


DROP TABLE IF EXISTS JobSeekerSkills;




CREATE TABLE JobSeekerSkills (
id			int primary key,  -- not unique
skill_id		int
);


insert JobSeekerSkills (id, skill_id)
	select distinct a.resp_id, b.id  from staging_db.JobSeekers a, SkillReference b where a.skill=b.short_description;

select * from JobSeekerSkills;



----------------------------------------------------------------------------------------------------------------------



DROP TABLE IF EXISTS JobSeeker;

CREATE TABLE JobSeeker (
id			int primary key,  
location		varchar(40),
education_level_id	integer,
major_id		integer,
title_id		integer,
industry_id		integer
);

 

insert JobSeeker 
(id, location, education_level_id, major_id, title_id, industry_id)
	select
		distinct
			a.resp_id, a.location, b.id, c.id, d.id, e.id
		from
			staging_db.JobSeekers a,
            EducationLevelReference b,
            MajorReference c,
            TitleReference d,
            IndustryReference e
		where
			a.education=b.short_description and
			a.major=c.short_description and
			a.title=d.short_description and
			a.industry=e.short_description;
       
       
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
            
