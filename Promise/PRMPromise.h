//
//  Promise.h
//  Promise
//
//  Created by Klaas Pieter Annema on 13-06-13.
//
//

#import <Foundation/Foundation.h>

@class PRMPromise;

typedef id (^PRMPromiseResolverBlock)(id theValue);

typedef id (^ThenMethod)(PRMPromiseResolverBlock onFulfilled, PRMPromiseResolverBlock onRejected);
typedef void (^PRMPromiseResolver)(PRMPromiseResolverBlock resolve, PRMPromiseResolverBlock reject);

@interface PRMPromise : NSObject

@property (nonatomic, readonly, assign) BOOL isFulfilled;
@property (nonatomic, readonly, assign) BOOL isRejected;

- (id)initWithResolver:(PRMPromiseResolver)theResolver;

- (ThenMethod)then;

@end