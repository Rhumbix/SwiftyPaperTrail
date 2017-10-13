//
//  TCPTransport.swift
//  SwiftyPaperTrail
//
//  Created by Mark Eschbach on 12/19/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import CocoaAsyncSocket

//Intend to comply with RFC6587
public class TCPTransport : NSObject, GCDAsyncSocketDelegate, LogWireTrasnport {
    private var tcpSocket:GCDAsyncSocket?
    private var host : String
    private var port : UInt16
    private var callbacks = TaggedCallbacks()
    public var disconnectionListener : ( (TCPTransport) -> Void )?

    public var queue : DispatchQueue { get { return defaultDispatchQueue } }

    public init( to aHost : String, at aPort : UInt16 ){
        host = aHost
        port = aPort
        super.init()
        queue.async {
            self.connectTCPSocket()
        }
    }

    // Encryption for TCP
    var useTLS:Bool = false

    public func sendData( data : Data, callback : (() -> Void)? ) {
        if tcpSocket == nil { connectTCPSocket() }

        //Add frame delimiter
        var frame = Data()
        frame.append(data)
        frame.append(10)

        //Dispatch the frame
        let tag = callbacks.registerCallback(optionalCallback: callback)
        tcpSocket!.write(frame, withTimeout: -1, tag: tag)
    }

    private func connectTCPSocket() {
        do {
            tcpSocket = GCDAsyncSocket(delegate: self, delegateQueue: defaultDispatchQueue, socketQueue: queue)
            try tcpSocket!.connect(toHost: host, onPort: UInt16(port))
        } catch let error {
            fatalError("Error connecting to host: \(host). Error: \(error.localizedDescription)")
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
        tcpSocket = nil
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
