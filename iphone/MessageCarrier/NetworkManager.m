//
//  NetworkManager.m
//  MessageCarrier
//
//  Created by Joey Gibson on 6/3/11.
//  Copyright 2011 org.rhok. All rights reserved.
//

#import "NetworkManager.h"

@implementation NetworkManager

@synthesize currentSession;

- (id) init {
    return [self initWithMode: GKSessionModePeer];
}

- (id) initWithMode: (GKSessionMode) mode {
    self = [super init];
    
    if (self) {
        self.currentSession = [[GKSession alloc] initWithSessionID: SESSION_ID
                                                       displayName: nil 
                                                       sessionMode: mode];
    }
    
    return self;
}

- (void)shutdown {
    
}

#pragma mark - Action Methods
- (BOOL)sendMessage:(Message *)message {
    
}

#pragma mark - GKSessionDelegate Methods
/* Indicates a state change for the given peer.
 */
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    
}

/* Indicates a connection request was received from another peer. 
 
 Accept by calling -acceptConnectionFromPeer:
 Deny by calling -denyConnectionFromPeer:
 */
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
    
}

/* Indicates a connection error occurred with a peer, which includes connection request failures, or disconnects due to timeouts.
 */
- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
    
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
    
}
@end
