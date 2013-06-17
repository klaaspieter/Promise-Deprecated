//
//  PRMPromise3.2.5Spec.m
//  Promise
//
//  Created by Klaas Pieter Annema on 17-06-13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Kiwi.h"
#import "helpers.h"

SPEC_BEGIN(PRMPromise3_2_5Spec)

__block NSDictionary *sentinel = @{@"sentinel": @"sentinel"};

#warning The handlers should return this, but we need to support returning from handlers first.
//__block NSDictionary *other = @{@"other": @"other"};

describe(@"3.2.5: `then` may be called multiple times on the same promise.", ^{
    describe(@"3.2.5.1: If/when `promise` is fulfilled, respective `onFulfilled` callbacks must execute in the order ", ^{
        it(@"multiple boring fulfillment handlers", ^{
            PRMPromise *promise = fulfilled(sentinel);

            __block id handler1Value = nil;
            PRMFulfilledHandler handler1 = ^(id theValue) { handler1Value = theValue; };
            __block id handler2Value = nil;;
            PRMFulfilledHandler handler2 = ^(id theValue) { handler2Value = theValue; };
            __block id handler3Value = nil;;
            PRMFulfilledHandler handler3 = ^(id theValue) { handler3Value = theValue; };
            
            __block BOOL rejectedHandlerCalled = NO;
            PRMRejectedHandler rejectedHandler = ^(id theReason) { rejectedHandlerCalled = YES; };
            
            promise.then(handler1, rejectedHandler);
            promise.then(handler2, rejectedHandler);
            promise.then(handler3, rejectedHandler);
            
            __block id value = nil;
            promise.then(^(id theValue) {
                value = theValue;
            }, nil);
            
            waitForIt();
            
            [[value should] equal:sentinel];
            [[handler1Value should] equal:sentinel];
            [[handler2Value should] equal:sentinel];
            [[handler3Value should] equal:sentinel];
            [[theValue(rejectedHandlerCalled) should] beNo];
        });
        
        pending(@"multiple fulfillment handlers, one of which throws", ^{
            PRMPromise *promise = fulfilled(sentinel);
            
            __block id handler1Value = nil;
            PRMFulfilledHandler handler1 = ^(id theValue) { handler1Value = theValue; };
            __block id handler2Value = nil;;
            PRMFulfilledHandler handler2 = ^(id theValue) { @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"" userInfo:nil]; };
            __block id handler3Value = nil;;
            PRMFulfilledHandler handler3 = ^(id theValue) { handler3Value = theValue; };
            
            __block BOOL rejectedHandlerCalled = NO;
            PRMRejectedHandler rejectedHandler = ^(id theReason) { rejectedHandlerCalled = YES; };
            
            promise.then(handler1, rejectedHandler);
            promise.then(handler2, rejectedHandler);
            promise.then(handler3, rejectedHandler);
            
            __block id value = nil;
            promise.then(^(id theValue) {
                value = theValue;
            }, nil);
            
            waitForIt();
            
            [[value should] equal:sentinel];
            [[handler1Value should] equal:sentinel];
            [[handler2Value should] equal:sentinel];
            [[handler3Value should] equal:sentinel];
            [[theValue(rejectedHandlerCalled) should] beNo];
        });
        
        pending(@"results in multiple branching chains with their own fulfillment values", ^{
            //                 var semiDone = callbackAggregator(3, done);
            
            //                 promise.then(function () {
            //                     return sentinel;
            //                 }).then(function (value) {
            //                     assert.strictEqual(value, sentinel);
            //                     semiDone();
            //                 });
            
            //                 promise.then(function () {
            //                     throw sentinel2;
            //                 }).then(null, function (reason) {
            //                     assert.strictEqual(reason, sentinel2);
            //                     semiDone();
            //                 });
            
            //                 promise.then(function () {
            //                     return sentinel3;
            //                 }).then(function (value) {
            //                     assert.strictEqual(value, sentinel3);
            //                     semiDone();
            //                 });
            //             });
        });
        
        it(@"`onFulfilled` handlers are called in the original order", ^{
            PRMPromise *promise = fulfilled(sentinel);
            NSMutableArray *calls = [NSMutableArray array];
            
            PRMFulfilledHandler handler1 = ^(id theValue) { [calls addObject:@1]; };
            PRMFulfilledHandler handler2 = ^(id theValue) { [calls addObject:@2]; };
            PRMFulfilledHandler handler3 = ^(id theValue) { [calls addObject:@3]; };
            
            promise.then(handler1, nil);
            promise.then(handler2, nil);
            promise.then(handler3, nil);
            
            waitForIt();
            
            [[calls[0] should] equal:@1];
            [[calls[1] should] equal:@2];
            [[calls[2] should] equal:@3];
        });
        
        it(@"even when one handler is added inside another handler", ^{
            PRMPromise *promise = fulfilled(sentinel);
            NSMutableArray *calls = [NSMutableArray array];
            
            __block PRMFulfilledHandler handler1 = ^(id theValue) { [calls addObject:@1]; };
            PRMFulfilledHandler handler2 = ^(id theValue) { [calls addObject:@2]; };
            __block PRMFulfilledHandler handler3 = ^(id theValue) { [calls addObject:@3]; };
            
            promise.then(^(id theValue) {
                handler1(theValue);
                promise.then(handler3, nil);
            }, nil);
            promise.then(handler2, nil);
            
            waitForIt();
            
            [[calls[0] should] equal:@1];
            [[calls[1] should] equal:@2];
            [[calls[2] should] equal:@3];
        });
    });
    
    describe(@"3.2.5.2: If/when `promise` is rejected, respective `onRejected` callbacks must execute in the order", ^{
        it(@"multiple boring rejection handlers", ^{
            PRMPromise *promise = rejected(sentinel);
            
            __block id handler1Value = nil;
            PRMFulfilledHandler handler1 = ^(id theValue) { handler1Value = theValue; };
            __block id handler2Value = nil;;
            PRMFulfilledHandler handler2 = ^(id theValue) { handler2Value = theValue; };
            __block id handler3Value = nil;;
            PRMFulfilledHandler handler3 = ^(id theValue) { handler3Value = theValue; };
            
            __block BOOL fulfilledHandlerCalled = NO;
            PRMRejectedHandler fulfilledHandler = ^(id theReason) { fulfilledHandlerCalled = YES; };
            
            promise.then(fulfilledHandler, handler1);
            promise.then(fulfilledHandler, handler2);
            promise.then(fulfilledHandler, handler3);
            
            __block id value = nil;
            promise.then(nil, ^(id theValue) {
                value = theValue;
            });
            
            waitForIt();
            
            [[value should] equal:sentinel];
            [[handler1Value should] equal:sentinel];
            [[handler2Value should] equal:sentinel];
            [[handler3Value should] equal:sentinel];
            [[theValue(fulfilledHandlerCalled) should] beNo];
        });
        
        pending(@"multiple rejection handlers, one of which throws", ^{
            PRMPromise *promise = rejected(sentinel);
            
            __block id handler1Value = nil;
            PRMFulfilledHandler handler1 = ^(id theValue) { handler1Value = theValue; };
            __block id handler2Value = nil;;
            PRMFulfilledHandler handler2 = ^(id theValue) { @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"" userInfo:nil]; };
            __block id handler3Value = nil;;
            PRMFulfilledHandler handler3 = ^(id theValue) { handler3Value = theValue; };
            
            __block BOOL fulfilledHandlerCalled = NO;
            PRMRejectedHandler fulfilledHandler = ^(id theReason) { fulfilledHandlerCalled = YES; };
            
            promise.then(fulfilledHandler, handler1);
            promise.then(fulfilledHandler, handler2);
            promise.then(fulfilledHandler, handler3);
            
            __block id value = nil;
            promise.then(nil, ^(id theValue) {
                value = theValue;
            });
            
            waitForIt();
            
            [[value should] equal:sentinel];
            [[handler1Value should] equal:sentinel];
            [[handler2Value should] equal:sentinel];
            [[handler3Value should] equal:sentinel];
            [[theValue(fulfilledHandlerCalled) should] beNo];
        });
        
        pending(@"results in multiple branching chains with their own fulfillment values", ^{
            
            //             testRejected(sentinel, function (promise, done) {
            //                 var semiDone = callbackAggregator(3, done);
            
            //                 promise.then(null, function () {
            //                     return sentinel;
            //                 }).then(function (value) {
            //                     assert.strictEqual(value, sentinel);
            //                     semiDone();
            //                 });
            
            //                 promise.then(null, function () {
            //                     throw sentinel2;
            //                 }).then(null, function (reason) {
            //                     assert.strictEqual(reason, sentinel2);
            //                     semiDone();
            //                 });
            
            //                 promise.then(null, function () {
            //                     return sentinel3;
            //                 }).then(function (value) {
            //                     assert.strictEqual(value, sentinel3);
            //                     semiDone();
            //                 });
            //             });
            //         });
        });
        
        it(@"`onRejected` handlers are called in the original order", ^{
            PRMPromise *promise = rejected(sentinel);
            NSMutableArray *calls = [NSMutableArray array];
            
            PRMFulfilledHandler handler1 = ^(id theValue) { [calls addObject:@1]; };
            PRMFulfilledHandler handler2 = ^(id theValue) { [calls addObject:@2]; };
            PRMFulfilledHandler handler3 = ^(id theValue) { [calls addObject:@3]; };
            
            promise.then(nil, handler1);
            promise.then(nil, handler2);
            promise.then(nil, handler3);
            
            waitForIt();
            
            [[calls[0] should] equal:@1];
            [[calls[1] should] equal:@2];
            [[calls[2] should] equal:@3];
        });
        
        it(@"even when one handler is added inside another handler", ^{
            PRMPromise *promise = rejected(sentinel);
            NSMutableArray *calls = [NSMutableArray array];
            
            __block PRMFulfilledHandler handler1 = ^(id theValue) { [calls addObject:@1]; };
            PRMFulfilledHandler handler2 = ^(id theValue) { [calls addObject:@2]; };
            __block PRMFulfilledHandler handler3 = ^(id theValue) { [calls addObject:@3]; };
            
            promise.then(nil, ^(id theValue) {
                handler1(theValue);
                promise.then(nil, handler3);
            });
            promise.then(nil, handler2);
            
            waitForIt();
            
            [[calls[0] should] equal:@1];
            [[calls[1] should] equal:@2];
            [[calls[2] should] equal:@3];
        });
    });
});

SPEC_END