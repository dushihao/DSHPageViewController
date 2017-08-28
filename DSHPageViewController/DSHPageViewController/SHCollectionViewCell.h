//
//  SHCollectionViewCell.h
//  DSHPageViewController
//
//  Created by shihao on 2017/8/23.
//  Copyright © 2017年 shihao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHCollectionViewCell : UICollectionViewCell

/// 标题文本尺寸
@property (nonatomic) CGSize titleSize;

/// 标题放大系数 default titleScale = 1.2
@property (nonatomic) CGFloat titleScale;

/// 标题字体
@property (nonatomic) UIFont *titleFont;

/// 标题文本
@property (nonatomic, copy) NSString *title;

/// 普通标题颜色
@property (nonatomic)UIColor *normalTitleColor;

/// 选中标题颜色
@property (nonatomic)UIColor *selectedTitleColor;

/// 标签显示label
@property (nonatomic) UILabel *titleLabel;


/// 取值范围 -1.0~1.0
/// 0.0 表示选中状态，-1.0 和 +1.0 表示普通状态
/// (-1.0, 0.0) 和 (0.0, +1.0) 开区间表示过渡状态
@property (nonatomic) CGFloat gradient;
@end
