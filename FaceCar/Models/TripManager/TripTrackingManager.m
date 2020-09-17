#import "TripTrackingManager.h"
#import <FirebaseFirestore/FirebaseFirestore.h>

@import FirebaseAnalytics;
@interface TripTrackingManager()
@property (copy, nonatomic) NSString *currentTripId;
@property (strong, nonatomic) FCBooking *book;
@property (strong, nonatomic) FIRDocumentReference *documentRef;
@property (strong, nonatomic) FIRCollectionReference *tripNotifyRef;
@property (strong, nonatomic) RACDisposable *disposeListen;
@property (strong, nonatomic) RACSubject *mErrorSignal;
@property (strong, nonatomic) RACSubject *mBookingSignal;
@property (strong, nonatomic) RACSubject *mCommandSignal;
@property (strong, nonatomic) RACSubject *mBookInfoSignal;
@property (strong, nonatomic) RACSubject *mBookExtraSignal;
@property (strong, nonatomic) RACSubject *mBookEstimateSignal;
@property (strong, nonatomic) RACSubject *mPaymentMethodSignal;
@property (strong, nonatomic) NSMutableDictionary *backupInfo; // Use in case can't update firestore
@end

@implementation TripTrackingManager

#pragma mark - Class's constructors
- (instancetype)init:(NSString *)tripId {
    NSAssert(tripId.length != 0 , @"Not have tripId");
    if (self = [super init]) {
        self.currentTripId = tripId;
        self.mErrorSignal = [RACSubject new];
        self.mBookingSignal = [RACSubject new];
        self.mCommandSignal = [RACSubject new];
        self.mBookInfoSignal = [RACSubject new];
        self.mBookExtraSignal = [RACSubject new];
        self.mBookEstimateSignal = [RACSubject new];
        self.mPaymentMethodSignal = [RACSubject new];
        self.documentRef = [[FIRFirestore firestore] documentWithPath:[NSString stringWithFormat:@"Trip/%@", tripId]];
        self.tripNotifyRef = [[FIRFirestore firestore] collectionWithPath:TABLE_TRIP_NOTIFY];
        self.backupInfo = [NSMutableDictionary new];
        
        [self setupListen];
    }
    return self;
}

- (void) setupListen {
    @weakify(self);
    self.disposeListen = [[self listenChange] subscribeNext:^(NSDictionary *x) {
        @strongify(self);
        NSError *e;
        FCBooking *newChange = [[FCBooking alloc] initWithDictionary:x error:&e];
        if (e) {
            NSLog(@"%@", [e localizedDescription]);
        }
        self.book = newChange;
    } error:^(NSError *error) {
        @strongify(self);
        [self.mErrorSignal sendNext:error];
    }];
}

- (void)dealloc
{
    if (self.disposeListen) {
        [_disposeListen dispose];
    }
    [_mBookingSignal sendCompleted];
    [_mCommandSignal sendCompleted];
    [_mBookInfoSignal sendCompleted];
    [_mBookExtraSignal sendCompleted];
    [_mBookEstimateSignal sendCompleted];
    [_mPaymentMethodSignal sendCompleted];
}

- (void)stopListen {
    if (self.disposeListen) {
        [_disposeListen dispose];
    }
}

- (RACSignal *)listenChange {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        @weakify(self);
        id<FIRListenerRegistration> handler = [self.documentRef addSnapshotListenerWithIncludeMetadataChanges:YES listener:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
            @strongify(self);
            if (snapshot == nil) {
                NSError *e = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:@{ NSLocalizedDescriptionKey: @"Delete"}];
                [subscriber sendError:e];
                return;
            };
            
            if (error) {
                [subscriber sendError:error];
                return;
            }
            if ([snapshot data] == nil) {
                [self.mErrorSignal sendNext:error];
                return;
            }
            [subscriber sendNext:[snapshot data]];
        }];
        
        return [RACDisposable disposableWithBlock:^{
            [handler remove];
        }];
    }];
}

- (void)setBook:(FCBooking *)book {
    _book = book;
    if (!book) { return; }
    [_mBookingSignal sendNext:_book];
    [_mCommandSignal sendNext:[_book.command lastObject]];
    [_mBookInfoSignal sendNext:_book.info];
    [_mBookExtraSignal sendNext:_book.extra];
    [_mBookEstimateSignal sendNext:_book.estimate];
    [_mPaymentMethodSignal sendNext:@(_book.info.payment)];
}


#pragma mark - Publish
- (RACSignal *)paymentMethodSignal {
   return [[_mPaymentMethodSignal distinctUntilChanged] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)bookEstimateSignal {
    return [[_mBookEstimateSignal distinctUntilChanged] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)bookExtraSignal {
    return [[_mBookExtraSignal distinctUntilChanged] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)commandSignal {
    return [[_mCommandSignal distinctUntilChanged] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)bookInfoSignal {
    return  [[_mBookInfoSignal distinctUntilChanged] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)bookingSignal {
    return [_mBookingSignal deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)errorSignal {
    return [_mErrorSignal deliverOn:[RACScheduler mainThreadScheduler]];
}

#pragma mark - Set data
- (void)setDataToDatabase:(NSString *)path json:(NSDictionary *)json update:(BOOL)update {
    NSDictionary *result;
    if (path.length == 0) {
        result = json;
    } else {
        NSArray<NSString *> *components = [path componentsSeparatedByString:@"/"];
        result = [NSDictionary new];
        for (NSInteger idx = components.count - 1; idx >= 0; idx--) {
            NSString *key = components[idx];
            if ([[result allValues] count] == 0) {
                result = @{key: json};
            } else {
                result = @{key: result};
            }
        }
    }
    [_backupInfo addEntriesFromDictionary:result];
    NSLog(@"!!!!! json update : %@", result);
    [self.documentRef setData:result merge:update completion:^(NSError * _Nullable error) {
        if (error) {
            [FIRAnalytics logEventWithName:@"driver_ios_update_firestore_fail" parameters:@{@"json": json ?: @{}, @"reason": error.localizedFailureReason ?: @""}];
        }
    }];
}

- (void)setMutipleDataToDatabase:(NSArray<NSString *> *)paths json:(NSArray<NSDictionary *> *)jsons update:(BOOL)update {
    if (paths.count != jsons.count) { return; }
    
    NSMutableDictionary *resultLasted = [NSMutableDictionary new];
    for (NSInteger index = 0; index < paths.count; index ++) {
        NSString *path = paths[index];
        NSDictionary *json = jsons[index];
        
        NSDictionary *result;
        if (path.length == 0) {
            result = json;
        } else {
            NSArray<NSString *> *components = [path componentsSeparatedByString:@"/"];
            result = [NSDictionary new];
            for (NSInteger idx = components.count - 1; idx >= 0; idx--) {
                NSString *key = components[idx];
                if ([[result allValues] count] == 0) {
                    result = @{key: json};
                } else {
                    result = @{key: result};
                }
            }
        }
        if (result != nil) {
            [resultLasted addEntriesFromDictionary:result];
        }
        
    }
    [_backupInfo addEntriesFromDictionary:resultLasted];
    NSLog(@"!!!!! json update : %@", resultLasted);
    [self.documentRef setData:resultLasted merge:update];
}

- (void)setDataToDatabase:(NSString *)path
                     json:(NSDictionary *)json
                   update:(BOOL)update
               completion:(void(^)(NSError *error))handler
{
    NSDictionary *result;
    if (path.length == 0) {
        result = json;
    } else {
        NSArray<NSString *> *components = [path componentsSeparatedByString:@"/"];
        result = [NSDictionary new];
        for (NSInteger idx = components.count - 1; idx >= 0; idx--) {
            NSString *key = components[idx];
            if ([[result allValues] count] == 0) {
                result = @{key: json};
            } else {
                result = @{key: result};
            }
        }
    }
    NSLog(@"!!!!! json update : %@", result);
    [_backupInfo addEntriesFromDictionary:result];
    [self.documentRef setData:result merge:update completion:handler];
}

- (RACSignal *)getTripInfo {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        [self.documentRef getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
            if (error) {
                [subscriber sendError:error];
                return;
            }
            NSDictionary *json = snapshot.data ?: @{};
            [subscriber sendNext:json];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

#pragma mark - Trip notify
- (void)setDataTripNotify:(NSString *)tripId json:(NSDictionary *)json completion:(void(^)(NSError *))completion {
    FIRDocumentReference *notifyRef = [self.tripNotifyRef documentWithPath:tripId];
    [notifyRef setData:json completion:completion];
}

#pragma mark - Delete
- (void)deleteTrip {
    [self.documentRef deleteDocumentWithCompletion:^(NSError * _Nullable error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
}
#pragma mark - Clear Trip allow
- (void)clearTripAllow {
    NSString *uid = [FIRAuth auth].currentUser.uid;
    FIRFirestore *firestore = [FIRFirestore firestore];
    FIRDocumentReference *tripAllowRef = [[firestore collectionWithPath:TABLE_TRIP_ALLOW] documentWithPath:uid];
    [tripAllowRef setData:@{}];
}

- (void)setMutipleDataToDatabase:(NSDictionary<NSString *, NSDictionary *> *)data update:(BOOL)update {
    NSMutableDictionary *resultLasted = [NSMutableDictionary new];
    [data enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull path, NSDictionary * _Nonnull json, BOOL * _Nonnull stop) {
        NSDictionary *result = [self create:path json:json];
        [resultLasted addEntriesFromDictionary:result];
    }];
    NSLog(@"!!!!! json update : %@", resultLasted);
    [_backupInfo addEntriesFromDictionary:resultLasted];
    [self.documentRef setData:resultLasted merge:update];
}

- (NSDictionary *)create:(NSString *)path json:(NSDictionary *)json {
    NSDictionary *result;
    if (path.length == 0) {
        result = json;
    } else {
        NSArray<NSString *> *components = [path componentsSeparatedByString:@"/"];
        result = [NSDictionary new];
        for (NSInteger idx = components.count - 1; idx >= 0; idx--) {
            NSString *key = components[idx];
            if ([[result allValues] count] == 0) {
                result = @{key: json};
            } else {
                result = @{key: result};
            }
        }
    }
    NSLog(@"!!!!! %s: %@", __FUNCTION__, result);
    return result;
}

- (NSDictionary *)create: (NSDictionary<NSString *, NSDictionary *> *)data {
    NSMutableDictionary *result = [NSMutableDictionary new];
    [data enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull path, NSDictionary * _Nonnull json, BOOL * _Nonnull stop) {
        NSDictionary *temp = [self create:path json:json];
        [result addEntriesFromDictionary:temp];
    }];
    NSLog(@"!!!!! %s: %@", __FUNCTION__, result);
    return result;
}

- (RACSignal *)updateMutipleValue:(NSDictionary<NSString *, NSDictionary *> *)data update:(BOOL)update {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        NSDictionary *json = [self create:data];
        [self.backupInfo addEntriesFromDictionary:json];
        [self.documentRef setData:json merge:update completion:^(NSError * _Nullable error) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

+ (RACSignal *)loadCurrentTrip {
    NSString *uid = [FIRAuth auth].currentUser.uid;
    FIRDatabaseReference *ref = [[[FIRDatabase database].reference child:TABLE_DRIVER_TRIP] child:uid];
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSString *tripId = [NSString castFrom:snapshot.value];
            [subscriber sendNext:tripId];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

+ (void)removeCurrentTrip:(NSString *)tripId {
    if ([tripId length] == 0) {
        return;
    }
    NSString *uid = [FIRAuth auth].currentUser.uid;
    FIRDatabaseReference *ref = [[[FIRDatabase database].reference child:TABLE_DRIVER_TRIP] child:uid];
    [ref setValue:nil withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        NSAssert(!error, error.localizedDescription);
    }];
}

#pragma mark - load backup
- (NSDictionary *)backup {
    return _backupInfo;
}

@end

