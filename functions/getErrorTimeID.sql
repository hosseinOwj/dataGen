
create or replace function getErrorTimeID
(
min_AddedDays integer,
max_AddedDaya integer

)
return integer
IS

time_Last_ID integer;
added_Date date;
added_Date_Char  varchar2(8);

v_year integer; 
v_month integer;
v_day integer; 

v_ErrosNumber integer;

BEGIN

v_ErrosNumber := -20010;
--Input verification

v_ErrosNumber := v_ErrosNumber - 1;
if (min_AddedDays < 1) then
  raise_application_error(v_ErrosNumber,'Min Number of days to add can''t be less than 1');
end if;

v_ErrosNumber := v_ErrosNumber - 1;
if (max_AddedDaya < min_AddedDays) then
  raise_application_error(v_ErrosNumber,'Max Number of days to add can''t be less than Min Number of days to add');
end if;


select max(Time_ID) into time_Last_ID from W_TIME_D;
added_Date := to_Date( time_Last_ID , 'YYYYMMDD');
added_Date := added_Date + trunc(dbms_random.value(min_AddedDays,max_AddedDaya+0.99) ) ;

v_year  := extract(year from added_Date);  
v_month := extract(month from added_Date);
v_day := extract(day from added_Date);

added_Date_Char := v_year;
if ( v_month < 10 ) then added_Date_Char := added_Date_Char || '0' || v_month;
elsif ( v_month >= 10 ) then added_Date_Char := added_Date_Char || v_month;
end if;
if ( v_day < 10 ) then added_Date_Char := added_Date_Char || '0' || v_day;
elsif ( v_day >= 10 ) then added_Date_Char := added_Date_Char || v_day;
end if;      
return  to_Number( added_Date_Char );



END;