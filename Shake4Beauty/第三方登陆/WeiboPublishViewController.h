
#import <UIKit/UIKit.h>
#include "WeiboCommon.h"
#include "WeiboCommonAPI.h"

@interface WeiboPublishViewController : UIViewController
<WeiboCommonAPIDelegate, UIWebViewDelegate>
{
    BOOL isVerifing;//是否正在进行验证码确认，避免重复确认
    NSString *verifyStr;
    

}
@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) IBOutlet UINavigationBar *navigationBar;


@property (nonatomic, retain) NSArray *arrayWeiboInfo;

@property (nonatomic, assign) BOOL numerousPublish;
@property (nonatomic, assign) NSInteger weiboId;
@property (nonatomic, assign) WeiboCommonAPI *weiboApi;

/*
 存放授权时得到的OauthToken和OauthTokenSecret
 */
@property (nonatomic, retain) NSString *stringOauthToken;
@property (nonatomic, retain) NSString *stringOauthTokenSecret;
/*
 要发送的内容
 */
@property (nonatomic, retain) NSString *stringContent;
@property (nonatomic, retain) NSString *stringFilePath;
@property (nonatomic, assign) NSInteger userData;


@property (nonatomic, retain) NSString *verifyStr;


- (IBAction)barButtonItemCloseClicked:(id)sender;

- (IBAction)buttonSubmitVerifyClicked:(id)sender;
@end
