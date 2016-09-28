

create or replace function randomizeTimeID 
(
startDate IN number,
endDate IN number
)
return number
IS


timeRange integer;
date_Random integer;

Begin

execute immediate ' select count(*) from W_TIME_D where time_ID >= ' ||  startDate || ' and  time_ID <=  ' || endDate into timeRange;

date_Random := trunc(dbms_random.value(1,timeRange+0.9999));
if ( date_Random < 1 ) then date_Random := 1; end if;
return getAddedDays(startDate,date_Random-1);
 



end;