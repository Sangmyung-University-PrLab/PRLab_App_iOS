//
//  Font + Extension.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/07.
//

import Foundation
import SwiftUI

extension Font{
    static func notoSans(size: CGFloat, weight: Weight = .regular) -> Font{
        switch weight{
        case .black:
            return Font.custom("Inter-Black", size: size)
        case .bold:
            return Font.custom("Inter-Bold", size: size)
        case .semibold:
            return Font.custom("Inter-SemiBold", size: size)
        case .medium:
            return Font.custom("Inter-Medium", size: size)
        case .light:
            return Font.custom("Inter-Light", size: size)
        case .thin:
            return Font.custom("Inter-Thin", size: size)
        default:
            return Font.custom("Inter-Regular", size: size)
        }
    }
}
