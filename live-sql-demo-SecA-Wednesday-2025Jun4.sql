DROP TABLE client

CREATE TABLE client(
    CLIENT_ID NUMBER PRIMARY KEY,
    CLIENT_FORENAMES VARCHAR2(100),
    CLIENT_SURNAME VARCHAR2(100)
);

DROP SEQUENCE seq_client

CREATE SEQUENCE seq_client
MINVALUE 10001
START WITH 10001
INCREMENT BY 10
NOCACHE;

INSERT INTO client VALUES(seq_client.nextval, 'Fred', 'Smith');
INSERT INTO client VALUES(seq_client.nextval, 'Jane', 'Stevens');

SELECT * FROM client;

SELECT * FROM CLIENT where CLIENT_FORENAMES = 'Fred';

SELECT * FROM CLIENT where CLIENT_FORENAMES = '&client_name';



SET SERVEROUTPUT ON;

DECLARE
 length NUMBER := 5;
 breadth NUMBER := 10;
 area NUMBER;

 BEGIN
    area := length * breadth;
    DBMS_OUTPUT.PUT_LINE('Area: ' ||area);

END;
/

DECLARE
		too_old EXCEPTION;
        still_young EXCEPTION;
BEGIN
		IF &what_is_your_age > 55 THEN
			RAISE too_old;
        ELSE
            RAISE still_young; 
		END IF;
EXCEPTION
		WHEN too_old THEN
			DBMS_OUTPUT.PUT_LINE('You are past it!');

        WHEN still_young THEN
			DBMS_OUTPUT.PUT_LINE('You are still young!');
END;

/*===== May 27, 2025 ======= */

DROP TABLE students;

CREATE TABLE students(
    id NUMBER PRIMARY KEY,
    name VARCHAR2(100),
    AMD NUMBER,
    AI NUMBER
);

DROP SEQUENCE seq_students

CREATE SEQUENCE seq_students
MINVALUE 1
START WITH 1
INCREMENT BY 1
NOCACHE;

INSERT INTO students VALUES(seq_students.nextval, 'Fred', 77, 80);
INSERT INTO students VALUES(seq_students.nextval, 'Sam', 59, 75);
INSERT INTO students VALUES(seq_students.nextval, 'Collin', 82, 89);

SELECT * FROM STUDENTS;

/* Pre-defined Exception Example */

DECLARE
    my_name students.NAME%TYPE;

BEGIN
    SELECT name
    INTO my_name 
    FROM STUDENTS
    WHERE AMD = &enter_amd_marks;

    DBMS_OUTPUT.PUT_LINE('Student name is ' ||my_name);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No such student');

END;

/* Calculate Average Marks of Students Example Using PL/SQL */

DECLARE
    amd_marks STUDENTS.AMD%TYPE;
    ai_marks Students.AI%TYPE;
    avg_marks NUMBER;

BEGIN
    SELECT AMD, AI
    INTO amd_marks, ai_marks 
    FROM STUDENTS
    WHERE NAME = '&enter_student_name';

    avg_marks := (amd_marks + ai_marks) / 2;
    DBMS_OUTPUT.PUT_LINE('Average Marks is ' ||avg_marks);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No such student');

END;


/* Calculate Average Marks of Students Example Using Stored Procedure */

/* Compilation Part */
CREATE OR REPLACE PROCEDURE calculate_average(studentName VARCHAR2) AS
    amd_marks STUDENTS.AMD%TYPE;
    ai_marks Students.AI%TYPE;
    avg_marks NUMBER;

BEGIN
    SELECT AMD, AI
    INTO amd_marks, ai_marks 
    FROM STUDENTS
    WHERE NAME = studentName;

    avg_marks := (amd_marks + ai_marks) / 2;
    DBMS_OUTPUT.PUT_LINE('Average Marks is ' ||avg_marks);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No such student');

END;

/* Execution Part */
EXECUTE calculate_average('Sam');
EXECUTE calculate_average('Rishav');

/* Calculate Average Marks using Stored Function */
CREATE OR REPLACE FUNCTION cal_average_marks(amd_marks Students.AMD%TYPE, ai_marks Students.AI%TYPE)
RETURN NUMBER AS
    avg_marks NUMBER;
BEGIN
    avg_marks := (amd_marks + ai_marks) / 2;
    RETURN avg_marks;

END;

/* SQL Query using Stored Function directly */
SELECT name, AMD, AI, cal_average_marks(AMD, AI) AS Average from STUDENTS;

/* Calculate Average Marks of Students Example Using Stored Procedure and Stored Function */

/* Compilation Part */
CREATE OR REPLACE PROCEDURE calculate_average(studentName VARCHAR2) AS
    amd_marks STUDENTS.AMD%TYPE;
    ai_marks Students.AI%TYPE;

BEGIN
    SELECT AMD, AI
    INTO amd_marks, ai_marks 
    FROM STUDENTS
    WHERE NAME = studentName;

    DBMS_OUTPUT.PUT_LINE('Average Marks is ' ||CAL_AVERAGE_MARKS(amd_marks, ai_marks));

EXCEPTION
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No such student');

END;

/* Execution Part */
EXECUTE calculate_average('Sam');
EXECUTE calculate_average('Rishav');

/* Stored Function For End Programmer */
CREATE OR REPLACE FUNCTION cal_average_marks(studentName VARCHAR2) RETURN NUMBER AS
    amd_marks Students.AMD%TYPE;
    ai_marks Students.AI%TYPE;
    avg_marks NUMBER;
BEGIN
    SELECT AMD, AI
    INTO amd_marks, ai_marks 
    FROM STUDENTS
    WHERE NAME = studentName;

    avg_marks := (amd_marks + ai_marks) / 2;
    RETURN avg_marks;
END;