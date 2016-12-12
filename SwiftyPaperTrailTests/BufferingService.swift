//
//  BufferingService.swift
//  SwiftyPaperTrail
//
//  Created by Mark Eschbach on 12/12/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import CocoaAsyncSocket

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
