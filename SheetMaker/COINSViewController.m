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
	longPressGestureRecognizer.minimumPressDuration = 1.0;
	[self.sheetImageView addGestureRecognizer:longPressGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)panAction:(id)sender
{
	UIPanGestureRecognizer *pan = sender;
	NSLog(@"Location = (%5.1f, %5.1f), Translation = (%5.1f, %5.1f), State = %d", [pan locationInView:self.sheetImageView].x, [pan locationInView:self.sheetImageView].y, [pan translationInView:self.sheetImageView].x, [pan translationInView:self.sheetImageView].y, pan.state);
	
	if (pan.state == UIGestureRecognizerStateEnded) {
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
    //here i took cache directory as saved directory you can also take   NSDocumentDirectory
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
        [_recorder prepareToRecord];
//        [self recordAudio];
	}
    
    UTSoundButton *soundButton = [UTSoundButton buttonWithType:UIButtonTypeCustom];
    CGFloat buttonRadius = 22.0;
    soundButton.frame = CGRectMake([longPressGestureRecognizer locationInView:self.sheetImageView].x - buttonRadius,
                                   [longPressGestureRecognizer locationInView:self.sheetImageView].y - buttonRadius,
                                   2 * buttonRadius, 2 * buttonRadius);
    soundButton.layer.borderColor = [[UIColor blackColor] CGColor];
    soundButton.layer.borderWidth = 1.0;
    soundButton.layer.cornerRadius = buttonRadius;
    [self.sheetImageView addSubview:soundButton];
}

- (void)recordAudio
{
	if (!_recorder.recording)
	{
		_recorder.delegate = self;
		[_recorder recordForDuration:3.0];
	}
}

# pragma mark - AVAudioRecorderDelegate

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
	//Your code after sucessful recording;
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
