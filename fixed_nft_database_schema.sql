-- Digital Art NFT Marketplace & Creator Economy - Oracle Object-Relational Database (CORRECTED)
-- This script creates a comprehensive NFT marketplace system using Oracle's object-relational features

-- First, create the basic array type for tags
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

-- Base Creator type (NOT FINAL for inheritance) - FIXED: Removed FINAL
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
    MEMBER PROCEDURE update_earnings(p_amount IN NUMBER),
    
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
    
    MEMBER PROCEDURE update_earnings(p_amount IN NUMBER) IS
    BEGIN
        total_earnings := total_earnings + p_amount;
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
    MEMBER PROCEDURE place_bid(p_bid_amount IN NUMBER)
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
    
    MEMBER PROCEDURE place_bid(p_bid_amount IN NUMBER) IS
    BEGIN
        IF is_active() AND p_bid_amount > current_highest_bid THEN
            current_highest_bid := p_bid_amount;
        ELSE
            RAISE_APPLICATION_ERROR(-20001, 'Invalid bid or auction not active');
        END IF;
    END;
END;
/

-- Transaction type for marketplace operations
CREATE OR REPLACE TYPE transaction_type AS OBJECT (
    transaction_id NUMBER,
    transaction_hash VARCHAR2(100),
    transaction_type_name VARCHAR2(20), -- 'SALE', 'AUCTION', 'TRANSFER'
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
    STATIC FUNCTION calculate_platform_fee(p_amount IN NUMBER) RETURN NUMBER
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
    
    STATIC FUNCTION calculate_platform_fee(p_amount IN NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN p_amount * 0.025; -- 2.5% platform fee
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
    MEMBER PROCEDURE update_stats(p_transaction_amount IN NUMBER)
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
    
    MEMBER PROCEDURE update_stats(p_transaction_amount IN NUMBER) IS
    BEGIN
        total_volume := total_volume + p_transaction_amount;
        total_transactions := total_transactions + 1;
    END;
END;
/

-- Nested table types for aggregation
CREATE OR REPLACE TYPE bid_table_type AS TABLE OF bid_type;
/
CREATE OR REPLACE TYPE transaction_table_type AS TABLE OF REF transaction_type;
/

-- Create sequences first
CREATE SEQUENCE creator_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE nft_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE transaction_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE collection_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE auction_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE marketplace_id_seq START WITH 1 INCREMENT BY 1;

-- Create tables with object-relational features

CREATE TABLE marketplace OF marketplace_type (
    PRIMARY KEY (marketplace_id)
) OBJECT IDENTIFIER IS SYSTEM GENERATED;

CREATE TABLE nft_collection OF collection_type (
    PRIMARY KEY (collection_id)
) OBJECT IDENTIFIER IS SYSTEM GENERATED;

-- FIXED: Correct syntax for substitutable object table
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

-- FIXED: Create NFT table with proper scoping
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
WHEN (NEW.transaction_type_name = 'SALE')
DECLARE
    v_royalty_amount NUMBER;
BEGIN
    -- Calculate and distribute royalties
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

-- Sample creators using substitutable object table
INSERT INTO creator VALUES (
    creator_type(creator_id_seq.NEXTVAL, '0x1234567890abcdef1234567890abcdef12345678', 'ArtMaster3000', 
                'artist@example.com', 'Digital artist specializing in surreal landscapes', 
                'https://example.com/profiles/artmaster.jpg', SYSTIMESTAMP, 0, 0)
);

INSERT INTO creator VALUES (
    verified_creator_type(creator_id_seq.NEXTVAL, '0x7777888899990000111122223333444455556666', 'VerifiedArtist', 
                         'verified@example.com', 'Verified digital artist with gold tier', 
                         'https://example.com/profiles/verified.jpg', SYSTIMESTAMP, 0, 0,
                         SYSTIMESTAMP - INTERVAL '30' DAY, 'Gold')
);

-- Sample auctions
INSERT INTO auction VALUES (
    auction_type(auction_id_seq.NEXTVAL, 1.0, 0, 0.8, 
                SYSTIMESTAMP, SYSTIMESTAMP + INTERVAL '7' DAY, 'ACTIVE')
);

-- Sample transactions
INSERT INTO transaction_history VALUES (
    transaction_type(transaction_id_seq.NEXTVAL, '0xtx1234567890abcdef', 'SALE', 2.5, 0.0625, 0.01, 
                    SYSTIMESTAMP - INTERVAL '1' DAY, 1000001)
);

-- THE 5 REQUIRED COMPLEX QUERIES:

-- Query 1: JOIN of three or more tables with multiple join types and restrictions
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
    a.current_highest_bid
FROM nft n
INNER JOIN creator c ON n.creator = REF(c)
LEFT OUTER JOIN transaction_history t ON t.transaction_id = (
    SELECT MAX(th.transaction_id) 
    FROM transaction_history th, TABLE(n.transactions) nt 
    WHERE REF(th) = nt.COLUMN_VALUE
)
LEFT OUTER JOIN auction a ON n.auction = REF(a)
WHERE n.view_count > 500 AND n.like_count > 25
ORDER BY n.view_count DESC, n.like_count DESC;

-- Query 2: UNION operation involving multiple tables
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
    (SELECT MAX(b.bid_amount) FROM TABLE(n.bids) b) AS highest_bid
FROM nft n, creator c
WHERE n.creator = REF(c)
AND n.auction IS NOT NULL
AND CARDINALITY(n.bids) > 0
ORDER BY (SELECT MAX(b.bid_amount) FROM TABLE(n.bids) b) DESC;

-- Query 4: Query using temporal features with intervals and timestamps
SELECT 
    time_period,
    COUNT(*) AS transaction_count,
    AVG(amount) AS avg_transaction_value,
    SUM(amount) AS total_volume
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
    WHERE t.transaction_type_name = 'SALE'
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
SELECT 
    creator_tier,
    collection_name,
    time_bucket,
    COUNT(*) AS nft_count,
    AVG(price) AS avg_price,
    SUM(price) AS total_value,
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

COMMIT;