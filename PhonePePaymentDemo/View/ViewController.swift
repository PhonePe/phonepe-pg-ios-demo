//
//  ViewController.swift
//  PhonePePaymentDemo
//
//  Created by Rajan Arora on 30/08/24.
//

import UIKit
import PhonePePayment

protocol ViewControllerProtocol: AnyObject {
    func startAnimating()
    func stopAnimating()
    func printResult(_ message: String)
    func resetInstruments()
}

class ViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var linkBtn: UIButton!
    @IBOutlet weak var orderTokenTxtfield: UITextField!
    @IBOutlet weak var sdkTokenTxtfield: UITextField!
    @IBOutlet weak var merchantTxtfield: UITextField!
    @IBOutlet weak var resultLbl: UILabel!
    @IBOutlet weak var serverSegment: UISegmentedControl!
    
    let viewModel = ViewModel()
    var instruments: [Instrument] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    var selectedInstrument: Instrument?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.callback = self
        setupViews()
    }
    
    func setupViews() {
        viewModel.setViewController(controller: self)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: Actions
    @IBAction func initSDK(_ sender: Any) {
        
        guard let text = merchantTxtfield.text, !text.isEmpty else {
            printResult("Enter Merchant Id First")
            return
        }
        
        let enviroment: Environment = serverSegment.selectedSegmentIndex == 0 ? .sandbox: .production
        
        viewModel.initPhonePeSDK(merchantId: text, enviroment: enviroment)
    }
    
    @IBAction func getInstruments(_ sender: Any) {
        
        guard let token = sdkTokenTxtfield.text, !token.isEmpty else {
            printResult("Enter SDK token first")
            return
        }
        
        guard viewModel.isPhonePeSDKInitalize() else {
            printResult("Initalise SDK first")
            return
        }
        
        viewModel.getInstruments(token: token)
    }
    
    @IBAction func linkPhonePe(_ sender: Any) {
        viewModel.linkPhonePe()
    }
    
    @IBAction func pay(_ sender: Any) {
        
        if selectedInstrument == nil {
            printResult("Select the instrument from the Get Instruments call")
            return
        }
        
        guard let token = orderTokenTxtfield.text, !token.isEmpty else {
            printResult("Enter Order token first")
            return
        }
        
        guard viewModel.isPhonePeSDKInitalize() else {
            printResult("Initalise SDK first")
            return
        }
        
        let merchantId = merchantTxtfield.text ?? ""
        viewModel.pay(instrument: selectedInstrument!, merchantId: merchantId, token: token, controller: self)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instruments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let instrument = instruments[indexPath.row]
        cell.textLabel?.text = instrument.title
        cell.textLabel?.isEnabled = instrument.available ?? false
        return cell
    }
    
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let instrument = instruments[indexPath.row]
        
        guard instrument.available == true else {
            selectedInstrument = nil
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        selectedInstrument = instrument
    }
}

extension ViewController: PhonePeSDKInstrumentHandler {
    func showLinkButton() {
        DispatchQueue.main.async { [weak self] in
            self?.linkBtn.isHidden = false
        }
    }
    
    func hideLinkButton() {
        DispatchQueue.main.async { [weak self] in
            self?.linkBtn.isHidden = true
        }
    }
    
    func getInstruments(_ instruments: [PhonePePayment.Instrument]) {
        self.instruments = instruments
    }
    
    func getError(message: String?) {
        printResult("Error: \(String(describing: message))")
    }
    
    
}

extension ViewController: ViewControllerProtocol {
    
    func startAnimating() {
        DispatchQueue.main.async { [weak self] in
            self?.view.isUserInteractionEnabled = false
            self?.activityIndicator.isHidden = false
            self?.activityIndicator.startAnimating()
        }
    }
    
    func stopAnimating() {
        DispatchQueue.main.async { [weak self] in
            self?.view.isUserInteractionEnabled = true
            self?.activityIndicator.hidesWhenStopped = true
            self?.activityIndicator.stopAnimating()
        }
    }
    
    func printResult(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.resultLbl.text = "Result: \(message)"
        }
    }
    
    func resetInstruments() {
        instruments.removeAll()
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
