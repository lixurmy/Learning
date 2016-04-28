//
//  LoopScrollView.h
//  LoopScrollView
//
//  Created by 臧金晓 on 8/18/15.
//  Copyright (c) 2015 臧金晓. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoopScrollItem : NSObject

@end

@interface LoopScrollCell : UIControl

@property (nonatomic, weak) LoopScrollItem *cellItem;

@end

@interface LoopScrollView : UIScrollView

@property (nonatomic, assign) NSTimeInterval inteval;

@property (nonatomic, readonly) LoopScrollItem *currentItem;

@property (nonatomic, strong) NSArray *items;

@property (nonatomic, strong) Class loopCellClass;

@property (nonatomic, assign) BOOL showing;

@end
