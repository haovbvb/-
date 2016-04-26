//
//  HttpRequest.h
//  Shake4Beauty
//
//  Created by Ping on 13-8-10.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HttpRequestDelegate <NSObject>

- (void)httpRequestSuccess:(NSDictionary*)dict Name:(NSString*)name;
- (void)httpRequestfailed:(NSString*)errorInfo Name:(NSString*)name;

@end


//#define GOOJJE_MOBILE_SHAKE4BAUTY @"http://192.168.1.220/Goojje_Mobile"
#define GOOJJE_MOBILE_SHAKE4BAUTY @"http://www.goojje.com/Goojje_Mobile"

#define OAuthSignIn     @"OAuthSignIn"
#define GoojjeSignUp    @"UserReg"
#define GoojjeLogin     @"UserLogin"
#define RandomGetImage  @"RandomGetImage"
#define GetNewestImage  @"GetImage"
#define GetLikeImage    @"GetUserLikeImage"
#define LikeAImage      @"ApiLike"

@interface HttpRequest : NSObject <NSURLConnectionDataDelegate>{

    
}
@property (nonatomic , copy)NSString *menthodName;
@property (nonatomic , retain)NSMutableData *receivedData;
@property (nonatomic , retain)id<HttpRequestDelegate> httpRequestDelegate;
@property (nonatomic , retain)NSURLConnection *connect;


- (id)initWithDelegate:(id<HttpRequestDelegate>)delegate;
- (void)httpRequest:(NSString*)url method:(NSString*)httpMethod withPara:(NSDictionary*)dict;
- (NSMutableURLRequest*)httpRequestPOST:(NSString*)url para:(NSDictionary*)dict;
- (NSMutableURLRequest*)httpRequestGET:(NSString*)url para:(NSDictionary*)dict;

@end
