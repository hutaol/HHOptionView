//
//  HHMultipleOptionView.m
//  Pods
//
//  Created by Henry on 2021/7/13.
//

#import "HHMultipleOptionView.h"

@implementation HHMultipleOptionItem

- (instancetype)initWithTitle:(NSString *)title type:(NSString *)type selected:(BOOL)selected {
    self = [super init];
    if (self) {
        _title = title;
        _type = type;
        _selected = selected;
    }
    return self;
}

@end

static CGFloat const kAnimationTime = 0.3;
static CGFloat const kRowHeight = 44;
static CGFloat const kSearchHeight = 44;
static CGFloat const kSpaceHeight = 20;

static NSString *kSelectAllType = @"All";

static NSString *kCellIdentifier = @"HHMultipleOptionViewTableViewCellIdentifier";


@interface HHMultipleOptionView () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

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


@implementation HHMultipleOptionView

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

- (instancetype)initWithFrame:(CGRect)frame dataSource:(NSArray<HHMultipleOptionItem *> *)dataSource {
    if (self = [super initWithFrame:frame]) {
        self.dataSource = dataSource.mutableCopy;
        [self configView];
    }
    return self;
}

- (void)configView {
    self.cornerRadius = 5;
    self.borderWidth = 1;
    self.borderColor = [UIColor colorWithRed:153.0/255 green:153.0/255 blue:153.0/255 alpha:1];
    self.selectedImage = [self getResourceImage:@"icon_selected"];
    self.unselectedImage = [self getResourceImage:@"icon_unselected"];
    self.showSelectAllButton = NO;
    
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

                frame.size.height = contentHeight - self.titleLabel.frame.size.height - kSpaceHeight - [self hh_safeTop];
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
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(multipleOptionView:dismiss:)]) {
        [self.delegate multipleOptionView:self dismiss:[self getSelectedItems]];
    }
    
    if (self.dismissBlock) {
        self.dismissBlock(self, [self getSelectedItems]);
    }
}

#pragma mark - Public

- (void)resetTitle {
    self.title = [self getTitles];
}

- (NSString *)getSelectedTypes {
    NSString *str = @"";
    for (HHMultipleOptionItem *item in self.dataSource) {
        if (item.selected && ![item.type isEqualToString:kSelectAllType]) {
            if (str.length == 0) {
                str = item.type;
            } else {
                NSString *itemStr = [@"," stringByAppendingString:item.type];
                str = [str stringByAppendingString:itemStr];
            }
        }
    }
    return str;
}

- (NSArray<HHMultipleOptionItem *> *)getSelectedItems {
    NSMutableArray *arr = [NSMutableArray array];
    for (HHMultipleOptionItem *item in self.dataSource) {
        if (item.selected && ![item.type isEqualToString:kSelectAllType]) {
            [arr addObject:item];
        }
    }
    return arr;
}


- (NSString *)getTitles {
    NSString *str = @"";
    for (HHMultipleOptionItem *item in self.dataSource) {
        if (item.selected && ![item.type isEqualToString:kSelectAllType]) {
            if (str.length == 0) {
                str = item.title;
            } else {
                NSString *itemStr = [@"," stringByAppendingString:item.title];
                str = [str stringByAppendingString:itemStr];
            }
        }
    }
    return str;
}

#pragma mark - Privte

// 更新全选和高度
- (void)updateDataAndHeight {
    if (self.isSearch) {
        return;
    }
    // 取第一个
    if (self.dataSource.count > 0) {
        HHMultipleOptionItem *item = self.dataSource[0];
        if ([item.type isEqualToString:kSelectAllType]) {
            if (!self.showSelectAllButton) {
                [self.dataSource removeObjectAtIndex:0];
            }
        } else {
            if (self.showSelectAllButton) {
                HHMultipleOptionItem *allItem = [[HHMultipleOptionItem alloc] initWithTitle:@"全选" type:kSelectAllType selected:NO];
                [self.dataSource insertObject:allItem atIndex:0];
            }
        }
    }
    
    [self updateHeight];
}

- (void)updateHeight {
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
            UIScrollView* scrollView = (UIScrollView*)view;
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
    for (HHMultipleOptionItem *tempItem in self.dataList) {
        NSRange titleResult = [tempItem.title rangeOfString:searchText options:NSCaseInsensitiveSearch];
        if (titleResult.length > 0) {
            [copyArray addObject:tempItem];
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
    HHMultipleOptionItem *item = self.dataSource[indexPath.row];
    cell.textLabel.text = item.title;

    cell.imageView.image = item.selected ? self.selectedImage : self.unselectedImage;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    HHMultipleOptionItem *item = self.dataSource[indexPath.row];
    
    if (self.isSearch) {
        item.selected = YES;
        cell.imageView.image = self.selectedImage;

        self.dataSource = self.dataList;
        [self.tableView reloadData];
        self.isSearch = NO;
        self.searchBar.text = @"";
        [self.searchBar resignFirstResponder];
        [self resetTitle];
        
        if (self.showSelectAllButton) {
            // 所有选中 为全选
            BOOL isAllSelected = YES;
            for (HHMultipleOptionItem *tt in self.dataSource) {
                if (![tt.type isEqualToString:kSelectAllType]) {
                    if (tt.selected == NO) {
                        isAllSelected = NO;
                        break;
                    }
                }
            }
            UITableViewCell *firstCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            HHMultipleOptionItem *firstItem = self.dataSource[0];

            if (isAllSelected) {
                firstCell.imageView.image = self.selectedImage;
                firstItem.selected = YES;
            } else {
                firstCell.imageView.image = self.unselectedImage;
                firstItem.selected = NO;
            }
        }
        
        return;
    }
    
    if (item.selected) {
        item.selected = NO;
        cell.imageView.image = self.unselectedImage;
        
        // 全选按钮 取消
        if ([item.type isEqualToString:kSelectAllType]) {
            for (HHMultipleOptionItem *tt in self.dataSource) {
                tt.selected = NO;
            }
            [self.tableView reloadData];
        } else {
            // 一个取消 全选为取消
            if (self.showSelectAllButton) {
                UITableViewCell *firstCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                firstCell.imageView.image = self.unselectedImage;
                HHMultipleOptionItem *firstItem = self.dataSource[0];
                firstItem.selected = NO;
            }
        }
    } else {
        item.selected = YES;
        cell.imageView.image = self.selectedImage;
            
        // 全选按钮 取消
        if ([item.type isEqualToString:kSelectAllType]) {
            for (HHMultipleOptionItem *tt in self.dataSource) {
                tt.selected = YES;
            }
            [self.tableView reloadData];
        } else {
            if (self.showSelectAllButton) {
                // 所有选中 为全选
                BOOL isAllSelected = YES;
                for (HHMultipleOptionItem *tt in self.dataSource) {
                    if (![tt.type isEqualToString:kSelectAllType]) {
                        if (tt.selected == NO) {
                            isAllSelected = NO;
                            break;
                        }
                    }
                }
                UITableViewCell *firstCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                HHMultipleOptionItem *firstItem = self.dataSource[0];

                if (isAllSelected) {
                    firstCell.imageView.image = self.selectedImage;
                    firstItem.selected = YES;
                } else {
                    firstCell.imageView.image = self.unselectedImage;
                    firstItem.selected = NO;
                }
            }
        }
    }
    
    // TODO 多选 更新 title
    [self resetTitle];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(multipleOptionView:selectedItem:)]) {
        [self.delegate multipleOptionView:self selectedItem:item];
    }
    if (self.selectedBlock) {
        self.selectedBlock(self, item);
    }
}

#pragma mark - Setters

- (void)setDataSource:(NSMutableArray<HHMultipleOptionItem *> *)dataSource {
    _dataSource = dataSource;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    self.titleLabel.textColor = titleColor;
}

- (void)setTitleFontSize:(CGFloat)titleFontSize {
    _titleFontSize = titleFontSize;
    self.titleLabel.font = [UIFont systemFontOfSize:titleFontSize];
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

- (NSMutableArray *)selectedIndexArray {
    if (!_selectedIndexArray) {
        _selectedIndexArray = [NSMutableArray array];
    }
    return _selectedIndexArray;
}

- (void)setRowHeight:(CGFloat)rowHeight {
    _rowHeight = rowHeight;
    self.tableView.rowHeight = rowHeight;
}

- (void)setShowSelectAllButton:(BOOL)showSelectAllButton {
    if (_showSelectAllButton == showSelectAllButton) {
        return;
    }
    _showSelectAllButton = showSelectAllButton;
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
