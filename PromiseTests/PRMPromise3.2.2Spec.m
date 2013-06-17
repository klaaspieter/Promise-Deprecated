//
//  PRMPromise3.2.2Spec.m
//  Promise
//
//  Created by Klaas Pieter Annema on 16-06-13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Kiwi.h"
#import "helpers.h"

SPEC_BEGIN(PRMPromise3_2_2Spec)

__block NSDictionary *dummy = @{ @"dummy": @"dummy" };

__block id value;
//__block id reason;

describe(@"3.2.2: If ~onFulfilled` is a function, ", ^{
    it(@"3.2.2.1: must be called after `promise` is fulfilled, with `promise`'s fulfillment value as its first argument", ^{
        fulfilled(dummy).then(^(id theValue) {
            value = theValue;
        }, nil);
        
        waitForIt();
        [[value should] equal:dummy];
    });
    
    describe(@"3.2.2.2: it must not be called more than once.", ^{
        it(@"already-fulfilled", ^{
            __block NSUInteger timesCalled = 0;
            fulfilled(dummy).then(^(id theValue) {
                timesCalled++;
            }, nil);
            
            waitForIt();
            [[theValue(timesCalled) should] equal:theValue(1)];
        });
        
        it(@"trying to fulfill a pending promise more than once, immediately", ^{
            PRMPending *tuple = PRMAdapter.pending;
            __block NSUInteger timesCalled = 0;
            
            tuple.promise.then(^(id theValue) {
                timesCalled++;
            }, nil);
            
            tuple.fulfill(dummy);
            tuple.fulfill(dummy);
            
            waitForIt();
            [[theValue(timesCalled) should] equal:theValue(1)];
        });
        
        it(@"trying to fulfill a pending promise more than once, delayed", ^{
            PRMPending *tuple = PRMAdapter.pending;
            __block NSUInteger timesCalled = 0;
            
            tuple.promise.then(^(id theValue) {
                timesCalled++;
            }, nil);
            
            double delayInSeconds = 0.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                tuple.fulfill(dummy);
                tuple.fulfill(dummy);
            });
            
            [[expectFutureValue(theValue(timesCalled)) shouldEventually] equal:theValue(1)];
        });
        
        it(@"trying to fulfill a pending promise more than once, immediately then delayed", ^{
            PRMPending *tuple = PRMAdapter.pending;
            __block NSUInteger timesCalled = 0;
            
            tuple.promise.then(^(id theValue) {
                timesCalled++;
            }, nil);
            
            tuple.fulfill(dummy);
            
            __block BOOL wasCalled = NO;
            double delayInSeconds = 0.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                tuple.fulfill(dummy);
                wasCalled = YES;
            });
            
            [[expectFutureValue(theValue(wasCalled)) shouldEventually] beYes];
            [[expectFutureValue(theValue(timesCalled)) shouldEventually] equal:theValue(1)];
        });
        
        it(@"when multiple `then` calls are made, spaced apart in time", ^{
            PRMPending *tuple = PRMAdapter.pending;
            __block NSUInteger timesCalledFirst = 0;
            __block NSUInteger timesCalledSecond = 0;
            __block NSUInteger timesCalledThird = 0;
            
            tuple.promise.then(^(id theValue) {
                timesCalledFirst++;
            }, nil);
            
            __block BOOL secondBlockWasCalled = NO;
            double delayInSeconds = 0.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                tuple.promise.then(^(id theValue) {
                    timesCalledSecond++;
                }, nil);
                secondBlockWasCalled = YES;
            });
            
            __block BOOL thirdBlockWasCalled = NO;
            delayInSeconds = 0.05;
            popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                tuple.promise.then(^(id theValue) {
                    timesCalledThird++;
                }, nil);
                thirdBlockWasCalled = YES;
            });
            
            __block BOOL fulfillBlockWasCalled = NO;
            delayInSeconds = 0.1;
            popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                tuple.fulfill(dummy);
                fulfillBlockWasCalled = YES;
            });
            
            [[expectFutureValue(theValue(secondBlockWasCalled)) shouldEventually] beYes];
            [[expectFutureValue(theValue(thirdBlockWasCalled)) shouldEventually] beYes];
            [[expectFutureValue(theValue(fulfillBlockWasCalled)) shouldEventually] beYes];
            
            [[expectFutureValue(theValue(timesCalledFirst)) shouldEventually] equal:theValue(1)];
            [[expectFutureValue(theValue(timesCalledSecond)) shouldEventually] equal:theValue(1)];
            [[expectFutureValue(theValue(timesCalledThird)) shouldEventually] equal:theValue(1)];
        });
        
        it(@"when `then` is interleaved with fulfillment", ^{
            PRMPending *tuple = PRMAdapter.pending;
            __block NSUInteger timesCalledFirst = 0;
            __block NSUInteger timesCalledSecond = 0;
            
            tuple.promise.then(^(id theValue) {
                timesCalledFirst++;
            }, nil);
            
            tuple.fulfill(dummy);
            
            tuple.promise.then(^(id theValue) {
                timesCalledSecond++;
            }, nil);
            
            [[expectFutureValue(theValue(timesCalledFirst)) shouldEventually] equal:theValue(1)];
            [[expectFutureValue(theValue(timesCalledSecond)) shouldEventually] equal:theValue(1)];
        });
    });
    
    describe(@"3.2.2.3: it must not be called if `onRejected` has been called.", ^{
        it(@"trying to reject then immediately fulfill", ^{
            PRMPending *tuple = PRMAdapter.pending;
            __block BOOL onFulfilledCalled = NO;
            __block BOOL onRejectedCalled = NO;
            
            tuple.promise.then(^(id theValue) {
                onFulfilledCalled = YES;
            }, ^(id theReason) {
                onRejectedCalled = YES;
            });
            
            tuple.reject(dummy);
            tuple.fulfill(dummy);
            
            waitForIt();
            [[theValue(onFulfilledCalled) should] beNo];
            [[theValue(onRejectedCalled) should] beYes];
        });
        
        it(@"trying to reject then fulfill, delayed", ^{
            PRMPending *tuple = PRMAdapter.pending;
            __block BOOL onFulfilledCalled = NO;
            __block BOOL onRejectedCalled = NO;
            
            tuple.promise.then(^(id theValue) {
                onFulfilledCalled = YES;
            }, ^(id theReason) {
                onRejectedCalled = YES;
            });
            
            double delayInSeconds = 0.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                tuple.reject(dummy);
                tuple.fulfill(dummy);
            });
            
            [[expectFutureValue(theValue(onFulfilledCalled)) shouldEventually] beNo];
            [[expectFutureValue(theValue(onRejectedCalled)) shouldEventually] beYes];
        });
        
        it(@"trying to reject immediately then fulfill delayed", ^{
            PRMPending *tuple = PRMAdapter.pending;
            __block BOOL onFulfilledCalled = NO;
            __block BOOL onRejectedCalled = NO;
            
            tuple.promise.then(^(id theValue) {
                onFulfilledCalled = YES;
            }, ^(id theReason) {
                onRejectedCalled = YES;
            });
            
            tuple.reject(dummy);
            
            double delayInSeconds = 0.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                tuple.fulfill(dummy);
            });
            
            [[expectFutureValue(theValue(onFulfilledCalled)) shouldEventually] beNo];
            [[expectFutureValue(theValue(onRejectedCalled)) shouldEventually] beYes];
        });
    });
});

SPEC_END