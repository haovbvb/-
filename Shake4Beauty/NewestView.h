//
//  NewestView.h
//  Shake4Beauty
//
//  Created by Ping on 13-8-15.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpRequest.h"
#import "WaterfallView.h"
#import "ImageLoadQueue.h"
#import "LoadingView.h"

@interface NewestView : UIView<WaterfallViewDelegate,HttpRequestDelegate,ImageLoadQueueDelegate>{
    
    int page;
    int limit;
    
    int sumCount;
    
    WaterfallView *waterfallView;
    ImageLoadQueue *imageLoadQueue;
    
    LoadingView* loadingIndicator;
    
    
}

@end
