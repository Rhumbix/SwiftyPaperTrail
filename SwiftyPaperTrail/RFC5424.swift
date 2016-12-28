//
//  RFC5424.swift
//  SwiftyPaperTrail
//
//  Created by Mark Eschbach on 12/27/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import Foundation

extension DateFormatter {
    public class func RFC3339() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }
}

extension Scanner {
    func nextWord() -> String? {
        var value : NSString?
        guard self.scanUpTo(" ", into: &value), !self.isAtEnd else { return nil }
        return value as? String
    }

    func scanDate_RFC3339() -> Date? {
        guard let word = nextWord() else { return nil }

        let format = DateFormatter.RFC3339()
        let result = format.date(from: word)
        return result
    }
}

public struct RFC5424Packet {
    public var version : Int = 1
    public var priority : UInt8 {
        get { return (facility << 3) + severity }
        set {
            facility = newValue >> 3
            severity = newValue & 7
        }
    }

    public var facility : UInt8 = 1 {
        didSet {
            if facility > 23 {
                fatalError("Facility may not be than 23")
            }
        }
    }

    public var severity : UInt8 = 5 {
        didSet {
            if severity > 7 {
                fatalError("Severity may not exced 7")
            }
        }
    }

    public var timestamp : Date?
    public var host : String?
    public var application : String?
    public var pid : String?
    public var messageID : String?
    public var structured : String?
    public var message : String?

    public init() {}

    public static func parse( packet frame : String ) -> RFC5424Packet {
        func defaultPacket() -> RFC5424Packet {
            let packet = RFC5424Packet()
            return packet
        }

        let scanner = Scanner(string: frame)


        guard scanner.verifyConstant(character: "<") else { return defaultPacket() }
        guard let priority = scanner.scanInt(), priority < 192 else { return defaultPacket() }
        guard scanner.verifyConstant(character: ">") else { return defaultPacket() }
        guard let version = scanner.scanInt() else { return defaultPacket() }

        guard let when = scanner.scanDate_RFC3339() else { return defaultPacket() }
        guard let hostName = scanner.nextWord() else { return defaultPacket() }
        guard let app = scanner.nextWord() else { return defaultPacket() }
        guard let pidWord = scanner.nextWord() else { return defaultPacket() }
        guard let messageWord = scanner.nextWord() else { return defaultPacket() }
        guard let structWord = scanner.nextWord() else { return defaultPacket() }

        var packet = RFC5424Packet()
        packet.version = version
        packet.priority = UInt8(priority)
        packet.timestamp = when
        packet.host = hostName == "-" ? nil : hostName
        packet.application = app == "-" ? nil : app
        packet.pid = pidWord == "-" ? nil : pidWord
        packet.messageID = messageWord == "-" ? nil : messageWord
        packet.structured = structWord == "-" ? nil : structWord
        packet.message = scanner.remainder()
        return packet
    }
}
