-- PLSQL

DECLARE
 rp_dc_reporting_period_id number := 0; -- странная подсветка для rp_dc_reporting_period_id number :
 rp_dc_period_name_id      number := 0; -- странная подсветка для rp_dc_period_name_id      number :
 end_date                  number;
BEGIN
  DELETE FROM RP_RL_PERIOD_NAME WHERE RP_RL_PERIOD_NAME.ID_REPORTING_PERIOD= RP_RL_PERIOD_NAME.ID_REPORTING_PERIOD;
  DELETE FROM RP_DC_PERIOD_NAME WHERE RP_DC_PERIOD_NAME.ID = RP_DC_PERIOD_NAME.ID;
  DELETE FROM rp_dc_reporting_period WHERE rp_dc_reporting_period.id= rp_dc_reporting_period.id;
  COMMIT;
  
  -- Yearly
  rp_dc_reporting_period_id := rp_dc_reporting_period_id + 1; -- странная подсветка для rp_dc_reporting_period_id :
  INSERT INTO rp_dc_reporting_period (ID, PERIOD, BEGIN_DEFAULT, END_DEFAULT) VALUES (rp_dc_reporting_period_id,'YEARLY',0,0);
  rp_dc_period_name_id := rp_dc_period_name_id +1; -- странная подсветка для  rp_dc_period_name_id :
  end_date := date_to_second('yyyy/MM/dd','1971/01/01',0) - date_to_second('yyyy/MM/dd','1970/01/01',0); -- странная подсветка для -- странная подсветка для  
  INSERT INTO rp_dc_period_name (ID, END_DATE, NAME) VALUES (rp_dc_period_name_id, end_date, 'YEAR');
  
  
END;
