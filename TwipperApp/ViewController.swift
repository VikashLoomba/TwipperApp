//
//  ViewController.swift
//  TwipperApp
//
//  Created by Vikash Loomba on 9/7/15.
//  Copyright © 2015 Vikash Loomba. All rights reserved.
//

import UIKit
import Foundation
import Social
import Accounts


class ViewController: UITableViewController {
    var tweets = [Tweet]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        requestTweets()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // how many cells are we going to need?
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    //cell contents
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell")! as! TweetCell
        
        let tweet = tweets[indexPath.row]
        
        cell.tweetTextLabel.text = tweet.tweetText
        cell.userNameLabel.text = tweet.userName
        cell.createdAtLabel.text = tweet.createdAt
        
        if tweet.pictureURL != nil {
            if let imageData = NSData(contentsOfURL: tweet.pictureURL!) {
                cell.pictureImageView.image = UIImage(data: imageData)
            }
        }
        
        return cell
    }
    
    
    //request the tweets
    func requestTweets() {
        let accountStore = ACAccountStore()
        let twitterAccountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        accountStore.requestAccessToAccountsWithType(twitterAccountType,
            options: nil,
            completion: {
                (granted: Bool, error: NSError!) -> Void in
                if (!granted) {
                    print("Access to Twitter Account denied")
                } else {
                    let twitterAccounts = accountStore.accountsWithAccountType(twitterAccountType)
                    if twitterAccounts.count == 0 {
                        print("No Twitter Accounts available")
                        return
                    } else {
                        let twitterParams = [
                            "count" : "150"
                        ]
                        let twitterAPIURL = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
                        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
                            requestMethod: SLRequestMethod.GET,
                            URL: twitterAPIURL,
                            parameters: twitterParams)
                        request.account = twitterAccounts.first as! ACAccount
                        request.performRequestWithHandler ( {
                            (data: NSData!, urlResponse: NSHTTPURLResponse!, error: NSError!) -> Void in
                            self.handleTweetsResponse(data, urlResponse: urlResponse, error: error)
                        })
                    }
                }
        })
    }
    
    func handleTweetsResponse(data: NSData!, urlResponse: NSHTTPURLResponse!, error: NSError!) {
        if let dataValue = data {
            let jsonObject: AnyObject?
            do {
                jsonObject = try NSJSONSerialization.JSONObjectWithData(dataValue, options: NSJSONReadingOptions(rawValue: 0))
            } catch let error as NSError {
                print(error)
                jsonObject = nil
            }
            
            if let jsonArray = jsonObject as? [[String: AnyObject]] {
                self.tweets.removeAll(keepCapacity: true)
                for tweetDict in jsonArray {
                    let tweetText = tweetDict["text"] as! String
                    let df = NSDateFormatter()
                    // this is the format that we are getting from Twitter API
                    df.dateFormat = "EEE MMM d HH:mm:ss Z y"
                    let createdAtLong = tweetDict["created_at"] as! String
                    // convert a string into NSDate using our date formatter
                    let createdAtShort = df.dateFromString(createdAtLong)
                    // configure our date formatter to have a shorter format
                    df.dateFormat = "EEE MMM d"
                    // use our newly configured date formatter to convert string to NSDate
                    let createdAt = df.stringFromDate(createdAtShort!)
                    let userDict = tweetDict["user"] as! NSDictionary
                    let userName = userDict["name"] as! String
                    let pictureURL = userDict["profile_image_url"] as! String
                    let tweet = Tweet(tweetText: tweetText, userName: userName, createdAt: createdAt, pictureURL: NSURL(string: pictureURL))
                    self.tweets.append(tweet)
                }
                self.tableView.reloadData()
            }
        } else {
            print("handleTwitterData received no data")
        }
    }
    
    

    

}

