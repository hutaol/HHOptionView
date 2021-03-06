//
//  HHOptionView.m
//  Pods
//
//  Created by Henry on 2021/4/29.
//

#import "HHOptionView.h"

static CGFloat const kAnimationTime = 0.3;
static CGFloat const kRowHeight = 44;
static CGFloat const kSearchHeight = 44;
static CGFloat const kSpaceHeight = 20;

static NSString *kCellIdentifier = @"HHOptionViewTableViewCellIdentifier";


@interface HHOptionView () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

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
/// 搜索框
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, assign) CGFloat tableViewHeight;
@property (nonatomic, assign) CGRect tableViewFrame;
@property (nonatomic, assign) CGFloat keyboardHeight;

@property (nonatomic, assign) CGRect superRect;

@property (nonatomic, assign) BOOL isDirectionUp;
@property (nonatomic, assign) BOOL isSearch;

@property (nonatomic, strong) NSMutableArray *dataList;


@end

@implementation HHOptionView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configView];
    }
    return self;
}

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

- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    self.keyboardHeight = keyboardRect.size.height;
    
    [UIView animateWithDuration:kAnimationTime animations:^{
        [self updateLocation];
    }];
}

- (void)updateLocation {
    CGFloat contentHeight = self.window.frame.size.height - self.keyboardHeight;
    
    if (!self.isDirectionUp) {
        CGFloat maxY = CGRectGetMaxY(self.tableView.frame);
        if (maxY > contentHeight) {
            CGFloat increment = maxY - contentHeight;
            
            CGRect superRect =  self.superview.frame;
            
            CGRect frame = self.tableView.frame;

            if (self.tableViewHeight > contentHeight) {
                superRect.origin.y -= (frame.origin.y - self.titleLabel.frame.size.height);
                superRect.origin.y += kSpaceHeight;
                superRect.origin.y += [self hh_safeTop];

                frame.size.height = contentHeight - self.titleLabel.frame.size.height - kSpaceHeight - [self hh_safeTop] ;
            } else {
                superRect.origin.y -= increment;
            }
            
            self.superview.frame = superRect;
            
            frame.origin.y = [self hh_screenViewY] + self.titleLabel.frame.size.height;
            self.tableView.frame = frame;

        }
    } else {
        CGFloat maxY = CGRectGetMaxY(self.tableView.frame) + self.titleLabel.frame.size.height;
        if (maxY > contentHeight) {
            
            CGFloat increment = maxY - contentHeight;
            CGRect superRect =  self.superview.frame;
            superRect.origin.y -= increment;
            self.superview.frame = superRect;
            
            CGRect frame = self.tableView.frame;
            if (self.tableViewHeight > contentHeight) {
                frame.origin.y = kSpaceHeight + [self hh_safeTop];
                frame.size.height = contentHeight - self.titleLabel.frame.size.height - kSpaceHeight - [self hh_safeTop];
            } else {
                frame.origin.y -= increment;
            }
            self.tableView.frame = frame;

        }
    }
}

- (void)show {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];

    self.dataList = [self.dataSource mutableCopy];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.backgroundBtn];
    [window addSubview:self.tableView];
    
    [self updateDataAndHeight];
    
    self.backgroundBtn.frame = [UIScreen mainScreen].bounds;
    
    self.tableView.frame = CGRectMake(self.tableViewFrame.origin.x, self.tableViewFrame.origin.y+(self.isDirectionUp?self.tableViewHeight:0), self.tableViewFrame.size.width, 0);

    typeof(self) __weak weakSelf = self;
    [UIView animateWithDuration:kAnimationTime animations:^{
        weakSelf.rightImageView.transform = CGAffineTransformRotate(weakSelf.rightImageView.transform,self.isDirectionUp?-M_PI/2:M_PI/2);
        weakSelf.tableView.frame = weakSelf.tableViewFrame;
        weakSelf.superRect = self.superview.frame;
    }];
    
}

- (void)dismiss {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    typeof(self) __weak weakSelf = self;
    [UIView animateWithDuration:kAnimationTime animations:^{
        weakSelf.rightImageView.transform = CGAffineTransformIdentity;
        weakSelf.tableView.frame = CGRectMake(weakSelf.tableView.frame.origin.x, weakSelf.tableView.frame.origin.y+(self.isDirectionUp?self.tableViewHeight:0), weakSelf.tableView.frame.size.width, 0);
    } completion:^(BOOL finished) {
        [weakSelf.backgroundBtn removeFromSuperview];
        [weakSelf.tableView removeFromSuperview];
    }];
}

#pragma mark - Private

- (void)updateDataAndHeight {
    if (self.isSearch) {
        return;
    }
    
    CGFloat hh = 0;
    if (self.rowHeight) {
        hh = self.dataSource.count*self.rowHeight;
    } else {
        hh = self.dataSource.count*kRowHeight;
    }
    
    if (self.showSearchBar) {
        hh += kSearchHeight;
    }
    
    CGFloat topHeight = [self hh_screenViewY] - [self hh_safeTop];
    CGFloat bottomHeight = [[UIScreen mainScreen] bounds].size.height - [self hh_screenViewY] - self.frame.size.height - [self hh_safeBottom];
    if (topHeight > bottomHeight) {
        self.isDirectionUp = YES;
    } else {
        self.isDirectionUp = NO;
    }
    CGFloat mh = MAX(topHeight, bottomHeight);
    mh -= kSpaceHeight;
    self.tableViewHeight = MIN(hh, mh);
    
    CGRect frame = [self convertRect:self.bounds toView:self.window];
    
    CGRect tableViewFrame;
    tableViewFrame.size.width = frame.size.width;
    tableViewFrame.size.height = self.tableViewHeight;
    tableViewFrame.origin.x = frame.origin.x;
    
    if (self.isDirectionUp) {
        tableViewFrame.origin.y = frame.origin.y - self.tableViewHeight;
    } else {
        tableViewFrame.origin.y = frame.origin.y + frame.size.height;
    }
    
    self.tableViewFrame = tableViewFrame;

}

- (CGFloat)hh_safeBottom {
    if (@available(iOS 11.0, *)) {
        return self.window.safeAreaInsets.bottom;
    } else {
        return 0;
    }
}

- (CGFloat)hh_safeTop {
    if (@available(iOS 11.0, *)) {
        return self.window.safeAreaInsets.top;
    } else {
        return 0;
    }
}

- (CGFloat)hh_screenViewY {
    CGFloat y = 0;
    for (UIView *view = self; view; view = view.superview) {
        y += view.frame.origin.y;
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView*)view;
            y -= scrollView.contentOffset.y;
        }
    }
    return y;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.isSearch = NO;
    [UIView animateWithDuration:kAnimationTime animations:^{
        self.tableView.frame = self.tableViewFrame;
        self.superview.frame = self.superRect;
    }];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length == 0) {
        self.isSearch = NO;

        self.dataSource = self.dataList;
        [self.tableView reloadData];
        return;
    }
    
    self.isSearch = YES;
    
    NSMutableArray *copyArray = [NSMutableArray array];
    for (NSString *string in self.dataList) {
        NSRange titleResult = [string rangeOfString:searchText options:NSCaseInsensitiveSearch];
        if (titleResult.length > 0) {
            [copyArray addObject:string];
        }
    }
    
    self.dataSource = copyArray;
    [self.tableView reloadData];

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
    
    if (self.isSearch) {
        self.dataSource = self.dataList;
        [self.tableView reloadData];
        self.isSearch = NO;
        self.searchBar.text = @"";
        [self.searchBar resignFirstResponder];
        for (int i = 0; i < self.dataSource.count; i ++) {
            if ([self.dataSource[i] isEqualToString:self.title]) {
                self.selectedIndex = i;
                break;
            }
        }
    }

    [self dismiss];
    if ([self.delegate respondsToSelector:@selector(optionView:selectedIndex:)]) {
        [self.delegate optionView:self selectedIndex:indexPath.row];
    }
    if (self.selectedBlock) {
        self.selectedBlock(self, indexPath.row);
    }
}

#pragma mark - Setters

- (void)setRowHeight:(CGFloat)rowHeight {
    _rowHeight = rowHeight;
    self.tableView.rowHeight = rowHeight;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)setDataSource:(NSArray *)dataSource {
    _dataSource = dataSource;
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

- (void)setShowSearchBar:(BOOL)showSearchBar {
    if (_showSearchBar == showSearchBar) {
        return;
    }
    _showSearchBar = showSearchBar;
    if (showSearchBar) {
        self.tableView.tableHeaderView = self.searchBar;
    } else {
        self.tableView.tableHeaderView = nil;
    }
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
        _rightImageView = [[UIImageView alloc] initWithImage:[self getResourceImage:@"icon_default"]];
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
        _tableView.rowHeight = kRowHeight;
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

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, kSearchHeight)];
        _searchBar.placeholder = @"搜索";
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (UIImage *)getResourceImage:(NSString *)name {
    NSString *path = [[[[NSBundle bundleForClass:[self class]] URLForResource:@"HHOptionView" withExtension:@"bundle"] relativePath] stringByAppendingPathComponent:name];
    return [UIImage imageWithContentsOfFile:path];
}

@end
