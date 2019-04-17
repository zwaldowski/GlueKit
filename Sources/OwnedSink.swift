//
//  StrongMethodSink.swift
//  GlueKit
//
//  Created by Károly Lőrentey on 2016-10-24.
//  Copyright © 2015–2017 Károly Lőrentey.
//

protocol UniqueOwnedSink: SinkType {
    associatedtype Owner: AnyObject

    var owner: Owner { get }
}

extension UniqueOwnedSink {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(owner))
    }

    static func ==(left: Self, right: Self) -> Bool {
        return left.owner === right.owner
    }
}

protocol OwnedSink: SinkType {
    associatedtype Owner: AnyObject
    associatedtype Identifier: Hashable

    var owner: Owner { get }
    var identifier: Identifier { get }
}

extension OwnedSink {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(owner))
        hasher.combine(identifier)
    }

    static func ==(left: Self, right: Self) -> Bool {
        return left.owner === right.owner && left.identifier == right.identifier
    }
}
