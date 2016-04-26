//
//  LikeView.m
//  Shake4Beauty
//
//  Created by Ping on 13-8-16.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "LikeView.h"
#import "UserInfo.h"
@implementation LikeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blueColor];
        UIImageView *bg_user = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)]autorelease];
        [bg_user setImage:getPNGImage(@"bg_list_normal_colour")];
        [self addSubview:bg_user];
        
        UILabel *nick = [[[UILabel alloc]initWithFrame:CGRectMake(45, 7, 100, 30)]autorelease];
        nick.backgroundColor = [UIColor clearColor];
        nick.text = [UserInfo info].GoojjeNickName;
        nick.textColor = [UIColor colorWithRed:180.0/255 green:180.0/255 blue:180.0/255 alpha:1];
        nick.font = [UIFont systemFontOfSize:13];
        [bg_user addSubview:nick];
        
        likeCountLabel = [[[UILabel alloc]initWithFrame:CGRectMake(250, 7, 100, 30)]autorelease];
        likeCountLabel.backgroundColor = [UIColor clearColor];
        likeCountLabel.textColor = [UIColor colorWithRed:180.0/255 green:180.0/255 blue:180.0/255 alpha:1];
        likeCountLabel.font = [UIFont systemFontOfSize:13];
        [bg_user addSubview:likeCountLabel];
        
        UIImageView *headShadow = [[[UIImageView alloc]initWithFrame:CGRectMake(7, 7, 30, 30)]autorelease];
        [headShadow setImage:getPNGImage(@"head_shadow")];
        [bg_user addSubview:headShadow];
        
        UIImageView *head = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 28, 28)]autorelease];
        head.center = headShadow.center;
        
        [head setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[UserInfo info].userHead]]]];
        [bg_user addSubview:head];
        if (head.image==nil) {
            [head setImage:[UIImage imageNamed:@"userphoto_default_180.png"]];
        }
        
        waterfallView = [[WaterfallView alloc]initWithFrame:CGRectMake(0, 44, 320, self.bounds.size.height-44)];
        waterfallView.waterfallViewDelegate = self;
        [self addSubview:waterfallView];
        
        
        imageLoadQueue = [[ImageLoadQueue alloc]initWithDelegate:self];
        page=1;
        likeCount = INT32_MAX;
        [self requestLikeImageArr];
        
        
    }
    return self;
}


- (void)requestLikeImageArr{// 这个接口每次反10张图.
    if ((page-1)*10>likeCount) {
        waterfallView.loading = NO;
        return;
    }
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UserInfo info].GoojjeID,@"userID",
                          [NSNumber numberWithInt:page++] ,@"p",
                          nil];
    
    HttpRequest *request = [[HttpRequest alloc]initWithDelegate:self];
    [request httpRequest:GetLikeImage method:@"GET" withPara:dict];
    [request release];
}

- (void)imageQueueLoading:(UIImage*)image WithContext:(id)context{
    NSArray *arr = [NSArray arrayWithObjects:image,context,nil];
    
    [waterfallView addWaterfallImage:arr];
}
- (void)httpRequestSuccess:(NSDictionary*)dict Name:(NSString*)name{
    if ([name isEqualToString:GetLikeImage]) {
        likeCountLabel.text = [NSString stringWithFormat:@"喜欢%d张",[[dict objectForKey:@"count"]intValue]];
        likeCount=[[dict objectForKey:@"count"]intValue];
        if ([[dict objectForKey:@"count"]intValue]>0) {
            
            NSArray *imageArr = [dict objectForKey:@"data"]; 
            NSMutableArray *addrArr = [NSMutableArray array];
            for (NSDictionary *imageDict in imageArr) {
                [addrArr addObject:[imageDict objectForKey:@"imageAdd"]];
            }
            [imageLoadQueue loadQueueFromUrl:addrArr];
        }
    }
}
- (void)httpRequestfailed:(NSString*)errorInfo Name:(NSString*)name{
    
}
- (void)WaterfallViewScrollToEnd{
    [self requestLikeImageArr];
}
@end
