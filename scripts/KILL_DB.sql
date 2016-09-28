declare 

CURSOR const_cur IS
SELECT table_name, constraint_name
FROM user_constraints;

ExStr VARCHAR2(4000);
BEGIN
  FOR fke_rec IN const_cur
  LOOP
    ExStr := 'ALTER TABLE ' || fke_rec.table_name ||
             ' DROP CONSTRAINT ' ||
              fke_rec.constraint_name;
    BEGIN
      EXECUTE IMMEDIATE ExStr;
    EXCEPTION
      WHEN OTHERS THEN
                dbms_output.put_line('Dynamic SQL Failure: ' || SQLERRM);
               dbms_output.put_line('On statement: ' || ExStr);    END;
  END LOOP;
END;

/

declare
  cursor ix is
    select *
      from user_objects
     where object_type in ('TABLE', 'VIEW', 'FUNCTION', 'SEQUENCE','PROCEDURE');
begin
 for x in ix loop
   execute immediate('drop '||x.object_type||' '||x.object_name);
 end loop;
end;

/


