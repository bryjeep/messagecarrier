//
//  Message.h
//  MessageCarrier
//
//  Created by Brian Davidson on 6/3/11.
//  Copyright (c) 2011 Georgia Institute of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Message : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * Status;
@property (nonatomic, retain) NSString * MessageBody;
@property (nonatomic, retain) NSString * Destination;
@property (nonatomic, retain) NSNumber * HopCount;
@property (nonatomic, retain) NSString * SourceID;
@property (nonatomic, retain) NSString * MessageID;
@property (nonatomic, retain) NSNumber * MessageType;
@property (nonatomic, retain) NSString * SenderName;
@property (nonatomic, retain) NSString * Location;
@property (nonatomic, retain) NSString * TimeStamp;

@end
