create or replace function checkData
(
tableName IN varchar2,
fieldName in varchar2,
item in varchar2
)
return boolean
IS

v_Counter integer;

Begin

execute IMMEDIATE '  select count(*) from ' || tableName || ' where '|| fieldName ||' = ' || item  into v_Counter ;
if v_Counter = 0 then return false; 
elsif v_Counter <> 0 then return true; 
end if;

End;