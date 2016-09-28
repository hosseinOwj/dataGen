
create or replace PROCEDURE G_Delay_G(
    default_Delay_Rate      NUMBER DEFAULT 2,
    default_Delay_Days      INTEGER DEFAULT 2,
    exception_Delay_Rate    NUMBER DEFAULT 10,
    exception_Delay_Days    INTEGER DEFAULT 10,
    exception_Usage_Rate    NUMBER DEFAULT 20,
    default_Forecast_acc    NUMBER DEFAULT 10,
    exception_Forecast_acc  NUMBER DEFAULT 25,
    exception_Forecast_rate NUMBER DEFAULT 10,
    default_Budget_acc number default 10,
    exception_Budget_acc number default 25,
    exception_Budget_rate NUMBER DEFAULT 10)
IS
  -- Table Variables prefix Delay_
  Delay_SALES_CLASS_ID G_DELAY.SALES_CLASS_ID%TYPE;
  Delay_LOCATION_ID G_DELAY.LOCATION_ID%TYPE;
  Delay_DELAY_RATE G_DELAY.DELAY_RATE%TYPE;
  Delay_DELAY_DAYS G_DELAY.DELAY_DAYS%TYPE;
  Delay_SALES_FORECAST_ACC G_DELAY.SALES_FORECAST_ACC%TYPE;
  Delay_COST_BUDGET_ACC G_DELAY.COST_BUDGET_ACC%TYPE;
  -- Procedure Variables perfix v_
  v_ErrosNumber       INTEGER;
  v_NoRows_SalesClass INTEGER;
  v_NoRows_Location   INTEGER;
  v_Exception_Ran     NUMBER(5,2);
BEGIN
  /*******************************************
  Inital process
  ********************************************/
  -- Error sequence
  v_ErrosNumber := -20010; -- Error Number starts with -20010 each error will mines this number by one
  EXECUTE immediate 'delete from G_delay';
  EXECUTE immediate 'select count(*) from W_SALES_CLASS_D' INTO v_NoRows_SalesClass;
  EXECUTE immediate 'select count(*) from W_LOCATION_D' INTO v_NoRows_Location;
  /*******************************************
  Verify Input
  ********************************************/
  v_ErrosNumber          := v_ErrosNumber - 1;
  IF ( default_Delay_Rate > 66 OR default_Delay_Rate < 0 ) THEN
    raise_application_error(v_ErrosNumber,'default_Delay_Rate out of range ( 0 - 66 )');
  END IF;
  v_ErrosNumber          := v_ErrosNumber - 1;
  IF ( default_Delay_Days > 66 OR default_Delay_Days < 0 ) THEN
    raise_application_error(v_ErrosNumber,'default_Delay_Date out of range ( 0 - 66 )');
  END IF;
  v_ErrosNumber            := v_ErrosNumber - 1;
  IF ( exception_Delay_Rate > 66 OR exception_Delay_Rate < 0 ) THEN
    raise_application_error(v_ErrosNumber,'exception_Delay_Rate out of range ( 0 - 66 )');
  END IF;
  v_ErrosNumber            := v_ErrosNumber - 1;
  IF ( exception_Delay_Days > 66 OR exception_Delay_Days < 0 ) THEN
    raise_application_error(v_ErrosNumber,'exception_Delay_Days out of range ( 0 - 66 )');
  END IF;
  v_ErrosNumber            := v_ErrosNumber - 1;
  IF ( exception_Usage_Rate > 100 OR exception_Usage_Rate < 0 ) THEN
    raise_application_error(v_ErrosNumber,'exception_Usage_Rate out of range ( 0 - 100 )');
  END IF;
  /*******************************************
  GENERATING DElays
  ********************************************/
  -- Sales_Class_ID loop
  Delay_SALES_CLASS_ID := 0;
  FOR i IN 1.. v_NoRows_SalesClass
  LOOP
    -- Delay_SALES_CLASS_ID
    EXECUTE immediate 'select min(sales_class_ID) from W_SALES_CLASS_D where sales_class_ID > ' || Delay_SALES_CLASS_ID INTO Delay_SALES_CLASS_ID ;
    -- Location_ID class
    Delay_LOCATION_ID := 0;
    FOR j IN 1.. v_NoRows_Location
    LOOP
      -- Delay_LOCATION_ID
      EXECUTE immediate 'select min(location_ID) from W_LOCATION_D where location_ID > ' || Delay_LOCATION_ID INTO Delay_LOCATION_ID;
      v_Exception_Ran := TRUNC ( dbms_Random.value(0,100.01) , 2 ) ;
      --default case
      IF ( v_Exception_Ran     > exception_Usage_Rate ) THEN
        Delay_DELAY_RATE      := TRUNC ( dbms_Random.value( (default_Delay_Rate - default_Delay_Rate/2 ) , ( default_Delay_Rate + default_Delay_Rate/2 ) + 0.01 ) , 2 );
        Delay_DELAY_DAYS      := TRUNC ( dbms_Random.value( (default_Delay_Days - default_Delay_Days/2) , ( default_Delay_Days + default_Delay_Days/2 ) + 1 ) );
      ELSif ( v_Exception_Ran <= exception_Usage_Rate ) THEN
        Delay_DELAY_RATE      := TRUNC ( dbms_Random.value( (exception_Delay_Rate - exception_Delay_Rate/2) , ( exception_Delay_Rate + exception_Delay_Rate/2 ) + 0.01 ) , 2 );
        Delay_DELAY_DAYS      := TRUNC ( dbms_Random.value( (exception_Delay_Days - exception_Delay_Days/2) , ( exception_Delay_Days + exception_Delay_Days/2 ) + 1 ) );
      END IF;
      --
      --Delay_SALES_FORECAST_ACC
      v_Exception_Ran            := TRUNC ( dbms_Random.value(0,100.01) , 2 ) ;
      IF ( v_Exception_Ran       <= exception_Forecast_rate ) THEN
        Delay_SALES_FORECAST_ACC := TRUNC ( dbms_Random.value( (100 - exception_Forecast_acc ), ( 100 + exception_Forecast_acc) + 0.01 ) , 2 );
      ELSE
        Delay_SALES_FORECAST_ACC := TRUNC ( dbms_Random.value( (100 - default_Forecast_acc ), ( 100 + default_Forecast_acc) + 0.01 ) , 2 );
      END IF;
      
      --Delay_COST_BUDGET_ACC
      v_Exception_Ran            := TRUNC ( dbms_Random.value(0,100.01) , 2 ) ;
      IF ( v_Exception_Ran       <= exception_Budget_rate ) THEN
        Delay_COST_BUDGET_ACC := TRUNC ( dbms_Random.value( (100 - exception_Budget_acc ), ( 100 + exception_Budget_acc) + 0.01 ) , 2 );
      ELSE
        Delay_COST_BUDGET_ACC := TRUNC ( dbms_Random.value( (100 - default_Budget_acc ), ( 100 + default_Budget_acc) + 0.01 ) , 2 );
      END IF;
      
      -- insert statement
      INSERT
      INTO G_Delay
        (
          SALES_CLASS_ID ,
          LOCATION_ID ,
          DELAY_RATE ,
          DELAY_DAYS,
          SALES_FORECAST_ACC,
          COST_BUDGET_ACC
        )
        VALUES
        (
          Delay_SALES_CLASS_ID ,
          Delay_LOCATION_ID ,
          Delay_DELAY_RATE ,
          Delay_DELAY_DAYS,
          Delay_SALES_FORECAST_ACC,
          Delay_COST_BUDGET_ACC
          
        );
    END LOOP;
  END LOOP;
END;