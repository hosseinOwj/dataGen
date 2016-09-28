/**********************************
        INSTALLATION FILE 
**********************************/
-- This file includes 3 tasks:
-- 1. Create Tables and Sequences using 'scripts\createTableFinal' file.
-- 2. Create all functions and procedures inculde in \functions and \procedures folder
-- 3. Load the Configuration file 'configuration.sql' with the default values

-- ***NOTICE*** Set the path variable with the exact path of the project in your system. Use '\' at the very end. 
-- Example. 'C:\finalProject\'

-- ***NOTICE*** This installation load the 'configuration.sql' with it's default values. You can manually run the configuration file with your own values.

set define on;
set define on;

-- Installation Directory
-- Change this variable with the exact path of the project(where you copy paste the folder). Use a '\' at the end.

define path = 'C:\DB\finalProject\';


-- define variables 
define s_createTables = 'scripts\createTableFinal'; 
define p_calculateRange = 'procedures\calculateRange';
define f_checkData = 'functions\checkData';
define f_getAddedDays = 'functions\getAddedDays';
define f_getErrorTimeID = 'functions\getErrorTimeID';
define f_getSubbedDays = 'functions\getSubbedDays';
define f_getTimeIDDif = 'functions\getTimeIDDif';
define f_randomizeID = 'functions\randomizeID';
define f_randomizeTimeID = 'functions\randomizeTimeID';
define f_returnAName = 'functions\returnAName';
define f_timeDiff = 'functions\timeDiff';
define p_deleteAll_F    = 'procedures\deleteAll_F';
define p_drop_all_constraints = 'procedures\drop_all_constraints';
define p_fact_Count = 'procedures\fact_Count';
define p_G_Delay_G = 'procedures\G_Delay_G';
define p_W_CUSTOMERLOCATION_D_GEN = 'procedures\W_CUSTOMERLOCATION_D_GEN';
define p_W_SALES_AGENT_D_GEN = 'procedures\W_SALES_AGENT_D_GEN';
define p_W_Time_D_Gen = 'procedures\W_Time_D_Gen';
define p_LEAD_JOB_SUB_SHIP_F_GEN = 'procedures\LEAD_JOB_SUB_SHIP_F_GEN';
define p_W_FINANC_SUM_COST_D_GEN = 'procedures\W_FINANC_SUM_COST_D_GEN';
define p_W_FINANC_SUM_SALES_D_GEN = 'procedures\W_FINANC_SUM_SALES_D_GEN';
define p_W_Job_Change_Data_Gen = 'procedures\W_Job_Change_Data_Gen';




-- Create Tables and Sequences
@&path&s_createTables;

-- Create Functions and Procedures
set define on;
@&path&p_calculateRange;  
@&path&f_checkData;   
@&path&f_getAddedDays; 
@&path&f_getErrorTimeID;
@&path&f_getSubbedDays;
@&path&f_getTimeIDDif;
@&path&f_randomizeID;
@&path&f_randomizeTimeID;
@&path&f_returnAName;
@&path&f_timeDiff;
@&path&p_deleteAll_F;
@&path&p_drop_all_constraints;
@&path&p_fact_Count;
@&path&p_G_Delay_G;
@&path&p_W_SALES_AGENT_D_GEN;
@&path&p_W_Time_D_Gen;
@&path&p_W_CUSTOMERLOCATION_D_GEN;
@&path&p_LEAD_JOB_SUB_SHIP_F_GEN;
set define on;
@&path&p_W_FINANC_SUM_COST_D_GEN;
@&path&p_W_FINANC_SUM_SALES_D_GEN;
@&path&p_W_Job_Change_Data_Gen;



-- Run the configuration file with the default values.
set define on;
define s_configuration = 'configuration'; 
@&path&s_configuration;





