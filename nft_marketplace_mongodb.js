// Digital Art NFT Marketplace & Creator Economy - MongoDB Implementation
// This file contains all MongoDB collections, data insertion, and queries
// Demonstrating conversion from Object-Relational to Document Store features

// Connect to MongoDB and select database
use nft_marketplace;

// Drop existing collections to start fresh
db.creators.drop();
db.nfts.drop();
db.collections.drop();
db.marketplaces.drop();
db.auctions.drop();
db.transactions.drop();

// ============================================================================
// COLLECTION 1: CREATORS
// Demonstrates: Inheritance through embedded documents, polymorphism
// ============================================================================

db.creators.insertMany([
    // Standard Creator
    {
        _id: ObjectId(),
        creator_id: 1,
        wallet_address: "0x1234567890abcdef1234567890abcdef12345678",
        username: "ArtMaster3000",
        email: "artist@example.com",
        bio: "Digital artist specializing in surreal landscapes",
        profile_image_url: "https://example.com/profiles/artmaster.jpg",
        created_at: new Date("2024-06-01T10:00:00Z"),
        total_sales: 3,
        total_earnings: 18.75,
        creator_type: "standard",
        reputation_metrics: {
            score: 75.5,
            status: "Established",
            reviews_count: 25,
            average_rating: 4.6
        },
        social_media: {
            twitter: "@artmaster3000",
            instagram: "artmaster_digital",
            website: "https://artmaster3000.art"
        },
        created_nfts: [1, 4],
        favorite_tags: ["surreal", "landscape", "digital art", "dreams"]
    },
    
    // Standard Creator 2
    {
        _id: ObjectId(),
        creator_id: 2,
        wallet_address: "0xabcdef1234567890abcdef1234567890abcdef12",
        username: "PixelWizard",
        email: "pixel@example.com",
        bio: "Retro game-inspired pixel artist",
        profile_image_url: "https://example.com/profiles/pixelwizard.jpg",
        created_at: new Date("2024-05-15T14:30:00Z"),
        total_sales: 2,
        total_earnings: 6.0,
        creator_type: "standard",
        reputation_metrics: {
            score: 62.8,
            status: "Emerging",
            reviews_count: 18,
            average_rating: 4.3
        },
        social_media: {
            twitter: "@pixelwizard",
            discord: "PixelWizard#1234"
        },
        created_nfts: [2, 5],
        favorite_tags: ["pixel art", "retro", "gaming", "8bit"]
    },
    
    // Verified Creator (inheritance - additional verification fields)
    {
        _id: ObjectId(),
        creator_id: 5,
        wallet_address: "0x7777888899990000111122223333444455556666",
        username: "VerifiedArtist",
        email: "verified@example.com",
        bio: "Verified digital artist with gold tier status",
        profile_image_url: "https://example.com/profiles/verified.jpg",
        created_at: new Date("2024-05-01T09:15:00Z"),
        total_sales: 5,
        total_earnings: 41.25,
        creator_type: "verified",
        
        // Verification-specific embedded document
        verification: {
            verified_date: new Date("2024-05-01T12:00:00Z"),
            tier: "Gold",
            verification_authority: "NFTopia Verification Board",
            benefits: [
                "Lower fees (1.5% instead of 2.5%)",
                "Priority customer support",
                "Featured in verified collections",
                "Early access to new features"
            ],
            documents_verified: ["identity", "portfolio", "social_media"]
        },
        
        reputation_metrics: {
            score: 88.2,
            status: "Verified Professional",
            reviews_count: 47,
            average_rating: 4.8,
            verification_boost: 15
        },
        
        social_media: {
            twitter: "@verifiedartist",
            instagram: "verified_digital_art",
            website: "https://verifiedartist.com",
            linkedin: "verified-artist"
        },
        
        created_nfts: [5],
        favorite_tags: ["verified", "exclusive", "premium", "professional"],
        
        // Additional features for verified creators
        featured_works: [
            {
                nft_id: 5,
                featured_date: new Date("2024-06-15T00:00:00Z"),
                feature_duration_days: 7
            }
        ]
    },
    
    // Premium Creator (multiple inheritance - verified + premium features)
    {
        _id: ObjectId(),
        creator_id: 7,
        wallet_address: "0x9999000011112222333344445555666677778888",
        username: "PremiumMaster",
        email: "premium@example.com",
        bio: "Premium tier digital artist with exclusive marketplace features",
        profile_image_url: "https://example.com/profiles/premium.jpg",
        created_at: new Date("2024-04-15T11:20:00Z"),
        total_sales: 8,
        total_earnings: 105.6,
        creator_type: "premium",
        
        // Verification embedded document (inherited from verified)
        verification: {
            verified_date: new Date("2024-04-20T10:00:00Z"),
            tier: "Gold",
            verification_authority: "NFTopia Verification Board",
            benefits: [
                "Lowest fees (1% only)",
                "24/7 priority support",
                "Featured listings guaranteed",
                "Beta feature access",
                "Custom marketplace themes"
            ],
            documents_verified: ["identity", "portfolio", "social_media", "tax_documentation"]
        },
        
        // Premium-specific embedded document
        premium: {
            premium_since: new Date("2024-05-01T00:00:00Z"),
            subscription_tier: "Platinum",
            monthly_fee: 99.99,
            exclusive_features: [
                "Custom marketplace storefront",
                "Advanced analytics dashboard",
                "Bulk upload tools",
                "API access",
                "White-label solutions"
            ],
            api_key: "premium_api_key_12345",
            custom_branding: {
                primary_color: "#FF6B35",
                secondary_color: "#004E89",
                logo_url: "https://example.com/premium/logo.png"
            }
        },
        
        reputation_metrics: {
            score: 96.7,
            status: "Premium Elite",
            reviews_count: 89,
            average_rating: 4.9,
            verification_boost: 15,
            premium_boost: 10
        },
        
        social_media: {
            twitter: "@premiummaster",
            instagram: "premium_digital_art",
            website: "https://premiummaster.art",
            linkedin: "premium-master-artist",
            youtube: "PremiumArtTutorials"
        },
        
        created_nfts: [6],
        favorite_tags: ["premium", "exclusive", "luxury", "limited edition"],
        
        // Advanced analytics embedded
        analytics: {
            monthly_views: 15420,
            conversion_rate: 3.2,
            top_performing_tags: ["luxury", "limited edition"],
            geographic_distribution: {
                "North America": 45,
                "Europe": 30,
                "Asia": 20,
                "Other": 5
            }
        }
    }
]);

// ============================================================================
// COLLECTION 2: NFT COLLECTIONS
// Demonstrates: Aggregation, embedded statistics, temporal data
// ============================================================================

db.collections.insertMany([
    {
        _id: ObjectId(),
        collection_id: 1,
        name: "Digital Dreams",
        description: "A mesmerizing collection of surreal digital landscapes that blur the line between reality and imagination",
        cover_image_url: "https://example.com/collections/digital-dreams.jpg",
        created_at: new Date("2024-05-01T00:00:00Z"),
        
        // Embedded pricing and statistics
        pricing: {
            floor_price: 1.2,
            ceiling_price: 8.8,
            average_price: 4.15,
            total_volume: 16.6,
            currency: "ETH"
        },
        
        // Collection statistics embedded
        statistics: {
            item_count: 4,
            total_owners: 4,
            unique_owners: 4,
            trading_volume_24h: 0,
            trading_volume_7d: 2.5,
            trading_volume_30d: 8.3,
            trading_volume_all_time: 16.6
        },
        
        // Category and attributes
        category: "Digital Art",
        subcategory: "Surreal Landscapes",
        tags: ["surreal", "landscape", "digital", "dreams", "fantasy"],
        
        // Royalty information
        royalty: {
            percentage: 7.5,
            beneficiary_wallet: "0x1234567890abcdef1234567890abcdef12345678",
            split_enabled: false
        },
        
        // Social and marketing
        social_links: {
            website: "https://digitaldreams.art",
            twitter: "@digitaldreams_nft",
            discord: "https://discord.gg/digitaldreams"
        },
        
        // Time-based data for temporal queries
        milestones: [
            {
                event: "Collection Launch",
                date: new Date("2024-05-01T00:00:00Z"),
                description: "Initial collection launch with 2 pieces"
            },
            {
                event: "First Sale",
                date: new Date("2024-06-28T15:30:00Z"),
                description: "First NFT sold for 2.5 ETH"
            }
        ]
    },
    
    {
        _id: ObjectId(),
        collection_id: 2,
        name: "Pixel Perfect",
        description: "Retro pixel art masterpieces inspired by classic video games and 8-bit aesthetics",
        cover_image_url: "https://example.com/collections/pixel-perfect.jpg",
        created_at: new Date("2024-05-10T00:00:00Z"),
        
        pricing: {
            floor_price: 1.2,
            ceiling_price: 5.5,
            average_price: 2.9,
            total_volume: 8.7,
            currency: "ETH"
        },
        
        statistics: {
            item_count: 3,
            total_owners: 3,
            unique_owners: 3,
            trading_volume_24h: 0,
            trading_volume_7d: 0,
            trading_volume_30d: 0,
            trading_volume_all_time: 0
        },
        
        category: "Pixel Art",
        subcategory: "Retro Gaming",
        tags: ["pixel", "retro", "gaming", "8bit", "nostalgia"],
        
        royalty: {
            percentage: 5.0,
            beneficiary_wallet: "0xabcdef1234567890abcdef1234567890abcdef12",
            split_enabled: false
        },
        
        social_links: {
            twitter: "@pixelperfect_nft",
            discord: "https://discord.gg/pixelperfect"
        },
        
        milestones: [
            {
                event: "Collection Launch",
                date: new Date("2024-05-10T00:00:00Z"),
                description: "Pixel Perfect collection goes live"
            }
        ]
    },
    
    {
        _id: ObjectId(),
        collection_id: 3,
        name: "Abstract Expressions",
        description: "Contemporary abstract digital art exploring mathematical concepts and chaos theory",
        cover_image_url: "https://example.com/collections/abstract.jpg",
        created_at: new Date("2024-05-20T00:00:00Z"),
        
        pricing: {
            floor_price: 4.8,
            ceiling_price: 8.8,
            average_price: 6.8,
            total_volume: 13.6,
            currency: "ETH"
        },
        
        statistics: {
            item_count: 2,
            total_owners: 2,
            unique_owners: 2,
            trading_volume_24h: 0,
            trading_volume_7d: 4.8,
            trading_volume_30d: 4.8,
            trading_volume_all_time: 4.8
        },
        
        category: "Abstract Art",
        subcategory: "Mathematical Art",
        tags: ["abstract", "mathematics", "chaos theory", "contemporary"],
        
        royalty: {
            percentage: 10.0,
            beneficiary_wallet: "0x9876543210fedcba9876543210fedcba98765432",
            split_enabled: true,
            splits: [
                { wallet: "0x9876543210fedcba9876543210fedcba98765432", percentage: 70 },
                { wallet: "0x1111222233334444555566667777888899990000", percentage: 30 }
            ]
        },
        
        social_links: {
            website: "https://abstractexpressions.art",
            twitter: "@abstract_expr_nft"
        },
        
        milestones: [
            {
                event: "Collection Launch",
                date: new Date("2024-05-20T00:00:00Z"),
                description: "Abstract Expressions collection debuts"
            },
            {
                event: "Featured Collection",
                date: new Date("2024-06-01T00:00:00Z"),
                description: "Featured on marketplace homepage"
            }
        ]
    }
]);

// ============================================================================
// COLLECTION 3: MARKETPLACES
// Demonstrates: Platform management, aggregated statistics
// ============================================================================

db.marketplaces.insertMany([
    {
        _id: ObjectId(),
        marketplace_id: 1,
        name: "NFTopia Marketplace",
        description: "Premier destination for digital art NFTs with advanced creator tools",
        website: "https://nftopia.com",
        
        // Fee structure embedded
        fee_structure: {
            platform_fee_percentage: 2.5,
            creator_royalty_percentage: 5.0,
            minimum_listing_price: 0.01,
            currency: "ETH",
            payment_methods: ["ETH", "WETH", "USDC"]
        },
        
        // Aggregated platform statistics
        statistics: {
            total_volume: 38.9,
            total_transactions: 6,
            active_listings: 6,
            total_users: 7,
            total_creators: 5,
            total_collections: 3,
            average_transaction_value: 6.48
        },
        
        // Supported blockchain networks
        supported_networks: [
            {
                name: "Ethereum",
                chain_id: 1,
                native_currency: "ETH",
                enabled: true
            },
            {
                name: "Polygon",
                chain_id: 137,
                native_currency: "MATIC",
                enabled: false
            }
        ],
        
        // Platform features
        features: [
            "Advanced search and filtering",
            "Real-time bidding",
            "Creator verification system",
            "Analytics dashboard",
            "Social features",
            "Mobile responsive design"
        ],
        
        // Temporal data for platform evolution
        launch_date: new Date("2024-04-01T00:00:00Z"),
        major_updates: [
            {
                version: "1.0",
                date: new Date("2024-04-01T00:00:00Z"),
                features: ["Basic marketplace functionality", "Creator onboarding"]
            },
            {
                version: "1.1",
                date: new Date("2024-05-01T00:00:00Z"),
                features: ["Verification system", "Advanced search"]
            },
            {
                version: "1.2",
                date: new Date("2024-06-01T00:00:00Z"),
                features: ["Analytics dashboard", "Premium creator tools"]
            }
        ]
    }
]);

// ============================================================================
// COLLECTION 4: AUCTIONS
// Demonstrates: Real-time data, nested bid arrays, temporal features
// ============================================================================

db.auctions.insertMany([
    {
        _id: ObjectId(),
        auction_id: 1,
        nft_id: 1,
        starting_price: 1.0,
        current_highest_bid: 1.8,
        reserve_price: 0.8,
        start_time: new Date("2024-07-02T00:00:00Z"),
        end_time: new Date("2024-07-09T00:00:00Z"),
        status: "active",
        
        // Bid history as nested array
        bids: [
            {
                bid_id: ObjectId(),
                bidder_wallet: "0xbidder1111222233334444555566667777888899990",
                bid_amount: 1.2,
                bid_timestamp: new Date("2024-07-02T14:00:00Z"),
                transaction_hash: "0xbid1234567890abcdef",
                is_winning: false,
                bid_with_fees: 1.23
            },
            {
                bid_id: ObjectId(),
                bidder_wallet: "0xbidder2222333344445555666677778888999900001",
                bid_amount: 1.5,
                bid_timestamp: new Date("2024-07-02T15:00:00Z"),
                transaction_hash: "0xbid2345678901bcdef0",
                is_winning: false,
                bid_with_fees: 1.5375
            },
            {
                bid_id: ObjectId(),
                bidder_wallet: "0xbidder3333444455556666777788889999000011112",
                bid_amount: 1.8,
                bid_timestamp: new Date("2024-07-02T15:30:00Z"),
                transaction_hash: "0xbid3456789012cdef01",
                is_winning: true,
                bid_with_fees: 1.845
            }
        ],
        
        // Auction metadata
        auction_type: "english", // english, dutch, sealed-bid
        minimum_bid_increment: 0.1,
        auto_extend_enabled: true,
        auto_extend_duration: 600, // 10 minutes in seconds
        
        // Performance metrics
        metrics: {
            total_bids: 3,
            unique_bidders: 3,
            bid_frequency: "high",
            last_bid_time: new Date("2024-07-02T15:30:00Z"),
            time_remaining: 517200 // seconds until end_time
        }
    },
    
    {
        _id: ObjectId(),
        auction_id: 2,
        nft_id: 3,
        starting_price: 2.5,
        current_highest_bid: 3.1,
        reserve_price: 2.0,
        start_time: new Date("2024-07-01T00:00:00Z"),
        end_time: new Date("2024-07-08T00:00:00Z"),
        status: "active",
        
        bids: [
            {
                bid_id: ObjectId(),
                bidder_wallet: "0xbidder4444555566667777888899990000111122223",
                bid_amount: 2.7,
                bid_timestamp: new Date("2024-07-01T10:00:00Z"),
                transaction_hash: "0xbid4567890123def012",
                is_winning: false,
                bid_with_fees: 2.7675
            },
            {
                bid_id: ObjectId(),
                bidder_wallet: "0xbidder5555666677778888999900001111222233334",
                bid_amount: 3.1,
                bid_timestamp: new Date("2024-07-01T16:00:00Z"),
                transaction_hash: "0xbid5678901234ef0123",
                is_winning: true,
                bid_with_fees: 3.1775
            }
        ],
        
        auction_type: "english",
        minimum_bid_increment: 0.2,
        auto_extend_enabled: true,
        auto_extend_duration: 300,
        
        metrics: {
            total_bids: 2,
            unique_bidders: 2,
            bid_frequency: "medium",
            last_bid_time: new Date("2024-07-01T16:00:00Z"),
            time_remaining: 430800
        }
    }
]);

// ============================================================================
// COLLECTION 5: TRANSACTIONS
// Demonstrates: Financial data, blockchain integration, temporal queries
// ============================================================================

db.transactions.insertMany([
    {
        _id: ObjectId(),
        transaction_id: 1,
        transaction_hash: "0xtx1234567890abcdef",
        transaction_type: "sale",
        nft_id: 1,
        
        // Financial details embedded
        financial: {
            amount: 2.5,
            platform_fee: 0.0625,
            gas_fee: 0.01,
            total_cost: 2.5725,
            currency: "ETH",
            usd_equivalent: 4628.75, // at time of transaction
            exchange_rate: 1851.5
        },
        
        // Blockchain details
        blockchain: {
            network: "Ethereum",
            block_number: 1000001,
            block_hash: "0xblock1234567890abcdef",
            gas_used: 21000,
            gas_price: 20, // gwei
            confirmation_time: 13.2 // seconds
        },
        
        // Parties involved
        parties: {
            seller: "0x1234567890abcdef1234567890abcdef12345678",
            buyer: "0xbuyer1111222233334444555566667777888899990",
            marketplace: "0xnftopia1234567890abcdef1234567890abcdef123"
        },
        
        // Temporal data
        timestamps: {
            initiated: new Date("2024-06-29T15:30:00Z"),
            confirmed: new Date("2024-06-29T15:30:13Z"),
            finalized: new Date("2024-06-29T15:31:00Z")
        },
        
        status: "completed",
        
        // Additional metadata
        metadata: {
            payment_method: "wallet_direct",
            escrow_used: false,
            instant_transfer: true
        }
    },
    
    {
        _id: ObjectId(),
        transaction_id: 2,
        transaction_hash: "0xtx2345678901bcdef0",
        transaction_type: "sale",
        nft_id: 2,
        
        financial: {
            amount: 1.8,
            platform_fee: 0.045,
            gas_fee: 0.008,
            total_cost: 1.853,
            currency: "ETH",
            usd_equivalent: 3330.0,
            exchange_rate: 1850.0
        },
        
        blockchain: {
            network: "Ethereum",
            block_number: 1000002,
            block_hash: "0xblock2345678901bcdef0",
            gas_used: 21000,
            gas_price: 18,
            confirmation_time: 14.8
        },
        
        parties: {
            seller: "0xabcdef1234567890abcdef1234567890abcdef12",
            buyer: "0xbuyer2222333344445555666677778888999900001",
            marketplace: "0xnftopia1234567890abcdef1234567890abcdef123"
        },
        
        timestamps: {
            initiated: new Date("2024-06-30T10:15:00Z"),
            confirmed: new Date("2024-06-30T10:15:15Z"),
            finalized: new Date("2024-06-30T10:16:00Z")
        },
        
        status: "completed",
        
        metadata: {
            payment_method: "wallet_direct",
            escrow_used: false,
            instant_transfer: true
        }
    },
    
    {
        _id: ObjectId(),
        transaction_id: 3,
        transaction_hash: "0xtx3456789012cdef01",
        transaction_type: "auction",
        nft_id: 3,
        auction_id: 2,
        
        financial: {
            amount: 3.2,
            platform_fee: 0.08,
            gas_fee: 0.012,
            total_cost: 3.292,
            currency: "ETH",
            usd_equivalent: 5920.0,
            exchange_rate: 1850.0
        },
        
        blockchain: {
            network: "Ethereum",
            block_number: 1000003,
            block_hash: "0xblock3456789012cdef01",
            gas_used: 31500,
            gas_price: 22,
            confirmation_time: 12.1
        },
        
        parties: {
            seller: "0x9876543210fedcba9876543210fedcba98765432",
            buyer: "0xbuyer3333444455556666777788889999000011112",
            marketplace: "0xnftopia1234567890abcdef1234567890abcdef123"
        },
        
        timestamps: {
            initiated: new Date("2024-06-28T20:45:00Z"),
            confirmed: new Date("2024-06-28T20:45:12Z"),
            finalized: new Date("2024-06-28T20:46:00Z")
        },
        
        status: "completed",
        
        metadata: {
            payment_method: "auction_settlement",
            escrow_used: true,
            instant_transfer: false,
            winning_bid: true
        }
    }
]);

// ============================================================================
// COLLECTION 6: NFTS (Main Collection)
// Demonstrates: Complex document structure, multiple relationships via embedded refs
// ============================================================================

db.nfts.insertMany([
    {
        _id: ObjectId(),
        nft_id: 1,
        token_id: "TOKEN_001",
        title: "Ethereal Dreamscape",
        description: "A mesmerizing digital landscape that blurs the line between reality and dreams. This piece explores the subconscious mind through surreal imagery and ethereal color palettes.",
        
        // Media and metadata
        media: {
            image_url: "https://example.com/nfts/dreamscape.jpg",
            thumbnail_url: "https://example.com/nfts/dreamscape_thumb.jpg",
            metadata_url: "https://example.com/metadata/dreamscape.json",
            file_size: 5242880, // 5MB
            dimensions: "3000x2000",
            format: "PNG"
        },
        
        // Pricing and financial
        pricing: {
            current_price: 2.5,
            original_price: 2.5,
            currency: "ETH",
            royalty_percentage: 7.5,
            last_sale_price: 2.5,
            price_history: [
                { price: 2.5, date: new Date("2024-06-29T15:30:00Z"), type: "sale" }
            ]
        },
        
        // Creator reference (denormalized for performance)
        creator: {
            creator_id: 1,
            username: "ArtMaster3000",
            wallet_address: "0x1234567890abcdef1234567890abcdef12345678",
            creator_type: "standard",
            reputation_score: 75.5
        },
        
        // Collection reference (denormalized)
        collection: {
            collection_id: 1,
            name: "Digital Dreams",
            floor_price: 1.2
        },
        
        // Current ownership
        ownership: {
            current_owner_wallet: "0xbuyer1111222233334444555566667777888899990",
            owner_since: new Date("2024-06-29T15:31:00Z"),
            previous_owners: [
                {
                    wallet: "0x1234567890abcdef1234567890abcdef12345678",
                    owned_from: new Date("2024-05-20T10:00:00Z"),
                    owned_until: new Date("2024-06-29T15:31:00Z")
                }
            ]
        },
        
        // Engagement metrics
        engagement: {
            view_count: 1250,
            like_count: 89,
            share_count: 23,
            comment_count: 12,
            watchlist_count: 34,
            trending_score: 87.5
        },
        
        // Tags and categorization
        tags: ["surreal", "landscape", "digital art", "dreams", "fantasy", "ethereal"],
        category: "Digital Art",
        subcategory: "Surreal",
        
        // Temporal data
        timestamps: {
            created_at: new Date("2024-05-20T10:00:00Z"),
            last_updated: new Date("2024-06-29T15:31:00Z"),
            last_sale_date: new Date("2024-06-29T15:30:00Z"),
            last_view: new Date("2024-07-02T23:45:00Z")
        },
        
        // Auction reference (if active)
        auction: {
            auction_id: 1,
            status: "active",
            current_bid: 1.8,
            end_time: new Date("2024-07-09T00:00:00Z")
        },
        
        // Transaction history (embedded references)
        transaction_history: [
            {
                transaction_id: 1,
                type: "sale",
                amount: 2.5,
                date: new Date("2024-06-29T15:30:00Z"),
                from: "0x1234567890abcdef1234567890abcdef12345678",
                to: "0xbuyer1111222233334444555566667777888899990"
            }
        ],
        
        // Technical attributes
        technical: {
            blockchain: "Ethereum",
            token_standard: "ERC-721",
            contract_address: "0xcontract1234567890abcdef1234567890abcdef",
            minting_transaction: "0xmint1234567890abcdef",
            verified_authentic: true
        },
        
        // Status flags
        status: {
            listed: true,
            verified: true,
            flagged: false,
            featured: false
        }
    },
    
    {
        _id: ObjectId(),
        nft_id: 2,
        token_id: "TOKEN_002",
        title: "8-Bit Warriors",
        description: "Classic retro-style warriors ready for digital battle. Inspired by legendary 8-bit RPG games.",
        
        media: {
            image_url: "https://example.com/nfts/8bit-warriors.jpg",
            thumbnail_url: "https://example.com/nfts/8bit-warriors_thumb.jpg",
            metadata_url: "https://example.com/metadata/8bit-warriors.json",
            file_size: 1048576, // 1MB
            dimensions: "512x512",
            format: "PNG"
        },
        
        pricing: {
            current_price: 1.2,
            original_price: 1.2,
            currency: "ETH",
            royalty_percentage: 5.0,
            last_sale_price: null,
            price_history: []
        },
        
        creator: {
            creator_id: 2,
            username: "PixelWizard",
            wallet_address: "0xabcdef1234567890abcdef1234567890abcdef12",
            creator_type: "standard",
            reputation_score: 62.8
        },
        
        collection: {
            collection_id: 2,
            name: "Pixel Perfect",
            floor_price: 1.2
        },
        
        ownership: {
            current_owner_wallet: "0xabcdef1234567890abcdef1234567890abcdef12",
            owner_since: new Date("2024-05-25T14:30:00Z"),
            previous_owners: []
        },
        
        engagement: {
            view_count: 850,
            like_count: 156,
            share_count: 45,
            comment_count: 28,
            watchlist_count: 67,
            trending_score: 72.3
        },
        
        tags: ["pixel art", "retro", "gaming", "warriors", "8bit", "RPG"],
        category: "Pixel Art",
        subcategory: "Gaming",
        
        timestamps: {
            created_at: new Date("2024-05-25T14:30:00Z"),
            last_updated: new Date("2024-05-25T14:30:00Z"),
            last_sale_date: null,
            last_view: new Date("2024-07-02T20:15:00Z")
        },
        
        auction: null,
        transaction_history: [],
        
        technical: {
            blockchain: "Ethereum",
            token_standard: "ERC-721",
            contract_address: "0xcontract1234567890abcdef1234567890abcdef",
            minting_transaction: "0xmint2345678901bcdef0",
            verified_authentic: true
        },
        
        status: {
            listed: true,
            verified: true,
            flagged: false,
            featured: false
        }
    },
    
    {
        _id: ObjectId(),
        nft_id: 3,
        token_id: "TOKEN_003",
        title: "Chaos Theory Visualization",
        description: "Mathematical beauty expressed through abstract digital forms. This piece visualizes complex mathematical concepts through algorithmic art generation.",
        
        media: {
            image_url: "https://example.com/nfts/chaos-theory.jpg",
            thumbnail_url: "https://example.com/nfts/chaos-theory_thumb.jpg",
            metadata_url: "https://example.com/metadata/chaos-theory.json",
            file_size: 8388608, // 8MB
            dimensions: "4000x4000",
            format: "PNG"
        },
        
        pricing: {
            current_price: 4.8,
            original_price: 4.8,
            currency: "ETH",
            royalty_percentage: 10.0,
            last_sale_price: 4.8,
            price_history: [
                { price: 4.8, date: new Date("2024-06-28T20:45:00Z"), type: "auction" }
            ]
        },
        
        creator: {
            creator_id: 3,
            username: "AbstractGenius",
            wallet_address: "0x9876543210fedcba9876543210fedcba98765432",
            creator_type: "standard",
            reputation_score: 78.9
        },
        
        collection: {
            collection_id: 3,
            name: "Abstract Expressions",
            floor_price: 4.8
        },
        
        ownership: {
            current_owner_wallet: "0xbuyer3333444455556666777788889999000011112",
            owner_since: new Date("2024-06-28T20:46:00Z"),
            previous_owners: [
                {
                    wallet: "0x9876543210fedcba9876543210fedcba98765432",
                    owned_from: new Date("2024-05-22T16:45:00Z"),
                    owned_until: new Date("2024-06-28T20:46:00Z")
                }
            ]
        },
        
        engagement: {
            view_count: 2100,
            like_count: 234,
            share_count: 67,
            comment_count: 45,
            watchlist_count: 123,
            trending_score: 91.2
        },
        
        tags: ["abstract", "mathematics", "chaos theory", "contemporary", "algorithmic"],
        category: "Abstract Art",
        subcategory: "Mathematical",
        
        timestamps: {
            created_at: new Date("2024-05-22T16:45:00Z"),
            last_updated: new Date("2024-06-28T20:46:00Z"),
            last_sale_date: new Date("2024-06-28T20:45:00Z"),
            last_view: new Date("2024-07-03T01:00:00Z")
        },
        
        auction: {
            auction_id: 2,
            status: "active",
            current_bid: 3.1,
            end_time: new Date("2024-07-08T00:00:00Z")
        },
        
        transaction_history: [
            {
                transaction_id: 3,
                type: "auction",
                amount: 3.2,
                date: new Date("2024-06-28T20:45:00Z"),
                from: "0x9876543210fedcba9876543210fedcba98765432",
                to: "0xbuyer3333444455556666777788889999000011112"
            }
        ],
        
        technical: {
            blockchain: "Ethereum",
            token_standard: "ERC-721",
            contract_address: "0xcontract1234567890abcdef1234567890abcdef",
            minting_transaction: "0xmint3456789012cdef01",
            verified_authentic: true
        },
        
        status: {
            listed: false,
            verified: true,
            flagged: false,
            featured: true
        }
    },
    
    {
        _id: ObjectId(),
        nft_id: 4,
        token_id: "TOKEN_004",
        title: "Blockchain Genesis",
        description: "The birth of a new digital era captured in art. This piece represents the revolutionary potential of blockchain technology.",
        
        media: {
            image_url: "https://example.com/nfts/blockchain-genesis.jpg",
            thumbnail_url: "https://example.com/nfts/blockchain-genesis_thumb.jpg",
            metadata_url: "https://example.com/metadata/blockchain-genesis.json",
            file_size: 6291456, // 6MB
            dimensions: "3500x2500",
            format: "PNG"
        },
        
        pricing: {
            current_price: 3.3,
            original_price: 3.3,
            currency: "ETH",
            royalty_percentage: 6.0,
            last_sale_price: 3.3,
            price_history: [
                { price: 3.3, date: new Date("2024-06-27T14:20:00Z"), type: "sale" }
            ]
        },
        
        creator: {
            creator_id: 4,
            username: "CryptoCreator",
            wallet_address: "0x5555666677778888999900001111222233334444",
            creator_type: "standard",
            reputation_score: 69.2
        },
        
        collection: {
            collection_id: 1,
            name: "Digital Dreams",
            floor_price: 1.2
        },
        
        ownership: {
            current_owner_wallet: "0xbuyer4444555566667777888899990000111122223",
            owner_since: new Date("2024-06-27T14:21:00Z"),
            previous_owners: [
                {
                    wallet: "0x5555666677778888999900001111222233334444",
                    owned_from: new Date("2024-05-26T11:15:00Z"),
                    owned_until: new Date("2024-06-27T14:21:00Z")
                }
            ]
        },
        
        engagement: {
            view_count: 1750,
            like_count: 198,
            share_count: 56,
            comment_count: 34,
            watchlist_count: 89,
            trending_score: 85.7
        },
        
        tags: ["blockchain", "genesis", "digital era", "technology", "revolutionary"],
        category: "Digital Art",
        subcategory: "Technology",
        
        timestamps: {
            created_at: new Date("2024-05-26T11:15:00Z"),
            last_updated: new Date("2024-06-27T14:21:00Z"),
            last_sale_date: new Date("2024-06-27T14:20:00Z"),
            last_view: new Date("2024-07-02T18:30:00Z")
        },
        
        auction: null,
        
        transaction_history: [
            {
                transaction_id: 4,
                type: "sale",
                amount: 3.3,
                date: new Date("2024-06-27T14:20:00Z"),
                from: "0x5555666677778888999900001111222233334444",
                to: "0xbuyer4444555566667777888899990000111122223"
            }
        ],
        
        technical: {
            blockchain: "Ethereum",
            token_standard: "ERC-721",
            contract_address: "0xcontract1234567890abcdef1234567890abcdef",
            minting_transaction: "0xmint4567890123def012",
            verified_authentic: true
        },
        
        status: {
            listed: false,
            verified: true,
            flagged: false,
            featured: false
        }
    },
    
    {
        _id: ObjectId(),
        nft_id: 5,
        token_id: "TOKEN_005",
        title: "Verified Masterpiece",
        description: "An exclusive artwork from a verified gold-tier creator, showcasing premium quality and artistic excellence.",
        
        media: {
            image_url: "https://example.com/nfts/verified-masterpiece.jpg",
            thumbnail_url: "https://example.com/nfts/verified-masterpiece_thumb.jpg",
            metadata_url: "https://example.com/metadata/verified-masterpiece.json",
            file_size: 7340032, // 7MB
            dimensions: "4500x3000",
            format: "PNG"
        },
        
        pricing: {
            current_price: 5.5,
            original_price: 5.5,
            currency: "ETH",
            royalty_percentage: 8.0,
            last_sale_price: null,
            price_history: []
        },
        
        creator: {
            creator_id: 5,
            username: "VerifiedArtist",
            wallet_address: "0x7777888899990000111122223333444455556666",
            creator_type: "verified",
            reputation_score: 88.2,
            verification_tier: "Gold"
        },
        
        collection: {
            collection_id: 2,
            name: "Pixel Perfect",
            floor_price: 1.2
        },
        
        ownership: {
            current_owner_wallet: "0x7777888899990000111122223333444455556666",
            owner_since: new Date("2024-06-30T09:20:00Z"),
            previous_owners: []
        },
        
        engagement: {
            view_count: 2500,
            like_count: 345,
            share_count: 89,
            comment_count: 67,
            watchlist_count: 156,
            trending_score: 94.1
        },
        
        tags: ["verified", "exclusive", "premium", "masterpiece", "gold-tier"],
        category: "Premium Art",
        subcategory: "Verified Exclusive",
        
        timestamps: {
            created_at: new Date("2024-06-30T09:20:00Z"),
            last_updated: new Date("2024-06-30T09:20:00Z"),
            last_sale_date: null,
            last_view: new Date("2024-07-03T01:10:00Z")
        },
        
        auction: null,
        transaction_history: [],
        
        technical: {
            blockchain: "Ethereum",
            token_standard: "ERC-721",
            contract_address: "0xcontract1234567890abcdef1234567890abcdef",
            minting_transaction: "0xmint5678901234ef0123",
            verified_authentic: true
        },
        
        status: {
            listed: true,
            verified: true,
            flagged: false,
            featured: true
        }
    },
    
    {
        _id: ObjectId(),
        nft_id: 6,
        token_id: "TOKEN_006",
        title: "Premium Collection #1",
        description: "First piece from an exclusive premium creator collection, featuring advanced marketplace integration and custom branding.",
        
        media: {
            image_url: "https://example.com/nfts/premium-collection-1.jpg",
            thumbnail_url: "https://example.com/nfts/premium-collection-1_thumb.jpg",
            metadata_url: "https://example.com/metadata/premium-collection-1.json",
            file_size: 10485760, // 10MB
            dimensions: "5000x5000",
            format: "PNG"
        },
        
        pricing: {
            current_price: 8.8,
            original_price: 8.8,
            currency: "ETH",
            royalty_percentage: 12.0,
            last_sale_price: null,
            price_history: []
        },
        
        creator: {
            creator_id: 7,
            username: "PremiumMaster",
            wallet_address: "0x9999000011112222333344445555666677778888",
            creator_type: "premium",
            reputation_score: 96.7,
            verification_tier: "Gold",
            premium_tier: "Platinum"
        },
        
        collection: {
            collection_id: 3,
            name: "Abstract Expressions",
            floor_price: 4.8
        },
        
        ownership: {
            current_owner_wallet: "0x9999000011112222333344445555666677778888",
            owner_since: new Date("2024-07-02T13:45:00Z"),
            previous_owners: []
        },
        
        engagement: {
            view_count: 3200,
            like_count: 456,
            share_count: 123,
            comment_count: 89,
            watchlist_count: 234,
            trending_score: 98.5
        },
        
        tags: ["premium", "exclusive", "collection", "first edition", "platinum"],
        category: "Premium Art",
        subcategory: "Exclusive Collection",
        
        timestamps: {
            created_at: new Date("2024-07-02T13:45:00Z"),
            last_updated: new Date("2024-07-02T13:45:00Z"),
            last_sale_date: null,
            last_view: new Date("2024-07-03T01:15:00Z")
        },
        
        auction: null,
        transaction_history: [],
        
        // Premium-specific features
        premium_features: {
            custom_branding: true,
            api_integration: true,
            analytics_enabled: true,
            white_label: false
        },
        
        technical: {
            blockchain: "Ethereum",
            token_standard: "ERC-721",
            contract_address: "0xcontract1234567890abcdef1234567890abcdef",
            minting_transaction: "0xmint6789012345f01234",
            verified_authentic: true
        },
        
        status: {
            listed: true,
            verified: true,
            flagged: false,
            featured: true
        }
    }
]);

// ============================================================================
// CREATE INDEXES FOR PERFORMANCE
// ============================================================================

// Creators collection indexes
db.creators.createIndex({ "creator_id": 1 }, { unique: true });
db.creators.createIndex({ "wallet_address": 1 }, { unique: true });
db.creators.createIndex({ "username": 1 }, { unique: true });
db.creators.createIndex({ "creator_type": 1 });
db.creators.createIndex({ "reputation_metrics.score": -1 });
db.creators.createIndex({ "created_at": 1 });

// NFTs collection indexes
db.nfts.createIndex({ "nft_id": 1 }, { unique: true });
db.nfts.createIndex({ "token_id": 1 }, { unique: true });
db.nfts.createIndex({ "creator.creator_id": 1 });
db.nfts.createIndex({ "collection.collection_id": 1 });
db.nfts.createIndex({ "pricing.current_price": 1 });
db.nfts.createIndex({ "timestamps.created_at": 1 });
db.nfts.createIndex({ "engagement.trending_score": -1 });
db.nfts.createIndex({ "tags": 1 });
db.nfts.createIndex({ "status.listed": 1, "status.verified": 1 });

// Collections collection indexes
db.collections.createIndex({ "collection_id": 1 }, { unique: true });
db.collections.createIndex({ "name": 1 });
db.collections.createIndex({ "pricing.floor_price": 1 });
db.collections.createIndex({ "statistics.total_volume": -1 });
db.collections.createIndex({ "created_at": 1 });

// Auctions collection indexes
db.auctions.createIndex({ "auction_id": 1 }, { unique: true });
db.auctions.createIndex({ "nft_id": 1 });
db.auctions.createIndex({ "status": 1 });
db.auctions.createIndex({ "end_time": 1 });
db.auctions.createIndex({ "current_highest_bid": -1 });

// Transactions collection indexes
db.transactions.createIndex({ "transaction_id": 1 }, { unique: true });
db.transactions.createIndex({ "transaction_hash": 1 }, { unique: true });
db.transactions.createIndex({ "nft_id": 1 });
db.transactions.createIndex({ "transaction_type": 1 });
db.transactions.createIndex({ "timestamps.confirmed": 1 });
db.transactions.createIndex({ "financial.amount": -1 });

// Marketplaces collection indexes
db.marketplaces.createIndex({ "marketplace_id": 1 }, { unique: true });
db.marketplaces.createIndex({ "name": 1 });

// ============================================================================
// MONGODB QUERIES EQUIVALENT TO THE 5 ORACLE QUERIES
// ============================================================================

print("=== MongoDB Query 1: Complex Join Equivalent ===");
print("Natural Language: Show comprehensive NFT marketplace data with creator verification status, collection performance, and engagement metrics for NFTs with high engagement");

// Query 1: Multi-collection aggregation with lookups (equivalent to complex joins)
db.nfts.aggregate([
    // Match high engagement NFTs
    {
        $match: {
            "engagement.view_count": { $gt: 500 },
            "engagement.like_count": { $gt: 25 }
        }
    },
    
    // Lookup creator information
    {
        $lookup: {
            from: "creators",
            localField: "creator.creator_id",
            foreignField: "creator_id",
            as: "creator_details"
        }
    },
    
    // Lookup collection information
    {
        $lookup: {
            from: "collections",
            localField: "collection.collection_id",
            foreignField: "collection_id",
            as: "collection_details"
        }
    },
    
    // Lookup auction information (left join equivalent)
    {
        $lookup: {
            from: "auctions",
            localField: "nft_id",
            foreignField: "nft_id",
            as: "auction_details"
        }
    },
    
    // Lookup recent transactions
    {
        $lookup: {
            from: "transactions",
            localField: "nft_id",
            foreignField: "nft_id",
            as: "recent_transactions"
        }
    },
    
    // Project the required fields
    {
        $project: {
            nft_id: 1,
            title: 1,
            "pricing.current_price": 1,
            "engagement.view_count": 1,
            "engagement.like_count": 1,
            creator_name: { $arrayElemAt: ["$creator_details.username", 0] },
            creator_reputation: { $arrayElemAt: ["$creator_details.reputation_metrics.score", 0] },
            creator_tier: { $arrayElemAt: ["$creator_details.creator_type", 0] },
            collection_name: { $arrayElemAt: ["$collection_details.name", 0] },
            collection_floor: { $arrayElemAt: ["$collection_details.pricing.floor_price", 0] },
            last_sale_amount: { 
                $arrayElemAt: [
                    {
                        $map: {
                            input: { $slice: ["$recent_transactions", -1] },
                            as: "tx",
                            in: "$$tx.financial.amount"
                        }
                    }, 0
                ]
            },
            auction_status: {
                $cond: {
                    if: { $gt: [{ $size: "$auction_details" }, 0] },
                    then: { $arrayElemAt: ["$auction_details.status", 0] },
                    else: null
                }
            },
            current_highest_bid: { $arrayElemAt: ["$auction_details.current_highest_bid", 0] }
        }
    },
    
    // Sort by engagement
    {
        $sort: {
            "engagement.view_count": -1,
            "engagement.like_count": -1
        }
    }
]);

print("\n=== MongoDB Query 2: Union Equivalent ===");
print("Natural Language: Get all wallet addresses that are either NFT creators or current NFT owners with their roles and counts");

// Query 2: Union equivalent using $facet and $unionWith
db.nfts.aggregate([
    {
        $facet: {
            creators: [
                {
                    $lookup: {
                        from: "creators",
                        localField: "creator.creator_id",
                        foreignField: "creator_id",
                        as: "creator_info"
                    }
                },
                {
                    $group: {
                        _id: { $arrayElemAt: ["$creator_info.wallet_address", 0] },
                        role_type: { $first: "Creator" },
                        item_count: { $sum: 1 },
                        total_value: { $sum: "$pricing.current_price" }
                    }
                },
                {
                    $project: {
                        wallet_address: "$_id",
                        role_type: 1,
                        item_count: 1,
                        total_value: 1,
                        _id: 0
                    }
                }
            ],
            owners: [
                {
                    $match: {
                        "ownership.current_owner_wallet": { $ne: null }
                    }
                },
                {
                    $group: {
                        _id: "$ownership.current_owner_wallet",
                        role_type: { $first: "Owner" },
                        item_count: { $sum: 1 },
                        total_value: { $sum: "$pricing.current_price" }
                    }
                },
                {
                    $project: {
                        wallet_address: "$_id",
                        role_type: 1,
                        item_count: 1,
                        total_value: 1,
                        _id: 0
                    }
                }
            ]
        }
    },
    {
        $project: {
            combined: { $concatArrays: ["$creators", "$owners"] }
        }
    },
    { $unwind: "$combined" },
    { $replaceRoot: { newRoot: "$combined" } },
    {
        $sort: {
            total_value: -1,
            item_count: -1
        }
    }
]);

print("\n=== MongoDB Query 3: Inheritance and Arrays Equivalent ===");
print("Natural Language: Display NFT details with creator type-specific information and bid history for NFTs with active auctions");

// Query 3: Using inheritance-like features and nested arrays
db.nfts.aggregate([
    // Match NFTs with active auctions
    {
        $match: {
            "auction": { $ne: null }
        }
    },
    
    // Lookup creator details
    {
        $lookup: {
            from: "creators",
            localField: "creator.creator_id",
            foreignField: "creator_id",
            as: "creator_details"
        }
    },
    
    // Lookup auction details with bids
    {
        $lookup: {
            from: "auctions",
            localField: "auction.auction_id",
            foreignField: "auction_id",
            as: "auction_details"
        }
    },
    
    // Project with conditional logic for creator types
    {
        $project: {
            nft_id: 1,
            title: 1,
            "pricing.current_price": 1,
            creator_status: { $arrayElemAt: ["$creator_details.reputation_metrics.status", 0] },
            creator_benefits: {
                $switch: {
                    branches: [
                        {
                            case: { $eq: [{ $arrayElemAt: ["$creator_details.creator_type", 0] }, "premium"] },
                            then: {
                                $concat: [
                                    "Premium Features: ",
                                    {
                                        $reduce: {
                                            input: { $arrayElemAt: ["$creator_details.premium.exclusive_features", 0] },
                                            initialValue: "",
                                            in: { $concat: ["$$value", "$$this", ", "] }
                                        }
                                    }
                                ]
                            }
                        },
                        {
                            case: { $eq: [{ $arrayElemAt: ["$creator_details.creator_type", 0] }, "verified"] },
                            then: {
                                $concat: [
                                    "Verification Benefits: ",
                                    {
                                        $reduce: {
                                            input: { $arrayElemAt: ["$creator_details.verification.benefits", 0] },
                                            initialValue: "",
                                            in: { $concat: ["$$value", "$$this", ", "] }
                                        }
                                    }
                                ]
                            }
                        }
                    ],
                    default: "Standard creator benefits"
                }
            },
            total_bids: { $size: { $arrayElemAt: ["$auction_details.bids", 0] } },
            highest_bid: {
                $max: {
                    $map: {
                        input: { $arrayElemAt: ["$auction_details.bids", 0] },
                        as: "bid",
                        in: "$$bid.bid_amount"
                    }
                }
            },
            highest_bidder: {
                $arrayElemAt: [
                    {
                        $map: {
                            input: {
                                $filter: {
                                    input: { $arrayElemAt: ["$auction_details.bids", 0] },
                                    as: "bid",
                                    cond: "$$bid.is_winning"
                                }
                            },
                            as: "winning_bid",
                            in: "$$winning_bid.bidder_wallet"
                        }
                    }, 0
                ]
            }
        }
    },
    
    // Filter only NFTs with bids
    {
        $match: {
            total_bids: { $gt: 0 }
        }
    },
    
    // Sort by highest bid
    {
        $sort: {
            highest_bid: -1
        }
    }
]);

print("\n=== MongoDB Query 4: Temporal Features Equivalent ===");
print("Natural Language: Analyze NFT market activity over different time periods using temporal operations");

// Query 4: Temporal analysis using date operations
db.transactions.aggregate([
    // Match transactions from last 90 days
    {
        $match: {
            "transaction_type": "sale",
            "timestamps.confirmed": {
                $gte: new Date(new Date().getTime() - 90 * 24 * 60 * 60 * 1000)
            }
        }
    },
    
    // Add time period classification
    {
        $addFields: {
            time_period: {
                $switch: {
                    branches: [
                        {
                            case: {
                                $gte: [
                                    "$timestamps.confirmed",
                                    new Date(new Date().getTime() - 24 * 60 * 60 * 1000)
                                ]
                            },
                            then: "Last 24 Hours"
                        },
                        {
                            case: {
                                $gte: [
                                    "$timestamps.confirmed",
                                    new Date(new Date().getTime() - 7 * 24 * 60 * 60 * 1000)