//
//  RFC3339Tests.swift
//  SwiftyPaperTrail
//
//  Created by Mark Eschbach on 12/27/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import Foundation
import XCTest

internal func assertWithinMillisecond( actual : Date!, expected : Date!, file: StaticString = #file, line: UInt = #line){
    let calendar = Calendar.current
    let diff = calendar.dateComponents([.year,.month,.day,.hour,.minute,.second,.nanosecond], from: actual, to: expected)

    let msDiff = diff.nanosecond! / 1000000
    if msDiff > 1 {
        XCTFail("Times didn't match, off by \(msDiff)ms", file: file, line: line)
    } else {
        XCTAssertEqual(diff.year, 0, "Years differ by \(diff.year)", file: file, line: line)
        XCTAssertEqual(diff.month, 0, file: file, line: line)
        XCTAssertEqual(diff.day, 0, file: file, line: line)
        XCTAssertEqual(diff.hour, 0, "Hours differ by \(diff.hour)", file: file, line: line)
        XCTAssertEqual(diff.minute, 0, file: file, line: line)
        XCTAssertEqual(diff.second, 0, file: file, line: line)
    }
}

class RFC3339Tests : XCTestCase {
    func testFullDate(){
        var components = DateComponents()
        components.calendar = Calendar.current
        components.year = 2003
        components.month = 10
        components.day = 11
        components.hour = 22
        components.minute = 14
        components.second = 15
        components.nanosecond = (3 * 1000000) //NOTE: There is a discrpency of 15ns here, don't know why
        components.timeZone = TimeZone(identifier: "GMT")
        let expected = components.date

        let parser = DateFormatter.RFC3339_output()
        let when = parser.date(from: "2003-10-11T22:14:15.003Z")

        assertWithinMillisecond( actual: when!, expected: expected! )
    }
}
