//
//  AlbumFlowLayout.m
//  BabyGems
//
//  Created by Bobby Ren on 12/15/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import "AlbumFlowLayout.h"
#import "LSCollectionViewLayoutHelper.h"

@implementation AlbumFlowLayout
{
    LSCollectionViewLayoutHelper *_layoutHelper;
}

- (LSCollectionViewLayoutHelper *)layoutHelper
{
    if(_layoutHelper == nil) {
        _layoutHelper = [[LSCollectionViewLayoutHelper alloc] initWithCollectionViewLayout:self];
    }
    return _layoutHelper;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.layoutHelper modifiedLayoutAttributesForElements:[super layoutAttributesForElementsInRect:rect]];
}

- (CGSize)collectionViewContentSize
{
    // Only support single section for now.
    // Only support Horizontal scroll
    NSUInteger sections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    CGSize canvasSize = _appDelegate.window.bounds.size;
    CGSize contentSize = canvasSize;
    contentSize.height = [self offsetForSection:sections];

    return contentSize;
}

#if 0
// not used - use LSCollectionViewHelper
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes * attr = [super layoutAttributesForItemAtIndexPath:indexPath];
    attr.frame = [self frameForItemAtIndexPath:indexPath];
    return attr;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray * attrs = [NSMutableArray array];
    NSInteger sections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    for (NSUInteger section = 0; section < sections; ++section)
    {
        NSInteger rows = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:section];
        for (int row = 0; row < rows; row++) {
            UICollectionViewLayoutAttributes * attr = nil;
            NSIndexPath * idxPath = [NSIndexPath indexPathForRow:row inSection:section];
            CGRect itemFrame = [self frameForItemAtIndexPath:idxPath];
            if (CGRectIntersectsRect(itemFrame, rect))
            {
                attr = [self layoutAttributesForItemAtIndexPath:idxPath];
                [attrs addObject:attr];
            }
        }
    }

    return attrs;
}

- (CGRect)frameForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize canvasSize = _appDelegate.window.bounds.size;

    NSUInteger rowCount = (canvasSize.height - self.itemSize.height) / (self.itemSize.height + self.minimumInteritemSpacing) + 1;
    NSUInteger columnCount = (canvasSize.width - self.itemSize.width) / (self.itemSize.width + self.minimumLineSpacing) + 1;

    NSUInteger page = indexPath.row / (rowCount * columnCount);
    NSUInteger remainder = indexPath.row - page * (rowCount * columnCount);
    NSUInteger row = remainder / columnCount;
    NSUInteger column = remainder - row * columnCount;

    CGRect cellFrame = CGRectZero;
    cellFrame.origin.x = column * (self.itemSize.width + self.minimumLineSpacing);
    cellFrame.origin.y = row * (self.itemSize.height + self.minimumInteritemSpacing) + self.sectionInset.top;
    cellFrame.size.width = self.itemSize.width;
    cellFrame.size.height = self.itemSize.height;

//     NSLog(@"section %d index %d row %d col %d page %d", indexPath.section, indexPath.row, row, column, page);

    cellFrame.origin.x += page * (self.itemSize.width+self.minimumInteritemSpacing) + self.sectionInset.left;
    cellFrame.origin.y += [self offsetForSection:indexPath.section];

    return cellFrame;
}
#endif

#define CELLS_PER_ROW 3
#define BORDER_PADDING 5
#define HEADER_HEIGHT 5
-(CGSize)itemSize {
    return CGSizeMake((_appDelegate.window.bounds.size.width - [self sectionInset].left - [self sectionInset].right - (CELLS_PER_ROW-1)*[self minimumInteritemSpacing]) /CELLS_PER_ROW, 165);
}

-(int)headerHeight {
    return HEADER_HEIGHT;
}

-(CGFloat)minimumInteritemSpacing {
    return 1;
}

-(CGFloat)minimumLineSpacing {
    return 10;
}

-(UIEdgeInsets)sectionInset {
    float top = 0;
    float bottom = 0;
    float left = BORDER_PADDING;
    float right = left;
    return UIEdgeInsetsMake(top, left, bottom, right);
}

-(float)offsetForSection:(int)section {
    float offset = [self headerHeight];
    if (section == 0) {
        return offset;
    }
    offset += [self offsetForSection:section-1];
    NSInteger cells = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:section-1];
    int rows = ceil((float)cells / CELLS_PER_ROW);
    offset += rows * [self itemSize].height;

    NSLog(@"Offset for section %d offset: %f cells %d rows %d", section, offset, cells, rows);
    return offset;
}

@end
