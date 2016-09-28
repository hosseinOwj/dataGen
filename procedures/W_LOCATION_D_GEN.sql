


create or replace procedure W_LOCATION_D_GEN

IS

begin



execute IMMEDIATE 'delete from W_LOCATION_D';

execute IMMEDIATE 'insert into W_LOCATION_D (LOCATION_ID,LOCATION_NAME,LOCATION_CAT) select myLOCATION_KEY,MYLOCATION,MYLOCATION_CAT from myLocation';


end;