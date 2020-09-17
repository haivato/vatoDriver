#import "TripListenNewTripManager.h"
#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebaseFirestore/FirebaseFirestore.h>

NSDate *expiredReceiveTrip;
@import FirebaseAnalytics;
@interface TripNewModel : JSONModel
@property (copy, nonatomic) NSString *tripId;
@property (nonatomic) NSTimeInterval timeStamp;
@property (nonatomic) NSTimeInterval expiredAt;
@end

@implementation TripNewModel
- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err {
    self = [super init];
    self.tripId = [NSString castFrom:[dict objectForKey:@"tripId"]];
    NSNumber *time = [NSNumber castFrom:[dict objectForKey:@"timeStamp"]];
    NSNumber *expire = [NSNumber castFrom:[dict objectForKey:@"expiredAt"]];
    if (time) {
        self.timeStamp = [time doubleValue];
    }
    
    if (expire) {
        self.expiredAt = [expire doubleValue];
    }
    
    return self;
}

- (BOOL)isEqual:(id)object {
    TripNewModel *newTrip = [TripNewModel castFrom:object];
    if (!newTrip) { return NO; }
    return [_tripId isEqualToString:newTrip.tripId] && _timeStamp == newTrip.timeStamp;
}
@end

@interface TripListenNewTripManager()
@property (strong, nonatomic) FIRDocumentReference *tripAllowRef;
@property (strong, nonatomic) FIRCollectionReference *tripNotifyRef;
@property (strong, nonatomic) RACSubject *mTripNewSignal;
@property (strong, nonatomic) RACDisposable *disposeListen;
@end

@implementation TripListenNewTripManager

#pragma mark - Class's properties

#pragma mark - Class's constructors
- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *uid = [FIRAuth auth].currentUser.uid;
        FIRFirestore *firestore = [FIRFirestore firestore];
        self.tripAllowRef = [[firestore collectionWithPath:TABLE_TRIP_ALLOW] documentWithPath:uid];
        self.mTripNewSignal = [RACSubject new];
        [self listenNewTrip];
    }
    return self;
}

- (RACSignal *)newTrip {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        id<FIRListenerRegistration> handler = [self.tripAllowRef addSnapshotListenerWithIncludeMetadataChanges:NO listener:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
            if (error) {
                [FIRAnalytics logEventWithName:@"listen_newtrip_error"
                                    parameters:@{@"reason": error.localizedDescription ?: @"Lỗi không listen new trip.!!!"}];
                [subscriber sendError:error];
                return;
            }
            
            NSDictionary *json = [snapshot data] ?: @{};
            NSError *e;
            TripNewModel *trip = [[TripNewModel alloc] initWithDictionary:json error:&e];
            [subscriber sendNext:trip];
        }];
        
        return [RACDisposable disposableWithBlock:^{
            [handler remove];
        }];
    }];
}

- (void) listenNewTrip {
    @weakify(self);
    self.disposeListen = [[[self newTrip] distinctUntilChanged] subscribeNext:^(TripNewModel *x) {
        @strongify(self);
        if (x) {
            NSTimeInterval expired = [x expiredAt] / 1000;
            NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:expired];
            expiredReceiveTrip = date;
        }
        
        NSLog(@"!!!!!!! TripId : %@", x.tripId ?: @"");
        [self.mTripNewSignal sendNext:x];
    } error:^(NSError *error) {
        @strongify(self);
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self alertRestart];
        });
    }];
}

- (void) alertRestart {
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Đồng ý" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        exit(0);
    }];
    
    UIAlertController *alertVC = [UIAlertController showAlertInViewController:[UIApplication sharedApplication].keyWindow.rootViewController withTitle:@"Thông báo" message:@"Hệ thống có lỗi, vui lòng khởi động lại ứng dụng." cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:nil];
    [alertVC addAction:action];
}

- (void)dealloc
{
    if (_disposeListen) {
        [_disposeListen dispose];
    }
    [_mTripNewSignal sendCompleted];
}

#pragma mark - publish
- (RACSignal *)tripNewSignal {
    return [[_mTripNewSignal distinctUntilChanged] map:^NSString *(TripNewModel *value) {
        return value.tripId;
    }];
}

- (void)clearTripAllow {
    [self.tripAllowRef setData:@{}];
}

- (RACSignal *)findTrip:(NSString *)tripId {
   FIRDocumentReference *tripRef = [[FIRFirestore firestore] documentWithPath:[NSString stringWithFormat:@"Trip/%@", tripId]];
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [tripRef getDocumentWithSource:FIRFirestoreSourceServer completion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
            if (error) {
                [subscriber sendError:error];
                return;
            }
            
            NSError *err;
            NSDictionary *json = [snapshot data] ?: @{};
            FCBooking* booking = [[FCBooking alloc] initWithDictionary:json error:&err];
            if (err) {
                [subscriber sendError:err];
                return;
            }
            [subscriber sendNext:booking];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

- (void)deleteTrip:(NSString *)tripId {
    FIRDocumentReference *tripRef = [[FIRFirestore firestore] documentWithPath:[NSString stringWithFormat:@"Trip/%@", tripId]];
    [tripRef deleteDocumentWithCompletion:^(NSError * _Nullable error) {
        NSAssert(!error, [error localizedDescription]);
    }];
}

+ (NSString *)generateIdTrip {
    FIRCollectionReference *collectionTripRef = [[FIRFirestore firestore] collectionWithPath:@"Trip"];
    FIRDocumentReference *newRef = [collectionTripRef documentWithAutoID];
    return newRef.documentID;
}

+ (void)setDataTripNotify:(NSString *)tripId json:(NSDictionary *)json completion:(void(^)(NSError * _Nullable))completion {
    FIRCollectionReference *tripNotifyRef = [[FIRFirestore firestore] collectionWithPath:TABLE_TRIP_NOTIFY];
    FIRDocumentReference *notifyRef = [tripNotifyRef documentWithPath:tripId];
    [notifyRef setData:json completion:completion];
}

@end

