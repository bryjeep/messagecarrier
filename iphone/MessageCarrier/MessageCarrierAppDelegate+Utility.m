//
//  MessageCarrierAppDelegate+Utility.m
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

@implementation MessageCarrierAppDelegate ( Utility )

+ (NSString *)createUUID
{
    // Create universally unique identifier (object)
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    
    // Get the string representation of CFUUID object.
    NSString *uuidStr = [(NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject) autorelease];
    
    // If needed, here is how to get a representation in bytes, returned as a structure
    // typedef struct {
    //   UInt8 byte0;
    //   UInt8 byte1;
    //   ...
    //   UInt8 byte15;
    // } CFUUIDBytes;
    //CFUUIDBytes bytes = CFUUIDGetUUIDBytes(uuidObject);
    
    CFRelease(uuidObject);
    
    return uuidStr;
}
//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    if([curReach currentReachabilityStatus] == NotReachable)
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSManagedObjectContext *context = self.managedObjectContext;
        NSFetchRequest *request = [[MessageCarrierAppDelegate sharedMessageCarrierAppDelegate]createFetchRequestForMessage];
        
        NSError *err;
        NSPredicate *toDeliver = [NSPredicate
                                           predicateWithFormat:@"(Status == %@)",
                                           [NSNumber numberWithInt:UNSENT]];
        [request setPredicate:toDeliver];
        NSArray *results = [context executeFetchRequest:request error:&err];
        
        for(OutOfBandMessage* message in results)
        {
            [MessageCarrierAppDelegate serverSendMessage: message];
        }
    });
}

+(void)serverSendMessage:(OutOfBandMessage*)message{
    NSLog(@"Sending %@ %@ To Server",message,[message string]);
    NSMutableURLRequest * request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://208.78.40.74:9292/messages"]
                                                          cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                      timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: [[[message dictionaryRepresentation] JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
	
    [MessageCarrierAppDelegate asyncRequest:request
                                    success:^(NSData * data, NSURLResponse * response){
                                        //Message got sent
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            NSLog(@"----->Server Send Sucess");
                                            if ([response isKindOfClass:[NSHTTPURLResponse class]])
                                            {
                                                NSLog(@"%@",[NSString stringWithUTF8String:[data bytes]]);
                                                NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
                                                NSLog(@"----->Server Send Response Code %d",[(NSHTTPURLResponse*)httpResponse statusCode]);
                                                if ([httpResponse statusCode] == 200){
                                                    NSError* error;
                                                    
                                                    message.Status = [NSNumber numberWithUnsignedInt: SENT];
                                                    
                                                    if([[[MessageCarrierAppDelegate sharedMessageCarrierAppDelegate] managedObjectContext] save:&error]){
                                                        [[[MessageCarrierAppDelegate sharedMessageCarrierAppDelegate] viewController] messageDelivery];
                                                    }else{
                                                        NSLog(@"Success Save Error %@",error);
                                                    }
                                               }
                                            }else{
                                                NSLog(@"----->This should be impossible");
                                            }
                                            
                                        });
                                    }
                                    failure:^(NSData * data, NSError * response){
                                        //Message got sent
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            NSLog(@"----->Server Send Failed");
                                            NSError* error;
                                            message.Status = [NSNumber numberWithUnsignedInt: FAILED];
                                            if(![[[MessageCarrierAppDelegate sharedMessageCarrierAppDelegate] managedObjectContext] save:&error]){
                                                NSLog(@"Failed Save Error %@",error);
                                            }
                                            
                                        });
                                    }];
}

+ (void)asyncRequest:(NSURLRequest *)request success:(void(^)(NSData *,NSURLResponse *))successBlock failure:(void(^)(NSData *,NSError *))failureBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if (error) {
            failureBlock(data,error);
        } else {
            successBlock(data,response);
        }
        
        [pool release];
    });
}
@end
