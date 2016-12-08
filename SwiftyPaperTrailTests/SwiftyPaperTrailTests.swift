//
//  SwiftyPaperTrailTests.swift
//  SwiftyPaperTrailTests
//
//  Created by Majd Murad on 11/30/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import XCTest
@testable import SwiftyPaperTrail

class SwiftyPaperTrailTests: XCTestCase {
    
    func testDoesntLogWithoutConfiguration() {

    }
    
    func testDoesntLogWithInvalidFormat(){
        
    }
    
    func testSendsViaTCPwithoutTLS(){
        print("Testing TCP without TLS")
        let pt = SwiftyPaperTrail()
        pt.host = "logs2.papertrailapp.com"
        pt.port = 29065
        pt.useTCP = true
        pt.useTLS = false
        
        let tcpSent = expectation(description: "TCP without TLS data sent")
        pt.logMessage(message: "Testing TCP without TLS", callBack: {
            print("MADE IT HERE")
        })
        sleep(4)
        tcpSent.fulfill()

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
                pt.disconnect()
            }
        }
    }
    
    func testSendsViaTCPwithTLS(){
        print("Testing TCP with TLS")
        let pt = SwiftyPaperTrail()
        pt.host = "logs2.papertrailapp.com"
        pt.port = 29065
        pt.useTCP = true
        pt.useTLS = true
        
        let tcpSent = expectation(description: "TCP with TLS data sent")
        pt.logMessage(message: "Testing TCP with TLS", callBack: {
            tcpSent.fulfill()
        })
        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
        
    }
    
    func testSendsViaUDP() {
        let pt = SwiftyPaperTrail()
        pt.host = "logs2.papertrailapp.com"
        pt.port = 29065
        pt.useTCP = false
        
        let udpSent = expectation(description: "UDP data sent")
        pt.logMessage(message: "Testing UDP", callBack: {
            udpSent.fulfill()
        })
        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    
    
}
