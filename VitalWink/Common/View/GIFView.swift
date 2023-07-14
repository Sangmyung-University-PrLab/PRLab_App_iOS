//
//  GIFView.swift
//  VitalWink
//
//  Created by 유호준 on 2023/07/14.
//

import Foundation
import SwiftUI
import FLAnimatedImage

struct GIFView: UIViewRepresentable{
    init(url: URL){
        self.url = url
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.addSubview(imageView)

        imageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo:view.heightAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        Task(priority:.userInitiated){
            guard let data = try? Data(contentsOf: url) else{
                return
            }

            let image = FLAnimatedImage(animatedGIFData: data)

            await MainActor.run{
                imageView.animatedImage = image
            }
        }
    }
    
    private let imageView:FLAnimatedImageView = {
        let imageView = FLAnimatedImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        return imageView
    }()
    private let url: URL
}
