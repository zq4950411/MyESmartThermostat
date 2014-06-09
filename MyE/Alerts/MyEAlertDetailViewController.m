//
//  MyEAlertDetailViewController.m
//  MyE
//
//  Created by Ye Yuan on 6/3/14.
//  Copyright (c) 2014 MyEnergy Domain. All rights reserved.
//

#import "MyEAlertDetailViewController.h"

@interface MyEAlertDetailViewController ()
- (void) setReadToServer;
- (void) configureView;
@end

@implementation MyEAlertDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 使用下面的语句设置字体， 因为在Storyboard里面设置的字体似乎不管用， http://isobar.logdown.com/posts/183808-uitextview-issues-in-ios6-and-ios7
    [self.contentTextView setEditable:YES];
    [self.contentTextView setFont:[UIFont fontWithName:@"Helvetica" size:18]];
    [self.contentTextView setEditable:NO];
    
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [self setReadToServer];
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)setAlert:(MyEAlert *)alert
{
    if(_alert != alert)
        _alert = alert;
    [self configureView];
}
#pragma mark private method
-(void) configureView
{
    self.titleLabel.text = self.alert.title;
    self.contentTextView.text = self.alert.content;
    self.publishDateLabel.text = self.alert.publish_date;
}

#pragma mark -
#pragma mark URL Loading System methods
-(void) setReadToServer{
    if (self.alert.new_flag == 0) {
        return;
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@?id=%d",GetRequst(URL_FOR_ALERT_SET_READ), self.alert.ID];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"ReadAlertUploader"  userDataDictionary:Nil];
    NSLog(@"ReadAlertUploader is %@",downloader.name);
}
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict
{
    if([name isEqualToString:@"ReadAlertUploader"]) {
        if ([string isEqualToString:@"fail"]) {
            NSLog(@"Network or backend error when set Alert to read. alert id = %ld", (long)self.alert.ID);
        } else {
            self.alert.new_flag = 0;
        }
        
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
//    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error"
//                                                  message:@"Communication error. Please try again."
//                                                 delegate:self
//                                        cancelButtonTitle:@"Ok"
//                                        otherButtonTitles:nil];
//    [alert show];
    
    // inform the user
    NSLog(@"Connection of %@ failed! Error - %@ %@",name,
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

@end
