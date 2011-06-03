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

@protocol NetworkManagerDelegate <NSObject>

- (void) messageSent: (Message *) message;
- (void) messageReceived: (Message *) message;
@end

@interface NetworkManager : NSObject <GKSessionDelegate> {
    
}

@property (nonatomic, retain) id <NetworkManagerDelegate> delegate;
@property (nonatomic, retain) GKSession *currentSession;

- (void) shutdown;
- (NSError *) sendMessage: (Message *) message;
- (NSArray *) localPeers;
- (BOOL) peersNearby;
@end
