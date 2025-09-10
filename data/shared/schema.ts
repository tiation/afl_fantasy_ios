import { pgTable, text, serial, integer, boolean, jsonb, real, timestamp, primaryKey, foreignKey } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod";
import { relations } from "drizzle-orm";

// Player schemas
export const players = pgTable("players", {
  id: serial("id").primaryKey(),
  name: text("name").notNull(),
  position: text("position").notNull(), // MID, FWD, DEF, RUCK
  price: integer("price").notNull(),
  breakEven: integer("break_even").notNull(),
  category: text("category").notNull(), // Premium, Mid-Pricer, Rookie
  team: text("team").notNull(),
  averagePoints: real("average_points").notNull(),
  lastScore: integer("last_score"),
  projectedScore: integer("projected_score"),
  
  // Fantasy stats
  roundsPlayed: integer("rounds_played").default(0),
  l3Average: real("l3_average"),
  l5Average: real("l5_average"),
  priceChange: integer("price_change").default(0),
  pricePerPoint: real("price_per_point"),
  totalPoints: integer("total_points").default(0),
  selectionPercentage: real("selection_percentage"),
  
  // Basic stats
  kicks: integer("kicks"),
  handballs: integer("handballs"),
  disposals: integer("disposals"),
  marks: integer("marks"),
  tackles: integer("tackles"),
  freeKicksFor: integer("free_kicks_for"),
  freeKicksAgainst: integer("free_kicks_against"),
  clearances: integer("clearances"),
  hitouts: integer("hitouts"),
  cba: real("cba"),
  kickIns: integer("kick_ins"),
  uncontestedMarks: integer("uncontested_marks"),
  contestedMarks: integer("contested_marks"),
  uncontestedDisposals: integer("uncontested_disposals"),
  contestedDisposals: integer("contested_disposals"),
  
  // VS stats
  averageVsOpp: real("average_vs_opp"),
  averageAtVenue: real("average_at_venue"),
  averageVs3RoundOpp: real("average_vs_3round_opp"),
  averageAt3RoundVenue: real("average_at_3round_venue"),
  opponentDifficulty: real("opponent_difficulty"),
  opponent3RoundDifficulty: real("opponent_3round_difficulty"),
  
  // Extended stats
  standardDeviation: real("standard_deviation"),
  highScore: integer("high_score"),
  lowScore: integer("low_score"),
  belowAveragePercentage: real("below_average_percentage"),
  nextOpponent: text("next_opponent"),
  scoreImpact: real("score_impact"),
  projectedAverage: real("projected_average"),
  nextVenue: text("next_venue"),
  venueScoreVariance: real("venue_score_variance"),
  projectedPriceChange: integer("projected_price_change"),
  breakEvenPercentage: real("break_even_percentage"),
  projectedOwnershipChange: real("projected_ownership_change"),
  
  // Status
  isSelected: boolean("is_selected").default(true),
  isInjured: boolean("is_injured").default(false),
  isSuspended: boolean("is_suspended").default(false),
  isFavorite: boolean("is_favorite").default(false)
});

export const insertPlayerSchema = createInsertSchema(players).omit({
  id: true
});

// Team schemas
export const teams = pgTable("teams", {
  id: serial("id").primaryKey(),
  userId: integer("user_id").notNull(),
  name: text("name").notNull(),
  value: integer("value").notNull().default(10000000), // Team value in dollars
  score: integer("score").notNull().default(0),
  captainId: integer("captain_id"),
  overallRank: integer("overall_rank"),
  trades: integer("trades").notNull().default(2),
});

export const insertTeamSchema = createInsertSchema(teams).omit({
  id: true
});

// Team Player schemas (for tracking which players are in which teams)
export const teamPlayers = pgTable("team_players", {
  id: serial("id").primaryKey(),
  teamId: integer("team_id").notNull(),
  playerId: integer("player_id").notNull(),
  position: text("position").notNull(), // MID, FWD, DEF, RUCK
  isOnField: boolean("is_on_field").notNull().default(false), // Whether the player is active or on the bench
});

export const insertTeamPlayerSchema = createInsertSchema(teamPlayers).omit({
  id: true
});

// League schemas
export const leagues = pgTable("leagues", {
  id: serial("id").primaryKey(),
  name: text("name").notNull(),
  creatorId: integer("creator_id").notNull(),
  code: text("code").notNull(),
});

export const insertLeagueSchema = createInsertSchema(leagues).omit({
  id: true
});

// League Team schemas (for tracking which teams are in which leagues)
export const leagueTeams = pgTable("league_teams", {
  id: serial("id").primaryKey(),
  leagueId: integer("league_id").notNull(),
  teamId: integer("team_id").notNull(),
  wins: integer("wins").notNull().default(0),
  losses: integer("losses").notNull().default(0),
  pointsFor: integer("points_for").notNull().default(0),
});

export const insertLeagueTeamSchema = createInsertSchema(leagueTeams).omit({
  id: true
});

// Matchup schemas (for tracking match-ups between teams in leagues)
export const matchups = pgTable("matchups", {
  id: serial("id").primaryKey(),
  leagueId: integer("league_id").notNull(),
  round: integer("round").notNull(),
  team1Id: integer("team1_id").notNull(),
  team2Id: integer("team2_id").notNull(),
  team1Score: integer("team1_score"),
  team2Score: integer("team2_score"),
});

export const insertMatchupSchema = createInsertSchema(matchups).omit({
  id: true
});

// Round performance schemas (for tracking team performance by round)
export const roundPerformances = pgTable("round_performances", {
  id: serial("id").primaryKey(),
  teamId: integer("team_id").notNull(),
  round: integer("round").notNull(),
  score: integer("score").notNull(),
  value: integer("value").notNull(),
  rank: integer("rank"),
  projectedScore: integer("projected_score"),
});

export const insertRoundPerformanceSchema = createInsertSchema(roundPerformances).omit({
  id: true
});

// User schemas
export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  username: text("username").notNull().unique(),
  password: text("password").notNull(),
});

export const insertUserSchema = createInsertSchema(users).omit({
  id: true
});

// Types
export type InsertPlayer = z.infer<typeof insertPlayerSchema>;
export type Player = typeof players.$inferSelect;

export type InsertTeam = z.infer<typeof insertTeamSchema>;
export type Team = typeof teams.$inferSelect;

export type InsertTeamPlayer = z.infer<typeof insertTeamPlayerSchema>;
export type TeamPlayer = typeof teamPlayers.$inferSelect;

export type InsertLeague = z.infer<typeof insertLeagueSchema>;
export type League = typeof leagues.$inferSelect;

export type InsertLeagueTeam = z.infer<typeof insertLeagueTeamSchema>;
export type LeagueTeam = typeof leagueTeams.$inferSelect;

export type InsertMatchup = z.infer<typeof insertMatchupSchema>;
export type Matchup = typeof matchups.$inferSelect;

export type InsertRoundPerformance = z.infer<typeof insertRoundPerformanceSchema>;
export type RoundPerformance = typeof roundPerformances.$inferSelect;

export type InsertUser = z.infer<typeof insertUserSchema>;
export type User = typeof users.$inferSelect;

// Player Round Scores - Individual round-by-round performance data
export const playerRoundScores = pgTable("player_round_scores", {
  id: serial("id").primaryKey(),
  playerId: integer("player_id").notNull(),
  round: integer("round").notNull(),
  score: integer("score").notNull(),
  price: integer("price").notNull(),
  opponent: text("opponent").notNull(),
  venue: text("venue").notNull(),
  isHome: boolean("is_home").notNull().default(false),
  minutes: integer("minutes"),
  breakEven: integer("break_even"),
  priceChange: integer("price_change").default(0),
});

export const insertPlayerRoundScoreSchema = createInsertSchema(playerRoundScores).omit({
  id: true
});

// Opponent History - Head-to-head performance records
export const opponentHistory = pgTable("opponent_history", {
  id: serial("id").primaryKey(),
  playerId: integer("player_id").notNull(),
  opponent: text("opponent").notNull(),
  averageScore: real("average_score").notNull(),
  gamesPlayed: integer("games_played").notNull(),
  lastScore: integer("last_score"),
  last3Average: real("last_3_average"),
  lastRound: integer("last_round"),
});

export const insertOpponentHistorySchema = createInsertSchema(opponentHistory).omit({
  id: true
});

// Venue History - Venue-specific performance records
export const venueHistory = pgTable("venue_history", {
  id: serial("id").primaryKey(),
  playerId: integer("player_id").notNull(),
  venue: text("venue").notNull(),
  averageScore: real("average_score").notNull(),
  gamesPlayed: integer("games_played").notNull(),
  lastScore: integer("last_score"),
  last3Average: real("last_3_average"),
  lastRound: integer("last_round"),
});

export const insertVenueHistorySchema = createInsertSchema(venueHistory).omit({
  id: true
});

// Price History - Historical price tracking for price predictor
export const priceHistory = pgTable("price_history", {
  id: serial("id").primaryKey(),
  playerId: integer("player_id").notNull(),
  round: integer("round").notNull(),
  startPrice: integer("start_price").notNull(),
  endPrice: integer("end_price").notNull(),
  priceChange: integer("price_change").notNull(),
  breakEven: integer("break_even").notNull(),
  score: integer("score"),
  magicNumber: real("magic_number"),
});

export const insertPriceHistorySchema = createInsertSchema(priceHistory).omit({
  id: true
});

// System Parameters - For price predictor calculations
export const systemParameters = pgTable("system_parameters", {
  id: serial("id").primaryKey(),
  round: integer("round").notNull(),
  magicNumber: real("magic_number").notNull(),
  betaWeight: real("beta_weight").notNull().default(0.15),
  priceSensitivityFactor: real("price_sensitivity_factor").notNull().default(150),
  updatedAt: timestamp("updated_at").defaultNow(),
});

export const insertSystemParametersSchema = createInsertSchema(systemParameters).omit({
  id: true
});

// Fixtures - Upcoming game information for projections
export const fixtures = pgTable("fixtures", {
  id: serial("id").primaryKey(),
  round: integer("round").notNull(),
  homeTeam: text("home_team").notNull(),
  awayTeam: text("away_team").notNull(),
  venue: text("venue").notNull(),
  gameDate: timestamp("game_date"),
});

export const insertFixtureSchema = createInsertSchema(fixtures).omit({
  id: true
});

// Team Defense vs Position - Opponent strength data
export const teamDefenseVsPosition = pgTable("team_defense_vs_position", {
  id: serial("id").primaryKey(),
  team: text("team").notNull(),
  position: text("position").notNull(), // MID, FWD, DEF, RUCK
  averageAgainst: real("average_against").notNull(),
  pointsAllowed: integer("points_allowed").notNull(),
  gamesPlayed: integer("games_played").notNull(),
  rank: integer("rank"), // 1 = easiest, 18 = hardest
});

export const insertTeamDefenseVsPositionSchema = createInsertSchema(teamDefenseVsPosition).omit({
  id: true
});

export type InsertPlayerRoundScore = z.infer<typeof insertPlayerRoundScoreSchema>;
export type PlayerRoundScore = typeof playerRoundScores.$inferSelect;

export type InsertOpponentHistory = z.infer<typeof insertOpponentHistorySchema>;
export type OpponentHistory = typeof opponentHistory.$inferSelect;

export type InsertVenueHistory = z.infer<typeof insertVenueHistorySchema>;
export type VenueHistory = typeof venueHistory.$inferSelect;

export type InsertPriceHistory = z.infer<typeof insertPriceHistorySchema>;
export type PriceHistory = typeof priceHistory.$inferSelect;

export type InsertSystemParameters = z.infer<typeof insertSystemParametersSchema>;
export type SystemParameters = typeof systemParameters.$inferSelect;

export type InsertFixture = z.infer<typeof insertFixtureSchema>;
export type Fixture = typeof fixtures.$inferSelect;

export type InsertTeamDefenseVsPosition = z.infer<typeof insertTeamDefenseVsPositionSchema>;
export type TeamDefenseVsPosition = typeof teamDefenseVsPosition.$inferSelect;
