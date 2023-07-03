//
//  CircularSegmentedPickerView.swift
//  VitalWink
//
//  Created by 유호준 on 2023/06/11.
//

import SwiftUI

struct CircularSegmentedPickerView<Item>: View where Item:CaseIterable & Equatable{
    
    //아직 더 좋은 구현 방법을 모르겠음
    init(selected:Binding<Item>, texts: [String]){
        allCases = Array(Item.allCases)
        numberOfItems = allCases.count
        self.texts = texts
        self._selected = selected

        if texts.count != numberOfItems{
            fatalError("Item의 개수와 텍스트의 개수가 맞지 않음")
        }
    }
    
    var body: some View {
        GeometryReader{proxy in
            let innerCapsuleWidth = proxy.size.width / CGFloat(numberOfItems) - 2 * innerPadding
            ZStack{
                Capsule()
                    .foregroundColor(backgroundColor)
                Capsule()
                    .frame(width: innerCapsuleWidth, height: 30)
                    .foregroundColor(.blue)
                    .position(x:proxy.frame(in: .local).minX + getInnerCapsulePosition(innerCapsuleWidth: innerCapsuleWidth, offset: proxy.size.width / CGFloat(numberOfItems)), y: proxy.frame(in: .local).midY)
                
                HStack(spacing:0){
                    ForEach(0 ..< numberOfItems, id:\.self){index in
                        
                        Text("\(texts[index])")
                            .frame(width: proxy.size.width / CGFloat(numberOfItems), height: 40)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selected = allCases[index]
                                self.index = index
                            }
                          
                            .font(.notoSans(size: 14, weight: self.index == index ? .bold : .regular))
                            .foregroundColor(self.index == index ? .white : .black)
                            
                    }
                }
            }.animation(.easeInOut, value: index)
        }.frame(height:40)
            .onAppear{
                index = allCases.firstIndex{selected == $0} ?? 0
            }
    }
    
    
    private func getInnerCapsulePosition(innerCapsuleWidth: CGFloat, offset: CGFloat) -> CGFloat{
        let inititalPosition = innerCapsuleWidth / 2 + innerPadding
        
       return inititalPosition + offset * CGFloat(index)
    }
    
    @Binding private var selected: Item
    @State private var index: Int = 0
    private let allCases: [Item]
    private let numberOfItems: Int
    private let texts: [String]
    private let innerPadding: CGFloat = 5
    private let backgroundColor = Color(red: 0.894117647058824, green: 0.949019607843137, blue: 1)
}

struct CircularSegmentedPickerView_Previews: PreviewProvider {
    static var previews: some View {
        var t = Binding<Period>.constant(.week)
        CircularSegmentedPickerView(selected: t, texts: ["1일", "1주","1개월","1년"])
    }
}
