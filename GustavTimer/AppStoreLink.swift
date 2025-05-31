//
//  AppStoreLinks.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 31.05.2025.
//
import Foundation

enum AppStoreLink {
    case review
    case weightsApp

    var url: URL {
        switch self {
        case .review:
            return URL(string: "https://apps.apple.com/app/id6478176431?action=write-review")!
        case .weightsApp:
            return URL(string: "https://apps.apple.com/us/app/gustav-weights/id6483001116")!
        }
    }

    var string: String {
        url.absoluteString
    }
}
