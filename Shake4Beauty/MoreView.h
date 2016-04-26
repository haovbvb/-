//
//  MoreView.h
//  Shake4Beauty
//
//  Created by Ping on 13-8-16.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MoreViewDelegate <NSObject>

- (void)moreViewlogin;
- (void)moreViewDelCache;
- (void)moreViewlogout;

@end

@interface MoreView : UIView
- (id)initWithFrame:(CGRect)frame Withdelegate:(id<MoreViewDelegate>)delegate;
@property (nonatomic, assign)id<MoreViewDelegate> moreViewDelegate;
@end
