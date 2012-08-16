//
//  AZLogger.h
//  exchangeExport
//
//  Created by Andreas Zöllner on 8/14/12.
//  Copyright 2012 Studio Istanbul. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UKNibOwner.h"



@interface AZLogger : UKNibOwner {
	NSMutableArray*		logs;
	NSURL*              remoteUrl;
	IBOutlet NSArrayController*	arrayViewController;
	IBOutlet NSWindow* azwindow;
    IBOutlet NSPanel* statusPanel;
    IBOutlet NSPanel* confirmPanel;
    IBOutlet NSTextField* idField;
    IBOutlet NSProgressIndicator* prog;
    IBOutlet NSTextField* eMailField;
}

-(AZLogger*)init;
-(AZLogger*)initWithURL:(NSURL*)url;
-(void)log:(NSString*)stringToLog;
-(void)printLogToNSLog;
-(void)askForSendingLogModalForWindow:(NSWindow*)window;
-(void)setURL:(NSURL*)url;
-(NSWindow*)logWindow;
-(IBAction)sendLogToServer:(id)sender;
-(IBAction)closeWindow:(id)sender;
-(IBAction)closePanel:(id)sender;
@end
