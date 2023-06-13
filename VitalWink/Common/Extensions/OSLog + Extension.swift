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
    static let findId = OSLog(subsystem: subsytem, category: "FindId")


}
