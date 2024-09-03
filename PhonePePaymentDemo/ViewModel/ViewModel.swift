//
//  ViewModel.swift
//  PhonePePaymentDemo
//
//  Created by Rajan Arora on 30/08/24.
//

import UIKit
import PhonePePayment

class ViewModel {
    
    init() {}
    
    weak var callback: PhonePeSDKInstrumentHandler?
    weak private var viewController: ViewControllerProtocol?
    private var ppPayment: PPPayment?
    private var phonePeUserAccount: PhonePeUserAccount?
    
    func setViewController(controller: ViewControllerProtocol) {
        viewController = controller
    }
    
    func isPhonePeSDKInitalize() -> Bool {
        ppPayment != nil
    }
    
    func initPhonePeSDK(merchantId: String, enviroment: Environment) {
        ppPayment = PPPayment(environment: enviroment, flowId: UUID().uuidString, merchantId: merchantId)
        viewController?.printResult("SDK INIT - TRUE")
    }
    
    func getInstruments(token: String) {
        if phonePeUserAccount == nil {
            phonePeUserAccount = PhonePeUserAccount(appSchema: "PhonePePaymentDemo", delegate: self)
        }
        
        viewController?.resetInstruments()
        viewController?.startAnimating()
        phonePeUserAccount?.getUserInstruments(token: token)
    }
    
    func linkPhonePe() {
        if phonePeUserAccount == nil {
            phonePeUserAccount = PhonePeUserAccount(appSchema: "PhonePePaymentDemo", delegate: self)
        }
        
        viewController?.resetInstruments()
        viewController?.startAnimating()
        phonePeUserAccount?.link()
    }
    
    func pay(instrument: Instrument, merchantId: String, token: String, controller: UIViewController) {
        let request = B2BPGTransactionRequest(merchantId: merchantId, orderId: UUID().uuidString, token: token, appSchema: "PhonePePaymentDemo", paymentMode: .ppeIntent(request: PPEIntentPaymentMode(accountId: instrument.accountId ?? "")))
        
        ppPayment?.startTransaction(request: request, on: controller, completion: { _, state in
            self.viewController?.printResult("\(state)")
        })
    }
}

extension ViewModel: PhonePeUserAccountProvider {
    func onInstrumentsReady(instruments: [PhonePePayment.Instrument]?, failure: PhonePePayment.SavedInstrumentFailure?) {
        viewController?.stopAnimating()
        print("Instruments: \(String(describing: instruments)) and failure: \(String(describing: failure))")
        
        switch failure {
        case .noValidApp:
            callback?.getError(message: "No Valid App")
            return
        case .appReopened(let message):
            callback?.getError(message: message)
            return
        case .apiFailure(let message):
            callback?.getError(message: message)
            return
        default:
            break
        }
        
        guard let instruments = instruments, instruments.count > 0 else {
            callback?.getError(message: "Not get the instruments")
            return
        }
        
        callback?.getInstruments(instruments)
    }
    
    func showLinkButton() {
        viewController?.stopAnimating()
        viewController?.printResult("Show Link Button")
        callback?.showLinkButton()
    }
    
    func hideLinkButton(_ state: PhonePePayment.OptionState) {
        viewController?.stopAnimating()
        viewController?.printResult("hide link button: \(state.rawValue)")
        callback?.hideLinkButton()
    }
    
    func onConsentNotGiven() {
        viewController?.stopAnimating()
        viewController?.printResult("Consent not given")
        callback?.hideLinkButton()
    }
}
