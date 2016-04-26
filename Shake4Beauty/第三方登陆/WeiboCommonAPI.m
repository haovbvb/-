

enum RequestId {
    GettingOauthToken,
    GettingAccessToken,
    GettingUserInfo,
    PublishMessage
};

BOOL g_isdoubanSharingPicture;

#include "ifaddrs.h"
#include "arpa/inet.h"
#import "WeiboCommon.h"
#import "WeiboCommonAPI.h"
#import "NSURL+Additions.h"
#import "NSString+Additions.h"
#import "JSON.h"
#import "WeiboWrapper.h"


#import "UserInfo.h"

@interface WeiboCommonAPI()
- (NSInteger)getNextSendingId;
@end

@implementation WeiboCommonAPI
@synthesize oauthKey;
@synthesize connectionWeibo, dataReceive, currentWeiboId, delegate, numerousPublish;
@synthesize stringFilePath, stringSendingContent, stringImageUrl;
@synthesize userData;

- (void)dealloc
{
    [oauthKey release];
    
    [self.connectionWeibo cancel];
    self.connectionWeibo = nil;
    //[self.connectionWeibo release];
    [dataReceive release];
    
    [stringSendingContent release];
    [stringFilePath release];
    [stringImageUrl release];
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        MicroBlogOauthKey *key = [[MicroBlogOauthKey alloc] init];
        self.oauthKey = key;
        [key release];
        
        isOAuth2 = NO;
    }
    return self;
}

- (void)initAccessTokenWithBlogId:(enum WeiboId)weiboId
{
    NSDictionary *info = [WeiboCommon getBlogInfo:weiboId];
    if (currentRequestId != GettingOauthToken) {
        oauthKey.tokenKey = [info objectForKey:@"oauth_token"];
        oauthKey.tokenSecret = [info objectForKey:@"oauth_token_secret"];
    }    
#warning bug here qq第2次登录 带了tokenKey过去. 不知道这里用这个干嘛的.
    
    oauthKey.callbackUrl = nil;
    switch (weiboId) {
        case Weibo_Sina:
            oauthKey.consumerKey = KEY_SINA;
            oauthKey.consumerSecret = SECRETKEY_SINA;
            break;
        case Weibo_Tencent:
            oauthKey.consumerKey = KEY_TENCENT;
            oauthKey.consumerSecret = SECRETKEY_TENCENT;
            break;
        case Weibo_Netease:
            oauthKey.consumerKey = KEY_NETEASE;
            oauthKey.consumerSecret = SECRETKEY_NETEASE;
            break;
        case Weibo_douban:
            oauthKey.consumerKey = KEY_douban;
            oauthKey.consumerSecret = SECRETKEY_douban;
            break;
        default:
            break;
    }
}


#pragma mark 得到OauthToken部分

- (void)getOauth2TokenWithWeiboId:(enum WeiboId)weiboId{

    switch (weiboId) {
        case Weibo_Sina:
            [delegate getOauth2Token];
            break;
        case Weibo_Netease:
            [delegate getOauth2Token];
            break;
        default:
            break;
    }
}


- (void)getOauth2AccessTokenAPIWithCode:(NSString*)code{

    
    NSDictionary *params ;
    
    NSString *url ;
    
    switch (currentWeiboId) {
        case Weibo_Sina:
            params = [NSDictionary dictionaryWithObjectsAndKeys:KEY_SINA, @"client_id",
                      SECRETKEY_SINA, @"client_secret",
                      @"authorization_code", @"grant_type",
                      URI_SINA, @"redirect_uri",
                      code, @"code", nil];
            url = @"https://api.weibo.com/oauth2/access_token";
            break;
        case Weibo_Netease:
            params = [NSDictionary dictionaryWithObjectsAndKeys:KEY_NETEASE, @"client_id",
                      SECRETKEY_NETEASE, @"client_secret",
                      @"authorization_code", @"grant_type",
                      URI_NETEASE, @"redirect_uri",
                      code, @"code", nil];
            url = @"https://api.t.163.com/oauth2/access_token";
            break;
        default:
            break;
    }
    
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
														   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
													   timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    
    NSMutableData *body = [NSMutableData data];
    
    [body appendData:[[NSString stringFromDictionary:params] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];  
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    NSLog(@"connection :%@ %@",connection,request.URL);
    
    currentRequestId = GettingAccessToken;
    isOAuth2 = YES;
}








- (void)getOauthTokenWithWeiboId:(enum WeiboId)weiboId
{
    currentWeiboId = weiboId;
    
    if ([WeiboCommon checkHasBindingById:weiboId]) {
        if (weiboId == Weibo_Sina) {
            [self getUserInfoOAuth2WithWeiboId];
        }else if (weiboId == Weibo_Netease) {
            [self getUserInfoOAuth2WithWeiboId];
        }else if (weiboId == Weibo_Tencent) {
            [self getUserInfoWithWeiboId:Weibo_Tencent];
        }else if (weiboId == Weibo_douban) {
            [self getUserInfoWithWeiboId:Weibo_douban];
        }
        return;
    }
    
    currentRequestId = GettingOauthToken;
    
    NSString *url = nil;
    NSString *method = @"GET";
    
    [self initAccessTokenWithBlogId:weiboId];
    switch (weiboId) {
        case Weibo_Sina:
            [self getOauth2TokenWithWeiboId:Weibo_Sina];
            return;
            //OAuth1.0
            url = @"http://api.t.sina.com.cn/oauth/request_token";
            break;
        case Weibo_Tencent:
            url = @"https://open.t.qq.com/cgi-bin/request_token";
            self.oauthKey.callbackUrl = @"http://wap.qq.com";
            break;
        case Weibo_Netease:
            [self getOauth2TokenWithWeiboId:Weibo_Netease];
            return;
            
            
            url = @"http://api.t.163.com/oauth/request_token";
            break;
        case Weibo_douban:
            url = @"http://www.douban.com/service/auth/request_token";
            self.oauthKey.callbackUrl = @"http://";
            break;
        default:
            break;
    }
    
    self.connectionWeibo = [MicroBlogRequest asyncRequestWithUrl:url httpMethod:method oauthKey:oauthKey parameters:nil files:nil delegate:self];
}

- (void)notifyGetOauthTokenFailed
{
    if (delegate && [delegate respondsToSelector:@selector(getOauthTokenFailed:)]) {
        [delegate getOauthTokenFailed:self];
    }
}

- (void)notifyGetOauthTokenSuccessWithOauthToken:(NSString *)oauthToken andOauthTokenSecret:(NSString *)oauthTokenSecret
{
    if (self && [delegate respondsToSelector:@selector(getOauthTokenSuccess:andOauthToken:andOauthTokenSecret:)]) {
        [delegate getOauthTokenSuccess:self andOauthToken:oauthToken andOauthTokenSecret:oauthTokenSecret];
    }
}

/*
 处理得到的OauthToken数据
 */
- (void)processOauthTokenData
{
    NSString *string = [[NSString alloc ] initWithData:dataReceive encoding:NSUTF8StringEncoding];
    //NSLog(@"%@", string);
    NSDictionary *params = [NSURL parseURLQueryString:string];
    NSString *oauthToken = [params objectForKey:@"oauth_token"];
    NSString *oauthTokenSecret = [params objectForKey:@"oauth_token_secret"];
    if (oauthToken && oauthTokenSecret) {
        [self notifyGetOauthTokenSuccessWithOauthToken:oauthToken andOauthTokenSecret:oauthTokenSecret];
    }else{
        [self notifyGetOauthTokenFailed];
    }
    [string release];
}

#pragma mark 得到AccessToken和AccessTokenSecret
- (void)getAccessTokenWithOauthToken:(NSString *)oauthToken andOauthTokenSecret:(NSString*)oauthTokenSecret andVerifier:(NSString*)verifier andBlogId:(enum WeiboId)weiboId
{
    currentRequestId = GettingAccessToken;

    NSString *url = nil;
    NSString *method = @"GET";
    switch (weiboId) {
        case Weibo_Sina:
            url = @"http://api.t.sina.com.cn/oauth/access_token";
            break;
        case Weibo_Tencent:
            url = @"https://open.t.qq.com/cgi-bin/access_token";
            break;
        case Weibo_Netease:
            url = @"http://api.t.163.com/oauth/access_token";
            break;
        case Weibo_douban:
            url = @"http://www.douban.com/service/auth/access_token";
            break;
        default:
            break;
    }
    [self initAccessTokenWithBlogId:weiboId];
    oauthKey.tokenKey = oauthToken;
    oauthKey.tokenSecret = oauthTokenSecret;
    oauthKey.verify = verifier;
    self.connectionWeibo = [MicroBlogRequest asyncRequestWithUrl:url httpMethod:method oauthKey:oauthKey parameters:nil files:nil delegate:self];
}

- (void)notifyGetAccessTokenFailed
{
    if (delegate && [delegate respondsToSelector:@selector(getAccessTokenFailed:)]) {
        [delegate getAccessTokenFailed:self];
    }
}

- (void)notifyGetAccessTokenSuccess
{
    if (delegate && [delegate respondsToSelector:@selector(getaccesstokenSuccess:)]) {
        [delegate getaccesstokenSuccess:self];
    }
}
- (void)notifyGetAccessTokenOauth2Success{
    [self getUserInfoOAuth2WithWeiboId];

}


- (void)processAccessTokenOAuth2{
    NSString *string = [[NSString alloc ] initWithData:dataReceive encoding:NSUTF8StringEncoding];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict = [parser objectWithString:string];
    if ([dict objectForKey:@"access_token"]) {
        [WeiboCommon saveWeiboInfo:dict blogId:currentWeiboId];
        [self notifyGetAccessTokenOauth2Success];
    }else{
        
        [self notifyGetAccessTokenFailed];
    }
}





- (void)processAccessTokenData
{
    NSString *string = [[NSString alloc ] initWithData:dataReceive encoding:NSUTF8StringEncoding];
    NSDictionary *params = [NSURL parseURLQueryString:string];
    if ([params objectForKey:@"oauth_token"]==nil || [params objectForKey:@"oauth_token_secret"]==nil) {
        [self notifyGetAccessTokenFailed];
    }else{
        [WeiboCommon saveWeiboInfo:params blogId:currentWeiboId];
        [self notifyGetAccessTokenSuccess];
    }
    [string release];
}

#pragma mark 获取用户信息
- (void)getUserInfoOAuth2WithWeiboId{
    currentRequestId = GettingUserInfo;
    
    NSString *url = nil;

    NSDictionary *info = [WeiboCommon getBlogInfo:currentWeiboId];
    NSDictionary *dict ; 
    
    switch (currentWeiboId) {
        case Weibo_Sina:
            url = @"https://api.weibo.com/2/users/show.json";
            NSString *accessToken = [info objectForKey:@"access_token"];
            NSString *userID = [info objectForKey:@"uid"];
            dict = [NSDictionary dictionaryWithObjectsAndKeys:accessToken,@"access_token",
                userID,@"uid",nil];
            
            break;
    case Weibo_Netease:
            url = @"https://api.t.163.com/users/show.json";
            dict = [NSDictionary dictionaryWithObjectsAndKeys:[info objectForKey:@"access_token"],@"access_token",
                    [info objectForKey:@"user_id"],@"user_id",nil];
            break;
        default:
            break;
    }
    url=[url stringByAppendingFormat:@"?%@",[NSString stringFromDictionary:dict]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [NSURLConnection connectionWithRequest:request delegate:self];
    NSLog(@" show user : %@",url);
}
- (void)getUserInfoWithWeiboId:(enum WeiboId)weiboId
{
    currentRequestId = GettingUserInfo;

    NSString *url = nil;
    NSString *user_id = nil;
    NSDictionary *info = [WeiboCommon getBlogInfo:weiboId];
    NSString *method = @"GET";
    
    [self initAccessTokenWithBlogId:weiboId];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:1];
    
    switch (weiboId) {
        case Weibo_Sina:
            url = @"http://api.t.sina.com.cn/users/show.json";
            user_id = [info objectForKey:@"user_id"];
            [parameters setObject:user_id forKey:@"user_id"];
            break;
        case Weibo_Tencent:
            url = @"http://open.t.qq.com/api/user/info";
            [parameters setObject:@"json" forKey:@"format"];
            break;
        case Weibo_Netease:
            url = @"http://api.t.163.com/users/show.json";
            break;
        case Weibo_douban:
            url = @"http://api.douban.com/people/%40me";
            break;
        default:
            break;
    }
    
    self.connectionWeibo = [MicroBlogRequest asyncRequestWithUrl:url httpMethod:method oauthKey:oauthKey parameters:parameters files:nil delegate:self];
}

- (void)notifyGetUserInfoFailed
{
    if (delegate && [delegate respondsToSelector:@selector(getUserInfoFailed:)]) {
        [delegate getUserInfoFailed:self];
    }
}

- (void)notifyGetuserInfoSuccess:(NSString *)userName
{
    if (delegate && [delegate respondsToSelector:@selector(getUserInfoSuccess:andUserName:)]) {
        [delegate getUserInfoSuccess:self andUserName:userName];
    }
    
    
    
}

- (void)processGetUserInfoData
{
    NSString *string = [[NSString alloc ] initWithData:dataReceive encoding:NSUTF8StringEncoding];
    NSLog(@"processGetUserInfoData:%@", string);
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict = [parser objectWithString:string];
    NSString *name = nil;
    
    
    switch (currentWeiboId) {
        case Weibo_Sina:                    
        case Weibo_Netease:
            name = [dict objectForKey:@"name"];
            [UserInfo info].userHead = [dict objectForKey:@"profile_image_url"];
            break;
        case Weibo_douban:
            NSLog(@"");
            NSXMLParser *xmlParser = [[NSXMLParser alloc]initWithData:dataReceive];
            xmlParser.delegate = self;
            [xmlParser parse];
            [xmlParser release];
            break;
        case Weibo_Tencent:
            name = [[dict objectForKey:@"data"]objectForKey:@"name"];
            NSString *head = [[dict objectForKey:@"data"] objectForKey:@"head"];
            [UserInfo info].userHead = [head stringByAppendingFormat:@"/180"];

            break;
        
        default:
            break;
    }
    
    if (name){
        [WeiboCommon saveWeiboName:name blogId:currentWeiboId];
        [self notifyGetuserInfoSuccess:name];
        [[NSNotificationCenter defaultCenter]postNotificationName:OAUTH_LOGIN_FINISHED object:dict];
        
    }else{
        [self notifyGetUserInfoFailed];
    }
    [parser release];
    [string release];
}

#pragma mark parser delegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    NSLog(@"didStartElement   !");
    NSLog(@"parser:%@ , ele:%@ uri:%@ , name:%@  attr:%@ ",parser,elementName,namespaceURI,qName,attributeDict);
    if ([elementName isEqualToString:@"link"]) {
        if ([[attributeDict objectForKey:@"rel"]isEqualToString:@"icon"]) {
            [UserInfo info].userHead = [attributeDict objectForKey:@"href"];
            [WeiboCommon saveWeiboName:nil blogId:currentWeiboId];
            [self notifyGetuserInfoSuccess:nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:OAUTH_LOGIN_FINISHED object:nil];
        }
    }
}


#pragma mark NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    switch (currentRequestId) {
        case GettingOauthToken:
            [self notifyGetOauthTokenFailed];
            break;
        case GettingAccessToken:
            [self notifyGetAccessTokenFailed];
            break;
        case GettingUserInfo:
            [self notifyGetUserInfoFailed];
            break;
        default:
            break;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.dataReceive = nil;
    dataReceive = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.dataReceive appendData:data];
    NSString *string = [[NSString alloc ] initWithData:dataReceive encoding:NSUTF8StringEncoding];
    NSLog(@"didReceiveData: %@ " ,  string);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    switch (currentRequestId) {
        case GettingOauthToken:
            [self performSelectorOnMainThread:@selector(processOauthTokenData) withObject:nil waitUntilDone:NO];
            break;
        case GettingAccessToken:
            if (isOAuth2) {
                [self performSelectorOnMainThread:@selector(processAccessTokenOAuth2) withObject:nil waitUntilDone:NO];
            }else {
                [self performSelectorOnMainThread:@selector(processAccessTokenData) withObject:nil waitUntilDone:NO];
            }            
            break;
        case GettingUserInfo:
            [self performSelectorOnMainThread:@selector(processGetUserInfoData) withObject:nil waitUntilDone:NO];
            break;
        case PublishMessage:
            [self performSelectorOnMainThread:@selector(processPublishMessageData) withObject:nil waitUntilDone:NO];
            break;
        default:
            break;
    }
}

- (NSInteger)getNextSendingId
{
    if (!numerousPublish) {
        return 0;
    }
    if (currentWeiboId == 0) {
        currentWeiboId = Weibo_Sina;
    }else{
        currentWeiboId = currentWeiboId*2;
    }
    int i;
    for (i = currentWeiboId; i<Weibo_Max; i=i*2) {
        //检查是否已绑定，并且打开开关
        if ([WeiboCommon getWeiboEnabledWithWeiboId:i] && [WeiboCommon checkHasBindingById:i]) {
            break;
        }
    }
    return (i<Weibo_Max)?i:0;
}





@end


