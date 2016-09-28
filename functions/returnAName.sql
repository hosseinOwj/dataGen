



create or replace function returnAName

return varchar2
IS

v_Counter integer;
v_Cust_Name_Random integer;

v_Random_Name varchar2(25);

v_Min integer;
v_Max integer;


Begin


            
   calculateRange('G_NAME','NAME_KEY','',v_Min,v_Max);        

   v_Cust_Name_Random := trunc(dbms_random.value(v_Max-v_Min,v_Max+0.99),0);
            if ( checkData('G_NAME','NAME_KEY',v_Cust_Name_Random) = true ) then 
            execute IMMEDIATE  'select myName from myName where myName_Key = ' || v_Cust_Name_Random into v_Random_Name ;
            end if;
            if ( v_Random_Name = '' or null ) then raise_application_error(-20011,'No matched name found'); end if;
            
            return v_Random_Name;

End;



