//
//  MainViewController.h
//  Post
//
//  Created by Vivian on 2017/6/9.
//  Copyright © 2017年 Hsin_Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MainViewController : UIViewController
@property (nonatomic, strong) IBOutlet UIScrollView *mainScrollView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end
