# Coolme-Project
Coolme, что в переводе означает "попробуй не засмеятся", это уникальный продукт для любителей Казахстанского юмора.  Интереснейший контент, который обьединяет отрывки из лучших выступлений комик артистов, вайнеров и видеоблогеров Казахстана просто не даст тебе заскучать. Узнай свои пределы стойкости перед отборным юмором и потягайся в этом со своими друзьями.

![logo](https://github.com/TA2002/Coolme-Project/blob/master/Icon-App-83.5x83.5%402x.png) 

<a href="url"><img src="https://github.com/TA2002/Coolme-Project/blob/master/0.jpg" align="left" height="550" width="300" ></a> <a href="url"><img src="https://github.com/TA2002/Coolme-Project/blob/master/1.jpg" align="right" height="550" width="300" ></a>

<a href="url"><img src="https://github.com/TA2002/Coolme-Project/blob/master/2.jpg" align="left" height="550" width="300" ></a> <a href="url"><img src="https://github.com/TA2002/Coolme-Project/blob/master/3.jpg" align="right" height="550" width="300" ></a>

<p align="center">
  <img src="https://github.com/TA2002/Coolme-Project/blob/master/4.jpg" height="550" width="300" top="10" >
</p>

# iOS Vision API Samples

At this time, these samples demonstrate the vision API for detecting faces.

## A note on CocoaPods

The Google Mobile Vision iOS SDK and related samples are distributed through CocoaPods.
Set up CocoaPods by going to cocoapods.org and following the directions.

## Try the sample apps

After installing CocoaPods, run the command `pod try GoogleMobileVision` from Terminal
to open up any example projects for the library. There are 2 sample apps available:

* FaceDetectorDemo: This demo demonstrates basic face detection and integration with
AVFoundation. The app highlights face, eyes, nose, mouth, cheeks, and ears within detected faces.

* GooglyEyesDemo: This demo demonstrates how to use  the `GoogleMVDataOutput` pod to simplify
integration with the video pipeline. The app draws cartoon eyes on top of detected faces.

If you want to try the samples from the github source code. Do the following:

- Run the command `pod install` from Terminal in the folder that contains the Podfile. This will
  download the required dependencies.
- Launch the [Project Name].xcworkspace. This will open the sample app with xcode.


## Support

For General questions and discussion on StackOverflow:
- Stack Overflow: http://stackoverflow.com/questions/tagged/google-ios-vision

If you've found an error in this sample, please file an issue:
https://github.com/googlesamples/ios-vision/issues

Patches are encouraged, and may be submitted by forking this project and
submitting a pull request through GitHub.

License
-------

Copyright 2016 Google, Inc. All Rights Reserved.

Licensed to the Apache Software Foundation (ASF) under one or more contributor
license agreements.  See the NOTICE file distributed with this work for
additional information regarding copyright ownership.  The ASF licenses this
file to you under the Apache License, Version 2.0 (the "License"); you may not
use this file except in compliance with the License.  You may obtain a copy of
the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
License for the specific language governing permissions and limitations under
the License.


# YouTube-Player-iOS-Helper

[![Version](https://cocoapod-badges.herokuapp.com/v/youtube-ios-player-helper/badge.png)](https://cocoapods.org/pods/youtube-ios-player-helper)
[![Platform](https://cocoapod-badges.herokuapp.com/p/youtube-ios-player-helper/badge.png)](https://cocoapods.org/pods/youtube-ios-player-helper)

## Usage

To run the example project; clone the repo, and run `pod install` from the Project directory first.  For a simple tutorial see this Google Developers article - [Using the YouTube Helper Library to embed YouTube videos in your iOS application](https://developers.google.com/youtube/v3/guides/ios_youtube_helper).

## Requirements

## Installation

YouTube-Player-iOS-Helper is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "youtube-ios-player-helper", "~> 0.1.4"

After installing in your project and opening the workspace, to use the library:

  1. Drag a UIView the desired size of your player onto your Storyboard.
  2. Change the UIView's class in the Identity Inspector tab to YTPlayerView
  3. Import "YTPlayerView.h" in your ViewController.
  4. Add the following property to your ViewController's header file:
```objc
    @property(nonatomic, strong) IBOutlet YTPlayerView *playerView;
```
  5. Load the video into the player in your controller's code with the following code:
```objc
    [self.playerView loadWithVideoId:@"M7lc1UVf-VE"];
```
  6. Run your code!

See the sample project for more advanced uses, including passing additional player parameters and
working with callbacks via YTPlayerViewDelegate.

## Author

Ikai Lan
Ibrahim Ulukaya, ulukaya@google.com
Yoshifumi Yamaguchi, yoshifumi@google.com

## License

YouTube-Player-iOS-Helper is available under the Apache 2.0 license. See the LICENSE file for more info.

