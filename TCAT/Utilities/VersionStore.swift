//
//  VersionStore.swift
//  TCAT
//
//  Created by Omar Rasheed on 10/14/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import UIKit
import WhatsNewKit

class VersionStore: WhatsNewVersionStore {
    
    static let shared = VersionStore()
    
    /// The current app version, dynamically loaded based on bundle identifier.
    var currentAppVersion: WhatsNew.Version {
        return WhatsNew.Version(stringLiteral: Constants.App.version)
    }
    
    /// The saved app version in UserDefaults. This is manually updated on release.
    var savedAppVersion: WhatsNew.Version {
        let versionString = userDefaults.string(forKey: Constants.UserDefaults.version) ?? Constants.App.version
        return WhatsNew.Version(stringLiteral: versionString)
    }
    
    /// Returns true if update has been seen
    func has(version: WhatsNew.Version) -> Bool {
        let isVersionPatch = version.patch > 0
        let isNotNewVersion = (currentAppVersion == savedAppVersion)

        // TODO: Confirm this still works!
        // set(version: WhatsNew.Version.current())
        return isVersionPatch || isNotNewVersion
    }

    func set(version: WhatsNew.Version) {
        userDefaults.set(Constants.App.version, forKey: Constants.UserDefaults.version)
    }

}
