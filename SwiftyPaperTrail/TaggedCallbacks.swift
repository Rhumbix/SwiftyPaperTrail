//
//  TaggedCallbacks.swift
//  SwiftyPaperTrail
//
//  Created by Mark Eschbach on 12/12/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//


/**
 Encapsulates the logic for managing a tagged callback API suitable for use with
 an Objective-C API.
 */
class TaggedCallbacks {
    typealias Callback = () -> ()
    private var callbackDict = [Int:Callback]()

    private func generateCallbackKey() -> Int{
        var key:Int = Int(exactly: arc4random())!
        while callbackDict[key] != nil {
            key = Int(exactly: arc4random())!
        }
        return key
    }

    func registerCallback( optionalCallback : Callback? ) -> Int {
        if let callback = optionalCallback {
            let tag = generateCallbackKey()
            callbackDict[tag] = callback
            return tag
        } else {
            return 0
        }
    }

    func maybeCall( tag aTag : Int ) -> Callback? {
        guard aTag != 0 else { return nil }
        return callbackDict[aTag]
    }


    func completed( tag aTag : Int ) {
        guard aTag != 0 else { return }
        if let cb = callbackDict[aTag] {
            cb()
        }
        callbackDict.removeValue(forKey: aTag )
    }
}
