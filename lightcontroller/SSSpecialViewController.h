//
//  SSSpecialViewController.h
//  LightMobile
//
//  Created by Glenn Vassallo on 24/08/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#define PLAYER_TYPE_PREF_KEY @"player_type_preference"
//#define AUDIO_TYPE_PREF_KEY @"audio_technology_preference"

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioRecorder.h>
#import "MusicTableViewController.h"
#import "SSAppDelegate.h"
#import "SSConnection.h"
#import "SSUtilities.h"
#import "GCDAsyncSocket.h"

@class SSConnection;

@interface SSSpecialViewController : UIViewController <MPMediaPickerControllerDelegate,  UIPageViewControllerDelegate, AVAudioPlayerDelegate, UIAccelerometerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MusicTableViewControllerDelegate>
{
    //SSAppDelegate               *applicationDelegate;
    
    SSConnection                *conn;
    SSUtilities                 *utils;
    
    NSInputStream               *inputStream;
    NSOutputStream              *outputStream;
    GCDAsyncSocket              *asyncSocket;
    
    UIAccelerationValue         accelerationValue[3];

    BOOL						playedMusicOnce;
	BOOL						interruptedOnPlayback;
	BOOL						playing ;
    
    IBOutlet UIButton			*addOrShowMusicButton;
    IBOutlet UIButton*          microphoneButton;
    IBOutlet UIButton*          microphoneSensitivityButton;
    IBOutlet UIButton*          acceleromterButton;
	IBOutlet UIButton*			musicPlayButton;
    IBOutlet UIButton*          musicNextButton;
    IBOutlet UIButton*          photosButton;
    IBOutlet UISegmentedControl *effectsSegment;
    
	MPMusicPlayerController		*musicPlayer;
	MPMediaItemCollection		*userMediaItemCollection;
        
    //AVAudioPlayer               *audioPlayer;
    NSTimer                     *musicTimer;
    AVAudioRecorder             *recorder;
    NSTimer                     *recordTimer;
    
    UIImage *image;
    UIImageView *imageView;
    UIView *view;

}

@property (strong, nonatomic) IBOutlet UILabel          *featureDescription;

@property (nonatomic, retain)	IBOutlet UIButton		*microphoneButton;
@property (nonatomic, retain)	IBOutlet UIButton		*acceleratorButton;
@property (nonatomic, retain)	IBOutlet UIButton		*addMusicButton;
@property (nonatomic, retain)	IBOutlet UIButton		*musicPlayButton;
@property (nonatomic, retain)	IBOutlet UIButton		*musicNextButton;
@property (nonatomic, retain)	IBOutlet UIButton		*photosButton;
@property (nonatomic, retain)   IBOutlet UIButton       *microphoneSensitivityButton;

@property (nonatomic,retain)    IBOutlet UIImageView    *photoImageView;
@property (nonatomic, retain)	MPMediaItemCollection	*userMediaItemCollection;
@property (nonatomic, retain)	MPMusicPlayerController	*musicPlayer;
@property (strong, nonatomic)   AVAudioPlayer           *audioPlayer;

@property (readwrite)			BOOL					interruptedOnPlayback;
@property (readwrite)			BOOL					playing;

- (IBAction)musicToggle:(id)sender;
- (IBAction)nextSong:(id)sender;
- (IBAction)addMusic:(id) sender;
- (IBAction)accelerometerToggle:(id)sender;
- (IBAction)microphoneToggle:(id)sender;
- (IBAction)microphoneSensitivity:(id)sender;
- (IBAction)selectEffect:(id)sender;
- (IBAction)photoScan:(id)sender;
- (IBAction)startRecording;

- (BOOL) useiPodPlayer;

- (void)recordTimerCallback:(NSTimer *)timer;
- (void)stateManager :(NSString*) selectedFeature;
- (void)musicTimerCallback:(NSTimer *)timer;
- (void)registerForMediaPlayerNotifications;


@end

@protocol MusicTableViewControllerDelegate

// implemented in MainViewController.m
//- (void) musicTableViewControllerDidFinish: (MusicTableViewController *) controller;
- (void) musicTableViewControllerDidFinish: (MPMusicPlayerController *) controller;
- (void) updatePlayerQueueWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection;

@end