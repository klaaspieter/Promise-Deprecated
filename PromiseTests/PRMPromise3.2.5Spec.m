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

__block NSDictionary *dummy = @{@"dummy": @"dummy"};

__block NSDictionary *sentinel = @{@"sentinel": @"sentinel"};
__block NSDictionary *sentinel3 = @{ @"sentinel3": @"sentinel3" };


__block NSDictionary *other = @{@"other": @"other"};
__block NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException reason:@"" userInfo:nil];

describe(@"3.2.5: `then` may be called multiple times on the same promise.", ^{
    describe(@"3.2.5.1: If/when `promise` is fulfilled, respective `onFulfilled` callbacks must execute in the order ", ^{
        it(@"multiple boring fulfillment handlers", ^{
            PRMPromise *promise = fulfilled(sentinel);

            __block id handler1Value = nil;
            PRMPromiseResolverBlock handler1 = ^id (id theValue) { handler1Value = theValue; return other; };
            __block id handler2Value = nil;;
            PRMPromiseResolverBlock handler2 = ^id (id theValue) { handler2Value = theValue; return other; };
            __block id handler3Value = nil;;
            PRMPromiseResolverBlock handler3 = ^id (id theValue) { handler3Value = theValue; return other; };
            
            __block BOOL rejectedHandlerCalled = NO;
            PRMPromiseResolverBlock rejectedHandler = ^id (id theReason) { rejectedHandlerCalled = YES; return nil; };
            
            promise.then(handler1, rejectedHandler);
            promise.then(handler2, rejectedHandler);
            promise.then(handler3, rejectedHandler);
            
            __block id value = nil;
            promise.then(^id (id theValue) {
                value = theValue;
                return theValue;
            }, nil);
            
            waitForIt();
            
            [[value should] equal:sentinel];
            [[handler1Value should] equal:sentinel];
            [[handler2Value should] equal:sentinel];
            [[handler3Value should] equal:sentinel];
            [[theValue(rejectedHandlerCalled) should] beNo];
        });
        
        it(@"multiple fulfillment handlers, one of which throws", ^{
            PRMPromise *promise = fulfilled(sentinel);
            
            __block id handler1Value = nil;
            PRMPromiseResolverBlock handler1 = ^id (id theValue) { handler1Value = theValue; return other; };
            __block id handler2Value = nil;;
            PRMPromiseResolverBlock handler2 = ^id (id theValue) { handler2Value = theValue; @throw exception; return other; };
            __block id handler3Value = nil;;
            PRMPromiseResolverBlock handler3 = ^id (id theValue) { handler3Value = theValue; return other; };
            
            __block BOOL rejectedHandlerCalled = NO;
            PRMPromiseResolverBlock rejectedHandler = ^id (id theReason) { rejectedHandlerCalled = YES; return nil; };
            
            promise.then(handler1, rejectedHandler);
            promise.then(handler2, rejectedHandler);
            promise.then(handler3, rejectedHandler);
            
            __block id value = nil;
            promise.then(^id (id theValue) {
                value = theValue;
                return theValue;
            }, nil);
            
            waitForIt();
            
            [[value should] equal:sentinel];
            [[handler1Value should] equal:sentinel];
            [[handler2Value should] equal:sentinel];
            [[handler3Value should] equal:sentinel];
            [[theValue(rejectedHandlerCalled) should] beNo];
        });
        
        it(@"results in multiple branching chains with their own fulfillment values", ^{
            
            PRMPromise *promise = fulfilled(dummy);
            __block id value1 = nil;
            __block id value2 = nil;
            __block id value3 = nil;
            
            ((PRMPromise *)promise.then(^id (id theValue) {
                return sentinel;
            }, nil)).then(^id (id theValue) {
                value1 = theValue;
                return nil;
            }, nil);

            ((PRMPromise *)promise.then(^id (id theValue) {
                @throw exception;
            }, nil)).then(nil, ^id (id theReason) {
                value2 = theReason;
                return nil;
            });

            ((PRMPromise *)promise.then(^id (id theValue) {
                return sentinel3;
            }, nil)).then(^id (id theValue) {
                value3 = theValue;
                return nil;
            }, nil);

            waitForIt();
            [[value1 should] equal:sentinel];
            [[value2 should] equal:exception];
            [[value3 should] equal:sentinel3];
        });
        
        it(@"`onFulfilled` handlers are called in the original order", ^{
            PRMPromise *promise = fulfilled(sentinel);
            NSMutableArray *calls = [NSMutableArray array];
            
            PRMPromiseResolverBlock handler1 = ^id (id theValue) { [calls addObject:@1]; return theValue; };
            PRMPromiseResolverBlock handler2 = ^id (id theValue) { [calls addObject:@2]; return theValue; };
            PRMPromiseResolverBlock handler3 = ^id (id theValue) { [calls addObject:@3]; return theValue; };
            
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
            
            __block PRMPromiseResolverBlock handler1 = ^id (id theValue) { [calls addObject:@1]; return theValue; };
            PRMPromiseResolverBlock handler2 = ^id (id theValue) { [calls addObject:@2]; return theValue; };
            __block PRMPromiseResolverBlock handler3 = ^id (id theValue) { [calls addObject:@3]; return theValue; };
            
            promise.then(^id (id theValue) {
                handler1(theValue);
                promise.then(handler3, nil);
                return theValue;
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
            PRMPromiseResolverBlock handler1 = ^id (id theValue) { handler1Value = theValue; return other; };
            __block id handler2Value = nil;;
            PRMPromiseResolverBlock handler2 = ^id (id theValue) { handler2Value = theValue; return other; };
            __block id handler3Value = nil;;
            PRMPromiseResolverBlock handler3 = ^id (id theValue) { handler3Value = theValue; return other; };
            
            __block BOOL fulfilledHandlerCalled = NO;
            PRMPromiseResolverBlock fulfilledHandler = ^id (id theReason) { fulfilledHandlerCalled = YES; return nil; };
            
            promise.then(fulfilledHandler, handler1);
            promise.then(fulfilledHandler, handler2);
            promise.then(fulfilledHandler, handler3);
            
            __block id value = nil;
            promise.then(nil, ^id (id theValue) {
                value = theValue;
                return theValue;
            });
            
            waitForIt();
            
            [[value should] equal:sentinel];
            [[handler1Value should] equal:sentinel];
            [[handler2Value should] equal:sentinel];
            [[handler3Value should] equal:sentinel];
            [[theValue(fulfilledHandlerCalled) should] beNo];
        });
        
        it(@"multiple rejection handlers, one of which throws", ^{
            PRMPromise *promise = rejected(sentinel);
            
            __block id handler1Value = nil;
            PRMPromiseResolverBlock handler1 = ^id (id theValue) { handler1Value = theValue; return other; };
            __block id handler2Value = nil;;
            PRMPromiseResolverBlock handler2 = ^id (id theValue) { handler2Value = theValue; @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"" userInfo:nil];};
            __block id handler3Value = nil;;
            PRMPromiseResolverBlock handler3 = ^id (id theValue) { handler3Value = theValue; return other; };
            
            __block BOOL fulfilledHandlerCalled = NO;
            PRMPromiseResolverBlock fulfilledHandler = ^id (id theReason) { fulfilledHandlerCalled = YES; return nil; };
            
            promise.then(fulfilledHandler, handler1);
            promise.then(fulfilledHandler, handler2);
            promise.then(fulfilledHandler, handler3);
            
            __block id value = nil;
            promise.then(nil, ^id (id theValue) {
                value = theValue;
                return theValue;
            });
            
            waitForIt();
            
            [[value should] equal:sentinel];
            [[handler1Value should] equal:sentinel];
            [[handler2Value should] equal:sentinel];
            [[handler3Value should] equal:sentinel];
            [[theValue(fulfilledHandlerCalled) should] beNo];
        });
        
        it(@"results in multiple branching chains with their own fulfillment values", ^{
            
            PRMPromise *promise = rejected(dummy);
            __block id value1 = nil;
            __block id value2 = nil;
            __block id value3 = nil;
            
            ((PRMPromise *)promise.then(nil, ^id (id theValue) {
                return sentinel;
            })).then(^id (id theValue) {
                value1 = theValue;
                return nil;
            }, nil);
            
            ((PRMPromise *)promise.then(nil, ^id (id theValue) {
                @throw exception;
            })).then(nil, ^id (id theReason) {
                value2 = theReason;
                return nil;
            });
            
            ((PRMPromise *)promise.then(nil, ^id (id theValue) {
                return sentinel3;
            })).then(^id (id theValue) {
                value3 = theValue;
                return nil;
            }, nil);
            
            waitForIt();
            [[value1 should] equal:sentinel];
            [[value2 should] equal:exception];
            [[value3 should] equal:sentinel3];

        });
        
        it(@"`onRejected` handlers are called in the original order", ^{
            PRMPromise *promise = rejected(sentinel);
            NSMutableArray *calls = [NSMutableArray array];
            
            PRMPromiseResolverBlock handler1 = ^id (id theValue) { [calls addObject:@1]; return other; };
            PRMPromiseResolverBlock handler2 = ^id (id theValue) { [calls addObject:@2]; return other; };
            PRMPromiseResolverBlock handler3 = ^id (id theValue) { [calls addObject:@3]; return other; };
            
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
            
            __block PRMPromiseResolverBlock handler1 = ^id (id theValue) { [calls addObject:@1]; return other; };
            PRMPromiseResolverBlock handler2 = ^id (id theValue) { [calls addObject:@2]; return other; };
            __block PRMPromiseResolverBlock handler3 = ^id (id theValue) { [calls addObject:@3]; return other; };
            
            promise.then(nil, ^id (id theValue) {
                handler1(theValue);
                promise.then(nil, handler3);
                return theValue;
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