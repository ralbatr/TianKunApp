//
//  AppDelegate.m
//  TianKunApp
//
//  Created by 天堃 on 2018/3/19.
//  Copyright © 2018年 天堃. All rights reserved.
//

#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "WQTabBarViewController.h"
#import "LoginViewController.h"
#import "SVProgressHUD.h"
//share SDK
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
//微信SDK头文件
#import "WXApi.h"
//新浪微博SDK头文件
#import "WeiboSDK.h"
//新浪微博SDK需要在项目Build Settings中的Other Linker Flags添加"-ObjC"
//百度地图
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <AlipaySDK/AlipaySDK.h>
//融云
#import <RongIMLib/RongIMLib.h>

#import "XTGuidePagesViewController.h"
#import "CALayer+Transition.h"
#import "AFAppDotNetAPIClient.h"

@interface AppDelegate ()<selectDelegate,WXApiDelegate>
@property (nonatomic,strong) NetWorkEngine *netWorkEngine;
@property (nonatomic ,strong) BMKMapManager *mapManager;

@property (nonatomic ,assign) NSInteger messageNum;


@end

@implementation AppDelegate

+(instancetype)sharedAppDelegate{
    
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //注册appid
    BOOL isSucceed = [WXApi registerApp:@"wxaf103657968f1a62"];
    
    if(isSucceed){
        
    }
   
    

    [self setSDImage];
    [self configureShare];
    [self configureBaiduMap];
    [self configureRongCloud];
    
    _messageNum = 5;
    
    
    // 获取当前应用程序的UIApplication对象
    UIApplication *app = [UIApplication sharedApplication];
    
    // iOS 8 系统要求设置通知的时候必须经过用户许可。
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
    
    [app registerUserNotificationSettings:settings];
    
    // 设置应用程序右上角的"通知图标"Badge
//    app.applicationIconBadgeNumber = _messageNum;  // 根据逻辑设置

    
    
    
    [SVProgressHUD setBackgroundColor:COLOR_TEXT_BLACK];
    [SVProgressHUD setForegroundColor:COLOR_WHITE];
    [AFAppDotNetAPIClient shared];

    NSArray *images = @[@"welcome1", @"welcome2", @"welcome3"];
    BOOL y = [XTGuidePagesViewController isShow];
    if (y) {
        XTGuidePagesViewController *xt = [[XTGuidePagesViewController alloc] init];
        self.window.rootViewController = xt;
        xt.delegate = self;
        [xt guidePageControllerWithImages:images];
    }else{
        [self clickEnter];
    }

    return YES;
}
- (void)clickEnter{
//    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self  setRootController];


}

- (void)setRootController{
    self.window.rootViewController =  [self getRootViewController];
    [self.window makeKeyAndVisible];
    [self.window.layer transitionWithAnimType:TransitionAnimTypeRippleEffect subType:TransitionSubtypesFromTop curve:TransitionCurveEaseIn duration:1.0f];

    
}
-(UIViewController *)getRootViewController{
//    if ([UserInfoEngine isLogin]) {
        return  [[WQTabBarViewController alloc] init];
//    }else{
//        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[LoginViewController new]];
//        return nav;
//
//    }
}
-(void)netWorkChangeMonitoring{
    
    if (!_netWorkEngine) {
        _netWorkEngine = [[NetWorkEngine alloc]init];
    }
    [_netWorkEngine monitoringnetWorkChangeWithBaseUrl:@"http://baidu.com" networkReachabilityStatusBlock:^(NetworkReachabilityStatus networkReachabilityStatus) {
        
        self.netWorkStates = networkReachabilityStatus;
        
    }];
    
    
}
- (void)configureShare{
    /**初始化ShareSDK应用
     
     @param activePlatforms
     
     使用的分享平台集合
     
     @param importHandler (onImport)
     
     导入回调处理，当某个平台的功能需要依赖原平台提供的SDK支持时，需要在此方法中对原平台SDK进行导入操作
     
     @param configurationHandler (onConfiguration)
     
     配置回调处理，在此方法中根据设置的platformType来填充应用配置信息
     
     */
    
    [ShareSDK registerActivePlatforms:@[
                                        @(SSDKPlatformTypeSinaWeibo),
                                        @(SSDKPlatformTypeWechat),
                                        @(SSDKPlatformTypeQQ),
                                        ]
                             onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class] delegate:self];
                 break;
             case SSDKPlatformTypeQQ:
                 [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                 break;
             case SSDKPlatformTypeSinaWeibo:
                 [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                 break;
             default:
                 break;
         }
     }
                      onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {
         
         switch (platformType)
         {
             case SSDKPlatformTypeSinaWeibo:
                 //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                 [appInfo SSDKSetupSinaWeiboByAppKey:@"568898243"
                                           appSecret:@"38a4f8204cc784f81f9f0daaf31e02e3"
                                         redirectUri:@"http://www.sharesdk.cn"
                                            authType:SSDKAuthTypeBoth];
                 break;
             case SSDKPlatformTypeWechat:
                 [appInfo SSDKSetupWeChatByAppId:@"wxaf103657968f1a62"
                                       appSecret:@"1f595c95bbc52790528e24205abf76b4"];
                 break;
             case SSDKPlatformTypeQQ:
                 [appInfo SSDKSetupQQByAppId:@"100371282"
                                      appKey:@"aed9b0303e3ed1e27bae87c33761161d"
                                    authType:SSDKAuthTypeBoth];
                 break;
             default:
                 break;
         }
     }];
    //(注意：每一个case对应一个break不要忘记填写，不然很可能有不必要的错误，新浪微博的外部库如果不要客户端分享或者不需要加关注微博的功能可以不添加，否则要添加，QQ，微信，google＋这些外部库文件必须要加)

}
- (void)configureBaiduMap{
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:@"WcKHtS5ZNEUxD73CjpCyIFlVunIehuzt"  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }

}
- (void)configureRongCloud{
    [[RCIMClient sharedRCIMClient] initWithAppKey:@"YourTestAppKey"];

}
#pragma mark - 屏幕旋转相关设置
-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (self.allowRotation) {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {

}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
-(void)setSDImage{
    
    NSString *userAgent = @"";
    userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
    
    if (userAgent) {
        if (![userAgent canBeConvertedToEncoding:NSASCIIStringEncoding]) {
            NSMutableString *mutableUserAgent = [userAgent mutableCopy];
            if (CFStringTransform((__bridge CFMutableStringRef)(mutableUserAgent), NULL, (__bridge CFStringRef)@"Any-Latin; Latin-ASCII; [:^ASCII:] Remove", false)) {
                userAgent = mutableUserAgent;
            }
        }
        [[SDWebImageDownloader sharedDownloader] setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    }
    
    
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            if (_aliPayFinishBlock) {
                _aliPayFinishBlock(resultDic);
                
            }
            WQLog(@"result = %@",resultDic);
        }];
        
        // 授权跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            // 解析 auth code
            NSString *result = resultDic[@"result"];
            NSString *authCode = nil;
            if (result.length>0) {
                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                for (NSString *subResult in resultArr) {
                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                        authCode = [subResult substringFromIndex:10];
                        break;
                    }
                }
            }
            NSLog(@"授权结果 authCode = %@", authCode?:@"");
        }];
    }
    [WXApi handleOpenURL:url delegate:self];
    return YES;
}

// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            if (_aliPayFinishBlock) {
                _aliPayFinishBlock(resultDic);
                
            }

            WQLog(@"result = %@",resultDic);
        }];
        
        // 授权跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            // 解析 auth code
            NSString *result = resultDic[@"result"];
            NSString *authCode = nil;
            if (result.length>0) {
                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                for (NSString *subResult in resultArr) {
                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                        authCode = [subResult substringFromIndex:10];
                        break;
                    }
                }
            }
            NSLog(@"授权结果 authCode = %@", authCode?:@"");
        }];
    }
    [WXApi handleOpenURL:url delegate:self];
    
    return YES;
}
#pragma mark ---微信
//9.0前的方法，为了适配低版本 保留
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [WXApi handleOpenURL:url delegate:self];
}
//微信SDK自带的方法，处理从微信客户端完成操作后返回程序之后的回调方法,显示支付结果的
-(void) onResp:(BaseResp*)resp
{
    
    if (_wexinPayFinishBlock) {
        _wexinPayFinishBlock(resp.errCode,[NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr]);
        
    }
    //启动微信支付的response
    NSString *payResoult = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        switch (resp.errCode) {
            case 0:
                payResoult = @"支付结果：成功！";
                break;
            case -1:
                payResoult = @"支付结果：失败！";
                break;
            case -2:
                payResoult = @"用户已经退出支付！";
                break;
            default:
                payResoult = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr];
                break;
        }
    }
}

@end
