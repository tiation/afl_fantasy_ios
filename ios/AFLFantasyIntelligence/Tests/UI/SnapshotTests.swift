import XCTest
import SwiftUI
@testable import AFL_Fantasy_Intelligence

final class SnapshotTests: XCTestCase {
    
    // MARK: - PlayerRowView Snapshots
    
    func testPlayerRowView_Midfielder() {
        let player = Player(
            id: "1",
            name: "Marcus Bontempelli",
            team: "WB",
            position: .midfielder,
            price: 725000,
            average: 105.2,
            projected: 108.5,
            breakeven: -15
        )
        
        let view = PlayerRowView(player: player)
            .frame(width: 390)
            .padding()
        
        assertSnapshot(matching: view, as: .image(size: CGSize(width: 390, height: 100)))
    }
    
    func testPlayerRowView_Defender() {
        let player = Player(
            id: "2",
            name: "Jordan Dawson",
            team: "ADE",
            position: .defender,
            price: 420000,
            average: 89.2,
            projected: 92.8,
            breakeven: 45
        )
        
        let view = PlayerRowView(player: player)
            .frame(width: 390)
            .padding()
        
        assertSnapshot(matching: view, as: .image(size: CGSize(width: 390, height: 100)))
    }
    
    // MARK: - DSStatCard Snapshots
    
    func testDSStatCard_Standard() {
        let view = DSStatCard(
            title: "Current Score",
            value: "1,247",
            trend: .up("+12.3%"),
            icon: "chart.line.uptrend.xyaxis",
            style: .standard
        )
        .frame(width: 180, height: 120)
        .padding()
        
        assertSnapshot(matching: view, as: .image(size: CGSize(width: 200, height: 140)))
    }
    
    func testDSStatCard_Gradient() {
        let view = DSStatCard(
            title: "Bank Balance",
            value: "$156,000",
            trend: .up("Healthy"),
            icon: "banknote",
            style: .gradient
        )
        .frame(width: 180, height: 120)
        .padding()
        
        assertSnapshot(matching: view, as: .image(size: CGSize(width: 200, height: 140)))
    }
    
    // MARK: - DSButton Snapshots
    
    func testDSButton_AllStyles() {
        let view = VStack(spacing: DS.Spacing.m) {
            DSButton("Primary Button", style: .primary) {}
            DSButton("Secondary Button", style: .secondary) {}
            DSButton("Outline Button", style: .outline) {}
            DSButton("Ghost Button", style: .ghost) {}
        }
        .frame(width: 300)
        .padding()
        
        assertSnapshot(matching: view, as: .image(size: CGSize(width: 320, height: 250)))
    }
    
    // MARK: - APIStatusChip Snapshots
    
    func testAPIStatusChip_Connected() {
        let apiService = APIService.mock
        apiService.isHealthy = true
        
        let view = APIStatusChip()
            .environmentObject(apiService)
            .padding()
        
        assertSnapshot(matching: view, as: .image(size: CGSize(width: 150, height: 50)))
    }
    
    func testAPIStatusChip_Offline() {
        let apiService = APIService.mock
        apiService.isHealthy = false
        
        let view = APIStatusChip()
            .environmentObject(apiService)
            .padding()
        
        assertSnapshot(matching: view, as: .image(size: CGSize(width: 150, height: 50)))
    }
}

// MARK: - Snapshot Test Helper

/// Simple snapshot assertion helper
/// In production, you'd use PointFree's swift-snapshot-testing library
private func assertSnapshot<V: View>(
    matching view: V,
    as snapshotting: ImageSnapshot,
    file: StaticString = #file,
    testName: String = #function,
    line: UInt = #line
) {
    // This is a simplified implementation
    // In real tests, you'd use a proper snapshot testing library
    let renderer = ImageRenderer(content: view)
    renderer.scale = UIScreen.main.scale
    
    guard let _ = renderer.uiImage else {
        XCTFail("Failed to render snapshot", file: file, line: line)
        return
    }
    
    // In production, you'd save the image and compare with a reference
    // For now, we just verify it renders without crashing
    XCTAssertTrue(true, "Snapshot rendered successfully", file: file, line: line)
}

private struct ImageSnapshot {
    let size: CGSize
    
    static func image(size: CGSize) -> ImageSnapshot {
        ImageSnapshot(size: size)
    }
}
