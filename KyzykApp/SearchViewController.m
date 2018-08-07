//
//  SearchViewController.m
//  KyzykApp
//
//  Created by Tarlan Askaruly on 26.07.2018.
//  Copyright © 2018 Tarlan Askaruly. All rights reserved.
//

@import AVFoundation;
@import GoogleMobileVision;
#import "SearchViewController.h"
#import "AVFoundation/AVFoundation.h"
#import "AVKit/AVKit.h"




@interface SearchViewController ()


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

@property (weak, nonatomic) IBOutlet UILabel *CountViewStartLabel;
@property (weak, nonatomic) IBOutlet UILabel *CountViewTimerLabel;

@property (weak, nonatomic) IBOutlet UIView *CountView;
@property (weak, nonatomic) IBOutlet UISwitch *cameraSwitch;

@property (weak, nonatomic) IBOutlet UIView *placeHolder;
@property (weak, nonatomic) IBOutlet UIView *overlayView;

@property (weak, nonatomic) IBOutlet UIImageView *SearchIcon;
@property (weak, nonatomic) IBOutlet UILabel *SearchName;
@property (weak, nonatomic) IBOutlet UILabel *SearchDescription;


//Detector
@property(nonatomic, strong) GMVDetector *faceDetector;

@end

@implementation SearchViewController

NSTimer *myTimer;
bool startCounting = false;
bool alreadyCounting = false;
INT32_C(countingTimer) = 0;
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue",
                                                          DISPATCH_QUEUE_SERIAL);
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [myTimer invalidate];
    myTimer = nil;
    countingTimer = 0;
    alreadyCounting = false;
    startCounting = false;
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetMedium;
    self.cameraSwitch.on = YES;
    [_cameraSwitch setHidden:YES];
    [self updateCameraSelection];
    
    // Setup video processing pipeline.
    [self setupVideoProcessing];
    
    
    // Setup camera preview.
    [self setupCameraPreview];
    // Do any additional setup after loading the view, typically from a nib.
    // Initialize the face detector.
    NSDictionary *options = @{
                              GMVDetectorFaceMinSize : @(0.3),
                              GMVDetectorFaceTrackingEnabled : @(YES),
                              GMVDetectorFaceLandmarkType : @(GMVDetectorFaceLandmarkAll),
                              GMVDetectorFaceClassificationType : @(GMVDetectorFaceClassificationAll)
                              };
    self.faceDetector = [GMVDetector detectorOfType:GMVDetectorTypeFace options:options];
    
    self.SearchDescription.numberOfLines = 2;
    self.SearchDescription.lineBreakMode = NSLineBreakByWordWrapping;
    self.SearchName.numberOfLines = 2;
    self.SearchName.lineBreakMode = NSLineBreakByWordWrapping;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.session startRunning];
}

//- (void)loopVideo {
//  [self.moviePlayer play];
//}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.session stopRunning];
    [myTimer invalidate];
    myTimer = nil;
    countingTimer = 0;
    alreadyCounting = false;
    startCounting = false;
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


- (void)countingFunction {
    countingTimer = countingTimer + 1;
    self->_CountViewTimerLabel.text = [NSString stringWithFormat:@"%d", countingTimer];
    alreadyCounting = false;
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    AVCaptureDevicePosition devicePosition = self.cameraSwitch.isOn ? AVCaptureDevicePositionFront :
    AVCaptureDevicePositionBack;
    
    // Establish the image orientation.
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    GMVImageOrientation orientation = [GMVUtility
                                       imageOrientationFromOrientation:deviceOrientation
                                       withCaptureDevicePosition:devicePosition
                                       defaultDeviceOrientation:[self deviceOrientationFromInterfaceOrientation]];
    NSDictionary *options = @{
                              GMVDetectorImageOrientation : @(orientation)
                              };
    // Detect features using GMVDetector.
    NSArray<GMVFaceFeature *> *faces = [self.faceDetector featuresInBuffer:sampleBuffer
                                                                   options:options];
    //NSLog(@"Detected %lu face(s).", (unsigned long)[faces count]);
    
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        if(countingTimer == 3){
            alreadyCounting = false;
            startCounting = false;
            countingTimer = 0;
            [self.CountView setHidden: true];
            [self performSegueWithIdentifier:@"toCamera" sender:self];
            [myTimer invalidate];
            myTimer = nil;
        }
        if (startCounting == true && alreadyCounting == true){
            [self.CountView setHidden: false];
            countingTimer = 0;
            myTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                             target:self
                                           selector:@selector(countingFunction)
                                           userInfo:nil
                                            repeats:YES];
            
            alreadyCounting = false;
        }
        // Remove previously added feature
        for (UIView *featureview in self.overlayView.subviews) {
            [featureview removeFromSuperview];
        }
        if ((unsigned long)[faces count] < 1 || (unsigned long)[faces count] > 1){
            //NSLog(@"faaaaace %lu face(s).", (unsigned long)[faces count]);
            self->_SearchName.text = [NSString stringWithFormat:@"ГДЕ ЖЕ ВАШЕ ЛИЦО?!?"];
            self->_SearchDescription.text = [NSString stringWithFormat:@"Убедитесь в том, что камера правильно расположена"];
            [self->_SearchIcon setImage:[UIImage imageNamed:@"searchingIcon"]];
            startCounting = false;
            alreadyCounting = false;
            [self.CountView setHidden: true];
            [myTimer invalidate];
            myTimer = nil;
            self->_CountViewTimerLabel.text = [NSString stringWithFormat:@"%d", 0];
        }
        else {
        // Display detected features in overlay.
        for (GMVFaceFeature *face in faces) {
            
            if (face.hasMouthPosition && face.hasLeftEyePosition && face.hasRightEyePosition && face.hasNoseBasePosition){
                
                    //NSLog(@"faaaaace %lu face(s).", (unsigned long)[faces count]);
                    self->_SearchName.text = [NSString stringWithFormat:@"МЫ НАШЛИ ВАШЕ ЛИЦО!"];
                    self->_SearchDescription.text = [NSString stringWithFormat:@"Будте на готове, игра скоро начнется"];
                [self->_SearchIcon setImage:[UIImage imageNamed:@"happyIcon"]];
                [self.CountView setHidden: false];
                if(startCounting == false){
                    alreadyCounting = true;
                }
                startCounting = true;
                
            }
            else{
                //NSLog(@"faaaaace %lu face(s).", (unsigned long)[faces count]);
                self->_SearchName.text = [NSString stringWithFormat:@"ГДЕ ЖЕ ВАШЕ ЛИЦО?!?"];
                self->_SearchDescription.text = [NSString stringWithFormat:@"Убедитесь в том, что камера правильно расположена"];
                [self->_SearchIcon setImage:[UIImage imageNamed:@"searchingIcon"]];
                startCounting = false;
                alreadyCounting = false;
                [self.CountView setHidden: true];
                [myTimer invalidate];
                myTimer = nil;
                self->_CountViewTimerLabel.text = [NSString stringWithFormat:@"%d", 0];
            }
            if (face.hasSmilingProbability && face.smilingProbability > 0.4) {
                
            }
            else{
                
            }
            
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
    //[_previewLayer bringSubviewToFront:self.SearchDescription];
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


@end
