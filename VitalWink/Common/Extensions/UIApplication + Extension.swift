//
//  UIApplication + Extension.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/09.
//

import Foundation
extension UIApplication{
    var safeAreaInsets: UIEdgeInsets?{
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let keyWindow = windowScene?.windows.first(where: {$0.isKeyWindow})
        return keyWindow?.safeAreaInsets
    }
    
    var screenSize: CGRect?{
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let keyWindow = windowScene?.windows.first(where: {$0.isKeyWindow})
        return keyWindow?.screen.bounds
    }
    
    var rootController: UIViewController?{
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let keyWindow = windowScene?.windows.first(where: {$0.isKeyWindow})
        return keyWindow?.rootViewController
    }
    
    var barManager: UIStatusBarManager?{
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        
        return windowScene?.statusBarManager
    }
    
}
