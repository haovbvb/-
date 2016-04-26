//
//  ShakeDetectedWindow.h
//  Shake4Beauty
//
//  Created by Ping on 13-8-25.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//


// Detect shake and  UIWebview's touch.


#import <UIKit/UIKit.h>
@protocol TapDetectingWindowDelegate
- (void)userDidTapWebView:(id)tapPoint;
@end
@interface ShakeDetectedWindow : UIWindow{
    UIView *viewToObserve;
    id <TapDetectingWindowDelegate> controllerThatObserves;
}
@property (nonatomic, retain) UIView *viewToObserve;
@property (nonatomic, assign) id <TapDetectingWindowDelegate> controllerThatObserves;
@end
