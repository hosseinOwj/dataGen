
create or replace procedure deleteAll_F

IS

BEGIN
delete from W_LEAD_F;
delete from W_JOB_F;
delete from W_SUB_JOB_F;
delete from W_JOB_SHIPMENT_F;
delete from W_INVOICELINE_F;
delete from W_FINANCIAL_SUMMARY_COST_F;
delete from W_FINANCIAL_SUMMARY_SALES_F;

end;