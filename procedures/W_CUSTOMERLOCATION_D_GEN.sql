
create or replace procedure W_CUSTOMERLOCATION_D_GEN 
(

noRows IN integer, -- number of Customers rows to generate
--activity_Type IN integer, -- 0:NO, 1:Yes, >=2:Random
minCredit_Limit IN decimal, -- Minimum of Credit_Limit  for each Customer Location
maxCredit_Limit IN decimal,  -- Maximum of Credit_Limit  for each Customer Location 
minNumLocation IN integer, -- Min number of Locations for each customer
maxNumLocation IN integer, -- Max number of Locations for each customer

-- Credit limit is a sum of limit in related locations plus a padding (Min% to Max%)
-- Credit limit: round to nearest 1,000
minCustomerLimitPadding number, -- min Padding for each Customer Credit_Limit Percentage
maxCustomerLimitPadding number  -- min Padding for each Customer Credit_Limit Percentage

)
IS

-- W_CUSTOMER_D variables
c_Cust_Key integer;
c_cust_Name varchar2(50);
--v_active char(1);
c_city varchar2(25);
c_country varchar(25);
c_credit_Limit decimal(10,2);
c_e_mail_address varchar2(50);
--v_phone varchar2(10);
c_Terms_Code varchar2(10);
c_cust_state varchar2(2);
c_zip varchar2(10);




-- procedure variables
errosNumber number;


-- W_CUSTOMER_D procedure variables
type namesarray IS VARRAY(100) OF VARCHAR2(25);
type companyCountArray IS VARRAY(10000) of integer;
companyCount companyCountArray  := companyCountArray();
--companyCountCounter integer;
--names namesarray;
--cities namesarray;
termCodes namesarray;
--phoneAreas namesarray;
--v_numRowsCounter integer;
--v_Cust_Code_Counter integer;
--v_Cust_Code_Random integer;
--v_Cust_Name_Random integer;
--v_e_mail_address_Random integer;
--v_activity_Type integer;
--v_city_Random integer;
--v_Phone_Random integer;
--v_phone_area integer;

--v_Min_NoRows_MyName integer;
--v_Max_NoRows_MyName integer;
v_Customer_Name_Random integer;

v_Customer_FirstName varchar2(25);
v_Customer_LastName varchar2(25);
v_Email_Domain varchar2(50);
v_G_Name_Random integer;
v_G_Company_Count integer;


--W_CUST_LOCATIN_D table variables
l_Cust_Loc_Key integer;
l_City varchar2(25);
l_Country varchar2(25);
l_Credit_Limit number (10,2);
l_Email_Address varchar2(50);
l_location_State varchar2(2);
l_Terms_Code varchar2(10);
l_Zip varchar2(10);
l_Cust_Key number(10);
l_Cust_Name varchar2(50);

-- W_CUST_LOCATIN_D Proedure Variables
--v_Flag1 boolean;
--v_NoRows_Customer integer;
v_noLocations integer;
v_City_Random_ID integer;
--v_Email_Domain varchar2(50);
--v_G_Name_Random integer;
--v_Customer_FirstName varchar2(25);
--v_Customer_LastName varchar2(25);
v_Credit_Limit_Total integer;


Begin

--Initial procedure

errosNumber := -20010;

execute immediate 'delete from W_CUSTOMER_D';
select count(*) into v_G_Company_Count from G_COMPANY;
for i in 1..v_G_Company_Count loop
  companyCount.EXTEND;
  companyCount(i) := 0;
end loop;



---  verify input parms

errosNumber := errosNumber - 1;
if (noRows<1) then
  raise_application_error(errosNumber,'Error - Number of Rows must be greater or equal to 1');
end if;

errosNumber := errosNumber - 1;   
if ( minCredit_Limit <0 ) then
  raise_application_error(errosNumber,'Min Credit_Limit can''t be less than 0');
end if;

errosNumber := errosNumber - 1;   
if ( maxCredit_Limit < minCredit_Limit  ) then
  raise_application_error(errosNumber,'Max Credit_Limit can'' be less than Min Carry Cost ');
end if;

errosNumber := errosNumber - 1;   
if ( minNumLocation <0 ) then
  raise_application_error(errosNumber,'Min number of locations can''t be less than 0');
end if;

errosNumber := errosNumber - 1;   
if ( maxNumLocation < minNumLocation  ) then
  raise_application_error(errosNumber,'Max number of locations can'' be less Min number of locations');
end if;

errosNumber := errosNumber - 1;   
if ( minCustomerLimitPadding <0 ) then
  raise_application_error(errosNumber,'Min percentage of padding can''t be less than 0');
end if;
   
errosNumber := errosNumber - 1;   
if ( maxCustomerLimitPadding < minCustomerLimitPadding  ) then
  raise_application_error(errosNumber,'Max percentage of padding can'' be less Min percentage of padding');
end if;
      

   
   


-- Generate Customer Loop
for i in 1.. noRows loop

  -- Generate PK
  c_Cust_Key := W_Customer_D_Seq.nextval;
  
  -- Generate Customer Name
  v_Customer_Name_Random := RANDOMIZEID('G_COMPANY','company_Key','',0,0);
  execute immediate 'select company_Name from G_Company where Company_Key = ' || v_Customer_Name_Random into c_cust_Name;
           
  v_Email_Domain := replace(c_cust_Name,' ','');
  v_Email_Domain := replace(v_Email_Domain,'''','');
           
  companyCount(v_Customer_Name_Random) := companyCount(v_Customer_Name_Random) + 1 ; 
  c_cust_Name := c_cust_Name || ' ' || to_Char(  companyCount(v_Customer_Name_Random) );
  
  -- Generate Email address
  v_G_Name_Random := randomizeID('G_NAME','Name_Key','',0,0);
  execute immediate 'select firstName from G_Name where Name_Key = ' || v_G_Name_Random into v_Customer_FirstName;
  v_G_Name_Random := randomizeID('G_NAME','Name_Key','',0,0);
  execute immediate 'select lastName from G_Name where Name_Key = ' || v_G_Name_Random into v_Customer_LastName;
  c_e_mail_address := v_Customer_FirstName || '.' || v_Customer_LastName || '@' || v_Email_Domain || '.com' ;
  
  -- Generate City
  execute immediate ' select  Company_City from G_company where company_Key = ' || v_Customer_Name_Random into c_city;
  
  -- Generate Country
  execute immediate ' select  Company_Country from G_company where company_Key = ' || v_Customer_Name_Random into c_country;
             
  -- Generate Cust_State
  execute immediate ' select  Company_State from G_company where company_Key = ' || v_Customer_Name_Random into c_cust_state;
             
  -- Generate Zip code
  execute immediate ' select  Company_Zip from G_company where company_Key = ' || v_Customer_Name_Random into c_zip;
  c_zip := replace(c_zip,' ','');
           
  -- Generate Credit_Limit
  -- Customer Credi_Limit will be calculated after gerenering Customer Location credit limit
  -- c_credit_Limit := trunc(dbms_random.value(minCredit_Limit,maxCredit_Limit+0.99),2);
  c_credit_Limit := 0;
           
  -- Generate Terms_Code
  termCodes := namesarray('COD','Net20','Net30','Net60');
  c_Terms_Code := termCodes( trunc(dbms_random.value(1,5),0) );
  
  
  -- insert customer
  
   insert into W_CUSTOMER_D
           (cust_Key,cust_Name,city,country,credit_Limit,e_mail_address,cust_state,zip,terms_Code)
           values
           (c_Cust_Key,c_cust_Name,c_city,c_country,c_credit_Limit,c_e_mail_address, c_cust_state, c_zip, c_Terms_Code);
        
  
  -- Random number of location for each Customer
  v_noLocations := trunc(dbms_random.value(minNumLocation,maxNumLocation+0.99),0); 
  v_Credit_Limit_Total :=0 ;
  
  for j in 1.. v_noLocations loop
  
    --Generating Primary KEy
    l_Cust_Loc_Key := W_CUST_LOCATION_D_SEQ.nextval;
  
    --Generating Cust_Name
    l_Cust_Name := c_Cust_Name || ' - Location ' || j;
    
    -- Randomize City record from G_CITY
    v_City_Random_ID := randomizeID('G_CITY','CITY_KEY','',0,0);
    --Generating City
    execute immediate 'select city_name from G_CITY where City_Key = ' ||  v_City_Random_ID into l_City;
    
    --Generating Country 
    execute immediate 'select city_country from G_CITY where City_Key = ' ||  v_City_Random_ID into l_Country;
    
    --Generating State
    execute immediate 'select city_State from G_CITY where City_Key = ' ||  v_City_Random_ID into l_location_State;
    
    --Generating Zip
    execute immediate 'select city_zip from G_CITY where City_Key = ' ||  v_City_Random_ID into l_Zip;
    l_Zip := replace(l_Zip,' ','');
    
    --Generating eamil address
    execute immediate 'select firstName from G_Name where Name_Key = ' || v_G_Name_Random into v_Customer_FirstName;
    v_G_Name_Random := randomizeID('G_NAME','Name_Key','',0,0);
    execute immediate 'select lastName from G_Name where Name_Key = ' || v_G_Name_Random into v_Customer_LastName;
    l_Email_Address := v_Customer_FirstName || '.' || v_Customer_LastName || '@' || v_Email_Domain || '.com' ;
        
    --Generating Credit Limit
     l_Credit_Limit := round ( trunc(dbms_random.value(minCredit_Limit,maxCredit_Limit+0.99),0)/1000)*1000;
     v_Credit_Limit_Total := v_Credit_Limit_Total + l_Credit_Limit;
     
     --Insert statement
     Insert into W_CUST_LOCATION_D 
     (cust_loc_key, city, country, credit_limit, e_mail_Address, cust_location_state, zip, cust_Key, cust_Name)
     values
     (l_Cust_Loc_Key,l_City, l_Country , l_Credit_Limit, l_Email_Address , l_location_State , l_Zip , c_Cust_Key , l_Cust_Name  );
     
    
  end loop;
  
  
  -- Generate Credit_Limit for Customer
  
  
  c_credit_Limit := round ( ( v_Credit_Limit_Total + (  v_Credit_Limit_Total * trunc(dbms_random.value(minCustomerLimitPadding,maxCustomerLimitPadding+0.99),2)/100 ) )/1000 )*1000 ;
  execute immediate ' update W_CUSTOMER_D set credit_Limit =  ' || c_credit_Limit ||' where  cust_Key = ' || c_Cust_Key;
           

end loop;

end;