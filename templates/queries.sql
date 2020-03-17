/* CREATE TEST TABLE */
CREATE TABLE CUSTOMERS  
( customer_id number(10) NOT NULL,  
  customer_name varchar2(50) NOT NULL,  
  city varchar2(50),  
  CONSTRAINT customers_pk PRIMARY KEY (customer_id)  
);

INSERT INTO CUSTOMERS VALUES (1234567890, 'teste', 'teste');

SELECT * FROM CUSTOMERS;

/* CREATE DATAPUMP FILE */
DECLARE
hdnl NUMBER;
BEGIN
	hdnl := DBMS_DATAPUMP.OPEN( operation => 'EXPORT', job_mode => 'SCHEMA', job_name=>null);
	DBMS_DATAPUMP.ADD_FILE(handle => hdnl, filename => 'sample.dmp', directory => 'DATA_PUMP_DIR', filetype => dbms_datapump.ku$_file_type_dump_file);
	DBMS_DATAPUMP.ADD_FILE( handle => hdnl, filename => 'exp.log', directory => 'DATA_PUMP_DIR', filetype => dbms_datapump.ku$_file_type_log_file);
	DBMS_DATAPUMP.METADATA_FILTER(hdnl,'SCHEMA_EXPR','IN (''ADMIN'')');
	DBMS_DATAPUMP.START_JOB(hdnl);
END;

SELECT * FROM  V$SESSION_LONGOPS WHERE OPNAME='DB_BACKUP';

/* UPLOADING TO S3 */
SELECT rdsadmin.rdsadmin_s3_tasks.upload_to_s3(
      p_bucket_name    =>  'poc-backup-bucket', 
      p_prefix         =>  '', 
      p_s3_prefix      =>  'dbfiles/', 
      p_directory_name =>  'DATA_PUMP_DIR') 
AS TASK_ID FROM DUAL;

/* DROP TEST TABLE */
DROP TABLE CUSTOMERS;

/* DELETE LOCAL DATAPUMP */
BEGIN 
	utl_file.fremove('DATA_PUMP_DIR','sample.dmp'); 
END;

/* DOWNLOADING FROM S3 */
SELECT rdsadmin.rdsadmin_s3_tasks.download_from_s3(
      p_bucket_name    =>  'poc-backup-bucket', 
      p_s3_prefix      =>  'dbfiles/', 
      p_directory_name =>  'DATA_PUMP_DIR') 
AS TASK_ID FROM DUAL;

/* VIEW TASK */
SELECT text FROM table(rdsadmin.rds_file_util.read_text_file('BDUMP','dbtask-1584429951483-621.log'));

/* RESTORING */
DECLARE
hdnl NUMBER;
BEGIN
	hdnl := DBMS_DATAPUMP.OPEN( operation => 'IMPORT', job_mode => 'SCHEMA', job_name=>null);
	DBMS_DATAPUMP.ADD_FILE( handle => hdnl, filename => 'sample.dmp', directory => 'DATA_PUMP_DIR', filetype => dbms_datapump.ku$_file_type_dump_file);
	DBMS_DATAPUMP.METADATA_FILTER(hdnl,'SCHEMA_EXPR','IN (''ADMIN'')');
	DBMS_DATAPUMP.START_JOB(hdnl);
END;