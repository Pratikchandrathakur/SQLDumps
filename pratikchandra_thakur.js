// pratikchandra_thakur.js
// MongoDB Implementation for eSports Management System
// Created: 2025-06-16
// Author: Pratik Chandra Thakur

// Connect to database (assuming running locally)
// If using MongoDB Atlas or another configuration, update connection string as needed
// Run this script with: mongosh --file pratikchandra_thakur.js

// Create or switch to esports database
db = db.getSiblingDB('esports');

// Drop existing collections to ensure clean implementation
db.players.drop();
db.teams.drop();
db.tournaments.drop();
db.matches.drop();

// Create players collection
db.players.insertMany([
  {
    _id: 101,
    gamerTag: "ZywOo",
    name: "Mathieu Herbaut",
    email: "zywoo@team.com",
    dateOfBirth: ISODate("2000-11-09"),
    nationality: "France",
    joinDate: ISODate("2019-03-15"),
    type: "Professional",
    contract: {
      id: "CTR-VIT-001",
      salary: 550000.00,
      startDate: ISODate("2023-01-01"),
      expiryDate: ISODate("2026-12-31"),
    },
    stats: {
      rating: 1.29,
      killsPerRound: 0.85,
      headshots: 49.2,
      mapsPlayed: 321
    },
    socialMedia: {
      twitter: "@zywoo",
      instagram: "@zywoo_csgo",
      twitch: "zywoo"
    }
  },
  {
    _id: 102,
    gamerTag: "s1mple",
    name: "Oleksandr Kostyliev",
    email: "s1mple@team.com",
    dateOfBirth: ISODate("1997-10-02"),
    nationality: "Ukraine",
    joinDate: ISODate("2016-08-04"),
    type: "Professional",
    contract: {
      id: "CTR-NAV-002",
      salary: 620000.00,
      startDate: ISODate("2022-06-01"),
      expiryDate: ISODate("2025-06-01"),
    },
    stats: {
      rating: 1.33,
      killsPerRound: 0.87,
      headshots: 47.8,
      mapsPlayed: 598
    },
    socialMedia: {
      twitter: "@s1mpleO",
      instagram: "@s1mpleo",
      twitch: "s1mple"
    }
  },
  {
    _id: 103,
    gamerTag: "NiKo",
    name: "Nikola Kovač",
    email: "niko@team.com",
    dateOfBirth: ISODate("1997-02-16"),
    nationality: "Bosnia",
    joinDate: ISODate("2017-02-09"),
    type: "Professional",
    contract: {
      id: "CTR-G2-003",
      salary: 580000.00,
      startDate: ISODate("2021-11-01"),
      expiryDate: ISODate("2024-07-15"),
    },
    stats: {
      rating: 1.27,
      killsPerRound: 0.82,
      headshots: 59.1,
      mapsPlayed: 527
    }
  },
  {
    _id: 104,
    gamerTag: "device",
    name: "Nicolai Reedtz",
    email: "device@team.com",
    dateOfBirth: ISODate("1995-09-08"),
    nationality: "Denmark",
    joinDate: ISODate("2015-01-19"),
    type: "Professional",
    contract: {
      id: "CTR-AST-004",
      salary: 540000.00,
      startDate: ISODate("2022-10-01"),
      expiryDate: ISODate("2025-09-30"),
    },
    stats: {
      rating: 1.21,
      killsPerRound: 0.79,
      headshots: 45.3,
      mapsPlayed: 612
    }
  },
  {
    _id: 105,
    gamerTag: "Faker",
    name: "Lee Sang-hyeok",
    email: "faker@team.com",
    dateOfBirth: ISODate("1996-05-07"),
    nationality: "South Korea",
    joinDate: ISODate("2013-02-15"),
    type: "Professional",
    contract: {
      id: "CTR-SKT-005",
      salary: 700000.00,
      startDate: ISODate("2022-01-15"),
      expiryDate: ISODate("2027-01-14"),
    },
    stats: {
      kda: 4.2,
      csPerMinute: 9.1,
      goldPerMinute: 428,
      championsPlayed: 74
    }
  },
  {
    _id: 201,
    gamerTag: "RisingTide",
    name: "James Wilson",
    email: "rising@amateur.com",
    dateOfBirth: ISODate("2002-06-12"),
    nationality: "UK",
    joinDate: ISODate("2023-01-05"),
    type: "Amateur",
    experienceLevel: "Intermediate",
    ranking: 157,
    preferredGames: ["Counter-Strike 2", "Valorant"],
    stats: {
      rating: 0.97,
      killsPerRound: 0.65,
      headshots: 42.1,
      mapsPlayed: 87
    }
  },
  {
    _id: 202,
    gamerTag: "NovaStar",
    name: "Emma Roberts",
    email: "nova@amateur.com",
    dateOfBirth: ISODate("2003-03-27"),
    nationality: "Canada",
    joinDate: ISODate("2023-02-10"),
    type: "Amateur",
    experienceLevel: "Advanced",
    ranking: 89,
    preferredGames: ["Valorant", "Overwatch 2"],
    stats: {
      rating: 1.04,
      killsPerRound: 0.69,
      headshots: 38.7,
      mapsPlayed: 103
    }
  }
]);

// Create indexes for efficient queries
db.players.createIndex({ gamerTag: 1 }, { unique: true });
db.players.createIndex({ nationality: 1 });
db.players.createIndex({ "stats.rating": -1 });
db.players.createIndex({ type: 1 });

// Create teams collection with embedded roster information
db.teams.insertMany([
  {
    _id: 1001,
    name: "Team Vitality",
    foundedDate: ISODate("2013-08-10"),
    region: "Europe",
    ranking: 4,
    website: "www.teamvitality.gg",
    accolades: [
      { name: "ESL Pro League Season 16", date: ISODate("2022-10-02") },
      { name: "BLAST Premier Spring Finals", date: ISODate("2023-06-18") }
    ],
    gameTitles: [
      { name: "Counter-Strike 2", genre: "FPS" },
      { name: "League of Legends", genre: "MOBA" }
    ],
    roster: [
      { 
        playerId: 101, 
        gamerTag: "ZywOo",
        role: "AWPer",
        joinDate: ISODate("2022-01-01"),
        isCaptain: false
      },
      {
        playerId: 109, 
        gamerTag: "Bjergsen",
        role: "Mid Laner",
        joinDate: ISODate("2023-03-01"),
        isCaptain: true
      }
    ],
    financials: {
      estimatedValue: 45000000,
      sponsorships: ["Adidas", "Red Bull", "AMD"],
      yearlyBudget: 12000000
    }
  },
  {
    _id: 1002,
    name: "Natus Vincere",
    foundedDate: ISODate("2009-12-17"),
    region: "CIS",
    ranking: 3,
    website: "www.navi.gg",
    accolades: [
      { name: "PGL Major Stockholm", date: ISODate("2021-11-07") },
      { name: "BLAST Premier World Final", date: ISODate("2021-12-19") }
    ],
    gameTitles: [
      { name: "Counter-Strike 2", genre: "FPS" },
      { name: "Dota 2", genre: "MOBA" }
    ],
    roster: [
      { 
        playerId: 102, 
        gamerTag: "s1mple",
        role: "AWPer",
        joinDate: ISODate("2021-01-15"),
        isCaptain: true
      }
    ],
    financials: {
      estimatedValue: 40000000,
      sponsorships: ["Monster Energy", "HyperX", "Logitech G"],
      yearlyBudget: 10000000
    }
  },
  {
    _id: 1003,
    name: "G2 Esports",
    foundedDate: ISODate("2014-02-24"),
    region: "Europe",
    ranking: 2,
    website: "www.g2esports.com",
    accolades: [
      { name: "LEC Spring Split", date: ISODate("2023-04-16") },
      { name: "BLAST Premier Fall Final", date: ISODate("2022-11-27") }
    ],
    gameTitles: [
      { name: "League of Legends", genre: "MOBA" },
      { name: "Counter-Strike 2", genre: "FPS" },
      { name: "Valorant", genre: "FPS" }
    ],
    roster: [
      { 
        playerId: 103, 
        gamerTag: "NiKo",
        role: "Rifler",
        joinDate: ISODate("2021-11-01"),
        isCaptain: true
      },
      {
        playerId: 106, 
        gamerTag: "Perkz",
        role: "Mid Laner",
        joinDate: ISODate("2022-04-15"),
        isCaptain: false
      },
      {
        playerId: 107, 
        gamerTag: "Caps",
        role: "Mid Laner",
        joinDate: ISODate("2023-01-10"),
        isCaptain: true
      }
    ],
    financials: {
      estimatedValue: 55000000,
      sponsorships: ["BMW", "Logitech G", "Mastercard"],
      yearlyBudget: 15000000
    }
  },
  {
    _id: 1004,
    name: "Astralis",
    foundedDate: ISODate("2016-01-18"),
    region: "Denmark",
    ranking: 8,
    website: "www.astralis.gg",
    accolades: [
      { name: "ESL Pro League Season 12", date: ISODate("2020-10-04") },
      { name: "ELEAGUE Major Atlanta", date: ISODate("2017-01-29") },
      { name: "IEM Katowice Major", date: ISODate("2019-03-03") }
    ],
    gameTitles: [
      { name: "Counter-Strike 2", genre: "FPS" },
      { name: "League of Legends", genre: "MOBA" }
    ],
    roster: [
      { 
        playerId: 104, 
        gamerTag: "device",
        role: "AWPer",
        joinDate: ISODate("2022-10-01"),
        isCaptain: false
      }
    ]
  },
  {
    _id: 1005,
    name: "T1",
    foundedDate: ISODate("2012-12-13"),
    region: "South Korea",
    ranking: 1,
    website: "www.t1.gg",
    accolades: [
      { name: "LoL World Championship", date: ISODate("2022-11-05") },
      { name: "LCK Summer Split", date: ISODate("2023-08-20") }
    ],
    gameTitles: [
      { name: "League of Legends", genre: "MOBA" },
      { name: "Valorant", genre: "FPS" },
      { name: "Dota 2", genre: "MOBA" }
    ],
    roster: [
      { 
        playerId: 105, 
        gamerTag: "Faker",
        role: "Mid Laner",
        joinDate: ISODate("2013-02-15"),
        isCaptain: true
      }
    ]
  },
  {
    _id: 1006,
    name: "Fnatic",
    foundedDate: ISODate("2004-07-23"),
    region: "Europe",
    ranking: 5,
    website: "www.fnatic.com",
    accolades: [
      { name: "LEC Spring Split", date: ISODate("2021-04-11") },
      { name: "LoL World Championship Season 1", date: ISODate("2011-06-20") }
    ],
    gameTitles: [
      { name: "League of Legends", genre: "MOBA" },
      { name: "Counter-Strike 2", genre: "FPS" }
    ],
    roster: [
      { 
        playerId: 108, 
        gamerTag: "Rekkles",
        role: "ADC",
        joinDate: ISODate("2022-12-01"),
        isCaptain: false
      },
      {
        playerId: 110, 
        gamerTag: "Doublelift",
        role: "ADC",
        joinDate: ISODate("2022-08-15"),
        isCaptain: true
      }
    ]
  }
]);

// Create indexes for teams
db.teams.createIndex({ name: 1 }, { unique: true });
db.teams.createIndex({ ranking: 1 });
db.teams.createIndex({ region: 1 });
db.teams.createIndex({ "roster.playerId": 1 });

// Create tournaments collection
db.tournaments.insertMany([
  {
    _id: 2001,
    name: "ESL Pro League Season 20",
    startDate: ISODate("2025-09-01"),
    endDate: ISODate("2025-10-15"),
    prizePool: 850000.00,
    location: "Malta",
    status: "Scheduled",
    format: "Group Stage + Playoffs",
    game: "Counter-Strike 2",
    organizer: "ESL",
    participants: [
      { 
        teamId: 1001, 
        teamName: "Team Vitality",
        registrationDate: ISODate("2025-07-15"),
        seedNumber: 1,
        finalPosition: null
      },
      { 
        teamId: 1002, 
        teamName: "Natus Vincere",
        registrationDate: ISODate("2025-07-16"),
        seedNumber: 2,
        finalPosition: null
      },
      { 
        teamId: 1003, 
        teamName: "G2 Esports",
        registrationDate: ISODate("2025-07-17"),
        seedNumber: 3,
        finalPosition: null
      },
      { 
        teamId: 1004, 
        teamName: "Astralis",
        registrationDate: ISODate("2025-07-18"),
        seedNumber: 4,
        finalPosition: null
      }
    ],
    groups: [
      {
        name: "Group A",
        teams: ["Team Vitality", "Astralis"]
      },
      {
        name: "Group B",
        teams: ["Natus Vincere", "G2 Esports"]
      }
    ],
    streamingPlatforms: ["Twitch", "YouTube", "ESL TV"],
    sponsors: ["Intel", "DHL", "CS.Money"]
  },
  {
    _id: 2002,
    name: "IEM Katowice 2026",
    startDate: ISODate("2026-02-01"),
    endDate: ISODate("2026-02-14"),
    prizePool: 1000000.00,
    location: "Katowice, Poland",
    status: "Scheduled",
    format: "GSL Groups + Single Elimination Playoffs",
    game: "Counter-Strike 2",
    organizer: "ESL",
    participants: [
      { 
        teamId: 1001, 
        teamName: "Team Vitality",
        registrationDate: ISODate("2025-12-01"),
        seedNumber: 1,
        finalPosition: null
      },
      { 
        teamId: 1002, 
        teamName: "Natus Vincere",
        registrationDate: ISODate("2025-12-02"),
        seedNumber: 2,
        finalPosition: null
      },
      { 
        teamId: 1003, 
        teamName: "G2 Esports",
        registrationDate: ISODate("2025-12-03"),
        seedNumber: 3,
        finalPosition: null
      },
      { 
        teamId: 1005, 
        teamName: "T1",
        registrationDate: ISODate("2025-12-04"),
        seedNumber: 4,
        finalPosition: null
      }
    ],
    streamingPlatforms: ["Twitch", "YouTube", "ESL TV"],
    sponsors: ["Intel", "benq", "HyperX"]
  },
  {
    _id: 2003,
    name: "BLAST Premier World Final 2025",
    startDate: ISODate("2025-12-10"),
    endDate: ISODate("2025-12-18"),
    prizePool: 1250000.00,
    location: "Copenhagen, Denmark",
    status: "Scheduled",
    format: "Double Elimination Bracket",
    game: "Counter-Strike 2",
    organizer: "BLAST",
    participants: [
      { 
        teamId: 1001, 
        teamName: "Team Vitality",
        registrationDate: ISODate("2025-10-15"),
        seedNumber: 1,
        finalPosition: null
      },
      { 
        teamId: 1002, 
        teamName: "Natus Vincere",
        registrationDate: ISODate("2025-10-16"),
        seedNumber: 2,
        finalPosition: null
      },
      { 
        teamId: 1004, 
        teamName: "Astralis",
        registrationDate: ISODate("2025-10-17"),
        seedNumber: 3,
        finalPosition: null
      },
      { 
        teamId: 1006, 
        teamName: "Fnatic",
        registrationDate: ISODate("2025-10-18"),
        seedNumber: 4,
        finalPosition: null
      }
    ],
    streamingPlatforms: ["Twitch", "YouTube", "BLAST.tv"],
    sponsors: ["Betway", "Logitech G", "CS.Money"]
  },
  {
    _id: 2004,
    name: "LEC Summer Split 2025",
    startDate: ISODate("2025-06-15"),
    endDate: ISODate("2025-08-20"),
    prizePool: 500000.00,
    location: "Berlin, Germany",
    status: "Scheduled",
    format: "Round Robin + Playoffs",
    game: "League of Legends",
    organizer: "Riot Games",
    participants: [
      { 
        teamId: 1003, 
        teamName: "G2 Esports",
        registrationDate: ISODate("2025-05-15"),
        seedNumber: 1,
        finalPosition: null
      },
      { 
        teamId: 1005, 
        teamName: "T1",
        registrationDate: ISODate("2025-05-16"),
        seedNumber: 2,
        finalPosition: null
      },
      { 
        teamId: 1006, 
        teamName: "Fnatic",
        registrationDate: ISODate("2025-05-17"),
        seedNumber: 3,
        finalPosition: null
      }
    ],
    streamingPlatforms: ["Twitch", "YouTube", "lolesports.com"],
    sponsors: ["KitKat", "KIA", "Mastercard"]
  },
  {
    _id: 2005,
    name: "PGL Major Stockholm 2025",
    startDate: ISODate("2025-11-01"),
    endDate: ISODate("2025-11-14"),
    prizePool: 2000000.00,
    location: "Stockholm, Sweden",
    status: "Scheduled",
    format: "Swiss System + Single Elimination Playoffs",
    game: "Counter-Strike 2",
    organizer: "PGL",
    participants: [
      { 
        teamId: 1001, 
        teamName: "Team Vitality",
        registrationDate: ISODate("2025-09-15"),
        seedNumber: 1,
        finalPosition: null
      },
      { 
        teamId: 1002, 
        teamName: "Natus Vincere",
        registrationDate: ISODate("2025-09-16"),
        seedNumber: 2,
        finalPosition: null
      },
      { 
        teamId: 1003, 
        teamName: "G2 Esports",
        registrationDate: ISODate("2025-09-17"),
        seedNumber: 3,
        finalPosition: null
      },
      { 
        teamId: 1004, 
        teamName: "Astralis",
        registrationDate: ISODate("2025-09-18"),
        seedNumber: 4,
        finalPosition: null
      }
    ],
    qualifiers: [
      {
        region: "Europe",
        slots: 8,
        dates: {
          start: ISODate("2025-09-01"),
          end: ISODate("2025-09-10")
        }
      },
      {
        region: "Americas",
        slots: 6,
        dates: {
          start: ISODate("2025-09-01"),
          end: ISODate("2025-09-10")
        }
      },
      {
        region: "Asia",
        slots: 4,
        dates: {
          start: ISODate("2025-09-01"),
          end: ISODate("2025-09-10")
        }
      }
    ],
    streamingPlatforms: ["Twitch", "YouTube", "SteamTV"],
    sponsors: ["SteelSeries", "OMEN by HP", "CSGO.com"]
  }
]);

// Create indexes for tournaments
db.tournaments.createIndex({ name: 1 }, { unique: true });
db.tournaments.createIndex({ startDate: 1 });
db.tournaments.createIndex({ game: 1 });
db.tournaments.createIndex({ "participants.teamId": 1 });

// Create matches collection with rich embedded data
db.matches.insertMany([
  {
    _id: 3001,
    tournamentId: 2001,
    tournamentName: "ESL Pro League Season 20",
    matchDate: ISODate("2025-09-03T14:00:00Z"),
    teams: [
      {
        teamId: 1001,
        name: "Team Vitality",
        score: null,
        side: "CT"  // Counter-Terrorist
      },
      {
        teamId: 1002,
        name: "Natus Vincere",
        score: null,
        side: "T"  // Terrorist
      }
    ],
    status: "Scheduled",
    map: "de_inferno",
    streamLink: "https://twitch.tv/esl_csgo",
    predictedViewers: 320000,
    mapPool: ["de_dust2", "de_inferno", "de_mirage", "de_nuke", "de_overpass", "de_ancient", "de_vertigo"],
    format: {
      type: "Best of 3",
      currentMap: 1
    },
    playerStats: [] // Will be populated after match
  },
  {
    _id: 3002,
    tournamentId: 2001,
    tournamentName: "ESL Pro League Season 20",
    matchDate: ISODate("2025-09-03T17:00:00Z"),
    teams: [
      {
        teamId: 1003,
        name: "G2 Esports",
        score: null,
        side: "T"
      },
      {
        teamId: 1004,
        name: "Astralis",
        score: null,
        side: "CT"
      }
    ],
    status: "Scheduled",
    map: "de_nuke",
    streamLink: "https://twitch.tv/esl_csgo",
    predictedViewers: 280000,
    mapPool: ["de_dust2", "de_inferno", "de_mirage", "de_nuke", "de_overpass", "de_ancient", "de_vertigo"],
    format: {
      type: "Best of 3",
      currentMap: 1
    },
    playerStats: []
  },
  {
    _id: 3003,
    tournamentId: 2002,
    tournamentName: "IEM Katowice 2026",
    matchDate: ISODate("2026-02-02T12:00:00Z"),
    teams: [
      {
        teamId: 1001,
        name: "Team Vitality",
        score: null,
        side: "T"
      },
      {
        teamId: 1003,
        name: "G2 Esports",
        score: null,
        side: "CT"
      }
    ],
    status: "Scheduled",
    map: "de_dust2",
    streamLink: "https://twitch.tv/esl_csgo",
    predictedViewers: 350000,
    format: {
      type: "Best of 3",
      currentMap: 1
    },
    playerStats: []
  },
  // Adding a completed match with player statistics
  {
    _id: 3004,
    tournamentId: 2002,
    tournamentName: "IEM Katowice 2026",
    matchDate: ISODate("2026-02-02T15:00:00Z"),
    teams: [
      {
        teamId: 1002,
        name: "Natus Vincere",
        score: 16,
        side: "CT"
      },
      {
        teamId: 1005,
        name: "T1",
        score: 10,
        side: "T"
      }
    ],
    status: "Completed",
    map: "de_mirage",
    streamLink: "https://twitch.tv/esl_csgo",
    actualViewers: 295000,
    format: {
      type: "Best of 3",
      currentMap: 1,
      mapsPlayed: 2,
      winner: "Natus Vincere",
      maps: ["de_mirage", "de_nuke"]
    },
    matchLength: {
      hours: 1,
      minutes: 23,
      seconds: 47
    },
    playerStats: [
      {
        playerId: 102,
        gamerTag: "s1mple",
        team: "Natus Vincere",
        kills: 27,
        deaths: 14,
        assists: 8,
        rating: 1.47,
        headshots: 17,
        adr: 103.2, // Average Damage per Round
        kast: 84.6  // Kill/Assist/Survive/Trade %
      },
      {
        playerId: 105,
        gamerTag: "Faker",
        team: "T1",
        kills: 19,
        deaths: 18,
        assists: 7,
        rating: 1.05,
        headshots: 10,
        adr: 78.4,
        kast: 73.1
      }
    ],
    highlights: [
      {
        round: 15,
        description: "s1mple ace with AWP",
        clipLink: "https://clips.twitch.tv/example-clip-1"
      },
      {
        round: 23,
        description: "Faker 1v3 clutch",
        clipLink: "https://clips.twitch.tv/example-clip-2"
      }
    ],
    roundHistory: [
      { round: 1, winner: "Natus Vincere", type: "Regular" },
      { round: 2, winner: "Natus Vincere", type: "Regular" },
      { round: 3, winner: "T1", type: "Regular" },
      // Additional rounds would be here...
      { round: 26, winner: "Natus Vincere", type: "Regular" }
    ]
  }
]);

// Create indexes for matches
db.matches.createIndex({ tournamentId: 1 });
db.matches.createIndex({ "teams.teamId": 1 });
db.matches.createIndex({ matchDate: 1 });
db.matches.createIndex({ status: 1 });
db.matches.createIndex({ map: 1 });

// Create aggregation pipeline to find top players by rating
db.createView(
  "topPlayers",
  "players",
  [
    { $match: { type: "Professional" } },
    { $sort: { "stats.rating": -1 } },
    { $project: { 
        _id: 0,
        gamerTag: 1, 
        nationality: 1,
        "stats.rating": 1,
        "stats.killsPerRound": 1,
        "stats.mapsPlayed": 1
    }},
    { $limit: 10 }
  ]
);

// Create a function to get player contract status
db.system.js.save({
  _id: "getContractStatus",
  value: function(playerId) {
    var player = db.players.findOne({
      _id: playerId,
      type: "Professional"
    });
    
    if (!player) {
      return "Not a Professional Player";
    }
    
    var today = new Date();
    var expiryDate = player.contract.expiryDate;
    var daysRemaining = Math.floor((expiryDate - today) / (1000 * 60 * 60 * 24));
    
    if (daysRemaining < 0) {
      return "Expired";
    } else if (daysRemaining < 90) {
      return "Expires Soon";
    } else {
      return "Active";
    }
  }
});

// Load the function into the current session
db.loadServerScripts();

// Create a function to register a team for a tournament
db.system.js.save({
  _id: "registerTeamForTournament",
  value: function(teamId, tournamentId, seedNumber) {
    // Check if team exists
    var team = db.teams.findOne({ _id: teamId });
    if (!team) {
      return { success: false, message: "Team ID " + teamId + " does not exist." };
    }
    
    // Check if tournament exists and is open for registration
    var tournament = db.tournaments.findOne({ _id: tournamentId });
    if (!tournament) {
      return { success: false, message: "Tournament ID " + tournamentId + " does not exist." };
    }
    
    if (tournament.status !== "Scheduled") {
      return { success: false, message: "Tournament is not open for registration. Status: " + tournament.status };
    }
    
    // Check if team is already registered
    var alreadyRegistered = db.tournaments.findOne({
      _id: tournamentId,
      "participants.teamId": teamId
    });
    
    if (alreadyRegistered) {
      return { success: false, message: "Team is already registered for this tournament." };
    }
    
    // Check if tournament is full (assuming max 32 teams)
    var maxTeams = 32;
    if (tournament.participants && tournament.participants.length >= maxTeams) {
      return { success: false, message: "Tournament has reached maximum capacity of " + maxTeams + " teams." };
    }
    
    // Determine seed number if not provided
    var seed = seedNumber;
    if (!seed) {
      var highestSeed = 0;
      if (tournament.participants && tournament.participants.length > 0) {
        tournament.participants.forEach(function(p) {
          if (p.seedNumber > highestSeed) {
            highestSeed = p.seedNumber;
          }
        });
      }
      seed = highestSeed + 1;
    } else {
      // Check if seed is already taken
      var seedTaken = db.tournaments.findOne({
        _id: tournamentId,
        "participants.seedNumber": seed
      });
      
      if (seedTaken) {
        return { success: false, message: "Seed number " + seed + " is already assigned to another team." };
      }
    }
    
    // Register the team
    var newParticipant = {
      teamId: teamId,
      teamName: team.name,
      registrationDate: new Date(),
      seedNumber: seed,
      finalPosition: null
    };
    
    db.tournaments.updateOne(
      { _id: tournamentId },
      { $push: { participants: newParticipant } }
    );
    
    return { 
      success: true, 
      message: "Team ID " + teamId + " successfully registered for Tournament ID " + tournamentId + " with seed number " + seed 
    };
  }
});

// Test queries
print("\nVerification Queries:");
print("\nTotal Players: " + db.players.countDocuments());
print("Professional Players: " + db.players.countDocuments({ type: "Professional" }));
print("Amateur Players: " + db.players.countDocuments({ type: "Amateur" }));
print("Total Teams: " + db.teams.countDocuments());
print("Total Tournaments: " + db.tournaments.countDocuments());
print("Total Matches: " + db.matches.countDocuments());

// Display top player by rating
print("\nTop player by rating:");
var topPlayer = db.players.find().sort({"stats.rating": -1}).limit(1).toArray()[0];
print(topPlayer.gamerTag + " with rating: " + topPlayer.stats.rating);

// Test system function
if (typeof getContractStatus === "function") {
  print("\nContract status for player 102 (s1mple): " + getContractStatus(102));
  print("Contract status for player 201 (RisingTide): " + getContractStatus(201));
}

print("\nMongoDB implementation completed successfully.");