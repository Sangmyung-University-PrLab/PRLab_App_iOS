//
//  OSLog + Extension.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/26.
//

import Foundation
import OSLog

extension OSLog{
    private static var subsytem = Bundle.main.bundleIdentifier!
    
    static let login = OSLog(subsystem: subsytem, category: "Login")
    static let signUp = OSLog(subsystem: subsytem, category: "SignUp")
    static let findUserInfo = OSLog(subsystem: subsytem, category: "FindUserInfo")
    static let monitoring = OSLog(subsystem: subsytem, category: "monitoring")
    static let metricChart = OSLog(subsystem: subsytem, category: "metircChart")
}
