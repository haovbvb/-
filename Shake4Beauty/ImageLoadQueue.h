//
//  ImageLoadQueue.h
//  WaterFall_demo
//
//  Created by Ping on 13-7-19.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageLoader.h"


@protocol ImageLoadQueueDelegate <NSObject>

- (void)imageQueueLoading:(UIImage*)image WithContext:(id)context;

@end
@interface ImageLoadQueue : NSObject<ImageLoaderDelegate>{

    id<ImageLoadQueueDelegate> imageLoadQueueDelegate;
}

- (id)initWithDelegate:(id<ImageLoadQueueDelegate>)delegate;

// url 可以是url数组 也可以是单个url
- (void)loadQueueFromUrl:(id)url;
@end
