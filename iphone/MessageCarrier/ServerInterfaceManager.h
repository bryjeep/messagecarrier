//
//  ServerInterfaceManager.h
//  MessageCarrier
//
//  Created by Brian Davidson on 6/3/11.
//  Copyright 2011 Georgia Institute of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OutOfBandMessage.h"

@interface ServerInterfaceManager : NSObject {
    
}

+(void)serverSendMessage:(OutOfBandMessage*)message;

@end
