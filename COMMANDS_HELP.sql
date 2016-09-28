/**********************************
        COMMANDS HELP
*********************************
-- This file provides descriptions and help for different COMMANDS. Including:
-- 1. Generation COMMANDS
-- 2. Utility COMMANDS

-- ***NOTICE*** This document only provides help and instruction for using different COMMAND. Please copy paste the command in another SQL file. DO NOT use the commands in here.
-- ***NOTICE*** Meaningless numbers may distort the behaviour of the software. Use extra CAUTION with changing the values in order to generate meaningful data. 
-- ***NOTICE*** You may use these COMMANDS by copy pasting the command name in SQL Developer with correct parameters. Please notice that you need add 'EXEC' before the 
-- command name in order to execute the command.

** USED TERMS DESCRIPTION **
-- COMMAND: name of the command 
-- Nature: Additive or non-additive nature of the command. Additive commands will add rows to the destination table WITHOUT removing previous rows. On the other hand, 
 Non-Additive commands will first remove all the rows from the table and then generate new data.
-- Parameters: the parameters used in the command. Some of the parameters are coming with default value. Check the default value part.
-- Notes: extra information about the command.


**** GENERATION COMMANDS *****
** DIMENTIONS **


*********************************************************************************************************************
COMMAND:  W_Time_D_Gen(noRows) 
*********************************************************************************************************************
Nature: Additive
Parameters:

#     Parameter Name                         Description                            Data Type          Range         Default Value               RECOMMENDED VALUE
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
1         noRows                   Number of rows in W_TIME_D.                       Integer           1-N               N/A                             2555
                                   Each row is equal to 1 day. Thus
                                   noRows = number of days.
NOTES:
1. If W_TIME_D is empty this COMMAND add noRows business days starting from 1/1/2012.
2. if W_TIME_D is NOT empty this COMMAND add noRows business days to the last available date in the table.

***********************************************************************************************************************



*********************************************************************************************************************
COMMAND:  W_SALES_AGENT_D_GEN(noRows) 
*********************************************************************************************************************
Nature: Additive
Parameters:

#     Parameter Name                         Description                            Data Type          Range        Default Value       RECOMMENDED VALUE
------------------------------------------------------------------------------------------------------------------------------------------------------------
1         noRows                   Number of rows in W_SALES_AGENT_D.                  Integer           1-N             N/A                     400
                                    
NOTES:
1. This COMMAND adds noRows sales agents to W_SALES_AGENT_D.

***********************************************************************************************************************



*********************************************************************************************************************
COMMAND:  W_CUSTOMERLOCATION_D_GEN(noRows,minCredit_Limit,maxCredit_Limit,minNumLocation,maxNumLocation,minCustomerLimitPadding,maxCustomerLimitPadding) 
*********************************************************************************************************************
Nature: Non-Additive
Parameters:

#     Parameter Name                         Description                              Data Type          Range            Default Value           RECOMMENDED VALUE
----------------------------------------------------------------------------------------------------------------------------------------------------------------
1         noRows                      Number of rows in W_CUSTOMER_D.                  Integer           1-N                 N/A                        500

2         minCredit_Limit             Minimum of Credit_Limit  for each                Integer           1-N                 N/A                        80000
                                      Customer Location 
                                     
3         maxCredit_Limit             Maximum of Credit_Limit  for each                Integer           1-N                 N/A                       1200000
                                      Customer Location
                                      
4         minNumLocation              Min number of customer Locations for             Integer           1-N                 N/A                          1
                                      each customer
                                      
5         maxNumLocation              Max number of customer Locations for             Integer           1-(10000/noRows)    N/A                          5
                                      each customer 
                                      
6         minCustomerLimitPadding     Min Padding for each Customer Credit_Limit       Integer           1-100               N/A                          5

7         maxCustomerLimitPadding     Max Padding for each Customer Credit_Limit       Integer           1-100               N/A                          10
                                  
NOTES:
1. This COMMAND generate data for both W_CUSTOMER_D and W_CUST_LOCATION_D at the same time.

-- ***NOTICE*** The combination of W_CUSTOMER_D noRows * maxNumLocation has a limitation at the moment. The number cannot be greate than 10,000. 

***********************************************************************************************************************



** FACT TABLES **


*********************************************************************************************************************
COMMAND:  LEAD_JOB_SUB_SHIP_F_GEN(noRows,startDate,endDate,fact_Select,Parameters_Table_ID,change_Table_Enable) 
*********************************************************************************************************************
Nature: Additive
Parameters:

#     Parameter Name                         Description                                          Data Type          Range        Default Value       RECOMMENDED VALUE
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
1         noRows                    number of rows in W_LEAD_F table.                              Integer           1-N              N/A                     N/A

2         startDate                 given data range - start. W_TIME_D FK                          Integer         FK-Limit           N/A                     N/A

3         endDate                   given data range - end. W_TIME_D FK                            Integer         FK-Limit           N/A                     N/A

4         fact_Select               Fact Table selector. Chosing different numbers                 Integer          0-3               N/A                     N/a
                                    will result for partial data generation. Possible 
                                    combinations:  0 (Lead, Job, Subjob, Shipment), 
                                    1 (Lead, Job, Subjob), 2 (Lead, Job), 3 (Lead)
                                   
5        Parameters_Table_ID         G_PARAMETER PK.Ignore it if you want the procedure             Integer         0-N               0                       0
                                     use the LAST row of the G_PARAMETER table as default; 
                                     0: last row of the table, >0 the G_Parameters_ID
                                    
6        change_Table_Enable         This parameter is desinged for interal or test usage.
                                     ALWAYS ignore it when you are directly using this procedure;    Integer        0-1               0                       0
                                     0:Disabled , 1:Enabled ; 
                                     MUST always set to 0 when using this Procedure; 
                                     DONT USE THIS PROCEDURE FOR CHANGE DATA; 
                                     USE W_Job_Change_Data_Gen Instead                
NOTES:
1. STARTDATE and ENDDATES must be FKs from W_TIME_D
2. Make sure you have correct parameters in G_PARAMETERS table.
3. ALWAYS ignore change_Table_Enable parameter when you are directly using this command. MUST be always set to 0. Failure might cause a fatal error.

***********************************************************************************************************************


*********************************************************************************************************************
COMMAND:  W_FINANC_SUM_SALES_D_GEN(Internal_Sales_Rate,Parameters_Table_ID) 
*********************************************************************************************************************
Nature:Non-Additive
Parameters:

#     Parameter Name                         Description                                           Data Type            Range         Default Value               RECOMMENDED VALUE
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
1     Internal_Sales_Rate                 Internal Sales rate. The ACTUAL_UNITS                       Double             1-100             N/A                           85
                                          of Financial Sales will multiply by a random number
                                          between Internal_Sales_Rate and 100% to adjust the
                                          internal sales.
                                
2       Parameters_Table_ID              G_PARAMETER PK.Ignore it if you want the procedure           Integer             0-N               0                             0
                                          use the LAST row of the G_PARAMETER table as default; 
                                          0: last row of the table, >0 the G_Parameters_ID
NOTES:

***********************************************************************************************************************



*********************************************************************************************************************
COMMAND:  W_FINANC_SUM_COST_D_GEN(reconciliation_Rate,Parameters_Table_ID) 
*********************************************************************************************************************
Nature:Non-Additive
Parameters:

#     Parameter Name                         Description                                                Data Type          Range         Default Value               RECOMMENDED VALUE
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
1     reconciliation_Rate                 Reconciliation Rate.The actual cost will be                    Integer           1-100                 N/A                       10
                                          +/- reconciliation_Rate% of the query. 
                                          The actial costs will be added by the actual cost
                                          multiply by a random
                                          number btween (100 - reconciliation_Rate )
                                          and (100 + reconciliation_Rate) 
                                          
2       Parameters_Table_ID              G_PARAMETER PK.Ignore it if you want the procedure               Integer         0-N                      0                        0
                                          use the LAST row of the G_PARAMETER table as default; 
                                          0: last row of the table, >0 the G_Parameters_ID
NOTES:

***********************************************************************************************************************



*********************************************************************************************************************
COMMAND:  W_Job_Change_Data_Gen(noRows,error_Rate,startDate,endDate,Parameters_Table_ID) 
*********************************************************************************************************************
Nature:Non-Additive
Parameters:

#     Parameter Name                         Description                                         Data Type           Range         Default Value               RECOMMENDED VALUE
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
1     noRows                            Number of rows in W_JOB_CHANGE_DATA.                      Integer             1-N               N/A                 1/4 of rows in W_JOB_F

2     error_Rate                        Error rate. Chance that each row get 1                     Double             1-N               N/A                           10
                                        or more error data.
                                        
3     startDate                         given data range - start. W_TIME_D FK                      Integer          FK-Limit            N/A                          N/A

4     endDate                           given data range - end. W_TIME_D FK                        Integer          FK-Limit            N/A                          N/A
                                        
5     Parameters_Table_ID               G_PARAMETER PK.Ignore it if you want the procedure          Integer            0-N               0                            0
                                        use the LAST row of the G_PARAMETER table as default; 
                                        0: last row of the table, >0 the G_Parameters_ID
NOTES:
1. This Procedure will generate rows in W_LEAD_F with all 'N' for success.

***********************************************************************************************************************



**** UTILITY COMMANDS *****


*********************************************************************************************************************
COMMAND:  deleteAll_F() 
*********************************************************************************************************************
Nature: Non-Additive
Parameters:

#     Parameter Name                         Description                                           Data Type          Range         Default Value               RECOMMENDED VALUE
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

NOTES:
1. This COMMAND deletes all Fact tables. including:   W_LEAD_F,  W_JOB_F ,  W_SUB_JOB_F ,  W_JOB_SHIPMENT_F ,   W_INVOICELINE_F ,  W_FINANCIAL_SUMMARY_COST_F ,  W_FINANCIAL_SUMMARY_SALES_F;

***NOTICE*** Misusing of this command will result in data loss.
***********************************************************************************************************************



*********************************************************************************************************************
COMMAND:  fact_Count() 
*********************************************************************************************************************
Nature: Non-Additive
Parameters:

#     Parameter Name                         Description                                           Data Type          Range         Default Value               RECOMMENDED VALUE
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

NOTES:
1. This COMMAND will print the number of rows in Fact tables, in addition to overall number of rows in all fact tables.
2. " Set serverouput on" must be used before using of this COMMAND.

***********************************************************************************************************************


*********************************************************************************************************************
COMMAND:  G_Delay_G() 
*********************************************************************************************************************
Nature: Non-Additive
Parameters:

#     Parameter Name                         Description                                           Data Type          Range         Default Value               RECOMMENDED VALUE
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

NOTES:
1. Generate Data for G_Delay Table. Refer to main folder 'configuration.sql' or '\procedures\G_DELAY_G' for more info.

***********************************************************************************************************************


**** EXTRA UTILITY COMMANDS *****


*********************************************************************************************************************
COMMAND:  @[PATH]scripts\Remove_T_S.sql 
*********************************************************************************************************************
Nature: Non-Additive
Parameters:

#     Parameter Name                         Description                                           Data Type          Range         Default Value               RECOMMENDED VALUE
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

NOTES:
1. This COMMAND will remove all tables and sequnces. 
2. [PATH] needs to replace with the path of installating.

***NOTICE*** Misusing of this command will result in data loss.

***********************************************************************************************************************

*********************************************************************************************************************
COMMAND:  @[PATH]scripts\KILL_DB.sql 
*********************************************************************************************************************
Nature: Non-Additive
Parameters:

#     Parameter Name                         Description                                           Data Type          Range         Default Value               RECOMMENDED VALUE
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

NOTES:
1. This COMMAND will remove all TABLE, VIEW, FUNCTION, SEQUENCE and PROCEDURE. 
2. [PATH] needs to replace with the path of installating.

***NOTICE*** Misusing of this command will result in data loss.

***********************************************************************************************************************

