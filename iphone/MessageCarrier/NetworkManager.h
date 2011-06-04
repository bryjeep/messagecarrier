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

#define kSESSION_ID @"MessageCarrier"
#define kMESSAGE_ID @"MESSAGE_ID"
#define kHOP_COUNT @"HOP_COUNT"
#define kSOURCE_ID @"SOURCE_ID"
#define kMESSAGE_TYPE @"MESSAGE_TYPE"
#define kDESTINATION @"DESTINATION"
#define kMESSAGE_BODY @"MESSAGE_BODY"
#define kSTATUS @"STATUS"
#define kMESSAGE_WAS_ACCEPTED @"MESSAGE_WAS_ACCEPTED"
#define kSENDER_NAME @"SENDER_NAME"
#define kDATE_TIME @"DATE_TIME"
#define kLOCATION @"LOCATION"

@class NetworkManager;

@protocol NetworkManagerDelegate <NSObject>

- (void) networkManager: (NetworkManager *) networkManager sentMessage: (OutOfBandMessage *) message;
- (void) networkManager: (NetworkManager *) networkManager receivedMessage: (OutOfBandMessage *) message wasAccepted: (BOOL) accepted;
- (void) networkManagerDiscoveredPeer: (NetworkManager *) networkManager;
- (void) networkManagerConnectedPeer: (NetworkManager *) networkManager;
- (void) networkManagerDisconnectedPeer: (NetworkManager *) networkManager;

@end

@interface NetworkManager : NSObject <GKSessionDelegate> {
    NSTimer *timer;
    GKSession *currentSession;
    NSMutableArray *peers;   
}

@property (nonatomic, retain) id <NetworkManagerDelegate> delegate;

- (BOOL) startup;
- (void) shutdown;
- (NSError *) sendMessage: (OutOfBandMessage *) message;
- (NSError *) sendMessage: (OutOfBandMessage *) message asAccepted: (BOOL) accepted;

@end

