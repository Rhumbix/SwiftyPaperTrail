//
//  RFC3164Tests.swift
//  SwiftyPaperTrail
//
//  Created by Mark Eschbach on 12/27/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import Foundation
import XCTest
import SwiftyPaperTrail

class RFC3164_Simple_ParsingTests : XCTestCase {
    func test_simplest_priority_22(){
        let example = "<22>sendername: the log message"
        let message = RFC3164Packet.parse(packet: example)

        XCTAssertEqual(message.priority, 22)
    }

    func test_simplest_priority_1(){
        let example = "<1>sendername: the log message"
        let message = RFC3164Packet.parse(packet: example)

        XCTAssertEqual(message.priority, 1)
    }

    func test_simplest_sender(){
        let example = "<22>sendername: the log message"
        let message = RFC3164Packet.parse(packet: example)

        XCTAssertEqual(message.sender, "sendername")
    }

    func test_simplest_message(){
        let example = "<22>sendername: the log message"
        let message = RFC3164Packet.parse(packet: example)

        XCTAssertEqual(message.message, "the log message")
    }

    func test_bad_withoutStartBracket(){
        let example = "22>sendername: the log message"
        let result = RFC3164Packet.parse(packet: example)
        XCTAssertEqual(result.priority, 13)
        XCTAssertEqual(result.message, example)
    }

    func test_bad_withoutEndingBracket(){
        let example = "<22sendername: the log message"
        let result = RFC3164Packet.parse(packet: example)
        XCTAssertEqual(result.priority, 13)
        XCTAssertEqual(result.message, example)
    }

    func test_bad_withoutSender(){
        let example = "<22>sendername the log message"
        let result = RFC3164Packet.parse(packet: example)
        XCTAssertEqual(result.priority, 13)
        XCTAssertEqual(result.message, example)
    }
}

class RFC3164_withDate_ParsingTests : XCTestCase {
    func test_priority() {
        let example = "<22>Apr 25 23:45:56 sendername programname: the log message"
        let result = RFC3164Packet.parse(packet: example)
        XCTAssertEqual(result.priority, 22)
    }
}

class RFC3164_Priority_Cases : XCTestCase {
    func test_kernel_emergency() {
        var message = RFC3164Packet()
        message.priority = 0

        XCTAssertEqual(message.facility, 0)
        XCTAssertEqual(message.severity, 0)
    }

    func test_local4_notice() {
        var message = RFC3164Packet()
        message.facility = 20
        message.severity = 5

        XCTAssertEqual(message.priority, 165)
    }
}
