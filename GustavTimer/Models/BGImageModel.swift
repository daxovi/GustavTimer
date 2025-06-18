//
//  BGImageModel.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 22.10.2023.
//

import SwiftUI

struct BGImageModel: Identifiable {
    let id = UUID()
    let image: String
    let author: String
    let source: String
    
    func getImage() -> Image {
        return Image("\(image)")
    }
    
    func getTitle() -> String {
        if !author.isEmpty && !source.isEmpty {
            return "Image by \(author) from \(source)"
        } else if !author.isEmpty {
            return "Image by \(author)"
        } else if !source.isEmpty {
            return "Image source: \(source)"
        } else {
            return ""
        }
    }
}
