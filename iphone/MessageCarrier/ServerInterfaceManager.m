//
//  ServerInterfaceManager.m
//  MessageCarrier
//
//  Created by Brian Davidson on 6/3/11.
//  Copyright 2011 Georgia Institute of Technology. All rights reserved.
//

#import "SBJson.h"
#import "ServerInterfaceManager.h"
#import "OutOfBandMessage.h"
#import "MessageCarrierAppDelegate+DataModel.h"
#import "MessageCarrierAppDelegate+Utility.h"

@implementation ServerInterfaceManager

+(void)serverSendMessage:(OutOfBandMessage*)message{    
    NSMutableURLRequest * request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://someweb/messages"]
                                                          cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                      timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: [[[message dictionaryRepresentation] JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [MessageCarrierAppDelegate asyncRequest:request
                                    success:^(NSData * data, NSURLResponse * response){
                                        //Message got sent
                                        message.Status = [NSNumber numberWithUnsignedInt: SENT];
                                    }
                                    failure:^(NSData * data, NSError * response){
                                        //Message got sent
                                        message.Status = [NSNumber numberWithUnsignedInt: FAILED];
                                    }];
}

@end
