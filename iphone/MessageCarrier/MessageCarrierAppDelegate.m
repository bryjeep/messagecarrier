//
//  MessageCarrierAppDelegate.m
//  MessageCarrier
//
//  Created by Joey Gibson on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageCarrierAppDelegate.h"
#import "MessageCarrierAppDelegate+Application.h"
#import "MessageCarrierAppDelegate+DataModel.h"
#import "MessageCarrierAppDelegate+Utility.h"

@implementation MessageCarrierAppDelegate

#pragma mark -
#pragma mark PolarisAppDelegate+Application

@synthesize window=_window;

@synthesize viewController=_viewController;

#pragma mark -

static MessageCarrierAppDelegate *sharedMessageCarrierAppDelegate = nil;

+ (MessageCarrierAppDelegate *) sharedMessageCarrierAppDelegate
{
	@synchronized(self)
	{
		if (sharedMessageCarrierAppDelegate == nil)
		{
			sharedMessageCarrierAppDelegate = (MessageCarrierAppDelegate*)[[UIApplication sharedApplication] delegate];
		}
	}
	
	return sharedMessageCarrierAppDelegate;
}

#pragma mark -

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}
@end
