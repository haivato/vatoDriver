//
//  NSObject.m
//  FaceCar
//
//  Created by Vu Dang on 6/6/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "NSObject+Helper.h"
#import "FCToast.h"
#import "AppDelegate.h"
#import "libPhoneNumberiOS.h"
#import "FCTrackingHelper.h"

#if DEV
#import "Driver_DEV-Swift.h"
#else
#import "VATO_Driver-Swift.h"
#endif

static AVAudioPlayer *audioPlayer;
@implementation NSObject (Helper)

#pragma mark -
- (void) saveAppVersion :(NSString*) version {
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:@"current_version"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*) getCurrentAppVersion {
    NSString* version = [[NSUserDefaults standardUserDefaults] valueForKey:@"current_version"];
    return version;
}

#pragma mark -
- (BOOL) isNetworkAvailable {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    AFNetworkReachabilityStatus st = [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus];
    if (st == AFNetworkReachabilityStatusNotReachable) {
        return FALSE;
    }
    return TRUE;
}

- (void) playsound:(NSString *)soundname
{
    [self playsound:soundname withVolume:1.0f isLoop:NO];
}

- (void) playsound:(NSString *)soundname
            ofType:(NSString*) type
        withVolume:(CGFloat)volume
            isLoop:(BOOL)loop {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSURL* musicFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:soundname ofType:type]];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile error:nil];
    if (loop)
    {
        audioPlayer.numberOfLoops = -1;
    }
    else
    {
        audioPlayer.numberOfLoops = 0;
    }
    
    [audioPlayer setVolume:volume];
    [audioPlayer prepareToPlay];
    [audioPlayer play];
}

- (void) playsound:(NSString *)soundname withVolume:(CGFloat)volume isLoop:(BOOL)loop
{
    [self playsound:soundname
             ofType:@"mp3"
         withVolume:volume
             isLoop:loop];
}

- (void) stopSound
{
    if (audioPlayer)
    {
        [audioPlayer stop];
        audioPlayer = nil;
    }
}

- (void) vibrateDevice
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void) showMessageBanner: (NSString*) message status:(BOOL) succ {
    if (message.length == 0) {
        return;
    }
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    FCToast* toastView = [[FCToast alloc] initView];
    toastView.message.text = message;
    toastView.parentView = appDelegate.window;
    if (!succ)
        toastView.bg.backgroundColor = [UIColor redColor];
    [appDelegate.window addSubview:toastView];
    [toastView show];
}

- (NSDate*)getDateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];
    return [calendar dateFromComponents:components];
}

- (NSDate*) getCurrentDate {
    return [NSDate date];
}

- (double) getCurrentTimeStamp {
    NSTimeInterval time = [FireBaseTimeHelper default].currentTime;
    return time;//[[NSDate date] timeIntervalSince1970] * 1000;
}

- (double) getTimestampOfDate:(NSDate *)date
{
    if (date != nil)
    {
        return [date timeIntervalSince1970] * 1000;
    }
    
    return -1;
}

- (NSString*) getTimeString:(double)timeStamp {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp/1000.0];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm dd/MM/yyyy";
    return [dateFormatter stringFromDate:date];
}

- (NSString*) getTimeString:(long long) timeStamp withFormat: (NSString*) format {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp/1000.0];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    return [dateFormatter stringFromDate:date];
}

- (NSString*) getTimeStringByDate:(NSDate*)date {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd/MM/yyyy";
    return [dateFormatter stringFromDate:date];
}

- (NSString*) getTimeYYYYMMString:(double)timeStamp {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp/1000.0];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMM";
    return [dateFormatter stringFromDate:date];
}

- (BOOL) theSameDay:(long long)date1 and:(long long)date2 {
    if (date1 > 0 && date2 > 0) {
        NSDate* day1 = [NSDate dateWithTimeIntervalSince1970:date1/1000];
        NSDate* day2 = [NSDate dateWithTimeIntervalSince1970:date2/1000];
        return [[NSCalendar currentCalendar] isDate:day1 inSameDayAsDate:day2];
    }
    
    return NO;
}

- (NSString*) getMinuteAndSecond:(NSInteger)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
//    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

- (NSString*) getHourAndMinuteAndSecond:(NSInteger)totalSeconds
{
    totalSeconds = totalSeconds / 1000.0f;
    int seconds = (int) totalSeconds % 60;
    int minutes = (int)(totalSeconds / 60) % 60;
    int hours = (int)totalSeconds / 3600;
    
    if (hours > 0)
    {
        return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    }
    else
    {
        return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }
    
}

- (NSInteger) getColorCodeFromString: (NSString*) rgb {
    unsigned result = 0;
    NSScanner *scanner = [NSScanner scannerWithString:rgb];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&result];
    
    return result;
}

- (CLLocationDistance) getDistance:(CLLocation*) from fromMe: (CLLocation*) to {
    CLLocationDistance distance = [to distanceFromLocation:from];
    
//    DLog(@"--------- Distance from (%f, %f) - to (%f, %f): %f",from.coordinate.latitude, from.coordinate.longitude, to.coordinate.latitude, to.coordinate.longitude, distance/1000.0f)
    
    return distance;
}

- (__autoreleasing NSString *)getAppVersion {
    __autoreleasing NSDictionary<NSString*,id> *info = [[NSBundle mainBundle] infoDictionary];
    __autoreleasing NSString *version = (NSString*) info[@"CFBundleShortVersionString"];
    return version;
}

- (__autoreleasing NSString *)getBundleIdentifier {
    __autoreleasing NSDictionary<NSString*,id> *info = [[NSBundle mainBundle] infoDictionary];
    __autoreleasing NSString *bundleIdentifier = (NSString*) info[@"CFBundleIdentifier"];
    return bundleIdentifier;
}

- (void) callPhone: (NSString*) phone {
    phone = [[[[phone stringByReplacingOccurrencesOfString:@"+84" withString:@"0"] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""];
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phone]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    }
}

- (BOOL) validPhone :(NSString*) phone {
    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
    NSError *anError = nil;
    NBPhoneNumber *myNumber = [phoneUtil parse:phone
                                 defaultRegion:@"VN" error:&anError];
    if (!anError) {
        NSString* national = [phoneUtil format:myNumber
                                  numberFormat:NBEPhoneNumberFormatNATIONAL
                                         error:&anError]; // = 902xxx (phone is 0902xxx)
        national = [national stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSLog(@"NATIONAL : %@", national);
        // prevent enter 11 numbers
        if (national.length > 10) {
            return NO;
        }
        return [phoneUtil isValidNumber:myNumber];
    }
    
    return NO;
}

- (BOOL) validEmail :(NSString*) email {
    email = [email stringByReplacingOccurrencesOfString:@" " withString:@""];
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL result = [emailTest evaluateWithObject:email];
    
    return result;
}

- (BOOL) validBankAccount: (NSString*) bankaccount {
    NSString *specialCharacterString = @"!~`@#$%^&*-+();:={}[],.<>?\\/\"\' ";
    NSCharacterSet *specialCharacterSet = [NSCharacterSet
                                           characterSetWithCharactersInString:specialCharacterString];
    
    if ([bankaccount.lowercaseString rangeOfCharacterFromSet:specialCharacterSet].length) {
        return NO;
    }
    
    return YES;
}

- (NSString*) convertAccessString : (NSString*)input {
    DLog(@"-------- Input: %@", input)
    
    NSData *data = [input dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *newStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    DLog(@"-------- Output: %@", newStr)
    return newStr;
}

- (NSString*) formatPrice :(long) _priceNum {
    NSNumberFormatter* priceFormat = [[NSNumberFormatter alloc] init];
    priceFormat.currencyCode = @"VND";
    priceFormat.currencySymbol = @"";
    [priceFormat setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString* priceStr = [priceFormat stringFromNumber:[NSNumber numberWithLong:_priceNum]];
    return [NSString stringWithFormat:@"%@đ",priceStr];
}

- (NSString*) formatPrice:(long)priceNum withSeperator:(NSString *)seperator
{
    NSNumberFormatter* priceFormat = [[NSNumberFormatter alloc] init];
    [priceFormat setNumberStyle:NSNumberFormatterDecimalStyle];
    [priceFormat setGroupingSize:3];
    [priceFormat setGroupingSeparator:seperator];
    return [priceFormat stringFromNumber:[NSNumber numberWithLong:priceNum]];
}

- (NSInteger) getPrice : (NSString*) str {
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890"] invertedSet];
    NSString *resultString = [[str componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    NSLog (@"Result: %@", resultString);
    return resultString.integerValue;
}

- (long) roundUpPrice: (long) price {
    
    if (price%1000 == 0) {
        return price;
    }
    
    return (price/1000 + 1) * 1000;
}

- (long) caculatePrice : (FCFareSetting*) receipe distance: (long) distance duration:(long)duration timeWait:(long)wait {
    long    perkm, // don gia / km
    limitedperkm,
    perHour,// don gia / 1 gio
    perMinute, // don gia di chuyen / 1 phut
    TienTime = 0,
    TienKM,
    FirstKM,
    TongTien,
    tempPerTime = 0;
    
    double  kms, // tong so km
    waitTimes; // thoi gian cho (tinh bang gio)
    
    kms = distance/1000.0; // tong km di
    waitTimes = wait/(1000*3600); // thoi gian cho tinh bang gio
    
    perkm = receipe.perKm;
    limitedperkm = perkm * 70 / 100;
    
    perHour = receipe.perHour;
    perMinute = receipe.perMin;
    
    FirstKM = receipe.firstKm; //gia mo cua
    TienKM = FirstKM + (long) (kms * perkm);
    for (int i = 0; i < waitTimes; i++)
    {
        if (i < 5)            {
            tempPerTime = perHour - perHour * i / 10;
            TienTime = (long)(TienTime + tempPerTime);
        }
        else
        {
            TienTime = TienTime + tempPerTime;
        }
    }
    
    TongTien = TienKM + TienTime + duration/60* perMinute;
    int TempTongTien = (int) TongTien / 1000;
    TongTien = TempTongTien * 1000;
    
    NSInteger result = TongTien + TongTien * receipe.percent/100;
    return MAX(result, receipe.min);
}

- (long) caculatePrice : (FCFareSetting*) receipe
               distance: (long) distance
            timeRunning: (long) running
               finished: (BOOL) finished {
    long    perkm, // don gia / km
    limitedperkm,
    perMinute, // don gia di chuyen / 1 phut
    TienTime = 0,
    TienKM,
    FirstKM,
    TongTien;
    
    double  kms, // tong so km
    runningTimes; // thoi gian cho (tinh bang gio)
    
    
    kms = distance/1000.0; // tong km di
    runningTimes = running/60; // thoi gian cho tinh bang phut
    
    perkm = receipe.perKm;
    limitedperkm = perkm * 70 / 100;
    
    perMinute = receipe.perMin;
    
    FirstKM = receipe.firstKm; //gia mo cua
    TienKM = FirstKM + (long) (kms * perkm);
    
    TienTime = (long) (runningTimes * perMinute);
    
    TongTien = TienKM + TienTime;
    
    NSInteger result = TongTien + TongTien * receipe.percent/100;
    if (finished) {
        return MAX(result, receipe.min);
    }
    return result;
}

- (NSString*) formatDistance:(NSInteger)meter
{
    NSInteger kilometer = meter / 1000;
    NSInteger hundredMeter = meter / 100;
    
    if (hundredMeter > 0)
    {
        return [NSString stringWithFormat:@"%ld,%ld km", (long)kilometer, (long)hundredMeter];
    }
    else
    {
        return [NSString stringWithFormat:@"%ld m", (long)meter];
    }
}

- (void)setViewRoundCorner:(UIView*)view withRadius:(CGFloat)radius
{
    view.layer.cornerRadius = radius;
    view.clipsToBounds = YES;
}

- (NSString*) getDeviceId {
    return [[UIDevice currentDevice].identifierForVendor UUIDString];
}
    
- (void) createDynamicLink {
    
}

- (BOOL) isIpad {
    if ([(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"]) {
        return YES;
    }
    
    return NO;
}

- (BOOL) isPhoneX {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && UIScreen.mainScreen.nativeBounds.size.height == 2436)  {
        return YES;
    }
    
    return NO;
}


#pragma mark - Base
- (NSString*) formatNumber:(NSUInteger)n toBase:(NSUInteger)base
{
    NSString *alphabet = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"; // 62 digits
    NSAssert([alphabet length]>=base,@"Not enough characters. Use base %ld or lower.",(unsigned long)[alphabet length]);
    return [self formatNumber:n usingAlphabet:[alphabet substringWithRange:NSMakeRange (0, base)]];
}

- (NSString*) formatNumber:(NSUInteger)n usingAlphabet:(NSString*)alphabet
{
    NSUInteger base = [alphabet length];
    if (n<base){
        // direct conversion
        NSRange range = NSMakeRange(n, 1);
        return [alphabet substringWithRange:range];
    } else {
        return [NSString stringWithFormat:@"%@%@",
                
                // Get the number minus the last digit and do a recursive call.
                // Note that division between integer drops the decimals, eg: 769/10 = 76
                [self formatNumber:n/base usingAlphabet:alphabet],
                
                // Get the last digit and perform direct conversion with the result.
                [alphabet substringWithRange:NSMakeRange(n%base, 1)]];
    }
}

- (void) scanerPhoneNumber: (NSString*) string complete: (void (^)(NSString* phone, NSRange range)) block {
    if (string.length == 0) {
        block(nil, NSMakeRange(0, 0));
        return;
    }
    
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber
                                                               error:&error];
    
    [detector enumerateMatchesInString:string
                               options:NSMatchingReportCompletion
                                 range:NSMakeRange(0, [string length])
                            usingBlock:  ^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                if (block) {
                                    *stop = TRUE;
                                    block(result.phoneNumber, result.range);
                                }
                            }];
}
@end

@implementation NSObject(Cast)

+ (instancetype)castFrom:(id) obj{
    if (![obj isKindOfClass:[self class]]) {
        return nil;
    }
    return obj;
}

@end

@implementation NSArray(Map)

- (NSArray *)map:(id  _Nonnull (^)(id _Nonnull))block {
    NSMutableArray *result = [NSMutableArray new];
    for (id object in self) {
        [result addObject:block(object)];
    }
    return result;
}

@end
@implementation  NSObject(Update)
+ (void)updateDriverStatus:(OnlineStatus)status funcName:(NSString *)name {
    [FCTrackingHelper trackEvent:@"Driver_Update_Status" value:@{ @"functionName": name, @"value": @(status) }];
    [[NSUserDefaults standardUserDefaults] setInteger:status forKey:KEY_LAST_ONLINE_STATE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

