//
//  SHCollectionViewCell.m
//  DSHPageViewController
//
//  Created by shihao on 2017/8/23.
//  Copyright © 2017年 shihao. All rights reserved.
//

#import "SHCollectionViewCell.h"

@interface SHCollectionViewCell (){
    CGAffineTransform _transform;
}
@property (nonatomic) UIView *bgView;

@end

@implementation SHCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        // self.backgroundColor = [UIColor colorWithRed:arc4random()%256/255.0f green:arc4random()%256/255.0f blue:arc4random()%256/255.0f alpha:1];
        
        // 遮罩文本label
        UILabel *lab = [[UILabel alloc]initWithFrame:frame];
        
        lab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:lab];;
        _titleLabel = lab;
        self.maskView = _titleLabel;
        
        // contentView
        UIView *bgView = [[UIView alloc]init];
        [self.contentView addSubview:bgView];
        _bgView = bgView;
        
        _gradient = -1.0;
        _titleScale = 1.0;
        _transform = CGAffineTransformIdentity;
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self sh_updateBackGroundViewFrame];
}

#pragma mark - 重写 set 方法  设置外观

- (void)setTitleFont:(UIFont *)titleFont{
    
    _titleFont = titleFont;
    _titleLabel.font = titleFont;
}

- (void)setTitleScale:(CGFloat)titleScale{
    
    titleScale = fmax(1.0, titleScale);
    if (titleScale == self.titleScale) {
        return;
    }
    _titleScale = titleScale;
    
    [self sh_updateTransform];
    [self sh_updateBackGroundViewFrame];
}

- (void)setNormalTitleColor:(UIColor *)normalTitleColor{
    
    _normalTitleColor =  normalTitleColor;
    self.backgroundColor = normalTitleColor;
}

- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor{
    
    _selectedTitleColor = selectedTitleColor;
    self.bgView.backgroundColor = selectedTitleColor;
}

- (void)setTitle:(NSString *)title{
    
    _title = title;
    _titleLabel.text = title;
}

- (void)setTitleSize:(CGSize)titleSize{
    
    _titleSize = titleSize;
    [self sh_updateMaskAndBackGroundView];
}

// 设置选中状态
- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    
    //更新标题大小 颜色
    [self sh_updateTransformForSelected:selected animated:YES];
    
    self.gradient = (selected ? 0 : 1);
}

// set backgroud gradient
- (void)setGradient:(CGFloat)gradient{
    
    gradient = fmax(-1.0, fmin(gradient, +1.0));
    if (gradient == _gradient) {
        return;
    }
    _gradient = gradient;
    
    [self sh_updateTransform];
    [self sh_updateMaskAndBackGroundView];
}

#pragma mark - 私有方法

- (void)sh_updateTransformForSelected:(BOOL)selected animated:(BOOL)animated{
    
    //如果标题已经变大/变小，不在进行动画处理
    if (self.bgView.center.x == self.bounds.size.width /2) return;
    
    self.titleLabel.transform = CGAffineTransformIdentity;
    self.bgView.alpha = 0;

    [UIView animateWithDuration:animated ? .3: 0 animations:^{
        
        if (selected) {
            self.titleLabel.transform = CGAffineTransformMakeScale(self.titleScale, self.titleScale);
            self.bgView.alpha = 1;
        }else{
            self.titleLabel.transform = CGAffineTransformIdentity;
            // self.bgView.alpha = 0;
        }
    } completion:^(BOOL finished) {
        self.bgView.alpha = 1 ;
    }];
}

- (void)sh_updateTransform{
    
    CGFloat scale = self.titleScale - (self.titleScale - 1) * fabs(self.gradient) ;
    _transform = CGAffineTransformMakeScale(scale, scale);
}

- (void)sh_updateMaskAndBackGroundView{
    
    [self sh_updateMaskLabelFrame];
    [self sh_updateBackGroundViewFrame];
}

- (void)sh_updateMaskLabelFrame{
    
    self.titleLabel.transform = CGAffineTransformIdentity;
    self.titleLabel.frame = self.bounds;
    self.titleLabel.transform  = _transform;
}

- (void)sh_updateBackGroundViewFrame{
    
    self.bgView.transform = CGAffineTransformIdentity;
    self.bgView.frame = (CGRect){
        .size = self.titleSize
    };
    self.bgView.center = (CGPoint){
        CGRectGetMidX(self.bounds) + self.gradient * self.titleSize.width,
        CGRectGetMidY(self.bounds)
    };
    
    self.bgView.transform = _transform;
}

#pragma mark - 复用清理

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    _gradient = -1.0;
    _titleScale = 1.0;
    _transform = CGAffineTransformIdentity;
    
   // self.bgView.frame = CGRectZero;
}
@end
