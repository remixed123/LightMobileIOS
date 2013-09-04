//
//  SSFirstViewController.h
//  lightcontroller
//
//  Created by Glenn Vassallo on 24/08/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#define PLAYER_TYPE_PREF_KEY @"player_type_preference"
#define AUDIO_TYPE_PREF_KEY @"audio_technology_preference"

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

@interface SSSpecialViewController : UIViewController <MPMediaPickerControllerDelegate,  UIPageViewControllerDelegate, AVAudioPlayerDelegate, UIAccelerometerDelegate >
//@interface SSSpecialViewController : UIViewController <MPMediaPickerControllerDelegate, MusicTableViewControllerDelegate,AVAudioPlayerDelegate>

{
    UIAccelerationValue         accelerationValue[3];
 	//SSAppDelegate               *applicationDelegate;
	IBOutlet UIBarButtonItem	*artworkItem;
	IBOutlet UINavigationBar	*navigationBar;
	IBOutlet UILabel			*nowPlayingLabel;
	BOOL						playedMusicOnce;
    
	AVAudioPlayer				*appSoundPlayer;
	NSURL						*soundFileURL;
	//IBOutlet UIButton			*appSoundButton;
	IBOutlet UIButton			*addOrShowMusicButton;
	BOOL						interruptedOnPlayback;
	BOOL						playing ;
    
	UIBarButtonItem				*playBarButton;
	UIBarButtonItem				*pauseBarButton;
	MPMusicPlayerController		*musicPlayer;
	MPMediaItemCollection		*userMediaItemCollection;
	UIImage						*noArtworkImage;
	NSTimer						*backgroundColorTimer;
    OSStatus                    status;
    
    UIView*                     _configViewContainer;
    UIButton*                   _redButton;
    UIButton*                   _greenButton;
    
//    UIButton*                   connectNowButton;
    IBOutlet UIButton*          microphoneButton;
    IBOutlet UIButton*          acceleromterButton;
    
    NSInputStream               *inputStream;
    NSOutputStream              *outputStream;
    GCDAsyncSocket              *asyncSocket;
    
    SSConnection                *conn;
    SSUtilities                *utils;
    
    AVAudioRecorder             *recorder;
    NSTimer                     *levelTimer;    

}

extern AudioComponentInstance audioUnit;

//@property (nonatomic, retain)	UIView                  *configViewContainer;
//@property (nonatomic, retain)	IBOutlet UIButton		*connectNowButton;
@property (nonatomic, retain)	IBOutlet UIButton		*microphoneButton;
@property (nonatomic, retain)	IBOutlet UIButton		*acceleratorButton;

@property (nonatomic, retain)	UIBarButtonItem			*artworkItem;
@property (nonatomic, retain)	UINavigationBar			*navigationBar;
@property (nonatomic, retain)	UILabel					*nowPlayingLabel;
@property (readwrite)			BOOL					playedMusicOnce;

@property (nonatomic, retain)	UIBarButtonItem			*playBarButton;
@property (nonatomic, retain)	UIBarButtonItem			*pauseBarButton;
@property (nonatomic, retain)	MPMediaItemCollection	*userMediaItemCollection;
@property (nonatomic, retain)	MPMusicPlayerController	*musicPlayer;
@property (nonatomic, retain)	UIImage					*noArtworkImage;
@property (nonatomic, retain)	NSTimer					*backgroundColorTimer;

@property (nonatomic, retain)	AVAudioPlayer			*appSoundPlayer;
@property (nonatomic, retain)	NSURL					*soundFileURL;
@property (nonatomic, retain)	IBOutlet UIButton		*appSoundButton;
@property (nonatomic, retain)	IBOutlet UIButton		*addOrShowMusicButton;
@property (readwrite)			BOOL					interruptedOnPlayback;
@property (readwrite)			BOOL					playing;

//@property (strong, nonatomic) IBOutlet UILabel *statusDescription;
@property (strong, nonatomic) IBOutlet UILabel *featureDescription;
//@property (strong, nonatomic) IBOutlet UILabel *colorDescription;

//@property (strong, nonatomic) IBOutlet UITextField *ipAddressText;
//@property (strong, nonatomic) IBOutlet UITextField *portNumberText;

- (IBAction)playOrPauseMusic:(id)sender;
- (IBAction)AddMusicOrShowMusic:(id) sender;
- (IBAction)playAppSound:(id)sender;

//- (IBAction)connectNow:(id)sender;
- (IBAction)accelerometerToggle:(id)sender;
- (IBAction)microphoneToggle:(id)sender;

- (BOOL) useiPodPlayer;

- (IBAction)startRecording;

- (void)levelTimerCallback:(NSTimer *)timer;


@end
