
create or replace function getAddedDays
(

time_ID number,
numberOfDatesToAdd number

)
return number

IS

addedDate_ID number(10);

Begin

if ( numberOfDatesToAdd < 1 ) then
  return time_ID;
else
  execute immediate ' select max(time_ID) from ( select Time_ID from W_TIME_D where rownum <= ' || numberOfDatesToAdd || ' and Time_ID > ' || time_ID || ' order by Time_ID asc) ' into addedDate_ID  ;

  if ( addedDate_ID = '' or addedDate_ID = null )then
    raise_application_error(-20011,addedDate_ID || ' An error occured adding days to the date');
  else
    return  addedDate_ID ;
  end if;
end if;


END;