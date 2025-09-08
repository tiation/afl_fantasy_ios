import {
  type User, type InsertUser,
  type Player, type InsertPlayer,
  type Team, type InsertTeam,
  type TeamPlayer, type InsertTeamPlayer,
  type League, type InsertLeague,
  type LeagueTeam, type InsertLeagueTeam,
  type Matchup, type InsertMatchup,
  type RoundPerformance, type InsertRoundPerformance
} from "@shared/schema";

export interface IStorage {
  // User methods
  getUser(id: number): Promise<User | undefined>;
  getUserByUsername(username: string): Promise<User | undefined>;
  createUser(user: InsertUser): Promise<User>;
  
  // Player methods
  getAllPlayers(): Promise<Player[]>;
  getPlayer(id: number): Promise<Player | undefined>;
  getPlayersByPosition(position: string): Promise<Player[]>;
  searchPlayers(query: string): Promise<Player[]>;
  createPlayer(player: InsertPlayer): Promise<Player>;
  updatePlayer(id: number, player: Partial<InsertPlayer>): Promise<Player | undefined>;
  
  // Team methods
  getTeam(id: number): Promise<Team | undefined>;
  getTeamByUserId(userId: number): Promise<Team | undefined>;
  createTeam(team: InsertTeam): Promise<Team>;
  updateTeam(id: number, team: Partial<InsertTeam>): Promise<Team | undefined>;
  
  // TeamPlayer methods
  getTeamPlayers(teamId: number): Promise<TeamPlayer[]>;
  getTeamPlayersByPosition(teamId: number, position: string): Promise<TeamPlayer[]>;
  getTeamPlayerDetails(teamId: number): Promise<(TeamPlayer & { player: Player })[]>;
  addPlayerToTeam(teamPlayer: InsertTeamPlayer): Promise<TeamPlayer>;
  removePlayerFromTeam(teamId: number, playerId: number): Promise<boolean>;
  
  // League methods
  getLeague(id: number): Promise<League | undefined>;
  getLeaguesByUserId(userId: number): Promise<League[]>;
  createLeague(league: InsertLeague): Promise<League>;
  
  // LeagueTeam methods
  getLeagueTeams(leagueId: number): Promise<LeagueTeam[]>;
  getLeagueTeamDetails(leagueId: number): Promise<(LeagueTeam & { team: Team })[]>;
  addTeamToLeague(leagueTeam: InsertLeagueTeam): Promise<LeagueTeam>;
  updateLeagueTeam(leagueId: number, teamId: number, data: Partial<InsertLeagueTeam>): Promise<LeagueTeam | undefined>;
  
  // Matchup methods
  getMatchups(leagueId: number, round: number): Promise<Matchup[]>;
  getMatchupDetails(leagueId: number, round: number): Promise<(Matchup & { team1: Team, team2: Team })[]>;
  createMatchup(matchup: InsertMatchup): Promise<Matchup>;
  updateMatchup(id: number, matchup: Partial<InsertMatchup>): Promise<Matchup | undefined>;
  
  // Round Performance methods
  getRoundPerformances(teamId: number): Promise<RoundPerformance[]>;
  getRoundPerformance(teamId: number, round: number): Promise<RoundPerformance | undefined>;
  createRoundPerformance(perf: InsertRoundPerformance): Promise<RoundPerformance>;
  updateRoundPerformance(id: number, perf: Partial<InsertRoundPerformance>): Promise<RoundPerformance | undefined>;
}

export class MemStorage implements IStorage {
  private users: Map<number, User>;
  private players: Map<number, Player>;
  private teams: Map<number, Team>;
  private teamPlayers: Map<number, TeamPlayer>;
  private leagues: Map<number, League>;
  private leagueTeams: Map<number, LeagueTeam>;
  private matchups: Map<number, Matchup>;
  private roundPerformances: Map<number, RoundPerformance>;
  
  private nextIds: {
    user: number;
    player: number;
    team: number;
    teamPlayer: number;
    league: number;
    leagueTeam: number;
    matchup: number;
    roundPerformance: number;
  };

  constructor() {
    this.users = new Map();
    this.players = new Map();
    this.teams = new Map();
    this.teamPlayers = new Map();
    this.leagues = new Map();
    this.leagueTeams = new Map();
    this.matchups = new Map();
    this.roundPerformances = new Map();
    
    this.nextIds = {
      user: 1,
      player: 1,
      team: 1,
      teamPlayer: 1,
      league: 1,
      leagueTeam: 1,
      matchup: 1,
      roundPerformance: 1
    };
    
    this.initializeData();
  }

  private initializeData() {
    // Initialize with some sample AFL players
    const samplePlayers: InsertPlayer[] = [
      {
        name: "Marcus Bontempelli",
        position: "MID",
        price: 982000,
        breakEven: 112,
        category: "Premium",
        team: "WBD",
        averagePoints: 125.3,
        lastScore: 143,
        projectedScore: 130,
        // Fantasy stats
        roundsPlayed: 7,
        l3Average: 131.7,
        l5Average: 128.2,
        priceChange: 12000,
        pricePerPoint: 7840,
        totalPoints: 877,
        selectionPercentage: 42.8,
        // Basic stats
        kicks: 18,
        handballs: 12,
        disposals: 30,
        marks: 5,
        tackles: 7,
        freeKicksFor: 2,
        freeKicksAgainst: 1,
        clearances: 8,
        hitouts: 0,
        cba: 85.5,
        kickIns: 0,
        uncontestedMarks: 3,
        contestedMarks: 2,
        uncontestedDisposals: 18,
        contestedDisposals: 12,
        // VS stats
        averageVsOpp: 118.3,
        averageAtVenue: 130.2,
        averageVs3RoundOpp: 116.5,
        averageAt3RoundVenue: 127.8,
        opponentDifficulty: 6.8,
        opponent3RoundDifficulty: 7.2,
        // Extended stats
        standardDeviation: 11.2,
        highScore: 143,
        lowScore: 108,
        belowAveragePercentage: 0.14,
        nextOpponent: "GEE",
        scoreImpact: 5.2,
        projectedAverage: 120.1,
        nextVenue: "MCG",
        venueScoreVariance: 8.7,
        projectedPriceChange: 8000,
        breakEvenPercentage: 0.42,
        projectedOwnershipChange: 1.2,
        // Status
        isSelected: true,
        isInjured: false,
        isSuspended: false,
        isFavorite: false
      },
      {
        name: "Clayton Oliver",
        position: "MID",
        price: 950000,
        breakEven: 106,
        category: "Premium",
        team: "MEL",
        averagePoints: 121.2,
        lastScore: 131,
        projectedScore: 125,
        // Fantasy stats
        roundsPlayed: 7,
        l3Average: 128.7,
        l5Average: 124.4,
        priceChange: 15000,
        pricePerPoint: 7840,
        totalPoints: 848,
        selectionPercentage: 25.3,
        // Basic stats
        kicks: 16,
        handballs: 18,
        disposals: 34,
        marks: 4,
        tackles: 8,
        freeKicksFor: 1,
        freeKicksAgainst: 2,
        clearances: 9,
        hitouts: 0,
        cba: 92.1,
        kickIns: 0,
        uncontestedMarks: 2,
        contestedMarks: 2,
        uncontestedDisposals: 20,
        contestedDisposals: 14,
        // VS stats
        averageVsOpp: 127.5,
        averageAtVenue: 124.8,
        averageVs3RoundOpp: 125.6,
        averageAt3RoundVenue: 126.2,
        opponentDifficulty: 4.2,
        opponent3RoundDifficulty: 5.4,
        // Extended stats
        standardDeviation: 10.8,
        highScore: 139,
        lowScore: 105,
        belowAveragePercentage: 0.14,
        nextOpponent: "RIC",
        scoreImpact: 6.8,
        projectedAverage: 127.8,
        nextVenue: "MCG",
        venueScoreVariance: 9.2,
        projectedPriceChange: 18000,
        breakEvenPercentage: 0.38,
        projectedOwnershipChange: 2.8,
        // Status
        isSelected: true,
        isInjured: false,
        isSuspended: false,
        isFavorite: false
      },
      {
        name: "Jack Macrae",
        position: "MID",
        price: 872000,
        breakEven: 98,
        category: "Mid-Pricer",
        team: "WBD",
        averagePoints: 102.5,
        lastScore: 95,
        projectedScore: 105,
        // Fantasy stats
        roundsPlayed: 7,
        l3Average: 98.3,
        l5Average: 99.6,
        priceChange: -4000,
        pricePerPoint: 8510,
        totalPoints: 717,
        selectionPercentage: 14.3,
        // Basic stats
        kicks: 15,
        handballs: 15,
        disposals: 30,
        marks: 6,
        tackles: 4,
        freeKicksFor: 1,
        freeKicksAgainst: 1,
        clearances: 6,
        hitouts: 0,
        cba: 65.5,
        kickIns: 0,
        uncontestedMarks: 4,
        contestedMarks: 2,
        uncontestedDisposals: 20,
        contestedDisposals: 10,
        // VS stats
        averageVsOpp: 103.3,
        averageAtVenue: 105.2,
        averageVs3RoundOpp: 102.5,
        averageAt3RoundVenue: 104.8,
        opponentDifficulty: 5.8,
        opponent3RoundDifficulty: 6.4,
        // Extended stats
        standardDeviation: 15.2,
        highScore: 123,
        lowScore: 78,
        belowAveragePercentage: 0.29,
        nextOpponent: "GEE",
        scoreImpact: -3.2,
        projectedAverage: 99.3,
        nextVenue: "MCG",
        venueScoreVariance: 14.7,
        projectedPriceChange: -6000,
        breakEvenPercentage: 0.52,
        projectedOwnershipChange: -0.9,
        // Status
        isSelected: true,
        isInjured: false,
        isSuspended: false,
        isFavorite: false
      },
      {
        name: "Christian Petracca",
        position: "FWD",
        price: 890000,
        breakEven: 104,
        category: "Premium",
        team: "MEL",
        averagePoints: 115.7,
        lastScore: 122,
        projectedScore: 118,
        // Fantasy stats
        roundsPlayed: 7,
        l3Average: 118.3,
        l5Average: 116.6,
        priceChange: 12000,
        pricePerPoint: 7693,
        totalPoints: 810,
        selectionPercentage: 28.6,
        // Basic stats
        kicks: 17,
        handballs: 14,
        disposals: 31,
        marks: 5,
        tackles: 6,
        freeKicksFor: 2,
        freeKicksAgainst: 1,
        clearances: 7,
        hitouts: 0,
        cba: 78.5,
        kickIns: 0,
        uncontestedMarks: 3,
        contestedMarks: 2,
        uncontestedDisposals: 18,
        contestedDisposals: 13,
        // VS stats
        averageVsOpp: 117.3,
        averageAtVenue: 118.2,
        averageVs3RoundOpp: 116.5,
        averageAt3RoundVenue: 119.8,
        opponentDifficulty: 5.2,
        opponent3RoundDifficulty: 5.8,
        // Extended stats
        standardDeviation: 13.2,
        highScore: 135,
        lowScore: 96,
        belowAveragePercentage: 0.25,
        nextOpponent: "RIC",
        scoreImpact: 4.8,
        projectedAverage: 118.5,
        nextVenue: "MCG",
        venueScoreVariance: 11.7,
        projectedPriceChange: 10000,
        breakEvenPercentage: 0.46,
        projectedOwnershipChange: 1.5,
        // Status
        isSelected: true,
        isInjured: false,
        isSuspended: false,
        isFavorite: false
      },
      {
        name: "Jeremy Cameron",
        position: "FWD",
        price: 820000,
        breakEven: 95,
        category: "Premium",
        team: "GEE",
        averagePoints: 98.3,
        lastScore: 87,
        projectedScore: 102,
        // Fantasy stats
        roundsPlayed: 7,
        l3Average: 92.3,
        l5Average: 95.6,
        priceChange: -8000,
        pricePerPoint: 8342,
        totalPoints: 688,
        selectionPercentage: 18.7,
        // Basic stats
        kicks: 14,
        handballs: 8,
        disposals: 22,
        marks: 8,
        tackles: 3,
        freeKicksFor: 2,
        freeKicksAgainst: 2,
        clearances: 1,
        hitouts: 0,
        cba: 0,
        kickIns: 0,
        uncontestedMarks: 5,
        contestedMarks: 3,
        uncontestedDisposals: 14,
        contestedDisposals: 8,
        // VS stats
        averageVsOpp: 95.3,
        averageAtVenue: 101.2,
        averageVs3RoundOpp: 97.5,
        averageAt3RoundVenue: 99.8,
        opponentDifficulty: 6.6,
        opponent3RoundDifficulty: 7.2,
        // Extended stats
        standardDeviation: 19.2,
        highScore: 132,
        lowScore: 68,
        belowAveragePercentage: 0.33,
        nextOpponent: "WBD",
        scoreImpact: -5.5,
        projectedAverage: 92.8,
        nextVenue: "GMHBA",
        venueScoreVariance: 15.7,
        projectedPriceChange: -12000,
        breakEvenPercentage: 0.64,
        projectedOwnershipChange: -2.2,
        // Status
        isSelected: true,
        isInjured: false,
        isSuspended: false,
        isFavorite: false
      },
      {
        name: "Isaac Heeney",
        position: "FWD",
        price: 850000,
        breakEven: 97,
        category: "Premium",
        team: "SYD",
        averagePoints: 112.3,
        lastScore: 118,
        projectedScore: 115,
        // Fantasy stats
        roundsPlayed: 7,
        l3Average: 115.7,
        l5Average: 113.6,
        priceChange: 18000,
        pricePerPoint: 7569,
        totalPoints: 786,
        selectionPercentage: 32.7,
        // Basic stats
        kicks: 15,
        handballs: 11,
        disposals: 26,
        marks: 8,
        tackles: 6,
        freeKicksFor: 3,
        freeKicksAgainst: 2,
        clearances: 5,
        hitouts: 0,
        cba: 42.5,
        kickIns: 0,
        uncontestedMarks: 5,
        contestedMarks: 3,
        uncontestedDisposals: 15,
        contestedDisposals: 11,
        // VS stats
        averageVsOpp: 109.6,
        averageAtVenue: 115.8,
        averageVs3RoundOpp: 112.1,
        averageAt3RoundVenue: 116.3,
        opponentDifficulty: 6.1,
        opponent3RoundDifficulty: 5.8,
        // Extended stats
        standardDeviation: 11.2,
        highScore: 128,
        lowScore: 92,
        belowAveragePercentage: 0.29,
        nextOpponent: "COL",
        scoreImpact: 1.8,
        projectedAverage: 114.1,
        nextVenue: "SCG",
        venueScoreVariance: 9.2,
        projectedPriceChange: 12000,
        breakEvenPercentage: 0.48,
        projectedOwnershipChange: 1.5,
        // Status
        isSelected: true,
        isInjured: false,
        isSuspended: false,
        isFavorite: false
      },
      {
        name: "Jake Lloyd",
        position: "DEF",
        price: 780000,
        breakEven: 94,
        category: "Premium",
        team: "SYD",
        averagePoints: 96.8,
        lastScore: 88,
        projectedScore: 95,
        // Fantasy stats
        roundsPlayed: 7,
        l3Average: 92.3,
        l5Average: 94.6,
        priceChange: -5000,
        pricePerPoint: 8057,
        totalPoints: 678,
        selectionPercentage: 12.4,
        // Basic stats
        kicks: 19,
        handballs: 8,
        disposals: 27,
        marks: 8,
        tackles: 2,
        freeKicksFor: 1,
        freeKicksAgainst: 0,
        clearances: 2,
        hitouts: 0,
        cba: 0,
        kickIns: 8,
        uncontestedMarks: 6,
        contestedMarks: 2,
        uncontestedDisposals: 20,
        contestedDisposals: 7,
        // VS stats
        averageVsOpp: 92.4,
        averageAtVenue: 98.2,
        averageVs3RoundOpp: 94.3,
        averageAt3RoundVenue: 96.8,
        opponentDifficulty: 7.2,
        opponent3RoundDifficulty: 6.8,
        // Extended stats
        standardDeviation: 14.8,
        highScore: 112,
        lowScore: 76,
        belowAveragePercentage: 0.43,
        nextOpponent: "COL",
        scoreImpact: -3.5,
        projectedAverage: 93.3,
        nextVenue: "SCG",
        venueScoreVariance: 12.5,
        projectedPriceChange: -8000,
        breakEvenPercentage: 0.58,
        projectedOwnershipChange: -0.8,
        // Status
        isSelected: true,
        isInjured: false,
        isSuspended: false,
        isFavorite: false
      },
      {
        name: "James Sicily",
        position: "DEF",
        price: 810000,
        breakEven: 98,
        category: "Premium",
        team: "HAW",
        averagePoints: 99.4,
        lastScore: 110,
        projectedScore: 100,
        // Fantasy stats
        roundsPlayed: 7,
        l3Average: 104.7,
        l5Average: 101.2,
        priceChange: 8000,
        pricePerPoint: 8148,
        totalPoints: 696,
        selectionPercentage: 18.9,
        // Basic stats
        kicks: 18,
        handballs: 7,
        disposals: 25,
        marks: 9,
        tackles: 3,
        freeKicksFor: 1,
        freeKicksAgainst: 2,
        clearances: 1,
        hitouts: 0,
        cba: 0,
        kickIns: 6,
        uncontestedMarks: 7,
        contestedMarks: 2,
        uncontestedDisposals: 17,
        contestedDisposals: 8,
        // VS stats
        averageVsOpp: 95.6,
        averageAtVenue: 101.2,
        averageVs3RoundOpp: 97.5,
        averageAt3RoundVenue: 103.8,
        opponentDifficulty: 6.1,
        opponent3RoundDifficulty: 5.8,
        // Extended stats
        standardDeviation: 13.6,
        highScore: 118,
        lowScore: 78,
        belowAveragePercentage: 0.29,
        nextOpponent: "WCE",
        scoreImpact: 6.5,
        projectedAverage: 105.9,
        nextVenue: "MCG",
        venueScoreVariance: 11.2,
        projectedPriceChange: 15000,
        breakEvenPercentage: 0.45,
        projectedOwnershipChange: 2.2,
        // Status
        isSelected: true,
        isInjured: false,
        isSuspended: false,
        isFavorite: false
      },
      {
        name: "Nick Daicos",
        position: "DEF",
        price: 889000,
        breakEven: 103,
        category: "Premium",
        team: "COL",
        averagePoints: 115.6,
        lastScore: 88,
        projectedScore: 110,
        // Fantasy stats
        roundsPlayed: 7,
        l3Average: 105.3,
        l5Average: 112.4,
        priceChange: -8000,
        pricePerPoint: 7691,
        totalPoints: 809,
        selectionPercentage: 38.5,
        // Basic stats
        kicks: 22,
        handballs: 10,
        disposals: 32,
        marks: 8,
        tackles: 4,
        freeKicksFor: 1,
        freeKicksAgainst: 2,
        clearances: 5,
        hitouts: 0,
        cba: 10.2,
        kickIns: 7,
        uncontestedMarks: 5,
        contestedMarks: 3,
        uncontestedDisposals: 22,
        contestedDisposals: 10,
        // VS stats
        averageVsOpp: 102.8,
        averageAtVenue: 97.5,
        averageVs3RoundOpp: 101.2,
        averageAt3RoundVenue: 104.7,
        opponentDifficulty: 8.2,
        opponent3RoundDifficulty: 7.6,
        // Extended stats
        standardDeviation: 18.5,
        highScore: 135,
        lowScore: 88,
        belowAveragePercentage: 0.29,
        nextOpponent: "SYD",
        scoreImpact: -7.5,
        projectedAverage: 108.1,
        nextVenue: "SCG",
        venueScoreVariance: 22.6,
        projectedPriceChange: -12000,
        breakEvenPercentage: 0.65,
        projectedOwnershipChange: -3.5,
        // Status
        isSelected: true,
        isInjured: false,
        isSuspended: false,
        isFavorite: false
      },
      {
        name: "Max Gawn",
        position: "RUCK",
        price: 870000,
        breakEven: 103,
        category: "Premium",
        team: "MEL",
        averagePoints: 113.5,
        lastScore: 105,
        projectedScore: 110,
        // Fantasy stats
        roundsPlayed: 7,
        l3Average: 108.3,
        l5Average: 111.6,
        priceChange: 2000,
        pricePerPoint: 7665,
        totalPoints: 795,
        selectionPercentage: 14.8,
        // Basic stats
        kicks: 12,
        handballs: 10,
        disposals: 22,
        marks: 6,
        tackles: 3,
        freeKicksFor: 3,
        freeKicksAgainst: 2,
        clearances: 6,
        hitouts: 38,
        cba: 98.7,
        kickIns: 0,
        uncontestedMarks: 3,
        contestedMarks: 3,
        uncontestedDisposals: 9,
        contestedDisposals: 13,
        // VS stats
        averageVsOpp: 128.5,
        averageAtVenue: 105.8,
        averageVs3RoundOpp: 120.2,
        averageAt3RoundVenue: 112.5,
        opponentDifficulty: 3.5,
        opponent3RoundDifficulty: 5.2,
        // Extended stats
        standardDeviation: 13.6,
        highScore: 132,
        lowScore: 95,
        belowAveragePercentage: 0.29,
        nextOpponent: "GCS",
        scoreImpact: 8.5,
        projectedAverage: 117.2,
        nextVenue: "TIO",
        venueScoreVariance: 15.7,
        projectedPriceChange: 15000,
        breakEvenPercentage: 0.55,
        projectedOwnershipChange: 0.8,
        // Status
        isSelected: false,
        isInjured: true,
        isSuspended: false,
        isFavorite: false
      },
      {
        name: "Harry Sheezel",
        position: "DEF",
        price: 750000,
        breakEven: 78,
        category: "Mid-Pricer",
        team: "NTH",
        averagePoints: 97.1,
        lastScore: 103,
        projectedScore: 100,
        // Fantasy stats
        roundsPlayed: 7,
        l3Average: 99.7,
        l5Average: 98.2,
        priceChange: 28000,
        pricePerPoint: 7724,
        totalPoints: 680,
        selectionPercentage: 22.5,
        // Basic stats
        kicks: 19,
        handballs: 9,
        disposals: 28,
        marks: 7,
        tackles: 2,
        freeKicksFor: 1,
        freeKicksAgainst: 1,
        clearances: 1,
        hitouts: 0,
        cba: 0,
        kickIns: 12,
        uncontestedMarks: 5,
        contestedMarks: 2,
        uncontestedDisposals: 21,
        contestedDisposals: 7,
        // VS stats
        averageVsOpp: 92.5,
        averageAtVenue: 98.2,
        averageVs3RoundOpp: 94.7,
        averageAt3RoundVenue: 97.5,
        opponentDifficulty: 5.8,
        opponent3RoundDifficulty: 6.2,
        // Extended stats
        standardDeviation: 10.3,
        highScore: 114,
        lowScore: 83,
        belowAveragePercentage: 0.29,
        nextOpponent: "CAR",
        scoreImpact: 2.5,
        projectedAverage: 99.6,
        nextVenue: "Marvel",
        venueScoreVariance: 9.8,
        projectedPriceChange: 10000,
        breakEvenPercentage: 0.42,
        projectedOwnershipChange: 1.2,
        // Status
        isSelected: true,
        isInjured: false,
        isSuspended: false,
        isFavorite: false
      },
      {
        name: "Colby McKercher",
        position: "DEF",
        price: 380000,
        breakEven: 20,
        category: "Rookie",
        team: "NTH",
        averagePoints: 79.5,
        lastScore: 81,
        projectedScore: 75,
        // Fantasy stats
        roundsPlayed: 6,
        l3Average: 81.7,
        l5Average: 77.6,
        priceChange: 42000,
        pricePerPoint: 4780,
        totalPoints: 477,
        selectionPercentage: 18.9,
        // Basic stats
        kicks: 14,
        handballs: 8,
        disposals: 22,
        marks: 5,
        tackles: 2,
        freeKicksFor: 1,
        freeKicksAgainst: 1,
        clearances: 2,
        hitouts: 0,
        cba: 0,
        kickIns: 5,
        uncontestedMarks: 4,
        contestedMarks: 1,
        uncontestedDisposals: 16,
        contestedDisposals: 6,
        // VS stats
        averageVsOpp: 72.5,
        averageAtVenue: 77.8,
        averageVs3RoundOpp: 75.2,
        averageAt3RoundVenue: 76.1,
        opponentDifficulty: 7.8,
        opponent3RoundDifficulty: 7.2,
        // Extended stats
        standardDeviation: 12.6,
        highScore: 96,
        lowScore: 61,
        belowAveragePercentage: 0.33,
        nextOpponent: "CAR",
        scoreImpact: -5.2,
        projectedAverage: 74.3,
        nextVenue: "Marvel",
        venueScoreVariance: 11.7,
        projectedPriceChange: 22000,
        breakEvenPercentage: 0.08,
        projectedOwnershipChange: 0.2,
        // Status
        isSelected: true,
        isInjured: false,
        isSuspended: false,
        isFavorite: false
      },
      {
        name: "Nick Larkey",
        position: "FWD",
        price: 720000,
        breakEven: 75,
        category: "Mid-Pricer",
        team: "NTH",
        averagePoints: 91.8,
        lastScore: 96,
        projectedScore: 93,
        // Fantasy stats
        roundsPlayed: 7,
        l3Average: 94.3,
        l5Average: 92.8,
        priceChange: 22000,
        pricePerPoint: 7843,
        totalPoints: 643,
        selectionPercentage: 8.5,
        // Basic stats
        kicks: 12,
        handballs: 5,
        disposals: 17,
        marks: 9,
        tackles: 3,
        freeKicksFor: 2,
        freeKicksAgainst: 3,
        clearances: 0,
        hitouts: 0,
        cba: 0,
        kickIns: 0,
        uncontestedMarks: 3,
        contestedMarks: 6,
        uncontestedDisposals: 8,
        contestedDisposals: 9,
        // VS stats
        averageVsOpp: 86.5,
        averageAtVenue: 92.8,
        averageVs3RoundOpp: 88.2,
        averageAt3RoundVenue: 93.1,
        opponentDifficulty: 7.2,
        opponent3RoundDifficulty: 6.8,
        // Extended stats
        standardDeviation: 19.8,
        highScore: 122,
        lowScore: 58,
        belowAveragePercentage: 0.43,
        nextOpponent: "CAR",
        scoreImpact: -5.2,
        projectedAverage: 88.6,
        nextVenue: "Marvel",
        venueScoreVariance: 18.7,
        projectedPriceChange: 4000,
        breakEvenPercentage: 0.32,
        projectedOwnershipChange: -0.2,
        // Status
        isSelected: true,
        isInjured: false,
        isSuspended: false,
        isFavorite: false
      },
      {
        name: "Shai Bolton",
        position: "FWD",
        price: 760000,
        breakEven: 81,
        category: "Mid-Pricer",
        team: "RIC",
        averagePoints: 97.5,
        lastScore: 85,
        projectedScore: 95,
        // Fantasy stats
        roundsPlayed: 7,
        l3Average: 88.7,
        l5Average: 92.4,
        priceChange: -8000,
        pricePerPoint: 7795,
        totalPoints: 683,
        selectionPercentage: 19.3,
        // Basic stats
        kicks: 14,
        handballs: 10,
        disposals: 24,
        marks: 5,
        tackles: 4,
        freeKicksFor: 2,
        freeKicksAgainst: 2,
        clearances: 3,
        hitouts: 0,
        cba: 32.6,
        kickIns: 0,
        uncontestedMarks: 3,
        contestedMarks: 2,
        uncontestedDisposals: 16,
        contestedDisposals: 8,
        // VS stats
        averageVsOpp: 93.2,
        averageAtVenue: 99.8,
        averageVs3RoundOpp: 96.1,
        averageAt3RoundVenue: 98.5,
        opponentDifficulty: 7.0,
        opponent3RoundDifficulty: 6.2,
        // Extended stats
        standardDeviation: 21.8,
        highScore: 135,
        lowScore: 65,
        belowAveragePercentage: 0.57,
        nextOpponent: "ESS",
        scoreImpact: -3.5,
        projectedAverage: 94.0,
        nextVenue: "MCG",
        venueScoreVariance: 24.5,
        projectedPriceChange: -5000,
        breakEvenPercentage: 0.68,
        projectedOwnershipChange: -2.1,
        // Status
        isSelected: true,
        isInjured: false,
        isSuspended: true,
        isFavorite: false
      }
    ];
    
    samplePlayers.forEach(player => this.createPlayer(player));
    
    // Create a test user
    this.createUser({
      username: "test",
      password: "password"
    }).then(user => {
      // Create a team for the test user
      this.createTeam({
        userId: user.id,
        name: "Bont's Brigade",
        value: 15800000,
        score: 2150,
        captainId: 1, // Bontempelli
        overallRank: 12000,
        trades: 2
      }).then(team => {
        // Add players to the user's team
        const addMidfielders = [
          { playerId: 1, position: "MID", isOnField: true }, // Bontempelli
          { playerId: 2, position: "MID", isOnField: true }, // Oliver
          { playerId: 3, position: "MID", isOnField: true }, // Macrae
        ];
        
        const addForwards = [
          { playerId: 4, position: "FWD", isOnField: true }, // Petracca
          { playerId: 5, position: "FWD", isOnField: true }, // Cameron
          { playerId: 6, position: "FWD", isOnField: true }, // Heeney
        ];
        
        const addDefenders = [
          { playerId: 7, position: "DEF", isOnField: true }, // Lloyd 
          { playerId: 8, position: "DEF", isOnField: true }, // Sicily
          { playerId: 9, position: "DEF", isOnField: true }, // McGovern
        ];
        
        const addRucks = [
          { playerId: 10, position: "RUCK", isOnField: true }, // Grundy
          { playerId: 11, position: "RUCK", isOnField: true }, // Marshall
        ];
        
        // Add all players to the team
        [...addMidfielders, ...addForwards, ...addDefenders, ...addRucks].forEach(playerData => {
          this.addPlayerToTeam({
            teamId: team.id,
            playerId: playerData.playerId,
            position: playerData.position,
            isOnField: playerData.isOnField
          });
        });
        
        // Create 5 leagues for this user with active matchups
        const leagueNames = [
          "AFL Elite League",
          "Supercoach Masters",
          "Victoria Footy League",
          "Pro Fantasy Classic",
          "Premiership Contenders"
        ];
        
        // Create opponent teams
        const createOpponentTeams = async () => {
          const opponentTeams = [];
          
          for (let i = 0; i < 5; i++) {
            // Create user for opponent
            const oppUser = await this.createUser({
              username: `opponent${i}`,
              password: "password"
            });
            
            // Create team for opponent
            const oppTeam = await this.createTeam({
              userId: oppUser.id,
              name: `Opponent Team ${i+1}`,
              value: 15000000 + (Math.floor(Math.random() * 1000000)),
              score: 1900 + (Math.floor(Math.random() * 300)),
              captainId: Math.floor(Math.random() * 16) + 1, // Random captain
              overallRank: 15000 + (Math.floor(Math.random() * 20000)),
              trades: Math.floor(Math.random() * 5) + 5
            });
            
            // Add some players to opponent team
            const positions = ["MID", "FWD", "DEF", "RUCK"];
            for (let j = 1; j <= 16; j++) {
              const position = positions[Math.floor(Math.random() * positions.length)];
              await this.addPlayerToTeam({
                teamId: oppTeam.id,
                playerId: j,
                position: position,
                isOnField: true
              });
            }
            
            opponentTeams.push(oppTeam);
          }
          
          return opponentTeams;
        };
        
        createOpponentTeams().then(opponentTeams => {
          // Create the leagues and add the user to them
          const createLeaguesPromises = leagueNames.map(async (name, index) => {
            const league = await this.createLeague({
              name: name,
              creatorId: user.id,
              code: `AFL${index+1}23`
            });
            
            // Add the user's team to the league
            await this.addTeamToLeague({
              leagueId: league.id,
              teamId: team.id,
              wins: 3 + Math.floor(Math.random() * 4), // 3-6 wins
              losses: Math.floor(Math.random() * 4), // 0-3 losses
              pointsFor: 12000 + Math.floor(Math.random() * 3000)
            });
            
            // Add 5-10 opponent teams to the league
            const numTeams = 5 + Math.floor(Math.random() * 6);
            for (let i = 0; i < numTeams; i++) {
              if (i < opponentTeams.length) {
                await this.addTeamToLeague({
                  leagueId: league.id,
                  teamId: opponentTeams[i].id,
                  wins: Math.floor(Math.random() * 7),
                  losses: Math.floor(Math.random() * 4),
                  pointsFor: 10000 + Math.floor(Math.random() * 4000)
                });
              }
            }
            
            // Create matchup for this league with varying scores 
            // and different opponents for each league
            const oppTeam = opponentTeams[index % opponentTeams.length];
            await this.createMatchup({
              leagueId: league.id,
              round: 7,
              team1Id: team.id,
              team2Id: oppTeam.id,
              team1Score: 1700 + Math.floor(Math.random() * 400), // 1700-2100
              team2Score: 1600 + Math.floor(Math.random() * 400)  // 1600-2000
            });
            
            return league;
          });
          
          Promise.all(createLeaguesPromises).then(() => {
            // Add round performance history for the team
            for (let i = 1; i <= 6; i++) {
              this.createRoundPerformance({
                teamId: team.id,
                round: i,
                score: 2000 + (i * 25), // Gradually increasing scores
                value: 15000000 + (i * 100000), // Gradually increasing value
                rank: 20000 - (i * 1500), // Rank getting better
                projectedScore: 1950 + (i * 20) // Projected scores
              });
            }
          });
        });
      });
    });
  }

  // User Methods
  async getUser(id: number): Promise<User | undefined> {
    return this.users.get(id);
  }

  async getUserByUsername(username: string): Promise<User | undefined> {
    return Array.from(this.users.values()).find(
      (user) => user.username === username,
    );
  }

  async createUser(insertUser: InsertUser): Promise<User> {
    const id = this.nextIds.user++;
    const user: User = { ...insertUser, id };
    this.users.set(id, user);
    return user;
  }

  // Player Methods
  async getAllPlayers(): Promise<Player[]> {
    return Array.from(this.players.values());
  }

  async getPlayer(id: number): Promise<Player | undefined> {
    return this.players.get(id);
  }

  async getPlayersByPosition(position: string): Promise<Player[]> {
    return Array.from(this.players.values()).filter(
      player => player.position === position
    );
  }

  async searchPlayers(query: string): Promise<Player[]> {
    const lowerQuery = query.toLowerCase();
    return Array.from(this.players.values()).filter(
      player => 
        player.name.toLowerCase().includes(lowerQuery) ||
        player.team.toLowerCase().includes(lowerQuery) ||
        player.position.toLowerCase().includes(lowerQuery)
    );
  }

  async createPlayer(insertPlayer: InsertPlayer): Promise<Player> {
    const id = this.nextIds.player++;
    const player: Player = { ...insertPlayer, id };
    this.players.set(id, player);
    return player;
  }

  async updatePlayer(id: number, playerData: Partial<InsertPlayer>): Promise<Player | undefined> {
    const player = this.players.get(id);
    if (!player) return undefined;
    
    const updatedPlayer = { ...player, ...playerData };
    this.players.set(id, updatedPlayer);
    return updatedPlayer;
  }

  // Team Methods
  async getTeam(id: number): Promise<Team | undefined> {
    return this.teams.get(id);
  }

  async getTeamByUserId(userId: number): Promise<Team | undefined> {
    return Array.from(this.teams.values()).find(
      team => team.userId === userId
    );
  }

  async createTeam(insertTeam: InsertTeam): Promise<Team> {
    const id = this.nextIds.team++;
    const team: Team = { ...insertTeam, id };
    this.teams.set(id, team);
    return team;
  }

  async updateTeam(id: number, teamData: Partial<InsertTeam>): Promise<Team | undefined> {
    const team = this.teams.get(id);
    if (!team) return undefined;
    
    const updatedTeam = { ...team, ...teamData };
    this.teams.set(id, updatedTeam);
    return updatedTeam;
  }

  // TeamPlayer Methods
  async getTeamPlayers(teamId: number): Promise<TeamPlayer[]> {
    return Array.from(this.teamPlayers.values()).filter(
      tp => tp.teamId === teamId
    );
  }

  async getTeamPlayersByPosition(teamId: number, position: string): Promise<TeamPlayer[]> {
    return Array.from(this.teamPlayers.values()).filter(
      tp => tp.teamId === teamId && tp.position === position
    );
  }

  async getTeamPlayerDetails(teamId: number): Promise<(TeamPlayer & { player: Player })[]> {
    const teamPlayers = await this.getTeamPlayers(teamId);
    return teamPlayers.map(tp => {
      const player = this.players.get(tp.playerId);
      if (!player) throw new Error(`Player not found: ${tp.playerId}`);
      return { ...tp, player };
    });
  }

  async addPlayerToTeam(insertTeamPlayer: InsertTeamPlayer): Promise<TeamPlayer> {
    const id = this.nextIds.teamPlayer++;
    const teamPlayer: TeamPlayer = { ...insertTeamPlayer, id };
    this.teamPlayers.set(id, teamPlayer);
    return teamPlayer;
  }

  async removePlayerFromTeam(teamId: number, playerId: number): Promise<boolean> {
    const teamPlayerEntry = Array.from(this.teamPlayers.entries()).find(
      ([_, tp]) => tp.teamId === teamId && tp.playerId === playerId
    );
    
    if (!teamPlayerEntry) return false;
    
    this.teamPlayers.delete(teamPlayerEntry[0]);
    return true;
  }

  // League Methods
  async getLeague(id: number): Promise<League | undefined> {
    return this.leagues.get(id);
  }

  async getLeaguesByUserId(userId: number): Promise<League[]> {
    // Get user's team
    const userTeam = await this.getTeamByUserId(userId);
    if (!userTeam) {
      return [];
    }
    
    // Find all league teams that include the user's team
    const userLeagueTeams = Array.from(this.leagueTeams.values()).filter(
      lt => lt.teamId === userTeam.id
    );
    
    // Get all the league IDs
    const leagueIds = userLeagueTeams.map(lt => lt.leagueId);
    
    // Get all the leagues
    return Array.from(this.leagues.values()).filter(
      league => leagueIds.includes(league.id)
    );
  }

  async createLeague(insertLeague: InsertLeague): Promise<League> {
    const id = this.nextIds.league++;
    const league: League = { ...insertLeague, id };
    this.leagues.set(id, league);
    return league;
  }

  // LeagueTeam Methods
  async getLeagueTeams(leagueId: number): Promise<LeagueTeam[]> {
    return Array.from(this.leagueTeams.values()).filter(
      lt => lt.leagueId === leagueId
    );
  }

  async getLeagueTeamDetails(leagueId: number): Promise<(LeagueTeam & { team: Team })[]> {
    const leagueTeams = await this.getLeagueTeams(leagueId);
    return leagueTeams.map(lt => {
      const team = this.teams.get(lt.teamId);
      if (!team) throw new Error(`Team not found: ${lt.teamId}`);
      return { ...lt, team };
    });
  }

  async addTeamToLeague(insertLeagueTeam: InsertLeagueTeam): Promise<LeagueTeam> {
    const id = this.nextIds.leagueTeam++;
    const leagueTeam: LeagueTeam = { ...insertLeagueTeam, id };
    this.leagueTeams.set(id, leagueTeam);
    return leagueTeam;
  }

  async updateLeagueTeam(leagueId: number, teamId: number, data: Partial<InsertLeagueTeam>): Promise<LeagueTeam | undefined> {
    const leagueTeamEntry = Array.from(this.leagueTeams.entries()).find(
      ([_, lt]) => lt.leagueId === leagueId && lt.teamId === teamId
    );
    
    if (!leagueTeamEntry) return undefined;
    
    const [id, leagueTeam] = leagueTeamEntry;
    const updatedLeagueTeam = { ...leagueTeam, ...data };
    this.leagueTeams.set(id, updatedLeagueTeam);
    return updatedLeagueTeam;
  }

  // Matchup Methods
  async getMatchups(leagueId: number, round: number): Promise<Matchup[]> {
    return Array.from(this.matchups.values()).filter(
      m => m.leagueId === leagueId && m.round === round
    );
  }

  async getMatchupDetails(leagueId: number, round: number): Promise<(Matchup & { team1: Team, team2: Team })[]> {
    const matchups = await this.getMatchups(leagueId, round);
    
    // Initialize the second team if it doesn't exist
    if (matchups.length > 0 && !this.teams.has(2)) {
      const team2: Team = {
        id: 2,
        userId: 2,
        name: "The Contenders",
        value: 12500000,
        score: 1950,
        overallRank: 2500,
        trades: 3,
        captainId: 2
      };
      this.teams.set(2, team2);
    }
    
    return matchups.map(m => {
      const team1 = this.teams.get(m.team1Id);
      const team2 = this.teams.get(m.team2Id);
      
      // Use existing teams or create fallback teams
      const team1Data = team1 || {
        id: m.team1Id,
        userId: 99,
        name: `Team ${m.team1Id}`,
        value: 15000000,
        score: 2000,
        overallRank: 5000,
        trades: 5,
        captainId: 1
      };
      
      const team2Data = team2 || {
        id: m.team2Id,
        userId: 99,
        name: `Team ${m.team2Id}`,
        value: 15000000,
        score: 2000,
        overallRank: 5000,
        trades: 5,
        captainId: 1
      };
      
      return { ...m, team1: team1Data, team2: team2Data };
    });
  }

  async createMatchup(insertMatchup: InsertMatchup): Promise<Matchup> {
    const id = this.nextIds.matchup++;
    const matchup: Matchup = { ...insertMatchup, id };
    this.matchups.set(id, matchup);
    return matchup;
  }

  async updateMatchup(id: number, matchupData: Partial<InsertMatchup>): Promise<Matchup | undefined> {
    const matchup = this.matchups.get(id);
    if (!matchup) return undefined;
    
    const updatedMatchup = { ...matchup, ...matchupData };
    this.matchups.set(id, updatedMatchup);
    return updatedMatchup;
  }

  // Round Performance Methods
  async getRoundPerformances(teamId: number): Promise<RoundPerformance[]> {
    return Array.from(this.roundPerformances.values())
      .filter(rp => rp.teamId === teamId)
      .sort((a, b) => a.round - b.round);
  }

  async getRoundPerformance(teamId: number, round: number): Promise<RoundPerformance | undefined> {
    return Array.from(this.roundPerformances.values()).find(
      rp => rp.teamId === teamId && rp.round === round
    );
  }

  async createRoundPerformance(insertPerf: InsertRoundPerformance): Promise<RoundPerformance> {
    const id = this.nextIds.roundPerformance++;
    const perf: RoundPerformance = { ...insertPerf, id };
    this.roundPerformances.set(id, perf);
    return perf;
  }

  async updateRoundPerformance(id: number, perfData: Partial<InsertRoundPerformance>): Promise<RoundPerformance | undefined> {
    const perf = this.roundPerformances.get(id);
    if (!perf) return undefined;
    
    const updatedPerf = { ...perf, ...perfData };
    this.roundPerformances.set(id, updatedPerf);
    return updatedPerf;
  }
}

export const storage = new MemStorage();
