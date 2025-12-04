import SwiftUI

struct GradientAnimation: View {
    let gradientColors: [Color]
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<10, id: \.self) { index in
                let rands = rand18(CGFloat(index))
                Ellipse()
                    .fill(gradientColors[index % gradientColors.count])
                    .frame(
                        width: CGFloat(rands[1] + 2) * 250,
                        height: CGFloat(rands[2] + 2) * 250
                    )
                    .offset(
                        x: animate ? rands[3] * 400 : rands[0] * 400,
                        y: animate ? rands[4] * 400 : rands[5] * 400
                    )
                    .blur(radius: 45)
                    .opacity(0.8)
            }
        }
        .drawingGroup()
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 8)
                    .repeatForever(autoreverses: true)
            ) {
                animate = true
            }
        }
    }

    private func rand18(_ index: CGFloat) -> [CGFloat] {
        var results: [CGFloat] = []
        for i in 0..<6 {
            let value = sin(index * 1.5 + CGFloat(i) * 2.0) * cos(index * 0.8 + CGFloat(i))
            results.append(value)
        }
        return results
    }
}

// Gradient color palettes for different episodes
extension GradientAnimation {
    static let orangeGradient: [Color] = [
        Color(hex: "F98425"),
        Color(hex: "FB6E1C"),
        Color(hex: "FA5617"),
        Color(hex: "F93F1B"),
        Color(hex: "F4523B"),
        Color(hex: "B22C16"),
        Color(hex: "7A1710"),
        Color(hex: "3D0907")
    ]

    static let blueGradient: [Color] = [
        Color(hex: "B7F6FE"),
        Color(hex: "86E1FD"),
        Color(hex: "5BCDFD"),
        Color(hex: "369FE9"),
        Color(hex: "1A6BB1"),
        Color(hex: "0D4479"),
        Color(hex: "062241"),
        Color(hex: "030C2F")
    ]

    static let cyanGradient: [Color] = [
        Color(hex: "66E7FF"),
        Color(hex: "4DD8EE"),
        Color(hex: "38C9DD"),
        Color(hex: "25BACC"),
        Color(hex: "169098"),
        Color(hex: "0B6664"),
        Color(hex: "054230"),
        Color(hex: "02251B")
    ]

    static let purpleGradient: [Color] = [
        Color(hex: "E0B3FF"),
        Color(hex: "C88EFF"),
        Color(hex: "B069FF"),
        Color(hex: "9844FF"),
        Color(hex: "7A2FCC"),
        Color(hex: "5C1A99"),
        Color(hex: "3E0566"),
        Color(hex: "200033")
    ]

    static let pinkGradient: [Color] = [
        Color(hex: "FFB3D9"),
        Color(hex: "FF8EC8"),
        Color(hex: "FF69B7"),
        Color(hex: "FF44A6"),
        Color(hex: "CC2F85"),
        Color(hex: "991A64"),
        Color(hex: "660543"),
        Color(hex: "330022")
    ]

    static let yellowGradient: [Color] = [
        Color(hex: "FFF3B3"),
        Color(hex: "FFEB8E"),
        Color(hex: "FFE369"),
        Color(hex: "FFDB44"),
        Color(hex: "CCAF2F"),
        Color(hex: "99831A"),
        Color(hex: "665705"),
        Color(hex: "332B00")
    ]
}

// Helper to create Color from hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
