//
//  TCPTLSIntegrationTests.swift
//  SwiftyPaperTrail
//
//  Created by Mark Eschbach on 12/27/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import XCTest
import SwiftyLogger
import SwiftyPaperTrail

class TCPIntegrationTests : XCTestCase {
    func testSimpleIntegration(){
        let transport = SwiftyPaperTrail.withTLSoverTCP(to: "logs2.papertrailapp.com", at: 29065)
        let loggerFactory = DefaultLoggerFactory()
        loggerFactory.minimumLogLevel = .debug
        loggerFactory.addTarget(transport)
        let logger = loggerFactory.makeLogger()
        logger.logCritical("Sing the blues")
        transport.disconnect()
    }
}
