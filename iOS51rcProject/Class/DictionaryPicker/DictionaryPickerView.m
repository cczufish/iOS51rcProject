#import "DictionaryPickerView.h"
#import <QuartzCore/QuartzCore.h>
#import "FMDatabase.h"
#import "CommonController.h"
#import "Toast+UIView.h"

#define kDuration 0.3

@interface DictionaryPickerView ()
{
    NSMutableArray *arrDictionaryL1;
    NSMutableArray *arrDictionaryL2;
    NSMutableArray *arrDictionaryL3;
    FMDatabase *db;
}

@end

@implementation DictionaryPickerView

@synthesize delegate = _delegate;
@synthesize pickerType = _pickerType;
@synthesize pickerInclude = _pickerInclude;
@synthesize pickerDictionary = _pickerDictionary;
@synthesize arrSelectValue = _arrSelectValue;
@synthesize arrSelectName = _arrSelectName;
@synthesize selectTableName = _selectTableName;
@synthesize pickerMode = _pickerMode;

- (void)dealloc
{
    [db close];
    [db release];
    [_pickerDictionary release];
    [_arrSelectValue release];
    [_arrSelectName release];
    [_selectTableName release];
    [arrDictionaryL1 release];
    [arrDictionaryL2 release];
    [arrDictionaryL3 release];
    [_viewMultiTop release];
    [_viewMultiBottom release];
    [_viewOneTop release];
    [_lbMulti release];
    [_scrollMulti release];
    [super dealloc];
}


- (id)initWithCustom:(DictionaryPickerType)pickerType
          pickerMode:(DictionaryPickerMode)pickerMode
       pickerInclude:(DictionaryPickerInclude)pickerInclude
           delegate:(id <DictionaryPickerDelegate>)delegate
        defaultValue:(NSString *)defaultValue
         defaultName:(NSString *)defalutName
{
    self = [[[[NSBundle mainBundle] loadNibNamed:@"DictionaryPickerView" owner:self options:nil] objectAtIndex:0] retain];
    if (self) {
        self.delegate = delegate;
        self.pickerType = pickerType;
        self.pickerMode = pickerMode;
        self.pickerInclude = pickerInclude;
        self.pickerDictionary.dataSource = self;
        self.pickerDictionary.delegate = self;
        self.arrSelectValue = [NSMutableArray arrayWithCapacity:10];
        self.arrSelectName = [NSMutableArray arrayWithCapacity:10];
        if (defaultValue.length > 0) {
            self.arrSelectValue = [[[defaultValue componentsSeparatedByString:@" "] mutableCopy] autorelease];
            self.arrSelectName = [[[defalutName componentsSeparatedByString:@" "] mutableCopy] autorelease];
            [self setupScollMulti];
        }
        [self setupDictionary];
    }
    return self;
}

- (id)initWithCommon:(id <DictionaryPickerDelegate>)delegate
          pickerMode:(DictionaryPickerMode)pickerMode
           tableName:(NSString *)tableName
        defalutValue:(NSString *)defaultValue
         defaultName:(NSString *)defaultName
{
    self = [[[[NSBundle mainBundle] loadNibNamed:@"DictionaryPickerView" owner:self options:nil] objectAtIndex:0] retain];
    if (self) {
        self.delegate = delegate;
        self.pickerType = DictionaryPickerWithCommon;
        self.pickerMode = pickerMode;
        self.pickerInclude = DictionaryPickerNoIncludeParent;
        self.pickerDictionary.dataSource = self;
        self.pickerDictionary.delegate = self;
        self.selectTableName = tableName;
        self.arrSelectValue = [NSMutableArray arrayWithCapacity:10];
        self.arrSelectName = [NSMutableArray arrayWithCapacity:10];
        
        if (defaultValue.length > 0) {
            self.arrSelectValue = [[[defaultValue componentsSeparatedByString:@" "] mutableCopy] autorelease];
            self.arrSelectName = [[[defaultName componentsSeparatedByString:@" "] mutableCopy] autorelease];
            [self setupScollMulti];
        }
        [self setupDictionary];
    }
    return self;
}

- (id)initWithDictionary:(id <DictionaryPickerDelegate>)delegate
       defaultArray:(NSMutableArray *)defaultArray
            defalutValue:(NSString *)defaultValue
             defalutName:(NSString *)defalutName
              pickerMode:(DictionaryPickerMode)pickerMode
{
    self = [[[[NSBundle mainBundle] loadNibNamed:@"DictionaryPickerView" owner:self options:nil] objectAtIndex:0] retain];
    if (self) {
        self.delegate = delegate;
        self.pickerType = DictionaryPickerWithCommon;
        self.pickerMode = pickerMode;
        self.pickerInclude = DictionaryPickerNoIncludeParent;
        self.pickerDictionary.dataSource = self;
        self.pickerDictionary.delegate = self;
        arrDictionaryL1 = [defaultArray retain];
        self.arrSelectValue = [NSMutableArray arrayWithCapacity:10];
        self.arrSelectName = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

-(void)connectDbAndInit
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"dictionary.db"];
    
    db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    [db retain];
    
    //加载数据
    arrDictionaryL1 = [[NSMutableArray alloc] init];
    arrDictionaryL2 = [[NSMutableArray alloc] init];
    arrDictionaryL3 = [[NSMutableArray alloc] init];
}

- (void) setupDictionary
{
    [self connectDbAndInit];
    switch (self.pickerType) {
        case DictionaryPickerWithRegionL3:
        {
            [self setRegionDictionary:@""];
            break;
        }
        case DictionaryPickerWithRegionL2:
        {
            [self setRegionDictionary:@""];
            break;
        }
        case DictionaryPickerWithJobType:
        {
            [self setJobTypeDictionary:@""];
        }
        case DictionaryPickerWithCommon:
        {
            [self setCommonDictionary];
        }
        default:
            break;
    }
}

- (void)setJobTypeDictionary:(NSString *)parentid
{
    if ([parentid length] == 0) {
        FMResultSet *jobTypeList = [db executeQuery:@"select * from dcjobtype where parentid is null and _id<>0"];
        int i = 0;
        while ([jobTypeList next]) {
            NSDictionary *dicJobType = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [jobTypeList stringForColumn:@"_id"],@"id",
                                        [jobTypeList stringForColumn:@"description"],@"value"
                                        , nil];
            [arrDictionaryL1 addObject:dicJobType];
            [dicJobType release];
            if (i == 0) {
                [self setJobTypeDictionary:[jobTypeList stringForColumn:@"_id"]];
            }
            i++;
        }
    }
    else if ([parentid length] == 2) {
        [arrDictionaryL2 removeAllObjects];
        int i = 0;
        if (self.pickerInclude == DictionaryPickerIncludeParent) {
            for (i=0; i<arrDictionaryL1.count; i++) {
                if ([arrDictionaryL1[i][@"id"] compare:parentid options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                    break;
                }
            }
            if (i<arrDictionaryL1.count) {
                NSDictionary *dicParent = arrDictionaryL1[i];
                [arrDictionaryL2 addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                             dicParent[@"id"],@"id",
                                             [NSString stringWithFormat:@"全部%@",dicParent[@"value"]],@"value"
                                             , nil] autorelease]];
            }
        }
        i = 0;
        FMResultSet *cityList = [db executeQuery:[NSString stringWithFormat:@"select * from dcjobtype where parentid=%@",parentid]];
        while ([cityList next]) {//有下一个的话，就取出它的数据，然后关闭数据库
            NSDictionary *dicJobType = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [cityList stringForColumn:@"_id"],@"id",
                                        [cityList stringForColumn:@"description"],@"value"
                                        , nil];
            [arrDictionaryL2 addObject:dicJobType];
            [dicJobType release];
            i++;
        }
    }
}

- (void)setRegionDictionary:(NSString *)parentid
{
    if ([parentid length] == 0) {
        FMResultSet *provinceList = [db executeQuery:@"select * from dcregion where parentid=''"];
        int i = 0;
        while ([provinceList next]) {
            NSDictionary *dicRegion = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       [provinceList stringForColumn:@"_id"],@"id",
                                       [provinceList stringForColumn:@"description"],@"value"
                                       , nil];
            [arrDictionaryL1 addObject:dicRegion];
            [dicRegion release];
            //加载市
            if (i == 0) {
                [self setRegionDictionary:[provinceList stringForColumn:@"_id"]];
            }
            i++;
        }
    }
    else if ([parentid length] == 2) {
        [arrDictionaryL2 removeAllObjects];
        if (self.pickerType == DictionaryPickerWithRegionL2 && [self isMunicipality:parentid]) {
            return;
        }
        int i = 0;
        if (self.pickerInclude == DictionaryPickerIncludeParent) {
            for (i=0; i<arrDictionaryL1.count; i++) {
                if ([arrDictionaryL1[i][@"id"] compare:parentid options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                    break;
                }
            }
            if (i<arrDictionaryL1.count) {
                NSDictionary *dicParent = arrDictionaryL1[i];
                [arrDictionaryL2 addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                             dicParent[@"id"],@"id",
                                             [NSString stringWithFormat:@"全部%@",dicParent[@"value"]],@"value"
                                             , nil] autorelease]];
            }
        }
        i = 0;
        FMResultSet *cityList = [db executeQuery:[NSString stringWithFormat:@"select * from dcregion where parentid=%@",parentid]];
        while ([cityList next]) {//有下一个的话，就取出它的数据，然后关闭数据库
            NSDictionary *dicRegion = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       [cityList stringForColumn:@"_id"],@"id",
                                       [cityList stringForColumn:@"description"],@"value"
                                       , nil];
            [arrDictionaryL2 addObject:dicRegion];
            [dicRegion release];
            //加载区
            if (i == 0) {
                [self setRegionDictionary:[cityList stringForColumn:@"_id"]];
            }
            i++;
        }
    }
    else if ([parentid length] == 4) {
        [arrDictionaryL3 removeAllObjects];
        if (self.pickerType == DictionaryPickerWithRegionL2) {
            return;
        }
        if (self.pickerType == DictionaryPickerWithRegionL3 && [self isMunicipality:[parentid substringToIndex:2]]) {
            return;
        }
        int i = 0;
        if (self.pickerInclude == DictionaryPickerIncludeParent) {
            for (i=0; i<arrDictionaryL2.count; i++) {
                if ([arrDictionaryL2[i][@"id"] compare:parentid options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                    break;
                }
            }
            if (i<arrDictionaryL2.count) {
                NSDictionary *dicParent = arrDictionaryL2[i];
                [arrDictionaryL3 addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                             dicParent[@"id"],@"id",
                                             [NSString stringWithFormat:@"全部%@",dicParent[@"value"]],@"value"
                                             , nil] autorelease]];
            }
        }
        
        FMResultSet *districtList = [db executeQuery:[NSString stringWithFormat:@"select * from dcregion where parentid=%@",parentid]];
        while ([districtList next]) {//有下一个的话，就取出它的数据，然后关闭数据库
            NSDictionary *dicRegion = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       [districtList stringForColumn:@"_id"],@"id",
                                       [districtList stringForColumn:@"description"],@"value"
                                       ,nil];
            
            [arrDictionaryL3 addObject:dicRegion];
            [dicRegion release];
        }
    }
}

- (void)setCommonDictionary
{
    FMResultSet *commonList = [db executeQuery:[NSString stringWithFormat:@"select * from %@",self.selectTableName]];
    int i = 0;
    while ([commonList next]) {
        if (i == 0) {
            [self setJobTypeDictionary:[commonList stringForColumn:@"_id"]];
        }
        NSDictionary *dicCommon = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [commonList stringForColumn:@"_id"],@"id",
                                   [commonList stringForColumn:@"description"],@"value"
                                   , nil];
        [arrDictionaryL1 addObject:dicCommon];
        [dicCommon release];
        i++;
    }
}

#pragma mark - PickerView lifecycle

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    switch (self.pickerType) {
        case DictionaryPickerWithRegionL3:
            return 3;
            break;
        case DictionaryPickerWithRegionL2:
            return 2;
            break;
        case DictionaryPickerWithJobType:
            return 2;
            break;
        default:
            return 1;
            break;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [arrDictionaryL1 count];
            break;
        case 1:
            return [arrDictionaryL2 count];
            break;
        case 2:
            return [arrDictionaryL3 count];
            break;
        default:
            return 0;
            break;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (self.pickerType) {
        case DictionaryPickerWithRegionL3:
        {
            switch (component) {
                case 0:
                {
                    [self setRegionDictionary:[arrDictionaryL1[row] objectForKey:@"id"]];
                    [self.pickerDictionary reloadComponent:1];
                    [self.pickerDictionary reloadComponent:2];
                    if (self.pickerInclude == DictionaryPickerIncludeParent) {
                        [self.pickerDictionary selectRow:1 inComponent:1 animated:YES];
                        [self.pickerDictionary selectRow:1 inComponent:2 animated:YES];
                    }
                    else {
                        [self.pickerDictionary selectRow:0 inComponent:1 animated:YES];
                        [self.pickerDictionary selectRow:0 inComponent:2 animated:YES];
                    }
                    break;
                }
                case 1:
                {
                    NSString *regionId = [arrDictionaryL2[row] objectForKey:@"id"];
                    if (regionId.length == 2) {
                        [arrDictionaryL3 removeAllObjects];
                    }
                    else {
                        [self setRegionDictionary:regionId];
                    }
                    [self.pickerDictionary reloadComponent:2];
                    if (self.pickerInclude == DictionaryPickerIncludeParent) {
                        [self.pickerDictionary selectRow:1 inComponent:2 animated:YES];
                    }
                    else {
                        [self.pickerDictionary selectRow:0 inComponent:2 animated:YES];
                    }
                    
                    break;
                }
                case 3:
                {
                    
                }
                default:
                    break;
            }
            break;
        }
        case DictionaryPickerWithRegionL2:
        {
            if (component == 0) {
                [self setRegionDictionary:[arrDictionaryL1[row] objectForKey:@"id"]];
                [self.pickerDictionary reloadComponent:1];
                if (self.pickerInclude == DictionaryPickerIncludeParent) {
                    [self.pickerDictionary selectRow:1 inComponent:1 animated:YES];
                }
                else {
                    [self.pickerDictionary selectRow:0 inComponent:1 animated:YES];
                }
                break;
            }
        }
        case DictionaryPickerWithJobType:
        {
            if (component == 0) {
                [self setJobTypeDictionary:[arrDictionaryL1[row] objectForKey:@"id"]];
                [self.pickerDictionary reloadComponent:1];
                if (self.pickerInclude == DictionaryPickerIncludeParent) {
                    [self.pickerDictionary selectRow:1 inComponent:1 animated:YES];
                }
                else {
                    [self.pickerDictionary selectRow:0 inComponent:1 animated:YES];
                }
                break;
            }
        }
        default:
            break;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    CGSize rowSize = [self.pickerDictionary rowSizeForComponent:component];
    UIView *viewContent = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, rowSize.width, rowSize.height)] autorelease];
    NSString *strTitle;
    bool blnSelected = NO;
    switch (component) {
        case 0:
            strTitle = [arrDictionaryL1[row] objectForKey:@"value"];
            if (self.pickerMode == DictionaryPickerModeMulti && self.pickerType == DictionaryPickerWithCommon && [self.arrSelectValue containsObject:[arrDictionaryL1[row] objectForKey:@"id"]]) {
                blnSelected = YES;
            }
            break;
        case 1:
            strTitle = [arrDictionaryL2[row] objectForKey:@"value"];
            if (self.pickerMode == DictionaryPickerModeMulti && [self.arrSelectValue containsObject:[arrDictionaryL2[row] objectForKey:@"id"]]) {
                blnSelected = YES;
            }
            break;
        case 2:
            strTitle = [arrDictionaryL3[row] objectForKey:@"value"];
            if (self.pickerMode == DictionaryPickerModeMulti && [self.arrSelectValue containsObject:[arrDictionaryL3[row] objectForKey:@"id"]]) {
                blnSelected = YES;
            }
            break;
        default:
            strTitle = @"";
            break;
    }
    CGSize labelSize = [CommonController CalculateFrame:strTitle fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(1000, rowSize.height)];
    float fltLeft = MAX(0, (rowSize.width-labelSize.width-15)/2);
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, labelSize.width, rowSize.height)];
    lbTitle.textColor = [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
    lbTitle.text = strTitle;
    lbTitle.font = [UIFont systemFontOfSize:14];
    lbTitle.frame = CGRectMake(lbTitle.frame.origin.x+fltLeft, lbTitle.frame.origin.y, lbTitle.frame.size.width, lbTitle.frame.size.height);
    
    if (blnSelected) {
        UIImageView *imgChecked = [[UIImageView alloc] initWithFrame:CGRectMake(fltLeft, 7, 15, 15)];
        [imgChecked setImage:[UIImage imageNamed:@"check.png"]];
        [viewContent addSubview:imgChecked];
        [imgChecked release];
    }
    [viewContent addSubview:lbTitle];
    [lbTitle release];
    return viewContent;
}

- (IBAction)savePicker:(id)sender {
    if ([self.delegate respondsToSelector:@selector(pickerDidChangeStatus:selectedValue:selectedName:)]) {
        NSDictionary *dicSelected;
        if ([arrDictionaryL3 count] > 0) {
            dicSelected = arrDictionaryL3[[self.pickerDictionary selectedRowInComponent:2]];
        }
        else if ([arrDictionaryL2 count] > 0) {
            dicSelected = arrDictionaryL2[[self.pickerDictionary selectedRowInComponent:1]];
        }
        else {
            dicSelected = arrDictionaryL1[[self.pickerDictionary selectedRowInComponent:0]];
        }
        [self.delegate pickerDidChangeStatus:self selectedValue:[NSString stringWithFormat:@"%@",dicSelected[@"id"]] selectedName:[[NSString stringWithFormat:@"%@",dicSelected[@"value"]] stringByReplacingOccurrencesOfString:@"全部" withString:@""]];
        
    }
}

- (IBAction)saveMultiPicker:(id)sender {
    if ([self.delegate respondsToSelector:@selector(pickerDidChangeStatus:selectedValue:selectedName:)]) {
        [self.delegate pickerDidChangeStatus:self selectedValue:[self.arrSelectValue componentsJoinedByString:@","] selectedName:[self.arrSelectName componentsJoinedByString:@" "]];
        
    }
}

- (IBAction)addPickerSelect:(id)sender {
    if (self.arrSelectValue.count >= 5) {
        [self makeToast:@"最多选择5个"];
        return;
    }
    NSDictionary *dicSelected;
    if ([arrDictionaryL3 count] > 0) {
        dicSelected = arrDictionaryL3[[self.pickerDictionary selectedRowInComponent:2]];
    }
    else if ([arrDictionaryL2 count] > 0) {
        dicSelected = arrDictionaryL2[[self.pickerDictionary selectedRowInComponent:1]];
    }
    else {
        dicSelected = arrDictionaryL1[[self.pickerDictionary selectedRowInComponent:0]];
    }
    
    if ([self.arrSelectValue count] > 0 && self.pickerType != DictionaryPickerWithCommon) {
        NSMutableArray *arrNewSelectValue = [[[NSMutableArray alloc] init] autorelease];
        NSMutableArray *arrNewSelectName = [[[NSMutableArray alloc] init] autorelease];
        if ([self.arrSelectValue containsObject:dicSelected[@"id"]]) {
            return;
        }
        for (int i=0; i<self.arrSelectValue.count; i++) {
            if ([self.arrSelectValue[i] isEqualToString:[dicSelected[@"id"] substringToIndex:MIN([self.arrSelectValue[i] length], [dicSelected[@"id"] length])]] | [dicSelected[@"id"] isEqualToString:[self.arrSelectValue[i] substringToIndex:MIN([self.arrSelectValue[i] length], [dicSelected[@"id"] length])]]) {
                
            }
            else {
                [arrNewSelectValue addObject:self.arrSelectValue[i]];
                [arrNewSelectName addObject:self.arrSelectName[i]];
            }
        }
        [arrNewSelectValue addObject:dicSelected[@"id"]];
        [arrNewSelectName addObject:[dicSelected[@"value"] stringByReplacingOccurrencesOfString:@"全部" withString:@""]];
        
        self.arrSelectValue = arrNewSelectValue;
        self.arrSelectName = arrNewSelectName;
    }
    else {
        [self.arrSelectValue addObject:dicSelected[@"id"]];
        [self.arrSelectName addObject:[dicSelected[@"value"] stringByReplacingOccurrencesOfString:@"全部" withString:@""]];
    }
    [self.pickerDictionary reloadAllComponents];
    [self setupScollMulti];
}

- (void)setupScollMulti
{
    for (UIView *viewChild in self.scrollMulti.subviews) {
        [viewChild removeFromSuperview];
    }
    UIFont *scrollFont = [UIFont systemFontOfSize:12];
    float fltMultiWidth = 0;
    for (int i=0; i<self.arrSelectValue.count; i++) {
        CGSize labelSize = [CommonController CalculateFrame:self.arrSelectName[i] fontDemond:scrollFont sizeDemand:CGSizeMake(5000, 22)];
        
        UIButton *btnMultiSelect = [[UIButton alloc] initWithFrame:CGRectMake(fltMultiWidth, 0, labelSize.width+15, 22)];
        [btnMultiSelect setBackgroundColor:[UIColor colorWithRed:208.f/255.f green:208.f/255.f blue:208.f/255.f alpha:1]];
        
        UIImageView *imgMultiSelect = [[UIImageView alloc] initWithFrame:CGRectMake(3, 5, 10, 10)];
        [imgMultiSelect setImage:[UIImage imageNamed:@"check.png"]];
        [btnMultiSelect addSubview:imgMultiSelect];
        [imgMultiSelect release];
        btnMultiSelect.tag = [self.arrSelectValue[i] intValue];
        [btnMultiSelect addTarget:self action:@selector(removeMultiSelect:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollMulti addSubview:btnMultiSelect];
        
        UILabel *lbMultiSelect = [[UILabel alloc] initWithFrame:CGRectMake(13, 0, labelSize.width, 22)];
        [lbMultiSelect setFont:scrollFont];
        [lbMultiSelect setText:self.arrSelectName[i]];
        [btnMultiSelect addSubview:lbMultiSelect];
        [lbMultiSelect release];
        fltMultiWidth += labelSize.width+20;
    }
    [self.scrollMulti setContentSize:CGSizeMake(fltMultiWidth, 22)];
    [self.scrollMulti scrollRectToVisible:CGRectMake(0, 0, fltMultiWidth, 22) animated:true];
    [self.lbMulti setText:[NSString stringWithFormat:@"已选%d个",self.arrSelectValue.count]];
}

- (void)removeMultiSelect:(UIButton *)sender
{
    NSString *multiSelectValue = [NSString stringWithFormat: @"%d", sender.tag];
    for (int i=0; i<self.arrSelectValue.count; i++) {
        if ([multiSelectValue isEqualToString:self.arrSelectValue[i]]) {
            [self.arrSelectValue removeObjectAtIndex:i];
            [self.arrSelectName removeObjectAtIndex:i];
            break;
        }
    }
    [self.pickerDictionary reloadAllComponents];
    [self setupScollMulti];
}

- (IBAction)removeAllMultiSelect:(id)sender {
    [self.arrSelectValue removeAllObjects];
    [self.arrSelectName removeAllObjects];
    [self.pickerDictionary reloadAllComponents];
    [self setupScollMulti];
}

#pragma mark - animation

- (void)showInView:(UIView *) view
{
    if (self.pickerMode == DictionaryPickerModeOne) {
        [self.viewMultiTop setHidden:true];
        [self.viewMultiBottom setHidden:true];
        [self.viewOneTop setHidden:false];
    }
    else {
        [self.viewMultiTop setHidden:false];
        [self.viewMultiBottom setHidden:false];
        [self.viewOneTop setHidden:true];
    }
    self.frame = CGRectMake(0, view.frame.size.height, self.frame.size.width, self.frame.size.height);
    [view addSubview:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, view.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    }];
    if (self.pickerInclude == DictionaryPickerIncludeParent) {
        [self.pickerDictionary selectRow:1 inComponent:1 animated:YES];
        if (self.pickerType == DictionaryPickerWithRegionL3) {
            [self.pickerDictionary selectRow:1 inComponent:2 animated:YES];
        }
    }
    
    //根据默认值显示
    if (self.pickerMode == DictionaryPickerModeOne) {
        
    }
    else {
//        [self setupScollMulti];
    }
}

- (IBAction)cancelPicker:(id)sender {
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = CGRectMake(0, self.frame.origin.y+self.frame.size.height, self.frame.size.width, self.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                     }];
}

- (void)cancelPicker {
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = CGRectMake(0, self.frame.origin.y+self.frame.size.height, self.frame.size.width, self.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                     }];
}

- (BOOL)isMunicipality:(NSString *)regionId //是否是直辖市
{
    if ([regionId isEqual:@"10"]|[regionId isEqual:@"11"]|[regionId isEqual:@"30"]|[regionId isEqual:@"60"]|[regionId isEqual:@"90"]|[regionId isEqual:@"91"]|[regionId isEqual:@"92"]|[regionId isEqual:@"93"]) {
        return YES;
    }
    else {
        return NO;
    }
}

@end
