//
//  WaterfallView.h
//  WaterFall_demo
//
//  Created by Ping on 13-7-19.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WaterfallViewDelegate <NSObject>

- (void)WaterfallViewScrollToEnd;

@end

@interface WaterfallView : UIScrollView{

    
    NSCondition *condition;
    int threadCount;
    
    float maxY; // 当前contentview. height
    BOOL loading;
    
    NSMutableArray *volumeArr;  //存列数的数组
    
    float imageViewWedth;  //瀑布流图片一列宽
    
    NSMutableArray *waterfallArr;  //瀑布流所有图片的位置信息
    
    NSMutableArray *showedImageArr;// 当前显示的图片
    NSMutableArray *cacheArr; //缓存区图片
    
}
@property(nonatomic) BOOL loading;
@property(nonatomic ,assign)id<WaterfallViewDelegate> waterfallViewDelegate;
//(NSArray*)imageInfo    : (image , imageAdrr , id, .....) 
- (BOOL)addWaterfallImage:(NSArray*)imageInfo;


@end
