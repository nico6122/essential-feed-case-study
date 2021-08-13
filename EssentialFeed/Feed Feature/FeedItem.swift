//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Nicolas Guasch on 23-07-21.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageUrl: URL
}
