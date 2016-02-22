//
//  MasterTableViewController.m
//  Dota2Heros
//
//  Created by QinJianjie on 15/5/9.
//  Copyright (c) 2015年 ylink. All rights reserved.
//

#define kAPI_KEY @"1068278A6645C323CD76C8E6CF2C5DC0"

#import "MasterTableViewController.h"
#import "DetailTableViewController.h"
#import "HeroTableViewCell.h"
#import <UIImageView+WebCache.h>

//验证steam的key
//1068278A6645C323CD76C8E6CF2C5DC0

@interface MasterTableViewController ()
{
    NSString *docPath;
}

@property NSArray *heroList;
@property NSURLSession *session;
@property NSDictionary *heroesDetail;

@end

@implementation MasterTableViewController



- (void)fetchHeroesListData
{
    NSURL *apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.steampowered.com/IEconDOTA2_570/GetHeroes/v0001/?key=%@&language=en_US",kAPI_KEY]];
    
    NSURLSessionDataTask *dataTask =[self.session dataTaskWithURL:apiURL
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                                                    
                                                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                    
                                                    self.heroList = json[@"result"][@"heroes"];
                                                    [self.heroList writeToFile:[docPath stringByAppendingPathComponent:@"ListData.plist"] atomically:YES];
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [self.tableView reloadData];
                                                    });
                                                    
                                                }];
    [dataTask resume];
}

- (void)fetchHeroesDetailData
{
    NSURL *apiURL = [NSURL URLWithString:@"http://www.dota2.com/jsfeed/heropickerdata"];
    
    NSURLSessionDataTask *dataTask =[self.session dataTaskWithURL:apiURL
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                                                
                                                    self.heroesDetail = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                    [self.heroesDetail writeToFile:[docPath stringByAppendingPathComponent:@"DetailData.plist"] atomically:YES];
                                                }];
    [dataTask resume];
    
}

- (void)fetchHeroAbilityData
{
    NSURL *apiURL = [NSURL URLWithString:@"http://www.dota2.com/jsfeed/abilitydata"];
    
    NSURLSessionDataTask *dataTask =[self.session dataTaskWithURL:apiURL
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                                                    
                                                    NSDictionary *abilityData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil][@"abilitydata"];
                                                    
                                                    [abilityData writeToFile:[docPath stringByAppendingPathComponent:@"AbilityData.plist"] atomically:YES];
                                                
                                                    
                                                }];
    [dataTask resume];

}

- (void)setupDataSource
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[docPath stringByAppendingPathComponent:@"ListData.plist"]])
    {
        self.heroList = [NSArray arrayWithContentsOfFile:[docPath stringByAppendingPathComponent:@"ListData.plist"]];
    }
    else
    {
        [self fetchHeroesListData];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[docPath stringByAppendingPathComponent:@"DetailData.plist"]])
    {
        self.heroesDetail = [NSDictionary dictionaryWithContentsOfFile:[docPath stringByAppendingPathComponent:@"DetailData.plist"]];
    }
    else
    {
        [self fetchHeroesDetailData];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[docPath stringByAppendingPathComponent:@"AbilityData.plist"]])
    {
        
    }
    else
    {
        [self fetchHeroAbilityData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.title = @"Dota 2 Heropedia";
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    [self setupDataSource];


    NSLog(@"%@",docPath);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TODETAIL"]) {
        DetailTableViewController *detailVC = [segue destinationViewController];
        
        NSString *selectedHero = [self.heroList[self.tableView.indexPathForSelectedRow.row][@"name"] stringByReplacingOccurrencesOfString:@"npc_dota_hero_" withString:@""];
        
        detailVC.heroName = selectedHero;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.heroList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HeroTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    
    //NSString *sourceName = self.heroList[indexPath.row][@"name"];
    //NSString *realName = [self.heroList[indexPath.row][@"name"] stringByReplacingOccurrencesOfString:@"npc_dota_hero_" withString:@""];
    
    NSString *urlString = [NSString stringWithFormat:@"http://cdn.dota2.com.cn/apps/dota2/images/heroes/%@_full.png",[self.heroList[indexPath.row][@"name"] stringByReplacingOccurrencesOfString:@"npc_dota_hero_" withString:@""]];
    
    [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:urlString]];
    
    cell.nameLabel.text = self.heroList[indexPath.row][@"localized_name"];
    
    cell.typeLabel.text = self.heroesDetail[[self.heroList[indexPath.row][@"name"] stringByReplacingOccurrencesOfString:@"npc_dota_hero_" withString:@""]][@"atk_l"];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
