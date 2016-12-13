//
//  TaggCallbacksTests.swift
//  SwiftyPaperTrail
//
//  Created by Mark Eschbach on 12/12/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import XCTest
@testable import SwiftyPaperTrail

class TaggedCallbacksTests : XCTestCase {
    func testCallable(){
        var called = false
        //Given
        let table = TaggedCallbacks()
        let tag = table.registerCallback {
            called = true
        }
        //When
        let cb = table.maybeCall(tag: tag)
        XCTAssertNotNil(cb)
        cb?()
        //Then
        XCTAssertTrue(called, "Not called back")
    }

    func testDoesntRegisterNil(){
        //Given
        let table = TaggedCallbacks()
        //When
        let tag = table.registerCallback(optionalCallback: nil)
        let cb = table.maybeCall(tag: tag)
        //When
        XCTAssertNil(cb)
    }

    func testCompletedInvokesAndRemoves(){
        var called = false
        //Given
        let table = TaggedCallbacks()
        let tag = table.registerCallback {
            called = true
        }
        //When
        table.completed(tag: tag)
        //Then
        XCTAssertTrue(called, "Not called back")
    }

    func testIgnoresUnkonwnTags(){
        //Given
        let table = TaggedCallbacks()
        //When
        let cb = table.maybeCall(tag: 2016)
        //When
        XCTAssertNil(cb)
    }
}
