//
//  SignUpViewController.m
//  Shake4Beauty
//
//  Created by Ping on 13-8-25.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "SignUpViewController.h"
#import "UserInfo.h"
#import "WeiboCommon.h"
#import "NoticeName.h"
#import "RegexKitLite.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController
@synthesize inputView;
@synthesize accoutTxtF;
@synthesize passwordTxtF;
@synthesize nameTxtF;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setAccoutTxtF:nil];
    [self setPasswordTxtF:nil];
    [self setNameTxtF:nil];
    [self setInputView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [accoutTxtF release];
    [passwordTxtF release];
    [nameTxtF release];
    [inputView release];
    [super dealloc];
}
- (BOOL)allTextFieldInFormat{
    NSString *regex_acc = @"^([\\w\\d_\\.-]+)@([\\w\\d_-]+\\.)+\\w{2,4}$";
    NSString *regex_name = @"[\\w\\d_(\\u4E00-\\uFA29)]{4,30}";
    NSString *regex_pwd = @".{6,}";
    BOOL format1 = [accoutTxtF.text isMatchedByRegex:regex_acc];
    BOOL format2 = [nameTxtF.text isMatchedByRegex:regex_name];
    BOOL format3 = [passwordTxtF.text isMatchedByRegex:regex_pwd];
    NSLog(@"%d %d %d",format1 ,format2 ,format3);
    
    NSString *errStr=nil;
    if (!format2) {
        errStr=@"昵称为4-30个字符,不包含特殊标点";
    } else if (!format1) {
        errStr=@"账号只能是Email格式";
    }else if (!format3) {
        errStr=@"密码小于6位";
    }
    if (errStr) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:errStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    
    return format1&&format2&&format3;
}
- (IBAction)goojjeSignUp:(id)sender {
    if ([self allTextFieldInFormat]) {
        
        NSDictionary *weiboDICT = [WeiboCommon getBlogInfo:[UserInfo info].userSiteID];
        
        
        NSMutableDictionary *mutableDICT = [NSMutableDictionary dictionary];
        [mutableDICT setObject:accoutTxtF.text forKey:@"account"];
        [mutableDICT setObject:passwordTxtF.text forKey:@"password"];
        [mutableDICT setObject:nameTxtF.text forKey:@"nick"];
        [mutableDICT setObject:[UserInfo info].userID forKey:@"siteUId"];
        [mutableDICT setObject:[NSNumber numberWithInt:[UserInfo info].userSiteID] forKey:@"siteId"];
        [mutableDICT setObject:[UserInfo info].userHead forKey:@"image"];
        
        if ([UserInfo info].userSiteID == 1||[UserInfo info].userSiteID == 4) {
            [mutableDICT setObject:@"2" forKey:@"oauthVersion"];
            [mutableDICT setObject:[weiboDICT objectForKey:@"access_token"] forKey:@"accessToken"];
        }else {
            [mutableDICT setObject:@"1" forKey:@"oauthVersion"];
            [mutableDICT setObject:[weiboDICT objectForKey:@"oauth_token"] forKey:@"appKey"];
            [mutableDICT setObject:[weiboDICT objectForKey:@"oauth_token_secret"] forKey:@"appSecret"];
        }
        
        
        HttpRequest *request = [[HttpRequest alloc]initWithDelegate:self];
        [request httpRequest:GoojjeSignUp method:@"POST" withPara:mutableDICT]; 
    }   
}


- (void)textFieldDidBeginEditing:(UITextField *)textField{
    inputView.center = CGPointMake(160, 180);
    

}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    inputView.center = CGPointMake(160, 236);
    return YES;
}

- (IBAction)backToSuperVC:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
#pragma mark HttpRequestDelegate
- (void)httpRequestSuccess:(NSDictionary*)dict Name:(NSString*)name{
    if ([name isEqualToString:GoojjeSignUp]) {
        if ([[dict objectForKey:@"code"]intValue]==1) {
            NSDictionary *userDict = [dict objectForKey:@"data"];
            [UserInfo info].GoojjeID = [userDict objectForKey:@"userId"];
            [UserInfo info].GoojjeNickName = [userDict objectForKey:@"nick"];
            [UserInfo info].GoojjeUserName = [userDict objectForKey:@"userName"];
            [[NSNotificationCenter defaultCenter]postNotificationName:Signup_Sucess_Notice object:nil];
            [self dismissModalViewControllerAnimated:NO];
        }else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"注册失败" message:[dict objectForKey:@"desc"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
        
    }
   
}
- (void)httpRequestfailed:(NSString*)errorInfo Name:(NSString*)name{

}
@end
