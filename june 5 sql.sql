







DROP TABLE customer_data;

CREATE TABLE customer_data (
    customer_name VARCHAR(200),
    Bank_name VARCHAR(200),
    Principal NUMBER,
    Rate NUMBER,
    Time NUMBER
);

INSERT INTO customer_data VALUES ('Prashant', 'Mega Bank', 2500000, 8, 5);

INSERT INTO customer_data VALUES ('Suman','Rastriya Banijya Bank',2700000,7.5,6);
INSERT INTO customer_data VALUES ('Arpan','Laxmi Sunrise Bank',2900000,6.5,7);


SELECT * from CUSTOMER_DATA;

CREATE OR REPLACE FUNCTION calculate_emi (
    principal IN NUMBER,
    rate      IN NUMBER,  
    time      IN NUMBER   
) RETURN NUMBER IS
    monthly_rate NUMBER;
    total_months NUMBER;
    emi          NUMBER;
BEGIN
    monthly_rate := rate / (12 * 100);
    
    total_months := time * 12;

    -- EMI formula
    emi := (principal * monthly_rate * POWER(1 + monthly_rate, total_months)) /
           (POWER(1 + monthly_rate, total_months) - 1);

  
    RETURN ROUND(emi, 2);
END;
/

