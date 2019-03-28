//
//  GeneralData.m
//  Post
//
//  Created by Vivian on 2017/6/7.
//  Copyright © 2017年 Hsin_Yu. All rights reserved.
//

#import "GeneralData.h"

@implementation GeneralData

static GeneralData __strong *generalDataObject = nil;

@synthesize user;

+(GeneralData *) sharedInstance
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        generalDataObject = [[self alloc]init];
    });
    return generalDataObject;
}
@end
