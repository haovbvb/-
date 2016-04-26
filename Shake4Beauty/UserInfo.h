//
//  UserInfo.h
//  Shake4Beauty
//
//  Created by Ping on 13-8-11.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//test2

@interface UserInfo : NSObject{
    
    NSMutableDictionary *imageDict;
}
//图片
@property (nonatomic , retain)NSMutableDictionary *imageDict;

//第三方的信息
@property (nonatomic , copy)NSString  *userID;
@property (nonatomic , copy)NSString  *userName;

//goojje信息
@property (nonatomic)int                 userSiteID;
@property (nonatomic , copy)NSString  *GoojjeID;
@property (nonatomic , copy)NSString  *GoojjePWD;
@property (nonatomic , copy)NSString  *GoojjeNickName;
@property (nonatomic , copy)NSString  *GoojjeUserName;
@property (nonatomic , copy)NSString   *userHead;
+ (UserInfo*)info;
+ (void)clearUserInfo;
+ (void)imageDictFromArr:(NSArray*)arr;

+ (void)saveLoginInfo;

@end
