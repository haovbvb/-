//
//  ContentScrollView.h
//  Shake4Beauty
//
//  Created by Ping on 13-7-19.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ShakeDetectedWindow.h"

@protocol ContentScrollViewDelegate <NSObject>

- (void)getOneTouched;
- (void)touchEnd;

@end
@interface ContentScrollView : UIScrollView<TapDetectingWindowDelegate>{
    int page_count;
    int current_page;
    
    
    UIWebView *pageView;
    ShakeDetectedWindow *mWindow;
}
- (id)initWithFrame:(CGRect)frame andPage:(NSArray*)arr;
- (void)show1Page:(int)page_num;
- (NSString*)getCurrentPageInfo;

@property (nonatomic)int current_page;
@property (nonatomic ,assign)id<ContentScrollViewDelegate>contentScrollViewDelegate;
@property (nonatomic,retain)NSArray *pagesArr;
@end

