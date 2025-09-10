-- Sample AFL Fantasy Players for testing
-- This script populates the players table with realistic sample data

INSERT INTO players (name, position, team, price, average_score, break_even, last_score, projected_score, rounds_played, ownership_percentage) VALUES
('Max Gawn', 'RUC', 'Melbourne', 800000, 105.2, 78, 112, 105, 22, 45.8),
('Clayton Oliver', 'MID', 'Melbourne', 750000, 115.8, 82, 128, 116, 23, 52.3),
('Christian Petracca', 'MID', 'Melbourne', 720000, 110.4, 85, 94, 110, 20, 41.2),
('Marcus Bontempelli', 'MID', 'Western Bulldogs', 700000, 108.7, 89, 115, 109, 22, 48.7),
('Touk Miller', 'MID', 'Gold Coast', 650000, 102.3, 76, 98, 102, 23, 38.9),
('Lachie Neale', 'MID', 'Brisbane', 680000, 112.1, 88, 105, 112, 21, 44.6),
('Sam Walsh', 'MID', 'Carlton', 620000, 98.5, 72, 86, 99, 23, 35.2),
('Tim Taranto', 'MID', 'Richmond', 580000, 95.2, 65, 102, 95, 22, 28.4),
('Rory Laird', 'DEF', 'Adelaide', 600000, 92.8, 68, 88, 93, 23, 42.1),
('Jake Lloyd', 'DEF', 'Sydney', 590000, 89.4, 71, 95, 89, 22, 38.7),
('Jeremy McGovern', 'DEF', 'West Coast', 550000, 85.6, 63, 78, 86, 20, 25.3),
('Jordan Dawson', 'DEF', 'Adelaide', 570000, 88.9, 69, 92, 89, 22, 34.8),
('Nick Daicos', 'DEF', 'Collingwood', 650000, 95.7, 78, 103, 96, 23, 46.2),
('Tom Stewart', 'DEF', 'Geelong', 620000, 91.3, 75, 87, 91, 21, 41.5),
('Charlie Curnow', 'FWD', 'Carlton', 750000, 98.5, 92, 85, 99, 18, 39.8),
('Jeremy Cameron', 'FWD', 'Geelong', 700000, 89.7, 86, 94, 90, 22, 35.7),
('Tom Hawkins', 'FWD', 'Geelong', 600000, 82.4, 71, 76, 82, 20, 28.9),
('Taylor Walker', 'FWD', 'Adelaide', 580000, 78.9, 68, 82, 79, 21, 24.6),
('Isaac Heeney', 'FWD', 'Sydney', 650000, 85.3, 79, 91, 85, 22, 33.4),
('Toby Greene', 'FWD', 'GWS', 620000, 88.1, 74, 89, 88, 19, 31.2),
-- Add some rookies/value picks
('George Wardlaw', 'MID', 'North Melbourne', 350000, 45.2, 32, 52, 45, 15, 8.7),
('Mattaes Phillipou', 'MID', 'St Kilda', 380000, 52.8, 38, 48, 53, 18, 12.3),
('Cam Mackenzie', 'FWD', 'Hawthorn', 320000, 38.5, 28, 42, 39, 12, 6.2),
('Jye Amiss', 'FWD', 'Fremantle', 410000, 58.3, 42, 61, 58, 16, 15.8),
('Sam Darcy', 'FWD', 'Western Bulldogs', 450000, 62.7, 48, 68, 63, 19, 18.9),
-- Add more mid-price players
('Tom Green', 'MID', 'GWS', 520000, 89.4, 58, 96, 89, 23, 22.4),
('Jack Steele', 'MID', 'St Kilda', 480000, 85.7, 52, 79, 86, 20, 19.8),
('Zach Merrett', 'MID', 'Essendon', 560000, 94.2, 62, 88, 94, 22, 26.7),
('Darcy Parish', 'MID', 'Essendon', 540000, 91.8, 59, 102, 92, 23, 24.1),
('Jack Macrae', 'MID', 'Western Bulldogs', 500000, 87.3, 54, 83, 87, 21, 21.5);
