//
//  RFC5424Tests.swift
//  SwiftyPaperTrail
//
//  Created by Mark Eschbach on 12/27/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import Foundation
import XCTest
import SwiftyPaperTrail

class RFC5424_Example1 : XCTestCase {
    var packet : RFC5424Packet!

    override func setUp() {
        let example = "<34>1 2003-10-11T22:14:15.003Z mymachine.example.com su - ID47 - 'su root' failed for lonvick on /dev/pts/8"
        packet = RFC5424Packet.parse( packet: example )
    }

    func test_priority(){ XCTAssertEqual( packet.priority, 34 ) }
    func test_version(){ XCTAssertEqual( packet.version, 1) }
    func test_date(){
        var components = DateComponents()
        components.calendar = Calendar.current
        components.year = 2003
        components.month = 10
        components.day = 11
        components.hour = 22
        components.minute = 14
        components.second = 15
        components.nanosecond = 3 * 1000000
        components.timeZone = TimeZone(identifier: "UTC")

        let when = components.date
        assertWithinMillisecond( actual: packet.timestamp, expected: when )
    }

    func test_host(){ XCTAssertEqual( packet.host, "mymachine.example.com") }
    func test_application(){ XCTAssertEqual( packet.application, "su") }
    func test_pid(){ XCTAssertNil( packet.pid ) }
    func test_message_id(){ XCTAssertEqual( packet.messageID, "ID47" ) }
    func test_structrued_data(){ XCTAssertNil( packet.structured ) }
    func test_message(){
        XCTAssertEqual(packet.message, "'su root' failed for lonvick on /dev/pts/8")
    }
}
