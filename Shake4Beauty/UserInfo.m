//
//  UserInfo.m
//  Shake4Beauty
//
//  Created by Ping on 13-8-11.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo
@synthesize userID,userName,userSiteID,GoojjeID , userHead , GoojjeUserName ,GoojjeNickName,imageDict , GoojjePWD;

+ (UserInfo*)info{
    static UserInfo *singleton = nil;
    if (self) {
        @synchronized(self){
            if (singleton == nil) {
                singleton = [[UserInfo alloc]init];
                
            }
        }
    }
    return singleton;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.userSiteID = 0;
        self.userSiteID = [[[NSUserDefaults standardUserDefaults]objectForKey:@"sid"]intValue];
        self.userID = [[NSUserDefaults standardUserDefaults]objectForKey:@"uid"];
        self.GoojjePWD = [[NSUserDefaults standardUserDefaults]objectForKey:@"pwd"];
        self.GoojjeUserName = [[NSUserDefaults standardUserDefaults]objectForKey:@"acc"];
        self.imageDict = [[NSMutableDictionary alloc]init];
    }
    return self;
}

+ (void)saveLoginInfo{
    if ([UserInfo info].userSiteID != 0) {
        [[NSUserDefaults standardUserDefaults]setInteger:[UserInfo info].userSiteID forKey:@"sid"];
        [[NSUserDefaults standardUserDefaults]setObject:[UserInfo info].userID forKey:@"uid"];
    }else {
        [[NSUserDefaults standardUserDefaults]setObject:[UserInfo info].GoojjePWD forKey:@"pwd"];
        [[NSUserDefaults standardUserDefaults]setObject:[UserInfo info].GoojjeUserName forKey:@"acc"];
    }
}
    


+ (void)clearLoginInfo{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"sid"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"uid"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"acc"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"pwd"];
}

+ (void)clearUserInfo{
    [UserInfo info].userSiteID = 0;
    [UserInfo info].GoojjePWD=nil;
    [UserInfo info].userID=nil;
    [UserInfo info].userName=nil;
    [UserInfo info].GoojjeID=nil;
    [UserInfo info].GoojjeNickName=nil;
    [UserInfo info].GoojjeUserName=nil;
    [UserInfo info].userHead=nil;
    //[UserInfo info].imageDict = nil;
    [UserInfo clearLoginInfo];
}

/*
 imgId = adb2d7a0bf661733aeccf28ed755d065;
 imgPath = "http://192.168.1.221/LikeImage/48/1545/6c772a75ed4a98ac8c66da8ea3a4e129/1/1344577645751_center.jpg?559X730";
 isLike = "-1";
 */
+ (void)imageDictFromArr:(NSArray*)arr{  
    for (NSDictionary *dict in arr) {
        [[UserInfo info].imageDict setObject:[NSArray arrayWithObjects:[dict objectForKey:@"imgId"],[dict objectForKey:@"isLike"], nil] forKey:[dict objectForKey:@"imgPath"]];
    }
}

@end
