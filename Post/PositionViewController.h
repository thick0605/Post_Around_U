//
//  PositionViewController.h
//  Post
//
//  Created by Vivian on 2017/8/9.
//  Copyright © 2017年 Hsin_Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PositionViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *searchResultTableView;
@property (copy, nonatomic) NSMutableArray *placeArray;
@end
