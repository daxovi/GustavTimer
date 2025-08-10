//
//  ServicesTests.swift
//  GustavTimerTests
//
//  Created by AI Assistant on 10.08.2024.
//

import XCTest
@testable import GustavTimer

final class ServicesTests: XCTestCase {
    
    func testMockAudioService() {
        let mockAudio = MockAudioService()
        
        XCTAssertEqual(mockAudio.intervalEndPlayCount, 0)
        XCTAssertEqual(mockAudio.cycleEndPlayCount, 0)
        
        mockAudio.playIntervalEnd()
        XCTAssertEqual(mockAudio.intervalEndPlayCount, 1)
        
        mockAudio.playCycleEnd()
        XCTAssertEqual(mockAudio.cycleEndPlayCount, 1)
        
        mockAudio.playIntervalEnd()
        mockAudio.playIntervalEnd()
        XCTAssertEqual(mockAudio.intervalEndPlayCount, 3)
    }
    
    func testMockHapticsService() {
        let mockHaptics = MockHapticsService()
        
        XCTAssertEqual(mockHaptics.intervalEndCount, 0)
        XCTAssertEqual(mockHaptics.cycleEndCount, 0)
        
        mockHaptics.intervalEnd()
        XCTAssertEqual(mockHaptics.intervalEndCount, 1)
        
        mockHaptics.cycleEnd()
        XCTAssertEqual(mockHaptics.cycleEndCount, 1)
        
        mockHaptics.intervalEnd()
        mockHaptics.intervalEnd()
        XCTAssertEqual(mockHaptics.intervalEndCount, 3)
    }
}