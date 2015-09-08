//
//  TweetClass.swift
//  TwipperApp
//
//  Created by Vikash Loomba on 9/7/15.
//  Copyright © 2015 Vikash Loomba. All rights reserved.
//

import Foundation
class Tweet {
    var tweetText: String?
    var userName: String?
    var createdAt: String?
    var pictureURL: NSURL?
    init (tweetText: String?, userName: String?, createdAt: String?, pictureURL: NSURL?) {
        self.tweetText = tweetText
        self.userName = userName
        self.createdAt = createdAt
        self.pictureURL = pictureURL
    }
    
    
}