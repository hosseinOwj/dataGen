
create or replace function getTimeIDDif
(

time_ID1 number,
time_ID2 number

)
return number

IS


v_timne_ID1 integer;
v_timne_ID2 integer;
transTimeID integer;
difference integer;

Begin

v_timne_ID1 := time_ID1;
v_timne_ID2 := time_ID2;

if ( v_timne_ID1 = v_timne_ID2 ) then
return 0;
elsif ( v_timne_ID1 > v_timne_ID2 ) then 
transTimeID := v_timne_ID1;
v_timne_ID1 := v_timne_ID2;
v_timne_ID2 := transTimeID;
end if;


  execute immediate ' select count(*) from w_time_D where time_ID <= ' ||  v_timne_ID2 ||' and time_ID > ' || v_timne_ID1 into difference  ;

  if ( difference = '' or difference is null )then
    raise_application_error(-20011, ' An error occured calculating the difference');
  else
    return  difference ;
  end if;



END;