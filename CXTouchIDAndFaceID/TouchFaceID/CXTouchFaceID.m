//
//  CXTouchFaceID.m
//  CXTouchIDAndFaceID
//
//  Created by 陈晓辉 on 2018/10/14.
//  Copyright © 2018年 陈晓辉. All rights reserved.
//

#import "CXTouchFaceID.h"


@implementation CXTouchFaceID

- (void)showTouchFaceIDWithLocalizedReason:(NSString *)localizedReason localizedFallbackTitle:(NSString *)localizedFallbackTitle delegate:(nonnull id<CXTouchFaceIDDelegate>)delegate {
    
    self.delegate = delegate;
    
    //创建安全验证对象
    LAContext *context = [[LAContext alloc] init];
    if (localizedFallbackTitle.length > 0) {
        context.localizedFallbackTitle = localizedFallbackTitle;
    }else{
        //localizedFallbackTitle＝@"",不会出现“输入密码”按钮
//        context.localizedFallbackTitle = @"";
    }
    
    /**
     需要先判断是否支持识别
     这里有两种验证方式可选：
     1. LAPolicyDeviceOwnerAuthentication
     iOS 9.0以上支持，包含指纹验证与输入密码的验证方式,手机密码的验证方式
     2. LAPolicyDeviceOwnerAuthenticationWithBiometrics
     iOS8.0以上支持，只有指纹验证功能,指纹的验证方式，使用这种方式需要设置 context.localizedFallbackTitle = @""; 否则在验证失败时会出现点击无响应的“输入密码”按钮
     */
    //错误对象
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        
        /**
         需要先判断是否支持指纹或者Face ID识别后，才能判断是什么类型的识别方式
         */
        if (@available(ios 11.0, *)) {
            if (context.biometryType == LABiometryTypeNone) {
                
                //
                NSLog(@"LABiometryNone");
            }else if (context.biometryType == LABiometryTypeFaceID) {
                
                //支持 Touch ID
                context.localizedReason = localizedReason;
                NSLog(@"LABiometryTypeFaceID");
            }else if (context.biometryType == LABiometryTypeTouchID) {
                
                //支持 Face ID
                //使用FaceID需要在info.plist中增加NSFaceIDUsageDescription权限申请说明，这个跟定位、拍照等一样，如果不增加默认提示如下，虽然不会崩溃，但最好还是加上。
                NSLog(@"LABiometryTypeTouchID");
            }
        }
        
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:localizedReason reply:^(BOOL success, NSError *error) {
            
            if (success) { //识别成功
                
                [self touchFaceIDAuthorizeFailureWithErrorCode:error.code];
            }else{ //识别失败
                
                //多次连续使用Touch ID失败，Touch ID被锁，需要用户输入密码解锁
                if(error.code == LAErrorBiometryLockout) {
                    
                    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error]) {
                        [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:localizedReason reply:^(BOOL success, NSError * _Nullable error) {
                            
                            if (success) {
                                
                                [self touchFaceIDAuthorizeFailureWithErrorCode:error.code];
                            }else{
                                //识别失败,要求用户重新登录,(业务)
                                NSLog(@"识别失败: %@",error);
                                [self touchFaceIDAuthorizeFailureWithErrorCode:error.code];
                            }
                        }];
                    } else{
                        NSLog(@"调起账号密码页面失败!!!");
                    }
                }else{
                    
                    //识别失败,要求用户重新登录,(业务)
                    NSLog(@"识别失败: %@",error);
                    [self touchFaceIDAuthorizeFailureWithErrorCode:error.code];
                }
            }
        }];
    }else{
        
        NSLog(@"设备不支持生物识别, 调起TouchUD,FaceID失败!!!");
    }
}

- (void)touchFaceIDAuthorizeFailureWithErrorCode:(LAError)errorCode {
    
    switch (errorCode) {
        case LAErrorAuthenticationFailed:
            //TouchID验证失败, 3次验证失败时, 调用
            //身份验证不成功，因为用户无法提供有效的凭据。
            self.resultCode = CXTouchFaceIDAuthenticationFailed;
            break;
        case LAErrorUserCancel:
            //取消TouchID验证 (用户点击了取消)
            //认证被用户取消(例如用户点击了取消按钮)。
            self.resultCode = CXTouchFaceIDUserCancel;
            break;
        case LAErrorUserFallback:
            //在TouchID对话框中点击输入密码按钮
            //认证被取消了,因为用户利用回退按钮(输入密码)。在TouchID对话框中点击输入密码按钮
            self.resultCode = CXTouchFaceIDUserFallback;
            break;
        case LAErrorSystemCancel:
            //在验证的TouchID的过程中被系统取消 例如突然来电话、按了Home键、锁屏...
            self.resultCode = CXTouchFaceIDSystemCancel;
            break;
        case LAErrorPasscodeNotSet:
            //无法启用TouchID,设备没有设置密码
            //身份验证无法启动,因为设备没有设置密码。
            self.resultCode = CXTouchFaceIDPasscodeNotSet;
            break;
        case LAErrorBiometryNotAvailable:
            //该设备的TouchID无效
            //身份验证无法启动,因为触摸ID不可用在设备上。
            self.resultCode = CXTouchFaceIDBiometryNotAvailable;
            break;
        case LAErrorBiometryNotEnrolled:
            //设备没有录入TouchID,无法启用TouchID
            //身份验证无法启动,因为没有登记的手指触摸ID。
            //身份验证无法启动，因为生物识别没有录入信息。
            self.resultCode = CXTouchFaceIDBiometryNotEnrolled;
            break;
        case LAErrorBiometryLockout:
            //如果多次验证失败后, Touch ID 会自动锁定,需要去设置中, 重新解锁手机, 在解锁之前, 手机 Touch ID 失效
            //验证不成功,因为有太多的失败的触摸ID尝试和触///摸现在ID是锁着的。
            //解锁TouchID必须要使用密码，例如调用LAPolicyDeviceOwnerAuthenti//cationWithBiometrics的时候密码是必要条件。
            //身份验证不成功，因为有太多失败的触摸ID尝试和触摸ID现在被锁定
            //身份验证不成功，因为太多次的验证失败并且生物识别验证是锁定状态。此时，必须输入密码才能解锁。例如LAPolicyDeviceOwnerAuthenticationWithBiometrics时候将密码作为先决条件。。
            self.resultCode = CXTouchFaceIDBiometryLockout;
            break;
        case LAErrorAppCancel:
            //当前软件被挂起取消了授权(如突然来了电话,应用进入前台)
            //应用程序取消了身份验证（例如在进行身份验证时调用了无效）。
            self.resultCode = CXTouchFaceIDAppCancel;
            break;
        case LAErrorInvalidContext:
            //当前软件被挂起取消了授权 (授权过程中,LAContext对象被释)
            //LAContext传递给这个调用之前已经失效。
            self.resultCode = CXTouchFaceIDInvalidContext;
            break;
        case LAErrorNotInteractive:
            //身份验证失败。因为这需要显示UI已禁止使用interactionNotAllowed属性。
            self.resultCode = CXTouchFaceIDNotInteractive;
            break;
        default:
            //成功
            self.resultCode = CXTouchFaceIDResultCodeSuccess;
            break;
    }
    
    __weak typeof(self)weakSelf = self;
    if ([self.delegate respondsToSelector:@selector(CXTouchFaceIDAuthorizeFailureWithResultCode:)]) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            [self.delegate CXTouchFaceIDAuthorizeFailureWithResultCode:weakSelf.resultCode];
        }];
    }
}


@end
