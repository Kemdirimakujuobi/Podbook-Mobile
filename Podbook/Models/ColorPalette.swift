import SwiftUI

struct ColorPalette {
    let shade50: String
    let shade100: String
    let shade200: String
    let shade300: String
    let shade400: String
    let shade500: String
    let shade600: String
    let shade700: String
    let shade800: String
    let shade900: String
    let shade950: String

    // Hex color definitions
    static let brand = ColorPalette(
        shade50: "#f3f0ff",
        shade100: "#d7d3ff",
        shade200: "#bbb6ec",
        shade300: "#a099d8",
        shade400: "#867dc3",
        shade500: "#6d60b2",
        shade600: "#56449d",
        shade700: "#402b82",
        shade800: "#2a1163",
        shade900: "#160042",
        shade950: "#070026"
    )

    static let velvet = ColorPalette(
        shade50: "#ffeafb",
        shade100: "#ffd6f1",
        shade200: "#ffbae0",
        shade300: "#f69ecc",
        shade400: "#dd78ae",
        shade500: "#bb598f",
        shade600: "#9a3b71",
        shade700: "#732753",
        shade800: "#4e1336",
        shade900: "#2b051b",
        shade950: "#17040e"
    )

    static let greenNotFound = ColorPalette(
        shade50: "#f7f6e6",
        shade100: "#ebeacd",
        shade200: "#d9d7af",
        shade300: "#c4c190",
        shade400: "#a6a169",
        shade500: "#87834b",
        shade600: "#6a662e",
        shade700: "#4d491c",
        shade800: "#322f0a",
        shade900: "#191702",
        shade950: "#0d0c02"
    )

    static let ficusElastica = ColorPalette(
        shade50: "#e7fbef",
        shade100: "#cff2dd",
        shade200: "#b1e2c5",
        shade300: "#93cdac",
        shade400: "#6bb08a",
        shade500: "#4c916c",
        shade600: "#2c7350",
        shade700: "#1a5438",
        shade800: "#073722",
        shade900: "#001c0e",
        shade950: "#020f07"
    )

    /* OKLCH VALUES - Saved for potential rollback
    static let brand = ColorPalette(
        shade50: "oklch(0.962 0.020 295.2)",
        shade100: "oklch(0.884 0.060 289.3)",
        shade200: "oklch(0.799 0.076 288.8)",
        shade300: "oklch(0.712 0.091 289.0)",
        shade400: "oklch(0.626 0.104 288.9)",
        shade500: "oklch(0.539 0.125 288.8)",
        shade600: "oklch(0.453 0.139 288.9)",
        shade700: "oklch(0.368 0.139 288.8)",
        shade800: "oklch(0.277 0.132 288.5)",
        shade900: "oklch(0.193 0.111 287.0)",
        shade950: "oklch(0.133 0.079 282.5)"
    )

    static let velvet = ColorPalette(
        shade50: "oklch(0.959 0.032 332.1)",
        shade100: "oklch(0.919 0.057 338.8)",
        shade200: "oklch(0.863 0.093 345.0)",
        shade300: "oklch(0.800 0.118 347.5)",
        shade400: "oklch(0.701 0.140 348.0)",
        shade500: "oklch(0.600 0.141 348.0)",
        shade600: "oklch(0.500 0.141 348.2)",
        shade700: "oklch(0.401 0.118 348.0)",
        shade800: "oklch(0.299 0.097 348.0)",
        shade900: "oklch(0.201 0.069 349.0)",
        shade950: "oklch(0.150 0.041 348.3)"
    )

    static let greenNotFound = ColorPalette(
        shade50: "oklch(0.970 0.021 103.9)",
        shade100: "oklch(0.930 0.038 105.5)",
        shade200: "oklch(0.871 0.053 105.1)",
        shade300: "oklch(0.801 0.066 104.8)",
        shade400: "oklch(0.700 0.076 103.8)",
        shade500: "oklch(0.600 0.077 104.9)",
        shade600: "oklch(0.501 0.077 105.1)",
        shade700: "oklch(0.399 0.064 104.2)",
        shade800: "oklch(0.300 0.054 104.7)",
        shade900: "oklch(0.201 0.038 104.6)",
        shade950: "oklch(0.152 0.025 105.1)"
    )

    static let ficusElastica = ColorPalette(
        shade50: "oklch(0.970 0.026 159.6)",
        shade100: "oklch(0.930 0.046 159.0)",
        shade200: "oklch(0.871 0.065 158.8)",
        shade300: "oklch(0.799 0.076 159.1)",
        shade400: "oklch(0.701 0.090 158.8)",
        shade500: "oklch(0.601 0.091 158.6)",
        shade600: "oklch(0.501 0.091 158.9)",
        shade700: "oklch(0.400 0.077 158.7)",
        shade800: "oklch(0.300 0.063 159.3)",
        shade900: "oklch(0.200 0.046 158.9)",
        shade950: "oklch(0.151 0.029 158.3)"
    )
    */

    // Get palette by cover color string
    static func palette(for coverColor: String) -> ColorPalette {
        switch coverColor {
        case "purple":
            return .brand
        case "pink":
            return .velvet
        case "yellow":
            return .greenNotFound
        case "green":
            return .ficusElastica
        default:
            return .velvet // Default to velvet
        }
    }
}

// Hex Color Extension (uses existing Color(hex:) from GradientAnimation.swift)
extension Color {
    init(palette: String) {
        // Use the existing hex initializer
        self.init(hex: palette)
    }
}

/* OKLCH Color Extension - Saved for potential rollback
extension Color {
    init(oklch: String) {
        // Parse OKLCH string format: "oklch(L C H)"
        let components = oklch
            .replacingOccurrences(of: "oklch(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .split(separator: " ")
            .compactMap { Double($0) }

        guard components.count == 3 else {
            self = .white
            return
        }

        let l = components[0]
        let c = components[1]
        let h = components[2]

        // Convert OKLCH to RGB
        let rgb = Color.oklchToRGB(l: l, c: c, h: h)
        self = Color(red: rgb.0, green: rgb.1, blue: rgb.2)
    }

    private static func oklchToRGB(l: Double, c: Double, h: Double) -> (Double, Double, Double) {
        // Convert hue from degrees to radians
        let hRad = h * .pi / 180.0

        // Convert LCH to Lab
        let labA = c * cos(hRad)
        let labB = c * sin(hRad)

        // Convert OKLab to linear RGB
        let l_ = l + 0.3963377774 * labA + 0.2158037573 * labB
        let m_ = l - 0.1055613458 * labA - 0.0638541728 * labB
        let s_ = l - 0.0894841775 * labA - 1.2914855480 * labB

        let l3 = l_ * l_ * l_
        let m3 = m_ * m_ * m_
        let s3 = s_ * s_ * s_

        let r_linear = +4.0767416621 * l3 - 3.3077115913 * m3 + 0.2309699292 * s3
        let g_linear = -1.2684380046 * l3 + 2.6097574011 * m3 - 0.3413193965 * s3
        let b_linear = -0.0041960863 * l3 - 0.7034186147 * m3 + 1.7076147010 * s3

        // Apply gamma correction (sRGB)
        func srgbGamma(_ x: Double) -> Double {
            if x >= 0.0031308 {
                return 1.055 * pow(x, 1.0 / 2.4) - 0.055
            } else {
                return 12.92 * x
            }
        }

        let r = max(0, min(1, srgbGamma(r_linear)))
        let g = max(0, min(1, srgbGamma(g_linear)))
        let b = max(0, min(1, srgbGamma(b_linear)))

        return (r, g, b)
    }
}
*/
