//
//  COINSViewController.m
//  SheetMaker
//
//  Created by Yusuke Iwama on 1/25/14.
//  Copyright (c) 2014 COINS Project AID. All rights reserved.
//

#import "COINSViewController.h"
#import "UTSoundButton.h"

@interface COINSViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *sheetImageView;

@end

@implementation COINSViewController {
	NSMutableArray	*_fields;
	AVAudioRecorder *_recorder;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	_fields = [NSMutableArray array];
	
	UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
	[self.sheetImageView addGestureRecognizer:panGestureRecognizer];
	
	UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
	[self.sheetImageView addGestureRecognizer:longPressGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)panAction:(id)sender
{
	static UIView *whiteView;
	if (whiteView == nil) {
		whiteView = [[UIView alloc] init];
		whiteView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
		whiteView.layer.borderWidth = 3.0;
		[self.sheetImageView addSubview:whiteView];
	}
	
	UIPanGestureRecognizer *pan = sender;
	NSLog(@"Location = (%5.1f, %5.1f), Translation = (%5.1f, %5.1f), State = %d", [pan locationInView:self.sheetImageView].x, [pan locationInView:self.sheetImageView].y, [pan translationInView:self.sheetImageView].x, [pan translationInView:self.sheetImageView].y, pan.state);
	
	// Update whiteView's frame
	if (pan.state == UIGestureRecognizerStateChanged) {
		whiteView.hidden = NO;
		whiteView.frame = CGRectMake([pan locationInView:self.sheetImageView].x - [pan translationInView:self.sheetImageView].x,
									 [pan locationInView:self.sheetImageView].y - [pan translationInView:self.sheetImageView].y,
									 [pan translationInView:self.sheetImageView].x,
									 [pan translationInView:self.sheetImageView].y);
	}
	
	// Add field
	if (pan.state == UIGestureRecognizerStateEnded) {
		whiteView.hidden = YES;
		CGRect frame = CGRectMake([pan locationInView:self.sheetImageView].x - [pan translationInView:self.sheetImageView].x,
								  [pan locationInView:self.sheetImageView].y - [pan translationInView:self.sheetImageView].y,
								  [pan translationInView:self.sheetImageView].x,
								  [pan translationInView:self.sheetImageView].y);
		UITextField *field = [[UITextField alloc] initWithFrame:frame];
		field.delegate = self;
		field.textAlignment = NSTextAlignmentCenter;
		field.backgroundColor	= [UIColor whiteColor];
		field.layer.borderColor	= [[UIColor blackColor] CGColor];
		field.layer.borderWidth	= 3.0;
		[_fields addObject:field];
		[self.sheetImageView addSubview:field];
	}
}

- (void)longPressAction:(id)sender
{
	UILongPressGestureRecognizer *longPressGestureRecognizer = sender;
	if (longPressGestureRecognizer.state != UIGestureRecognizerStateEnded) return;
	
	NSLog(@"Long pressed");
	
    NSArray *dirPaths;
    NSString *docsDir;
	
    dirPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
	
	// At this path the recorded audio will be saved.
    NSString *soundFilePath = [docsDir stringByAppendingPathComponent:@"sound.caf"];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    NSDictionary *settings = @{AVEncoderAudioQualityKey: @(AVAudioQualityMin),
                               AVNumberOfChannelsKey:    @1,
							   AVSampleRateKey:          @22050.0};
	
    NSError *error = nil;
	_recorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:settings error:&error];
	
    if ( !_recorder ) {
        UIAlertView *alert  =
        [[UIAlertView alloc] initWithTitle: @"Warning" message: [error localizedDescription] delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
	
    if ( error ) {
        NSLog( @"error: %@", [error localizedDescription] );
    } else {
        if ([_recorder prepareToRecord]) NSLog(@"succeeded in preparing");
        [self recordAudio];
	}
    
	CGPoint touchPoint = [longPressGestureRecognizer locationInView:self.sheetImageView];
    UTSoundButton *soundButton = [UTSoundButton buttonAtPoint:touchPoint];
    [self.sheetImageView addSubview:soundButton];
}

- (void)recordAudio
{
	if (!_recorder.recording)
	{
		_recorder.delegate = self;
		// FIXME: Can't record
		if ([_recorder recordForDuration:3.0]) NSLog(@"succeeded in recording");
	}
}

# pragma mark - AVAudioRecorderDelegate

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
	// Your code after sucessful recording;
	if (flag == false) {
		NSLog(@"fail to record");
	} else {
		NSLog(@"succeeded to record");
	}
	NSArray *dirPaths;
    NSString *docsDir;
	dirPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
	NSString *soundFilePath = [docsDir stringByAppendingPathComponent:@"sound.caf"];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
	AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
	[player play];
}
-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
	NSLog(@"Encode Error occurred");
}

# pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}


@end
