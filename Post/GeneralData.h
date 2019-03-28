//
//  GeneralData.h
//  Post
//
//  Created by Vivian on 2017/6/7.
//  Copyright © 2017年 Hsin_Yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface GeneralData : NSObject
@property (nonatomic) User *user;
+(GeneralData *) sharedInstance;
@end
