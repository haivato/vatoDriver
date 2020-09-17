//
//  FirebaseDynamicLinkHelper.m
//  FC
//
//  Created by facecar on 7/12/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FirebaseDynamicLinkHelper.h"
@import Firebase;

static NSString *const Link = @"Link Value";
static NSString *const Domain = @"App Domain";
static NSString *const Source = @"Source";
static NSString *const Medium = @"Medium";
static NSString *const Campaign = @"Campaign";
static NSString *const Term = @"Term";
static NSString *const Content = @"Content";
static NSString *const BundleID = @"App Bundle ID";
static NSString *const FallbackURL = @"Fallback URL";
static NSString *const MinimumAppVersion = @"Minimum App Version";
static NSString *const CustomScheme = @"Custom Scheme";
static NSString *const IPadBundleID = @"iPad Bundle ID";
static NSString *const IPadFallbackURL = @"iPad Fallback URL";
static NSString *const AppStoreID = @"AppStore ID";
static NSString *const AffiliateToken = @"Affiliate Token";
static NSString *const CampaignToken = @"Campaign Token";
static NSString *const ProviderToken = @"Provider Token";
static NSString *const PackageName = @"Package Name";
static NSString *const AndroidFallbackURL = @"Android Fallback URL";
static NSString *const MinimumVersion = @"Minimum Version";
static NSString *const Title = @"Title";
static NSString *const DescriptionText = @"Description Text";
static NSString *const ImageURL = @"Image URL";

static NSInteger const NumberParams = 23;

static NSString *const GoogleAnalytics = @"Google Analytics";
static NSString *const ios = @"iOS";
static NSString *const ITunes = @"iTunes Connect Analytics";
static NSString *const Android = @"Android";
static NSString *const Social = @"Social Meta Tag";

static NSString *const DYNAMIC_LINK_DOMAIN = @"x75sc.app.goo.gl";


@interface FirebaseDynamicLinkHelper ()
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *dictionary;
@end


@implementation FirebaseDynamicLinkHelper
    
static FirebaseDynamicLinkHelper * instnace = nil;
+ (FirebaseDynamicLinkHelper*) shareInstance {
    if (instnace == nil) {
        instnace = [[FirebaseDynamicLinkHelper alloc] init];
    }
    return instnace;
}

    
- (void) buildFDLLink: (NSString*) inviteCode complete: (void (^)(NSURL* link)) handler{
    if (!_dictionary) {
        _dictionary = [[NSMutableDictionary alloc] init];
    }
    
    _dictionary[Link] = [NSString stringWithFormat:@"http://vato.vn?invitecode=%@", inviteCode];
    _dictionary[BundleID] = APP_BUNDLE_ID;
    _dictionary[AppStoreID] = APP_STORE_ID;
    _dictionary[CustomScheme] = APP_URL_SCHEME;
    _dictionary[PackageName] = ANDROID_PACKAGE;
    _dictionary[MinimumVersion] = ANDROID_MIN_VER;
    
    if ([DYNAMIC_LINK_DOMAIN  isEqual: @"YOUR_DYNAMIC_LINK_DOMAIN"]) {
        [NSException raise:@"YOUR_DYNAMIC_LINK_DOMAIN"
                    format:@"%@",
         @"Please update DYNAMIC_LINK_DOMAIN constant in your code from Firebase Console!"];
    }
    if (_dictionary[Link] == nil) {
        NSLog(@"%@", @"Link can not be empty!");
        return;
    }
    // [START buildFDLLink]
    NSURL *link = [NSURL URLWithString:_dictionary[Link]];
    FIRDynamicLinkComponents *components =
    [FIRDynamicLinkComponents componentsWithLink:link
                                          domainURIPrefix:DYNAMIC_LINK_DOMAIN];
    
    FIRDynamicLinkGoogleAnalyticsParameters *analyticsParams =
    [FIRDynamicLinkGoogleAnalyticsParameters parametersWithSource:_dictionary[Source]
                                                           medium:_dictionary[Medium]
                                                         campaign:_dictionary[Campaign]];
    analyticsParams.term = _dictionary[Term];
    analyticsParams.content = _dictionary[Content];
    components.analyticsParameters = analyticsParams;
    
    if (_dictionary[BundleID]) {
        FIRDynamicLinkIOSParameters *iOSParams = [FIRDynamicLinkIOSParameters parametersWithBundleID:_dictionary[BundleID]];
        iOSParams.fallbackURL = [NSURL URLWithString:_dictionary[FallbackURL]];
        iOSParams.minimumAppVersion = _dictionary[MinimumAppVersion];
        iOSParams.customScheme = _dictionary[CustomScheme];
        iOSParams.iPadBundleID = _dictionary[IPadBundleID];
        iOSParams.iPadFallbackURL = [NSURL URLWithString:_dictionary[IPadFallbackURL]];
        iOSParams.appStoreID = _dictionary[AppStoreID];
        components.iOSParameters = iOSParams;
        
        FIRDynamicLinkItunesConnectAnalyticsParameters *appStoreParams = [FIRDynamicLinkItunesConnectAnalyticsParameters parameters];
        appStoreParams.affiliateToken = _dictionary[AffiliateToken];
        appStoreParams.campaignToken = _dictionary[CampaignToken];
        appStoreParams.providerToken = _dictionary[ProviderToken];
        components.iTunesConnectParameters = appStoreParams;
    }
    
    
    if (_dictionary[PackageName]) {
        FIRDynamicLinkAndroidParameters *androidParams = [FIRDynamicLinkAndroidParameters parametersWithPackageName: _dictionary[PackageName]];
        androidParams.fallbackURL = [NSURL URLWithString:_dictionary[FallbackURL]];
        androidParams.minimumVersion = (_dictionary[MinimumVersion]).integerValue;
        components.androidParameters = androidParams;
    }
    
    FIRDynamicLinkSocialMetaTagParameters *socialParams = [FIRDynamicLinkSocialMetaTagParameters parameters];
    socialParams.title = _dictionary[Title];
    socialParams.descriptionText = _dictionary[DescriptionText];
    socialParams.imageURL = [NSURL URLWithString:_dictionary[ImageURL]];
    components.socialMetaTagParameters = socialParams;
    
    NSURL* _longLink = components.url;
    NSLog(@"Long URL: %@", _longLink.absoluteString);
    // [END buildFDLLink]
    
    
    // [START shortLinkOptions]
    FIRDynamicLinkComponentsOptions *options = [FIRDynamicLinkComponentsOptions options];
    options.pathLength = FIRShortDynamicLinkPathLengthUnguessable;
    components.options = options;
    // [END shortLinkOptions]
    
    // [START shortenLink]
    [components shortenWithCompletion:^(NSURL *_Nullable shortURL,
                                        NSArray *_Nullable warnings,
                                        NSError *_Nullable error) {
        // Handle shortURL or error.
        if (error) {
            NSLog(@"Error generating short link: %@", error.description);
            return;
        }
        NSURL* _shortLink = shortURL;
        NSLog(@"Short URL: %@", _shortLink.absoluteString);
        
        handler(_shortLink);
        
    }];
    // [END shortenLink]
}
@end
