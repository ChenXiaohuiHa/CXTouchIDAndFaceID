//
//  CXTouchFaceIDWindow.m
//  CXTouchIDAndFaceID
//
//  Created by 陈晓辉 on 2018/10/14.
//  Copyright © 2018年 陈晓辉. All rights reserved.
//

#import "CXTouchFaceIDWindow.h"

#import "CXTouchFaceIDViewController.h"
#import <LocalAuthentication/LAContext.h>

@interface CXTouchFaceIDWindow ()

/** ObjC */
@property (nonatomic, strong) LAContext *context;

@end
@implementation CXTouchFaceIDWindow

+ (void)load {
    
    [self shareManager];
}
static CXTouchFaceIDWindow *instance = nil;
+ (CXTouchFaceIDWindow *)shareManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CXTouchFaceIDWindow alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        //监听程序启动完成通知
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            
            //MARK: step-1 初始化, 并显示 touchID / faceID
            //这里也创建一个 window, 并这只较高的优先级, 这样touchWindow 将显示在 self.window 的上方,以便验证成功后, 直接移除, 并显示加载完成的 self.window
            instance = [instance initWithFrame:[UIScreen mainScreen].bounds];
            [instance show];
            NSLog(@"DidFinishLaunching");
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            
            [instance show];
            NSLog(@"WillEnterForeground");
        }];
    }
    return self;
}


/*
 LocalAuthentication是用来实现iOS中的生物识别(指纹)的，自从iPhone5s加入TouchID后，LocalAuthentication也越来越受到关注。
 
 LocalAuthentication 以 LAContext 的方式工作，先用canEvaluatePolicy:error:方法判断机器是否具有指纹识别的功能，再用evaluatePolicy:localizedReason:reply:方法来实现指纹识别功能。整个过程中，用户的生物信息都被安全的存储在硬件当中。
 
 LocalAuthentication的支持库是LocalAuthentication.framework
*/
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        //设置较高的优先级, 默认 window 优先级为 0, UIWindowLevelAlert = 2000
        self.windowLevel = UIWindowLevelAlert;
        self.rootViewController = [CXTouchFaceIDViewController new];
    }
    return self;
}

/**
 显示 touch window
 */
- (void)show {
    
    [self makeKeyAndVisible];
    self.hidden = NO;
}

@end
