//
//  SignUpViewController.h
//  Shake4Beauty
//
//  Created by Ping on 13-8-25.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpRequest.h"

@interface SignUpViewController : UIViewController<HttpRequestDelegate,UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UIView *inputView;

@property (retain, nonatomic) IBOutlet UITextField *accoutTxtF;
@property (retain, nonatomic) IBOutlet UITextField *passwordTxtF;
@property (retain, nonatomic) IBOutlet UITextField *nameTxtF;

- (IBAction)goojjeSignUp:(id)sender;
- (IBAction)backToSuperVC:(id)sender;

@end
