//
//  HHMultipleOptionView.h
//  Pods
//
//  Created by Henry on 2021/7/13.
//

#import <UIKit/UIKit.h>
@class HHMultipleOptionView;

NS_ASSUME_NONNULL_BEGIN

@interface HHMultipleOptionItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, assign) BOOL selected;

- (instancetype)initWithTitle:(NSString *)title type:(NSString *)type selected:(BOOL)selected;

@end


@protocol HHMultipleOptionViewDelegate <NSObject>

@optional

- (void)multipleOptionView:(HHMultipleOptionView *)optionView selectedItem:(HHMultipleOptionItem *)item;

- (void)multipleOptionView:(HHMultipleOptionView *)optionView dismiss:(NSArray <HHMultipleOptionItem *> *)selectedArray;

@end


@interface HHMultipleOptionView : UIView

@property (nonatomic, weak) id<HHMultipleOptionViewDelegate> delegate;

/// 标题名
@property (nonatomic, strong) IBInspectable NSString *title;

/// 标题颜色
@property (nonatomic, strong) IBInspectable UIColor *titleColor;

/// 标题字体大小
@property (nonatomic, assign) IBInspectable CGFloat titleFontSize;

/// 视图圆角
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;

/// 视图边框颜色
@property (nonatomic, strong) IBInspectable UIColor *borderColor;

/// 边框宽度
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;

/// 行高度
@property (nonatomic, assign) CGFloat rowHeight;

@property (nonatomic, strong) NSMutableArray <HHMultipleOptionItem *> *dataSource;

@property (nonatomic, strong) NSMutableArray *selectedIndexArray;

@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UIImage *unselectedImage;

/// 展示全选，默认NO
@property (nonatomic, assign) BOOL showSelectAllButton;
/// 展示搜索，默认NO
@property (nonatomic, assign) BOOL showSearchBar;

- (instancetype)initWithFrame:(CGRect)frame dataSource:(NSArray <HHMultipleOptionItem *> *)dataSource;

@property (nonatomic, copy) void(^dismissBlock)(HHMultipleOptionView *optionView, NSArray <HHMultipleOptionItem *> *selectedArray);
@property (nonatomic, copy) void(^selectedBlock)(HHMultipleOptionView *optionView, HHMultipleOptionItem *item);


- (NSString *)getSelectedTypes;

- (NSArray <HHMultipleOptionItem *> *)getSelectedItems;

@end

NS_ASSUME_NONNULL_END
