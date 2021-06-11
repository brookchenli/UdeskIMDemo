//
//  UdeskIMViewController.m
//  UdeskIMDemo
//
//  Created by 陈历 on 2021/6/1.
//

#import "UdeskIMViewController.h"

#define SUPPORT_IM_SDK 1

#if SUPPORT_IM_SDK
#import <UdeskSDK/Udesk.h>
#endif

@interface UdeskIMViewController ()
@property (weak, nonatomic) IBOutlet UITextField *dominTextField;
@property (weak, nonatomic) IBOutlet UITextField *appKeyTextField;
@property (weak, nonatomic) IBOutlet UITextField *appIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *sdkTokenTextField;

@end

@implementation UdeskIMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if SUPPORT_IM_SDK
    NSLog(@"IM SDK Version=%@", [UdeskManager sdkVersion]);
#endif
    // Do any additional setup after loading the view.
}
- (IBAction)openIM:(id)sender {
#if SUPPORT_IM_SDK
    
    NSString *sdk_token = self.sdkTokenTextField.text;
   
    UdeskOrganization *organization = [[UdeskOrganization alloc] initWithDomain:self.dominTextField.text
                                                                         appKey:self.appKeyTextField.text
                                                                          appId:self.appIdTextField.text];
    
    UdeskCustomer *customer = [UdeskCustomer new];
    customer.sdkToken = sdk_token;

    [UdeskManager initWithOrganization:organization customer:customer];
    
    UdeskSDKStyle *style = [UdeskSDKStyle customStyle];
    UdeskSDKConfig *config = [UdeskSDKConfig customConfig];
    
    //初始化sdk
    UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:style sdkConfig:config sdkActionConfig:nil];
    [chatViewManager pushUdeskInViewController:self completion:nil];
#endif
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
