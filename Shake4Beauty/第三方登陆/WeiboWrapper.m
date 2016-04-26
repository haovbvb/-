
#import "WeiboWrapper.h"
#import "WeiboCommon.h"
#import "WeiboCommonAPI.h"
#import "AppDelegate.h"
#import "WeiboPublishViewController.h"


@implementation WeiboWrapper
+ (BOOL)publishMessage:(NSString *)content andController:(UIViewController*)controller andUserData:(NSInteger)userData
{
    if (controller == nil) {
        return NO;
    }
    int i;
    for (i=Weibo_Sina; i<Weibo_Max; i=i*2) {
        if ([WeiboCommon getWeiboEnabledWithWeiboId:i] && [WeiboCommon checkHasBindingById:i]) {
            break;
        }
    }
    if (i > Weibo_Max) {
        return NO;
    }
    WeiboPublishViewController *publishcontroller = [[WeiboPublishViewController alloc] initWithNibName:@"WeiboPublishViewController" bundle:nil];
    publishcontroller.numerousPublish = YES;
    publishcontroller.weiboId = i;
    publishcontroller.stringContent = content;
    publishcontroller.userData = userData;
    [controller presentModalViewController:publishcontroller animated:YES];
    [publishcontroller release];
    return YES;
}

+ (BOOL)publishMessage:(NSString *)content andWeiboId:(NSInteger)weiboId andController:(UIViewController *)controller andUserData:(NSInteger)userData
{
    WeiboPublishViewController *publishcontroller = [[WeiboPublishViewController alloc] initWithNibName:@"WeiboPublishViewController" bundle:nil];
    publishcontroller.numerousPublish = NO;
    publishcontroller.weiboId = weiboId;
    publishcontroller.stringContent = content;
    publishcontroller.stringFilePath = nil;
    publishcontroller.userData = userData;
    [controller presentModalViewController:publishcontroller animated:NO];
    [publishcontroller release];
    return YES;
}

+ (BOOL)publishMessage:(NSString *)content andFilePath:(NSString *)imagePath andController:(UIViewController*)controller andUserData:(NSInteger)userData
{
    if (controller == nil) {
        return NO;
    }
    int i;
    for (i=Weibo_Sina; i<Weibo_Max; i=i*2) {
        if ([WeiboCommon getWeiboEnabledWithWeiboId:i] && [WeiboCommon checkHasBindingById:i]) {
            break;
        }
    }
    if (i > Weibo_Max) {
        return NO;
    }
    WeiboPublishViewController *publishcontroller = [[WeiboPublishViewController alloc] initWithNibName:@"WeiboPublishViewController" bundle:nil];
    publishcontroller.numerousPublish = YES;
    publishcontroller.weiboId = i;
    publishcontroller.stringContent = content;
    publishcontroller.stringFilePath = imagePath;
    publishcontroller.userData = userData;
    [controller presentModalViewController:publishcontroller animated:YES];
    [publishcontroller release];
    return YES;
}

+ (BOOL)publishMessage:(NSString *)content andImagePath:(NSString*)imgPath andWeiboId:(NSInteger)weiboId andController:(UIViewController *)controller andUserData:(NSInteger)userData
{
    WeiboPublishViewController *publishcontroller = [[WeiboPublishViewController alloc] initWithNibName:@"WeiboPublishViewController" bundle:nil];
    publishcontroller.numerousPublish = NO;
    publishcontroller.weiboId = weiboId;
    publishcontroller.stringContent = content;
    publishcontroller.stringFilePath = nil;
    publishcontroller.stringFilePath = imgPath;
    publishcontroller.userData = userData;
    [controller presentModalViewController:publishcontroller animated:YES];
    [publishcontroller release];
    return YES;
}



@end
