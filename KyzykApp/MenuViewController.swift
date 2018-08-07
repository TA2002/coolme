//
//  MenuViewController.swift
//  Kok Zhailau
//
//  Created by Tarlan Askaruly on 12.07.2018.
//  Copyright © 2018 Tarlan Askaruly. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import AVFoundation
import CoreImage

class MenuViewController: UIViewController {
    
    var url = "http://tarlan.askaruly.kz/videos.txt"
    var error = 0
    var Once: Bool = false;
    
    var VinesCollection: [Video] = []
    var TelevisionCollection: [Video] = []
    var DailyCollection: [Video] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        error = 0
        Challenge_Button.titleLabel?.numberOfLines = 2
        Submit_Button.titleLabel?.numberOfLines = 2
        Challenge_Button.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
        Submit_Button.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
        Challenge_Button.layer.cornerRadius = 5
        let myColor : UIColor = UIColor( red: 1.0, green: 0, blue:0, alpha: 1.0 )
        Submit_Button.layer.borderColor = myColor.cgColor
        Submit_Button.layer.borderWidth = 2
        Submit_Button.layer.cornerRadius = 5
        let myColor2 : UIColor = UIColor( red: 135, green: 0, blue:168, alpha: 1.0 )
        if(Once == false){
            sendRequest()
        }
    }
    
    func sendRequest(){
        Alamofire.request(url).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let allList = JSON(responseData.result.value!)
                let first = allList["data"].arrayValue
                for i in first{
                    
                    let tempName = i["name"].string!
                    let tempUrl = i["url"].string!
                    let tempAuthor = i["author"].string!
                    print(tempName)
                    let tempType = i["type"].string!
                    if(tempType == "kvn"){
                        print("ok")
                        self.TelevisionCollection.append(Video(name: tempName, author: tempAuthor, url: tempUrl))
                    }
                    if(tempType == "vine"){
                        self.VinesCollection.append(Video(name: tempName, author: tempAuthor, url: tempUrl))
                    }
                    if(tempType == "daily"){
                        self.DailyCollection.append(Video(name: tempName, author: tempAuthor, url: tempUrl))
                    }
                }
                self.Once = true;
            }
            else{
                let alert = UIAlertView()
                alert.title = "Что то произошло не так"
                alert.message = "Нет доступа к сети"
                alert.addButton(withTitle:"ОК")
                alert.show()
                self.error = 10
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toCategory") {
            let destinationVC = segue.destination as! CategoryViewController
            destinationVC.VinesCollection = self.VinesCollection
            destinationVC.TelevisionCollection = self.TelevisionCollection
            destinationVC.DailyCollection = self.DailyCollection
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.isHidden = false
    }
    @IBOutlet weak var Challenge_Button: UIButton!
    @IBOutlet weak var Submit_Button: UIButton!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toCategory_Pressed(_ sender: UIButton) {
        if(error == 10){
            let alert = UIAlertView()
            alert.title = "Что то произошло не так"
            alert.message = "Нет доступа к сети"
            alert.addButton(withTitle:"ОК")
            alert.show()
        }
        else{
            performSegue(withIdentifier: "toCategory", sender: nil)
        }
    }
    
    
    @IBAction func toMail_Pressed(_ sender: UIButton) {
        if(error == 10){
            let alert = UIAlertView()
            alert.title = "Что то произошло не так"
            alert.message = "Нет доступа к сети"
            alert.addButton(withTitle:"ОК")
            alert.show()
        }
        else{
            performSegue(withIdentifier: "toMail", sender: nil)
        }
    }
    
}



