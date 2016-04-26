

#import "WeiboPublishViewController.h"
#import "AppDelegate.h"
#import "RegexKitLite.h"

#import "NSString+Additions.h"


@interface WeiboPublishViewController()
- (void)showActivityIndicator;
- (void)hideActivityIndicator;

- (void)switchToAutorizeMode;
- (void)switchToPublishMode;
- (void)showOauthTokenError;
@end


@implementation WeiboPublishViewController
@synthesize verifyStr;
@synthesize weiboId, weiboApi, numerousPublish;
@synthesize webView, navigationBar;
@synthesize stringOauthToken, stringOauthTokenSecret;
@synthesize stringContent, stringFilePath, userData;
@synthesize arrayWeiboInfo;

- (void)dealloc {
    
    self.weiboApi.delegate = nil;
    
    [navigationBar release];
    [webView release];
    
    [stringOauthToken release];
    [stringOauthTokenSecret release];
    
    [stringContent release];
    [stringFilePath release];
    
    [verifyStr release];
    
    [arrayWeiboInfo release];
    

    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.weiboApi = [[WeiboCommonAPI alloc] init];
    weiboApi.delegate = self;
    isVerifing = NO;

    [weiboApi getOauthTokenWithWeiboId:weiboId];

}

- (void)viewDidUnload
{
    [self setNavigationBar:nil];
    [self setWebView:nil];

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self hideActivityIndicator];
}

-(NSString*) valueForKey:(NSString *)key ofQuery:(NSString*)query
{
	NSArray *pairs = [query componentsSeparatedByString:@"&"];
	for(NSString *aPair in pairs){
		NSArray *keyAndValue = [aPair componentsSeparatedByString:@"="];
		if([keyAndValue count] != 2) continue;
		if([[keyAndValue objectAtIndex:0] isEqualToString:key]){
			return [keyAndValue objectAtIndex:1];
		}
	}
	return nil;
}

#pragma mark WeiboCommonAPIDelegate
/*
 当得到正确的oauthToken时，使用oauthToken来访问网页，请求用户输入用户名和密码
 */



- (void)getOauth2Token{
    NSDictionary *params;
    NSString *url;
    switch (weiboId) {
        case Weibo_Sina:
            params = [NSDictionary dictionaryWithObjectsAndKeys:KEY_SINA, @"client_id",  @"code", @"response_type",
                      URI_SINA, @"redirect_uri", 
                      @"mobile", @"display", nil];
            url = [NSString stringWithFormat:@"https://api.weibo.com/oauth2/authorize?%@",  [NSString stringFromDictionary:params]];            
            break;
        case Weibo_Netease:
            params = [NSDictionary dictionaryWithObjectsAndKeys:KEY_NETEASE, @"client_id",  @"code", @"response_type",
                      URI_NETEASE, @"redirect_uri", 
                      @"mobile", @"display", nil];
            url = [NSString stringWithFormat:@"https://api.t.163.com/oauth2/authorize?%@",  [NSString stringFromDictionary:params]];
        default:
            break;
    }   
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60];
    
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    
    [self.webView loadRequest:request];	
}


- (void)getOauth2AccessToken:(NSString*)code{
    if (isVerifing) {
        return;
    }
    isVerifing = YES;

    [weiboApi getOauth2AccessTokenAPIWithCode:code];

}



- (void)getOauthTokenSuccess:(WeiboCommonAPI *)api andOauthToken:(NSString *)oauthToken andOauthTokenSecret:(NSString *)oauthTokenSecret
{
    [self hideActivityIndicator];
    self.stringOauthToken = oauthToken;
    self.stringOauthTokenSecret = oauthTokenSecret;
    NSString *baseUrl = nil;
    switch (weiboId) {
        case Weibo_Sina:
            baseUrl = @"http://api.t.sina.com.cn/oauth/authorize?oauth_token=";
            break;
        case Weibo_Tencent:
            baseUrl = @"http://open.t.qq.com/cgi-bin/authorize?oauth_token=";
            break;
        case Weibo_Netease:
            baseUrl = @"http://api.t.163.com/oauth/authorize?oauth_token=";
            break;
        case Weibo_douban:
            baseUrl = @"http://www.douban.com/service/auth/authorize?oauth_token=";
            break;
        default:
            break;
    }
    NSString *url = [NSString stringWithFormat:@"%@%@", baseUrl, oauthToken];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60];
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [self.webView loadRequest:request];	
}

- (void)getOauthTokenFailed:(WeiboCommonAPI *)api
{
    [self hideActivityIndicator];
    [self showOauthTokenError];
    [WeiboCommon deleteWeiboInfo:weiboId];
}

/*
 当获取到正确的AccessToken时，获取用户的信息，主要是用户昵称
 */

- (void)getaccesstokenSuccess:(WeiboCommonAPI *)api
{
    NSLog(@"getaccesstokenSuccess:(WeiboCommonAPI *)api");
    [weiboApi getUserInfoWithWeiboId:weiboId];
    isVerifing = NO;
}

- (void)getAccessTokenFailed:(WeiboCommonAPI *)api
{
    NSLog(@"getAccessTokenFailed:(WeiboCommonAPI *)api");
    [self showOauthTokenError];
    isVerifing = NO;
    [WeiboCommon deleteWeiboInfo:weiboId];
}

- (void)getUserInfoSuccess:(WeiboCommonAPI *)api andUserName:(NSString *)userName
{
    isVerifing = NO;
    [self switchToPublishMode];
}

- (void)getUserInfoFailed:(WeiboCommonAPI *)api
{
    //失败, 清除所有登录的缓存
    isVerifing = NO;
    [WeiboCommon deleteWeiboInfo:api.currentWeiboId];
    NSLog(@"login fail!!!!!!!!!!!!");
    //提示
}


- (NSString *)getVeriferFromHtml:(NSString *)htmlStr
{
    NSString *mark = nil;
    
    switch (weiboId) {
        case Weibo_Sina:
            mark = @"<div class=\"getCodeWrap\"> 获取到的授权码：<span class=\"fb\">([0-9]*)</span>";
            break;
        case Weibo_Tencent:
            return nil;
            break;
        case Weibo_douban:
            mark = @"<li><span style=\"font-size:16px;font-weight:bold;color:red;\">([0-9]*)</span>";
            break;
        case Weibo_Netease:
            mark = @"<span class=\"pin\" id=\"verifier\">([0-9]*)</span>";
            break;
        default:
            return nil;
            break;
    }
    NSString *str = [htmlStr stringByMatching:mark capture:1];
    return str;
}


#pragma mark UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self showActivityIndicator];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideActivityIndicator];
    if (!isVerifing) {
        NSString *htmlstr = [self.webView stringByEvaluatingJavaScriptFromString:
                             @"document.getElementsByTagName('html')[0].outerHTML"];
        //NSLog(@"%@", htmlstr);
        NSString *verifier = [self getVeriferFromHtml:htmlstr];
        
        if (verifier) {
            self.verifyStr = [NSString stringWithString:verifier];
            [self buttonSubmitVerifyClicked:nil];
        }
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	NSLog(@"shouldStartLoadWithRequest : %@",request.URL);
    if (weiboId == Weibo_Sina||weiboId == Weibo_Netease) {
        if ([[request.URL absoluteString]hasPrefix:@"http://www.goojje.com/?error_uri="]) {
            //[self getAccessTokenFailed:nil];
        }
        NSRange range = [request.URL.absoluteString rangeOfString:@"code="];
        
        if (range.location != NSNotFound)
        {
            NSString *code = [request.URL.absoluteString substringFromIndex:range.location + range.length];
            [self.webView stopLoading];
            [self getOauth2AccessToken:code];
        }
        return YES;
    }
    
    
    
	NSString *query = [[request URL] query];
    NSLog(@"%@", query);
    NSLog(@"%@",request);
//    NSRange rangeOfOauthtoken = [query rangeOfString:@"oauth_token"];
    if (query == nil ) {
        //[self showInputVerifyView];
    }
    
    //douban Oauth1.0这里 跳转一个revoke_token 这个页面  就授权不了 token了... 很诡异. 在这个之前来请求认证token , 这里会有bug 如果请求没快速送出去 这个revoke页面加载进来 就会使之前的token失效.
    if ([[request.URL absoluteString]hasSuffix:@"revoke_token"]||[[request.URL absoluteString]isEqualToString:@"http://www.douban.com/"]) {
        [self.webView stopLoading];
        [self buttonSubmitVerifyClicked:nil];
    }
    
	NSString *verifier = [self valueForKey:@"oauth_verifier" ofQuery:query];
	if (verifier && ![verifier isEqualToString:@""]) {
        self.verifyStr = [NSString stringWithString:verifier];
        [self buttonSubmitVerifyClicked:nil];
    }
    return YES;
}

#pragma mark 其他界面函数

/*
 切换到授权模式
 */
- (void)switchToAutorizeMode
{
    NSString *title = nil;
    switch (weiboId) {
        case Weibo_Sina:
            title = @"添加新浪微博";
            break;
        case Weibo_Tencent:
            title = @"添加腾讯微博";
            break;
        case Weibo_douban:
            title = @"添加搜狐微博";
            break;
        case Weibo_Netease:
            title = @"添加网易微博";
            break;
        default:
            break;
    }
    self.navigationBar.topItem.title = title;

    self.webView.hidden = NO;

}
/*
 当授权成功时，切换到发微博的模式
 */
- (void)switchToPublishMode
{
    
    [self dismissModalViewControllerAnimated:NO];
//    self.webView.hidden = YES;
//
//    if (self.stringFilePath != nil) {
//
//    }else {
//
//    }
//    if (numerousPublish) {
//        self.navigationBar.topItem.title = @"分享到微博";
//
//    }else{
//        self.navigationBar.topItem.title = [WeiboCommon getUserNameWithId:weiboId];
//
//    }
  //  [NSNotificationCenter defaultCenter]postNotificationName:OAUTH_LOGIN_FINISHED object:<#(id)#> userInfo:<#(NSDictionary *)#>

}

#pragma mark 公用函数
- (void)showActivityIndicator
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)hideActivityIndicator
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)showOauthTokenError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登录失败，请稍后重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    alert.tag = 101;//随便定义了一下.... 
    alert.delegate=self;
    [alert show];
    [alert release];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag=101) {
        [self barButtonItemCloseClicked:nil];
    }
}




#pragma mark 按钮函数
- (IBAction)barButtonItemCloseClicked:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)buttonSubmitVerifyClicked:(id)sender {
    //    if ([self.textFieldVerify.text length] == 0 && !isVerifing) {
    //        return;
    //    }
    if (isVerifing) {
        return;
    }
    isVerifing = YES;
    
    [weiboApi getAccessTokenWithOauthToken:self.stringOauthToken andOauthTokenSecret:self.stringOauthTokenSecret andVerifier:self.verifyStr andBlogId:weiboId];
}


@end





















