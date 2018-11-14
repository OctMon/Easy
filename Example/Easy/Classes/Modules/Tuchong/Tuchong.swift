//
//  Tuchong.swift
//  Easy
//
//  Created by OctMon on 2018/10/16.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

private let session: easy.Session = {
    var config = easy.Config()
    config.url.alias = "Tuchong"
    config.url.release = "https://api.tuchong.com/feed-app"
    config.url.test = "https://api.tuchong.com/feed-app"
    config.url.list = ["https://api.test", "https://api.develop"]
    config.key.list = ["feedList"]
    config.key.size = "pose_id"
    config.code.success = config.code.unknown
    return easy.Session(config)
}()

struct Tuchong: Codable {
    let createdAt: String?
    let publishedAt: String?
    let favoriteListPrefix: [String]?
    let comments: Int?
    let url: String?
    let rewardable: Bool?
    let parentComments: String?
    let siteID: String?
    let type: String?
    let passedTime: String?
    let favorites: Int?
    let authorID: String?
    let recomType: String?
    let update: Bool?
    let views: Int?
    let sites: [String]?
    let site: Site?
    let images: [Image]?
    let eventTags: [String]?
    let tags: [String]?
    let content: String?
    let excerpt: String?
    let delete: Bool?
    let collected: Bool?
    let titleImage: String?
    let rewardListPrefix: [String]?
    let rqtID: String?
    let isFavorite: Bool?
    let imageCount: Int?
    let dataType: String?
    let title: String?
    let postID: Int?
    let rewards: String?
    let commentListPrefix: [String]?
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case publishedAt = "published_at"
        case favoriteListPrefix = "favorite_list_prefix"
        case comments = "comments"
        case url = "url"
        case rewardable = "rewardable"
        case parentComments = "parent_comments"
        case siteID = "site_id"
        case type = "type"
        case passedTime = "passed_time"
        case favorites = "favorites"
        case authorID = "author_id"
        case recomType = "recom_type"
        case update = "update"
        case views = "views"
        case sites = "sites"
        case site = "site"
        case images = "images"
        case eventTags = "event_tags"
        case tags = "tags"
        case content = "content"
        case excerpt = "excerpt"
        case delete = "delete"
        case collected = "collected"
        case titleImage = "title_image"
        case rewardListPrefix = "reward_list_prefix"
        case rqtID = "rqt_id"
        case isFavorite = "is_favorite"
        case imageCount = "image_count"
        case dataType = "data_type"
        case title = "title"
        case postID = "post_id"
        case rewards = "rewards"
        case commentListPrefix = "comment_list_prefix"
    }
}

extension Tuchong {
    
    struct Image: Codable {
        let imgID: Int?
        let excerpt: String?
        let height: Int?
        let title: String?
        let width: Int?
        let userID: Int?
        let description: String?
        
        enum CodingKeys: String, CodingKey {
            case imgID = "img_id"
            case excerpt = "excerpt"
            case height = "height"
            case title = "title"
            case width = "width"
            case userID = "user_id"
            case description = "description"
        }
    }
    
    struct Site: Codable {
        let description: String?
        let verifications: Int?
        let verified: Bool?
        let domain: String?
        let url: String?
        let type: String?
        let verifiedReason: String?
        let verificationList: [String]?
        let isFollowing: Bool?
        let icon: String?
        let followers: Int?
        let siteID: String?
        let name: String?
        let verifiedType: Int?
        
        enum CodingKeys: String, CodingKey {
            case description = "description"
            case verifications = "verifications"
            case verified = "verified"
            case domain = "domain"
            case url = "url"
            case type = "type"
            case verifiedReason = "verified_reason"
            case verificationList = "verification_list"
            case isFollowing = "is_following"
            case icon = "icon"
            case followers = "followers"
            case siteID = "site_id"
            case name = "name"
            case verifiedType = "verified_type"
        }
    }

}

extension Tuchong.Image {
    
    var imageURL: String {
        let id = userID?.toString ?? ""
        let img = imgID.toString ?? ""
        return "https://photo.tuchong.com/" + id + "/f/" + img + ".jpg"
    }
    
    var imageSize: CGSize {
        if let width = width?.toCGFloat, let height = height?.toCGFloat {
            let space: CGFloat = 2.5
            let imageWidth = (app.screenWidth - space * 3) / 2
            let imageHeight = CGSize(width: width, height: height).calcFlowHeight(in: imageWidth)
            return CGSize(width: imageWidth, height: imageHeight)
        }
        return .zero
    }
    
}

extension Tuchong {
    
    /// 图虫
    static func getTuchong(page: Int, poseId: Int?, handler: @escaping (easy.DataResponse) -> Void) {
        session.get(parameters: session.pageSize(page, poseId)) { (dataResponse) in
            if dataResponse.resultValid {
                handler(dataResponse.fill(list: dataResponse.resultList.compactMap({ JSONDecoder().decode(Tuchong.self, from: $0) })))
            } else {
                handler(dataResponse)
            }
        }
    }

}
