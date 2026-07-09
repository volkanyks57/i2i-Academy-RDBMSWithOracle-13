CREATE OR REPLACE TRIGGER trg_books_audit
AFTER INSERT ON books
FOR EACH ROW
BEGIN
INSERT INTO audit_logs (table_name, action, db_user, log_time) VALUES ('BOOKS', 'INSERT', USER, SYSTIMESTAMP);
END;