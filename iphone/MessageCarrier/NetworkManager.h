//
//  NetworkManager.h
//  MessageCarrier
//
//  Created by Joey Gibson on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "Message.h"

#define SESSION_ID @"MessageCarrier"

@interface NetworkManager : NSObject <GKSessionDelegate> {
    
}

@property (nonatomic, retain) GKSession *currentSession;

- (id) initWithMode: (GKSessionMode) mode;
- (NSError *) startup;
- (void) shutdown;
- (BOOL) sendMessage: (Message *) message;
- (NSArray *) localPeers;
- (BOOL) peersNearby;
@end
