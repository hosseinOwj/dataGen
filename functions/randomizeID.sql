
create or replace function randomizeID
(

tableName IN varchar2,
fieldName IN varchar2,
whereClause IN varchar2,
v_Min_Input IN integer,
v_Max_Input IN integer


)

return integer
IS

v_Return_ID integer;
v_Counter integer;
v_Min integer;
v_Max integer;



Begin

if ( v_Min_Input = 0 and v_Max_Input = 0) then
calculateRange(tableName,fieldName,whereClause,v_Min,v_Max);
else
v_Min := v_Min_Input;
v_Max := v_Max_Input;
end if;


 v_Counter := 0;
          while  v_Counter < 25
          loop
          v_Return_ID  := trunc(dbms_random.value(v_Max-v_Min+1,v_Max+0.99),0);
          if CHECKDATA(tableName,fieldName,v_Return_ID) = true then return v_Return_ID; end if;
          v_Counter := v_Counter +1;
          END loop;
          if v_Counter = 25 then
          raise_application_error(-20054,'The application failed to generate a ' || fieldName ||' after 25 attemps');
          end if;

End;