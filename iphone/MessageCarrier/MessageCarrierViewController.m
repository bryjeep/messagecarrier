//
//  MessageCarrierViewController.m
//  MessageCarrier
//
//  Created by Joey Gibson on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageCarrierViewController.h"
#import "UITextViewWithPlaceholder.h"

#import "MessageCarrierAppDelegate+DataModel.h"
#import "MessageCarrierAppDelegate+Utility.h"

@implementation MessageCarrierViewController
@synthesize MessageField, sentCnt, deliveredCnt, carriedCnt, sendMessageBtn, toField, messageType;

@synthesize networkManager;
@synthesize message;

- (void)dealloc
{
    [super dealloc];
    [self.MessageField dealloc];
    [self.sentCnt dealloc];
    [self.deliveredCnt dealloc];
    [self.carriedCnt dealloc];
    [self.sendMessageBtn dealloc];
    [self.toField dealloc];
    [self.messageType dealloc];
}

- (id) init {
    self = [super init];
    
    if (self) {
        self.message = [[MessageCarrierAppDelegate sharedMessageCarrierAppDelegate] createOutOfBoundMessage];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.MessageField resignFirstResponder];
    [self.toField resignFirstResponder];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.MessageField.layer setBorderColor: [[UIColor grayColor] CGColor]];
    [self.MessageField.layer setBorderWidth: 1.0];
    [self.MessageField.layer setCornerRadius:8.0f];
    [self.MessageField.layer setMasksToBounds:YES];
    [self.MessageField setClipsToBounds:YES];
    
    self.MessageField.delegate = self;
    self.MessageField.placeholder = @"enter your message";
    
    self.sentCnt.text = [[NSNumber numberWithInt:0] stringValue];
    self.deliveredCnt.text = [[NSNumber numberWithInt:0] stringValue];
    self.carriedCnt.text = [[NSNumber numberWithInt:0] stringValue];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField == self.toField) {
        [self.MessageField becomeFirstResponder];
    }
	
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [textView resignFirstResponder];
        if (textView == self.MessageField) {
            [self sendMessage];
        }
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}

- (void) networkManager: (NetworkManager *) networkManager sentMessage: (OutOfBandMessage *) message {
    NSLog(@"XXX sentMessage");
}

- (void) networkManager: (NetworkManager *) networkManager receivedMessage: (OutOfBandMessage *) message wasAccepted: (BOOL) accepted {
    NSLog(@"receivedMessage");
}

- (void) networkManagerDiscoveredPeer: (NetworkManager *) networkManager {
    NSLog(@"discoveredPeer");
}
- (void) networkManagerConnectedPeer: (NetworkManager *) networkManager {
    NSLog(@"addedPeer");
}
- (void) networkManagerDisconnectedPeer: (NetworkManager *) networkManager {
    NSLog(@"removedPeer");
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

-(void)sendMessage {
    //TODO: fill in send logic
}
-(void)resignTextView
{
	[self.MessageField resignFirstResponder];
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

- (IBAction)SendMessageClicked:(id)sender
{	
    NSManagedObjectContext* managedObjectContext = [[MessageCarrierAppDelegate sharedMessageCarrierAppDelegate] managedObjectContext];
	NSError *error = nil;
	
    self.message.Status         = [NSNumber numberWithInt: UNSENT];

    self.message.SourceID       = [[UIDevice currentDevice] uniqueIdentifier];
    self.message.Destination    = self.toField.text;
    self.message.MessageID      = [MessageCarrierAppDelegate createUUID];
    self.message.HopCount       = [NSNumber numberWithInt: 0];
    self.message.Location       = @"Unknown";
    self.message.TimeStamp      = [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
    
    self.message.MessageType    = [NSNumber numberWithInt: [self.messageType selectedSegmentIndex]];
    self.message.SenderName     = @"Somebody";
    self.message.MessageBody    = self.MessageField.text;
    
	if ([managedObjectContext save: &error]){
        [self.networkManager sendMessage:self.message];
        
        self.message = [[MessageCarrierAppDelegate sharedMessageCarrierAppDelegate] createOutOfBoundMessage];
        self.toField.text = @"";
        self.MessageField.text = @"";
    }else{
        NSLog(@"Error Creating Message");
    }
}

- (IBAction)MessageTypeChanged:(id)sender
{
}
@end
