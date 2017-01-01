//
//  SyslogFormatterTests.swift
//  SwiftyPaperTrail
//
//  Created by Majd Murad on 12/1/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import XCTest
import SwiftyPaperTrail

class SyslogFormatterTests: XCTestCase {
    
    func testFormatReturnsString() {
        let formattedString = SyslogFormatter.sharedInstance.formatLogMessage(message: "Testing Message")
        XCTAssert(type(of: formattedString) == String.self)
    }
    
    func testDefaultSyslogFormat() {
        let formattedString = SyslogFormatter.sharedInstance.formatLogMessage(message: "Testing Message")
        let packet = RFC5424Packet.parse(packet: formattedString)
        XCTAssertEqual(packet.message, "Testing Message")
    }
    
    func testDifferentMachineName() {
        let customMachineName = "my-custom-machine-name"
        SyslogFormatter.sharedInstance.machineName = customMachineName
        let formattedString = SyslogFormatter.sharedInstance.formatLogMessage(message: "Testing Machine Name Change")
        let packet = RFC5424Packet.parse(packet: formattedString)
        XCTAssertEqual(packet.host, "my-custom-machine-name")
    }
    
    func testDifferentProgramName() {
        let customProgramName = "My-Custom-Program-Name"
        SyslogFormatter.sharedInstance.programName = customProgramName
        let formattedString = SyslogFormatter.sharedInstance.formatLogMessage(message: "Testing Program Name Change")
        let packet = RFC5424Packet.parse(packet: formattedString)
        XCTAssertEqual(packet.application, customProgramName)
    }
    
}
