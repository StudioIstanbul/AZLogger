//
//  AZLogger.m
//  exchangeExport
//
//  Created by Andreas Zöllner on 8/14/12.
//  Copyright 2012 Studio Istanbul. All rights reserved.
//

#import "AZLogger.h"


@implementation AZLogger

-(AZLogger*)init {
	[super init];
	[arrayViewController removeObjectAtArrangedObjectIndex:0];
	logs = [[NSMutableArray alloc]init];
	[logs addObject:[NSString stringWithFormat:@"%@: started logging.", [[NSDate date] description]]];
	[arrayViewController addObject:[NSString stringWithFormat:@"%@: started logging.", [[NSDate date] description]]];
	return self;
}

- (AZLogger*)initWithURL:(NSURL*)url {
    [self init];
    remoteUrl = url;
    return self;
}

-(void)log:(NSString *)stringToLog {
	[logs addObject:[NSString stringWithFormat:@"%@: %@", [[NSDate date] description], stringToLog]];
	[arrayViewController addObject:[NSString stringWithFormat:@"%@: %@", [[NSDate date] description], stringToLog]];
}

-(void)printLogToNSLog {
	for (NSString* logstring in logs) {
		NSLog(@"%@", logstring);
	}
}

-(void)askForSendingLogModalForWindow:(NSWindow*)window {
	
}

-(NSWindow*)logWindow {
	return window;
}

@end
