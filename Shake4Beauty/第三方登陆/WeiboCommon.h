

#import <Foundation/Foundation.h>

enum WeiboId{
    Weibo_Sina = 1,
    Weibo_Tencent = 3,
    Weibo_Netease = 4,
    Weibo_douban = 5,
    Weibo_Max
};

#define PublishMessageResultNotification          @"PublishMessageResultNotification"
#define PublishMessageBeginNotification           @"PublishMessageBeginNotification"
#define RefreshDataWhenUidNotNullNotification     @"RefreshDataWhenUidNotNullNotification"


#define OAUTH_LOGIN_FINISHED @"OAUTH_LOGIN_FINISHED"

#define KEY_NETEASE @"j9p5n7BTMFE0ANW3"
#define SECRETKEY_NETEASE  @"rgZgjgT1cZzuhTYzLOUeWig2w2GgeH8R"
#define URI_NETEASE @"http://www.goojje.com"

#define KEY_douban    @"0473de2531c5bf4c0d5b9a6f95513de4"
#define SECRETKEY_douban   @"661ef533a84bd8d2"

#define KEY_TENCENT	@"8de9238e2fd74c9f9ce67ca81e2e00b9"
#define SECRETKEY_TENCENT	@"4d6bb542888fb5ba93d10cf6baa5c1d5"

#define KEY_SINA	@"1672033623"
#define SECRETKEY_SINA	@"150ee031a6b348f7ed14e2314a37a0dc"
#define URI_SINA @"http://www.goojje.com"


@interface WeiboCommon : NSObject {
    
}
/*
 根据blogid来保存字典信息
 */
+ (void)saveWeiboInfo:(NSDictionary *)parars blogId:(NSUInteger)blogid;
/*
 保存blogid的username，以方便授权成功时获取个人信息和每次发微博时更新姓名
 */
+ (void)saveWeiboName:(NSString *)name blogId:(NSInteger)blogid;
/*
 删除bloid的信息
 */
+ (void)deleteWeiboInfo:(NSUInteger)blogid;
/*
 检查该微博是否已绑定
 */
+ (BOOL)checkHasBindingById:(NSUInteger)blogId;
/*
 得到微博的所有保存信息，包括oauth_key、oauth_secret、可能存在name
 */
+ (NSDictionary*)getBlogInfo:(NSInteger)blogId;
/*
 得到微博对应的姓名，如果存在，返回姓名。不存在返回oauth_key（因为后面有用姓名来判断是否已绑定的逻辑）
 */
+ (NSString *)getUserNameWithId:(NSInteger)blogId;
/*
 设置微博是否开启
 */
+ (void)setWeiboEnableWithWeiboId:(NSInteger)weiboId andStatus:(BOOL)isEnabled;
/*
 得到微博是否开启
 */
+ (BOOL)getWeiboEnabledWithWeiboId:(NSInteger)weiboId;
/*
 加载微博信息，该数组里保存的是字典，内容包括name 和 enable
 */
+ (NSArray*)loadWeiboInfo;
/*
 加载已绑定的微博信息，该数组内容是字典，包括name和weiboid
 */
+ (NSArray*)loadAuthorizedWeiboInfo;
/*
 发送消息
 */
//+ (BOOL)publishMessage:(NSString *)content;

@end

