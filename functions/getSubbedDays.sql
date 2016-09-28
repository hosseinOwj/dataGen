

create or replace function getSubbedDays
(

time_ID number,
numberOfDatesToSub number

)
return number

IS

SubbedDateID number(10);
minTimeID integer;

Begin

execute immediate ' select min(Time_ID) from W_TIME_D' into minTimeID;
if ( numberOfDatesToSub < 1  or time_ID =  minTimeID) then
  return time_ID;
else
  execute immediate ' select min(time_ID) from ( select Time_ID from W_TIME_D where rownum <= ' || numberOfDatesToSub || ' and Time_ID  < ' || time_ID || ' order by Time_ID desc) ' into SubbedDateID  ;

  if ( SubbedDateID = '' or SubbedDateID is null )then
    raise_application_error(-20011,SubbedDateID || ' An error occured subtracting days to the date');
  else
    return  SubbedDateID ;
  end if;
end if;


END;