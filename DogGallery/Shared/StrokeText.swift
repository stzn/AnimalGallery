//
//  StrokeText.swift
//  DogGallery
//
//  Created by Shinzan Takata on 2020/07/05.
//

import SwiftUI

struct StrokeText: View {
    let text: String
    let width: CGFloat
    let color: Color

    var body: some View {
        ZStack{
            ZStack{
                Text(text).offset(x:  width, y:  width)
                Text(text).offset(x: -width, y: -width)
                Text(text).offset(x: -width, y:  width)
                Text(text).offset(x:  width, y: -width)
            }
            .foregroundColor(color)
            Text(text)
        }
    }
}

struct StrokeText_Previews: PreviewProvider {
    static var previews: some View {
        StrokeText(text: "preview", width: 1, color: .white)
            .foregroundColor(.black)
            .background(Color.blue)
            .font(.system(size: 12, weight: .bold))
    }
}
