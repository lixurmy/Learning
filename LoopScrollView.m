//
//  LoopScrollView.m
//  LoopScrollView
//
//  Created by 臧金晓 on 8/18/15.
//  Copyright (c) 2015 臧金晓. All rights reserved.
//

#import "LoopScrollView.h"

@interface LoopScrollItem ()

@property (nonatomic, weak) LoopScrollItem *next;
@property (nonatomic, weak) LoopScrollItem *previous;
@property (nonatomic, weak) LoopScrollCell *cell;

@end

@implementation LoopScrollItem


@end

@implementation LoopScrollCell

- (void)setCellItem:(LoopScrollItem *)cellItem
{
    _cellItem.cell = nil;
    _cellItem = cellItem;
    _cellItem.cell = self;
}

@end

@interface LoopScrollView () <UIScrollViewDelegate>

@end

@implementation LoopScrollView

@synthesize currentItem = _currentItem;

- (instancetype)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		self.delegate = self;
	}
	return self;
}

- (void)setItems:(NSArray *)items
{
    _items = items;
    [self buildItems:items];
	[self setupCells];
}

- (void)setupCells
{
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	self.contentSize = CGSizeMake(self.width * 3, self.height);
	[self setContentOffset:CGPointMake(self.width, 0)];
    
    LoopScrollCell *cell = [[_loopCellClass alloc] init];
    [self addSubview:cell];
    cell.cellItem = _currentItem;
    
    LoopScrollCell *previousCell = [[_loopCellClass alloc] init];
    [self addSubview:previousCell];
    previousCell.cellItem = _currentItem.previous;
    
    LoopScrollCell *nextCell = [[_loopCellClass alloc] init];
    [self addSubview:nextCell];
    nextCell.cellItem = _currentItem.next;
	[self layout];
	
	
	@weakify(self);
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[[[RACSignal interval:self.inteval > 0 ? self.inteval : 5 onScheduler:[RACScheduler mainThreadScheduler]] takeUntil:[self rac_signalForSelector:@selector(setupCells)]] subscribeNext:^(id x) {
			if (self_weak_.showing)
			{
				[self_weak_ performSelector:@selector(autoScroll) withObject:nil afterDelay:0 inModes:@[NSDefaultRunLoopMode]];
			}
			YDLog(@"%d", self_weak_.showing);
		}];
	});
}

- (void)autoScroll
{
	[self setContentOffset:CGPointMake(self.contentOffset.x + self.width, 0) animated:YES];
}

- (void)next
{
	_currentItem.previous.cell.cellItem = _currentItem.next.next;
	[self willChangeValueForKey:@"currentItem"];
	_currentItem = _currentItem.next;
	[self didChangeValueForKey:@"currentItem"];
	[self layout];
}

- (void)previous
{
	_currentItem.next.cell.cellItem = _currentItem.previous.previous;
	[self willChangeValueForKey:@"currentItem"];
	_currentItem = _currentItem.previous;
	[self didChangeValueForKey:@"currentItem"];
	[self layout];
}

- (void)layout
{
	[_currentItem.previous.cell mas_remakeConstraints:^(MASConstraintMaker *make) {
		make.left.and.top.and.bottom.and.width.and.height.equalTo(self);
	}];
	[_currentItem.cell mas_remakeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(self);
		make.left.equalTo(_currentItem.previous.cell.mas_right);
		make.size.equalTo(_currentItem.previous.cell);
	}];
	[_currentItem.next.cell mas_remakeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(self);
		make.left.equalTo(_currentItem.cell.mas_right);
		make.size.equalTo(_currentItem.cell);
		make.right.equalTo(self);
	}];
}

- (void)buildItems:(NSArray *)items
{
    for (int i = 0; i < items.count; i ++)
    {
        if (i + 1 < items.count)
        {
            LoopScrollItem *item1 = items[i];
            LoopScrollItem *item2 = items[i + 1];
            item1.next = item2;
            item2.previous = item1;
        }
    }
    
    [items.firstObject setPrevious:items.lastObject];
    [items.lastObject setNext:items.firstObject];
	
	[self willChangeValueForKey:@"currentItem"];
    _currentItem = items.firstObject;
	[self didChangeValueForKey:@"currentItem"];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self process:scrollView];
}

- (void)process:(UIScrollView *)scrollView
{
	if (scrollView.contentOffset.x < self.width / 2.0)
	{
		[self previous];
		scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x + scrollView.width, 0);
	}
	else if (scrollView.contentOffset.x > self.width * 1.5)
	{
		[self next];
		scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x - scrollView.width, 0);
	}
}

@end
