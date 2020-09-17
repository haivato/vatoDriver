import UIKit

// MARK: Constant
struct ZoneConstant {
    static let vn = 1
}

struct MapConfig {
    struct Zoom {
        static let min: Float = 11
        static let max: Float = 20
    }
}

// MARK: Color
struct Color {
    static let darkGreen = #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1) // Primary green
    static let orange = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1) // Primary orange

    static let battleshipGrey = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
    static let colorSelectService = #colorLiteral(red: 0.9294117647, green: 0.368627451, blue: 0.1411764706, alpha: 0.2)
    static let greyishBrown = #colorLiteral(red: 0.3098039216, green: 0.3098039216, blue: 0.3098039216, alpha: 1)
    static let battleshipGreyTwo = #colorLiteral(red: 0.6352941176, green: 0.6705882353, blue: 0.7019607843, alpha: 1)
    static let black40 = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 0.4)
    static let reddishOrange60 = #colorLiteral(red: 0.9215686275, green: 0.368627451, blue: 0.1411764706, alpha: 0.6)
    static let battleshipGreyThree = #colorLiteral(red: 0.3607843137, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
}

struct Padding {
    static let left: CGFloat = 16.0
    static let right: CGFloat = 16.0
    static let bottom: CGFloat = 16.0
    static let top: CGFloat = 16.0
}

struct StyleButton {
    let view: StyleView
    let textColor: UIColor
    let font: UIFont
    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    let borderColor: UIColor

    static let `default` = StyleButton(view: .default, textColor: .white, font: .systemFont(ofSize: 16, weight: .semibold), cornerRadius: 8, borderWidth: 1, borderColor: .clear)
    static let cancel = StyleButton(view: .cancel, textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), font: .systemFont(ofSize: 16, weight: .semibold), cornerRadius: 8, borderWidth: 1, borderColor: #colorLiteral(red: 0.8005949259, green: 0.8212553859, blue: 0.8408017755, alpha: 1))
    static let disable = StyleButton(view: .disable, textColor: .white, font: .systemFont(ofSize: 16, weight: .semibold), cornerRadius: 8, borderWidth: 1, borderColor: .clear)
    
    static let newDefault = StyleButton(view: .newDefault, textColor: Color.orange, font: .systemFont(ofSize: 15, weight: .medium), cornerRadius: 8, borderWidth: 0, borderColor: .clear)
    
    static let newCancel = StyleButton(view: .newDefault, textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), font: .systemFont(ofSize: 15, weight: .medium), cornerRadius: 8, borderWidth: 0, borderColor: .clear)
}
