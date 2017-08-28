//
//  ViewController.m
//  DSHPageViewController
//
//  Created by shihao on 2017/8/23.
//  Copyright © 2017年 shihao. All rights reserved.
//

#import "ViewController.h"
#import "TableViewController.h"
#import "SHTitleView.h"

static const CGFloat kTittleViewHeight = 40;

@interface ViewController ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource,UIScrollViewDelegate>

@property (nonatomic) SHTitleView *titleView;
@property (nonatomic) UIPageViewController *pageViewController;

@property (nonatomic) UIFont *titleFont; // 字体大小
@property (nonatomic) UIColor *normalTitleColor;
@property (nonatomic) UIColor *seletedTitleColor;
@property (nonatomic) CGFloat minimumTitleSpacing;

@property (nonatomic) NSUInteger targetIndex;
@property (nonatomic) NSUInteger seletedIndex;
@property (nonatomic) NSString *seletedTitle;
@property (nonatomic) UIViewController *seletedController;
@property (nonatomic) NSArray *viewControllers; // sub Controllers

@property (nonatomic) UIScrollView *pageScrollView;

@property (nonatomic) BOOL isSlideProgessValid;

@end

@implementation ViewController

#pragma mark - 构造方法

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder{
    
    self = [super initWithCoder:coder];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit{
    
    _minimumTitleSpacing = 25;
    _seletedTitleColor = [UIColor redColor];
    _titleFont = [UIFont systemFontOfSize:15];
//    _normalTitleColor = [UIColor colorWithRed:248/255.0f green:248/255.0f blue:248/255.0f alpha:1];
    _normalTitleColor = [UIColor blackColor];
}

#pragma mark - lazy load

- (SHTitleView *)titleView{
    
    if (!_titleView) {
        _titleView = [[SHTitleView alloc]initWithFrame:CGRectMake(0, 60, self.view.bounds.size.width, kTittleViewHeight)];
        _titleView.titleFont = _titleFont;
        _titleView.normalTitleColor = _normalTitleColor;
        _titleView.seletedTitleColor = _seletedTitleColor;
        _titleView.minimumTitleSpacing = _minimumTitleSpacing;
    }
    return _titleView;
}

- (UIPageViewController *)pageViewController{
    if (!_pageViewController) {
        _pageViewController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    }
    return _pageViewController;
}

#pragma mark - life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *titles = @[@"头条",@"视频",@"娱乐新闻",@"体育",@"杭州城事",@"网易号",@"财经",@"科技",@"汽车",@"军事",@"时尚",@"直播",@"NBA",@"图片",@"跟帖",@"热点",@"房产"];
    //添加标签视图
    self.titleView.titles = [titles copy];
    
    __weak __typeof(self) weakSelf = self;
    [self.view addSubview:self.titleView];
    
    self.titleView.seltedTitlehander = ^(NSUInteger seletedIndex,NSString *selectedTitle){
        
    UIPageViewControllerNavigationDirection direction = seletedIndex < self.seletedIndex ? UIPageViewControllerNavigationDirectionReverse : UIPageViewControllerNavigationDirectionForward;
    weakSelf.seletedIndex = seletedIndex;
    [weakSelf.pageViewController setViewControllers:@[weakSelf.viewControllers[seletedIndex]] direction:direction animated:YES completion:nil];
        
        NSLog(@"current index == %@,current title === %@",@(seletedIndex),selectedTitle);
        
};
    
    //添加子控制器
    NSMutableArray *VCArray = [NSMutableArray arrayWithCapacity:titles.count];
    for (int i = 0; i<titles.count; ++i) {
        TableViewController *tableVC = [TableViewController new];
        tableVC.title = titles[i];
        [VCArray addObject:tableVC];
    }
    [self addViewControlls:VCArray titles:titles];
    
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.titleView sh_seletedItemForIndex:0 animated:NO];
    // 该段代码 会在在下个运行循环执行
//    [self.pageViewController setViewControllers:@[self.viewControllers[1]] direction:kNilOptions animated:NO completion:nil];
    });
}

#pragma mark - =.=

- (void)addViewControlls:(NSArray *)viewControllers titles:(NSArray *)titles{
    
    _viewControllers = viewControllers;
    _seletedIndex = 0;
    _seletedTitle = titles[0];
    _seletedController = viewControllers[0];
    
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    self.pageViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    //布局
    UIView *containerView = self.pageViewController.view;
    id<UILayoutSupport> bottomLayoutGuite = self.bottomLayoutGuide;
    NSDictionary *views = NSDictionaryOfVariableBindings(containerView,_titleView,bottomLayoutGuite);
    NSString *visualFormat[] = {
                                     @"H:|[containerView]|",
                                     @"V:[_titleView][containerView][bottomLayoutGuite]"
                                     };
    for (int i = 0; i<2; i++) {
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:visualFormat[i] options:kNilOptions metrics:nil views:views]];
    }
    
//    获取pageViewController delegate
    UIScrollView *scrollview = [self.pageViewController.view valueForKey:@"scrollView"];
    scrollview.panGestureRecognizer.maximumNumberOfTouches = 1;
    scrollview.delegate = self;
    self.pageScrollView = scrollview;
    
    
    
    [self.pageViewController setViewControllers:@[self.seletedController] direction:kNilOptions animated:NO completion:nil];
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    self.view.userInteractionEnabled = NO;
    self.isSlideProgessValid = YES;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (!self.isSlideProgessValid || self.targetIndex == NSNotFound) {
        return;
    }
    // 正在拖拽或松手后处于减速滑动或者回弹中
    if (scrollView.isDragging || scrollView.isDecelerating) {
        CGFloat widthOfScrollView = CGRectGetWidth(scrollView.bounds);
        CGFloat contentOffsetX = scrollView.contentOffset.x;
        CGFloat progress = (contentOffsetX - widthOfScrollView) / widthOfScrollView;
        if (progress > -1.0 && progress < 1.0) {
            self.titleView.slideProgress = progress;
        } else {
            // 大幅度滑动时，进度可能会溢出 [-1.0, +1.0] 闭区间，
            // 然后又会在回弹过程在重新落入 [-1.0, +1.0] 闭区间，
            // 因此一旦进度溢出，就判定到达最大值，并标记进度无效，忽略重新落入区间内的情况
            self.isSlideProgessValid = NO;
            self.view.userInteractionEnabled = NO;
            self.titleView.slideProgress = (progress > 0 ? +1.0 : -1.0);
        }
    }

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    // 为了避免潜在的问题，松手后会进入减速滑动状态则不允许再拖拽了
    if (decelerate) {
        self.view.userInteractionEnabled = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    // 减速滑动静止后重新开启交互功能
    self.view.userInteractionEnabled = YES;
    self.titleView.userInteractionEnabled = YES;
}

#pragma mark - pageViewController datasource / delegate

// datasource
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    
    if (self.viewControllers.count == 0) {
        return nil;
    }
    NSUInteger index = [self.viewControllers indexOfObjectIdenticalTo:viewController];
    if (index == NSNotFound || index == 0) {
        return nil;
    }
    return self.viewControllers[index-1];
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    if (self.viewControllers.count == 0) {
        return nil;
    }
    NSUInteger index = [self.viewControllers indexOfObjectIdenticalTo:viewController];
    if (index == NSNotFound || index == self.viewControllers.count - 1) {
        return nil;
    }
    return self.viewControllers[index+1];
}

// <UIPageViewControllerDelegate>
- (void)pageViewController:(UIPageViewController *)pageViewController
willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers{

    NSUInteger index = [self.viewControllers indexOfObjectIdenticalTo:pendingViewControllers[0]];
    NSAssert(index != NSNotFound, @"通过手势滑动页面时 index 不应该为 NSNotFound");
    self.targetIndex = index;
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    // 位于左右边界时，若继续向边界外拖动，则会跳过 -pageViewController:willTransitionToViewControllers:，
    // 而直接调用 -pageViewController:didFinishAnimating:previousViewControllers:transitionCompleted:，
    // 这种情况下 self.targetIndex 会为 NSNotFound
    
    if (completed && self.targetIndex != NSNotFound) {
        self.seletedIndex = self.targetIndex;
    }
    self.targetIndex = NSNotFound;
    
}

@end
