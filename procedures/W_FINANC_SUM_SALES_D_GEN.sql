
create or replace procedure W_FINANC_SUM_SALES_D_GEN
(
Internal_Sales_Rate number,
--Min_Forcast_Rate number,
--Max_Forcast_Rate number,
--Cumulative_Select integer  default 1 -- 0: cumulative  OFF , 1: cumulative  ON
--combination_rate number default 100 -- Rate of Combination for SALES_CLASS_ID and LOCATION_ID default 100(all)
-- Optional Parameters 
Parameters_Table_ID integer default 0 -- Optional Parameter: Ignore it if you want the procedure use the last row of the G_PARAMETER table as default; 0: last row of the table, >0 the G_Parameters_ID

)
IS

-- W_FINANCIAL_SUMMARY_D Table Variables prefix with FinSales_
FinSales_PK W_FINANCIAL_SUMMARY_SALES_F.FINANCIAL_SUMMARY_SALES_ID%TYPE;
FinSales_ACTUAL_UNITS W_FINANCIAL_SUMMARY_SALES_F.ACTUAL_UNITS%TYPE;
FinSales_ACTUAL_AMOUNT W_FINANCIAL_SUMMARY_SALES_F.ACTUAL_AMOUNT%TYPE;
FinSales_FORCAST_UNIT W_FINANCIAL_SUMMARY_SALES_F.FORCAST_UNIT%TYPE;
FinSales_FORCAST_AMOUNT W_FINANCIAL_SUMMARY_SALES_F.FORCAST_AMOUNT%TYPE;
FinSales_LOCATION_ID W_FINANCIAL_SUMMARY_SALES_F.LOCATION_ID%TYPE;
FinSales_SALES_CLASS_ID W_FINANCIAL_SUMMARY_SALES_F.SALES_CLASS_ID%TYPE;
FinSales_REPORT_BEGIN_DATE_ID W_FINANCIAL_SUMMARY_SALES_F.REPORT_BEGIN_DATE_ID%TYPE;
FinSales_REPORT_END_DATE_ID W_FINANCIAL_SUMMARY_SALES_F.REPORT_END_DATE_ID%TYPE;

-- W_FINANCIAL_SUMMARY_D procedure variables v_
v_G_Parameters_ID G_PARAMETERS.G_PARAMETERS_ID%TYPE;
v_ErrosNumber number;
v_G_Month integer;
v_G_Location integer;
v_G_SalesClass integer;
v_G_Year integer;
v_NoRows_Invoice integer;
v_NoRows_Time integer;
v_Year integer;
v_NoRows_SalesClass integer;
v_NoRows_Location integer;
v_Min_InvocieYear integer;
v_Min_InvoiceMonth integer;
v_Max_InvocieYear integer;
v_Max_InvoiceMonth integer;
v_NoRows integer;
v_Last_DayOfTheMonth integer;
v_First_DayOfTheMonth integer;
v_Avg_UnitPrice number(7,4);
v_Forcast_Random number(5,2);
v_Forcast_Loop integer;
v_Forcast_Month_Loop varchar2(4);

v_Cuml_ACTUAL_UNITS integer;
v_Cuml_ACTUAL_AMOUNT number(18,2);
v_LookUp_PK integer;

v_Month_Counter integer;
v_NoRows_Month integer;


v_MaxMonthOfYear number;

v_Flag1 integer;

v_Combination_rate integer;

v_Forcast_ZeroDetector  integer;

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
if (Internal_Sales_Rate<0 Or Internal_Sales_Rate > 100) then
  raise_application_error(v_ErrosNumber,'Error - External Sales Rate out of range (0-100)');
end if;

/*
-- Min_Forcast_Rate  and Max_Forcast_Rate 
v_ErrosNumber := v_ErrosNumber - 1;
if (Min_Forcast_Rate < 1) then
  raise_application_error(v_ErrosNumber,'Min Forcast Rate can''t be less than 1');
end if;
v_ErrosNumber := v_ErrosNumber - 1;
if (Max_Forcast_Rate < Min_Forcast_Rate) then
  raise_application_error(v_ErrosNumber,'Max Forcast Rate can''t be less than Min Forcast Rate ');
end if;

*/

-- W_INVOICELINE_F and W_TIME_D  can't be empty
execute immediate 'select count(*) from W_INVOICELINE_F' into v_NoRows_Invoice;
if ( v_NoRows_Invoice < 1 ) then 
 raise_application_error(v_ErrosNumber,'W_INVOICELINE_F is empty!');
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



execute immediate 'delete from W_FINANCIAL_SUMMARY_SALES_F';


execute immediate 'select distinct TIME_YEAR from W_TIME_D inner join W_INVOICELINE_F ON W_TIME_D.time_id = W_INVOICELINE_F.INVOICE_DUE_DATE and INVOICE_DUE_DATE in ( Select  min( INVOICE_DUE_DATE) from W_INVOICELINE_F )' into v_Min_InvocieYear;
execute immediate 'select distinct TIME_MONTH from W_TIME_D inner join W_INVOICELINE_F ON W_TIME_D.time_id = W_INVOICELINE_F.INVOICE_DUE_DATE and INVOICE_DUE_DATE in ( Select  min( INVOICE_DUE_DATE) from W_INVOICELINE_F )' into v_Min_InvoiceMonth;

execute immediate 'select distinct TIME_YEAR from W_TIME_D inner join W_INVOICELINE_F ON W_TIME_D.time_id = W_INVOICELINE_F.INVOICE_DUE_DATE and INVOICE_DUE_DATE in ( Select  max( INVOICE_DUE_DATE) from W_INVOICELINE_F )' into v_Max_InvocieYear;
execute immediate 'select distinct TIME_MONTH from W_TIME_D inner join W_INVOICELINE_F ON W_TIME_D.time_id = W_INVOICELINE_F.INVOICE_DUE_DATE and INVOICE_DUE_DATE in ( Select  max( INVOICE_DUE_DATE) from W_INVOICELINE_F )' into v_Max_InvoiceMonth;

 v_Cuml_ACTUAL_UNITS := 0 ;
  v_Cuml_ACTUAL_AMOUNT := 0 ;
  v_Forcast_ZeroDetector := 0;
  
  
  v_Flag1 := 0;

v_G_Month := v_Min_InvoiceMonth;
v_G_Year := v_Min_InvocieYear;



execute immediate 'select count(*) from W_SALES_CLASS_D' into v_NoRows_SalesClass;
execute immediate 'select count(*) from W_LOCATION_D' into v_NoRows_Location;

v_NoRows_SalesClass := round ( v_NoRows_SalesClass * v_Combination_rate / 100 ) ;
v_NoRows_Location := round ( v_NoRows_Location * v_Combination_rate / 100 ) ;

if ( v_NoRows_SalesClass < 1 ) then 
v_NoRows_SalesClass := 1;
end if;

if ( v_NoRows_Location < 1 ) then 
v_NoRows_Location := 1;
end if;

-- NoRows 

v_NoRows := ( v_Max_InvocieYear - v_Min_InvocieYear ) * 12 + ( v_Max_InvoiceMonth - v_Min_InvoiceMonth + 1 ) ;

/*******************************************
            GENERATING SUMMARY SALES
********************************************/
-- Main Loop


for i in 1..v_NoRows loop
  
  -- Inital
  
  v_Forcast_ZeroDetector := 0;
  
  execute immediate 'select max(TIME_MONTH) from W_TIME_D inner join W_INVOICELINE_F ON W_TIME_D.time_id = W_INVOICELINE_F.INVOICE_DUE_DATE and INVOICE_DUE_DATE <= '|| v_G_Year || 12 || 31 || ' and W_Time_D.TIME_YEAR =  ' || v_G_Year  into v_MaxMonthOfYear;
 

  -- FinSales_REPORT_BEGIN_DATE_ID
  execute immediate 'select min(Time_ID) from W_TIME_D where TIME_YEAR = ' || v_G_Year || ' and TIME_MONTH = ' || v_G_Month into  FinSales_REPORT_BEGIN_DATE_ID ;
 
  --FinSales_REPORT_END_DATE_ID
  -- v_Last_DayOfTheMonth
  execute immediate 'select max(Time_ID) from W_TIME_D where TIME_YEAR = ' || v_G_Year || ' and TIME_MONTH = ' || v_G_Month into FinSales_REPORT_END_DATE_ID;
  
  
  
  
 
  
  
  
  v_G_SalesClass := 0;
  for k in 1.. v_NoRows_SalesClass loop
    
    -- FinSales_SALES_CLASS_ID
    execute immediate 'select min(sales_class_ID) from W_SALES_CLASS_D where sales_class_ID > ' || v_G_SalesClass  into v_G_SalesClass;
    FinSales_SALES_CLASS_ID := v_G_SalesClass;
    
    
     v_G_Location := 0;
    for l in 1.. v_NoRows_Location loop
    
      -- FinSales_LOCATION_ID
     execute immediate 'select min(location_ID) from W_LOCATION_D where location_ID > ' || v_G_Location into v_G_Location;
     FinSales_LOCATION_ID := v_G_Location;
     
      --FinSales_PK
      FinSales_PK := v_G_Year ;
      if ( v_G_Month < 10 ) then 
         FinSales_PK := FinSales_PK || '0' || to_Char (v_G_Month );
      elsif ( v_G_Month >= 10 ) then
         
         FinSales_PK := FinSales_PK || to_Char (v_G_Month );
      end if;
      
       if ( v_G_SalesClass < 10 ) then 
        FinSales_PK := FinSales_PK || '0' || to_Char (v_G_SalesClass );
      elsif ( v_G_SalesClass >= 10 ) then
         FinSales_PK := FinSales_PK || to_Char (v_G_SalesClass );
      end if;

      if ( v_G_Location < 10 ) then 
        FinSales_PK := FinSales_PK || '0' || to_Char (v_G_Location );
      elsif ( v_G_Location >= 10 ) then
        FinSales_PK := FinSales_PK || to_Char (v_G_Location );
      end if;

     --FinSales_ACTUAL_UNITS , FinSales_ACTUAL_AMOUNT
      execute immediate ' select sum(INVOICE_QUANTITY), sum(INVOICE_AMOUNT) from W_INVOICELINE_F where INVOICE_DUE_DATE >= ' || FinSales_REPORT_BEGIN_DATE_ID  || ' and  INVOICE_DUE_DATE  <=  ' || FinSales_REPORT_END_DATE_ID  ||
                        ' and SALES_CLASS_ID = ' ||   v_G_SalesClass || ' and LOCATION_ID = ' ||  v_G_Location into  FinSales_ACTUAL_UNITS , FinSales_ACTUAL_AMOUNT;
    
     /*
     --FinSales_ACTUAL_UNITS
      execute immediate ' select sum(INVOICE_QUANTITY) from W_INVOICELINE_F where INVOICE_DUE_DATE >= ' || FinSales_REPORT_BEGIN_DATE_ID  || ' and  INVOICE_DUE_DATE  <=  ' || FinSales_REPORT_END_DATE_ID  ||
                        ' and SALES_CLASS_ID = ' ||   v_G_SalesClass || ' and LOCATION_ID = ' ||  v_G_Location into  FinSales_ACTUAL_UNITS;
    
    -- FinSales_ACTUAL_AMOUNT
     execute immediate ' select sum(INVOICE_AMOUNT) from W_INVOICELINE_F where INVOICE_DUE_DATE >= ' ||FinSales_REPORT_BEGIN_DATE_ID  || ' and  INVOICE_DUE_DATE  <=  ' || FinSales_REPORT_END_DATE_ID  ||
                        ' and SALES_CLASS_ID = ' ||   v_G_SalesClass || ' and LOCATION_ID = ' ||  v_G_Location into  FinSales_ACTUAL_AMOUNT;
    */
    
    if (  FinSales_ACTUAL_UNITS is null  )  then 
      FinSales_ACTUAL_UNITS := 0;
    end if;
    
     if (  FinSales_ACTUAL_AMOUNT is null  )  then 
      FinSales_ACTUAL_AMOUNT := 0;
    end if;
    
    
    
    --v_Avg_UnitPrice
    if ( FinSales_ACTUAL_UNITS <> 0 and FinSales_ACTUAL_AMOUNT <> 0 ) then
    v_Avg_UnitPrice := FinSales_ACTUAL_AMOUNT / FinSales_ACTUAL_UNITS ;
     FinSales_ACTUAL_UNITS := trunc ( FinSales_ACTUAL_UNITS * ( trunc (  dbms_Random.value(Internal_Sales_Rate,100.01),2 ) / 100 ) );
     FinSales_ACTUAL_AMOUNT :=  FinSales_ACTUAL_UNITS * v_Avg_UnitPrice;
    end if;
    
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
    
    
    execute immediate ' select ACTUAL_UNITS , ACTUAL_AMOUNT from W_FINANCIAL_SUMMARY_SALES_F where FINANCIAL_SUMMARY_SALES_ID = ' || v_LookUp_PK into v_Cuml_ACTUAL_UNITS , v_Cuml_ACTUAL_AMOUNT;
    
    /*
    execute immediate ' select ACTUAL_UNITS from W_FINANCIAL_SUMMARY_SALES_F where FINANCIAL_SUMMARY_SALES_ID = ' || v_LookUp_PK into v_Cuml_ACTUAL_UNITS;
    execute immediate ' select ACTUAL_AMOUNT from W_FINANCIAL_SUMMARY_SALES_F where FINANCIAL_SUMMARY_SALES_ID = ' || v_LookUp_PK into v_Cuml_ACTUAL_AMOUNT;
    */
   FinSales_ACTUAL_UNITS := FinSales_ACTUAL_UNITS + v_Cuml_ACTUAL_UNITS ;
   FinSales_ACTUAL_AMOUNT := FinSales_ACTUAL_AMOUNT + v_Cuml_ACTUAL_AMOUNT ;
    end if;
    
    
    FinSales_FORCAST_UNIT := 0;
    FinSales_FORCAST_AMOUNT := 0;
    
   if ( v_G_Month = v_MaxMonthOfYear ) then 
   
   v_Forcast_ZeroDetector := 0;
   
    EXECUTE immediate ' select SALES_FORECAST_ACC from G_Delay where Sales_Class_ID = ' ||v_G_SalesClass || ' and location_ID = ' || v_G_Location INTO v_Forcast_Random;
   
    -- v_Forcast_Random :=  trunc( dbms_Random.value(Min_Forcast_Rate,Max_Forcast_Rate + 0.01),2)  / 100 ;
    --FinSales_FORCAST_UNIT
    FinSales_FORCAST_UNIT := trunc ( FinSales_ACTUAL_UNITS * v_Forcast_Random / 100 );
    
    --FinSales_FORCAST_AMOUNT
    FinSales_FORCAST_AMOUNT := round ( FinSales_ACTUAL_AMOUNT * v_Forcast_Random / 100 ) ;
    
    if ( FinSales_FORCAST_UNIT = 0 and FinSales_FORCAST_AMOUNT = 0 ) then
    v_Forcast_ZeroDetector := 1;
    end if;
    
    
    -- update statment
    
    v_Forcast_Loop := v_MaxMonthOfYear - 1 ;
    while ( v_Forcast_Loop >= v_Min_InvoiceMonth  ) loop
   v_LookUp_PK := to_Char(v_G_Year) ;
      if ( v_Forcast_Loop  < 10 ) then 
         v_LookUp_PK := v_LookUp_PK || '0' || to_Char (v_Forcast_Loop);
      elsif ( v_Forcast_Loop  >= 10 ) then
         v_LookUp_PK := v_LookUp_PK || to_Char (v_Forcast_Loop  );
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
      
      if ( v_Forcast_ZeroDetector = 0 ) then 
    execute immediate '  update W_FINANCIAL_SUMMARY_SALES_F 
                            set FORCAST_UNIT = ' || FinSales_FORCAST_UNIT ||
                            ', FORCAST_AMOUNT = ' ||  FinSales_FORCAST_AMOUNT ||
                            ' where FINANCIAL_SUMMARY_SALES_ID = ' || v_LookUp_PK ;
                            
      else 
      
      execute immediate ' delete from W_FINANCIAL_SUMMARY_SALES_F where FINANCIAL_SUMMARY_SALES_ID = ' || v_LookUp_PK;
      
      end if;
                            
   v_Forcast_Loop := v_Forcast_Loop - 1;
    
    
    end loop;
    
    end if; 
    
    -- Insert Statement
    
    if ( v_Forcast_ZeroDetector = 0 ) then
    
    Insert into W_FINANCIAL_SUMMARY_SALES_F
    (FINANCIAL_SUMMARY_SALES_ID , ACTUAL_UNITS , ACTUAL_AMOUNT , FORCAST_UNIT , FORCAST_AMOUNT , LOCATION_ID , SALES_CLASS_ID , REPORT_BEGIN_DATE_ID , REPORT_END_DATE_ID) 
    values
    (FinSales_PK , FinSales_ACTUAL_UNITS ,  FinSales_ACTUAL_AMOUNT , FinSales_FORCAST_UNIT , FinSales_FORCAST_AMOUNT ,   FinSales_LOCATION_ID ,  FinSales_SALES_CLASS_ID , FinSales_REPORT_BEGIN_DATE_ID , 
     FinSales_REPORT_END_DATE_ID );
     
    -- if ( v_G_Month = 12 ) then
     
    end if;
    
  end loop;
end loop;


 v_Flag1 := 1;
v_G_Month := v_G_Month + 1;
 
 if ( v_G_Month = 13 ) then
 v_G_Year := v_G_Year + 1;
    v_G_Month := 1;
    v_Min_InvoiceMonth := 1;
     v_Flag1 := 0;
  end if; 

 


end loop;




End;