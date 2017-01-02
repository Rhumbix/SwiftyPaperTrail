//
//  SyslogFormatterTests.swift
//  SwiftyPaperTrail
//
//  Created by Majd Murad on 12/1/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import XCTest
import SwiftyLogger
import SwiftyPaperTrail

class SyslogFormatterTests: XCTestCase {
    func testDefaultSyslogFormat() {
        var message = LogMessage()
        message.message = "Testing Message"

        let formattedString = SyslogFormatter.sharedInstance.format(message: message)
        let packet = RFC5424Packet.parse(packet: formattedString)
        XCTAssertEqual(packet.message, "iOS: Testing Message")
    }
    
    func testDifferentMachineName() {
        var message = LogMessage()
        message.message = "Testing Machine Name Change"

        let customMachineName = "my-custom-machine-name"
        SyslogFormatter.sharedInstance.machineName = customMachineName

        let formattedString = SyslogFormatter.sharedInstance.format(message: message)
        let packet = RFC5424Packet.parse(packet: formattedString)
        XCTAssertEqual(packet.host, "my-custom-machine-name")
    }
    
    func testDifferentProgramName() {
        var message = LogMessage()
        message.message = "Testing Program Name Change"

        let customProgramName = "My-Custom-Program-Name"
        SyslogFormatter.sharedInstance.programName = customProgramName
        let formattedString = SyslogFormatter.sharedInstance.format(message: message)

        let packet = RFC5424Packet.parse(packet: formattedString)
        XCTAssertEqual(packet.application, customProgramName)
    }
    
}
