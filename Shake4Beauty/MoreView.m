//
//  MoreView.m
//  Shake4Beauty
//
//  Created by Ping on 13-8-16.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "MoreView.h"
#import "UserInfo.h"

@implementation MoreView
@synthesize moreViewDelegate;
- (id)initWithFrame:(CGRect)frame Withdelegate:(id<MoreViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.moreViewDelegate = delegate;
        
        self.backgroundColor = [UIColor clearColor];
        
        int list_num = 3;
        float y = 0;
        float height = 44;
        while (list_num--) {
            UIButton *listBtn = [UIButton buttonWithType:UIButtonTypeCustom];            
            listBtn.frame = CGRectMake(0, y, 320, height);
            y+=height;
            [listBtn setBackgroundImage:getPNGImage(@"bg_list_normal_colour") forState:UIControlStateNormal];
            [listBtn setBackgroundImage:getPNGImage(@"bg_list_press_colour") forState:UIControlStateHighlighted];
            [listBtn setTitleColor:[UIColor colorWithRed:180.0/255 green:180.0/255 blue:180.0/255 alpha:1] forState:UIControlStateNormal];
            listBtn.titleLabel.font =  [UIFont systemFontOfSize:16];
            listBtn.imageEdgeInsets = UIEdgeInsetsMake(11, 20, 11, 278);
            listBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -150, 0, 0);        
            listBtn.tag = 3-list_num;
            switch (listBtn.tag) {
                case 1:
                    [listBtn setImage:getPNGImage(@"list_icon_Login_normal") forState:UIControlStateNormal];
                    [listBtn setImage:getPNGImage(@"list_icon_Login_press") forState:UIControlStateHighlighted];
                    [listBtn setTitle:@"登录" forState:UIControlStateNormal];
                    [listBtn addTarget:self action:@selector(loginBtnPressed) forControlEvents:UIControlEventTouchUpInside];
                    listBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -200, 0, 0);
                    break;
                case 2:
                    [listBtn setImage:getPNGImage(@"list_icon_delete_normal") forState:UIControlStateNormal];
                    [listBtn setImage:getPNGImage(@"list_icon_delete_press") forState:UIControlStateHighlighted];
                    [listBtn setTitle:@"清除全部缓存" forState:UIControlStateNormal];
                    [listBtn addTarget:self action:@selector(deleteBtnPressed) forControlEvents:UIControlEventTouchUpInside];
                    listBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -140, 0, 0);
                    break;
                case 3:
                    [listBtn setImage:getPNGImage(@"list_icon_Logout_normal") forState:UIControlStateNormal];
                    [listBtn setImage:getPNGImage(@"list_icon_Logout_press") forState:UIControlStateHighlighted];
                    [listBtn setTitle:@"退出账号" forState:UIControlStateNormal];
                    [listBtn addTarget:self action:@selector(logoutBtnPressed) forControlEvents:UIControlEventTouchUpInside];
                    listBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -170, 0, 0);
                    break;
                    
                default:
                    break;
            }

            [self addSubview:listBtn];
            
        }
        
    }
    return self;
}
- (void)logoutBtnPressed{
    [moreViewDelegate moreViewlogout];
}
- (void)loginBtnPressed{
    NSLog(@"loginBtnPressed");
    if ([UserInfo info].GoojjeID) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"您已经登录,如要切换账号请先登出." delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    [moreViewDelegate moreViewlogin];
}
- (void)deleteBtnPressed{
    [moreViewDelegate moreViewDelCache];
}



@end
