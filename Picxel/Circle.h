//
//  Circle.h
//  Picxel
//
//  Created by Ali Haris on 7/1/14.
//  Copyright (c) 2014 Ali Haris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Circle : UIImageView {
    UIImage* backgroundImageName;
}

@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) UIView *picker;

@end
