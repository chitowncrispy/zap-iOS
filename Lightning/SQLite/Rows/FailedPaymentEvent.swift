//
//  Lightning
//
//  Created by Otto Suess on 11.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import SQLite
import SwiftLnd

/// Gets created when a payment request fails to complete.
public struct FailedPaymentEvent: Equatable, DateProvidingEvent, AmountProvidingEvent {
    public let paymentHash: String
    public let memo: String?
    public let amount: Satoshi
    public let destination: String
    public let date: Date
    public let expiry: Date
    public let fallbackAddress: BitcoinAddress?
    public let paymentRequest: String
}

extension FailedPaymentEvent {
    init(paymentRequest: PaymentRequest, amount: Satoshi) {
        paymentHash = paymentRequest.paymentHash
        memo = paymentRequest.memo
        self.amount = amount
        destination = paymentRequest.destination
        date = paymentRequest.date
        expiry = paymentRequest.expiryDate
        fallbackAddress = paymentRequest.fallbackAddress
        self.paymentRequest = paymentRequest.raw
    }
}

// MARK: - Persistance
extension FailedPaymentEvent {
    private enum Column {
        static let paymentHash = Expression<String>("paymentHash")
        static let memo = Expression<String?>("memo")
        static let amount = Expression<Satoshi>("amount")
        static let destination = Expression<String>("destination")
        static let date = Expression<Date>("date")
        static let expiry = Expression<Date>("expiry")
        static let fallbackAddress = Expression<String?>("fallbackAddress")
        static let paymentRequest = Expression<String>("paymentRequest")
    }
    
    private static let table = Table("failedPaymentEvent")

    init(row: Row) {
        paymentHash = row[Column.paymentHash]
        memo = row[Column.memo]
        amount = row[Column.amount]
        destination = row[Column.destination]
        date = row[Column.date]
        expiry = row[Column.expiry]
        
        if let addressString = row[Column.fallbackAddress] {
            fallbackAddress = BitcoinAddress(string: addressString)
        } else {
            fallbackAddress = nil
        }
        
        paymentRequest = row[Column.paymentRequest]
    }
    
    static func createTable(database: Connection) throws {
        try database.run(table.create(ifNotExists: true) { t in
            t.column(Column.paymentHash, primaryKey: true)
            t.column(Column.memo)
            t.column(Column.amount)
            t.column(Column.destination)
            t.column(Column.date)
            t.column(Column.expiry)
            t.column(Column.fallbackAddress)
            t.column(Column.paymentRequest)
        })
    }
    
    func insert() throws {
        try SQLiteDataStore.shared.database.run(FailedPaymentEvent.table.insert(
            Column.paymentHash <- paymentHash,
            Column.memo <- memo,
            Column.amount <- amount,
            Column.destination <- destination,
            Column.date <- date,
            Column.expiry <- expiry,
            Column.fallbackAddress <- fallbackAddress?.string,
            Column.paymentRequest <- paymentRequest)
        )
    }
    
    public static func events() throws -> [FailedPaymentEvent] {
        return try SQLiteDataStore.shared.database.prepare(FailedPaymentEvent.table)
            .map(FailedPaymentEvent.init)
    }
}
