//
//  MessageCarrierViewController.m
//  MessageCarrier
//
//  Created by Joey Gibson on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageCarrierViewController.h"

@implementation MessageCarrierViewController

@synthesize networkManager;

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void) networkManager: (NetworkManager *) networkManager sentMessage: (OutOfBandMessage *) message {
    NSLog(@"sentMessage");
}

- (void) networkManager: (NetworkManager *) networkManager receivedMessage: (OutOfBandMessage *) message wasAccepted: (BOOL) accepted {
    NSLog(@"receivedMessage");
}

- (void) networkManagerDiscoveredPeers: (NetworkManager *) networkManager {
    NSLog(@"discoveredPeers");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    self.networkManager = [[NetworkManager alloc] init];
    self.networkManager.delegate = self;
    
    [self.networkManager startup];
    
//    GKPeerPickerController *picker = [[GKPeerPickerController alloc] init];
//    picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
//    [picker show];    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
