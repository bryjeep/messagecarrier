//
//  NetworkManager.m
//  MessageCarrier
//
//  Created by Joey Gibson on 6/3/11.
//  Copyright 2011 org.rhok. All rights reserved.
//

#import "SBJson.h"

#import "NetworkManager.h"
#import "MessageCarrierAppDelegate+DataModel.h"

@interface NetworkManager ()

@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) GKSession *currentSession;
@property (nonatomic, retain) NSMutableArray *peers;
@end;

@interface NetworkManager ()//Private Methods

@end

@implementation NetworkManager

@synthesize currentSession;
@synthesize delegate;
@synthesize timer;
@synthesize peers;

#pragma mark -

- (id) init {
    self = [super init];
    
    if (self) {
        self.currentSession = [[GKSession alloc] initWithSessionID: kSESSION_ID
                                                       displayName: nil 
                                                       sessionMode: GKSessionModePeer];
        self.currentSession.delegate = self;
        [self.currentSession setDataReceiveHandler: self
                                       withContext: nil];
        
        self.peers = [NSMutableArray arrayWithCapacity:16];
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

- (BOOL) startup {
    self.currentSession.available = YES;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(bluetoothAvailabilityChanged:)
     name:@"BluetoothAvailabilityChangedNotification"
     object:nil];
    
    //[self checkForPeers];
    
    return YES;
}

- (void)shutdown {
    [self.timer invalidate];
    
    self.currentSession.available = NO;
    
    self.timer = nil;
    self.currentSession = nil;
}

#pragma mark

- (void)bluetoothAvailabilityChanged:(NSNotification *)notification {
    NSLog(@"BT NOT: %@", notification);
}

#pragma mark - Send And Receive

- (NSError *) sendMessage: (OutOfBandMessage *) message {
    return [self sendMessage: message asAccepted: NO];
}

- (NSError *) sendMessage: (OutOfBandMessage *) message asAccepted: (BOOL) accepted {
    NSError *error = nil;
    
    NSLog(@"Sending %@",[message string]);
    
    if (self.currentSession.available) {
        NSMutableData *data = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData: data];
        
        [archiver encodeObject: message.MessageID forKey: kMESSAGE_ID];
        [archiver encodeObject: message.HopCount forKey: kHOP_COUNT];
        [archiver encodeObject: message.SourceID forKey: kSOURCE_ID];
        [archiver encodeObject: message.MessageType forKey: kMESSAGE_TYPE];
        [archiver encodeObject: message.Destination forKey: kDESTINATION];
        [archiver encodeObject: message.MessageBody forKey: kMESSAGE_BODY];
        [archiver encodeObject: message.Status forKey: kSTATUS];
        [archiver encodeObject: message.SenderName forKey: kSENDER_NAME];
        [archiver encodeObject: message.TimeStamp forKey: kDATE_TIME];
        [archiver encodeObject: message.Location forKey: kLOCATION];
        
        [archiver encodeBool: accepted forKey: kMESSAGE_WAS_ACCEPTED];
        
        // TESTING
        //        [archiver encodeObject: @"12345" forKey: kMESSAGE_ID];
        //        [archiver encodeObject: @"This is a test" forKey: kMESSAGE_BODY];
        
        [archiver finishEncoding];
        
        [self.currentSession sendDataToAllPeers: data
                                   withDataMode: GKSendDataReliable
                                          error: &error];        
        [archiver release];
    }
    
    return error;
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
    NSLog(@"receiveData");
    if (self.currentSession.available) {        
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData: data];

        OutOfBandMessage *message = [[MessageCarrierAppDelegate sharedMessageCarrierAppDelegate] createOutOfBoundMessage];
        
        message.MessageID = [unarchiver decodeObjectForKey: kMESSAGE_ID];
        message.HopCount = [unarchiver decodeObjectForKey: kHOP_COUNT];
        message.SourceID = [unarchiver decodeObjectForKey: kSOURCE_ID];
        message.MessageType = [unarchiver decodeObjectForKey: kMESSAGE_TYPE];
        message.Destination = [unarchiver decodeObjectForKey: kDESTINATION];
        message.MessageBody = [unarchiver decodeObjectForKey: kMESSAGE_BODY];
        message.Status = [unarchiver decodeObjectForKey: kSTATUS];
        message.SenderName = [unarchiver decodeObjectForKey: kSENDER_NAME];
        message.TimeStamp = [unarchiver decodeObjectForKey: kDATE_TIME];
        message.Location = [unarchiver decodeObjectForKey: kLOCATION];
        
        NSLog(@"Received %@",[message string]);
        
        BOOL accepted = [unarchiver decodeBoolForKey: kMESSAGE_WAS_ACCEPTED];
        
        [self.delegate networkManager: self
                      receivedMessage: message
                          wasAccepted: accepted];
        
        [unarchiver release];
    }
}


#pragma mark - GKSessionDelegate Methods
/* Indicates a state change for the given peer.
 */
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    switch (state) {
        case GKPeerStateAvailable:
            NSLog(@"Avaiable To Connect To Peer %@", peerID);
            [self.delegate networkManagerDiscoveredPeer: self];
            [self.currentSession connectToPeer: peerID withTimeout: 60];
            break;        
        case GKPeerStateUnavailable:
            NSLog(@"Unable To Connect To Peer %@", peerID);
            break;
        case GKPeerStateConnected:
            [self.delegate networkManagerConnectedPeer: self];
            NSLog(@"Connected To Peer %@", peerID);
            break;        
        case GKPeerStateDisconnected:
            [self.delegate networkManagerDisconnectedPeer: self];
            NSLog(@"Disconnected From Peer %@", peerID);
            break;        
        case GKPeerStateConnecting:
            NSLog(@"Connecting To Peer %@", peerID);
            break;
        default:
            NSLog(@"%@ didChangeState: %d", peerID, state);
            break;
    }
}

/* Indicates a connection request was received from another peer. 
 Accept by calling -acceptConnectionFromPeer:
 Deny by calling -denyConnectionFromPeer:
 */
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
    NSError *error = nil;
    
    if (self.currentSession.available) {
        NSLog(@"Accepting Connection");
        [session acceptConnectionFromPeer: peerID
                                    error: &error];
    }else{
        NSLog(@"---->Not Accepting Connection");
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
