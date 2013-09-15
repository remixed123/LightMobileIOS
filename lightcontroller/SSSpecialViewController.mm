//
//  SSSpecialViewController.mm
//  LightMobile
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
#import <MediaPlayer/MediaPlayer.h>
#import "MusicTableViewController.h"
#import "SSColorSetting.h"
#import "SSUtilities.h"
#import "SSGlobalSettings.h"
#import "GCDAsyncSocket.h"
#import "MeterTable.h"
#import "SSPhotoScanViewController.h"

@interface SSSpecialViewController ()

@end


@implementation SSSpecialViewController
{
    MeterTable meterTable;
    BOOL _isPlaying;
}

NSString *switchEffect = @"3";
int micSensitityState = 2;
int totalItemCount;
int itemPosition = 0;
int effectTypeSpecial = 1;

@synthesize acceleratorButton;          //
@synthesize userMediaItemCollection;	// the media item collection created by the user, using the media item picker
@synthesize musicPlayButton;            // the button for invoking Play on the music player
@synthesize musicNextButton;
@synthesize microphoneButton;			// the button for invoking the microphone feature
@synthesize microphoneSensitivityButton;
@synthesize photosButton;
@synthesize musicPlayer;				// the music player, which plays media items from the iPod library
@synthesize addMusicButton;		// the button for invoking the media item picker. if the user has already
@synthesize interruptedOnPlayback;		// A flag indicating whether or not the application was interrupted during
@synthesize playing;					// An application that responds to interruptions must keep track of its playing/

#pragma Button Manager Methods________________________________
//////////////////////////////////////////////
// Button Manager Methods.,
//////////////////////////////////////////////
- (void)stateManager :(NSString*) selectedFeature
{
    if (![selectedFeature isEqual: @"tilt"])
    {
        [self accelerometerStop];
    }
    if (!([selectedFeature isEqual: @"mic"]))
    {
        [self recorderStop];
    }
    if (!([selectedFeature isEqual: @"music"]))
    {
        [self musicStop];
    }
    if (!([selectedFeature isEqual: @"photo"]))
    {
        //stop photo feature
    }
}

#pragma Button Manager Methods________________________________
//////////////////////////////////////////////
// Effect Segment Methods
//////////////////////////////////////////////
-(IBAction)selectEffect:(id)sender
{
	if(effectsSegment.selectedSegmentIndex == 0)
    {
        effectTypeSpecial = 1;
	}
    
	if(effectsSegment.selectedSegmentIndex == 1)
    {
        effectTypeSpecial = 2;
	}
    
    if(effectsSegment.selectedSegmentIndex == 2)
    {
        effectTypeSpecial = 3;
	}
    
    if(effectsSegment.selectedSegmentIndex == 3)
    {
        effectTypeSpecial = 4;
	}
    
}

#pragma mark accelerometer Methods________________________________
//////////////////////////////////////////////
// Accelerometer Methods
//////////////////////////////////////////////

- (IBAction)accelerometerToggle:(id)sender
{
    if ([UIAccelerometer sharedAccelerometer].delegate == nil)
    {
        [self accelerometerStart];
    }
    else
    {
        [self accelerometerStop];
    }
}

-(void)accelerometerStart
{
    [self stateManager :@"tilt"];
    
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:0.2];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
    
    self.featureDescription.text = @"Tilt Adjust";
}

-(void)accelerometerStop
{
    [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
    
    self.featureDescription.text = @"Tilt Adjust Off";
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
    NSString *lwdpPacket = [utils createLwdpPacket:@"11" :colorHex];

    NSLog(@"accelerometer: lwdpPacket: %@", lwdpPacket);   
    [conn sendPacket:lwdpPacket];

}

#pragma mark Microphone Methods________________________________
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
    
    
    if (recordTimer == nil)
    {
        recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
        if (recorder)
        {
            [self recorderStart];
        }
        else
        {
           // NSLog([@"error description: %@",error]);
        }
    }
    else
    {
        [self recorderStop];
    }
}

- (IBAction)microphoneSensitivity:(id)sender
{
    if (micSensitityState == 1) // if it is currently set to soft
    {
        micSensitityState = 2;
    }
    else if (micSensitityState == 2) //if it is currently set to loud
    {
        micSensitityState = 1;
    }
}

-(void)recorderStop
{
    [recorder stop];
    recorder = nil;
    if(recordTimer)
    {
        [recordTimer invalidate];
        recordTimer = nil;
    }
    self.featureDescription.text = @"Mic Off";
}

-(void)recorderStart
{
    [self stateManager:@"mic"];
    [recorder prepareToRecord];
    recorder.meteringEnabled = YES;
    [recorder record];
    recordTimer = [NSTimer scheduledTimerWithTimeInterval: 0.05 target: self selector: @selector(recordTimerCallback:) userInfo: nil repeats: YES];
    self.featureDescription.text = @"Microphone";
}

- (void)recordTimerCallback:(NSTimer *)timer
{
    float scale = 0.1; //0.5
    if (recorder.isRecording)
    {
        [recorder updateMeters];
        
        float power = 0.0f;
        power += [recorder averagePowerForChannel:0];
        
        float level = meterTable.ValueAt(power);
        scale = level * 5 * micSensitityState; //adjust to whether we are using soft or loud sensitivity
        if (scale > 5) //make sure we do not have a number that evenuatually calculates about 255.
        {
            scale = 5;
        }
    }
    
    NSLog(@"musicTimerCallback: scale: %f", scale);
    
    [self sendSoundEffect:scale:effectTypeSpecial];

}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
    NSLog (@"audioRecorderDidFinishRecording:successfully:");
    // your actions here
}

//////////////////////////////////////////////
// Music Player Methods
//////////////////////////////////////////////

#pragma mark Music control________________________________

// A toggle control for playing or pausing iPod library music playback, invoked
//		when the user taps the 'playBarButton' in the Navigation bar.
- (IBAction) musicToggle:(id)sender
{
    if (_isPlaying)
    {
        [self musicPause];
    }
    else
    {
        [self musicPlay];
    }
    //_isPlaying = !_isPlaying;
}

-(void)musicPlay
{
    [_audioPlayer play];
    [self stateManager:@"music"];
    self.featureDescription.text = @"Music";
    
    _audioPlayer.meteringEnabled = YES;
    _isPlaying = true;
    
    musicTimer = [NSTimer scheduledTimerWithTimeInterval: 0.05 target: self selector: @selector(musicTimerCallback:) userInfo: nil repeats: YES];
}

-(void)musicStop
{
    // Pause audio here
    [_audioPlayer stop];
    self.featureDescription.text = @"Music Stopped";
    //[_toolBar setItems:_playItems];  // toggle play/pause button
    if (musicTimer)
    {
        [musicTimer invalidate];
        musicTimer = nil;
    }
    _isPlaying = false;
}

-(void)musicPause
{
    // Pause audio here
    [_audioPlayer pause];
    self.featureDescription.text = @"Music Paused";
    //[_toolBar setItems:_playItems];  // toggle play/pause button
    if (musicTimer)
    {
        [musicTimer invalidate];
        musicTimer = nil;
    }
    _isPlaying = false;
}

-(IBAction)nextSong:(id)sender
{
    [self musicStop];
    
    itemPosition = itemPosition + 1;
    if (itemPosition < totalItemCount)
    {
        MPMediaItem *item = [[self.userMediaItemCollection items] objectAtIndex:itemPosition];
        NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
        // Play the item using AVPlayer
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [self musicPlay];
    }
    else
    {
        [self musicStop];
    }

}

// If there is no selected media item collection, display the media item picker. If there's
// already a selected collection, display the list of selected songs.
- (IBAction) addMusic:(id)sender
{
	// if the user has already chosen some music, display that list
	if (userMediaItemCollection) {
        
		MusicTableViewController *controller = [[MusicTableViewController alloc] initWithNibName: @"MusicTableView" bundle: nil];
		
        controller.delegateMP = self;
		controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		
		[self presentModalViewController: controller animated: YES];
        
        // else, if no music is chosen yet, display the media item picker
	} else {
        
		MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
		
		picker.delegate						= self;
		picker.allowsPickingMultipleItems	= YES;
		picker.prompt						= NSLocalizedString (@"Add songs to play", "Prompt in media item picker");
		
		// The media item picker uses the default UI style, so it needs a default-style status bar to match it visually
		[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault animated: YES];
		
		[self presentModalViewController: picker animated: YES];
	}
    
    totalItemCount = userMediaItemCollection.count;
}

// Invoked by the delegate of the media item picker when the user is finished picking music.
//		The delegate is either this class or the table view controller, depending on the
//		state of the application.
- (void) updatePlayerQueueWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection
{    
	// Configure the music player, but only if the user chose at least one song to play
	if (mediaItemCollection) {
        
		// If there's no playback queue yet...
		if (userMediaItemCollection == nil)
        {
			// apply the new media item collection as a playback queue for the music player
			[self setUserMediaItemCollection: mediaItemCollection];
			[musicPlayer setQueueWithItemCollection: userMediaItemCollection];
            [self stateManager:@"music"];
            self.featureDescription.text = @"Music Paused";
            
        // Obtain the music player's state so it can then be restored after updating the playback queue.
		}
        else
        {
			// Combine the previously-existing media item collection with the new one
			NSMutableArray *combinedMediaItems	= [[userMediaItemCollection items] mutableCopy];
			NSArray *newMediaItems				= [mediaItemCollection items];
			[combinedMediaItems addObjectsFromArray: newMediaItems];
			
			[self setUserMediaItemCollection: [MPMediaItemCollection collectionWithItems: (NSArray *) combinedMediaItems]];

			// Apply the new media item collection as a playback queue for the music player.
			[musicPlayer setQueueWithItemCollection: userMediaItemCollection];
            totalItemCount = userMediaItemCollection.count;	
		}
        
		[addOrShowMusicButton	setTitle: NSLocalizedString (@"Show Music", @"Alternate title for 'Add Music' button, after user has chosen some music")
                              forState: UIControlStateNormal];
	}
}

#pragma mark Media item picker delegate methods________

// Invoked when the user taps the Done button in the media item picker after having chosen one or more media items to play.
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{
	// Dismiss the media item picker.
	[self dismissModalViewControllerAnimated: YES];
	
	// Apply the chosen songs to the music player's queue.
	[self updatePlayerQueueWithMediaCollection: mediaItemCollection];
    
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated: YES];
    
    MPMediaItem *item = [[mediaItemCollection items] objectAtIndex:itemPosition];
    NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];

    totalItemCount = mediaItemCollection.count;
    
    // Play the item using AVPlayer
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self stateManager:@"music"];
    self.featureDescription.text = @"Music Paused";
}

// Invoked when the user taps the Done button in the media item picker having chosen zero media items to play
- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{    
	[self dismissModalViewControllerAnimated: YES];
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated: YES];
}

#pragma mark Music Table view delegate methods________________

// Invoked when the user taps the Done button in the table view.
- (void) musicTableViewControllerDidFinish: (MusicTableViewController *) controller
{	
	[self dismissModalViewControllerAnimated: YES];
}

#pragma mark Music Send Packet Update methods________________

- (void)musicTimerCallback:(NSTimer *)timer
{
    float scale = 0.1; //0.5
    if (_audioPlayer.playing )
    {
        [_audioPlayer updateMeters];
        
        float power = 0.0f;
        for (int i = 0; i < [_audioPlayer numberOfChannels]; i++) {
            power += [_audioPlayer averagePowerForChannel:i];
        }
        power /= [_audioPlayer numberOfChannels];
        
        float level = meterTable.ValueAt(power);
        scale = level * 5;
    }
    
    NSLog(@"musicTimerCallback: scale: %f", scale);
    
    [self sendSoundEffect:scale:effectTypeSpecial];
}

-(void)sendSoundEffect: (float) scale :(int) effectTypeSelected
{
    int redInt;
    int greenInt;
    int blueInt;

    NSString *lwdpPacket;

        
    if (effectTypeSelected == 2)  // Black to Red for intensity
    {
        redInt = abs((int) (scale * 50));
        greenInt = 0;
        blueInt = 0;
        NSString *colorHex = [utils createHexColorFromIntColors:redInt :greenInt :blueInt];
        //  NSLog(@"recordTimerCallback: colorHex: %@", colorHex);
        lwdpPacket = [utils createLwdpPacket:@"11" :colorHex];
    }
    else if (effectTypeSelected == 3) // Blue to Red for intensity
    {
        redInt = abs((int) (scale * 50));
        greenInt = 0;
        blueInt = abs((int) (255 - (scale * 60)));
        NSString *colorHex = [utils createHexColorFromIntColors:redInt :greenInt :blueInt];
        //  NSLog(@"recordTimerCallback: colorHex: %@", colorHex);
        lwdpPacket = [utils createLwdpPacket:@"11" :colorHex];
    }
     else if (effectTypeSelected == 4)  // Candy cane blue and red to green for intensity
     {
         redInt = 0;
         greenInt = abs((int) (scale * 50));
         blueInt = abs((int) (255 - (scale * 60)));
         NSString *colorHex = [utils createHexColorFromIntColors:redInt :greenInt :blueInt];
         
         redInt = abs((int) (255 - (scale * 60)));
         greenInt = abs((int) (scale * 50)); 
         blueInt = 0;

         NSString *colorHex2 =  [utils createHexColorFromIntColors:redInt :greenInt :blueInt];
         
         NSString *hexEffectType = @"0000";
         NSString *hexTimeSeperation = @"0000";
         
         NSString *payLoad = [NSString stringWithFormat:@"%@%@%@%@%@",hexEffectType,hexTimeSeperation,@"02",colorHex, colorHex2];
         //  NSLog(@"recordTimerCallback: colorHex: %@", colorHex);
         lwdpPacket = [utils createLwdpPacket:@"20" :payLoad];
     }
    else // Candy cane blue and green to red for intensity
    {
        redInt = abs((int) (scale * 50));
        greenInt = 0;
        blueInt = abs((int) (255 - (scale * 60)));
        NSString *colorHex = [utils createHexColorFromIntColors:redInt :greenInt :blueInt];
        
        redInt = abs((int) (scale * 50));
        greenInt = abs((int) (255 - (scale * 60)));
        blueInt = 0;

        NSString *colorHex2 =  [utils createHexColorFromIntColors:redInt :greenInt :blueInt];
        
        NSString *hexEffectType = @"0000";
        NSString *hexTimeSeperation = @"0000";
        
        NSString *payLoad = [NSString stringWithFormat:@"%@%@%@%@%@",hexEffectType,hexTimeSeperation,@"02",colorHex, colorHex2];
        //  NSLog(@"recordTimerCallback: colorHex: %@", colorHex);
        lwdpPacket = [utils createLwdpPacket:@"20" :payLoad];
    }

    //  NSLog(@"recordTimerCallback: lwdpPacket: %@", lwdpPacket);
    
    [conn sendPacket:lwdpPacket];
}

//////////////////////////////////////////////
// Photo Scan Methods
//////////////////////////////////////////////

- (IBAction)photoScan:(id)sender
{
    
    UIImagePickerController *imagePickController=[[UIImagePickerController alloc]init];
    imagePickController.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickController.delegate=self;
    imagePickController.allowsEditing=true;
    [self presentModalViewController:imagePickController animated:YES];
    
    //if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    view = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 280, 280)];


    NSString *mediaType = info[UIImagePickerControllerMediaType];

    image = [info valueForKey:UIImagePickerControllerEditedImage];
    
    SSPhotoScanViewController *photoScanView = [[SSPhotoScanViewController alloc] initWithNibName:@"SSPhotoScanViewController" bundle:nil];

    photoScanView.view = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 280, 280)];
    
    [picker pushViewController:photoScanView animated:YES];
    
    imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(20, 20, 280, 280);
    [photoScanView.view addSubview:imageView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:photoScanView action:@selector(endPhotoScan:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"done" forState:UIControlStateNormal];
    button.frame = CGRectMake(140.0, 330.0, 80.0, 25.0);
    [photoScanView.view addSubview:button];
      
    
}


#pragma mark View, Config and UI Methods____________________________

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //////////////////////////////////////////////
    // Connection Configuration
    //////////////////////////////////////////////
    
    conn = [[SSConnection alloc] init];
    utils = [[SSUtilities alloc] init];
    
    //////////////////////////////////////////////
    // UI Configuration
    //////////////////////////////////////////////
    
    self.featureDescription.text = @"";
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    _featureDescription.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _featureDescription.layer.borderWidth = 1.5;
    _featureDescription.layer.cornerRadius = 8;

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tapRecognizer];
    [microphoneSensitivityButton setTitle: @"soft" forState: UIControlStateNormal];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{

}


-(void)viewDidDisappear:(BOOL)animated
{
    //Changing views so turn off everything that is currentoy running.
    [self musicStop];
    [self recorderStop];
    [self accelerometerStop];
    
    self.featureDescription.text = @"";
}

-(void)tap:(UITapGestureRecognizer *)gr
{
    [self.view endEditing:YES];
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

@end
