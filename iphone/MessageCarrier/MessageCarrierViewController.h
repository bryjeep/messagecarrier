//
//  MessageCarrierViewController.h
//  MessageCarrier
//
//  Created by Joey Gibson on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkManager.h"
#import "UITextViewWithPlaceholder.h"
#import <QuartzCore/QuartzCore.h>
#import "UITextViewWithPlaceholder.h"

@interface MessageCarrierViewController : UIViewController<UITextViewDelegate,NetworkManagerDelegate> {
	UITextViewWithPlaceholder *MessageField;
    UILabel *sentCnt;
    UILabel *deliveredCnt;
    UILabel *carriedCnt;
    UIButton *sendMessageBtn;
    UISegmentedControl *messageType;
    UITextField *toField;
}

@property (nonatomic, retain) IBOutlet UITextViewWithPlaceholder *MessageField;
@property (nonatomic, retain) IBOutlet UILabel *sentCnt;
@property (nonatomic, retain) IBOutlet UILabel *deliveredCnt;
@property (nonatomic, retain) IBOutlet UILabel *carriedCnt;
@property (nonatomic, retain) IBOutlet UIButton *sendMessageBtn;
@property (nonatomic, retain) IBOutlet UISegmentedControl *messageType;
@property (nonatomic, retain) IBOutlet UITextField *toField;
@property (nonatomic, retain) NetworkManager *networkManager;

-(void)sendMessage;
- (IBAction)SendMessageClicked:(id)sender;
- (IBAction)MessageTypeChanged:(id)sender;

@end
