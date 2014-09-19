//
//  SpecialitityModifyViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-19.
//

#import <UIKit/UIKit.h>

@interface SpecialitityModifyViewController : UIViewController
@property (retain, nonatomic) NSString *cvId;
@property (retain, nonatomic) NSString *specialitity;
@property (retain, nonatomic) IBOutlet UIButton *btnSave;
@property (retain, nonatomic) IBOutlet UITextView *txtSpecialitity;

@end
