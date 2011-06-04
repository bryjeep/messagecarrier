//
//  NetworkManager.h
//  MessageCarrier
//
//  Created by Joey Gibson on 6/3/11.
//  Copyright 2011 org.rhok. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "OutOfBandMessage.h"

#define SESSION_ID @"MessageCarrier"
#define MESSAGE_ID @"MESSAGE_ID"
#define HOP_COUNT @"HOP_COUNT"
#define SOURCE_ID @"SOURCE_ID"
#define MESSAGE_TYPE @"MESSAGE_TYPE"
#define DESTINATION @"DESTINATION"
#define MESSAGE_BODY @"MESSAGE_BODY"
#define STATUS @"STATUS"
#define MESSAGE_WAS_ACCEPTED @"MESSAGE_WAS_ACCEPTED"
#define SENDER_NAME @"SENDER_NAME"
#define DATE_TIME @"DATE_TIME"
#define LOCATION @"LOCATION"

@class NetworkManager;

@protocol NetworkManagerDelegate <NSObject>

- (void) networkManager: (NetworkManager *) networkManager sentMessage: (OutOfBandMessage *) message;
- (void) networkManager: (NetworkManager *) networkManager receivedMessage: (OutOfBandMessage *) message wasAccepted: (BOOL) accepted;
- (void) networkManagerDiscoveredPeers: (NetworkManager *) networkManager;
@end

@interface NetworkManager : NSObject <GKSessionDelegate> {
    
}

@property (nonatomic, retain) id <NetworkManagerDelegate> delegate;

- (BOOL) startup;
- (void) shutdown;
- (NSError *) sendMessage: (OutOfBandMessage *) message asAccepted: (BOOL) accepted;
- (BOOL) peersNearby;
@end
