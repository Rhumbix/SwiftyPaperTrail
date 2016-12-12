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

//NOTE: This was put together very quickly
class BufferingService : NSObject, GCDAsyncSocketDelegate {
    var serviceSocket : GCDAsyncSocket!
    var buffers = [BufferingClient]()

    var disconnectionSignal : (( Data ) -> Void)?

    func awaitData() -> UInt16 {
        serviceSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.init(label: "com.rhumbix.test"), socketQueue:DispatchQueue.init(label: "com.rhumbix.test.socket") )
        try! serviceSocket.accept(onPort: 0)
        return serviceSocket.localPort
    }

    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        print("New client")
        let target = Data()
        let client = BufferingClient(clientSocket: newSocket, target: target)
        buffers.append(client)
    }
}

class BufferingClient : NSObject, GCDAsyncSocketDelegate {
    var socket : GCDAsyncSocket
    var buffer : Data

    init( clientSocket : GCDAsyncSocket, target : Data ){
        socket = clientSocket
        buffer = target
        super.init()
        socket.delegate = self
        socket.readData(withTimeout: -1, tag: 0)
    }

    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        buffer.append(data)
        sock.readData(withTimeout: -1, tag: 0)
    }

    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("Socket closed: \(err)")
    }
}

class SwiftyPaperTrailTests: XCTestCase {

    func getCurrentMillis()->Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }

    func testDoesntLogWithoutConfiguration() {

    }
    
    func testDoesntLogWithInvalidFormat(){
        
    }
    
    func testSendsViaTCPwithoutTLS(){
        print("Testing TCP without TLS")
        let buffer = BufferingService()
        let port = buffer.awaitData()

        let pt = SwiftyPaperTrail()
        pt.host = "localhost"
        pt.port = Int(port)
        pt.useTCP = true
        pt.useTLS = false

        let sendSync = expectation(description: "Sending data")
        pt.logMessage(message: "Testing TCP without TLS", callBack: {
            sendSync.fulfill()
        })

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
                return
            }

            let sent = String(data: buffer.buffers[0].buffer, encoding: .utf8)
            print("Data: \(sent)")
            XCTAssertTrue(sent!.hasSuffix("Testing TCP without TLS"))
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
