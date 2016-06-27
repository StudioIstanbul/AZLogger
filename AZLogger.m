//
//  AZLogger.m
//  exchangeExport
//
//  Created by Andreas Zöllner on 8/14/12.
//  Copyright 2012 Studio Istanbul. All rights reserved.
//

#import "AZLogger.h"
#import "UKSystemInfo.h"
#import "NSFileManager+DirectoryLocations.h"
#import "SISheetQueue.h"
#import "NSAlert+BBlock.h"
#import "AFNetworking.h"
#import "NSDictionary+postParameters.h"

@implementation AZLogger

@synthesize crashLog, remoteUrl = _remoteUrl, outputToConsole;

static AZLogger* _azlogger;

+(AZLogger*)sharedLogger {
    @synchronized([AZLogger class]) {
        if (!_azlogger) _azlogger = [[self alloc] init];
        return _azlogger;
    }
    return nil;
}

-(AZLogger*)init {
	self = [super init];
	[arrayViewController removeObjectAtArrangedObjectIndex:0];
    self.crashLog = NO;
#ifdef DEBUG
    outputToConsole = YES;
#else
    outputToConsole = NO;
#endif
#ifdef NON_APPSTORE
    //[systemInfo release];
#endif
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[[NSFileManager defaultManager] applicationSupportDirectory] stringByAppendingPathComponent:@"logfile.data"]] == YES) {
        NSLog(@"found crash log!");
        logs = [NSMutableArray arrayWithContentsOfFile:[[[NSFileManager defaultManager] applicationSupportDirectory] stringByAppendingPathComponent:@"logfile.data"]];
        [arrayViewController setContent:logs];
        [self performSelector:@selector(showWindowModal) withObject:nil afterDelay:1];
    } else {
        logs = [[NSMutableArray alloc]init];
        [arrayViewController setContent:logs];
    }
    NSString* systemInfo = [NSString stringWithString:UKSystemVersionString()];
    [self log:[NSString stringWithFormat:@"Product: %@ - version %@", [[NSBundle mainBundle] bundleIdentifier], [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleVersion"]]];
    [self log:[NSString stringWithFormat:@"System Information: Operating System %@ | Model %@ %u cores | CPU %@ | RAM %u", systemInfo, UKMachineName(),UKCountCores(), UKCPUName(),UKPhysicalRAMSize()]];
    [self log:@"started logging."];
	return self;
}

-(void)showWindowModal {
    [self.logWindow makeKeyAndOrderFront:self];
    [NSApp runModalForWindow:self.logWindow];
}

- (AZLogger*)initWithURL:(NSURL*)url {
    self = [self init];
    _remoteUrl = url;
    return self;
}

-(void)setURL:(NSURL*)url {
    _remoteUrl = url;
}

-(IBAction)closeWindow:(id)sender {
    [azwindow orderOut:self];
    [NSApp stopModal];
}

-(void)logError:(NSError *)error {
    [self log:[NSString stringWithFormat:@"ERROR %li: %@", error.code, error.localizedDescription]];
}

-(void)log:(NSString *)stringToLog {
    NSArray* objectsToLog = [stringToLog componentsSeparatedByString:@"\n"];
    @synchronized(logs) {
        for (NSString* obj in objectsToLog) {
            [logs addObject:[NSString stringWithFormat:@"%@: %@", [[NSDate date] description], obj]];
        }
        if (outputToConsole) {
            NSLog(@"%@", stringToLog);
        }
        [arrayViewController performSelectorOnMainThread:@selector(rearrangeObjects) withObject:nil waitUntilDone:NO];
        if (crashLog == YES) {
            [logs writeToURL:[[NSURL fileURLWithPath:[[NSFileManager defaultManager] applicationSupportDirectory] isDirectory:YES] URLByAppendingPathComponent:@"logfile.data"] atomically:NO];
        }
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
    NSString* logContent = @"";
    for (NSString* elem in logs) {
        logContent = [logContent stringByAppendingString:[NSString stringWithFormat:@"%@::",elem]];
    }
    
    NSLog(@"sending to %@", [_remoteUrl description]);
    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:_remoteUrl];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setValue:@"new" forKey:@"cmd"];
    [params setValue:logContent forKey:@"logfile"];
    [params setValue:[eMailField stringValue] forKey:@"email"];
    [params setValue:[[NSBundle mainBundle] bundleIdentifier] forKey:@"product"];
    [params setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"version"];
    [params setValue:UKSystemVersionString() forKey:@"osversion"];
    [urlRequest setHTTPBody:[params httpBodyForParamsDictionary]];
    NSLog(@"params: %@", params);
    AFHTTPRequestOperation* request = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [request setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        prog.maxValue = totalBytesExpectedToWrite;
        prog.doubleValue = totalBytesWritten;
    }];
    [request setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [NSApp stopModal];
        [NSApp endSheet:statusPanel];
        [statusPanel orderOut:self];
        NSString* trackingId = [operation responseString];
        NSLog(@"tracking id %@", trackingId);
        [idField setStringValue:trackingId];
        int statusCode = [operation.response statusCode];
        NSLog(@"server status %i", statusCode);
        [NSApp beginSheet:confirmPanel modalForWindow:azwindow modalDelegate:self didEndSelector:nil contextInfo:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"could not connect to server %@", [error description]);
        [NSApp stopModal];
        [NSApp endSheet:statusPanel];
        [statusPanel orderOut:self];
        NSAlert* alert = [NSAlert alertWithError:error];
        [alert beginSheetModalForWindow:azwindow modalDelegate:self didEndSelector:nil contextInfo:nil];
    }];
    [request start];
}

-(IBAction)closePanel:(id)sender {
    [confirmPanel orderOut:self];
    [NSApp endSheet:confirmPanel];
    [NSApp stopModal];
    [azwindow orderOut:self];
    [NSApp stopModal];
}

-(void)askForSendingLogModalForWindow:(NSWindow*)window {
	
}

-(NSWindow*)logWindow {
	return azwindow;
}

-(void)dealloc {
    NSLog(@"logger deallocated");
}

-(void)removeLog {
    if (self.crashLog == YES)[[NSFileManager defaultManager] removeItemAtURL:[[NSURL fileURLWithPath:[[NSFileManager defaultManager] applicationSupportDirectory] isDirectory:YES] URLByAppendingPathComponent:@"logfile.data"] error:nil];
}

@end

@implementation AZLoggerAlert

+(AZLoggerAlert*)alertWithError:(NSError *)error {
    AZLoggerAlert* alert = (AZLoggerAlert*)[super alertWithError:error];
    [[AZLogger sharedLogger] log:[NSString stringWithFormat:@"--[ERROR: %li]: %@", error.code, error.localizedDescription]];
    return alert;
}

-(void)queueOnWindow:(NSWindow *)window {
    [self addButtonWithTitle:NSLocalizedString(@"dismiss", @"dismiss AZLoggerAlert")];
    [self addButtonWithTitle:NSLocalizedString(@"open support ticket", @"open support ticket AZLoggerAlert")];
    [[SISheetQueue sharedQueue] queueSheet:self modalForWindow:window completionHandler:^(NSInteger returnCode) {
        if (returnCode == NSAlertSecondButtonReturn) {
            [[SISheetQueue sharedQueue] queueSheet:[[AZLogger sharedLogger] logWindow] modalForWindow:window completionHandler:nil];
        }
    }];
}

-(void)show {
   [self queueOnWindow:nil];
}

@end
