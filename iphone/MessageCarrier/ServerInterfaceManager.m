//
//  ServerInterfaceManager.m
//  MessageCarrier
//
//  Created by Brian Davidson on 6/3/11.
//  Copyright 2011 Georgia Institute of Technology. All rights reserved.
//

#import "ServerInterfaceManager.h"
#import "MessageCarrierAppDelegate+Utility.h"

@implementation ServerInterfaceManager

+(void)serverSendMessage:(Message*)message{ 
    NSMutableURLRequest * request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://someweb/messages"]
                                                          cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                      timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: [@"HELLO WORLD" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [MessageCarrierAppDelegate asyncRequest:request
                                    success:^(NSData * data, NSURLResponse * response){
                                        
                                    }
                                    failure:^(NSData * data, NSError * response){
                                        
                                    }];
}

@end
