//
//  SwiftyLoggerTests.swift
//  SwiftyPaperTrail
//
//  Created by Mark Eschbach on 12/13/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import XCTest
import Foundation
import SwiftyLogger
import SwiftyPaperTrail

class SwiftyLoggerTests : XCTestCase {
    func testSimpleWrite(){
        let buffer = BufferingTransport()
        var loggerFactory = DefaultLoggerFactory()
        loggerFactory.addTarget(SwiftyPaperTrail(wireLayer: buffer))
        let logger = loggerFactory.makeLogger()

        let logMessage = "Let the world stand still at least for me"
        logger.logInfo(logMessage)


        let change = expectation(description: "Log line will be recorded")
        func check(){
            if buffer.writes.count > 0 {
                change.fulfill()
            } else {
                DispatchQueue.main.async(execute: check)
            }
        }
        check()

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
                return
            }
            let message = String(data: buffer.writes[0], encoding: .utf8)!
            let packet = RFC5424Packet.parse(packet: message)
            XCTAssertNotNil(packet.application)
            
            let packetMessage = packet.message
            XCTAssertEqual(packetMessage, packet.application! + ": " + logMessage)
        }
    }
}
