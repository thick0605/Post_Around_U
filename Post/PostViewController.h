//
//  PostViewController.h
//  Post
//
//  Created by Vivian on 2017/6/7.
//  Copyright © 2017年 Hsin_Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlaces/GooglePlaces.h>
@interface PostViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *myPicView;
@property (weak, nonatomic) IBOutlet UILabel *myName;
@property (weak, nonatomic) IBOutlet UITextView *myTextView;
- (IBAction)sendButtonClick:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *myPostView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic)GMSPlace *chosenPlace;
@end
