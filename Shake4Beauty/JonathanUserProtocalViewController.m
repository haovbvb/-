//
//  GoojjeUserProtocalViewController.m
//  Shake4Beauty
//
//  Created by Ping on 13-8-21.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "JonathanUserProtocalViewController.h"

@interface JonathanUserProtocalViewController ()

@end

@implementation JonathanUserProtocalViewController
@synthesize userProtocalWebView;

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
    NSString *path = [[[NSBundle mainBundle]bundlePath]stringByAppendingPathComponent:@"GoojjeUserProtocal.html"];
    [userProtocalWebView  loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];    
}

- (void)viewDidUnload
{
    [self setUserProtocalWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [userProtocalWebView release];
    [super dealloc];
}
- (IBAction)back:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
@end
