//
//  CampusCompanyViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-9.
//

#import <UIKit/UIKit.h>

@interface CampusCompanyViewController : UIViewController
@property (retain, nonatomic) IBOutlet UILabel *lbCompanyName;
@property (retain, nonatomic) IBOutlet UILabel *lbCity;
@property (retain, nonatomic) IBOutlet UILabel *lbIndustry;
@property (retain, nonatomic) IBOutlet UILabel *lbHomepage;
@property (retain, nonatomic) IBOutlet UILabel *lbUnderline;
@property (retain, nonatomic) IBOutlet UILabel *lbBrief;
@property (retain, nonatomic) IBOutlet UILabel *lbCampus;
@property (retain, nonatomic) IBOutlet UILabel *lbEmploy;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UICollectionView *collectView;
@property (retain, nonatomic) IBOutlet UIView *viewHomepage;
@property (retain, nonatomic) IBOutlet UILabel *lbDescription;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollCpInfo;

@property (retain, nonatomic) NSString *employId;
@property (retain, nonatomic) NSString *companyId;
@property int tabIndex;

@end
