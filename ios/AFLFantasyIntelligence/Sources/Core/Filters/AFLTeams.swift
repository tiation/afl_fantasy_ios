import Foundation

// MARK: - AFL Teams

struct AFLTeam {
    static let allTeams: [String] = [
        "ADE", // Adelaide Crows
        "BRL", // Brisbane Lions
        "CAR", // Carlton Blues
        "COL", // Collingwood Magpies
        "ESS", // Essendon Bombers
        "FRE", // Fremantle Dockers
        "GEE", // Geelong Cats
        "GCS", // Gold Coast Suns
        "GWS", // Greater Western Sydney Giants
        "HAW", // Hawthorn Hawks
        "MEL", // Melbourne Demons
        "NM",  // North Melbourne Kangaroos
        "POR", // Port Adelaide Power
        "RIC", // Richmond Tigers
        "STK", // St Kilda Saints
        "SYD", // Sydney Swans
        "WC",  // West Coast Eagles
        "WB"   // Western Bulldogs
    ]
    
    static let teamNames: [String: String] = [
        "ADE": "Adelaide Crows",
        "BRL": "Brisbane Lions",
        "CAR": "Carlton Blues",
        "COL": "Collingwood Magpies",
        "ESS": "Essendon Bombers",
        "FRE": "Fremantle Dockers",
        "GEE": "Geelong Cats",
        "GCS": "Gold Coast Suns",
        "GWS": "Greater Western Sydney Giants",
        "HAW": "Hawthorn Hawks",
        "MEL": "Melbourne Demons",
        "NM": "North Melbourne Kangaroos",
        "POR": "Port Adelaide Power",
        "RIC": "Richmond Tigers",
        "STK": "St Kilda Saints",
        "SYD": "Sydney Swans",
        "WC": "West Coast Eagles",
        "WB": "Western Bulldogs"
    ]
    
    static func fullName(for code: String) -> String {
        return teamNames[code] ?? code
    }
}
