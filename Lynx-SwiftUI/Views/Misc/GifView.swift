//
//  GifView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 12/31/23.
//

import SwiftUI
import FLAnimatedImage

struct GifView: UIViewRepresentable {
    let animatecdView = FLAnimatedImageView()
    let fileName: String
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        
        let path = Bundle.main.path(forResource: fileName, ofType: "gif")!
        let url = URL(filePath: path)
        let gifData = try! Data(contentsOf: url)
        
        let gif = FLAnimatedImage(animatedGIFData: gifData)
        animatecdView.animatedImage = gif
    
        animatecdView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animatecdView)
        
        NSLayoutConstraint.activate([
            animatecdView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animatecdView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) { }
}
