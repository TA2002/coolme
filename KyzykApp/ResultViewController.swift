//
//  ResultViewController.swift
//  KyzykApp
//
//  Created by Tarlan Askaruly on 30.07.2018.
//  Copyright © 2018 Tarlan Askaruly. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class ResultViewController: UIViewController {
    
    var chalTime: String!
    var chalImage = UIImage()
    var HighScoreDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(HighScoreDefault.value(forKey: "HighMinutes") != nil){
            HighMinutesCount = (HighScoreDefault.value(forKey: "HighMinutes") as! Int?)!
            
        }
        else{
            HighMinutesCount = 0
        }
        
        if(HighScoreDefault.value(forKey: "HighSeconds") != nil){
            HighSecondsCount = (HighScoreDefault.value(forKey: "HighSeconds") as! Int?)!
            
        }
        else{
            HighSecondsCount = 0
        }
        ShareButton.layer.cornerRadius = 5
        challengeTime.text = Name
        challengeImage.image = Image
        
        if (MinutesCount > HighMinutesCount || (MinutesCount >= HighMinutesCount && SecondsCount > HighSecondsCount)) {

            HighScoreDefault.setValue(MinutesCount, forKey: "HighMinutes")
            HighScoreDefault.setValue(SecondsCount, forKey: "HighSeconds")
            HighScoreDefault.synchronize()
            congratsLabel.text = "Новый рекорд:"
            
        }
        else{
            congratsLabel.text = "Время:"
        }
        
        //challengeTime.text = "\(CameraViewController.videoName.tag)"
    }
    
    @IBOutlet weak var ShareButton: UIButton!
    @IBAction func SharePressed(_ sender: UIButton) {
        let activityVC = UIActivityViewController(activityItems: ["Привет, я продержался в CoolMe: \(Name). А сколько удастся тебе?"], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func toMenu_Pressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "backToMenu", sender: self)
    }
    @IBOutlet weak var challengeImage: UIImageView!
    @IBOutlet weak var challengeTime: UILabel!
    @IBOutlet weak var congratsLabel: UILabel!
}
