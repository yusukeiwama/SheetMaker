//
//  UTSoundButton.h
//  SheetMaker
//
//  Created by Yusuke Iwama on 1/25/14.
//  Copyright (c) 2014 COINS Project AID. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UTSoundButton : UIButton

@property NSString *soundFilePath; 

+ (id)buttonAtPoint:(CGPoint)point;

@end
