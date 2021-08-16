//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Nicolas Guasch on 23-07-21.
//

import Foundation

public struct FeedItem: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageUrl: URL
    
    public init(id: UUID, description: String?,location: String?, imageUrl: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageUrl = imageUrl
    }
    
}
