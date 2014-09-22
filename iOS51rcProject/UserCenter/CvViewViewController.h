//
//  CvViewViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-15.
//

#import <UIKit/UIKit.h>

@interface CvViewViewController : UIViewController
@property (nonatomic, retain) NSString *cvId;
@property (retain, nonatomic) IBOutlet UIImageView *imgPhoto;
@property (retain, nonatomic) IBOutlet UILabel *lbPaName;
@property (retain, nonatomic) IBOutlet UILabel *lbGender;
@property (retain, nonatomic) IBOutlet UILabel *lbBirth;
@property (retain, nonatomic) IBOutlet UILabel *lbPaOther;
@property (retain, nonatomic) IBOutlet UILabel *lbLivePlace;
@property (retain, nonatomic) IBOutlet UILabel *lbAccountPlace;
@property (retain, nonatomic) IBOutlet UILabel *lbGrowPlace;
@property (retain, nonatomic) IBOutlet UILabel *lbLoginDate;
@property (retain, nonatomic) IBOutlet UILabel *lbMobile;
@property (retain, nonatomic) IBOutlet UILabel *lbEmail;
@property (retain, nonatomic) IBOutlet UILabel *lbRefreshDate;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollCvView;
@property (retain, nonatomic) IBOutlet UIView *viewJobIntention;
@property (retain, nonatomic) IBOutlet UILabel *lbEmployType;
@property (retain, nonatomic) IBOutlet UILabel *lbSalary;
@property (retain, nonatomic) IBOutlet UILabel *lbExpectJobPlace;
@property (retain, nonatomic) IBOutlet UILabel *lbExpectJobType;
@property (retain, nonatomic) IBOutlet UIView *viewIntention1;
@property (retain, nonatomic) IBOutlet UIView *viewIntention2;
@property (retain, nonatomic) IBOutlet UILabel *lbSpeciality;
@property (retain, nonatomic) IBOutlet UIView *viewSpeciality;
@property (retain, nonatomic) IBOutlet UIView *viewEduAndExp;
@property (retain, nonatomic) IBOutlet UIImageView *imgMobileCer;
@property (retain, nonatomic) IBOutlet UILabel *lbMobileCer;
@property (retain, nonatomic) IBOutlet UIView *viewPaBasic;

@end