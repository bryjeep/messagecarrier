//
//  MessageCarrierViewController.m
//  MessageCarrier
//
//  Created by Joey Gibson on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageCarrierViewController.h"
#import "UITextViewWithPlaceholder.h"

@implementation MessageCarrierViewController
@synthesize MessageField, sentCnt, deliveredCnt, carriedCnt, sendMessageBtn, toField, messageType;

@synthesize networkManager;

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

- (void) networkManagerDiscoveredPeers: (NetworkManager *) networkManager {
    NSLog(@"discoveredPeers");
    
    [self.networkManager sendMessage: nil];
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

- (IBAction)SendMessageClicked:(id)sender {
}

- (IBAction)MessageTypeChanged:(id)sender {
}
@end
