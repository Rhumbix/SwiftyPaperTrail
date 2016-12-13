//
//  LogWireTrasnport.swift
//  SwiftyPaperTrail
//
//  Created by Mark Eschbach on 12/13/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import CocoaAsyncSocket

protocol LogWireTrasnport {
    func sendData( data : Data, callback : (() -> Void)?)
    func disconnect()
}

class TCPTransport : NSObject, GCDAsyncSocketDelegate, LogWireTrasnport {
    private var tcpSocket:GCDAsyncSocket?
    var host : String
    var port : UInt16
    var callbacks = TaggedCallbacks()
    var disconnectionListener : ( (TCPTransport) -> Void )?

    init( to aHost : String, at aPort : UInt16 ){
        host = aHost
        port = aPort
    }

    // Encryption for TCP
    var useTLS:Bool = false

    func sendData( data : Data, callback : (() -> Void)? ) {
        if tcpSocket == nil {
            let queue = DispatchQueue(label: "com.rhumbix.swiftpapertrail")
            tcpSocket = GCDAsyncSocket(delegate: self, delegateQueue: queue, socketQueue: queue)
            connectTCPSocket()
        }
        let tag = callbacks.registerCallback(optionalCallback: callback)
        tcpSocket!.write(data, withTimeout: -1, tag: tag)
    }

    private func connectTCPSocket() {
        do {
            print("Connecting TCP")
            try tcpSocket!.connect(toHost: host, onPort: UInt16(port))
        } catch let error {
            print("Error connecting to host: \(host). Error: \(error.localizedDescription)")
            return
        }

        if useTLS {
            print("Using TLS")
            tcpSocket!.startTLS(nil)
        }

    }

    func disconnect() {
        tcpSocket!.disconnectAfterReadingAndWriting()
        tcpSocket = nil
    }

    //Delegate methods
    @objc func socketDidSecure(_ sock: GCDAsyncSocket) {
        print("Socket Secured")
    }

    @objc func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("Connected to \(host):\(port)")
    }

    @objc func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("Socket Disconnected. Error: \(err)")
        disconnectionListener?(self)
    }

    func socket(_ sock: GCDAsyncSocket, didWritePartialDataOfLength partialLength: UInt, tag: Int) {
        print("Partial write")
    }

    @objc func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        callbacks.completed(tag: tag)
    }
}

class UDPTransport : NSObject, GCDAsyncUdpSocketDelegate, LogWireTrasnport  {
    private var udpSocket:GCDAsyncUdpSocket?
    var host:String?
    var port:Int?
    var callbacks = TaggedCallbacks()


    func disconnect() {
        udpSocket!.close()
        udpSocket = nil
    }

    func sendData( data : Data, callback : (() -> Void)? ) {
        if udpSocket == nil {
            udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        }
        let tag = callbacks.registerCallback(optionalCallback: callback)
        udpSocket!.send(data, toHost: host!, port: UInt16(port!), withTimeout: -1, tag: tag)
    }

    /*
     GCDAsyncUdpSocketDelegate Methods
     */
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        callbacks.completed(tag: tag)
    }
}
