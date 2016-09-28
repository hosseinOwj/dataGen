/**********************************
        CONFIGURATION FILE 
**********************************/
-- This file include 2 tasks
-- 1. Populate the background tables; G_CITY, G_COMPANY, G_DELAY, G_NAME and G_PARAMETERS.
-- 2. Populate the Hard Coded Dimention tables; W_LOCATION_D, W_SALES_CLASS_D and W_MACHINE_TYPE_D

-- ***NOTICE*** all procedures are loaded with default values. Use extra CAUTION with changing the values in order to generate meaningful data. 

set define on;
set define on;

delete from G_CITY;
delete from G_COMPANY;
delete from G_NAME;
delete from G_PARAMETERS;
delete from G_DELAY;
delete from W_SALES_CLASS_D;
delete from W_LOCATION_D;
delete from W_MACHINE_TYPE_D;
-- Installation Directory
-- Change this variable with the exact path of the project(where you copy paste the folder). Use a '\' at the end. Same as Install.sql path.

define path = 'C:\DB\finalProject\';

-- Loading background tables and Hard Coded dimentions data using sql insert. Check the file 'backgroundTablesPop.sql' in order to modify, add or remove.
-- Tables include: G_CITY, G_COMPANY, G_NAME , W_LOCATION_D, W_SALES_CLASS_D and W_MACHINE_TYPE_D.
define s_backgroundTablesPop = 'scripts\backgroundTablesPop';
@&path&s_backgroundTablesPop;


set define on;
-- PARAMETER TABLE 
-- ***NOTICE*** meaningless numbers may distort the behaviour of the software. Use extra CAUTION with changing the values in order to generate meaningful data. 

-- Parameter Table includes this columns:

/*   
#    Column Name                    Column Description                                      Related Table(s)      Number nature         Range       RECOMMENDED VALUE
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
1    G_PARAMETERS_ID            Primary key of the table.                                                              integer           1-N               none
                                No sequence is assigned                                 

2    SUCCESS_RATE               Success rate of leads to                                        W_LEAD_F              percentage         1-100              85 
                                job
                             
3     MIN_ORDER_QTY             Minimum Quote_Qty  of the                                       W_LEAD_F               integer           1-N               40000    
                                lead table.                                            

4     MAX_ORDER_QTY             Maximum Quote_Qty  of the                                       W_LEAD_F               integer           1-N              1250000    
                                lead table.                                           
                          
5     MIN_SUB_QTY               Minimum Quantity of a sub job.                                  W_SUB_JOB_F            integer           1-N               50000
                                Uses in order to find out the 
                                number of required subjobs.
                      
6     MAX_SUB_QTY               Maximum Quantity of a sub job.                                  W_SUB_JOB_F            integer           1-N               500000
                                Uses in order to find out the 
                                number of required subjobs.
                          
7     MIN_NUM_SHIP              Minimum number of shipments                                     W_JOB_SHIPMENT_F       integer           1-N                 1
                                for each subjob.
                          
8     MAX_NUM_SHIP              Maximum number of shipments                                     W_JOB_SHIPMENT_F        integer          1-N                 5
                                for each subjob.
                          
9     MIN_BOX_QTY               Minimum quanity of each box.                                    W_JOB_SHIPMENT_F        integer          1-N                1000
                                For each shipment.Uses in order to 
                                find out the number of required 
                                boxes. 
                          
10     MAX_BOX_QTY              Maximum quanity of each box                                     W_JOB_SHIPMENT_F        integer          1-N                5000
                                for each shipment.Uses in order to 
                                find out the number of required 
                                boxes.
                          
11    VOL_LEVEL                 Dividing MAX_ORDER_QTY into N 
                                different levels. Each higher 
                                level recieve an additional 1% discount on
                                the Unit price. Example MAX_ORDER_QTY = 1,250,000 ,              W_LEAD_F               integer           1-N                10
                                lead_QUOTE_QTY = 250,000 , VOL_LEVEL = 10. 
                                1,250,000 / 10 = 125,000 . 250,000 / 125,000 = 2 => 
                                the customer will recieve a 2% discount on
                                the unit price.
                          
12    MIN_COST_RATE             Minimum Cost rate to calulate different costs                  W_SUB_JOB_F             percentage        1-100               40
                                for sub job.
                          
13    MAX_COST_RATE             Maximum Cost rate to calulate different costs                  W_SUB_JOB_F             percentage        1-100               70
                                for sub job.
                          
14    INVOICE_RATE              Rate of Shipments who gets an invoiced.                        W_INVOICELINE_F         percentage        1-100               95
                                The change that a shipment gets invoiced.           
                          
15   COMPLETE_INVOICE_RATE      The change that Invoice_Quantity is equal to                   W_INVOICELINE_F         percentage        1-100               75
                                Invoice_QUANTITY_SHIPPED. Example, if 
                                COMPLETE_INVOICE_RATE = 75%, there is 75% that
                                the two column be equal. if not the Invoice_Quantity
                                will be equal to a Invoice_QUANTITY_SHIPPED * a
                                random number between 0.7 to 0.9.
                            
16    COMBINATION_RATE          The precentage of SALES_CLASS and LOCATION usage               ALL FACT TABLES        percentage         1-100               100
                                in data generation. Example, if we have 10 SALES_CLASS
                                and 20 LOCATION and COMBINATION_RATE = 50%, the software
                                will use 10 * 0.5 = 5 of SALES_CLASS and 20 * 0.5 = 10 of
                                the LOCATION.
*/

-- Populating G_PARAMETERS table with recommended values
Insert into G_PARAMETERS (G_PARAMETERS_ID,SUCCESS_RATE,MIN_ORDER_QTY,MAX_ORDER_QTY,MIN_SUB_QTY,MAX_SUB_QTY,MIN_NUM_SHIP,MAX_NUM_SHIP,MIN_BOX_QTY,MAX_BOX_QTY,VOL_LEVEL,MIN_COST_RATE,MAX_COST_RATE,INVOICE_RATE,COMPLETE_INVOICE_RATE,COMBINATION_RATE) values (1,85,40000,12000000,50000,500000,1,5,1000,5000,10,40,70,95,75,100);


-- Populating G_DELAY Table
-- The procedure populate the delay table using default values. Check the procedure file '\procedures\G_Delay_G.sql' for more information.
-- This procedure uses parametes below. Please notice that all parameters are defined with default values.
--    default_Delay_Rate          RECOMMENDED VALUE:  2
--    default_Delay_Days          RECOMMENDED VALUE:  2
--    exception_Delay_Rate        RECOMMENDED VALUE:  10
--    exception_Delay_Days        RECOMMENDED VALUE:  10
--    exception_Usage_Rate        RECOMMENDED VALUE:  20
--    default_Forecast_acc        RECOMMENDED VALUE:  10
--    exception_Forecast_acc      RECOMMENDED VALUE:  25
--    exception_Forecast_rate     RECOMMENDED VALUE:  10
--    default_Budget_acc          RECOMMENDED VALUE:  10
--    exception_Budget_acc        RECOMMENDED VALUE:  25
--    exception_Budget_rate       RECOMMENDED VALUE:  10

--***NOTICE**** Use extra CAUTION with changing the values in order to generate meaningful data. 

-- Populating G_PARAMETERS table with recommended values
exec G_Delay_G();







