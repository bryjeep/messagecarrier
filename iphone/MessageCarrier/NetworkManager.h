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

@class NetworkManager;

@protocol NetworkManagerDelegate <NSObject>

- (void) networkManager: (NetworkManager *) networkManager sentMessage: (OutOfBandMessage *) message;
- (void) networkManager: (NetworkManager *) networkManager receivedMessage: (OutOfBandMessage *) message wasAccepted: (BOOL) accepted;
- (void) networkManagerDiscoveredPeer: (NetworkManager *) networkManager;
- (void) networkManagerConnectedPeer: (NetworkManager *) networkManager;
- (void) networkManagerDisconnectedPeer: (NetworkManager *) networkManager;

@end

@interface NetworkManager : NSObject <GKSessionDelegate> {
    GKSession *currentSession; 
}

@property (nonatomic, retain) id <NetworkManagerDelegate> delegate;

- (BOOL) startup;
- (void) shutdown;
- (NSError *) sendMessage: (OutOfBandMessage *) message;
- (NSError *) sendMessage: (OutOfBandMessage *) message asAccepted: (BOOL) accepted;
- (int) currentPeerCount;

@end

