//
//  MyEDataLoader.m
//  MyE
//
//  Created by Ye Yuan on 3/7/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEDataLoader.h"
#import "MyEHouseListViewController.h"
#import <netdb.h>
#import <SystemConfiguration/SCNetworkReachability.h>

@interface MyEDataLoader (Private)
- (BOOL)_processHttpRespondForString:(NSString *)respondText;
@end

@implementation MyEDataLoader
@synthesize delegate = _delegate;
@synthesize name = _name, userDataDictionary = _userDataDictionary;

// 1.判断是否联网：// 需要加入 frameworks:/System/Library/Frameworks/SystemConfiguration.framework
+ (BOOL) isConnectedToInternet {
    //创建零地址，0.0.0.0的地址表示查询本机的网络连接状态 
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress)); 
    zeroAddress.sin_len = sizeof(zeroAddress); 
    zeroAddress.sin_family = AF_INET; 
    // Recover reachability flags 
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress); 
    SCNetworkReachabilityFlags flags;
    
    //获得连接的标志 
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags); 
    CFRelease(defaultRouteReachability);
    
    //如果不能获取连接标志，则不能连接网络，直接返回 
    if (!didRetrieveFlags)
    {
        return NO;
    }
    
    //根据获得的连接标志进行判断
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
    
}

- (id)initLoadingWithURLString:(NSString *)urlString postData:(NSString *)postString delegate:(id <MyEDataLoaderDelegate>)delegate loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict;
{
    self = [super init];
    if(self)
    {
        _delegate = delegate;
        _name = name;
        
        //用户词典仅用于保存用户数据的，将来异步加载完成后，会把这个数据返回给用户，
        //用可以可以根据此数据里面的值知道此加载器进行了刚才是用来干什么的，从而可以进行下一步动作
        _userDataDictionary = dict;
        // 下面代码是用于进行异步HTTP URL请求的
        NSData *postData = nil;   
        NSString *postLength = nil;
        if (postString) {
            postData = [postString dataUsingEncoding:NSUTF8StringEncoding  allowLossyConversion:YES];   
            postLength = [NSString stringWithFormat:@"%d", [postData length]]; 
        }else {
            postData = nil;
            postLength = 0;
        }
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];   
//        [request setURL:[NSURL URLWithString:urlString]];
        [request setURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:
                                              NSUTF8StringEncoding]]];
        NSLog(@"%@",[urlString stringByAddingPercentEscapesUsingEncoding:
                     NSUTF8StringEncoding]);

        [request setHTTPMethod:@"POST"];
        [request setTimeoutInterval: 60];//setting timeout  
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];   
        [request setValue:@"application/x-www-form-urlencoded"  forHTTPHeaderField:@"Content-Type"];   
        [request setHTTPBody:postData];
        
        // create the connection with the request and start loading the data
        NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request  delegate:self];  
        if (theConnection) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES; 
            // Create the NSMutableData to hold the received data.
            // receivedData is an instance variable declared elsewhere.
            _receivedData = [NSMutableData data];
        } else {
            // Inform the user that the connection failed.
        }
        return  self;
    }
    return  nil;
}
+ (void)startLoadingWithURLString:(NSString *)urlString postData:(NSString *)postString delegate:(id <MyEDataLoaderDelegate>)delegate loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    MyEDataLoader *loader= [[MyEDataLoader alloc] initLoadingWithURLString:urlString postData:postString delegate:delegate loaderName:name userDataDictionary:dict];
    NSLog(@"Loader name is %@", loader.name);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse
                                                                     *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is an instance variable declared elsewhere.
    [_receivedData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [_receivedData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // inform the user
    NSLog(@"Connection failed for %@! Error - %@ %@",
          self.name,
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    if ([self.delegate respondsToSelector:@selector(connection:didFailWithError:loaderName:)]) {
        [self.delegate connection:connection didFailWithError:error loaderName:self.name];
    }
    
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (_receivedData == (NSData *)[NSNull null]) {
        NSLog(@"数据为空");
        return;
    }
    if ([_receivedData length] == 0) {
        NSLog(@"数据请求为0");
        return;
    }
    NSLog(@"Succeeded! Received %d bytes of data",[_receivedData length]);
    NSString *string = [[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
//    if([self.name isEqualToString:@"DashboardDownloader"])
//        string = @"-999";
//    if(![self _processHttpRespondForString:string])
//        return ;
    
    // 如果uploader里面带了用户数据，就调用下面函数把用户数据词典传回去
    if ([self.delegate respondsToSelector:@selector(didReceiveString:loaderName:userDataDictionary:)]) {
        [self.delegate didReceiveString:string loaderName:self.name userDataDictionary:self.userDataDictionary];
    }
    
}
-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount] == 0) {
        NSURLCredential *newCredential;
        newCredential = [NSURLCredential credentialWithUser:@"myenergydomain"
                                                   password:@"MyE090401"
                                                persistence:NSURLCredentialPersistenceNone];
        [[challenge sender] useCredential:newCredential
               forAuthenticationChallenge:challenge];
    } else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
        // inform the user that the user name and password
        // in the preferences are incorrect
        NSLog(@"user name and password is not correct to pass the authentification on www.myenergydomain.com");
    }
}
#pragma mark -
#pragma mark private methods
/* 判定是否服务器响应正常，如果正常返回一些字符串，如果服务器相应为-999/-998，
// 那么函数迫使Navigation View Controller跳转到Houselist view，并返回NO。
// 如果要中断外层函数执行，必须捕捉此函数返回的NO值，并中断外层函数。
 -999	No Connection，网络连接中断、出现硬件问题、掉电、用户人为插拔
 -998	表示温控器禁止远程控制
 -996	用户没有登录，返回登录页面
 -994	网关离线
 服务器响应正常， 返回YES，否则返回NO
 */
- (BOOL)_processHttpRespondForString:(NSString *)respondText {
    NSInteger respondInt = [respondText intValue];// 从字符串开始寻找整数，如果碰到字母就结束，如果字符串不能转换成整数，那么此转换结果就是0
    if ( respondInt == -994 ) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        MyEHouseListViewController *hlvc = [storyboard instantiateViewControllerWithIdentifier:@"HouseListVC"];
        [MainDelegate.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
        MainDelegate.window.rootViewController = hlvc;// 用主Navigation VC作为程序的rootViewController
        
        // Houselist view controller 从服务器获取最新数据。
        [hlvc downloadModelFromServer ];
        
        //获取当前正在操作的house的name
        NSString *currentHouseName = MainDelegate.houseData.houseName;
        NSString *message;

        message = [NSString stringWithFormat:@"The gateway of house %@ is disconnected.", currentHouseName];
        
        [hlvc showAutoDisappearAlertWithTile:@"Alert" message:message delay:10.0f];
        return NO;
    }
    if (respondInt == -996 ) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        MyELoginViewController *lvc = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        lvc.accountData = MainDelegate.accountData;
        [MainDelegate.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
        MainDelegate.window.rootViewController = lvc;// 用Login VC作为程序的rootViewController
        [SVProgressHUD showErrorWithStatus:@"Please sign in."];
        return NO;
    }
    if (respondInt == -999 ) {
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//        SWRevealViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SlideMenuVC"];
//        [MainDelegate.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
//        MainDelegate.window.rootViewController = vc;// 用主Navigation VC作为程序的rootViewController
        UIViewController *vc = (UIViewController *)self.delegate;
        NSLog(@"%@",vc.navigationController);
        if(vc.navigationController)
            [vc.navigationController popViewControllerAnimated:YES];
//            [vc.navigationController performSelectorOnMainThread:@selector(popToViewController:animated:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
        else
            [vc dismissViewControllerAnimated:YES completion:nil];
        [SVProgressHUD showErrorWithStatus:@"Device is disconnected."];
        return NO;
    }
    return YES;
}
@end

