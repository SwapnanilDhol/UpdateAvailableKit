#if canImport(SwiftUI)
import SwiftUI

public struct UpdateAvailableBannerTheme: Sendable {
    public let backgroundColor: Color
    public let titleColor: Color
    public let subtitleColor: Color
    public let iconName: String
    public let buttonTitle: String
    public let buttonColor: Color
    public let buttonTitleColor: Color

    public init(
        backgroundColor: Color = Color.purple.opacity(0.12),
        titleColor: Color = .purple,
        subtitleColor: Color = .secondary,
        iconName: String = "arrow.down.app.fill",
        buttonTitle: String = "Update Now",
        buttonColor: Color = .purple,
        buttonTitleColor: Color = .white
    ) {
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor
        self.subtitleColor = subtitleColor
        self.iconName = iconName
        self.buttonTitle = buttonTitle
        self.buttonColor = buttonColor
        self.buttonTitleColor = buttonTitleColor
    }

    public static let `default` = UpdateAvailableBannerTheme()
}
#endif
