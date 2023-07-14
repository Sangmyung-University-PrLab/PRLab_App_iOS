//
//  Expression.swift
//  VitalWink
//
//  Created by 유호준 on 2023/07/10.
//

import Foundation
import SwiftUI
enum Expression: String, Codable, CaseIterable{
    case neutral = "neutral"
    case happy = "happy"
    case sad = "sad"
    case surprise = "surprise"
    case fear = "fear"
    case angry = "angry"
    case disgust = "disgust"
    case contempt = "contempt"
 
    var korean: String{
        switch self {
        case .neutral:
            return "중립"
        case .happy:
            return "행복"
        case .sad:
            return "웃음"
        case .surprise:
            return "놀람"
        case .fear:
            return "공포"
        case .angry:
            return "분노"
        case .disgust:
            return "역겨움"
        case .contempt:
            return "멸시"
        }
    }
    var color: Color{
        switch self {
        case .neutral:
            return .init(red: 0.909803921568627, green: 0.658823529411765, blue: 0.219607843137255)
        case .happy:
            return .init(red: 0.592156862745098, green: 0.890196078431373, blue: 0.835294117647059)
        case .sad:
            return .init(red: 0.909803921568627, green: 0.756862745098039, blue: 0.627450980392157)
        case .surprise:
            return .init(red: 0.850980392156863, green: 0.349019607843137, blue: 0.8)
        case .fear:
            return .init(red: 0.592156862745098, green: 0.749019607843137, blue: 0.890196078431373)
        case .angry:
            return .init(red: 0.945098039215686, green: 0.882352941176471, blue: 0.356862745098039)
        case .disgust:
            return .init(red: 0.623529411764706, green: 0.933333333333333, blue: 0.513725490196078)
        case .contempt:
            return .init(red: 0.917647058823529, green: 0.611764705882353, blue: 0.866666666666667)
        }
    }
}
