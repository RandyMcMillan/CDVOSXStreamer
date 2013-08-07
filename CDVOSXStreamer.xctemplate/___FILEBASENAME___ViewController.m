/*
 *   Licensed to the Apache Software Foundation (ASF) under one
 *   or more contributor license agreements.  See the NOTICE file
 *   distributed with this work for additional information
 *   regarding copyright ownership.  The ASF licenses this file
 *   to you under the Apache License, Version 2.0 (the
 *   "License"); you may not use this file except in compliance
 *   with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing,
 *   software distributed under the License is distributed on an
 *   "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *   KIND, either express or implied.  See the License for the
 *   specific language governing permissions and limitations
 *   under the License.
 *
 *      ___FILEBASENAME___
 *      ___FILEBASENAME___ Template Created ___DATE___.
 *      Copyright 2013 @RandyMcMillan
 *
 *     Created by ___FULLUSERNAME___ on ___DATE___.
 *     Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
 */
#include <sys/types.h>
#include <sys/sysctl.h>
#import "___FILEBASENAME___ViewController.h"

#import "AudioStreamer.h"
#import <QuartzCore/CoreAnimation.h>


@implementation ___FILEBASENAME___ViewController

@synthesize imageURL, isImage;
@synthesize delegate, orientationDelegate;
// @synthesize spinner, webView, addressLabel;
@synthesize closeBtn, refreshBtn, backBtn, fwdBtn, safariBtn;
@synthesize webView;


+ (NSString *)resolveImageResource:(NSString *)resource
{
	size_t size;

	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	NSString *modelVersion = [NSString stringWithUTF8String:machine];
	free(machine);

	NSString	*systemVersion	= modelVersion;
	BOOL		isLessThaniOS4	= ([systemVersion compare:@"4.0" options:NSNumericSearch] == NSOrderedAscending);

	/*
	 *
	 *   float displayScale = 1;
	 *   if ([[NSScreen mainScreen] respondsToSelector:@selector(backingScaleFactor)]) {
	 *   NSArray *screens = [NSScreen screens];
	 *   for (int i = 0; i < [screens count]; i++) {
	 *   float s = [[screens objectAtIndex:i] backingScaleFactor];
	 *   if (s > displayScale)
	 *   displayScale = s;
	 *   }
	 *   }
	 *
	 */

	if (isLessThaniOS4) {
		return [NSString stringWithFormat:@"%@.png", resource];
	} else {
		if (([[NSScreen mainScreen] respondsToSelector:@selector(backingScaleFactor)] == YES) && ([[NSScreen mainScreen] backingScaleFactor] == 2.00)) {
			return [NSString stringWithFormat:@"%@@2x.png", resource];
		}
	}

	return resource;// if all else fails
}

- (___FILEBASENAME___ViewController *)initWithScale:(BOOL)enabled
{
	self = [super init];
	self.scaleEnabled = enabled;
	return self;
}

- (void)windowWillLoad
{
	NSLog(@"____windowWillLoad____");
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
	NSString *aDisplayName = @"display NAME";

	displayName = aDisplayName;
	return displayName;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)windowDidLoad
{
	// [self.window setTitle:[self windowTitleForDocumentDisplayName:nil]];
	[self.window setTitle:@""];
	[self.window setBackgroundColor:[NSColor colorWithCalibratedWhite:0.423 alpha:1.000]];
	[super windowDidLoad];

	[self.refreshBtn setImage:[NSImage imageNamed:[[self class] resolveImageResource:@"___FILEBASENAME___.bundle/but_refresh"]]];
	[self.backBtn setImage:[NSImage imageNamed:[[self class] resolveImageResource:@"___FILEBASENAME___.bundle/arrow_left"]]];
	[self.fwdBtn setImage:[NSImage imageNamed:[[self class] resolveImageResource:@"___FILEBASENAME___.bundle/arrow_right"]]];
	[self.safariBtn setImage:[NSImage imageNamed:[[self class] resolveImageResource:@"___FILEBASENAME___.bundle/compass"]]];

	// self.webView.delegate			= self;
	// self.webView.scalesPageToFit	= TRUE;
	// self.webView.backgroundColor	= [UIColor whiteColor];
	NSLog(@"_______Window did load_______");
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	// [super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

- (void)WindowDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	NSLog(@"View did UN-load");
}

- (void)dealloc
{
	// self.webView.delegate		= nil;
	self.delegate				= nil;
	self.orientationDelegate	= nil;

#if !__has_feature(objc_arc)
		self.webView		= nil;
		self.closeBtn		= nil;
		self.refreshBtn		= nil;
		self.addressLabel	= nil;
		self.backBtn		= nil;
		self.fwdBtn			= nil;
		self.safariBtn		= nil;
		self.spinner		= nil;

		[super dealloc];
#endif
    
    [self destroyStreamer];
	if (progressUpdateTimer)
	{
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;
	}
    
#if !__has_feature(objc_arc)
    
	[super dealloc];
    
#endif

    
    
}

- (void)closeBrowser
{
	NSLog(@"closeBrowser");

	if (self.delegate != nil) {
		[self.delegate onClose];
	}

	if ([self respondsToSelector:@selector(presentingViewController)]) {
		// Reference UIViewController.h Line:179 for update to iOS 5 difference - @RandyMcMillan
		// [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
	} else {
		// [[self parentViewController] dismissModalViewControllerAnimated:YES];
	}

	// has to do with stopping media playback when window is hidden
	NSString *htmlText = @"<html><body style='background-color:transparent;margin:0px;padding:0px;'><img style='min-height:200px;margin:0px;padding:0px;width:100%;height:100%;' alt='' src='IMGSRC'/></body></html>";
	htmlText = [htmlText stringByReplacingOccurrencesOfString:@"IMGSRC" withString:@""];

	[self.webView.mainFrame loadHTMLString:htmlText baseURL:[NSURL URLWithString:self.savedURL]];

	[self.webView.backForwardList setCapacity:0];

	self.contentView.window.isVisible = FALSE;
}

- (IBAction)onDoneButtonPress:(id)sender
{
	[self closeBrowser];
	// NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]];
	// [self.webView loadRequest:request];
}

- (IBAction)onSafariButtonPress:(id)sender
{
	if (self.delegate != nil) {
		[self.delegate onOpenInSafari];
	}

	if (self.isImage) {
		NSURL *pURL = [NSURL URLWithString:self.imageURL];
		//	[[NSApplication sharedApplication] openURL:pURL];
	} else {
		// NSURLRequest *request = self.webView.request;
		// [[NSApplication sharedApplication] openURL:request.URL];
	}
}

- (void)loadURL:(NSString *)url
{
	NSLog(@"Opening Url : %@", url);
	self.savedURL = url;
	[self.webView.backForwardList setCapacity:10];

	if ([url hasPrefix:@"http://"]) {
		if ([url hasSuffix:@".png"] ||
			[url hasSuffix:@".jpg"] ||
			[url hasSuffix:@".jpeg"] ||
			[url hasSuffix:@".bmp"] ||
			[url hasSuffix:@".gif"]) {
			self.imageURL	= nil;
			self.imageURL	= url;
			self.isImage	= YES;
			NSString *htmlText = @"<html><body style='background-color:#717171;margin:0px;padding:0px;'><img style='min-height:200px;margin:0px;padding:0px;width:100%;height:auto;' alt='' src='IMGSRC'/></body></html>";
			htmlText = [htmlText stringByReplacingOccurrencesOfString:@"IMGSRC" withString:url];

			[self.webView.mainFrame loadHTMLString:htmlText baseURL:[NSURL URLWithString:@""]];
		} else {
			self.imageURL	= @"";
			self.isImage	= NO;

			NSLog(@"url sent from html = %@ ", url);
			NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
			[self.webView.mainFrame loadRequest:request];
		}
	} else {
		NSLog(@"Local url sent from html = %@ ", url);
		NSURLRequest *request = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:url ofType:nil inDirectory:@"www"]];
		NSLog(@"Local request sent from html = %@ ", request);
		[self.webView.mainFrame loadRequest:[NSURLRequest requestWithURL:request]];
	}

	self.webView.hidden = NO;
}

- (void)webViewDidStartLoad:(WebView *)sender
{
	self.addressLabel.stringValue	= @"Loading...";
	self.backBtn.enabled			= self.webView.canGoBack;
	self.fwdBtn.enabled				= self.webView.canGoForward;

	//	[self.spinner startAnimating];
}

- (void)webViewDidFinishLoad:(WebView *)sender
{
	NSLog(@"New Address is : %@", self.webView.mainFrameURL);
	self.addressLabel.stringValue = self.webView.mainFrameURL;	// [command.arguments objectAtIndex:0];

	self.backBtn.enabled	= self.webView.canGoBack;
	self.fwdBtn.enabled		= self.webView.canGoForward;
	// [self.spinner stopAnimating];

	if (self.delegate != NULL) {
		[self.delegate onChildLocationChange:self.webView.mainFrameURL];
	}
}

/*- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error {
 *    NSLog (@"webView:didFailLoadWithError");
 *    [spinner stopAnimating];
 *    addressLabel.text = @"Failed";
 *    if (error != NULL) {
 *        UIAlertView *errorAlert = [[UIAlertView alloc]
 *                                   initWithTitle: [error localizedDescription]
 *                                   message: [error localizedFailureReason]
 *                                   delegate:nil
 *                                   cancelButtonTitle:@"OK"
 *                                   otherButtonTitles:nil];
 *        [errorAlert show];
 *        [errorAlert release];
 *    }
 *   }
 */

#pragma mark CDVOrientationDelegate

- (BOOL)shouldAutorotate
{
	if ((self.orientationDelegate != nil) && [self.orientationDelegate respondsToSelector:@selector(shouldAutorotate)]) {
		return [self.orientationDelegate shouldAutorotate];
	}

	return YES;
}


- (void)awakeFromNib
{
	[downloadSourceField setStringValue:@"http://www.largesound.com/ashborytour/sound/brobob.mp3"];
}

//
// setButtonImage:
//
// Used to change the image on the playbutton. This method exists for
// the purpose of inter-thread invocation because
// the observeValueForKeyPath:ofObject:change:context: method is invoked
// from secondary threads and UI updates are only permitted on the main thread.
//
// Parameters:
//    image - the image to set on the play button.
//
- (void)setButtonImage:(NSImage *)image
{
	[button.layer removeAllAnimations];
	if (!image)
	{
		[button setImage:[NSImage imageNamed:@"playbutton"]];
	}
	else
	{
		[button setImage:image];
		
		if ([button.image isEqual:[NSImage imageNamed:@"loadingbutton"]])
		{
			[self spinButton];
		}
	}
}

//
// destroyStreamer
//
// Removes the streamer, the UI update timer and the change notification
//
- (void)destroyStreamer
{
	if (streamer)
	{
		[[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:ASStatusChangedNotification
         object:streamer];
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;
		
		[streamer stop];
#if !__has_feature(objc_arc)
        
		[streamer release];
#endif
        
		streamer = nil;
	}
}

//
// createStreamer
//
// Creates or recreates the AudioStreamer object.
//
- (void)createStreamer
{
	if (streamer)
	{
		return;
	}
    
	[self destroyStreamer];
	
	NSString *escapedValue =
#if !__has_feature(objc_arc)
	
    [
     
#endif
     
     (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                           nil,
                                                                           (CFStringRef)[downloadSourceField stringValue],
                                                                           NULL,
                                                                           NULL,
                                                                           kCFStringEncodingUTF8))
     
#if !__has_feature(objc_arc)
     
     autorelease
#endif
#if !__has_feature(objc_arc)
     
     ]
#endif
    
    ;
    
	NSURL *url = [NSURL URLWithString:escapedValue];
	streamer = [[AudioStreamer alloc] initWithURL:url];
	
	progressUpdateTimer =
    [NSTimer
     scheduledTimerWithTimeInterval:0.1
     target:self
     selector:@selector(updateProgress:)
     userInfo:nil
     repeats:YES];
	[[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playbackStateChanged:)
     name:ASStatusChangedNotification
     object:streamer];
}

//
// spinButton
//
// Shows the spin button when the audio is loading. This is largely irrelevant
// now that the audio is loaded from a local file.
//
- (void)spinButton
{
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	CGRect frame = NSRectToCGRect([button frame]);
	button.layer.anchorPoint = CGPointMake(0.5, 0.5);
	button.layer.position = CGPointMake(frame.origin.x + 0.5 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
	[CATransaction commit];
    
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
	[CATransaction setValue:[NSNumber numberWithFloat:2.0] forKey:kCATransactionAnimationDuration];
    
	CABasicAnimation *animation;
	animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animation.fromValue = [NSNumber numberWithFloat:0.0];
	animation.toValue = [NSNumber numberWithFloat:-2 * M_PI];
	animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
	animation.delegate = self;
	[button.layer addAnimation:animation forKey:@"rotationAnimation"];
    
	[CATransaction commit];
}

//
// animationDidStop:finished:
//
// Restarts the spin animation on the button when it ends. Again, this is
// largely irrelevant now that the audio is loaded from a local file.
//
// Parameters:
//    theAnimation - the animation that rotated the button.
//    finished - is the animation finised?
//
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished
{
	if (finished)
	{
		[self spinButton];
	}
}

//
// buttonPressed:
//
// Handles the play/stop button. Creates, observes and starts the
// audio streamer when it is a play button. Stops the audio streamer when
// it isn't.
//
// Parameters:
//    sender - normally, the play/stop button.
//
- (IBAction)buttonPressed:(id)sender
{
	if ([button.image isEqual:[NSImage imageNamed:@"playbutton"]])
	{
		[downloadSourceField resignFirstResponder];
		
		[self createStreamer];
		[self setButtonImage:[NSImage imageNamed:@"loadingbutton"]];
		[streamer start];
	}
	else
	{
		[streamer stop];
	}
}

//
// playbackStateChanged:
//
// Invoked when the AudioStreamer
// reports that its playback status has changed.
//
- (void)playbackStateChanged:(NSNotification *)aNotification
{
	if ([streamer isWaiting])
	{
		[self setButtonImage:[NSImage imageNamed:@"loadingbutton"]];
	}
	else if ([streamer isPlaying])
	{
		[self setButtonImage:[NSImage imageNamed:@"stopbutton"]];
	}
	else if ([streamer isIdle])
	{
		[self destroyStreamer];
		[self setButtonImage:[NSImage imageNamed:@"playbutton"]];
	}
}

//
// sliderMoved:
//
// Invoked when the user moves the slider
//
// Parameters:
//    aSlider - the slider (assumed to be the progress slider)
//
- (IBAction)sliderMoved:(NSSlider *)aSlider
{
	if (streamer.duration)
	{
		double newSeekTime = ([aSlider doubleValue] / 100.0) * streamer.duration;
		[streamer seekToTime:newSeekTime];
	}
}

//
// updateProgress:
//
// Invoked when the AudioStreamer
// reports that its playback progress has changed.
//
- (void)updateProgress:(NSTimer *)updatedTimer
{
	if (streamer.bitRate != 0.0)
	{
		double progress = streamer.progress;
		double duration = streamer.duration;
		
		if (duration > 0)
		{
			[positionLabel setStringValue:
             [NSString stringWithFormat:@"Time Played: %.1f/%.1f seconds",
              progress,
              duration]];
			[progressSlider setEnabled:YES];
			[progressSlider setDoubleValue:100 * progress / duration];
		}
		else
		{
			[progressSlider setEnabled:NO];
		}
	}
	else
	{
		[positionLabel setStringValue:@"Time Played:"];
	}
}

//
// textFieldShouldReturn:
//
// Dismiss the text field when done is pressed
//
// Parameters:
//    sender - the text field
//
// returns YES
//
- (BOOL)textFieldShouldReturn:(NSTextField *)sender
{
	[sender resignFirstResponder];
	[self createStreamer];
	return YES;
}




@end
