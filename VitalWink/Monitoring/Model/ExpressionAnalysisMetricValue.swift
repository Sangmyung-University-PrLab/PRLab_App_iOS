//
//  ExpressionAnalysisMetricValueType.swift
//  VitalWink
//
//  Created by 유호준 on 2023/05/22.
//

import Foundation
struct ExpressionAnalysisMetricValue:DataBaseType{
    let arousal: MinMaxType<Float>
    let valence: MinMaxType<Float>
    let expressions: [Expression: Float]
    
    
    enum CodingKeys: String, CodingKey{
        case arousal
        case valence
        case expressions = "expression"
    }
    
    
    init(arousal: MinMaxType<Float>, valence: MinMaxType<Float>, expressions: [Expression: Float]) {
        self.arousal = arousal
        self.valence = valence
        self.expressions = expressions
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.arousal = try container.decode(MinMaxType<Float>.self, forKey: .arousal)
        self.valence = try container.decode(MinMaxType<Float>.self, forKey: .valence)
        let expressionsArray = try container.decode([String : Float].self, forKey: .expressions)
        var expressions: [Expression: Float] = [:]
        expressionsArray.forEach{expressions.updateValue($0.value, forKey: Expression(rawValue: $0.key)!)}
        self.expressions = expressions
    }
    
    #if DEBUG
    static let mock =  ExpressionAnalysisMetricValue(arousal: .init(min: 0.1, max: 1.0), valence: .init(min: 0.1, max: 1.0), expressions: [.neutral: 0.125, .happy: 0.125, .smile: 0.125, .surprise: 0.125, .fear: 0.125, .angry: 0.125, .disgust: 0.125, .scron: 0.125])
    #endif
}
