//
//  MyEDoughnutView.m
//  MyE
//
//  Created by Ye Yuan on 2/7/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEDoughnutView.h"
#import <QuartzCore/QuartzCore.h>
#import "MyESectorView.h"
#import "MyEUtil.h"
#import "MyETodayScheduleController.h"
#import "MyEScheduleTodayData.h"

#include <math.h>
static inline double radians (double degrees) {return degrees * M_PI/180;}

// 用于指定某个sector是处于一个时段的顺时针方向的第一个，中间，还是最后一个位置， 或者是孤立的半点sector构成的时段。
typedef enum {
    SectorPositionTypeFirst,
    SectorPositionTypeMiddle,
    SectorPositionTypeLast,
    SectorPositionTypeSingle
} SectorPositionType;


@interface MyEDoughnutView(PrivateMethods)
- (void)_initModeIdArray;

//根据modeIdArray和modeIdColorDictionary取得当前的sectorColors数组,由48个颜色对象构成
- (NSMutableArray *)_getSectorColorArray;

//sector view 构建函数
- (MyESectorView *)_createSectorViewAtIndex:(int)index fillColor:(UIColor *)fillColor isFlashing:(BOOL)isFlashing;

//- (void)_drawTickContents;

//绘制全部内容的函数
- (void)_drawContents;

// 返回位于当前触摸位置处的sector的序号
- (int)_sectorIdOnTouchedLocation:(CGPoint)touchLocation;

// 当外部类更新了本类的modeIdArray或modeColorDirection时，就需要调用下面函数更新sector显示
- (void)_createOrUpdateSectorColors;


// 用于指定某个sector是处于一个时段的顺时针方向的第一个，中间，还是最后一个位置。
- (SectorPositionType)_sectorPositionTypeOfSectorId:(NSInteger)sectorId;

//在Today模块，用户tap在一个时段sector上，并准备拖动改变时段的开始或结束时刻，就要调用下面函数，
//该函数返回所允许用户触摸改变的最早最前的sector和所允许的改变的sector的数目
//在Weekly模块，这个变量的分量分别取0和48，表示允许用户用当前模式修改全部48个sector
- (NSRange)_changeableSectorRangeForSelectedSector:(NSInteger)selectedSectorId;

// 私有函数，用于判定是否涂抹以及实现当前涂抹的动作。仅用于在手指触摸sector时Touch事件的Move、End阶段
- (BOOL)_paintingSectorWithStartSectorId:(uint)sectorId currentSectorId:(NSInteger)csid;


// tap响应函数
- (void)_singleTaped:(id)sender;
- (void)_doubleTaped:(id)sender;
@end







@implementation MyEDoughnutView(PrivateMethods)

#pragma mark -
#pragma mark 和模式相关的方法
// 注意，self.modeIdArray和_modeIdColorDictionary应该由外部传入，这个函数仅在为初始化这个两变量时才有用。
- (void)_initModeIdArray
{
    if(self.modeIdArray == nil)
        self.modeIdArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 8; i++) {
        [self.modeIdArray addObject:[NSNumber numberWithInt:1]];
    }
    for (int i = 8; i < 16; i++) {
        [self.modeIdArray addObject:[NSNumber numberWithInt:2]];
    }
    for (int i = 16; i < 24; i++) {
        [self.modeIdArray addObject:[NSNumber numberWithInt:3]];
    }
    for (int i = 24; i < 32; i++) {
        [self.modeIdArray addObject:[NSNumber numberWithInt:4]];
    }
    for (int i = 32; i < 40; i++) {
        [self.modeIdArray addObject:[NSNumber numberWithInt:5]];
    }
    for (int i = 40; i < NUM_SECTOR; i++) {
        [self.modeIdArray addObject:[NSNumber numberWithInt:3]];
    }
    
    self.delegate.currentSelectedModeId = 1;
}

//根据modeIdArray取得当前的sectorColors数组
- (NSMutableArray *)_getSectorColorArray
{
    NSMutableArray *sectorColors = [NSMutableArray array];
    for (int i = 0; i < NUM_SECTOR; i++) {
        NSInteger modeId = [[self.modeIdArray objectAtIndex:i] intValue];//这里取得的modeId不知为何不是NSString* 类型了，所以导致下面的词典取值不能取到。所以在下面的词典取值时，重新构造了一次NSString类型的key
        UIColor *color = [self.delegate colorForModeId:modeId];
        
        //===========?????????????????????????
        //color 有可能为nil，主要是在delegate初始化时，会初始化doughnut view，此时还没从服务器取得schedule数据，从而导致从delegate取得颜色为空。
        if(color == nil)
            color = [UIColor grayColor];
        [sectorColors addObject:color];
        
    }
    return sectorColors;
}

// 返回位于当前触摸位置处的sector的序号
- (int)_sectorIdOnTouchedLocation:(CGPoint)touchLocation
{
    // -1 表示当前不在任何一个sectorView上
    int i;
    for (i=0; i<NUM_SECTOR; i++) {
        MyESectorView *sectorView = [_sectorViews objectAtIndex:i];
        CGPoint ap = [self convertPoint:touchLocation toView:sectorView];
        if ([sectorView pointInside:ap]) {
            return i;
        }
    }
    return -1;
}

// 用于计算某个sector是处于一个时段的顺时针方向的第一个，中间，还是最后一个位置。
- (SectorPositionType)_sectorPositionTypeOfSectorId:(NSInteger)sectorId {
    NSInteger currentModeId = [[self.modeIdArray objectAtIndex:sectorId] intValue];
    NSInteger prevModeId = -1;//初始化为一个不存在的modeId
    NSInteger nextModeId = -1;//初始化为一个不存在的modeId
    NSString *hold = [self.holdArray objectAtIndex:sectorId];
    if ([hold caseInsensitiveCompare:@"none"] != NSOrderedSame)// 如果当前涂抹的sector被hold了，就不允许拖动
        return SectorTouchTypeDisable;
    if (sectorId == 0 ) {
        nextModeId = [[self.modeIdArray objectAtIndex:(sectorId + 1)] intValue];
        if(currentModeId == nextModeId)
            return SectorPositionTypeFirst;
        else return  SectorPositionTypeSingle;
    } else if (sectorId == NUM_SECTOR - 1 ) {
        prevModeId = [[self.modeIdArray objectAtIndex:(sectorId - 1)] intValue];
        if(currentModeId == prevModeId)
            return SectorPositionTypeLast;
        else return  SectorPositionTypeSingle;
    } else {
        nextModeId = [[self.modeIdArray objectAtIndex:(sectorId + 1)] intValue];
        prevModeId = [[self.modeIdArray objectAtIndex:(sectorId - 1)] intValue];
        if( currentModeId != prevModeId && currentModeId != nextModeId)
            return SectorPositionTypeSingle;
        if( currentModeId != prevModeId ){
            NSString *hold = [self.holdArray objectAtIndex:(sectorId + 1)];
            if ([hold caseInsensitiveCompare:@"none"] != NSOrderedSame) { // 如果前一sector属于不同时段，并且前一时段被hold，就不允许拖动
                return SectorTouchTypeDisable;
            } else 
                return SectorPositionTypeFirst;
        }
        if( currentModeId != nextModeId ){
             NSString *hold = [self.holdArray objectAtIndex:(sectorId - 1)];
            if ([hold caseInsensitiveCompare:@"none"] != NSOrderedSame) {// 如果后一sector属于不同时段，并且后一时段被hold，就不允许拖动

                return SectorTouchTypeDisable;
            } else
                return SectorPositionTypeLast;
        }
        return SectorPositionTypeMiddle;
        
    }
    
}

//用户tap在一个时段sector上，并准备拖动改变时段的开始或结束时刻，就要调用下面函数，
//该函数返回所允许用户触摸改变的最早最前的sector和所允许的改变的sector的数目
- (NSRange)_changeableSectorRangeForSelectedSector:(NSInteger)selectedSectorId
{
    
    int location = 0;
    int length = 0;
    if (selectedSectorId < 0 || selectedSectorId >= NUM_SECTOR) {
        return NSMakeRange(location, length);
    }
    
    // 对当前选择的sector，向前寻找前一时段的第二个sector，向后寻找下一时段的倒数第二个sector
    NSInteger sidOfPrevPeriod = -1;//前一时段的第一个sector的id
    NSInteger eidOfPrevPeriod = -1;//前一时段的最后一个sector的id
    NSInteger modeIdOfPrevPeriod; // 前一时段的mode id
    NSInteger sidOfNextPeriod = -1;//后一时段的第一个sector的id
    NSInteger eidOfNextPeriod = -1;//后一时段的最后一个sector的id
    NSInteger modeIdOfNextPeriod; // 后一时段的mode id
    NSInteger modeIdOfSelectedSector = [[self.modeIdArray objectAtIndex:selectedSectorId] intValue];// 当前手指按下去的sector的mode id
    
    int i;
    // 向前搜索
    for (i = selectedSectorId; i >= 0; i--) {
        if(modeIdOfSelectedSector != [[self.modeIdArray objectAtIndex:i] intValue] )
        {// 碰到前面一个时段了
            eidOfPrevPeriod = i;
            modeIdOfPrevPeriod = [[self.modeIdArray objectAtIndex:i] intValue];
            break;
        }
    }
    if(eidOfPrevPeriod > -1) // 如果找到前一个时段的最后一个sector
    {
        for (i = eidOfPrevPeriod; i >= 0; i--) {
            if(modeIdOfPrevPeriod != [[self.modeIdArray objectAtIndex:i]intValue])
            {// 碰到前面一个时段的开始位置之前一个sector了
                sidOfPrevPeriod = i +1;
                break;
            }
        }
        if(sidOfPrevPeriod > -1)// 如果找到前一个时段的第一个sector
        {
            //设置允许改变的开始位置为前一时段的开始sector的下一个sector
            location = sidOfPrevPeriod + 1;
        }else if(i < 0) // 如果向前遍历完了，i已经变成-1了，表面0就是前一时段的开始的sector id
        {
            //设置允许改变的开始位置的sector id为1
            location = 1;
        }
    } else { 
        // 如果没有找到前一个时段的最后一个sector，表明手指按下去的sector所在时段就是第一个时段
        // 那么设置允许被改变的的开始位置就是0，其实也可以排除本手指按下去的sector所在时段的所有sector
        location = 1;
    }
    
    // 向后搜索
    for (i = selectedSectorId; i < NUM_SECTOR; i++) {
        if(modeIdOfSelectedSector != [[self.modeIdArray objectAtIndex:i]intValue])
        {// 碰到前后面一个时段了
            sidOfNextPeriod = i;
            modeIdOfNextPeriod = [[self.modeIdArray objectAtIndex:i] intValue];
            break;
        }
    }
    if(sidOfNextPeriod > -1) // 如果找到后一个时段的第一个sector
    {
        for (i = sidOfNextPeriod; i < NUM_SECTOR; i++) {
            if(modeIdOfNextPeriod != [[self.modeIdArray objectAtIndex:i]intValue])
            {// 碰到前后一个时段的结束位置之后一个sector了
                eidOfNextPeriod = i -1;
                break;
            }
        }
        if(eidOfNextPeriod > -1)// 如果找到后一个时段的最后一个sector
        {
            //设置允许改变的结束位置为后一时段的结束sector的前一个sector，此处计算range长度
            length = eidOfNextPeriod - 1 - location;
        }else
            if(i > NUM_SECTOR -1) // 如果向后遍历完了，i已经变成48了，表明47就是后一时段的结束的sector id
            {
                //设置允许改变的结束位置的sector id为46，此处计算range长度
                length = NUM_SECTOR - 2  - location;
            }
    }else{ 
        // 如果没有找到前一个时段的最后一个sector，表面手指按下去的sector所在时段就是第一个时段
        // 那么设置允许被改变的的开始位置就是0，其实也可以排除本手指按下去的sector所在时段的所有sector
        length = NUM_SECTOR - 2   - location;
    }
    
    // 如果是Today模块，还需要对检查:本身这个sector是否被hold；允许范围内的个sector是否被hold，以及当前时刻的下一个半点之前的sector设置为不允许改变
    if (_scheduleType == SCHEDULE_TYPE_TODAY || _scheduleType == SCHEDULE_TYPE_NEXT24HRS)
    {
        //首先如果本身这个sector如果被hold，它的许可范围就不存在。
        if ([[self.holdArray objectAtIndex:selectedSectorId] caseInsensitiveCompare:@"none"] != NSOrderedSame) {
            location = 0;
            length = 0;
            return NSMakeRange(location, length);
        }
        // 再对设置为hold的sector都设置为不可改变
        int start = location;
        int end = location + length;
        for (i = start; i < end; i++) {
            if ([[self.holdArray objectAtIndex:i] caseInsensitiveCompare:@"none"] != NSOrderedSame) {
                location ++;
                length--;
            }
        }
        if (length <= 0) { // 表明整个范围的sector全部都是被hold了
            location = -1;
            length = 0;
        }
        
        // 如果当前sector早于当前时刻之前，其允许范围就不存在。
        if (selectedSectorId <= self.sectorIdSpaningCurrentTime) {
            location = -1;
            length = 0;
        }
        
        // 再对当前时刻的下一个半点sector之前的sector设置为不可改变
        if (location > -1 && length > 0) {
            start = location;
            end = location + length;
            for (i = start; i < end; i++) {
                if(i<=self.sectorIdSpaningCurrentTime + 1)
                {
                    location ++;
                    length --;
                }
            }
            if(length <= 0)//表明所有的有效的sector都在当前时刻之前
                location = -1;
        }
        
    }
    
//    NSLog(@"2222range.location = %i, length = %i", location, length);
    return NSMakeRange(location, length);
}


// 私有函数，用于判定是否涂抹以及实现当前涂抹的动作
//如果触摸过程真正地改变了Schedule，就返回YES，
//如果仅仅触摸了，但触摸过程并没满足触摸条件或者触摸在不可改变地sector上，这就实际上没有真正修改Schedule，那就返回NO
- (BOOL)_paintingSectorWithStartSectorId:(uint)sectorId currentSectorId:(NSInteger)csid {    
    //首先，如果当前触摸不在任何一个sector上，直接退出。这种情况不应出现，因为调用本函数之前，已经处理了。
    if(csid <0) {
        NSLog(@"没有触摸在sector上，退出");
        return NO;
    }
    if (csid == 0) {
        NSLog(@"-------跨过0点----------, _lastSectorViewIdTouched = %i",  _lastSectorViewIdTouched);
        self.sectorTouchType = SectorTouchTypeDisable;
    }
    ///today模块中，如果当前触摸到的sector的id小于当前时刻所在sector的下一个sector，就退出
    if (_scheduleType == SCHEDULE_TYPE_TODAY || _scheduleType == SCHEDULE_TYPE_NEXT24HRS) {
        NSString *hold = [self.holdArray objectAtIndex:sectorId];
        if ([hold caseInsensitiveCompare:@"None"] != NSOrderedSame) {
            NSLog(@"today|Next24Hrs模块中，如果当前触摸到的sector的hold不是None，就退出");
            return NO;
        }
        if (csid <= self.sectorIdSpaningCurrentTime + 1) {
            NSLog(@"today|Next24Hrs模块中，如果当前触摸到的sector的id小于当前时刻所在sector的下一个sector，就退出");
            return NO;
        }
    }
        
    // psid 是当前应该涂抹的最新的secotr id。由于目前的操作方式，当在手指拖动边界过程中，
    //如果手指按在时段A的边界，朝着时段A自己的中心拖动，设和时段A被拖动边界相邻的是时段B，
    // 就会用时段B的mode涂抹手指触摸经过的前一个sector，而不是手指当前所在的sector
    int psid = csid;
    
    NSRange changeableSectorRange = [self _changeableSectorRangeForSelectedSector:sectorId];

    // 首先如果是不允许触摸的情况就直接返回。
    if (self.sectorTouchType == SectorTouchTypeDisable) {
        NSLog(@"禁止触摸的类型，退出");
        return NO;
    } 
    // 下面处理拖动边界sector的情况。
    else if (self.sectorTouchType == SectorTouchTypeDraggingBorder) {
        //如果是在拖动边界，但当前sector和最后一次触摸的sector是同一个，也就是手指仍然在一个sector移动时调用此函数，就不进行拖动处理，直接退出
        if (_lastSectorViewIdTouched == csid) {
            //NSLog(@"手指停留在前一个sector上没有移动，退出");
            return NO;
        }
        // 处理从最后一个sector顺时针触摸移动到第一个sector的情况，此时设置禁止操作，并退出即可
        if (_lastSectorViewIdTouched == NUM_SECTOR - 1 && csid == 0) {
            NSLog(@"从最后一个sector顺时针触摸移动到第一个sector，退出");
            self.sectorTouchType = SectorTouchTypeDisable;
            return NO;
        }
        // 处理从第一个sector触摸移动到最后一个sector的情况，此时设置禁止操作，并退出即可
        if (_lastSectorViewIdTouched == 0 && csid == NUM_SECTOR - 1) {
            NSLog(@"从第一个sector触摸移动到最后一个sector，退出");
            self.sectorTouchType = SectorTouchTypeDisable;
            return NO;
        }
        // 需要处理从一个period的sector手指按下去，然后离开doughnut 上的 sector，然后哟直接进入到其他和离开的sector不相邻的任何一个sector的情况。此时直接退出，不再进行任何操作。
//        NSLog(@"csid = %i,  _lastSectorViewIdTouched = %i", csid , _lastSectorViewIdTouched);
        if ( abs( csid - _lastSectorViewIdTouched) > 1) {
            NSLog(@"从一个sector离开doughnut然后进入一个不相邻的sector，此操作不允许，退出");
            self.sectorTouchType = SectorTouchTypeDisable;
            return NO;
        }
        
        SectorPositionType position = [self _sectorPositionTypeOfSectorId:_lastSectorViewIdTouched];
        if( csid < _lastSectorViewIdTouched ) {//逆时针触摸
            // 处理从最后一个sector触摸移动到倒数第二个sector的情况，此时强制设置触摸位置为时段的开始sector
            if (_lastSectorViewIdTouched == NUM_SECTOR - 1 && csid == NUM_SECTOR - 2) {
                position = SectorPositionTypeFirst;
            }
            if (position == SectorPositionTypeSingle) {
                position = SectorPositionTypeFirst;
            }
            
            if (position == SectorPositionTypeFirst ) {// if the current sector is the first sector of the period
                // Comment 1: 计算允许的拖动范围，以前一次涂抹过的sector为标准计算，如果前一次拖动到边界了，
                // 就以边界沿着拖动方向向前的下一个sectorId的mode为准继续拖动。
                // 现在注释的目的是只允许以触摸的第一sectorId为准计算允许的范围，
                //其结果就是只能在当前时段的前后两个相邻时段里面进行拖动，不能影响到第三个时段。
                // 如果下句注释，原因见Comment 1
                changeableSectorRange = [self _changeableSectorRangeForSelectedSector:_lastSectorViewIdTouched+1];
                // 如果当准备要修改涂抹的sector(psid)不允许被改变，就返回。
                if (psid < changeableSectorRange.location || psid > changeableSectorRange.location + changeableSectorRange.length) {
                    NSLog(@"拖动边界 & 逆时针 & position first, 超出许可范围退出");
                    return NO;
                }

                self.delegate.currentSelectedModeId = [[self.modeIdArray objectAtIndex:_lastSectorViewIdTouched] intValue];
                NSLog(@"拖动边界 & 逆时针 & position First");
            } 
            if (position == SectorPositionTypeLast ){ // if the current sector is the last sector of the period
                psid = csid + 1;//允许涂抹的当前sid设置为比当前sid大1
                if (psid >= NUM_SECTOR) {
                    NSLog(@"拖动边界 & 逆时针 & position Last, psid>47超出范围退出");
                    return NO;
                }
                // 如果下句注释，原因见Comment 1
                changeableSectorRange = [self _changeableSectorRangeForSelectedSector:_lastSectorViewIdTouched+1];
                // 如果当准备要修改涂抹的sector(psid)不允许被改变，就返回。
                if (psid < changeableSectorRange.location || psid > changeableSectorRange.location + changeableSectorRange.length) {
                    NSLog(@"拖动边界 & 逆时针 & position Last, 超出许可范围退出");
                    return NO;
                }
                self.delegate.currentSelectedModeId = [[self.modeIdArray objectAtIndex:_lastSectorViewIdTouched+1] intValue];
                NSLog(@"拖动边界 & 逆时针 & position Last");
            }
        } else if( csid > _lastSectorViewIdTouched ) {//顺时针触摸
            // 处理从第一个sector触摸移动到第二个sector的情况，此时强制设置触摸位置为时段的最后sector
            if (_lastSectorViewIdTouched == 0 && csid ==1) {
                position = SectorPositionTypeLast;
            }
            if (position == SectorPositionTypeSingle) {
                position = SectorPositionTypeLast;
            }
            
            if (position == SectorPositionTypeFirst ) {// if the current sector is the first sector of the period
                psid = csid - 1;//允许涂抹的当前sid设置为比当前sid小1
                if (psid < 0) {
                    NSLog(@"拖动边界 & 顺时针 & position First, psid<0超出范围退出");
                    return NO;
                }
                
                // 如果下句注释，原因见Comment 1
                changeableSectorRange = [self _changeableSectorRangeForSelectedSector:_lastSectorViewIdTouched - 1];
                // 如果当准备要修改涂抹的sector(psid)不允许被改变，就返回。
                if (psid < changeableSectorRange.location || psid > changeableSectorRange.location + changeableSectorRange.length) {
                    NSLog(@"拖动边界 & 顺时针 & position First, 超出许可范围退出");
                    return NO;
                }
                self.delegate.currentSelectedModeId = [[self.modeIdArray objectAtIndex:_lastSectorViewIdTouched-1] intValue];
                
                NSLog(@"拖动边界 & 顺时针 & position First");
            }
            if (position == SectorPositionTypeLast ) {// if the current sector is the last sector of the period
                // 如果下句注释，原因见Comment 1
                changeableSectorRange = [self _changeableSectorRangeForSelectedSector:_lastSectorViewIdTouched-1];
                // 如果当准备要修改涂抹的sector(psid)不允许被改变，就返回。
                if (psid < changeableSectorRange.location || psid > changeableSectorRange.location + changeableSectorRange.length) {
                    NSLog(@"拖动边界 & 顺时针 & position last, 超出许可范围退出");
                    return NO;
                }
                self.delegate.currentSelectedModeId = [[self.modeIdArray objectAtIndex:_lastSectorViewIdTouched] intValue];
                NSLog(@"拖动边界 & 顺时针 & position Last");
            }
        }
    } 
    // 下面处理涂抹的情况。
    else if (self.sectorTouchType == SectorTouchTypePainting) { 
    }
    
    // 如果当准备要修改涂抹的sector(psid)不允许被改变，就返回。
    if (psid < changeableSectorRange.location || psid > changeableSectorRange.location + changeableSectorRange.length) {
        return NO;
    }
    
    //接下来，处理从触摸开始的Sector到当前sector进行mode涂色。
    //规定在触摸开始的sector和当前被触摸的sector之间取间距较小的一个方向进行涂色
    int i;
    
    
    //按照顺时针方向旋转标记的需要连续涂色的开始sector id和结束sector id，仅用于绘制时使用,
    int sid, eid;
    if(_lastSectorViewIdTouched > psid)
    {
        //如果从最后涂色的sector顺时针到达当前sector的间距小于NUM_SECTOR/2 = 24,刚好是Doughnut的半圈
        if (_lastSectorViewIdTouched - psid > NUM_SECTOR/2)
        {
            sid = _lastSectorViewIdTouched;
            eid = psid;
        } else
        {
            eid = _lastSectorViewIdTouched;
            sid = psid;
        }
    }else{//否则正常处理
        if ( psid - _lastSectorViewIdTouched > NUM_SECTOR/2 )
        {
            eid = _lastSectorViewIdTouched;
            sid = psid;
        }else
        {
            sid = _lastSectorViewIdTouched;
            eid = psid;
        }
    }
    
    //如果开始的sector id大于当前sector id，表示用户触摸动作跨过了0分界线，需要分两个部分处理
    if(eid < sid)
    {
        // 第一部分，从当前id到最后的47号sector进行涂色
        for (i = sid; i < NUM_SECTOR; i++) {
            [self.modeIdArray replaceObjectAtIndex:i withObject:[NSNumber numberWithInt: self.delegate.currentSelectedModeId]];
            MyESectorView *sectorView = [_sectorViews objectAtIndex:i];
            sectorView.fillColor = [self.delegate currentModeColor];
        }
        //第二部分，从0号id开始，到触摸开始的sector
        for (i = 0; i <= eid; i++) {
            [self.modeIdArray replaceObjectAtIndex:i withObject:[NSNumber numberWithInt: self.delegate.currentSelectedModeId]];
            MyESectorView *sectorView = [_sectorViews objectAtIndex:i];
            sectorView.fillColor = [self.delegate currentModeColor];
        }
        NSLog(@"分段涂抹   sid = %i, eid = %i",sid, eid);
    }else{//否则正常处理
        for (i = sid; i <= eid; i++) {
            [self.modeIdArray replaceObjectAtIndex:i withObject:[NSNumber numberWithInt: self.delegate.currentSelectedModeId]];
            MyESectorView *sectorView = [_sectorViews objectAtIndex:i];
            sectorView.fillColor = [self.delegate currentModeColor];
        }
        NSLog(@"正常涂抹   sid = %i, eid = %i",sid, eid);
    }
    return YES;
}



#pragma mark -
#pragma mark SectorView的构建方法
// 用给定颜色、是否闪烁等属性创建序号为index的sector
- (MyESectorView *)_createSectorViewAtIndex:(int)index fillColor:(UIColor *)fillColor isFlashing:(BOOL)isFlashing
{
    
    CGRect sectorFrame;
    MyESectorView *sectorView;
    CGRect bounds = [self bounds];
    CGPoint center = CGPointMake(bounds.size.width / 2.0, bounds.size.height / 2.0);
    
    float radius = MIN(bounds.size.width/2, bounds.size.height/2);//同心圆外圆外半径
    float perimeter = 2.0 * M_PI * radius; //同心圆外圆的周长
    float sectorWidth = perimeter / NUM_SECTOR; // 每个sectorView所在矩形的宽度
    float sectorHeight = sectorWidth * SECTOR_ASPECT_RATIO; // 每个sectorView所在矩形的高度，取为宽度的SECTOR_ASPECT_RATIO倍
    
    
    double angle = index * ALPHA;
    
    //计算扇形梯形在本View容器上的位置
    sectorFrame = CGRectMake(center.x - sectorWidth/2+ (radius - sectorWidth * SECTOR_ASPECT_RATIO/2)*cos(angle - M_PI_2), 
                             center.y - sectorWidth * SECTOR_ASPECT_RATIO/2 + (radius - sectorWidth * SECTOR_ASPECT_RATIO/2)*sin(angle - M_PI_2), 
                             sectorWidth, 
                             sectorHeight);
    
    //下面的坐标都是以MyESectorView的UIKit坐标系为默认坐标系
    sectorView =[[MyESectorView alloc] 
                 initWithFrame:sectorFrame 
                 fillColor:fillColor 
                 radiusOfCC:radius 
                 angle:angle
                 uid:index
                 isFlashing:isFlashing];
    //原来旋转扇形矩形的默认0度为和X轴重叠，现在旋转为以Y轴为0度
    CGAffineTransform xform = CGAffineTransformMakeRotation(angle);
    sectorView.transform = xform;
    
    // 添加子View的阴影,每个sector的X方向阴影为0
    [[sectorView layer] setShadowOffset:CGSizeMake(0*sin(angle+M_PI_4), 3*cos(angle+M_PI_4))];
    [[sectorView layer] setShadowRadius:1];
    [[sectorView layer] setShadowOpacity:1]; 
    [[sectorView layer] setShadowColor:[UIColor grayColor].CGColor];
    
    sectorView.delegate = self;
    
    return sectorView;
    
}
- (void)_drawContents
{
    if(_sectorViews == nil)
        _sectorViews = [[NSMutableArray alloc] init];
    
    //如果这两个对象没有被初始化，就调用自带的初始化程序
    if( self.modeIdArray == nil || [self.modeIdArray count] == 0)
        [self _initModeIdArray];
    
    
    [self _createOrUpdateSectorColors];
    
    // 旋转半个ALPHA角度，使得0点分割线垂直，相应地MyESectorView中每个sector上的文字需要进行旋转
    CGAffineTransform xform = CGAffineTransformMakeRotation( ALPHA/2.0);
    self.transform = xform;
    
    
    
    
    
    //=======================创建圆环蒙板，绘制在一个UIGraphicsBeginImageContext上，最后再作为image绘制到CALayer上，再加入本View===========
    CGRect bounds = [self bounds];
    CGPoint center = CGPointMake(bounds.size.width / 2.0, bounds.size.height / 2.0);
    float radius = MIN(bounds.size.width/2, bounds.size.height/2);//同心圆外圆外半径
    float perimeter = 2 * M_PI * radius; //同心圆外圆的周长
    float sectorWidth = perimeter / NUM_SECTOR; // 每个sectorView所在矩形的宽度
    float sectorHeight = sectorWidth * SECTOR_ASPECT_RATIO; // 每个sectorView所在矩形的高度，取为宽度的3倍
    
    //create a cglayer and draw the background graphic to it
    CGContextRef context = MyECreateBitmapContext(self.bounds.size.width, self.bounds.size.height);
    // 设置反锯齿效果
    CGContextSetShouldAntialias(context, YES);
    CGContextSetAllowsAntialiasing(context, YES);
    
    
    // ========================= 1 绘制外层圆环  ===============================
    CGContextSaveGState(context);
    
    // 最外层圆环的外圆的外接矩形
    CGRect rect1 = CGRectMake(center.x -radius, 
                              center.y-radius, 
                              2*radius, 2*radius);
    CGContextAddEllipseInRect(context, rect1); 
    
    // 最外层圆环的内圆的外接矩形
    CGRect rect2 = CGRectMake(center.x -( radius-2), 
                              center.y - (radius-2), 
                              2* (radius-2), 2 * (radius-2));
    CGContextAddEllipseInRect(context, rect2);
    
    CGContextEOClip(context);
    
    
    CGContextTranslateCTM(context, 0, bounds.size.height);
    CGContextScaleCTM(context, 1, -1);
    CGGradientRef myGradient;
    CGColorSpaceRef myColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 1.0, 1.0, 1.0, 0.7, // Start color
        0.0, 0.0, 0.0, 0.7 }; // End color
    myColorspace = CGColorSpaceCreateDeviceRGB();
    myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
                                                      locations, num_locations);    
    CGPoint myStartPoint, myEndPoint;
    myStartPoint.x = rect1.origin.x;
    myStartPoint.y = rect1.origin.y;
    myEndPoint.x = rect1.origin.x + rect1.size.width;
    myEndPoint.y = rect1.origin.y + rect1.size.height;
    CGContextDrawLinearGradient (context, myGradient, myStartPoint, myEndPoint, 0);
    CGGradientRelease(myGradient);
    CGContextRestoreGState(context);
    
    
    // ========================= 2 绘制内层圆环  ===============================
    CGContextSaveGState(context);
    float margin = 2;//第二层圆环扩大遮盖底下的SectorView圆环的偏移距离
    // 第二层圆环的外圆的外接矩形
    rect1 = CGRectMake(center.x - (radius-sectorHeight)-margin, 
                       center.y - (radius-sectorHeight)-margin, 
                       2 *(radius-sectorHeight)+2*margin, 
                       2 * (radius-sectorHeight)+2*margin);
    CGContextAddEllipseInRect(context, rect1);
    
    // 第二层圆环的内圆的外接矩形
    rect2 = CGRectMake(center.x - (radius-sectorHeight -2)-margin, 
                       center.y - (radius-sectorHeight -2)-margin, 
                       2 *(radius-sectorHeight-2)+2*margin, 
                       2 * (radius-sectorHeight-2)+2*margin);
    CGContextAddEllipseInRect(context, rect2);
    
    CGContextEOClip(context);
    
    CGContextTranslateCTM(context, 0, bounds.size.height);
    CGContextScaleCTM(context, 1, -1);
    CGFloat components1[8] = { 0.0, 0.0, 0.0, 0.7, // Start color
        1.0, 1.0, 1.0, 0.7 }; // End color
    
    myGradient = CGGradientCreateWithColorComponents (myColorspace, components1,
                                                      locations, num_locations);    
    CGColorSpaceRelease (myColorspace);
    myStartPoint.x = rect1.origin.x;
    myStartPoint.y = rect1.origin.y;
    myEndPoint.x = rect1.origin.x + rect1.size.width;
    myEndPoint.y = rect1.origin.y + rect1.size.height;
    CGContextDrawLinearGradient (context, myGradient, myStartPoint, myEndPoint, 0);
    CGGradientRelease(myGradient);
    CGContextRestoreGState(context);
    
    /*
     // 测试添加一个圆盘作为内部表盘，但这个圆盘会遮住底下的view本身的layer上的内容。
     // 所以这里把表盘绘制到下面的drawRect:函数里面，也就是绘制到了底下的view本身的layer上。
     CGContextSaveGState(context);
     CGFloat components2[4] = {0.8,0.8,0.8,1.0};
     CGContextSetFillColor(context, components2);
     CGContextFillEllipseInRect(context, rect2);
     CGContextRestoreGState(context);
     
     // ============== 在图片上绘制时刻文字 ================
     // 这个方法绘制处理的文字不清晰，还没来得及找原因，所以暂时不用
     // 绘制一段文字 参考  http://blog.csdn.net/kmyhy/article/details/7258338
     
     float tickTextRadius = (radius - sectorHeight-25);
     for(int i=0; i<24; i++)
     {
     CGContextSaveGState(context);
     
     NSString* string = [NSString stringWithFormat:@"%i ", i];
     
     CGContextSelectFont (context, // 3
     
     "Helvetica",
     
     10,
     
     kCGEncodingMacRoman);
     
     CGContextSetCharacterSpacing (context, 0); // 4
     
     CGContextSetTextDrawingMode (context, kCGTextFill); // 5
     
     CGContextSetRGBFillColor (context, 0, 0, 0, 1); // 6
     
     CGContextSetRGBStrokeColor (context, 0, 0, 1, 1); // 7
     
     CGAffineTransform myTextTransform =  CGAffineTransformMakeRotation(ALPHA/2); // 由于如容器旋转了，这里需要反向旋转补偿
     
     CGContextSetTextMatrix (context, myTextTransform); // 9
     
     float angle = (23-i) * ALPHA *2  + 1.2*M_PI_2;
     CGContextSetTextPosition(context, center.x-4 +  tickTextRadius*cos(angle), 
     center.y-4 + tickTextRadius*sin(angle));
     
     
     CGContextShowText(context,  [string cStringUsingEncoding:NSStringEncodingConversionAllowLossy], 2);
     CGContextRestoreGState(context);
     }
     
     // */
    
    
    
    CGImageRef myMaskImg = CGBitmapContextCreateImage(context);
    
    // =============== 添加图片到层上 ============
    // Create the layer.
    CALayer *myLayer = [[CALayer alloc] init];
    
    // Set the contents of the layer to a fixed image. And set
    // the size of the layer to match the image size.
    UIImage *layerContents = [UIImage imageWithCGImage:myMaskImg];
    CGSize imageSize = layerContents.size;
    
    myLayer.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
    myLayer.contents = (id)layerContents.CGImage;
    
    
    // Add the layer to the view.
    [self.layer addSublayer:myLayer];
    
    // Center the layer in the view.
    myLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    CGContextRelease(context);
    CGImageRelease(myMaskImg);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
// 下面主要用于绘制内部表盘时刻刻度和文字
- (void)drawRect:(CGRect)rect {
    CGPoint center = CGPointMake(rect.size.width / 2.0, rect.size.height / 2.0);
    float radius = MIN(rect.size.width/2, rect.size.height/2);//同心圆外圆外半径
    float perimeter = 2 * M_PI * radius; //同心圆外圆的周长
    float sectorWidth = perimeter / NUM_SECTOR; // 每个sectorView所在矩形的宽度
    float sectorHeight = sectorWidth * SECTOR_ASPECT_RATIO; // 每个sectorView所在矩形的高度，取为宽度的3倍
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 设置反锯齿效果
    CGContextSetShouldAntialias(context, YES);
    CGContextSetAllowsAntialiasing(context, YES);
    
    // ===================绘制表盘的白色圆盘背景 dial plate====================================
    CGContextSaveGState(context);
    float dialPlateRadius = (radius - sectorHeight);
    [[UIColor whiteColor] setFill];
    UIBezierPath* bPath = [UIBezierPath bezierPathWithArcCenter:center radius:dialPlateRadius startAngle:0 endAngle:2*M_PI clockwise:YES];
    [bPath fill];
    CGContextRestoreGState(context);
    
    

    
    // =================== 绘制刻度位置24小时时刻 dial plate====================================
    center = CGPointMake(rect.size.width / 2.0  -14, rect.size.height / 2.0 + 3);//绘制刻度文字的中心进行了微调整，还不清楚中心为何不同
    float tickTextRadius = (radius - sectorHeight - 8);
    for(int i=0; i<24; i++)
    {
        CGContextSaveGState(context);
        
        [[UIColor blackColor] setFill];
        CGContextSetLineWidth(context, 1.0);
        
        float width = self.bounds.size.width;
        float height = self.bounds.size.height;
        
        NSString* string = [NSString stringWithFormat:@"%i", i];
        UIFont* theFont = [UIFont systemFontOfSize:10];
        
        CGSize maxSize = CGSizeMake(width, height);
        CGSize stringSize = [string sizeWithFont:theFont
                               constrainedToSize:maxSize
                                   lineBreakMode:UILineBreakModeClip];
        float angle = 0;

        if(_scheduleType == SCHEDULE_TYPE_TODAY || _scheduleType == SCHEDULE_TYPE_WEEKLY)
            angle = i * ALPHA *2  - M_PI_2 + 0.02;// 微调，顺时针旋转了一点
        else if(_scheduleType == SCHEDULE_TYPE_NEXT24HRS) 
            angle = self.zeroHourSectorId * ALPHA + i * ALPHA *2  - M_PI_2;
        CGRect stringRect = CGRectMake(center.x + tickTextRadius*cos(angle) + 1, // 调节水平位置，向右移动1点
                                       center.y + tickTextRadius*sin(angle) ,
                                       stringSize.width,
                                       stringSize.height);
        
        
        //进行文字旋转，由于整个view为了使0点指向正上方而旋转了ALPHA/2
        //此处反向旋转ALPHA/2角度，以校正由于父容器MyEDoughnutView为了使0点线垂直而进行的旋转
        CGContextRotateCTM(context, -ALPHA/2);
        
        [string drawInRect:stringRect withFont:theFont];
        
        CGContextRestoreGState(context);
    }

    // =================== 绘制指向当前正在运行的sector的时钟指针 =============================================
    if(_scheduleType == SCHEDULE_TYPE_TODAY) {
        // 由于上面绘制时刻文字所用的中心和下面的红点、指针用的指针不同，所以这里重新定义一个中心。还不知为什么这两套东西的中心为何不一样。
        CGPoint newCenter = CGPointMake(rect.size.width / 2.0, rect.size.height / 2.0);
        
        // ---------------首先在标准坐标系形成Bezier曲线路径
        UIBezierPath* aPath = [UIBezierPath bezierPath];
        
        // Set the starting point of the shape.
        [aPath addArcWithCenter:CGPointMake(newCenter.x, newCenter.y)
                         radius:5
                     startAngle:self.sectorIdSpaningCurrentTime * ALPHA - M_PI_2 - M_PI_4/2  //最后这个- M_PI_4/2是为了让开口逆时针扩大一点
                       endAngle:self.sectorIdSpaningCurrentTime * ALPHA + ALPHA - M_PI_2 + M_PI_4/2 //最后这个+ M_PI_4/2是为了让开口顺时针扩大一点
                      clockwise:NO];
        // Draw the lines
        [aPath addLineToPoint:CGPointMake(newCenter.x + tickTextRadius * 0.9 * cos(self.sectorIdSpaningCurrentTime * ALPHA - M_PI_2), 
                                          newCenter.y + tickTextRadius * 0.9 * sin(self.sectorIdSpaningCurrentTime * ALPHA - M_PI_2))];
        [aPath closePath];
        
        // for test
        NSLog(@"In Doughnut view draw rect, Current Time is : %@", ((MyETodayScheduleController *)self.delegate).todayModel.currentTime);
        
        
        // ------------下面绘制表针的阴影，要向右下角偏移一点距离----------------
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 1, 1);//绘制阴影，向右下角偏移一定的距离
        [[UIColor lightGrayColor] setFill];
        [aPath fill];
        CGContextRestoreGState(context);

        // ------------ 下面绘制正常的表针，用梯度颜色填充，下面是一个很好的梯度颜色填充具体形状的很好的例子 ------------
        CGContextSaveGState(context);
        CGContextAddPath(context, aPath.CGPath);
        CGContextEOClip(context);
        
        
        CGGradientRef myGradient;
        CGColorSpaceRef myColorspace;
        size_t num_locations = 2;
        CGFloat locations[2] = { 0.0, 1.0 };
        CGFloat components[8] = { 0.0, 0.0, 1.0, 0.99, // Start color
            0.0, 0.0, 0.0, 0.99 }; // End color
        myColorspace = CGColorSpaceCreateDeviceRGB();
        myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
                                                          locations, num_locations);    
        CGPoint myStartPoint, myEndPoint;
        myStartPoint.x = newCenter.x;
        myStartPoint.y = newCenter.y;
        myEndPoint.x = newCenter.x + tickTextRadius * 0.9 * cos(self.sectorIdSpaningCurrentTime * ALPHA - M_PI_2);
        myEndPoint.y = newCenter.y + tickTextRadius * 0.9 * sin(self.sectorIdSpaningCurrentTime * ALPHA - M_PI_2);
        
        CGContextDrawLinearGradient (context, myGradient, myStartPoint, myEndPoint, kCGGradientDrawsBeforeStartLocation);
        CGGradientRelease(myGradient);
        CGColorSpaceRelease (myColorspace);
        CGContextRestoreGState(context);
        
    }
    

}



// update sectorColors according to updated mode array and mode-color dictionary, update the sector views in the same time
- (void)_createOrUpdateSectorColors
{
    BOOL needCreateSectors = NO;
    if([_sectorViews count] == 0) // 如果当前数组里面的sector数目0，就说明各个sector没有创建
        needCreateSectors = YES;
    NSArray *sectorColors = [self _getSectorColorArray];
    for (int i = 0; i < NUM_SECTOR; i++) {
        BOOL isFlashing = NO;// 设置是否允许这个sector view正在用绿色背景进行闪烁，仅在Today面板有效，如果这个sector正跨越当前时刻
        // 为当前要绘制的第i个sector view设定应该取的填充颜色
        UIColor *realFillColor = [sectorColors objectAtIndex:i];
        if (_scheduleType == SCHEDULE_TYPE_TODAY || _scheduleType == SCHEDULE_TYPE_NEXT24HRS) {//如果是Today面板，就需要判定当前在绘制的sector是否在可以改变的范围内
            if(i < self.sectorIdSpaningCurrentTime)
            {
                // 取得当前sector的mode所对应的颜色
                NSInteger modeId = [[self.modeIdArray objectAtIndex:i] intValue];
                UIColor *modeColor = [self.delegate colorForModeId:modeId];
                
                // 根据上述颜色，生成一个颜色相同但亮度更低的
                MyEHSVColorStruct hsv;
                [modeColor getHue:&hsv.hue saturation:&hsv.sat brightness:&hsv.val alpha:&hsv.alpha];
                realFillColor= [UIColor colorWithHue:hsv.hue saturation:hsv.sat brightness:hsv.val * 0.8 alpha:hsv.alpha];
            }else  if([[self.holdArray objectAtIndex:i] caseInsensitiveCompare:@"none"] != NSOrderedSame)
            {
                realFillColor= [UIColor lightGrayColor];
            }
            if(i == self.sectorIdSpaningCurrentTime)
            {
                //                realFillColor = [UIColor greenColor];
                isFlashing = YES;
            }
            
        }
        
        MyESectorView *sectorView;
        if(needCreateSectors){
             sectorView= [self _createSectorViewAtIndex:i fillColor:realFillColor isFlashing:isFlashing];
            // 把新生成的 sector view 添加到第一个子view位置, 可以用下面两种办法，但会应用subview的排序，从而影响遮盖关系
            //[self insertSubview:sectorView atIndex:0];//把新生成的 sector view插入到父容器的方法
            [self addSubview:sectorView];//把新生成的 sector view追加到父容器的方法
            [_sectorViews addObject:sectorView];
        } else {
            sectorView = [_sectorViews objectAtIndex:i];
            sectorView.fillColor = realFillColor;
            sectorView.isFlashing = isFlashing;
        }
//        NSLog(@"isFlashing = %@, userInteractionEnabled = %@", isFlashing?@"YES":@"NO", sectorView.userInteractionEnabled?@"YES":@"NO");

    }
}
#pragma mark -
#pragma mark 触摸函数和触摸识别代理方法
// tap响应函数
- (void)_singleTaped:(id)sender {
    NSLog(@"_singleTaped");
}
- (void)_doubleTaped:(id)sender {
    NSLog(@"_doubleTaped");
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
        // Disallow recognition of tap gestures in the segmented control.
//        if ( ) {//change it to your condition
//            return NO;
//        }
    return YES;
}

@end




@implementation MyEDoughnutView

@synthesize modeIdArray = _modeIdArray;
@synthesize sectorIdSpaningCurrentTime = _sectorIdSpaningCurrentTime;
@synthesize holdArray = _holdArray;
@synthesize delegate = _delegate;
@synthesize sectorTouchType = _sectorTouchType;
@synthesize isRemoteControl = _isRemoteControl;
@synthesize zeroHourSectorId = _zeroHourSectorId;

- (id)initWithFrame:(CGRect)frame  delegate:(id <MyEDoughnutViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _delegate = delegate;
        // 很多变量应该在后面的createViewsWithModeArray:::函数中更要传递进来
        
        _scheduleType = SCHEDULE_TYPE_WEEKLY;//默认指定当前图形是为Weekly模块的。如果当前图形是用与Weekly模块，请务必在生成此类时指定。
        _sectorIdSpaningCurrentTime = 0;//指定刚好跨越当前时刻的sector，如果时刻刚好在整半点处，那么就取下一个sector的id
        
        _timeArrowViews = [[NSMutableArray alloc] init];
        _sectorViews = [[NSMutableArray alloc] init];
        
        _sectorTouchType = SectorTouchTypeDisable;
        
        _isRemoteControl = NO;
        
        // 主要是用于Next24Hrs面板，用于表明0点所在的sector的index，取值范围是0~48，对于today面板和weekly面板，这个值的取值始终是0
        _zeroHourSectorId = 0;
        
        // 描绘本容器view的边界，以便于调试
        //        CALayer *theLayer= [self layer];
        //        theLayer.borderColor = [UIColor colorWithRed:0.9 green:0.6 blue:0.9 alpha:0.4].CGColor;
        //        theLayer.borderWidth = 1;
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        _singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_singleTaped:)] ;
        [_singleTapRecognizer setNumberOfTapsRequired:1];
        [_singleTapRecognizer setDelegate:self];
        [self addGestureRecognizer:_singleTapRecognizer];
        
        _doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_doubleTaped:)] ;
        [_doubleTapRecognizer setNumberOfTapsRequired:2];
        [_doubleTapRecognizer setDelegate:self];
        [self addGestureRecognizer:_doubleTapRecognizer];
    }
    return self;
}


- (void) setModeIdArray:(NSMutableArray *)modeIdArray
{
    _modeIdArray = [modeIdArray mutableCopy];
}

- (void) setSectorIdSpaningCurrentTime:(NSInteger)sectorIdSpaningCurrentTime {
    _sectorIdSpaningCurrentTime = sectorIdSpaningCurrentTime;
    [self setNeedsDisplay];
}

//注意，设置模式数组和模式颜色词典，并开始绘制圆环。modeIdArray是48个modeId元素，表示每个半点的modeId。
- (void)createViewsWithModeArray:(NSMutableArray *)modeIdArray scheduleType:(NSInteger)type
{
    _scheduleType = type;
    self.modeIdArray = modeIdArray;
    
    [self _drawContents];
    
}

// 更新模式数组，同时刷新view的显示
- (void)updateWithModeIdArray:(NSMutableArray *)modeIdArray
{    
    if([modeIdArray count] != NUM_SECTOR)
    {
        [NSException raise:@"Error in number of element" format:@"Number of color is not 48 in modes"];
        return;
    }
    
    self.modeIdArray = modeIdArray;
    
    [self _createOrUpdateSectorColors];
}

// 把序号为index的sector的modeId设置为modeId
// index is zero-based, range from 0 to 47
- (void)updateSectorViewAtIndex:(int)index modeId:(NSInteger)modeId
{
    [self.modeIdArray replaceObjectAtIndex:index withObject:[NSNumber numberWithInt: modeId]];
    
    MyESectorView *sectorView = [_sectorViews objectAtIndex:index];
    UIColor *fillColor = [self.delegate colorForModeId:[[NSNumber numberWithInt:modeId]intValue]];
    if (fillColor == nil) {
        fillColor = [UIColor blackColor];
    }
    [sectorView setFillColor: fillColor];
}

// 把序号从fromIndex到toIndex的sector的modeId设置为modeId
// fromIndex and toIndex (inclusion) is zero-based, range from 0 to 47
- (void)updateSectorViewFrom:(int)fromIndex to:(int)toIndex modeId:(NSInteger)modeId
{
    for (int i = fromIndex; i <= toIndex; i++) {
        [self.modeIdArray replaceObjectAtIndex:i withObject:[NSNumber numberWithInt: modeId]];
        MyESectorView *sectorView = [_sectorViews objectAtIndex:i];
        UIColor *fillColor = [self.delegate colorForModeId:modeId];
        if (fillColor == nil) {
            fillColor = [UIColor blackColor];
        }
        sectorView.fillColor = fillColor;
    }
}




#pragma mark -
#pragma mark 某个MyESectorView被触摸时调用的函数
//下面几个函数是某个MyESectorView被触摸时调用的函数，其中的sectorId是tap事件第一次触摸的MyESectorView对象。而touchLocation已经被转换到了本View的坐标空间
- (void)handleTouchBeganAtLocation:(CGPoint)touchLocation sectorId:(uint)sectorId {
    // 如果当前不允许远程控制，那么直接返回
    if (!self.delegate.isRemoteControl) {
        return;
    }
    
    
    _lastSectorViewIdTouched = sectorId;
    self.sectorTouchType = SectorTouchTypeDraggingBorder;//初始化
    // Decide the touch type
    SectorPositionType position = [self _sectorPositionTypeOfSectorId:sectorId];
    
    if (_scheduleType == SCHEDULE_TYPE_TODAY) {//如果在today模块
        if(sectorId == 0 || (sectorId == NUM_SECTOR - 1 && position != SectorPositionTypeSingle)) {// 如果当前点击在第一个和最后一个sector，就是禁止触摸的模块
            self.sectorTouchType = SectorTouchTypeDisable;
        } else {
            if ([[self.holdArray objectAtIndex:sectorId] caseInsensitiveCompare:@"none"] != NSOrderedSame) {
                //如果当前sector被hold了，就不允许拖动
                NSLog(@"today模块，hold不是none，设置self.sectorTouchType = SectorTouchTypeDisable;");
                self.sectorTouchType = SectorTouchTypeDisable;
            } else if(position == SectorPositionTypeMiddle ) {//如果当前触摸的sector位于一个时段的中间，就不允许拖动
                self.sectorTouchType = SectorTouchTypeDisable;
            } else if(position == SectorPositionTypeFirst ) {// if the current sector is the first sector of the period
                if ([[self.holdArray objectAtIndex:sectorId - 1] caseInsensitiveCompare:@"none"] != NSOrderedSame) {// 如果前一时段被hold住了，也不能拖动
                    self.sectorTouchType = SectorTouchTypeDisable;
                }else {
                    self.delegate.currentSelectedModeId = [[self.modeIdArray objectAtIndex:sectorId] intValue];
                    self.sectorTouchType = SectorTouchTypeDraggingBorder;
                    
                }
            } else if(position == SectorPositionTypeLast ){// if the current sector is the last sector of the period
                if ([[self.holdArray objectAtIndex:sectorId + 1] caseInsensitiveCompare:@"none"] != NSOrderedSame) {// 如果后一时段被hold住了，也不能拖动
                    self.sectorTouchType = SectorTouchTypeDisable;
                }else {
                    self.delegate.currentSelectedModeId = [[self.modeIdArray objectAtIndex:sectorId] intValue];
                    self.sectorTouchType = SectorTouchTypeDraggingBorder;
                }
            }
        }

    } else if (_scheduleType == SCHEDULE_TYPE_NEXT24HRS){ //如果在Next24Hrs模块
        if(sectorId == 0 || (sectorId == NUM_SECTOR - 1 && position != SectorPositionTypeSingle)) {// 如果当前点击在第一个, 或者如果当前点击在最后一个sector，并且该sector不是一个孤立的，就是禁止触摸的模块
            self.sectorTouchType = SectorTouchTypeDisable;
        } else {
            if ([[self.holdArray objectAtIndex:sectorId] caseInsensitiveCompare:@"none"] != NSOrderedSame) {
                //如果当前sector被hold了，就不允许拖动
                NSLog(@"Next24Hrs模块，hold不是none，设置self.sectorTouchType = SectorTouchTypeDisable;");
                self.sectorTouchType = SectorTouchTypeDisable;
            } else if(position == SectorPositionTypeMiddle ) {//如果当前触摸的sector位于一个时段的中间，就不允许拖动
                self.sectorTouchType = SectorTouchTypeDisable;
            } else if(position == SectorPositionTypeFirst ) {// if the current sector is the first sector of the period
                if ([[self.holdArray objectAtIndex:sectorId - 1] caseInsensitiveCompare:@"none"] != NSOrderedSame) {// 如果前一时段被hold住了，也不能拖动
                    self.sectorTouchType = SectorTouchTypeDisable;
                }else {
                    self.delegate.currentSelectedModeId = [[self.modeIdArray objectAtIndex:sectorId] intValue];
                    self.sectorTouchType = SectorTouchTypeDraggingBorder;
                    
                }
            } else if(position == SectorPositionTypeLast ) {// if the current sector is the last sector of the period
                if ([[self.holdArray objectAtIndex:sectorId + 1] caseInsensitiveCompare:@"none"] != NSOrderedSame) {// 如果后一时段被hold住了，也不能拖动
                    self.sectorTouchType = SectorTouchTypeDisable;
                }else {
                    self.delegate.currentSelectedModeId = [[self.modeIdArray objectAtIndex:sectorId] intValue];
                    self.sectorTouchType = SectorTouchTypeDraggingBorder;
                }
            }
        }
        
    } else if (_scheduleType == SCHEDULE_TYPE_WEEKLY){ //如果在Weekly模块
        if( self.delegate.currentSelectedModeId == -1){//如果没有选择某个mode，就不允许涂抹
            if((sectorId == 0 && position != SectorPositionTypeSingle) || // 如果当前点击在第一个sector，并且该sector不是一个孤立的，就是禁止触摸的模块
               (sectorId == NUM_SECTOR - 1 && position != SectorPositionTypeSingle)) {// 如果当前点击在最后一个sector，并且该sector不是一个孤立的，就是禁止触摸的模块
                self.sectorTouchType = SectorTouchTypeDisable;
            } else {
                if(position == SectorPositionTypeMiddle ) {//如果当前触摸的sector位于一个时段的中间
                    self.sectorTouchType = SectorTouchTypeDisable;
                } else if(position == SectorPositionTypeFirst ) {// if the current sector is the first sector of the period
                    self.delegate.currentSelectedModeId = [[self.modeIdArray objectAtIndex:sectorId] intValue];
                    self.sectorTouchType = SectorTouchTypeDraggingBorder;
                } else {// if the current sector is the last sector of the period
                    self.delegate.currentSelectedModeId = [[self.modeIdArray objectAtIndex:sectorId] intValue];
                    self.sectorTouchType = SectorTouchTypeDraggingBorder;
                }
            }
            
        } else { // 如果选择了某个mode
            self.sectorTouchType = SectorTouchTypePainting;//如果选择了某个mode，就允许涂抹
        }
    }
    
    _isScheduleChanged = NO;//触摸一开始，标记当前没有修改Schedule时段
}

//sectorId参数记录每次触摸sector view时，手指点击的第一个sector的id
- (void)handleTouchMovedAtLocation:(CGPoint)touchLocation sectorId:(uint)sectorId {
    // 如果当前不允许远程控制，那么直接返回
    if (!self.delegate.isRemoteControl) {
        return;
    }
    
    // csid 是当前手指触摸到的sector id
    int csid = [self _sectorIdOnTouchedLocation:touchLocation];
    if (csid < 0) {//当前有可能触摸到sector之外，此时csid等于-1，此时不处理，退出
        return;
    }
    
    _isScheduleChanged = _isScheduleChanged | [self _paintingSectorWithStartSectorId:sectorId currentSectorId:csid];
    // 仅当进入一个新的sector时，才更新_lastSectorViewIdTouched
    if (_lastSectorViewIdTouched != csid)
        _lastSectorViewIdTouched = csid;
}
- (void)handleTouchEndedAtLocation:(CGPoint)touchLocation sectorId:(uint)sectorId {
    // 如果当前不允许远程控制，那么直接返回
    if (!self.delegate.isRemoteControl) {
        return;
    }
    
    // csid 是当前手指触摸到的sector id
    int csid = [self _sectorIdOnTouchedLocation:touchLocation];
    if (csid < 0) {//当前有可能触摸到sector之外，此时csid等于-1，此时让csid取值为_lastSectorViewIdTouched，即最后一次触摸到的sector id
        csid = _lastSectorViewIdTouched;
    }
    
    _isScheduleChanged = _isScheduleChanged | [self _paintingSectorWithStartSectorId:sectorId currentSectorId:csid];
    
    if(_isScheduleChanged) {//当这次触摸中，真正地改变了schedule，就调用deldgeate的方法，传回新的self.modeIdArray
        // 每当用户手指触摸修改了若干sector的模式，用户手指抬起来后，就向delegate发送这个消息
        if ([self.delegate respondsToSelector:@selector(didSchecduleChangeWithModeIdArray:)]) {
            [self.delegate didSchecduleChangeWithModeIdArray:self.modeIdArray];
        }
    } else {
        //如果当这次触摸中，并没改变schedule，就调用deldgeate的方法，但传回nil作为参数
        // 每当用户手指触摸修改了若干sector的模式，用户手指抬起来后，就向delegate发送这个消息
        if ([self.delegate respondsToSelector:@selector(didSchecduleChangeWithModeIdArray:)]) {
            [self.delegate didSchecduleChangeWithModeIdArray:nil];
        }
    }
}


//sectorId参数记录每次触摸sector view时，手指点击的第一个sector的id
- (void)handleSingleTapAtLocation:(CGPoint)touchLocation sectorId:(uint)sectorId {
    if ([self.delegate respondsToSelector:@selector(didSingleTapSectorIndex:)]) {
        [self.delegate didSingleTapSectorIndex:sectorId];
    }
}
- (void)handleDoubleTapAtLocation:(CGPoint)touchLocation sectorId:(uint)sectorId {
    if ([self.delegate respondsToSelector:@selector(didDoubleTapSectorIndex:)]) {
        [self.delegate didDoubleTapSectorIndex:sectorId];
    }
}




// 下面一个方法是利用在SectorView中获取到的touchs集合去控制程序中的各个元素做各种事情。
// 下面的代码实现了一个类似于鼠标跟随的触摸跟随特效；
-(void)manageTouches:(NSSet*)touches{
    for (UITouch *touch in touches) {
        if (touch.phase == UITouchPhaseBegan) {
            //            CGPoint touchPos = [touch locationInView:self];
            //            NSLog(@"Begin:%3.0f,%3.0f",touchPos.x,touchPos.y);
            //            NSLog(@"一开始Subview 总数目： %i",[[self subviews] count]);
        }else if(touch.phase == UITouchPhaseMoved){
            CGPoint touchPos = [touch locationInView:self];
            //            NSLog(@"Touch 正在移动中..., move:%3.0f,%3.0f",touchPos.x,touchPos.y);
            
            [self touchMoveWithPoint:touchPos];
            
        }else if(touch.phase == UITouchPhaseEnded){
            if (touch.tapCount>1) {
                //                NSLog(@"Taps:%2i",touch.tapCount);
            }else{
                //                NSLog(@"Tap 了一次...");
            }
            //            CGPoint touchPos = [touch locationInView:self];
            //            NSLog(@"End:%3.0f,%3.0f",touchPos.x,touchPos.y);
            //            NSLog(@"清理之前，Subview 总数目： %i",[[self subviews] count]);
            while ([[self subviews] count]>NUM_SECTOR) {
                
                [[[self subviews] objectAtIndex:NUM_SECTOR] removeFromSuperview];
            }
            //            NSLog(@"清理之后， Subview 总数目： %i",[[self subviews] count]);
        }
    }
}

-(void)touchMoveWithPoint:(CGPoint)touchPos{
    UIView *aview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 3, 3)];
    [aview setBackgroundColor:[UIColor redColor]];
    [self addSubview:aview];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [aview setAlpha:0.0];
    [UIView commitAnimations];
    
    [self dragView:aview withPoint:touchPos];
    
    if ([[self subviews] count]>50+ NUM_SECTOR) {
        [[[self subviews] objectAtIndex:4+NUM_SECTOR] removeFromSuperview];
    }
}
-(void)dragView:(UIView*)aView withPoint:(CGPoint)point{
    aView.center = point;
}


@end
