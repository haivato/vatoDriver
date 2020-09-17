import Foundation
import FwiCoreRX

let errorDomain = "vn.vato.Client"

enum Text: String {
    // A
    case agree = "Đồng ý"
    case accountError = "Xảy ra lỗi trong quá trình đăng nhập, bạn vui lòng kiểm tra lại thông tin đăng nhập hoặc goi 19006667 để được hỗ trợ"
    case addBlacklist = "Chặn tài xế này"
    case addFavorite = "Thêm vào tài xế riêng"
    case allDriversAreBusy = "Hiện tại các xe đều đang bận. Quý khách vui lòng chọn dịch vụ khác của VATO hoặc thử lại sau ít phút."
    case amountOfMoney = "Số tiền"
    case amountToRecharge = "Số tiền muốn nạp"
    case and = "và"
    case authenticationCodeExpired = "Mã xác thực hết hạn. Gửi lại mã ngay!"
    case addFavoritePlace = "Thêm địa điểm"
    case addService = "Bổ sung dịch vụ"
    
    // B
    case baseOnActualRoute = "Theo lộ trình thực tế"
    case balance = "Số dư khả dụng"
    case blacklist = "Danh sách chặn"
    case bookWithoutDestination = "Đặt xe không cần điểm đến"
    case bookingFeedback = "Phản hồi đặt xe"
    // C
    case cannotContinueWithBookingRequest = "Hiện tại bạn chưa thể tiếp tục đặt xe, vui lòng thử lại sau.";
    case cash = "Tiền mặt"
    case check = "Kiểm tra"
    case contactDriver = "Đang liên hệ với lái xe"
    case calculateBaseOnActualMoving = "Tính theo lộ trình thực tế"
    case cancel = "Huỷ"
    case cannotPayDebt = "Không thể thanh toán khoản nợ hiện tại với phương thức thanh toán này, vui lòng chọn phương thức thanh toán khác."
    case changePincode = "Đổi mật khẩu thanh toán"
    case changePincodeDescription = "Mật khẩu thanh toán dùng để xác thực mỗi khi thực hiện chuyển và rút tiền"
    case chooseServices = "Chọn dịch vụ"
    case confirm = "Xác nhận"
    case confirmPickDestinationLocation = "Chọn điểm đến trên bản đồ"
    case confirmPickOriginLocation = "Chọn điểm đón trên bản đồ"
    case `continue` = "Tiếp tục"
    case connectWith = "Hoặc kết nối cùng"
    case copy = "Sao chép"
    case copied = "Đã sao chép"
    case currentPin = "Vị Trí Ghim"
    case change = "Thay đổi"
    case confirmWithPolicy = "Xác nhận đã đọc các thông tin trên"
    case confirmSupport = "Xác nhận loại yêu cầu hỗ trợ"
    // D
    case depositMethod = "Kênh nạp tiền"
    case destinationBaseOnYourRequest = "Điểm đến theo yêu cầu của bạn"
    case detailPrice = "Chi tiết giá"
    case detroyPromotion = "Sử dụng sau"
    case dismiss = "Đóng"
    case driverInfo = "Thông tin tài xế"
    case driversAreReceivingYourBookingRequest = "Các tài xế đang xem yêu cầu cuốc xe của bạn"
    case deletePlace = "Xóa địa chỉ"
    case deleteThisPlaceConfirm = "Bạn có muốn xóa địa chỉ này không?"
    case deliveryFail = "Giao hàng thất bại"
    case descriptionDetail = "Mô tả chi tiết"
    case descriptionDetailDescribe = "Mô tả chi  tiết vấn đề của bạn"
    // E
    case email = "Email"
    case enablePrivateDriverMode = "Đã bật tính năng Lái xe riêng. VATO sẽ ưu tiên các tài xế trong danh sách yêu thích của bạn."
    case enterPhoneNumber = "Nhập số điện thoai di động"
    case error = "Lỗi"
    case eWallet = "Tài khoản điện tử"
    case enterTheSearchAddress = "Nhập địa chỉ tìm kiếm"
    // F
    case fare = "Cước phí"
    case findBestDriverForYou = "Đang tìm tài xế tốt nhất cho bạn ..."
    case fullname = "Họ và tên"
    case favoritePlace = "Địa điểm Cá nhân"
    // G
    // H
    case home = "Nhà"
    case headerRegisterService = "Chọn xe đã được duyệt để đăng ký dịch vụ bổ sung."
    case hello = "Hello %@"
    // I
    case ignore = "Bỏ qua"
    case inputDriverPhone = "Nhập số điện thoại lái xe"
    case inputVerificationCode = "Nhập mã được gửi đến số"
    case inputYourPromotionCode = "Nhập mã khuyến mãi của bạn"
    case invalidEmail = "Email không hợp lệ"
    case invalidFullname = "Họ và tên không hợp lệ"
    case invalidPhoneNumber = "Số điện thoại không hợp lệ"
    case invalidPhoneNumberLength = "Số điện thoại không thể nhiều hơn 10 chữ số."
    case invalidNickname = "Nickname của bạn chưa hợp lệ!"
    case invalidSocialAccount = "This phone number had been associated with another social account. Would you like to continue?"
    case invalidAuthenticationCode = "Mã xác thực không đúng"
    case invalidReferralCode = "Mã giới thiệu không hợp lệ"
    case inviteFriend = "Gửi lời mời!"
    case inputPassService = "Nhập mật khẩu để dùng dịch vụ"
    case imageFromPhoto = "Chọn hình từ thư viện"
    case imageFromCamera = "Chọn hình từ Camera"
    case imageFoodBill = "Ảnh chụp biên nhận hàng (tối đa 3 ảnh)"
    // J
    case joinVato = "Tham gia cùng VATO"
    // K
    // L
    case later = "Để sau"
    case locationStart = "Vị Trí Đi"
    case locationEnd = "Vị Trí Đến"
    case logout = "Đăng xuất"
    case limitImage = "Hình ảnh đính kèm (tối đa 3 ảnh)"
    case listBank = "Danh sách ngân hàng"
    // M
    case maxLengthNickname = "Nickname của bạn phải từ 5 đến 40 ký tự"
    case minLengthFullname = "Tên của bạn phải từ 2 đến 5 từ"
    case minDistanceBetweenOriginAndDestination = "Khoảng cách giữa điểm đi và điểm đến phải lớn hơn 50 mét. Xin vui lòng chọn lại."
//    case minLengthNickname = "Tên riêng phải có ít nhất năm ký tự."
    // N
    case map = "Bản đồ"
    case networkDown = "Mất kết nối"
    case networkDownDescription = "Đường truyền mạng trên thiết bị đã mất kết nối. Vui lòng kiểm tra và thử lại."
    case thereWasAnErrorFunction = "Chức năng tạm thời gián đoạn. Vui lòng thử lại sau."
    case nickname = "Nickname"
    case noBlacklistDrivers = "Bạn chưa chặn tài xế"
    case noDriversAcceptedBookingRequests = "Rất tiếc, chưa tìm được xe nào cho bạn. Hãy dùng thử tính năng Chủ động cước phí."
    case noFavoriteDrivers = "Hiện tại bạn chưa có lái xe riêng nào. Để tạo danh sách lái xe riêng, bạn chọn Thêm lái xe"
    case note = "Ghi chú"
    case noteForDriver = "Lưu ý cho lái xe"
    case notification = "Thông báo"
    case noPromotion = "Bạn chưa có khuyến mãi nào"
    case notEnoughVATOPay = "Không đủ số dư VATOPay"
    case notEnoughVATOPayDescription = "Bạn không đủ số dư trong VATOPay để thanh toán cho chuyến đi này, vui lòng nạp thêm hoặc chuyển sang thanh toán băng tiền mặt."
    case nameOfPlace = "Tên địa điểm"
    case addressOfPlace = "Địa chỉ địa điểm"
    case numberCar = "Biển số xe"
    case nameCar = "Loại xe"
    case needToCreatePw = "Bạn cần tạo mật khẩu thanh toán để yêu cầu dịch vụ này."
    case needToAllowCamera = "Bạn cần cấp quyền mở camera để chụp hình."
    // O
    case otherAmount = "Số tiền khác"
    case otherPlace = "Địa điểm khác"
    // P
    case paymentMethod = "Phương thức thanh toán"
    case payWithCash = "Thanh toán tiền mặt"
    case payWithVATOPay = "Thanh toán VATOPay"
    case pending = "Chờ duyệt"
    case pendingApproval = "Số dư chờ duyệt"
    case pickupAddress = "Điểm đón"
    case pickupAt = "Đón bạn ở"
    case pincode = "Pincode"
    case phoneNumber = "Số điện thoại"
    case phoneNumberIsAssociatedWithAnotherAccount = "SDT này đang được sử dụng với một tài khoản khác."
    case privacyPolicy = "Chính sách bảo mật"
    case privateDriver = "Lái xe riêng"
    case profileInfo = "Thông tin của bạn"
    case promotion = "Khuyến mãi"
    case promotionApplyCodeError = "Mã khuyến mãi không áp dụng cho "
    case promotionApplyForAllError = "Mã khuyến mãi không hợp lệ. Vui lòng kiểm tra lại"
    case promotionApplySuccess = "Đã áp dụng mã khuyến mãi. Tận hưởng chuyến đi cùng VATO nhé !"
    case promotionExceedDay = "Đã dùng hết số lượng mã khuyến mãi trong ngày"
    case promotionShip = "Khuyến mãi chuyến đi"
    // Q
    case quickBooking = "Đặt xe ngay"
    // R
    case recentTransactions = "Hoạt động gần đây"
    case rechargeVATOPay = "Nạp tiền VATOPay"
    case releaseAt = "Đưa bạn đến"
    case removeBlacklist = "Xóa chặn tài xế"
    case removeFavorite = "Xóa khỏi lái xe riêng"
    case referral = "Thưởng giới thiệu"
    case referralCode = "Mã giới thiệu"
    case referralCodeIfNeccessary = "Mã giới thiệu (nếu có)"
    case requiredEmail = "Email không được để trống."
    case requiredFullname = "Họ và tên không được để trống."
    case requiredNickname = "Tên riêng không được để trống."
    case requiredPhoneNumber = "Bạn chưa nhập số điện thoại."
    case resendOTP = "Gửi lại mã"
    case reset = "Đặt lại"
    case retry = "Thử lại"
    case returnToBookingConfirm = "Quay lại màn hình đặt xe"
    case reasonCancelDelivery = "Lý do giao hàng thất bại"
    case reasonCancelBooking = "Lý do huỷ"
    // S
    case slogan = "VATO gọi xe là có"
    case search = "Tìm kiếm"
    case searchPromotionNotFound = "Mã khuyến mãi của bạn không hợp lệ hoặc đã hết hạn"
    case seeMore = "Xem thêm"
    case selectPaymentMethod = "Chọn phương thức thanh toán"
    case sendingOTP = "Đang gửi mã xác thực"
    case settings = "Cài đặt"
    case support = "Tôi cần hỗ trợ"
    case savePlace = "Lưu địa chỉ"
    case selectAddService = "Chọn dịch vụ bổ sung"
    case selectCarInGara = "Chọn xe trong Gara"
    // T
    case term = "Điều khoản dịch vụ"
    case thereWasAnError = "Đã xảy ra lỗi. Vui lòng thử lại sau!"
    case tipDriver = "Tip lái xe"
    case tipNow = "Tip liền tay, cả ngày may mắn"
    case total = "Tổng cộng"
    case totalPayment = "Tổng cộng thanh toán"
    case totalTopUp = "Tổng tiền nạp"
    case topUp = "Nạp tiền"
    case topUpNow = "Nạp tiền ngay"
    case topUpVATOPay = "Nạp tiền vào VATOPay để nhận nhiều ưu đãi và thanh toán nhanh chóng."
    case termAndPrivacyPolicyDescription = "Khi đăng nhập hoặc đăng ký, bạn đã đồng ý với"
    case transfers = "Chuyển tiền"
    case trip = "Chuyến đi"
    case tripCancelled = "Huỷ chuyến"
    case tripCancellationConfirm = "Xác nhận huỷ chuyến"
    case tripCancellationConfirmMessage = "Bạn thực sự muốn huỷ chuyến đi này?"
    case tripFare = "Cước phí di chuyển"
    case tripHistories = "Lịch sử đặt xe"
    case turnOnLocationFeature = "Bật dịch vụ truy cập địa điểm"
    case turnOnLocationFeatureDescription = "Việc này giúp cải thiện hoạt động đón trả khách và hỗ trợ của chúng tôi."
    // U
    case unnamedRoad = "Unnamed Road"
    case updateFavoritePlace = "Cập nhật địa điểm"
    // V
    case validTo = "Có giá trị đến "
    case verifyingAuthenticationCode = "Nhập mã xác thực"
    case version = "Phiên bản"
    // W
    case wallet = "VATOPay"
    case warningMessagePromotion = "Mã khuyến mãi áp dụng không hợp lệ, vui lòng kiểm tra lại thông tin mã hoặc đặt xe không dùng mã khuyến mãi."
    case warningPromotion = "Đặt xe không khuyến mãi"
    case warningReviewPromotion = "Xem lại mã khuyến mãi"
    case welcomeToVato = "Chào mừng đến với VATO!"
    case welcomeToVatoDescription = "Đặt VATO Bike và VATO Car trên toàn quốc"
    case whereDoYouGo = "Bạn muốn đi đâu?"
    case withdraw = "Rút tiền"
    case workNoun = "Nơi làm việc"
    case warningCancel = "VATO sẽ hậu kiểm chuyến đi. Nếu bác tài chọn lý do không đúng sự thật sẽ ảnh hưởng đến ưu tiên nhận chuyến."
    // X
    // Y
    case youHaveNoActivities = "Bạn chưa có hoạt động nào"
    case yourCurrentLocation = "Bạn đang ở"
    case yourPromotion = "Khuyến mãi của bạn"
    // Z


    var text: String {
        return rawValue
    }

    var localizedText: String {
        return text
    }
}

@objcMembers
final class LocalizeObjC: NSObject {
    static func reset() {
//        FwiSDKConfig.initializeConfig()
        #if DEBUG
//            FwiLog.debug(FwiLocale.currentLocale)
        #endif
    }

    static func localized(for text: String) -> String {
        return text
//        return FwiLocale.localized(forString: text)
    }
}
