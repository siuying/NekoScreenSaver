# IGYouTubeExtractor

IGYouTubeExtractor is a fork of [RMYouTubeExtractor] that extract MP4 URLs and metadata from a YouTube video identifier.

This library borrows code from [XCDYouTubeVideoPlayerViewController] by [Cédric Luthi] - sans the MPMoviePlayerController, allowing you to just extract the URLs and roll your own player. 

## Requirements

- iOS 7 (uses NSURLSession)
- ARC

## Installation

### CocoaPods

````
pod “RMYouTubeExtractor”
````

then

````
$ pod install
````

### Submodule / manually

1. Add `IGYouTubeExtractor.h` and `IGYouTubeExtractor.m` to your project
2. `@import AVFoundation;`

### Usage

```objc
[[IGYouTubeExtractor sharedInstance] extractVideoForIdentifier:youtubeID
                                                    completion:^(NSArray *videos, NSError *error) {
                                                        }];
```

The instance returns a dictionary with up to 4 video qualities: 240p, 360p, 720p and 1080p. 1080p is rare.

Don’t forget to check for empty dictionary / errors.

### Demo project

See demo project for an example of how to use the extractor.

##Credit

Developed by Rune Madsen ([@runmad] and [runmad.com]).

Credit to [Cédric Luthi] for his work on extraction code.

##Feedback

I appreciate feedback. Create Github issues, pull requests or connect with me on Twitter.

I'd love to see and hear from you if you use it in a project.

## License

IGYouTubeExtractor is available under the MIT license. See the LICENSE file for more information.

[RMYouTubeExtractor]: https://github.com/runmad/RMYouTubeExtractor
[XCDYouTubeVideoPlayerViewController]: https://github.com/0xced/XCDYouTubeVideoPlayerViewController
[@runmad]: http://www.twitter.com/runmad
[runmad.com]: http://www.runmad.com
[Cédric Luthi]: http://github.com/0xced
