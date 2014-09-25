
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark View

- (void)viewDidLoad
{
    NSLog(@"[start] %@", NSStringFromSelector(_cmd));
    
    [super viewDidLoad];
    
    self.service = @"service1";
    self.account = @"account1";
    self.secret = @"helloworld1";
    self.descriptionText = @"mydescription1";
    
    NSLog(@"[service] %@", self.service);
    NSLog(@"[account] %@", self.account);
    NSLog(@"[secret] %@", self.secret);
    NSLog(@"[descriptionText] %@", self.descriptionText);
    
    NSLog(@"[end] %@", NSStringFromSelector(_cmd));
}

#pragma mark Button Click Handlers

- (IBAction)removeBtnClicked:(UIButton*) sender
{
    NSLog(@"[start] %@", NSStringFromSelector(_cmd));
    
    [self deleteSecretForService:self.service account:self.account];
    
    NSLog(@"[end] %@", NSStringFromSelector(_cmd));
}

- (IBAction)quickBtnClicked:(UIButton*) sender
{
    NSLog(@"[start] %@", NSStringFromSelector(_cmd));
    
    [self protectBtnClicked:nil];
    [self readBtnClicked:nil];
    [self readBtnClicked:nil];
    
    NSLog(@"[end] %@", NSStringFromSelector(_cmd));
}

- (IBAction) quickBtnClickedWithDelay:(UIButton*) sender
{
    NSLog(@"[start] %@", NSStringFromSelector(_cmd));
    
    [self protectBtnClicked:nil];
    [self readBtnClicked:nil];
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self readBtnClicked:nil];
        
        NSLog(@"[end 2] %@", NSStringFromSelector(_cmd));
    });
    
    NSLog(@"[end 1] %@", NSStringFromSelector(_cmd));
}

- (IBAction)readBtnClicked:(UIButton*) sender
{
    NSLog(@"[start] %@", NSStringFromSelector(_cmd));
    
    [self readSecretForService:self.service account:self.account description:self.descriptionText];
    
    NSLog(@"[end] %@", NSStringFromSelector(_cmd));
}

- (IBAction)protectBtnClicked:(UIButton*) sender
{
    NSLog(@"[start] %@", NSStringFromSelector(_cmd));
    
    [self writeSecret:self.secret service:self.service account:self.account];
    
    NSLog(@"[end] %@", NSStringFromSelector(_cmd));
}

#pragma mark Keychain API Calls

- (void) writeSecret:(NSString*) secret
             service:(NSString*) service
             account:(NSString*) account
{
    NSLog(@"[start] %@", NSStringFromSelector(_cmd));
    
    CFErrorRef error = NULL;
    
    SecAccessControlRef sacObject = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, kSecAccessControlUserPresence, &error);
    
    NSData* secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *query = @{
                            (__bridge id) kSecClass : (__bridge id) kSecClassGenericPassword,
                            (__bridge id) kSecAttrService : service,
                            (__bridge id) kSecAttrAccount : account,
                            (__bridge id) kSecValueData : secretData,
                            (__bridge id) kSecAttrAccessControl : (__bridge id) sacObject
                            };
    
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef) query, nil);
    
    NSLog(@"[status - SecItemAdd] %d - %@", (int) status, [self keychainErrorToString:status]);

    
    NSLog(@"[end] %@", NSStringFromSelector(_cmd));
}

- (void) readSecretForService:(NSString*) service
                      account:(NSString*) account
                  description:(NSString*) description
{
    NSLog(@"[start] %@", NSStringFromSelector(_cmd));
    
    NSDictionary *query = @{
                            (__bridge id) kSecClass : (__bridge id) kSecClassGenericPassword,
                            (__bridge id) kSecAttrService : service,
                            (__bridge id) kSecAttrAccount : account,
                            (__bridge id) kSecReturnData : @YES,
                            (__bridge id) kSecUseOperationPrompt : description
                            };
    
    CFTypeRef dataTypeRef = NULL;
    
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef) query, &dataTypeRef);
    
    NSLog(@"[status - SecItemCopyMatching] %d - %@", (int) status, [self keychainErrorToString:status]);
    
    if (status == noErr) {
        NSData *resultData = (__bridge NSData*) dataTypeRef;
        NSString* result = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
        
        NSLog(@"[result - SecItemCopyMatching] %@", result);
    }
    
    NSLog(@"[end] %@", NSStringFromSelector(_cmd));
}

- (void) deleteSecretForService:(NSString*) service account: (NSString *)account
{
    NSLog(@"[start] %@", NSStringFromSelector(_cmd));
    
    NSDictionary* query = @{
                            (__bridge id) kSecClass: (__bridge id) kSecClassGenericPassword,
                            (__bridge id) kSecAttrService : service,
                            (__bridge id) kSecAttrAccount :account
                            };
    
    
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef) query);
    
    NSLog(@"[status - SecItemDelete] %d - %@", (int) status, [self keychainErrorToString:status]);
    
    NSLog(@"[end] %@", NSStringFromSelector(_cmd));
}

#pragma mark Unrelated Methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSString*) keychainErrorToString:(OSStatus) error
{
    
    NSString *msg = [NSString stringWithFormat:@"%ld", (long) error];
    
    switch (error) {
        
        case errSecSuccess:
            msg = NSLocalizedString(@"Success.", nil);
            break;
        
        case errSecIO:
            msg = NSLocalizedString(@"I/O error.", nil);
            break;
            
        case errSecOpWr:
            msg = NSLocalizedString(@"File already open with with write permission.", nil);
            break;
            
        case errSecUnimplemented:
            msg = NSLocalizedString(@"Function or operation not implemented.", nil);
            break;
        
        case errSecParam:
            msg = NSLocalizedString(@"One or more parameters passed to a function where not valid.", nil);
            break;

        case errSecAllocate:
            msg = NSLocalizedString(@"Failed to allocate memory.", nil);
            break;
            
        case errSecUserCanceled:
            msg = NSLocalizedString(@"User canceled the operation.", nil);
            break;
            
        case errSecBadReq:
            msg = NSLocalizedString(@"Bad parameter or invalid state for operation.", nil);
            break;
            
        case errSecInternalComponent:
            msg = NSLocalizedString(@"Internal component error.", nil);
            break;
         
        case errSecNotAvailable:
            msg = NSLocalizedString(@"No keychain is available. You may need to restart your computer.", nil);
            break;
            
        case errSecDuplicateItem:
            msg = NSLocalizedString(@"The specified item already exists in the keychain.", nil);
            break;
        
        case errSecItemNotFound :
            msg = NSLocalizedString(@"The specified item could not be found in the keychain.", nil);
            break;
        
        case errSecAuthFailed:
            msg = NSLocalizedString(@"The user name or passphrase you entered is not correct.", nil);
            break;
            
        case errSecInteractionNotAllowed:
            msg = NSLocalizedString(@"User interaction is not allowed.", nil);
            break;
        
        case errSecDecode:
            msg = NSLocalizedString(@"Unable to decode the provided data.", nil);
            break;
            
        default:
            msg = NSLocalizedString(@"Unknown error.", nil);
            break;
    }
    
    return msg;
}

@end
