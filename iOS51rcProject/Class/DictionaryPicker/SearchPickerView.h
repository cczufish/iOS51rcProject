#import <UIKit/UIKit.h>

typedef enum {
    SearchPickerWithRegion,
    SearchPickerWithJobType,
    SearchPickerWithOther
} SearchPickerType;

typedef enum {
    SearchPickerOtherAll,
    SearchPickerOtherNoWelfare
} SearchPickerOther;

@class SearchPickerView;

@protocol SearchPickerDelegate <NSObject>

@optional
- (void)searchPickerDidChangeStatus:(SearchPickerView *)picker
                selectedValue:(NSString *)selectedValue
                 selectedName:(NSString *)selectedName;

@end

@interface SearchPickerView : UIView <UIPickerViewDelegate, UIPickerViewDataSource>

@property (assign, nonatomic) id <SearchPickerDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIButton *btnMultiClear;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerDictionary;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollMulti;
@property (retain, nonatomic) IBOutlet UIButton *btnMultiAdd;
@property (retain, nonatomic) IBOutlet UIView *viewMultiTop;
@property (retain, nonatomic) IBOutlet UIView *viewMultiBottom;
@property (retain, nonatomic) IBOutlet UILabel *lbMulti;
@property (retain, nonatomic) IBOutlet UIButton *btnMultiSave;
@property (retain, nonatomic) IBOutlet UIButton *btnMultiCancel;
@property (strong, nonatomic) IBOutlet UIButton *btnCancel;
@property (strong, nonatomic) IBOutlet UIButton *btnSave;
@property (retain, nonatomic) IBOutlet UIView *viewOneTop;
@property (nonatomic) SearchPickerType pickerType;
@property (retain, nonatomic) NSMutableArray *arrSelectValue;
@property (retain, nonatomic) NSMutableArray *arrSelectName;
@property (assign, nonatomic) NSString *selectTableName;
@property (assign, nonatomic) NSString *selectIdentify;

- (id)initWithSearchRegionFilter:(id <SearchPickerDelegate>)delegate
                     selectValue:(NSString *)selectValue
                      selectName:(NSString *)selectName
                    defaultValue:(NSString *)defaultValue;

- (id)initWithSearchJobTypeFilter:(id <SearchPickerDelegate>)delegate
                     selectValue:(NSString *)selectValue
                      selectName:(NSString *)selectName
                    defaultValue:(NSString *)defaultValue;

- (id)initWithSearchOtherFilter:(id <SearchPickerDelegate>)delegate
                   defaultValue:(NSString *)defaultValue
                    defaultName:(NSString *)defaultName
                      otherType:(SearchPickerOther)otherType;

- (void)showInView:(UIView *)view;
- (void)cancelPicker;

@end