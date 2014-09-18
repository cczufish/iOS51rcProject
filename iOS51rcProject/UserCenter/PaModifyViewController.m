//
//  PaModifyViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-17.
//

#import "PaModifyViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import "CvModifyViewController.h"
#import "DatePickerView.h"
#import "DictionaryPickerView.h"
#import "Toast+UIView.h"

@interface PaModifyViewController () <NetWebServiceRequestDelegate,UITextFieldDelegate,DatePickerDelegate,DictionaryPickerDelegate>
{
    LoadingAnimationView *loadView;
}
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) NSUserDefaults *userDefaults;
@property (nonatomic, retain) DictionaryPickerView *DictionaryPicker;
@end

@implementation PaModifyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.viewPa.layer.borderColor = [[UIColor grayColor] CGColor];
    self.viewPa.layer.borderWidth = 1;
    self.viewPa.layer.cornerRadius = 5;
    self.btnSave.layer.cornerRadius = 5;
    [self.scrollPa setContentSize:CGSizeMake(320, 480)];
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    [self getCvInfo];
}

- (void)getCvInfo
{
    if (![loadView isAnimating]) {
        [loadView startAnimating];
    }
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:[self.userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:self.cvId forKey:@"cvMainID"];
    [dicParam setObject:[self.userDefaults objectForKey:@"code"] forKey:@"code"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetCvInfo" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
    [dicParam release];
}

- (IBAction)savePaMain:(id)sender {
    if (![CommonController isValidateMobile:self.txtMobile.text]) {
        [self.view makeToast:@"请填写正确的手机号"];
        return;
    }
    if (![CommonController isChinese:self.txtName.text] || self.txtName.text.length > 6) {
        [self.view makeToast:@"请输入6字以内的中文姓名"];
        return;
    }
    if (![loadView isAnimating]) {
        [loadView startAnimating];
    }
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:[self.userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:self.cvId forKey:@"cvMainID"];
    [dicParam setObject:[self.userDefaults objectForKey:@"code"] forKey:@"code"];
    [dicParam setObject:self.txtName.text forKey:@"name"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",[self.segGender selectedSegmentIndex]] forKey:@"gender"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.btnBirth.tag] forKey:@"birthDay"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.btnLivePlace.tag] forKey:@"livePlace"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.btnAccountPlace.tag] forKey:@"accountPlace"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.btnGrowPlace.tag] forKey:@"growPlace"];
    [dicParam setObject:self.txtMobile.text forKey:@"mobile"];
    [dicParam setObject:@"1" forKey:@"dcCareerStatus"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"UpdatePaMain" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
    [dicParam release];
}

- (void)netRequestFinishedFromCvInfo:(NetWebServiceRequest *)request
                          xmlContent:(GDataXMLDocument *)xmlContent;
{
    NSDictionary *paData = [self getArrayFromXml:xmlContent tableName:@"paData"][0];
    if (!paData[@"LivePlace"]) {
        return;
    }
    [self.txtName setText:paData[@"Name"]];
    [self.btnLivePlace setTitle:paData[@"LiveRegion"] forState:UIControlStateNormal];
    [self.btnLivePlace setTag:[paData[@"LivePlace"] intValue]];
    [self.btnAccountPlace setTitle:paData[@"AccountRegion"] forState:UIControlStateNormal];
    [self.btnAccountPlace setTag:[paData[@"AccountPlace"] intValue]];
    [self.btnGrowPlace setTitle:paData[@"GrowRegion"] forState:UIControlStateNormal];
    [self.btnGrowPlace setTag:[paData[@"GrowPlace"] intValue]];
    [self.txtMobile setText:paData[@"Mobile"]];
    [self.lbEmail setText:paData[@"Email"]];
    [self.btnBirth setTitle:[NSString stringWithFormat:@"%@年%@月",[paData[@"BirthDay"] substringWithRange:NSMakeRange(0, 4)],[paData[@"BirthDay"] substringWithRange:NSMakeRange(4, 2)]] forState:UIControlStateNormal];
    [self.btnBirth setTag:[paData[@"BirthDay"] intValue]];
    if ([paData[@"Gender"] isEqualToString:@"false"]) {
        [self.segGender setSelectedSegmentIndex:0];
    }
    else {
        [self.segGender setSelectedSegmentIndex:1];
    }
    [loadView stopAnimating];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSArray *)requestData
{
    [loadView stopAnimating];
    CvModifyViewController *cvModifyC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    cvModifyC.toastType = 1;
    [self.navigationController popViewControllerAnimated:true];
}

//获取相关表数据
- (NSArray *)getArrayFromXml:(GDataXMLDocument *)xmlContent
                   tableName:(NSString *)tableName
{
    NSArray *xmlTable = [xmlContent nodesForXPath:[NSString stringWithFormat:@"//%@", tableName] error:nil];
    NSMutableArray *arrXml = [[NSMutableArray alloc] init];
    for (int i=0; i<xmlTable.count; i++) {
        GDataXMLElement *oneXmlElement = [xmlTable objectAtIndex:i];
        NSArray *arrChild = [oneXmlElement children];
        NSMutableDictionary *dicOneXml = [[NSMutableDictionary alloc] init];
        for (int j=0; j<arrChild.count; j++) {
            [dicOneXml setObject:[arrChild[j] stringValue] forKey:[arrChild[j] name]];
        }
        [arrXml addObject:dicOneXml];
    }
    return arrXml;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 1) {
        CGRect frameView = self.view.frame;
        frameView.origin.y = -100;
        [UIView animateWithDuration:0.3 animations:^{
            if ([CommonController is35inchScreen]) {
                [self.scrollPa setContentOffset:CGPointMake(0, 80)];
            }
            [self.view setFrame:frameView];
        }];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == 1) {
        CGRect frameView = self.view.frame;
        frameView.origin.y = 0;
        [UIView animateWithDuration:0.3 animations:^{
            [self.view setFrame:frameView];
        }];
    }
}

- (IBAction)textFiledReturnEditing:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)clickBirth:(id)sender {
    DatePickerView *datePicker = [[DatePickerView alloc] initWithCustom:DatePickerTypeMonth dateButton:DatePickerWithoutReset maxYear:2000 minYear:1955 selectYear:1990 delegate:self];
    [datePicker showDatePicker:self.view];
}

- (void)getSelectDate:(NSString *)date
{
    [self.btnBirth setTitle:date forState:UIControlStateNormal];
    NSString *strBirth = [date stringByReplacingOccurrencesOfString:@"年" withString:@""];
    strBirth = [strBirth stringByReplacingOccurrencesOfString:@"月" withString:@""];
    [self.btnBirth setTag:[strBirth intValue]];
}

- (IBAction)selectLivePlace:(id)sender {
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithCustom:DictionaryPickerWithRegionL3 pickerMode:DictionaryPickerModeOne pickerInclude:DictionaryPickerNoIncludeParent delegate:self defaultValue:@"" defaultName:@""] autorelease];
    self.DictionaryPicker.tag = 1;
    [self.DictionaryPicker showInView:self.view];
}

- (IBAction)selectAccountPlace:(id)sender {
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithCustom:DictionaryPickerWithRegionL2 pickerMode:DictionaryPickerModeOne pickerInclude:DictionaryPickerNoIncludeParent delegate:self defaultValue:@"" defaultName:@""] autorelease];
    self.DictionaryPicker.tag = 2;
    [self.DictionaryPicker showInView:self.view];
}

- (IBAction)selectGrowPlace:(id)sender {
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithCustom:DictionaryPickerWithRegionL3 pickerMode:DictionaryPickerModeOne pickerInclude:DictionaryPickerNoIncludeParent delegate:self defaultValue:@"" defaultName:@""] autorelease];
    self.DictionaryPicker.tag = 3;
    [self.DictionaryPicker showInView:self.view];
}

- (void)pickerDidChangeStatus:(DictionaryPickerView *)picker
                selectedValue:(NSString *)selectedValue
                 selectedName:(NSString *)selectedName
{
    if (picker.tag == 1) {
        [self.btnLivePlace setTitle:selectedName forState:UIControlStateNormal];
        [self.btnLivePlace setTag:[selectedValue intValue]];
    }
    else if (picker.tag == 2) {
        [self.btnAccountPlace setTitle:selectedName forState:UIControlStateNormal];
        [self.btnAccountPlace setTag:[selectedValue intValue]];
    }
    else if (picker.tag == 3) {
        [self.btnGrowPlace setTitle:selectedName forState:UIControlStateNormal];
        [self.btnGrowPlace setTag:[selectedValue intValue]];
    }
    [self cancelDicPicker];
}

-(void)cancelDicPicker
{
    [self.DictionaryPicker cancelPicker];
    self.DictionaryPicker.delegate = nil;
    self.DictionaryPicker = nil;
    [_DictionaryPicker release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [loadView release];
    [_runningRequest release];
    [_DictionaryPicker release];
    [_userDefaults release];
    [_scrollPa release];
    [_viewPa release];
    [_txtName release];
    [_segGender release];
    [_btnBirth release];
    [_btnLivePlace release];
    [_btnAccountPlace release];
    [_btnGrowPlace release];
    [_txtMobile release];
    [_lbEmail release];
    [_btnSave release];
    [super dealloc];
}
@end