//
//  ContentScrollView.m
//  Shake4Beauty
//
//  Created by Ping on 13-7-19.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "ContentScrollView.h"
#define page_width  320
@implementation ContentScrollView

@synthesize pagesArr , contentScrollViewDelegate , current_page;
- (id)initWithFrame:(CGRect)frame andPage:(NSArray*)arr
{
    self = [super initWithFrame:frame];
    if (self) {
        self.pagesArr = arr;
        page_count = [arr count];
        current_page = -1;
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.delegate = (id<UIScrollViewDelegate>)self;
        [self setContentSize:CGSizeMake(page_width*page_count, self.frame.size.height)];

        pageView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, page_width, self.frame.size.height)];
        pageView.scalesPageToFit = YES;

        
        [self addSubview:pageView];
        
        
        mWindow = (ShakeDetectedWindow *)[[UIApplication sharedApplication].windows objectAtIndex:0];
        mWindow.viewToObserve = pageView;
        mWindow.controllerThatObserves = self;
        
        
    }
    return self;
}
- (void)userDidTapWebView:(id)tapPoint{
    NSLog(@"################################");
    [contentScrollViewDelegate getOneTouched];
}


- (void)show1Page:(int)page_num{    
    if (current_page == page_num) {
        return;
    }
    current_page = page_num;
    pageView.frame = CGRectMake(current_page*page_width, 0, page_width, self.frame.size.height);
    [self setContentOffset:pageView.frame.origin];
    
    NSString *url = [[pagesArr objectAtIndex:current_page]objectAtIndex:4];
    url = [url stringByReplacingOccurrencesOfString:@"center" withString:@"big"];
    
    
//    NSString *str = [NSString stringWithContentsOfFile:[[[NSBundle mainBundle]bundlePath]stringByAppendingPathComponent:@"asdf.html"]  encoding:NSUTF8StringEncoding error:nil]; 
//    [pageView loadHTMLString:str baseURL:nil];

    
    [pageView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    
}

- (NSString*)getCurrentPageInfo{
    NSLog(@"%@" , [[pagesArr objectAtIndex:current_page]objectAtIndex:4]);
    
    //NSDictionary *dict = ;
    
    return [[pagesArr objectAtIndex:current_page]objectAtIndex:4];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [contentScrollViewDelegate getOneTouched];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int page_num = scrollView.contentOffset.x/page_width;
    NSLog(@"%d",page_num);
    [self show1Page:page_num];
    [contentScrollViewDelegate touchEnd];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touched");
    
}


- (void)dealloc
{
    [pagesArr release];
    [pageView release];
    [super dealloc];
}

@end
