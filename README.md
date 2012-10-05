AZLogger
========

This is a small Objective-C class for your Cocoa OS X Applications to log output from your application and give the user the opportunity to send this log to your server for debugging purposes (after an error occured, etc...)

Requirements
============

This class relies on ASIHTTPRequest to post the form data and UKNibowner to present its dialogs and UKSysteminfo to gather information about the users system. For your convenience these classes are included in the repo but feel free to use the latest versions. Please make sure you also meet their license requirements.

You need a cgi script running on your server where your applications can post your logs to. A sample script is included.

License
=======

This class is open source. Please feel free to use it or modify it for use in your commercial or non-commercial application. You are kindly requested to put a copyright note in your applications about box or documentation when you use this class. Something like "this application uses AZLogger by Studio Istanbul/Andreas Zöllner" is completely enough.

Usage
=====

Init

AZLogger *logger = [[AZLogger alloc] initWithURL:[NSURL URLWithString:@"http://myserver.com/cgi-bin/script.cgi"]];

Log something

[logger log:@"something"];

Request to send to server

[[logger logWindow] orderFront:self];

(or do something else with this window...)

Class Interface
===============

See AZLogger.h

