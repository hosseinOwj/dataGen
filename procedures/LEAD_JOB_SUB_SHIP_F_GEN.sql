--SET define OFF;
CREATE OR REPLACE PROCEDURE LEAD_JOB_SUB_SHIP_F_GEN(
    -- Mandatory Parameters
    noRows      INTEGER,  -- number of rows in W_LEAD_F table
    startDate   NUMBER,   -- given data range - start
    endDate     NUMBER,   -- given data range - end
    fact_Select INTEGER , -- 0 (Lead, Job, Subjob, Shipment), 1 (Lead, Job, Subjob), 2 (Lead, Job), 3 (Lead)
    -- Optional Parameters
    Parameters_Table_ID INTEGER DEFAULT 0, -- Optional Parameter: Ignore it if you want the procedure use the last row of the G_PARAMETER table as default; 0: last row of the table, >0 the G_Parameters_ID
    change_Table_Enable INTEGER DEFAULT 0  -- Optional Parameter: ALWAYS ignore it when you are directly using this procedure;  0:Disabled , 1:Enabled ; MUST always set to 0 when using this Procedure; DONT USE THIS PROCEDURE FOR CHANGE DATA ; USE W_Job_Change_Data_Gen Instead
  )
IS
  /*******************************************
  TABLE VARIABLES
  ********************************************/
  /*******  LEAD TABLE *********/
  --W_LEAD_F table variables with lead_ prefix
  lead_LEAD_ID W_LEAD_F.LEAD_ID%TYPE;
  lead_QUOTE_QTY W_LEAD_F.QUOTE_QTY%TYPE;
  lead_QUOTE_PRICE W_LEAD_F.QUOTE_PRICE%TYPE;
  lead_LEAD_SUCCESS W_LEAD_F.LEAD_SUCCESS%TYPE;
  lead_JOB_ID W_LEAD_F.JOB_ID%TYPE;
  lead_CREATED_DATE W_LEAD_F.CREATED_DATE%TYPE;
  lead_CUST_ID W_LEAD_F.CUST_ID%TYPE;
  lead_LOCATION_ID W_LEAD_F.LOCATION_ID%TYPE;
  lead_SALES_AGENT_ID W_LEAD_F.SALES_AGENT_ID%TYPE;
  lead_SALES_CLASS_ID W_LEAD_F.SALES_CLASS_ID%TYPE;
  /*******  JOB TABLE *********/
  --W_JOB_F table variables with job_ prefix
  job_JOB_ID W_JOB_F.JOB_ID%TYPE;
  job_CONTRACT_DATE W_JOB_F.CONTRACT_DATE%TYPE;
  job_SALES_AGENT_ID W_JOB_F.SALES_AGENT_ID%TYPE;
  job_SALES_CLASS_ID W_JOB_F.SALES_CLASS_ID%TYPE;
  job_job_LOCATION_ID W_JOB_F.LOCATION_ID%TYPE;
  job_CUST_ID_ORDERED_BY W_JOB_F.CUST_ID_ORDERED_BY%TYPE;
  job_DATE_PROMISED W_JOB_F.DATE_PROMISED%TYPE;
  job_DATE_SHIP_BY W_JOB_F.DATE_SHIP_BY%TYPE;
  job_NUMBER_OF_SUBJOBS W_JOB_F.NUMBER_OF_SUBJOBS%TYPE;
  job_UNIT_PRICE W_JOB_F.UNIT_PRICE%TYPE;
  job_QUANTITY_ORDERED W_JOB_F.QUANTITY_ORDERED%TYPE;
  job_Quote_Qty W_JOB_F.QUOTE_QTY%TYPE;
  /******* SUB JOB TABLE *********/
  --W_SUB_JOB_F table variables with sub_ prefix
  sub_SUB_JOB_ID W_SUB_JOB_F.SUB_JOB_ID%TYPE;
  sub_COST_LABOR W_SUB_JOB_F.COST_LABOR%TYPE;
  sub_COST_MATERIAL W_SUB_JOB_F.COST_MATERIAL%TYPE;
  sub_COST_OVERHEAD W_SUB_JOB_F.COST_OVERHEAD%TYPE;
  sub_MACHINE_HOURS W_SUB_JOB_F.MACHINE_HOURS%TYPE;
  sub_QUANTITY_PRODUCED W_SUB_JOB_F.QUANTITY_PRODUCED%TYPE;
  sub_SUB_JOB_AMOUNT W_SUB_JOB_F.SUB_JOB_AMOUNT%TYPE;
  sub_JOB_ID W_SUB_JOB_F.JOB_ID%TYPE;
  sub_MACHINE_TYPE_ID W_SUB_JOB_F.MACHINE_TYPE_ID%TYPE;
  sub_SALES_CLASS_ID W_SUB_JOB_F.SALES_CLASS_ID%TYPE;
  sub_DATE_PROD_BEGIN W_SUB_JOB_F.DATE_PROD_BEGIN%TYPE;
  sub_DATE_PROD_END W_SUB_JOB_F.DATE_PROD_END%TYPE;
  sub_LOCATION_ID W_SUB_JOB_F.LOCATION_ID%TYPE;
  sub_CUST_ID_ORDERED_BY W_SUB_JOB_F.CUST_ID_ORDERED_BY%TYPE;
  /******* SHIPMENT TABLE *********/
  --W_JOB_SHIPENT_F table variables with ship_ prefix
  ship_JOB_SHIPMENT_ID W_JOB_SHIPMENT_F.JOB_SHIPMENT_ID%TYPE;
  ship_ACTUAL_QUANTITY W_JOB_SHIPMENT_F.ACTUAL_QUANTITY%TYPE;
  ship_REQUESTED_QUANTITY W_JOB_SHIPMENT_F.REQUESTED_QUANTITY%TYPE;
  ship_BOXES W_JOB_SHIPMENT_F.BOXES%TYPE;
  ship_QUANTITY_PER_BOX W_JOB_SHIPMENT_F.QUANTITY_PER_BOX%TYPE;
  ship_QUANTITY_PER_PARTIAL_BOX W_JOB_SHIPMENT_F.QUANTITY_PER_PARTIAL_BOX%TYPE;
  ship_X_SHIPPED_AMOUNT W_JOB_SHIPMENT_F.SHIPPED_AMOUNT%TYPE;
  ship_SUB_JOB_ID W_JOB_SHIPMENT_F.SUB_JOB_ID%TYPE;
  ship_SALES_CLASS_ID W_JOB_SHIPMENT_F.SALES_CLASS_ID%TYPE;
  ship_LOCATION_ID W_JOB_SHIPMENT_F.LOCATION_ID%TYPE;
  ship_CUST_ID_SHIP_TO W_JOB_SHIPMENT_F.CUST_ID_SHIP_TO%TYPE;
  ship_ACTUAL_SHIP_DATE W_JOB_SHIPMENT_F.ACTUAL_SHIP_DATE%TYPE;
  ship_REQUESTED_SHIP_DATE W_JOB_SHIPMENT_F.REQUESTED_SHIP_DATE%TYPE;
  ship_INVOICE_ID W_JOB_SHIPMENT_F.INVOICE_ID%TYPE;
  /******* INVOICE TABLE *********/
  --W_INVOICELINE_F table variables with Invoice_ perfix
  Invoice_INVOICE_ID W_INVOICELINE_F.INVOICE_ID%TYPE;
  Invoice_INVOICE_QUANTITY W_INVOICELINE_F.INVOICE_QUANTITY%TYPE;
  Invoice_INVOICE_AMOUNT W_INVOICELINE_F.INVOICE_AMOUNT%TYPE;
  Invoice_QUANTITY_SHIPPED W_INVOICELINE_F.QUANTITY_SHIPPED%TYPE;
  Invoice_SALES_CLASS_ID W_INVOICELINE_F.SALES_CLASS_ID%TYPE;
  Invoice_INVOICE_SENT_DATE W_INVOICELINE_F.INVOICE_SENT_DATE%TYPE;
  Invoice_INVOICE_DUE_DATE W_INVOICELINE_F.INVOICE_DUE_DATE%TYPE;
  Invoice_CUST_KEY W_INVOICELINE_F.CUST_KEY%TYPE;
  Invoice_SALES_AGENT_ID W_INVOICELINE_F.SALES_AGENT_ID%TYPE;
  Invoice_LOCATION_ID W_INVOICELINE_F.LOCATION_ID%TYPE;
  /******* PARAMETERS TABLE *********/
  v_G_Parameters_ID G_PARAMETERS.G_PARAMETERS_ID%TYPE;
  v_Success_Rate G_PARAMETERS.SUCCESS_RATE%TYPE;
  v_Min_Order_Qty G_PARAMETERS.Min_Order_Qty%TYPE;
  v_Max_Order_Qty G_PARAMETERS.Max_Order_Qty%TYPE;
  v_Min_Sub_Qty G_PARAMETERS.MIN_SUB_QTY%TYPE;
  v_Max_Sub_Qty G_PARAMETERS.MAX_SUB_QTY%TYPE;
  v_Min_Num_Ship G_PARAMETERS.MIN_NUM_SHIP%TYPE;
  v_Max_Num_Ship G_PARAMETERS.MAX_NUM_SHIP%TYPE;
  v_Min_Box_Qty G_PARAMETERS.MIN_BOX_QTY%TYPE;
  v_Max_Box_Qty G_PARAMETERS.MAX_BOX_QTY%TYPE;
  v_Vol_Level G_PARAMETERS.Vol_Level%TYPE;
  v_Min_Cost_Rate G_PARAMETERS.Min_Cost_Rate%TYPE;
  v_Max_Cost_Rate G_PARAMETERS.Max_Cost_Rate%TYPE;
  v_Invoice_Rate G_PARAMETERS.INVOICE_RATE%TYPE;
  v_Complete_Invoice_Rate G_PARAMETERS.COMPLETE_INVOICE_RATE%TYPE;
  v_Combination_rate G_PARAMETERS.COMBINATION_RATE%TYPE;
  /*******************************************
  PROCEDURE VARIABLES
  ********************************************/
  /*******  LEAD TABLE *********/
  --W_LEAD PROCEDURE Variables with v_Lead prefix
  v_Lead_Succ_Random W_LEAD_F.LEAD_ID%TYPE;
  /*******  JOB TABLE *********/
  --W_JOB_F procedure variables with v_Job prefix
  v_Job_Promised_Random   NUMBER;
  v_Job_No_Subjobs_Random NUMBER;
  v_Job_Ship_Random       NUMBER;
  /******* SUB JOB TABLE *********/
  --W_SUB_JOB_F procedure variables with v_Sub prefix
  v_Sub_JobQtyTot       NUMBER;
  v_Sub_Duration_Random NUMBER;
  v_Sub_Cost_Random     NUMBER;
  v_Sub_CostRate_Random NUMBER;
  v_Sub_Cost_Machine    NUMBER;
  v_Sub_TotalCost       NUMBER;
  v_Sub_Mach_Rate       NUMBER;
  v_Sub_Delay_Ran       NUMBER(5,2);
  v_Sub_Delay_Rate      NUMBER(5,2);
  v_Sub_Delay_Days      INTEGER;
  /******* SHIPMENT TABLE *********/
  --W_JOB_SHIPENT_F procedure variables with v_Ship prefix
  v_Ship_NoShip_Ran           INTEGER;
  v_Ship_TotalQty             NUMBER;
  v_Ship_Qty                  NUMBER;
  v_Ship_Box_Ran              NUMBER;
  v_RequestQty_Ran            NUMBER;
  v_ship_ACTUAL_SHIP_DATE_Ran NUMBER;
  /******* INVOICE TABLE *********/
  -- W_INVOICELINE_F produced variables with v_Invoice perfix
  v_InvoiceRate_Ran             NUMBER(5,2);
  v_Invoice_CustTerms           VARCHAR2(50);
  v_Invoice_CustKey             INTEGER;
  v_Invoice_CustNoRow           INTEGER;
  v_Invoice_BillingCycleRan     INTEGER;
  v_Invoice_CustInvoiceLine     INTEGER;
  v_Invoice_InvoiceID           INTEGER;
  v_Invoice_FirstDayOfMonth     INTEGER;
  v_Invoice_FirstDayOfNextMonth INTEGER;
  v_Invoice_LastDayOfNextMonth  INTEGER;
  v_Invoice_CycActualDate       INTEGER;
    /******* Change Table Procedure Varaiables *********/
  -- Change Table Procedur variables with v_ Change
  v_Change_CONTRACT_DATE char(10);
  v_Change_DATE_PROMISED char(10);
  v_Change_DATE_SHIP_BY char(10);
  
  
  /******* LEAD_JOB_SUB_SHIP_F_GEN Procedure Varaiables *********/
  -- LEAD_JOB_SUB_SHIP_F_GEN procedure variables with v_ prefix
  v_ErrosNumber       NUMBER;
  v_MaxDate           NUMBER;
  v_Min_W_Time_D      NUMBER;
  v_Date_Check1       NUMBER;
  v_StartDate         NUMBER;
  v_EndDate           NUMBER;
  v_Vol_Qty_level     NUMBER(10,2);
  v_NoRows_SalesClass INTEGER;
  v_NoRows_Location   INTEGER;
  v_NoRows_Machine    INTEGER;
BEGIN
  /*******************************************
  Inital process
  ********************************************/
  -- Error sequence
  v_ErrosNumber := -20010;                                                    -- Error Number starts with -20010 each error will mines this number by one
  EXECUTE immediate 'select min(time_ID) from W_TIME_D ' INTO v_Min_W_Time_D; -- Check for starting and eding date including avaiable extra 180 days in W_TIME_D
  /*******************************************
  Verify Input
  ********************************************/
  -- StartDate & EndDate
  v_ErrosNumber      := v_ErrosNumber - 1;
  IF ( v_Min_W_Time_D = '' OR v_Min_W_Time_D = NULL OR v_Min_W_Time_D = 0 ) THEN
    raise_application_error(v_ErrosNumber,'W_TIME_D is empty');
  ELSE
    EXECUTE immediate 'select count(*) from W_TIME_D where ' || startDate || ' >= '||v_Min_W_Time_D INTO v_Date_Check1 ;
  END IF;
  v_ErrosNumber     := v_ErrosNumber - 1;
  IF ( v_Date_Check1 = 0 ) THEN
    raise_application_error(v_ErrosNumber,'Invalid StartTime input. The starting date must be greater than or equal to '|| v_Min_W_Time_D);
  END IF;
  v_ErrosNumber := v_ErrosNumber - 1;
  EXECUTE immediate ' select count(*) from W_TIME_D where time_ID > ' || startDate INTO v_MaxDate;
  IF (v_MaxDate<365) THEN
    raise_application_error(v_ErrosNumber,'Not enough dates in W_D_TIMe; Make sure you have at least 365 business days in W_TIME_D in advance to ' || startDate);
  END IF;
  v_ErrosNumber := v_ErrosNumber - 1;
  EXECUTE immediate ' select count(*) from W_TIME_D where time_ID > ' || endDate INTO v_MaxDate;
  IF (v_MaxDate<365) THEN
    raise_application_error(v_ErrosNumber,'Not enough dates in W_D_TIMe; Make sure you have at least 365 business days in W_TIME_D in advance to ' || endDate);
  END IF;
  v_ErrosNumber := v_ErrosNumber - 1;
  IF (endDate    <startDate) THEN
    raise_application_error(v_ErrosNumber,'End Date can''t be less than Start Date ' || endDate);
  END IF;
  -- Number of Rows
  v_ErrosNumber := v_ErrosNumber - 1;
  IF (noRows     <1) THEN
    raise_application_error(v_ErrosNumber,'Error - Number of Rows must be greater or equal to 1');
  END IF;
  -- fact_Select
  v_ErrosNumber := v_ErrosNumber - 1;
  IF (fact_Select<0 OR fact_Select > 3) THEN
    raise_application_error(v_ErrosNumber,'Error - Fact Select ' || fact_Select || ' out of range ( 0 - 3 )');
  END IF;
  -- Parameters_Table_ID check
  IF ( Parameters_Table_ID = 0 ) THEN
    EXECUTE immediate 'select max(G_PARAMETERS_ID) from G_PARAMETERS' INTO v_G_Parameters_ID;
  elsif ( Parameters_Table_ID > 0 ) THEN
    EXECUTE immediate ' select G_PARAMETERS_ID from G_PARAMETERS  where G_PARAMETERS_ID =  ' || Parameters_Table_ID INTO v_G_Parameters_ID;
  END IF;
  -- change_Table_Enable check
  v_ErrosNumber          := v_ErrosNumber - 1;
  IF (change_Table_Enable < 0 OR change_Table_Enable>1) THEN
    raise_application_error(v_ErrosNumber,'Error - Fact Select ' || change_Table_Enable || ' out of range ( 0 - 1 )');
  END IF;
  --  change_Table_Enable and fact_Select
  v_ErrosNumber           := v_ErrosNumber - 1;
  IF ( change_Table_Enable = 1 AND fact_Select <> 2 ) THEN
    raise_application_error(v_ErrosNumber,'Fact_Select must set to 2 if Change_Table_Enable is enabled(1)');
  END IF;
  v_ErrosNumber         := v_ErrosNumber - 1;
  IF ( v_G_Parameters_ID = 0 OR v_G_Parameters_ID = '' OR v_G_Parameters_ID IS NULL ) THEN
    raise_application_error(v_ErrosNumber,'Parameter Table row doesnt exist in the table, re-check G_PARAMETERS table');
  END IF;
  -- layer 3 check fact_Select:2 (Lead, Job), 3 (Lead)
  v_ErrosNumber := v_ErrosNumber - 1;
  EXECUTE immediate 'select SUCCESS_RATE from G_PARAMETERS where G_PARAMETERS_ID = ' || v_G_Parameters_ID INTO v_Success_Rate;
  IF (v_Success_Rate<0) THEN
    raise_application_error(v_ErrosNumber,'Error - Lead Success Percentage can''t be less than 0');
  END IF;
  v_ErrosNumber    := v_ErrosNumber - 1;
  IF (v_Success_Rate>100) THEN
    raise_application_error(v_ErrosNumber,'Error - Lead Success Percentage can''t be greater than 100');
  END IF;
  v_ErrosNumber := v_ErrosNumber - 1;
  EXECUTE immediate 'select MIN_ORDER_QTY from G_PARAMETERS where G_PARAMETERS_ID = ' || v_G_Parameters_ID INTO v_Min_Order_Qty;
  IF (v_Min_Order_Qty < 1) THEN
    raise_application_error(v_ErrosNumber,'Min Number of Qty can''t be less than 1');
  END IF;
  v_ErrosNumber := v_ErrosNumber - 1;
  EXECUTE immediate 'select MAX_ORDER_QTY from G_PARAMETERS where G_PARAMETERS_ID = ' || v_G_Parameters_ID INTO v_Max_Order_Qty;
  IF (v_Max_Order_Qty < v_Min_Order_Qty) THEN
    raise_application_error(v_ErrosNumber,'Max Number of Qty can''t be less than Min Number of Qty');
  END IF;
  v_ErrosNumber := v_ErrosNumber - 1;
  EXECUTE immediate 'select vol_Level from G_PARAMETERS where G_PARAMETERS_ID = ' || v_G_Parameters_ID INTO v_Vol_Level;
  IF (v_Vol_Level < 1) THEN
    raise_application_error(v_ErrosNumber,'Quantity Volume cant''t be less than 1 ');
  END IF;
  v_ErrosNumber := v_ErrosNumber - 1;
  EXECUTE immediate 'select Combination_rate from G_PARAMETERS where G_PARAMETERS_ID = ' || v_G_Parameters_ID INTO v_Combination_rate;
  IF (v_Combination_rate < 1 OR v_Combination_rate > 100) THEN
    raise_application_error(v_ErrosNumber,'v_Combination_rate out of range (1-100) ');
  END IF;
  -- layer 2 check fact_Select:1 (Lead, Job, Subjob)
  IF ( fact_Select < 3 ) THEN
    v_ErrosNumber := v_ErrosNumber - 1;
    EXECUTE immediate 'select MIN_SUB_QTY from G_PARAMETERS where G_PARAMETERS_ID = ' || v_G_Parameters_ID INTO v_Min_Sub_Qty;
    IF (v_Min_Order_Qty < 1) THEN
      raise_application_error(v_ErrosNumber,'Min Number of Sub Jobs can''t be less than 1');
    END IF;
    v_ErrosNumber := v_ErrosNumber - 1;
    EXECUTE immediate 'select MAX_SUB_QTY from G_PARAMETERS where G_PARAMETERS_ID = ' || v_G_Parameters_ID INTO v_Max_Sub_Qty;
    IF (v_Max_Sub_Qty < v_Min_Sub_Qty) THEN
      raise_application_error(v_ErrosNumber,'Max Number of Sub Jobs can''t be less than Min Number of Sub Jobs');
    END IF;
    v_ErrosNumber := v_ErrosNumber - 1;
    EXECUTE immediate 'select Min_Cost_Rate from G_PARAMETERS where G_PARAMETERS_ID = ' || v_G_Parameters_ID INTO v_Min_Cost_Rate;
    IF (v_Min_Cost_Rate < 1) THEN
      raise_application_error(v_ErrosNumber,'Min Cost Rate can''t be less than 1');
    END IF;
    v_ErrosNumber := v_ErrosNumber - 1;
    EXECUTE immediate 'select Max_Cost_Rate from G_PARAMETERS where G_PARAMETERS_ID = ' || v_G_Parameters_ID INTO v_Max_Cost_Rate;
    IF (v_Max_Cost_Rate < v_Min_Cost_Rate) THEN
      raise_application_error(v_ErrosNumber,'Max Cost Rate can''t be less than Max Cost Rate can''t be less than');
    END IF;
  END IF;
  -- layer 1 check fact_Select:0 (Lead, Job, Subjob, Shipment)
  IF ( fact_Select < 1 ) THEN
    v_ErrosNumber := v_ErrosNumber - 1;
    EXECUTE immediate 'select MIN_NUM_SHIP from G_PARAMETERS where G_PARAMETERS_ID = ' || v_G_Parameters_ID INTO v_Min_Num_Ship;
    IF (v_Min_Num_Ship < 1) THEN
      raise_application_error(v_ErrosNumber,'Min Number of shipments can''t be less than 1');
    END IF;
    v_ErrosNumber := v_ErrosNumber - 1;
    EXECUTE immediate 'select MAX_NUM_SHIP from G_PARAMETERS where G_PARAMETERS_ID = ' || v_G_Parameters_ID INTO v_Max_Num_Ship;
    IF (v_Max_Num_Ship < v_Min_Num_Ship) THEN
      raise_application_error(v_ErrosNumber,'Max Number of shipments can''t be less than Min Number of shipments');
    END IF;
    v_ErrosNumber := v_ErrosNumber - 1;
    EXECUTE immediate 'select MIN_BOX_QTY from G_PARAMETERS where G_PARAMETERS_ID = ' || v_G_Parameters_ID INTO v_Min_Box_Qty;
    IF (v_Min_Box_Qty < 1) THEN
      raise_application_error(v_ErrosNumber,'Min Number of Boxes can''t be less than 1');
    END IF;
    v_ErrosNumber := v_ErrosNumber - 1;
    EXECUTE immediate 'select MAX_BOX_QTY from G_PARAMETERS where G_PARAMETERS_ID = ' || v_G_Parameters_ID INTO v_Max_Box_Qty;
    IF (v_Max_Box_Qty < v_Min_Box_Qty) THEN
      raise_application_error(v_ErrosNumber,'Max Number of Boxes can''t be less than Min Number of Boxes');
    END IF;
    v_ErrosNumber := v_ErrosNumber - 1;
    EXECUTE immediate 'select Invoice_Rate from G_PARAMETERS where G_PARAMETERS_ID = ' || v_G_Parameters_ID INTO v_Invoice_Rate;
    IF (v_Invoice_Rate < 0 OR v_Invoice_Rate > 100) THEN
      raise_application_error(v_ErrosNumber,'Invoice Rate cant be less than 1 or greater than 100');
    END IF;
    v_ErrosNumber := v_ErrosNumber - 1;
    EXECUTE immediate 'select Complete_Invoice_Rate from G_PARAMETERS where G_PARAMETERS_ID = ' || v_G_Parameters_ID INTO v_Complete_Invoice_Rate;
    IF (v_Complete_Invoice_Rate < 0 OR v_Complete_Invoice_Rate > 100) THEN
      raise_application_error(v_ErrosNumber,'Complete Invoice Rate cant be less than 1 or greater than 100');
    END IF;
  END IF;
  /*******************************************
  GENERATING LEADs
  ********************************************/
  -- W_LEAD_F loop
  FOR i IN 1.. noRows
  LOOP
    --Generating Lead
    -- Lead_ID
    lead_LEAD_ID := W_LEAD_F_SEQ.nextval;
    -- Generating Quote_Qty
    lead_QUOTE_QTY := ROUND ( TRUNC(dbms_random.value(v_Min_Order_Qty,v_Max_Order_Qty+1))/100 )* 100;
    -- Generating lead_SALES_CLASS_ID
    EXECUTE immediate 'select count(*) from W_SALES_CLASS_D' INTO v_NoRows_SalesClass;
    v_NoRows_SalesClass     := ROUND ( v_NoRows_SalesClass * v_Combination_rate / 100 ) ;
    IF ( v_NoRows_SalesClass < 1 ) THEN
      v_NoRows_SalesClass   := 1;
    END IF;
    lead_SALES_CLASS_ID := randomizeID('W_SALES_CLASS_D','SALES_CLASS_ID','',v_NoRows_SalesClass,v_NoRows_SalesClass);
    -- Gnerating Quote_Price
    -- Not using the  Unit_Of_Measure_Factor as V.8
    EXECUTE immediate 'select base_Price from W_SALES_CLASS_D where sales_Class_ID = ' || lead_SALES_CLASS_ID INTO lead_QUOTE_PRICE ;
    v_Vol_Qty_level  := TRUNC( lead_QUOTE_QTY / (v_Max_Order_Qty / v_Vol_Level ) ) ;
    lead_QUOTE_PRICE := lead_QUOTE_PRICE      * ( 1 - ( 0.01) * v_Vol_Qty_level ) ;
    -- Generating QUOTE_VALUE
    -- Not using the  Unit_Of_Measure_Factor
    -- Removed in V.8
    -- Generating LEAD_SUCCESS
    IF ( v_Success_Rate   >= 100) THEN
      v_Lead_Succ_Random  := 1;
    elsif ( v_Success_Rate < 100 ) THEN
      v_Lead_Succ_Random  := TRUNC ( dbms_random.value(0,101),2);
    END IF;
    IF ( v_Lead_Succ_Random   <= v_Success_Rate) THEN
      lead_LEAD_SUCCESS       := 'Y';
    elsif ( v_Lead_Succ_Random > v_Success_Rate ) THEN
      lead_LEAD_SUCCESS       :='N';
    END IF;
    -- Generating lead_JOB_ID
    -- leaves Null for nw and Will generate later on
    lead_JOB_ID := NULL;
    -- Generating lead_CREATED_DATE
    IF ( CHECKDATA('W_TIME_D','TIME_ID',startDate)    = true ) THEN
      v_StartDate                                    := startDate;
    elsif ( CHECKDATA('W_TIME_D','TIME_ID',startDate) = false ) THEN
      v_StartDate                                    := getAddedDays(startDate,1);
    END IF;
    IF ( CHECKDATA('W_TIME_D','TIME_ID',endDate)      = true ) THEN
      v_EndDate                                      := endDate;
    elsif ( CHECKDATA('W_TIME_D','TIME_ID',startDate) = false ) THEN
      v_EndDate                                      := getAddedDays(endDate,1);
    END IF;
    lead_CREATED_DATE := randomizeTimeID(v_StartDate,v_EndDate);
    -- Generating lead_CUST_ID
    lead_CUST_ID := randomizeID('W_CUSTOMER_D','CUST_KEY','',0,0);
    -- Generating lead_LOCATION_ID
    EXECUTE immediate 'select count(*) from W_LOCATION_D' INTO v_NoRows_Location;
    v_NoRows_Location     := ROUND ( v_NoRows_Location * v_Combination_rate / 100 ) ;
    IF ( v_NoRows_Location < 1 ) THEN
      v_NoRows_Location   := 1;
    END IF;
    lead_LOCATION_ID := randomizeID('W_LOCATION_D','LOCATION_ID','',v_NoRows_Location,v_NoRows_Location);
    -- Generating lead_SALES_AGENT_ID
    lead_SALES_AGENT_ID := randomizeID('W_SALES_AGENT_D','SALES_AGENT_ID','',0,0);
    /*******************************************
    GENERATING JOBs
    ********************************************/
    -- Generating W_JOB_F
    -- Only for lead_LEAD_SUCCESS with value of 'Y' and only of the fact_Select is less than or equal to 2
    IF ( (fact_Select < 3 AND lead_LEAD_SUCCESS = 'Y') OR change_Table_Enable = 1 ) THEN
      -- Generating Job_ID
      job_JOB_ID              := W_JOB_F_SEQ.nextval;
      IF ( change_Table_Enable = 0 ) THEN -- If the change_Table_Enable was 0 it will leave lead_JOB_ID to null
        lead_JOB_ID           := job_JOB_ID;
      END IF;
      --Generating Contract_Date  7 to 60 days after Lead Created Date
      job_CONTRACT_DATE := getAddedDays ( lead_CREATED_DATE, TRUNC(dbms_random.value(7,61)) );
      -- job_SALES_AGENT_ID
      job_SALES_AGENT_ID := lead_SALES_AGENT_ID;
      -- job_SALES_CLASS_ID
      job_SALES_CLASS_ID := lead_SALES_CLASS_ID;
      -- job_job_LOCATION_ID
      job_job_LOCATION_ID := lead_LOCATION_ID;
      -- job_CUST_ID_ORDERED_BY
      job_CUST_ID_ORDERED_BY := lead_CUST_ID;
      -- job_DATE_PROMISED , 14 to 31 after job_CONTRACT_DATE
      v_Job_Promised_Random := TRUNC(dbms_random.value(14,31)) ;
      job_DATE_PROMISED     := getAddedDays ( job_CONTRACT_DATE, v_Job_Promised_Random );
      -- job_DATE_SHIP_BY 2 to 7 days before job_DATE_PROMISED
      v_Job_Ship_Random := TRUNC(dbms_random.value(2,8));
      job_DATE_SHIP_BY  := getAddedDays ( job_CONTRACT_DATE, v_Job_Promised_Random - v_Job_Ship_Random );
      -- job_UNIT_OF_MEASURE_FACTOR
      -- Removed in V.8
      -- job_UNIT_PRICE
      job_UNIT_PRICE := lead_QUOTE_PRICE;
      -- job_QUANTITY_ORDERED
      job_QUANTITY_ORDERED := ROUND ( (lead_QUOTE_QTY * TRUNC(dbms_random.value(0.8,1.2),2) ) / 100 ) * 100 ;
      -- job_Quote_Qty
      job_Quote_Qty := lead_QUOTE_QTY ;
      -- job_QUOTATION_AMOUNT
      -- removed in version 8
      -- job_X_ORDERED_AMOUNT
      -- Removed in version 8
      -- job_NUMBER_OF_SUBJOBS
      v_Job_No_Subjobs_Random                                    := ROUND ( TRUNC(dbms_random.value(v_Min_Sub_Qty,v_Max_Sub_Qty+1)) / 100 ) * 100;
      IF ( MOD ( job_QUANTITY_ORDERED , v_Job_No_Subjobs_Random ) = 0 ) THEN
        job_NUMBER_OF_SUBJOBS                                    := job_QUANTITY_ORDERED / v_Job_No_Subjobs_Random;
      ELSE
        job_NUMBER_OF_SUBJOBS := ROUND( (job_QUANTITY_ORDERED / v_Job_No_Subjobs_Random) +0.5);
      END IF;
      /*******************************************
      GENERATING SUB JOBs
      ********************************************/
      v_Sub_JobQtyTot := job_QUANTITY_ORDERED ;
      IF ( fact_Select < 2 ) THEN
        -- Generating W_SUB_JOB_F
        v_Sub_Delay_Ran := TRUNC ( dbms_Random.value(0,100.01) , 2 );
        FOR j IN 1.. job_NUMBER_OF_SUBJOBS
        LOOP
          -- sub_SUB_JOB_ID
          sub_SUB_JOB_ID := W_SUB_JOB_F_SEQ.nextval;
          -- sub_QUANTITY_PRODUCED
          IF ( ( v_Sub_JobQtyTot - v_Job_No_Subjobs_Random )                                             >= 0 ) THEN
            sub_QUANTITY_PRODUCED                                                                        := v_Job_No_Subjobs_Random ;
            v_Sub_JobQtyTot                                                                              := v_Sub_JobQtyTot - sub_QUANTITY_PRODUCED;
          elsif ( ( v_Sub_JobQtyTot                                             - v_Job_No_Subjobs_Random < 0 ) ) THEN
            sub_QUANTITY_PRODUCED                                                                        := v_Sub_JobQtyTot;
          END IF;
          -- Cost Generating
          v_Sub_CostRate_Random := TRUNC (v_Min_Cost_Rate,v_Max_Cost_Rate+0.99) / 100 ;
          v_Sub_TotalCost       := sub_QUANTITY_PRODUCED                 * job_UNIT_PRICE * v_Sub_CostRate_Random;
          -- sub_COST_LABOR
          v_Sub_Cost_Random := TRUNC (dbms_random.value(0.25,0.76),2) ;
          sub_COST_LABOR    := v_Sub_TotalCost * v_Sub_Cost_Random;
          v_Sub_TotalCost   := v_Sub_TotalCost - sub_COST_LABOR;
          -- sub_MACHINE_TYPE_ID
          EXECUTE immediate 'select count(*) from W_MACHINE_TYPE_D ' INTO v_NoRows_Machine;
          v_NoRows_Machine     := ROUND ( v_NoRows_Machine * v_Combination_rate / 100 ) ;
          IF ( v_NoRows_Machine < 1 ) THEN
            v_NoRows_Machine   := 1;
          END IF;
          sub_MACHINE_TYPE_ID := randomizeID('W_MACHINE_TYPE_D','MACHINE_TYPE_ID','',v_NoRows_Machine,v_NoRows_Machine);
          -- sub_MACHINE_HOURS
          v_Sub_Cost_Random  := TRUNC (dbms_random.value(0.25,0.76),2) ;
          v_Sub_Cost_Machine := v_Sub_TotalCost * v_Sub_Cost_Random;
          v_Sub_TotalCost    := v_Sub_TotalCost - v_Sub_Cost_Machine;
          v_Sub_Mach_Rate    := 1;
          EXECUTE immediate 'select RATE_PER_HOUR from W_MACHINE_TYPE_D where MACHINE_TYPE_ID = ' || sub_MACHINE_TYPE_ID INTO v_Sub_Mach_Rate ;
          sub_MACHINE_HOURS := TRUNC( ( v_Sub_Cost_Machine / v_Sub_Mach_Rate ), 0 );
          -- sub_COST_MATERIAL
          v_Sub_Cost_Random := TRUNC (dbms_random.value(0.25,0.76),2) ;
          sub_COST_MATERIAL := v_Sub_TotalCost * v_Sub_Cost_Random;
          v_Sub_TotalCost   := v_Sub_TotalCost - sub_COST_MATERIAL;
          -- sub_COST_OVERHEAD
          sub_COST_OVERHEAD := v_Sub_TotalCost ;
          -- sub_SUB_JOB_AMOUNT
          sub_SUB_JOB_AMOUNT := sub_QUANTITY_PRODUCED * job_UNIT_PRICE;
          -- sub_JOB_ID
          sub_JOB_ID := job_JOB_ID;
          -- sub_SALES_CLASS_ID
          sub_SALES_CLASS_ID := job_SALES_CLASS_ID;
          -- sub_LOCATION_ID
          sub_LOCATION_ID := job_job_LOCATION_ID;
          -- sub_CUST_ID_ORDERED_BY
          sub_CUST_ID_ORDERED_BY := job_CUST_ID_ORDERED_BY;
          -- Delay Procedure
          EXECUTE immediate ' select delay_rate,delay_Days from G_Delay where Sales_Class_ID = ' ||sub_SALES_CLASS_ID || ' and location_ID = ' || sub_LOCATION_ID INTO v_Sub_Delay_Rate,v_Sub_Delay_Days;
          -- no Delay Case
          v_Sub_Duration_Random := TRUNC(dbms_random.value(1,v_Job_Promised_Random - v_Job_Ship_Random - 1) ); -- v_Sub_Duration_Random can be any number btween 1 to one day before job shipment
          -- sub_DATE_PROD_BEGIN
          sub_DATE_PROD_BEGIN := getAddedDays ( job_CONTRACT_DATE, TRUNC(dbms_random.value(1, v_Job_Promised_Random - v_Job_Ship_Random - v_Sub_Duration_Random ) ) ); -- sub_DATE_PROD_BEGIN can be any date btween 1 day after job_CONTRACT_DATE to v_Job_Promised_Random - v_Job_Ship_Random  - v_Sub_Duration_Random
          -- sub_DATE_PROD_END
          sub_DATE_PROD_END := getAddedDays (sub_DATE_PROD_BEGIN, v_Sub_Duration_Random ); -- sub_DATE_PROD_END will be sub_DATE_PROD_BEGIN + v_Sub_Duration_Random business days
          --ship_REQUESTED_SHIP_DATE := sub_DATE_PROD_END;
          ship_ACTUAL_SHIP_DATE := ship_REQUESTED_SHIP_DATE;
          IF ( v_Sub_Delay_Ran  <= v_Sub_Delay_Rate ) THEN
            -- sub_DATE_PROD_BEGIN
            v_Sub_Duration_Random := TRUNC(dbms_random.value(1, v_Job_Ship_Random                                 + v_Sub_Delay_Days ) );
            sub_DATE_PROD_BEGIN   := getAddedDays ( job_DATE_SHIP_BY, TRUNC(dbms_random.value(1,v_Job_Ship_Random + v_Sub_Delay_Days - v_Sub_Duration_Random ) ) ); -- sub_DATE_PROD_BEGIN can be any date btween 1 day after job_CONTRACT_DATE to v_Job_Promised_Random - v_Job_Ship_Random  - v_Sub_Duration_Random
            -- sub_DATE_PROD_END
            sub_DATE_PROD_END     := getAddedDays (sub_DATE_PROD_BEGIN, v_Sub_Duration_Random ); -- sub_DATE_PROD_END will be sub_DATE_PROD_BEGIN + v_Sub_Duration_Random business days
            ship_ACTUAL_SHIP_DATE := sub_DATE_PROD_END;
          END IF;
          -- Insert into W_SUB_JOB_F
          INSERT
          INTO W_SUB_JOB_F
            (
              SUB_JOB_ID,
              COST_LABOR,
              COST_MATERIAL,
              COST_OVERHEAD,
              MACHINE_HOURS,
              QUANTITY_PRODUCED,
              SUB_JOB_AMOUNT,
              JOB_ID,
              MACHINE_TYPE_ID,
              SALES_CLASS_ID,
              DATE_PROD_BEGIN,
              DATE_PROD_END,
              LOCATION_ID,
              CUST_ID_ORDERED_BY
            )
            VALUES
            (
              sub_SUB_JOB_ID ,
              sub_COST_LABOR ,
              sub_COST_MATERIAL ,
              sub_COST_OVERHEAD ,
              sub_MACHINE_HOURS ,
              sub_QUANTITY_PRODUCED ,
              sub_SUB_JOB_AMOUNT ,
              sub_JOB_ID ,
              sub_MACHINE_TYPE_ID ,
              sub_SALES_CLASS_ID ,
              sub_DATE_PROD_BEGIN ,
              sub_DATE_PROD_END ,
              sub_LOCATION_ID ,
              sub_CUST_ID_ORDERED_BY
            );
          /*******************************************
          GENERATING SHIPMENTs
          ********************************************/
          -- Generating W_JOB_SHIPMENT_F
          -- Shipments initial procedure; number of shipments, qty of the shipments
          -- Subjobs with less than 1000 quantity will use one shipment
          IF ( sub_QUANTITY_PRODUCED     < 1000 ) THEN
            v_Ship_NoShip_Ran           := 1 ;
            v_Ship_Qty                  := sub_QUANTITY_PRODUCED;
          ELSIF ( sub_QUANTITY_PRODUCED >= 1000 ) THEN
            v_Ship_NoShip_Ran           := TRUNC(dbms_random.value(v_Min_Num_Ship,v_Max_Num_Ship+ 1) );
            v_Ship_Qty                  := ROUND ( (sub_QUANTITY_PRODUCED                       / v_Ship_NoShip_Ran) /100 ) * 100;
          END IF;
          v_Ship_TotalQty := sub_QUANTITY_PRODUCED;
          -- ship_CUST_ID_SHIP_TO
          -- Random Customer Location using sub_CUST_ID_ORDERED_BY, calculated for each subjob above
          ship_CUST_ID_SHIP_TO := RANDOMIZEID('W_CUST_LOCATION_D','CUST_LOC_KEY','CUST_KEY = ' ||sub_CUST_ID_ORDERED_BY ,0,0);
          FOR k IN 1.. v_Ship_NoShip_Ran
          LOOP
            -- ship_JOB_SHIPMENT_ID
            ship_JOB_SHIPMENT_ID := W_JOB_SHIPMENT_F_SEQ.nextval;
            -- ship_ACTUAL_QUANTITY
            IF ( (v_Ship_TotalQty / v_Ship_Qty )                                  >= 1 ) THEN
              ship_ACTUAL_QUANTITY                                                := v_Ship_Qty ;
              v_Ship_TotalQty                                                     := v_Ship_TotalQty - ship_ACTUAL_QUANTITY;
            elsif ( (v_Ship_TotalQty                                / v_Ship_Qty ) < 1 ) THEN
              ship_ACTUAL_QUANTITY                                                := v_Ship_TotalQty;
            END IF;
            -- ship_REQUESTED_QUANTITY
            v_RequestQty_Ran          := TRUNC ( dbms_Random.value(0,101) ) ;
            IF ( v_RequestQty_Ran     <=70) THEN
              ship_REQUESTED_QUANTITY := ship_ACTUAL_QUANTITY;
            elsif ( v_RequestQty_Ran   > 70 AND v_RequestQty_Ran <= 100) THEN
              ship_REQUESTED_QUANTITY := ship_ACTUAL_QUANTITY * TRUNC ( dbms_Random.value(0.8,1.2),2 ) ;
            END IF;
            -- ship_BOXES , ,
            v_Ship_Box_Ran := ROUND ( TRUNC(dbms_random.value(v_Min_Box_Qty,v_Max_Box_Qty+ 1) )/100 )* 100;
            ship_BOXES     := TRUNC ( ship_ACTUAL_QUANTITY                               / v_Ship_Box_Ran ) ;
            -- ship_QUANTITY_PER_BOX
            IF ( ship_BOXES         >= 1 ) THEN
              ship_QUANTITY_PER_BOX := v_Ship_Box_Ran;
            elsif ( ship_BOXES       < 1 ) THEN
              ship_QUANTITY_PER_BOX := 0;
            END IF;
            -- ship_QUANTITY_PER_PARTIAL_BOX
            ship_QUANTITY_PER_PARTIAL_BOX := mod( ship_ACTUAL_QUANTITY , v_Ship_Box_Ran );
            -- ship_X_SHIPPED_AMOUNT
            ship_X_SHIPPED_AMOUNT := job_UNIT_PRICE * ship_ACTUAL_QUANTITY;
            -- ship_SUB_JOB_ID
            ship_SUB_JOB_ID := sub_SUB_JOB_ID;
            -- ship_SALES_CLASS_ID
            ship_SALES_CLASS_ID := sub_SALES_CLASS_ID;
            -- ship_LOCATION_ID
            ship_LOCATION_ID := sub_LOCATION_ID;
            -- ship_REQUESTED_SHIP_DATE
            ship_REQUESTED_SHIP_DATE := getaddeddays( sub_DATE_PROD_BEGIN , TRUNC ( dbms_Random.value(1,3) ) ) ;
            -- ship_ACTUAL_SHIP_DATE
            IF ( dbms_Random.value(0,101) <= 75 ) THEN
              ship_ACTUAL_SHIP_DATE       := ship_REQUESTED_SHIP_DATE;
            ELSE
              ship_ACTUAL_SHIP_DATE := getaddeddays( ship_REQUESTED_SHIP_DATE , TRUNC ( dbms_Random.value(1,4) ) ) ;
            END IF;
            -- ship_INVOICE_ID
            ship_INVOICE_ID := NULL;
            /*******************************************
            GENERATING INVOICEs
            ********************************************/
            -- Generating W_INVOICELINE_F
            v_InvoiceRate_Ran      := TRUNC( dbms_Random.value(0,100.01),2);
            IF ( v_InvoiceRate_Ran <= v_Invoice_Rate ) THEN
              --Invoice_INVOICE_ID
              Invoice_INVOICE_ID := W_INVOICELINE_F_SEQ.nextval;
              ship_INVOICE_ID    := Invoice_INVOICE_ID;
              --Invoice_QUANTITY_SHIPPED
              Invoice_QUANTITY_SHIPPED := ship_ACTUAL_QUANTITY;
              --Invoice_INVOICE_QUANTITY
              IF ( TRUNC( dbms_Random.value(1,100.01),2) <= v_Complete_Invoice_Rate ) THEN
                Invoice_INVOICE_QUANTITY                 := Invoice_QUANTITY_SHIPPED;
              ELSE
                Invoice_INVOICE_QUANTITY := Invoice_QUANTITY_SHIPPED * TRUNC( dbms_Random.value(0.7,0.91),2) ;
              END IF;
              --Invoice_INVOICE_AMOUNT
              Invoice_INVOICE_AMOUNT := ship_X_SHIPPED_AMOUNT;
              --Invoice_CUST_KEY
              Invoice_CUST_KEY := job_CUST_ID_ORDERED_BY;
              --Invoice_SALES_CLASS_ID
              Invoice_SALES_CLASS_ID := ship_SALES_CLASS_ID;
              --Invoice_INVOICE_SENT_DATE
              Invoice_INVOICE_SENT_DATE := getAddedDays(ship_ACTUAL_SHIP_DATE,TRUNC( dbms_Random.value(7,21) ) );
              --Invoice_INVOICE_DUE_DATE
              Invoice_INVOICE_DUE_DATE:= Invoice_INVOICE_SENT_DATE;
              --Invoice_SALES_AGENT_ID
              Invoice_SALES_AGENT_ID := job_SALES_AGENT_ID;
              --Invoice_LOCATION_ID
              Invoice_LOCATION_ID := ship_LOCATION_ID;
              --Insert Into W_INVOICELINE_F
              INSERT
              INTO W_INVOICELINE_F
                (
                  INVOICE_ID,
                  INVOICE_QUANTITY,
                  INVOICE_AMOUNT,
                  QUANTITY_SHIPPED,
                  SALES_CLASS_ID,
                  INVOICE_SENT_DATE,
                  INVOICE_DUE_DATE,
                  CUST_KEY,
                  SALES_AGENT_ID ,
                  LOCATION_ID
                )
                VALUES
                (
                  Invoice_INVOICE_ID ,
                  Invoice_INVOICE_QUANTITY ,
                  Invoice_INVOICE_AMOUNT ,
                  Invoice_QUANTITY_SHIPPED ,
                  Invoice_SALES_CLASS_ID ,
                  Invoice_INVOICE_SENT_DATE ,
                  Invoice_INVOICE_DUE_DATE ,
                  Invoice_CUST_KEY ,
                  Invoice_SALES_AGENT_ID ,
                  Invoice_LOCATION_ID
                );
            END IF;
            -- Insert statment W_JOB_SHIPMENT_F
            INSERT
            INTO W_JOB_SHIPMENT_F
              (
                JOB_SHIPMENT_ID,
                ACTUAL_QUANTITY,
                REQUESTED_QUANTITY,
                BOXES,
                QUANTITY_PER_BOX,
                QUANTITY_PER_PARTIAL_BOX ,
                SHIPPED_AMOUNT ,
                SUB_JOB_ID,
                SALES_CLASS_ID,
                LOCATION_ID,
                CUST_ID_SHIP_TO,
                ACTUAL_SHIP_DATE,
                REQUESTED_SHIP_DATE ,
                INVOICE_ID
              )
              VALUES
              (
                ship_JOB_SHIPMENT_ID ,
                ship_ACTUAL_QUANTITY ,
                ship_REQUESTED_QUANTITY ,
                ship_BOXES ,
                ship_QUANTITY_PER_BOX ,
                ship_QUANTITY_PER_PARTIAL_BOX ,
                ship_X_SHIPPED_AMOUNT ,
                ship_SUB_JOB_ID ,
                ship_SALES_CLASS_ID ,
                ship_LOCATION_ID ,
                ship_CUST_ID_SHIP_TO ,
                ship_ACTUAL_SHIP_DATE ,
                ship_REQUESTED_SHIP_DATE ,
                ship_INVOICE_ID
              );
          END LOOP;
        END LOOP;
      END IF;
      -- Insert Statment for W_JOB_F Or W_Job_Change_Data
      IF ( change_Table_Enable = 0 ) THEN -- if change_Table_Enable = 0 Insert into W_JOB_F
        INSERT
        INTO W_JOB_F
          (
            job_ID ,
            number_Of_SubJobs ,
            unit_Price ,
            quantity_Ordered ,
            contract_Date ,
            sales_Agent_ID ,
            sales_Class_ID ,
            location_ID ,
            cust_ID_Ordered_By ,
            date_Promised ,
            date_Ship_By,
            QUOTE_QTY
          )
          VALUES
          (
            job_JOB_ID ,
            job_NUMBER_OF_SUBJOBS ,
            job_UNIT_PRICE ,
            job_QUANTITY_ORDERED ,
            job_CONTRACT_DATE,
            job_SALES_AGENT_ID ,
            job_SALES_CLASS_ID ,
            job_job_LOCATION_ID ,
            job_CUST_ID_ORDERED_BY ,
            job_DATE_PROMISED ,
            job_DATE_SHIP_BY ,
            job_Quote_Qty
          ); 
      elsif ( change_Table_Enable = 1 ) THEN -- if change_Table_Enable = 1 Insert W_Job_Change_Data
      
    
       v_Change_CONTRACT_DATE := to_char (  SUBSTR(to_char(job_CONTRACT_DATE),1,4) || '-' || SUBSTR(to_char(job_CONTRACT_DATE),5,2) || '-' || SUBSTR(to_char(job_CONTRACT_DATE),7,2) ) ;
       v_Change_DATE_PROMISED := to_char ( SUBSTR(to_char(job_DATE_PROMISED),1,4) || '-' || SUBSTR(to_char(job_DATE_PROMISED),5,2) || '-' || SUBSTR(to_char(job_DATE_PROMISED),7,2) );
       v_Change_DATE_SHIP_BY := to_char ( SUBSTR(to_char(job_DATE_SHIP_BY),1,4) || '-' || SUBSTR(to_char(job_DATE_SHIP_BY),5,2) || '-' || SUBSTR(to_char(job_DATE_SHIP_BY),7,2) );
       
        INSERT
        INTO W_Job_Change_Data
          (
            Change_ID ,
            CONTRACT_DATE ,
            SALES_AGENT_ID ,
            SALES_CLASS_ID ,
            LOCATION_ID ,
            CUST_ID_ORDERED_BY ,
            DATE_PROMISED ,
            DATE_SHIP_BY ,
            NUMBER_OF_SUBJOBS ,
            UNIT_PRICE ,
            QUANTITY_ORDERED,
            QUOTE_QTY ,
            LEAD_ID
          )
          VALUES
          (
            W_JOB_CHANGE_DATA_SEQ.Nextval ,
            v_Change_CONTRACT_DATE ,
            job_SALES_AGENT_ID ,
            job_SALES_CLASS_ID ,
            job_job_LOCATION_ID ,
            job_CUST_ID_ORDERED_BY ,
            v_Change_DATE_PROMISED ,
            v_Change_DATE_SHIP_BY ,
            job_NUMBER_OF_SUBJOBS ,
            job_UNIT_PRICE ,
            job_QUANTITY_ORDERED ,
            job_Quote_Qty ,
            lead_LEAD_ID
          );
      END IF;
    END IF;
    -- Insert Statment for W_Lead_F
    IF ( change_Table_Enable = 1 ) THEN
      lead_LEAD_SUCCESS     := 'N';
    END IF; -- if change_Table_Enable = 1 then set lead_LEAD_SUCCESS to 'N'
    INSERT
    INTO W_LEAD_F
      (
        LEAD_ID ,
        QUOTE_QTY ,
        QUOTE_PRICE ,
        LEAD_SUCCESS ,
        JOB_ID ,
        CREATED_DATE ,
        CUST_ID ,
        LOCATION_ID ,
        SALES_AGENT_ID ,
        SALES_CLASS_ID
      )
      VALUES
      (
        lead_LEAD_ID ,
        lead_QUOTE_QTY ,
        lead_QUOTE_PRICE ,
        lead_LEAD_SUCCESS ,
        lead_JOB_ID ,
        lead_CREATED_DATE ,
        lead_CUST_ID ,
        lead_LOCATION_ID ,
        lead_SALES_AGENT_ID ,
        lead_SALES_CLASS_ID
      );
  END LOOP;
  IF ( change_Table_Enable = 0 ) THEN
    -- Update Invoice_INVOICE_SENT_DATE and Invoice_INVOICE_DUE_DATE
    v_Invoice_CustKey :=0;
    EXECUTE immediate 'select count(*) from W_CUSTOMER_D' INTO v_Invoice_CustNoRow;
    FOR i IN 1.. v_Invoice_CustNoRow
    LOOP
      EXECUTE immediate ' select min(cust_key) from W_CUSTOMER_D where cust_key > ' || v_Invoice_CustKey INTO v_Invoice_CustKey;
      EXECUTE immediate ' select count(*) from W_INVOICELINE_F where cust_Key = ' || v_Invoice_CustKey INTO v_Invoice_CustInvoiceLine;
      v_Invoice_InvoiceID           := 0;
      v_Invoice_BillingCycleRan     := TRUNC ( dbms_Random.value(1,19) ) ;
      IF ( v_Invoice_CustInvoiceLine > 0 ) THEN
        FOR j IN 1.. v_Invoice_CustInvoiceLine
        LOOP
          EXECUTE immediate ' select min(invoice_ID) from W_INVOICELINE_F where invoice_ID > '|| v_Invoice_InvoiceID ||' and cust_Key = ' || v_Invoice_CustKey INTO v_Invoice_InvoiceID;
          EXECUTE immediate 'select INVOICE_SENT_DATE from W_INVOICELINE_F where INVOICE_ID = ' || v_Invoice_InvoiceID INTO Invoice_INVOICE_SENT_DATE;
          EXECUTE immediate ' select min(time_ID) from W_TIME_D where TIME_YEAR = ' || to_number(SUBSTR(Invoice_INVOICE_SENT_DATE,1,4)) || ' and TIME_MONTH = ' || to_number(SUBSTR(Invoice_INVOICE_SENT_DATE,5,2)) INTO v_Invoice_FirstDayOfMonth;
          v_Invoice_CycActualDate        := GETADDEDDAYS(v_Invoice_FirstDayOfMonth,v_Invoice_BillingCycleRan);
          IF ( Invoice_INVOICE_SENT_DATE <= v_Invoice_CycActualDate ) THEN
            Invoice_INVOICE_SENT_DATE    := v_Invoice_CycActualDate;
          ELSE
            EXECUTE immediate ' select max(time_ID) from W_TIME_D where TIME_YEAR = ' || to_number(SUBSTR(Invoice_INVOICE_SENT_DATE,1,4)) || ' and TIME_MONTH = ' || to_number(SUBSTR(Invoice_INVOICE_SENT_DATE,5,2)) INTO v_Invoice_LastDayOfNextMonth;
            Invoice_INVOICE_SENT_DATE := GETADDEDDAYS(v_Invoice_LastDayOfNextMonth,v_Invoice_BillingCycleRan+1);
          END IF;
          EXECUTE immediate 'select terms_CODE from W_CUSTOMER_D where CUST_KEY = ' || v_Invoice_CustKey INTO v_Invoice_CustTerms;
          IF ( v_Invoice_CustTerms    = 'Net20' ) THEN
            Invoice_INVOICE_DUE_DATE := getAddedDays(Invoice_INVOICE_SENT_DATE,20);
          elsif ( v_Invoice_CustTerms = 'Net30' ) THEN
            Invoice_INVOICE_DUE_DATE := getAddedDays(Invoice_INVOICE_SENT_DATE,30);
          elsif ( v_Invoice_CustTerms = 'Net60' ) THEN
            Invoice_INVOICE_DUE_DATE := getAddedDays(Invoice_INVOICE_SENT_DATE,60);
          elsif ( v_Invoice_CustTerms = 'COD' ) THEN
            Invoice_INVOICE_DUE_DATE := getAddedDays(Invoice_INVOICE_SENT_DATE,1);
          ELSE
            Invoice_INVOICE_DUE_DATE := getAddedDays(Invoice_INVOICE_SENT_DATE,1);
          END IF;
          -- update statement
          EXECUTE immediate '    
UPDATE W_INVOICELINE_F    
SET  INVOICE_SENT_DATE = ' || Invoice_INVOICE_SENT_DATE || ' ,   INVOICE_DUE_DATE =  ' || Invoice_INVOICE_DUE_DATE || ' where INVOICE_ID = ' || v_Invoice_InvoiceID;
        END LOOP;
      END IF;
    END LOOP;
  END IF;
END;