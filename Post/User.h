//
//  User.h
//  Post
//
//  Created by Vivian on 2017/6/7.
//  Copyright © 2017年 Hsin_Yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
@interface User : NSObject
@property (nonatomic) FBSDKAccessToken *myAccessToken;
@property (nonatomic) NSString *ID;
@property (nonatomic) NSString *Name;
@property (nonatomic) NSString *Picture;
@property (nonatomic) NSString *Email;
@property (nonatomic) CGFloat Longitude;
@property (nonatomic) CGFloat Latitude;
@end
