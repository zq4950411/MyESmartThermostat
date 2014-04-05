//
//  LoadMoreTableFooterView.h
//
//  Created by Ye Dingding on 10-12-24.
//  Copyright 2010 Intridea, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


#import "LoadMoreTableFooterView.h"


#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f
#define DIFFERENTENCE (self.frame.size.height - 60)//300 //260
#define DRAG_HEIGHT 30

@interface LoadMoreTableFooterView (Private)
- (void)setState:(LoadMoreState)aState;
@end

@implementation LoadMoreTableFooterView

@synthesize delegate=_delegate;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 20.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont boldSystemFontOfSize:15.0f];
		label.textColor = TEXT_COLOR;
		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		[self addSubview:label];
		_statusLabel=label;
		[label release];
				
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		view.frame = CGRectMake(150.0f, 20.0f, 20.0f, 20.0f);
		[self addSubview:view];
		_activityView = view;
		[view release];
		self.hidden = NO;
		
		[self setState:LoadMoreNormal];
    }
	
    return self;	
}


#pragma mark -
#pragma mark Setters

- (void)setState:(LoadMoreState)aState{	
	switch (aState) {
		case LoadMorePulling:
			_statusLabel.text = @"释放加载更多...";//NSLocalizedString(@"Release to load more...", @"Release to load more");
			break;
		case LoadMoreNormal:
			_statusLabel.text = @"下拉加载更多...";//NSLocalizedString(@"Load More...", @"Load More");
			_statusLabel.hidden = NO;
			[_activityView stopAnimating];
			break;
		case LoadMoreLoading:
			_statusLabel.hidden = YES;
			[_activityView startAnimating];
			break;
		default:
			break;
	}
	
	_state = aState;
}


#pragma mark -
#pragma mark ScrollView Methods

- (void)loadMoreScrollViewDidScroll:(UIScrollView *)scrollView 
{
    CGSize tableViewSize = scrollView.bounds.size;
    CGSize contentSize = scrollView.contentSize;
    CGPoint offset = scrollView.contentOffset;
    
    //NSLog(@"ScrollView did scroll  contentOffsetY = %f, contentSizeHeight = %f,frameSize.height = %f",scrollView.contentOffset.y,scrollView.contentSize.height,scrollView.frame.size.height);
    
    if (offset.y < 0) 
    {
        return ;
    }
	if (_state == LoadMoreLoading) 
    {
		scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 60.0f, 0.0f);
	}
    else if (scrollView.isDragging) 
    {
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(loadMoreTableFooterDataSourceIsLoading:)]) 
        {
			_loading = [_delegate loadMoreTableFooterDataSourceIsLoading:self];
		}
		       
        if (contentSize.height <= tableViewSize.height)
        {
            if (offset.y < DRAG_HEIGHT)
            {
                self.hidden = NO;
                
                CGRect selfFrame = self.frame;
                selfFrame.origin.y = tableViewSize.height;
                self.frame = selfFrame;
            }
            //滑到了底部
            else if (offset.y >= DRAG_HEIGHT) 
            {
                if (_state == LoadMoreNormal && !_loading) 
                {
                    CGRect selfFrame = self.frame;
                    selfFrame.origin.y = tableViewSize.height;
                    self.frame = selfFrame;
                    
                    [self setState:LoadMorePulling];
                }
            }
            else
            {
                if (_state == LoadMorePulling && !_loading) 
                {
                    [self setState:LoadMoreNormal];
                }
            }
        }
        else
        {
            if (offset.y - contentSize.height + tableViewSize.height < DRAG_HEIGHT)
            {
                self.hidden = NO;
                
                CGRect selfFrame = self.frame;
                selfFrame.origin.y = contentSize.height;
                self.frame = selfFrame;
            }
            //滑到了底部
            else if (offset.y - contentSize.height + tableViewSize.height - DRAG_HEIGHT >= 0)
            {
                if (_state == LoadMoreNormal && !_loading) 
                {
                    CGRect selfFrame = self.frame;
                    selfFrame.origin.y = contentSize.height;
                    self.frame = selfFrame;
                    
                    [self setState:LoadMorePulling];
                }
            }
            else 
            {
                if (_state == LoadMorePulling && !_loading) 
                {
                    [self setState:LoadMoreNormal];
                }
            }
        }
		
		if (scrollView.contentInset.bottom != 0) 
        {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
	}
}

- (void)loadMoreScrollViewDidEndDragging:(UIScrollView *)scrollView 
{
    CGSize tableViewSize = scrollView.bounds.size;
    CGSize contentSize = scrollView.contentSize;
    CGPoint offset = scrollView.contentOffset;
    //NSLog(@"ScrollView did end drag  contentOffsetY = %f, contentSizeHeight = %f,frameSize.height = %f",scrollView.contentOffset.y,scrollView.contentSize.height,scrollView.frame.size.height);
	
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(loadMoreTableFooterDataSourceIsLoading:)]) 
    {
		_loading = [_delegate loadMoreTableFooterDataSourceIsLoading:self];
	}
    
    BOOL b = NO;
    if (contentSize.height <= tableViewSize.height)
    {
        if (offset.y >= DRAG_HEIGHT) 
        {
            if (!_loading) 
            {
                b = YES;
            }
        }
    }
    else
    {
        if (offset.y - contentSize.height + tableViewSize.height - DRAG_HEIGHT >= 0)
        {
            if (!_loading) 
            {
                b = YES;
            }
        }
    }
    
    if (b) 
    {
        if ([_delegate respondsToSelector:@selector(loadMoreTableFooterDidTriggerRefresh:)]) 
        {
            [_delegate loadMoreTableFooterDidTriggerRefresh:self];
        }
        
        [self setState:LoadMoreLoading];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 60.0f, 0.0f);
        [UIView commitAnimations];
    }
}

- (void)loadMoreScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView 
{	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[self setState:LoadMoreNormal];
	self.hidden = NO;
    if (scrollView.contentInset.bottom != 0) 
    {
        scrollView.contentInset = UIEdgeInsetsZero;
    }
    
    self.hidden = YES;
}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	_delegate=nil;
	_activityView = nil;
	_statusLabel = nil;
    [super dealloc];
}


@end
