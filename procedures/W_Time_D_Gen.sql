
create or replace procedure W_Time_D_Gen
(

noRows IN integer

) IS

-- table variables
v_time_ID integer;
v_year integer;
v_quarter integer;
v_month integer;
v_day integer;
v_week integer;

-- procedure variables
startDate date;
nextDate date;
startYear number(4);
startMonth number(2);
startDay number(2);

w_Time_D_Count integer;
w_Time_D_Last integer;
v_DayOfWeek integer;

v_time_ID_Char varchar2(8);

v_Flag1 boolean;



Begin



--  verify input parms

      if (noRows<1) then
      raise_application_error(-20011,'Error - Number of Rows must be greater or equal to 1');
      end if;  
   -- First row check 
      
        select count(*) into w_Time_D_Count from W_Time_D ;
       
       if (  w_Time_D_Count = 0 ) then 
       
       startYear := 2012; startMonth := 1; startDay := 1;
       startDate := to_Date( to_Char(startMonth)|| '/' || to_char(startDay)|| '/' || to_Char(startYear),'MM/DD/YYYY') ;
       nextDate := startDate; 
        
        
       elsif ( w_Time_D_Count <> 0 ) then 
       
       
       execute IMMEDIATE 'select time_ID from W_Time_D where rownum = 1 order by time_ID desc' into w_Time_D_Last;
       execute IMMEDIATE 'select w_time_year from W_Time_D where time_ID = ' || w_Time_D_Last into startYear ;
       execute IMMEDIATE 'select w_time_Month from W_Time_D where time_ID = ' || w_Time_D_Last into startMonth ;
       execute IMMEDIATE 'select w_time_Day from W_Time_D where time_ID = ' || w_Time_D_Last into startDay ;
       
        startDate := to_Date( to_Char(startMonth)|| '/' || to_char(startDay)|| '/' || to_Char(startYear),'MM/DD/YYYY') ;
        nextDate := startDate + 1;
        
        
       end if;
       
      
        
        
  for i in 1.. noRows loop
       -- PK 
       -- Will be generate down there
        
       -- v_time_ID := W_TIME_D_SEQ.nextVal;
         
       -- Generate dates
          
       v_Flag1 := false;  
       while ( v_Flag1 = false ) loop
       
        v_DayOfWeek :=  to_Number ( to_Char( nextDate,'D' ) );
        
       if ( v_DayOfWeek <> 1 and v_DayOfWeek <> 7 )  then
          
           v_year  := extract(year from nextDate);  
           v_month := extract(month from nextDate);
           v_day := extract(day from nextDate);
       
            if ( v_month >= 1 and v_month <= 3 )  then v_quarter := 1 ;
                 elsif ( v_month > 3 and v_month <= 6 ) then v_quarter := 2;
                 elsif ( v_month > 6 and v_month <= 9 ) then v_quarter := 3;
                 elsif ( v_month > 9 and v_month <=12 ) then v_quarter := 4;
           end if;
       
             v_week := to_number ( to_char(nextDate+2,'IW') );
             
          -- Generating PK    (v_time_ID)
          v_time_ID_Char := v_year;
          if ( v_month < 10 ) then v_time_ID_Char := v_time_ID_Char || '0' || v_month;
          elsif ( v_month >= 10 ) then v_time_ID_Char := v_time_ID_Char || v_month;
          end if;
          if ( v_day < 10 ) then v_time_ID_Char := v_time_ID_Char || '0' || v_day;
          elsif ( v_day >= 10 ) then v_time_ID_Char := v_time_ID_Char || v_day;
          end if;
          
          v_time_ID := to_Number( v_time_ID_Char );
          
          
           
       -- insert statments
       
       insert into W_TIME_D 
       (Time_ID,Time_Year,Time_Quarter,time_Month,time_Day,time_week)
       values
       (v_time_ID,v_year,v_quarter,v_month,v_day,v_week);
       
       v_Flag1 := true;
       
       end if;
    
      nextDate := nextDate + 1;
       
       
       end loop;
       
    
       
      
       
       
       
       
   end loop;
END;
