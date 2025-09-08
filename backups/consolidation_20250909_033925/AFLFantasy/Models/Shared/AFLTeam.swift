import SwiftUI

// MARK: - AFLTeam

/// Represents AFL teams with their codes, full names, and branding colors.
/// This is the single source of truth for team data in the app.
public enum AFLTeam: String, Codable, CaseIterable, Hashable {
    case adelaide = "ADE"
    case brisbane = "BRL"
    case carlton = "CAR"
    case collingwood = "COL"
    case essendon = "ESS"
    case fremantle = "FRE"
    case geelong = "GEE"
    case goldCoast = "GCS"
    case greaterWesternSydney = "GWS"
    case hawthorn = "HAW"
    case melbourne = "MEL"
    case northMelbourne = "NTH"
    case portAdelaide = "POR"
    case richmond = "RIC"
    case stKilda = "STK"
    case sydney = "SYD"
    case westCoast = "WCE"
    case westernBulldogs = "WBD"

    /// Returns the full name of the team.
    public var fullName: String {
        switch self {
        case .adelaide: "Adelaide Crows"
        case .brisbane: "Brisbane Lions"
        case .carlton: "Carlton Blues"
        case .collingwood: "Collingwood Magpies"
        case .essendon: "Essendon Bombers"
        case .fremantle: "Fremantle Dockers"
        case .geelong: "Geelong Cats"
        case .goldCoast: "Gold Coast Suns"
        case .greaterWesternSydney: "GWS Giants"
        case .hawthorn: "Hawthorn Hawks"
        case .melbourne: "Melbourne Demons"
        case .northMelbourne: "North Melbourne Kangaroos"
        case .portAdelaide: "Port Adelaide Power"
        case .richmond: "Richmond Tigers"
        case .stKilda: "St Kilda Saints"
        case .sydney: "Sydney Swans"
        case .westCoast: "West Coast Eagles"
        case .westernBulldogs: "Western Bulldogs"
        }
    }

    /// Returns the team's nickname without the city/location.
    public var nickname: String {
        switch self {
        case .adelaide: "Crows"
        case .brisbane: "Lions"
        case .carlton: "Blues"
        case .collingwood: "Magpies"
        case .essendon: "Bombers"
        case .fremantle: "Dockers"
        case .geelong: "Cats"
        case .goldCoast: "Suns"
        case .greaterWesternSydney: "Giants"
        case .hawthorn: "Hawks"
        case .melbourne: "Demons"
        case .northMelbourne: "Kangaroos"
        case .portAdelaide: "Power"
        case .richmond: "Tigers"
        case .stKilda: "Saints"
        case .sydney: "Swans"
        case .westCoast: "Eagles"
        case .westernBulldogs: "Bulldogs"
        }
    }

    /// Returns the team's primary color.
    public var primaryColor: Color {
        switch self {
        case .adelaide: .red
        case .brisbane: Color(red: 0.78, green: 0.27, blue: 0.18) // Lions maroon
        case .carlton: .blue
        case .collingwood: .black
        case .essendon: .red
        case .fremantle: .purple
        case .geelong: .blue
        case .goldCoast: .red
        case .greaterWesternSydney: .orange
        case .hawthorn: Color(red: 0.47, green: 0.27, blue: 0.07) // Hawks brown
        case .melbourne: .red
        case .northMelbourne: .blue
        case .portAdelaide: Color(red: 0.0, green: 0.27, blue: 0.53) // Power navy
        case .richmond: .yellow
        case .stKilda: .red
        case .sydney: .red
        case .westCoast: .blue
        case .westernBulldogs: .red
        }
    }

    /// Returns the team's secondary color.
    public var secondaryColor: Color {
        switch self {
        case .adelaide: .yellow
        case .brisbane: .yellow
        case .carlton: .white
        case .collingwood: .white
        case .essendon: .black
        case .fremantle: .white
        case .geelong: .white
        case .goldCoast: .yellow
        case .greaterWesternSydney: .charcoal
        case .hawthorn: .yellow
        case .melbourne: .navy
        case .northMelbourne: .white
        case .portAdelaide: .teal
        case .richmond: .black
        case .stKilda: .black
        case .sydney: .white
        case .westCoast: .yellow
        case .westernBulldogs: .white
        }
    }
}

// MARK: - Color Extension

private extension Color {
    static let navy = Color(red: 0.0, green: 0.12, blue: 0.35)
    static let charcoal = Color(red: 0.2, green: 0.2, blue: 0.2)
    static let teal = Color(red: 0.0, green: 0.6, blue: 0.6)
}
