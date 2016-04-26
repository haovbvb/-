//
//  HttpRequest.m
//  Shake4Beauty
//
//  Created by Ping on 13-8-10.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "HttpRequest.h"
#import "JSON.h"



@implementation HttpRequest
@synthesize httpRequestDelegate , connect ,receivedData ,menthodName;

- (id)initWithDelegate:(id<HttpRequestDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.httpRequestDelegate = delegate;
    }
    return self;
}



- (void)httpRequest:(NSString*)url method:(NSString*)httpMethod withPara:(NSDictionary*)dict{
    NSMutableURLRequest *request;
    self.menthodName = url;
    if ([httpMethod isEqualToString:@"GET"]) {
        request = [self httpRequestGET:url para:dict];        
    }else if ([httpMethod isEqualToString:@"POST"]) {
        request = [self httpRequestPOST:url para:dict];
    }else {
        NSLog(@"httpMethod Wrong!!!");
        return ;
    }
    if (connect) {
        [connect cancel];
    }

    self.receivedData = [NSMutableData data];
    self.connect = [NSURLConnection connectionWithRequest:request delegate:self];
    
    
    
    
}
- (NSMutableURLRequest*)httpRequestPOST:(NSString*)url para:(NSDictionary*)dict{
    NSURL *realURL = [NSURL URLWithString:[self getRealURL:url para:nil]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:realURL];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[self handlePara:dict]dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"body %@",[self handlePara:dict] );
    return request;
}
- (NSMutableURLRequest*)httpRequestGET:(NSString*)url para:(NSDictionary*)dict{
    NSURL *realURL = [NSURL URLWithString:[self getRealURL:url para:dict]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:realURL];
    return request;
}



- (NSString*)getRealURL:(NSString*)url para:(NSDictionary*)dict{
    NSString *realURL = [GOOJJE_MOBILE_SHAKE4BAUTY stringByAppendingFormat:url];
    if (dict) {
        realURL = [realURL stringByAppendingFormat:@"?%@",[self handlePara:dict]];
        NSLog(@"url:%@",realURL);
    }
    NSLog(@"url:%@",realURL);
    return realURL;
}


- (NSString*)handlePara:(NSDictionary*)dict{
    NSMutableArray *arr = [NSMutableArray array];
    for (NSString *key in dict) {
        [arr addObject:[NSString stringWithFormat:@"%@=%@",key,[dict objectForKey:key]]];
    }
    return [arr componentsJoinedByString:@"&"];
}




#pragma mark NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.receivedData appendData:data];
    
    NSString *str = [[NSString alloc]initWithData:self.receivedData encoding:NSUTF8StringEncoding];    
    NSLog(@"self.receivedDada : %@", str );
    [str release];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSDictionary *dict;
    NSString *JsonStr = [[NSString alloc]initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    SBJsonParser *parser = [[SBJsonParser alloc]init];
    dict = [parser objectWithString:JsonStr];
    [JsonStr release];
    [parser release];
    NSLog(@" Json parser : %@", dict);
    [httpRequestDelegate httpRequestSuccess:dict Name:self.menthodName];
}


- (void)dealloc
{
    self.menthodName = nil;
    self.httpRequestDelegate = nil;
    self.receivedData= nil;
    self.connect = nil;
    [super dealloc];
}



@end
