//
//  MessageCarrierViewController.h
//  MessageCarrier
//
//  Created by Joey Gibson on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkManager.h"

@interface MessageCarrierViewController : UIViewController <NetworkManagerDelegate> {
    
}

@property (nonatomic, retain) NetworkManager *networkManager;
@end
