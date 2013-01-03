//
//  AZLogger.h
//  exchangeExport
//
//  Created by Andreas Zöllner on 8/14/12.
//  Copyright 2012 Studio Istanbul. All rights reserved.
//  This class is open source, please feel free to modify and use it
//  in your commercial and non-commercial projects, but please include
//  a short notice about this in your applications about box or documentation.
//
//  please also recognize the license agreements of the 3rd party modules
//  included (ASIHTTPRequest, UKNibowner, UKSysteminfo)
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
    BOOL crashLog;
}

// enable writing of logfile to disk for crashlogs, default NO
@property (assign) BOOL crashLog;

// old init method, depreciated, use initWithURL instead!
-(AZLogger*)init;

// init a new logger object, URL must reply with just ticket ID
-(AZLogger*)initWithURL:(NSURL*)url;

-(void)removeLog;

// log a string
-(void)log:(NSString*)stringToLog;

// output the whole log to system log
-(void)printLogToNSLog;

// for future use - not implemented yet!
-(void)askForSendingLogModalForWindow:(NSWindow*)window;

// set URL for log transfer
-(void)setURL:(NSURL*)url;

// access the Object's window and ask for sending the log.
// you can also use this window as sheet
-(NSWindow*)logWindow;

// methods for interface, do not use them directly
-(IBAction)sendLogToServer:(id)sender;
-(IBAction)closeWindow:(id)sender;
-(IBAction)closePanel:(id)sender;
@end
