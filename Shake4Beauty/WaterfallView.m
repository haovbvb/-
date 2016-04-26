//
//  WaterfallView.m
//  WaterFall_demo
//
//  Created by Ping on 13-7-19.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "WaterfallView.h"
#import <QuartzCore/QuartzCore.h>
#import "NoticeName.h"

#define VOLUME_NUM 3
#define VOLUME_OFFSET 4
#define LINE_OFFSET 3
#define CACHE_OFFSET 500

#define BoardGap 7

@implementation WaterfallView

@synthesize waterfallViewDelegate;
@synthesize loading;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        condition = [[NSCondition alloc]init];
        threadCount = 0;
        self.delegate = (id<UIScrollViewDelegate>)self;        
        waterfallArr = [[NSMutableArray alloc]init];
        showedImageArr = [[NSMutableArray alloc]init];
        cacheArr = [[NSMutableArray alloc]init];

        volumeArr = [[NSMutableArray alloc]initWithCapacity:VOLUME_NUM];
        for (int i = 0; i<VOLUME_NUM; i++) {
            [volumeArr addObject:[NSNumber numberWithInt:0]];
        }
        imageViewWedth = (frame.size.width-BoardGap-BoardGap-(VOLUME_NUM-1)*VOLUME_OFFSET)/VOLUME_NUM;
        //改UIScollerVIew背景.
        self.backgroundColor = [UIColor colorWithPatternImage:getPNGImage(@"bg_shaking")]; 
    }
    return self;
}
- (void)dealloc
{
    [volumeArr release];
    [waterfallArr release];
    [showedImageArr release];
    [cacheArr release];
    
    [super dealloc];
}

- (BOOL)addWaterfallImage:(NSArray*)imageInfo{//imageInfo:(image,addr,id,...)
    if ([imageInfo count]<2) {
        return NO;
    }
    loading = YES;
    UIImage *image = [imageInfo objectAtIndex:0];
    NSString *imageAddr = [imageInfo objectAtIndex:1];
    
    float ratio = image.size.height/image.size.width;
    int height =  imageViewWedth*ratio;
    int vol = 0;
    int y = [[volumeArr objectAtIndex:0] intValue];
    for (int i = 0; i<[volumeArr count]; i++) {
        if ([[volumeArr objectAtIndex:i] intValue]<y) {
            y = [[volumeArr objectAtIndex:i] intValue];
            vol = i ; 
        }
    }
    [volumeArr replaceObjectAtIndex:vol withObject:[NSNumber numberWithInt:(y+height+LINE_OFFSET)]];
    maxY = [[volumeArr objectAtIndex:vol]floatValue];;
    loading = NO;
    int x = vol*(VOLUME_OFFSET+imageViewWedth)+BoardGap;
    CGRect rect= CGRectMake(x, y, imageViewWedth, height);
    NSArray *rectArr = [NSArray arrayWithObjects:
                        [NSNumber numberWithInt:x], 
                        [NSNumber numberWithInt:y],
                        [NSNumber numberWithInt:height],
                        image,imageAddr,nil];
    [waterfallArr addObject:rectArr];
    
    if (y<=self.frame.size.height+CACHE_OFFSET) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:rect];
        imageView.userInteractionEnabled = YES;
        
        imageView.tag = 100+[waterfallArr indexOfObject:rectArr];
        [imageView setImage:image];
        [self addSubview:imageView];
        [showedImageArr addObject:imageView];
    }
        
    int yMax=[[volumeArr objectAtIndex:0] intValue];
    for (int i = 0; i<[volumeArr count]; i++) {
        if ([[volumeArr objectAtIndex:i] intValue]>yMax) {
            yMax = [[volumeArr objectAtIndex:i] intValue];
        }
    }
    [self setContentSize:CGSizeMake(self.frame.size.width-10, yMax)]; 

    loading = NO;
    
    return YES;
}   

- (void)reloadImageViews{
    [condition lock];
    NSLog(@"rrrrrrrrrrrrrrrrrrrrrrrrrrrrrreloadImageViews");
    float offSet_Y = self.contentOffset.y;
    NSMutableArray *readyToRemove = [NSMutableArray array];
    for (UIImageView *imageV in showedImageArr) {
        if (imageV.frame.origin.y+imageV.frame.size.height+CACHE_OFFSET<offSet_Y||imageV.frame.origin.y-CACHE_OFFSET>offSet_Y+self.frame.size.height) {//已经划出view的图片
            [readyToRemove addObject:imageV];
        }
    }
    for (UIImageView *view in readyToRemove) {
        [showedImageArr removeObject:view];
        [view removeFromSuperview];
        [cacheArr addObject:view];
    }
    for (NSArray *imageArr in waterfallArr) {
        BOOL SHOWED;
        float image_Y = [[imageArr objectAtIndex:1]floatValue];
        float image_H = [[imageArr objectAtIndex:2]floatValue];
        if (image_Y+image_H+CACHE_OFFSET<offSet_Y||image_Y-CACHE_OFFSET>offSet_Y+self.frame.size.height) {
            SHOWED = NO;
        }else {
            SHOWED = YES;
            //有机会把这个for弄掉  影响应能
            for (UIImageView *ima in showedImageArr) {
                if (ima.tag-100 == [waterfallArr indexOfObject:imageArr]) {
                    SHOWED=NO;
                }
            }
        }
        if (SHOWED) {
            UIImageView *needShowedView = [self getCacheCell];
            if (needShowedView) {
                [needShowedView setImage:nil];
            }else {
                needShowedView = [[UIImageView alloc]init];
                needShowedView.userInteractionEnabled = YES;
                
            }
            needShowedView.frame = CGRectMake([[imageArr objectAtIndex:0]floatValue], [[imageArr objectAtIndex:1]floatValue], imageViewWedth, [[imageArr objectAtIndex:2]floatValue]);
            needShowedView.tag = 100+[waterfallArr indexOfObject:imageArr];
            
            [self addSubview:needShowedView];
            needShowedView.image = [imageArr objectAtIndex:3];
            [showedImageArr addObject:needShowedView];
        }
    }
    threadCount--;
    threadCount = threadCount<0?0:threadCount;
    
    [condition unlock];
    [NSThread exit];
}


- (UIImageView*)getCacheCell{
    UIImageView *v = nil; 
    if (cacheArr&& [cacheArr isKindOfClass:[NSArray class]] &&[cacheArr count]>0) {
        v = [cacheArr lastObject];
        [cacheArr removeLastObject];
    }
    return v;
}




static float OFFSET_Y=0;
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    if (loading) {
        return;
    }

    
    if (fabs(scrollView.contentOffset.y-OFFSET_Y)>200 ) {
        OFFSET_Y=scrollView.contentOffset.y;

        NSThread *aThread = [[NSThread alloc]initWithTarget:self selector:@selector(reloadImageViews) object:nil];
        if (threadCount>1) {
            aThread=nil;
        }else {
            threadCount++;
            [aThread start];
        }
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ((maxY-self.frame.size.height)<scrollView.contentOffset.y-80) {

        loading = YES;
        [waterfallViewDelegate WaterfallViewScrollToEnd];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touched");
    UITouch *touch = [touches anyObject];
    if ([touch.view isKindOfClass:[UIImageView class]]) {
        NSLog(@"touch.view.tag %d",touch.view.tag);
        NSLog(@"addr : %@",[waterfallArr objectAtIndex:touch.view.tag-100]);
        [[NSNotificationCenter defaultCenter]postNotificationName:Waterfall_Choosed_Notice 
                                                           object:waterfallArr 
                                                         userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:touch.view.tag-100] forKey:@"index"]];
    }
}








// unuse
- (NSArray*)imageArrProcessing:(NSArray*)imageArr{
    NSMutableArray *arr = [NSMutableArray array];
    for (UIImage *image in imageArr) {
        UIImage *scaledImage = [self strenchImage:image];
        [arr addObject:scaledImage];
    }
    return arr;
}


- (UIImage*)strenchImage:(UIImage*)image{
    CGSize size = CGSizeMake(imageViewWedth, imageViewWedth*image.size.height/image.size.width);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  
    return newImage;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
