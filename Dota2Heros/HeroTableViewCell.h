//
//  HeroTableViewCell.h
//  Dota2Heros
//
//  Created by QinJianjie on 15/5/9.
//  Copyright (c) 2015年 ylink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeroTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;

@end
