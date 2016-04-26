//
//  ContentView.m
//  Shake4Beauty
//
//  Created by Ping on 13-7-19.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "ContentView.h"
#import <QuartzCore/QuartzCore.h>
#import "UserInfo.h"
#import "NoticeName.h"

@implementation ContentView
@synthesize ISLIKED;
- (id)initWithFrame:(CGRect)frame andPage:(NSArray*)arr
{
    self = [super initWithFrame:frame];
    if (self) {

        
        scroller = [[ContentScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) andPage:arr];
        
        imageArr = [[NSArray alloc]initWithArray:arr];
        
        scroller.contentScrollViewDelegate = self;
        [self addSubview:scroller];
        self.backgroundColor = [UIColor whiteColor];
        
        
        ctrlBoard = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
        ctrlBoard.backgroundColor = [UIColor clearColor];
        UIImageView *bg_CtrlBoard = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)]autorelease];
        bg_CtrlBoard.backgroundColor = [UIColor blackColor];
        bg_CtrlBoard.alpha = 0.5;
        [ctrlBoard addSubview:bg_CtrlBoard];
        
        UIButton *backBtn_ctrlBoard = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn_ctrlBoard.frame = CGRectMake(10, 6, 52, 31);
        [backBtn_ctrlBoard setBackgroundImage:getPNGImage(@"title_back_normal") forState:UIControlStateNormal];
        [backBtn_ctrlBoard addTarget:self action:@selector(contentBack) forControlEvents:UIControlEventTouchUpInside];
        [ctrlBoard addSubview:backBtn_ctrlBoard];
        likeBtn_ctrlBoard = [UIButton buttonWithType:UIButtonTypeCustom];
        likeBtn_ctrlBoard.frame = CGRectMake(258, 6, 52, 31);
        [likeBtn_ctrlBoard setBackgroundImage:getPNGImage(@"title_collect_normal") forState:UIControlStateNormal];
        [likeBtn_ctrlBoard addTarget:self action:@selector(like) forControlEvents:UIControlEventTouchUpInside];
        [ctrlBoard addSubview:likeBtn_ctrlBoard];
        
        ctrlBoard.layer.opacity = 0;
        
        [self addSubview:ctrlBoard];
        
        
        ISLIKED = NO;
        
    }
    return self;
}

- (void)updateLikeBtn{
    if (ISLIKED) {
        [likeBtn_ctrlBoard setBackgroundImage:getPNGImage(@"title_collect_press") forState:UIControlStateNormal];
        return;
    }
    
    NSArray *image =[[UserInfo info].imageDict objectForKey:[[imageArr objectAtIndex:scroller.current_page]objectAtIndex:4]];
    NSLog(@"%@",image);
    if ([image count]==2) {
        if ([[image objectAtIndex:1]intValue]==-1||[[image objectAtIndex:1]intValue]==0) {
            [likeBtn_ctrlBoard setBackgroundImage:getPNGImage(@"title_collect_normal") forState:UIControlStateNormal];
        }else if([[image objectAtIndex:1]intValue]==1){
            [likeBtn_ctrlBoard setBackgroundImage:getPNGImage(@"title_collect_press") forState:UIControlStateNormal];
        }
    return;
    }
    [likeBtn_ctrlBoard setBackgroundImage:getPNGImage(@"title_collect_normal") forState:UIControlStateNormal];
}

- (void)like{
    if ([UserInfo info].GoojjeID==nil) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"您登录以后才可以喜欢" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    
    [likeBtn_ctrlBoard setBackgroundImage:getPNGImage(@"title_collect_press") forState:UIControlStateNormal];
    
    NSArray *imageInfoArr = [[UserInfo info].imageDict objectForKey:[scroller getCurrentPageInfo]];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UserInfo info].GoojjeID,@"uid",
                          [imageInfoArr objectAtIndex:0],@"lid",
                          nil];
    [self likeRequest:dict];
    
    NSArray *arr = [NSArray arrayWithObjects:[imageInfoArr objectAtIndex:0], [NSNumber numberWithInt:1], nil];
    [[UserInfo info].imageDict setObject:arr forKey:[scroller getCurrentPageInfo]];
}

- (void)likeRequest:(NSDictionary*)dict{
    HttpRequest *request = [[HttpRequest alloc]initWithDelegate:self];
    [request httpRequest:LikeAImage method:@"POST" withPara:dict];
    [request release];
}
- (void)httpRequestSuccess:(NSDictionary*)dict Name:(NSString*)name{

}
- (void)httpRequestfailed:(NSString*)errorInfo Name:(NSString*)name{

}
- (void)showCtrlBoard{
    if (fabs(ctrlBoard.layer.opacity-0)<0.0001) {
        CABasicAnimation *ctrlBoardShowd = [CABasicAnimation animationWithKeyPath:@"opacity"];
        ctrlBoardShowd.fromValue = [NSNumber numberWithFloat:0.1];
        ctrlBoardShowd.toValue = [NSNumber numberWithFloat:1];
        ctrlBoard.layer.opacity=1;
        ctrlBoardShowd.duration = 0.4;
        [ctrlBoard.layer addAnimation:ctrlBoardShowd forKey:nil];
    }
    [self performSelector:@selector(hideCtrlBoard) withObject:nil afterDelay:3];
}

- (void)hideCtrlBoard{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideCtrlBoard) object:nil];
    if (ctrlBoard.layer.opacity==1) {
        CABasicAnimation *ctrlBoardhided = [CABasicAnimation animationWithKeyPath:@"opacity"];
        ctrlBoardhided.fromValue = [NSNumber numberWithFloat:1];
        ctrlBoardhided.toValue = [NSNumber numberWithFloat:0.1];
        ctrlBoard.layer.opacity=0;
        ctrlBoardhided.duration = 0.4;
        [ctrlBoard.layer addAnimation:ctrlBoardhided forKey:nil];
    }
}

- (void)contentBack{
    [[NSNotificationCenter defaultCenter]postNotificationName:CONETENT_REMOVE object:nil];
    [self removeFromSuperview];
}


- (void)show1Page:(int)page_num{
    [scroller show1Page:page_num];
    [self updateLikeBtn];
}
- (void)touchEnd{
    [self updateLikeBtn];
}
- (void)getOneTouched{
    NSLog(@"getOneTouched");
   [self showCtrlBoard];
    
}



- (void)dealloc
{
    [imageArr release];
    [ctrlBoard release];
    [scroller release];
    [super dealloc];
}

@end
