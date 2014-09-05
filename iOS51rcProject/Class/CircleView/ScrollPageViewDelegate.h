//
//  ScrollPageViewDelegate.h
//  iOS51rcProject
//
//  Created by qlrc on 14-9-5.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ScrollPageViewDelegate <NSObject>
-(void)didScrollPageViewChangedPage:(NSInteger)aPage;
@end
