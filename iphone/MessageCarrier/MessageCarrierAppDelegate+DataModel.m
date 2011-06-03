//
//  MessageCarrierAppDelegate+DataModel.m
//  MessageCarrier
//
//  Created by Brian Davidson on 6/3/11.
//  Copyright 2011 Georgia Institute of Technology. All rights reserved.
//

#import "MessageCarrierAppDelegate+DataModel.h"

@implementation MessageCarrierAppDelegate ( DataModel )

#pragma mark -
#pragma mark Private

-(NSURL*)storeURL {
    return [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"messages.sqlite"]];
}

-(void)removeExistingStore {
	NSURL* storeUrl = [self storeURL];
	NSError *error;
    
	NSPersistentStoreCoordinator *storeCoordinator = [self persistentStoreCoordinator];
	if([[storeCoordinator persistentStores] count] > 0){
		NSPersistentStore *store = [[storeCoordinator persistentStores] objectAtIndex:0];
		[storeCoordinator removePersistentStore:store error:&error];
	} else if (storeUrl == nil) {
		return;
	}
	[[NSFileManager defaultManager] removeItemAtPath:storeUrl.path error:&error];
	[storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error];
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	
	NSLog(@"Creating New Managed Object Context [managedObjectContext]");
	
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
		[managedObjectContext setMergePolicy: NSMergeByPropertyObjectTrumpMergePolicy];
		[[managedObjectContext undoManager] disableUndoRegistration];
    }else {
		NSLog(@"PersistentStoreCoordinator is nil while making managedObjectContext");
	}
    
    return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	NSLog(@"Creating New Managed Object Model");
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
	NSLog(@"Creating New Persistent Store Coordinator");
    
	NSURL* storeUrl = [self storeURL];
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
        [self removeExistingStore];
    }
	
    return persistentStoreCoordinator;
}

@end