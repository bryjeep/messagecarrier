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

@property (nonatomic, retain) GKSession *currentSession;

@end;

@interface NetworkManager ()//Private Methods

@end

@implementation NetworkManager

@synthesize currentSession;
@synthesize delegate;


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
    }
    
    return self;
}

- (void) dealloc {
    self.currentSession = nil;
    self.delegate = nil;
    
    [super dealloc];
}

- (BOOL) startup {
    self.currentSession.available = YES;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(bluetoothAvailabilityChanged:)
     name:@"BluetoothAvailabilityChangedNotification"
     object:nil];

    return YES;
}

- (void)shutdown {
    self.currentSession.available = NO;
    
    self.currentSession = nil;
}

- (int)currentPeerCount {
    return [[self.currentSession peersWithConnectionState: GKPeerStateConnected] count];
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
    
    NSString *dataString = [[message dictionaryRepresentation] JSONRepresentation];
    
    NSLog(@"Sending %@",dataString);
    
    if (self.currentSession.available) {  
        [self.currentSession sendDataToAllPeers: [dataString dataUsingEncoding: NSUTF8StringEncoding]
                                   withDataMode: GKSendDataReliable
                                          error: &error];        
    }
    
    return error;
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
    NSLog(@"receiveData");
    if (self.currentSession.available) {
        NSString* string = [NSString stringWithUTF8String:[data bytes]];
        NSLog(@"Received %@",string);
        
        NSDictionary* dictionary = (NSDictionary*)[string JSONValue];
        if([dictionary objectForKey:@"ack"]){
            NSFetchRequest  *fetchRequest = [[MessageCarrierAppDelegate sharedMessageCarrierAppDelegate] createFetchRequestForMessageWithID: [dictionary objectForKey:@"messageid"]];
            NSManagedObjectContext * managedObjectContext = [MessageCarrierAppDelegate sharedMessageCarrierAppDelegate].managedObjectContext;
            
            NSError* error;
            NSArray* results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if(!results){
                NSLog(@"Error Fetching Results %@",error);
                return;
            }
            if ([results count]){
                OutOfBandMessage * message = [results objectAtIndex:0];
                message.MessageAttempts = [NSNumber numberWithInt:[message.MessageAttempts intValue] + 1];
                
                if ([managedObjectContext save: &error]){
                    NSLog(@"Received an ACK for %@",[dictionary objectForKey:@"messageid"]);

                }else{
                    NSLog(@"Error Modifying Message");
                }
            }
        }else{
            NSError* error;
            
            NSFetchRequest  *fetchRequest = [[MessageCarrierAppDelegate sharedMessageCarrierAppDelegate] createFetchRequestForMessageWithID: [dictionary objectForKey:@"messageid"]];
            NSManagedObjectContext * managedObjectContext = [MessageCarrierAppDelegate sharedMessageCarrierAppDelegate].managedObjectContext;
            
            NSArray* results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if(!results){
                NSLog(@"Error Fetching Results %@",error);
                return;
            }
            
            if ([results count]){                
                [self.delegate networkManager: self
                              receivedMessage: (OutOfBandMessage *) [results objectAtIndex:0]
                                  wasAccepted: NO];
            }else{
                OutOfBandMessage *message = [[MessageCarrierAppDelegate sharedMessageCarrierAppDelegate] createOutOfBoundMessage];            
                [message setWithDictionaryRepresentation: dictionary];
                
                if(![[[MessageCarrierAppDelegate sharedMessageCarrierAppDelegate] managedObjectContext] save:&error]){
                    NSLog(@"Save Error %@",error);
                }else{
                    [self.delegate networkManager: self
                                  receivedMessage: message
                                      wasAccepted: YES];
                    NSDictionary* ack = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:TRUE],@"ack",message.MessageID,@"messageid",nil];
                    [self.currentSession sendData:[[ack JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding] toPeers:[NSArray arrayWithObject: peer] withDataMode:GKSendDataReliable error:&error];               
                }
            }
        }
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
