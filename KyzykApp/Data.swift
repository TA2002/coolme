//
//  Data.swift
//  Kok Zhailau
//
//  Created by Tarlan Askaruly on 24.07.2018.
//  Copyright © 2018 Tarlan Askaruly. All rights reserved.
//

import Foundation
import UIKit

@objc class Video : NSObject {
    var name: String = ""
    var author: String = ""
    var url: String = ""
    
    init(name: String, author: String, url: String){
        self.name = name
        self.author = author
        self.url = url
    }
}

public var RandomFinalCollectionName = ["card1", "card2"]
public var RandomFinalCollectionAuthor = ["card1", "card2"]
public var RandomFinalCollectionUrl = ["card1", "card2"]

public var Name = ""
public var Image = UIImage()

//public var AllVines = [Video]()

public var SecondsCount = 0
public var MinutesCount = 0

public var HighSecondsCount = 0
public var HighMinutesCount = 0

@objcMembers class TimeFunctions: NSObject {
    override init() {}
    @objc class func changeSeconds(seconds: Int) {
        SecondsCount = seconds
    }
    @objc class func changeMinutes(minutes: Int) {
        MinutesCount = minutes
    }
}

@objcMembers class ResultFunction: NSObject {
    override init() {}
    @objc class func changeName(namee: String) {
        Name = namee
    }
    @objc class func changeImage(imagee: UIImage) {
        Image = imagee
    }
}


@objcMembers class AppConstant: NSObject {
    override init() {}
    @objc class func name() -> [String] { return RandomFinalCollectionName }
    @objc class func author() -> [String] { return RandomFinalCollectionAuthor}
    @objc class func url() -> [String] { return RandomFinalCollectionUrl}
}





















extension UIButton {
    
    func pulsate() {
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.25
        pulse.fromValue = 0.95
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 1
        pulse.initialVelocity = 1
        pulse.damping = 1.0
        
        layer.add(pulse, forKey: "pulse")
    }
    
    func flash() {
        
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.5
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 3
        
        layer.add(flash, forKey: nil)
    }
    
    
    func shake() {
        
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        
        let fromPoint = CGPoint(x: center.x - 5, y: center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        
        let toPoint = CGPoint(x: center.x + 5, y: center.y)
        let toValue = NSValue(cgPoint: toPoint)
        
        shake.fromValue = fromValue
        shake.toValue = toValue
        
        layer.add(shake, forKey: "position")
    }
}


// Example of using the extension on button press





