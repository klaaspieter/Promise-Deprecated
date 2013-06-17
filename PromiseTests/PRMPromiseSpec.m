//
//  PromiseSpec.m
//  Promise
//
//  Created by Klaas Pieter Annema on 13-06-13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Kiwi.h"

#import "PRMPromise.h"

SPEC_BEGIN(PRMPromiseSpec)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
describe(@"initialization", ^{
    it(@"throws if the resolver is not a block", ^{
        [[theBlock(^{
            PRMPromise *promise = [[PRMPromise alloc] init];
        }) should] raiseWithName:NSInternalInconsistencyException];
    });
    
    it(@"is resolved if 'resolve' is called with a value", ^{
        NSString *resolvedValue = @"value";
        PRMPromise *promise = [[PRMPromise alloc] initWithResolver:^(PRMPromiseResolverBlock resolve, PRMPromiseResolverBlock reject) {
            resolve(resolvedValue);
        }];
        
        __block NSString *value;
        promise.then(^(id theValue) {
            value = theValue;
        }, nil);
        
        waitForIt();
        [[value should] equal:resolvedValue];
    });
    
    it(@"is rejected if 'reject' is called with a reason", ^{
        NSString *resolvedValue = @"value";
        NSError *rejectedReason = [NSError errorWithDomain:@"" code:0 userInfo:nil];
        PRMPromise *promise = [[PRMPromise alloc] initWithResolver:^(PRMPromiseResolverBlock resolve, PRMPromiseResolverBlock reject) {
            reject(rejectedReason);
        }];
        
        __block NSString *value;
        __block NSError *reason;
        
        promise.then(^(id theValue) {
            value = theValue;
        }, ^(id theReason) {
            reason = theReason;
        });
        
        waitForIt();
        [value shouldBeNil];
        [[reason should] equal:rejectedReason];
    });
    
    it(@"is rejected if the resolver throws an exception", ^{
        NSException *resolvedException = [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Test" userInfo:nil];
        PRMPromise *promise = [[PRMPromise alloc] initWithResolver:^(PRMPromiseResolverBlock resolve, PRMPromiseResolverBlock reject) {
            @throw resolvedException;
        }];
        
        __block NSException *exception = nil;
        promise.then(^(id theValue) {}, ^(id theError) {
            exception = theError;
        });
        
        waitForIt();
        [[exception should] equal:resolvedException];
    });
});
#pragma clang diagnostic pop

SPEC_END


