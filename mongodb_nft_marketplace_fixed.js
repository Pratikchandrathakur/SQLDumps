// Digital Art NFT Marketplace & Creator Economy - MongoDB Document Store Implementation
// This script creates the equivalent NoSQL document store for the Oracle object-relational database
// Demonstrates MongoDB features: nested documents, arrays, temporal data, embedded objects

// Connect to MongoDB database
use nft_marketplace

// Drop existing collections to ensure clean start
db.creators.drop();
db.nfts.drop();
db.collections.drop();
db.auctions.drop();
db.transactions.drop();
db.marketplace.drop();

// Create collections with flexible validation schemas

// Marketplace collection with flexible schema
db.createCollection("marketplace", {
   validator: {
      $jsonSchema: {
         bsonType: "object",
         required: ["marketplace_id", "name", "platform_fee_percentage"],
         properties: {
            marketplace_id: { bsonType: "int" },
            name: { bsonType: "string" },
            platform_fee_percentage: { bsonType: "double" },
            total_volume: { bsonType: "double" },
            total_transactions: { bsonType: "int" },
            active_listings: { bsonType: "int" },
            created_at: { bsonType: "date" }
         },
         additionalProperties: true
      }
   }
});

// Collections (NFT Collections) with flexible schema
db.createCollection("collections", {
   validator: {
      $jsonSchema: {
         bsonType: "object",
         required: ["collection_id", "name"],
         properties: {
            collection_id: { bsonType: "int" },
            name: { bsonType: "string" },
            description: { bsonType: "string" },
            cover_image_url: { bsonType: "string" },
            floor_price: { bsonType: "double" },
            total_volume: { bsonType: "double" },
            item_count: { bsonType: "int" },
            created_at: { bsonType: "date" }
         },
         additionalProperties: true
      }
   }
});

// Creators collection with inheritance hierarchy using discriminator pattern
db.createCollection("creators", {
   validator: {
      $jsonSchema: {
         bsonType: "object",
         required: ["creator_id", "wallet_address", "username", "creator_type"],
         properties: {
            creator_id: { bsonType: "int" },
            creator_type: { enum: ["standard", "verified", "premium"] },
            wallet_address: { bsonType: "string" },
            username: { bsonType: "string" },
            email: { bsonType: "string" },
            bio: { bsonType: "string" },
            profile_image_url: { bsonType: "string" },
            created_at: { bsonType: "date" },
            total_sales: { bsonType: "double" },
            total_earnings: { bsonType: "double" }
         },
         additionalProperties: true
      }
   }
});

// Auctions collection with flexible schema
db.createCollection("auctions", {
   validator: {
      $jsonSchema: {
         bsonType: "object",
         required: ["auction_id", "starting_price", "status"],
         properties: {
            auction_id: { bsonType: "int" },
            starting_price: { bsonType: "double" },
            current_highest_bid: { bsonType: "double" },
            reserve_price: { bsonType: "double" },
            start_time: { bsonType: "date" },
            end_time: { bsonType: "date" },
            status: { bsonType: "string" }
         },
         additionalProperties: true
      }
   }
});

// Transactions collection with flexible schema
db.createCollection("transactions", {
   validator: {
      $jsonSchema: {
         bsonType: "object",
         required: ["transaction_id", "transaction_hash", "transaction_type_name"],
         properties: {
            transaction_id: { bsonType: "int" },
            transaction_hash: { bsonType: "string" },
            transaction_type_name: { bsonType: "string" },
            amount: { bsonType: "double" },
            platform_fee: { bsonType: "double" },
            gas_fee: { bsonType: "double" },
            transaction_timestamp: { bsonType: "date" },
            block_number: { bsonType: "int" }
         },
         additionalProperties: true
      }
   }
});

// NFTs collection with flexible schema for embedded documents
db.createCollection("nfts", {
   validator: {
      $jsonSchema: {
         bsonType: "object",
         required: ["nft_id", "token_id", "title"],
         properties: {
            nft_id: { bsonType: "int" },
            token_id: { bsonType: "string" },
            title: { bsonType: "string" },
            description: { bsonType: "string" },
            image_url: { bsonType: "string" },
            price: { bsonType: "double" },
            royalty_percentage: { bsonType: "double" },
            tags: { bsonType: "array" },
            created_at: { bsonType: "date" },
            view_count: { bsonType: "int" },
            like_count: { bsonType: "int" },
            current_owner_wallet: { bsonType: "string" }
         },
         additionalProperties: true
      }
   }
});

// Insert sample data that matches the Oracle database exactly

// Insert marketplace data
db.marketplace.insertOne({
    marketplace_id: 1,
    name: "NFTopia Marketplace",
    platform_fee_percentage: 2.5,
    total_volume: 0.0,
    total_transactions: 0,
    active_listings: 0,
    created_at: new Date("2025-07-03T05:34:18Z"),
    analytics: {
        daily_volume_estimate: 0.0,
        average_transaction_value: 0.0,
        peak_trading_hours: []
    }
});

// Insert collections data with embedded statistics
db.collections.insertMany([
    {
        collection_id: 1,
        name: "Digital Dreams",
        description: "Surreal digital art collection",
        cover_image_url: "https://example.com/collections/digital-dreams.jpg",
        floor_price: 0.5,
        total_volume: 0.0,
        item_count: 0,
        created_at: new Date("2025-07-03T05:34:18Z"),
        metrics: {
            average_price: 0.0,
            volume_24h: 0.0,
            unique_owners: 0,
            trending_score: 0.0
        },
        featured_nfts: []
    },
    {
        collection_id: 2,
        name: "Pixel Perfect",
        description: "Retro pixel art masterpieces",
        cover_image_url: "https://example.com/collections/pixel-perfect.jpg",
        floor_price: 0.3,
        total_volume: 0.0,
        item_count: 0,
        created_at: new Date("2025-07-03T05:34:18Z"),
        metrics: {
            average_price: 0.0,
            volume_24h: 0.0,
            unique_owners: 0,
            trending_score: 0.0
        },
        featured_nfts: []
    },
    {
        collection_id: 3,
        name: "Abstract Expressions",
        description: "Contemporary abstract digital art",
        cover_image_url: "https://example.com/collections/abstract.jpg",
        floor_price: 1.2,
        total_volume: 0.0,
        item_count: 0,
        created_at: new Date("2025-07-03T05:34:18Z"),
        metrics: {
            average_price: 0.0,
            volume_24h: 0.0,
            unique_owners: 0,
            trending_score: 0.0
        },
        featured_nfts: []
    }
]);

// Insert creators data using inheritance hierarchy with discriminator pattern
db.creators.insertMany([
    {
        creator_id: 1,
        creator_type: "standard",
        wallet_address: "0x1234567890abcdef1234567890abcdef12345678",
        username: "ArtMaster3000",
        email: "artist@example.com",
        bio: "Digital artist specializing in surreal landscapes",
        profile_image_url: "https://example.com/profiles/artmaster.jpg",
        created_at: new Date("2025-07-03T05:34:18Z"),
        total_sales: 0.0,
        total_earnings: 0.0,
        profile: {
            reputation_score: 40,
            status: "Emerging",
            followers: 150,
            following: 75,
            verified: false
        },
        social_links: [
            { platform: "twitter", url: "https://twitter.com/artmaster3000" },
            { platform: "instagram", url: "https://instagram.com/artmaster3000" }
        ],
        statistics: {
            total_views: 1250,
            total_likes: 89,
            avg_sale_price: 0.0,
            most_expensive_sale: 0.0
        }
    },
    {
        creator_id: 2,
        creator_type: "standard",
        wallet_address: "0xabcdef1234567890abcdef1234567890abcdef12",
        username: "PixelWizard",
        email: "pixel@example.com",
        bio: "Retro game-inspired pixel artist",
        profile_image_url: "https://example.com/profiles/pixelwizard.jpg",
        created_at: new Date("2025-07-03T05:34:18Z"),
        total_sales: 0.0,
        total_earnings: 0.0,
        profile: {
            reputation_score: 40,
            status: "Emerging",
            followers: 200,
            following: 100,
            verified: false
        },
        social_links: [
            { platform: "discord", url: "https://discord.com/pixelwizard" }
        ],
        statistics: {
            total_views: 850,
            total_likes: 156,
            avg_sale_price: 0.0,
            most_expensive_sale: 0.0
        }
    },
    {
        creator_id: 3,
        creator_type: "verified",
        wallet_address: "0x7777888899990000111122223333444455556666",
        username: "VerifiedArtist",
        email: "verified@example.com",
        bio: "Verified digital artist with gold tier",
        profile_image_url: "https://example.com/profiles/verified.jpg",
        created_at: new Date("2025-07-03T05:34:18Z"),
        total_sales: 0.0,
        total_earnings: 0.0,
        verification: {
            verification_date: new Date("2025-06-03T05:34:18Z"),
            verification_tier: "Gold",
            benefits: ["Lower fees", "Priority support", "Featured listings"],
            verified_by: "NFTopia Team",
            verification_badge_url: "https://example.com/badges/gold.png"
        },
        profile: {
            reputation_score: 80,
            status: "Verified Professional",
            followers: 5000,
            following: 500,
            verified: true
        },
        social_links: [
            { platform: "twitter", url: "https://twitter.com/verifiedartist" },
            { platform: "website", url: "https://verifiedartist.com" }
        ],
        statistics: {
            total_views: 2500,
            total_likes: 345,
            avg_sale_price: 0.0,
            most_expensive_sale: 0.0
        }
    },
    {
        creator_id: 4,
        creator_type: "premium",
        wallet_address: "0x9999000011112222333344445555666677778888",
        username: "PremiumMaster",
        email: "premium@example.com",
        bio: "Premium tier digital artist with exclusive features",
        profile_image_url: "https://example.com/profiles/premium.jpg",
        created_at: new Date("2025-07-03T05:34:18Z"),
        total_sales: 0.0,
        total_earnings: 0.0,
        verification: {
            verification_date: new Date("2025-05-19T05:34:18Z"),
            verification_tier: "Gold",
            benefits: ["Lower fees", "Priority support", "Featured listings"],
            verified_by: "NFTopia Team",
            verification_badge_url: "https://example.com/badges/gold.png"
        },
        premium: {
            premium_since: new Date("2025-06-18T05:34:18Z"),
            exclusive_features: ["Early Access", "Custom Marketplace", "Priority Support"],
            tier: "Platinum",
            custom_branding: {
                banner_url: "https://example.com/banners/premium.jpg",
                theme_color: "#FFD700",
                custom_domain: "premiummaster.nftopia.com"
            },
            analytics_access: true,
            api_access: true
        },
        profile: {
            reputation_score: 95,
            status: "Premium Verified Elite",
            followers: 15000,
            following: 1000,
            verified: true
        },
        social_links: [
            { platform: "twitter", url: "https://twitter.com/premiummaster" },
            { platform: "website", url: "https://premiummaster.com" },
            { platform: "youtube", url: "https://youtube.com/premiummaster" }
        ],
        statistics: {
            total_views: 3200,
            total_likes: 456,
            avg_sale_price: 0.0,
            most_expensive_sale: 0.0
        }
    }
]);

// Insert auctions data with embedded bid history
db.auctions.insertMany([
    {
        auction_id: 1,
        starting_price: 1.0,
        current_highest_bid: 0.0,
        reserve_price: 0.8,
        start_time: new Date("2025-07-03T05:34:18Z"),
        end_time: new Date("2025-07-10T05:34:18Z"),
        status: "ACTIVE",
        bid_history: [],
        metadata: {
            total_bids: 0,
            unique_bidders: 0,
            average_bid: 0.0,
            time_remaining_hours: 168
        }
    },
    {
        auction_id: 2,
        starting_price: 2.5,
        current_highest_bid: 3.1,
        reserve_price: 2.0,
        start_time: new Date("2025-07-01T05:34:18Z"),
        end_time: new Date("2025-07-08T05:34:18Z"),
        status: "ACTIVE",
        bid_history: [
            {
                bidder_wallet: "0xbidder1111222233334444555566667777888899990",
                bid_amount: 2.6,
                bid_timestamp: new Date("2025-07-03T03:34:18Z"),
                total_with_fees: 2.665
            },
            {
                bidder_wallet: "0xbidder2222333344445555666677778888999900001",
                bid_amount: 2.8,
                bid_timestamp: new Date("2025-07-03T04:34:18Z"),
                total_with_fees: 2.87
            },
            {
                bidder_wallet: "0xbidder3333444455556666777788889999000011112",
                bid_amount: 3.1,
                bid_timestamp: new Date("2025-07-03T05:04:18Z"),
                total_with_fees: 3.1775
            }
        ],
        metadata: {
            total_bids: 3,
            unique_bidders: 3,
            average_bid: 2.83,
            time_remaining_hours: 120
        }
    }
]);

// Insert transactions data with embedded blockchain details
db.transactions.insertMany([
    {
        transaction_id: 1,
        transaction_hash: "0xtx1234567890abcdef",
        transaction_type_name: "SALE",
        amount: 2.5,
        platform_fee: 0.0625,
        gas_fee: 0.01,
        transaction_timestamp: new Date("2025-07-02T05:34:18Z"),
        block_number: 1000001,
        blockchain: {
            network: "Ethereum",
            gas_used: 21000,
            gas_price: 20,
            confirmation_count: 12,
            status: "confirmed"
        },
        metadata: {
            total_cost: 2.5725,
            transaction_age_hours: 24,
            fee_percentage: 2.5
        }
    },
    {
        transaction_id: 2,
        transaction_hash: "0xtx2345678901bcdef0",
        transaction_type_name: "SALE",
        amount: 1.8,
        platform_fee: 0.045,
        gas_fee: 0.008,
        transaction_timestamp: new Date("2025-06-30T05:34:18Z"),
        block_number: 1000002,
        blockchain: {
            network: "Ethereum",
            gas_used: 21000,
            gas_price: 18,
            confirmation_count: 48,
            status: "confirmed"
        },
        metadata: {
            total_cost: 1.853,
            transaction_age_hours: 72,
            fee_percentage: 2.5
        }
    }
]);

// Insert NFTs data with embedded references and arrays
db.nfts.insertMany([
    {
        nft_id: 1,
        token_id: "TOKEN_001",
        title: "Ethereal Dreamscape",
        description: "A mesmerizing digital landscape that blurs the line between reality and dreams",
        image_url: "https://example.com/nfts/dreamscape.jpg",
        metadata_url: "https://example.com/metadata/dreamscape.json",
        price: 2.5,
        royalty_percentage: 5.0,
        tags: ["surreal", "landscape", "digital art", "dreams"],
        created_at: new Date("2025-06-23T05:34:18Z"),
        last_sale_date: new Date("2025-07-02T05:34:18Z"),
        view_count: 1250,
        like_count: 89,
        current_owner_wallet: "0x1234567890abcdef1234567890abcdef12345678",
        creator: {
            creator_id: 1,
            username: "ArtMaster3000",
            wallet_address: "0x1234567890abcdef1234567890abcdef12345678",
            creator_type: "standard",
            reputation_score: 40,
            verified: false
        },
        collection: {
            collection_id: 1,
            name: "Digital Dreams",
            floor_price: 0.5
        },
        auction: {
            auction_id: 1,
            status: "ACTIVE",
            current_highest_bid: 0.0,
            end_time: new Date("2025-07-10T05:34:18Z")
        },
        transaction_history: [
            {
                transaction_id: 1,
                transaction_hash: "0xtx1234567890abcdef",
                amount: 2.5,
                transaction_timestamp: new Date("2025-07-02T05:34:18Z"),
                transaction_type_name: "SALE"
            }
        ],
        bids: [
            {
                bidder_wallet: "0xbidder1111222233334444555566667777888899990",
                bid_amount: 1.2,
                bid_timestamp: new Date("2025-07-03T03:34:18Z"),
                total_with_fees: 1.23
            },
            {
                bidder_wallet: "0xbidder2222333344445555666677778888999900001",
                bid_amount: 1.5,
                bid_timestamp: new Date("2025-07-03T04:34:18Z"),
                total_with_fees: 1.5375
            },
            {
                bidder_wallet: "0xbidder3333444455556666777788889999000011112",
                bid_amount: 1.8,
                bid_timestamp: new Date("2025-07-03T05:04:18Z"),
                total_with_fees: 1.845
            }
        ],
        metadata: {
            file_size: "2.5MB",
            resolution: "1920x1080",
            format: "PNG",
            color_palette: ["#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4"],
            rarity_score: 85.6,
            attributes: [
                { trait_type: "Style", value: "Surreal" },
                { trait_type: "Mood", value: "Dreamy" },
                { trait_type: "Complexity", value: "High" }
            ]
        },
        engagement: {
            shares: 45,
            comments: 12,
            favorites: 89,
            views_24h: 150,
            trending_score: 78.5
        }
    },
    {
        nft_id: 2,
        token_id: "TOKEN_002",
        title: "8-Bit Warriors",
        description: "Classic retro-style warriors ready for digital battle",
        image_url: "https://example.com/nfts/8bit-warriors.jpg",
        metadata_url: "https://example.com/metadata/8bit-warriors.json",
        price: 1.2,
        royalty_percentage: 5.0,
        tags: ["pixel art", "retro", "gaming", "warriors"],
        created_at: new Date("2025-06-28T05:34:18Z"),
        last_sale_date: null,
        view_count: 850,
        like_count: 156,
        current_owner_wallet: "0xabcdef1234567890abcdef1234567890abcdef12",
        creator: {
            creator_id: 2,
            username: "PixelWizard",
            wallet_address: "0xabcdef1234567890abcdef1234567890abcdef12",
            creator_type: "standard",
            reputation_score: 40,
            verified: false
        },
        collection: {
            collection_id: 2,
            name: "Pixel Perfect",
            floor_price: 0.3
        },
        auction: null,
        transaction_history: [],
        bids: [],
        metadata: {
            file_size: "1.2MB",
            resolution: "512x512",
            format: "GIF",
            color_palette: ["#FF0000", "#00FF00", "#0000FF", "#FFFF00"],
            rarity_score: 72.3,
            attributes: [
                { trait_type: "Style", value: "Pixel Art" },
                { trait_type: "Era", value: "8-bit" },
                { trait_type: "Animation", value: "Static" }
            ]
        },
        engagement: {
            shares: 23,
            comments: 8,
            favorites: 156,
            views_24h: 89,
            trending_score: 65.2
        }
    },
    {
        nft_id: 3,
        token_id: "TOKEN_003",
        title: "Verified Masterpiece",
        description: "An exclusive artwork from a verified gold-tier creator",
        image_url: "https://example.com/nfts/verified-masterpiece.jpg",
        metadata_url: "https://example.com/metadata/verified-masterpiece.json",
        price: 5.5,
        royalty_percentage: 8.0,
        tags: ["verified", "exclusive", "premium", "masterpiece"],
        created_at: new Date("2025-07-01T05:34:18Z"),
        last_sale_date: null,
        view_count: 2500,
        like_count: 345,
        current_owner_wallet: "0x7777888899990000111122223333444455556666",
        creator: {
            creator_id: 3,
            username: "VerifiedArtist",
            wallet_address: "0x7777888899990000111122223333444455556666",
            creator_type: "verified",
            reputation_score: 80,
            verified: true,
            verification_tier: "Gold"
        },
        collection: {
            collection_id: 2,
            name: "Pixel Perfect",
            floor_price: 0.3
        },
        auction: null,
        transaction_history: [],
        bids: [],
        metadata: {
            file_size: "4.8MB",
            resolution: "2048x2048",
            format: "PNG",
            color_palette: ["#FFD700", "#C0C0C0", "#CD7F32", "#000000"],
            rarity_score: 94.7,
            attributes: [
                { trait_type: "Style", value: "Contemporary" },
                { trait_type: "Status", value: "Verified" },
                { trait_type: "Exclusivity", value: "Limited" }
            ]
        },
        engagement: {
            shares: 89,
            comments: 34,
            favorites: 345,
            views_24h: 450,
            trending_score: 92.1
        }
    },
    {
        nft_id: 4,
        token_id: "TOKEN_004",
        title: "Premium Collection #1",
        description: "First piece from an exclusive premium creator collection",
        image_url: "https://example.com/nfts/premium-collection-1.jpg",
        metadata_url: "https://example.com/metadata/premium-collection-1.json",
        price: 8.8,
        royalty_percentage: 12.0,
        tags: ["premium", "exclusive", "collection", "first edition"],
        created_at: new Date("2025-07-02T05:34:18Z"),
        last_sale_date: null,
        view_count: 3200,
        like_count: 456,
        current_owner_wallet: "0x9999000011112222333344445555666677778888",
        creator: {
            creator_id: 4,
            username: "PremiumMaster",
            wallet_address: "0x9999000011112222333344445555666677778888",
            creator_type: "premium",
            reputation_score: 95,
            verified: true,
            verification_tier: "Gold",
            premium_features: ["Early Access", "Custom Marketplace", "Priority Support"]
        },
        collection: {
            collection_id: 3,
            name: "Abstract Expressions",
            floor_price: 1.2
        },
        auction: null,
        transaction_history: [],
        bids: [],
        metadata: {
            file_size: "6.2MB",
            resolution: "3840x2160",
            format: "PNG",
            color_palette: ["#FF1493", "#00CED1", "#FF6347", "#9370DB"],
            rarity_score: 98.9,
            attributes: [
                { trait_type: "Style", value: "Abstract" },
                { trait_type: "Status", value: "Premium" },
                { trait_type: "Edition", value: "First" },
                { trait_type: "Tier", value: "Platinum" }
            ]
        },
        engagement: {
            shares: 156,
            comments: 67,
            favorites: 456,
            views_24h: 890,
            trending_score: 97.8
        }
    }
]);

// Create indexes for better query performance
db.creators.createIndex({ "creator_id": 1 }, { unique: true })
db.creators.createIndex({ "wallet_address": 1 }, { unique: true })
db.creators.createIndex({ "username": 1 }, { unique: true })
db.creators.createIndex({ "creator_type": 1 })
db.creators.createIndex({ "profile.reputation_score": -1 })

db.nfts.createIndex({ "nft_id": 1 }, { unique: true })
db.nfts.createIndex({ "token_id": 1 }, { unique: true })
db.nfts.createIndex({ "creator.creator_id": 1 })
db.nfts.createIndex({ "collection.collection_id": 1 })
db.nfts.createIndex({ "price": 1 })
db.nfts.createIndex({ "created_at": -1 })
db.nfts.createIndex({ "tags": 1 })
db.nfts.createIndex({ "view_count": -1 })

db.collections.createIndex({ "collection_id": 1 }, { unique: true })
db.collections.createIndex({ "name": 1 })
db.collections.createIndex({ "floor_price": 1 })

db.auctions.createIndex({ "auction_id": 1 }, { unique: true })
db.auctions.createIndex({ "status": 1 })
db.auctions.createIndex({ "end_time": 1 })

db.transactions.createIndex({ "transaction_id": 1 }, { unique: true })
db.transactions.createIndex({ "transaction_hash": 1 }, { unique: true })
db.transactions.createIndex({ "transaction_timestamp": -1 })
db.transactions.createIndex({ "transaction_type_name": 1 })

db.marketplace.createIndex({ "marketplace_id": 1 }, { unique: true })

// Print confirmation message
print("MongoDB NFT Marketplace database created successfully!")
print("Collections created:")
print("- creators: " + db.creators.countDocuments())
print("- nfts: " + db.nfts.countDocuments())
print("- collections: " + db.collections.countDocuments())
print("- auctions: " + db.auctions.countDocuments())
print("- transactions: " + db.transactions.countDocuments())
print("- marketplace: " + db.marketplace.countDocuments())
print("All indexes created for optimal query performance.")

print("")
print("=== MongoDB Document Store Features Demonstrated ===")
print("1. Nested Documents: Creator profiles, metadata, analytics embedded")
print("2. Arrays: Tags, bid_history, transaction_history, social_links")
print("3. Inheritance via Discriminator: creator_type field with polymorphic behavior")
print("4. Temporal Data: ISODate objects for timestamps and intervals")
print("5. Embedded References: Denormalized creator and collection data in NFTs")
print("6. Schema Validation: JSON Schema validators for data integrity")
print("7. Flexible Schema: Different document structures based on type")
print("8. Document Embedding: Reduced collections by embedding related data")
print("=== Database ready for NoSQL queries! ===")