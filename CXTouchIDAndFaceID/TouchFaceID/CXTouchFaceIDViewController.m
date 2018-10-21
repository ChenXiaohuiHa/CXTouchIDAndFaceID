//
//  CXTouchFaceIDViewController.m
//  CXTouchIDAndFaceID
//
//  Created by 陈晓辉 on 2018/10/14.
//  Copyright © 2018年 陈晓辉. All rights reserved.
//

#import "CXTouchFaceIDViewController.h"

#import "CXTouchFaceID.h"

#define kScreen_Width [UIScreen mainScreen].bounds.size.width
#define kScreen_Height [UIScreen mainScreen].bounds.size.height

@interface CXTouchFaceIDViewController ()<CXTouchFaceIDDelegate>

/** 验证对象 */
@property (nonatomic, strong) CXTouchFaceID *touchFaceID;

/** 提示框按钮 */
@property (nonatomic, strong) UIAlertAction *confirmAction;

@end

@implementation CXTouchFaceIDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadTouchFaceID];
    [self setUpBackgroudView];
}
//MARK: 初始化验证对象
- (void)loadTouchFaceID {
    
    CXTouchFaceID *touchFaceID = [[CXTouchFaceID alloc] init];
    touchFaceID.delegate = self;
    [touchFaceID showTouchFaceIDWithLocalizedReason:@"验证信息" localizedFallbackTitle:@"密码输入" delegate:self];
}
//MARK: 设置视图背景
- (void)setUpBackgroudView {
    
    UIImage *image = [UIImage imageNamed:@"test.jpg"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
    imageView.image = image;
    [self.view addSubview:imageView];
}




/**
 验证失败, 或使用密码
 
 @param resultCode 失败原因, 枚举
 */
- (void)CXTouchFaceIDAuthorizeFailureWithResultCode:(CXTouchFaceIDResultCode)resultCode {
    
    switch (resultCode) {
        case CXTouchFaceIDResultCodeSuccess:
            //验证成功
            NSLog(@"验证成功");
            [self imageViewShowAnimation];
            break;
        case CXTouchFaceIDAuthenticationFailed:
            //TouchID验证失败, 3次验证失败时, 调用
            //身份验证不成功，因为用户无法提供有效的凭据。
            NSLog(@"身份验证失败, 3次验证失败时, 调用");
            break;
        case CXTouchFaceIDUserCancel:
            //取消TouchID验证 (用户点击了取消)
            //认证被用户取消(例如用户点击了取消按钮)。
            NSLog(@"认证被用户取消(例如用户点击了取消按钮)");
            break;
        case CXTouchFaceIDUserFallback:
            //在TouchID对话框中点击输入密码按钮
            //认证被取消了,因为用户利用回退按钮(输入密码)。在TouchID对话框中点击输入密码按钮
            NSLog(@"在TouchID对话框中点击输入密码按钮");
            [self alertViewWithEnterPassword:YES];
            break;
        case CXTouchFaceIDSystemCancel:
            //在验证的TouchID的过程中被系统取消 例如突然来电话、按了Home键、锁屏...
            NSLog(@"在验证的TouchID的过程中被系统取消 例如突然来电话、按了Home键、锁屏...");
            break;
        case CXTouchFaceIDPasscodeNotSet:
            //无法启用TouchID,设备没有设置密码
            //身份验证无法启动,因为设备没有设置密码。
            NSLog(@"无法启用TouchID,设备没有设置密码");
            break;
        case CXTouchFaceIDBiometryNotAvailable:
            //该设备的TouchID无效
            //身份验证无法启动,因为触摸ID不可用在设备上。
            NSLog(@"该设备的TouchID无效");
            break;
        case CXTouchFaceIDBiometryNotEnrolled:
            //设备没有录入TouchID,无法启用TouchID
            //身份验证无法启动,因为没有登记的手指触摸ID。
            //身份验证无法启动，因为生物识别没有录入信息。
            NSLog(@"设备没有录入TouchID,无法启用TouchID");
            break;
        case CXTouchFaceIDBiometryLockout:
            //如果多次验证失败后, Touch ID 会自动锁定,需要去设置中, 重新解锁手机, 在解锁之前, 手机 Touch ID 失效
            //验证不成功,因为有太多的失败的触摸ID尝试和触///摸现在ID是锁着的。
            //解锁TouchID必须要使用密码，例如调用LAPolicyDeviceOwnerAuthenti//cationWithBiometrics的时候密码是必要条件。
            //身份验证不成功，因为有太多失败的触摸ID尝试和触摸ID现在被锁定
            //身份验证不成功，因为太多次的验证失败并且生物识别验证是锁定状态。此时，必须输入密码才能解锁。例如LAPolicyDeviceOwnerAuthenticationWithBiometrics时候将密码作为先决条件。。
            NSLog(@"多次连续使用Touch ID失败，Touch ID被锁，需要用户输入密码解锁");
            break;
        case CXTouchFaceIDAppCancel:
            //当前软件被挂起取消了授权(如突然来了电话,应用进入前台)
            //应用程序取消了身份验证（例如在进行身份验证时调用了无效）。
            NSLog(@"当前软件被挂起取消了授权(如突然来了电话,应用进入前台)");
            break;
        case CXTouchFaceIDInvalidContext:
            //当前软件被挂起取消了授权 (授权过程中,LAContext对象被释)
            //LAContext传递给这个调用之前已经失效。
            NSLog(@"当前软件被挂起取消了授权 (授权过程中,LAContext对象被释)败");
            break;
        case CXTouchFaceIDNotInteractive:
            //身份验证失败。因为这需要显示UI已禁止使用interactionNotAllowed属性。
            NSLog(@"身份验证失败。因为这需要显示UI已禁止使用interactionNotAllowed属性。");
            break;
            
        default:
            break;
    }
}


//if it is not support touch ID,then input password
- (void)alertViewWithEnterPassword:(BOOL)isTrue {
    UIAlertController *alertVC;
    if (isTrue)
    {
        alertVC = [UIAlertController alertControllerWithTitle:@"密码输入" message:@"请再次输入密码" preferredStyle:UIAlertControllerStyleAlert];
    }
    else
    {
        alertVC = [UIAlertController alertControllerWithTitle:@"密码错误" message:@"请再次输入密码" preferredStyle:UIAlertControllerStyleAlert];
    }
    
    
    UIAlertAction *backAction = [UIAlertAction actionWithTitle:@"Back Touch" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:alertVC.textFields.firstObject];
        
        [self.touchFaceID showTouchFaceIDWithLocalizedReason:@"验证信息" localizedFallbackTitle:@"密码输入" delegate:self];
        
    }];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:alertVC.textFields.firstObject];
        
        //验证 用户输入值, 是否正确, 这里默认 123456
        if ([alertVC.textFields.firstObject.text isEqualToString:@"123456"])
        {
            [self imageViewShowAnimation];
        }
        else
        {
            [self alertViewWithEnterPassword:NO];
        }
    }];
    
    confirmAction.enabled = NO;
    self.confirmAction = confirmAction;
    __weak typeof(self)weakSelf = self;
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(alertTextFieldChangeTextNotificationHandler:) name:UITextFieldTextDidChangeNotification object:textField];
    }];
    
    [alertVC addAction:backAction];
    [alertVC addAction:confirmAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)alertTextFieldChangeTextNotificationHandler:(NSNotification *)notification {
    
    UITextField *textField = notification.object;
    self.confirmAction.enabled = textField.text.length > 5;
}
//successed,show animation
- (void)imageViewShowAnimation {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.view.alpha = 0;
            self.view.transform = CGAffineTransformMakeScale(1.5, 1.5);
            
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
            
            [self.view.window resignKeyWindow];
            self.view.window.hidden = YES;
        }];
    });
}

@end
