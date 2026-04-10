-- Digital Art NFT Marketplace & Creator Economy - Oracle Object-Relational Database (FIXED)
-- Drop all objects for the NFT Marketplace System (Oracle version)
-- Each block uses PL/SQL with exception handling to avoid errors if the object does not exist

-- Drop Triggers
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_nft_creation';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_sale_transaction';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_creator_registration';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_auction_bid';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Drop Procedures
BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE create_nft';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE process_sale';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE manage_auction';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE calculate_royalties';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE get_marketplace_analytics';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Drop Functions
BEGIN
    EXECUTE IMMEDIATE 'DROP FUNCTION get_creator_earnings';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP FUNCTION calculate_platform_fees';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP FUNCTION get_nft_market_value';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP FUNCTION get_collection_stats';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP FUNCTION get_trending_score';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Drop Sequences
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE creator_id_seq';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE nft_id_seq';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE transaction_id_seq';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE collection_id_seq';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE auction_id_seq';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE marketplace_id_seq';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Drop Tables (in dependency order)
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE nft CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE premium_creator CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE verified_creator CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE creator CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE transaction_history CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE auction CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE nft_collection CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE marketplace CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Drop Nested Table Types
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE nft_table_type';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE transaction_table_type';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE bid_table_type';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE tag_array_type';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Drop Subtypes First
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE premium_creator_type';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE verified_creator_type';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Drop Base Types Last
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE creator_type';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE nft_type';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE transaction_type';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE auction_type';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE collection_type';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE marketplace_type';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE bid_type';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Create array type for tags
CREATE OR REPLACE TYPE tag_array_type AS VARRAY(20) OF VARCHAR2(50);
/

-- Create bid type for auction functionality
CREATE OR REPLACE TYPE bid_type AS OBJECT (
    bidder_wallet VARCHAR2(100),
    bid_amount NUMBER(15,2),
    bid_timestamp TIMESTAMP,
    
    -- Member function to check if bid is valid
    MEMBER FUNCTION is_valid_bid(current_highest NUMBER) RETURN BOOLEAN,
    
    -- Member function to calculate bid with fees
    MEMBER FUNCTION total_with_fees RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY bid_type AS
    MEMBER FUNCTION is_valid_bid(current_highest NUMBER) RETURN BOOLEAN IS
    BEGIN
        RETURN bid_amount > current_highest;
    END;
    
    MEMBER FUNCTION total_with_fees RETURN NUMBER IS
    BEGIN
        RETURN bid_amount * 1.025; -- 2.5% platform fee
    END;
END;
/

-- Base Creator type (NOT FINAL for inheritance)
CREATE OR REPLACE TYPE creator_type AS OBJECT (
    creator_id NUMBER,
    wallet_address VARCHAR2(100),
    username VARCHAR2(50),
    email VARCHAR2(100),
    bio CLOB,
    profile_image_url VARCHAR2(500),
    created_at TIMESTAMP,
    total_sales NUMBER(15,2),
    total_earnings NUMBER(15,2),
    
    -- Member function to get creator reputation score
    MEMBER FUNCTION get_reputation_score RETURN NUMBER,
    
    -- Member procedure to update earnings
    MEMBER PROCEDURE update_earnings(amount IN NUMBER),
    
    -- Member function to get creator status
    MEMBER FUNCTION get_creator_status RETURN VARCHAR2
) NOT FINAL;
/

CREATE OR REPLACE TYPE BODY creator_type AS
    MEMBER FUNCTION get_reputation_score RETURN NUMBER IS
    BEGIN
        RETURN CASE 
            WHEN total_earnings > 50000 THEN 95 + (total_sales / 1000)
            WHEN total_earnings > 10000 THEN 80 + (total_sales / 500)
            WHEN total_earnings > 1000 THEN 60 + (total_sales / 100)
            ELSE 40 + (total_sales / 50)
        END;
    END;
    
    MEMBER PROCEDURE update_earnings(amount IN NUMBER) IS
    BEGIN
        total_earnings := total_earnings + amount;
        total_sales := total_sales + 1;
    END;
    
    MEMBER FUNCTION get_creator_status RETURN VARCHAR2 IS
    BEGIN
        RETURN CASE 
            WHEN total_earnings > 50000 THEN 'Elite'
            WHEN total_earnings > 10000 THEN 'Professional'
            WHEN total_earnings > 1000 THEN 'Established'
            ELSE 'Emerging'
        END;
    END;
END;
/

-- Verified Creator subtype
CREATE OR REPLACE TYPE verified_creator_type UNDER creator_type (
    verification_date TIMESTAMP,
    verification_tier VARCHAR2(20),
    
    -- Override get_creator_status method
    OVERRIDING MEMBER FUNCTION get_creator_status RETURN VARCHAR2,
    
    -- New member function for verification benefits
    MEMBER FUNCTION get_verification_benefits RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY verified_creator_type AS
    OVERRIDING MEMBER FUNCTION get_creator_status RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Verified ' || (SELF AS creator_type).get_creator_status();
    END;
    
    MEMBER FUNCTION get_verification_benefits RETURN VARCHAR2 IS
    BEGIN
        RETURN CASE verification_tier
            WHEN 'Gold' THEN 'Lower fees, Priority support, Featured listings'
            WHEN 'Silver' THEN 'Lower fees, Priority support'
            WHEN 'Bronze' THEN 'Lower fees'
            ELSE 'Standard verification benefits'
        END;
    END;
END;
/

-- Premium Creator subtype
CREATE OR REPLACE TYPE premium_creator_type UNDER verified_creator_type (
    premium_since TIMESTAMP,
    exclusive_features tag_array_type,
    
    -- Override get_creator_status method
    OVERRIDING MEMBER FUNCTION get_creator_status RETURN VARCHAR2,
    
    -- New member function for premium features
    MEMBER FUNCTION get_premium_features RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY premium_creator_type AS
    OVERRIDING MEMBER FUNCTION get_creator_status RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Premium ' || (SELF AS verified_creator_type).get_creator_status();
    END;
    
    MEMBER FUNCTION get_premium_features RETURN VARCHAR2 IS
        feature_list VARCHAR2(1000) := '';
    BEGIN
        IF exclusive_features IS NOT NULL THEN
            FOR i IN 1..exclusive_features.COUNT LOOP
                feature_list := feature_list || exclusive_features(i) || ', ';
            END LOOP;
        END IF;
        RETURN RTRIM(feature_list, ', ');
    END;
END;
/

-- NFT type (NOT FINAL for possible extension)
CREATE OR REPLACE TYPE nft_type AS OBJECT (
    nft_id NUMBER,
    token_id VARCHAR2(100),
    title VARCHAR2(200),
    description CLOB,
    image_url VARCHAR2(500),
    metadata_url VARCHAR2(500),
    price NUMBER(15,2),
    royalty_percentage NUMBER(5,2),
    tags tag_array_type,
    created_at TIMESTAMP,
    last_sale_date TIMESTAMP,
    view_count NUMBER,
    like_count NUMBER,
    
    -- Member function to check if NFT is trending
    MEMBER FUNCTION is_trending RETURN BOOLEAN,
    
    -- Member procedure to update engagement metrics
    MEMBER PROCEDURE update_engagement(views IN NUMBER, likes IN NUMBER),
    
    -- Member function to calculate royalty amount
    MEMBER FUNCTION calculate_royalty(sale_price IN NUMBER) RETURN NUMBER
) NOT FINAL;
/

CREATE OR REPLACE TYPE BODY nft_type AS
    MEMBER FUNCTION is_trending RETURN BOOLEAN IS
    BEGIN
        RETURN view_count > 1000 AND like_count > 100 AND 
               last_sale_date > SYSTIMESTAMP - INTERVAL '7' DAY;
    END;
    
    MEMBER PROCEDURE update_engagement(views IN NUMBER, likes IN NUMBER) IS
    BEGIN
        view_count := view_count + views;
        like_count := like_count + likes;
    END;
    
    MEMBER FUNCTION calculate_royalty(sale_price IN NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN sale_price * (royalty_percentage / 100);
    END;
END;
/

-- Transaction type for marketplace operations
CREATE OR REPLACE TYPE transaction_type AS OBJECT (
    transaction_id NUMBER,
    transaction_hash VARCHAR2(100),
    transaction_type VARCHAR2(20), -- 'SALE', 'AUCTION', 'TRANSFER'
    amount NUMBER(15,2),
    platform_fee NUMBER(15,2),
    gas_fee NUMBER(15,2),
    transaction_timestamp TIMESTAMP,
    block_number NUMBER,
    
    -- Member function to get total cost
    MEMBER FUNCTION get_total_cost RETURN NUMBER,
    
    -- Member function to check transaction age
    MEMBER FUNCTION get_transaction_age RETURN INTERVAL DAY TO SECOND,
    
    -- Static function to calculate platform fee
    STATIC FUNCTION calculate_platform_fee(amount IN NUMBER) RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY transaction_type AS
    MEMBER FUNCTION get_total_cost RETURN NUMBER IS
    BEGIN
        RETURN amount + platform_fee + gas_fee;
    END;
    
    MEMBER FUNCTION get_transaction_age RETURN INTERVAL DAY TO SECOND IS
    BEGIN
        RETURN SYSTIMESTAMP - transaction_timestamp;
    END;
    
    STATIC FUNCTION calculate_platform_fee(amount IN NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN amount * 0.025; -- 2.5% platform fee
    END;
END;
/

-- Collection type for NFT groupings
CREATE OR REPLACE TYPE collection_type AS OBJECT (
    collection_id NUMBER,
    name VARCHAR2(100),
    description CLOB,
    cover_image_url VARCHAR2(500),
    floor_price NUMBER(15,2),
    total_volume NUMBER(15,2),
    item_count NUMBER,
    created_at TIMESTAMP,
    
    -- Member function to calculate average price
    MEMBER FUNCTION get_average_price RETURN NUMBER,
    
    -- Member procedure to update collection stats
    MEMBER PROCEDURE update_stats(new_sale_price IN NUMBER)
);
/

CREATE OR REPLACE TYPE BODY collection_type AS
    MEMBER FUNCTION get_average_price RETURN NUMBER IS
    BEGIN
        IF item_count > 0 THEN
            RETURN total_volume / item_count;
        ELSE
            RETURN 0;
        END IF;
    END;
    
    MEMBER PROCEDURE update_stats(new_sale_price IN NUMBER) IS
    BEGIN
        total_volume := total_volume + new_sale_price;
        IF floor_price = 0 OR new_sale_price < floor_price THEN
            floor_price := new_sale_price;
        END IF;
    END;
END;
/

-- Auction type for auction functionality
CREATE OR REPLACE TYPE auction_type AS OBJECT (
    auction_id NUMBER,
    starting_price NUMBER(15,2),
    current_highest_bid NUMBER(15,2),
    reserve_price NUMBER(15,2),
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    status VARCHAR2(20), -- 'ACTIVE', 'ENDED', 'CANCELLED'
    
    -- Member function to check if auction is active
    MEMBER FUNCTION is_active RETURN BOOLEAN,
    
    -- Member function to get time remaining
    MEMBER FUNCTION get_time_remaining RETURN INTERVAL DAY TO SECOND,
    
    -- Member procedure to place bid
    MEMBER PROCEDURE place_bid(bid_amount IN NUMBER)
);
/

CREATE OR REPLACE TYPE BODY auction_type AS
    MEMBER FUNCTION is_active RETURN BOOLEAN IS
    BEGIN
        RETURN status = 'ACTIVE' AND SYSTIMESTAMP BETWEEN start_time AND end_time;
    END;
    
    MEMBER FUNCTION get_time_remaining RETURN INTERVAL DAY TO SECOND IS
    BEGIN
        IF SYSTIMESTAMP < end_time THEN
            RETURN end_time - SYSTIMESTAMP;
        ELSE
            RETURN INTERVAL '0' DAY;
        END IF;
    END;
    
    MEMBER PROCEDURE place_bid(bid_amount IN NUMBER) IS
    BEGIN
        IF is_active() AND bid_amount > current_highest_bid THEN
            current_highest_bid := bid_amount;
        ELSE
            RAISE_APPLICATION_ERROR(-20001, 'Invalid bid or auction not active');
        END IF;
    END;
END;
/

-- Marketplace type for platform management
CREATE OR REPLACE TYPE marketplace_type AS OBJECT (
    marketplace_id NUMBER,
    name VARCHAR2(100),
    platform_fee_percentage NUMBER(5,2),
    total_volume NUMBER(18,2),
    total_transactions NUMBER,
    active_listings NUMBER,
    
    -- Member function to calculate daily volume
    MEMBER FUNCTION get_daily_volume RETURN NUMBER,
    
    -- Member procedure to update marketplace stats
    MEMBER PROCEDURE update_stats(transaction_amount IN NUMBER)
);
/

CREATE OR REPLACE TYPE BODY marketplace_type AS
    MEMBER FUNCTION get_daily_volume RETURN NUMBER IS
        daily_vol NUMBER := 0;
    BEGIN
        -- This would typically query recent transactions
        -- For demo purposes, returning estimated daily volume
        RETURN total_volume * 0.05; -- Estimate 5% of total volume per day
    END;
    
    MEMBER PROCEDURE update_stats(transaction_amount IN NUMBER) IS
    BEGIN
        total_volume := total_volume + transaction_amount;
        total_transactions := total_transactions + 1;
    END;
END;
/

-- Nested table types for aggregation
CREATE OR REPLACE TYPE bid_table_type AS TABLE OF bid_type;
/
CREATE OR REPLACE TYPE nft_table_type AS TABLE OF REF nft_type;
/
CREATE OR REPLACE TYPE transaction_table_type AS TABLE OF REF transaction_type;
/

-- Create tables with object-relational features
-- FIXED: Using substitutable object tables for inheritance

CREATE TABLE marketplace OF marketplace_type (
    PRIMARY KEY (marketplace_id)
) OBJECT IDENTIFIER IS SYSTEM GENERATED;

CREATE TABLE nft_collection OF collection_type (
    PRIMARY KEY (collection_id)
) OBJECT IDENTIFIER IS SYSTEM GENERATED;

-- Base creator table using substitutable object table
CREATE TABLE creator OF creator_type (
    PRIMARY KEY (creator_id),
    CONSTRAINT unique_wallet UNIQUE (wallet_address),
    CONSTRAINT unique_username UNIQUE (username)
) SUBSTITUTABLE AT ALL LEVELS
OBJECT IDENTIFIER IS SYSTEM GENERATED;

CREATE TABLE auction OF auction_type (
    PRIMARY KEY (auction_id)
) OBJECT IDENTIFIER IS SYSTEM GENERATED;

CREATE TABLE transaction_history OF transaction_type (
    PRIMARY KEY (transaction_id),
    CONSTRAINT unique_tx_hash UNIQUE (transaction_hash)
) OBJECT IDENTIFIER IS SYSTEM GENERATED;

CREATE TABLE nft (
    nft_id NUMBER PRIMARY KEY,
    token_id VARCHAR2(100) UNIQUE,
    title VARCHAR2(200),
    description CLOB,
    image_url VARCHAR2(500),
    metadata_url VARCHAR2(500),
    price NUMBER(15,2),
    royalty_percentage NUMBER(5,2),
    tags tag_array_type,
    created_at TIMESTAMP,
    last_sale_date TIMESTAMP,
    view_count NUMBER DEFAULT 0,
    like_count NUMBER DEFAULT 0,
    creator REF creator_type SCOPE IS creator,
    collection REF collection_type SCOPE IS nft_collection,
    current_owner_wallet VARCHAR2(100),
    auction REF auction_type SCOPE IS auction,
    transactions transaction_table_type,
    bids bid_table_type
) NESTED TABLE transactions STORE AS nft_transactions
  NESTED TABLE bids STORE AS nft_bids;

-- Create sequences
CREATE SEQUENCE creator_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE nft_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE transaction_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE collection_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE auction_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE marketplace_id_seq START WITH 1 INCREMENT BY 1;

-- Create indexes for performance
CREATE INDEX idx_nft_creator ON nft(creator);
CREATE INDEX idx_nft_collection ON nft(collection);
CREATE INDEX idx_nft_price ON nft(price);
CREATE INDEX idx_nft_created_at ON nft(created_at);
CREATE INDEX idx_transaction_timestamp ON transaction_history(transaction_timestamp);

-- Create object views for complex queries
CREATE OR REPLACE VIEW nft_marketplace_view AS
SELECT 
    n.nft_id,
    n.title,
    n.price,
    DEREF(n.creator).username AS creator_name,
    DEREF(n.creator).get_reputation_score() AS creator_reputation,
    DEREF(n.collection).name AS collection_name,
    n.view_count,
    n.like_count,
    n.created_at,
    CASE WHEN n.auction IS NOT NULL THEN 'AUCTION' ELSE 'FIXED_PRICE' END AS sale_type
FROM nft n;

CREATE OR REPLACE VIEW creator_analytics_view AS
SELECT 
    c.creator_id,
    c.username,
    c.total_earnings,
    c.total_sales,
    c.get_reputation_score() AS reputation_score,
    c.get_creator_status() AS status,
    CASE 
        WHEN VALUE(c) IS OF (premium_creator_type) THEN 'Premium'
        WHEN VALUE(c) IS OF (verified_creator_type) THEN 'Verified'
        ELSE 'Standard'
    END AS account_type
FROM creator c;

-- Create triggers for object-relational behavior

-- Trigger to log NFT creation
CREATE OR REPLACE TRIGGER trg_nft_creation
AFTER INSERT ON nft
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('NFT ' || :NEW.nft_id || ' "' || :NEW.title || '" created by ' || 
                         :NEW.current_owner_wallet);
    
    -- Update collection item count
    UPDATE nft_collection c 
    SET c.item_count = c.item_count + 1 
    WHERE REF(c) = :NEW.collection;
END;
/

-- Trigger to process sale transactions
CREATE OR REPLACE TRIGGER trg_sale_transaction
AFTER INSERT ON transaction_history
FOR EACH ROW
WHEN (NEW.transaction_type = 'SALE')
DECLARE
    v_creator_ref REF creator_type;
    v_creator creator_type;
    v_royalty_amount NUMBER;
BEGIN
    -- Calculate and distribute royalties
    -- Note: This is a simplified example
    v_royalty_amount := :NEW.amount * 0.05; -- 5% royalty
    
    DBMS_OUTPUT.PUT_LINE('Sale transaction processed: ' || :NEW.transaction_hash || 
                         ', Royalty: ' || v_royalty_amount);
END;
/

-- Trigger for creator registration
CREATE OR REPLACE TRIGGER trg_creator_registration
BEFORE INSERT ON creator
FOR EACH ROW
BEGIN
    :NEW.created_at := SYSTIMESTAMP;
    :NEW.total_sales := 0;
    :NEW.total_earnings := 0;
    DBMS_OUTPUT.PUT_LINE('New creator registered: ' || :NEW.username);
END;
/

-- Trigger for auction bids
CREATE OR REPLACE TRIGGER trg_auction_bid
BEFORE UPDATE OF current_highest_bid ON auction
FOR EACH ROW
BEGIN
    IF :NEW.current_highest_bid <= :OLD.current_highest_bid THEN
        RAISE_APPLICATION_ERROR(-20002, 'Bid must be higher than current highest bid');
    END IF;
    DBMS_OUTPUT.PUT_LINE('New bid placed: ' || :NEW.current_highest_bid);
END;
/

-- Create procedures with object-relational features

-- Procedure to create an NFT
CREATE OR REPLACE PROCEDURE create_nft(
    p_token_id IN VARCHAR2,
    p_title IN VARCHAR2,
    p_description IN CLOB,
    p_image_url IN VARCHAR2,
    p_price IN NUMBER,
    p_creator_id IN NUMBER,
    p_collection_id IN NUMBER,
    p_tags IN tag_array_type DEFAULT NULL,
    p_nft_id OUT NUMBER
) AS
    v_creator_ref REF creator_type;
    v_collection_ref REF collection_type;
BEGIN
    -- Get references
    SELECT REF(c) INTO v_creator_ref FROM creator c WHERE c.creator_id = p_creator_id;
    SELECT REF(col) INTO v_collection_ref FROM nft_collection col WHERE col.collection_id = p_collection_id;
    
    -- Generate new NFT ID
    SELECT nft_id_seq.NEXTVAL INTO p_nft_id FROM dual;
    
    -- Insert NFT
    INSERT INTO nft VALUES (
        p_nft_id,
        p_token_id,
        p_title,
        p_description,
        p_image_url,
        NULL, -- metadata_url
        p_price,
        5.0, -- default 5% royalty
        p_tags,
        SYSTIMESTAMP,
        NULL,
        0, -- view_count
        0, -- like_count
        v_creator_ref,
        v_collection_ref,
        DEREF(v_creator_ref).wallet_address,
        NULL, -- auction
        transaction_table_type(),
        bid_table_type()
    );
    
    DBMS_OUTPUT.PUT_LINE('NFT created with ID: ' || p_nft_id);
END;
/

-- Procedure to process a sale
CREATE OR REPLACE PROCEDURE process_sale(
    p_nft_id IN NUMBER,
    p_buyer_wallet IN VARCHAR2,
    p_sale_price IN NUMBER,
    p_transaction_hash IN VARCHAR2
) AS
    v_transaction_ref REF transaction_type;
    v_transaction_id NUMBER;
    v_platform_fee NUMBER;
    v_gas_fee NUMBER := 0.01; -- Estimated gas fee
BEGIN
    -- Calculate platform fee
    v_platform_fee := transaction_type.calculate_platform_fee(p_sale_price);
    
    -- Create transaction record
    SELECT transaction_id_seq.NEXTVAL INTO v_transaction_id FROM dual;
    INSERT INTO transaction_history VALUES (
        transaction_type(
            v_transaction_id,
            p_transaction_hash,
            'SALE',
            p_sale_price,
            v_platform_fee,
            v_gas_fee,
            SYSTIMESTAMP,
            1000000 + v_transaction_id -- Mock block number
        )
    ) RETURNING REF(t) INTO v_transaction_ref;
    
    -- Update NFT ownership and last sale date
    UPDATE nft n 
    SET n.current_owner_wallet = p_buyer_wallet,
        n.last_sale_date = SYSTIMESTAMP,
        n.transactions = n.transactions MULTISET UNION transaction_table_type(v_transaction_ref)
    WHERE n.nft_id = p_nft_id;
    
    DBMS_OUTPUT.PUT_LINE('Sale processed for NFT ' || p_nft_id);
END;
/

-- Procedure to manage auctions
CREATE OR REPLACE PROCEDURE manage_auction(
    p_action IN VARCHAR2,
    p_nft_id IN NUMBER,
    p_starting_price IN NUMBER DEFAULT NULL,
    p_duration_hours IN NUMBER DEFAULT NULL,
    p_bid_amount IN NUMBER DEFAULT NULL,
    p_bidder_wallet IN VARCHAR2 DEFAULT NULL
) AS
    v_auction_ref REF auction_type;
    v_auction_id NUMBER;
    v_new_bid bid_type;
BEGIN
    CASE p_action
        WHEN 'CREATE' THEN
            SELECT auction_id_seq.NEXTVAL INTO v_auction_id FROM dual;
            INSERT INTO auction VALUES (
                auction_type(
                    v_auction_id,
                    p_starting_price,
                    0,
                    p_starting_price * 0.8, -- Reserve price 80% of starting
                    SYSTIMESTAMP,
                    SYSTIMESTAMP + NUMTODSINTERVAL(p_duration_hours, 'HOUR'),
                    'ACTIVE'
                )
            ) RETURNING REF(a) INTO v_auction_ref;
            
            UPDATE nft SET auction = v_auction_ref WHERE nft_id = p_nft_id;
            
        WHEN 'BID' THEN
            v_new_bid := bid_type(p_bidder_wallet, p_bid_amount, SYSTIMESTAMP);
            
            UPDATE nft n 
            SET n.bids = n.bids MULTISET UNION bid_table_type(v_new_bid)
            WHERE n.nft_id = p_nft_id;
            
            UPDATE auction a 
            SET a.current_highest_bid = p_bid_amount 
            WHERE REF(a) = (SELECT auction FROM nft WHERE nft_id = p_nft_id);
            
        WHEN 'END' THEN
            UPDATE auction a 
            SET a.status = 'ENDED' 
            WHERE REF(a) = (SELECT auction FROM nft WHERE nft_id = p_nft_id);
            
        ELSE
            RAISE_APPLICATION_ERROR(-20003, 'Invalid auction action');
    END CASE;
    
    DBMS_OUTPUT.PUT_LINE('Auction action ' || p_action || ' completed for NFT ' || p_nft_id);
END;
/

-- Procedure to calculate royalties
CREATE OR REPLACE PROCEDURE calculate_royalties(
    p_nft_id IN NUMBER,
    p_sale_price IN NUMBER,
    p_royalty_amount OUT NUMBER,
    p_creator_earnings OUT NUMBER
) AS
    v_nft nft%ROWTYPE;
    v_creator creator_type;
BEGIN
    -- Get NFT details
    SELECT * INTO v_nft FROM nft WHERE nft_id = p_nft_id;
    
    -- Calculate royalty
    p_royalty_amount := p_sale_price * (v_nft.royalty_percentage / 100);
    
    -- Get creator and update earnings
    v_creator := DEREF(v_nft.creator);
    v_creator.update_earnings(p_royalty_amount);
    p_creator_earnings := v_creator.total_earnings;
    
    DBMS_OUTPUT.PUT_LINE('Royalty calculated: ' || p_royalty_amount || ' for creator ' || v_creator.username);
END;
/

-- Create functions with object-relational features

-- Function to get creator earnings
CREATE OR REPLACE FUNCTION get_creator_earnings(
    p_creator_id IN NUMBER,
    p_period_days IN NUMBER DEFAULT 30
) RETURN NUMBER IS
    v_earnings NUMBER := 0;
    v_creator_ref REF creator_type;
BEGIN
    SELECT REF(c) INTO v_creator_ref FROM creator c WHERE c.creator_id = p_creator_id;
    
    SELECT SUM(t.amount * 0.05) INTO v_earnings
    FROM nft n, TABLE(n.transactions) tr, transaction_history t
    WHERE n.creator = v_creator_ref
    AND tr.COLUMN_VALUE = REF(t)
    AND t.transaction_timestamp > SYSTIMESTAMP - NUMTODSINTERVAL(p_period_days, 'DAY');
    
    RETURN NVL(v_earnings, 0);
END;
/

-- Function to calculate platform fees
CREATE OR REPLACE FUNCTION calculate_platform_fees(
    p_start_date IN TIMESTAMP,
    p_end_date IN TIMESTAMP
) RETURN NUMBER IS
    v_total_fees NUMBER := 0;
BEGIN
    SELECT SUM(platform_fee) INTO v_total_fees
    FROM transaction_history
    WHERE transaction_timestamp BETWEEN p_start_date AND p_end_date;
    
    RETURN NVL(v_total_fees, 0);
END;
/

-- Function to get NFT market value
CREATE OR REPLACE FUNCTION get_nft_market_value(p_nft_id IN NUMBER) RETURN NUMBER IS
    v_market_value NUMBER;
    v_nft nft%ROWTYPE;
    v_collection collection_type;
BEGIN
    SELECT * INTO v_nft FROM nft WHERE nft_id = p_nft_id;
    v_collection := DEREF(v_nft.collection);
    
    -- Calculate market value based on collection floor price and NFT attributes
    v_market_value := v_collection.floor_price * 
                     (1 + (v_nft.view_count / 10000) + (v_nft.like_count / 1000));
    
    RETURN v_market_value;
END;
/

-- Function to get collection statistics
CREATE OR REPLACE FUNCTION get_collection_stats(p_collection_id IN NUMBER) 
RETURN VARCHAR2 IS
    v_collection collection_type;
    v_stats VARCHAR2(500);
BEGIN
    SELECT VALUE(c) INTO v_collection FROM nft_collection c WHERE c.collection_id = p_collection_id;
    
    v_stats := 'Collection: ' || v_collection.name || 
               ', Items: ' || v_collection.item_count ||
               ', Floor Price: ' || v_collection.floor_price ||
               ', Total Volume: ' || v_collection.total_volume ||
               ', Avg Price: ' || v_collection.get_average_price();
    
    RETURN v_stats;
END;
/

-- Insert sample data using object constructors

-- Sample marketplace
INSERT INTO marketplace VALUES (
    marketplace_type(marketplace_id_seq.NEXTVAL, 'NFTopia Marketplace', 2.5, 0, 0, 0)
);

-- Sample collections
INSERT INTO nft_collection VALUES (
    collection_type(collection_id_seq.NEXTVAL, 'Digital Dreams', 'Surreal digital art collection', 
                   'https://example.com/collections/digital-dreams.jpg', 0.5, 0, 0, SYSTIMESTAMP)
);

INSERT INTO nft_collection VALUES (
    collection_type(collection_id_seq.NEXTVAL, 'Pixel Perfect', 'Retro pixel art masterpieces', 
                   'https://example.com/collections/pixel-perfect.jpg', 0.3, 0, 0, SYSTIMESTAMP)
);

INSERT INTO nft_collection VALUES (
    collection_type(collection_id_seq.NEXTVAL, 'Abstract Expressions', 'Contemporary abstract digital art', 
                   'https://example.com/collections/abstract.jpg', 1.2, 0, 0, SYSTIMESTAMP)
);

-- Sample creators using substitutable object table
INSERT INTO creator VALUES (
    creator_type(creator_id_seq.NEXTVAL, '0x1234567890abcdef1234567890abcdef12345678', 'ArtMaster3000', 
                'artist@example.com', 'Digital artist specializing in surreal landscapes', 
                'https://example.com/profiles/artmaster.jpg', SYSTIMESTAMP, 0, 0)
);

INSERT INTO creator VALUES (
    creator_type(creator_id_seq.NEXTVAL, '0xabcdef1234567890abcdef1234567890abcdef12', 'PixelWizard', 
                'pixel@example.com', 'Retro game-inspired pixel artist', 
                'https://example.com/profiles/pixelwizard.jpg', SYSTIMESTAMP, 0, 0)
);

INSERT INTO creator VALUES (
    creator_type(creator_id_seq.NEXTVAL, '0x9876543210fedcba9876543210fedcba98765432', 'AbstractGenius', 
                'abstract@example.com', 'Contemporary abstract digital artist', 
                'https://example.com/profiles/abstract.jpg', SYSTIMESTAMP, 0, 0)
);

INSERT INTO creator VALUES (
    creator_type(creator_id_seq.NEXTVAL, '0x5555666677778888999900001111222233334444', 'CryptoCreator', 
                'crypto@example.com', 'Blockchain-native digital artist', 
                'https://example.com/profiles/crypto.jpg', SYSTIMESTAMP, 0, 0)
);

-- Sample verified creators (using substitution)
INSERT INTO creator VALUES (
    verified_creator_type(5, '0x7777888899990000111122223333444455556666', 'VerifiedArtist', 
                         'verified@example.com', 'Verified digital artist with gold tier', 
                         'https://example.com/profiles/verified.jpg', SYSTIMESTAMP, 0, 0,
                         SYSTIMESTAMP - INTERVAL '30' DAY, 'Gold')
);

INSERT INTO creator VALUES (
    verified_creator_type(6, '0x8888999900001111222233334444555566667777', 'SilverCreator', 
                         'silver@example.com', 'Silver tier verified creator', 
                         'https://example.com/profiles/silver.jpg', SYSTIMESTAMP, 0, 0,
                         SYSTIMESTAMP - INTERVAL '60' DAY, 'Silver')
);

-- Sample premium creator (using substitution)
INSERT INTO creator VALUES (
    premium_creator_type(7, '0x9999000011112222333344445555666677778888', 'PremiumMaster', 
                        'premium@example.com', 'Premium tier digital artist with exclusive features', 
                        'https://example.com/profiles/premium.jpg', SYSTIMESTAMP, 0, 0,
                        SYSTIMESTAMP - INTERVAL '45' DAY, 'Gold',
                        SYSTIMESTAMP - INTERVAL '15' DAY, 
                        tag_array_type('Early Access', 'Custom Marketplace', 'Priority Support'))
);

-- Sample auctions
INSERT INTO auction VALUES (
    auction_type(auction_id_seq.NEXTVAL, 1.0, 0, 0.8, 
                SYSTIMESTAMP, SYSTIMESTAMP + INTERVAL '7' DAY, 'ACTIVE')
);

INSERT INTO auction VALUES (
    auction_type(auction_id_seq.NEXTVAL, 2.5, 3.1, 2.0, 
                SYSTIMESTAMP - INTERVAL '2' DAY, SYSTIMESTAMP + INTERVAL '5' DAY, 'ACTIVE')
);

-- Sample transactions
INSERT INTO transaction_history VALUES (
    transaction_type(transaction_id_seq.NEXTVAL, '0xtx1234567890abcdef', 'SALE', 2.5, 0.0625, 0.01, 
                    SYSTIMESTAMP - INTERVAL '1' DAY, 1000001)
);

INSERT INTO transaction_history VALUES (
    transaction_type(transaction_id_seq.NEXTVAL, '0xtx2345678901bcdef0', 'SALE', 1.8, 0.045, 0.008, 
                    SYSTIMESTAMP - INTERVAL '3' DAY, 1000002)
);

INSERT INTO transaction_history VALUES (
    transaction_type(transaction_id_seq.NEXTVAL, '0xtx3456789012cdef01', 'AUCTION', 3.2, 0.08, 0.012, 
                    SYSTIMESTAMP - INTERVAL '5' DAY, 1000003)
);

-- Sample NFTs
DECLARE
    v_nft_id NUMBER;
    v_creator_ref REF creator_type;
    v_collection_ref REF collection_type;
    v_auction_ref REF auction_type;
    v_transaction_refs transaction_table_type := transaction_table_type();
    v_bids bid_table_type := bid_table_type();
BEGIN
    -- Get references
    SELECT REF(c) INTO v_creator_ref FROM creator c WHERE c.creator_id = 1;
    SELECT REF(col) INTO v_collection_ref FROM nft_collection col WHERE col.collection_id = 1;
    SELECT REF(a) INTO v_auction_ref FROM auction a WHERE a.auction_id = 1;
    
    -- Get transaction references
    SELECT REF(t) BULK COLLECT INTO v_transaction_refs 
    FROM transaction_history t WHERE t.transaction_id IN (1, 2);
    
    -- Create sample bids
    v_bids.EXTEND(3);
    v_bids(1) := bid_type('0xbidder1111222233334444555566667777888899990', 1.2, SYSTIMESTAMP - INTERVAL '2' HOUR);
    v_bids(2) := bid_type('0xbidder2222333344445555666677778888999900001', 1.5, SYSTIMESTAMP - INTERVAL '1' HOUR);
    v_bids(3) := bid_type('0xbidder3333444455556666777788889999000011112', 1.8, SYSTIMESTAMP - INTERVAL '30' MINUTE);
    
    -- Insert NFT 1
    INSERT INTO nft VALUES (
        nft_id_seq.NEXTVAL,
        'TOKEN_001',
        'Ethereal Dreamscape',
        'A mesmerizing digital landscape that blurs the line between reality and dreams',
        'https://example.com/nfts/dreamscape.jpg',
        'https://example.com/metadata/dreamscape.json',
        2.5,
        7.5,
        tag_array_type('surreal', 'landscape', 'digital art', 'dreams'),
        SYSTIMESTAMP - INTERVAL '10' DAY,
        SYSTIMESTAMP - INTERVAL '1' DAY,
        1250,
        89,
        v_creator_ref,
        v_collection_ref,
        '0x1234567890abcdef1234567890abcdef12345678',
        v_auction_ref,
        v_transaction_refs,
        v_bids
    );
END;
/

-- Additional NFTs
DECLARE
    v_creator_ref REF creator_type;
    v_collection_ref REF collection_type;
BEGIN
    SELECT REF(c) INTO v_creator_ref FROM creator c WHERE c.creator_id = 2;
    SELECT REF(col) INTO v_collection_ref FROM nft_collection col WHERE col.collection_id = 2;
    
    INSERT INTO nft VALUES (
        nft_id_seq.NEXTVAL,
        'TOKEN_002',
        '8-Bit Warriors',
        'Classic retro-style warriors ready for digital battle',
        'https://example.com/nfts/8bit-warriors.jpg',
        'https://example.com/metadata/8bit-warriors.json',
        1.2,
        5.0,
        tag_array_type('pixel art', 'retro', 'gaming', 'warriors'),
        SYSTIMESTAMP - INTERVAL '5' DAY,
        NULL,
        850,
        156,
        v_creator_ref,
        v_collection_ref,
        '0xabcdef1234567890abcdef1234567890abcdef12',
        NULL,
        transaction_table_type(),
        bid_table_type()
    );
END;
/

DECLARE
    v_creator_ref REF creator_type;
    v_collection_ref REF collection_type;
BEGIN
    SELECT REF(c) INTO v_creator_ref FROM creator c WHERE c.creator_id = 3;
    SELECT REF(col) INTO v_collection_ref FROM nft_collection col WHERE col.collection_id = 3;
    
    INSERT INTO nft VALUES (
        nft_id_seq.NEXTVAL,
        'TOKEN_003',
        'Chaos Theory Visualization',
        'Mathematical beauty expressed through abstract digital forms',
        'https://example.com/nfts/chaos-theory.jpg',
        'https://example.com/metadata/chaos-theory.json',
        4.8,
        10.0,
        tag_array_type('abstract', 'mathematics', 'chaos theory', 'contemporary'),
        SYSTIMESTAMP - INTERVAL '3' DAY,
        SYSTIMESTAMP - INTERVAL '2' DAY,
        2100,
        234,
        v_creator_ref,
        v_collection_ref,
        '0x9876543210fedcba9876543210fedcba98765432',
        NULL,
        transaction_table_type(),
        bid_table_type()
    );
END;
/

-- More NFTs for comprehensive testing
DECLARE
    v_creator_ref REF creator_type;
    v_collection_ref REF collection_type;
BEGIN
    SELECT REF(c) INTO v_creator_ref FROM creator c WHERE c.creator_id = 4;
    SELECT REF(col) INTO v_collection_ref FROM nft_collection col WHERE col.collection_id = 1;
    
    INSERT INTO nft VALUES (
        nft_id_seq.NEXTVAL,
        'TOKEN_004',
        'Blockchain Genesis',
        'The birth of a new digital era captured in art',
        'https://example.com/nfts/blockchain-genesis.jpg',
        'https://example.com/metadata/blockchain-genesis.json',
        3.3,
        6.0,
        tag_array_type('blockchain', 'genesis', 'digital era', 'technology'),
        SYSTIMESTAMP - INTERVAL '7' DAY,
        SYSTIMESTAMP - INTERVAL '4' DAY,
        1750,
        198,
        v_creator_ref,
        v_collection_ref,
        '0x5555666677778888999900001111222233334444',
        NULL,
        transaction_table_type(),
        bid_table_type()
    );
END;
/

-- NFT from verified creator
DECLARE
    v_creator_ref REF creator_type;
    v_collection_ref REF collection_type;
BEGIN
    SELECT REF(c) INTO v_creator_ref FROM creator c WHERE c.creator_id = 5;
    SELECT REF(col) INTO v_collection_ref FROM nft_collection col WHERE col.collection_id = 2;
    
    INSERT INTO nft VALUES (
        nft_id_seq.NEXTVAL,
        'TOKEN_005',
        'Verified Masterpiece',
        'An exclusive artwork from a verified gold-tier creator',
        'https://example.com/nfts/verified-masterpiece.jpg',
        'https://example.com/metadata/verified-masterpiece.json',
        5.5,
        8.0,
        tag_array_type('verified', 'exclusive', 'premium', 'masterpiece'),
        SYSTIMESTAMP - INTERVAL '2' DAY,
        NULL,
        2500,
        345,
        v_creator_ref,
        v_collection_ref,
        '0x7777888899990000111122223333444455556666',
        NULL,
        transaction_table_type(),
        bid_table_type()
    );
END;
/

-- NFT from premium creator
DECLARE
    v_creator_ref REF creator_type;
    v_collection_ref REF collection_type;
BEGIN
    SELECT REF(c) INTO v_creator_ref FROM creator c WHERE c.creator_id = 7;
    SELECT REF(col) INTO v_collection_ref FROM nft_collection col WHERE col.collection_id = 3;
    
    INSERT INTO nft VALUES (
        nft_id_seq.NEXTVAL,
        'TOKEN_006',
        'Premium Collection #1',
        'First piece from an exclusive premium creator collection',
        'https://example.com/nfts/premium-collection-1.jpg',
        'https://example.com/metadata/premium-collection-1.json',
        8.8,
        12.0,
        tag_array_type('premium', 'exclusive', 'collection', 'first edition'),
        SYSTIMESTAMP - INTERVAL '1' DAY,
        NULL,
        3200,
        456,
        v_creator_ref,
        v_collection_ref,
        '0x9999000011112222333344445555666677778888',
        NULL,
        transaction_table_type(),
        bid_table_type()
    );
END;
/

-- Update collection statistics
UPDATE nft_collection c SET 
    c.item_count = (SELECT COUNT(*) FROM nft n WHERE n.collection = REF(c)),
    c.total_volume = (SELECT NVL(SUM(n.price), 0) FROM nft n WHERE n.collection = REF(c)),
    c.floor_price = (SELECT NVL(MIN(n.price), 0) FROM nft n WHERE n.collection = REF(c));

-- Update creator earnings based on sales
UPDATE creator c SET 
    c.total_sales = (SELECT COUNT(*) FROM nft n WHERE n.creator = REF(c)),
    c.total_earnings = (SELECT NVL(SUM(n.price * 0.075), 0) FROM nft n WHERE n.creator = REF(c) AND n.last_sale_date IS NOT NULL);

COMMIT;

-- Demonstrate object methods and inheritance
DECLARE
    v_creator creator_type;
    v_verified verified_creator_type;
    v_premium premium_creator_type;
    v_nft nft%ROWTYPE;
    v_collection collection_type;
    v_transaction transaction_type;
    v_auction auction_type;
BEGIN
    -- Demonstrate creator hierarchy methods
    SELECT VALUE(c) INTO v_creator FROM creator c WHERE c.creator_id = 1;
    DBMS_OUTPUT.PUT_LINE('Creator Info: ' || v_creator.get_creator_status());
    DBMS_OUTPUT.PUT_LINE('Reputation Score: ' || v_creator.get_reputation_score());
    
    -- Demonstrate verified creator methods
    SELECT TREAT(VALUE(c) AS verified_creator_type) INTO v_verified 
    FROM creator c WHERE c.creator_id = 5;
    DBMS_OUTPUT.PUT_LINE('Verified Creator Status: ' || v_verified.get_creator_status());
    DBMS_OUTPUT.PUT_LINE('Verification Benefits: ' || v_verified.get_verification_benefits());
    
    -- Demonstrate premium creator methods
    SELECT TREAT(VALUE(c) AS premium_creator_type) INTO v_premium 
    FROM creator c WHERE c.creator_id = 7;
    DBMS_OUTPUT.PUT_LINE('Premium Creator Status: ' || v_premium.get_creator_status());
    DBMS_OUTPUT.PUT_LINE('Premium Features: ' || v_premium.get_premium_features());
    
    -- Demonstrate collection methods
    SELECT VALUE(c) INTO v_collection FROM nft_collection c WHERE c.collection_id = 1;
    DBMS_OUTPUT.PUT_LINE('Collection Average Price: ' || v_collection.get_average_price());
    
    -- Demonstrate transaction methods
    SELECT VALUE(t) INTO v_transaction FROM transaction_history t WHERE t.transaction_id = 1;
    DBMS_OUTPUT.PUT_LINE('Transaction Total Cost: ' || v_transaction.get_total_cost());
    DBMS_OUTPUT.PUT_LINE('Transaction Age: ' || v_transaction.get_transaction_age());
    
    -- Demonstrate auction methods
    SELECT VALUE(a) INTO v_auction FROM auction a WHERE a.auction_id = 1;
    DBMS_OUTPUT.PUT_LINE('Auction Active: ' || CASE WHEN v_auction.is_active() THEN 'Yes' ELSE 'No' END);
    DBMS_OUTPUT.PUT_LINE('Time Remaining: ' || v_auction.get_time_remaining());
END;
/

-- THE 5 REQUIRED COMPLEX QUERIES:

-- Query 1: JOIN of three or more tables with multiple join types and restrictions
-- Natural Language: Show comprehensive NFT marketplace data with creator verification status, 
-- collection performance, and recent transaction activity for NFTs with high engagement
SELECT 
    n.nft_id,
    n.title AS nft_title,
    n.price AS current_price,
    n.view_count,
    n.like_count,
    DEREF(n.creator).username AS creator_name,
    DEREF(n.creator).get_reputation_score() AS creator_reputation,
    CASE 
        WHEN VALUE(c) IS OF (premium_creator_type) THEN 'Premium'
        WHEN VALUE(c) IS OF (verified_creator_type) THEN 'Verified'
        ELSE 'Standard'
    END AS creator_tier,
    DEREF(n.collection).name AS collection_name,
    DEREF(n.collection).floor_price AS collection_floor,
    t.transaction_hash,
    t.amount AS last_sale_amount,
    t.transaction_timestamp AS last_sale_date,
    a.current_highest_bid,
    a.end_time AS auction_end_time
FROM nft n
INNER JOIN creator c ON n.creator = REF(c)
LEFT OUTER JOIN transaction_history t ON t.transaction_id = (
    SELECT MAX(th.transaction_id) 
    FROM transaction_history th, TABLE(n.transactions) nt 
    WHERE REF(th) = nt.COLUMN_VALUE
)
RIGHT OUTER JOIN auction a ON n.auction = REF(a)
WHERE n.view_count > 500 AND n.like_count > 25
ORDER BY n.view_count DESC, n.like_count DESC;

-- Query 2: UNION operation involving multiple tables
-- Natural Language: Get all wallet addresses that are either NFT creators or current NFT owners,
-- along with their role and associated counts
SELECT wallet_address, role_type, item_count, total_value
FROM (
    SELECT 
        c.wallet_address,
        'Creator' AS role_type,
        COUNT(*) AS item_count,
        SUM(n.price) AS total_value
    FROM creator c
    INNER JOIN nft n ON n.creator = REF(c)
    GROUP BY c.wallet_address
    
    UNION
    
    SELECT 
        n.current_owner_wallet AS wallet_address,
        'Owner' AS role_type,
        COUNT(*) AS item_count,
        SUM(n.price) AS total_value
    FROM nft n
    WHERE n.current_owner_wallet IS NOT NULL
    GROUP BY n.current_owner_wallet
)
ORDER BY total_value DESC, item_count DESC;

-- Query 3: Query using inheritance hierarchy and nested tables
-- Natural Language: Display NFT details with creator type-specific information and bid history
-- for NFTs that have active auctions
SELECT 
    n.nft_id,
    n.title,
    n.price,
    CASE 
        WHEN VALUE(c) IS OF (premium_creator_type) THEN 
            TREAT(VALUE(c) AS premium_creator_type).get_premium_features()
        WHEN VALUE(c) IS OF (verified_creator_type) THEN 
            TREAT(VALUE(c) AS verified_creator_type).get_verification_benefits()
        ELSE 'Standard creator benefits'
    END AS creator_benefits,
    VALUE(c).get_creator_status() AS creator_status,
    CARDINALITY(n.bids) AS total_bids,
    (SELECT MAX(b.bid_amount) FROM TABLE(n.bids) b) AS highest_bid,
    (SELECT b.bidder_wallet FROM TABLE(n.bids) b 
     WHERE b.bid_amount = (SELECT MAX(b2.bid_amount) FROM TABLE(n.bids) b2)) AS highest_bidder
FROM nft n, creator c
WHERE n.creator = REF(c)
AND n.auction IS NOT NULL
AND CARDINALITY(n.bids) > 0
ORDER BY (SELECT MAX(b.bid_amount) FROM TABLE(n.bids) b) DESC;

-- Query 4: Query using temporal features with intervals and timestamps
-- Natural Language: Analyze NFT market activity over different time periods using temporal operations
SELECT 
    time_period,
    COUNT(*) AS transaction_count,
    AVG(amount) AS avg_transaction_value,
    SUM(amount) AS total_volume,
    AVG(EXTRACT(HOUR FROM (SYSTIMESTAMP - transaction_timestamp))) AS avg_hours_ago
FROM (
    SELECT 
        t.transaction_id,
        t.amount,
        t.transaction_timestamp,
        CASE 
            WHEN t.transaction_timestamp > SYSTIMESTAMP - INTERVAL '1' DAY THEN 'Last 24 Hours'
            WHEN t.transaction_timestamp > SYSTIMESTAMP - INTERVAL '7' DAY THEN 'Last Week'
            WHEN t.transaction_timestamp > SYSTIMESTAMP - INTERVAL '30' DAY THEN 'Last Month'
            ELSE 'Older'
        END AS time_period
    FROM transaction_history t
    WHERE t.transaction_type = 'SALE'
    AND t.transaction_timestamp > SYSTIMESTAMP - INTERVAL '90' DAY
)
GROUP BY time_period
HAVING COUNT(*) > 0
ORDER BY 
    CASE time_period
        WHEN 'Last 24 Hours' THEN 1
        WHEN 'Last Week' THEN 2
        WHEN 'Last Month' THEN 3
        ELSE 4
    END;

-- Query 5: OLAP query with ROLLUP and CUBE features
-- Natural Language: Comprehensive marketplace analytics with multi-dimensional aggregations
-- by creator tier, collection, and time periods
SELECT 
    creator_tier,
    collection_name,
    time_bucket,
    COUNT(*) AS nft_count,
    AVG(price) AS avg_price,
    SUM(price) AS total_value,
    AVG(view_count) AS avg_views,
    SUM(like_count) AS total_likes,
    GROUPING(creator_tier) AS tier_grouping,
    GROUPING(collection_name) AS collection_grouping,
    GROUPING(time_bucket) AS time_grouping
FROM (
    SELECT 
        n.nft_id,
        n.price,
        n.view_count,
        n.like_count,
        CASE 
            WHEN VALUE(c) IS OF (premium_creator_type) THEN 'Premium'
            WHEN VALUE(c) IS OF (verified_creator_type) THEN 'Verified'
            ELSE 'Standard'
        END AS creator_tier,
        DEREF(n.collection).name AS collection_name,
        CASE 
            WHEN n.created_at > SYSTIMESTAMP - INTERVAL '7' DAY THEN 'This Week'
            WHEN n.created_at > SYSTIMESTAMP - INTERVAL '30' DAY THEN 'This Month'
            ELSE 'Older'
        END AS time_bucket
    FROM nft n, creator c
    WHERE n.creator = REF(c)
)
GROUP BY ROLLUP(creator_tier, collection_name, time_bucket)
HAVING COUNT(*) > 0
ORDER BY 
    GROUPING(creator_tier),
    GROUPING(collection_name), 
    GROUPING(time_bucket),
    creator_tier NULLS LAST,
    collection_name NULLS LAST,
    time_bucket NULLS LAST;

-- Demonstrate stored procedure usage with one of the queries
CREATE OR REPLACE PROCEDURE get_marketplace_analytics(
    p_days_back IN NUMBER DEFAULT 30,
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR
    SELECT 
        creator_tier,
        collection_name,
        COUNT(*) AS nft_count,
        AVG(price) AS avg_price,
        SUM(price) AS total_value,
        AVG(view_count) AS avg_views
    FROM (
        SELECT 
            n.price,
            n.view_count,
            CASE 
                WHEN VALUE(c) IS OF (premium_creator_type) THEN 'Premium'
                WHEN VALUE(c) IS OF (verified_creator_type) THEN 'Verified'
                ELSE 'Standard'
            END AS creator_tier,
            DEREF(n.collection).name AS collection_name
        FROM nft n, creator c
        WHERE n.creator = REF(c)
        AND n.created_at > SYSTIMESTAMP - NUMTODSINTERVAL(p_days_back, 'DAY')
    )
    GROUP BY CUBE(creator_tier, collection_name)
    ORDER BY total_value DESC NULLS LAST;
END;
/

-- Demonstrate stored function usage in a query
CREATE OR REPLACE FUNCTION get_trending_score(
    p_view_count IN NUMBER,
    p_like_count IN NUMBER,
    p_days_since_creation IN NUMBER
) RETURN NUMBER IS
    v_score NUMBER;
BEGIN
    v_score := (p_view_count * 0.6 + p_like_count * 2.5) / GREATEST(p_days_since_creation, 1);
    RETURN ROUND(v_score, 2);
END;
/

-- Query using the stored function
SELECT 
    n.nft_id,
    n.title,
    n.view_count,
    n.like_count,
    EXTRACT(DAY FROM (SYSTIMESTAMP - n.created_at)) AS days_old,
    get_trending_score(
        n.view_count, 
        n.like_count, 
        EXTRACT(DAY FROM (SYSTIMESTAMP - n.created_at))
    ) AS trending_score
FROM nft n
ORDER BY trending_score DESC;

COMMIT;