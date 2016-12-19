//
//  TCPTransport.swift
//  SwiftyPaperTrail
//
//  Created by Mark Eschbach on 12/19/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import CocoaAsyncSocket

public class TCPTransport : NSObject, GCDAsyncSocketDelegate, LogWireTrasnport {
    private var tcpSocket:GCDAsyncSocket?
    private var host : String
    private var port : UInt16
    private var callbacks = TaggedCallbacks()
    public var disconnectionListener : ( (TCPTransport) -> Void )?

    public var queue : DispatchQueue { get { return defaultDispatchQueue } }

    init( to aHost : String, at aPort : UInt16 ){
        host = aHost
        port = aPort
    }

    // Encryption for TCP
    var useTLS:Bool = false

    public func sendData( data : Data, callback : (() -> Void)? ) {
        if tcpSocket == nil {
            tcpSocket = GCDAsyncSocket(delegate: self, delegateQueue: defaultDispatchQueue, socketQueue: queue)
            connectTCPSocket()
        }
        let tag = callbacks.registerCallback(optionalCallback: callback)
        tcpSocket!.write(data, withTimeout: -1, tag: tag)
    }

    private func connectTCPSocket() {
        do {
            try tcpSocket!.connect(toHost: host, onPort: UInt16(port))
        } catch let error {
            //TODO: Add handler mechanism for this
            print("Error connecting to host: \(host). Error: \(error.localizedDescription)")
            return
        }

        if useTLS {
            tcpSocket!.startTLS(nil)
        }

    }

    public func disconnect() {
        tcpSocket!.disconnectAfterReadingAndWriting()
        tcpSocket = nil
    }

    //Delegate methods
    @objc public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        disconnectionListener?(self)
    }

    @objc public func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        callbacks.completed(tag: tag)
    }
}

extension SwiftyPaperTrail {
    public class func withTCP( to aHost : String, at aPort : UInt16 ) -> SwiftyPaperTrail {
        let tcpLayer = TCPTransport(to: aHost, at: aPort )
        let logger = SwiftyPaperTrail.init(wireLayer: tcpLayer)
        return logger
    }

    public class func withTLSoverTCP( to aHost : String, at aPort : UInt16 ) -> SwiftyPaperTrail {
        let tcpLayer = TCPTransport(to: aHost, at: aPort )
        tcpLayer.useTLS = true
        let logger = SwiftyPaperTrail.init(wireLayer: tcpLayer)
        return logger
    }
}
