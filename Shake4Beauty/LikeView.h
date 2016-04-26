//
//  LikeView.h
//  Shake4Beauty
//
//  Created by Ping on 13-8-16.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpRequest.h"
#import "WaterfallView.h"
#import "ImageLoadQueue.h"

@interface LikeView : UIView<WaterfallViewDelegate,HttpRequestDelegate,ImageLoadQueueDelegate>{
    int page;
    WaterfallView *waterfallView;
    ImageLoadQueue *imageLoadQueue;
    UILabel *likeCountLabel;
    int likeCount;
}

@end
