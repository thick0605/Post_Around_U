//
//  MainViewController.m
//  Post
//
//  Created by Vivian on 2017/6/9.
//  Copyright © 2017年 Hsin_Yu. All rights reserved.
//

#import "MainViewController.h"
#import "GeneralData.h"
#import <GooglePlaces/GooglePlaces.h>
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlacePicker/GooglePlacePicker.h>
#import <GLKit/GLKit.h>

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define EARTH_RADIUS 6371

@interface MainViewController (){
    __block NSDictionary *postAround;
    int lastPostID;
    BOOL refreshTag;
}

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _mainScrollView.contentSize = CGSizeMake(_mainScrollView.frame.size.width, 3000);
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    [self.mainScrollView addSubview:self.refreshControl]; //把RefreshControl加到ScrollView中
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:true];
    refreshTag = NO;
    [self fetchNearbyPost];
    [self addPostViewIn:_mainScrollView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//將貼文內容放到view上
- (UIView *)createPostView:(int)index{
    
    NSDictionary *nearbyPostInfo = [postAround objectForKey:[NSString stringWithFormat:@"%d",index]];
    NSLog(@"%@",nearbyPostInfo);
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"Post" owner:nil options:nil];

    //設置poster的大頭照
    UIImageView *userPicView = (UIImageView *)[views[0] viewWithTag:5];
    NSData *userPic = [NSData dataWithContentsOfURL:[NSURL URLWithString:[nearbyPostInfo objectForKey:@"Picture"]]];
    userPicView.image = [UIImage imageWithData:userPic];
    
    //設置poster的姓名
    UILabel *userName = (UILabel *)[views[0] viewWithTag:1];
    userName.text = [nearbyPostInfo objectForKey:@"Name"];
    
    //設置poster的位置
    UILabel *userPlace = (UILabel *)[views[0] viewWithTag:6];
    userPlace.text = [nearbyPostInfo objectForKey:@"PlaceName"];
    
    //設置post的內容
    UILabel *postContext = (UILabel *)[views[0] viewWithTag:2];
    postContext.text = [nearbyPostInfo objectForKey:@"Context"];
    
    //設置post的時間
    UILabel *postTime = (UILabel *)[views[0] viewWithTag:3];
    postTime.text = [self calculateTimeInterval:[nearbyPostInfo objectForKey:@"Time"]];
    
    //設置post的位置
    UILabel *postLocation = (UILabel *)[views[0] viewWithTag:4];
    CGFloat distance = [self calculateDistanceFromLongitude:[nearbyPostInfo objectForKey:@"Longitude"] Latitude:[nearbyPostInfo objectForKey:@"Latitude"]];
    postLocation.text = [NSString stringWithFormat:@"距離:%.2f公里",distance];
    return views[0];
}

//將每個貼文的view放到scroll view
-(void)addPostViewIn:(UIView *)mainView{
    while(!postAround);
    lastPostID = [[[postAround objectForKey:@"0"] objectForKey:@"0"] intValue];
    UIView *postView;
    [self displaceDown:postAround.count];
    
    for (int i=0; i<postAround.count; i++){
        
        postView = [self createPostView:i];
        postView.frame = CGRectMake(0, 220*i, 375, 200);
        [mainView addSubview:postView];
        
    }
    [self.refreshControl endRefreshing];
    

}

//下移scroll view中所有view
-(void)displaceDown:(NSUInteger)times{
    NSArray *mainSubviews = [_mainScrollView subviews];
    UIView *mySubview;
    for (int i=0; i<mainSubviews.count; i++){
        mySubview = mainSubviews[i];
        mySubview.frame = CGRectMake(mySubview.frame.origin.x, mySubview.frame.origin.y+220*times, mySubview.frame.size.width, mySubview.frame.size.height);
    }
}

//抓取方圓5公里內的貼文
-(void)fetchNearbyPost{
    NSLog(@"抓方圓5公里貼文");
    CLLocationCoordinate2D myLocation = CLLocationCoordinate2DMake([GeneralData sharedInstance].user.Latitude, [GeneralData sharedInstance].user.Longitude);
    NSDictionary *coorRange = [self nearBy:myLocation Within:3];
    NSLog(@"座標:%@",coorRange);
    NSMutableDictionary *fetchPost = [NSMutableDictionary dictionaryWithCapacity:6];
    [fetchPost setValue:[NSNumber numberWithBool:refreshTag] forKey:@"refreshTag"];
    [fetchPost setValue:[NSNumber numberWithInt:lastPostID] forKey:@"lastPostID"];
    [fetchPost addEntriesFromDictionary:coorRange];
    NSLog(@"欲傳送之data%@",fetchPost);
    //宣告一個 NSMutableURLRequest 並給予一個記憶體空間
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //宣告一個 NSURL 並給予記憶體空間、連線位置(透過php與Database溝通)
    NSURL *connection = [[NSURL alloc] initWithString:@"http://liocean.esy.es/fetchNearbyPost.php"];
    
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSError *error;
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:fetchPost options:0 error:&error];
    
    //設定連線
    [request setURL:connection];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postdata];
    
    //回傳結果並繼續其他task
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        postAround = (NSDictionary *) [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSLog(@"回傳：%@",postAround);
    }]resume];
}

//計算方圓5公里最大最小經緯度的範圍
- (NSDictionary *)nearBy:(CLLocationCoordinate2D)myCoordinate Within:(CGFloat)distance{
    CGFloat d_lng=2*asin(sin(distance/(2*EARTH_RADIUS))/cos(GLKMathDegreesToRadians(myCoordinate.longitude)));
    d_lng= GLKMathRadiansToDegrees(d_lng);
    
    CGFloat d_lat = distance/EARTH_RADIUS;
    d_lat= GLKMathRadiansToDegrees(d_lat);
    
    NSNumber *d_lng_max= [NSNumber numberWithFloat:myCoordinate.longitude+fabs(d_lng)];//最大經度
    NSNumber *d_lng_min= [NSNumber numberWithFloat:myCoordinate.longitude-fabs(d_lng)];//最小經度
    NSNumber *d_lat_max= [NSNumber numberWithFloat:myCoordinate.latitude+fabs(d_lat)];//最北緯度
    NSNumber *d_lat_min= [NSNumber numberWithFloat:myCoordinate.latitude-fabs(d_lat)];//最南緯度
    NSDictionary *coorRange = @{
                                @"lng_max":d_lng_max,
                                @"lng_min":d_lng_min,
                                @"lat_max":d_lat_max,
                                @"lat_min":d_lat_min
                                };
    NSLog(@"%@",coorRange);
        return coorRange;
}

//計算兩個座標間的距離
- (double)calculateDistanceFromLongitude:(NSString *)longitude Latitude:(NSString *)latitude{
    CLLocation *postLocation = [[CLLocation alloc]initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
    CLLocation *userLocation = [[CLLocation alloc]initWithLatitude:[GeneralData sharedInstance].user.Latitude longitude:[GeneralData sharedInstance].user.Longitude];
       return [userLocation distanceFromLocation:postLocation]/1000;
    
}

//計算當前時間與貼文時間的時間差
- (NSString *)calculateTimeInterval:(NSString *)postTime{
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFomatter = [[NSDateFormatter alloc] init];
    dateFomatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    
    NSString *nowTime = [dateFomatter stringFromDate:nowDate];
    // po文時間date格式
    NSDate *postTimeDate = [dateFomatter dateFromString:postTime];
    // 当前时间date格式
    nowDate = [dateFomatter dateFromString:nowTime];
    // 当前日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // 需要对比的时间数据
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth
    | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute ;
    // 对比时间差
    NSDateComponents *dateCom = [calendar components:unit fromDate:postTimeDate toDate:nowDate options:0];
    
    if (dateCom.year == 0){
        if (dateCom.month == 0){
            if (dateCom.day == 0){
                if (dateCom.hour == 0){
                    return [NSString stringWithFormat:@"%li分鐘前",(long)dateCom.minute];
                }
                else{
                    return [NSString stringWithFormat:@"%li小時前",(long)dateCom.hour];
                }
            }
            else{
                return [NSString stringWithFormat:@"%li天前",(long)dateCom.day];
            }
        }
        else{
            return [NSString stringWithFormat:@"%li月前",(long)dateCom.month];
        }
    }
    else{
        return [NSString stringWithFormat:@"%li年前",(long)dateCom.year];
    }
}

//更新頁面
-(void)refresh{
    NSLog(@"更新摟");
    refreshTag = YES;
    [self fetchNearbyPost];
    [self addPostViewIn:_mainScrollView];
}


















/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
