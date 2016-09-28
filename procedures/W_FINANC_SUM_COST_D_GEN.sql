

create or replace procedure W_FINANC_SUM_COST_D_GEN
(
reconciliation_Rate number, -- The actual cost will be +/- reconciliation_Rate% of the query
--Min_Budget_Rate number,
--Max_Budget_Rate number,
--Cumulative_Select integer  default 1 -- 0: cumulative  OFF , 1: cumulative  ON

--combination_rate number default 100 -- Rate of Combination for SALES_CLASS_ID and LOCATION_ID default 100(all)
-- Optional Parameters 
Parameters_Table_ID integer default 0 -- Optional Parameter: Ignore it if you want the procedure use the last row of the G_PARAMETER table as default; 0: last row of the table, >0 the G_Parameters_ID

)
IS

-- W_FINANCIAL_SUMMARY_D Table Variables prefix with FinCost_

FinCost_PK W_FINANCIAL_SUMMARY_COST_F.FINANCIAL_SUMMARY_COST_ID%TYPE;
FinCost_ACTUAL_UNITS W_FINANCIAL_SUMMARY_COST_F.ACTUAL_UNITS%TYPE;
FinCost_ACTUAL_LABOR_COST W_FINANCIAL_SUMMARY_COST_F.ACTUAL_LABOR_COST%TYPE;
FinCost_ACTUAL_MATERIAL_COST W_FINANCIAL_SUMMARY_COST_F.ACTUAL_MATERIAL_COST%TYPE;
FinCost_ACTUAL_MACHINE_COST W_FINANCIAL_SUMMARY_COST_F.ACTUAL_MACHINE_COST%TYPE;
FinCost_ACTUAL_OVERHEAD_COST W_FINANCIAL_SUMMARY_COST_F.ACTUAL_OVERHEAD_COST%TYPE;
FinCost_BUDGET_UNITS W_FINANCIAL_SUMMARY_COST_F.BUDGET_UNITS%TYPE;
FinCost_BUDGET_LABOR_COST W_FINANCIAL_SUMMARY_COST_F.BUDGET_LABOR_COST%TYPE;
FinCost_BUDGET_MATERIAL_COST W_FINANCIAL_SUMMARY_COST_F.BUDGET_MATERIAL_COST%TYPE;
FinCost_BUDGET_MACHINE_COST W_FINANCIAL_SUMMARY_COST_F.BUDGET_MACHINE_COST%TYPE;
FinCost_BUDGET_OVERHEAD_COST W_FINANCIAL_SUMMARY_COST_F.BUDGET_OVERHEAD_COST%TYPE;
FinCost_LOCATION_ID W_FINANCIAL_SUMMARY_COST_F.LOCATION_ID%TYPE;
FinCost_MACHINE_TYPE_ID W_FINANCIAL_SUMMARY_COST_F.MACHINE_TYPE_ID%TYPE;
FinCost_SALES_CLASS_ID W_FINANCIAL_SUMMARY_COST_F.SALES_CLASS_ID%TYPE;
FinCost_REPORT_BEGIN_DATE_ID W_FINANCIAL_SUMMARY_COST_F.REPORT_BEGIN_DATE_ID%TYPE;
FinCost_REPORT_END_DATE_ID W_FINANCIAL_SUMMARY_COST_F.REPORT_END_DATE_ID%TYPE;

-- W_FINANCIAL_SUMMARY_D procedure variables v_
v_G_Parameters_ID G_PARAMETERS.G_PARAMETERS_ID%TYPE;
v_ErrosNumber number;
v_G_Month integer;
v_G_Location integer;
v_G_SalesClass integer;
v_G_Machine integer;
v_G_Year integer;
v_NoRows_Sub integer;
v_NoRows_Time integer;
v_Year integer;
v_NoRows_SalesClass integer;
v_NoRows_Location integer;
v_NoRows_Machine integer;
v_Min_SubYear integer;
v_Min_SubMonth integer;
v_Max_SubYear integer;
v_Max_SubMonth integer;
v_NoRows integer;
v_Last_DayOfTheMonth integer;
v_First_DayOfTheMonth integer;
v_Avg_UnitPrice number(7,4);
v_Budget_Random number(5,2);
v_Budget_Loop integer;
v_Budget_Month_Loop varchar2(4);

v_Cuml_ACTUAL_UNITS integer;
v_Cuml_ACTUAL_LABOR_COST number(18,2);
v_Cuml_ACTUAL_MATERIAL_COST number(18,2);
v_Cuml_ACTUAL_MACHINE_COST number(18,2);
v_Cuml_ACTUAL_OVERHEAD_COST number(18,2);

v_LookUp_PK integer;
v_MaxMonthOfYear number;

v_Budget_ZeroDetector integer;




v_Flag1 integer;

v_Combination_rate integer;

Begin

/*******************************************
          Error Inital process
********************************************/

-- Error sequence
v_ErrosNumber := -20010; -- Error Number starts with -20010 each error will mines this number by one


/*******************************************
            Verify Input 
********************************************/

-- External_Sales_Rate
v_ErrosNumber := v_ErrosNumber - 1;
if (reconciliation_Rate<0 Or reconciliation_Rate > 100) then
  raise_application_error(v_ErrosNumber,'Error - External Sales Rate out of range (0-100)');
end if;

/*
-- Min_Budget_Rate  and Max_Forcast_Rate 
v_ErrosNumber := v_ErrosNumber - 1;
if (Min_Budget_Rate < 1) then
  raise_application_error(v_ErrosNumber,'Min Forcast Rate can''t be less than 1');
end if;
v_ErrosNumber := v_ErrosNumber - 1;
if (Max_Budget_Rate < Min_Budget_Rate) then
  raise_application_error(v_ErrosNumber,'Max Forcast Rate can''t be less than Min Forcast Rate ');
end if;
*/
-- W_INVOICELINE_F and W_TIME_D  can't be empty
execute immediate 'select count(*) from W_SUB_JOB_F' into v_NoRows_Sub;
if ( v_NoRows_Sub < 1 ) then 
 raise_application_error(v_ErrosNumber,'W_SUB_JOB_F is empty!');
end if;
execute immediate 'select count(*) from W_TIME_D' into v_NoRows_Time;
if ( v_NoRows_Time < 1 ) then 
 raise_application_error(v_ErrosNumber,'W_TIME_D is empty!');
end if;

-- Parameters_Table_ID check
if ( Parameters_Table_ID = 0 ) then 
  execute immediate 'select max(G_PARAMETERS_ID) from G_PARAMETERS' into v_G_Parameters_ID;
elsif ( Parameters_Table_ID > 0 ) then
  execute immediate ' select G_PARAMETERS_ID from G_PARAMETERS  where G_PARAMETERS_ID =  ' || Parameters_Table_ID   into v_G_Parameters_ID;
end if;

--combination_rate
v_ErrosNumber := v_ErrosNumber - 1;
execute immediate 'select Combination_rate from G_PARAMETERS where G_PARAMETERS_ID = ' || v_G_Parameters_ID into v_Combination_rate;
if (v_Combination_rate < 1 or v_Combination_rate > 100) then
  raise_application_error(v_ErrosNumber,'v_Combination_rate out of range (1-100) ');
end if;





/*******************************************
           Inital process
********************************************/

execute immediate 'delete from W_FINANCIAL_SUMMARY_COST_F';


execute immediate 'select distinct TIME_YEAR from W_TIME_D inner join W_SUB_JOB_F ON W_TIME_D.time_id = W_SUB_JOB_F.DATE_PROD_END and DATE_PROD_END in ( Select  min( DATE_PROD_END) from W_SUB_JOB_F )' into v_Min_SubYear;
execute immediate 'select distinct TIME_MONTH from W_TIME_D inner join W_SUB_JOB_F ON W_TIME_D.time_id = W_SUB_JOB_F.DATE_PROD_END and DATE_PROD_END in ( Select  min( DATE_PROD_END) from W_SUB_JOB_F )' into v_Min_SubMonth;

execute immediate 'select distinct TIME_YEAR from W_TIME_D inner join W_SUB_JOB_F ON W_TIME_D.time_id = W_SUB_JOB_F.DATE_PROD_END and DATE_PROD_END in ( Select  max( DATE_PROD_END) from W_SUB_JOB_F )' into v_Max_SubYear;
execute immediate 'select distinct TIME_MONTH from W_TIME_D inner join W_SUB_JOB_F ON W_TIME_D.time_id = W_SUB_JOB_F.DATE_PROD_END and DATE_PROD_END in ( Select  max( DATE_PROD_END) from W_SUB_JOB_F )' into v_Max_SubMonth;

v_Cuml_ACTUAL_UNITS := 0 ;
v_Cuml_ACTUAL_LABOR_COST  := 0 ;
v_Cuml_ACTUAL_MATERIAL_COST := 0 ;
v_Cuml_ACTUAL_MACHINE_COST := 0 ;
v_Cuml_ACTUAL_OVERHEAD_COST := 0 ;
 v_Budget_ZeroDetector := 0;

  
  v_Flag1 := 0;

v_G_Month := v_Min_SubMonth;
v_G_Year := v_Min_SubYear;

execute immediate 'select count(*) from W_SALES_CLASS_D' into v_NoRows_SalesClass;
execute immediate 'select count(*) from W_LOCATION_D' into v_NoRows_Location;
execute immediate 'select count(*) from W_MACHINE_TYPE_D ' into v_NoRows_Machine;

v_NoRows_SalesClass := round ( v_NoRows_SalesClass * v_Combination_rate / 100 ) ;
v_NoRows_Location := round ( v_NoRows_Location * v_Combination_rate / 100 ) ;
v_NoRows_Machine := round ( v_NoRows_Machine * v_Combination_rate / 100 ) ;


if ( v_NoRows_SalesClass < 1 ) then 
v_NoRows_SalesClass := 1;
end if;

if ( v_NoRows_Location < 1 ) then 
v_NoRows_Location := 1;
end if;

if ( v_NoRows_Machine < 1 ) then 
v_NoRows_Machine := 1;
end if;


-- NoRows 

v_NoRows := ( v_Max_SubYear - v_Min_SubYear ) * 12 + ( v_Max_SubMonth - v_Min_SubMonth + 1 ) ;

/*******************************************
            GENERATING LEADs 
********************************************/
-- Main Loop

for i in 1..v_NoRows loop
  
  -- Inital
   v_Budget_ZeroDetector := 0;
  
  execute immediate 'select max(TIME_MONTH) from W_TIME_D inner join W_SUB_JOB_F ON W_TIME_D.time_id = W_SUB_JOB_F.DATE_PROD_END and DATE_PROD_END <= '|| v_G_Year || 12 || 31 || '  and W_TIME_D.TIME_YEAR =' || v_G_Year  into v_MaxMonthOfYear ;

 

  -- FinCost_REPORT_BEGIN_DATE_ID
  execute immediate 'select min(Time_ID) from W_TIME_D where TIME_YEAR = ' || v_G_Year || ' and TIME_MONTH = ' || v_G_Month into  FinCost_REPORT_BEGIN_DATE_ID ;
 
  --FinCost_REPORT_END_DATE_ID
  -- v_Last_DayOfTheMonth
  execute immediate 'select max(Time_ID) from W_TIME_D where TIME_YEAR = ' || v_G_Year || ' and TIME_MONTH = ' || v_G_Month into FinCost_REPORT_END_DATE_ID;
  
  
  

  
  
  
  v_G_SalesClass := 0;
  for k in 1.. v_NoRows_SalesClass loop
    
    -- FinCost_SALES_CLASS_ID
    execute immediate 'select min(sales_class_ID) from W_SALES_CLASS_D where sales_class_ID > ' || v_G_SalesClass  into v_G_SalesClass;
    FinCost_SALES_CLASS_ID := v_G_SalesClass;
    
    
     v_G_Location := 0;
    for l in 1.. v_NoRows_Location loop
    
      -- FinCost_LOCATION_ID
     execute immediate 'select min(location_ID) from W_LOCATION_D where location_ID > ' || v_G_Location into v_G_Location;
     FinCost_LOCATION_ID := v_G_Location;
     
    
     
     v_G_Machine := 0;
     for m in 1..v_NoRows_Machine loop
     
      -- FinCost_MACHINE_TYPE_ID
      execute immediate 'select min(MACHINE_TYPE_ID) from W_MACHINE_TYPE_D where MACHINE_TYPE_ID > ' || v_G_Machine into v_G_Machine;
     FinCost_MACHINE_TYPE_ID := v_G_Machine;
     
      --FinSales_PK
      FinCost_PK := v_G_Year ;
      if ( v_G_Month < 10 ) then 
         FinCost_PK := FinCost_PK || '0' || to_Char (v_G_Month );
      elsif ( v_G_Month >= 10 ) then
         
         FinCost_PK := FinCost_PK || to_Char (v_G_Month );
      end if;
      
       if ( v_G_SalesClass < 10 ) then 
        FinCost_PK := FinCost_PK || '0' || to_Char (v_G_SalesClass );
      elsif ( v_G_SalesClass >= 10 ) then
         FinCost_PK := FinCost_PK || to_Char (v_G_SalesClass );
      end if;

      if ( v_G_Location < 10 ) then 
        FinCost_PK := FinCost_PK || '0' || to_Char (v_G_Location );
      elsif ( v_G_Location >= 10 ) then
        FinCost_PK := FinCost_PK || to_Char (v_G_Location );
      end if;
      
      if ( v_G_Machine < 10 ) then 
        FinCost_PK := FinCost_PK || '0' || to_Char (v_G_Machine );
      elsif ( v_G_Machine >= 10 ) then
        FinCost_PK := FinCost_PK || to_Char (v_G_Machine );
      end if;
    
     -- FinSales_ACTUAL_UNITS , FinCost_ACTUAL_LABOR_COST , FinCost_ACTUAL_MATERIAL_COST , FinCost_ACTUAL_OVERHEAD_COST
     execute immediate ' select sum(QUANTITY_PRODUCED) ,  sum(COST_LABOR) , sum(COST_MATERIAL) ,  sum(COST_OVERHEAD) from W_SUB_JOB_F where DATE_PROD_END >= ' || FinCost_REPORT_BEGIN_DATE_ID  || ' and  DATE_PROD_END  <=  ' || FinCost_REPORT_END_DATE_ID  ||
                        ' and SALES_CLASS_ID = ' ||   v_G_SalesClass || ' and LOCATION_ID = ' ||  v_G_Location || ' and MACHINE_TYPE_ID = ' || v_G_Machine  into  FinCost_ACTUAL_UNITS , FinCost_ACTUAL_LABOR_COST , FinCost_ACTUAL_MATERIAL_COST , FinCost_ACTUAL_OVERHEAD_COST ;
    
     
     /*
     --FinSales_ACTUAL_UNITS
      execute immediate ' select sum(QUANTITY_PRODUCED) from W_SUB_JOB_F where DATE_PROD_END >= ' || FinCost_REPORT_BEGIN_DATE_ID  || ' and  DATE_PROD_END  <=  ' || FinCost_REPORT_END_DATE_ID  ||
                        ' and SALES_CLASS_ID = ' ||   v_G_SalesClass || ' and LOCATION_ID = ' ||  v_G_Location || ' and MACHINE_TYPE_ID = ' || v_G_Machine  into  FinCost_ACTUAL_UNITS;
    
    -- FinCost_ACTUAL_LABOR_COST 
     execute immediate ' select sum(COST_LABOR) from W_SUB_JOB_F where DATE_PROD_END >= ' || FinCost_REPORT_BEGIN_DATE_ID  || ' and  DATE_PROD_END  <=  ' || FinCost_REPORT_END_DATE_ID  ||
                        ' and SALES_CLASS_ID = ' ||   v_G_SalesClass || ' and LOCATION_ID = ' ||  v_G_Location || ' and MACHINE_TYPE_ID = ' || v_G_Machine  into FinCost_ACTUAL_LABOR_COST ;
   
   
    -- FinCost_ACTUAL_MATERIAL_COST
    execute immediate ' select sum(COST_MATERIAL) from W_SUB_JOB_F where DATE_PROD_END >= ' || FinCost_REPORT_BEGIN_DATE_ID  || ' and  DATE_PROD_END  <=  ' || FinCost_REPORT_END_DATE_ID  ||
                        ' and SALES_CLASS_ID = ' ||   v_G_SalesClass || ' and LOCATION_ID = ' ||  v_G_Location || ' and MACHINE_TYPE_ID = ' || v_G_Machine  into FinCost_ACTUAL_MATERIAL_COST;
                        
     -- FinCost_ACTUAL_OVERHEAD_COST
    execute immediate ' select sum(COST_OVERHEAD) from W_SUB_JOB_F where DATE_PROD_END >= ' || FinCost_REPORT_BEGIN_DATE_ID  || ' and  DATE_PROD_END  <=  ' || FinCost_REPORT_END_DATE_ID  ||
                        ' and SALES_CLASS_ID = ' ||   v_G_SalesClass || ' and LOCATION_ID = ' ||  v_G_Location || ' and MACHINE_TYPE_ID = ' || v_G_Machine  into FinCost_ACTUAL_OVERHEAD_COST ;
      */                  
    -- FinCost_ACTUAL_MACHINE_COST
                          
    execute immediate ' select sum(W_MACHINE_TYPE_D.RATE_PER_HOUR * W_SUB_JOB_F.MACHINE_HOURS ) from W_SUB_JOB_F inner join W_MACHINE_TYPE_D on W_SUB_JOB_F.MACHINE_TYPE_ID = W_MACHINE_TYPE_D.MACHINE_TYPE_ID   where DATE_PROD_END >=  ' || 
                        FinCost_REPORT_BEGIN_DATE_ID ||' and  DATE_PROD_END  <=  '|| FinCost_REPORT_END_DATE_ID ||  
                        ' and W_SUB_JOB_F.SALES_CLASS_ID = '|| v_G_SalesClass ||' and W_SUB_JOB_F.LOCATION_ID =  '|| v_G_Location ||'  and W_SUB_JOB_F.MACHINE_TYPE_ID = '|| v_G_Machine  into FinCost_ACTUAL_MACHINE_COST ;
   
    
    
    if ( FinCost_ACTUAL_UNITS  is null  )  then 
     FinCost_ACTUAL_UNITS  := 0;
    end if;
    
     if ( FinCost_ACTUAL_LABOR_COST  is null  )  then 
     FinCost_ACTUAL_LABOR_COST  := 0;
    end if;
    
    if ( FinCost_ACTUAL_MATERIAL_COST  is null  )  then 
     FinCost_ACTUAL_MATERIAL_COST  := 0;
    end if;
    
    
     if ( FinCost_ACTUAL_MACHINE_COST  is null  )  then 
     FinCost_ACTUAL_MACHINE_COST  := 0;
    end if;
    
     if (  FinCost_ACTUAL_OVERHEAD_COST is null  )  then 
     FinCost_ACTUAL_OVERHEAD_COST  := 0;
    end if;
    
    -- reconciliation
    --reconciliation_Rate
    FinCost_ACTUAL_UNITS := round ( FinCost_ACTUAL_UNITS * trunc ( dbms_Random.value(100- reconciliation_Rate, 100+reconciliation_Rate ) /100 , 2  )  );
    FinCost_ACTUAL_LABOR_COST := FinCost_ACTUAL_LABOR_COST * trunc ( dbms_Random.value(100- reconciliation_Rate, 100+reconciliation_Rate ) /100 , 2 );
    FinCost_ACTUAL_MATERIAL_COST := FinCost_ACTUAL_MATERIAL_COST *  trunc ( dbms_Random.value(100- reconciliation_Rate, 100+reconciliation_Rate ) /100 ,2  );
    FinCost_ACTUAL_MACHINE_COST := FinCost_ACTUAL_MACHINE_COST *  trunc ( dbms_Random.value(100- reconciliation_Rate, 100+reconciliation_Rate ) /100 , 2   );
    FinCost_ACTUAL_OVERHEAD_COST := FinCost_ACTUAL_OVERHEAD_COST * trunc ( dbms_Random.value(100- reconciliation_Rate, 100+reconciliation_Rate )  /100 , 2 );
   
    
    if ( v_Flag1 = 1 ) then 
    -- v_LookUp_PK
      v_LookUp_PK := to_Char(v_G_Year) ;
      if ( v_G_Month - 1 < 10 ) then 
         v_LookUp_PK := v_LookUp_PK || '0' || to_Char (v_G_Month - 1);
      elsif ( v_G_Month - 1 >= 10 ) then
         v_LookUp_PK := v_LookUp_PK || to_Char (v_G_Month - 1 );
      end if;
      
       if ( v_G_SalesClass  < 10 ) then 
        v_LookUp_PK := v_LookUp_PK || '0' || to_Char (v_G_SalesClass );
      elsif ( v_G_SalesClass >= 10 ) then
         v_LookUp_PK := v_LookUp_PK || to_Char (v_G_SalesClass );
      end if;

      if ( v_G_Location < 10 ) then 
        v_LookUp_PK := v_LookUp_PK || '0' || to_Char (v_G_Location );
      elsif ( v_G_Location >= 10 ) then
        v_LookUp_PK := v_LookUp_PK || to_Char (v_G_Location );
      end if;
      
       if ( v_G_Machine < 10 ) then 
        v_LookUp_PK := v_LookUp_PK || '0' || to_Char (v_G_Machine );
      elsif ( v_G_Machine >= 10 ) then
        v_LookUp_PK := v_LookUp_PK || to_Char (v_G_Machine );
      end if;
    

     execute immediate ' select ACTUAL_UNITS , ACTUAL_LABOR_COST , ACTUAL_MATERIAL_COST , ACTUAL_MACHINE_COST ,ACTUAL_OVERHEAD_COST 
                            from W_FINANCIAL_SUMMARY_COST_F where FINANCIAL_SUMMARY_COST_ID = ' || v_LookUp_PK into 
                              v_Cuml_ACTUAL_UNITS , v_Cuml_ACTUAL_LABOR_COST , v_Cuml_ACTUAL_MATERIAL_COST , v_Cuml_ACTUAL_MACHINE_COST , v_Cuml_ACTUAL_OVERHEAD_COST;
    
    /*
    execute immediate ' select ACTUAL_UNITS from W_FINANCIAL_SUMMARY_COST_F where FINANCIAL_SUMMARY_COST_ID = ' || v_LookUp_PK into v_Cuml_ACTUAL_UNITS;
    execute immediate ' select ACTUAL_LABOR_COST from W_FINANCIAL_SUMMARY_COST_F where FINANCIAL_SUMMARY_COST_ID = ' || v_LookUp_PK into v_Cuml_ACTUAL_LABOR_COST;
    execute immediate ' select ACTUAL_MATERIAL_COST from W_FINANCIAL_SUMMARY_COST_F where FINANCIAL_SUMMARY_COST_ID = ' || v_LookUp_PK into v_Cuml_ACTUAL_MATERIAL_COST;
    execute immediate ' select ACTUAL_MACHINE_COST from W_FINANCIAL_SUMMARY_COST_F where FINANCIAL_SUMMARY_COST_ID = ' || v_LookUp_PK into v_Cuml_ACTUAL_MACHINE_COST;
    execute immediate ' select ACTUAL_OVERHEAD_COST from W_FINANCIAL_SUMMARY_COST_F where FINANCIAL_SUMMARY_COST_ID = ' || v_LookUp_PK into v_Cuml_ACTUAL_OVERHEAD_COST;
    */
   
    FinCost_ACTUAL_UNITS := FinCost_ACTUAL_UNITS + v_Cuml_ACTUAL_UNITS ;
    FinCost_ACTUAL_LABOR_COST := FinCost_ACTUAL_LABOR_COST + v_Cuml_ACTUAL_LABOR_COST ;
    FinCost_ACTUAL_MATERIAL_COST := FinCost_ACTUAL_MATERIAL_COST + v_Cuml_ACTUAL_MATERIAL_COST ;
    FinCost_ACTUAL_MACHINE_COST := FinCost_ACTUAL_MACHINE_COST + v_Cuml_ACTUAL_MACHINE_COST;
    FinCost_ACTUAL_OVERHEAD_COST := FinCost_ACTUAL_OVERHEAD_COST + v_Cuml_ACTUAL_OVERHEAD_COST ;
   
    
    end if;
    
    
    FinCost_BUDGET_UNITS := 0 ;
    FinCost_BUDGET_LABOR_COST := 0 ;
    FinCost_BUDGET_MATERIAL_COST := 0 ;
    FinCost_BUDGET_MACHINE_COST := 0 ;
    FinCost_BUDGET_OVERHEAD_COST := 0 ;
    
   if ( v_G_Month = v_MaxMonthOfYear ) then 
   
   v_Budget_ZeroDetector := 0;
   
    EXECUTE immediate ' select COST_BUDGET_ACC from G_Delay where Sales_Class_ID = ' ||v_G_SalesClass || ' and location_ID = ' || v_G_Location INTO v_Budget_Random;
   
     --v_Budget_Random :=  trunc( dbms_Random.value(Min_Budget_Rate,Max_Budget_Rate + 0.01),2)  / 100 ;
     
    --FinCost_BUDGET_UNITS
    FinCost_BUDGET_UNITS := trunc ( FinCost_ACTUAL_UNITS * v_Budget_Random  / 100);
    
    
    --FinCost_BUDGET_LABOR_COST 
    FinCost_BUDGET_LABOR_COST := FinCost_ACTUAL_LABOR_COST  * ( v_Budget_Random  + round( dbms_Random.value(-1,1),2) ) / 100 ;
    
    --FinCost_BUDGET_MATERIAL_COST 
    FinCost_BUDGET_MATERIAL_COST :=  FinCost_ACTUAL_MATERIAL_COST * ( v_Budget_Random  + round( dbms_Random.value(-1,1),2) ) / 100 ;
    
    --FinCost_BUDGET_MACHINE_COST 
    FinCost_BUDGET_MACHINE_COST := FinCost_ACTUAL_MACHINE_COST  * ( v_Budget_Random  + round( dbms_Random.value(-1,1),2) ) / 100 ;
    
    -- FinCost_BUDGET_OVERHEAD_COST 
    FinCost_BUDGET_OVERHEAD_COST := FinCost_ACTUAL_OVERHEAD_COST  * ( v_Budget_Random  + round( dbms_Random.value(-1,1),2) ) / 100 ;
    
    
    if ( FinCost_BUDGET_UNITS = 0 and FinCost_BUDGET_LABOR_COST = 0 and FinCost_BUDGET_MATERIAL_COST = 0 and FinCost_BUDGET_MACHINE_COST = 0 and FinCost_BUDGET_OVERHEAD_COST = 0 ) then
    v_Budget_ZeroDetector := 1;
    end if;
    
    
    -- update statment
    
    v_Budget_Loop := v_MaxMonthOfYear - 1 ;
    while ( v_Budget_Loop >= v_Min_SubMonth  ) loop
   v_LookUp_PK := to_Char(v_G_Year) ;
      if ( v_Budget_Loop  < 10 ) then 
         v_LookUp_PK := v_LookUp_PK || '0' || to_Char (v_Budget_Loop);
      elsif ( v_Budget_Loop  >= 10 ) then
         v_LookUp_PK := v_LookUp_PK || to_Char (v_Budget_Loop  );
      end if;
      
       if ( v_G_SalesClass  < 10 ) then 
        v_LookUp_PK := v_LookUp_PK || '0' || to_Char (v_G_SalesClass );
      elsif ( v_G_SalesClass >= 10 ) then
         v_LookUp_PK := v_LookUp_PK || to_Char (v_G_SalesClass );
      end if;

      if ( v_G_Location < 10 ) then 
        v_LookUp_PK := v_LookUp_PK || '0' || to_Char (v_G_Location );
      elsif ( v_G_Location >= 10 ) then
        v_LookUp_PK := v_LookUp_PK || to_Char (v_G_Location );
      end if;
      
       if ( v_G_Machine < 10 ) then 
        v_LookUp_PK := v_LookUp_PK || '0' || to_Char (v_G_Machine );
      elsif ( v_G_Machine >= 10 ) then
        v_LookUp_PK := v_LookUp_PK || to_Char (v_G_Machine );
      end if;
      
      if ( v_Budget_ZeroDetector = 0 ) then
    execute immediate '  update W_FINANCIAL_SUMMARY_COST_F 
                            set BUDGET_UNITS = ' || FinCost_BUDGET_UNITS ||
                            ', BUDGET_LABOR_COST = ' ||  FinCost_BUDGET_LABOR_COST ||
                            ', BUDGET_MATERIAL_COST = ' ||  FinCost_BUDGET_MATERIAL_COST ||
                            ', BUDGET_MACHINE_COST = ' ||  FinCost_BUDGET_MACHINE_COST ||
                            ', BUDGET_OVERHEAD_COST = ' ||  FinCost_BUDGET_OVERHEAD_COST ||
                            ' where FINANCIAL_SUMMARY_COST_ID = ' || v_LookUp_PK ;
      else 
      
      execute immediate ' delete from W_FINANCIAL_SUMMARY_COST_F where FINANCIAL_SUMMARY_COST_ID = ' || v_LookUp_PK;
      
      end if;
                            
   v_Budget_Loop := v_Budget_Loop - 1;
    
    
     
    end loop;
    
    end if; 
    
    -- Insert Statement
    
    if ( v_Budget_ZeroDetector = 0 ) then
    
    Insert into W_FINANCIAL_SUMMARY_COST_F
    (FINANCIAL_SUMMARY_COST_ID , ACTUAL_UNITS , ACTUAL_LABOR_COST , ACTUAL_MATERIAL_COST , ACTUAL_MACHINE_COST , ACTUAL_OVERHEAD_COST , BUDGET_UNITS , BUDGET_LABOR_COST , BUDGET_MATERIAL_COST ,
     BUDGET_MACHINE_COST , BUDGET_OVERHEAD_COST ,  LOCATION_ID , MACHINE_TYPE_ID ,  SALES_CLASS_ID , REPORT_BEGIN_DATE_ID ,  REPORT_END_DATE_ID ) 
    values
    (FinCost_PK , FinCost_ACTUAL_UNITS ,  FinCost_ACTUAL_LABOR_COST , FinCost_ACTUAL_MATERIAL_COST , FinCost_ACTUAL_MACHINE_COST ,   FinCost_ACTUAL_OVERHEAD_COST ,  FinCost_BUDGET_UNITS , FinCost_BUDGET_LABOR_COST , 
     FinCost_BUDGET_MATERIAL_COST , FinCost_BUDGET_MACHINE_COST , FinCost_BUDGET_OVERHEAD_COST , FinCost_LOCATION_ID ,  FinCost_MACHINE_TYPE_ID , FinCost_SALES_CLASS_ID ,  FinCost_REPORT_BEGIN_DATE_ID ,FinCost_REPORT_END_DATE_ID   );
     
    -- if ( v_G_Month = 12 ) then
     end if;
    
   end loop; 
  end loop;
end loop;


 v_Flag1 := 1;
v_G_Month := v_G_Month + 1;
 
 
  if ( v_G_Month = 13 ) then 
    v_G_Year := v_G_Year + 1;
    v_G_Month := 1;
    v_Min_SubMonth := 1;
     v_Flag1 := 0;
     
    
  
    
    
    
  end if;

 


end loop;


End;