
create or replace procedure calculateRange
(
tableName IN varchar2,
fieldName in varchar2,
whereClause In varchar2,

out_Min OUT integer,
out_Max OUT integer

)

IS

v_Counter integer;

Begin

 if ( whereClause = ' ' or whereClause = '' or  whereClause = null or whereClause is null ) then
  execute IMMEDIATE ' select ' || fieldName || ' from ' || tableName || '  where rownum = 1 order by ' || fieldName || '  desc ' into out_Max ;
  execute IMMEDIATE ' select count(*) from ' ||  tableName into out_Min; 
 elsif ( whereClause <> ' ' and whereClause <> '' and whereClause <> null or whereClause is not null ) then 
  execute IMMEDIATE ' select ' || fieldName || ' from ' || tableName || '  where rownum = 1 AND '|| whereClause || ' order by ' || fieldName || '  desc ' into out_Max ;
  execute IMMEDIATE ' select count(*) from ' ||  tableName || ' where ' || whereClause  into out_Min; 
 end if;
 
 if ( out_Min = '' or out_Min = null or out_Min = 0 ) then 
          raise_application_error(-20015,'The Table ' || tableName || ' is empty or an error occurred while calculating the Min '); end if;
 if ( out_Max = '' or out_Max = null or out_Max = 0 ) then 
          raise_application_error(-20016,'The Table ' || tableName || ' is empty or an error occurred while calculating the Max '); end if;

End;