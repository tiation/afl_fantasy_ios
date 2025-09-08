/// Position represents the valid player positions in AFL Fantasy.
/// This is the single source of truth for position data in the app.
public enum Position: String, Codable, CaseIterable, Hashable {
    case defender = "DEF"
    case midfielder = "MID"
    case ruck = "RUC"
    case forward = "FWD"

    /// Returns a formatted display name for the position.
    public var displayName: String {
        switch self {
        case .defender: "Defender"
        case .midfielder: "Midfielder"
        case .ruck: "Ruck"
        case .forward: "Forward"
        }
    }

    /// Returns the abbreviated form, matching AFL API format.
    public var abbreviation: String { rawValue }
}
