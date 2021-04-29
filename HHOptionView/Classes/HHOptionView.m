//
//  HHOptionView.m
//  Pods
//
//  Created by Henry on 2021/4/29.
//

#import "HHOptionView.h"

static CGFloat const animationTime = 0.3;
static CGFloat const rowheight = 44;

#define kCellIdentifier @"HHOptionViewTableViewCellIdentifier"


@interface HHOptionView () <UITableViewDataSource, UITableViewDelegate>

/// 标题控件
@property (nonatomic, strong) UILabel *titleLabel;
/// 右边箭头图片
@property (nonatomic, strong) UIImageView *rightImageView;
/// 控件透明按钮，也可以给控件加手势
@property (nonatomic, strong) UIButton *maskBtn;
/// 选项列表
@property (nonatomic, strong) UITableView *tableView;
/// 蒙版
@property (nonatomic, strong) UIButton *backgroundBtn;
/// tableView的高度
@property (nonatomic, assign) CGFloat tableViewHeight;

@property (nonatomic, assign) BOOL isDirectionUp;

@end

@implementation HHOptionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame dataSource:(NSArray *)dataSource {
    if (self = [super initWithFrame:frame]) {
        self.dataSource = dataSource;
        [self configView];
    }
    return self;
}

- (void)configView {
    self.cornerRadius = 5;
    self.borderWidth = 1;
    self.borderColor = [UIColor colorWithRed:153.0/255 green:153.0/255 blue:153.0/255 alpha:1];

    [self addSubview:self.rightImageView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.maskBtn];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat imageWidth = 12;
    self.rightImageView.frame = CGRectMake(self.frame.size.width-imageWidth-10, (self.frame.size.height-imageWidth)/2, imageWidth, imageWidth);
    self.titleLabel.frame = CGRectMake(10, 0, self.frame.size.width-imageWidth-20, self.frame.size.height);
    self.maskBtn.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)show {
    typeof(self) __weak weakSelf = self;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.backgroundBtn];
    [window addSubview:self.tableView];
    
    // 获取按钮在屏幕中的位置
    CGRect frame = [self convertRect:self.bounds toView:window];
    CGFloat tableViewY = frame.origin.y + frame.size.height;
    CGRect tableViewFrame;
    tableViewFrame.size.width = frame.size.width;
    tableViewFrame.size.height = self.tableViewHeight;
    tableViewFrame.origin.x = frame.origin.x;
    
    if (tableViewY + self.tableViewHeight <= CGRectGetHeight([UIScreen mainScreen].bounds)) {
        tableViewFrame.origin.y = tableViewY;
        self.isDirectionUp = NO;
    } else {
        tableViewFrame.origin.y = frame.origin.y - self.tableViewHeight;
        self.isDirectionUp = YES;
    }
    
    self.tableView.frame = CGRectMake(tableViewFrame.origin.x, tableViewFrame.origin.y+(self.isDirectionUp?self.tableViewHeight:0), tableViewFrame.size.width, 0);
    
    [UIView animateWithDuration:animationTime animations:^{
        weakSelf.rightImageView.transform = CGAffineTransformRotate(weakSelf.rightImageView.transform,self.isDirectionUp?-M_PI/2:M_PI/2);
        weakSelf.tableView.frame = CGRectMake(tableViewFrame.origin.x, tableViewFrame.origin.y, tableViewFrame.size.width, tableViewFrame.size.height);
    }];
    
}

- (void)dismiss {
    typeof(self) __weak weakSelf = self;
    [UIView animateWithDuration:animationTime animations:^{
        weakSelf.rightImageView.transform = CGAffineTransformIdentity;
        weakSelf.tableView.frame = CGRectMake(weakSelf.tableView.frame.origin.x, weakSelf.tableView.frame.origin.y+(self.isDirectionUp?self.tableViewHeight:0), weakSelf.tableView.frame.size.width, 0);
    } completion:^(BOOL finished) {
        [weakSelf.backgroundBtn removeFromSuperview];
        [weakSelf.tableView removeFromSuperview];
    }];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    cell.textLabel.text = self.dataSource[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.title = self.dataSource[indexPath.row];
    self.selectedIndex = indexPath.row;
    [self dismiss];
    if ([self.delegate respondsToSelector:@selector(optionView:selectedIndex:)]) {
        [self.delegate optionView:self selectedIndex:indexPath.row];
    }
    if (self.selectedBlock) {
        self.selectedBlock(self, indexPath.row);
    }
}

#pragma mark - Setters

- (void)setRowHeigt:(CGFloat)rowHeigt {
    _rowHeigt = rowHeigt;
    self.tableView.rowHeight = rowHeigt;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)setDataSource:(NSArray *)dataSource {
    _dataSource = dataSource;
    
    CGFloat hh = 0;
    if (self.rowHeigt) {
        hh = self.dataSource.count*self.rowHeigt;
    } else {
        hh = self.dataSource.count*rowheight;
    }
    
    CGFloat mh = MAX([self hh_screenViewY] - [self hh_safeTop], [[UIScreen mainScreen] bounds].size.height - [self hh_ttScreenY] - self.frame.size.height - [self hh_safeBottom]);
    self.tableViewHeight = hh > mh ? mh : hh;
}

- (CGFloat)hh_safeBottom {
    if ([[UIApplication sharedApplication] statusBarFrame].size.height > 20) {
        return 34;
    }
    return 10;
}

- (CGFloat)hh_safeTop {
    return [[UIApplication sharedApplication] statusBarFrame].size.height;
}

- (CGFloat)hh_screenViewY {
    CGFloat y = 0;
    for (UIView* view = self; view; view = view.superview) {
        y += view.frame.origin.y;
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView* scrollView = (UIScrollView*)view;
            y -= scrollView.contentOffset.y;
        }
    }
    return y;
}

- (CGFloat)hh_ttScreenY {
    CGFloat y = 0.0f;
    for (UIView* view = self; view; view = view.superview) {
        y += view.frame.origin.y;
    }
    return y;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    if (self.dataSource.count > selectedIndex && selectedIndex > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex-1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }

}

- (void)setTitleFontSize:(CGFloat)titleFontSize {
    _titleFontSize = titleFontSize;
    self.titleLabel.font = [UIFont systemFontOfSize:titleFontSize];
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    self.titleLabel.textColor = titleColor;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
}

- (CGFloat)cornerRadius {
    return self.layer.cornerRadius;
}

- (void)setBorderColor:(UIColor *)borderColor {
    self.layer.borderColor = borderColor.CGColor;
}

- (UIColor *)borderColor {
    return (UIColor *)self.layer.borderColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    self.layer.borderWidth = borderWidth;
}

- (CGFloat)borderWidth {
    return self.layer.borderWidth;
}

#pragma mark - Getters

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.text = @"请选择选项";
        _titleLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1];
        _titleLabel.font = [UIFont systemFontOfSize:17];
    }
    return _titleLabel;
}

- (UIImageView *)rightImageView {
    if(!_rightImageView) {
        NSString *path = [self getResourcePath:@"icon_default"];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        _rightImageView = [[UIImageView alloc] initWithImage:image];
        _rightImageView.contentMode = UIViewContentModeScaleAspectFit;
        _rightImageView.clipsToBounds = YES;
    }
    return _rightImageView;
}

- (UIButton *)maskBtn {
    if (!_maskBtn) {
        _maskBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _maskBtn.backgroundColor = [UIColor clearColor];
        _maskBtn.clipsToBounds = YES;
        [_maskBtn addTarget:self action:@selector(show) forControlEvents:UIControlEventTouchUpInside];
    }
    return _maskBtn;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.tableFooterView = [UIView new];
        _tableView.rowHeight = rowheight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.layer.shadowOffset = CGSizeMake(4, 4);
        _tableView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
        _tableView.layer.shadowOpacity = 0.8;
        _tableView.layer.shadowRadius = 4;
        _tableView.layer.borderColor = [UIColor grayColor].CGColor;
        _tableView.layer.borderWidth = 0.5;
        _tableView.layer.cornerRadius = self.cornerRadius;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 5, 0, 5);
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIApplicationBackgroundFetchIntervalNever;
        }
    }
    return _tableView;
}

- (UIButton *)backgroundBtn {
    if (!_backgroundBtn) {
        _backgroundBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backgroundBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _backgroundBtn.frame = [UIScreen mainScreen].bounds;
        [_backgroundBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backgroundBtn;
}

- (NSBundle *)getResourceBundle:(NSString *)bundleName {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *bundleURL = [bundle URLForResource:bundleName withExtension:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithURL:bundleURL];
    if (!resourceBundle) {
        NSString * bundlePath = [bundle.resourcePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bundle", bundleName]];
        resourceBundle = [NSBundle bundleWithPath:bundlePath];
    }
    return resourceBundle ?: bundle;
}

- (NSString *)getResourcePath:(NSString *)name {
    return [[[self getResourceBundle:@"HHOptionView"] resourcePath] stringByAppendingPathComponent:name];
}


@end
