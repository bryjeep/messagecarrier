//
//  NetworkManager.m
//  MessageCarrier
//
//  Created by Joey Gibson on 6/3/11.
//  Copyright 2011 org.rhok. All rights reserved.
//

#import "NetworkManager.h"

@interface NetworkManager ()

@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, assign) BOOL shouldProcessData;
@property (nonatomic, retain) GKSession *currentSession;
@property (nonatomic, retain) NSArray *peers;
@end;

@implementation NetworkManager

@synthesize currentSession;
@synthesize delegate;
@synthesize shouldProcessData;
@synthesize timer;
@synthesize peers;

- (id) init {
    self = [super init];
    
    if (self) {
        self.currentSession = [[GKSession alloc] initWithSessionID: SESSION_ID
                                                       displayName: nil 
                                                       sessionMode: GKSessionModePeer];
        
        [self.currentSession setDataReceiveHandler: self
                                       withContext: nil];
    }
    
    self.shouldProcessData = NO;
    
    return self;
}

- (void) dealloc {
    self.currentSession = nil;
    self.delegate = nil;
    self.timer = nil;
    self.peers = nil;
    
    [super dealloc];
}

- (BOOL) startup {
    self.shouldProcessData = YES;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval: 5.0
                                                  target: self
                                                selector: @selector(checkForPeers)
                                                userInfo: nil
                                                 repeats: YES];
    
    return YES;
}

- (void)shutdown {
    self.shouldProcessData = NO;
    [self.timer invalidate];
    self.timer = nil;
    
    self.currentSession = nil;
}

- (void) checkForPeers {
    if ([self peersNearby]) {
        [self.delegate networkManagerDiscoveredPeers: self];
    }
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
    if (self.shouldProcessData) {
        
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData: data];
        
        Message *message = [[Message alloc] init];
        
        message.MessageID = [unarchiver decodeObjectForKey: MESSAGE_ID];
        message.HopCount = [unarchiver decodeObjectForKey: HOP_COUNT];
        message.SourceID = [unarchiver decodeObjectForKey: SOURCE_ID];
        message.MessageType = [unarchiver decodeObjectForKey: MESSAGE_TYPE];
        message.Destination = [unarchiver decodeObjectForKey: DESTINATION];
        message.MessageBody = [unarchiver decodeObjectForKey: MESSAGE_BODY];
        message.Status = [unarchiver decodeObjectForKey: STATUS];

        BOOL accepted = [unarchiver decodeBoolForKey: MESSAGE_WAS_ACCEPTED];
        
        [self.delegate networkManager: self
                      receivedMessage: message
                          wasAccepted: accepted];
        
        [unarchiver release];
    }
}

// Store array of peers - when new array comes in, compare to existing one - if same, do nothing.

#pragma mark - Action Methods
- (NSError *) sendMessage: (Message *) message asAccepted: (BOOL) accepted {
    NSError *error = nil;

    if (self.shouldProcessData) {
        NSMutableData *data = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData: data];
        
        [archiver encodeObject: message.MessageID forKey: MESSAGE_ID];
        [archiver encodeObject: message.HopCount forKey: HOP_COUNT];
        [archiver encodeObject: message.SourceID forKey: SOURCE_ID];
        [archiver encodeObject: message.MessageType forKey: MESSAGE_TYPE];
        [archiver encodeObject: message.Destination forKey: DESTINATION];
        [archiver encodeObject: message.MessageBody forKey: MESSAGE_BODY];
        [archiver encodeObject: message.Status forKey: STATUS];
        [archiver encodeBool: accepted forKey: MESSAGE_WAS_ACCEPTED];
         
        [archiver finishEncoding];
        
        [self.currentSession sendDataToAllPeers: data
                                   withDataMode: GKSendDataReliable
                                          error: &error];
        
        if (!error) {
            [self.delegate networkManager: self
                              sentMessage: message];
        }
        
        [archiver release];
    }
    
    return error;
}

- (NSArray *) localPeers {
    return [self.currentSession peersWithConnectionState: GKSessionModePeer];
}

- (BOOL) peersNearby {
    NSInteger count = 0;
    
    NSArray *localPeers = [self localPeers];
    //TODO
    if (self.peers != localPeers) {
        self.peers = localPeers;
        
        count = [localPeers count];
    }
    
    return count != 0;
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
    NSError *error = nil;
    
    if (self.shouldProcessData) {
        [session acceptConnectionFromPeer: peerID
                                    error: &error];
    }
}

/* Indicates a connection error occurred with a peer, which includes connection request failures, or disconnects due to timeouts.
 */
- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
    
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
    
}
@end
