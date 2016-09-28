


create or replace procedure W_SALES_AGENT_D_GEN 
(
noRows IN integer -- number of rows to generate
--active_Type IN integer -- 0:NO, 1:Yes, >= 2:Random -- Removed in V8
)
IS

-- table variable prefix with agent_

agent_SALES_AGENT_ID W_SALES_AGENT_D.SALES_AGENT_ID%TYPE;
agent_SALES_AGENT_NAME W_SALES_AGENT_D.SALES_AGENT_NAME%TYPE;
agent_SALES_AGENT_STATE W_SALES_AGENT_D.SALES_AGENT_STATE%TYPE;
agent_COUNTRY W_SALES_AGENT_D.COUNTRY%TYPE;


-- Procedure Variables

v_Name_Random integer;
v_FirstName varchar(25);
v_LastName varchar(25);
v_City_Random integer;

BEGIN

---  verify input parms

if (noRows<1) then
      raise_application_error(-20011,'Error - Number of Rows must be greater or equal to 1');
   end if;
  
  for i in 1..  noRows Loop
   -- Generate PK
   agent_SALES_AGENT_ID := W_SALES_AGENT_D_SEQ.nextval;
   
   -- Generate Agent Name
   v_Name_Random := RANDOMIZEID('G_NAME','NAME_KEY','',0,0);
   execute immediate 'select FIRSTNAME from G_NAME where NAME_KEY = ' || v_Name_Random into v_FirstName;
   
    v_Name_Random := RANDOMIZEID('G_NAME','NAME_KEY','',0,0);
   execute immediate 'select LASTNAME from G_NAME where NAME_KEY = ' || v_Name_Random into v_LastName;
   
   agent_SALES_AGENT_NAME :=  v_FirstName || ' ' || v_LastName; 
    
    v_City_Random := RANDOMIZEID('G_CITY','CITY_KEY','',0,0);
   -- Generate Agen State
   execute immediate ' select CITY_STATE from G_CITY where CITY_KEY = ' || v_City_Random into agent_SALES_AGENT_STATE;
   
   
   -- Generate Country
   execute immediate ' select CITY_COUNTRY from G_CITY where CITY_KEY = ' || v_City_Random into agent_COUNTRY;
  
   
   -- Generate Active
   -- Removed in V8
   /*
   v_Active_Type := active_Type;
           
   if ( v_Active_Type >= 2 ) then v_Active_Type  := trunc(dbms_random.value(0,1.99),0); end if;
   if ( v_Active_Type = 0 ) then v_Record_Active := 'N';
   elsif ( v_Active_Type = 1 ) then v_Record_Active := 'Y'; end if;
   */
   
   -- Insert statments
   
   insert into W_SALES_AGENT_D
   (SALES_AGENT_ID,SALES_AGENT_NAME,SALES_AGENT_STATE,COUNTRY)
   values
   (agent_SALES_AGENT_ID , agent_SALES_AGENT_NAME , agent_SALES_AGENT_STATE , agent_COUNTRY  );

 end loop;  
   

END;
