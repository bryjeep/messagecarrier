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
@synthesize delegate;

- (id) init {
    self = [super init];
    
    if (self) {
        self.currentSession = [[GKSession alloc] initWithSessionID: SESSION_ID
                                                       displayName: nil 
                                                       sessionMode: GKSessionModePeer];
    }
    
    return self;
}

- (void)shutdown {
    
}

#pragma mark - Action Methods
- (NSError *) sendMessage: (Message *) message {
    NSError *error;
    NSData *data = nil;
    
    [self.currentSession sendDataToAllPeers: data
                               withDataMode: GKSendDataReliable
                                      error: &error];
    
    return error;
}

- (NSArray *) localPeers {
    return [self.currentSession peersWithConnectionState: GKSessionModePeer];
}

- (BOOL) peersNearby {
    return [[self localPeers] count] > 0;
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
