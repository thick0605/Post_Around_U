//
//  ViewController.m
//  Post
//
//  Created by Vivian on 2017/6/4.
//  Copyright © 2017年 Hsin_Yu. All rights reserved.
//

#import "ViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "GeneralData.h"

@interface ViewController (){
    User *user;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    FBSDKLoginButton *loginButton;
}


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //location manager init
    locationManager = [[CLLocationManager alloc] init];
    [locationManager requestWhenInUseAuthorization];
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    
    //user init
    user = [[User alloc] init];

}

//待視圖出現後再進行登入判斷
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:true];
    if ([FBSDKAccessToken currentAccessToken]) {
        [self fetchProfile];
    }
    else{
        //fb login init
        loginButton = [[FBSDKLoginButton alloc] init];
        loginButton.readPermissions = @[@"email"];
        loginButton.delegate = self;
        loginButton.center = self.view.center;
        [self.view addSubview:loginButton];
    }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    
    [self fetchProfile];
    
}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    
}

-(BOOL)loginButtonWillLogin:(FBSDKLoginButton *)loginButton{
    return YES;
}

- (void)fetchProfile{
    loginButton.hidden = YES;

    //fetch profile information from fb graph
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                       parameters:@{@"fields": @"picture.type(large), email,name,id"}]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             [self uploadProfile:result];
             //store profile information to general data
             user.myAccessToken = [FBSDKAccessToken currentAccessToken];
             user.ID = [result objectForKey:@"id"];
             user.Name = [result objectForKey:@"name"];
             user.Email = [result objectForKey:@"email"];
             user.Picture = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",[result objectForKey:@"id"]];
             [GeneralData sharedInstance].user = user;
             NSLog(@"user data%f",[GeneralData sharedInstance].user.Longitude);
             
             [self performSegueWithIdentifier:@"RootToMain" sender:self];
         }
         else{
             NSLog(@"%@", [error localizedDescription]);
         }
     }];
    
    
}

-(void)uploadProfile:(id)result{

    //宣告一個 NSMutableURLRequest 並給予一個記憶體空間
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //宣告一個 NSURL 並給予記憶體空間、連線位置(透過php與Database溝通)
    NSURL *connection = [[NSURL alloc] initWithString:@"http://liocean.esy.es/upload_profile.php"];
    
    //將欲傳送之個人資料以json格式傳送
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; 
    NSDictionary *payload = [[NSDictionary alloc] initWithObjectsAndKeys:
                        @"u564252906_hsu", @"username",
                        @"thick65a", @"password",
                        [result objectForKey:@"id"], @"id",
                        [result objectForKey:@"name"], @"name",
                        [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",[result objectForKey:@"id"]], @"picture",
                        [result objectForKey:@"email"], @"email",
                        nil];
    NSError *error;
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&error];
    
    //設定連線
    [request setURL:connection];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postdata];
    
    //回傳結果並繼續其他task
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
    }]resume];

}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    //取得當前位置
    currentLocation = [locations lastObject];
    if(currentLocation != nil){
        user.Longitude = currentLocation.coordinate.longitude;
        user.Latitude = currentLocation.coordinate.latitude;
        [locationManager stopUpdatingLocation];
    }
}



@end
