//
//  MessageCarrierViewController.h
//  MessageCarrier
//
//  Created by Joey Gibson on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITextViewWithPlaceholder.h"
#import <QuartzCore/QuartzCore.h>
#import "UITextViewWithPlaceholder.h"
#import <AddressBook/AddressBook.h>
#import <CoreFoundation/CoreFoundation.h>
#import <AddressBookUI/AddressBookUI.h>

#import "NetworkManager.h"
#import "OutOfBandMessage.h"

@interface MessageCarrierViewController : UIViewController<UITextViewDelegate,NetworkManagerDelegate, ABPeoplePickerNavigationControllerDelegate> {
	UITextViewWithPlaceholder *MessageField;
    UILabel *sentCnt;
    UILabel *deliveredCnt;
    UILabel *carriedCnt;
    UIButton *sendMessageBtn;
    UIButton *chooseContact;
    UISegmentedControl *messageType;
    UITextField *toField;
    UILabel *charCounter;
    UILabel *connectionLabel;

    NetworkManager *networkManager;
    OutOfBandMessage *message;
}
@property (nonatomic, retain) IBOutlet UILabel *charCounter;

@property (nonatomic, retain) IBOutlet UITextViewWithPlaceholder *MessageField;
@property (nonatomic, retain) IBOutlet UILabel *sentCnt;
@property (nonatomic, retain) IBOutlet UILabel *deliveredCnt;
@property (nonatomic, retain) IBOutlet UILabel *carriedCnt;
@property (nonatomic, retain) IBOutlet UIButton *sendMessageBtn;
@property (nonatomic, retain) IBOutlet UIButton *chooseContact;
@property (nonatomic, retain) IBOutlet UISegmentedControl *messageType;
@property (nonatomic, retain) IBOutlet UITextField *toField;
@property (nonatomic, retain) IBOutlet UILabel *connectionLabel;

@property (nonatomic, retain) NetworkManager *networkManager;
@property (nonatomic, retain) OutOfBandMessage* message;

- (IBAction)choseContactTouch:(id)sender;
-(void)sendMessage;
- (IBAction)SendMessageClicked:(id)sender;
- (IBAction)MessageTypeChanged:(id)sender;
- (void)setConnectionCount:(NSUInteger) cnt;
@end
