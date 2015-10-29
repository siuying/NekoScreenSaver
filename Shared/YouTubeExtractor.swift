//
//  YouTubeExtractor.swift
//  NekoScreenSaverOSX
//
//  Created by Chan Fai Chong on 19/9/2015.
//  Copyright © 2015 Ignition Soft. All rights reserved.
//

import Foundation
import AVFoundation

typealias YouTubeExtractorCallback = ([YouTubeVideo]?, NSError?) -> Void
let YouTubeExtractorErrorDomain = "YouTubeExtractorError"

struct YouTubeVideo {
    var title : String
    var videoURL : NSURL
    var thumbnailURL : NSURL
    var quality : YouTubeExtractor.VideoQuality
    
    init(title: String, videoURL: NSURL, thumbnailURL: NSURL, quality: YouTubeExtractor.VideoQuality) {
        self.title = title
        self.videoURL = videoURL
        self.thumbnailURL = thumbnailURL
        self.quality = quality
    }
}

var _AppLanguageIdentifierToken: dispatch_once_t = 0
var _ApplicationLanguageIdentifier: String = "en"
func AppLanguageIdentifier() -> String {
    dispatch_once(&_AppLanguageIdentifierToken) { () -> Void in
        _ApplicationLanguageIdentifier = "en"
        if let preferredLocalization = NSBundle(forClass: YouTubeExtractor.self).preferredLocalizations.first {
            _ApplicationLanguageIdentifier = NSLocale.canonicalLanguageIdentifierFromString(preferredLocalization)
        }
        return
    }
    return _ApplicationLanguageIdentifier
}

class YouTubeExtractor {
    static let sharedExtractor = YouTubeExtractor()

    enum AttemptType : Int {
        case Embedded
        case DetailPage
        case Vevo
        case Blank
        case Error

        func next() -> AttemptType {
            switch self {
            case .Embedded:
                return .DetailPage
            case .DetailPage:
                return .Vevo
            case .Vevo:
                return .Blank
            case .Blank:
                return .Error
            case .Error:
                return .Error
            }
        }
    }
    
    enum VideoQuality : Int {
        case Unknown        = 0
        case Small240       = 133
        case Medium360      = 134
        case Medium480      = 135
        case HD720          = 136
        case HD1080         = 137
    }
    
    var attemptType : AttemptType = .Embedded

    func extractVideoForIdentifier(id: String, completion: YouTubeExtractorCallback) {
        var parameters : [String:String] = ["video_id": id, "ps": "default", "eurl": "", "gl": "US", "hl": AppLanguageIdentifier()]
        print("extractVideoForIdentifier: \(id), attemptType: \(self.attemptType)")
        switch self.attemptType {
        case .Embedded:
            parameters["el"] = "embedded"
        case .DetailPage:
            parameters["el"] = "detailpage"
        case .Vevo:
            parameters["el"] = "vevo"
        case .Blank:
            parameters["el"] = ""
        case .Error:
            let error = NSError(domain: YouTubeExtractorErrorDomain, code: 1, userInfo: [NSLocalizedFailureReasonErrorKey: "Unable to find playable content"])
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(nil, error)
            })
            return
        }
        
        let urlString = addQueryStringToURLString("https://www.youtube.com/get_video_info", withParameters: parameters)
        let URL = NSURL(string: urlString)!
        NSURLSession.sharedSession().dataTaskWithURL(URL) { (data, response, error) -> Void in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(nil, error)
                })
                return
            }
            
            if let data = data {
                if let videoQuery = String(data: data, encoding:NSASCIIStringEncoding) {
                    var video = self.dictionaryWithQueryString(videoQuery)
                    let title = video["title"] ?? ""
                    let thumbnailURLString = video["iurl"] ?? video["irulhq"] ?? video["irulmq"] ?? video["iurlsq"] ?? ""
                    let thumbnailURL = NSURL(string: thumbnailURLString)
                    var streamQueries = video["url_encoded_fmt_stream_map"]?.componentsSeparatedByString(",") ?? []
                    let adaptiveFmts = video["adaptive_fmts"]?.componentsSeparatedByString(",") ?? []
                    streamQueries.appendContentsOf(adaptiveFmts)
                    
                    var videos : [YouTubeVideo] = []
                    for streamQuery in streamQueries {
                        let stream = self.dictionaryWithQueryString(streamQuery)
                        if let type = stream["type"], var urlString = stream["url"] {
                            if AVURLAsset.isPlayableExtendedMIMEType(type) {
                                if let signature = stream["sig"] {
                                    urlString = urlString + "&signature=\(signature)"
                                }
                                if let streamURL = NSURL(string: urlString), query = streamURL.query {
                                    let params = self.dictionaryWithQueryString(query)
                                    if params.keys.contains("signature") {
                                        let itagStr = stream["itag"] != nil ? stream["itag"]! : ""
                                        let itag = Int(itagStr) ?? 0
                                        if let quality = VideoQuality(rawValue: itag), thumbnailURL = thumbnailURL {
                                            let video = YouTubeVideo(title: title, videoURL: streamURL, thumbnailURL: thumbnailURL, quality: quality)
                                            videos.append(video)
                                        } else {
                                            print("unknown quality: \(itag)")
                                        }
                                    } else {
                                        print("missing signature")
                                    }
                                }
                            }
                        }
                    }
                    
                    if videos.count > 0 {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            completion(videos, nil)
                        })
                    } else {
                        self.attemptType = self.attemptType.next()
                        self.extractVideoForIdentifier(id, completion: completion)
                    }
                }

            }
        }.resume()
    }
    
    func addQueryStringToURLString(URLString: String, withParameters parameters: [String:String]) -> String {
        var urlWithQueryString = URLString
        for (key, value) in parameters {
            if let encodedKey = key.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()),
                encodedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
                if urlWithQueryString.containsString("?") {
                    urlWithQueryString.appendContentsOf("&\(encodedKey)=\(encodedValue)")
                    
                } else {
                    urlWithQueryString.appendContentsOf("?\(encodedKey)=\(encodedValue)")
                }
            }
        }
        return urlWithQueryString
    }
    
    
    func dictionaryWithQueryString(query: String) -> [String:String] {
        var result : [String: String] = [:]
        for field in query.componentsSeparatedByString("&") {
            let pair = field.componentsSeparatedByString("=")
            if pair.count == 2 {
                result[pair[0]] = pair[1].stringByRemovingPercentEncoding?.stringByReplacingOccurrencesOfString("+", withString: " ")
            }
        }
        return result
    }

}