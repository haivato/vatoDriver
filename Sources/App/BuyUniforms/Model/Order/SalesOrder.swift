/* 
Copyright (c) 2019 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation

enum StoreOrderStatus: Int, Codable  {
    case CANCELED = 0
    case NEW = 1
    case PENDING_PAYMENT = 2
    case PAYMENT_SUCCESS = 3
    case MERCHANT_ACCEPTED = 4
    case FIND_DRIVER = 5
    case DRIVER_ACCEPTED = 6
    case PICK_SALES_ORDER = 7
    case SHIPPING_SALES_ORDER = 8
    case COMPLETE = 9
    case HAVE_NOT_DRIVER = 10
    case DRIVER_CANCEL = 11
    case CLIENT_CANCEL = 12
    case MERCHANT_CANCEL = 13
    case MERCHANT_DELIVERY = 14
    case PAYMENT_FOR_MERCHANT = 15
    case PROBLEM = 16
    case ERROR = -1
}

/*
OrderState {
  CANCELED(0, "Huỷ"),
  NEW(1, "Mới tạo đơn hàng"),
  PAYMENT(2, "Thanh toán"),
COMPLETE(4,"Hoàn thành đơn hàng")}
*/

enum StoreOrderState: Int, Codable {
    case CANCELED = 0
    case NEW = 1
    case PAYMENT = 2
    case COMPLETE = 4
    
    
    var stringValue: String {
        switch self {
        case .CANCELED:
            return "Hủy"
        case .NEW:
            return "Đặt hàng thành công"
        case .PAYMENT:
            return "Đã xác nhận"
        case .COMPLETE:
            return "Hoàn thành"
        }
    }
    
    var bgColor: UIColor {
        switch self {
        case .NEW:
            return #colorLiteral(red: 0.9607843137, green: 0.4117647059, blue: 0.1725490196, alpha: 0.2011855332)
        case .PAYMENT:
            return #colorLiteral(red: 0.2980392157, green: 0.7098039216, blue: 0.02352941176, alpha: 0.15)
        case .COMPLETE:
            return #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 0.2)
        case .CANCELED:
            return #colorLiteral(red: 1, green: 0.1411764706, blue: 0.1411764706, alpha: 0.2)
        }
    }
    
    var txtColor: UIColor {
        switch self {
        case .NEW:
            return #colorLiteral(red: 0.9607843137, green: 0.4117647059, blue: 0.1725490196, alpha: 1)
        case .PAYMENT:
            return #colorLiteral(red: 0.2980392157, green: 0.7098039216, blue: 0.02352941176, alpha: 1)
        case .COMPLETE:
            return #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
        case .CANCELED:
            return #colorLiteral(red: 1, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
        }
    }
}

struct SalesOrderHistoryResponse: Codable {
    let orderOfflineList: [SalesOrder]?
}

struct SalesOrderShipments: Codable {
    let address: String?
    let discountAmount: Double?
    let id: String?
    let method: Int?
    let methodDesc: String?
    let phone: String?
    let price: Double?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        address = try values.decodeIfPresent(String.self, forKey: .address)
        discountAmount = try values.decodeIfPresent(Double.self, forKey: .discountAmount)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        method = try values.decodeIfPresent(Int.self, forKey: .method)
        methodDesc = try values.decodeIfPresent(String.self, forKey: .methodDesc)
        phone = try values.decodeIfPresent(String.self, forKey: .phone)
        price = try values.decodeIfPresent(Double.self, forKey: .price)
    }
}

struct SalesOrder : Codable {

//	let createdBy : Double?
//	let updatedBy : Double?
	let createdAt : Double?
//	let updatedAt : Double?
	let id : String?
	let appliedRuleIds : String?
	let adjustmentNegative : Int?
	let adjustmentPositive : Int?
	let baseAdjustmentNegative : Int?
	let baseAdjustmentPositive : Int?
	let baseDiscountAmount : Int?
	let baseDiscountCanceled : Int?
	let baseDiscountInvoiced : Int?
	let baseDiscountRefunded : Int?
	let baseGrandTotal : Double?
	let baseShippingAmount : Int?
	let baseShippingCanceled : Int?
	let baseShippingDiscountAmount : Int?
	let baseShippingInvoice : Int?
	let baseShippingRefunded : Int?
	let baseSubTotal : Int?
	let baseSubTotalCanceled : Int?
	let baseSubTotalInvoiced : Int?
	let baseSubTotalRefunded : Int?
	let baseToOrderRate : Int?
	let baseTotalCanceled : Int?
	let baseTotalDue : Int?
	let baseTotalInvoiced : Int?
	let baseTotalPaid : Int?
	let baseTotalQtyOrdered : Int?
	let baseTotalRefunded : Int?
//	let couponCode : String?
	let customerId : Int?
	let customerNote : String?
	let customerNoteNotify : String?
	let discountAmount : Int?
	let discountCanceled : Int?
	let discountDescription : String?
	let discountInvoice : Int?
	let discountRefunded : Int?
	let grandTotal : Double?
	let codeShip : String?
    let addressStore : String?
	let salesOrderAddress : [SalesOrderAddress]?
	let paymentAuthExpiration : Int?
	let state : StoreOrderState?
    var status : StoreOrderStatus?
    let _status: Int?
	let statusDes : String?
	let stateDes : String?
	let storeId : Int?
	let nameStore : String?
	let subTotal : Int?
	let subTotalInvoice : Int?
	let taxAmount : Int?
	let totalCanceled : Int?
	let totalDue : Int?
	let totalInvoiced : Int?
	let totalItemCount : Int?
	let totalQtyOrdered : Int?
	let totalPaid : Int?
	let totalRefunded : Int?
	let payment : Bool?
	let timePickup : Double?
	let nameShipper : String?
	let phoneShipper : String?
	let orderItems : [OrderItem]?
	let salesOrderShipments : [SalesOrderShipments]?
	let salesOrderPayments : [SalesOrderPayment]?
	let salesOrderStatusHistories : [SalesOrderStatusHistory]?
    let code: String?
	enum CodingKeys: String, CodingKey {

//		case createdBy = "createdBy"
//		case updatedBy = "updatedBy"
		case createdAt = "createdAt"
//		case updatedAt = "updatedAt"
		case id = "id"
		case appliedRuleIds = "appliedRuleIds"
		case adjustmentNegative = "adjustmentNegative"
		case adjustmentPositive = "adjustmentPositive"
		case baseAdjustmentNegative = "baseAdjustmentNegative"
		case baseAdjustmentPositive = "baseAdjustmentPositive"
		case baseDiscountAmount = "baseDiscountAmount"
		case baseDiscountCanceled = "baseDiscountCanceled"
		case baseDiscountInvoiced = "baseDiscountInvoiced"
		case baseDiscountRefunded = "baseDiscountRefunded"
		case baseGrandTotal = "baseGrandTotal"
		case baseShippingAmount = "baseShippingAmount"
		case baseShippingCanceled = "baseShippingCanceled"
		case baseShippingDiscountAmount = "baseShippingDiscountAmount"
		case baseShippingInvoice = "baseShippingInvoice"
		case baseShippingRefunded = "baseShippingRefunded"
		case baseSubTotal = "baseSubTotal"
		case baseSubTotalCanceled = "baseSubTotalCanceled"
		case baseSubTotalInvoiced = "baseSubTotalInvoiced"
		case baseSubTotalRefunded = "baseSubTotalRefunded"
		case baseToOrderRate = "baseToOrderRate"
		case baseTotalCanceled = "baseTotalCanceled"
		case baseTotalDue = "baseTotalDue"
		case baseTotalInvoiced = "baseTotalInvoiced"
		case baseTotalPaid = "baseTotalPaid"
		case baseTotalQtyOrdered = "baseTotalQtyOrdered"
		case baseTotalRefunded = "baseTotalRefunded"
//		case couponCode = "couponCode"
		case customerId = "customerId"
		case customerNote = "customerNote"
		case customerNoteNotify = "customerNoteNotify"
		case discountAmount = "discountAmount"
		case discountCanceled = "discountCanceled"
		case discountDescription = "discountDescription"
		case discountInvoice = "discountInvoice"
		case discountRefunded = "discountRefunded"
		case grandTotal = "grandTotal"
		case codeShip = "codeShip"
		case salesOrderAddress = "salesOrderAddress"
		case paymentAuthExpiration = "paymentAuthExpiration"
		case state = "state"
		case status = "status"
		case statusDes = "statusDes"
		case stateDes = "stateDes"
		case storeId = "storeId"
		case nameStore = "nameStore"
		case subTotal = "subTotal"
		case subTotalInvoice = "subTotalInvoice"
		case taxAmount = "taxAmount"
		case totalCanceled = "totalCanceled"
		case totalDue = "totalDue"
		case totalInvoiced = "totalInvoiced"
		case totalItemCount = "totalItemCount"
		case totalQtyOrdered = "totalQtyOrdered"
		case totalPaid = "totalPaid"
		case totalRefunded = "totalRefunded"
		case payment = "payment"
		case timePickup = "timePickup"
		case nameShipper = "nameShipper"
		case phoneShipper = "phoneShipper"
		case orderItems = "orderItems"
//		case salesOrderShipments = "salesOrderShipments"
		case salesOrderPayments = "salesOrderPayments"
		case salesOrderStatusHistories = "salesOrderStatusHistories"
        case addressStore = "addressStore"
        case code = "code"
        case salesOrderShipments
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            createdAt = try values.decodeIfPresent(Double.self, forKey: .createdAt)
        } catch {
            createdAt = 0
        }
        
		id = try values.decodeIfPresent(String.self, forKey: .id)
		appliedRuleIds = try values.decodeIfPresent(String.self, forKey: .appliedRuleIds)
		adjustmentNegative = try values.decodeIfPresent(Int.self, forKey: .adjustmentNegative)
		adjustmentPositive = try values.decodeIfPresent(Int.self, forKey: .adjustmentPositive)
		baseAdjustmentNegative = try values.decodeIfPresent(Int.self, forKey: .baseAdjustmentNegative)
		baseAdjustmentPositive = try values.decodeIfPresent(Int.self, forKey: .baseAdjustmentPositive)
		baseDiscountAmount = try values.decodeIfPresent(Int.self, forKey: .baseDiscountAmount)
		baseDiscountCanceled = try values.decodeIfPresent(Int.self, forKey: .baseDiscountCanceled)
		baseDiscountInvoiced = try values.decodeIfPresent(Int.self, forKey: .baseDiscountInvoiced)
		baseDiscountRefunded = try values.decodeIfPresent(Int.self, forKey: .baseDiscountRefunded)
		baseGrandTotal = try values.decodeIfPresent(Double.self, forKey: .baseGrandTotal)
		baseShippingAmount = try values.decodeIfPresent(Int.self, forKey: .baseShippingAmount)
		baseShippingCanceled = try values.decodeIfPresent(Int.self, forKey: .baseShippingCanceled)
		baseShippingDiscountAmount = try values.decodeIfPresent(Int.self, forKey: .baseShippingDiscountAmount)
		baseShippingInvoice = try values.decodeIfPresent(Int.self, forKey: .baseShippingInvoice)
		baseShippingRefunded = try values.decodeIfPresent(Int.self, forKey: .baseShippingRefunded)
		baseSubTotal = try values.decodeIfPresent(Int.self, forKey: .baseSubTotal)
		baseSubTotalCanceled = try values.decodeIfPresent(Int.self, forKey: .baseSubTotalCanceled)
		baseSubTotalInvoiced = try values.decodeIfPresent(Int.self, forKey: .baseSubTotalInvoiced)
		baseSubTotalRefunded = try values.decodeIfPresent(Int.self, forKey: .baseSubTotalRefunded)
		baseToOrderRate = try values.decodeIfPresent(Int.self, forKey: .baseToOrderRate)
		baseTotalCanceled = try values.decodeIfPresent(Int.self, forKey: .baseTotalCanceled)
		baseTotalDue = try values.decodeIfPresent(Int.self, forKey: .baseTotalDue)
		baseTotalInvoiced = try values.decodeIfPresent(Int.self, forKey: .baseTotalInvoiced)
		baseTotalPaid = try values.decodeIfPresent(Int.self, forKey: .baseTotalPaid)
		baseTotalQtyOrdered = try values.decodeIfPresent(Int.self, forKey: .baseTotalQtyOrdered)
		baseTotalRefunded = try values.decodeIfPresent(Int.self, forKey: .baseTotalRefunded)
//		couponCode = try values.decodeIfPresent(String.self, forKey: .couponCode)
		customerId = try values.decodeIfPresent(Int.self, forKey: .customerId)
		customerNote = try values.decodeIfPresent(String.self, forKey: .customerNote)
		customerNoteNotify = try values.decodeIfPresent(String.self, forKey: .customerNoteNotify)
		discountAmount = try values.decodeIfPresent(Int.self, forKey: .discountAmount)
		discountCanceled = try values.decodeIfPresent(Int.self, forKey: .discountCanceled)
		discountDescription = try values.decodeIfPresent(String.self, forKey: .discountDescription)
		discountInvoice = try values.decodeIfPresent(Int.self, forKey: .discountInvoice)
		discountRefunded = try values.decodeIfPresent(Int.self, forKey: .discountRefunded)
		grandTotal = try values.decodeIfPresent(Double.self, forKey: .grandTotal)
		codeShip = try values.decodeIfPresent(String.self, forKey: .codeShip)
		salesOrderAddress = try values.decodeIfPresent([SalesOrderAddress].self, forKey: .salesOrderAddress)
		paymentAuthExpiration = try values.decodeIfPresent(Int.self, forKey: .paymentAuthExpiration)
		state = try values.decodeIfPresent(StoreOrderState.self, forKey: .state)
        _status = try values.decodeIfPresent(Int.self, forKey: .status)
        status = nil
        if let s = _status {
            self.status = StoreOrderStatus.init(rawValue: s) ?? StoreOrderStatus.ERROR
        }
		statusDes = try values.decodeIfPresent(String.self, forKey: .statusDes)
		stateDes = try values.decodeIfPresent(String.self, forKey: .stateDes)
		storeId = try values.decodeIfPresent(Int.self, forKey: .storeId)
		nameStore = try values.decodeIfPresent(String.self, forKey: .nameStore)
		subTotal = try values.decodeIfPresent(Int.self, forKey: .subTotal)
		subTotalInvoice = try values.decodeIfPresent(Int.self, forKey: .subTotalInvoice)
		taxAmount = try values.decodeIfPresent(Int.self, forKey: .taxAmount)
		totalCanceled = try values.decodeIfPresent(Int.self, forKey: .totalCanceled)
		totalDue = try values.decodeIfPresent(Int.self, forKey: .totalDue)
		totalInvoiced = try values.decodeIfPresent(Int.self, forKey: .totalInvoiced)
		totalItemCount = try values.decodeIfPresent(Int.self, forKey: .totalItemCount)
		totalQtyOrdered = try values.decodeIfPresent(Int.self, forKey: .totalQtyOrdered)
		totalPaid = try values.decodeIfPresent(Int.self, forKey: .totalPaid)
		totalRefunded = try values.decodeIfPresent(Int.self, forKey: .totalRefunded)
		payment = try values.decodeIfPresent(Bool.self, forKey: .payment)
		timePickup = try values.decodeIfPresent(Double.self, forKey: .timePickup)
		nameShipper = try values.decodeIfPresent(String.self, forKey: .nameShipper)
		phoneShipper = try values.decodeIfPresent(String.self, forKey: .phoneShipper)
        addressStore = try values.decodeIfPresent(String.self, forKey: .addressStore)
		orderItems = try values.decodeIfPresent([OrderItem].self, forKey: .orderItems)
//		salesOrderShipments = try values.decodeIfPresent([String].self, forKey: .salesOrderShipments)
		salesOrderPayments = try values.decodeIfPresent([SalesOrderPayment].self, forKey: .salesOrderPayments)
		salesOrderStatusHistories = try values.decodeIfPresent([SalesOrderStatusHistory].self, forKey: .salesOrderStatusHistories)
        code = try values.decodeIfPresent(String.self, forKey: .code)
        salesOrderShipments = try values.decodeIfPresent([SalesOrderShipments].self, forKey: .salesOrderShipments)
	}

}


extension SalesOrder: Equatable {
    static func == (lhs: SalesOrder, rhs: SalesOrder) -> Bool {
        return lhs.id == rhs.id && lhs.status == rhs.status
    }
}


extension SalesOrder {
    func timePickUpString() -> String {
        guard let timePickup = self.timePickup else {
            return "Sớm nhất có thể"
        }
        
        let date = Date.init(timeIntervalSince1970: timePickup/1000)
        
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        let text = dateFormatter.string(from: date)
        return text
    }
}
