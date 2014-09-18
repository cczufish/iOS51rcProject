//
//  IntentionModifyViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-18.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntentionModifyViewController : UIViewController
@property (retain, nonatomic) NSString *cvId;
@property (retain, nonatomic) IBOutlet UIView *viewIntention;
@property (retain, nonatomic) IBOutlet UIButton *btnExperience;
@property (retain, nonatomic) IBOutlet UIButton *btnEmployType;
@property (retain, nonatomic) IBOutlet UIButton *btnSalary;
@property (retain, nonatomic) IBOutlet UIButton *btnWorkPlace;
@property (retain, nonatomic) IBOutlet UIButton *btnJobType;
@property (retain, nonatomic) IBOutlet UIButton *btnNogetiation;
@property (retain, nonatomic) IBOutlet UIButton *btnSave;

@end
