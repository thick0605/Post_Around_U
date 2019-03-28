//
//  PostViewController.m
//  Post
//
//  Created by Vivian on 2017/6/7.
//  Copyright © 2017年 Hsin_Yu. All rights reserved.
//

#import "PostViewController.h"
#import "GeneralData.h"
#import <CoreLocation/CoreLocation.h>
#import "PositionViewController.h"
#import "AppDelegate.h"
@import GooglePlaces;

@interface PostViewController () <CLLocationManagerDelegate,UITextViewDelegate>{
    User *currentUser;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    GMSPlacesClient *_placesClient;
    NSMutableArray *_placeArray;
}

@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _myTextView.delegate = self;
    locationManager = [[CLLocationManager alloc] init];
    [locationManager requestWhenInUseAuthorization];
    //設定delegate
    locationManager.delegate = self;
    
    currentUser = [GeneralData sharedInstance].user;
    _placesClient = [GMSPlacesClient sharedClient];
    [self getCurrentPlace];
    [self setPicAndName];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPlace:) name:@"chosenPlace" object:nil];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:true];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

//設定po文頁面使用者大頭照及名字
-(void)setPicAndName{
    NSData *userPic = [NSData dataWithContentsOfURL:[NSURL URLWithString:currentUser.Picture]];
    _myPicView.image = [UIImage imageWithData:userPic];
    _myName.text = currentUser.Name;
}

//設定po文者選取的地標
-(void)setPlace:(NSNotification *)notification{
    _chosenPlace = (GMSPlace *)notification.object;
    if(notification.object){
        _nameLabel.text = _chosenPlace.name;
    }
}
//按下送出按鈕
-(void)sendButtonClick:(id)sender{
    
    [self postToDatabase];
}

//隱藏鍵盤
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![_myTextView isExclusiveTouch]) {
        [_myTextView resignFirstResponder];
    }
}

//將內容上傳至資料庫
-(void)postToDatabase{
    //宣告一個 NSMutableURLRequest 並給予一個記憶體空間
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //宣告一個 NSURL 並給予記憶體空間、連線位置(透過php與Database溝通)
    NSURL *connection = [[NSURL alloc] initWithString:@"http://liocean.esy.es/post.php"];

    //將欲傳送之個人資料以json格式傳送
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *payload = @{
                               @"username":@"u564252906_hsu",
                               @"password":@"thick65a",
                               @"poster":currentUser.ID,
                               @"name":currentUser.Name,
                               @"context":_myTextView.text,
                               @"longitude":[NSNumber numberWithDouble:_chosenPlace.coordinate.longitude],
                               @"latitude":[NSNumber numberWithDouble:_chosenPlace.coordinate.latitude],
                               @"placeName":_chosenPlace.name,
                               @"placeID":_chosenPlace.placeID
                               };
    NSError *error;
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&error];
    
    //設定連線
    [request setURL:connection];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postdata];
    
    //回傳結果並繼續其他task
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if([[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] isEqualToString:@"ok"]){
            NSLog(@"post success");

        };
        
    }]resume];
    UITabBarController *rootController = self.tabBarController;
    rootController.selectedIndex = 0;
    

}

//取得最近地標
- (void)getCurrentPlace {
    _placeArray = [[NSMutableArray alloc]init];
    [_placesClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *placeLikelihoodList, NSError *error){
        if (error != nil) {
            NSLog(@"Pick Place error %@", [error localizedDescription]);
            return;
        }
        for (GMSPlaceLikelihood *likelihood in placeLikelihoodList.likelihoods) {
            GMSPlace* place = likelihood.place;
            [_placeArray addObject:place];
        }
        NSLog(@"附近地標:%@",_placeArray);
    }];
    
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"PostToPosition"]){
        PositionViewController *positionViewController = segue.destinationViewController;
        while(!_placeArray);
        positionViewController.placeArray = _placeArray;
    }
}

@end
