//
//  Analytics.swift
//  TCAT
//
//  Created by Serge-Olivier Amega on 12/29/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//
// To log an event, use the shared RegisterSession (RegisterSession.shared)

import Foundation
import SwiftRegister
import SwiftyJSON

fileprivate var registerSession: RegisterSession? = nil

fileprivate func getSecretKey() -> String {
    let configURL = Bundle.main.url(forResource: "config", withExtension: "json")!
    let configJSON = try! JSON(Data(contentsOf: configURL))
    return configJSON["register-secret"].stringValue
}

extension RegisterSession {
    
    static var shared: RegisterSession {
        guard let session = registerSession else {
            let url = URL(string: "http://52.54.98.130/api/")!
            let secretKey = getSecretKey()
            registerSession = RegisterSession(apiUrl: url, secretKey: secretKey)
            return registerSession!
        }
        return session
    }
    
}

/// Log device information
struct DeviceInfo: Codable {
    
    let model: String = UIDevice.current.modelName
    let softwareVersion: String = UIDevice.current.systemVersion
    let appVersion: String = Constants.App.version
    let language: String = Locale.preferredLanguages.first ?? "n/a"
    
}

// MARK: Event Payloads

struct AppLaunchedPayload: Payload {
    static let eventName: String = "App Launched"
}

struct SearchBarTappedEventPayload: Payload {
    
    static let eventName: String = "Search Bar Tapped"
    static let deviceInfo = DeviceInfo()
    
    enum SearchBarTapLocation: String, Codable {
        case home
    }
    
    let location: SearchBarTapLocation
}

struct DestinationSearchedEventPayload: Payload {
    
    static let eventName: String = "Destination Searched"
    static let deviceInfo = DeviceInfo()
    
    let destination: String
    let requestUrl: String?
    let stopType: String?
    
}

struct RouteResultsCellTappedEventPayload: Payload {
    static let eventName: String = "Tapped Route Results Cell"
    static let deviceInfo = DeviceInfo()
}

struct InformationViewControllerTappedEventPayload: Payload {
    static let eventName: String = "Tapped Big Blue Bus"
    static let deviceInfo = DeviceInfo()
}

struct RouteSharedEventPayload: Payload {
    
    static let eventName: String = "Share Route"
    static let deviceInfo = DeviceInfo()
    
    let activityType: String
    let didSelectAndCompleteShare: Bool
    let error: String?
    
}

struct GetRoutesErrorPayload: Payload {
    
    static let eventName: String = "Get Routes Error"
    static let deviceInfo = DeviceInfo()
    
    let description: String
    let url: String?
    
}
