//
//  RFC5424.swift
//  SwiftyPaperTrail
//
//  Created by Mark Eschbach on 12/27/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import Foundation

//As defined in RFC3164 and RFC5424
public enum SyslogFacilities : UInt8 {
    case kernel = 0
    case user = 1
    case mail = 2
    case system = 3
    case security1 = 4
    case syslogd = 5
    case line = 6
    case network = 7
    case uucp = 8
    case clock1 = 9
    case security2 = 10
    case ftp = 11
    case ntp = 12
    case audit = 13
    case alert = 14
    case clock2 = 15
    case local0 = 16
    case local1 = 17
    case local2 = 18
    case local3 = 19
    case local4 = 20
    case local5 = 21
    case local6 = 22
    case local7 = 23
}

public enum SyslogPriorities : UInt8 {
    case emergency = 0
    case alert = 1
    case critical = 2
    case error = 3
    case warning = 4
    case notice = 5
    case information = 6
    case debug = 7
}

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
        get { return (facility << 3) | severity }
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

    public init() {
        version = 1
    }

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

        guard let messageIDWord = scanner.nextWord() else { return defaultPacket() }

        var structuredData : String?
        if scanner.verifyConstant(character: "[") {
            structuredData = scanner.scanUp(to: "]")
        }else {
            guard scanner.verifyConstant(character: "-") else {
                return defaultPacket()
            }
        }

        var packet = RFC5424Packet()
        packet.version = version
        packet.priority = UInt8(priority)
        packet.timestamp = when
        packet.host = hostName == "-" ? nil : hostName
        packet.application = app == "-" ? nil : app
        packet.pid = pidWord == "-" ? nil : pidWord
        packet.messageID = messageIDWord == "-" ? nil : messageIDWord
        packet.structured = structuredData
        packet.message = scanner.remainder()
        return packet
    }

    private func formatWord( maybeValue : String? ) -> String {
        if let value = maybeValue {
            return value
        } else {
            return "-"
        }
    }

    private func formatDate() -> String {
        guard let knownWhen = self.timestamp else {
            return "-"
        }
        let formatter = DateFormatter.RFC3339()
        formatter.timeZone = TimeZone(identifier: "GMT")
        return formatter.string(from: knownWhen)
    }

    public var asString : String {  get {
        let date = formatDate()
        let host = formatWord(maybeValue: self.host)
        let application = formatWord(maybeValue: self.application)
        let pidWord = formatWord(maybeValue: self.pid)
        let messageIDWord = formatWord(maybeValue: self.messageID)
        let data = formatWord(maybeValue: self.structured)
        let msg = formatWord(maybeValue: self.message)

        return "<\(priority)>\(version) \(date) \(host) \(application) \(pidWord) \(messageIDWord) \(data) \(msg)"
    } }
}
