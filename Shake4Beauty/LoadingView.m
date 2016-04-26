//
//  LoadingView.m
//  Shake4Beauty
//
//  Created by Ping on 13-8-25.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.//

#import "LoadingView.h"
#import <QuartzCore/QuartzCore.h>

@implementation LoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        //圆角化 =========
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        //===============
        UIImageView *BG = [[UIImageView alloc]initWithFrame:self.bounds];
        BG.backgroundColor = [UIColor blackColor];
        BG.alpha = 0.5;
        [self addSubview:BG];
        [BG release];
        
        loadingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        loadingIndicator.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        [self addSubview:loadingIndicator];

    }
    return self;
}

- (void)startLoading{
    [loadingIndicator startAnimating];
    self.hidden = NO;
}

- (void)stopLoading{
    [loadingIndicator stopAnimating];
    self.hidden = YES;
}

- (BOOL)isLoading{
    return [loadingIndicator isAnimating];
}

- (void)dealloc
{
    [loadingIndicator release];
    [super dealloc];
}


@end
