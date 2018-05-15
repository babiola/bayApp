CREATE OR REPLACE PACKAGE BODY PORTALUSER.pkg_cdr_query AS
/*
test package created by OD... 150715
*/
PROCEDURE prc_get_result (v_msisdn varchar2, p_start_date varchar2, p_end_date varchar2, p_result OUT sys_refcursor) AS
    p_start_dt date := to_date(p_start_date, 'YYYY-MM-DD');
    p_end_dt date := to_date(p_end_date, 'YYYY-MM-DD');
    p_msisdn varchar2(100);
    BEGIN
    --check msisdn
        IF SUBSTR(v_msisdn, 1, 3) = '234' THEN
            p_msisdn := v_msisdn;
        ELSE
            p_msisdn := '234' || v_msisdn;
        END IF;
       -- INSERT INTO ST_END_TABLE(P_START_DATE,E_END_DATE)VALUES( p_partition_date, p_partition_date);
        --COMMIT;
        
        OPEN p_result FOR 
            SELECT /*+ index(a CALINGPARTYNUMB_LOC_DATA_IDX) */
            TO_CHAR(NULL) "charged_type",
            accounttype1 ||
                CASE WHEN accounttype2 <> 0 THEN '-'||accounttype2 ELSE '' END ||
                CASE WHEN accounttype3 <> 0 THEN '-'||accounttype3 ELSE '' END ||
                CASE WHEN accounttype4 <> 0 THEN '-'||accounttype4 ELSE '' END ||
                CASE WHEN accounttype5 <> 0 THEN '-'||accounttype5 ELSE '' END
            account,
            case
               -- when serviceflow = 1 then '001'
               -- when serviceflow = 2 then '002'
               -- when callforwardindicator <>0 then '029'
               -- when serviceflow = 2 and accessprefix = 268 then '005'
                when homezoneid = 333000 then '004'
                --when callinggroupno = 930 and calledgroupno > 0 then '008'
                when productid = 5025553 then '013'
                when accounttype1 = 4000 then '018'
                when productid in (122189,122589,122690,122789) then '007'
            end call_type,
            TO_CHAR(NULL) "called_subscriber",
            to_char(chargingtime, 'dd/mm/yyyy') date_,
            to_char(chargingtime, 'hh24:mi:ss') time,
            TO_number(0) "actual_duration" ,
            to_char(chargeduration) duration,
            subcosid tariff_group,
            ' ' tariff_group_desc,
            cast ('001 Normal rate calls' as varchar2(100)) tariff_class,
            ((nvl(CURRENTACCTAMOUNT1, 0) + nvl(CURRENTACCTAMOUNT2, 0)
            + nvl(CURRENTACCTAMOUNT3, 0) + nvl(CURRENTACCTAMOUNT4, 0)
            + nvl(CURRENTACCTAMOUNT5, 0) + nvl(CURRENTACCTAMOUNT6, 0)
            + nvl(CURRENTACCTAMOUNT7, 0) + nvl(CURRENTACCTAMOUNT8, 0)
            + nvl(CURRENTACCTAMOUNT9, 0) + nvl(CURRENTACCTAMOUNT10, 0))
            + (nvl(CHARGEAMOUNT1, 0) + nvl(CHARGEAMOUNT2, 0)
            + nvl(CHARGEAMOUNT3, 0) + nvl(CHARGEAMOUNT4, 0)
            + nvl(CHARGEAMOUNT5, 0) + nvl(CHARGEAMOUNT6, 0)
            + nvl(CHARGEAMOUNT7, 0) + nvl(CHARGEAMOUNT8, 0)
            + nvl(CHARGEAMOUNT9, 0) + nvl(CHARGEAMOUNT10, 0))) /100 gross_amount,
            to_char((nvl(chargefrompostpaid, 0)+nvl(chargefromprepaid, 0))/100
            || ' - BAL(' || (nvl(PREPAIDBALANCE, 0)+nvl(POSTPAIDBALANCE, 0))/100 || ')') bill_amount, 
            TO_CHAR((nvl(chargefrompostpaid, 0)+nvl(chargefromprepaid, 0))/100) || ' - DATA USAGE ' bill_text
            FROM ods.rated_data_cdr a
            WHERE callingpartynumber = p_msisdn
              and chargingtime between p_start_dt and p_end_dt + 1 - 1/24/3600
              union all
SELECT /*+ index(a CHARGGPARTYNUMB_LOC_MON_IDX) */
            TO_CHAR(NULL) charged_type,
            accounttype1 ||
                CASE WHEN accounttype2 <> 0 THEN '-'||accounttype2 ELSE '' END ||
                CASE WHEN accounttype3 <> 0 THEN '-'||accounttype3 ELSE '' END ||
                CASE WHEN accounttype4 <> 0 THEN '-'||accounttype4 ELSE '' END ||
                CASE WHEN accounttype5 <> 0 THEN '-'||accounttype5 ELSE '' END
            account,
            case
               -- when serviceflow = 1 then '001'
                --when serviceflow = 2 then '002'
                --when callforwardindicator <>0 then '029'
                --when serviceflow = 2 and accessprefix = 268 then '005'
                --when homezoneid = 333000 then '004'
                --when callinggroupno = 930 and calledgroupno > 0 then '008'
                when productid = 5025553 then '013'
                when accounttype1 = 4000 then '018'
                when productid in (122189,122589,122690,122789) then '007'
            end call_type,
            to_char(0) called_subscriber,
            to_char(timestamp, 'dd/mm/yyyy') date_,
            to_char(timestamp, 'hh24:mi:ss') time,
            to_number(0) actual_duration,
            to_char(0) duration,
            subcosid tariff_group,
            ' ' tariff_group_desc,
            cast ('001 Normal rate calls' as varchar2(100)) tariff_class,
            ((nvl(CURRENTACCTAMOUNT1, 0) + nvl(CURRENTACCTAMOUNT2, 0)
            + nvl(CURRENTACCTAMOUNT3, 0) + nvl(CURRENTACCTAMOUNT4, 0)
            + nvl(CURRENTACCTAMOUNT5, 0) + nvl(CURRENTACCTAMOUNT6, 0)
            + nvl(CURRENTACCTAMOUNT7, 0) + nvl(CURRENTACCTAMOUNT8, 0)
            + nvl(CURRENTACCTAMOUNT9, 0) + nvl(CURRENTACCTAMOUNT10, 0))
            + (nvl(CHARGEAMOUNT1, 0) + nvl(CHARGEAMOUNT2, 0)
            + nvl(CHARGEAMOUNT3, 0) + nvl(CHARGEAMOUNT4, 0)
            + nvl(CHARGEAMOUNT5, 0) + nvl(CHARGEAMOUNT6, 0)
            + nvl(CHARGEAMOUNT7, 0) + nvl(CHARGEAMOUNT8, 0)
            + nvl(CHARGEAMOUNT9, 0) + nvl(CHARGEAMOUNT10, 0))) /100 gross_amount,
            to_char((nvl(DEBIT_FROM_POSTPAID, 0)+nvl(DEDUCTFROMPREPAID, 0))/100
            || ' - BAL(' || (nvl(PREPAIDBALANCE, 0)+nvl(POSTPAIDBALANCE, 0))/100 || ')') bill_amount, 
            TO_CHAR((nvl(DEBIT_FROM_POSTPAID, 0)+nvl(DEDUCTFROMPREPAID, 0))/100) || ' - BUNDLE USAGE ' bill_text
            FROM ods.rated_mon_cdr_cutover a
             WHERE chargingpartynumber = p_msisdn
                     and timestamp between p_start_dt and p_end_dt + 1 - 1/24/3600
            UNION ALL
             SELECT /*+ index(a CALINGPARTYNUMB_LOC_SMS_IDX) */
           TO_CHAR(NULL) charged_type,
            accounttype1 ||
                CASE WHEN accounttype2 <> 0 THEN '-'||accounttype2 ELSE '' END ||
                CASE WHEN accounttype3 <> 0 THEN '-'||accounttype3 ELSE '' END ||
                CASE WHEN accounttype4 <> 0 THEN '-'||accounttype4 ELSE '' END ||
                CASE WHEN accounttype5 <> 0 THEN '-'||accounttype5 ELSE '' END 
            account,
            case
                when serviceflow = 1 then '001'
                when serviceflow = 2 then '002'
                when callforwardindicator <>0 then '029'
                --when serviceflow = 2 and accessprefix = 268 then '005'
                when homezoneid = 333000 then '004'
                when callinggroupno = 930 and calledgroupno > 0 then '008'
                when productid = 5025553 then '013'
                when accounttype1 = 4000 then '018'
                when productid in (122189,122589,122690,122789) then '007'
            end call_type,
            calledpartynumber called_subscriber,
            to_char(chargingtime, 'dd/mm/yyyy') date_,
            to_char(chargingtime, 'hh24:mi:ss') time,
            to_number(0) actual_duration,
            to_char(0) duration,
            subcosid tariff_group,
            ' ' tariff_group_desc,
            cast ('001 Normal rate calls' as varchar2(100)) tariff_class,
            ((nvl(CURRENTACCTAMOUNT1, 0) + nvl(CURRENTACCTAMOUNT2, 0) 
            + nvl(CURRENTACCTAMOUNT3, 0) + nvl(CURRENTACCTAMOUNT4, 0) 
            + nvl(CURRENTACCTAMOUNT5, 0) + nvl(CURRENTACCTAMOUNT6, 0)
            + nvl(CURRENTACCTAMOUNT7, 0) + nvl(CURRENTACCTAMOUNT8, 0) 
            + nvl(CURRENTACCTAMOUNT9, 0) + nvl(CURRENTACCTAMOUNT10, 0)) 
            + (nvl(CHARGEAMOUNT1, 0) + nvl(CHARGEAMOUNT2, 0) 
            + nvl(CHARGEAMOUNT3, 0) + nvl(CHARGEAMOUNT4, 0) 
            + nvl(CHARGEAMOUNT5, 0) + nvl(CHARGEAMOUNT6, 0) 
            + nvl(CHARGEAMOUNT7, 0) + nvl(CHARGEAMOUNT8, 0) 
            + nvl(CHARGEAMOUNT9, 0) + nvl(CHARGEAMOUNT10, 0))) /100 gross_amount,
            to_char((nvl(DEBIT_FROM_POSTPAID, 0)+nvl(CHARGEFROMPREPAID, 0))/100 
            || ' - BAL(' || (nvl(PREPAIDBALANCE, 0)+nvl(POSTPAIDBALANCE, 0))/100 || ')') bill_amount,  
            TO_CHAR((nvl(DEBIT_FROM_POSTPAID, 0)+nvl(CHARGEFROMPREPAID, 0))/100) || ' - SMS ' bill_text
            FROM ods.rated_sms_cdr_cutover a
			 WHERE callingpartynumber = p_msisdn
            AND chargingtime between p_start_dt and p_end_dt + 1 - 1/24/3600
            UNION ALL
                    SELECT /*+ index(a CALINGPARTYNUMB_LOC_COM_IDX) */ 
            TO_CHAR(NULL) charged_type,
            accounttype1 ||
                CASE WHEN accounttype2 <> 0 THEN '-'||accounttype2 ELSE '' END ||
                CASE WHEN accounttype3 <> 0 THEN '-'||accounttype3 ELSE '' END ||
                CASE WHEN accounttype4 <> 0 THEN '-'||accounttype4 ELSE '' END ||
                CASE WHEN accounttype5 <> 0 THEN '-'||accounttype5 ELSE '' END 
            account,
            case
               -- when serviceflow = 1 then '001'
               -- when serviceflow = 2 then '002'
               -- when callforwardindicator <>0 then '029'
                --when serviceflow = 2 and accessprefix = 268 then '005'
               -- when homezoneid = 333000 then '004'
              --  when callinggroupno = 930 and calledgroupno > 0 then '008'
               -- when productid = 5025553 then '013'
                when accounttype1 = 4000 then '018'
               -- when productid in (122189,122589,122690,122789) then '007'
            end call_type,
            to_char(0) called_subscriber,
            to_char(chargingtime, 'dd/mm/yyyy') date_,
            to_char(chargingtime, 'hh24:mi:ss') time,
            to_number(0) actual_duration,
            to_char(0) duration,
            subcosid tariff_group,
            ' ' tariff_group_desc,
            cast ('001 Normal rate calls' as varchar2(100)) tariff_class,
            ((nvl(CURRENTACCTAMOUNT1, 0) + nvl(CURRENTACCTAMOUNT2, 0) 
            + nvl(CURRENTACCTAMOUNT3, 0) + nvl(CURRENTACCTAMOUNT4, 0) 
            + nvl(CURRENTACCTAMOUNT5, 0) + nvl(CURRENTACCTAMOUNT6, 0)
            + nvl(CURRENTACCTAMOUNT7, 0) + nvl(CURRENTACCTAMOUNT8, 0) 
            + nvl(CURRENTACCTAMOUNT9, 0) + nvl(CURRENTACCTAMOUNT10, 0)) 
            + (nvl(CHARGEAMOUNT1, 0) + nvl(CHARGEAMOUNT2, 0) 
            + nvl(CHARGEAMOUNT3, 0) + nvl(CHARGEAMOUNT4, 0) 
            + nvl(CHARGEAMOUNT5, 0) + nvl(CHARGEAMOUNT6, 0) 
            + nvl(CHARGEAMOUNT7, 0) + nvl(CHARGEAMOUNT8, 0) 
            + nvl(CHARGEAMOUNT9, 0) + nvl(CHARGEAMOUNT10, 0))) /100 gross_amount,
            to_char((nvl(DEBIT_FROM_POSTPAID, 0)+nvl(CHARGEFROMPREPAID, 0))/100 
            || ' - BAL(' || (nvl(PREPAIDBALANCE, 0)+nvl(POSTPAIDBALANCE, 0))/100 || ')') bill_amount,  
            TO_CHAR((nvl(DEBIT_FROM_POSTPAID, 0)+nvl(CHARGEFROMPREPAID, 0))/100) || CDRSERVICENAME bill_text
            FROM ods.rated_com_cdr_cutover a
            WHERE callingpartynumber = p_msisdn
            AND chargingtime between p_start_dt and p_end_dt + 1 - 1/24/3600
           UNION ALL 
                   SELECT /*+ index(a CHARGGPARTYNUMB_LOC_MGR_IDX) */ 
           TO_CHAR(NULL) charged_type,
            accounttype1 ||
                CASE WHEN accounttype2 <> 0 THEN '-'||accounttype2 ELSE '' END ||
                CASE WHEN accounttype3 <> 0 THEN '-'||accounttype3 ELSE '' END ||
                CASE WHEN accounttype4 <> 0 THEN '-'||accounttype4 ELSE '' END ||
                CASE WHEN accounttype5 <> 0 THEN '-'||accounttype5 ELSE '' END 
            account,
            case
               -- when serviceflow = 1 then '001'
               -- when serviceflow = 2 then '002'
               -- when callforwardindicator <>0 then '029'
                --when serviceflow = 2 and accessprefix = 268 then '005'
               -- when homezoneid = 333000 then '004'
              --  when callinggroupno = 930 and calledgroupno > 0 then '008'
               -- when productid = 5025553 then '013'
                when accounttype1 = 4000 then '018'
               -- when productid in (122189,122589,122690,122789) then '007'
            end call_type,
            to_char(0) called_subscriber,
            to_char(chargingtime, 'dd/mm/yyyy') date_,
            to_char(chargingtime, 'hh24:mi:ss') time,
            to_number(0) actual_duration,
            to_char(0) duration,
            subcosid tariff_group,
            ' ' tariff_group_desc,
            cast ('001 Normal rate calls' as varchar2(100)) tariff_class,
            ((nvl(CURRENTACCTAMOUNT1, 0) + nvl(CURRENTACCTAMOUNT2, 0) 
            + nvl(CURRENTACCTAMOUNT3, 0) + nvl(CURRENTACCTAMOUNT4, 0) 
            + nvl(CURRENTACCTAMOUNT5, 0) + nvl(CURRENTACCTAMOUNT6, 0)
            + nvl(CURRENTACCTAMOUNT7, 0) + nvl(CURRENTACCTAMOUNT8, 0) 
            + nvl(CURRENTACCTAMOUNT9, 0) + nvl(CURRENTACCTAMOUNT10, 0)) 
            + (nvl(CHARGEAMOUNT1, 0) + nvl(CHARGEAMOUNT2, 0) 
            + nvl(CHARGEAMOUNT3, 0) + nvl(CHARGEAMOUNT4, 0) 
            + nvl(CHARGEAMOUNT5, 0) + nvl(CHARGEAMOUNT6, 0) 
            + nvl(CHARGEAMOUNT7, 0) + nvl(CHARGEAMOUNT8, 0) 
            + nvl(CHARGEAMOUNT9, 0) + nvl(CHARGEAMOUNT10, 0))) /100 gross_amount,
            to_char((nvl(DEBIT_FROM_POSTPAID, 0)+nvl(CHARGEFROMPREPAID, 0))/100 
            || ' - BAL(' || (nvl(PREPAIDBALANCE, 0)+nvl(POSTPAIDBALANCE, 0))/100 || ')') bill_amount,  
            TO_CHAR((nvl(DEBIT_FROM_POSTPAID, 0)+nvl(CHARGEFROMPREPAID, 0))/100) || ' - MGR USAGE ' bill_text
            FROM ods.rated_mgr_cdr a
			WHERE chargingpartynumber = p_msisdn
            AND chargingtime between p_start_dt and p_end_dt + 1 - 1/24/3600
            UNION ALL
                    SELECT /*+ index(a CHARGINPARTYNUMB_LOC_ADJ_IDX) */ 
            TO_CHAR(NULL) charged_type,
            accounttype1 ||
                CASE WHEN accounttype2 <> 0 THEN '-'||accounttype2 ELSE '' END ||
                CASE WHEN accounttype3 <> 0 THEN '-'||accounttype3 ELSE '' END ||
                CASE WHEN accounttype4 <> 0 THEN '-'||accounttype4 ELSE '' END ||
                CASE WHEN accounttype5 <> 0 THEN '-'||accounttype5 ELSE '' END 
            account,
            case
               -- when serviceflow = 1 then '001'
               -- when serviceflow = 2 then '002'
               -- when callforwardindicator <>0 then '029'
                --when serviceflow = 2 and accessprefix = 268 then '005'
               -- when homezoneid = 333000 then '004'
              --  when callinggroupno = 930 and calledgroupno > 0 then '008'
               -- when productid = 5025553 then '013'
                when accounttype1 = 4000 then '018'
               -- when productid in (122189,122589,122690,122789) then '007'
            end call_type,
            to_char(0) called_subscriber,
            to_char(chargingtime, 'dd/mm/yyyy') date_,
            to_char(chargingtime, 'hh24:mi:ss') time,
            to_number(0) actual_duration,
            to_char(0) duration,
            subcosid tariff_group,
            ' ' tariff_group_desc,
            cast ('001 Normal rate calls' as varchar2(100)) tariff_class,
            ((nvl(CURRENTACCTAMOUNT1, 0) + nvl(CURRENTACCTAMOUNT2, 0) 
            + nvl(CURRENTACCTAMOUNT3, 0) + nvl(CURRENTACCTAMOUNT4, 0) 
            + nvl(CURRENTACCTAMOUNT5, 0) + nvl(CURRENTACCTAMOUNT6, 0)
            + nvl(CURRENTACCTAMOUNT7, 0) + nvl(CURRENTACCTAMOUNT8, 0) 
            + nvl(CURRENTACCTAMOUNT9, 0) + nvl(CURRENTACCTAMOUNT10, 0)) 
            + (nvl(CHARGEAMOUNT1, 0) + nvl(CHARGEAMOUNT2, 0) 
            + nvl(CHARGEAMOUNT3, 0) + nvl(CHARGEAMOUNT4, 0) 
            + nvl(CHARGEAMOUNT5, 0) + nvl(CHARGEAMOUNT6, 0) 
            + nvl(CHARGEAMOUNT7, 0) + nvl(CHARGEAMOUNT8, 0) 
            + nvl(CHARGEAMOUNT9, 0) + nvl(CHARGEAMOUNT10, 0))) /100 gross_amount,
            to_char((nvl(DEBIT_FROM_POSTPAID, 0)+nvl(CHARGEFROMPREPAID, 0))/100 
            || ' - BAL(' || (nvl(ADVANCE_PREPAID_BALANCE, 0)+nvl(ADVANCE_POSTPAID_BALANCE, 0))/100 || ')') bill_amount,  
            TO_CHAR((nvl(DEBIT_FROM_POSTPAID, 0)+nvl(CHARGEFROMPREPAID, 0))/100) || ' - ADJUSTMENT ' bill_text
            FROM ods.rated_adj_cdr a
			WHERE chargingpartynumber = p_msisdn
            AND chargingtime between p_start_dt and p_end_dt + 1 - 1/24/3600
            UNION ALL
                    SELECT /*+ index(a CHARGINPARTYNUMB_LOC_TRA_IDX) */ 
            TO_CHAR(NULL) charged_type,
            accounttype1 ||
                CASE WHEN accounttype2 <> 0 THEN '-'||accounttype2 ELSE '' END ||
                CASE WHEN accounttype3 <> 0 THEN '-'||accounttype3 ELSE '' END ||
                CASE WHEN accounttype4 <> 0 THEN '-'||accounttype4 ELSE '' END ||
                CASE WHEN accounttype5 <> 0 THEN '-'||accounttype5 ELSE '' END 
            account,
            case
               -- when serviceflow = 1 then '001'
               -- when serviceflow = 2 then '002'
               -- when callforwardindicator <>0 then '029'
                --when serviceflow = 2 and accessprefix = 268 then '005'
               -- when homezoneid = 333000 then '004'
              --  when callinggroupno = 930 and calledgroupno > 0 then '008'
               -- when productid = 5025553 then '013'
                when accounttype1 = 4000 then '018'
               -- when productid in (122189,122589,122690,122789) then '007'
            end call_type,
            to_char(0) called_subscriber,
            to_char(TIMESTAMP, 'dd/mm/yyyy') date_,
            to_char(TIMESTAMP, 'hh24:mi:ss') time,
            to_number(0) actual_duration,
            to_char(0) duration,
            subcosid tariff_group,
            ' ' tariff_group_desc,
            cast ('001 Normal rate calls' as varchar2(100)) tariff_class,
            ((nvl(CURRENTACCTAMOUNT_1, 0) + nvl(CURRENTACCTAMOUNT_2, 0) 
            + nvl(CURRENTACCTAMOUNT_3, 0) + nvl(CURRENTACCTAMOUNT_4, 0) 
            + nvl(CURRENTACCTAMOUNT_5, 0) + nvl(CURRENTACCTAMOUNT_6, 0)
            + nvl(CURRENTACCTAMOUNT_7, 0) + nvl(CURRENTACCTAMOUNT_8, 0) 
            + nvl(CURRENTACCTAMOUNT_9, 0) + nvl(CURRENTACCTAMOUNT_10, 0)) 
            + (nvl(CHARGEAMOUNT1, 0) + nvl(CHARGEAMOUNT2, 0) 
            + nvl(CHARGEAMOUNT3, 0) + nvl(CHARGEAMOUNT4, 0) 
            + nvl(CHARGEAMOUNT5, 0) + nvl(CHARGEAMOUNT6, 0) 
            + nvl(CHARGEAMOUNT7, 0) + nvl(CHARGEAMOUNT8, 0) 
            + nvl(CHARGEAMOUNT9, 0) + nvl(CHARGEAMOUNT10, 0))) /100 gross_amount,
            to_char((nvl(TRANSFERAMOUNT, 0))/100 
            || ' - BAL(' || (nvl(PREPAIDBALANCE, 0)+nvl(POSTPAIDBALANCE_2, 0))/100 || ')') bill_amount,  
            TO_CHAR((nvl(TRANSFERAMOUNT, 0))/100) || ' - TRANSFER ' bill_text
            FROM ods.rated_tra_cdr a
			WHERE chargingpartynumber = p_msisdn
            AND timestamp between p_start_dt and p_end_dt + 1 - 1/24/3600
              UNION ALL
                 SELECT  /*+ index(a CHARGGPARTYNUMB_LOC_MMS_IDX) */
            TO_CHAR(NULL) charged_type,
            accounttype1 ||
                CASE WHEN accounttype2 <> 0 THEN '-'||accounttype2 ELSE '' END ||
                CASE WHEN accounttype3 <> 0 THEN '-'||accounttype3 ELSE '' END ||
                CASE WHEN accounttype4 <> 0 THEN '-'||accounttype4 ELSE '' END ||
                CASE WHEN accounttype5 <> 0 THEN '-'||accounttype5 ELSE '' END 
            account,
            case
               -- when serviceflow = 1 then '001'
               -- when serviceflow = 2 then '002'
               -- when callforwardindicator <>0 then '029'
                --when serviceflow = 2 and accessprefix = 268 then '005'
               -- when homezoneid = 333000 then '004'
              --  when callinggroupno = 930 and calledgroupno > 0 then '008'
               -- when productid = 5025553 then '013'
                when accounttype1 = 4000 then '018'
               -- when productid in (122189,122589,122690,122789) then '007'
            end call_type,
            to_char(0) called_subscriber,
            to_char(chargingtime, 'dd/mm/yyyy') date_,
            to_char(chargingtime, 'hh24:mi:ss') time,
            to_number(0) actual_duration,
            to_char(0) duration,
            subcosid tariff_group,
            ' ' tariff_group_desc,
            cast ('001 Normal rate calls' as varchar2(100)) tariff_class,
            ((nvl(CURRENTACCTAMOUNT1, 0) + nvl(CURRENTACCTAMOUNT2, 0) 
            + nvl(CURRENTACCTAMOUNT3, 0) + nvl(CURRENTACCTAMOUNT4, 0) 
            + nvl(CURRENTACCTAMOUNT5, 0) + nvl(CURRENTACCTAMOUNT6, 0)
            + nvl(CURRENTACCTAMOUNT7, 0) + nvl(CURRENTACCTAMOUNT8, 0) 
            + nvl(CURRENTACCTAMOUNT9, 0) + nvl(CURRENTACCTAMOUNT10, 0)) 
            + (nvl(CHARGEAMOUNT1, 0) + nvl(CHARGEAMOUNT2, 0) 
            + nvl(CHARGEAMOUNT3, 0) + nvl(CHARGEAMOUNT4, 0) 
            + nvl(CHARGEAMOUNT5, 0) + nvl(CHARGEAMOUNT6, 0) 
            + nvl(CHARGEAMOUNT7, 0) + nvl(CHARGEAMOUNT8, 0) 
            + nvl(CHARGEAMOUNT9, 0) + nvl(CHARGEAMOUNT10, 0))) /100 gross_amount,
            to_char((nvl(DEBIT_FROM_POSTPAID, 0)+nvl(CHARGEFROMPREPAID, 0))/100 
            || ' - BAL(' || (nvl(PREPAIDBALANCE, 0)+nvl(POSTPAIDBALANCE, 0))/100 || ')') bill_amount,  
            TO_CHAR((nvl(DEBIT_FROM_POSTPAID, 0)+nvl(CHARGEFROMPREPAID, 0))/100) || ' - MMS USAGE ' bill_text
            FROM ods.rated_mms_cdr a
            where chargingpartynumber = p_msisdn
           AND chargingtime between p_start_dt and p_end_dt + 1 - 1/24/3600
           UNION ALL
       SELECT /*+ index(a CALINGPARTYNUMB_LOC_VOICE_IDX) */
            DECODE(calltype, '3', 'International', 'Local') charged_type,
            accounttype1 ||
                CASE WHEN accounttype2 <> 0 THEN '-'||accounttype2 ELSE '' END ||
                CASE WHEN accounttype3 <> 0 THEN '-'||accounttype3 ELSE '' END ||
                CASE WHEN accounttype4 <> 0 THEN '-'||accounttype4 ELSE '' END ||
                CASE WHEN accounttype5 <> 0 THEN '-'||accounttype5 ELSE '' END 
            account,
            case
                when serviceflow = 1 then '001'
                when serviceflow = 2 then '002'
                when callforwardindicator <>0 then '029'
                when serviceflow = 2 and accessprefix = 268 then '005'
                when homezoneid = 333000 then '004'
                when callinggroupno = 930 and calledgroupno > 0 then '008'
                when productid = 5025553 then '013'
                when accounttype1 = 4000 then '018'
                when productid in (122189,122589,122690,122789) then '007'
            end call_type,
            calledpartynumber called_subscriber,
            to_char(chargingtime, 'dd/mm/yyyy') date_,
            to_char(chargingtime, 'hh24:mi:ss') time,
            callduration actual_duration,
            to_char(chargeduration) duration,
            subcosid tariff_group,
            ' ' tariff_group_desc,
            cast ('001 Normal rate calls' as varchar2(100)) tariff_class,
            ((nvl(CURRENTACCTAMOUNT1, 0) + nvl(CURRENTACCTAMOUNT2, 0) 
            + nvl(CURRENTACCTAMOUNT3, 0) + nvl(CURRENTACCTAMOUNT4, 0) 
            + nvl(CURRENTACCTAMOUNT5, 0) + nvl(CURRENTACCTAMOUNT6, 0)
            + nvl(CURRENTACCTAMOUNT7, 0) + nvl(CURRENTACCTAMOUNT8, 0) 
            + nvl(CURRENTACCTAMOUNT9, 0) + nvl(CURRENTACCTAMOUNT10, 0)) 
            + (nvl(CHARGEAMOUNT1, 0) + nvl(CHARGEAMOUNT2, 0) 
            + nvl(CHARGEAMOUNT3, 0) + nvl(CHARGEAMOUNT4, 0) 
            + nvl(CHARGEAMOUNT5, 0) + nvl(CHARGEAMOUNT6, 0) 
            + nvl(CHARGEAMOUNT7, 0) + nvl(CHARGEAMOUNT8, 0) 
            + nvl(CHARGEAMOUNT9, 0) + nvl(CHARGEAMOUNT10, 0))) /100 gross_amount,
            to_char((nvl(DEBIT_FROM_POSTPAID, 0)+nvl(DEBIT_FROM_PREPAID, 0))/100 
            || ' - BAL(' || (nvl(PREPAIDBALANCE, 0)+nvl(POSTPAIDBALANCE, 0))/100 || ')') bill_amount,  
            TO_CHAR((nvl(DEBIT_FROM_POSTPAID, 0)+nvl(DEBIT_FROM_PREPAID, 0))/100) || ' - VOICE CALL ' bill_text
            FROM ods.rated_voice_cdr_cutover a
            WHERE callingpartynumber = p_msisdn
            AND chargingtime between p_start_dt and p_end_dt + 1 - 1/24/3600
            UNION ALL
            SELECT  /*+ index(a CHARGGPARTYNUMB_LOC_VOU_IDX) */
            TO_CHAR(NULL) charged_type,
            accounttype1 ||
                CASE WHEN accounttype2 <> 0 THEN '-'||accounttype2 ELSE '' END ||
                CASE WHEN accounttype3 <> 0 THEN '-'||accounttype3 ELSE '' END ||
                CASE WHEN accounttype4 <> 0 THEN '-'||accounttype4 ELSE '' END ||
                CASE WHEN accounttype5 <> 0 THEN '-'||accounttype5 ELSE '' END 
            account,
            case
               -- when serviceflow = 1 then '001'
               -- when serviceflow = 2 then '002'
               -- when callforwardindicator <>0 then '029'
                --when serviceflow = 2 and accessprefix = 268 then '005'
               -- when homezoneid = 333000 then '004'
              --  when callinggroupno = 930 and calledgroupno > 0 then '008'
               -- when productid = 5025553 then '013'
                when accounttype1 = 4000 then '018'
               -- when productid in (122189,122589,122690,122789) then '007'
            end call_type,
            to_char(0) called_subscriber,
            to_char(timestamp, 'dd/mm/yyyy') date_,
            to_char(timestamp, 'hh24:mi:ss') time,
            to_number(0) actual_duration,
            to_char(0) duration,
            subcosid tariff_group,
            ' ' tariff_group_desc,
            cast ('001 Normal rate calls' as varchar2(100)) tariff_class,
            ((nvl(CURRENTACCTAMOUNT1, 0) + nvl(CURRENTACCTAMOUNT2, 0) 
            + nvl(CURRENTACCTAMOUNT3, 0) + nvl(CURRENTACCTAMOUNT4, 0) 
            + nvl(CURRENTACCTAMOUNT5, 0) + nvl(CURRENTACCTAMOUNT6, 0)
            + nvl(CURRENTACCTAMOUNT7, 0) + nvl(CURRENTACCTAMOUNT8, 0) 
            + nvl(CURRENTACCTAMOUNT9, 0) + nvl(CURRENTACCTAMOUNT10, 0)) 
            + (nvl(CHARGEAMOUNT1, 0) + nvl(CHARGEAMOUNT2, 0) 
            + nvl(CHARGEAMOUNT3, 0) + nvl(CHARGEAMOUNT4, 0) 
            + nvl(CHARGEAMOUNT5, 0) + nvl(CHARGEAMOUNT6, 0) 
            + nvl(CHARGEAMOUNT7, 0) + nvl(CHARGEAMOUNT8, 0) 
            + nvl(CHARGEAMOUNT9, 0) + nvl(CHARGEAMOUNT10, 0))) /100 gross_amount,
            to_char((nvl(rechargeforpostpaid, 0)+nvl(rechargeforprepaid, 0))/100 
            || ' - BAL(' || (nvl(PREPAIDBALANCEBEFORE, 0)+nvl(POSTPAIDBALANCEBEFORE, 0))/100 || ')') bill_amount,  
            TO_CHAR((nvl(rechargeforpostpaid, 0)+nvl(rechargeforprepaid, 0))/100) || ' - RECHARGES ' bill_text
            FROM ods.rated_vou_cdr a
            where chargingpartynumber = p_msisdn
            AND timestamp between p_start_dt and p_end_dt + 1 - 1/24/3600;
            
    END;
PROCEDURE prc_get_data_result (v_msisdn varchar2, p_start_date varchar2, p_end_date varchar2, p_result OUT sys_refcursor) AS
    p_start_dt date := to_date(p_start_date, 'yyyy/mm/dd');
    p_end_dt date := to_date(p_end_date, 'yyyy/mm/dd');
    p_msisdn varchar2(100);
    --check msisdn
    BEGIN
        IF SUBSTR(v_msisdn, 1, 3) = '234' THEN
            p_msisdn := v_msisdn;    
        ELSE   
            p_msisdn := '234' || v_msisdn;  
        END IF;
        OPEN p_result FOR 
            SELECT 
                ACCOUNTTYPE1_A ||
                    CASE WHEN accounttype2 <> 0 then '-'||accounttype2 else '' end ||
                    CASE WHEN accounttype3 <> 0 then '-'||accounttype3 else '' end ||
                    CASE WHEN accounttype4 <> 0 then '-'||accounttype4 else '' end ||
                    CASE WHEN accounttype5 <> 0 then '-'||accounttype5 else '' end 
                account,
                CASE
                    when chargingtype = 1 then '051'
                    when accounttype1 = 4503 then '018'
                    ELSE '050'
                END call_type,
                to_char(chargingtime,'dd/mm/yyyy') date_,
                to_char(chargingtime,'hh24:mi:ss') time,
                trunc(datediff(starttime,stoptime)/60)  || ':' || mod(datediff(starttime,stoptime),60) duration,
                apn apn,
                totalflux/1024 totalflux,
                subcosid tariff_group,
                ' ' tariff_group_desc,
                cast ('001 Normal rate data' as varchar2(100)) tariff_class,         
                (nvl(PREPAIDBALANCE, 0)+nvl(POSTPAIDBALANCE, 0)/100) BILL_BALANCE,
                (nvl(CHARGEFROMPREPAID, 0)+nvl(CHARGEFROMPOSTPAID, 0)/100) BILL_AMOUNT,
                case
                    when chargingtype = 1 then 'DATA'
                    when accounttype1 = 4503 then 'DATA BONUS USAGE'
                    else 'DATA'
                end || ' - PROD(' || PRODUCTID || ')' bill_text
                FROM ods.rated_data_cdr data
                WHERE callingpartynumber = p_msisdn
                AND chargingtime >= trunc(p_start_dt) AND chargingtime <= trunc(p_end_dt) + 1 - 1/24/3600;
    END;
    PROCEDURE prc_get_result_no_cursor (v_msisdn varchar2, p_start_date varchar2, p_end_date varchar2 , p_result OUT sys_refcursor) AS
   -- p_start_dt date := to_date(p_start_date, 'YYYY-MM-DD');
--p_start_dt date := to_date(p_end_date, 'YYYY-MM-DD');
    --p_date varchar2(20) := to_char(p_start_date, 'YYYYMMDD');
    p_partition_date varchar2(20) := 'partition(p'||p_start_date||')';
    p_msisdn varchar2(100);
    v_sql varchar2(3500) :='';
    
    BEGIN
    --check msisdn
        IF SUBSTR(v_msisdn, 1, 3) = '234' THEN
            p_msisdn := v_msisdn;
        ELSE
            p_msisdn := '234' || v_msisdn;
        END IF;
        INSERT INTO ST_END_TABLE(P_START_DATE,E_END_DATE)VALUES( p_partition_date, p_partition_date);
        COMMIT;
        
        --OPEN p_result FOR 
    /* Formatted on 2/7/2018 3:51:06 PM (QP5 v5.294) */
 --v_sql:='INSERT INTO rated_voice_portaluser
v_sql:= 'SELECT DECODE (calltype, ''3'',''International'',''Local'') charged_type,
            accounttype1 ||
                CASE WHEN accounttype2 <> 0 THEN ''-''||accounttype2 ELSE 0 END ||
                CASE WHEN accounttype3 <> 0 THEN ''-''||accounttype3 ELSE 0 END ||
                CASE WHEN accounttype4 <> 0 THEN ''-''||accounttype4 ELSE 0 END ||
                CASE WHEN accounttype5 <> 0 THEN ''-''||accounttype5 ELSE 0 END
            account,
            case
                when serviceflow = 1 then ''001''
                when serviceflow = 2 then ''002''
                when callforwardindicator <>0 then ''029''
                when serviceflow = 2 and accessprefix = 268 then ''005''
                when homezoneid = 333000 then ''004''
                when callinggroupno = 930 and calledgroupno > 0 then ''008''
                when productid = 5025553 then ''013''
                when accounttype1 = 4000 then ''018''
                when productid in (122189,122589,122690,122789) then ''007''
            end call_type,
            calledpartynumber called_subscriber,
            to_char(chargingtime, ''dd/mm/yyyy'') date_,
            to_char(chargingtime, ''hh24:mi:ss'') time,
            callduration actual_duration,
            to_char(chargeduration) duration,
            subcosid tariff_group,
            '' '' tariff_group_desc,
            cast (''001 Normal rate calls'' as varchar2(100)) tariff_class,
            ((nvl(CURRENTACCTAMOUNT1, 0) + nvl(CURRENTACCTAMOUNT2, 0)
            + nvl(CURRENTACCTAMOUNT3, 0) + nvl(CURRENTACCTAMOUNT4, 0)
            + nvl(CURRENTACCTAMOUNT5, 0) + nvl(CURRENTACCTAMOUNT6, 0)
            + nvl(CURRENTACCTAMOUNT7, 0) + nvl(CURRENTACCTAMOUNT8, 0)
            + nvl(CURRENTACCTAMOUNT9, 0) + nvl(CURRENTACCTAMOUNT10, 0))
            + (nvl(CHARGEAMOUNT1, 0) + nvl(CHARGEAMOUNT2, 0)
            + nvl(CHARGEAMOUNT3, 0) + nvl(CHARGEAMOUNT4, 0)
            + nvl(CHARGEAMOUNT5, 0) + nvl(CHARGEAMOUNT6, 0)
            + nvl(CHARGEAMOUNT7, 0) + nvl(CHARGEAMOUNT8, 0)
            + nvl(CHARGEAMOUNT9, 0) + nvl(CHARGEAMOUNT10, 0))) /100 gross_amount,
            to_char((nvl(DEBIT_FROM_POSTPAID, 0)+nvl(DEBIT_FROM_PREPAID, 0))/100
            || '' - BAL('' || (nvl(PREPAIDBALANCE, 0)+nvl(POSTPAIDBALANCE, 0))/100 || '')'') bill_amount,
            TO_CHAR((nvl(DEBIT_FROM_POSTPAID, 0)+nvl(DEBIT_FROM_PREPAID, 0))/100) || '' - VOICE CALL'' bill_text FROM ods.rated_voice_cdr_cutover ';
            v_sql := v_sql||p_partition_date||'where callingpartynumber = :m';
            --execute immediate v_sql;
           -- commit;
            OPEN p_result FOR v_sql USING p_msisdn;
    END;
END;
/
