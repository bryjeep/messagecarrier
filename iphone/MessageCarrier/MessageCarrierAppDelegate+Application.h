//
//  MessageCarrierAppDelegate+Application.h
//  MessageCarrier
//
//  Created by Brian Davidson on 6/3/11.
//  Copyright 2011 Georgia Institute of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MessageCarrierAppDelegate.h"

@interface MessageCarrierAppDelegate ( Application )

// Category Definition
//   You should only put methods definition here.
//   You cannot put instance variables in this file.
//   You cannot put properties in this file if you plan to synthesize them.
//   You can put properties in this file if you define the getter and setter manually.
//   You should put the instance variables and sythesized properties definition in MessageCarrierAppDelegate.h
//   You should @synthesize the properties in MessageCarrierAppDelegate.m

+(NSString *)applicationDocumentsDirectory;
@end

