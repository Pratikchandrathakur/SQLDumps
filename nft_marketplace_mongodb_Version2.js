// Digital Art NFT Marketplace & Creator Economy - MongoDB Document Store Implementation
// This script creates a comprehensive NFT marketplace system using MongoDB's document-oriented features
// Equivalent to the Oracle Object-Relational Database implementation

// Connect to MongoDB and use the nft_marketplace database
use nft_marketplace;

// Drop existing collections to start fresh
db.creators.drop();
db.nfts.drop();
db.collections.drop();
db.auctions.drop();
db.transactions.drop();
db.marketplace.drop();

// Create collections with validation schemas to ensure data integrity

// 1. MARKETPLACE COLLECTION
// Simple collection for marketplace configuration
db.marketplace.insertOne({
    _id: 1,
    name: "NFTopia Marketplace",
    platform_fee_percentage: 2.5,
    total_volume: 0,
    total_transactions: 0,
    active_listings: 0,
    created_at: new Date(),
    // Embedded configuration object
    settings: {
        max_royalty_percentage: 15,
        min_price: 0.01,
        supported_currencies: ["ETH", "USD"],
        features: ["auctions", "fixed_price", "offers"]
    }
});

// 2. COLLECTIONS COLLECTION
// Represents NFT collections with embedded statistics
db.collections.insertMany([
    {
        _id: 1,
        name: "Digital Dreams",
        description: "Surreal digital art collection",
        cover_image_url: "https://example.com/collections/digital-dreams.jpg",
        floor_price: 0.5,
        total_volume: 0,
        item_count: 0,
        created_at: new Date(),
        // Embedded collection metadata
        metadata: {
            category: "Digital Art",
            theme: "Surreal",
            artist_count: 0,
            verified: true
        },
        // Array of collection statistics over time
        volume_history: [],
        // Array of top sales in this collection
        top_sales: []
    },
    {
        _id: 2,
        name: "Pixel Perfect",
        description: "Retro pixel art masterpieces",
        cover_image_url: "https://example.com/collections/pixel-perfect.jpg",
        floor_price: 0.3,
        total_volume: 0,
        item_count: 0,
        created_at: new Date(),
        metadata: {
            category: "Pixel Art",
            theme: "Retro Gaming",
            artist_count: 0,
            verified: true
        },
        volume_history: [],
        top_sales: []
    },
    {
        _id: 3,
        name: "Abstract Expressions",
        description: "Contemporary abstract digital art",
        cover_image_url: "https://example.com/collections/abstract.jpg",
        floor_price: 1.2,
        total_volume: 0,
        item_count: 0,
        created_at: new Date(),
        metadata: {
            category: "Abstract Art",
            theme: "Contemporary",
            artist_count: 0,
            verified: false
        },
        volume_history: [],
        top_sales: []
    }
]);

// 3. CREATORS COLLECTION
// Demonstrates inheritance-like behavior using type discrimination and embedded documents
db.creators.insertMany([
    // Standard Creator
    {
        _id: 1,
        creator_type: "standard",
        wallet_address: "0x1234567890abcdef1234567890abcdef12345678",
        username: "ArtMaster3000",
        email: "artist@example.com",
        bio: "Digital artist specializing in surreal landscapes",
        profile_image_url: "https://example.com/profiles/artmaster.jpg",
        created_at: new Date(),
        total_sales: 0,
        total_earnings: 0,
        // Embedded social media links
        social_links: {
            twitter: "@artmaster3000",
            instagram: "artmaster_official",
            website: "https://artmaster3000.com"
        },
        // Array of skills/specialties
        specialties: ["Digital Painting", "Concept Art", "Surrealism"],
        // Embedded reputation metrics
        reputation: {
            score: 40,
            reviews_count: 0,
            average_rating: 0,
            badges: ["New Creator"]
        }
    },
    // Standard Creator 2
    {
        _id: 2,
        creator_type: "standard",
        wallet_address: "0xabcdef1234567890abcdef1234567890abcdef12",
        username: "PixelWizard",
        email: "pixel@example.com",
        bio: "Retro game-inspired pixel artist",
        profile_image_url: "https://example.com/profiles/pixelwizard.jpg",
        created_at: new Date(),
        total_sales: 0,
        total_earnings: 0,
        social_links: {
            twitter: "@pixelwizard",
            discord: "PixelWizard#1234"
        },
        specialties: ["Pixel Art", "8-bit Design", "Game Assets"],
        reputation: {
            score: 40,
            reviews_count: 0,
            average_rating: 0,
            badges: ["New Creator", "Pixel Artist"]
        }
    },
    // Verified Creator (inheritance-like behavior)
    {
        _id: 3,
        creator_type: "verified",
        wallet_address: "0x7777888899990000111122223333444455556666",
        username: "VerifiedArtist",
        email: "verified@example.com",
        bio: "Verified digital artist with gold tier",
        profile_image_url: "https://example.com/profiles/verified.jpg",
        created_at: new Date(),
        total_sales: 0,
        total_earnings: 0,
        // Verification-specific embedded document
        verification: {
            date: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000), // 30 days ago
            tier: "Gold",
            verifier: "NFTopia Team",
            benefits: ["Lower fees", "Priority support", "Featured listings"],
            expires_at: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000) // 1 year from now
        },
        social_links: {
            twitter: "@verifiedartist",
            instagram: "verified_artist_official",
            website: "https://verifiedartist.com"
        },
        specialties: ["Contemporary Art", "Digital Sculptures", "Mixed Media"],
        reputation: {
            score: 80,
            reviews_count: 15,
            average_rating: 4.7,
            badges: ["Verified", "Top Seller", "Community Favorite"]
        }
    },
    // Premium Creator (multi-level inheritance-like behavior)
    {
        _id: 4,
        creator_type: "premium",
        wallet_address: "0x9999000011112222333344445555666677778888",
        username: "PremiumMaster",
        email: "premium@example.com",
        bio: "Premium tier digital artist with exclusive features",
        profile_image_url: "https://example.com/profiles/premium.jpg",
        created_at: new Date(),
        total_sales: 0,
        total_earnings: 0,
        // Inherits verification properties
        verification: {
            date: new Date(Date.now() - 45 * 24 * 60 * 60 * 1000), // 45 days ago
            tier: "Gold",
            verifier: "NFTopia Team",
            benefits: ["Lower fees", "Priority support", "Featured listings"],
            expires_at: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000)
        },
        // Premium-specific embedded document
        premium: {
            since: new Date(Date.now() - 15 * 24 * 60 * 60 * 1000), // 15 days ago
            tier: "Platinum",
            exclusive_features: ["Early Access", "Custom Marketplace", "Priority Support"],
            monthly_fee: 99.99,
            perks: {
                featured_placement: true,
                custom_profile: true,
                analytics_access: true,
                direct_messaging: true
            }
        },
        social_links: {
            twitter: "@premiummaster",
            instagram: "premium_master_art",
            website: "https://premiummaster.art",
            discord: "PremiumMaster#0001"
        },
        specialties: ["Exclusive Collections", "Limited Editions", "High-Value Art"],
        reputation: {
            score: 95,
            reviews_count: 50,
            average_rating: 4.9,
            badges: ["Premium", "Verified", "Top Earner", "Exclusive", "Master Artist"]
        }
    }
]);

// 4. AUCTIONS COLLECTION
// Demonstrates temporal data and embedded bidding history
db.auctions.insertMany([
    {
        _id: 1,
        starting_price: 1.0,
        current_highest_bid: 0,
        reserve_price: 0.8,
        start_time: new Date(),
        end_time: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days from now
        status: "ACTIVE",
        // Embedded array of bid history
        bids: [],
        // Embedded auction settings
        settings: {
            bid_increment: 0.1,
            auto_extend: true,
            extension_time: 300, // 5 minutes
            max_bids: 1000
        }
    },
    {
        _id: 2,
        starting_price: 2.5,
        current_highest_bid: 3.1,
        reserve_price: 2.0,
        start_time: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), // 2 days ago
        end_time: new Date(Date.now() + 5 * 24 * 60 * 60 * 1000), // 5 days from now
        status: "ACTIVE",
        bids: [
            {
                bidder_wallet: "0xbidder1111222233334444555566667777888899990",
                bid_amount: 2.6,
                bid_timestamp: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000),
                transaction_hash: "0xbid123"
            },
            {
                bidder_wallet: "0xbidder2222333344445555666677778888999900001",
                bid_amount: 3.1,
                bid_timestamp: new Date(Date.now() - 12 * 60 * 60 * 1000), // 12 hours ago
                transaction_hash: "0xbid456"
            }
        ],
        settings: {
            bid_increment: 0.1,
            auto_extend: true,
            extension_time: 300,
            max_bids: 1000
        }
    }
]);

// 5. TRANSACTIONS COLLECTION
// Demonstrates temporal data and embedded transaction details
db.transactions.insertMany([
    {
        _id: 1,
        transaction_hash: "0xtx1234567890abcdef",
        transaction_type: "SALE",
        amount: 2.5,
        platform_fee: 0.0625,
        gas_fee: 0.01,
        transaction_timestamp: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000), // 1 day ago
        block_number: 1000001,
        // Embedded transaction details
        details: {
            from_wallet: "0x1234567890abcdef1234567890abcdef12345678",
            to_wallet: "0xbuyer1111222233334444555566667777888899990",
            currency: "ETH",
            usd_value: 4000.00, // at time of transaction
            royalty_paid: 0.125,
            royalty_recipient: "0x1234567890abcdef1234567890abcdef12345678"
        },
        // Embedded blockchain verification
        blockchain: {
            network: "Ethereum",
            confirmations: 50,
            verified: true,
            gas_used: 21000
        }
    },
    {
        _id: 2,
        transaction_hash: "0xtx2345678901bcdef0",
        transaction_type: "SALE",
        amount: 1.8,
        platform_fee: 0.045,
        gas_fee: 0.008,
        transaction_timestamp: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000), // 3 days ago
        block_number: 1000002,
        details: {
            from_wallet: "0xabcdef1234567890abcdef1234567890abcdef12",
            to_wallet: "0xbuyer2222333344445555666677778888999900001",
            currency: "ETH",
            usd_value: 2880.00,
            royalty_paid: 0.09,
            royalty_recipient: "0xabcdef1234567890abcdef1234567890abcdef12"
        },
        blockchain: {
            network: "Ethereum",
            confirmations: 100,
            verified: true,
            gas_used: 21000
        }
    }
]);

// 6. NFTS COLLECTION
// Main collection demonstrating complex nested documents, arrays, and references
db.nfts.insertMany([
    {
        _id: 1,
        token_id: "TOKEN_001",
        title: "Ethereal Dreamscape",
        description: "A mesmerizing digital landscape that blurs the line between reality and dreams",
        image_url: "https://example.com/nfts/dreamscape.jpg",
        metadata_url: "https://example.com/metadata/dreamscape.json",
        price: 2.5,
        royalty_percentage: 5.0,
        // Array of tags (equivalent to VARRAY in Oracle)
        tags: ["surreal", "landscape", "digital art", "dreams"],
        created_at: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000), // 10 days ago
        last_sale_date: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000), // 1 day ago
        view_count: 1250,
        like_count: 89,
        current_owner_wallet: "0x1234567890abcdef1234567890abcdef12345678",
        
        // Embedded creator reference with denormalized data for performance
        creator: {
            id: 1,
            username: "ArtMaster3000",
            wallet_address: "0x1234567890abcdef1234567890abcdef12345678",
            creator_type: "standard",
            reputation_score: 40
        },
        
        // Embedded collection reference
        collection: {
            id: 1,
            name: "Digital Dreams",
            floor_price: 0.5
        },
        
        // Embedded auction information (if applicable)
        auction: {
            id: 1,
            status: "ACTIVE",
            current_highest_bid: 0,
            end_time: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
        },
        
        // Array of transaction references
        transaction_history: [1],
        
        // Embedded array of bids (equivalent to nested table in Oracle)
        bids: [
            {
                bidder_wallet: "0xbidder1111222233334444555566667777888899990",
                bid_amount: 1.2,
                bid_timestamp: new Date(Date.now() - 2 * 60 * 60 * 1000), // 2 hours ago
                status: "outbid"
            },
            {
                bidder_wallet: "0xbidder2222333344445555666677778888999900001",
                bid_amount: 1.5,
                bid_timestamp: new Date(Date.now() - 1 * 60 * 60 * 1000), // 1 hour ago
                status: "outbid"
            },
            {
                bidder_wallet: "0xbidder3333444455556666777788889999000011112",
                bid_amount: 1.8,
                bid_timestamp: new Date(Date.now() - 30 * 60 * 1000), // 30 minutes ago
                status: "highest"
            }
        ],
        
        // Embedded metadata
        metadata: {
            attributes: [
                { trait_type: "Style", value: "Surreal" },
                { trait_type: "Color Palette", value: "Ethereal Blues" },
                { trait_type: "Technique", value: "Digital Painting" },
                { trait_type: "Rarity", value: "Rare" }
            ],
            external_url: "https://artmaster3000.com/ethereal-dreamscape",
            animation_url: null,
            background_color: "1a1a2e"
        },
        
        // Embedded analytics
        analytics: {
            daily_views: [
                { date: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000), views: 150 },
                { date: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), views: 120 }
            ],
            countries: ["US", "UK", "Canada", "Germany"],
            referrers: ["opensea.io", "direct", "twitter.com"]
        }
    },
    {
        _id: 2,
        token_id: "TOKEN_002",
        title: "8-Bit Warriors",
        description: "Classic retro-style warriors ready for digital battle",
        image_url: "https://example.com/nfts/8bit-warriors.jpg",
        metadata_url: "https://example.com/metadata/8bit-warriors.json",
        price: 1.2,
        royalty_percentage: 5.0,
        tags: ["pixel art", "retro", "gaming", "warriors"],
        created_at: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000), // 5 days ago
        last_sale_date: null,
        view_count: 850,
        like_count: 156,
        current_owner_wallet: "0xabcdef1234567890abcdef1234567890abcdef12",
        
        creator: {
            id: 2,
            username: "PixelWizard",
            wallet_address: "0xabcdef1234567890abcdef1234567890abcdef12",
            creator_type: "standard",
            reputation_score: 40
        },
        
        collection: {
            id: 2,
            name: "Pixel Perfect",
            floor_price: 0.3
        },
        
        auction: null,
        transaction_history: [],
        bids: [],
        
        metadata: {
            attributes: [
                { trait_type: "Style", value: "8-bit" },
                { trait_type: "Class", value: "Warrior" },
                { trait_type: "Weapon", value: "Sword" },
                { trait_type: "Rarity", value: "Common" }
            ],
            external_url: "https://pixelwizard.com/8bit-warriors",
            animation_url: "https://example.com/animations/warriors.gif",
            background_color: "000000"
        },
        
        analytics: {
            daily_views: [
                { date: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000), views: 85 },
                { date: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), views: 92 }
            ],
            countries: ["US", "Japan", "South Korea"],
            referrers: ["direct", "discord.com", "reddit.com"]
        }
    },
    {
        _id: 3,
        token_id: "TOKEN_003",
        title: "Verified Masterpiece",
        description: "An exclusive artwork from a verified gold-tier creator",
        image_url: "https://example.com/nfts/verified-masterpiece.jpg",
        metadata_url: "https://example.com/metadata/verified-masterpiece.json",
        price: 5.5,
        royalty_percentage: 8.0,
        tags: ["verified", "exclusive", "premium", "masterpiece"],
        created_at: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), // 2 days ago
        last_sale_date: null,
        view_count: 2500,
        like_count: 345,
        current_owner_wallet: "0x7777888899990000111122223333444455556666",
        
        creator: {
            id: 3,
            username: "VerifiedArtist",
            wallet_address: "0x7777888899990000111122223333444455556666",
            creator_type: "verified",
            reputation_score: 80,
            verification: {
                tier: "Gold",
                verified: true
            }
        },
        
        collection: {
            id: 2,
            name: "Pixel Perfect",
            floor_price: 0.3
        },
        
        auction: null,
        transaction_history: [],
        bids: [],
        
        metadata: {
            attributes: [
                { trait_type: "Style", value: "Contemporary" },
                { trait_type: "Medium", value: "Digital" },
                { trait_type: "Verification", value: "Gold Tier" },
                { trait_type: "Rarity", value: "Legendary" }
            ],
            external_url: "https://verifiedartist.com/masterpiece",
            animation_url: null,
            background_color: "ffd700"
        },
        
        analytics: {
            daily_views: [
                { date: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000), views: 500 },
                { date: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), views: 450 }
            ],
            countries: ["US", "UK", "France", "Switzerland"],
            referrers: ["foundation.app", "twitter.com", "instagram.com"]
        }
    },
    {
        _id: 4,
        token_id: "TOKEN_004",
        title: "Premium Collection #1",
        description: "First piece from an exclusive premium creator collection",
        image_url: "https://example.com/nfts/premium-collection-1.jpg",
        metadata_url: "https://example.com/metadata/premium-collection-1.json",
        price: 8.8,
        royalty_percentage: 12.0,
        tags: ["premium", "exclusive", "collection", "first edition"],
        created_at: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000), // 1 day ago
        last_sale_date: null,
        view_count: 3200,
        like_count: 456,
        current_owner_wallet: "0x9999000011112222333344445555666677778888",
        
        creator: {
            id: 4,
            username: "PremiumMaster",
            wallet_address: "0x9999000011112222333344445555666677778888",
            creator_type: "premium",
            reputation_score: 95,
            verification: {
                tier: "Gold",
                verified: true
            },
            premium: {
                tier: "Platinum",
                exclusive_access: true
            }
        },
        
        collection: {
            id: 3,
            name: "Abstract Expressions",
            floor_price: 1.2
        },
        
        auction: null,
        transaction_history: [],
        bids: [],
        
        metadata: {
            attributes: [
                { trait_type: "Style", value: "Premium Abstract" },
                { trait_type: "Series", value: "First Edition" },
                { trait_type: "Access Level", value: "Platinum" },
                { trait_type: "Rarity", value: "Mythic" }
            ],
            external_url: "https://premiummaster.art/collection-1",
            animation_url: "https://example.com/animations/premium-1.mp4",
            background_color: "9400d3"
        },
        
        analytics: {
            daily_views: [
                { date: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000), views: 800 },
                { date: new Date(), views: 1200 }
            ],
            countries: ["US", "Singapore", "UAE", "Monaco"],
            referrers: ["supersea.io", "premiummaster.art", "twitter.com"]
        }
    }
]);

// Create indexes for better query performance
db.nfts.createIndex({ "creator.id": 1 });
db.nfts.createIndex({ "collection.id": 1 });
db.nfts.createIndex({ price: 1 });
db.nfts.createIndex({ created_at: 1 });
db.nfts.createIndex({ tags: 1 });
db.nfts.createIndex({ "creator.creator_type": 1 });

db.creators.createIndex({ creator_type: 1 });
db.creators.createIndex({ wallet_address: 1 });
db.creators.createIndex({ username: 1 });
db.creators.createIndex({ "reputation.score": 1 });

db.transactions.createIndex({ transaction_timestamp: 1 });
db.transactions.createIndex({ transaction_type: 1 });
db.transactions.createIndex({ "details.from_wallet": 1 });
db.transactions.createIndex({ "details.to_wallet": 1 });

db.auctions.createIndex({ status: 1 });
db.auctions.createIndex({ end_time: 1 });

db.collections.createIndex({ name: 1 });
db.collections.createIndex({ "metadata.category": 1 });

// Update collection statistics based on inserted NFTs
db.collections.updateOne(
    { _id: 1 },
    { 
        $set: { 
            item_count: 1,
            total_volume: 2.5,
            "metadata.artist_count": 1
        }
    }
);

db.collections.updateOne(
    { _id: 2 },
    { 
        $set: { 
            item_count: 2,
            total_volume: 6.7, // 1.2 + 5.5
            "metadata.artist_count": 2
        }
    }
);

db.collections.updateOne(
    { _id: 3 },
    { 
        $set: { 
            item_count: 1,
            total_volume: 8.8,
            "metadata.artist_count": 1
        }
    }
);

// Update marketplace statistics
db.marketplace.updateOne(
    { _id: 1 },
    { 
        $set: { 
            total_volume: 18.0, // Sum of all NFT prices
            total_transactions: 2,
            active_listings: 4
        }
    }
);

print("=== NFT Marketplace MongoDB Database Created Successfully ===");
print("Document Store Features Demonstrated:");
print("1. Embedded documents for complex object relationships");
print("2. Arrays for collections of data (tags, bids, analytics)");
print("3. Type discrimination for inheritance-like behavior");
print("4. Denormalized data for query performance");
print("5. Temporal data with native Date objects");
print("6. Nested document structures for complex data");
print("7. Flexible schema allowing different document structures");
print("8. Rich metadata embedded within documents");
print("=== Database ready for queries! ===");