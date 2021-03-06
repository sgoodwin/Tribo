//
//  Tribo.m
//  Tribo
//
//  Created by Carter Allen on 9/25/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

#import "TBSite.h"
#import "HTTPServer.h"
#import <ApplicationServices/ApplicationServices.h>

void printHeader(const char *header);
void printError(const char *errorMessage);

int main (int argumentCount, const char *arguments[]) {
	@autoreleasepool {
		NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
		printHeader("Compiling website...");
		TBSite *site = [TBSite new];
		site.root = [NSURL fileURLWithPath:[NSFileManager defaultManager].currentDirectoryPath];
		site.destination = [site.root URLByAppendingPathComponent:@"Output" isDirectory:YES];
		site.sourceDirectory = [site.root URLByAppendingPathComponent:@"Source" isDirectory:YES];
		site.postsDirectory = [site.root URLByAppendingPathComponent:@"Posts" isDirectory:YES];
		site.templatesDirectory = [site.root URLByAppendingPathComponent:@"Templates" isDirectory:YES];
        
        NSError *error = nil;
		BOOL websiteBuilt = [site process:&error];
        if (!websiteBuilt) {
            printError([[error localizedDescription] cStringUsingEncoding:NSUTF8StringEncoding]);
            exit((int)[error code]);
        }
        
		HTTPServer *server = [HTTPServer new];
		server.documentRoot = site.destination.path;
		server.port = 4000;
		[server start:nil];
		printHeader("Development server started at http://localhost:4000/");
		printHeader("Opening website in default web browser...");
		LSOpenCFURLRef((__bridge CFURLRef)[NSURL URLWithString:@"http://localhost:4000/"], NULL);
		[runLoop run];
	}
    return EXIT_SUCCESS;
}

void printHeader(const char *header) {
	printf("\e[1m\e[34m==>\e[0m\e[0m ");
	printf("\e[1m%s\e[0m\n", header);
}
// Maybe you wanna put in special error color codes?
void printError(const char *errorMessage) {
    fprintf(stderr, "\e[1m\e[34m==>\e[0m\e[0m ");
	fprintf(stderr, "\e[1m%s\e[0m\n", errorMessage);
}
