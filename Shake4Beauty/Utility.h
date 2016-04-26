//
//  Utility.h
//  Shake4Beauty
//
//  Created by Ping on 13-8-3.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject

+ (NSString*)getUUID;

NSString * md5( NSString *str );

UIImage * getPNGImage(NSString *str);


@end
