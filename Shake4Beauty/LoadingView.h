//
//  LoadingView.h
//  Shake4Beauty
//
//  Created by Ping on 13-8-25.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView{
    UIActivityIndicatorView *loadingIndicator;
}

- (void)startLoading;

- (void)stopLoading;

- (BOOL)isLoading;


@end
