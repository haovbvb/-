//
//  NewestView.m
//  Shake4Beauty
//
//  Created by Ping on 13-8-15.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "NewestView.h"
#import "UserInfo.h"

@implementation NewestView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        limit = 15;
        page = 1;
        sumCount = INT32_MAX;
        waterfallView = [[WaterfallView alloc]initWithFrame:self.bounds];
        waterfallView.waterfallViewDelegate = self;
        [self addSubview:waterfallView];
        loadingIndicator = [[LoadingView alloc]initWithFrame:CGRectMake(120, 300, 80, 80)];
        [self addSubview:loadingIndicator];
        
        imageLoadQueue = [[ImageLoadQueue alloc]initWithDelegate:self];
        [self requestImagesArr];
    
    }
    return self;
}

- (void)requestImagesArr{
    if ([loadingIndicator isLoading]) {
        return;
    }
    if ((page-1)*limit>=sumCount) {
        waterfallView.loading = NO;
        return;
    }
    [loadingIndicator startLoading];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:page++],@"page",
                          [NSNumber numberWithInt:limit],@"limit",
                          [UserInfo info].GoojjeID,@"id",
                          nil];
    
    HttpRequest *request = [[HttpRequest alloc]initWithDelegate:self];
    [request httpRequest:GetNewestImage method:@"POST" withPara:dict];
    [request release];

}
- (void)imageQueueLoading:(UIImage*)image WithContext:(id)context{
    NSArray *arr = [NSArray arrayWithObjects:image,context,nil];
    
    [waterfallView addWaterfallImage:arr];
    
    [loadingIndicator stopLoading];
}
- (void)httpRequestSuccess:(NSDictionary*)dict Name:(NSString*)name{
    if ([name isEqualToString:GetNewestImage]) {
        if ([[dict objectForKey:@"code"]intValue]==1) {
            NSArray *imageArr = [[[dict objectForKey:@"data"]objectAtIndex:0]objectForKey:@"list"];
            sumCount = [[[[dict objectForKey:@"data"]objectAtIndex:0]objectForKey:@"count"]intValue];
            [UserInfo imageDictFromArr:imageArr];
            NSMutableArray *addrArr = [NSMutableArray array];
            for (NSDictionary *imageDict in imageArr) {
                [addrArr addObject:[imageDict objectForKey:@"imgPath"]];
            }
            [imageLoadQueue loadQueueFromUrl:addrArr];
        }
    }
}

- (void)httpRequestfailed:(NSString*)errorInfo Name:(NSString*)name{

}

- (void)WaterfallViewScrollToEnd{
    
    [self requestImagesArr];

}





- (void)dealloc
{
    [loadingIndicator release];
    [waterfallView release];
    [imageLoadQueue release];
    [super dealloc];
}

@end
