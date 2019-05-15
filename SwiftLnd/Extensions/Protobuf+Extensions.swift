//
//  Zap
//
//  Created by Otto Suess on 03.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

extension Lnrpc_Invoice {
    init(amount: Satoshi?, memo: String?) {
        self.init()
        if let memo = memo {
            self.memo = memo
        }
        if let amount = amount {
            value = amount.int64
        }
        `private` = true
    }
}

extension Lnrpc_NodeInfoRequest {
    init(pubKey: String) {
        self.init()

        self.pubKey = pubKey
    }
}

extension Lnrpc_PayReqString {
    init(payReq: String) {
        self.init()

        self.payReq = payReq
    }
}

extension Lnrpc_NewAddressRequest {
    init(type: OnChainRequestAddressType) {
        self.init()

        switch type {
        case .witnessPubkeyHash:
            self.type = .witnessPubkeyHash
        case .nestedPubkeyHash:
            self.type = .nestedPubkeyHash
        }
    }
}

extension Lnrpc_ConnectPeerRequest {
    init(pubKey: String, host: String) {
        self.init()

        addr = Lnrpc_LightningAddress()
        addr.pubkey = pubKey
        addr.host = host
    }
}

extension Lnrpc_OpenChannelRequest {
    init(pubKey: String, amount: Satoshi) {
        self.init()

        if let pubKey = Data(hexadecimalString: pubKey) {
            nodePubkey = pubKey
        }
        nodePubkeyString = pubKey
        localFundingAmount = amount.int64
        `private` = true
    }
}

extension Lnrpc_SendCoinsRequest {
    init(address: BitcoinAddress, amount: Satoshi) {
        self.init()

        self.addr = address.string
        self.amount = amount.int64
    }
}

extension Lnrpc_SendRequest {
    init(paymentRequest: String, amount: Satoshi?) {
        self.init()

        self.paymentRequest = paymentRequest
        if let amount = amount {
            self.amt = amount.int64
        }
    }
}

extension Lnrpc_CloseChannelRequest {
    init(channelPoint: ChannelPoint, force: Bool) {
        self.init()

        self.channelPoint = Lnrpc_ChannelPoint()
        self.channelPoint.outputIndex = UInt32(channelPoint.outputIndex)
        if let fundingTxidBytes = Data(hexadecimalString: channelPoint.fundingTxid.hexEndianSwap()) {
            self.channelPoint.fundingTxidBytes = fundingTxidBytes
        }
        self.force = force
    }
}

extension Lnrpc_QueryRoutesRequest {
    init(destination: String, amount: Satoshi) {
        self.init()

        pubKey = destination
        amt = amount.int64
        numRoutes = 10
    }
}

// MARK: - Wallet

extension Lnrpc_GenSeedRequest {
    init(passphrase: String?) {
        self.init()

        if let passphrase = passphrase?.data(using: .utf8) {
            self.aezeedPassphrase = passphrase
        }
    }
}

extension Lnrpc_InitWalletRequest {
    init(password: String, mnemonic: [String]) {
        self.init()

        if let passwordData = password.data(using: .utf8) {
            self.walletPassword = passwordData
        }
        self.cipherSeedMnemonic = mnemonic
    }
}

extension Lnrpc_UnlockWalletRequest {
    init(password: String) {
        self.init()

        if let passwordData = password.data(using: .utf8) {
            self.walletPassword = passwordData
        }
    }
}

extension Lnrpc_ListInvoiceRequest {
    init(reversed: Bool) {
        self.init()
        self.reversed = reversed
    }
}

extension Lnrpc_EstimateFeeRequest {
    init(address: BitcoinAddress, amount: Satoshi) {
        self.init()
        self.addrToAmount = [address.string: amount.int64]
    }
}
