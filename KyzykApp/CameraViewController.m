/*
 Copyright 2016-present Google Inc. All Rights Reserved.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */


@import AVFoundation;
@import GoogleMobileVision;
@import MediaPlayer;
#import "CameraViewController.h"
#import "AVFoundation/AVFoundation.h"
#import "AVKit/AVKit.h"
#import "MediaPlayer/MediaPlayer.h"
#import "KyzykApp-Swift.h"



@interface CameraViewController ()
    
    
    //video objects
    @property(nonatomic, strong) AVCaptureSession *session;
    @property(nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
    @property(nonatomic, strong) dispatch_queue_t videoDataOutputQueue;
    @property(nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
    

    //@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
    
    //mediaPlayer
    //@property (weak, nonatomic) IBOutlet UIView *videoView;
    //@property (weak, nonatomic) IBOutlet UIView *videoView;
    @property (weak, nonatomic) IBOutlet UIView *videoLayer;

    //uiobjects
@property (weak, nonatomic) IBOutlet UIView *countView;
@property (weak, nonatomic) IBOutlet UISwitch *cameraSwitch;
@property (weak, nonatomic) IBOutlet UIView *placeHolder;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UILabel *videoName;
@property (weak, nonatomic) IBOutlet UILabel *VideoAuthor;
@property (weak, nonatomic) IBOutlet UILabel *countingLabel;

    //Detector
    @property(nonatomic, strong) GMVDetector *faceDetector;
    
    @end

@implementation CameraViewController

NSString *videoId;
int(cnt);
bool ready;

NSArray *urlArray;
NSArray *nameArray;
NSArray *authorArray;
UIImage *myy;

INT32_C(TotalTime) = 0;
NSTimer *TimerForCounting;
bool startedCounting = false;
bool alreadystartedCounting = false;
INT32_C(mins) = 0;
INT32_C(seconds) = 0;
INT32_C(countingVariable) = 5;
NSTimer *GameTimer;
AVAudioSession *audioSession;


    - (id)initWithCoder:(NSCoder *)aDecoder {
        self = [super initWithCoder:aDecoder];
        if (self) {
            self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue",
                                                              DISPATCH_QUEUE_SERIAL);
        }
        return self;
    }
    
    // Set up default camera settings.
//NSNumber totalTime;


- (void)TakeScreenshot {
    UIWindow *userWindow = [UIApplication sharedApplication].keyWindow;
    
    if([[UIScreen mainScreen] respondsToSelector:@selector(scale)]){
        UIGraphicsBeginImageContextWithOptions(userWindow.bounds.size, NO, [UIScreen mainScreen].scale);
    }
    else{
        UIGraphicsBeginImageContext(userWindow.bounds.size);
    }
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *currentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [ResultFunction changeImageWithImagee:currentImage];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.playerView.delegate = self;
}

- (void)GameTime {
    TotalTime = TotalTime + 1;
}

- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView{
    if(ready == false){
        [self.playerView playVideo];
    }
    ready = true;
    GameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(GameTime)
                                               userInfo:nil
                                                repeats:YES];
}

- (void)receivedPlaybackStartedNotification:(NSNotification *) notification {
    if([notification.name isEqual:@"Playback started"] && notification.object != self) {
        [self.playerView pauseVideo];
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _overlayView.layer.cornerRadius = 15;
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetMedium;
    self.cameraSwitch.on = YES;
    [_cameraSwitch setHidden:YES];
    [self updateCameraSelection];
    [self setupVideoProcessing];
    [self setupCameraPreview];
    [GameTimer invalidate];
    GameTimer = nil;
    //[self->_playerView stopVideo];
    startedCounting = false;
    alreadystartedCounting = false;
    [TimerForCounting invalidate];
    TimerForCounting = nil;
    countingVariable = 5;
    TotalTime = 0;
    cnt = 0;
    urlArray = [AppConstant url];
    nameArray = [AppConstant name];
    authorArray = [AppConstant author];
    ready = false;
    NSDictionary *options = @{
                              GMVDetectorFaceMinSize : @(0.3),
                              GMVDetectorFaceTrackingEnabled : @(YES),
                              GMVDetectorFaceLandmarkType : @(GMVDetectorFaceLandmarkAll),
                              GMVDetectorFaceClassificationType : @(GMVDetectorFaceClassificationAll)
                              };
    self.faceDetector = [GMVDetector detectorOfType:GMVDetectorTypeFace options:options];
    
    videoId = urlArray[0];
    
    // For a full list of player parameters, see the documentation for the HTML5 player
    // at: https://developers.google.com/youtube/player_parameters?playerVersion=HTML5
    NSDictionary *playerVars = @{
                                 @"controls" : @0,
                                 @"playsinline" : @1,
                                 @"autohide" : @1,
                                 @"showinfo" : @1,
                                 @"modestbranding" : @1,
                                 @"autoplay" : @0,
                                 @"rel" : @0,
                                 @"iv_load_policy" : @3
                                 };
    [self.playerView loadWithVideoId:videoId playerVars:playerVars];
    self->_VideoAuthor.text = [NSString stringWithFormat:@"Автор: %@", authorArray[0]];
    self->_videoName.text = [NSString stringWithFormat:@"Имя: %@", nameArray[0]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedPlaybackStartedNotification:)
                                                 name:@"Playback started"
                                               object:nil];
    
    audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    self.playerView.webView.mediaPlaybackRequiresUserAction = NO;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.session startRunning];
}
    
//- (void)loopVideo {
  //  [self.moviePlayer play];
//}

- (UIImage*)screenshot
{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *im = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return im;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self->_playerView cueVideoById: @"hfsdkhfjksdhfkjsdhkj" startSeconds: (0.0) suggestedQuality:(kYTPlaybackQualityLarge)];
    startedCounting = false;
    alreadystartedCounting = false;
    [TimerForCounting invalidate];
    TimerForCounting = nil;
    countingVariable = 5;
    TotalTime = 0;
    [GameTimer invalidate];
    GameTimer = nil;
    [self.session stopRunning];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
    
    if (self.previewLayer) {
        if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
            self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        } else if (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
        } else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
            self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        } else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        }
    }
}
    
- (UIDeviceOrientation)deviceOrientationFromInterfaceOrientation {
    UIDeviceOrientation defaultOrientation = UIDeviceOrientationPortrait;
    switch ([[UIApplication sharedApplication] statusBarOrientation]) {
        case UIInterfaceOrientationLandscapeLeft:
        defaultOrientation = UIDeviceOrientationLandscapeRight;
        break;
        case UIInterfaceOrientationLandscapeRight:
        defaultOrientation = UIDeviceOrientationLandscapeLeft;
        break;
        case UIInterfaceOrientationPortraitUpsideDown:
        defaultOrientation = UIDeviceOrientationPortraitUpsideDown;
        break;
        case UIInterfaceOrientationPortrait:
        default:
        defaultOrientation = UIDeviceOrientationPortrait;
        break;
    }
    return defaultOrientation;
}

    
    
#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)checkEnd {
    [_playerView playVideo];
}

- (void)functionToCount{
    countingVariable = countingVariable - 1;
    self->_countingLabel.text = [NSString stringWithFormat:@"%d", countingVariable];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    size_t imageWidth = CVPixelBufferGetWidth(imageBuffer);
    size_t imageHeight = CVPixelBufferGetHeight(imageBuffer);
    AVCaptureDevicePosition devicePosition = self.cameraSwitch.isOn ? AVCaptureDevicePositionFront :
    AVCaptureDevicePositionBack;
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    GMVImageOrientation orientation = [GMVUtility
                                       imageOrientationFromOrientation:deviceOrientation
                                       withCaptureDevicePosition:devicePosition
                                       defaultDeviceOrientation:[self deviceOrientationFromInterfaceOrientation]];
    NSDictionary *options = @{                              GMVDetectorImageOrientation : @(orientation)
                              };
    
    //myy = (__bridge UIImage *)(sampleBuffer);
    //[ResultFunction changeImageWithImagee:myy];
    NSArray<GMVFaceFeature *> *existingFaces = [self.faceDetector featuresInBuffer:sampleBuffer
                                                                   options:options];
    //NSLog(@"Detected %lu face(s).", (unsigned long)[faces count]);
    
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        Float32 cur = self.playerView.currentTime;
        Float32 dur = self.playerView.duration;
        //g(@"%f", cur);
        
        if(countingVariable == 0){
            alreadystartedCounting = false;
            startedCounting = false;
            countingVariable = 5;
            [self.countView setHidden: true];
            [TimerForCounting invalidate];
            TimerForCounting = nil;
            [self performSegueWithIdentifier:@"toMenu" sender:self];
        }
        
        if (cur + 1 >= dur && ready == true && cur > 2.0) {
            
            //NSLog(@"ended");
            
            cnt = cnt + 1;
            
            if (cnt == nameArray.count) {
                mins = 0;
                seconds = 0;
                mins = TotalTime / 60;
                seconds = TotalTime - 60*mins;
                [TimeFunctions changeSecondsWithSeconds:seconds];
                [TimeFunctions changeMinutesWithMinutes:mins];
                [ResultFunction changeNameWithNamee:[NSString stringWithFormat:@"%dмин. %dсек.", mins, seconds]];
                UIImage *curr = [self screenshot];
                [ResultFunction changeImageWithImagee:curr];
                alreadystartedCounting = false;
                startedCounting = false;
                countingVariable = 5;
                [self.countView setHidden: true];
                [self performSegueWithIdentifier:@"toResult" sender:self];
                [TimerForCounting invalidate];
                TimerForCounting = nil;
            }
            
            videoId = urlArray[cnt];
            
            self->_VideoAuthor.text = [NSString stringWithFormat:@"Автор: %@", authorArray[cnt]];
            
            self->_videoName.text = [NSString stringWithFormat:@"Имя: %@", nameArray[cnt]];
            
            [self->_playerView cueVideoById: videoId startSeconds: (0.0) suggestedQuality:(kYTPlaybackQualityLarge)];
            
            [NSTimer scheduledTimerWithTimeInterval:2.0
                                             target:self
                                           selector:@selector(checkEnd)
                                           userInfo:nil
                                            repeats:NO];
        }
        
        
        if (startedCounting == true && alreadystartedCounting == true){
            countingVariable = 5;
            [self.countView setHidden: false];
            
            TimerForCounting = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                       target:self
                                                     selector:@selector(functionToCount)
                                                     userInfo:nil
                                                      repeats:YES];
            
            alreadystartedCounting = false;
        }
        
        for (UIView *featureview in self.overlayView.subviews) {
            [featureview removeFromSuperview];
        }
        
        if ((unsigned long)[existingFaces count] < 1 || (unsigned long)[existingFaces count] > 1){
            
            if(startedCounting == false){
                alreadystartedCounting = true;
            }
            startedCounting = true;
            [self.countView setHidden: false];
            [self->_playerView pauseVideo];
        }
        
        else{
            alreadystartedCounting = false;
            startedCounting = false;
            [self.countView setHidden: true];
            [self->_playerView playVideo];
            TimerForCounting.invalidate;
            TimerForCounting = nil;
            self->_countingLabel.text = [NSString stringWithFormat:@"%d", 5];
        }
        
        // Display detected features in overlay.
        for (GMVFaceFeature *existingFace in existingFaces) {
            
            if(existingFace.hasMouthPosition && existingFace.hasLeftEyePosition && existingFace.hasRightEyePosition && existingFace.hasNoseBasePosition){
                alreadystartedCounting = false;
                startedCounting = false;
                [self.countView setHidden: true];
                [self->_playerView playVideo];
                TimerForCounting.invalidate;
                TimerForCounting = nil;
                self->_countingLabel.text = [NSString stringWithFormat:@"%d", 5];
            }
            else{
                if(startedCounting == false){
                    alreadystartedCounting = true;
                }
                startedCounting = true;
                [self.countView setHidden: false];
            }
            
            NSLog([NSString stringWithFormat:@"%f probability", existingFace.smilingProbability]);
            
            if (existingFace.hasSmilingProbability && existingFace.smilingProbability > 0.85) {
                mins = 0;
                seconds = 0;
                mins = TotalTime / 60;
                seconds = TotalTime - 60 * mins;
                [TimeFunctions changeSecondsWithSeconds:seconds];
                [TimeFunctions changeMinutesWithMinutes:mins];
                [ResultFunction changeNameWithNamee:[NSString stringWithFormat:@"%dмин. %dсек.", mins, seconds]];
                UIImage *curr = [self screenshot];
                [ResultFunction changeImageWithImagee:curr];
                alreadystartedCounting = false;
                startedCounting = false;
                countingVariable = 5;
                [self.countView setHidden: true];
                [self performSegueWithIdentifier:@"toResult" sender:self];
                [TimerForCounting invalidate];
                TimerForCounting = nil;
            }
            else{
                
            }
            
        }
    });
}
    
    
    
#pragma mark - Camera setup
    
- (void)cleanupVideoProcessing {
    if (self.videoDataOutput) {
        [self.session removeOutput:self.videoDataOutput];
    }
    self.videoDataOutput = nil;
}
    
- (void)cleanupCaptureSession {
    [self.session stopRunning];
    [self cleanupVideoProcessing];
    self.session = nil;
    [self.previewLayer removeFromSuperlayer];
}
    
- (void)setupVideoProcessing {
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    NSDictionary *rgbOutputSettings = @{
                                        (__bridge NSString*)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)
                                        };
    [self.videoDataOutput setVideoSettings:rgbOutputSettings];
    
    if (![self.session canAddOutput:self.videoDataOutput]) {
        [self cleanupVideoProcessing];
        NSLog(@"Failed to setup video output");
        return;
    }
    [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
    [self.session addOutput:self.videoDataOutput];
}
    
- (void)setupCameraPreview {
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    CALayer *rootLayer = [self.placeHolder layer];
    [rootLayer setMasksToBounds:YES];
    [self.previewLayer setFrame:[rootLayer bounds]];
    //[rootLayer addSublayer: WholeScreen];
    //CGRect myframe = WholeScreen.frame;
    // CGFloat xPosition = CGRectGetWidth(rootLayer.frame) - CGRectGetWidth(myframe);
    //myframe.origin = CGPointMake(ceil(xPosition), 0.0);
    //WholeScreen.frame = myframe;
    
    [rootLayer addSublayer:self.previewLayer];
}
    
- (void)updateCameraSelection {
    [self.session beginConfiguration];
    
    // Remove old inputs
    NSArray *oldInputs = [self.session inputs];
    for (AVCaptureInput *oldInput in oldInputs) {
        [self.session removeInput:oldInput];
    }
    
    AVCaptureDevicePosition desiredPosition = self.cameraSwitch.isOn ?
    AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    AVCaptureDeviceInput *input = [self cameraForPosition:desiredPosition];
    if (!input) {
        // Failed, restore old inputs
        for (AVCaptureInput *oldInput in oldInputs) {
            [self.session addInput:oldInput];
        }
    } else {
        // Succeeded, set input and update connection states
        [self.session addInput:input];
    }
    [self.session commitConfiguration];
}

- (AVCaptureDeviceInput *)cameraForPosition:(AVCaptureDevicePosition)desiredPosition {
    for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([device position] == desiredPosition) {
            NSError *error = nil;
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                                error:&error];
            if ([self.session canAddInput:input]) {
                return input;
            }
        }
    }
    return nil;
}
    
- (IBAction)cameraDeviceChanged:(id)sender {
    [self updateCameraSelection];
}



    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
    
- (IBAction)cameraSwitch:(UISwitch *)sender {
}
@end
