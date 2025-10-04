-- Executar como auren_user
-- Este bloco:
-- 1) Garante a Alice
-- 2) Define a senha como BCRYPT gerado
-- 3) Ajusta flags comuns de status se existirem nas colunas

DECLARE
  v_exists NUMBER;
  v_email  VARCHAR2(255) := 'alice@example.net';
  v_hash   VARCHAR2(100) := '$2a$10$lDfnPYyd.lR.vgXL9PwIUuSXgYb2AKNW2ypbA4XkC7VTO0UgWBmX.'; -- <= SEU BCRYPT
BEGIN
  SELECT COUNT(*) INTO v_exists FROM users WHERE email = v_email;

  IF v_exists = 0 THEN
    INSERT INTO users (first_name, last_name, email, birth_date, password_hash, role)
    VALUES ('Alice','Silva', v_email, DATE '1990-05-15', v_hash, 'USER');
  ELSE
    UPDATE users SET password_hash = v_hash WHERE email = v_email;
  END IF;

  -- Ajustes opcionais de flags, somente se as colunas existirem
  FOR col IN (
    SELECT column_name FROM user_tab_columns WHERE table_name='USERS'
  ) LOOP
    BEGIN
      IF col.column_name = 'STATUS' THEN
        EXECUTE IMMEDIATE 'UPDATE users SET status = ''ACTIVE'' WHERE email = :1' USING v_email;
      ELSIF col.column_name = 'ENABLED' THEN
        EXECUTE IMMEDIATE 'UPDATE users SET enabled = 1 WHERE email = :1' USING v_email;
      ELSIF col.column_name IN ('IS_VERIFIED','EMAIL_VERIFIED','PIN_VERIFIED') THEN
        EXECUTE IMMEDIATE 'UPDATE users SET '||col.column_name||' = 1 WHERE email = :1' USING v_email;
      ELSIF col.column_name = 'FAILED_ATTEMPTS' THEN
        EXECUTE IMMEDIATE 'UPDATE users SET failed_attempts = 0 WHERE email = :1' USING v_email;
      ELSIF col.column_name = 'LOCKED_UNTIL' THEN
        EXECUTE IMMEDIATE 'UPDATE users SET locked_until = NULL WHERE email = :1' USING v_email;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN NULL; -- ignora colunas que não existirem/tipos diferentes
    END;
  END LOOP;

  COMMIT;
END;
/
-- Confirma o registro/ID
SELECT id, email, password_hash FROM users WHERE email = 'alice@example.net';
