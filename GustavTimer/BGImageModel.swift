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
        var result = ""
        if !author.isEmpty {
            result = "Image by \(author)"
        }
        if !source.isEmpty {
            if result.isEmpty {
                result = "Image source: \(source)"
            }
            result = result + " from \(source)"
        }
        return result
    }
}
