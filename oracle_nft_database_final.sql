-- Digital Art NFT Marketplace & Creator Economy - Oracle Object-Relational Database 
-- FINAL WORKING VERSION - Correct Oracle Syntax
-- This script creates a comprehensive NFT marketplace system using Oracle's object-relational features

-- Clean up any existing objects first
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE nft CASCADE CONSTRAINTS';
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
    EXECUTE IMMEDIATE 'DROP TABLE nft_collection CASCADE CONSTRAINTS';
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
    EXECUTE IMMEDIATE 'DROP TABLE transaction_history CASCADE CONSTRAINTS';
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

-- Drop sequences
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

-- Drop types in correct order
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE transaction_table_type FORCE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE bid_table_type FORCE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE premium_creator_type FORCE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE verified_creator_type FORCE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE creator_type FORCE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE transaction_type FORCE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE auction_type FORCE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE collection_type FORCE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE marketplace_type FORCE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE bid_type FORCE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE tag_array_type FORCE';
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
    
    MEMBER FUNCTION is_valid_bid(current_highest NUMBER) RETURN BOOLEAN,
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
    
    MEMBER FUNCTION get_reputation_score RETURN NUMBER,
    MEMBER PROCEDURE update_earnings(p_amount IN NUMBER),
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

-- Verified Creator subtype (NOT FINAL to allow premium_creator_type)
CREATE OR REPLACE TYPE verified_creator_type UNDER creator_type (
    verification_date TIMESTAMP,
    verification_tier VARCHAR2(20),
    
    OVERRIDING MEMBER FUNCTION get_creator_status RETURN VARCHAR2,
    MEMBER FUNCTION get_verification_benefits RETURN VARCHAR2
) NOT FINAL;
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
    
    OVERRIDING MEMBER FUNCTION get_creator_status RETURN VARCHAR2,
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

-- Collection type
CREATE OR REPLACE TYPE collection_type AS OBJECT (
    collection_id NUMBER,
    name VARCHAR2(100),
    description CLOB,
    cover_image_url VARCHAR2(500),
    floor_price NUMBER(15,2),
    total_volume NUMBER(15,2),
    item_count NUMBER,
    created_at TIMESTAMP,
    
    MEMBER FUNCTION get_average_price RETURN NUMBER,
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

-- Auction type
CREATE OR REPLACE TYPE auction_type AS OBJECT (
    auction_id NUMBER,
    starting_price NUMBER(15,2),
    current_highest_bid NUMBER(15,2),
    reserve_price NUMBER(15,2),
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    status VARCHAR2(20),
    
    MEMBER FUNCTION is_active RETURN BOOLEAN,
    MEMBER FUNCTION get_time_remaining RETURN INTERVAL DAY TO SECOND,
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

-- Transaction type
CREATE OR REPLACE TYPE transaction_type AS OBJECT (
    transaction_id NUMBER,
    transaction_hash VARCHAR2(100),
    transaction_type_name VARCHAR2(20),
    amount NUMBER(15,2),
    platform_fee NUMBER(15,2),
    gas_fee NUMBER(15,2),
    transaction_timestamp TIMESTAMP,
    block_number NUMBER,
    
    MEMBER FUNCTION get_total_cost RETURN NUMBER,
    MEMBER FUNCTION get_transaction_age RETURN INTERVAL DAY TO SECOND,
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

-- Marketplace type
CREATE OR REPLACE TYPE marketplace_type AS OBJECT (
    marketplace_id NUMBER,
    name VARCHAR2(100),
    platform_fee_percentage NUMBER(5,2),
    total_volume NUMBER(18,2),
    total_transactions NUMBER,
    active_listings NUMBER,
    
    MEMBER FUNCTION get_daily_volume RETURN NUMBER,
    MEMBER PROCEDURE update_stats(p_transaction_amount IN NUMBER)
);
/

CREATE OR REPLACE TYPE BODY marketplace_type AS
    MEMBER FUNCTION get_daily_volume RETURN NUMBER IS
    BEGIN
        RETURN total_volume * 0.05; -- Estimate 5% of total volume per day
    END;
    
    MEMBER PROCEDURE update_stats(p_transaction_amount IN NUMBER) IS
    BEGIN
        total_volume := total_volume + p_transaction_amount;
        total_transactions := total_transactions + 1;
    END;
END;
/

-- Nested table types
CREATE OR REPLACE TYPE bid_table_type AS TABLE OF bid_type;
/
CREATE OR REPLACE TYPE transaction_table_type AS TABLE OF REF transaction_type;
/

-- Create sequences
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

-- CORRECTED: Proper Oracle syntax for substitutable object table
CREATE TABLE creator OF creator_type 
    SUBSTITUTABLE AT ALL LEVELS
    (PRIMARY KEY (creator_id),
     UNIQUE (wallet_address),
     UNIQUE (username)
    );

CREATE TABLE auction OF auction_type (
    PRIMARY KEY (auction_id)
) OBJECT IDENTIFIER IS SYSTEM GENERATED;

CREATE TABLE transaction_history OF transaction_type (
    PRIMARY KEY (transaction_id),
    CONSTRAINT unique_tx_hash UNIQUE (transaction_hash)
) OBJECT IDENTIFIER IS SYSTEM GENERATED;

-- Create NFT table with simplified structure (using foreign keys to avoid REF issues)
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
    creator_id NUMBER,
    collection_id NUMBER,
    current_owner_wallet VARCHAR2(100),
    auction_id NUMBER,
    CONSTRAINT fk_nft_creator FOREIGN KEY (creator_id) REFERENCES creator(creator_id),
    CONSTRAINT fk_nft_collection FOREIGN KEY (collection_id) REFERENCES nft_collection(collection_id),
    CONSTRAINT fk_nft_auction FOREIGN KEY (auction_id) REFERENCES auction(auction_id)
);

-- Create indexes
CREATE INDEX idx_nft_creator ON nft(creator_id);
CREATE INDEX idx_nft_collection ON nft(collection_id);
CREATE INDEX idx_nft_price ON nft(price);
CREATE INDEX idx_nft_created_at ON nft(created_at);
CREATE INDEX idx_transaction_timestamp ON transaction_history(transaction_timestamp);

-- Create views that demonstrate object-relational features
CREATE OR REPLACE VIEW nft_marketplace_view AS
SELECT 
    n.nft_id,
    n.title,
    n.price,
    c.username AS creator_name,
    VALUE(c).get_reputation_score() AS creator_reputation,
    col.name AS collection_name,
    n.view_count,
    n.like_count,
    n.created_at,
    CASE WHEN n.auction_id IS NOT NULL THEN 'AUCTION' ELSE 'FIXED_PRICE' END AS sale_type
FROM nft n
JOIN creator c ON n.creator_id = c.creator_id
JOIN nft_collection col ON n.collection_id = col.collection_id;

CREATE OR REPLACE VIEW creator_analytics_view AS
SELECT 
    c.creator_id,
    c.username,
    c.total_earnings,
    c.total_sales,
    VALUE(c).get_reputation_score() AS reputation_score,
    VALUE(c).get_creator_status() AS status,
    CASE 
        WHEN VALUE(c) IS OF (premium_creator_type) THEN 'Premium'
        WHEN VALUE(c) IS OF (verified_creator_type) THEN 'Verified'
        ELSE 'Standard'
    END AS account_type
FROM creator c;

-- Create triggers
CREATE OR REPLACE TRIGGER trg_nft_creation
AFTER INSERT ON nft
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('NFT ' || :NEW.nft_id || ' "' || :NEW.title || '" created by ' || 
                         :NEW.current_owner_wallet);
    
    UPDATE nft_collection c 
    SET c.item_count = c.item_count + 1 
    WHERE c.collection_id = :NEW.collection_id;
END;
/

CREATE OR REPLACE TRIGGER trg_sale_transaction
AFTER INSERT ON transaction_history
FOR EACH ROW
WHEN (NEW.transaction_type_name = 'SALE')
BEGIN
    DBMS_OUTPUT.PUT_LINE('Sale transaction processed: ' || :NEW.transaction_hash || 
                         ', Amount: ' || :NEW.amount);
END;
/

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

-- Create procedures
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
    v_wallet_address VARCHAR2(100);
BEGIN
    SELECT c.wallet_address INTO v_wallet_address 
    FROM creator c WHERE c.creator_id = p_creator_id;
    
    SELECT nft_id_seq.NEXTVAL INTO p_nft_id FROM dual;
    
    INSERT INTO nft VALUES (
        p_nft_id,
        p_token_id,
        p_title,
        p_description,
        p_image_url,
        NULL,
        p_price,
        5.0,
        p_tags,
        SYSTIMESTAMP,
        NULL,
        0,
        0,
        p_creator_id,
        p_collection_id,
        v_wallet_address,
        NULL
    );
    
    DBMS_OUTPUT.PUT_LINE('NFT created with ID: ' || p_nft_id);
END;
/

CREATE OR REPLACE PROCEDURE process_sale(
    p_nft_id IN NUMBER,
    p_buyer_wallet IN VARCHAR2,
    p_sale_price IN NUMBER,
    p_transaction_hash IN VARCHAR2
) AS
    v_transaction_id NUMBER;
    v_platform_fee NUMBER;
BEGIN
    v_platform_fee := transaction_type.calculate_platform_fee(p_sale_price);
    
    SELECT transaction_id_seq.NEXTVAL INTO v_transaction_id FROM dual;
    
    INSERT INTO transaction_history VALUES (
        transaction_type(
            v_transaction_id,
            p_transaction_hash,
            'SALE',
            p_sale_price,
            v_platform_fee,
            0.01,
            SYSTIMESTAMP,
            1000000 + v_transaction_id
        )
    );
    
    UPDATE nft 
    SET current_owner_wallet = p_buyer_wallet,
        last_sale_date = SYSTIMESTAMP
    WHERE nft_id = p_nft_id;
    
    DBMS_OUTPUT.PUT_LINE('Sale processed for NFT ' || p_nft_id);
END;
/

-- Create functions
CREATE OR REPLACE FUNCTION get_creator_earnings(
    p_creator_id IN NUMBER,
    p_period_days IN NUMBER DEFAULT 30
) RETURN NUMBER IS
    v_earnings NUMBER := 0;
BEGIN
    SELECT SUM(t.amount * 0.05) INTO v_earnings
    FROM nft n
    JOIN transaction_history t ON t.transaction_type_name = 'SALE'
    WHERE n.creator_id = p_creator_id
    AND t.transaction_timestamp > SYSTIMESTAMP - NUMTODSINTERVAL(p_period_days, 'DAY');
    
    RETURN NVL(v_earnings, 0);
END;
/

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

-- Insert sample data
INSERT INTO marketplace VALUES (
    marketplace_type(marketplace_id_seq.NEXTVAL, 'NFTopia Marketplace', 2.5, 0, 0, 0)
);

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
    verified_creator_type(creator_id_seq.NEXTVAL, '0x7777888899990000111122223333444455556666', 'VerifiedArtist', 
                         'verified@example.com', 'Verified digital artist with gold tier', 
                         'https://example.com/profiles/verified.jpg', SYSTIMESTAMP, 0, 0,
                         SYSTIMESTAMP - INTERVAL '30' DAY, 'Gold')
);

INSERT INTO creator VALUES (
    premium_creator_type(creator_id_seq.NEXTVAL, '0x9999000011112222333344445555666677778888', 'PremiumMaster', 
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

-- Create NFTs using procedure
DECLARE
    v_nft_id NUMBER;
BEGIN
    create_nft(
        'TOKEN_001',
        'Ethereal Dreamscape',
        'A mesmerizing digital landscape that blurs the line between reality and dreams',
        'https://example.com/nfts/dreamscape.jpg',
        2.5,
        1,
        1,
        tag_array_type('surreal', 'landscape', 'digital art', 'dreams'),
        v_nft_id
    );
    DBMS_OUTPUT.PUT_LINE('Created NFT with ID: ' || v_nft_id);
END;
/

DECLARE
    v_nft_id NUMBER;
BEGIN
    create_nft(
        'TOKEN_002',
        '8-Bit Warriors',
        'Classic retro-style warriors ready for digital battle',
        'https://example.com/nfts/8bit-warriors.jpg',
        1.2,
        2,
        2,
        tag_array_type('pixel art', 'retro', 'gaming', 'warriors'),
        v_nft_id
    );
    DBMS_OUTPUT.PUT_LINE('Created NFT with ID: ' || v_nft_id);
END;
/

DECLARE
    v_nft_id NUMBER;
BEGIN
    create_nft(
        'TOKEN_003',
        'Verified Masterpiece',
        'An exclusive artwork from a verified gold-tier creator',
        'https://example.com/nfts/verified-masterpiece.jpg',
        5.5,
        3,
        2,
        tag_array_type('verified', 'exclusive', 'premium', 'masterpiece'),
        v_nft_id
    );
    DBMS_OUTPUT.PUT_LINE('Created NFT with ID: ' || v_nft_id);
END;
/

DECLARE
    v_nft_id NUMBER;
BEGIN
    create_nft(
        'TOKEN_004',
        'Premium Collection #1',
        'First piece from an exclusive premium creator collection',
        'https://example.com/nfts/premium-collection-1.jpg',
        8.8,
        4,
        3,
        tag_array_type('premium', 'exclusive', 'collection', 'first edition'),
        v_nft_id
    );
    DBMS_OUTPUT.PUT_LINE('Created NFT with ID: ' || v_nft_id);
END;
/

-- THE 5 REQUIRED COMPLEX QUERIES DEMONSTRATING OBJECT-RELATIONAL FEATURES:

-- Query 1: JOIN of three or more tables with multiple join types and object-relational features
-- Shows comprehensive NFT marketplace data with creator verification status and collection performance
SELECT 
    n.nft_id,
    n.title AS nft_title,
    n.price AS current_price,
    n.view_count,
    n.like_count,
    c.username AS creator_name,
    VALUE(c).get_reputation_score() AS creator_reputation,
    CASE 
        WHEN VALUE(c) IS OF (premium_creator_type) THEN 'Premium'
        WHEN VALUE(c) IS OF (verified_creator_type) THEN 'Verified'
        ELSE 'Standard'
    END AS creator_tier,
    col.name AS collection_name,
    VALUE(col).get_average_price() AS collection_avg_price,
    t.transaction_hash,
    t.amount AS last_sale_amount,
    a.current_highest_bid
FROM nft n
INNER JOIN creator c ON n.creator_id = c.creator_id
INNER JOIN nft_collection col ON n.collection_id = col.collection_id
LEFT OUTER JOIN transaction_history t ON t.transaction_type_name = 'SALE'
LEFT OUTER JOIN auction a ON n.auction_id = a.auction_id
WHERE n.view_count >= 0 AND n.like_count >= 0
ORDER BY VALUE(c).get_reputation_score() DESC, n.price DESC;

-- Query 2: UNION operation involving multiple tables with object methods
-- Gets all wallet addresses that are either NFT creators or current NFT owners with their roles
SELECT wallet_address, role_type, item_count, total_value, avg_reputation
FROM (
    SELECT 
        c.wallet_address,
        'Creator' AS role_type,
        COUNT(*) AS item_count,
        SUM(n.price) AS total_value,
        AVG(VALUE(c).get_reputation_score()) AS avg_reputation
    FROM creator c
    INNER JOIN nft n ON n.creator_id = c.creator_id
    GROUP BY c.wallet_address
    
    UNION
    
    SELECT 
        n.current_owner_wallet AS wallet_address,
        'Owner' AS role_type,
        COUNT(*) AS item_count,
        SUM(n.price) AS total_value,
        0 AS avg_reputation
    FROM nft n
    WHERE n.current_owner_wallet IS NOT NULL
    GROUP BY n.current_owner_wallet
)
ORDER BY total_value DESC, item_count DESC;

-- Query 3: Query using inheritance hierarchy and object methods
-- Displays NFT details with creator type-specific information using inheritance and polymorphism
SELECT 
    n.nft_id,
    n.title,
    n.price,
    VALUE(c).get_creator_status() AS creator_status,
    VALUE(c).get_reputation_score() AS reputation_score,
    CASE 
        WHEN VALUE(c) IS OF (premium_creator_type) THEN 
            TREAT(VALUE(c) AS premium_creator_type).get_premium_features()
        WHEN VALUE(c) IS OF (verified_creator_type) THEN 
            TREAT(VALUE(c) AS verified_creator_type).get_verification_benefits()
        ELSE 'Standard creator benefits'
    END AS creator_benefits,
    CASE 
        WHEN VALUE(c) IS OF (premium_creator_type) THEN 'Premium Tier'
        WHEN VALUE(c) IS OF (verified_creator_type) THEN 'Verified Tier'
        ELSE 'Standard Tier'
    END AS creator_tier_detail
FROM nft n
JOIN creator c ON n.creator_id = c.creator_id
ORDER BY VALUE(c).get_reputation_score() DESC, n.price DESC;

-- Query 4: Query using temporal features with intervals and timestamps
-- Analyzes NFT market activity over different time periods using temporal operations
-- Query 4: CORRECTED - Query using temporal features with intervals and timestamps
-- Analyzes NFT market activity over different time periods using temporal operations
SELECT 
    time_period,
    COUNT(*) AS transaction_count,
    AVG(amount) AS avg_transaction_value,
    SUM(amount) AS total_volume,
    AVG(total_cost) AS avg_total_cost_with_fees
FROM (
    SELECT 
        t.transaction_id,
        t.amount,
        VALUE(t).get_total_cost() AS total_cost,
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
-- Query 5: OLAP query with ROLLUP and CUBE features using object methods
-- Comprehensive marketplace analytics with multi-dimensional aggregations
SELECT 
    creator_tier,
    collection_name,
    time_bucket,
    COUNT(*) AS nft_count,
    AVG(price) AS avg_price,
    SUM(price) AS total_value,
    AVG(reputation_score) AS avg_creator_reputation,
    GROUPING(creator_tier) AS tier_grouping,
    GROUPING(collection_name) AS collection_grouping,
    GROUPING(time_bucket) AS time_grouping
FROM (
    SELECT 
        n.nft_id,
        n.price,
        n.view_count,
        n.like_count,
        VALUE(c).get_reputation_score() AS reputation_score,
        CASE 
            WHEN VALUE(c) IS OF (premium_creator_type) THEN 'Premium'
            WHEN VALUE(c) IS OF (verified_creator_type) THEN 'Verified'
            ELSE 'Standard'
        END AS creator_tier,
        col.name AS collection_name,
        CASE 
            WHEN n.created_at > SYSTIMESTAMP - INTERVAL '7' DAY THEN 'This Week'
            WHEN n.created_at > SYSTIMESTAMP - INTERVAL '30' DAY THEN 'This Month'
            ELSE 'Older'
        END AS time_bucket
    FROM nft n
    JOIN creator c ON n.creator_id = c.creator_id
    JOIN nft_collection col ON n.collection_id = col.collection_id
)
GROUP BY ROLLUP(creator_tier, collection_name, time_bucket)
HAVING COUNT(*) > 0
ORDER BY 
    GROUPING(creator_tier),
    GROUPING(collection_name), 
    GROUPING(time_bucket),
    avg_creator_reputation DESC NULLS LAST,
    total_value DESC NULLS LAST;

-- Test object method functionality and demonstrate inheritance
DECLARE
    v_creator creator_type;
    v_verified verified_creator_type;
    v_premium premium_creator_type;
    v_collection collection_type;
    v_transaction transaction_type;
    v_auction auction_type;
    v_stats VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Testing Object-Relational Features ===');
    
    -- Test base creator methods
    SELECT VALUE(c) INTO v_creator FROM creator c WHERE c.creator_id = 1;
    DBMS_OUTPUT.PUT_LINE('Base Creator Status: ' || v_creator.get_creator_status());
    DBMS_OUTPUT.PUT_LINE('Base Creator Reputation: ' || v_creator.get_reputation_score());
    
    -- Test verified creator methods (inheritance and polymorphism)
    SELECT TREAT(VALUE(c) AS verified_creator_type) INTO v_verified 
    FROM creator c WHERE c.creator_id = 3;
    DBMS_OUTPUT.PUT_LINE('Verified Creator Status: ' || v_verified.get_creator_status());
    DBMS_OUTPUT.PUT_LINE('Verification Benefits: ' || v_verified.get_verification_benefits());
    
    -- Test premium creator methods (multi-level inheritance)
    SELECT TREAT(VALUE(c) AS premium_creator_type) INTO v_premium 
    FROM creator c WHERE c.creator_id = 4;
    DBMS_OUTPUT.PUT_LINE('Premium Creator Status: ' || v_premium.get_creator_status());
    DBMS_OUTPUT.PUT_LINE('Premium Features: ' || v_premium.get_premium_features());
    
    -- Test collection methods
    SELECT VALUE(c) INTO v_collection FROM nft_collection c WHERE c.collection_id = 1;
    DBMS_OUTPUT.PUT_LINE('Collection Average Price: ' || v_collection.get_average_price());
    
    -- Test transaction methods
    SELECT VALUE(t) INTO v_transaction FROM transaction_history t WHERE t.transaction_id = 1;
    DBMS_OUTPUT.PUT_LINE('Transaction Total Cost: ' || v_transaction.get_total_cost());
    DBMS_OUTPUT.PUT_LINE('Transaction Age: ' || v_transaction.get_transaction_age());
    
    -- Test auction methods
    SELECT VALUE(a) INTO v_auction FROM auction a WHERE a.auction_id = 1;
    DBMS_OUTPUT.PUT_LINE('Auction Active: ' || CASE WHEN v_auction.is_active() THEN 'Yes' ELSE 'No' END);
    DBMS_OUTPUT.PUT_LINE('Time Remaining: ' || v_auction.get_time_remaining());
    
    -- Test collection statistics function
    v_stats := get_collection_stats(1);
    DBMS_OUTPUT.PUT_LINE('Collection Stats: ' || v_stats);
    
    DBMS_OUTPUT.PUT_LINE('=== All Tests Completed Successfully ===');
END;
/

COMMIT;

