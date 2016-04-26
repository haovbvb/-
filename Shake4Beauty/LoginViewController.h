//
//  LoginViewController.h
//  Shake4Beauty
//
//  Created by Ping on 13-8-25.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpRequest.h"
@interface LoginViewController : UIViewController<HttpRequestDelegate>{

    int weiboID;
     
}
@property (retain, nonatomic) IBOutlet UIButton *goojjeLoginBtn;

@property (retain, nonatomic) IBOutlet UITextField *loginAccountTxtF;
@property (retain, nonatomic) IBOutlet UITextField *loginPwdTxtF;


- (IBAction)removeLoginVC:(id)sender;

- (IBAction)loginWithBtnOf:(id)sender;

- (IBAction)goojjeLogin:(id)sender;



@end
