//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Nicolas Guasch on 23-07-21.
//

import Foundation

enum LoadFeedResult {
    case succes([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func loadFeed(completion: @escaping (LoadFeedResult)->Void)
}
