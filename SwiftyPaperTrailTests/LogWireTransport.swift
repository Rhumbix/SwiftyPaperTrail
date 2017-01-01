//
//  SwiftyPaperTrailTests.swift
//  SwiftyPaperTrailTests
//
//  Created by Majd Murad on 11/30/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import XCTest
import CocoaAsyncSocket
import Foundation
@testable import SwiftyPaperTrail

class SwiftyPaperTrailTests: XCTestCase {
    func testSendsViaTCPwithoutTLS(){
        let buffer = BufferingService()
        let port = buffer.awaitData()

        let pt = SwiftyPaperTrail(wireLayer: TCPTransport(to: "localhost", at: port))
        let sendSync = expectation(description: "Sending data")
        pt.logMessage(message: "Testing TCP without TLS", callBack: {
            sendSync.fulfill()
        })

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
                return
            }

            let sent = String(data: buffer.buffers[0].buffer, encoding: .utf8)
            XCTAssertTrue(sent!.hasSuffix("Testing TCP without TLS\n"))
        }
    }
}

class PendingTests {
    func testSendsViaTCPwithTLS(){
//        let buffer = BufferingService()
//        let port = buffer.awaitData()
//
//        print("Testing TCP with TLS")
//        let pt = SwiftyPaperTrail()
//        let tcpSent = expectation(description: "TCP with TLS data sent")
//        pt.logMessage(message: "Testing TCP with TLS", callBack: {
//            tcpSent.fulfill()
//        })
//        waitForExpectations(timeout: 5) { error in
//            if let error = error {
//                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
//            }
//        }
    }

    func testSendsViaUDP() {
//        let pt = SwiftyPaperTrail()
//        let udpSent = expectation(description: "UDP data sent")
//        pt.logMessage(message: "Testing UDP", callBack: {
//            udpSent.fulfill()
//        })
//        waitForExpectations(timeout: 5) { error in
//            if let error = error {
//                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
//            }
//        }
    }
}
