//
//  ImageLoadQueue.m
//  WaterFall_demo
//
//  Created by Ping on 13-7-19.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.//

#import "ImageLoadQueue.h"


@implementation ImageLoadQueue


- (id)initWithDelegate:(id<ImageLoadQueueDelegate>)delegate
{
    self = [super init];
    if (self) {
        imageLoadQueueDelegate = delegate;
    }
    return self;
}



//- (void)loadQueueFromUrl:(NSArray*)urlArr{
//    
//}
- (void)loadQueueFromUrl:(id)url{
    if ([url isKindOfClass:[NSArray class]]) {
        for (NSString *urlStr in url) {
            [self loadQueueFromUrl:urlStr];
        }
    }else if ([url isKindOfClass:[NSString class]]) {
        ImageLoader *aLoader = [[ImageLoader alloc]initWithDelegate:self];
        [aLoader loadImageFromUrl:url];
        
//        [loadQueue setObject:aLoader forKey:url];
        
        [aLoader release];
    }else {
        NSLog(@"url is not url!!!");
    }
}



#pragma mark ImageLoaderDelegate
- (void)loaderDidFinish:(UIImage*)image WithContext:(id)context{
    if (imageLoadQueueDelegate) {
        [imageLoadQueueDelegate imageQueueLoading:image WithContext:context];
    }
    
}

@end
