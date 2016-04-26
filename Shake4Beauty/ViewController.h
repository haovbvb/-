//
//  ViewController.h
//  Shake4Beauty
//
//  Created by Ping on 13-8-25.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ShakeView.h"
#import "NewestView.h"
#import "MoreView.h"
#import "LikeView.h"
#import "ContentView.h"
#import "HttpRequest.h"
#import "Reachability.h"

@interface ViewController : UIViewController<MoreViewDelegate,HttpRequestDelegate,UIActionSheetDelegate,UIAlertViewDelegate>{
    int currentViewType;

    UIView *currentView;
    
    UIView *logintipView;

    NewestView *newestView;
    
    int actionSheetNum;
    
    
}
@property (retain ,nonatomic) ContentView *contentView;
@property (retain, nonatomic) IBOutlet UIButton *shakeBtn;
@property (retain, nonatomic) IBOutlet UIButton *newestBtn;
@property (retain, nonatomic) IBOutlet UIButton *likeBtn;
@property (retain, nonatomic) IBOutlet UIButton *moreBtn;


- (IBAction)contentViewSwitch:(id)sender;


@end
