//
//  ContentView.h
//  Shake4Beauty
//
//  Created by Ping on 13-7-19.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.//

#import <UIKit/UIKit.h>
#import "ContentScrollView.h"
#import "HttpRequest.h"
@interface ContentView : UIView<ContentScrollViewDelegate,HttpRequestDelegate>{

    ContentScrollView *scroller;
    UIView *ctrlBoard;
    UIButton *likeBtn_ctrlBoard;
    
    NSArray *imageArr ;
    
    BOOL ISLIKED;
    
}
@property (nonatomic)    BOOL ISLIKED;

- (id)initWithFrame:(CGRect)frame andPage:(NSArray*)arr;
- (void)show1Page:(int)page_num;

@end
