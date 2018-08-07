//
//  CategoryViewController.swift
//  Kok Zhailau
//
//  Created by Tarlan Askaruly on 24.07.2018.
//  Copyright © 2018 Tarlan Askaruly. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import AVFoundation
import CoreImage
import Darwin

class CategoryViewController: UIViewController {
    
    var VinesCollection: [Video] = []
    var TelevisionCollection: [Video] = []
    var DailyCollection: [Video] = []
    
    var FinalCollection: [Video] = []
    
    var HighScoreDefault = UserDefaults.standard
    
    @IBOutlet weak var HighScoreLabel: UILabel!
    @IBOutlet weak var DailyCheck: UIImageView!
    @IBOutlet weak var TVCheck: UIImageView!
    @IBOutlet weak var VineCheck: UIImageView!
    @IBOutlet weak var VineButton: UIButton!
    @IBOutlet weak var TVButton: UIButton!
    @IBOutlet weak var DailyButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        VineCheck.isHidden = true
        TVCheck.isHidden = false
        DailyCheck.isHidden = true
        VineButton.layer.cornerRadius = 5
        VineButton.layer.borderColor = VineButton.currentTitleColor.cgColor
        VineButton.layer.borderWidth = 0
        VineButton.clipsToBounds = true
    
        TVButton.layer.cornerRadius = 5
        TVButton.layer.borderColor = TVButton.currentTitleColor.cgColor
        TVButton.layer.borderWidth = 0
        TVButton.clipsToBounds = true
        
        DailyButton.layer.cornerRadius = 5
        DailyButton.layer.borderColor = DailyButton.currentTitleColor.cgColor
        DailyButton.layer.borderWidth = 0
        DailyButton.clipsToBounds = true
        StartButton.layer.cornerRadius = 5
        BackButton.layer.cornerRadius = 5
        if(HighScoreDefault.value(forKey: "HighMinutes") != nil && HighScoreDefault.value(forKey: "HighSeconds") != nil){
            HighScoreLabel.text = "Ваш рекорд: \((HighScoreDefault.value(forKey: "HighMinutes") as! Int?)!)мин. \((HighScoreDefault.value(forKey: "HighSeconds") as! Int?)!)сек."
        }
        else{
            HighScoreLabel.text = "Ваш рекорд: \(0)мин. \(0)сек."
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("didAppear\(VinesCollection)")
        print("didAppear\(TelevisionCollection)")
        print("didAppear\(DailyCollection)")
    }
    
    @IBAction func VineButtonPressed(_ sender: UIButton) {
        VineButton.pulsate()
        if(DailyCheck.isHidden && TVCheck.isHidden){
            
        }
        else{
            VineCheck.isHidden = !VineCheck.isHidden
        }
    }
    @IBAction func DailyButtonPressed(_ sender: UIButton) {
        DailyButton.pulsate()
        if(VineCheck.isHidden && TVCheck.isHidden){
            
        }
        else{
            DailyCheck.isHidden = !DailyCheck.isHidden
        }
    }
    
    @IBAction func TVButtonPressed(_ sender: UIButton) {
        TVButton.pulsate()
        if(DailyCheck.isHidden && VineCheck.isHidden){
            
        }
        else{
            TVCheck.isHidden = !TVCheck.isHidden
        }
    }
    
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var StartButton: UIButton!
    
    @IBAction func BackButton_Pressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func StartChallenge_Pressed(_ sender: UIButton) {
        RandomFinalCollectionName = []
        RandomFinalCollectionUrl = []
        RandomFinalCollectionAuthor = []
        FinalCollection = []
        if(VineCheck.isHidden == false){
            print("Vine \(VinesCollection)")
            for num in 0..<VinesCollection.count {
                FinalCollection.append(VinesCollection[num])
            }
        }
        if(TVCheck.isHidden == false){
            print("TV \(TelevisionCollection)")
            for num in 0..<TelevisionCollection.count {
                FinalCollection.append(TelevisionCollection[num])
            }
        }
        if(DailyCheck.isHidden == false){
            print("Daily \(DailyCollection)")
            for num in 0..<DailyCollection.count {
                FinalCollection.append(DailyCollection[num])
            }
        }
        print("\(TelevisionCollection)")
        print("\(FinalCollection)")
        //var RandomFinalCollection: [Video] = []
        var was: [Int] = []
        var breakloop: Bool = false
        for _ in 0..<FinalCollection.count+2 {
            was.append(1)
        }
        while breakloop == false {
            
            let rand = Int(arc4random_uniform(UInt32(FinalCollection.count)))
            if was[rand] == 10 {
                
            }
            else{
                was[rand] = 10
                print("randomnumber \(rand)")
                //RandomFinalCollection.append(FinalCollection[rand])
                RandomFinalCollectionName.append(FinalCollection[rand].name)
                RandomFinalCollectionAuthor.append(FinalCollection[rand].author)
                RandomFinalCollectionUrl.append(FinalCollection[rand].url)
            }
            
            if RandomFinalCollectionName.count == FinalCollection.count {
                breakloop = true
            }
            
        }
    }
    
    
//   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //if (segue.identifier == "toCamera") {
            //for number in 0..<RandomVinesCollection.count {
              //  let destinationVC = segue.destination as!
            //        destinationVC.urlArray[number] = RandomVinesCollection[number].url
          //  }
        //}
        //if (segue.identifier == "toCamera") {
          //  let destinationVC = segue.destination as! CameraViewController
           // destinationVC.VinesCollection = self.VinesCollection
        //}
    //}
    
}



