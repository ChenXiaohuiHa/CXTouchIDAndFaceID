//
//  CXTouchFaceID.h
//  CXTouchIDAndFaceID
//
//  Created by 陈晓辉 on 2018/10/14.
//  Copyright © 2018年 陈晓辉. All rights reserved.
//

#import <LocalAuthentication/LocalAuthentication.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CXTouchFaceIDResultCode) {
    
    //验证成功
    CXTouchFaceIDResultCodeSuccess,
    
    //身份验证不成功，因为用户无法提供有效的凭据,3次验证失败时, 调用。
    CXTouchFaceIDAuthenticationFailed,
    
    //认证被用户取消(例如用户点击了取消按钮)。
    CXTouchFaceIDUserCancel,
    
    //认证被取消了,因为用户利用回退按钮(输入密码)。在TouchID对话框中点击输入密码按钮
    CXTouchFaceIDUserFallback,
    
    //在验证的TouchID的过程中被系统取消 例如突然来电话、按了Home键、锁屏...
    CXTouchFaceIDSystemCancel,
    
    //身份验证无法启动,因为设备没有设置密码。
    CXTouchFaceIDPasscodeNotSet,
    
    //身份验证无法启动,因为TouchID无效。
    CXTouchFaceIDBiometryNotAvailable,
    
    //身份验证无法启动，因为生物识别没有录入信息。
    CXTouchFaceIDBiometryNotEnrolled,
    
    //如果多次验证失败后, Touch ID 会自动锁定,需要去设置中, 重新解锁手机, 在解锁之前, 手机 Touch ID 失效
    //验证不成功,因为有太多的失败的TouchID尝试和触。
    //解锁TouchID必须要使用密码，例如调用LAPolicyDeviceOwnerAuthenti//cationWithBiometrics的时候密码是必要条件。
    //身份验证不成功，因为有太多失败的TouchID尝试和TouchID现在被锁定
    //身份验证不成功，因为太多次的验证失败并且生物识别验证是锁定状态。此时，必须输入密码才能解锁。例如LAPolicyDeviceOwnerAuthenticationWithBiometrics时候将密码作为先决条件。。
    CXTouchFaceIDBiometryLockout,
    
    //当前软件被挂起取消了授权(如突然来了电话,应用进入前台)
    //应用程序取消了身份验证（例如在进行身份验证时调用了无效）。
    CXTouchFaceIDAppCancel,
    
    //当前软件被挂起取消了授权 (授权过程中,LAContext对象被释)
    //LAContext传递给这个调用之前已经失效。
    CXTouchFaceIDInvalidContext,
    
    //身份验证失败。因为这需要显示UI已禁止使用interactionNotAllowed属性。
    CXTouchFaceIDNotInteractive,
};
@protocol CXTouchFaceIDDelegate <NSObject>


/**
 验证结果
 
 @param resultCode 验证结果, 枚举
 */
- (void)CXTouchFaceIDAuthorizeFailureWithResultCode:(CXTouchFaceIDResultCode)resultCode;

@end

@interface CXTouchFaceID : LAContext

/** 验证结果枚举 */
@property (nonatomic, assign) CXTouchFaceIDResultCode resultCode;

/** 代理协议 */
@property (nonatomic, weak) id<CXTouchFaceIDDelegate> delegate;

/**
 开始身份验证
 
 @param localizedReason 提示语
 @param localizedFallbackTitle 验证失败按钮标题
 @param delegate 代理回调
 */
- (void)showTouchFaceIDWithLocalizedReason:(NSString *)localizedReason localizedFallbackTitle:(NSString *)localizedFallbackTitle delegate:(id<CXTouchFaceIDDelegate>)delegate;

@end


NS_ASSUME_NONNULL_END
