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
@synthesize charCounter;
@synthesize chooseContact;
@synthesize MessageField, sentCnt, deliveredCnt, carriedCnt, sendMessageBtn, toField, messageType;
@synthesize connectionLabel;

@synthesize networkManager;
@synthesize message;

- (void)dealloc
{
    [chooseContact release];
    [charCounter release];
    [connectionLabel release];
    [super dealloc];
    [self.MessageField dealloc];
    [self.sentCnt dealloc];
    [self.deliveredCnt dealloc];
    [self.carriedCnt dealloc];
    [self.sendMessageBtn dealloc];
    [self.toField dealloc];
    [self.messageType dealloc];
    [locationManager dealloc];
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
    
    //load from db
    NSManagedObjectContext *context = [MessageCarrierAppDelegate sharedMessageCarrierAppDelegate].managedObjectContext;
    NSFetchRequest *request = [[MessageCarrierAppDelegate sharedMessageCarrierAppDelegate]createFetchRequestForMessage];
    
    NSError *err;
    NSUInteger totalRecords = [context countForFetchRequest:request error:&err];
    if(totalRecords == NSNotFound) {
        //Handle error
        totalRecords = 0;
        carriedNbr = 0;
    } 
    
    NSPredicate *myMessagesPredicate = [NSPredicate
                              predicateWithFormat:@"(SourceID == %@)",
                              [[UIDevice currentDevice] uniqueIdentifier]];
    [request setPredicate:myMessagesPredicate];
    NSUInteger count = [context countForFetchRequest:request error:&err];
    if(count == NSNotFound) {
        //Handle error
        sentNbr = 0;
    } else {
        sentNbr = count;
        carriedNbr = totalRecords - sentNbr;
    }
    


    NSPredicate *deliveredPredicate = [NSPredicate
                                        predicateWithFormat:@"(Status == %@)",
                                        [NSNumber numberWithInt:SENT]];
    [request setPredicate:deliveredPredicate];
    count = [context countForFetchRequest:request error:&err];
    if(count == NSNotFound) {
        //Handle error
        deliveredNbr = 0;
    } else {
        deliveredNbr = count;
    }
    [request release];
    
    self.sentCnt.text = [[NSNumber numberWithInt:sentNbr] stringValue];
    self.deliveredCnt.text = [[NSNumber numberWithInt:deliveredNbr] stringValue];
    self.carriedCnt.text = [[NSNumber numberWithInt:carriedNbr] stringValue];
    
    UIImage *buttonImageNormal = [UIImage imageNamed:@"action-normal.png"];
    UIImage *stretchableButtonImageNormal = [buttonImageNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    [self.sendMessageBtn setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
    
    UIImage *buttonImagePressed = [UIImage imageNamed:@"action-pressed.png"];
    UIImage *stretchableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    [self.sendMessageBtn setBackgroundImage:stretchableButtonImagePressed forState:UIControlStateHighlighted];
    [self setConnectionCount:0];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    

}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    location = newLocation;
    [locationManager stopUpdatingLocation];
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [locationManager startUpdatingLocation];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField == self.toField) {
        [self.MessageField becomeFirstResponder];
    }
	
    return YES;
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    self.charCounter.hidden = TRUE;
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
        self.charCounter.hidden = TRUE;
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    } else {
        self.charCounter.hidden = FALSE;
        NSUInteger newLength = [textView.text length] + [text length] - range.length;
        self.charCounter.text = [NSString stringWithFormat:@"%d", 140-newLength];
        return (newLength > 140) ? NO : YES;
    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}

- (void) networkManager: (NetworkManager *) networkManager sentMessage: (OutOfBandMessage *) message {
    NSLog(@"XXX sentMessage");
}

- (void) networkManager: (NetworkManager *) networkManager receivedMessage: (OutOfBandMessage *) message wasAccepted: (BOOL) accepted {
    NSLog(@"receivedMessage");
    if (accepted) {
        carriedNbr++;
        self.carriedCnt.text = [[NSNumber numberWithInt:carriedNbr] stringValue];
    }
}

- (void) networkManagerDiscoveredPeer: (NetworkManager *) nm {
    NSLog(@"discoveredPeer");
}
- (void) networkManagerConnectedPeer: (NetworkManager *) nm {
    [self setConnectionCount:[nm currentPeerCount]];
    NSLog(@"addedPeer");
}
- (void) networkManagerDisconnectedPeer: (NetworkManager *) nm {
    [self setConnectionCount:[nm currentPeerCount]];
    NSLog(@"removedPeer");
}

- (void)setConnectionCount:(NSUInteger) cnt{ 
    self.connectionLabel.text = [NSString stringWithFormat:@"%d Nearby Message Carrier%@", cnt, cnt != 1 ? @"s" : @""];
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
    [self SendMessageClicked:self];
}
-(void)resignTextView
{
	[self.MessageField resignFirstResponder];
}
- (void)viewDidUnload
{
    [self setChooseContact:nil];
    [self setCharCounter:nil];
    [self setConnectionLabel:nil];
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
    self.message.Location       = [NSString stringWithFormat:@"%d,%d", location.coordinate.longitude, location.coordinate.latitude ];
    self.message.TimeStamp      = [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
    
    self.message.MessageType    = [NSNumber numberWithInt: [self.messageType selectedSegmentIndex]];
    self.message.SenderName     = @"Somebody";
    self.message.MessageBody    = self.MessageField.text;
    
	if ([managedObjectContext save: &error]){
        [self.networkManager sendMessage:self.message];
        
        self.message = [[MessageCarrierAppDelegate sharedMessageCarrierAppDelegate] createOutOfBoundMessage];
        self.toField.text = @"";
        self.MessageField.text = @"";
        sentNbr++;
        self.sentCnt.text = [[NSNumber numberWithInt:sentNbr] stringValue];
        
    }else{
        NSLog(@"Error Creating Message");
    }
}

- (IBAction)MessageTypeChanged:(id)sender
{
    switch (self.messageType.selectedSegmentIndex) {
        case 0:
            self.toField.enabled =YES;
            self.toField.placeholder = @"destination phone number";
            self.toField.keyboardType = UIKeyboardTypeNamePhonePad;
            self.chooseContact.enabled = YES;
            break;
        case 1:
            self.toField.enabled =YES;
            self.toField.placeholder = @"destination email";
            self.toField.keyboardType = UIKeyboardTypeEmailAddress;
            self.chooseContact.enabled = YES;
            break;
        case 2:
            self.toField.enabled = NO;
            self.toField.placeholder = @"not used";
            self.chooseContact.enabled = NO;
            break;
        default:
            break;
    }
}
- (IBAction)choseContactTouch:(id)sender {
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    if (self.messageType.selectedSegmentIndex == 0) {
        picker.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonPhoneProperty]];
    } else if (self.messageType.selectedSegmentIndex == 1) {
        picker.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonEmailProperty]];
    }
	// place the delegate of the picker to the controll
	picker.peoplePickerDelegate = self;
    
	// showing the picker
	[self presentModalViewController:picker animated:YES];
	// releasing
	[picker release];
}
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    // assigning control back to the main controller
	[self dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController: (ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
	return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    ABMultiValueRef thisProperty = ABRecordCopyValue(person,property);

	NSString *strval = (NSString *)ABMultiValueCopyValueAtIndex(thisProperty,identifier);
    self.toField.text = strval;
	[strval release];
	
	[self dismissModalViewControllerAnimated:YES];
	return NO;
}

@end
