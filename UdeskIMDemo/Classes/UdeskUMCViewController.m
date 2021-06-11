//
//  UdeskUMCViewController.m
//  UdeskIMDemo
//
//  Created by 陈历 on 2021/6/1.
//

#import "UdeskUMCViewController.h"
#import <CommonCrypto/CommonDigest.h>

#define SUPPORT_UMC_SDK 1

#if SUPPORT_UMC_SDK

#import <UdeskMChatSDK/UMCManager.h>
#import <UdeskMChatSDK/UdeskMChatSDK.h>
#import "UdeskMChatUIKit.h"

#endif


@interface UdeskUMCViewController ()
@property (weak, nonatomic) IBOutlet UITextField *appKeyTextField;
@property (weak, nonatomic) IBOutlet UITextField *uuidTextField;
@property (weak, nonatomic) IBOutlet UITextField *euidTextField;
@property (weak, nonatomic) IBOutlet UISwitch *serverChange;
@property (weak, nonatomic) IBOutlet UITextField *userID;

@end

@implementation UdeskUMCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
#if SUPPORT_UMC_SDK
    NSLog(@"UMC Version=%@", [UMCManager sdkVersion]);
#endif
    
    // Do any additional setup after loading the view.
}

- (IBAction)openChatRoom:(id)sender {
    
    [UMCManager setIsDeveloper:self.serverChange.on];
    NSTimeInterval s = [[NSDate date] timeIntervalSince1970];
    NSString *sha1 = [NSString stringWithFormat:@"%@%@%.f",self.uuidTextField.text, self.appKeyTextField.text, s];
    
    [self pushSetingVCWithSign:[self sha1:sha1] timestamp:[NSString stringWithFormat:@"%.f",s]];
}

- (void)pushSetingVCWithSign:(NSString *)sign timestamp:(NSString *)timestamp {
#if SUPPORT_UMC_SDK
    UMCSystem *system = [UMCSystem new];
    
    system.UUID = self.uuidTextField.text;
    system.timestamp = timestamp;
    system.sign = sign;
    
    UMCCustomer *customer = [UMCCustomer new];
    customer.euid = self.euidTextField.text;
    customer.name = @"Brook";
//    customer.cellphone = @"15101509938";
//    customer.email = @"xuchen7@udesk.cn";
//    customer.org = @"udesk5";
//    customer.tags = @"测试7,test3";
//    customer.customerDescription = @"44442212125g";
//    customer.customField = @{@"TextField_34012":@"bbbvbb",
//                             @"SelectField_533":@[@(1)],
//    };
    
    [UMCManager initWithSystem:system customer:customer completion:^(NSError *error) {
        
        UMCSDKManager *sdkManager = [[UMCSDKManager alloc] initWithMerchantEuid:@"tz"];
        sdkManager.sdkConfig = [self getConfig];
        [sdkManager pushUdeskInViewController:self completion:nil];
    
    }];
#endif
    
}

#if SUPPORT_UMC_SDK
- (UMCSDKConfig *)getConfig {
    
    UMCSDKConfig *config = [UMCSDKConfig sharedConfig];
    
#warning 这里写死了单个商品的咨询对象，实际开发中可根据需求自定义
    UMCProduct *product = [[UMCProduct alloc] init];
    product.title = @"iPhone XiPhone XiPhone XXiPhone X";
    product.image = @"https://g-search3.alicdn.com/img/bao/uploaded/i4/i3/1917047079/TB1IfFybl_85uJjSZPfXXcp0FXa_!!0-item_pic.jpg_460x460Q90.jpg";
    product.url = @"http://www.apple.com/cn";
    
    UMCProductExtras *extras = [[UMCProductExtras alloc] init];
    extras.title = @"标题";
    extras.content = @"¥9999¥9999¥9999¥9999¥999999999999";
    
    product.extras = @[extras];
    config.product = product;
            
    UMCCustomButtonConfig *customButton = [[UMCCustomButtonConfig alloc] initWithTitle:@"自定义按钮" clickBlock:^(UMCCustomButtonConfig *customButton, UMCIMViewController *viewController){
            
            //点击自定义按钮回调
            //示例里直接在回调里发送了商品消息，开发者可以根据自己需求进行修改
            //[viewController sendGoodsMessageWithModel:[self getGoodsModel]];
        NSLog(@"sss");
        }];
        
        config.showCustomButtons = YES;
        config.customButtons = @[customButton];
    
    UMCSDKStyle *styly = [UMCSDKStyle defaultStyle];
    config.sdkStyle = styly;
    
    
    
    return config;
}
#endif


- (NSString *) sha1:(NSString *)input {
    
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}
- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
