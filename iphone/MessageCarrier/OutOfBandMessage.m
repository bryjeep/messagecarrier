//
//  OutOfBandMessage.m
//  MessageCarrier
//
//  Created by Brian Davidson on 6/3/11.
//  Copyright (c) 2011 Georgia Institute of Technology. All rights reserved.
//

#import "OutOfBandMessage.h"


@implementation OutOfBandMessage
@dynamic Status;

@dynamic SourceID;
@dynamic MessageID;
@dynamic Destination;
@dynamic HopCount;
@dynamic Location;
@dynamic TimeStamp;

@dynamic MessageType;
@dynamic SenderName;
@dynamic MessageBody;


-(NSMutableDictionary *)dictionaryRepresentation {
	
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] initWithCapacity:50] autorelease];
    
    [dict setObject: self.SourceID          forKey: @"sourceid"];
    [dict setObject: self.MessageID         forKey: @"messageid"];
	[dict setObject: self.Destination       forKey: @"destination"];
    [dict setObject: self.HopCount          forKey: @"hopcount"];
    [dict setObject: self.Location          forKey: @"location"];
	[dict setObject: self.TimeStamp         forKey: @"timestamp"];
    [dict setObject: self.MessageType       forKey: @"messagetype"];
    [dict setObject: self.SenderName        forKey: @"sendername"];
	[dict setObject: self.MessageBody       forKey: @"messagebody"];
    
	return dict;
}

-(NSString *) string {
    return [NSString stringWithFormat:@"Status = %@\nSourceID = %@\nMessageID=%@\nDestination=%@\nHopCount=%@\nLocation=%@\nTimeStamp=%@\nMessageType=%@\nSenderName=%@\nMessageBody=%@",self.Status,self.SourceID,self.MessageID,self.Destination,self.HopCount,self.Location,self.TimeStamp,self.MessageType,self.SenderName,self.MessageBody];
}
@end
