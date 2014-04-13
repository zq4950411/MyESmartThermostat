//
//  DeviceView.m
//  MyE
//
//  Created by space on 13-8-24.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "DeviceView.h"
#import "DeviceEntity.h"
#import "NSMutableArray+Safe.h"

@implementation DeviceView

@synthesize nextButton;
@synthesize cancelButton;
@synthesize pickView;
@synthesize datas;

//获取要添加的设备类型
-(DeviceEntity *) getSeletedDevice
{
    return [self.datas safeObjectAtIndex:[self.pickView selectedRowInComponent:0]];
}



-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.datas.count == 0)
    {
        pickerView.userInteractionEnabled = NO;
    }
    else
    {
        pickerView.userInteractionEnabled = YES;
    }
    return self.datas.count;
}


-(UIView *) pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    
    label.backgroundColor = [UIColor clearColor];
    
    DeviceEntity *device = (DeviceEntity *)[self.datas safeObjectAtIndex:row];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.text = device.deviceName;
    
    return label;
}



@end






@implementation DeviceStatusView

@synthesize pickView;
@synthesize fanSwitch;
@synthesize imagesDics;
@synthesize numbers;
@synthesize instructions;
@synthesize value;
@synthesize okButton;

@synthesize type;

-(NSMutableDictionary *) getSelectedDictionary
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (type == 0)
    {
        int imageIndex = [self.pickView selectedRowInComponent:0];
        NSDictionary *temp = [self.imagesDics safeObjectAtIndex:imageIndex];
        
        [params setObject:[temp objectForKey:@"value"] forKey:@"controlMode"];

        int numberIndex = [self.pickView selectedRowInComponent:1];
        
        [params safeSetObject:[self.numbers safeObjectAtIndex:numberIndex] forKey:@"point"];
        [params safeSetObject:@"1" forKey:@"type"];
        [params safeSetObject:[NSString stringWithFormat:@"%d",fanSwitch.isOn] forKey:@"fan"];

        return params;
    }
    else if(type == 1)
    {
        int index = [self.pickView selectedRowInComponent:0];
        NSDictionary *dic = [self.instructions safeObjectAtIndex:index];
        
        [params safeSetObject:[dic objectForKey:@"instructionId"] forKey:@"instructionId"];
        [params safeSetObject:@"2" forKey:@"type"];
    }
    else if(type == 2)
    {
        int index = [self.pickView selectedRowInComponent:0];
        if (index == 0)
        {
            [params safeSetObject:@"0" forKey:@"instructionId"];
        }
        else
        {
            [params safeSetObject:@"1" forKey:@"instructionId"];
        }
        [params safeSetObject:@"2" forKey:@"type"];
    }
    else if(type == 3 || type == 6)
    {
        NSString *channel = [value objectForKey:@"channel"];
        
        [params safeSetObject:channel forKey:@"channel"];
        [params safeSetObject:@"2" forKey:@"type"];
    }
    
    return params;
}




-(void) awakeFromNib
{
    self.pickView.delegate = self;
    self.pickView.dataSource = self;
    
    if (type == 0)
    {
        self.imagesDics = [NSMutableArray arrayWithCapacity:0];
        
        [self.imagesDics addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Tb_Heating01.png",@"imageName",@"1",@"value", nil]];
        
        [self.imagesDics addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Tb_Cooling01.png",@"imageName",@"2",@"value", nil]];
        
        [self.imagesDics addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Tb_AutoRun.png",@"imageName",@"3",@"value", nil]];
        
        [self.imagesDics addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Tb_EmgH01.png",@"imageName",@"4",@"value", nil]];
        
        [self.imagesDics addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Tb_Off.png",@"imageName",@"5",@"value", nil]];
        
        
        if (self.numbers == nil)
        {
            self.numbers = [NSMutableArray array];
            
            for (int i = 50; i < 90; i++)
            {
                [self.numbers addObject:[NSString stringWithFormat:@"%d",i]];
            }
        }
        
        self.pickView.height = 162.0;
    }
}

-(void) layoutSubviews
{
    if (self.type != 0)
    {
        self.pickView.height = 216;
        if (type == 1)
        {

        }
        else if(type == 2)
        {
    
        }
        else if(type == 3)
        {
            NSString *channel = [value valueToStringForKey:@"channel"];
            if (![channel isChannel])
            {
                [value safeSetObject:@"000000" forKey:@"channel"];
            }
            for (int i = 0; i < channel.length; i++)
            {
                if (i > 0)
                {
                    break;
                }
                NSString *temp = [NSString stringWithFormat:@"%c",[channel characterAtIndex:i]];
                if (temp.intValue == 1)
                {
                    [self.pickView selectRow:1 inComponent:1 animated:YES];
                }
                else
                {
                    [self.pickView selectRow:0 inComponent:1 animated:YES];
                }
            }
        }
        else if(type == 6)
        {
            NSString *channel = [value valueToStringForKey:@"channel"];
            if (![channel isSwitchChannel])
            {
                [value safeSetObject:@"000" forKey:@"channel"];
            }
            for (int i = 0; i < channel.length; i++)
            {
                NSString *temp = [NSString stringWithFormat:@"%c",[channel characterAtIndex:i]];
                if (temp.intValue == 1)
                {
                    [self.pickView selectRow:1 inComponent:i animated:YES];
                }
                else
                {
                    [self.pickView selectRow:0 inComponent:i animated:YES];
                }
            }
        }
    }
    else
    {
        NSString *controlMode = [value valueToStringForKey:@"controlMode"];
        int selectedRow = 0;
        
        for (int i = 0; i < self.imagesDics.count; i++)
        {
            NSDictionary *tempDIc = [self.imagesDics objectAtIndex:i];
            NSString *v = [tempDIc valueForKey:@"value"];
            
            if ([v isEqualToString:controlMode])
            {
                selectedRow = i;
            }
        }
        
        [self.pickView selectRow:selectedRow inComponent:0 animated:YES];
        
        NSString *point = [value valueToStringForKey:@"point"];
        int selectedRowAtPoint = [self.numbers indexOfObject:point];
        [self.pickView selectRow:selectedRowAtPoint inComponent:1 animated:YES];
        
        NSString *fanMode = [value valueToStringForKey:@"fan"];
        if (fanMode.intValue == 0)
        {
            [fanSwitch setOn:NO];
        }
        else
        {
            [fanSwitch setOn:YES];
        }
    }
}

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (type == 0 || type == 3)
    {
        return 2;
    }
    if (type == 6)
    {
        NSString *channel = [value valueToStringForKey:@"channel"];
        return channel.length;
    }
    else
    {
        return 1;
    }
}

-(NSInteger) pickerView:(UIPickerView *) pickerView numberOfRowsInComponent:(NSInteger) component
{
    if (type == 0)
    {
        if (component == 0)
        {
            return self.imagesDics.count;
        }
        else
        {
            return numbers.count;
        }
    }
    else if(type == 1)
    {
        if (self.instructions == nil)
        {
            self.instructions = [value valueForKey:@"instructionDeviceList"];
        }
        if (instructions.count == 0)
        {
            pickView.userInteractionEnabled = NO;
        }
        else
        {
            pickView.userInteractionEnabled = YES;
        }
        return instructions.count;
    }
    else if(type == 2)
    {
        return 2;
    }
    else if(type == 3)
    {
        if (component == 0)
        {
            return 6;
        }
        else
        {
            return 2;
        }
    }
    else if(type == 6)
    {
        return 2;
    }
    else
    {
        return 0;
    }
}

-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger) component
{
    if (type == 0)
    {
        if (component == 0)
        {
            [value safeSetObject:[NSString stringWithFormat:@"%d",(row + 1)] forKey:@"controlMode"];
        }
        else
        {
            [value safeSetObject:[NSString stringWithFormat:@"%d",(row + 50)] forKey:@"point"];
        }
        
    }
    else if(type == 3)
    {
        NSString *channel = [self.value objectForKey:@"channel"];
 
        if (component == 0)
        {
            char c = [channel characterAtIndex:row];
            if (c == '1')
            {
                [self.pickView selectRow:1 inComponent:1 animated:YES];
            }
            else
            {
                [self.pickView selectRow:0 inComponent:1 animated:YES];
            }
            
            pickerView.tag = row;
        }
        else if (component == 1)
        {
            if (row == 0)
            {
                channel = [channel safeReplaceString:@"0" atIndex:pickerView.tag];
            }
            else
            {
                channel = [channel safeReplaceString:@"1" atIndex:pickerView.tag];
            }
            
            [value safeSetObject:channel forKey:@"channel"];
        }
    }
    else if(type == 6)
    {
        NSString *channel = [self.value objectForKey:@"channel"];
        
        if (row == 0)
        {
            channel = [channel safeReplaceString:@"0" atIndex:component];
        }
        else
        {
            channel = [channel safeReplaceString:@"1" atIndex:component];
        }
        
        [value safeSetObject:channel forKey:@"channel"];
    }
}

-(CGFloat) pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    if (type == 0)
    {
        return 50;
    }
    else
    {
        return 44;
    }
}

-(UIView *) pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if (type == 0)
    {
        if (component == 0)
        {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            
            NSDictionary *dic = [self.imagesDics objectAtIndex:row];
            imageView.image = [UIImage imageNamed:[dic objectForKey:@"imageName"]];
            
            return imageView;
        }
        else
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
            
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [UIColor clearColor];
            label.text = [self.numbers objectAtIndex:row];
            
            return label;
        }
    }
    else
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        
        if (type == 1)
        {
            NSDictionary *dic = [instructions safeObjectAtIndex:row];
            label.text = [dic objectForKey:@"instructionName"];
        }
        else if(type == 2)
        {
            if (row == 0)
            {
                label.text = @"OFF";
            }
            else
            {
                label.text = @"ON";
            }
        }
        else if(type == 3)
        {
            if (component == 0)
            {
                label.text = [NSString stringWithFormat:@"%d",(row + 1)];
            }
            else
            {
                if (row == 0)
                {
                    label.text = @"OFF";
                }
                else
                {
                    label.text = @"ON";
                }
            }
        }
        else if(type == 6)
        {
            if (row == 0)
            {
                label.text = @"OFF";
            }
            else
            {
                label.text = @"ON";
            }
        }
        
        return label;
    }
    
    
    return nil;
}

@end




























