//
//  HHOptionView.h
//  Pods
//
//  Created by Henry on 2021/4/29.
//

#import <UIKit/UIKit.h>

@class HHOptionView;

IB_DESIGNABLE
NS_ASSUME_NONNULL_BEGIN

@protocol HHOptionViewDelete <NSObject>

- (void)optionView:(HHOptionView *)optionView selectedIndex:(NSInteger)selectedIndex;

@end

@interface HHOptionView : UIView

@property (nonatomic, weak) id<HHOptionViewDelete> delegate;

@property (nonatomic, copy) void(^selectedBlock)(HHOptionView *optionView, NSInteger selectedIndex);

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

@property (nonatomic, strong) NSArray <NSString *> *dataSource;

/// 展示搜索，默认NO
@property (nonatomic, assign) BOOL showSearchBar;

@property (nonatomic, assign) NSInteger selectedIndex;

- (instancetype)initWithFrame:(CGRect)frame dataSource:(NSArray *)dataSource;

@end

NS_ASSUME_NONNULL_END
