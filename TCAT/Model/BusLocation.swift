//
//  BusLocation.swift
//  TCAT
//
//  Created by Matthew Barker on 9/6/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class BusLocation: NSObject, NSCoding {
    
    var destination: String = ""
    var deviation: Int = 0
    var direction: String = ""
    var displayStatus: String = ""
    var gpsStatus: Int = 0
    var heading: Int = 0
    var lastStop: String = ""
    var lastUpdated: Date = .distantPast
    var latitude: Double = 0
    var longitude: Double = 0
    var name: Int = 0
    var opStatus: String = ""
    var routeID: String = ""
    var runID: Int = 0
    var speed: Int = 0
    var tripID: Int = 0
    var vehicleID: Int = 0
    
    init(routeID: String) {
        self.routeID = routeID
    }
    
    // MARK: NSCoding
    required convenience init(coder aDecoder: NSCoder) {
        let routeID = aDecoder.decodeObject(forKey: "routeID") as! String
        self.init(routeID: routeID)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.routeID, forKey: "routeID")
    }
    
    var iconView: UIView {
        let diameter = 22
        let circleView = UIView(frame: CGRect(x: 0, y: 0, width: diameter, height: diameter))
        circleView.center = .zero
        circleView.layer.cornerRadius = circleView.frame.width / 2.0
        circleView.layer.masksToBounds = true
        circleView.backgroundColor = .tcatBlueColor
        // circleView.layer.borderWidth = 4
        // circleView.layer.borderColor = borderColor.cgColor
        
        return circleView        
    }
    
}