//
//  PRMPromise3.2.3Spec.m
//  Promise
//
//  Created by Klaas Pieter Annema on 17-06-13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Kiwi.h"
#import "helpers.h"

SPEC_BEGIN(PRMPromise3_2_3Spec)

__block NSDictionary *sentinel = @{ @"sentinel": @"sentinel" };
__block NSDictionary *dummy = @{ @"dummy": @"dummy" };

describe(@"3.2.3: If `onRejected` is a function", ^{
    it(@"3.2.3.1: must be called after `promise` is rejected, with `promise`’s rejection reason as its first argument", ^{
        PRMPromise *promise = rejected(sentinel);
        __block id reason = nil;
        promise.then(nil, ^id (id theReason) {
            reason = theReason;
            return theReason;
        });
        
        waitForIt();
        [[reason should] equal:sentinel];
    });
    
    describe(@"3.2.3.2: it must not be called more than once.", ^{
        it(@"already-rejected", ^{
            __block NSUInteger timesCalled = 0;
            
            PRMPromise *promise = rejected(dummy);
            promise.then(nil, ^id (id theReason) {
                timesCalled++;
                return theReason;
            });
            
            waitForIt();
            [[theValue(timesCalled) should] equal:theValue(1)];
        });
        
        it(@"trying to reject a pending promise more than once, immediately", ^{
            PRMPending *tuple = PRMAdapter.pending;
            __block NSUInteger timesCalled = 0;
            
            tuple.promise.then(nil, ^id (id theReason) {
                timesCalled++;
                return theReason;
            });
            
            tuple.reject(dummy);
            tuple.reject(dummy);
            
            waitForIt();
            [[theValue(timesCalled) should] equal:theValue(1)];
        });
        
        it(@"trying to reject a pending promise more than once, delayed", ^{
            PRMPending *tuple = PRMAdapter.pending;
            __block NSUInteger timesCalled = 0;
            
            tuple.promise.then(nil, ^id (id theReason) {
                timesCalled++;
                return theReason;
            });
            
            double delayInSeconds = 0.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                tuple.reject(dummy);
                tuple.reject(dummy);
            });
            
            [[expectFutureValue(theValue(timesCalled)) shouldEventually] equal:theValue(1)];
        });
        
        it(@"trying to reject a pending promise more than once, immediately then delayed", ^{
            PRMPending *tuple = PRMAdapter.pending;
            __block NSUInteger timesCalled = 0;
            
            tuple.promise.then(nil, ^id (id theReason) {
                timesCalled++;
                return theReason;
            });
            
            tuple.reject(dummy);
            
            double delayInSeconds = 0.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                tuple.reject(dummy);
            });
            
            [[expectFutureValue(theValue(timesCalled)) shouldEventually] equal:theValue(1)];
        });
        
        it(@"when multiple `then` calls are made, spaced apart in time", ^{
            PRMPending *tuple = PRMAdapter.pending;
            __block NSUInteger timesCalledFirst = 0;
            __block NSUInteger timesCalledSecond = 0;
            __block NSUInteger timesCalledThird = 0;
            
            tuple.promise.then(nil, ^id (id theReason) {
                timesCalledFirst++;
                return theReason;
            });
            
            __block BOOL secondBlockWasCalled = NO;
            double delayInSeconds = 0.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                tuple.promise.then(nil, ^id (id theReason) {
                    timesCalledSecond++;
                    return theReason;
                });
                secondBlockWasCalled = YES;
            });
            
            __block BOOL thirdBlockWasCalled = NO;
            delayInSeconds = 0.05;
            popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                tuple.promise.then(nil, ^id (id theReason) {
                    timesCalledThird++;
                    return theReason;
                });
                thirdBlockWasCalled = YES;
            });
            
            __block BOOL rejectBlockWasCalled = NO;
            delayInSeconds = 0.1;
            popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                tuple.reject(dummy);
                rejectBlockWasCalled = YES;
            });
            
            [[expectFutureValue(theValue(secondBlockWasCalled)) shouldEventually] beYes];
            [[expectFutureValue(theValue(thirdBlockWasCalled)) shouldEventually] beYes];
            [[expectFutureValue(theValue(rejectBlockWasCalled)) shouldEventually] beYes];
            
            [[expectFutureValue(theValue(timesCalledFirst)) shouldEventually] equal:theValue(1)];
            [[expectFutureValue(theValue(timesCalledSecond)) shouldEventually] equal:theValue(1)];
            [[expectFutureValue(theValue(timesCalledThird)) shouldEventually] equal:theValue(1)];
        });
        
        it(@"when `then` is interleaved with rejection", ^{
            PRMPending *tuple = PRMAdapter.pending;
            __block NSUInteger timesCalledFirst = 0;
            __block NSUInteger timesCalledSecond = 0;
            
            tuple.promise.then(nil, ^id (id theValue) {
                timesCalledFirst++;
                return theValue;
            });
            
            tuple.reject(dummy);
            
            tuple.promise.then(nil, ^id (id theValue) {
                timesCalledSecond++;
                return theValue;
            });
            
            [[expectFutureValue(theValue(timesCalledFirst)) shouldEventually] equal:theValue(1)];
            [[expectFutureValue(theValue(timesCalledSecond)) shouldEventually] equal:theValue(1)];
        });
    });
    
    describe(@"3.2.3.3: it must not be called if `onFulfilled` has been called.", ^{
        it(@"test-fulfilled", ^{
            PRMPromise *promise = fulfilled(dummy);
            __block BOOL onFulfilledCalled = NO;
            __block BOOL onRejectedCalled = NO;
            
            promise.then(^id (id theValue) {
                onFulfilledCalled = YES;
                return theValue;
            }, ^id (id theReason) {
                onRejectedCalled = YES;
                return theReason;
            });
            
            waitForIt();
            [[theValue(onFulfilledCalled) should] beYes];
            [[theValue(onRejectedCalled) should] beNo];
        });
        
        it(@"trying to fulfill then immediately reject", ^{
            PRMPending *tuple = PRMAdapter.pending;
            __block BOOL onFulfilledCalled = NO;
            __block BOOL onRejectedCalled = NO;
            
            tuple.promise.then(^id (id theValue) {
                onFulfilledCalled = YES;
                return theValue;
            }, ^id (id theReason) {
                onRejectedCalled = YES;
                return theReason;
            });
            
            tuple.fulfill(dummy);
            tuple.reject(dummy);
            
            waitForIt();
            [[theValue(onFulfilledCalled) should] beYes];
            [[theValue(onRejectedCalled) should] beNo];
        });
        
        it(@"trying to fulfill then reject, delayed", ^{
            PRMPending *tuple = PRMAdapter.pending;
            __block BOOL onFulfilledCalled = NO;
            __block BOOL onRejectedCalled = NO;
            
            tuple.promise.then(^id (id theValue) {
                onFulfilledCalled = YES;
                return theValue;
            }, ^id (id theReason) {
                onRejectedCalled = YES;
                return theReason;
            });
            
            double delayInSeconds = 0.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                tuple.fulfill(dummy);
                tuple.reject(dummy);
            });
            
            [[expectFutureValue(theValue(onFulfilledCalled)) shouldEventually] beYes];
            [[expectFutureValue(theValue(onRejectedCalled)) shouldEventually] beNo];
        });
        
        it(@"trying to fulfill immediately then reject delayed", ^{
            PRMPending *tuple = PRMAdapter.pending;
            __block BOOL onFulfilledCalled = NO;
            __block BOOL onRejectedCalled = NO;
            
            tuple.promise.then(^id (id theValue) {
                onFulfilledCalled = YES;
                return theValue;
            }, ^id (id theReason) {
                onRejectedCalled = YES;
                return theReason;
            });
            
            tuple.fulfill(dummy);
            
            double delayInSeconds = 0.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                tuple.reject(dummy);
            });
            
            [[expectFutureValue(theValue(onFulfilledCalled)) shouldEventually] beYes];
            [[expectFutureValue(theValue(onRejectedCalled)) shouldEventually] beNo];
        });
    });
});

SPEC_END