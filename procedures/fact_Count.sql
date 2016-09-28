
create or replace procedure fact_Count

IS

Type tableName is table of varchar2(50);
myTableName tableName := tableName ('W_LEAD_F','W_JOB_F','W_SUB_JOB_F','W_JOB_SHIPMENT_F','W_INVOICELINE_F','W_FINANCIAL_SUMMARY_SALES_F','W_FINANCIAL_SUMMARY_COST_F');

Type tableCount is table of integer;
myTableCount tableCount  := tableCount();

counter integer;
total_Tables_Count integer;

Begin
total_Tables_Count:=0;

counter := 1;

myTableCount.EXTEND;
execute immediate 'select count(*)  from W_LEAD_F' into myTableCount(counter);
counter := counter + 1;

myTableCount.EXTEND;
execute immediate 'select count(*) from W_JOB_F' into myTableCount(counter) ;
counter := counter + 1;

myTableCount.EXTEND;
execute immediate 'select count(*)  from W_SUB_JOB_F' into myTableCount(counter);
counter := counter + 1;

myTableCount.EXTEND;
execute immediate 'select count(*)  from W_JOB_SHIPMENT_F' into myTableCount(counter);
counter := counter + 1;

myTableCount.EXTEND;
execute immediate 'select count(*)  from W_INVOICELINE_F' into myTableCount(counter) ;
counter := counter + 1;

myTableCount.EXTEND;
execute immediate 'select count(*)  from W_FINANCIAL_SUMMARY_SALES_F' into myTableCount(counter);
counter := counter + 1;

myTableCount.EXTEND;
execute immediate 'select count(*)  from W_FINANCIAL_SUMMARY_COST_F' into  myTableCount(counter) ;




for i in 1..myTableName.count loop

dbms_output.put_line(myTableName(i) || ' Count is : ' || myTableCount(i) );
total_Tables_Count := total_Tables_Count + myTableCount(i) ;
end loop;
dbms_output.put_line('The Total Count is :' || total_Tables_Count );


End;