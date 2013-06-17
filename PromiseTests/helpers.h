//
//  helpers.c
//  Promise
//
//  Created by Klaas Pieter Annema on 16-06-13.
//
//

#import <Foundation/Foundation.h>

#import "PRMPromise.h"

@interface PRMPending : NSObject

@property (nonatomic, readonly, strong) PRMPromise *promise;
@property (nonatomic, readonly, strong) PRMPromiseResolverBlock fulfill;
@property (nonatomic, readonly, strong) PRMPromiseResolverBlock reject;

@end

@interface PRMAdapter : NSObject
+ (PRMPending *)pending;
@end

extern PRMPromise *fulfilled(id theValue);
extern PRMPromise *rejected(id theReason);