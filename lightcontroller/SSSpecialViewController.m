//
//  SSFirstViewController.m
//  lightcontroller
//
//  Created by Glenn Vassallo on 24/08/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#import "SSSpecialViewController.h"
#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AUGraph.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVAudioRecorder.h>
#import "SSColorSetting.h"
#import "SSUtilities.h"
#import "SSGlobalSettings.h"
#import "GCDAsyncSocket.h"

@interface SSSpecialViewController ()

@end


AudioComponentInstance audioUnit = NULL;

#define kOutputBus 0
#define kInputBus 1


#pragma mark Audio session callbacks_______________________

// Audio session callback function for responding to audio route changes. If playing
//		back application audio when the headset is unplugged, this callback pauses
//		playback and displays an alert that allows the user to resume or stop playback.
//
//		The system takes care of iPod audio pausing during route changes--this callback
//		is not involved with pausing playback of iPod audio.
void audioRouteChangeListenerCallback (
                                       void                      *inUserData,
                                       AudioSessionPropertyID    inPropertyID,
                                       UInt32                    inPropertyValueSize,
                                       const void                *inPropertyValue
                                       ) {
	
	// ensure that this callback was invoked for a route change
	if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
    
	// This callback, being outside the implementation block, needs a reference to the
	//		MainViewController object, which it receives in the inUserData parameter.
	//		You provide this reference when registering this callback (see the call to
	//		AudioSessionAddPropertyListener).
	SSSpecialViewController *controller = (__bridge SSSpecialViewController *) inUserData;
	
	// if application sound is not playing, there's nothing to do, so return.
	if (controller.appSoundPlayer.playing == 0 ) {
        
		NSLog (@"Audio route change while application audio is stopped.");
		return;
		
	} else {
        
		// Determines the reason for the route change, to ensure that it is not
		//		because of a category change.
		CFDictionaryRef	routeChangeDictionary = inPropertyValue;
		
		CFNumberRef routeChangeReasonRef =
        CFDictionaryGetValue (
                              routeChangeDictionary,
                              CFSTR (kAudioSession_AudioRouteChangeKey_Reason)
                              );
        
		SInt32 routeChangeReason;
		
		CFNumberGetValue (
                          routeChangeReasonRef,
                          kCFNumberSInt32Type,
                          &routeChangeReason
                          );
		
		// "Old device unavailable" indicates that a headset was unplugged, or that the
		//	device was removed from a dock connector that supports audio output. This is
		//	the recommended test for when to pause audio.
		if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
            
			[controller.appSoundPlayer pause];
			NSLog (@"Output device removed, so application audio was paused.");
            
			UIAlertView *routeChangeAlertView =
            [[UIAlertView alloc]	initWithTitle: NSLocalizedString (@"Playback Paused", @"Title for audio hardware route-changed alert view")
                                       message: NSLocalizedString (@"Audio output was changed", @"Explanation for route-changed alert view")
                                      delegate: controller
                             cancelButtonTitle: NSLocalizedString (@"StopPlaybackAfterRouteChange", @"Stop button title")
                             otherButtonTitles: NSLocalizedString (@"ResumePlaybackAfterRouteChange", @"Play button title"), nil];
			[routeChangeAlertView show];
			// release takes place in alertView:clickedButtonAtIndex: method
            
		} else {
            
			NSLog (@"A route change occurred that does not require pausing of application audio.");
		}
	}
}



@implementation SSSpecialViewController

//@synthesize connectNowButton;           // the button to connect to the dmx server
@synthesize acceleratorButton;          //
@synthesize artworkItem;				// the now-playing media item's artwork image, displayed in the Navigation bar
@synthesize userMediaItemCollection;	// the media item collection created by the user, using the media item picker
@synthesize playBarButton;				// the button for invoking Play on the music player
@synthesize pauseBarButton;				// the button for invoking Pause on the music player
@synthesize musicPlayer;				// the music player, which plays media items from the iPod library
@synthesize navigationBar;				// the application's Navigation bar
@synthesize noArtworkImage;				// an image to display when a media item has no associated artwork
@synthesize backgroundColorTimer;		// a timer for changing the background color -- represents an application that is
//		doing something else while iPod music is playing
@synthesize nowPlayingLabel;			// descriptive text shown on the main screen about the now-playing media item
@synthesize appSoundButton;				// the button to invoke playback for the application sound
@synthesize addOrShowMusicButton;		// the button for invoking the media item picker. if the user has already
//		specified a media item collection, the title changes to "Show Music" and
//		the button invokes a table view that shows the specified collection
@synthesize appSoundPlayer;				// An AVAudioPlayer object for playing application sound
@synthesize soundFileURL;				// The path to the application sound
@synthesize interruptedOnPlayback;		// A flag indicating whether or not the application was interrupted during
//		application audio playback
@synthesize playedMusicOnce;			// A flag indicating if the user has played iPod library music at least one time
//		since application launch.
@synthesize playing;					// An application that responds to interruptions must keep track of its playing/
//		not-playing state.

//@synthesize ipAddressText;
//@synthesize portNumberText;

//#pragma mark Connection Methods________________________________
//
//- (IBAction)connectNow:(id)sender
//{
//
//    SSGlobalSettings *connSettings = [SSGlobalSettings sharedManager];
//    connSettings.ipAddress = self.ipAddressText.text;
//    connSettings.portNumber = [self.portNumberText.text intValue]; 
//    
//    [[NSUserDefaults standardUserDefaults]setObject:connSettings.ipAddress forKey:@"ipAddress"];
//    [[NSUserDefaults standardUserDefaults]setInteger:connSettings.portNumber forKey:@"portNumber"];
//    
//     NSLog(@"connectNow: connSettings.ipAddress: %@", connSettings.ipAddress);
//     NSLog(@"connectNow: connSettings.portNumber: %d", connSettings.portNumber);
//    
//     conn = [[SSConnection alloc] init];
//     [conn initNetworkCommunication];
//    
//    self.statusDescription.text = connSettings.ipAddress;
//    
//}


#pragma mark accelerometer Methods________________________________
//////////////////////////////////////////////
// Accelerometer Methods
//////////////////////////////////////////////

- (IBAction)accelerometerToggle:(id)sender
{
    
    if ([UIAccelerometer sharedAccelerometer].delegate == nil)
    {
    
        [[UIAccelerometer sharedAccelerometer] setUpdateInterval:0.2];
        [[UIAccelerometer sharedAccelerometer] setDelegate:self];
    }
    else
    {
        [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
    }
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
   
    accelerationValue[0] = acceleration.x;
    accelerationValue[1] = acceleration.y;
    accelerationValue[2] = acceleration.z;
    NSLog(@"accelerometer: X-axis: %1.1f, Y-axis: %1.1f, Z-axis: %1.1f", acceleration.x, acceleration.y, acceleration.z);
    
    NSString *colorHex = @"FFFFFF";
    
    int redInt = abs((int) (accelerationValue[0] * 127));
    int greenInt = abs((int) (accelerationValue[1] * 127));
    int blueInt = abs((int) (accelerationValue[2] * 127));
    
    NSLog(@"accelerometer: redInt: %i", redInt);
    NSLog(@"accelerometer: greenInt: %i", greenInt);
    NSLog(@"accelerometer: blueInt: %i", blueInt);
    
    colorHex = [utils createHexColorFromIntColors:redInt :greenInt :blueInt];
    NSString *lwdpPacket = [utils createLwdpPacket:@"00" :colorHex];

    NSLog(@"accelerometer: lwdpPacket: %@", lwdpPacket);   
    [conn sendPacket:lwdpPacket];

}

#pragma mark accelerometer Methods________________________________
//////////////////////////////////////////////
// Microphone Methods
//////////////////////////////////////////////

- (IBAction)microphoneToggle:(id)sender
{
   
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
  	NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    
  	NSError *error;
    
  	recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
  	if (recorder) {
  		[recorder prepareToRecord];
  		recorder.meteringEnabled = YES;
  		[recorder record];
        levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
        
  	} else
  		NSLog([error description]);
    
}

- (void)levelTimerCallback:(NSTimer *)timer {
	[recorder updateMeters];
	NSLog(@"levelTimerCallback: Average input: %f Peak input: %f", [recorder averagePowerForChannel:0], [recorder peakPowerForChannel:0]);
    
    
    const double ALPHA = 0.05;
    double peakPowerForChannel = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
    float lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA); // * lowPassResults;
    NSLog(@"levelTimerCallback: lowPassResults: %f",(lowPassResults*100.0f));
    
    float dB = 10 * log10(abs([recorder peakPowerForChannel:0]));
     NSLog(@"levelTimerCallback: db: %f",(dB));
    
    
    NSString *colorHex = @"FFFFFF";
    
//    int redInt = abs((int) (([recorder averagePowerForChannel:0] + 120) * 2));
//    int greenInt = abs((int) ([recorder averagePowerForChannel:0]));
//    int blueInt = abs((int) (([recorder averagePowerForChannel:0] + 120) / 2));
    
    int redInt = 255; //abs((int) (([recorder averagePowerForChannel:0] + 120) * 2));
    int greenInt = abs((int) dB * 10);
    int blueInt = abs((int) dB * 10);
    
    
    NSLog(@"levelTimerCallback: redInt: %i, greenInt: %i, blueInt %i", redInt, greenInt, blueInt);
    
    colorHex = [utils createHexColorFromIntColors:redInt :greenInt :blueInt];
    
    NSLog(@"accelerometer: colorHex: %@", colorHex);

    colorHex = [utils createHexColorFromIntColors:redInt :greenInt :blueInt];
    NSString *lwdpPacket = [utils createLwdpPacket:@"00" :colorHex];
    
    NSLog(@"levelTimerCallback: lwdpPacket: %@", lwdpPacket);
    [conn sendPacket:lwdpPacket];
    
}


- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
    
    NSLog (@"audioRecorderDidFinishRecording:successfully:");
    // your actions here
    
}




#pragma mark Music control________________________________

// A toggle control for playing or pausing iPod library music playback, invoked
//		when the user taps the 'playBarButton' in the Navigation bar.
- (IBAction) playOrPauseMusic: (id)sender {
    
	MPMusicPlaybackState playbackState = [musicPlayer playbackState];
    
	if (playbackState == MPMusicPlaybackStateStopped || playbackState == MPMusicPlaybackStatePaused) {
		[musicPlayer play];
	} else if (playbackState == MPMusicPlaybackStatePlaying) {
		[musicPlayer pause];
	}
    
    OSStatus status = AudioOutputUnitStart(audioUnit);
    AudioOutputUnitStart(audioUnit);
}

// If there is no selected media item collection, display the media item picker. If there's
// already a selected collection, display the list of selected songs.
- (IBAction) AddMusicOrShowMusic: (id) sender {
    
	// if the user has already chosen some music, display that list
	if (userMediaItemCollection) {
        
		MusicTableViewController *controller = [[MusicTableViewController alloc] initWithNibName: @"MusicTableView" bundle: nil];
		controller.delegateMP = self;
		
		controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		
		[self presentModalViewController: controller animated: YES];
		//[controller release];
        
        // else, if no music is chosen yet, display the media item picker
	} else {
        
		MPMediaPickerController *picker =
        [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
		
		picker.delegate						= self;
		picker.allowsPickingMultipleItems	= YES;
		picker.prompt						= NSLocalizedString (@"Add songs to play", "Prompt in media item picker");
		
		// The media item picker uses the default UI style, so it needs a default-style
		//		status bar to match it visually
		[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault animated: YES];
		
		[self presentModalViewController: picker animated: YES];
		//[picker release];
	}
}


// Invoked by the delegate of the media item picker when the user is finished picking music.
//		The delegate is either this class or the table view controller, depending on the
//		state of the application.
- (void) updatePlayerQueueWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection {
    
	// Configure the music player, but only if the user chose at least one song to play
	if (mediaItemCollection) {
        
		// If there's no playback queue yet...
		if (userMediaItemCollection == nil) {
            
			// apply the new media item collection as a playback queue for the music player
			[self setUserMediaItemCollection: mediaItemCollection];
			[musicPlayer setQueueWithItemCollection: userMediaItemCollection];
			[self setPlayedMusicOnce: YES];
			[musicPlayer play];
            
            // Obtain the music player's state so it can then be
            //		restored after updating the playback queue.
		} else {
            
			// Take note of whether or not the music player is playing. If it is
			//		it needs to be started again at the end of this method.
			BOOL wasPlaying = NO;
			if (musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
				wasPlaying = YES;
			}
			
			// Save the now-playing item and its current playback time.
			MPMediaItem *nowPlayingItem			= musicPlayer.nowPlayingItem;
			NSTimeInterval currentPlaybackTime	= musicPlayer.currentPlaybackTime;
            
			// Combine the previously-existing media item collection with the new one
			NSMutableArray *combinedMediaItems	= [[userMediaItemCollection items] mutableCopy];
			NSArray *newMediaItems				= [mediaItemCollection items];
			[combinedMediaItems addObjectsFromArray: newMediaItems];
			
			[self setUserMediaItemCollection: [MPMediaItemCollection collectionWithItems: (NSArray *) combinedMediaItems]];
			//[combinedMediaItems release];
            
			// Apply the new media item collection as a playback queue for the music player.
			[musicPlayer setQueueWithItemCollection: userMediaItemCollection];
			
			// Restore the now-playing item and its current playback time.
			musicPlayer.nowPlayingItem			= nowPlayingItem;
			musicPlayer.currentPlaybackTime		= currentPlaybackTime;
			
			// If the music player was playing, get it playing again.
			if (wasPlaying) {
				[musicPlayer play];
			}
		}
        
		// Finally, because the music player now has a playback queue, ensure that
		//		the music play/pause button in the Navigation bar is enabled.
		navigationBar.topItem.leftBarButtonItem.enabled = YES;
        
		[addOrShowMusicButton	setTitle: NSLocalizedString (@"Show Music", @"Alternate title for 'Add Music' button, after user has chosen some music")
                              forState: UIControlStateNormal];
	}
}

// If the music player was paused, leave it paused. If it was playing, it will continue to
//		play on its own. The music player state is "stopped" only if the previous list of songs
//		had finished or if this is the first time the user has chosen songs after app
//		launch--in which case, invoke play.
- (void) restorePlaybackState {
    
	if (musicPlayer.playbackState == MPMusicPlaybackStateStopped && userMediaItemCollection) {
        
		[addOrShowMusicButton	setTitle: NSLocalizedString (@"Show Music", @"Alternate title for 'Add Music' button, after user has chosen some music")
                              forState: UIControlStateNormal];
		
		if (playedMusicOnce == NO) {
            
			[self setPlayedMusicOnce: YES];
			[musicPlayer play];
		}
	}
    
}



#pragma mark Media item picker delegate methods________

// Invoked when the user taps the Done button in the media item picker after having chosen
//		one or more media items to play.
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection {
    
	// Dismiss the media item picker.
	[self dismissModalViewControllerAnimated: YES];
	
	// Apply the chosen songs to the music player's queue.
	[self updatePlayerQueueWithMediaCollection: mediaItemCollection];
    
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated: YES];
    
}

// Invoked when the user taps the Done button in the media item picker having chosen zero
//		media items to play
- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
    
	[self dismissModalViewControllerAnimated: YES];
	
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated: YES];
}



#pragma mark Music notification handlers__________________

// When the now-playing item changes, update the media item artwork and the now-playing label.
- (void) handle_NowPlayingItemChanged: (id) notification {
    
	MPMediaItem *currentItem = [musicPlayer nowPlayingItem];
	
	// Assume that there is no artwork for the media item.
	UIImage *artworkImage = noArtworkImage;
	
	// Get the artwork from the current media item, if it has artwork.
	MPMediaItemArtwork *artwork = [currentItem valueForProperty: MPMediaItemPropertyArtwork];
	
	// Obtain a UIImage object from the MPMediaItemArtwork object
	if (artwork) {
		artworkImage = [artwork imageWithSize: CGSizeMake (30, 30)];
	}
	
	// Obtain a UIButton object and set its background to the UIImage object
	UIButton *artworkView = [[UIButton alloc] initWithFrame: CGRectMake (0, 0, 30, 30)];
	[artworkView setBackgroundImage: artworkImage forState: UIControlStateNormal];
    
	// Obtain a UIBarButtonItem object and initialize it with the UIButton object
	UIBarButtonItem *newArtworkItem = [[UIBarButtonItem alloc] initWithCustomView: artworkView];
	[self setArtworkItem: newArtworkItem];
	//[newArtworkItem release];
	
	[artworkItem setEnabled: NO];
	
	// Display the new media item artwork
	[navigationBar.topItem setRightBarButtonItem: artworkItem animated: YES];
	
	// Display the artist and song name for the now-playing media item
	[nowPlayingLabel setText: [
                               NSString stringWithFormat: @"%@ %@ %@ %@",
                               NSLocalizedString (@"Now Playing:", @"Label for introducing the now-playing song title and artist"),
                               [currentItem valueForProperty: MPMediaItemPropertyTitle],
                               NSLocalizedString (@"by", @"Article between song name and artist name"),
                               [currentItem valueForProperty: MPMediaItemPropertyArtist]]];
    
	if (musicPlayer.playbackState == MPMusicPlaybackStateStopped) {
		// Provide a suitable prompt to the user now that their chosen music has
		//		finished playing.
		[nowPlayingLabel setText: [
                                   NSString stringWithFormat: @"%@",
                                   NSLocalizedString (@"Music-ended Instructions", @"Label for prompting user to play music again after it has stopped")]];
        
	}
}

// When the playback state changes, set the play/pause button in the Navigation bar
//		appropriately.
- (void) handle_PlaybackStateChanged: (id) notification {
    
	MPMusicPlaybackState playbackState = [musicPlayer playbackState];
	
	if (playbackState == MPMusicPlaybackStatePaused) {
        
		navigationBar.topItem.leftBarButtonItem = playBarButton;
		
	} else if (playbackState == MPMusicPlaybackStatePlaying) {
        
		navigationBar.topItem.leftBarButtonItem = pauseBarButton;
        
	} else if (playbackState == MPMusicPlaybackStateStopped) {
        
		navigationBar.topItem.leftBarButtonItem = playBarButton;
		
		// Even though stopped, invoking 'stop' ensures that the music player will play  
		//		its queue from the start.
		[musicPlayer stop];
        
	}
}

- (void) handle_iPodLibraryChanged: (id) notification {
    
	// Implement this method to update cached collections of media items when the 
	// user performs a sync while your application is running. This sample performs 
	// no explicit media queries, so there is nothing to update.
}

#pragma mark AV Foundation delegate methods____________

- (void) audioPlayerDidFinishPlaying: (AVAudioPlayer *) appSoundPlayer successfully: (BOOL) flag {
    
	playing = NO;
	[appSoundButton setEnabled: YES];
}

- (void) audioPlayerBeginInterruption: player {
    
	NSLog (@"Interrupted. The system has paused audio playback.");
	
	if (playing) {
        
		playing = NO;
		interruptedOnPlayback = YES;
	}
}

- (void) audioPlayerEndInterruption: player {
    
	NSLog (@"Interruption ended. Resuming audio playback.");
	
	// Reactivates the audio session, whether or not audio was playing
	//		when the interruption arrived.
	[[AVAudioSession sharedInstance] setActive: YES error: nil];
	
	if (interruptedOnPlayback) {
        
		[appSoundPlayer prepareToPlay];
		[appSoundPlayer play];
		playing = YES;
		interruptedOnPlayback = NO;
	}
}



#pragma mark Table view delegate methods________________

// Invoked when the user taps the Done button in the table view.
- (void) musicTableViewControllerDidFinish: (MusicTableViewController *) controller {
	
	[self dismissModalViewControllerAnimated: YES];
	[self restorePlaybackState];
}



#pragma mark Application setup____________________________

#if TARGET_IPHONE_SIMULATOR
#warning *** Simulator mode: iPod library access works only when running on a device.
#endif

- (void) setupApplicationAudio {
	
//	// Gets the file system path to the sound to play.
//	NSString *soundFilePath = [[NSBundle mainBundle]	pathForResource:	@"sound"
//                                                              ofType:				@"caf"];
//    
//	// Converts the sound's file path to an NSURL object
//	//NSURL *newURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
//	//self.soundFileURL = newURL;
//	//[newURL release];
//    
//	// Registers this class as the delegate of the audio session.
//	[[AVAudioSession sharedInstance] setDelegate: self];
//	
//	// The AmbientSound category allows application audio to mix with Media Player
//	// audio. The category also indicates that application audio should stop playing
//	// if the Ring/Siilent switch is set to "silent" or the screen locks.
//	[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: nil];
//    /*
//     // Use this code instead to allow the app sound to continue to play when the screen is locked.
//     [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
//     
//     UInt32 doSetProperty = 0;
//     AudioSessionSetProperty (
//     kAudioSessionProperty_OverrideCategoryMixWithOthers,
//     sizeof (doSetProperty),
//     &doSetProperty
//     );
//     */
//    
//	// Registers the audio route change listener callback function
//	AudioSessionAddPropertyListener (
//                                     kAudioSessionProperty_AudioRouteChange,
//                                     audioRouteChangeListenerCallback,
//                                     (__bridge void *)(self)
//                                     );
//    
//	// Activates the audio session.
//	
//	NSError *activationError = nil;
//	[[AVAudioSession sharedInstance] setActive: YES error: &activationError];
//    
//	// Instantiates the AVAudioPlayer object, initializing it with the sound
//	AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: soundFileURL error: nil];
//	self.appSoundPlayer = newPlayer;
//	//[newPlayer release];
//	
//	// "Preparing to play" attaches to the audio hardware and ensures that playback
//	//		starts quickly when the user taps Play
//	[appSoundPlayer prepareToPlay];
//	[appSoundPlayer setVolume: 1.0];
//	[appSoundPlayer setDelegate: self];
}


// To learn about notifications, see "Notifications" in Cocoa Fundamentals Guide.
- (void) registerForMediaPlayerNotifications {
    
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
	[notificationCenter addObserver: self
						   selector: @selector (handle_NowPlayingItemChanged:)
							   name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
							 object: musicPlayer];
	
	[notificationCenter addObserver: self
						   selector: @selector (handle_PlaybackStateChanged:)
							   name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
							 object: musicPlayer];
    
    /*
     // This sample doesn't use libray change notifications; this code is here to show how
     //		it's done if you need it.
     [notificationCenter addObserver: self
     selector: @selector (handle_iPodLibraryChanged:)
     name: MPMediaLibraryDidChangeNotification
     object: musicPlayer];
     
     [[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];
     */
    
	[musicPlayer beginGeneratingPlaybackNotifications];
}


// To learn about the Settings bundle and user preferences, see User Defaults Programming Topics
//		for Cocoa and "The Settings Bundle" in iPhone Application Programming Guide

// Returns whether or not to use the iPod music player instead of the application music player.
- (BOOL) useiPodPlayer {
    
	if ([[NSUserDefaults standardUserDefaults] boolForKey: PLAYER_TYPE_PREF_KEY]) {
		return YES;		
	} else {
		return NO;
	}		
}


//-(void) monitorAudioPlayer
//{
//    [musicPlayer updateMeters];
//    
//    for (int i=0; i<musicPlayer. numberOfChannels; i++)
//    {
//        //Log the peak and average power
//        NSLog(@"%d %0.2f %0.2f", i, [musicPlayer peakPowerForChannel:i],[musicPlayer averagePowerForChannel:i]);
//    }
//}
//
//- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
//{
//    NSLog (@"audioPlayerDidFinishPlaying:");
//    [playerTimer invalidate];
//    playerTimer = nil;
//}
-(void)tap:(UITapGestureRecognizer *)gr
{
    [self.view endEditing:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //////////////////////////////////////////////
    // Connection Configuration
    //////////////////////////////////////////////

    //self.ipAddressText.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"ipAddress"];
    //self.portNumberText.text =  [NSString stringWithFormat:@"%ld",(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"portNumber"]];
    
    conn = [[SSConnection alloc] init];
    utils = [[SSUtilities alloc] init];
    
    //////////////////////////////////////////////
    // UI Configuration
    //////////////////////////////////////////////
    
    
     self.view.backgroundColor = [UIColor darkGrayColor];
    
    //_statusDescription.layer.borderColor = [UIColor lightGrayColor].CGColor;
    //_statusDescription.layer.borderWidth = 1.5;
    //_statusDescription.layer.cornerRadius = 8;
    
    _featureDescription.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _featureDescription.layer.borderWidth = 1.5;
    _featureDescription.layer.cornerRadius = 8;
    
    //_colorDescription.layer.borderColor = [UIColor lightGrayColor].CGColor;
    //_colorDescription.layer.borderWidth = 1.5;
    //_colorDescription.layer.cornerRadius = 8;
    
    _configViewContainer.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _configViewContainer.layer.borderWidth = 1.5;
    _configViewContainer.layer.cornerRadius = 8;
    _configViewContainer.layer.masksToBounds = YES;
    
    
    _redButton.layer.borderColor = [UIColor blackColor].CGColor;
    _redButton.layer.borderWidth = 1.5;
    _redButton.tag = 1 ;
    [_redButton addTarget:self action:@selector(redColor:) forControlEvents:UIControlEventTouchUpInside];
    
    _greenButton.layer.borderColor = [UIColor blackColor].CGColor;
    _greenButton.layer.borderWidth = 1.5;
    _greenButton.tag = 2 ;
    [_greenButton addTarget:self action:@selector(greenColor:) forControlEvents:UIControlEventTouchUpInside];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tapRecognizer];


    
    //////////////////////////////////////////////
    // Audio Configuration
    //////////////////////////////////////////////
    
    [self setupApplicationAudio];
	
	[self setPlayedMusicOnce: NO];
    
	[self setNoArtworkImage:	[UIImage imageNamed: @"no_artwork.png"]];
    
	[self setPlayBarButton:		[[UIBarButtonItem alloc]	initWithBarButtonSystemItem: UIBarButtonSystemItemPlay
                                                                           target: self
                                                                           action: @selector (playOrPauseMusic:)]];
    
	[self setPauseBarButton:	[[UIBarButtonItem alloc]	initWithBarButtonSystemItem: UIBarButtonSystemItemPause
                                                                           target: self
                                                                           action: @selector (playOrPauseMusic:)]];
    
	[addOrShowMusicButton	setTitle: NSLocalizedString (@"Add Music", @"Title for 'Add Music' button, before user has chosen some music")
                          forState: UIControlStateNormal];
    
	[appSoundButton			setTitle: NSLocalizedString (@"Play App Sound", @"Title for 'Play App Sound' button")
                      forState: UIControlStateNormal];
    
	[nowPlayingLabel setText: NSLocalizedString (@"Instructions", @"Brief instructions to user, shown at launch")];
	
	// Instantiate the music player. If you specied the iPod music player in the Settings app,
	//		honor the current state of the built-in iPod app.
	if ([self useiPodPlayer]) {
        
		[self setMusicPlayer: [MPMusicPlayerController iPodMusicPlayer]];
		
		if ([musicPlayer nowPlayingItem]) {
            
			navigationBar.topItem.leftBarButtonItem.enabled = YES;
			
			// Update the UI to reflect the now-playing item.
			[self handle_NowPlayingItemChanged: nil];
			
			if ([musicPlayer playbackState] == MPMusicPlaybackStatePaused) {
				navigationBar.topItem.leftBarButtonItem = playBarButton;
			}
		}
		
	} else {
        
		[self setMusicPlayer: [MPMusicPlayerController applicationMusicPlayer]];
		
		// By default, an application music player takes on the shuffle and repeat modes
		//		of the built-in iPod app. Here they are both turned off.
		[musicPlayer setShuffleMode: MPMusicShuffleModeOff];
		[musicPlayer setRepeatMode: MPMusicRepeatModeNone];
        //musicPlayer.meteringEnabled = YES;
        //musicPlayer.delegate = self;
	}
    
	[self registerForMediaPlayerNotifications];

    
	// Configure a timer to change the background color. The changing color represents an
	//		application that is doing something else while iPod music is playing.
//	[self setBackgroundColorTimer: [NSTimer scheduledTimerWithTimeInterval: 3.5
//																	target: self
//																  selector: @selector (updateBackgroundColor)
//																  userInfo: nil
//																   repeats: YES]];
    
    
    //OSStatus status;
    //AudioComponentInstance audioUnit;
    
    // Describe audio component
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Get component
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    
    // Get audio units
    status = AudioComponentInstanceNew(inputComponent, &audioUnit);
    //checkStatus(status);
    
    // Enable IO for recording
    UInt32 flag = 1;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    //checkStatus(status);
    
    // Enable IO for playback
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &flag,
                                  sizeof(flag));
    
    AudioStreamBasicDescription audioFormat;
    // Describe format
//    audioFormat.mSampleRate			= 44100.00;
//    audioFormat.mFormatID			= kAudioFormatLinearPCM;
//    audioFormat.mFormatFlags		= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
//    audioFormat.mFramesPerPacket	= 1;
//    audioFormat.mChannelsPerFrame	= 1;
//    audioFormat.mBitsPerChannel		= 16;
//    audioFormat.mBytesPerPacket		= 2;
//    audioFormat.mBytesPerFrame		= 2;
    
    // Apply format
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    //checkStatus(status);
    
    // Set input callback
    AURenderCallbackStruct callbackStruct;
    //callbackStruct.inputProc = recordingCallback;
//    callbackStruct.inputProc = AudioUnitRenderCallback;
//    callbackStruct.inputProcRefCon = (__bridge void *)(self);
//    status = AudioUnitSetProperty(audioUnit,
//                                  kAudioOutputUnitProperty_SetInputCallback,
//                                  kAudioUnitScope_Global,
//                                  kInputBus,
//                                  &callbackStruct,
//                                  sizeof(callbackStruct));
    //checkStatus(status);
    
    // Set output callback
    //callbackStruct.inputProc = playbackCallback;
    callbackStruct.inputProc = AudioUnitRenderCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Global,
                                  kOutputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    //checkStatus(status);
    
    
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    //checkStatus(status);
    
    //status = AudioUnitSetProperty(audioUnit, <#AudioUnitPropertyID inID#>, <#AudioUnitScope inScope#>, <#AudioUnitElement inElement#>, <#const void *inData#>, <#UInt32 inDataSize#>)

    // Disable buffer allocation for the recorder (optional - do this if we want to pass in our own)
    flag = 0;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_ShouldAllocateBuffer,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    
    // TODO: Allocate our own buffers if we want
    
    // Initialise
    status = AudioUnitInitialize(audioUnit);
    //checkStatus(status);
    
    //OSStatus status =
    AudioOutputUnitStart(audioUnit);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    /*
     // This sample doesn't use libray change notifications; this code is here to show how
     //		it's done if you need it.
     [[NSNotificationCenter defaultCenter] removeObserver: self
     name: MPMediaLibraryDidChangeNotification
     object: musicPlayer];
     
     [[MPMediaLibrary defaultMediaLibrary] endGeneratingLibraryChangeNotifications];
     
     */
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
												  object: musicPlayer];
	
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
												  object: musicPlayer];
    
	[musicPlayer endGeneratingPlaybackNotifications];

}




- (void)sendSingleColor:(NSString*)singleColor
{
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    
    NSError *err = nil;
    if (![asyncSocket connectToHost:@"192.168.1.8" onPort:8999 error:&err]) // Asynchronous!
    {
        // If there was an error, it's likely something like "already connected" or "no delegate set"
        NSLog(@"It Broke...perhaps: %@", err);
    }
    else
    {
        NSLog(@"All Good!");
    }
    
    //IBOutlet HV
    
    NSString *requestStr = [NSString stringWithFormat:@"%@",singleColor];
    NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [asyncSocket writeData:requestData withTimeout:-1 tag:1];
    [asyncSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}



////////////////////////////////////////////////////////
////////////////////////////////////////////////////////

static OSStatus	AudioUnitRenderCallback (void *inRefCon,
                                         AudioUnitRenderActionFlags *ioActionFlags,
                                         const AudioTimeStamp *inTimeStamp,
                                         UInt32 inBusNumber,
                                         UInt32 inNumberFrames,
                                         AudioBufferList *ioData) {
    
    //OSStatus err = AudioUnitRender(audioUnitWrapper->audioUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
    
   
    OSStatus err = AudioUnitRender(audioUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
    
    if(err != 0) NSLog(@"AudioUnitRender status is %ld", err);
    
    // These values should be in a more conventional location for a bunch of preprocessor defines in your real code
    #define DBOFFSET -74.0
    // DBOFFSET is An offset that will be used to normalize the decibels to a maximum of zero.
    // This is an estimate, you can do your own or construct an experiment to find the right value
    #define LOWPASSFILTERTIMESLICE .001
    // LOWPASSFILTERTIMESLICE is part of the low pass filter and should be a small positive value
    
    SInt16* samples = (SInt16*)(ioData->mBuffers[0].mData); // Step 1: get an array of your samples that you can loop through. Each sample contains the amplitude.
    //UInt32* samples = (UInt32*)(ioData->mBuffers[0].mData);
    
    Float32 decibels = DBOFFSET; // When we have no signal we'll leave this on the lowest setting
    Float32 currentFilteredValueOfSampleAmplitude, previousFilteredValueOfSampleAmplitude; // We'll need these in the low-pass filter
    Float32 peakValue = DBOFFSET; // We'll end up storing the peak value here
    
    for (int i=0; i < inNumberFrames; i++)
    {
        
        Float32 absoluteValueOfSampleAmplitude = abs(samples[i]); //Step 2: for each sample, get its amplitude's absolute value.
        
        // Step 3: for each sample's absolute value, run it through a simple low-pass filter
        // Begin low-pass filter
        currentFilteredValueOfSampleAmplitude = LOWPASSFILTERTIMESLICE * absoluteValueOfSampleAmplitude + (1.0 - LOWPASSFILTERTIMESLICE) * previousFilteredValueOfSampleAmplitude;
        previousFilteredValueOfSampleAmplitude = currentFilteredValueOfSampleAmplitude;
        Float32 amplitudeToConvertToDB = currentFilteredValueOfSampleAmplitude;
        // End low-pass filter
        
        Float32 sampleDB = 20.0*log10(amplitudeToConvertToDB) + DBOFFSET;
        // Step 4: for each sample's filtered absolute value, convert it into decibels
        // Step 5: for each sample's filtered absolute value in decibels, add an offset value that normalizes the clipping point of the device to zero.
        
        if((sampleDB == sampleDB) && (sampleDB != -DBL_MAX))  // if it's a rational number and isn't infinite
        {
            
            if(sampleDB > peakValue) peakValue = sampleDB; // Step 6: keep the highest value you find.
            decibels = peakValue; // final value
        }
    }
    
    //NSLog(@"decibel level is %f", decibels);
    
    for (UInt32 i=0; i < ioData->mNumberBuffers; i++) { // This is only if you need to silence the output of the audio unit
        memset(ioData->mBuffers[i].mData, 0, ioData->mBuffers[i].mDataByteSize); // Delete if you need audio output as well as input
    }
    
    return err;
}

@end
