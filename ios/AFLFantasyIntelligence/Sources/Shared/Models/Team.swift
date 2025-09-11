import Foundation

// MARK: - Team

public enum Team: String, Codable, CaseIterable, Sendable {
    case adelaide = "ADE"
    case brisbane = "BRI"
    case carlton = "CAR"
    case collingwood = "COL"
    case essendon = "ESS"
    case fremantle = "FRE"
    case geelong = "GEE"
    case goldCoast = "GCS"
    case greatWesternSydney = "GWS"
    case hawthorn = "HAW"
    case melbourne = "MEL"
    case northMelbourne = "NOR"
    case portAdelaide = "POR"
    case richmond = "RIC"
    case stKilda = "STK"
    case sydney = "SYD"
    case westCoast = "WCE"
    case westernBulldogs = "WBD"
    
    public var displayName: String {
        switch self {
        case .adelaide: return "Adelaide Crows"
        case .brisbane: return "Brisbane Lions"
        case .carlton: return "Carlton Blues"
        case .collingwood: return "Collingwood Magpies"
        case .essendon: return "Essendon Bombers"
        case .fremantle: return "Fremantle Dockers"
        case .geelong: return "Geelong Cats"
        case .goldCoast: return "Gold Coast Suns"
        case .greatWesternSydney: return "Greater Western Sydney Giants"
        case .hawthorn: return "Hawthorn Hawks"
        case .melbourne: return "Melbourne Demons"
        case .northMelbourne: return "North Melbourne Kangaroos"
        case .portAdelaide: return "Port Adelaide Power"
        case .richmond: return "Richmond Tigers"
        case .stKilda: return "St Kilda Saints"
        case .sydney: return "Sydney Swans"
        case .westCoast: return "West Coast Eagles"
        case .westernBulldogs: return "Western Bulldogs"
        }
    }
}
