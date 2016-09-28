/**********************************
       READ ME BEFORE INSTALL
**********************************/
-- ABOUT:

-- This project is designed to generate sample data for  Credit Card Company, CPI Card Group, Inc., data warehouse.
-- This software generates data for different tables of data warehouse including:
-- DIMENTION TABLES: W_TIME_D, W_SALES_AGENT_D, W_CUSTOMER_D, W_CUST_LOCATION_D
-- FACT TABLES: W_LEAD_F, W_JOB_F, W_SUB_JOB_F, W_JOB_SJIPMENT_F, W_INVOICELINE_F, W_FINANCIAL_SUMMARY_SALES_F, W_FINANCIAL_SUMMARY_COST_F
-- And also W_JOB_CHANGE_DATA
-- The rest of dimention tables and background tables are populated manually
-- Software Developer: Mohammad Hossein Owj contact: hossein.owj@gmail.com
-- Supervisor: Dr. Michael Mannino contact: Michael.Mannino@ucdenver.edu
-- All rights are reserved for University of Colorado Denver Business School


--Instruction:
-- 1. Copy paste the installation file into SQL developer and run it. The install file will automatically configure the software with the default values.
-- 2. You need to Set the path variable with the exact path of the project in your system. Use '\' at the very end, in the 'install.sql' and 'configuration.sql' files.
--***NOTICE*** if you want to manually configure the software, edit and run 'configuration.sql' file in the main directory.
--3. Using the command help populate data for non-hard coded dimentions including: W_TIME_D, W_SALES_AGENT_D, W_CUSTOMER_D, W_CUST_LOCATION_D
--4. Using the command help populate data for fact tables. 
-- ***NOTICE*** There are some execution sample files in '\sample' folder for noth Fact and Dimention data generation. 
-- ***NOTICE*** You might need to specify some indexes for user specified executions. 