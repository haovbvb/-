//
//  ImageLoader.m
//  WaterFall_demo
//
//  Created by Ping on 13-7-19.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "ImageLoader.h"


@implementation ImageLoader
@synthesize connect, receivedDada, directory ,context;

- (id)initWithDelegate:(id<ImageLoaderDelegate>)delegate
{
    self = [super init];
    if (self) {
        imageLoaderDelegate = delegate;
    } 
    return self;
}


- (UIImage*)loadLocalImage:(NSString*)url{
    UIImage *image = nil;    
    NSArray	 *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *dir = [paths objectAtIndex:0];
    dir = [dir stringByAppendingFormat:@"/imageCache"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:dir]) {
        [fm createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    self.directory = [dir stringByAppendingFormat:@"/imageCache_%@.png",md5(url)];

    image = [UIImage imageWithContentsOfFile:directory];
    return image;
}

- (void)loadNetImage:(NSString*)url{
    self.receivedDada = [NSMutableData data];
    self.connect = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] delegate:self];
}

- (void)loadImageFromUrl:(NSString*)url{
    self.context = url;
    if (connect) {
        [connect cancel];
    }
    UIImage *image = [self loadLocalImage:url];
    if (image) {
        [imageLoaderDelegate loaderDidFinish:image WithContext:context];
    }else {
        [self loadNetImage:url];
    }
}







- (void)dealloc{
    [connect release];
    [super dealloc];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [imageLoaderDelegate loaderDidFinish:nil WithContext:nil];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *str = [[NSString alloc]initWithData:self.receivedDada encoding:NSUTF8StringEncoding];
    NSLog(@"self.receivedDada : %@", str );
    UIImage *image = [UIImage imageWithData:self.receivedDada];

    if (imageLoaderDelegate) {
        [imageLoaderDelegate loaderDidFinish:image WithContext:context];
    }
    
    if (image) {      
        NSData *imageData = UIImagePNGRepresentation(image);
        [imageData writeToFile:directory atomically:YES];
    }
    
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.receivedDada appendData:data];
}


@end
