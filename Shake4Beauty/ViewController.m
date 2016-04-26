//
//  ViewController.m
//  Shake4Beauty
//
//  Created by Ping on 13-8-25.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"


#import "NoticeName.h"
#import "UserInfo.h"

#import "WeiboCommon.h"

#define SubView_Frame CGRectMake(0, 0, 320, 480-20-44)

@interface ViewController ()

@end

@implementation ViewController
@synthesize shakeBtn;
@synthesize newestBtn;
@synthesize likeBtn;
@synthesize moreBtn;

@synthesize contentView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginSuccess) name:Login_Success_Notice object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showContentView:) name:Waterfall_Choosed_Notice object:nil];

    [self contentViewSwitch:[self.view viewWithTag:11]];
    
    [self autoLogin];

}


- (void)autoLogin{
    if([UserInfo info].userSiteID!=0&&[UserInfo info].userID){
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:[UserInfo info].userSiteID] ,@"siteId",
                              [UserInfo info].userID,@"siteUId",
                              nil];
        
        HttpRequest *request = [[HttpRequest alloc]initWithDelegate:self];
        [request httpRequest:OAuthSignIn method:@"POST" withPara:dict];
        [request release];
    }else if ([UserInfo info].GoojjePWD&&[UserInfo info].GoojjeUserName) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [UserInfo info].GoojjeUserName,@"account", 
                              [UserInfo info].GoojjePWD, @"password",nil];
        
        HttpRequest *request = [[HttpRequest alloc]initWithDelegate:self];
        [request httpRequest:GoojjeLogin method:@"POST" withPara:dict];
        [request release];
    }

}

- (void)showContentView:(NSNotification*)notice{
    if ([currentView isKindOfClass:[ShakeView class]]) {
        ((ShakeView*)currentView).receiveSake = NO;
    }
    self.contentView = [[ContentView alloc]initWithFrame:CGRectMake(0, 0, 320, 460) andPage:[notice object]];
    if ([currentView isKindOfClass:[LikeView class]]) {
        self.contentView.ISLIKED = YES;
    }
    [self.contentView show1Page:[[[notice userInfo]objectForKey:@"index"]intValue]];
    [self.view addSubview:contentView];

}
- (void)loginSuccess{
    [UserInfo saveLoginInfo];
    [self dismissModalViewControllerAnimated:YES];
    [self addLikeView];
}

- (void)addLikeView{
    if (currentViewType==13) {
        [self reLoadContentView];
    }else {
        [self contentViewSwitch:[self.view viewWithTag:13]];
    }
}
- (void)reLoadContentView{
    logintipView.hidden = YES;
    if ([currentView isKindOfClass:[NewestView class]]) {
        currentView.hidden=YES;
    }else {
        [currentView removeFromSuperview];
        [currentView release];
    }
    
    currentView = nil;
    switch (currentViewType) {
        case 11:
            currentView = [[ShakeView alloc]initWithFrame:SubView_Frame];
            break;
        case 12:
            if (newestView) {
                currentView = newestView;
                currentView.hidden=NO;
            }else {
                newestView = [[NewestView alloc]initWithFrame:SubView_Frame];
                currentView = newestView;
            }
            
            break;
        case 13:
            if ([UserInfo info].GoojjeID) {//是否登录
                currentView = [[LikeView alloc]initWithFrame:SubView_Frame];
            }else {
                [self showLoginTipView];
                [self showLoginVC];
            }
            break;
        case 14:
            currentView = [[MoreView alloc]initWithFrame:SubView_Frame Withdelegate:self];
            
            break;
        default:
            break;
    }
    [self.view addSubview:currentView];
}

- (void)showLoginTipView{
    if (logintipView==nil) {
        logintipView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 300)];
        logintipView.backgroundColor = [UIColor clearColor];
        logintipView.center = self.view.center;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 107, 41);
        btn.center = self.view.center;
        [btn setTitle:@"请先登录" forState:UIControlStateNormal];
        [btn setBackgroundImage:getPNGImage(@"bg_btn_normal") forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(showLoginVC) forControlEvents:UIControlEventTouchUpInside];
        [logintipView addSubview:btn];
        [self.view addSubview:logintipView];
    }
    logintipView.hidden = NO;
}

- (IBAction)contentViewSwitch:(id)sender{

    int type = ((UIButton*)sender).tag;
    if (type == currentViewType) {
        return;
    }
    
    if (type == 13) {
        if ([UserInfo info].GoojjeID) {//是否登录

        }else {
            [self showLoginVC];
            return;
        }
    }
    
    
    currentViewType = type;
    [self cancelBtnSelectedState];
    ((UIButton*)sender).selected = YES;  
    [self reLoadContentView];
    
}




- (void)cancelBtnSelectedState{
    shakeBtn.selected = NO;
    newestBtn.selected = NO;
    likeBtn.selected = NO;
    moreBtn.selected = NO;
}

- (void)showLoginVC{
    [self performSegueWithIdentifier:@"Login" sender:self];
}

#pragma moreViewDelegate
- (void)moreViewlogin{
    [self showLoginVC];
}


- (void)moreViewDelCache{
    actionSheetNum = 1;
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"清除全部缓存" otherButtonTitles: nil];
    sheet.actionSheetStyle = UIBarStyleBlackTranslucent;
    [sheet showInView:self.view];
    [sheet release];
}
- (void)moreViewlogout{
    actionSheetNum = 2;
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出登录" otherButtonTitles: nil];
    sheet.actionSheetStyle = UIBarStyleBlackTranslucent;
    [sheet showInView:self.view];
    [sheet release];
}

#pragma UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (actionSheetNum) {
        case 1:
            if (buttonIndex==0) {
                [self deleteCacheFile];
            }
            break;
        case 2:
            if (buttonIndex==0) {
                [self logout];
            }
            break;
        default:
            break;
    }
}
- (void)deleteCacheFile{
    NSArray	 *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *dir = [paths objectAtIndex:0];
    dir = [dir stringByAppendingFormat:@"/imageCache"];
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:dir error:nil];
}

- (void)logout{
    [WeiboCommon deleteWeiboInfo:[UserInfo info].userSiteID];
    [UserInfo clearUserInfo];
}



- (void)viewDidUnload
    {
    [self setShakeBtn:nil];
    [self setNewestBtn:nil];
    [self setLikeBtn:nil];
    [self setMoreBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}




- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)httpRequestSuccess:(NSDictionary*)dict Name:(NSString*)name{
    if ([name isEqualToString:OAuthSignIn]||[name isEqualToString:GoojjeLogin]) {
        if ([[dict objectForKey:@"code"]intValue]==1) {
            NSDictionary *userDict = [dict objectForKey:@"data"];
            [UserInfo info].GoojjeID = [userDict objectForKey:@"userId"];
            [UserInfo info].GoojjeNickName = [userDict objectForKey:@"nick"];
            [UserInfo info].GoojjeUserName = [userDict objectForKey:@"userName"];

        }else{
            [self logout];
        }
    }
}
- (void)httpRequestfailed:(NSString*)errorInfo Name:(NSString*)name{
    [self logout];
}




- (void)dealloc {
    [contentView release];
    [shakeBtn release];
    [newestBtn release];
    [likeBtn release];
    [moreBtn release];
    [super dealloc];
}
 // 是否wifi
//+ (BOOL) IsEnableWIFI {
//    return ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable);
//}
//
//// 是否3G
//+ (BOOL) IsEnable3G {
//    return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable);
//}

- (void)viewWillAppear:(BOOL)animated {    
    if (([Reachability reachabilityForInternetConnection].currentReachabilityStatus != NotReachable) && 
        ([Reachability reachabilityForLocalWiFi].currentReachabilityStatus == NotReachable)) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"当前网络状态为2G/3G，继续使用会消耗较多流量，建议在wifi环境下使用" delegate:self cancelButtonTitle:@"继续" otherButtonTitles:@"取消", nil];
        [alert show];
        [alert release];
    }
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        exit(0);  
    }
}
@end
