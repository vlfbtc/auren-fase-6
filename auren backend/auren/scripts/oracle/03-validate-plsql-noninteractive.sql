-- 03-validate-plsql-noninteractive.sql
-- Uso: @03-validate-plsql-noninteractive.sql <USER_ID> <MONTH> <YEAR>
-- Ex.: @/tmp/03-validate-plsql-noninteractive.sql 21 9 2025

SET SERVEROUTPUT ON
SET PAGESIZE 200
SET LINESIZE 200
SET FEEDBACK ON

-- Parâmetros posicionais vindos da linha de comando do SQL*Plus
DEFINE USER_ID = &1
DEFINE MONTH   = &2
DEFINE YEAR    = &3

PROMPT === 1) Objetos PL/SQL (status) ===
COL OBJECT_NAME FORMAT A25
SELECT object_name, object_type, status
  FROM user_objects
 WHERE object_type IN ('FUNCTION','PROCEDURE')
 ORDER BY object_type, object_name;

PROMPT
PROMPT === 2) Parâmetros recebidos ===
SELECT 'USER_ID='||'&USER_ID' AS param FROM dual
UNION ALL
SELECT 'MONTH='||'&MONTH' FROM dual
UNION ALL
SELECT 'YEAR='||'&YEAR' FROM dual;

PROMPT
PROMPT === 3) Teste: GET_MONTHLY_BALANCE ===
COLUMN SALDO FORMAT 9999990.99
SELECT get_monthly_balance(&USER_ID, &MONTH, &YEAR) AS saldo FROM dual;

PROMPT
PROMPT === 4) Teste: GET_TX_SUMMARY_JSON (preview) ===
COLUMN RESUMO FORMAT A180
SELECT SUBSTR(get_tx_summary_json(&USER_ID), 1, 180) AS resumo FROM dual;

PROMPT
PROMPT === 5) Teste: GET_CATEGORY_REPORT (REF CURSOR) ===
VAR rc REFCURSOR
EXEC get_category_report(&USER_ID, :rc);
PRINT rc

PROMPT
PROMPT === 6) Teste: LOG_HIGH_VALUE_TX (gera alerta se >= 1000) ===
DECLARE
  v_tx_id     NUMBER;
  v_threshold NUMBER := 1000;
BEGIN
  SELECT id INTO v_tx_id
  FROM (
    SELECT id
      FROM transactions
     WHERE user_id = &USER_ID
     ORDER BY tx_date DESC
  )
  WHERE ROWNUM = 1;

  dbms_output.put_line('Chamando LOG_HIGH_VALUE_TX para TX_ID='||v_tx_id||' threshold='||v_threshold);
  log_high_value_tx(v_tx_id, v_threshold);
END;
/
COMMIT;

PROMPT
PROMPT === 7) ALERTS gerados (recentes) ===
COLUMN MESSAGE FORMAT A80
SELECT id, transaction_id, 'TX '||transaction_id||' >= limiar '||threshold AS message, threshold, created_at
  FROM alerts
 WHERE transaction_id IN (SELECT id FROM transactions WHERE user_id = &USER_ID)
 ORDER BY created_at DESC
 FETCH FIRST 10 ROWS ONLY;

PROMPT
PROMPT === FIM ===
