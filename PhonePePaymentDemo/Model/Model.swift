//
//  Model.swift
//  PhonePePaymentDemo
//
//  Created by Rajan Arora on 02/09/24.
//

import PhonePePayment

protocol PhonePeSDKInstrumentHandler: AnyObject {
    func showLinkButton()
    func hideLinkButton()
    func getInstruments(_ instruments: [Instrument])
    func getError(message: String?)
}
