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
    
    func testFormatOfMessage() {
        let formattedString = SyslogFormatter.sharedInstance.formatLogMessage(message: "Testing Message")
    }
    
}
