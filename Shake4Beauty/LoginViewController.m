//
//  LoginViewController.m
//  Shake4Beauty
//
//  Created by Ping on 13-8-25.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "WeiboWrapper.h"

#import "UserInfo.h"

#import "SignUpViewController.h"
#import "NoticeName.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize goojjeLoginBtn;
@synthesize loginAccountTxtF;
@synthesize loginPwdTxtF;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)removeLoginVC:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)loginWithBtnOf:(id)sender {
    NSInteger type = ((UIButton*)sender).tag;
    
    weiboID = [self hashWeiBoID:type];
    [WeiboWrapper publishMessage:@"" andWeiboId:weiboID andController:self andUserData:0];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OAuthLoginfinished:)  name:OAUTH_LOGIN_FINISHED  object:nil];
    
}

- (BOOL)allTextFieldInFormat{
    return YES;
}
- (IBAction)goojjeLogin:(id)sender {
    if ([self allTextFieldInFormat]) {
        [UserInfo info].GoojjePWD = md5(loginPwdTxtF.text);
        //[UserInfo info].GoojjePWD = loginPwdTxtF.text;
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              loginAccountTxtF.text,@"account", 
                              loginPwdTxtF.text, @"password",nil];
        
        HttpRequest *request = [[HttpRequest alloc]initWithDelegate:self];
        [request httpRequest:GoojjeLogin method:@"POST" withPara:dict];
        [request release];
        
        goojjeLoginBtn.enabled = NO;
    }
}




- (void)OAuthLoginfinished:(NSNotification*)notice{
    NSLog(@"OAuthLoginfinished : %@ ", notice);
    NSDictionary *dict = [notice object];
    
    [UserInfo info].userName = [dict objectForKey:@"name"];
    [UserInfo info].userSiteID = weiboID;
    NSLog(@"[WeiboCommon getBlogInfo:weiboID] : %@",[WeiboCommon getBlogInfo:weiboID]);
    if (weiboID == 5) {//douban
        [UserInfo info].userID = [[WeiboCommon getBlogInfo:weiboID]objectForKey:@"douban_user_id"];
    }else if (weiboID == 3) {// tx
        [UserInfo info].userID = [[WeiboCommon getBlogInfo:weiboID]objectForKey:@"name"];
    }
    else {
        [UserInfo info].userID = [[WeiboCommon getBlogInfo:weiboID]objectForKey:@"uid"];
        
    }
    
    

    [self goojjeLoginCheckOauthUser:nil];
}

- (int)hashWeiBoID:(int)t{
    int hash[] = {0,1,3 ,4,5}; //1 sina 3 tx 4 ease 5 douban
    return hash[t];
}
- (void)goojjeLoginCheckOauthUser:(NSDictionary*)dic{
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:[UserInfo info].userSiteID] ,@"siteId",
                          [UserInfo info].userID,@"siteUId",
                          nil];
    
    
    
    HttpRequest *request = [[HttpRequest alloc]initWithDelegate:self];
    [request httpRequest:OAuthSignIn method:@"POST" withPara:dict];
    [request release];
}





- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(signupSucess) name:Signup_Sucess_Notice object:nil];
}

- (void)viewDidUnload
{
    [self setLoginAccountTxtF:nil];
    [self setLoginPwdTxtF:nil];
    [self setGoojjeLoginBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)signupSucess{
    [[NSNotificationCenter defaultCenter]postNotificationName:Login_Success_Notice object:nil];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark HttpRequestDelegate

- (void)httpRequestSuccess:(NSDictionary*)dict Name:(NSString*)name{
    //return;
    if ([name isEqualToString:OAuthSignIn]) {
        if ([[dict objectForKey:@"code"]intValue]==0) {
            [self performSegueWithIdentifier:@"signUp" sender:self];

        }else if ([[dict objectForKey:@"code"]intValue]==1) {
            NSDictionary *userDict = [dict objectForKey:@"data"];
            [UserInfo info].GoojjeID = [userDict objectForKey:@"userId"];
            [UserInfo info].GoojjeNickName = [userDict objectForKey:@"nick"];
            [UserInfo info].GoojjeUserName = [userDict objectForKey:@"userName"];
            [UserInfo info].userHead = [userDict objectForKey:@"image"];
            [[NSNotificationCenter defaultCenter]postNotificationName:Login_Success_Notice object:nil];
        }else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"登录失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
    }else if ([name isEqualToString:GoojjeLogin]) {
        if ([[dict objectForKey:@"code"]intValue]==1) {
            NSDictionary *userDict = [dict objectForKey:@"data"];
            [UserInfo info].GoojjeID = [userDict objectForKey:@"userId"];
            [UserInfo info].GoojjeNickName = [userDict objectForKey:@"nick"];
            [UserInfo info].GoojjeUserName = [userDict objectForKey:@"userName"];
            [UserInfo info].userHead = [userDict objectForKey:@"image"];
            [[NSNotificationCenter defaultCenter]postNotificationName:Login_Success_Notice object:nil];
        }else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"登录失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
        goojjeLoginBtn.enabled = YES;
    }
}
- (void)httpRequestfailed:(NSString*)errorInfo Name:(NSString*)name{
    if ([name isEqualToString:GoojjeLogin]) {
        goojjeLoginBtn.enabled = YES;
    }
    
}   

- (void)dealloc {
    [loginAccountTxtF release];
    [loginPwdTxtF release];
    [goojjeLoginBtn release];
    [super dealloc];
}
@end
