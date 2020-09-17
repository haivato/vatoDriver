//
//  Apis.h
//  FC
//
//  Created by facecar on 6/4/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#ifndef Apis_h
#define Apis_h

// HOST
#define HOST_MAP_API @"https://maps.googleapis.com"

#if DEV
    #define HOSTV2 @"https://apiv2.vivu.io"
    #define HOST_MAP @"https://map-dev.vato.vn/api"
    #define HOSTV3 @"https://api-dev.vato.vn/api"
#else
    #define HOSTV2 @"https://apiv2.vivu.io"
    #define HOST_MAP @"https://map.vato.vn/api"
    #define HOSTV3 @"https://api.vato.vn/api"
#endif

// APIs
#define API_GET_REFERAL_CODE   [NSString stringWithFormat: @"%@%@", HOSTV2 , @"/promotion/getreferralcode"]
#define API_VERIFY_REFERAL_CODE  [NSString stringWithFormat: @"%@%@", HOSTV2 , @"/promotion/applycode"]
#define API_GET_ZALO_ORDER [NSString stringWithFormat: @"%@%@", HOSTV2 , @"/zalo/depositorder"]
#define API_GET_BPLUS_ORDER [NSString stringWithFormat: @"%@%@", HOSTV2 , @"/bankplus/depositorder"]
#define API_REGISTER_LEVEL_2 [NSString stringWithFormat: @"%@%@", HOSTV2 , @"/user/verify/level-2"]
#define API_TRANSFER_MONEY_TO_ZALOPAY [NSString stringWithFormat: @"%@%@", HOSTV2 , @"/zalo/cashout"]
#define API_UPDATE_PAYMENT_CHANNEL [NSString stringWithFormat: @"%@%@", HOSTV2 , @"/user/update-cashout-chanel"]
#define API_CHANGE_PHONE_NUMBER [NSString stringWithFormat: @"%@%@", HOSTV2 , @"/user/change-username"]
#define API_SYNC_DATA [NSString stringWithFormat: @"%@%@", HOSTV2 , @"/user/sync"]
#define API_GET_MY_PARTNERS [NSString stringWithFormat: @"%@%@", HOSTV2 , @"/driver/my-partners"]
#define API_JOIN_TO_PARTNERS [NSString stringWithFormat: @"%@%@", HOSTV2 , @"/driver/join-partner"]

// apis V3
#define API_CHECK_ACCOUNT [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/check_account"]
#define API_CHECK_PHONE [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/check_phone"]
#define API_CREATE_ACCOUNT [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/create_account"]
#define API_UPDATE_ACCOUNT [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/update_account"]
#define API_UPDATE_ONLINE_STATUS [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/driver/update_status"]
#define API_GET_INVOICE  [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/transactions"]
#define API_GET_LIST_NOTIFY [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/notification/list_for_driver"]
#define API_GET_USER_INFO [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/check_info"]
#define API_TRANSFER_MONEY_TO_VATO [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/transfer"]
#define API_TRIP_PUSH [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/trip/push"]
#define API_TRIP_PUSH_LIST [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/trip/push_list"]
#define API_GET_BALANCE [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/balance/get"]
#define API_GET_TRIP_DAY [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/trip/list_driver"]
#define API_GET_LIST_CAR [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/vehicle/list_driver_v2"]
#define API_UPDATE_CAR_SERVICE [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/driver/update_service"]
#define API_CHECK_TRANF_CASH [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/check_pin"]
#define API_CREATE_PIN [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/set_pin"]
#define API_CHANGE_PIN [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/change_pin"]
#define API_RESET_PIN [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/reset_pin"]
#define API_GET_TRIP_SUMARY_iN_DAY [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/trip/summary_by_date"]
#define API_GET_TRIP_DETAIL [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/trip/trip_detail"]
#define API_GET_TRANS_DETAIL [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/get_transaction"]
#define API_ADD_TO_BLACK_LIST [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/add_user_to_blacklist"]
#define API_REMOVE_FROM_BLACK_LIST [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/remove_user_from_blacklist"]
#define API_CHECK_TRIP_FARE [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/trip/capture_fare"]
#define API_WITHDRAW_MONEY_TO_BANK [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/balance/add_withdraw"]
#define API_GET_WITHDRAW_ORDER [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/balance/list_withdraw_order"]
#define API_GET_MANIFEST_NOW [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/manifest/now_driver"]
#define API_GET_MANIFEST_DETAIL [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/manifest/get"]
#define API_LOGOUT [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/authenticate/logout"]
#define API_GET_WITHDRAW_CONFIG [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/get_user_withdraw_info"]
#define API_GET_TOPUP_CONFIG [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/get_user_topup_info"]
#define API_FARE_SETTINGS [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/trip/fare/settings"]

// Google Apis
#define GOOGLE_API_DIRECTION [NSString stringWithFormat: @"%@%@", HOST_MAP ,@"/directions"]
#define GOOGLE_API_PLACE [NSString stringWithFormat: @"%@%@", HOST_MAP ,@"/placesearch"]
#define GOOGLE_API_PLACE_DETAIL [NSString stringWithFormat: @"%@%@", HOST_MAP ,@"/placedetail"]

#endif /* Apis_h */
