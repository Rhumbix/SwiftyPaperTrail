//
//  SyslogFormatterTests.swift
//  SwiftyPaperTrail
//
//  Created by Majd Murad on 12/1/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import XCTest

class SyslogFormatterTests: XCTestCase {
    
    func testFormatReturnsString() {
        let formattedString = SyslogFormatter.sharedInstance.formatLogMessage(message: "Testing Message")
        XCTAssert(type(of: formattedString) == String.self)
    }
    
    func testDefaultSyslogFormat() {
        let formattedString = SyslogFormatter.sharedInstance.formatLogMessage(message: "Testing Message")
        let pattern = "<14>\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2} .+ .+:.*"
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: formattedString, options: [], range: NSRange(location: 0, length: formattedString.characters.count))
        
        XCTAssertFalse(matches.isEmpty)
    }
    
    func testDifferentMachineName() {
        let customMachineName = "My-Custom-Machine-Name"
        SyslogFormatter.sharedInstance.machineName = customMachineName
        let formattedString = SyslogFormatter.sharedInstance.formatLogMessage(message: "Testing Machine Name Change")
        let pattern = "<14>\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2} \(customMachineName) .+:.*"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: formattedString, options: [], range: NSRange(location: 0, length: formattedString.characters.count))
        
        XCTAssertFalse(matches.isEmpty, "Machine name did not match in pattern")
    }
    
    func testDifferentProgramName() {
        let customProgramName = "My-Custom-Program-Name"
        SyslogFormatter.sharedInstance.programName = customProgramName
        let formattedString = SyslogFormatter.sharedInstance.formatLogMessage(message: "Testing Program Name Change")
        let pattern = "<14>\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2} .+ \(customProgramName):.*"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: formattedString, options: [], range: NSRange(location: 0, length: formattedString.characters.count))
        
        XCTAssertFalse(matches.isEmpty, "Program name did not match in pattern")
    }
    
}
