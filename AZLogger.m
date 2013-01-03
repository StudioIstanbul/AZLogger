//
//  AZLogger.m
//  exchangeExport
//
//  Created by Andreas Zöllner on 8/14/12.
//  Copyright 2012 Studio Istanbul. All rights reserved.
//

#import "AZLogger.h"
#import "UKSystemInfo.m"
#import "ASIHTTPRequest/ASIHTTPRequest.h"
#import "ASIHTTPRequest/ASIFormDataRequest.h"
#import "NSFileManager+DirectoryLocations.h"

@implementation AZLogger

@synthesize crashLog;

-(AZLogger*)init {
	self = [super init];
	[arrayViewController removeObjectAtArrangedObjectIndex:0];
    self.crashLog = NO;
#ifdef NON_APPSTORE
    //[systemInfo release];
#endif
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[[NSFileManager defaultManager] applicationSupportDirectory] stringByAppendingPathComponent:@"logfile.data"]] == YES) {
        NSLog(@"found crash log!");
        logs = [NSMutableArray arrayWithContentsOfFile:[[[NSFileManager defaultManager] applicationSupportDirectory] stringByAppendingPathComponent:@"logfile.data"]];
        [logs retain];
        [arrayViewController setContent:logs];
        [self.logWindow makeKeyAndOrderFront:self];
    } else {
        logs = [[NSMutableArray alloc]init];
        [arrayViewController setContent:logs];
        NSString* systemInfo = [NSString stringWithString:UKSystemVersionString()];
        [self log:[NSString stringWithFormat:@"Product: %@ - version %@", [[NSBundle mainBundle] bundleIdentifier], [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleVersion"]]];
        [self log:[NSString stringWithFormat:@"System Information: Operating System %@ | Model %@ %u cores | CPU %@ | RAM %u", systemInfo, UKMachineName(),UKCountCores(), UKCPUName(),UKPhysicalRAMSize()]];
        [self log:@"started logging."];
    }
	return self;
}

- (AZLogger*)initWithURL:(NSURL*)url {
    self = [self init];
    remoteUrl = url;
    [remoteUrl retain];
    return self;
}

-(void)setURL:(NSURL*)url {
    if (remoteUrl) [remoteUrl release];
    remoteUrl = url;
    [remoteUrl retain];
}

-(IBAction)closeWindow:(id)sender {
    [azwindow orderOut:self];
}

-(void)log:(NSString *)stringToLog {
	[logs addObject:[NSString stringWithFormat:@"%@: %@", [[NSDate date] description], stringToLog]];
    [arrayViewController rearrangeObjects];
	//[arrayViewController addObject:[NSString stringWithFormat:@"%@: %@", [[NSDate date] description], stringToLog]];
    if (crashLog == YES) {
        [logs writeToURL:[[NSURL fileURLWithPath:[[NSFileManager defaultManager] applicationSupportDirectory] isDirectory:YES] URLByAppendingPathComponent:@"logfile.data"] atomically:NO];
    }
}

-(void)printLogToNSLog {
	for (NSString* logstring in logs) {
		NSLog(@"%@", logstring);
	}
}

-(IBAction)sendLogToServer:(id)sender {
    [NSApp beginSheet:statusPanel modalForWindow:azwindow modalDelegate:self didEndSelector:NULL contextInfo:nil];
    //[NSApp runModalForWindow:statusPanel];
    NSLog(@"sending to %@", [remoteUrl description]);
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:remoteUrl];
    [request setDelegate:self];
    [request addPostValue:@"new" forKey:@"cmd"];
    NSString* logContent = @"";
    for (NSString* elem in logs) {
        logContent = [logContent stringByAppendingString:[NSString stringWithFormat:@"%@::",elem]];
    }
    [request setPostValue:logContent forKey:@"logfile"];
    //NSLog(@"%@", logContent);
    [request setPostValue:[eMailField stringValue] forKey:@"email"];
    [request setPostValue:[[NSBundle mainBundle] bundleIdentifier] forKey:@"product"];
    [request setPostValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"version"];
    [request setPostValue:UKSystemVersionString() forKey:@"osversion"];
    [request setRequestMethod:@"POST"];
    [request setUploadProgressDelegate:prog];
    //[request setRequestFinishSelector:@selector(finishedUpload)];
    [request startAsynchronous];
}
-(void)requestFinished:(ASIHTTPRequest*) request {
    [NSApp stopModal];
    [NSApp endSheet:statusPanel];
    [statusPanel orderOut:self];
    NSString* trackingId = [request responseString];
    NSLog(@"tracking id %@", trackingId);
    //[logs removeAllObjects];
    [idField setStringValue:trackingId];
    int statusCode = [request responseStatusCode];
    NSLog(@"server status %i", statusCode);
    [NSApp beginSheet:confirmPanel modalForWindow:azwindow modalDelegate:self didEndSelector:nil contextInfo:nil];
    //[NSApp runModalForWindow:confirmPanel];
}

-(IBAction)closePanel:(id)sender {
    [confirmPanel orderOut:self];
    [NSApp endSheet:confirmPanel];
    [NSApp stopModal];
    [azwindow orderOut:self];
    [NSApp stopModal];
}

-(void)requestFailed:(ASIHTTPRequest*)request {
    NSLog(@"could not connect to server %@", [[request error] description]);
    [NSApp stopModal];
    [NSApp endSheet:statusPanel];
    [statusPanel orderOut:self];
    NSAlert* alert = [NSAlert alertWithError:[request error]];
    [alert beginSheetModalForWindow:azwindow modalDelegate:self didEndSelector:nil contextInfo:nil];
}

-(void)askForSendingLogModalForWindow:(NSWindow*)window {
	
}

-(NSWindow*)logWindow {
	return azwindow;
}

-(void)dealloc {
    NSLog(@"closing logger");
    [logs release];
    if(remoteUrl) [remoteUrl release];
    [self removeLog];
    [super dealloc];
}

-(void)removeLog {
    if (self.crashLog == YES)[[NSFileManager defaultManager] removeItemAtURL:[[NSURL fileURLWithPath:[[NSFileManager defaultManager] applicationSupportDirectory] isDirectory:YES] URLByAppendingPathComponent:@"logfile.data"] error:nil];
}

@end
