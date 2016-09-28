

create or replace procedure W_Job_Change_Data_Gen
(
noRows integer, -- Number of Rows in W_Job_Change_Data table
error_Rate number, -- Pecentage of Error Rate ( 0 - 100 )
startDate number, -- given data range - start
endDate number, -- given data range - end

-- Optional Parameters 
Parameters_Table_ID integer default 0 -- Optional Parameter: Ignore it if you want the procedure use the last row of the G_PARAMETER table as default; 0: last row of the table, >0 the G_Parameters_ID

)
IS

-- Table Variables
c_Change_ID number(10) ;
c_Contract_Date varchar2(10) ;
c_Sales_Agent_ID number(10);
c_Sales_Class_ID number(10) ;
c_Location_ID number(10) ;
c_Cust_ID_Ordered_By number(10) ;
c_Date_Promised varchar2(10) ;
c_Date_Ship_By varchar2(10) ;
c_Number_Of_SubJobs number(4) ;
c_Unit_Price decimal(5,2) ;
c_Quantity_Ordered number(8);
c_Quote_Qty number (8);
c_Lead_ID number(10,0);

-- W_Job_Change_Data_Gen procedure variables with v_ prefix
v_ErrosNumber number;
v_Correct_NoRows number;
v_Error_NoRows number;
v_Error_Random number;
v_ErrorRate_Random number(8,4);
v_Error_Ran_Div integer;
v_Counter1 integer;
v_Error_Level number(8,4);
v_Null_Ran integer;
v_Test_Var integer;

Type myTable Is Table  of integer(9);
v_Tab myTable := myTable();
v_Tab2 myTable := myTable();

v_MyV integer;

type columnName is table of varchar2(50);
mycolumNames columnName := columnName('Contract_Date' , 'Sales_Agent_ID ' , 'Sales_Class_ID' , 'Location_ID' , 'Cust_ID_Ordered_By' , 'Date_Promised ' ,
                                      'Date_Ship_By ' , 'Number_Of_SubJobs ' , 'Unit_Price' , 'Quantity_Ordered ' , 'Quote_Qty' , 'Lead_ID' ); 


Begin 

--initial process
execute immediate 'delete from W_JOB_CHANGE_DATA';


-- Error sequence
v_ErrosNumber := -20010;
v_Error_Ran_Div := 5;




v_MyV := 0;
for i in 1..v_Tab.count loop
v_Tab2.EXTEND;
v_Tab2(i) := v_Tab.NEXT(v_MyV);
v_MyV := v_Tab.NEXT(v_MyV);
end loop;






-- Input Data Verification
v_ErrosNumber := v_ErrosNumber - 1;
if (noRows<1) then
  raise_application_error(v_ErrosNumber,'Error - Number of Rows must be greater or equal to 1');
end if;

v_ErrosNumber := v_ErrosNumber - 1;
if (error_Rate>100 or error_Rate<0) then
  raise_application_error(v_ErrosNumber,'Error - Error Rate Percentage can''t be less than 0 or greater than 100');
end if;

-- inital process
v_Error_NoRows := round( noRows * error_Rate / 100 );
v_Correct_NoRows := noRows - v_Error_NoRows ;


-- Generating correct change rows

Begin
 LEAD_JOB_SUB_SHIP_F_GEN(noRows, startDate , endDate , 2 , 0 , 1 ) ;
end;

-- Perturbation Error Data

execute immediate ' select MIN(CHANGE_ID) from W_Job_Change_Data ' into c_Change_ID;

v_Test_Var:=0;
for i in 1.. noRows loop

v_ErrorRate_Random :=  trunc ( dbms_random.value(0.0001,99.9999),4);
--dbms_output.put_line ('*** ' || c_Change_ID || '*** ');

v_Error_Level := v_ErrorRate_Random  ;
v_Counter1 :=0 ; 
while ( v_Error_Level <= error_Rate ) loop
v_Error_Level :=   v_Error_Level * v_Error_Ran_Div ;
v_Counter1 := v_Counter1 + 1;
end loop;

if ( v_Counter1 > 8 ) then v_Counter1 := 9 ; end if;

v_Tab.delete;
for i in 1..9 loop
v_Tab.EXTEND;
v_Tab(i) := i;
end loop;


for j in 1.. v_Counter1 loop
   
v_MyV := 0;
v_Tab2.delete;
for i in 1..v_Tab.count loop
v_Tab2.EXTEND;
v_Tab2(i) := v_Tab.NEXT(v_MyV);
v_MyV := v_Tab.NEXT(v_MyV);
end loop;

v_Error_Random := v_Tab2 (dbms_random.value(1,v_Tab2.count) );

-- Null Value
if ( v_Error_Random = 1)  then
  --dbms_output.put_line ( 'Error 1');
  v_Null_Ran := trunc ( dbms_random.value(1,12.99) );
  execute immediate 'update W_Job_Change_Data set ' || mycolumNames(v_Null_Ran) || ' = null where CHANGE_ID = ' || c_Change_ID ;
  v_Tab.delete(1);
  v_Test_Var := v_Test_Var + 1;
-- Invalid date promised
elsif ( v_Error_Random = 2 ) then
  c_Date_Promised := to_Char ( getErrorTimeID(20,60) );
  c_Date_Promised := to_Char (  SUBSTR(c_Date_Promised,1,4) || '-' || SUBSTR(c_Date_Promised,5,2) || '-' || SUBSTR( c_Date_Promised,7,2)  );
  execute immediate 'update W_Job_Change_Data set ' || mycolumNames(6) || ' = '''|| c_Date_Promised || ''' where CHANGE_ID = ' || c_Change_ID ;
  v_Tab.delete(2);
  v_Test_Var := v_Test_Var + 1;
-- Invalid date shipped
elsif ( v_Error_Random = 3) then 
   c_Date_Ship_By := to_char ( getErrorTimeID(20,60) );
   c_Date_Ship_By := to_char (  SUBSTR(c_Date_Ship_By,1,4) || '-' || SUBSTR(c_Date_Ship_By,5,2) || '-' || SUBSTR(c_Date_Ship_By,7,2) ) ;
   execute immediate 'update W_Job_Change_Data set ' || mycolumNames(7) || ' = '''|| c_Date_Ship_By || ''' where CHANGE_ID = ' || c_Change_ID ;
   v_Tab.delete(3);
   v_Test_Var := v_Test_Var + 1;
-- Invalid Location_Id
elsif ( v_Error_Random = 4 ) then
   select MAX(LOCATION_ID) into c_Location_ID from W_LOCATION_D;
   c_Location_ID := c_Location_ID + trunc( dbms_random.value(100,1000.99) ) ;
    execute immediate 'update W_Job_Change_Data set ' || mycolumNames(4) || ' = '|| c_Location_ID || ' where CHANGE_ID = ' || c_Change_ID ;
   v_Tab.delete(4);
   v_Test_Var := v_Test_Var + 1;   
-- Invalid Cust_Id
elsif ( v_Error_Random = 5 ) then
   select MAX(CUST_KEY) into c_Cust_ID_Ordered_By from W_CUSTOMER_D;
   c_Cust_ID_Ordered_By := c_Cust_ID_Ordered_By + trunc( dbms_random.value(100,1000.99) ) ;
    execute immediate 'update W_Job_Change_Data set ' || mycolumNames(5) || ' = '|| c_Cust_ID_Ordered_By || ' where CHANGE_ID = ' || c_Change_ID ;
   v_Tab.delete(5);
   v_Test_Var := v_Test_Var + 1;
-- Invalid Sales_Agent_Id
elsif ( v_Error_Random = 6 ) then
   select MAX(SALES_AGENT_ID) into c_Sales_Agent_ID from W_SALES_AGENT_D;
   c_Sales_Agent_ID := c_Sales_Agent_ID + trunc( dbms_random.value(100,1000.99) ) ;
   execute immediate 'update W_Job_Change_Data set ' || mycolumNames(2) || ' = '|| c_Sales_Agent_ID || ' where CHANGE_ID = ' || c_Change_ID ;
   v_Tab.delete(6);
   v_Test_Var := v_Test_Var + 1;   
-- Invalid Sales_Class_Id
elsif ( v_Error_Random = 7 ) then
   select MAX(SALES_CLASS_ID) into c_Sales_Class_ID from W_SALES_CLASS_D;
   c_Sales_Class_ID := c_Sales_Class_ID + trunc( dbms_random.value(5,10.99) ) ;
   execute immediate 'update W_Job_Change_Data set ' || mycolumNames(3) || ' = '|| c_Sales_Class_ID || ' where CHANGE_ID = ' || c_Change_ID ;
   v_Tab.delete(7);
   v_Test_Var := v_Test_Var + 1;   
--  Invalid Lead_Id
elsif( v_Error_Random = 8 ) then
   select MAX(LEAD_ID) into c_Lead_ID from W_LEAD_F;
   c_Lead_ID := c_Lead_ID + trunc( dbms_random.value(100,1000.99) ) ;
   execute immediate 'update W_Job_Change_Data set ' || mycolumNames(12) || ' = '|| c_Lead_ID || ' where CHANGE_ID = ' || c_Change_ID ;
   v_Tab.delete(8);
   v_Test_Var := v_Test_Var + 1;   
-- Invalid contract date
elsif ( v_Error_Random = 9 ) then
  c_Contract_Date := to_char ( getErrorTimeID(20,60) );
  c_Contract_Date :=  to_char (  SUBSTR(c_Contract_Date,1,4) || '-' || SUBSTR(c_Contract_Date,5,2) || '-' || SUBSTR(c_Contract_Date,7,2) ) ;
  execute immediate 'update W_Job_Change_Data set ' || mycolumNames(1) || ' =  ''' ||  c_Contract_Date || ''' where CHANGE_ID = ' || c_Change_ID ;
 
  v_Tab.delete(9);
  v_Test_Var := v_Test_Var + 1;
else
    raise_application_error(v_ErrosNumber,'Error - No Error Generated.');
end if;




end loop;





execute immediate ' select MIN(CHANGE_ID) from W_Job_Change_Data where CHANGE_ID > '|| c_Change_ID  into c_Change_ID;
end loop;

--dbms_output.put_line (' ' || v_Test_Var||' ');


End;
