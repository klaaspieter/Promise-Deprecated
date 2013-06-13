//
//  Promise.h
//  Promise
//
//  Created by Klaas Pieter Annema on 13-06-13.
//
//

#import <Foundation/Foundation.h>

@class PRMPromise;

typedef void (^PRMFulfilledHandler)(id theResult);
typedef void (^PRMRejectedHandler)(NSError *theError);

typedef PRMPromise *(^ThenMethod)(PRMFulfilledHandler onFulfilled, PRMRejectedHandler onRejected);

@interface PRMPromise : NSObject

@property (nonatomic, readonly, assign) BOOL isFulfilled;
@property (nonatomic, readonly, assign) BOOL isRejected;

- (ThenMethod)then;

- (PRMPromise *)rejectWithError:(NSError *)theError;
- (PRMPromise *)fulfillWithValue:(id)theValue;

@end