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
typedef void (^PRMRejectedHandler)(id theError);
typedef PRMPromise *(^ThenMethod)(PRMFulfilledHandler onFulfilled, PRMRejectedHandler onRejected);

typedef PRMPromise *(^PRMPromiseResolverBlock)(id theValue);
typedef void (^PRMPromiseResolver)(PRMPromiseResolverBlock resolve, PRMPromiseResolverBlock reject);

@interface PRMPromise : NSObject

@property (nonatomic, readonly, assign) BOOL isFulfilled;
@property (nonatomic, readonly, assign) BOOL isRejected;

- (id)initWithResolver:(PRMPromiseResolver)theResolver;

- (ThenMethod)then;

@end