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
        pt.useTLS = false
        pt.logMessage(message: "Testing TCP without TLS")
        pt.disconnect()
    }
    
    func testSendsViaTCPwithTLS(){
        print("Testing TCP with TLS")
        SwiftyPaperTrail.sharedInstance.host = "logs2.papertrailapp.com"
        SwiftyPaperTrail.sharedInstance.port = 29065
        SwiftyPaperTrail.sharedInstance.useTLS = true
        SwiftyPaperTrail.sharedInstance.logMessage(message: "Testing TCP with TLS")
        SwiftyPaperTrail.sharedInstance.disconnect()
    }
    
    func testSendsViaUDP() {
        SwiftyPaperTrail.sharedInstance.host = "logs2.papertrailapp.com"
        SwiftyPaperTrail.sharedInstance.port = 29065
        SwiftyPaperTrail.sharedInstance.useTCP = false
        SwiftyPaperTrail.sharedInstance.logMessage(message: "Testing UDP.")
        SwiftyPaperTrail.sharedInstance.disconnect()
    }
    
    
    
}
