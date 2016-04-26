//
//  ShakeView.m
//  Shake4Beauty
//
//  Created by Ping on 13-8-13.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "ShakeView.h"
#import <QuartzCore/QuartzCore.h>
#import "UserInfo.h"
#import "NoticeName.h"
#import <AudioToolbox/AudioToolbox.h>



@implementation ShakeView
@synthesize receiveSake;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        receiveSake = YES;
        self.clipsToBounds = YES;
        shakeViewBG = [[UIImageView alloc]initWithFrame:self.bounds];
        [shakeViewBG setImage:getPNGImage(@"bg_shaking")];
        [self addSubview:shakeViewBG];
        
        shakeImage1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 193)];
        [shakeImage1 setImage:getPNGImage(@"bg_yaoyao_above")];
        shakeImage2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 193, 320, 223)];
        [shakeImage2 setImage:getPNGImage(@"bg_yaoyao_under")];
        
        shakeBGimage = [[UIImageView alloc]initWithImage:getPNGImage(@"bg_yaoyao_base_map")];
        shakeBGimage.frame = CGRectMake(0, 0, shakeBGimage.bounds.size.width/2, shakeBGimage.bounds.size.height/2);
        shakeBGimage.center = CGPointMake(self.center.x, shakeImage1.frame.size.height);
        
        shakeCount = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 50)];
        shakeCount.center = CGPointMake(self.center.x, 300);
        shakeCount.backgroundColor = [UIColor clearColor];
        shakeCount.textAlignment = UITextAlignmentCenter;
        shakeCount.textColor = [UIColor colorWithRed:180.0/255 green:180.0/255 blue:180.0/255 alpha:1];
        
        waterfallBack = [UIButton buttonWithType:UIButtonTypeCustom];
        [waterfallBack setImage:getPNGImage(@"list_unfold_normal") forState:UIControlStateNormal];
        [waterfallBack setImage:getPNGImage(@"list_unfold_press") forState:UIControlStateHighlighted];
        waterfallBack.frame = CGRectMake(0, 0, 320, 30);
        waterfallBack.hidden = YES;
        [waterfallBack addTarget:self action:@selector(hideWaterfallView) forControlEvents:UIControlEventTouchUpInside];
        
        
        [self addSubview:shakeBGimage];
        [self addSubview:shakeImage1];
        [self addSubview:shakeImage2];
        
        [self addSubview:shakeCount];
        
        [self addSubview:waterfallBack]; //这个放在最上层   waterfall 在add的时候要放在它下面
        
        loadingIndicator = [[LoadingView alloc]initWithFrame:CGRectMake(120, 300, 80, 80)];
        [self addSubview:loadingIndicator];

        
        
//        [self becomeFirstResponder];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shaked) name:SHAKE_DETECTED object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(openReceveShake) name:CONETENT_REMOVE object:nil];

        
        imageLoadQueue = [[ImageLoadQueue alloc]initWithDelegate:self];
        [self requestShakeImageArr];
        
        
        
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"dance" ofType:@"mp3"]] error:nil];
    }
    return self;
}



- (void)openReceveShake{
    receiveSake = YES;
}

- (void)hideWaterfallView{
    waterfallBack.hidden = YES;
    [self animationWaterfallClosing];
    
}
- (void)animationWaterfallClosing{
    CABasicAnimation *waterfallClosing = [CABasicAnimation animationWithKeyPath:@"position"];
    waterfallClosing.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    waterfallClosing.duration = 0.5;
    waterfallClosing.toValue = [NSValue valueWithCGPoint:CGPointMake(self.center.x, self.bounds.size.height+waterfallView.bounds.size.height/2)];
    waterfallClosing.fromValue = [NSValue valueWithCGPoint:self.center];
    [waterfallView.layer addAnimation:waterfallClosing forKey:nil];
    waterfallView.center = CGPointMake(self.center.x, self.bounds.size.height+waterfallView.bounds.size.height/2);
}
- (void)animationAfterShaking{
    float offset = shakeBGimage.bounds.size.height/2;
    float duration = 0.4;
    CABasicAnimation *shakeImage1Animation = [CABasicAnimation animationWithKeyPath:@"position"];
    shakeImage1Animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    shakeImage1Animation.delegate = self;
    shakeImage1Animation.duration = duration;
    shakeImage1Animation.autoreverses = YES;
    shakeImage1Animation.fromValue = [NSValue valueWithCGPoint:shakeImage1.center];
    shakeImage1Animation.toValue = [NSValue valueWithCGPoint:CGPointMake(shakeImage1.center.x, shakeImage1.center.y-offset)];
    CABasicAnimation *shakeImage2Animation = [CABasicAnimation animationWithKeyPath:@"position"];
    shakeImage2Animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    shakeImage2Animation.duration = duration;
    shakeImage2Animation.autoreverses = YES;
    shakeImage2Animation.fromValue = [NSValue valueWithCGPoint:shakeImage2.center];
    shakeImage2Animation.toValue = [NSValue valueWithCGPoint:CGPointMake(shakeImage2.center.x, shakeImage2.center.y+offset)];
    
    
    [shakeImage1.layer addAnimation:shakeImage1Animation forKey:@"shakeAnimation"];
    [shakeImage2.layer addAnimation:shakeImage2Animation forKey:nil];
    
    
    [self performSelector:@selector(switchWaitFlag) withObject:nil afterDelay:1];

}

- (void)switchWaitFlag{
    waitFlag = YES;
}

- (void)shaked{
    if (receiveSake) {
        receiveSake = NO;
        [self destroyWaterFallView];
        [player play];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [self requestShakeImageArr];
        [self animationAfterShaking];  
        
        
    }
      
}
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{

    
}
- (void)animationWaterfallShowing{
    waitFlag = NO;
    [self performSelector:@selector(showWaterfallBackBtn) withObject:nil afterDelay:0.5];
    CABasicAnimation *waterfallShowing = [CABasicAnimation animationWithKeyPath:@"position"];
    waterfallShowing.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    waterfallShowing.duration = 0.5;
    waterfallShowing.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.center.x, self.bounds.size.height+waterfallView.bounds.size.height/2)];
    waterfallShowing.toValue = [NSValue valueWithCGPoint:self.center];
    [waterfallView.layer addAnimation:waterfallShowing forKey:nil];
    waterfallView.center = self.center;
}
- (void)initWaterFallView{
    [self destroyWaterFallView];
    waterfallView = [[WaterfallView alloc]initWithFrame:self.bounds];
    waterfallView.center = CGPointMake(self.center.x, self.bounds.size.height+waterfallView.bounds.size.height/2);
    [self insertSubview:waterfallView belowSubview:waterfallBack];

}
- (void)destroyWaterFallView{
    if (waterfallView) {
        [waterfallView removeFromSuperview];
        [waterfallView release];
        waterfallView = nil;
    }
    waterfallBack.hidden = YES;
}

- (void)requestShakeImageArr{
    [loadingIndicator startLoading];
    HttpRequest *request = [[HttpRequest alloc]initWithDelegate:self];
    NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:
                          [Utility getUUID],@"UUID",
                          [UserInfo info].GoojjeID,@"uid",
                          nil];
    [request httpRequest:RandomGetImage method:@"POST" withPara:para];
    [request release];
}
- (void)imageQueueLoading:(UIImage*)image WithContext:(id)context{
    NSArray *arr = [NSArray arrayWithObjects:image,context,nil];
    
    [waterfallView addWaterfallImage:arr];
}


- (void)showTheWaterFallView{
    [self initWaterFallView];
    if (!waitFlag) {
        [self performSelector:@selector(animationWaterfallShowing) withObject:nil afterDelay:1];
    }else {
        [self animationWaterfallShowing];
    }
    
    
}
- (void)showWaterfallBackBtn{
    waterfallBack.hidden = NO;
    receiveSake = YES;
}
- (void)updateShakeCount:(NSString*)count{
    shakeCount.text = [NSString stringWithFormat:@"%@ 次摇摇看",count];
    
}

- (void)httpRequestSuccess:(NSDictionary*)dict Name:(NSString*)name{
    if ([name isEqualToString:RandomGetImage]) {
        [loadingIndicator stopLoading];
        NSLog(@"dict : %@",dict);
        if ([[dict objectForKey:@"code"]intValue]==1) {
            NSArray *imageArr = [[dict objectForKey:@"data"]objectForKey:@"ImageArr"];
            [UserInfo imageDictFromArr:imageArr];
            NSMutableArray *addrArr = [NSMutableArray array];
            for (NSDictionary *imageDict in imageArr) {
                [addrArr addObject:[imageDict objectForKey:@"imgPath"]];
            }
            if (shakeCount.text) {
                [self showTheWaterFallView];
                [imageLoadQueue loadQueueFromUrl:addrArr];
            }
            [self updateShakeCount:[[dict objectForKey:@"data"]objectForKey:@"Sum"]];
        }
    }
}
- (void)httpRequestfailed:(NSString*)errorInfo Name:(NSString*)name{
    
}





- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];

    
#warning  ImageLoadQueue内部还要取消所有请求
    [imageLoadQueue release];
    
    [waterfallView release];
    
    [shakeCount release];
    [shakeImage1 release];
    [shakeImage2 release];
    [shakeBGimage release];
    [shakeViewBG release];
    
    [super dealloc];
}

@end
