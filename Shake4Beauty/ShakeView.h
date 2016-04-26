//
//  ShakeView.h
//  Shake4Beauty
//
//  Created by Ping on 13-8-13.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpRequest.h"
#import "WaterfallView.h"
#import "ImageLoadQueue.h"
#import "LoadingView.h"

#import <AVFoundation/AVFoundation.h>
@interface ShakeView : UIView<HttpRequestDelegate,ImageLoadQueueDelegate>{
    UIImageView *shakeImage1;
    UIImageView *shakeImage2;
    UIImageView *shakeBGimage;
    UIImageView *shakeViewBG;
    
    UILabel *shakeCount;
    UIButton *waterfallBack;
    
    WaterfallView *waterfallView;
    
    ImageLoadQueue *imageLoadQueue;
    LoadingView* loadingIndicator;
    
    
    AVAudioPlayer *player;
    
    
    BOOL waitFlag;
    
}

@property(nonatomic)BOOL    receiveSake;

@end
