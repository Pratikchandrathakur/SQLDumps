# UML Class Diagram for eSports System

## Class Structure

### Player (Parent Class)
**Attributes:**
- playerID: String
- gamerTag: String
- name: String
- email: String
- dateOfBirth: Date

**Methods:**
- registerForTournament(): Boolean
- updateProfile(): void

### ProfessionalPlayer (Child of Player)
**Additional Attributes:**
- contractID: String
- salary: Double
- sponsorships: List<String>

**Additional Methods:**
- signContract(teamID: String): Boolean
- participateProEvent(): void

### AmateurPlayer (Child of Player)
**Additional Attributes:**
- experienceLevel: String
- preferredGames: List<String>

**Additional Methods:**
- joinAmateur(tournamentID: String): Boolean

### Team
**Attributes:**
- teamID: String
- teamName: String
- foundedDate: Date
- ranking: Integer

**Methods:**
- recruitPlayer(playerID: String): Boolean
- registerForTournament(tournamentID: String): Boolean

### Tournament
**Attributes:**
- tournamentID: String
- tournamentName: String
- startDate: Date
- endDate: Date
- prizePool: Double
- status: String

**Methods:**
- startTournament(): void
- endTournament(): void
- announceWinner(teamID: String): void

### Match
**Attributes:**
- matchID: String
- dateTime: DateTime
- status: String
- score: String
- streamLink: String

**Methods:**
- startMatch(): void
- endMatch(): void
- updateScore(score: String): Boolean

## Relationships

1. **Inheritance:**
   - ProfessionalPlayer ──▷ Player
   - AmateurPlayer ──▷ Player

2. **Aggregation:**
   - Tournament ◇─── Team (1..* to 4..32)
   - Team ◇─── Player (1..1 to 1..*)

3. **Associations:**
   - Tournament ─── Match (1 to 1..*)
   - Match ─── Team (1 to 2)

## Implementation in draw.io

1. Create each class box with three sections:
   - Class name at top
   - Attributes in middle section
   - Methods in bottom section

2. Use proper notation for relationships:
   - Inheritance: Solid line with unfilled arrowhead
   - Aggregation: Solid line with hollow diamond
   - Association: Simple solid line

3. Add multiplicity indicators at the ends of relationship lines (e.g., 1..*).

4. Use appropriate spacing and alignment for a clean layout.