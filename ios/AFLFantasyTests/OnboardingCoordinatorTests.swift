//
//  OnboardingCoordinatorTests.swift
//  AFLFantasyTests
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import XCTest
@testable import AFLFantasy

@MainActor
final class OnboardingCoordinatorTests: XCTestCase {
    
    var coordinator: OnboardingCoordinator!
    
    override func setUp() {
        super.setUp()
        coordinator = OnboardingCoordinator()
    }
    
    override func tearDown() {
        coordinator = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertEqual(coordinator.currentStep, .splash)
        XCTAssertTrue(coordinator.userName.isEmpty)
        XCTAssertNil(coordinator.favoriteTeam)
        XCTAssertTrue(coordinator.teamId.isEmpty)
        XCTAssertTrue(coordinator.sessionCookie.isEmpty)
        XCTAssertFalse(coordinator.isValidating)
        XCTAssertNil(coordinator.validationError)
        XCTAssertFalse(coordinator.isCompleted)
        XCTAssertTrue(coordinator.hasExistingTeam) // Default should be true
        XCTAssertFalse(coordinator.showValidationAlert)
    }
    
    // MARK: - Progress Calculation Tests
    
    func testProgressCalculation() {
        coordinator.currentStep = .splash
        XCTAssertEqual(coordinator.progress, 0.0)
        
        coordinator.currentStep = .welcome
        XCTAssertEqual(coordinator.progress, 1.0/6.0, accuracy: 0.001)
        
        coordinator.currentStep = .teamChoice
        XCTAssertEqual(coordinator.progress, 2.0/6.0, accuracy: 0.001)
        
        coordinator.currentStep = .credentials
        XCTAssertEqual(coordinator.progress, 4.0/6.0, accuracy: 0.001)
        
        coordinator.currentStep = .complete
        XCTAssertEqual(coordinator.progress, 1.0)
    }
    
    // MARK: - Linear Navigation Tests
    
    func testBasicNextStepFlow() {
        // Test splash → welcome
        coordinator.currentStep = .splash
        coordinator.nextStep()
        XCTAssertEqual(coordinator.currentStep, .welcome)
        
        // Test welcome → teamChoice
        coordinator.nextStep()
        XCTAssertEqual(coordinator.currentStep, .teamChoice)
    }
    
    func testBasicPreviousStepFlow() {
        coordinator.currentStep = .teamChoice
        coordinator.previousStep()
        XCTAssertEqual(coordinator.currentStep, .welcome)
        
        coordinator.previousStep()
        XCTAssertEqual(coordinator.currentStep, .splash)
    }
    
    // MARK: - Team Choice Branch Tests
    
    func testTeamChoiceBranchingWithExistingTeam() {
        coordinator.currentStep = .teamChoice
        coordinator.hasExistingTeam = true
        
        coordinator.nextStep()
        XCTAssertEqual(coordinator.currentStep, .personalInfo)
    }
    
    func testTeamChoiceBranchingWithNewTeam() {
        coordinator.currentStep = .teamChoice
        coordinator.hasExistingTeam = false
        
        coordinator.nextStep()
        XCTAssertEqual(coordinator.currentStep, .createTeamGuide)
    }
    
    func testSelectHasExistingTeam() {
        coordinator.currentStep = .teamChoice
        
        coordinator.selectHasExistingTeam()
        
        XCTAssertTrue(coordinator.hasExistingTeam)
        XCTAssertEqual(coordinator.currentStep, .personalInfo)
    }
    
    func testSelectNeedsToCreateTeam() {
        coordinator.currentStep = .teamChoice
        
        coordinator.selectNeedsToCreateTeam()
        
        XCTAssertFalse(coordinator.hasExistingTeam)
        XCTAssertEqual(coordinator.currentStep, .createTeamGuide)
    }
    
    // MARK: - Create Team Guide Flow Tests
    
    func testCreateTeamGuideToPersonalInfo() {
        coordinator.currentStep = .createTeamGuide
        
        coordinator.nextStep()
        XCTAssertEqual(coordinator.currentStep, .personalInfo)
    }
    
    func testReturnFromCreateGuide() {
        coordinator.currentStep = .createTeamGuide
        
        coordinator.returnFromCreateGuide()
        XCTAssertEqual(coordinator.currentStep, .personalInfo)
    }
    
    func testCreateTeamGuidePreviousStep() {
        coordinator.currentStep = .createTeamGuide
        
        coordinator.previousStep()
        XCTAssertEqual(coordinator.currentStep, .teamChoice)
    }
    
    // MARK: - Complete Flow Tests
    
    func testCompleteFlowExistingTeam() {
        // Simulate user with existing team
        coordinator.currentStep = .splash
        
        // splash → welcome
        coordinator.nextStep()
        XCTAssertEqual(coordinator.currentStep, .welcome)
        
        // welcome → teamChoice
        coordinator.nextStep()
        XCTAssertEqual(coordinator.currentStep, .teamChoice)
        
        // teamChoice → personalInfo (existing team)
        coordinator.selectHasExistingTeam()
        XCTAssertEqual(coordinator.currentStep, .personalInfo)
        
        // personalInfo → credentials
        coordinator.nextStep()
        XCTAssertEqual(coordinator.currentStep, .credentials)
        
        // credentials → validation (would trigger validation)
        // We'll test this separately to avoid network calls
    }
    
    func testCompleteFlowNewTeam() {
        // Simulate user creating new team
        coordinator.currentStep = .splash
        
        // splash → welcome → teamChoice
        coordinator.nextStep()
        coordinator.nextStep()
        
        // teamChoice → createTeamGuide (new team)
        coordinator.selectNeedsToCreateTeam()
        XCTAssertEqual(coordinator.currentStep, .createTeamGuide)
        
        // createTeamGuide → personalInfo
        coordinator.nextStep()
        XCTAssertEqual(coordinator.currentStep, .personalInfo)
        
        // personalInfo → credentials
        coordinator.nextStep()
        XCTAssertEqual(coordinator.currentStep, .credentials)
    }
    
    // MARK: - Validation State Tests
    
    func testValidationWithEmptyCredentials() {
        coordinator.currentStep = .credentials
        coordinator.teamId = ""
        coordinator.sessionCookie = ""
        
        // This should trigger validation error without network call
        coordinator.nextStep()
        
        XCTAssertEqual(coordinator.currentStep, .validation)
        XCTAssertNotNil(coordinator.validationError)
        if case .emptyFields = coordinator.validationError {
            // Expected
        } else {
            XCTFail("Expected emptyFields error")
        }
        XCTAssertTrue(coordinator.showValidationAlert)
    }
    
    func testValidationWithValidCredentials() {
        coordinator.currentStep = .credentials
        coordinator.teamId = "123456"
        coordinator.sessionCookie = "valid-session-cookie-string-here"
        
        // Move to validation step (actual validation would happen async)
        coordinator.nextStep()
        
        XCTAssertEqual(coordinator.currentStep, .validation)
        XCTAssertTrue(coordinator.isValidating)
    }
    
    func testRetryCountTracking() {
        coordinator.retryValidation()
        XCTAssertFalse(coordinator.shouldShowSupportOption())
        
        coordinator.retryValidation()
        coordinator.retryValidation()
        XCTAssertTrue(coordinator.shouldShowSupportOption()) // After 3 retries
    }
    
    // MARK: - Data Validation Tests
    
    func testUserDataPersistence() {
        coordinator.userName = "Test User"
        coordinator.favoriteTeam = .richmond
        coordinator.teamId = "123456"
        coordinator.sessionCookie = "test-cookie"
        
        XCTAssertEqual(coordinator.userName, "Test User")
        XCTAssertEqual(coordinator.favoriteTeam, .richmond)
        XCTAssertEqual(coordinator.teamId, "123456")
        XCTAssertEqual(coordinator.sessionCookie, "test-cookie")
    }
    
    // MARK: - Error State Tests
    
    func testOnboardingErrorTypes() {
        let networkError = OnboardingError.networkError("Test network error")
        XCTAssertEqual(networkError.errorDescription, "Network Error: Test network error")
        XCTAssertTrue(networkError.canRetry)
        
        let emptyFieldsError = OnboardingError.emptyFields
        XCTAssertEqual(emptyFieldsError.errorDescription, "Please fill in both your Team ID and Session Cookie.")
        XCTAssertFalse(emptyFieldsError.canRetry)
        
        let serverError = OnboardingError.serverError(500)
        XCTAssertEqual(serverError.errorDescription, "Server error (500). Please try again later.")
        XCTAssertTrue(serverError.canRetry)
        
        let timeoutError = OnboardingError.timeout
        XCTAssertEqual(timeoutError.errorDescription, "Request timed out. Please check your internet connection and try again.")
        XCTAssertTrue(timeoutError.canRetry)
    }
    
    func testErrorRecoveryMessages() {
        let networkError = OnboardingError.networkError("Connection failed")
        XCTAssertEqual(networkError.recoveryMessage, "Check your internet connection and try again.")
        
        let credentialsError = OnboardingError.invalidCredentials("Invalid team ID")
        XCTAssertEqual(credentialsError.recoveryMessage, "Double-check your credentials in the AFL Fantasy app or website.")
    }
    
    // MARK: - Step Number Validation Tests
    
    func testStepNumberConsistency() {
        let allSteps = OnboardingCoordinator.OnboardingStep.allCases
        
        // Verify all steps have valid step numbers
        for step in allSteps {
            XCTAssertTrue(step.stepNumber >= 0)
            XCTAssertTrue(step.stepNumber <= step.totalSteps)
        }
        
        // Verify createTeamGuide has same progress as personalInfo
        XCTAssertEqual(OnboardingCoordinator.OnboardingStep.createTeamGuide.stepNumber,
                      OnboardingCoordinator.OnboardingStep.personalInfo.stepNumber)
    }
    
    // MARK: - Edge Cases Tests
    
    func testPreviousStepFromSplash() {
        coordinator.currentStep = .splash
        coordinator.previousStep()
        
        // Should remain at splash
        XCTAssertEqual(coordinator.currentStep, .splash)
    }
    
    func testPreviousStepFromComplete() {
        coordinator.currentStep = .complete
        coordinator.previousStep()
        
        // Should remain at complete (no previous step defined)
        XCTAssertEqual(coordinator.currentStep, .complete)
    }
    
    func testValidationStepBackNavigation() {
        coordinator.currentStep = .validation
        coordinator.previousStep()
        
        XCTAssertEqual(coordinator.currentStep, .credentials)
    }
    
    // MARK: - AFL Team Tests
    
    func testAFLTeamEmojis() {
        XCTAssertEqual(AFLTeam.richmond.emoji, "🐅")
        XCTAssertEqual(AFLTeam.collingwood.emoji, "⚫")
        XCTAssertEqual(AFLTeam.melbourne.emoji, "🔴")
    }
    
    func testAFLTeamColors() {
        XCTAssertEqual(AFLTeam.richmond.colors, [.yellow, .black])
        XCTAssertEqual(AFLTeam.carlton.colors, [.blue, .white])
        XCTAssertTrue(AFLTeam.adelaide.colors.contains(.red))
    }
    
    func testAllAFLTeamsHaveEmojiAndColors() {
        for team in AFLTeam.allCases {
            XCTAssertFalse(team.emoji.isEmpty, "Team \(team.rawValue) missing emoji")
            XCTAssertFalse(team.colors.isEmpty, "Team \(team.rawValue) missing colors")
        }
    }
}

// MARK: - Integration Tests

@MainActor
final class OnboardingIntegrationTests: XCTestCase {
    
    var coordinator: OnboardingCoordinator!
    
    override func setUp() {
        super.setUp()
        coordinator = OnboardingCoordinator()
    }
    
    override func tearDown() {
        coordinator = nil
        super.tearDown()
    }
    
    func testCompleteOnboardingFlowExistingUser() {
        // Test complete flow for user with existing team
        
        // Start at splash
        XCTAssertEqual(coordinator.currentStep, .splash)
        
        // Navigate through initial steps
        coordinator.nextStep() // splash → welcome
        coordinator.nextStep() // welcome → teamChoice
        
        // User has existing team
        coordinator.selectHasExistingTeam()
        XCTAssertEqual(coordinator.currentStep, .personalInfo)
        XCTAssertTrue(coordinator.hasExistingTeam)
        
        // Fill in personal info
        coordinator.userName = "Test User"
        coordinator.favoriteTeam = .richmond
        coordinator.nextStep() // personalInfo → credentials
        
        // Fill in credentials
        coordinator.teamId = "123456"
        coordinator.sessionCookie = "valid-session-cookie"
        
        // Move to validation (would trigger async validation in real app)
        coordinator.nextStep() // credentials → validation
        XCTAssertEqual(coordinator.currentStep, .validation)
        XCTAssertTrue(coordinator.isValidating)
    }
    
    func testCompleteOnboardingFlowNewUser() {
        // Test complete flow for user creating new team
        
        // Navigate to team choice
        coordinator.nextStep() // splash → welcome  
        coordinator.nextStep() // welcome → teamChoice
        
        // User needs to create team
        coordinator.selectNeedsToCreateTeam()
        XCTAssertEqual(coordinator.currentStep, .createTeamGuide)
        XCTAssertFalse(coordinator.hasExistingTeam)
        
        // User completes team creation guide
        coordinator.returnFromCreateGuide()
        XCTAssertEqual(coordinator.currentStep, .personalInfo)
        
        // Continue with personal info
        coordinator.userName = "New User"
        coordinator.favoriteTeam = .melbourne
        coordinator.nextStep() // personalInfo → credentials
        
        // Fill credentials after creating team
        coordinator.teamId = "789012"
        coordinator.sessionCookie = "new-session-cookie"
        
        coordinator.nextStep() // credentials → validation
        XCTAssertEqual(coordinator.currentStep, .validation)
    }
    
    func testBackNavigationThroughFlow() {
        // Test that user can navigate backwards through the flow
        
        // Go forward to credentials
        coordinator.nextStep() // splash → welcome
        coordinator.nextStep() // welcome → teamChoice
        coordinator.selectHasExistingTeam() // teamChoice → personalInfo
        coordinator.nextStep() // personalInfo → credentials
        
        XCTAssertEqual(coordinator.currentStep, .credentials)
        
        // Navigate backwards
        coordinator.previousStep() // credentials → personalInfo
        XCTAssertEqual(coordinator.currentStep, .personalInfo)
        
        coordinator.previousStep() // personalInfo → teamChoice
        XCTAssertEqual(coordinator.currentStep, .teamChoice)
        
        coordinator.previousStep() // teamChoice → welcome
        XCTAssertEqual(coordinator.currentStep, .welcome)
        
        coordinator.previousStep() // welcome → splash
        XCTAssertEqual(coordinator.currentStep, .splash)
    }
    
    func testProgressThroughoutFlow() {
        // Test that progress calculation is correct throughout flow
        
        coordinator.currentStep = .splash
        XCTAssertEqual(coordinator.progress, 0.0)
        
        coordinator.nextStep() // welcome
        XCTAssertEqual(coordinator.progress, 1.0/6.0, accuracy: 0.001)
        
        coordinator.nextStep() // teamChoice
        XCTAssertEqual(coordinator.progress, 2.0/6.0, accuracy: 0.001)
        
        coordinator.selectHasExistingTeam() // personalInfo
        XCTAssertEqual(coordinator.progress, 3.0/6.0, accuracy: 0.001)
        
        coordinator.nextStep() // credentials
        XCTAssertEqual(coordinator.progress, 4.0/6.0, accuracy: 0.001)
        
        coordinator.teamId = "123456"
        coordinator.sessionCookie = "test-cookie"
        coordinator.nextStep() // validation
        XCTAssertEqual(coordinator.progress, 5.0/6.0, accuracy: 0.001)
        
        coordinator.nextStep() // complete
        XCTAssertEqual(coordinator.progress, 1.0)
    }
}
