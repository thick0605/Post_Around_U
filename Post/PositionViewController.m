//
//  PositionViewController.m
//  Post
//
//  Created by Vivian on 2017/8/9.
//  Copyright © 2017年 Hsin_Yu. All rights reserved.
//

#import "PositionViewController.h"
#import <GooglePlaces/GooglePlaces.h>
#import "PostViewController.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface PositionViewController ()<GMSAutocompleteResultsViewControllerDelegate,UITextViewDelegate,UITableViewDataSource,UITableViewDelegate>{
    GMSAutocompleteResultsViewController *_resultsViewController;
    UISearchController *_searchController;
    GMSPlacesClient *_placesClient;
}

@end

@implementation PositionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self searchBarInit];
    _searchResultTableView.userInteractionEnabled = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//search bar初始化
-(void)searchBarInit{
    _searchResultTableView.dataSource = self;
    _searchResultTableView.delegate = self;
    _resultsViewController = [[GMSAutocompleteResultsViewController alloc] init];
    
    _resultsViewController.delegate = self;
    _resultsViewController.autocompleteBounds = [[GMSCoordinateBounds alloc] initWithCoordinate:CLLocationCoordinate2DMake(21, 119) coordinate:CLLocationCoordinate2DMake(26, 122)];
    _searchController = [[UISearchController alloc]
                         initWithSearchResultsController:_resultsViewController];
    _searchController.searchResultsUpdater = _resultsViewController;
    
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 44)];
    _searchController.hidesNavigationBarDuringPresentation = NO;
    _searchController.searchBar.barTintColor = [UIColor colorWithRed:0.49412 green:0.7216 blue:0.8 alpha:1];
    [subView addSubview:_searchController.searchBar];
    [_searchController.searchBar sizeToFit];
    [self.view addSubview:subView];
    
    // When UISearchController presents the results view, present it in
    // this view controller, not one further up the chain.
    self.definesPresentationContext = YES;
    self.navigationController.navigationBar.translucent = NO;
    _searchController.hidesNavigationBarDuringPresentation = NO;
    
    // This makes the view area include the nav bar even though it is opaque.
    // Adjust the view placement down.
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.edgesForExtendedLayout = UIRectEdgeTop;
}


//點選cell後會呼叫此function告知哪個cell已經被選擇(0開始)
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"chosenPlace" object:[_placeArray objectAtIndex:indexPath.row]];
    NSArray *array = [self.navigationController viewControllers];
    [self.navigationController popToViewController:[array objectAtIndex:0] animated:YES];
}

//返回總共有多少cell筆數
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _placeArray.count;
}

//根據cellForRowAtIndexPath來取得目前TableView需要哪個cell的資料
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tableIdentifier = @"Simple table";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tableIdentifier];
    }
    GMSPlace* place = [_placeArray objectAtIndex:indexPath.row];
    cell.textLabel.text = place.name;
    cell.textLabel.font = [UIFont fontWithName:@"System" size:12];
    cell.detailTextLabel.text = place.formattedAddress;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    return cell;
}

// Handle the user's selection.
- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
 didAutocompleteWithPlace:(GMSPlace *)place {
    //[self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"chosenPlace" object:place];
    NSArray *array = [self.navigationController viewControllers];
    [self.navigationController popToViewController:[array objectAtIndex:0] animated:YES];
}

- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictionsForResultsController:
(GMSAutocompleteResultsViewController *)resultsController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictionsForResultsController:
(GMSAutocompleteResultsViewController *)resultsController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

////從Position頁面跳轉到Post頁面時pass從table view選取的data
//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    if([segue.identifier isEqualToString:@"PositionToPost"]){
//        PostViewController *postViewController = segue.destinationViewController;
//        postViewController.chosenPlace = chosenPlace;
//    }
//}





















/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
