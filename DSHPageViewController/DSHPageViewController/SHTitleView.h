//
//  SHTitleView.h
//  DSHPageViewController
//
//  Created by shihao on 2017/8/23.
//  Copyright © 2017年 shihao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHTitleView : UIView

@property (nonatomic) NSArray <NSString *> *titles; // 标签数组

@property (nonatomic) UIFont *titleFont;
/// 标题放大尺寸 default titleScale = 1.2
@property (nonatomic) CGFloat titleScale;
@property (nonatomic) CGFloat minimumTitleSpacing;  ///标签之间最小间距 default == 15
@property (nonatomic) UIColor *normalTitleColor;   //普通标签显示颜色
@property (nonatomic) UIColor *seletedTitleColor;  //选中标签显示颜色

@property (nonatomic,readonly) NSString *selectedTitle;
@property (nonatomic,readonly) NSUInteger selectedIndex;

@property (nonatomic) CGFloat slideProgress;

@property (nonatomic,copy) void (^ seltedTitlehander)(NSUInteger seletedIndex, NSString *selectedTitle);

// 设置选中某个指定标题
- (void)sh_seletedItemForIndex:(NSUInteger)index animated:(BOOL)animated;
@end
