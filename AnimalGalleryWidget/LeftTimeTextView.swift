//
//  LeftTimeTextView.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/07/05.
//

import SwiftUI

struct LeftTimeTextView: View {
    let date: Date
    let style: Text.DateStyle
    let width: CGFloat
    let color: Color

    var body: some View {
        ZStack{
            ZStack{
                Text(date, style: style).offset(x:  width, y:  width)
                Text(date, style: style).offset(x: -width, y: -width)
                Text(date, style: style).offset(x: -width, y:  width)
                Text(date, style: style).offset(x:  width, y: -width)
            }
            .foregroundColor(color)
            Text(date, style: style)
        }
    }
}

struct LeftTimeTextView_Previews: PreviewProvider {
    static var previews: some View {
        LeftTimeTextView(date: Date(), style: .timer, width: 1, color: .blue)
    }
}
