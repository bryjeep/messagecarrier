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
@property (nonatomic, retain) GKSession *currentSession;
@property (nonatomic, retain) NSArray *peers;
@end;

@implementation NetworkManager

@synthesize currentSession;
@synthesize delegate;
@synthesize timer;
@synthesize peers;

- (id) init {
    self = [super init];
    
    if (self) {
        self.currentSession = [[GKSession alloc] initWithSessionID: kSESSION_ID
                                                       displayName: nil 
                                                       sessionMode: GKSessionModePeer];
        self.currentSession.delegate = self;
        [self.currentSession setDataReceiveHandler: self
                                       withContext: nil];
    }
    
    return self;
}

- (void) dealloc {
    self.currentSession = nil;
    self.delegate = nil;
    self.timer = nil;
    self.peers = nil;
    
    [super dealloc];
}

- (void) checkForPeers {
    if ([self peersNearby]) {
        [self.delegate networkManagerDiscoveredPeers: self];
    }
    
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval: 10.0
                                                      target: self
                                                    selector: @selector(checkForPeers)
                                                    userInfo: nil
                                                     repeats: YES];
    }
}

- (BOOL) startup {
    self.currentSession.available = YES;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(bluetoothAvailabilityChanged:)
     name:@"BluetoothAvailabilityChangedNotification"
     object:nil];
    
    [self checkForPeers];
    
    return YES;
}

- (void)bluetoothAvailabilityChanged:(NSNotification *)notification {
    NSLog(@"BT NOT: %@", notification);
}

- (void)shutdown {
    [self.timer invalidate];
    
    self.currentSession.available = NO;
    
    self.timer = nil;
    self.currentSession = nil;
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
    NSLog(@"receiveDate");
    if (self.currentSession.available) {        
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData: data];
        
        OutOfBandMessage *message = [[OutOfBandMessage alloc] init];
        
//        message.MessageID = [unarchiver decodeObjectForKey: kMESSAGE_ID];
//        message.HopCount = [unarchiver decodeObjectForKey: kHOP_COUNT];
//        message.SourceID = [unarchiver decodeObjectForKey: kSOURCE_ID];
//        message.MessageType = [unarchiver decodeObjectForKey: kMESSAGE_TYPE];
//        message.Destination = [unarchiver decodeObjectForKey: kDESTINATION];
//        message.MessageBody = [unarchiver decodeObjectForKey: kMESSAGE_BODY];
//        message.Status = [unarchiver decodeObjectForKey: kSTATUS];
//        message.SenderName = [unarchiver decodeObjectForKey: kSENDER_NAME];
//        message.TimeStamp = [unarchiver decodeObjectForKey: kDATE_TIME];
//        message.Location = [unarchiver decodeObjectForKey: kLOCATION];

        // TESTING
        NSString *id = [unarchiver decodeObjectForKey: kMESSAGE_ID];
        NSString *body = [unarchiver decodeObjectForKey: kMESSAGE_BODY];
        
        NSLog(@"ID: %@, Body: %@", id, body);
        
        BOOL accepted = [unarchiver decodeBoolForKey: kMESSAGE_WAS_ACCEPTED];
        
        [self.delegate networkManager: self
                      receivedMessage: message
                          wasAccepted: accepted];
        
        [unarchiver release];
    }
}

#pragma mark - Action Methods
- (NSError *) sendMessage: (OutOfBandMessage *) message {
    return [self sendMessage: message asAccepted: NO];
}

- (NSError *) sendMessage: (OutOfBandMessage *) message asAccepted: (BOOL) accepted {
    NSError *error = nil;

    if (self.currentSession.available) {
        NSMutableData *data = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData: data];
        
//        [archiver encodeObject: message.MessageID forKey: kMESSAGE_ID];
//        [archiver encodeObject: message.HopCount forKey: kHOP_COUNT];
//        [archiver encodeObject: message.SourceID forKey: kSOURCE_ID];
//        [archiver encodeObject: message.MessageType forKey: kMESSAGE_TYPE];
//        [archiver encodeObject: message.Destination forKey: kDESTINATION];
//        [archiver encodeObject: message.MessageBody forKey: kMESSAGE_BODY];
//        [archiver encodeObject: message.Status forKey: kSTATUS];
//        [archiver encodeObject: message.SenderName forKey: kSENDER_NAME];
//        [archiver encodeObject: message.TimeStamp forKey: kDATE_TIME];
//        [archiver encodeObject: message.Location forKey: kLOCATION];
//
//        [archiver encodeBool: accepted forKey: kMESSAGE_WAS_ACCEPTED];

        // TESTING
        [archiver encodeObject: @"12345" forKey: kMESSAGE_ID];
        [archiver encodeObject: @"This is a test" forKey: kMESSAGE_BODY];
        
        [archiver finishEncoding];
        
//        [self.currentSession sendDataToAllPeers: data
//                                   withDataMode: GKSendDataReliable
//                                          error: &error];
        
        for (NSString *peerID in self.peers) {
            [self.currentSession sendData: data
                                  toPeers: [NSArray arrayWithObject: peerID]
                             withDataMode: GKSendDataReliable
                                    error: &error];
            
            if (!error) {
                [self.delegate networkManager: self
                                  sentMessage: message];
            }
        }
        
        [archiver release];
    }
    
    return error;
}

- (NSArray *) localPeers {
    return [self.currentSession peersWithConnectionState: GKPeerStateAvailable];
}

- (BOOL) peersNearby {
    NSInteger count = 0;
    
    NSArray *localPeers = [self localPeers];

//    NSLog(@"Peers: %@", localPeers);
    
    if (![self.peers isEqualToArray: localPeers]) {
        self.peers = localPeers;
        
        count = [localPeers count];
    }
    
    return count != 0;
}

#pragma mark - GKSessionDelegate Methods
/* Indicates a state change for the given peer.
 */
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    NSLog(@"%@ didChangeState: %d", peerID, state);
}

/* Indicates a connection request was received from another peer. 
 Accept by calling -acceptConnectionFromPeer:
 Deny by calling -denyConnectionFromPeer:
 */
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
    NSError *error = nil;
    
    if (self.currentSession.available) {
        [session acceptConnectionFromPeer: peerID
                                    error: &error];
    }
}

/* Indicates a connection error occurred with a peer, which includes connection request failures, or disconnects due to timeouts.
 */
- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
    NSLog(@"connectionWithPeerFailed: %@, %@", peerID, error);
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
}
@end
