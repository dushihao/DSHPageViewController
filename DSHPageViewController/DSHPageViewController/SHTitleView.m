//
//  SHTitleView.m
//  DSHPageViewController
//
//  Created by shihao on 2017/8/23.
//  Copyright © 2017年 shihao. All rights reserved.
//

#import "SHTitleView.h"
#import "SHCollectionView.h"
#import "SHCollectionViewCell.h"

static CGFloat const kAnimationTime = 0.3;
static CGFloat const kSliderHeight = 2;
@interface SHTitleView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic) SHCollectionView *titleCollectionView;
@property (nonatomic) UIView *slider;

@property (nonatomic) NSArray *titleSizeCache;
@property (nonatomic) NSArray *itemWidthCache;

@end

@implementation SHTitleView{
    NSArray *_titleSizeCache;
    NSArray *_itemWidthCache;
}

#pragma mark - 构造方法
- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    
    _minimumTitleSpacing = 15;
    _selectedIndex = NSNotFound;
    _titleFont = [UIFont systemFontOfSize:15];
    _titleScale = 1.2;
    _normalTitleColor = [UIColor lightGrayColor];
    _seletedTitleColor = [UIColor blueColor];
    
    // 布局collectionView
    [self setupCollectionView];
    // 布局sliderView
    [self setupSliderView];
}

- (void)setupCollectionView{
    
    SHCollectionView *collectionView = [[SHCollectionView alloc]initWithReuseIdentifier:NSStringFromClass([SHCollectionViewCell class])];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleCollectionView = collectionView;
    [self addSubview:collectionView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(collectionView);
    NSString *visualFormat[] = {@"H:|[collectionView]|",@"V:|[collectionView]|"};
    for (NSUInteger i = 0; i< 2; i++) {
        [NSLayoutConstraint activateConstraints:
        [NSLayoutConstraint constraintsWithVisualFormat:visualFormat[i] options:kNilOptions metrics:nil views:views]];
    }
}

- (void)setupSliderView{
    
    UIView *slider = [UIView new];
    self.slider = slider;
    [self.titleCollectionView addSubview:slider];
}

#pragma mark - set 方法 

- (void)setSeletedTitleColor:(UIColor *)seletedTitleColor{
    
    _seletedTitleColor = seletedTitleColor;
    self.slider.backgroundColor = seletedTitleColor;
}

#pragma mark - uicollectionView delegate / datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.titles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    SHCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SHCollectionViewCell class]) forIndexPath:indexPath];
    cell.title = self.titles[indexPath.row];
    cell.titleFont = self.titleFont;
    cell.titleScale = self.titleScale;
    cell.normalTitleColor = self.normalTitleColor;
    cell.selectedTitleColor = self.seletedTitleColor;
    cell.titleSize = [self.titleSizeCache[indexPath.item] CGSizeValue];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    // 动画效果处理
    if (self.selectedIndex != indexPath.item) {
        [self sh_seletedTitleForItem:indexPath.item];
        [self sh_scrollToItemForIndexPath:indexPath animated:YES];
        [self sh_scrollSliderToIndexPath:indexPath animated:YES];
        !self.seltedTitlehander ?:self.seltedTitlehander(indexPath.item, self.titles[indexPath.item]);
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [self sh_computerItemSizeCache];
    
    return CGSizeMake([self.itemWidthCache[indexPath.row] floatValue], CGRectGetHeight(collectionView.frame));
}

#pragma mark - *************************私有方法*********************************
#pragma mark - 选中标题

- (void)sh_seletedTitleForItem:(NSUInteger)item{
    
    if (self.selectedIndex == item) return;
    
    _selectedIndex = item;
    _selectedTitle = self.titles[item];
}

- (void)sh_seletedItemForIndex:(NSUInteger)index animated:(BOOL)animated{
    
    [self sh_seletedTitleForItem:index];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self.titleCollectionView selectItemAtIndexPath:indexPath animated:animated scrollPosition:UICollectionViewScrollPositionNone];
    [self sh_scrollSliderToIndexPath:indexPath animated:animated];
    !self.seltedTitlehander ?:self.seltedTitlehander(indexPath.item, self.titles[indexPath.item]);
}

#pragma mark - 滚动标题

- (void)sh_scrollToItemForIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated{
    // 滚动到屏幕中间
    [self.titleCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
}

// 设置slider

- (void)sh_scrollSliderToIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated{
    
    if (!self.titleSizeCache && !self.itemWidthCache) [self sh_computerItemSizeCache];
    
    if (animated)  self.userInteractionEnabled = NO;
    [UIView animateWithDuration:animated ?kAnimationTime : 0 animations:^{
        
        CGFloat sliderCenterX = [self sh_collectionViewItemAttributesForIndexPath:indexPath].center.x;
        CGFloat width = [self.itemWidthCache[indexPath.item] floatValue] ;
        
        self.slider.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - kSliderHeight, width, kSliderHeight);
        self.slider.center = ({
            CGPoint center = self.slider.center;
            center.x = sliderCenterX;
            center;
        });
    } completion:^(BOOL finished) {
        self.userInteractionEnabled = YES;
    }];
}

- (void)sh_computerItemSizeCache{
    
    if (_titleSizeCache && _itemWidthCache) return;
    
    NSUInteger titlesCount = self.titles.count;
    
    CGSize titleSizeArray[titlesCount];
    CGFloat itemWidthArray[titlesCount];
    
    CGFloat totalTextWidth = 0;
    CGFloat totalItemWidth = 0;
    
    NSMutableArray *titleSizeCache = [NSMutableArray arrayWithCapacity:titlesCount];
    NSInteger index=0;
    for (NSString *title in self.titles) {
        
        CGSize textSize = [title sizeWithAttributes:@{NSFontAttributeName:self.titleFont}];
        titleSizeArray[index] = textSize;
        totalTextWidth += titleSizeArray[index].width;
        [titleSizeCache addObject:[NSValue valueWithCGSize:textSize]];
        
        itemWidthArray[index] = textSize.width + self.minimumTitleSpacing;
        totalItemWidth += itemWidthArray[index];
        
        ++ index;
    }
    
    NSMutableArray *itemWidthCache = [NSMutableArray arrayWithCapacity:titlesCount];
    for (int i = 0; i < titlesCount; ++i) {
        [itemWidthCache addObject:@(itemWidthArray[i])];
    }
    
    _titleSizeCache = titleSizeCache;
    _itemWidthCache = itemWidthCache;
}

- (UICollectionViewLayoutAttributes *)sh_collectionViewItemAttributesForIndexPath:(NSIndexPath *)indexPath{
    
    return [self.titleCollectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
}

#pragma mark - 滑动标题

- (void)setSlideProgress:(CGFloat)slideProgress{
    
    slideProgress = fmax(-1.0, fmin(slideProgress, +1.0));
    if (slideProgress == _slideProgress) {
        return;
    }
    _slideProgress = slideProgress ;
    
    //设置目标index
    NSUInteger targetIndex = NSNotFound;
    if (slideProgress > 0) {
        NSAssert(self.selectedIndex < self.titles.count - 1, @"self.selectedIndex = self.titles.count-1 out of bound of titlesArray");
        targetIndex = self.selectedIndex + 1;
    }else if(slideProgress < 0){
        
        NSAssert(self.selectedIndex >= 1, @"self.selectedIndex == 0 will out of bound of titlesArray");
        targetIndex = self.selectedIndex - 1;
    }else{
        targetIndex = self.selectedIndex;
    }
    
    // 渲染cell
    [self sh_renderTitleBySliderProgressWithTargetindex:targetIndex];
    // 处理 slider
    [self sh_scrollSliderAtSlideProgressWithTargetIndex:targetIndex];
    
    if (self.slideProgress == -1.0 || self.slideProgress == + 1.0) {
        self.slideProgress = 0.0;
        [self sh_seletedItemForIndex:targetIndex animated:NO];
        // 滚动 titlecollectionView 使标题可见
        [self sh_scrollToItemForIndexPath:[NSIndexPath indexPathForRow:targetIndex inSection:0] animated:YES];
    }
}

// 渲染标题
- (void)sh_renderTitleBySliderProgressWithTargetindex:(NSUInteger)targetIndex{
    
    // render currentCell
    SHCollectionViewCell *currentCell = (SHCollectionViewCell *) [self.titleCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0]];
    currentCell.gradient = self.slideProgress;
    
    if (self.selectedIndex != targetIndex) {
        // render targetCell
        SHCollectionViewCell *targetCell = (SHCollectionViewCell *)[self.titleCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0]];
        if (self.slideProgress > 0) {
            targetCell.gradient = self.slideProgress - 1.0;
        }else if (self.slideProgress < 0){
            targetCell.gradient = self.slideProgress + 1.0;
        }else{
            NSAssert(NO, @" can't have this candition");
        }
      //  NSLog(@"currentCell.gradient == %f,targetCell.gradient == %f",currentCell.gradient ,targetCell.gradient);
    }
}

- (void)sh_scrollSliderAtSlideProgressWithTargetIndex:(NSUInteger)targetIndex{
    
    CGFloat progress = fabs(self.slideProgress);
    
    self.slider.frame = ({
        
        CGFloat currentWidth = self.slider.frame.size.width;
        CGFloat targetWidth = currentWidth ;
        if (self.selectedIndex != targetIndex) {
            targetWidth = [self.itemWidthCache[targetIndex] floatValue];
        }
        
        CGRect frame = self.slider.frame;
        frame.size.width = currentWidth + progress * (targetWidth - currentWidth);
        frame;
    });
    
    self.slider.center = ({
        
        CGFloat currentCenterX = [self sh_collectionViewItemAttributesForIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]].center.x;
        
        CGFloat targetCenterX = currentCenterX;
        
        if (self.selectedIndex != targetIndex) {
            targetCenterX = [self sh_collectionViewItemAttributesForIndexPath:[NSIndexPath indexPathForRow:targetIndex inSection:0]].center.x;
        }
        
        CGPoint center = self.slider.center;
        center.x = currentCenterX + progress * (targetCenterX - currentCenterX);
        center;
    });
}

@end
