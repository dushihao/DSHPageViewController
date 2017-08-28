//
//  SHCollectionView.m
//  DSHPageViewController
//
//  Created by shihao on 2017/8/23.
//  Copyright © 2017年 shihao. All rights reserved.
//

#import "SHCollectionView.h"
#import "SHCollectionViewCell.h"

@implementation SHCollectionView

- (instancetype)initWithReuseIdentifier:(NSString *)identifier{
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 7.5, 0, 7.5);
    
    self = [super initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    if (self) {
        _flowLayout = flowLayout;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.backgroundColor = [UIColor lightGrayColor];
        [self registerClass:[SHCollectionViewCell class] forCellWithReuseIdentifier:identifier];
    }
    return self;
}

- (void)setContentInset:(UIEdgeInsets)contentInset{
    // 避免 UIViewController 的 automaticallyAdjustsScrollViewInsets 属性影响 contentInset 。
}

@end
