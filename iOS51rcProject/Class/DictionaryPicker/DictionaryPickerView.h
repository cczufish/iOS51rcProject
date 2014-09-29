#import <UIKit/UIKit.h>

typedef enum {
    DictionaryPickerWithRegionL3,
    DictionaryPickerWithRegionL2,
    DictionaryPickerWithJobType,
    DictionaryPickerWithCommon
} DictionaryPickerType;

typedef enum {
    DictionaryPickerModeOne,
    DictionaryPickerModeMulti
} DictionaryPickerMode;

typedef enum {
    DictionaryPickerIncludeParent,
    DictionaryPickerNoIncludeParent
} DictionaryPickerInclude;

@class DictionaryPickerView;

@protocol DictionaryPickerDelegate <NSObject>

@optional
- (void)pickerDidChangeStatus:(DictionaryPickerView *)picker
                  selectedValue:(NSString *)selectedValue
                   selectedName:(NSString *)selectedName;

@end

@interface DictionaryPickerView : UIView <UIPickerViewDelegate, UIPickerViewDataSource>

@property (assign, nonatomic) id <DictionaryPickerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerDictionary;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollMulti;
@property (retain, nonatomic) IBOutlet UIView *viewMultiTop;
@property (retain, nonatomic) IBOutlet UIView *viewOneTop;
@property (retain, nonatomic) IBOutlet UIView *viewMultiBottom;
@property (retain, nonatomic) IBOutlet UILabel *lbMulti;
@property (retain, nonatomic) IBOutlet UIButton *btnMultiCancel;
@property (retain, nonatomic) IBOutlet UIButton *btnMultiConfirm;
@property (retain, nonatomic) IBOutlet UIButton *btnMultiAdd;

@property (nonatomic) DictionaryPickerType pickerType;
@property (nonatomic) DictionaryPickerMode pickerMode;
@property (nonatomic) DictionaryPickerInclude pickerInclude;
@property (retain, nonatomic) NSMutableArray *arrSelectValue;
@property (retain, nonatomic) NSMutableArray *arrSelectName;
@property (assign, nonatomic) NSString *selectTableName;

- (id)initWithCustom:(DictionaryPickerType)pickerType
          pickerMode:(DictionaryPickerMode)pickerMode
       pickerInclude:(DictionaryPickerInclude)pickerInclude
           delegate:(id <DictionaryPickerDelegate>)delegate
        defaultValue:(NSString *)defaultValue
         defaultName:(NSString *)defaultName;

- (id)initWithDictionary:(id <DictionaryPickerDelegate>)delegate
       defaultArray:(NSMutableArray *)defaultArray
            defaultValue:(NSString *)defaultValue
             defaultName:(NSString *)defaultName
              pickerMode:(DictionaryPickerMode)pickerMode;

- (id)initWithCommon:(id <DictionaryPickerDelegate>)delegate
          pickerMode:(DictionaryPickerMode)pickerMode
           tableName:(NSString *)tableName
        defaultValue:(NSString *)defaultValue
         defaultName:(NSString *)defaultName;

- (void)showInView:(UIView *)view;
- (void)cancelPicker;

@end
