//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Nicolas Guasch on 23-07-21.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult)->Void)
}
