//
//  AbilityCell.h
//  Dota2Heros
//
//  Created by QinJianjie on 15/5/11.
//  Copyright (c) 2015年 ylink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AbilityCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *abilityImageView;
@property (weak, nonatomic) IBOutlet UILabel *abilityNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *abilityDetailLabel;

@end
