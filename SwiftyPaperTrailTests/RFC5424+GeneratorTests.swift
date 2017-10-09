//
//  RFC5424+GeneratorTests.swift
//  SwiftyPaperTrail
//
//  Created by Mark Eschbach on 12/30/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import Foundation
import XCTest
import SwiftyPaperTrail

class RFC5424_Generator1 : XCTestCase {
    func test() {
        var packet = RFC5424Packet()
        packet.application = "Test"
        packet.priority = 6
        packet.host = "minecraft.invalid"
        packet.pid = "1423"
        packet.message = "Threw my sword again"

        var components = DateComponents()
        components.calendar = Calendar.current
        components.year = 2003
        components.month = 10
        components.day = 11
        components.hour = 22
        components.minute = 14
        components.second = 15
        components.nanosecond = 3 * 1000000
        components.timeZone = TimeZone(identifier: "PDT")
        packet.timestamp = components.date

        XCTAssertEqual(packet.asString, "82 <6>1 2003-10-12T05:14:15.003Z minecraft.invalid Test 1423 - - Threw my sword again")
    }
}
