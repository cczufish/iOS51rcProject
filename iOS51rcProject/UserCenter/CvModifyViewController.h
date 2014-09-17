//
//  CvModifyViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-15.
//

#import <UIKit/UIKit.h>

@interface CvModifyViewController : UIViewController
@property (nonatomic, retain) NSString *cvId;
@property (retain, nonatomic) IBOutlet UILabel *lbCvName;
@property (retain, nonatomic) IBOutlet UIButton *btnCvName;
@property (retain, nonatomic) IBOutlet UITextField *txtCvName;
@property (retain, nonatomic) IBOutlet UILabel *lbCvScore;
@property (retain, nonatomic) IBOutlet UILabel *lbPaName;
@property (retain, nonatomic) IBOutlet UILabel *lbGender;
@property (retain, nonatomic) IBOutlet UILabel *lbBirth;
@property (retain, nonatomic) IBOutlet UILabel *lbLivePlace;
@property (retain, nonatomic) IBOutlet UILabel *lbAccountPlace;
@property (retain, nonatomic) IBOutlet UILabel *lbGrowPlace;
@property (retain, nonatomic) IBOutlet UILabel *lbMobile;
@property (retain, nonatomic) IBOutlet UILabel *lbEmail;
@property (retain, nonatomic) IBOutlet UIView *viewPaInfo;
@property (retain, nonatomic) IBOutlet UIView *viewPhotoSelect;
@property (retain, nonatomic) IBOutlet UIButton *btnPhoto;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollCvModify;
@property (retain, nonatomic) IBOutlet UIView *viewJobIntention;
@property (retain, nonatomic) IBOutlet UILabel *lbExperience;
@property (retain, nonatomic) IBOutlet UILabel *lbEmployType;
@property (retain, nonatomic) IBOutlet UILabel *lbSalary;
@property (retain, nonatomic) IBOutlet UILabel *lbExpectJobPlace;
@property (retain, nonatomic) IBOutlet UILabel *lbExpectJobType;
@property (retain, nonatomic) IBOutlet UILabel *lbExpectJobTypeTitle;
@property (retain, nonatomic) IBOutlet UILabel *lbSpeciality;
@property (retain, nonatomic) IBOutlet UIView *viewSpeciality;
@property (retain, nonatomic) IBOutlet UIView *viewEducation;
@property (retain, nonatomic) IBOutlet UIView *viewExperience;
@property (retain, nonatomic) IBOutlet UIView *viewSetExperience;
@property (retain, nonatomic) IBOutlet UIButton *btnAddExperience;
@property (retain, nonatomic) IBOutlet UIButton *btnAddEducation;
@property (retain, nonatomic) IBOutlet UIButton *btnPhotoCancel;
@property (retain, nonatomic) IBOutlet UILabel *lbConfirmContent;
@property (retain, nonatomic) IBOutlet UIView *viewConfirm;
@property (retain, nonatomic) IBOutlet UIButton *btnConfirmOK;
@property (retain, nonatomic) IBOutlet UIButton *btnConfirmCancel;
@property (retain, nonatomic) IBOutlet UIButton *btnSetHasExp;
@property (retain, nonatomic) IBOutlet UIButton *btnSetNoExp;


@end
