//
//  RouteDiagram.swift
//  TCAT
//
//  Created by Monica Ong on 7/2/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class RouteDiagramElement: NSObject {
    
    var stopNameLabel: UILabel = UILabel()
    var stopDot: Circle = Circle(size: .small, color: .tcatBlueColor, style: .solid)
    var icon: UIView?
    var routeLine: RouteLine?
        
    override init() {
        super.init()
    }
}

class RouteDiagram: UIView {
    
    // MARK:  View vars
    
    var routeDiagramElements: [RouteDiagramElement] = []
    var travelDistanceLabel: UILabel = UILabel()
    
    // MARK: Spacing vars
    
    let stopDotLeftSpaceFromSuperview: CGFloat = 77.0
    static let routeLineHeight: CGFloat = 20.0
    let busIconLeftSpaceFromSuperview: CGFloat = 16.0
    let walkIconAndRouteLineHorizontalSpace: CGFloat = 36.0
    let stopDotAndStopLabelHorizontalSpace: CGFloat = 14.0
    let stopLabelAndDistLabelHorizontalSpace: CGFloat = 5.5
    
    // MARK: Data vars
    
    var isWalkingRoute: Bool?
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:  Reuse
    
    func prepareForReuse() {
        for routeDiagramElement in routeDiagramElements {
            routeDiagramElement.stopNameLabel.removeFromSuperview()
            routeDiagramElement.stopDot.removeFromSuperview()
            routeDiagramElement.icon?.removeFromSuperview()
            routeDiagramElement.routeLine?.removeFromSuperview()
        }
        travelDistanceLabel.removeFromSuperview()
        
        routeDiagramElements.removeAll()
        travelDistanceLabel = UILabel()
        isWalkingRoute = nil
    }
    
    // MARK: Set Data
    
    func setData(withDirections directions: [Direction], withTravelDistance travelDistance: Double, withWalkingRoute isWalkingRoute: Bool) {
        self.isWalkingRoute = isWalkingRoute
        
        setTravelDistance(withDistance: travelDistance, withWalkingRoute: isWalkingRoute)

        for index in directions.indices {
            // skip first walking direction if not walking route
            if !isWalkingRoute {
                let first = 0
                if index == first && directions[index].type == .walk {
                    continue
                }
            }
            
            let routeDiagramElement = RouteDiagramElement()
            
            routeDiagramElement.stopNameLabel = getStopNameLabel()
            routeDiagramElement.stopDot = getStopDot(fromDirections: directions, atIndex: index, withWalkingRoute: isWalkingRoute)
            routeDiagramElement.icon = getBusIcon(fromDirections: directions, atIndex: index, withWalkingRoute: isWalkingRoute, withTravelDistanceLabel: travelDistanceLabel)
            routeDiagramElement.routeLine = getRouteLine(fromDirections: directions, atIndex: index, withWalkingRoute: isWalkingRoute)
            
            styleStopLabel(routeDiagramElement.stopNameLabel)
            setStopLabel(routeDiagramElement.stopNameLabel, withStopName: directions[index].name)
            
            routeDiagramElements.append(routeDiagramElement)
        }
    }
    
    private func setTravelDistance(withDistance distance: Double, withWalkingRoute isWalkingRoute: Bool) {
        styleDistanceLabel()
        setDistanceLabel(withDistance: distance, withWalkingRoute: isWalkingRoute)
    }
    
    // only set distance if distance > 0
    private func setDistanceLabel(withDistance distance: Double, withWalkingRoute isWalkingRoute: Bool) {
        if distance > 0  {
            let numberOfPlacesToRound = (distance >= 10.0) ? 1 : 2
            var mutableDistance = distance
            let roundedDistance = mutableDistance.roundToPlaces(places: numberOfPlacesToRound)
            travelDistanceLabel.text = isWalkingRoute ? "\(roundedDistance) mi" : "\(roundedDistance) mi away"
            travelDistanceLabel.sizeToFit()
        }
    }
    
    private func setStopLabel(_ stopLabel: UILabel, withStopName stopName: String) {
        stopLabel.text = stopName
        stopLabel.sizeToFit()
    }
    
    // MARK: Get data from route ojbect
    
    private func getStopNameLabel() -> UILabel {
        let yPos: CGFloat = 101
        let rightSpaceFromSuperview: CGFloat = 16
        let width: CGFloat = UIScreen.main.bounds.width - yPos - rightSpaceFromSuperview
        
        let stopNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 17))
        
        return stopNameLabel
    }
    
    private func getStopDot(fromDirections directions: [Direction], atIndex index: Int, withWalkingRoute isWalkingRoute: Bool) -> Circle {
        let directionType = directions[index].type
        var pin: Circle
        let destinationDot = directions.count - 1

        switch directions[index].type {
            
            case .walk:
                
                if(index == destinationDot) {
                    let framedGreyCircle = Circle(size: .large, color: .mediumGrayColor, style: .bordered)
                    framedGreyCircle.backgroundColor = .white
                    
                    pin = framedGreyCircle
                } else {
                    let solidGreyCircle = Circle(size: .small, color: .mediumGrayColor, style: .solid)
                    
                    pin = solidGreyCircle
                }
            
            default:
                
                if(index == destinationDot) {
                    if isWalkingRoute {
                        // walking route destination should always be grey no matter what direction type
                        let framedGreyCircle = Circle(size: .large, color: .mediumGrayColor, style: .bordered)
                        framedGreyCircle.backgroundColor = .white
                        
                        pin = framedGreyCircle
                    } else {
                        let framedBlueCircle = Circle(size: .large, color: .tcatBlueColor, style: .bordered)
                        framedBlueCircle.backgroundColor = .white
                        
                        pin = framedBlueCircle
                    }
                } else {
                    let solidBlueCircle = Circle(size: .small, color: .tcatBlueColor, style: .solid)
                    
                    pin = solidBlueCircle
                }
            
        }
        
        return pin
    }
    
    private func getBusIcon(fromDirections directions: [Direction], atIndex index: Int, withWalkingRoute isWalkingRoute: Bool, withTravelDistanceLabel travelDistanceLabel: UILabel) -> UIView? {
        let first = 0
        // if walking route, add distance label to first walk icon
        if index == first && isWalkingRoute {
            let walkIcon = UIImageView(image: #imageLiteral(resourceName: "walk"))
            walkIcon.contentMode = .scaleAspectFit
            walkIcon.tintColor = .mediumGrayColor
            
            let walkIconAndDistanceLabelVerticalSpace: CGFloat = 2.0
            let width: CGFloat = travelDistanceLabel.frame.width > 0 ? travelDistanceLabel.frame.width : 34.0
            let height: CGFloat = walkIcon.frame.height + walkIconAndDistanceLabelVerticalSpace + travelDistanceLabel.frame.height
            let walkWithDistanceIcon = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: height)))
            
            walkIcon.center.x = walkWithDistanceIcon.center.x
            travelDistanceLabel.center.x = walkWithDistanceIcon.center.x
            
            let oldFrame = travelDistanceLabel.frame
            travelDistanceLabel.frame = CGRect(x: oldFrame.minX, y: walkIcon.frame.maxY + walkIconAndDistanceLabelVerticalSpace, width: oldFrame.width, height: oldFrame.height)

            walkWithDistanceIcon.addSubview(walkIcon)
            walkWithDistanceIcon.addSubview(travelDistanceLabel)
            
            return walkWithDistanceIcon
        }
        
        let last = directions.count - 1
        if index == last {
            return nil
        }
        
        let directionType = directions[index].type
        switch directionType {
            
            case .depart:
                let busNum = directions[index].routeNumber
                let busIcon = BusIcon(type: .directionSmall, number: busNum)
                return busIcon
            
            default:
                let walkIcon = UIImageView(image: #imageLiteral(resourceName: "walk"))
                walkIcon.contentMode = .scaleAspectFit
                walkIcon.tintColor = .mediumGrayColor
                return walkIcon
            
        }

    }
    
    private func getRouteLine(fromDirections directions: [Direction], atIndex index: Int, withWalkingRoute isWalkingRoute: Bool) -> RouteLine? {
        let last = directions.count - 1
        if index == last {
            return nil
        }
        
        if isWalkingRoute {
            let greyRouteLine = SolidLine(height: RouteDiagram.routeLineHeight, color: .mediumGrayColor)
            
            return greyRouteLine
        }
        
        let directionType = directions[index].type
        switch directionType {
            
            case .depart:
                let solidBlueRouteLine = SolidLine(height: RouteDiagram.routeLineHeight, color: .tcatBlueColor)
                
                return solidBlueRouteLine
            
            default:
                let dashedGreyRouteLine = DottedLine(height: RouteDiagram.routeLineHeight, color: .mediumGrayColor)
                
                return dashedGreyRouteLine
            
        }
        
    }

    // MARK: Style
    
    private func styleStopLabel(_ stopLabel: UILabel) {
        stopLabel.font = UIFont(name: FontNames.SanFrancisco.Regular, size: 14.0)
        stopLabel.textColor = .primaryTextColor
        stopLabel.allowsDefaultTighteningForTruncation = true
        stopLabel.lineBreakMode = .byWordWrapping
        stopLabel.numberOfLines = 0
    }
    
    private func styleDistanceLabel() {
        travelDistanceLabel.font = UIFont(name: FontNames.SanFrancisco.Regular, size: 12.0)
        travelDistanceLabel.textColor = .mediumGrayColor
    }
    
    // MARK: Position
    
    func positionSubviews() {
        
        for i in routeDiagramElements.indices {
            
            let stopDot = routeDiagramElements[i].stopDot
            let stopLabel = routeDiagramElements[i].stopNameLabel
            
            positionStopDot(stopDot, atIndex: i)
            positionStopLabelVertically(stopLabel, usingStopDot: stopDot)
            
            let first = 0
            if i == first {
                positionFirstStopLabelHorizontally(stopLabel, usingStopDot: stopDot)
            } else{
                let prevStopLabel = routeDiagramElements[i-1].stopNameLabel
                positionStopLabelHorizontally(stopLabel, usingPrevStopLabel: prevStopLabel)
            }
            
            if let routeLine = routeDiagramElements[i].routeLine {
                positionRouteLine(routeLine, usingStopDot: stopDot)
            }
            
            if let routeLine = routeDiagramElements[i].routeLine,
               let icon = routeDiagramElements[i].icon {
                positionIcon(icon, usingRouteLine: routeLine)
            }
            
        }
        
        guard let isWalkingRoute = isWalkingRoute else {
            positionDistanceLabel(usingFirstStopLabel: routeDiagramElements[0].stopNameLabel)
            resizeHeight()
            return
        }
        
        if isWalkingRoute {
            if let walkWithDistanceIcon = routeDiagramElements.first?.icon,
                let routeLine = routeDiagramElements.first?.routeLine {
                positionWalkWithDistanceIcon(walkWithDistanceIcon, usingRouteLine: routeLine, usingNextIcon: routeDiagramElements[1].icon)
            }
        }
        else {
            positionDistanceLabel(usingFirstStopLabel: routeDiagramElements[0].stopNameLabel)
        }
        
        resizeHeight()
    }
    
    private func positionStopDot(_ stopDot: Circle, atIndex index: Int) {
        let firstDot = 0
        
        if(index == firstDot) {
            
            stopDot.center.x = stopDotLeftSpaceFromSuperview + (stopDot.frame.width/2)
            stopDot.center.y = (stopDot.frame.height/2)
            
        }
        else {
            
            let previousRouteLine = routeDiagramElements[index-1].routeLine
            let previousStopDot = routeDiagramElements[index-1].stopDot
            
            stopDot.center.x = previousStopDot.center.x
            stopDot.center.y = (previousRouteLine?.frame.maxY ?? (previousStopDot.frame.maxY + RouteDiagram.routeLineHeight)) + (stopDot.frame.height/2)
            
        }
        
    }
    
    private func positionFirstStopLabelHorizontally(_ stopLabel: UILabel, usingStopDot stopDot: Circle) {
        let oldFrame = stopLabel.frame
        let newFrame = CGRect(x: stopDot.frame.maxX + stopDotAndStopLabelHorizontalSpace, y: oldFrame.minY, width: oldFrame.width, height: oldFrame.height)
        
        stopLabel.frame = newFrame
    }
    
    private func positionStopLabelVertically(_ stopLabel: UILabel, usingStopDot stopDot: Circle) {
        stopLabel.center.y = stopDot.center.y
    }
    
    private func positionStopLabelHorizontally(_ stopLabel: UILabel, usingPrevStopLabel prevStopLabel: UILabel) {
        let oldFrame = stopLabel.frame
        let newFrame = CGRect(x: prevStopLabel.frame.minX, y: oldFrame.minY, width: oldFrame.width, height: oldFrame.height)
        
        stopLabel.frame = newFrame
    }
    
    private func positionRouteLine(_ routeLine: RouteLine, usingStopDot stopDot: Circle) {
        routeLine.center.x = stopDot.center.x
        
        let oldFrame = routeLine.frame
        let newFrame = CGRect(x: oldFrame.minX, y: stopDot.frame.maxY, width: oldFrame.width, height: oldFrame.height)
        
        routeLine.frame = newFrame
    }
    
    private func positionIcon(_ icon: UIView, usingRouteLine routeLine: RouteLine) {
        if icon is BusIcon {
            positionBusIcon(icon as! BusIcon, usingRouteLine: routeLine)
        }
        else if icon is UIImageView {
            positionWalkIcon(icon as! UIImageView, usingRouteLine: routeLine)
        }
    }
    
    private func positionWalkIcon(_ walkIcon: UIImageView, usingRouteLine routeLine: RouteLine) {
        walkIcon.center.x = routeLine.frame.minX - walkIconAndRouteLineHorizontalSpace - (walkIcon.frame.width/2)
        walkIcon.center.y = routeLine.center.y
    }
    
    private func positionBusIcon(_ busIcon: BusIcon, usingRouteLine routeLine: RouteLine) {
        busIcon.center.x = busIconLeftSpaceFromSuperview + (busIcon.frame.width/2)
        busIcon.center.y = routeLine.center.y
    }
    
    private func positionWalkWithDistanceIcon(_ walkWithDistanceIcon: UIView, usingRouteLine routeLine: RouteLine, usingNextIcon nextIcon: UIView?) {
        if let nextIcon = nextIcon {
            walkWithDistanceIcon.center.x = nextIcon.center.x
            walkWithDistanceIcon.center.y = routeLine.center.y
        }
        else {
            let walkWithDistanceIconAndRouteLineHorizontalSpace: CGFloat = 22.0
            
            walkWithDistanceIcon.center.x = routeLine.frame.minX - walkWithDistanceIconAndRouteLineHorizontalSpace - (walkWithDistanceIcon.frame.width/2)
            walkWithDistanceIcon.center.y = routeLine.center.y
        }
    }
    
    private func positionDistanceLabel(usingFirstStopLabel firstStopLabel: UILabel) {
        let oldFrame = travelDistanceLabel.frame
        let newFrame = CGRect(x: firstStopLabel.frame.maxX + stopLabelAndDistLabelHorizontalSpace, y: firstStopLabel.frame.minY, width: oldFrame.width, height: oldFrame.height)
        
        travelDistanceLabel.frame = newFrame
    }
    
    // MARK: Add subviews
    
    func addSubviews() {
        
        for routeDiagramElement in routeDiagramElements {
            let stopDot = routeDiagramElement.stopDot
            let stopLabel = routeDiagramElement.stopNameLabel
            
            addSubview(stopDot)
            addSubview(stopLabel)
            
            if let routeLine = routeDiagramElement.routeLine {
                addSubview(routeLine)
            }
            
            if let icon = routeDiagramElement.icon {
                addSubview(icon)
            }
        }
        
        guard let isWalkingRoute = isWalkingRoute else {
            if travelDistanceLabel.text != "0.0 mi away" {
                addSubview(travelDistanceLabel)
            }
            
            return
        }
        
        if !isWalkingRoute && travelDistanceLabel.text != "0.0 mi away" {
            addSubview(travelDistanceLabel)
        }
        
    }
    
    private func resizeHeight() {
        let firstStopDot = routeDiagramElements[0].stopDot
        let lastStopDot = routeDiagramElements[routeDiagramElements.count - 1].stopDot
        
        let resizedHeight = lastStopDot.frame.maxY - firstStopDot.frame.minY
        
        let oldFrame = frame
        let newFrame = CGRect(x: oldFrame.minX, y: oldFrame.minY, width: oldFrame.width, height: resizedHeight)
        
        frame = newFrame
    }
}
