//
//  MailViewController.swift
//  KyzykApp
//
//  Created by Tarlan Askaruly on 30.07.2018.
//  Copyright © 2018 Tarlan Askaruly. All rights reserved.
//

import Foundation
import UIKit

class MailViewController: UIViewController, SSRadioButtonControllerDelegate {
    func didSelectButton(selectedButton: UIButton?) {
        
    }
    
    @IBOutlet weak var UrlTextField: UITextField!
    @IBOutlet weak var SendButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        SendButton.layer.cornerRadius = 5
        radioButtonController = SSRadioButtonsController(buttons: First, Second, Third)
        radioButtonController!.delegate = self
        radioButtonController!.shouldLetDeSelect = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBOutlet weak var First: SSRadioButton!
    var radioButtonController: SSRadioButtonsController?
    @IBOutlet weak var Second: SSRadioButton!
    @IBOutlet weak var Third: SSRadioButton!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ToMenuPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func sendEmail(_ sender: Any) {
        let currentButtonName = radioButtonController?.selectedButton()?.tag
        var category: String!
        if(currentButtonName == 2){
            category = "Ежедневные"
        }
        if(currentButtonName == 3){
            category = "Вайны"
        }
        if(currentButtonName == 4){
            category = "Телепередача"
        }
        let videoUrl = UrlTextField.text
        let smtpSession = MCOSMTPSession()
        smtpSession.hostname = "smtp.gmail.com"
        smtpSession.username = "hello.kyzykapp@gmail.com"
        smtpSession.password = "otekyzykapp2018"
        smtpSession.port = 465
        smtpSession.authType = MCOAuthType.saslPlain
        smtpSession.connectionType = MCOConnectionType.TLS
        smtpSession.connectionLogger = {(connectionID, type, data) in
            if data != nil {
                if let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                    NSLog("Connectionlogger: \(string)")
                }
            }
        }
        
        let builder = MCOMessageBuilder()
        builder.header.to = [MCOAddress(displayName: "KyzykApp", mailbox: "hello.kyzykapp@gmail.com")]
        builder.header.from = MCOAddress(displayName: "KyzykApp", mailbox: "hello.kyzykapp@gmail.com")
        builder.header.subject = "Video Request"
        builder.htmlBody = "\(videoUrl!) \(category!)"
        
        let rfc822Data = builder.data()
        let sendOperation = smtpSession.sendOperation(with: rfc822Data)
        sendOperation?.start { (error) -> Void in
            if (error != nil) {
                NSLog("Error sending email: \(error)")
            } else {
                NSLog("Successfully sent email!")
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
