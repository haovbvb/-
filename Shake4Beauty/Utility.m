//
//  Utility.m
//  Shake4Beauty
//
//  Created by Ping on 13-8-3.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "Utility.h"
#import <CommonCrypto/CommonDigest.h>
@implementation Utility
+ (NSString*)getUUID{
    NSString *uuidStr=[[NSUserDefaults standardUserDefaults]objectForKey:@"Utility_UUID"];    
    if (uuidStr==nil) {
        CFUUIDRef uuid = CFUUIDCreate(nil);
        uuidStr = (NSString*)CFUUIDCreateString(nil, uuid);
        CFRelease(uuid);        
        [[NSUserDefaults standardUserDefaults]setObject:uuidStr forKey:@"Utility_UUID"];
    }
    return uuidStr;
}

NSString * md5( NSString *str )
{
    if (str == nil) {
        return nil;
    }
    
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	
	return [NSString 
			stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1],
			result[2], result[3],
			result[4], result[5],
			result[6], result[7],
			result[8], result[9],
			result[10], result[11],
			result[12], result[13],
			result[14], result[15]
			];
}

UIImage * getPNGImage(NSString *str){
    NSString *path = [[NSBundle mainBundle]pathForResource:str ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return image;
}
@end
