//
//  UTSoundButton.m
//  SheetMaker
//
//  Created by Yusuke Iwama on 1/25/14.
//  Copyright (c) 2014 COINS Project AID. All rights reserved.
//

#import "UTSoundButton.h"

@implementation UTSoundButton

+ (id)buttonAtPoint:(CGPoint)point
{
	UTSoundButton *button = [super buttonWithType:UIButtonTypeCustom];
	if (button) {
		CGFloat buttonRadius = 22.0;
		button.frame = CGRectMake(point.x - buttonRadius,
								  point.y - buttonRadius,
								  2 * buttonRadius, 2 * buttonRadius);
		button.layer.borderColor = [[UIColor blackColor] CGColor];
		button.layer.borderWidth = 1.0;
		button.layer.cornerRadius = buttonRadius;
	}
	return button;
}

@end
