//
//  MessageCarrierAppDelegate.h
//  MessageCarrier
//
//  Created by Joey Gibson on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class MessageCarrierViewController;

@interface MessageCarrierAppDelegate : NSObject <UIApplicationDelegate> {
	//MessageCarrierAppDelegate+DataModel
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
	NSManagedObjectModel	*managedObjectModel;
	NSManagedObjectContext	*managedObjectContext;
}

#pragma mark -
#pragma mark Properties That Need To Be Synthesized

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MessageCarrierViewController *viewController;

//@synthesize not allowed in a category's implementation thus they must be in MessageCarrierAppDelegate.m


-(NSString *)applicationDocumentsDirectory;
@end
