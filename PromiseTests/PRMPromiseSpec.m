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
});
#pragma clang diagnostic pop

SPEC_END


