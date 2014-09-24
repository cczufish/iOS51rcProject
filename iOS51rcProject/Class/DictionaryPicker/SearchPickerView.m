#import "SearchPickerView.h"
#import "FMDatabase.h"
#import "CommonController.h"
#import "Toast+UIView.h"

@interface SearchPickerView ()
{
    NSMutableArray *arrDictionaryL1;
    NSMutableArray *arrDictionaryL2;
    NSMutableArray *arrDictionaryL3;
    FMDatabase *db;
}

@end

@implementation SearchPickerView

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

- (id)initWithSearchRegionFilter:(id <SearchPickerDelegate>)delegate
                     selectValue:(NSString *)selectValue
                      selectName:(NSString *)selectName
                    defaultValue:(NSString *)defaultValue
{
    self = [[[[NSBundle mainBundle] loadNibNamed:@"SearchPickerView" owner:self options:nil] objectAtIndex:0] retain];
    if (self) {
        self.delegate = delegate;
        self.pickerType = SearchPickerWithRegion;
        [self.viewOneTop setHidden:false];
        [self.viewMultiTop setHidden:true];
        [self.viewMultiBottom setHidden:true];
        [self.btnCancel addTarget:self action:@selector(cancelPicker) forControlEvents:UIControlEventTouchUpInside];
        [self.btnSave addTarget:self action:@selector(savePicker) forControlEvents:UIControlEventTouchUpInside];
        [self connectDbAndInit];
        if ([selectValue rangeOfString:@","].location == NSNotFound) {
            [self setRegionDictionary:selectValue];
            arrDictionaryL1 = [arrDictionaryL2 mutableCopy];
            [arrDictionaryL2 removeAllObjects];
            arrDictionaryL2 = [arrDictionaryL3 mutableCopy];
            [arrDictionaryL3 removeAllObjects];
            if (arrDictionaryL1.count == 0) {
                arrDictionaryL1 = [arrDictionaryL2 mutableCopy];
                [arrDictionaryL2 removeAllObjects];
            }
        }
        else {
            NSArray *arrSelectValue = [selectValue componentsSeparatedByString:@","];
            NSArray *arrSelectName = [selectName componentsSeparatedByString:@" "];
            for (int i=0; i<arrSelectValue.count; i++) {
                [arrDictionaryL1 addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                             arrSelectValue[i],@"id",
                                             arrSelectName[i],@"value", nil] autorelease]];
            }
            [self setRegionDictionary:[arrDictionaryL1[0] objectForKey:@"id"]];
            if (arrDictionaryL2.count == 0) {
                arrDictionaryL2 = [arrDictionaryL3 mutableCopy];
                [arrDictionaryL3 removeAllObjects];
            }
        }
        [arrDictionaryL1 insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                        @"",@"id",
                                        @"全部工作地点",@"value", nil] autorelease] atIndex:0];
        
    }
    return self;
}

- (id)initWithSearchJobTypeFilter:(id <SearchPickerDelegate>)delegate
                      selectValue:(NSString *)selectValue
                       selectName:(NSString *)selectName
                     defaultValue:(NSString *)defaultValue
{
    self = [[[[NSBundle mainBundle] loadNibNamed:@"SearchPickerView" owner:self options:nil] objectAtIndex:0] retain];
    if (self) {
        self.delegate = delegate;
        self.pickerType = SearchPickerWithJobType;
        [self.viewOneTop setHidden:false];
        [self.viewMultiTop setHidden:true];
        [self.viewMultiBottom setHidden:true];
        [self.btnCancel addTarget:self action:@selector(cancelPicker) forControlEvents:UIControlEventTouchUpInside];
        [self.btnSave addTarget:self action:@selector(savePicker) forControlEvents:UIControlEventTouchUpInside];
        [self connectDbAndInit];
        if (!selectValue) {
            selectValue = @"";
        }
        if ([selectValue rangeOfString:@","].location == NSNotFound) {
            [self setJobTypeDictionary:selectValue];
            if (selectValue.length > 0) {
                arrDictionaryL1 = [arrDictionaryL2 mutableCopy];
                [arrDictionaryL2 removeAllObjects];
            }
        }
        else {
            NSArray *arrSelectValue = [selectValue componentsSeparatedByString:@","];
            NSArray *arrSelectName = [selectName componentsSeparatedByString:@" "];
            for (int i=0; i<arrSelectValue.count; i++) {
                [arrDictionaryL1 addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                             arrSelectValue[i],@"id",
                                             arrSelectName[i],@"value", nil] autorelease]];
            }
            [self setJobTypeDictionary:[arrDictionaryL1[0] objectForKey:@"id"]];
        }
        [arrDictionaryL1 insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                        @"",@"id",
                                        @"全部职位类别",@"value", nil] autorelease] atIndex:0];
        
    }
    return self;
}

- (id)initWithSearchOtherFilter:(id <SearchPickerDelegate>)delegate
                   defaultValue:(NSString *)defaultValue
                    defaultName:(NSString *)defaultName
                      otherType:(SearchPickerOther)otherType

{
    self = [[[[NSBundle mainBundle] loadNibNamed:@"SearchPickerView" owner:self options:nil] objectAtIndex:0] retain];
    if (self) {
        [self connectDbAndInit];
        self.arrSelectValue = [NSMutableArray arrayWithCapacity:10];
        self.arrSelectName = [NSMutableArray arrayWithCapacity:10];
        if (defaultValue.length > 0) {
            self.arrSelectValue = [[defaultValue componentsSeparatedByString:@","] mutableCopy];
            self.arrSelectName = [[defaultName componentsSeparatedByString:@" "] mutableCopy];
        }
        self.delegate = delegate;
        [self.viewOneTop setHidden:true];
        [self.viewMultiTop setHidden:false];
        [self.viewMultiBottom setHidden:false];
        [self.btnMultiCancel addTarget:self action:@selector(cancelPicker) forControlEvents:UIControlEventTouchUpInside];
        [self.btnMultiSave addTarget:self action:@selector(saveMultiPicker) forControlEvents:UIControlEventTouchUpInside];
        
        [self.btnMultiAdd addTarget:self action:@selector(addPickerSelect) forControlEvents:UIControlEventTouchUpInside];
        [self.btnMultiClear addTarget:self action:@selector(removeAllMultiSelect) forControlEvents:UIControlEventTouchUpInside];
        self.pickerType = SearchPickerWithOther;
        [arrDictionaryL1 addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                     @"1",@"id",
                                     @"在线状态",@"value", nil] autorelease]];
        
        [arrDictionaryL1 addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                     @"2",@"id",
                                     @"学历要求",@"value", nil] autorelease]];
        
        [arrDictionaryL1 addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                     @"3",@"id",
                                     @"工作年限",@"value", nil] autorelease]];
        
        [arrDictionaryL1 addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                     @"4",@"id",
                                     @"工作性质",@"value", nil] autorelease]];
        
        [arrDictionaryL1 addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                     @"5",@"id",
                                     @"企业规模",@"value", nil] autorelease]];
        
        if (otherType != SearchPickerOtherNoWelfare){
            [arrDictionaryL1 addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                     @"6",@"id",
                                     @"福利待遇",@"value", nil] autorelease]];
        }
        
        [arrDictionaryL2 addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                     @"a1",@"id",
                                     @"在线",@"value", nil] autorelease]];
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
    if ([parentid length] == 2) {
        [arrDictionaryL2 removeAllObjects];
        int i = 0;
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
        NSArray *arrPrev;
        if (arrDictionaryL2.count == 0) {
            arrPrev = [[arrDictionaryL1 copy] autorelease];
        }
        else {
            arrPrev = [[arrDictionaryL2 copy] autorelease];
        }
        if ([self isMunicipality:[parentid substringToIndex:2]]) {
            return;
        }
        int i = 0;
        for (i=0; i<arrPrev.count; i++) {
            if ([arrPrev[i][@"id"] compare:parentid options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                break;
            }
        }
        if (i<arrPrev.count) {
            NSDictionary *dicParent = arrPrev[i];
            [arrDictionaryL3 addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                         dicParent[@"id"],@"id",
                                         [NSString stringWithFormat:@"全部%@",dicParent[@"value"]],@"value"
                                         , nil] autorelease]];
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
    FMResultSet *commonList;
    if ([self.selectTableName isEqualToString:@"Experience"]) {
        commonList = [db executeQuery:@"select DetailID _id,Description from dcothers where Category='职位要求工作经验'"];
    }
    else if ([self.selectTableName isEqualToString:@"EmployType"]) {
        commonList = [db executeQuery:@"select DetailID _id,Description from dcothers where Category='工作性质'"];
    }
    else {
        commonList = [db executeQuery:[NSString stringWithFormat:@"select * from %@",self.selectTableName]];
    }
    
    int i = 0;
    while ([commonList next]) {
        if (i == 0) {
            [self setJobTypeDictionary:[commonList stringForColumn:@"_id"]];
        }
        NSDictionary *dicCommon = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSString stringWithFormat:@"%@%@",self.selectIdentify,[commonList stringForColumn:@"_id"]],@"id",
                                   [commonList stringForColumn:@"description"],@"value"
                                   , nil];
        [arrDictionaryL2 addObject:dicCommon];
        [dicCommon release];
        i++;
    }
}

- (void)showInView:(UIView *)view
{
    self.frame = CGRectMake(0, view.frame.size.height, self.frame.size.width, self.frame.size.height);
    [view addSubview:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, view.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    }];
    if (self.pickerType == SearchPickerWithOther) {
        [self setupScollMulti];
        return;
    }
    [self.pickerDictionary selectRow:1 inComponent:0 animated:YES];
    [self.pickerDictionary selectRow:1 inComponent:1 animated:YES];
    if (self.pickerType == SearchPickerWithRegion) {
        [self.pickerDictionary selectRow:1 inComponent:2 animated:YES];
    }
}

- (void)cancelPicker
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = CGRectMake(0, self.frame.origin.y+self.frame.size.height, self.frame.size.width, self.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                     }];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    switch (self.pickerType) {
        case SearchPickerWithJobType:
            return 2;
            break;
        case SearchPickerWithRegion:
            return 3;
            break;
        case SearchPickerWithOther:
            return 2;
            break;
        default:
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

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    CGSize rowSize = [self.pickerDictionary rowSizeForComponent:component];
    UIView *viewContent = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, rowSize.width, rowSize.height)] autorelease];
    NSString *strTitle;
    bool blnSelected = NO;
    switch (component) {
        case 0:
            strTitle = [arrDictionaryL1[row] objectForKey:@"value"];
            break;
        case 1:
            strTitle = [arrDictionaryL2[row] objectForKey:@"value"];
            if ([self.arrSelectValue containsObject:[arrDictionaryL2[row] objectForKey:@"id"]]) {
                blnSelected = YES;
            }
            break;
        case 2:
            strTitle = [arrDictionaryL3[row] objectForKey:@"value"];
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

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (self.pickerType) {
        case SearchPickerWithRegion:
        {
            if (component == 0) {
                [arrDictionaryL2 removeAllObjects];
                [arrDictionaryL3 removeAllObjects];
                [self setRegionDictionary:[arrDictionaryL1[row] objectForKey:@"id"]];
                if (arrDictionaryL2.count == 0 && arrDictionaryL3.count > 0) {
                    arrDictionaryL2 = [arrDictionaryL3 mutableCopy];
                    [arrDictionaryL3 removeAllObjects];
                }
                [self.pickerDictionary reloadAllComponents];
                [self.pickerDictionary selectRow:1 inComponent:1 animated:true];
                [self.pickerDictionary selectRow:1 inComponent:2 animated:true];
                break;
            }
            else if (component == 1) {
                [arrDictionaryL3 removeAllObjects];
                if ([[arrDictionaryL2[row] objectForKey:@"id"] length] > 4) {
                    [self setRegionDictionary:[arrDictionaryL2[row] objectForKey:@"id"]];
                }
                [self.pickerDictionary reloadAllComponents];
                [self.pickerDictionary selectRow:1 inComponent:2 animated:true];
                break;
            }
        }
        case SearchPickerWithJobType:
            if (component == 0) {
                [arrDictionaryL2 removeAllObjects];
                if ([[arrDictionaryL1[row] objectForKey:@"id"] length] > 0) {
                    [self setJobTypeDictionary:[arrDictionaryL1[row] objectForKey:@"id"]];
                }
                [self.pickerDictionary reloadAllComponents];
                [self.pickerDictionary selectRow:1 inComponent:1 animated:true];
                break;
            }
            break;
        case SearchPickerWithOther:
            if (component == 0) {
                [arrDictionaryL2 removeAllObjects];
                switch (row) {
                    case 0:
                        [arrDictionaryL2 addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                                     @"a1",@"id",
                                                     @"在线",@"value", nil] autorelease]];
                        break;
                    case 1:
                        self.selectTableName = @"dcEducation";
                        self.selectIdentify = @"b";
                        [self setCommonDictionary];
                        break;
                    case 2:
                        self.selectTableName = @"Experience";
                        self.selectIdentify = @"c";
                        [self setCommonDictionary];
                        break;
                    case 3:
                        self.selectTableName = @"EmployType";
                        self.selectIdentify = @"d";
                        [self setCommonDictionary];
                        break;
                    case 4:
                        self.selectTableName = @"dcCompanySize";
                        self.selectIdentify = @"e";
                        [self setCommonDictionary];
                        break;
                    case 5:
                        [arrDictionaryL2 addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                                     @"f1",@"id",
                                                     @"保险",@"value", nil] autorelease]];
                        [arrDictionaryL2 addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                                     @"f2",@"id",
                                                     @"公积金",@"value", nil] autorelease]];
                        [arrDictionaryL2 addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                                     @"f13",@"id",
                                                     @"奖金提成",@"value", nil] autorelease]];
                        [arrDictionaryL2 addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                                     @"f3",@"id",
                                                     @"双休",@"value", nil] autorelease]];
                        [arrDictionaryL2 addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                                     @"f9",@"id",
                                                     @"8小时工作制",@"value", nil] autorelease]];
                        [arrDictionaryL2 addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                                     @"f10",@"id",
                                                     @"提供住宿",@"value", nil] autorelease]];
                        break;
                    default:
                        break;
                }

                
                [self.pickerDictionary reloadComponent:1];
                [self.pickerDictionary selectRow:0 inComponent:1 animated:true];
            }
        default:
            break;
    }
}

- (void)savePicker
{
    if ([self.delegate respondsToSelector:@selector(searchPickerDidChangeStatus:selectedValue:selectedName:)]) {
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
        [self.delegate searchPickerDidChangeStatus:self selectedValue:[NSString stringWithFormat:@"%@",dicSelected[@"id"]] selectedName:[[NSString stringWithFormat:@"%@",dicSelected[@"value"]] stringByReplacingOccurrencesOfString:@"全部" withString:@""]];
        
    }
}

- (void)saveMultiPicker
{
    if ([self.delegate respondsToSelector:@selector(searchPickerDidChangeStatus:selectedValue:selectedName:)]) {
        [self.delegate searchPickerDidChangeStatus:self selectedValue:[self.arrSelectValue componentsJoinedByString:@","] selectedName:[self.arrSelectName componentsJoinedByString:@" "]];
    }
}

- (void)addPickerSelect
{
    NSInteger selectRow = [self.pickerDictionary selectedRowInComponent:0];
    NSDictionary *dicSelected;
    dicSelected = arrDictionaryL2[[self.pickerDictionary selectedRowInComponent:1]];
    if ([self.arrSelectValue count] > 0) {
        if ([self.arrSelectValue containsObject:dicSelected[@"id"]]) {
            return;
        }
        if (selectRow != 5) {
            NSMutableArray *arrNewSelectValue = [[[NSMutableArray alloc] init] autorelease];
            NSMutableArray *arrNewSelectName = [[[NSMutableArray alloc] init] autorelease];
            for (int i=0; i<self.arrSelectValue.count; i++) {
                if ([[dicSelected[@"id"] substringToIndex:1] isEqualToString:[self.arrSelectValue[i] substringToIndex:1]]) {
                    
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
            [self.arrSelectName addObject:dicSelected[@"value"]];
        }
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
//        btnMultiSelect.tag = [self.arrSelectValue[i] intValue];
        [btnMultiSelect setTitle:self.arrSelectValue[i] forState:UIControlStateNormal];
        [btnMultiSelect setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
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
    NSString *multiSelectValue = sender.titleLabel.text;
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

- (void)removeAllMultiSelect
{
    [self.arrSelectValue removeAllObjects];
    [self.arrSelectName removeAllObjects];
    [self.pickerDictionary reloadAllComponents];
    [self setupScollMulti];
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
