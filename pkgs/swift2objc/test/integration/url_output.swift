// Test preamble text

import Foundation

@objc public class DecimalWrapper: NSObject {
  var wrappedInstance: Decimal

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isInfinite: Bool {
    get {
      wrappedInstance.isInfinite
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isCanonical: Bool {
    get {
      wrappedInstance.isCanonical
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isSignMinus: Bool {
    get {
      wrappedInstance.isSignMinus
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isSignaling: Bool {
    get {
      wrappedInstance.isSignaling
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isSubnormal: Bool {
    get {
      wrappedInstance.isSubnormal
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var significand: DecimalWrapper {
    get {
      DecimalWrapper(wrappedInstance.significand)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isSignalingNaN: Bool {
    get {
      wrappedInstance.isSignalingNaN
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var leastFiniteMagnitude: DecimalWrapper {
    get {
      DecimalWrapper(Decimal.leastFiniteMagnitude)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var leastNormalMagnitude: DecimalWrapper {
    get {
      DecimalWrapper(Decimal.leastNormalMagnitude)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var leastNonzeroMagnitude: DecimalWrapper {
    get {
      DecimalWrapper(Decimal.leastNonzeroMagnitude)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var greatestFiniteMagnitude: DecimalWrapper {
    get {
      DecimalWrapper(Decimal.greatestFiniteMagnitude)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var pi: DecimalWrapper {
    get {
      DecimalWrapper(Decimal.pi)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var nan: DecimalWrapper {
    get {
      DecimalWrapper(Decimal.nan)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var ulp: DecimalWrapper {
    get {
      DecimalWrapper(wrappedInstance.ulp)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isNaN: Bool {
    get {
      wrappedInstance.isNaN
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var radix: Int {
    get {
      Decimal.radix
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isZero: Bool {
    get {
      wrappedInstance.isZero
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var nextUp: DecimalWrapper {
    get {
      DecimalWrapper(wrappedInstance.nextUp)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var exponent: Int {
    get {
      wrappedInstance.exponent
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isFinite: Bool {
    get {
      wrappedInstance.isFinite
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isNormal: Bool {
    get {
      wrappedInstance.isNormal
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var nextDown: DecimalWrapper {
    get {
      DecimalWrapper(wrappedInstance.nextDown)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var quietNaN: DecimalWrapper {
    get {
      DecimalWrapper(Decimal.quietNaN)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var magnitude: DecimalWrapper {
    get {
      DecimalWrapper(wrappedInstance.magnitude)
    }
  }

  init(_ wrappedInstance: Decimal) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc init(floatLiteral value: Double) {
    wrappedInstance = Decimal(floatLiteral: value)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc init(integerLiteral value: Int) {
    wrappedInstance = Decimal(integerLiteral: value)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc init(signOf: DecimalWrapper, magnitudeOf magnitude: DecimalWrapper) {
    wrappedInstance = Decimal(signOf: signOf.wrappedInstance, magnitudeOf: magnitude.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc init(_ value: Int) {
    wrappedInstance = Decimal(value)
  }

  @objc override init() {
    wrappedInstance = Decimal()
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func isTotallyOrdered(belowOrEqualTo other: DecimalWrapper) -> Bool {
    return wrappedInstance.isTotallyOrdered(belowOrEqualTo: other.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func isLessThanOrEqualTo(_ other: DecimalWrapper) -> Bool {
    return wrappedInstance.isLessThanOrEqualTo(other.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func isLess(than other: DecimalWrapper) -> Bool {
    return wrappedInstance.isLess(than: other.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func isEqual(to other: DecimalWrapper) -> Bool {
    return wrappedInstance.isEqual(to: other.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func advanced(by n: DecimalWrapper) -> DecimalWrapper {
    let result = wrappedInstance.advanced(by: n.wrappedInstance)
    return DecimalWrapper(result)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func distance(to other: DecimalWrapper) -> DecimalWrapper {
    let result = wrappedInstance.distance(to: other.wrappedInstance)
    return DecimalWrapper(result)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func formatted() -> String {
    return wrappedInstance.formatted()
  }

  @objc public func negate() {
    return wrappedInstance.negate()
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class FormatStyleWrapper: NSObject {
    var wrappedInstance: Decimal.FormatStyle

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var number: DecimalWrapper.FormatStyleWrapper {
      get {
        FormatStyleWrapper(Decimal.FormatStyle.number)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var number: DecimalWrapper.FormatStyleWrapper {
      get {
        FormatStyleWrapper(Decimal.FormatStyle.number)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var attributed: FormatStyleWrapper.AttributedWrapper {
      get {
        AttributedWrapper(wrappedInstance.attributed)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var parseStrategy: DecimalWrapper.ParseStrategyWrapper {
      get {
        ParseStrategyWrapper(wrappedInstance.parseStrategy)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var locale: LocaleWrapper {
      get {
        LocaleWrapper(wrappedInstance.locale)
      }
      set {
        wrappedInstance.locale = newValue.wrappedInstance
      }
    }

    init(_ wrappedInstance: Decimal.FormatStyle) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func scale(_ multiplicand: Double) -> DecimalWrapper.FormatStyleWrapper {
      let result = wrappedInstance.scale(multiplicand)
      return FormatStyleWrapper(result)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func format(_ value: DecimalWrapper) -> String {
      return wrappedInstance.format(value.wrappedInstance)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func locale(_ locale: LocaleWrapper) -> DecimalWrapper.FormatStyleWrapper {
      let result = wrappedInstance.locale(locale.wrappedInstance)
      return FormatStyleWrapper(result)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public class AttributedWrapper: NSObject {
      var wrappedInstance: FormatStyle.Attributed

      init(_ wrappedInstance: FormatStyle.Attributed) {
        self.wrappedInstance = wrappedInstance
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func format(_ value: DecimalWrapper) -> AttributedStringWrapper {
        let result = wrappedInstance.format(value.wrappedInstance)
        return AttributedStringWrapper(result)
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func locale(_ locale: LocaleWrapper) -> FormatStyleWrapper.AttributedWrapper {
        let result = wrappedInstance.locale(locale.wrappedInstance)
        return AttributedWrapper(result)
      }

    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public class PercentWrapper: NSObject {
      var wrappedInstance: FormatStyle.Percent

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var percent: FormatStyleWrapper.PercentWrapper {
        get {
          PercentWrapper(FormatStyle.Percent.percent)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var percent: FormatStyleWrapper.PercentWrapper {
        get {
          PercentWrapper(FormatStyle.Percent.percent)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public var attributed: FormatStyleWrapper.AttributedWrapper {
        get {
          AttributedWrapper(wrappedInstance.attributed)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public var parseStrategy: DecimalWrapper.ParseStrategyWrapper {
        get {
          ParseStrategyWrapper(wrappedInstance.parseStrategy)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public var locale: LocaleWrapper {
        get {
          LocaleWrapper(wrappedInstance.locale)
        }
        set {
          wrappedInstance.locale = newValue.wrappedInstance
        }
      }

      init(_ wrappedInstance: FormatStyle.Percent) {
        self.wrappedInstance = wrappedInstance
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func scale(_ multiplicand: Double) -> FormatStyleWrapper.PercentWrapper {
        let result = wrappedInstance.scale(multiplicand)
        return PercentWrapper(result)
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func format(_ value: DecimalWrapper) -> String {
        return wrappedInstance.format(value.wrappedInstance)
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func locale(_ locale: LocaleWrapper) -> FormatStyleWrapper.PercentWrapper {
        let result = wrappedInstance.locale(locale.wrappedInstance)
        return PercentWrapper(result)
      }

    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public class CurrencyWrapper: NSObject {
      var wrappedInstance: FormatStyle.Currency

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public var attributed: FormatStyleWrapper.AttributedWrapper {
        get {
          AttributedWrapper(wrappedInstance.attributed)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public var currencyCode: String {
        get {
          wrappedInstance.currencyCode
        }
        set {
          wrappedInstance.currencyCode = newValue
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public var parseStrategy: DecimalWrapper.ParseStrategyWrapper {
        get {
          ParseStrategyWrapper(wrappedInstance.parseStrategy)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public var locale: LocaleWrapper {
        get {
          LocaleWrapper(wrappedInstance.locale)
        }
        set {
          wrappedInstance.locale = newValue.wrappedInstance
        }
      }

      init(_ wrappedInstance: FormatStyle.Currency) {
        self.wrappedInstance = wrappedInstance
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func scale(_ multiplicand: Double) -> FormatStyleWrapper.CurrencyWrapper {
        let result = wrappedInstance.scale(multiplicand)
        return CurrencyWrapper(result)
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func format(_ value: DecimalWrapper) -> String {
        return wrappedInstance.format(value.wrappedInstance)
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func locale(_ locale: LocaleWrapper) -> FormatStyleWrapper.CurrencyWrapper {
        let result = wrappedInstance.locale(locale.wrappedInstance)
        return CurrencyWrapper(result)
      }

    }

  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class ParseStrategyWrapper: NSObject {
    var wrappedInstance: Decimal.ParseStrategy

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var lenient: Bool {
      get {
        wrappedInstance.lenient
      }
      set {
        wrappedInstance.lenient = newValue
      }
    }

    init(_ wrappedInstance: Decimal.ParseStrategy) {
      self.wrappedInstance = wrappedInstance
    }

  }

}

@objc public class StringTransformWrapper: NSObject {
  var wrappedInstance: StringTransform

  @available(macOS, introduced: 10.11)
  @objc static public var fullwidthToHalfwidth: StringTransformWrapper {
    get {
      StringTransformWrapper(StringTransform.fullwidthToHalfwidth)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var hiraganaToKatakana: StringTransformWrapper {
    get {
      StringTransformWrapper(StringTransform.hiraganaToKatakana)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var latinToArabic: StringTransformWrapper {
    get {
      StringTransformWrapper(StringTransform.latinToArabic)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var latinToCyrillic: StringTransformWrapper {
    get {
      StringTransformWrapper(StringTransform.latinToCyrillic)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var latinToGreek: StringTransformWrapper {
    get {
      StringTransformWrapper(StringTransform.latinToGreek)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var latinToHangul: StringTransformWrapper {
    get {
      StringTransformWrapper(StringTransform.latinToHangul)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var latinToHebrew: StringTransformWrapper {
    get {
      StringTransformWrapper(StringTransform.latinToHebrew)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var latinToHiragana: StringTransformWrapper {
    get {
      StringTransformWrapper(StringTransform.latinToHiragana)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var latinToKatakana: StringTransformWrapper {
    get {
      StringTransformWrapper(StringTransform.latinToKatakana)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var latinToThai: StringTransformWrapper {
    get {
      StringTransformWrapper(StringTransform.latinToThai)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var mandarinToLatin: StringTransformWrapper {
    get {
      StringTransformWrapper(StringTransform.mandarinToLatin)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var stripCombiningMarks: StringTransformWrapper {
    get {
      StringTransformWrapper(StringTransform.stripCombiningMarks)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var stripDiacritics: StringTransformWrapper {
    get {
      StringTransformWrapper(StringTransform.stripDiacritics)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var toLatin: StringTransformWrapper {
    get {
      StringTransformWrapper(StringTransform.toLatin)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var toUnicodeName: StringTransformWrapper {
    get {
      StringTransformWrapper(StringTransform.toUnicodeName)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var toXMLHex: StringTransformWrapper {
    get {
      StringTransformWrapper(StringTransform.toXMLHex)
    }
  }

  init(_ wrappedInstance: StringTransform) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = StringTransform(rawValue: rawValue)
  }

  @objc init(_ rawValue: String) {
    wrappedInstance = StringTransform(rawValue)
  }

}

@objc public class URLFileProtectionWrapper: NSObject {
  var wrappedInstance: URLFileProtection

  @available(macOS, introduced: 11.0)
  @objc static public var complete: URLFileProtectionWrapper {
    get {
      URLFileProtectionWrapper(URLFileProtection.complete)
    }
  }

  @available(macOS, introduced: 11.0)
  @objc static public var completeUnlessOpen: URLFileProtectionWrapper {
    get {
      URLFileProtectionWrapper(URLFileProtection.completeUnlessOpen)
    }
  }

  @available(macOS, introduced: 11.0)
  @objc static public var completeUntilFirstUserAuthentication: URLFileProtectionWrapper {
    get {
      URLFileProtectionWrapper(URLFileProtection.completeUntilFirstUserAuthentication)
    }
  }

  @available(macOS, introduced: 11.0)
  @objc static public var none: URLFileProtectionWrapper {
    get {
      URLFileProtectionWrapper(URLFileProtection.none)
    }
  }

  init(_ wrappedInstance: URLFileProtection) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = URLFileProtection(rawValue: rawValue)
  }

}

@objc public class URLFileResourceTypeWrapper: NSObject {
  var wrappedInstance: URLFileResourceType

  @available(macOS, introduced: 10.7)
  @objc static public var blockSpecial: URLFileResourceTypeWrapper {
    get {
      URLFileResourceTypeWrapper(URLFileResourceType.blockSpecial)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var characterSpecial: URLFileResourceTypeWrapper {
    get {
      URLFileResourceTypeWrapper(URLFileResourceType.characterSpecial)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var directory: URLFileResourceTypeWrapper {
    get {
      URLFileResourceTypeWrapper(URLFileResourceType.directory)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var namedPipe: URLFileResourceTypeWrapper {
    get {
      URLFileResourceTypeWrapper(URLFileResourceType.namedPipe)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var regular: URLFileResourceTypeWrapper {
    get {
      URLFileResourceTypeWrapper(URLFileResourceType.regular)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var socket: URLFileResourceTypeWrapper {
    get {
      URLFileResourceTypeWrapper(URLFileResourceType.socket)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var symbolicLink: URLFileResourceTypeWrapper {
    get {
      URLFileResourceTypeWrapper(URLFileResourceType.symbolicLink)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var unknown: URLFileResourceTypeWrapper {
    get {
      URLFileResourceTypeWrapper(URLFileResourceType.unknown)
    }
  }

  init(_ wrappedInstance: URLFileResourceType) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = URLFileResourceType(rawValue: rawValue)
  }

}

@objc public class URLResourceKeyWrapper: NSObject {
  var wrappedInstance: URLResourceKey

  @available(macOS, introduced: 10.10)
  @objc static public var addedToDirectoryDateKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.addedToDirectoryDateKey)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var applicationIsScriptableKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.applicationIsScriptableKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var attributeModificationDateKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.attributeModificationDateKey)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var canonicalPathKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.canonicalPathKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var contentAccessDateKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.contentAccessDateKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var contentModificationDateKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.contentModificationDateKey)
    }
  }

  @available(macOS, introduced: 11.0)
  @objc static public var contentTypeKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.contentTypeKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var creationDateKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.creationDateKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var customIconKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.customIconKey)
    }
  }

  @available(macOS, introduced: 14.0)
  @objc static public var directoryEntryCountKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.directoryEntryCountKey)
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var documentIdentifierKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.documentIdentifierKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var effectiveIconKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.effectiveIconKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var fileAllocatedSizeKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.fileAllocatedSizeKey)
    }
  }

  @available(macOS, introduced: 11.0)
  @objc static public var fileContentIdentifierKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.fileContentIdentifierKey)
    }
  }

  @available(macOS, introduced: 13.3)
  @objc static public var fileIdentifierKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.fileIdentifierKey)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var fileProtectionKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.fileProtectionKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var fileResourceIdentifierKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.fileResourceIdentifierKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var fileResourceTypeKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.fileResourceTypeKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var fileSecurityKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.fileSecurityKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var fileSizeKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.fileSizeKey)
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var generationIdentifierKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.generationIdentifierKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var hasHiddenExtensionKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.hasHiddenExtensionKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var isAliasFileKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.isAliasFileKey)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var isApplicationKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.isApplicationKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var isDirectoryKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.isDirectoryKey)
    }
  }

  @available(macOS, introduced: 10.8)
  @objc static public var isExcludedFromBackupKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.isExcludedFromBackupKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var isExecutableKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.isExecutableKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var isHiddenKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.isHiddenKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var isMountTriggerKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.isMountTriggerKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var isPackageKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.isPackageKey)
    }
  }

  @available(macOS, introduced: 11.0)
  @objc static public var isPurgeableKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.isPurgeableKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var isReadableKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.isReadableKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var isRegularFileKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.isRegularFileKey)
    }
  }

  @available(macOS, introduced: 11.0)
  @objc static public var isSparseKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.isSparseKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var isSymbolicLinkKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.isSymbolicLinkKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var isSystemImmutableKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.isSystemImmutableKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var isUbiquitousItemKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.isUbiquitousItemKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var isUserImmutableKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.isUserImmutableKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var isVolumeKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.isVolumeKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var isWritableKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.isWritableKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var keysOfUnsetValuesKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.keysOfUnsetValuesKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var labelColorKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.labelColorKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var labelNumberKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.labelNumberKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var linkCountKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.linkCountKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var localizedLabelKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.localizedLabelKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var localizedNameKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.localizedNameKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var localizedTypeDescriptionKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.localizedTypeDescriptionKey)
    }
  }

  @available(macOS, introduced: 11.0)
  @objc static public var mayHaveExtendedAttributesKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.mayHaveExtendedAttributesKey)
    }
  }

  @available(macOS, introduced: 11.0)
  @objc static public var mayShareFileContentKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.mayShareFileContentKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var nameKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.nameKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var parentDirectoryURLKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.parentDirectoryURLKey)
    }
  }

  @available(macOS, introduced: 10.8)
  @objc static public var pathKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.pathKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var preferredIOBlockSizeKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.preferredIOBlockSizeKey)
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var quarantinePropertiesKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.quarantinePropertiesKey)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var tagNamesKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.tagNamesKey)
    }
  }

  @available(macOS, introduced: 10.10, deprecated: 12.0)
  @objc static public var thumbnailDictionaryKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.thumbnailDictionaryKey)
    }
  }

  @available(macOS, introduced: 10.10, deprecated: 12.0)
  @objc static public var thumbnailKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.thumbnailKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var totalFileAllocatedSizeKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.totalFileAllocatedSizeKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var totalFileSizeKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.totalFileSizeKey)
    }
  }

  @available(macOS, introduced: 10.6, deprecated: 100000)
  @objc static public var typeIdentifierKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.typeIdentifierKey)
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var ubiquitousItemContainerDisplayNameKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.ubiquitousItemContainerDisplayNameKey)
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var ubiquitousItemDownloadRequestedKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.ubiquitousItemDownloadRequestedKey)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var ubiquitousItemDownloadingErrorKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.ubiquitousItemDownloadingErrorKey)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var ubiquitousItemDownloadingStatusKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.ubiquitousItemDownloadingStatusKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var ubiquitousItemHasUnresolvedConflictsKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.ubiquitousItemHasUnresolvedConflictsKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var ubiquitousItemIsDownloadingKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.ubiquitousItemIsDownloadingKey)
    }
  }

  @available(macOS, introduced: 11.3)
  @objc static public var ubiquitousItemIsExcludedFromSyncKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.ubiquitousItemIsExcludedFromSyncKey)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var ubiquitousItemIsSharedKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.ubiquitousItemIsSharedKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var ubiquitousItemIsUploadedKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.ubiquitousItemIsUploadedKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var ubiquitousItemIsUploadingKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.ubiquitousItemIsUploadingKey)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var ubiquitousItemUploadingErrorKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.ubiquitousItemUploadingErrorKey)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var ubiquitousSharedItemCurrentUserPermissionsKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.ubiquitousSharedItemCurrentUserPermissionsKey)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var ubiquitousSharedItemCurrentUserRoleKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.ubiquitousSharedItemCurrentUserRoleKey)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var ubiquitousSharedItemMostRecentEditorNameComponentsKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.ubiquitousSharedItemMostRecentEditorNameComponentsKey)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var ubiquitousSharedItemOwnerNameComponentsKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.ubiquitousSharedItemOwnerNameComponentsKey)
    }
  }

  @available(macOS, introduced: 10.13)
  @objc static public var volumeAvailableCapacityForImportantUsageKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeAvailableCapacityForImportantUsageKey)
    }
  }

  @available(macOS, introduced: 10.13)
  @objc static public var volumeAvailableCapacityForOpportunisticUsageKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeAvailableCapacityForOpportunisticUsageKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var volumeAvailableCapacityKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeAvailableCapacityKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var volumeCreationDateKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeCreationDateKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var volumeIdentifierKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeIdentifierKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var volumeIsAutomountedKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeIsAutomountedKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var volumeIsBrowsableKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeIsBrowsableKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var volumeIsEjectableKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeIsEjectableKey)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var volumeIsEncryptedKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeIsEncryptedKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var volumeIsInternalKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeIsInternalKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var volumeIsJournalingKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeIsJournalingKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var volumeIsLocalKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeIsLocalKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var volumeIsReadOnlyKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeIsReadOnlyKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var volumeIsRemovableKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeIsRemovableKey)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var volumeIsRootFileSystemKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeIsRootFileSystemKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var volumeLocalizedFormatDescriptionKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeLocalizedFormatDescriptionKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var volumeLocalizedNameKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeLocalizedNameKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var volumeMaximumFileSizeKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeMaximumFileSizeKey)
    }
  }

  @available(macOS, introduced: 13.3)
  @objc static public var volumeMountFromLocationKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeMountFromLocationKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var volumeNameKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeNameKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var volumeResourceCountKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeResourceCountKey)
    }
  }

  @available(macOS, introduced: 13.3)
  @objc static public var volumeSubtypeKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeSubtypeKey)
    }
  }

  @available(macOS, introduced: 10.13)
  @objc static public var volumeSupportsAccessPermissionsKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeSupportsAccessPermissionsKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var volumeSupportsAdvisoryFileLockingKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeSupportsAdvisoryFileLockingKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var volumeSupportsCasePreservedNamesKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeSupportsCasePreservedNamesKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var volumeSupportsCaseSensitiveNamesKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeSupportsCaseSensitiveNamesKey)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var volumeSupportsCompressionKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeSupportsCompressionKey)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var volumeSupportsExclusiveRenamingKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeSupportsExclusiveRenamingKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var volumeSupportsExtendedSecurityKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeSupportsExtendedSecurityKey)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var volumeSupportsFileCloningKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeSupportsFileCloningKey)
    }
  }

  @available(macOS, introduced: 11.0)
  @objc static public var volumeSupportsFileProtectionKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeSupportsFileProtectionKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var volumeSupportsHardLinksKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeSupportsHardLinksKey)
    }
  }

  @available(macOS, introduced: 10.13)
  @objc static public var volumeSupportsImmutableFilesKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeSupportsImmutableFilesKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var volumeSupportsJournalingKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeSupportsJournalingKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var volumeSupportsPersistentIDsKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeSupportsPersistentIDsKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var volumeSupportsRenamingKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeSupportsRenamingKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var volumeSupportsRootDirectoryDatesKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeSupportsRootDirectoryDatesKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var volumeSupportsSparseFilesKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeSupportsSparseFilesKey)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var volumeSupportsSwapRenamingKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeSupportsSwapRenamingKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var volumeSupportsSymbolicLinksKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeSupportsSymbolicLinksKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var volumeSupportsVolumeSizesKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeSupportsVolumeSizesKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var volumeSupportsZeroRunsKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeSupportsZeroRunsKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var volumeTotalCapacityKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeTotalCapacityKey)
    }
  }

  @available(macOS, introduced: 13.3)
  @objc static public var volumeTypeNameKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeTypeNameKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var volumeURLForRemountingKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeURLForRemountingKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var volumeURLKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeURLKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var volumeUUIDStringKey: URLResourceKeyWrapper {
    get {
      URLResourceKeyWrapper(URLResourceKey.volumeUUIDStringKey)
    }
  }

  init(_ wrappedInstance: URLResourceKey) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = URLResourceKey(rawValue: rawValue)
  }

  @objc init(_ rawValue: String) {
    wrappedInstance = URLResourceKey(rawValue)
  }

}

@objc public class URLUbiquitousItemDownloadingStatusWrapper: NSObject {
  var wrappedInstance: URLUbiquitousItemDownloadingStatus

  @available(macOS, introduced: 10.9)
  @objc static public var current: URLUbiquitousItemDownloadingStatusWrapper {
    get {
      URLUbiquitousItemDownloadingStatusWrapper(URLUbiquitousItemDownloadingStatus.current)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var downloaded: URLUbiquitousItemDownloadingStatusWrapper {
    get {
      URLUbiquitousItemDownloadingStatusWrapper(URLUbiquitousItemDownloadingStatus.downloaded)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var notDownloaded: URLUbiquitousItemDownloadingStatusWrapper {
    get {
      URLUbiquitousItemDownloadingStatusWrapper(URLUbiquitousItemDownloadingStatus.notDownloaded)
    }
  }

  init(_ wrappedInstance: URLUbiquitousItemDownloadingStatus) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = URLUbiquitousItemDownloadingStatus(rawValue: rawValue)
  }

}

@objc public class URLUbiquitousSharedItemPermissionsWrapper: NSObject {
  var wrappedInstance: URLUbiquitousSharedItemPermissions

  @available(macOS, introduced: 10.12)
  @objc static public var readOnly: URLUbiquitousSharedItemPermissionsWrapper {
    get {
      URLUbiquitousSharedItemPermissionsWrapper(URLUbiquitousSharedItemPermissions.readOnly)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var readWrite: URLUbiquitousSharedItemPermissionsWrapper {
    get {
      URLUbiquitousSharedItemPermissionsWrapper(URLUbiquitousSharedItemPermissions.readWrite)
    }
  }

  init(_ wrappedInstance: URLUbiquitousSharedItemPermissions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = URLUbiquitousSharedItemPermissions(rawValue: rawValue)
  }

}

@objc public class URLUbiquitousSharedItemRoleWrapper: NSObject {
  var wrappedInstance: URLUbiquitousSharedItemRole

  @available(macOS, introduced: 10.12)
  @objc static public var owner: URLUbiquitousSharedItemRoleWrapper {
    get {
      URLUbiquitousSharedItemRoleWrapper(URLUbiquitousSharedItemRole.owner)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var participant: URLUbiquitousSharedItemRoleWrapper {
    get {
      URLUbiquitousSharedItemRoleWrapper(URLUbiquitousSharedItemRole.participant)
    }
  }

  init(_ wrappedInstance: URLUbiquitousSharedItemRole) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = URLUbiquitousSharedItemRole(rawValue: rawValue)
  }

}

@objc public class BundleWrapper: NSObject {
  var wrappedInstance: Bundle

  @objc static public var didLoadNotification: NSNotificationWrapper.NameWrapper {
    get {
      NameWrapper(Bundle.didLoadNotification)
    }
  }

  @objc static public var main: BundleWrapper {
    get {
      BundleWrapper(Bundle.main)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 15.0)
  @objc public var appStoreReceiptURL: URLWrapper? {
    get {
      wrappedInstance.appStoreReceiptURL == nil ? nil : URLWrapper(wrappedInstance.appStoreReceiptURL!)
    }
  }

  @objc public var builtInPlugInsPath: String? {
    get {
      wrappedInstance.builtInPlugInsPath
    }
  }

  @available(macOS, introduced: 10.6)
  @objc public var builtInPlugInsURL: URLWrapper? {
    get {
      wrappedInstance.builtInPlugInsURL == nil ? nil : URLWrapper(wrappedInstance.builtInPlugInsURL!)
    }
  }

  @objc public var bundleIdentifier: String? {
    get {
      wrappedInstance.bundleIdentifier
    }
  }

  @objc public var bundlePath: String {
    get {
      wrappedInstance.bundlePath
    }
  }

  @available(macOS, introduced: 10.6)
  @objc public var bundleURL: URLWrapper {
    get {
      URLWrapper(wrappedInstance.bundleURL)
    }
  }

  @objc public var developmentLocalization: String? {
    get {
      wrappedInstance.developmentLocalization
    }
  }

  @objc public var executablePath: String? {
    get {
      wrappedInstance.executablePath
    }
  }

  @available(macOS, introduced: 10.6)
  @objc public var executableURL: URLWrapper? {
    get {
      wrappedInstance.executableURL == nil ? nil : URLWrapper(wrappedInstance.executableURL!)
    }
  }

  @objc public var isLoaded: Bool {
    get {
      wrappedInstance.isLoaded
    }
  }

  @objc public var privateFrameworksPath: String? {
    get {
      wrappedInstance.privateFrameworksPath
    }
  }

  @available(macOS, introduced: 10.6)
  @objc public var privateFrameworksURL: URLWrapper? {
    get {
      wrappedInstance.privateFrameworksURL == nil ? nil : URLWrapper(wrappedInstance.privateFrameworksURL!)
    }
  }

  @objc public var resourcePath: String? {
    get {
      wrappedInstance.resourcePath
    }
  }

  @available(macOS, introduced: 10.6)
  @objc public var resourceURL: URLWrapper? {
    get {
      wrappedInstance.resourceURL == nil ? nil : URLWrapper(wrappedInstance.resourceURL!)
    }
  }

  @objc public var sharedFrameworksPath: String? {
    get {
      wrappedInstance.sharedFrameworksPath
    }
  }

  @available(macOS, introduced: 10.6)
  @objc public var sharedFrameworksURL: URLWrapper? {
    get {
      wrappedInstance.sharedFrameworksURL == nil ? nil : URLWrapper(wrappedInstance.sharedFrameworksURL!)
    }
  }

  @objc public var sharedSupportPath: String? {
    get {
      wrappedInstance.sharedSupportPath
    }
  }

  @available(macOS, introduced: 10.6)
  @objc public var sharedSupportURL: URLWrapper? {
    get {
      wrappedInstance.sharedSupportURL == nil ? nil : URLWrapper(wrappedInstance.sharedSupportURL!)
    }
  }

  init(_ wrappedInstance: Bundle) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init?(identifier: String) {
    if let instance = Bundle(identifier: identifier) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @objc init?(path: String) {
    if let instance = Bundle(path: path) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public func url(forResource name: String?, withExtension ext: String?, subdirectory subpath: String?, in bundleURL: URLWrapper) -> URLWrapper? {
    let result = Bundle.url(forResource: name, withExtension: ext, subdirectory: subpath, in: bundleURL.wrappedInstance)
    return result == nil ? nil : URLWrapper(result!)
  }

  @objc static public func path(forResource name: String?, ofType ext: String?, inDirectory bundlePath: String) -> String? {
    return Bundle.path(forResource: name, ofType: ext, inDirectory: bundlePath)
  }

  @available(macOS, introduced: 10.6)
  @objc public func url(forAuxiliaryExecutable executableName: String) -> URLWrapper? {
    let result = wrappedInstance.url(forAuxiliaryExecutable: executableName)
    return result == nil ? nil : URLWrapper(result!)
  }

  @available(macOS, introduced: 10.6)
  @objc public func url(forResource name: String?, withExtension ext: String?) -> URLWrapper? {
    let result = wrappedInstance.url(forResource: name, withExtension: ext)
    return result == nil ? nil : URLWrapper(result!)
  }

  @available(macOS, introduced: 10.6)
  @objc public func url(forResource name: String?, withExtension ext: String?, subdirectory subpath: String?) -> URLWrapper? {
    let result = wrappedInstance.url(forResource: name, withExtension: ext, subdirectory: subpath)
    return result == nil ? nil : URLWrapper(result!)
  }

  @available(macOS, introduced: 10.6)
  @objc public func url(forResource name: String?, withExtension ext: String?, subdirectory subpath: String?, localization localizationName: String?) -> URLWrapper? {
    let result = wrappedInstance.url(forResource: name, withExtension: ext, subdirectory: subpath, localization: localizationName)
    return result == nil ? nil : URLWrapper(result!)
  }

  @objc public func load() -> Bool {
    return wrappedInstance.load()
  }

  @available(macOS, introduced: 10.5)
  @objc public func loadAndReturnError() throws {
    return try wrappedInstance.loadAndReturnError()
  }

  @objc public func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
    return wrappedInstance.localizedString(forKey: key, value: value, table: tableName)
  }

  @objc public func path(forAuxiliaryExecutable executableName: String) -> String? {
    return wrappedInstance.path(forAuxiliaryExecutable: executableName)
  }

  @objc public func path(forResource name: String?, ofType ext: String?) -> String? {
    return wrappedInstance.path(forResource: name, ofType: ext)
  }

  @objc public func path(forResource name: String?, ofType ext: String?, inDirectory subpath: String?, forLocalization localizationName: String?) -> String? {
    return wrappedInstance.path(forResource: name, ofType: ext, inDirectory: subpath, forLocalization: localizationName)
  }

  @available(macOS, introduced: 10.5)
  @objc public func preflight() throws {
    return try wrappedInstance.preflight()
  }

  @objc public func unload() -> Bool {
    return wrappedInstance.unload()
  }

}

@objc public class NSCalendarWrapper: NSObject {
  var wrappedInstance: NSCalendar

  @available(macOS, introduced: 10.5)
  @objc static public var autoupdatingCurrent: CalendarWrapper {
    get {
      CalendarWrapper(NSCalendar.autoupdatingCurrent)
    }
  }

  @objc static public var current: CalendarWrapper {
    get {
      CalendarWrapper(NSCalendar.current)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc public var amSymbol: String {
    get {
      wrappedInstance.amSymbol
    }
  }

  @available(macOS, introduced: 10.7)
  @objc public var pmSymbol: String {
    get {
      wrappedInstance.pmSymbol
    }
  }

  @objc public var calendarIdentifier: NSCalendarWrapper.IdentifierWrapper {
    get {
      IdentifierWrapper(wrappedInstance.calendarIdentifier)
    }
  }

  @objc public var firstWeekday: Int {
    get {
      wrappedInstance.firstWeekday
    }
    set {
      wrappedInstance.firstWeekday = newValue
    }
  }

  @objc public var locale: LocaleWrapper? {
    get {
      wrappedInstance.locale == nil ? nil : LocaleWrapper(wrappedInstance.locale!)
    }
    set {
      wrappedInstance.locale = newValue?.wrappedInstance
    }
  }

  @objc public var minimumDaysInFirstWeek: Int {
    get {
      wrappedInstance.minimumDaysInFirstWeek
    }
    set {
      wrappedInstance.minimumDaysInFirstWeek = newValue
    }
  }

  @objc public var timeZone: TimeZoneWrapper {
    get {
      TimeZoneWrapper(wrappedInstance.timeZone)
    }
    set {
      wrappedInstance.timeZone = newValue.wrappedInstance
    }
  }

  init(_ wrappedInstance: NSCalendar) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.9)
  @objc init?(identifier calendarIdentifierConstant: NSCalendarWrapper.IdentifierWrapper) {
    if let instance = NSCalendar(identifier: calendarIdentifierConstant.wrappedInstance) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @objc init?(calendarIdentifier ident: NSCalendarWrapper.IdentifierWrapper) {
    if let instance = NSCalendar(calendarIdentifier: ident.wrappedInstance) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @objc init?(coder: NSCoderWrapper) {
    if let instance = NSCalendar(coder: coder.wrappedInstance) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @available(macOS, introduced: 10.9)
  @objc public func component(_ unit: NSCalendarWrapper.UnitWrapper, from date: DateWrapper) -> Int {
    return wrappedInstance.component(unit.wrappedInstance, from: date.wrappedInstance)
  }

  @objc public func components(_ unitFlags: NSCalendarWrapper.UnitWrapper, from date: DateWrapper) -> DateComponentsWrapper {
    let result = wrappedInstance.components(unitFlags.wrappedInstance, from: date.wrappedInstance)
    return DateComponentsWrapper(result)
  }

  @available(macOS, introduced: 10.9)
  @objc public func components(in timezone: TimeZoneWrapper, from date: DateWrapper) -> DateComponentsWrapper {
    let result = wrappedInstance.components(in: timezone.wrappedInstance, from: date.wrappedInstance)
    return DateComponentsWrapper(result)
  }

  @available(macOS, introduced: 10.9)
  @objc public func date(_ date: DateWrapper, matchesComponents components: DateComponentsWrapper) -> Bool {
    return wrappedInstance.date(date.wrappedInstance, matchesComponents: components.wrappedInstance)
  }

  @objc public func date(from comps: DateComponentsWrapper) -> DateWrapper? {
    let result = wrappedInstance.date(from: comps.wrappedInstance)
    return result == nil ? nil : DateWrapper(result!)
  }

  @available(macOS, introduced: 10.9)
  @objc public func date(era eraValue: Int, year yearValue: Int, month monthValue: Int, day dayValue: Int, hour hourValue: Int, minute minuteValue: Int, second secondValue: Int, nanosecond nanosecondValue: Int) -> DateWrapper? {
    let result = wrappedInstance.date(era: eraValue, year: yearValue, month: monthValue, day: dayValue, hour: hourValue, minute: minuteValue, second: secondValue, nanosecond: nanosecondValue)
    return result == nil ? nil : DateWrapper(result!)
  }

  @available(macOS, introduced: 10.9)
  @objc public func date(era eraValue: Int, yearForWeekOfYear yearValue: Int, weekOfYear weekValue: Int, weekday weekdayValue: Int, hour hourValue: Int, minute minuteValue: Int, second secondValue: Int, nanosecond nanosecondValue: Int) -> DateWrapper? {
    let result = wrappedInstance.date(era: eraValue, yearForWeekOfYear: yearValue, weekOfYear: weekValue, weekday: weekdayValue, hour: hourValue, minute: minuteValue, second: secondValue, nanosecond: nanosecondValue)
    return result == nil ? nil : DateWrapper(result!)
  }

  @available(macOS, introduced: 10.9)
  @objc public func isDate(_ date1: DateWrapper, equalTo date2: DateWrapper, toUnitGranularity unit: NSCalendarWrapper.UnitWrapper) -> Bool {
    return wrappedInstance.isDate(date1.wrappedInstance, equalTo: date2.wrappedInstance, toUnitGranularity: unit.wrappedInstance)
  }

  @available(macOS, introduced: 10.9)
  @objc public func isDate(_ date1: DateWrapper, inSameDayAs date2: DateWrapper) -> Bool {
    return wrappedInstance.isDate(date1.wrappedInstance, inSameDayAs: date2.wrappedInstance)
  }

  @available(macOS, introduced: 10.9)
  @objc public func isDateInToday(_ date: DateWrapper) -> Bool {
    return wrappedInstance.isDateInToday(date.wrappedInstance)
  }

  @available(macOS, introduced: 10.9)
  @objc public func isDateInTomorrow(_ date: DateWrapper) -> Bool {
    return wrappedInstance.isDateInTomorrow(date.wrappedInstance)
  }

  @available(macOS, introduced: 10.9)
  @objc public func isDateInWeekend(_ date: DateWrapper) -> Bool {
    return wrappedInstance.isDateInWeekend(date.wrappedInstance)
  }

  @available(macOS, introduced: 10.9)
  @objc public func isDateInYesterday(_ date: DateWrapper) -> Bool {
    return wrappedInstance.isDateInYesterday(date.wrappedInstance)
  }

  @objc public func ordinality(of smaller: NSCalendarWrapper.UnitWrapper, in larger: NSCalendarWrapper.UnitWrapper, for date: DateWrapper) -> Int {
    return wrappedInstance.ordinality(of: smaller.wrappedInstance, in: larger.wrappedInstance, for: date.wrappedInstance)
  }

  @available(macOS, introduced: 10.9)
  @objc public func startOfDay(for date: DateWrapper) -> DateWrapper {
    let result = wrappedInstance.startOfDay(for: date.wrappedInstance)
    return DateWrapper(result)
  }

  @objc public class OptionsWrapper: NSObject {
    var wrappedInstance: NSCalendar.Options

    @available(macOS, introduced: 10.9)
    @objc static public var matchFirst: NSCalendarWrapper.OptionsWrapper {
      get {
        OptionsWrapper(NSCalendar.Options.matchFirst)
      }
    }

    @available(macOS, introduced: 10.9)
    @objc static public var matchLast: NSCalendarWrapper.OptionsWrapper {
      get {
        OptionsWrapper(NSCalendar.Options.matchLast)
      }
    }

    @available(macOS, introduced: 10.9)
    @objc static public var matchNextTime: NSCalendarWrapper.OptionsWrapper {
      get {
        OptionsWrapper(NSCalendar.Options.matchNextTime)
      }
    }

    @available(macOS, introduced: 10.9)
    @objc static public var matchNextTimePreservingSmallerUnits: NSCalendarWrapper.OptionsWrapper {
      get {
        OptionsWrapper(NSCalendar.Options.matchNextTimePreservingSmallerUnits)
      }
    }

    @available(macOS, introduced: 10.9)
    @objc static public var matchPreviousTimePreservingSmallerUnits: NSCalendarWrapper.OptionsWrapper {
      get {
        OptionsWrapper(NSCalendar.Options.matchPreviousTimePreservingSmallerUnits)
      }
    }

    @available(macOS, introduced: 10.9)
    @objc static public var matchStrictly: NSCalendarWrapper.OptionsWrapper {
      get {
        OptionsWrapper(NSCalendar.Options.matchStrictly)
      }
    }

    @available(macOS, introduced: 10.9)
    @objc static public var searchBackwards: NSCalendarWrapper.OptionsWrapper {
      get {
        OptionsWrapper(NSCalendar.Options.searchBackwards)
      }
    }

    @objc static public var wrapComponents: NSCalendarWrapper.OptionsWrapper {
      get {
        OptionsWrapper(NSCalendar.Options.wrapComponents)
      }
    }

    @objc public var isEmpty: Bool {
      get {
        wrappedInstance.isEmpty
      }
    }

    init(_ wrappedInstance: NSCalendar.Options) {
      self.wrappedInstance = wrappedInstance
    }

    @objc override init() {
      wrappedInstance = NSCalendar.Options()
    }

  }

  @objc public class UnitWrapper: NSObject {
    var wrappedInstance: NSCalendar.Unit

    @available(macOS, introduced: 10.7, deprecated: 10.10)
    @objc static public var NSCalendarCalendarUnit: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.NSCalendarCalendarUnit)
      }
    }

    @available(macOS, introduced: 10.7)
    @objc static public var calendar: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.calendar)
      }
    }

    @objc static public var day: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.day)
      }
    }

    @available(macOS, introduced: 15.0)
    @objc static public var dayOfYear: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.dayOfYear)
      }
    }

    @objc static public var era: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.era)
      }
    }

    @objc static public var hour: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.hour)
      }
    }

    @objc static public var minute: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.minute)
      }
    }

    @objc static public var month: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.month)
      }
    }

    @available(macOS, introduced: 10.7)
    @objc static public var nanosecond: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.nanosecond)
      }
    }

    @available(macOS, introduced: 10.6)
    @objc static public var quarter: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.quarter)
      }
    }

    @objc static public var second: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.second)
      }
    }

    @available(macOS, introduced: 10.7)
    @objc static public var timeZone: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.timeZone)
      }
    }

    @available(macOS, introduced: 10.7)
    @objc static public var weekOfMonth: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.weekOfMonth)
      }
    }

    @available(macOS, introduced: 10.7)
    @objc static public var weekOfYear: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.weekOfYear)
      }
    }

    @objc static public var weekday: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.weekday)
      }
    }

    @objc static public var weekdayOrdinal: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.weekdayOrdinal)
      }
    }

    @objc static public var year: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.year)
      }
    }

    @available(macOS, introduced: 10.7)
    @objc static public var yearForWeekOfYear: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.yearForWeekOfYear)
      }
    }

    @available(macOS, introduced: 10.4, deprecated: 10.10)
    @objc static public var NSDayCalendarUnit: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.NSDayCalendarUnit)
      }
    }

    @available(macOS, introduced: 10.4, deprecated: 10.10)
    @objc static public var NSEraCalendarUnit: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.NSEraCalendarUnit)
      }
    }

    @available(macOS, introduced: 10.4, deprecated: 10.10)
    @objc static public var NSHourCalendarUnit: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.NSHourCalendarUnit)
      }
    }

    @available(macOS, introduced: 10.4, deprecated: 10.10)
    @objc static public var NSMinuteCalendarUnit: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.NSMinuteCalendarUnit)
      }
    }

    @available(macOS, introduced: 10.4, deprecated: 10.10)
    @objc static public var NSMonthCalendarUnit: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.NSMonthCalendarUnit)
      }
    }

    @available(macOS, introduced: 10.6, deprecated: 10.10)
    @objc static public var NSQuarterCalendarUnit: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.NSQuarterCalendarUnit)
      }
    }

    @available(macOS, introduced: 10.4, deprecated: 10.10)
    @objc static public var NSSecondCalendarUnit: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.NSSecondCalendarUnit)
      }
    }

    @available(macOS, introduced: 10.7, deprecated: 10.10)
    @objc static public var NSTimeZoneCalendarUnit: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.NSTimeZoneCalendarUnit)
      }
    }

    @available(macOS, introduced: 10.4, deprecated: 10.10)
    @objc static public var NSWeekCalendarUnit: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.NSWeekCalendarUnit)
      }
    }

    @available(macOS, introduced: 10.7, deprecated: 10.10)
    @objc static public var NSWeekOfMonthCalendarUnit: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.NSWeekOfMonthCalendarUnit)
      }
    }

    @available(macOS, introduced: 10.7, deprecated: 10.10)
    @objc static public var NSWeekOfYearCalendarUnit: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.NSWeekOfYearCalendarUnit)
      }
    }

    @available(macOS, introduced: 10.4, deprecated: 10.10)
    @objc static public var NSWeekdayCalendarUnit: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.NSWeekdayCalendarUnit)
      }
    }

    @available(macOS, introduced: 10.4, deprecated: 10.10)
    @objc static public var NSWeekdayOrdinalCalendarUnit: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.NSWeekdayOrdinalCalendarUnit)
      }
    }

    @available(macOS, introduced: 10.4, deprecated: 10.10)
    @objc static public var NSYearCalendarUnit: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.NSYearCalendarUnit)
      }
    }

    @available(macOS, introduced: 10.7, deprecated: 10.10)
    @objc static public var NSYearForWeekOfYearCalendarUnit: NSCalendarWrapper.UnitWrapper {
      get {
        UnitWrapper(NSCalendar.Unit.NSYearForWeekOfYearCalendarUnit)
      }
    }

    @objc public var isEmpty: Bool {
      get {
        wrappedInstance.isEmpty
      }
    }

    init(_ wrappedInstance: NSCalendar.Unit) {
      self.wrappedInstance = wrappedInstance
    }

    @objc override init() {
      wrappedInstance = NSCalendar.Unit()
    }

  }

  @objc public class IdentifierWrapper: NSObject {
    var wrappedInstance: NSCalendar.Identifier

    @available(macOS, introduced: 10.6)
    @objc static public var buddhist: NSCalendarWrapper.IdentifierWrapper {
      get {
        IdentifierWrapper(NSCalendar.Identifier.buddhist)
      }
    }

    @available(macOS, introduced: 10.6)
    @objc static public var chinese: NSCalendarWrapper.IdentifierWrapper {
      get {
        IdentifierWrapper(NSCalendar.Identifier.chinese)
      }
    }

    @available(macOS, introduced: 10.6)
    @objc static public var coptic: NSCalendarWrapper.IdentifierWrapper {
      get {
        IdentifierWrapper(NSCalendar.Identifier.coptic)
      }
    }

    @available(macOS, introduced: 10.6)
    @objc static public var ethiopicAmeteAlem: NSCalendarWrapper.IdentifierWrapper {
      get {
        IdentifierWrapper(NSCalendar.Identifier.ethiopicAmeteAlem)
      }
    }

    @available(macOS, introduced: 10.6)
    @objc static public var ethiopicAmeteMihret: NSCalendarWrapper.IdentifierWrapper {
      get {
        IdentifierWrapper(NSCalendar.Identifier.ethiopicAmeteMihret)
      }
    }

    @available(macOS, introduced: 10.6)
    @objc static public var gregorian: NSCalendarWrapper.IdentifierWrapper {
      get {
        IdentifierWrapper(NSCalendar.Identifier.gregorian)
      }
    }

    @available(macOS, introduced: 10.6)
    @objc static public var hebrew: NSCalendarWrapper.IdentifierWrapper {
      get {
        IdentifierWrapper(NSCalendar.Identifier.hebrew)
      }
    }

    @available(macOS, introduced: 10.6)
    @objc static public var ISO8601: NSCalendarWrapper.IdentifierWrapper {
      get {
        IdentifierWrapper(NSCalendar.Identifier.ISO8601)
      }
    }

    @available(macOS, introduced: 10.6)
    @objc static public var indian: NSCalendarWrapper.IdentifierWrapper {
      get {
        IdentifierWrapper(NSCalendar.Identifier.indian)
      }
    }

    @available(macOS, introduced: 10.6)
    @objc static public var islamic: NSCalendarWrapper.IdentifierWrapper {
      get {
        IdentifierWrapper(NSCalendar.Identifier.islamic)
      }
    }

    @available(macOS, introduced: 10.6)
    @objc static public var islamicCivil: NSCalendarWrapper.IdentifierWrapper {
      get {
        IdentifierWrapper(NSCalendar.Identifier.islamicCivil)
      }
    }

    @available(macOS, introduced: 10.10)
    @objc static public var islamicTabular: NSCalendarWrapper.IdentifierWrapper {
      get {
        IdentifierWrapper(NSCalendar.Identifier.islamicTabular)
      }
    }

    @available(macOS, introduced: 10.10)
    @objc static public var islamicUmmAlQura: NSCalendarWrapper.IdentifierWrapper {
      get {
        IdentifierWrapper(NSCalendar.Identifier.islamicUmmAlQura)
      }
    }

    @available(macOS, introduced: 10.6)
    @objc static public var japanese: NSCalendarWrapper.IdentifierWrapper {
      get {
        IdentifierWrapper(NSCalendar.Identifier.japanese)
      }
    }

    @available(macOS, introduced: 10.6)
    @objc static public var persian: NSCalendarWrapper.IdentifierWrapper {
      get {
        IdentifierWrapper(NSCalendar.Identifier.persian)
      }
    }

    @available(macOS, introduced: 10.6)
    @objc static public var republicOfChina: NSCalendarWrapper.IdentifierWrapper {
      get {
        IdentifierWrapper(NSCalendar.Identifier.republicOfChina)
      }
    }

    init(_ wrappedInstance: NSCalendar.Identifier) {
      self.wrappedInstance = wrappedInstance
    }

    @objc init(rawValue: String) {
      wrappedInstance = NSCalendar.Identifier(rawValue: rawValue)
    }

    @objc init(_ rawValue: String) {
      wrappedInstance = NSCalendar.Identifier(rawValue)
    }

  }

}

@objc public class NSCharacterSetWrapper: NSObject {
  var wrappedInstance: NSCharacterSet

  @available(macOS, introduced: 10.9)
  @objc static public var urlFragmentAllowed: CharacterSetWrapper {
    get {
      CharacterSetWrapper(NSCharacterSet.urlFragmentAllowed)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var urlHostAllowed: CharacterSetWrapper {
    get {
      CharacterSetWrapper(NSCharacterSet.urlHostAllowed)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var urlPasswordAllowed: CharacterSetWrapper {
    get {
      CharacterSetWrapper(NSCharacterSet.urlPasswordAllowed)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var urlPathAllowed: CharacterSetWrapper {
    get {
      CharacterSetWrapper(NSCharacterSet.urlPathAllowed)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var urlQueryAllowed: CharacterSetWrapper {
    get {
      CharacterSetWrapper(NSCharacterSet.urlQueryAllowed)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var urlUserAllowed: CharacterSetWrapper {
    get {
      CharacterSetWrapper(NSCharacterSet.urlUserAllowed)
    }
  }

  @objc static public var alphanumerics: CharacterSetWrapper {
    get {
      CharacterSetWrapper(NSCharacterSet.alphanumerics)
    }
  }

  @objc static public var capitalizedLetters: CharacterSetWrapper {
    get {
      CharacterSetWrapper(NSCharacterSet.capitalizedLetters)
    }
  }

  @objc static public var controlCharacters: CharacterSetWrapper {
    get {
      CharacterSetWrapper(NSCharacterSet.controlCharacters)
    }
  }

  @objc static public var decimalDigits: CharacterSetWrapper {
    get {
      CharacterSetWrapper(NSCharacterSet.decimalDigits)
    }
  }

  @objc static public var decomposables: CharacterSetWrapper {
    get {
      CharacterSetWrapper(NSCharacterSet.decomposables)
    }
  }

  @objc static public var illegalCharacters: CharacterSetWrapper {
    get {
      CharacterSetWrapper(NSCharacterSet.illegalCharacters)
    }
  }

  @objc static public var letters: CharacterSetWrapper {
    get {
      CharacterSetWrapper(NSCharacterSet.letters)
    }
  }

  @objc static public var lowercaseLetters: CharacterSetWrapper {
    get {
      CharacterSetWrapper(NSCharacterSet.lowercaseLetters)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var newlines: CharacterSetWrapper {
    get {
      CharacterSetWrapper(NSCharacterSet.newlines)
    }
  }

  @objc static public var nonBaseCharacters: CharacterSetWrapper {
    get {
      CharacterSetWrapper(NSCharacterSet.nonBaseCharacters)
    }
  }

  @objc static public var punctuationCharacters: CharacterSetWrapper {
    get {
      CharacterSetWrapper(NSCharacterSet.punctuationCharacters)
    }
  }

  @objc static public var symbols: CharacterSetWrapper {
    get {
      CharacterSetWrapper(NSCharacterSet.symbols)
    }
  }

  @objc static public var uppercaseLetters: CharacterSetWrapper {
    get {
      CharacterSetWrapper(NSCharacterSet.uppercaseLetters)
    }
  }

  @objc static public var whitespacesAndNewlines: CharacterSetWrapper {
    get {
      CharacterSetWrapper(NSCharacterSet.whitespacesAndNewlines)
    }
  }

  @objc static public var whitespaces: CharacterSetWrapper {
    get {
      CharacterSetWrapper(NSCharacterSet.whitespaces)
    }
  }

  @objc public var bitmapRepresentation: DataWrapper {
    get {
      DataWrapper(wrappedInstance.bitmapRepresentation)
    }
  }

  @objc public var inverted: CharacterSetWrapper {
    get {
      CharacterSetWrapper(wrappedInstance.inverted)
    }
  }

  init(_ wrappedInstance: NSCharacterSet) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(bitmapRepresentation data: DataWrapper) {
    wrappedInstance = NSCharacterSet(bitmapRepresentation: data.wrappedInstance)
  }

  @objc init(charactersIn aString: String) {
    wrappedInstance = NSCharacterSet(charactersIn: aString)
  }

  @objc init?(contentsOfFile fName: String) {
    if let instance = NSCharacterSet(contentsOfFile: fName) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @objc init(coder: NSCoderWrapper) {
    wrappedInstance = NSCharacterSet(coder: coder.wrappedInstance)
  }

  @objc public func isSuperset(of theOtherSet: CharacterSetWrapper) -> Bool {
    return wrappedInstance.isSuperset(of: theOtherSet.wrappedInstance)
  }

}

@objc public class NSCoderWrapper: NSObject {
  var wrappedInstance: NSCoder

  @objc public var allowsKeyedCoding: Bool {
    get {
      wrappedInstance.allowsKeyedCoding
    }
  }

  @available(macOS, introduced: 10.8)
  @objc public var requiresSecureCoding: Bool {
    get {
      wrappedInstance.requiresSecureCoding
    }
  }

  init(_ wrappedInstance: NSCoder) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func containsValue(forKey key: String) -> Bool {
    return wrappedInstance.containsValue(forKey: key)
  }

  @objc public func decodeBool(forKey key: String) -> Bool {
    return wrappedInstance.decodeBool(forKey: key)
  }

  @objc public func decodeData() -> DataWrapper? {
    let result = wrappedInstance.decodeData()
    return result == nil ? nil : DataWrapper(result!)
  }

  @objc public func decodeDouble(forKey key: String) -> Double {
    return wrappedInstance.decodeDouble(forKey: key)
  }

  @objc public func decodeFloat(forKey key: String) -> Float {
    return wrappedInstance.decodeFloat(forKey: key)
  }

  @available(macOS, introduced: 10.5)
  @objc public func decodeInteger(forKey key: String) -> Int {
    return wrappedInstance.decodeInteger(forKey: key)
  }

  @objc public func encode(_ value: Bool, forKey key: String) {
    return wrappedInstance.encode(value, forKey: key)
  }

  @objc public func encode(_ data: DataWrapper) {
    return wrappedInstance.encode(data.wrappedInstance)
  }

  @objc public func version(forClassName className: String) -> Int {
    return wrappedInstance.version(forClassName: className)
  }

}

@objc public class NSDataWrapper: NSObject {
  var wrappedInstance: NSData

  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  @objc public var length: Int {
    get {
      wrappedInstance.length
    }
  }

  @objc public var underestimatedCount: Int {
    get {
      wrappedInstance.underestimatedCount
    }
  }

  @objc public var count: Int {
    get {
      wrappedInstance.count
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var startIndex: Int {
    get {
      wrappedInstance.startIndex
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var endIndex: Int {
    get {
      wrappedInstance.endIndex
    }
  }

  init(_ wrappedInstance: NSData) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init?(contentsOfFile path: String) {
    if let instance = NSData(contentsOfFile: path) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @available(macOS, introduced: 10.0, deprecated: 10.10)
  @objc init?(contentsOfMappedFile path: String) {
    if let instance = NSData(contentsOfMappedFile: path) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @objc init(data: DataWrapper) {
    wrappedInstance = NSData(data: data.wrappedInstance)
  }

  @objc init?(coder: NSCoderWrapper) {
    if let instance = NSData(coder: coder.wrappedInstance) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @objc public func isEqual(to other: DataWrapper) -> Bool {
    return wrappedInstance.isEqual(to: other.wrappedInstance)
  }

  @objc public func write(toFile path: String, atomically useAuxiliaryFile: Bool) -> Bool {
    return wrappedInstance.write(toFile: path, atomically: useAuxiliaryFile)
  }

  @objc public func write(to url: URLWrapper, atomically: Bool) -> Bool {
    return wrappedInstance.write(to: url.wrappedInstance, atomically: atomically)
  }

  @available(macOS, introduced: 10.9)
  @objc public class Base64DecodingOptionsWrapper: NSObject {
    var wrappedInstance: NSData.Base64DecodingOptions

    @available(macOS, introduced: 10.9)
    @objc static public var ignoreUnknownCharacters: NSDataWrapper.Base64DecodingOptionsWrapper {
      get {
        Base64DecodingOptionsWrapper(NSData.Base64DecodingOptions.ignoreUnknownCharacters)
      }
    }

    @objc public var isEmpty: Bool {
      get {
        wrappedInstance.isEmpty
      }
    }

    init(_ wrappedInstance: NSData.Base64DecodingOptions) {
      self.wrappedInstance = wrappedInstance
    }

    @objc override init() {
      wrappedInstance = NSData.Base64DecodingOptions()
    }

  }

  @available(macOS, introduced: 10.9)
  @objc public class Base64EncodingOptionsWrapper: NSObject {
    var wrappedInstance: NSData.Base64EncodingOptions

    @available(macOS, introduced: 10.9)
    @objc static public var lineLength64Characters: NSDataWrapper.Base64EncodingOptionsWrapper {
      get {
        Base64EncodingOptionsWrapper(NSData.Base64EncodingOptions.lineLength64Characters)
      }
    }

    @available(macOS, introduced: 10.9)
    @objc static public var lineLength76Characters: NSDataWrapper.Base64EncodingOptionsWrapper {
      get {
        Base64EncodingOptionsWrapper(NSData.Base64EncodingOptions.lineLength76Characters)
      }
    }

    @available(macOS, introduced: 10.9)
    @objc static public var endLineWithCarriageReturn: NSDataWrapper.Base64EncodingOptionsWrapper {
      get {
        Base64EncodingOptionsWrapper(NSData.Base64EncodingOptions.endLineWithCarriageReturn)
      }
    }

    @available(macOS, introduced: 10.9)
    @objc static public var endLineWithLineFeed: NSDataWrapper.Base64EncodingOptionsWrapper {
      get {
        Base64EncodingOptionsWrapper(NSData.Base64EncodingOptions.endLineWithLineFeed)
      }
    }

    @objc public var isEmpty: Bool {
      get {
        wrappedInstance.isEmpty
      }
    }

    init(_ wrappedInstance: NSData.Base64EncodingOptions) {
      self.wrappedInstance = wrappedInstance
    }

    @objc override init() {
      wrappedInstance = NSData.Base64EncodingOptions()
    }

  }

  @objc public class ReadingOptionsWrapper: NSObject {
    var wrappedInstance: NSData.ReadingOptions

    @available(macOS, introduced: 10.0, deprecated: 100000)
    @objc static public var dataReadingMapped: NSDataWrapper.ReadingOptionsWrapper {
      get {
        ReadingOptionsWrapper(NSData.ReadingOptions.dataReadingMapped)
      }
    }

    @available(macOS, introduced: 10.7)
    @objc static public var alwaysMapped: NSDataWrapper.ReadingOptionsWrapper {
      get {
        ReadingOptionsWrapper(NSData.ReadingOptions.alwaysMapped)
      }
    }

    @objc static public var mappedIfSafe: NSDataWrapper.ReadingOptionsWrapper {
      get {
        ReadingOptionsWrapper(NSData.ReadingOptions.mappedIfSafe)
      }
    }

    @objc static public var uncached: NSDataWrapper.ReadingOptionsWrapper {
      get {
        ReadingOptionsWrapper(NSData.ReadingOptions.uncached)
      }
    }

    @available(macOS, introduced: 10.0, deprecated: 100000)
    @objc static public var mappedRead: NSDataWrapper.ReadingOptionsWrapper {
      get {
        ReadingOptionsWrapper(NSData.ReadingOptions.mappedRead)
      }
    }

    @available(macOS, introduced: 10.0, deprecated: 100000)
    @objc static public var uncachedRead: NSDataWrapper.ReadingOptionsWrapper {
      get {
        ReadingOptionsWrapper(NSData.ReadingOptions.uncachedRead)
      }
    }

    @objc public var isEmpty: Bool {
      get {
        wrappedInstance.isEmpty
      }
    }

    init(_ wrappedInstance: NSData.ReadingOptions) {
      self.wrappedInstance = wrappedInstance
    }

    @objc override init() {
      wrappedInstance = NSData.ReadingOptions()
    }

  }

  @available(macOS, introduced: 10.6)
  @objc public class SearchOptionsWrapper: NSObject {
    var wrappedInstance: NSData.SearchOptions

    @available(macOS, introduced: 10.6)
    @objc static public var anchored: NSDataWrapper.SearchOptionsWrapper {
      get {
        SearchOptionsWrapper(NSData.SearchOptions.anchored)
      }
    }

    @available(macOS, introduced: 10.6)
    @objc static public var backwards: NSDataWrapper.SearchOptionsWrapper {
      get {
        SearchOptionsWrapper(NSData.SearchOptions.backwards)
      }
    }

    @objc public var isEmpty: Bool {
      get {
        wrappedInstance.isEmpty
      }
    }

    init(_ wrappedInstance: NSData.SearchOptions) {
      self.wrappedInstance = wrappedInstance
    }

    @objc override init() {
      wrappedInstance = NSData.SearchOptions()
    }

  }

  @objc public class WritingOptionsWrapper: NSObject {
    var wrappedInstance: NSData.WritingOptions

    @available(macOS, introduced: 10.0, deprecated: 100000)
    @objc static public var atomicWrite: NSDataWrapper.WritingOptionsWrapper {
      get {
        WritingOptionsWrapper(NSData.WritingOptions.atomicWrite)
      }
    }

    @objc static public var atomic: NSDataWrapper.WritingOptionsWrapper {
      get {
        WritingOptionsWrapper(NSData.WritingOptions.atomic)
      }
    }

    @available(macOS, introduced: 11.0)
    @objc static public var completeFileProtection: NSDataWrapper.WritingOptionsWrapper {
      get {
        WritingOptionsWrapper(NSData.WritingOptions.completeFileProtection)
      }
    }

    @available(macOS, introduced: 11.0)
    @objc static public var completeFileProtectionUnlessOpen: NSDataWrapper.WritingOptionsWrapper {
      get {
        WritingOptionsWrapper(NSData.WritingOptions.completeFileProtectionUnlessOpen)
      }
    }

    @available(macOS, introduced: 11.0)
    @objc static public var completeFileProtectionUntilFirstUserAuthentication: NSDataWrapper.WritingOptionsWrapper {
      get {
        WritingOptionsWrapper(NSData.WritingOptions.completeFileProtectionUntilFirstUserAuthentication)
      }
    }

    @available(macOS, introduced: 11.0)
    @objc static public var fileProtectionMask: NSDataWrapper.WritingOptionsWrapper {
      get {
        WritingOptionsWrapper(NSData.WritingOptions.fileProtectionMask)
      }
    }

    @available(macOS, introduced: 11.0)
    @objc static public var noFileProtection: NSDataWrapper.WritingOptionsWrapper {
      get {
        WritingOptionsWrapper(NSData.WritingOptions.noFileProtection)
      }
    }

    @available(macOS, introduced: 10.8)
    @objc static public var withoutOverwriting: NSDataWrapper.WritingOptionsWrapper {
      get {
        WritingOptionsWrapper(NSData.WritingOptions.withoutOverwriting)
      }
    }

    @objc public var isEmpty: Bool {
      get {
        wrappedInstance.isEmpty
      }
    }

    init(_ wrappedInstance: NSData.WritingOptions) {
      self.wrappedInstance = wrappedInstance
    }

    @objc override init() {
      wrappedInstance = NSData.WritingOptions()
    }

  }

}

@objc public class NSDateWrapper: NSObject {
  var wrappedInstance: NSDate

  @objc static public var distantFuture: DateWrapper {
    get {
      DateWrapper(NSDate.distantFuture)
    }
  }

  @objc static public var distantPast: DateWrapper {
    get {
      DateWrapper(NSDate.distantPast)
    }
  }

  @available(macOS, introduced: 10.15)
  @objc static public var now: DateWrapper {
    get {
      DateWrapper(NSDate.now)
    }
  }

  @objc static public var timeIntervalSinceReferenceDate: TimeInterval {
    get {
      NSDate.timeIntervalSinceReferenceDate
    }
  }

  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  @objc public var timeIntervalSince1970: TimeInterval {
    get {
      wrappedInstance.timeIntervalSince1970
    }
  }

  @objc public var timeIntervalSinceNow: TimeInterval {
    get {
      wrappedInstance.timeIntervalSinceNow
    }
  }

  @objc public var timeIntervalSinceReferenceDate: TimeInterval {
    get {
      wrappedInstance.timeIntervalSinceReferenceDate
    }
  }

  init(_ wrappedInstance: NSDate) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = NSDate()
  }

  @objc init?(coder: NSCoderWrapper) {
    if let instance = NSDate(coder: coder.wrappedInstance) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @objc init(timeIntervalSinceReferenceDate ti: TimeInterval) {
    wrappedInstance = NSDate(timeIntervalSinceReferenceDate: ti)
  }

  @objc public func earlierDate(_ anotherDate: DateWrapper) -> DateWrapper {
    let result = wrappedInstance.earlierDate(anotherDate.wrappedInstance)
    return DateWrapper(result)
  }

  @objc public func isEqual(to otherDate: DateWrapper) -> Bool {
    return wrappedInstance.isEqual(to: otherDate.wrappedInstance)
  }

  @objc public func laterDate(_ anotherDate: DateWrapper) -> DateWrapper {
    let result = wrappedInstance.laterDate(anotherDate.wrappedInstance)
    return DateWrapper(result)
  }

  @objc public func timeIntervalSince(_ anotherDate: DateWrapper) -> TimeInterval {
    return wrappedInstance.timeIntervalSince(anotherDate.wrappedInstance)
  }

}

@objc public class NSDateComponentsWrapper: NSObject {
  var wrappedInstance: NSDateComponents

  @available(macOS, introduced: 10.7)
  @objc public var calendar: CalendarWrapper? {
    get {
      wrappedInstance.calendar == nil ? nil : CalendarWrapper(wrappedInstance.calendar!)
    }
    set {
      wrappedInstance.calendar = newValue?.wrappedInstance
    }
  }

  @available(macOS, introduced: 10.7)
  @objc public var date: DateWrapper? {
    get {
      wrappedInstance.date == nil ? nil : DateWrapper(wrappedInstance.date!)
    }
  }

  @objc public var day: Int {
    get {
      wrappedInstance.day
    }
    set {
      wrappedInstance.day = newValue
    }
  }

  @available(macOS, introduced: 15.0)
  @objc public var dayOfYear: Int {
    get {
      wrappedInstance.dayOfYear
    }
    set {
      wrappedInstance.dayOfYear = newValue
    }
  }

  @objc public var era: Int {
    get {
      wrappedInstance.era
    }
    set {
      wrappedInstance.era = newValue
    }
  }

  @objc public var hour: Int {
    get {
      wrappedInstance.hour
    }
    set {
      wrappedInstance.hour = newValue
    }
  }

  @available(macOS, introduced: 10.8)
  @objc public var isLeapMonth: Bool {
    get {
      wrappedInstance.isLeapMonth
    }
    set {
      wrappedInstance.isLeapMonth = newValue
    }
  }

  @objc public var minute: Int {
    get {
      wrappedInstance.minute
    }
    set {
      wrappedInstance.minute = newValue
    }
  }

  @objc public var month: Int {
    get {
      wrappedInstance.month
    }
    set {
      wrappedInstance.month = newValue
    }
  }

  @available(macOS, introduced: 10.7)
  @objc public var nanosecond: Int {
    get {
      wrappedInstance.nanosecond
    }
    set {
      wrappedInstance.nanosecond = newValue
    }
  }

  @available(macOS, introduced: 10.6)
  @objc public var quarter: Int {
    get {
      wrappedInstance.quarter
    }
    set {
      wrappedInstance.quarter = newValue
    }
  }

  @objc public var second: Int {
    get {
      wrappedInstance.second
    }
    set {
      wrappedInstance.second = newValue
    }
  }

  @available(macOS, introduced: 10.7)
  @objc public var timeZone: TimeZoneWrapper? {
    get {
      wrappedInstance.timeZone == nil ? nil : TimeZoneWrapper(wrappedInstance.timeZone!)
    }
    set {
      wrappedInstance.timeZone = newValue?.wrappedInstance
    }
  }

  @available(macOS, introduced: 10.9)
  @objc public var isValidDate: Bool {
    get {
      wrappedInstance.isValidDate
    }
  }

  @available(macOS, introduced: 10.7)
  @objc public var weekOfMonth: Int {
    get {
      wrappedInstance.weekOfMonth
    }
    set {
      wrappedInstance.weekOfMonth = newValue
    }
  }

  @available(macOS, introduced: 10.7)
  @objc public var weekOfYear: Int {
    get {
      wrappedInstance.weekOfYear
    }
    set {
      wrappedInstance.weekOfYear = newValue
    }
  }

  @objc public var weekday: Int {
    get {
      wrappedInstance.weekday
    }
    set {
      wrappedInstance.weekday = newValue
    }
  }

  @objc public var weekdayOrdinal: Int {
    get {
      wrappedInstance.weekdayOrdinal
    }
    set {
      wrappedInstance.weekdayOrdinal = newValue
    }
  }

  @objc public var year: Int {
    get {
      wrappedInstance.year
    }
    set {
      wrappedInstance.year = newValue
    }
  }

  @available(macOS, introduced: 10.7)
  @objc public var yearForWeekOfYear: Int {
    get {
      wrappedInstance.yearForWeekOfYear
    }
    set {
      wrappedInstance.yearForWeekOfYear = newValue
    }
  }

  init(_ wrappedInstance: NSDateComponents) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init?(coder: NSCoderWrapper) {
    if let instance = NSDateComponents(coder: coder.wrappedInstance) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @available(macOS, introduced: 10.9)
  @objc public func isValidDate(in calendar: CalendarWrapper) -> Bool {
    return wrappedInstance.isValidDate(in: calendar.wrappedInstance)
  }

  @available(macOS, introduced: 10.9)
  @objc public func setValue(_ value: Int, forComponent unit: NSCalendarWrapper.UnitWrapper) {
    return wrappedInstance.setValue(value, forComponent: unit.wrappedInstance)
  }

  @available(macOS, introduced: 10.9)
  @objc public func value(forComponent unit: NSCalendarWrapper.UnitWrapper) -> Int {
    return wrappedInstance.value(forComponent: unit.wrappedInstance)
  }

}

@available(macOS, introduced: 10.12)
@objc public class NSDateIntervalWrapper: NSObject {
  var wrappedInstance: NSDateInterval

  @available(macOS, introduced: 10.12)
  @objc public var duration: TimeInterval {
    get {
      wrappedInstance.duration
    }
  }

  @available(macOS, introduced: 10.12)
  @objc public var endDate: DateWrapper {
    get {
      DateWrapper(wrappedInstance.endDate)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc public var startDate: DateWrapper {
    get {
      DateWrapper(wrappedInstance.startDate)
    }
  }

  init(_ wrappedInstance: NSDateInterval) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.12)
  @objc init(coder: NSCoderWrapper) {
    wrappedInstance = NSDateInterval(coder: coder.wrappedInstance)
  }

  @available(macOS, introduced: 10.12)
  @objc init(start startDate: DateWrapper, duration: TimeInterval) {
    wrappedInstance = NSDateInterval(start: startDate.wrappedInstance, duration: duration)
  }

  @available(macOS, introduced: 10.12)
  @objc public func contains(_ date: DateWrapper) -> Bool {
    return wrappedInstance.contains(date.wrappedInstance)
  }

  @available(macOS, introduced: 10.12)
  @objc public func intersection(with dateInterval: DateIntervalWrapper) -> DateIntervalWrapper? {
    let result = wrappedInstance.intersection(with: dateInterval.wrappedInstance)
    return result == nil ? nil : DateIntervalWrapper(result!)
  }

  @available(macOS, introduced: 10.12)
  @objc public func intersects(_ dateInterval: DateIntervalWrapper) -> Bool {
    return wrappedInstance.intersects(dateInterval.wrappedInstance)
  }

  @available(macOS, introduced: 10.12)
  @objc public func isEqual(to dateInterval: DateIntervalWrapper) -> Bool {
    return wrappedInstance.isEqual(to: dateInterval.wrappedInstance)
  }

}

@objc public class NSErrorWrapper: NSObject {
  var wrappedInstance: NSError

  @objc public var code: Int {
    get {
      wrappedInstance.code
    }
  }

  @objc public var domain: String {
    get {
      wrappedInstance.domain
    }
  }

  @objc public var helpAnchor: String? {
    get {
      wrappedInstance.helpAnchor
    }
  }

  @objc public var localizedDescription: String {
    get {
      wrappedInstance.localizedDescription
    }
  }

  @objc public var localizedFailureReason: String? {
    get {
      wrappedInstance.localizedFailureReason
    }
  }

  @objc public var localizedRecoverySuggestion: String? {
    get {
      wrappedInstance.localizedRecoverySuggestion
    }
  }

  init(_ wrappedInstance: NSError) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init?(coder: NSCoderWrapper) {
    if let instance = NSError(coder: coder.wrappedInstance) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

}

@available(macOS, introduced: 10.7)
@objc public class NSFileSecurityWrapper: NSObject {
  var wrappedInstance: NSFileSecurity

  init(_ wrappedInstance: NSFileSecurity) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.7)
  @objc init?(coder: NSCoderWrapper) {
    if let instance = NSFileSecurity(coder: coder.wrappedInstance) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

}

@objc public class NSLocaleWrapper: NSObject {
  var wrappedInstance: NSLocale

  @available(macOS, introduced: 10.5)
  @objc static public var currentLocaleDidChangeNotification: NSNotificationWrapper.NameWrapper {
    get {
      NameWrapper(NSLocale.currentLocaleDidChangeNotification)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var autoupdatingCurrent: LocaleWrapper {
    get {
      LocaleWrapper(NSLocale.autoupdatingCurrent)
    }
  }

  @objc static public var current: LocaleWrapper {
    get {
      LocaleWrapper(NSLocale.current)
    }
  }

  @objc static public var system: LocaleWrapper {
    get {
      LocaleWrapper(NSLocale.system)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc public var alternateQuotationBeginDelimiter: String {
    get {
      wrappedInstance.alternateQuotationBeginDelimiter
    }
  }

  @available(macOS, introduced: 10.12)
  @objc public var alternateQuotationEndDelimiter: String {
    get {
      wrappedInstance.alternateQuotationEndDelimiter
    }
  }

  @available(macOS, introduced: 10.12)
  @objc public var calendarIdentifier: String {
    get {
      wrappedInstance.calendarIdentifier
    }
  }

  @available(macOS, introduced: 10.12)
  @objc public var collationIdentifier: String? {
    get {
      wrappedInstance.collationIdentifier
    }
  }

  @available(macOS, introduced: 10.12)
  @objc public var collatorIdentifier: String {
    get {
      wrappedInstance.collatorIdentifier
    }
  }

  @available(macOS, introduced: 10.12, deprecated: 100000)
  @objc public var countryCode: String? {
    get {
      wrappedInstance.countryCode
    }
  }

  @available(macOS, introduced: 10.12)
  @objc public var currencyCode: String? {
    get {
      wrappedInstance.currencyCode
    }
  }

  @available(macOS, introduced: 10.12)
  @objc public var currencySymbol: String {
    get {
      wrappedInstance.currencySymbol
    }
  }

  @available(macOS, introduced: 10.12)
  @objc public var decimalSeparator: String {
    get {
      wrappedInstance.decimalSeparator
    }
  }

  @available(macOS, introduced: 10.12)
  @objc public var exemplarCharacterSet: CharacterSetWrapper {
    get {
      CharacterSetWrapper(wrappedInstance.exemplarCharacterSet)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc public var groupingSeparator: String {
    get {
      wrappedInstance.groupingSeparator
    }
  }

  @available(macOS, introduced: 10.12)
  @objc public var languageCode: String {
    get {
      wrappedInstance.languageCode
    }
  }

  @available(macOS, introduced: 14.0)
  @objc public var languageIdentifier: String {
    get {
      wrappedInstance.languageIdentifier
    }
  }

  @objc public var localeIdentifier: String {
    get {
      wrappedInstance.localeIdentifier
    }
  }

  @available(macOS, introduced: 10.12)
  @objc public var quotationBeginDelimiter: String {
    get {
      wrappedInstance.quotationBeginDelimiter
    }
  }

  @available(macOS, introduced: 10.12)
  @objc public var quotationEndDelimiter: String {
    get {
      wrappedInstance.quotationEndDelimiter
    }
  }

  @available(macOS, introduced: 14.0)
  @objc public var regionCode: String? {
    get {
      wrappedInstance.regionCode
    }
  }

  @available(macOS, introduced: 10.12)
  @objc public var scriptCode: String? {
    get {
      wrappedInstance.scriptCode
    }
  }

  @available(macOS, introduced: 10.12)
  @objc public var usesMetricSystem: Bool {
    get {
      wrappedInstance.usesMetricSystem
    }
  }

  @available(macOS, introduced: 10.12)
  @objc public var variantCode: String? {
    get {
      wrappedInstance.variantCode
    }
  }

  init(_ wrappedInstance: NSLocale) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init?(coder: NSCoderWrapper) {
    if let instance = NSLocale(coder: coder.wrappedInstance) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @objc init(localeIdentifier string: String) {
    wrappedInstance = NSLocale(localeIdentifier: string)
  }

  @objc static public func canonicalLanguageIdentifier(from string: String) -> String {
    return NSLocale.canonicalLanguageIdentifier(from: string)
  }

  @objc static public func canonicalLocaleIdentifier(from string: String) -> String {
    return NSLocale.canonicalLocaleIdentifier(from: string)
  }

  @available(macOS, introduced: 10.12)
  @objc public func localizedString(forCalendarIdentifier calendarIdentifier: String) -> String? {
    return wrappedInstance.localizedString(forCalendarIdentifier: calendarIdentifier)
  }

  @available(macOS, introduced: 10.12)
  @objc public func localizedString(forCollationIdentifier collationIdentifier: String) -> String? {
    return wrappedInstance.localizedString(forCollationIdentifier: collationIdentifier)
  }

  @available(macOS, introduced: 10.12)
  @objc public func localizedString(forCollatorIdentifier collatorIdentifier: String) -> String? {
    return wrappedInstance.localizedString(forCollatorIdentifier: collatorIdentifier)
  }

  @available(macOS, introduced: 10.12)
  @objc public func localizedString(forCountryCode countryCode: String) -> String? {
    return wrappedInstance.localizedString(forCountryCode: countryCode)
  }

  @available(macOS, introduced: 10.12)
  @objc public func localizedString(forCurrencyCode currencyCode: String) -> String? {
    return wrappedInstance.localizedString(forCurrencyCode: currencyCode)
  }

  @available(macOS, introduced: 10.12)
  @objc public func localizedString(forLanguageCode languageCode: String) -> String? {
    return wrappedInstance.localizedString(forLanguageCode: languageCode)
  }

  @available(macOS, introduced: 10.12)
  @objc public func localizedString(forLocaleIdentifier localeIdentifier: String) -> String {
    return wrappedInstance.localizedString(forLocaleIdentifier: localeIdentifier)
  }

  @available(macOS, introduced: 10.12)
  @objc public func localizedString(forScriptCode scriptCode: String) -> String? {
    return wrappedInstance.localizedString(forScriptCode: scriptCode)
  }

  @available(macOS, introduced: 10.12)
  @objc public func localizedString(forVariantCode variantCode: String) -> String? {
    return wrappedInstance.localizedString(forVariantCode: variantCode)
  }

  @objc public class KeyWrapper: NSObject {
    var wrappedInstance: NSLocale.Key

    @available(macOS, introduced: 10.6)
    @objc static public var alternateQuotationBeginDelimiterKey: NSLocaleWrapper.KeyWrapper {
      get {
        KeyWrapper(NSLocale.Key.alternateQuotationBeginDelimiterKey)
      }
    }

    @available(macOS, introduced: 10.6)
    @objc static public var alternateQuotationEndDelimiterKey: NSLocaleWrapper.KeyWrapper {
      get {
        KeyWrapper(NSLocale.Key.alternateQuotationEndDelimiterKey)
      }
    }

    @objc static public var calendar: NSLocaleWrapper.KeyWrapper {
      get {
        KeyWrapper(NSLocale.Key.calendar)
      }
    }

    @objc static public var collationIdentifier: NSLocaleWrapper.KeyWrapper {
      get {
        KeyWrapper(NSLocale.Key.collationIdentifier)
      }
    }

    @available(macOS, introduced: 10.6)
    @objc static public var collatorIdentifier: NSLocaleWrapper.KeyWrapper {
      get {
        KeyWrapper(NSLocale.Key.collatorIdentifier)
      }
    }

    @objc static public var countryCode: NSLocaleWrapper.KeyWrapper {
      get {
        KeyWrapper(NSLocale.Key.countryCode)
      }
    }

    @objc static public var currencyCode: NSLocaleWrapper.KeyWrapper {
      get {
        KeyWrapper(NSLocale.Key.currencyCode)
      }
    }

    @objc static public var currencySymbol: NSLocaleWrapper.KeyWrapper {
      get {
        KeyWrapper(NSLocale.Key.currencySymbol)
      }
    }

    @objc static public var decimalSeparator: NSLocaleWrapper.KeyWrapper {
      get {
        KeyWrapper(NSLocale.Key.decimalSeparator)
      }
    }

    @objc static public var exemplarCharacterSet: NSLocaleWrapper.KeyWrapper {
      get {
        KeyWrapper(NSLocale.Key.exemplarCharacterSet)
      }
    }

    @objc static public var groupingSeparator: NSLocaleWrapper.KeyWrapper {
      get {
        KeyWrapper(NSLocale.Key.groupingSeparator)
      }
    }

    @objc static public var identifier: NSLocaleWrapper.KeyWrapper {
      get {
        KeyWrapper(NSLocale.Key.identifier)
      }
    }

    @objc static public var languageCode: NSLocaleWrapper.KeyWrapper {
      get {
        KeyWrapper(NSLocale.Key.languageCode)
      }
    }

    @objc static public var measurementSystem: NSLocaleWrapper.KeyWrapper {
      get {
        KeyWrapper(NSLocale.Key.measurementSystem)
      }
    }

    @available(macOS, introduced: 10.6)
    @objc static public var quotationBeginDelimiterKey: NSLocaleWrapper.KeyWrapper {
      get {
        KeyWrapper(NSLocale.Key.quotationBeginDelimiterKey)
      }
    }

    @available(macOS, introduced: 10.6)
    @objc static public var quotationEndDelimiterKey: NSLocaleWrapper.KeyWrapper {
      get {
        KeyWrapper(NSLocale.Key.quotationEndDelimiterKey)
      }
    }

    @objc static public var scriptCode: NSLocaleWrapper.KeyWrapper {
      get {
        KeyWrapper(NSLocale.Key.scriptCode)
      }
    }

    @objc static public var usesMetricSystem: NSLocaleWrapper.KeyWrapper {
      get {
        KeyWrapper(NSLocale.Key.usesMetricSystem)
      }
    }

    @objc static public var variantCode: NSLocaleWrapper.KeyWrapper {
      get {
        KeyWrapper(NSLocale.Key.variantCode)
      }
    }

    init(_ wrappedInstance: NSLocale.Key) {
      self.wrappedInstance = wrappedInstance
    }

    @objc init(rawValue: String) {
      wrappedInstance = NSLocale.Key(rawValue: rawValue)
    }

  }

}

@objc public class NSNotificationWrapper: NSObject {
  var wrappedInstance: NSNotification

  @objc public var name: NSNotificationWrapper.NameWrapper {
    get {
      NameWrapper(wrappedInstance.name)
    }
  }

  init(_ wrappedInstance: NSNotification) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init?(coder: NSCoderWrapper) {
    if let instance = NSNotification(coder: coder.wrappedInstance) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @objc public class NameWrapper: NSObject {
    var wrappedInstance: NSNotification.Name

    @objc static public var NSAppleEventManagerWillProcessFirstEvent: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSAppleEventManagerWillProcessFirstEvent)
      }
    }

    @available(macOS, introduced: 10.9)
    @objc static public var NSCalendarDayChanged: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSCalendarDayChanged)
      }
    }

    @objc static public var NSClassDescriptionNeededForClass: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSClassDescriptionNeededForClass)
      }
    }

    @objc static public var NSDidBecomeSingleThreaded: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSDidBecomeSingleThreaded)
      }
    }

    @objc static public var NSFileHandleConnectionAccepted: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSFileHandleConnectionAccepted)
      }
    }

    @objc static public var NSFileHandleDataAvailable: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSFileHandleDataAvailable)
      }
    }

    @objc static public var NSFileHandleReadToEndOfFileCompletion: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSFileHandleReadToEndOfFileCompletion)
      }
    }

    @available(macOS, introduced: 10.2)
    @objc static public var NSHTTPCookieManagerAcceptPolicyChanged: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSHTTPCookieManagerAcceptPolicyChanged)
      }
    }

    @available(macOS, introduced: 10.2)
    @objc static public var NSHTTPCookieManagerCookiesChanged: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSHTTPCookieManagerCookiesChanged)
      }
    }

    @available(macOS, introduced: 10.4)
    @objc static public var NSMetadataQueryDidFinishGathering: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSMetadataQueryDidFinishGathering)
      }
    }

    @available(macOS, introduced: 10.4)
    @objc static public var NSMetadataQueryDidStartGathering: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSMetadataQueryDidStartGathering)
      }
    }

    @available(macOS, introduced: 10.4)
    @objc static public var NSMetadataQueryDidUpdate: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSMetadataQueryDidUpdate)
      }
    }

    @available(macOS, introduced: 10.4)
    @objc static public var NSMetadataQueryGatheringProgress: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSMetadataQueryGatheringProgress)
      }
    }

    @available(macOS, introduced: 12.0)
    @objc static public var NSProcessInfoPowerStateDidChange: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSProcessInfoPowerStateDidChange)
      }
    }

    @available(macOS, introduced: 10.6)
    @objc static public var NSSystemClockDidChange: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSSystemClockDidChange)
      }
    }

    @available(macOS, introduced: 10.5)
    @objc static public var NSSystemTimeZoneDidChange: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSSystemTimeZoneDidChange)
      }
    }

    @objc static public var NSThreadWillExit: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSThreadWillExit)
      }
    }

    @available(macOS, introduced: 10.2)
    @objc static public var NSURLCredentialStorageChanged: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSURLCredentialStorageChanged)
      }
    }

    @available(macOS, introduced: 10.8)
    @objc static public var NSUbiquityIdentityDidChange: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSUbiquityIdentityDidChange)
      }
    }

    @available(macOS, introduced: 10.0)
    @objc static public var NSUndoManagerCheckpoint: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSUndoManagerCheckpoint)
      }
    }

    @available(macOS, introduced: 10.7)
    @objc static public var NSUndoManagerDidCloseUndoGroup: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSUndoManagerDidCloseUndoGroup)
      }
    }

    @available(macOS, introduced: 10.0)
    @objc static public var NSUndoManagerDidOpenUndoGroup: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSUndoManagerDidOpenUndoGroup)
      }
    }

    @available(macOS, introduced: 10.0)
    @objc static public var NSUndoManagerDidRedoChange: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSUndoManagerDidRedoChange)
      }
    }

    @available(macOS, introduced: 10.0)
    @objc static public var NSUndoManagerDidUndoChange: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSUndoManagerDidUndoChange)
      }
    }

    @available(macOS, introduced: 10.0)
    @objc static public var NSUndoManagerWillCloseUndoGroup: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSUndoManagerWillCloseUndoGroup)
      }
    }

    @available(macOS, introduced: 10.0)
    @objc static public var NSUndoManagerWillRedoChange: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSUndoManagerWillRedoChange)
      }
    }

    @available(macOS, introduced: 10.0)
    @objc static public var NSUndoManagerWillUndoChange: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSUndoManagerWillUndoChange)
      }
    }

    @objc static public var NSWillBecomeMultiThreaded: NSNotificationWrapper.NameWrapper {
      get {
        NameWrapper(NSNotification.Name.NSWillBecomeMultiThreaded)
      }
    }

    init(_ wrappedInstance: NSNotification.Name) {
      self.wrappedInstance = wrappedInstance
    }

    @objc init(rawValue: String) {
      wrappedInstance = NSNotification.Name(rawValue: rawValue)
    }

    @objc init(_ rawValue: String) {
      wrappedInstance = NSNotification.Name(rawValue)
    }

  }

}

@objc public class NSNumberWrapper: NSObject {
  var wrappedInstance: NSNumber

  @objc public var boolValue: Bool {
    get {
      wrappedInstance.boolValue
    }
  }

  @objc public var decimalValue: DecimalWrapper {
    get {
      DecimalWrapper(wrappedInstance.decimalValue)
    }
  }

  @objc public var doubleValue: Double {
    get {
      wrappedInstance.doubleValue
    }
  }

  @objc public var floatValue: Float {
    get {
      wrappedInstance.floatValue
    }
  }

  @available(macOS, introduced: 10.5)
  @objc public var intValue: Int {
    get {
      wrappedInstance.intValue
    }
  }

  @objc public var stringValue: String {
    get {
      wrappedInstance.stringValue
    }
  }

  init(_ wrappedInstance: NSNumber) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(value: Bool) {
    wrappedInstance = NSNumber(value: value)
  }

  @objc init?(coder: NSCoderWrapper) {
    if let instance = NSNumber(coder: coder.wrappedInstance) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @objc public func isEqual(to number: NSNumberWrapper) -> Bool {
    return wrappedInstance.isEqual(to: number.wrappedInstance)
  }

}

@available(macOS, introduced: 10.11)
@objc public class NSPersonNameComponentsWrapper: NSObject {
  var wrappedInstance: NSPersonNameComponents

  @available(macOS, introduced: 10.11)
  @objc public var familyName: String? {
    get {
      wrappedInstance.familyName
    }
    set {
      wrappedInstance.familyName = newValue
    }
  }

  @available(macOS, introduced: 10.11)
  @objc public var givenName: String? {
    get {
      wrappedInstance.givenName
    }
    set {
      wrappedInstance.givenName = newValue
    }
  }

  @available(macOS, introduced: 10.11)
  @objc public var middleName: String? {
    get {
      wrappedInstance.middleName
    }
    set {
      wrappedInstance.middleName = newValue
    }
  }

  @available(macOS, introduced: 10.11)
  @objc public var namePrefix: String? {
    get {
      wrappedInstance.namePrefix
    }
    set {
      wrappedInstance.namePrefix = newValue
    }
  }

  @available(macOS, introduced: 10.11)
  @objc public var nameSuffix: String? {
    get {
      wrappedInstance.nameSuffix
    }
    set {
      wrappedInstance.nameSuffix = newValue
    }
  }

  @available(macOS, introduced: 10.11)
  @objc public var nickname: String? {
    get {
      wrappedInstance.nickname
    }
    set {
      wrappedInstance.nickname = newValue
    }
  }

  @available(macOS, introduced: 10.11)
  @objc public var phoneticRepresentation: PersonNameComponentsWrapper? {
    get {
      wrappedInstance.phoneticRepresentation == nil ? nil : PersonNameComponentsWrapper(wrappedInstance.phoneticRepresentation!)
    }
    set {
      wrappedInstance.phoneticRepresentation = newValue?.wrappedInstance
    }
  }

  init(_ wrappedInstance: NSPersonNameComponents) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.11)
  @objc init?(coder: NSCoderWrapper) {
    if let instance = NSPersonNameComponents(coder: coder.wrappedInstance) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

}

@objc public class NSStringWrapper: NSObject {
  var wrappedInstance: NSString

  @objc public var isAbsolutePath: Bool {
    get {
      wrappedInstance.isAbsolutePath
    }
  }

  @available(macOS, introduced: 10.5)
  @objc public var boolValue: Bool {
    get {
      wrappedInstance.boolValue
    }
  }

  @objc public var capitalized: String {
    get {
      wrappedInstance.capitalized
    }
  }

  @objc public var decomposedStringWithCanonicalMapping: String {
    get {
      wrappedInstance.decomposedStringWithCanonicalMapping
    }
  }

  @objc public var decomposedStringWithCompatibilityMapping: String {
    get {
      wrappedInstance.decomposedStringWithCompatibilityMapping
    }
  }

  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  @objc public var doubleValue: Double {
    get {
      wrappedInstance.doubleValue
    }
  }

  @objc public var floatValue: Float {
    get {
      wrappedInstance.floatValue
    }
  }

  @objc public var hash: Int {
    get {
      wrappedInstance.hash
    }
  }

  @available(macOS, introduced: 10.5)
  @objc public var integerValue: Int {
    get {
      wrappedInstance.integerValue
    }
  }

  @objc public var lastPathComponent: String {
    get {
      wrappedInstance.lastPathComponent
    }
  }

  @objc public var length: Int {
    get {
      wrappedInstance.length
    }
  }

  @available(macOS, introduced: 10.11)
  @objc public var localizedCapitalized: String {
    get {
      wrappedInstance.localizedCapitalized
    }
  }

  @available(macOS, introduced: 10.11)
  @objc public var localizedLowercase: String {
    get {
      wrappedInstance.localizedLowercase
    }
  }

  @available(macOS, introduced: 10.11)
  @objc public var localizedUppercase: String {
    get {
      wrappedInstance.localizedUppercase
    }
  }

  @objc public var lowercased: String {
    get {
      wrappedInstance.lowercased
    }
  }

  @objc public var pathExtension: String {
    get {
      wrappedInstance.pathExtension
    }
  }

  @objc public var precomposedStringWithCanonicalMapping: String {
    get {
      wrappedInstance.precomposedStringWithCanonicalMapping
    }
  }

  @objc public var precomposedStringWithCompatibilityMapping: String {
    get {
      wrappedInstance.precomposedStringWithCompatibilityMapping
    }
  }

  @objc public var abbreviatingWithTildeInPath: String {
    get {
      wrappedInstance.abbreviatingWithTildeInPath
    }
  }

  @objc public var deletingLastPathComponent: String {
    get {
      wrappedInstance.deletingLastPathComponent
    }
  }

  @objc public var deletingPathExtension: String {
    get {
      wrappedInstance.deletingPathExtension
    }
  }

  @objc public var expandingTildeInPath: String {
    get {
      wrappedInstance.expandingTildeInPath
    }
  }

  @available(macOS, introduced: 10.9)
  @objc public var removingPercentEncoding: String? {
    get {
      wrappedInstance.removingPercentEncoding
    }
  }

  @objc public var resolvingSymlinksInPath: String {
    get {
      wrappedInstance.resolvingSymlinksInPath
    }
  }

  @objc public var standardizingPath: String {
    get {
      wrappedInstance.standardizingPath
    }
  }

  @objc public var uppercased: String {
    get {
      wrappedInstance.uppercased
    }
  }

  init(_ wrappedInstance: NSString) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = NSString()
  }

  @objc init?(coder: NSCoderWrapper) {
    if let instance = NSString(coder: coder.wrappedInstance) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @available(macOS, introduced: 10.8)
  @objc public func capitalized(with locale: LocaleWrapper?) -> String {
    return wrappedInstance.capitalized(with: locale?.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @objc public func contains(_ str: String) -> Bool {
    return wrappedInstance.contains(str)
  }

  @objc public func hasPrefix(_ str: String) -> Bool {
    return wrappedInstance.hasPrefix(str)
  }

  @objc public func hasSuffix(_ str: String) -> Bool {
    return wrappedInstance.hasSuffix(str)
  }

  @objc public func isEqual(to aString: String) -> Bool {
    return wrappedInstance.isEqual(to: aString)
  }

  @available(macOS, introduced: 10.10)
  @objc public func localizedCaseInsensitiveContains(_ str: String) -> Bool {
    return wrappedInstance.localizedCaseInsensitiveContains(str)
  }

  @available(macOS, introduced: 10.11)
  @objc public func localizedStandardContains(_ str: String) -> Bool {
    return wrappedInstance.localizedStandardContains(str)
  }

  @available(macOS, introduced: 10.8)
  @objc public func lowercased(with locale: LocaleWrapper?) -> String {
    return wrappedInstance.lowercased(with: locale?.wrappedInstance)
  }

  @available(macOS, introduced: 10.9)
  @objc public func addingPercentEncoding(withAllowedCharacters allowedCharacters: CharacterSetWrapper) -> String? {
    return wrappedInstance.addingPercentEncoding(withAllowedCharacters: allowedCharacters.wrappedInstance)
  }

  @objc public func appendingPathComponent(_ str: String) -> String {
    return wrappedInstance.appendingPathComponent(str)
  }

  @objc public func appendingPathExtension(_ str: String) -> String? {
    return wrappedInstance.appendingPathExtension(str)
  }

  @objc public func appending(_ aString: String) -> String {
    return wrappedInstance.appending(aString)
  }

  @available(macOS, introduced: 10.11)
  @objc public func applyingTransform(_ transform: StringTransformWrapper, reverse: Bool) -> String? {
    return wrappedInstance.applyingTransform(transform.wrappedInstance, reverse: reverse)
  }

  @objc public func padding(toLength newLength: Int, withPad padString: String, startingAt padIndex: Int) -> String {
    return wrappedInstance.padding(toLength: newLength, withPad: padString, startingAt: padIndex)
  }

  @available(macOS, introduced: 10.5)
  @objc public func replacingOccurrences(of target: String, with replacement: String) -> String {
    return wrappedInstance.replacingOccurrences(of: target, with: replacement)
  }

  @objc public func trimmingCharacters(in set: CharacterSetWrapper) -> String {
    return wrappedInstance.trimmingCharacters(in: set.wrappedInstance)
  }

  @objc public func substring(from: Int) -> String {
    return wrappedInstance.substring(from: from)
  }

  @objc public func substring(to: Int) -> String {
    return wrappedInstance.substring(to: to)
  }

  @available(macOS, introduced: 10.8)
  @objc public func uppercased(with locale: LocaleWrapper?) -> String {
    return wrappedInstance.uppercased(with: locale?.wrappedInstance)
  }

  @available(macOS, introduced: 10.11)
  @objc public func variantFittingPresentationWidth(_ width: Int) -> String {
    return wrappedInstance.variantFittingPresentationWidth(width)
  }

  @objc public class CompareOptionsWrapper: NSObject {
    var wrappedInstance: NSString.CompareOptions

    @objc static public var anchored: NSStringWrapper.CompareOptionsWrapper {
      get {
        CompareOptionsWrapper(NSString.CompareOptions.anchored)
      }
    }

    @objc static public var backwards: NSStringWrapper.CompareOptionsWrapper {
      get {
        CompareOptionsWrapper(NSString.CompareOptions.backwards)
      }
    }

    @objc static public var caseInsensitive: NSStringWrapper.CompareOptionsWrapper {
      get {
        CompareOptionsWrapper(NSString.CompareOptions.caseInsensitive)
      }
    }

    @available(macOS, introduced: 10.5)
    @objc static public var diacriticInsensitive: NSStringWrapper.CompareOptionsWrapper {
      get {
        CompareOptionsWrapper(NSString.CompareOptions.diacriticInsensitive)
      }
    }

    @available(macOS, introduced: 10.5)
    @objc static public var forcedOrdering: NSStringWrapper.CompareOptionsWrapper {
      get {
        CompareOptionsWrapper(NSString.CompareOptions.forcedOrdering)
      }
    }

    @objc static public var literal: NSStringWrapper.CompareOptionsWrapper {
      get {
        CompareOptionsWrapper(NSString.CompareOptions.literal)
      }
    }

    @objc static public var numeric: NSStringWrapper.CompareOptionsWrapper {
      get {
        CompareOptionsWrapper(NSString.CompareOptions.numeric)
      }
    }

    @available(macOS, introduced: 10.7)
    @objc static public var regularExpression: NSStringWrapper.CompareOptionsWrapper {
      get {
        CompareOptionsWrapper(NSString.CompareOptions.regularExpression)
      }
    }

    @available(macOS, introduced: 10.5)
    @objc static public var widthInsensitive: NSStringWrapper.CompareOptionsWrapper {
      get {
        CompareOptionsWrapper(NSString.CompareOptions.widthInsensitive)
      }
    }

    @objc public var isEmpty: Bool {
      get {
        wrappedInstance.isEmpty
      }
    }

    init(_ wrappedInstance: NSString.CompareOptions) {
      self.wrappedInstance = wrappedInstance
    }

    @objc override init() {
      wrappedInstance = NSString.CompareOptions()
    }

  }

  @objc public class EncodingConversionOptionsWrapper: NSObject {
    var wrappedInstance: NSString.EncodingConversionOptions

    @objc static public var allowLossy: NSStringWrapper.EncodingConversionOptionsWrapper {
      get {
        EncodingConversionOptionsWrapper(NSString.EncodingConversionOptions.allowLossy)
      }
    }

    @objc static public var externalRepresentation: NSStringWrapper.EncodingConversionOptionsWrapper {
      get {
        EncodingConversionOptionsWrapper(NSString.EncodingConversionOptions.externalRepresentation)
      }
    }

    @objc public var isEmpty: Bool {
      get {
        wrappedInstance.isEmpty
      }
    }

    init(_ wrappedInstance: NSString.EncodingConversionOptions) {
      self.wrappedInstance = wrappedInstance
    }

    @objc override init() {
      wrappedInstance = NSString.EncodingConversionOptions()
    }

  }

  @objc public class EnumerationOptionsWrapper: NSObject {
    var wrappedInstance: NSString.EnumerationOptions

    @available(macOS, introduced: 11.0)
    @objc static public var byCaretPositions: NSStringWrapper.EnumerationOptionsWrapper {
      get {
        EnumerationOptionsWrapper(NSString.EnumerationOptions.byCaretPositions)
      }
    }

    @objc static public var byComposedCharacterSequences: NSStringWrapper.EnumerationOptionsWrapper {
      get {
        EnumerationOptionsWrapper(NSString.EnumerationOptions.byComposedCharacterSequences)
      }
    }

    @available(macOS, introduced: 11.0)
    @objc static public var byDeletionClusters: NSStringWrapper.EnumerationOptionsWrapper {
      get {
        EnumerationOptionsWrapper(NSString.EnumerationOptions.byDeletionClusters)
      }
    }

    @objc static public var byLines: NSStringWrapper.EnumerationOptionsWrapper {
      get {
        EnumerationOptionsWrapper(NSString.EnumerationOptions.byLines)
      }
    }

    @objc static public var byParagraphs: NSStringWrapper.EnumerationOptionsWrapper {
      get {
        EnumerationOptionsWrapper(NSString.EnumerationOptions.byParagraphs)
      }
    }

    @objc static public var bySentences: NSStringWrapper.EnumerationOptionsWrapper {
      get {
        EnumerationOptionsWrapper(NSString.EnumerationOptions.bySentences)
      }
    }

    @objc static public var byWords: NSStringWrapper.EnumerationOptionsWrapper {
      get {
        EnumerationOptionsWrapper(NSString.EnumerationOptions.byWords)
      }
    }

    @objc static public var localized: NSStringWrapper.EnumerationOptionsWrapper {
      get {
        EnumerationOptionsWrapper(NSString.EnumerationOptions.localized)
      }
    }

    @objc static public var reverse: NSStringWrapper.EnumerationOptionsWrapper {
      get {
        EnumerationOptionsWrapper(NSString.EnumerationOptions.reverse)
      }
    }

    @objc static public var substringNotRequired: NSStringWrapper.EnumerationOptionsWrapper {
      get {
        EnumerationOptionsWrapper(NSString.EnumerationOptions.substringNotRequired)
      }
    }

    @objc public var isEmpty: Bool {
      get {
        wrappedInstance.isEmpty
      }
    }

    init(_ wrappedInstance: NSString.EnumerationOptions) {
      self.wrappedInstance = wrappedInstance
    }

    @objc override init() {
      wrappedInstance = NSString.EnumerationOptions()
    }

  }

}

@objc public class NSTimeZoneWrapper: NSObject {
  var wrappedInstance: NSTimeZone

  @available(macOS, introduced: 10.6)
  @objc static public var abbreviationDictionary: String {
    get {
      NSTimeZone.abbreviationDictionary
    }
    set {
      NSTimeZone.abbreviationDictionary = newValue
    }
  }

  @objc static public var `default`: TimeZoneWrapper {
    get {
      TimeZoneWrapper(NSTimeZone.`default`)
    }
    set {
      NSTimeZone.`default` = newValue.wrappedInstance
    }
  }

  @objc static public var local: TimeZoneWrapper {
    get {
      TimeZoneWrapper(NSTimeZone.local)
    }
  }

  @objc static public var system: TimeZoneWrapper {
    get {
      TimeZoneWrapper(NSTimeZone.system)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var timeZoneDataVersion: String {
    get {
      NSTimeZone.timeZoneDataVersion
    }
  }

  @objc public var abbreviation: String? {
    get {
      wrappedInstance.abbreviation
    }
  }

  @objc public var data: DataWrapper {
    get {
      DataWrapper(wrappedInstance.data)
    }
  }

  @objc public var isDaylightSavingTime: Bool {
    get {
      wrappedInstance.isDaylightSavingTime
    }
  }

  @available(macOS, introduced: 10.5)
  @objc public var daylightSavingTimeOffset: TimeInterval {
    get {
      wrappedInstance.daylightSavingTimeOffset
    }
  }

  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  @objc public var name: String {
    get {
      wrappedInstance.name
    }
  }

  @available(macOS, introduced: 10.5)
  @objc public var nextDaylightSavingTimeTransition: DateWrapper? {
    get {
      wrappedInstance.nextDaylightSavingTimeTransition == nil ? nil : DateWrapper(wrappedInstance.nextDaylightSavingTimeTransition!)
    }
  }

  @objc public var secondsFromGMT: Int {
    get {
      wrappedInstance.secondsFromGMT
    }
  }

  init(_ wrappedInstance: NSTimeZone) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init?(name tzName: String) {
    if let instance = NSTimeZone(name: tzName) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @objc init?(name tzName: String, data aData: DataWrapper?) {
    if let instance = NSTimeZone(name: tzName, data: aData?.wrappedInstance) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @objc init?(coder: NSCoderWrapper) {
    if let instance = NSTimeZone(coder: coder.wrappedInstance) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @objc static public func resetSystemTimeZone() {
    return NSTimeZone.resetSystemTimeZone()
  }

  @objc public func abbreviation(for aDate: DateWrapper) -> String? {
    return wrappedInstance.abbreviation(for: aDate.wrappedInstance)
  }

  @available(macOS, introduced: 10.5)
  @objc public func daylightSavingTimeOffset(for aDate: DateWrapper) -> TimeInterval {
    return wrappedInstance.daylightSavingTimeOffset(for: aDate.wrappedInstance)
  }

  @objc public func isDaylightSavingTime(for aDate: DateWrapper) -> Bool {
    return wrappedInstance.isDaylightSavingTime(for: aDate.wrappedInstance)
  }

  @objc public func isEqual(to aTimeZone: TimeZoneWrapper) -> Bool {
    return wrappedInstance.isEqual(to: aTimeZone.wrappedInstance)
  }

  @available(macOS, introduced: 10.5)
  @objc public func nextDaylightSavingTimeTransition(after aDate: DateWrapper) -> DateWrapper? {
    let result = wrappedInstance.nextDaylightSavingTimeTransition(after: aDate.wrappedInstance)
    return result == nil ? nil : DateWrapper(result!)
  }

  @objc public func secondsFromGMT(for aDate: DateWrapper) -> Int {
    return wrappedInstance.secondsFromGMT(for: aDate.wrappedInstance)
  }

}

// This wrapper is a stub. To generate the full wrapper, add NSURL
// to your config's include function.
@objc public class NSURLWrapper: NSObject {
  var wrappedInstance: NSURL

  init(_ wrappedInstance: NSURL) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.6)
  @objc public class BookmarkCreationOptionsWrapper: NSObject {
    var wrappedInstance: NSURL.BookmarkCreationOptions

    @available(macOS, introduced: 10.6)
    @objc static public var minimalBookmark: NSURLWrapper.BookmarkCreationOptionsWrapper {
      get {
        BookmarkCreationOptionsWrapper(NSURL.BookmarkCreationOptions.minimalBookmark)
      }
    }

    @available(macOS, introduced: 10.7)
    @objc static public var securityScopeAllowOnlyReadAccess: NSURLWrapper.BookmarkCreationOptionsWrapper {
      get {
        BookmarkCreationOptionsWrapper(NSURL.BookmarkCreationOptions.securityScopeAllowOnlyReadAccess)
      }
    }

    @available(macOS, introduced: 10.6)
    @objc static public var suitableForBookmarkFile: NSURLWrapper.BookmarkCreationOptionsWrapper {
      get {
        BookmarkCreationOptionsWrapper(NSURL.BookmarkCreationOptions.suitableForBookmarkFile)
      }
    }

    @available(macOS, introduced: 10.7)
    @objc static public var withSecurityScope: NSURLWrapper.BookmarkCreationOptionsWrapper {
      get {
        BookmarkCreationOptionsWrapper(NSURL.BookmarkCreationOptions.withSecurityScope)
      }
    }

    @available(macOS, introduced: 10.7)
    @objc static public var withoutImplicitSecurityScope: NSURLWrapper.BookmarkCreationOptionsWrapper {
      get {
        BookmarkCreationOptionsWrapper(NSURL.BookmarkCreationOptions.withoutImplicitSecurityScope)
      }
    }

    @objc public var isEmpty: Bool {
      get {
        wrappedInstance.isEmpty
      }
    }

    init(_ wrappedInstance: NSURL.BookmarkCreationOptions) {
      self.wrappedInstance = wrappedInstance
    }

    @objc override init() {
      wrappedInstance = NSURL.BookmarkCreationOptions()
    }

  }

  @available(macOS, introduced: 10.6)
  @objc public class BookmarkResolutionOptionsWrapper: NSObject {
    var wrappedInstance: NSURL.BookmarkResolutionOptions

    @available(macOS, introduced: 10.7)
    @objc static public var withSecurityScope: NSURLWrapper.BookmarkResolutionOptionsWrapper {
      get {
        BookmarkResolutionOptionsWrapper(NSURL.BookmarkResolutionOptions.withSecurityScope)
      }
    }

    @available(macOS, introduced: 11.2)
    @objc static public var withoutImplicitStartAccessing: NSURLWrapper.BookmarkResolutionOptionsWrapper {
      get {
        BookmarkResolutionOptionsWrapper(NSURL.BookmarkResolutionOptions.withoutImplicitStartAccessing)
      }
    }

    @available(macOS, introduced: 10.6)
    @objc static public var withoutMounting: NSURLWrapper.BookmarkResolutionOptionsWrapper {
      get {
        BookmarkResolutionOptionsWrapper(NSURL.BookmarkResolutionOptions.withoutMounting)
      }
    }

    @available(macOS, introduced: 10.6)
    @objc static public var withoutUI: NSURLWrapper.BookmarkResolutionOptionsWrapper {
      get {
        BookmarkResolutionOptionsWrapper(NSURL.BookmarkResolutionOptions.withoutUI)
      }
    }

    @objc public var isEmpty: Bool {
      get {
        wrappedInstance.isEmpty
      }
    }

    init(_ wrappedInstance: NSURL.BookmarkResolutionOptions) {
      self.wrappedInstance = wrappedInstance
    }

    @objc override init() {
      wrappedInstance = NSURL.BookmarkResolutionOptions()
    }

  }

}

@objc public class GlobalsWrapper: NSObject {
  @objc static public func urlFuncWrapper(url: NSURLWrapper) -> NSURLWrapper {
    let result = urlFunc(url: url.wrappedInstance)
    return NSURLWrapper(result)
  }

}

@available(macOS, introduced: 13)
@available(watchOS, introduced: 9)
@available(iOS, introduced: 16)
@available(tvOS, introduced: 16)
@objc public class URLResourceWrapper: NSObject {
  var wrappedInstance: URLResource

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public var subdirectory: String? {
    get {
      wrappedInstance.subdirectory
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public var name: String {
    get {
      wrappedInstance.name
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public var bundle: BundleWrapper {
    get {
      BundleWrapper(wrappedInstance.bundle)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public var locale: LocaleWrapper {
    get {
      LocaleWrapper(wrappedInstance.locale)
    }
    set {
      wrappedInstance.locale = newValue.wrappedInstance
    }
  }

  init(_ wrappedInstance: URLResource) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 10.10)
@available(watchOS, introduced: 2.0)
@available(iOS, introduced: 8.0)
@available(tvOS, introduced: 9.0)
@objc public class CharacterSetWrapper: NSObject {
  var wrappedInstance: CharacterSet

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var whitespaces: CharacterSetWrapper {
    get {
      CharacterSetWrapper(CharacterSet.whitespaces)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var alphanumerics: CharacterSetWrapper {
    get {
      CharacterSetWrapper(CharacterSet.alphanumerics)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var decimalDigits: CharacterSetWrapper {
    get {
      CharacterSetWrapper(CharacterSet.decimalDigits)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var decomposables: CharacterSetWrapper {
    get {
      CharacterSetWrapper(CharacterSet.decomposables)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var urlHostAllowed: CharacterSetWrapper {
    get {
      CharacterSetWrapper(CharacterSet.urlHostAllowed)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var urlPathAllowed: CharacterSetWrapper {
    get {
      CharacterSetWrapper(CharacterSet.urlPathAllowed)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var urlUserAllowed: CharacterSetWrapper {
    get {
      CharacterSetWrapper(CharacterSet.urlUserAllowed)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var urlQueryAllowed: CharacterSetWrapper {
    get {
      CharacterSetWrapper(CharacterSet.urlQueryAllowed)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var debugDescription: String {
    get {
      wrappedInstance.debugDescription
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var lowercaseLetters: CharacterSetWrapper {
    get {
      CharacterSetWrapper(CharacterSet.lowercaseLetters)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var uppercaseLetters: CharacterSetWrapper {
    get {
      CharacterSetWrapper(CharacterSet.uppercaseLetters)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var controlCharacters: CharacterSetWrapper {
    get {
      CharacterSetWrapper(CharacterSet.controlCharacters)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var illegalCharacters: CharacterSetWrapper {
    get {
      CharacterSetWrapper(CharacterSet.illegalCharacters)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var nonBaseCharacters: CharacterSetWrapper {
    get {
      CharacterSetWrapper(CharacterSet.nonBaseCharacters)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var capitalizedLetters: CharacterSetWrapper {
    get {
      CharacterSetWrapper(CharacterSet.capitalizedLetters)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var urlFragmentAllowed: CharacterSetWrapper {
    get {
      CharacterSetWrapper(CharacterSet.urlFragmentAllowed)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var urlPasswordAllowed: CharacterSetWrapper {
    get {
      CharacterSetWrapper(CharacterSet.urlPasswordAllowed)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var bitmapRepresentation: DataWrapper {
    get {
      DataWrapper(wrappedInstance.bitmapRepresentation)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var punctuationCharacters: CharacterSetWrapper {
    get {
      CharacterSetWrapper(CharacterSet.punctuationCharacters)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var whitespacesAndNewlines: CharacterSetWrapper {
    get {
      CharacterSetWrapper(CharacterSet.whitespacesAndNewlines)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var letters: CharacterSetWrapper {
    get {
      CharacterSetWrapper(CharacterSet.letters)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var symbols: CharacterSetWrapper {
    get {
      CharacterSetWrapper(CharacterSet.symbols)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var inverted: CharacterSetWrapper {
    get {
      CharacterSetWrapper(wrappedInstance.inverted)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var newlines: CharacterSetWrapper {
    get {
      CharacterSetWrapper(CharacterSet.newlines)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: CharacterSet) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc init(charactersIn string: String) {
    wrappedInstance = CharacterSet(charactersIn: string)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc init?(contentsOfFile file: String) {
    if let instance = CharacterSet(contentsOfFile: file) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc init(bitmapRepresentation data: DataWrapper) {
    wrappedInstance = CharacterSet(bitmapRepresentation: data.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc override init() {
    wrappedInstance = CharacterSet()
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func isSuperset(of other: CharacterSetWrapper) -> Bool {
    return wrappedInstance.isSuperset(of: other.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func subtracting(_ other: CharacterSetWrapper) -> CharacterSetWrapper {
    let result = wrappedInstance.subtracting(other.wrappedInstance)
    return CharacterSetWrapper(result)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func intersection(_ other: CharacterSetWrapper) -> CharacterSetWrapper {
    let result = wrappedInstance.intersection(other.wrappedInstance)
    return CharacterSetWrapper(result)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func formIntersection(_ other: CharacterSetWrapper) {
    return wrappedInstance.formIntersection(other.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func symmetricDifference(_ other: CharacterSetWrapper) -> CharacterSetWrapper {
    let result = wrappedInstance.symmetricDifference(other.wrappedInstance)
    return CharacterSetWrapper(result)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func formSymmetricDifference(_ other: CharacterSetWrapper) {
    return wrappedInstance.formSymmetricDifference(other.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func union(_ other: CharacterSetWrapper) -> CharacterSetWrapper {
    let result = wrappedInstance.union(other.wrappedInstance)
    return CharacterSetWrapper(result)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func insert(charactersIn string: String) {
    return wrappedInstance.insert(charactersIn: string)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func invert() {
    return wrappedInstance.invert()
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func remove(charactersIn string: String) {
    return wrappedInstance.remove(charactersIn: string)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func subtract(_ other: CharacterSetWrapper) {
    return wrappedInstance.subtract(other.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func formUnion(_ other: CharacterSetWrapper) {
    return wrappedInstance.formUnion(other.wrappedInstance)
  }

}

@available(macOS, introduced: 10.12)
@available(watchOS, introduced: 3.0)
@available(iOS, introduced: 10.0)
@available(tvOS, introduced: 10.0)
@objc public class DateIntervalWrapper: NSObject {
  var wrappedInstance: DateInterval

  @available(macOS, introduced: 10.12)
  @available(watchOS, introduced: 3.0)
  @available(iOS, introduced: 10.0)
  @available(tvOS, introduced: 10.0)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  @available(macOS, introduced: 10.12)
  @available(watchOS, introduced: 3.0)
  @available(iOS, introduced: 10.0)
  @available(tvOS, introduced: 10.0)
  @objc public var debugDescription: String {
    get {
      wrappedInstance.debugDescription
    }
  }

  @available(macOS, introduced: 10.12)
  @available(watchOS, introduced: 3.0)
  @available(iOS, introduced: 10.0)
  @available(tvOS, introduced: 10.0)
  @objc public var end: DateWrapper {
    get {
      DateWrapper(wrappedInstance.end)
    }
    set {
      wrappedInstance.end = newValue.wrappedInstance
    }
  }

  @available(macOS, introduced: 10.12)
  @available(watchOS, introduced: 3.0)
  @available(iOS, introduced: 10.0)
  @available(tvOS, introduced: 10.0)
  @objc public var start: DateWrapper {
    get {
      DateWrapper(wrappedInstance.start)
    }
    set {
      wrappedInstance.start = newValue.wrappedInstance
    }
  }

  @available(macOS, introduced: 10.12)
  @available(watchOS, introduced: 3.0)
  @available(iOS, introduced: 10.0)
  @available(tvOS, introduced: 10.0)
  @objc public var duration: TimeInterval {
    get {
      wrappedInstance.duration
    }
    set {
      wrappedInstance.duration = newValue
    }
  }

  init(_ wrappedInstance: DateInterval) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.12)
  @available(watchOS, introduced: 3.0)
  @available(iOS, introduced: 10.0)
  @available(tvOS, introduced: 10.0)
  @objc init(start: DateWrapper, end: DateWrapper) {
    wrappedInstance = DateInterval(start: start.wrappedInstance, end: end.wrappedInstance)
  }

  @available(macOS, introduced: 10.12)
  @available(watchOS, introduced: 3.0)
  @available(iOS, introduced: 10.0)
  @available(tvOS, introduced: 10.0)
  @objc init(start: DateWrapper, duration: TimeInterval) {
    wrappedInstance = DateInterval(start: start.wrappedInstance, duration: duration)
  }

  @available(macOS, introduced: 10.12)
  @available(watchOS, introduced: 3.0)
  @available(iOS, introduced: 10.0)
  @available(tvOS, introduced: 10.0)
  @objc override init() {
    wrappedInstance = DateInterval()
  }

  @available(macOS, introduced: 10.12)
  @available(watchOS, introduced: 3.0)
  @available(iOS, introduced: 10.0)
  @available(tvOS, introduced: 10.0)
  @objc public func intersects(_ dateInterval: DateIntervalWrapper) -> Bool {
    return wrappedInstance.intersects(dateInterval.wrappedInstance)
  }

  @available(macOS, introduced: 10.12)
  @available(watchOS, introduced: 3.0)
  @available(iOS, introduced: 10.0)
  @available(tvOS, introduced: 10.0)
  @objc public func intersection(with dateInterval: DateIntervalWrapper) -> DateIntervalWrapper? {
    let result = wrappedInstance.intersection(with: dateInterval.wrappedInstance)
    return result == nil ? nil : DateIntervalWrapper(result!)
  }

  @available(macOS, introduced: 10.12)
  @available(watchOS, introduced: 3.0)
  @available(iOS, introduced: 10.0)
  @available(tvOS, introduced: 10.0)
  @objc public func contains(_ date: DateWrapper) -> Bool {
    return wrappedInstance.contains(date.wrappedInstance)
  }

}

@available(macOS, introduced: 10.9)
@available(watchOS, introduced: 2.0)
@available(iOS, introduced: 8.0)
@available(tvOS, introduced: 9.0)
@objc public class DateComponentsWrapper: NSObject {
  var wrappedInstance: DateComponents

  @available(macOS, introduced: 10.9)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isValidDate: Bool {
    get {
      wrappedInstance.isValidDate
    }
  }

  @available(macOS, introduced: 10.9)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var nanosecond: Int? {
    get {
      wrappedInstance.nanosecond
    }
    set {
      wrappedInstance.nanosecond = newValue
    }
  }

  @available(macOS, introduced: 10.9)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var weekOfYear: Int? {
    get {
      wrappedInstance.weekOfYear
    }
    set {
      wrappedInstance.weekOfYear = newValue
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  @available(macOS, introduced: 10.9)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isLeapMonth: Bool? {
    get {
      wrappedInstance.isLeapMonth
    }
    set {
      wrappedInstance.isLeapMonth = newValue
    }
  }

  @available(macOS, introduced: 10.9)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var weekOfMonth: Int? {
    get {
      wrappedInstance.weekOfMonth
    }
    set {
      wrappedInstance.weekOfMonth = newValue
    }
  }

  @available(macOS, introduced: 10.9)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var weekdayOrdinal: Int? {
    get {
      wrappedInstance.weekdayOrdinal
    }
    set {
      wrappedInstance.weekdayOrdinal = newValue
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var debugDescription: String {
    get {
      wrappedInstance.debugDescription
    }
  }

  @available(macOS, introduced: 10.9)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var yearForWeekOfYear: Int? {
    get {
      wrappedInstance.yearForWeekOfYear
    }
    set {
      wrappedInstance.yearForWeekOfYear = newValue
    }
  }

  @available(macOS, introduced: 10.9)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var day: Int? {
    get {
      wrappedInstance.day
    }
    set {
      wrappedInstance.day = newValue
    }
  }

  @available(macOS, introduced: 10.9)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var era: Int? {
    get {
      wrappedInstance.era
    }
    set {
      wrappedInstance.era = newValue
    }
  }

  @available(macOS, introduced: 10.9)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var date: DateWrapper? {
    get {
      wrappedInstance.date == nil ? nil : DateWrapper(wrappedInstance.date!)
    }
  }

  @available(macOS, introduced: 10.9)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var hour: Int? {
    get {
      wrappedInstance.hour
    }
    set {
      wrappedInstance.hour = newValue
    }
  }

  @available(macOS, introduced: 10.9)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var year: Int? {
    get {
      wrappedInstance.year
    }
    set {
      wrappedInstance.year = newValue
    }
  }

  @available(macOS, introduced: 10.9)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var month: Int? {
    get {
      wrappedInstance.month
    }
    set {
      wrappedInstance.month = newValue
    }
  }

  @available(macOS, introduced: 10.9)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var minute: Int? {
    get {
      wrappedInstance.minute
    }
    set {
      wrappedInstance.minute = newValue
    }
  }

  @available(macOS, introduced: 10.9)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var second: Int? {
    get {
      wrappedInstance.second
    }
    set {
      wrappedInstance.second = newValue
    }
  }

  @available(macOS, introduced: 10.9)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var quarter: Int? {
    get {
      wrappedInstance.quarter
    }
    set {
      wrappedInstance.quarter = newValue
    }
  }

  @available(macOS, introduced: 10.9)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var weekday: Int? {
    get {
      wrappedInstance.weekday
    }
    set {
      wrappedInstance.weekday = newValue
    }
  }

  @available(macOS, introduced: 10.9)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var calendar: CalendarWrapper? {
    get {
      wrappedInstance.calendar == nil ? nil : CalendarWrapper(wrappedInstance.calendar!)
    }
    set {
      wrappedInstance.calendar = newValue?.wrappedInstance
    }
  }

  @available(macOS, introduced: 10.9)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var timeZone: TimeZoneWrapper? {
    get {
      wrappedInstance.timeZone == nil ? nil : TimeZoneWrapper(wrappedInstance.timeZone!)
    }
    set {
      wrappedInstance.timeZone = newValue?.wrappedInstance
    }
  }

  @available(macOS, introduced: 15)
  @available(watchOS, introduced: 11)
  @available(iOS, introduced: 18)
  @available(tvOS, introduced: 18)
  @objc public var dayOfYear: Int? {
    get {
      wrappedInstance.dayOfYear
    }
    set {
      wrappedInstance.dayOfYear = newValue
    }
  }

  init(_ wrappedInstance: DateComponents) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.9)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func isValidDate(in calendar: CalendarWrapper) -> Bool {
    return wrappedInstance.isValidDate(in: calendar.wrappedInstance)
  }

}

@available(macOS, introduced: 12)
@available(watchOS, introduced: 8)
@available(iOS, introduced: 15)
@available(tvOS, introduced: 15)
@objc public class AttributedStringWrapper: NSObject {
  var wrappedInstance: AttributedString

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public var characters: AttributedStringWrapper.CharacterViewWrapper {
    get {
      CharacterViewWrapper(wrappedInstance.characters)
    }
    set {
      wrappedInstance.characters = newValue.wrappedInstance
    }
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public var startIndex: AttributedStringWrapper.IndexWrapper {
    get {
      IndexWrapper(wrappedInstance.startIndex)
    }
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public var unicodeScalars: AttributedStringWrapper.UnicodeScalarViewWrapper {
    get {
      UnicodeScalarViewWrapper(wrappedInstance.unicodeScalars)
    }
    set {
      wrappedInstance.unicodeScalars = newValue.wrappedInstance
    }
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public var runs: AttributedStringWrapper.RunsWrapper {
    get {
      RunsWrapper(wrappedInstance.runs)
    }
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public var endIndex: AttributedStringWrapper.IndexWrapper {
    get {
      IndexWrapper(wrappedInstance.endIndex)
    }
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: AttributedString) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc init(stringLiteral value: String) {
    wrappedInstance = AttributedString(stringLiteral: value)
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init(localized resource: LocalizedStringResourceWrapper, options: AttributedStringWrapper.LocalizationOptionsWrapper) {
    wrappedInstance = AttributedString(localized: resource.wrappedInstance, options: options.wrappedInstance)
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init(localized resource: LocalizedStringResourceWrapper) {
    wrappedInstance = AttributedString(localized: resource.wrappedInstance)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc override init() {
    wrappedInstance = AttributedString()
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc init(_ substring: AttributedSubstringWrapper) {
    wrappedInstance = AttributedString(substring.wrappedInstance)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func setAttributes(_ attributes: AttributeContainerWrapper) {
    return wrappedInstance.setAttributes(attributes.wrappedInstance)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func replaceAttributes(_ attributes: AttributeContainerWrapper, with others: AttributeContainerWrapper) {
    return wrappedInstance.replaceAttributes(attributes.wrappedInstance, with: others.wrappedInstance)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func inflected() -> AttributedStringWrapper {
    let result = wrappedInstance.inflected()
    return AttributedStringWrapper(result)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func settingAttributes(_ attributes: AttributeContainerWrapper) -> AttributedStringWrapper {
    let result = wrappedInstance.settingAttributes(attributes.wrappedInstance)
    return AttributedStringWrapper(result)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func replacingAttributes(_ attributes: AttributeContainerWrapper, with others: AttributeContainerWrapper) -> AttributedStringWrapper {
    let result = wrappedInstance.replacingAttributes(attributes.wrappedInstance, with: others.wrappedInstance)
    return AttributedStringWrapper(result)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func index(afterCharacter i: AttributedStringWrapper.IndexWrapper) -> AttributedStringWrapper.IndexWrapper {
    let result = wrappedInstance.index(afterCharacter: i.wrappedInstance)
    return IndexWrapper(result)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func index(beforeCharacter i: AttributedStringWrapper.IndexWrapper) -> AttributedStringWrapper.IndexWrapper {
    let result = wrappedInstance.index(beforeCharacter: i.wrappedInstance)
    return IndexWrapper(result)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func index(afterUnicodeScalar i: AttributedStringWrapper.IndexWrapper) -> AttributedStringWrapper.IndexWrapper {
    let result = wrappedInstance.index(afterUnicodeScalar: i.wrappedInstance)
    return IndexWrapper(result)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func index(beforeUnicodeScalar i: AttributedStringWrapper.IndexWrapper) -> AttributedStringWrapper.IndexWrapper {
    let result = wrappedInstance.index(beforeUnicodeScalar: i.wrappedInstance)
    return IndexWrapper(result)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func index(afterRun i: AttributedStringWrapper.IndexWrapper) -> AttributedStringWrapper.IndexWrapper {
    let result = wrappedInstance.index(afterRun: i.wrappedInstance)
    return IndexWrapper(result)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func index(beforeRun i: AttributedStringWrapper.IndexWrapper) -> AttributedStringWrapper.IndexWrapper {
    let result = wrappedInstance.index(beforeRun: i.wrappedInstance)
    return IndexWrapper(result)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func index(_ i: AttributedStringWrapper.IndexWrapper, offsetByRuns distance: Int) -> AttributedStringWrapper.IndexWrapper {
    let result = wrappedInstance.index(i.wrappedInstance, offsetByRuns: distance)
    return IndexWrapper(result)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func index(_ i: AttributedStringWrapper.IndexWrapper, offsetByCharacters distance: Int) -> AttributedStringWrapper.IndexWrapper {
    let result = wrappedInstance.index(i.wrappedInstance, offsetByCharacters: distance)
    return IndexWrapper(result)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func index(_ i: AttributedStringWrapper.IndexWrapper, offsetByUnicodeScalars distance: Int) -> AttributedStringWrapper.IndexWrapper {
    let result = wrappedInstance.index(i.wrappedInstance, offsetByUnicodeScalars: distance)
    return IndexWrapper(result)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public class CharacterViewWrapper: NSObject {
    var wrappedInstance: AttributedString.CharacterView

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public var startIndex: AttributedStringWrapper.IndexWrapper {
      get {
        IndexWrapper(wrappedInstance.startIndex)
      }
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public var count: Int {
      get {
        wrappedInstance.count
      }
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public var endIndex: AttributedStringWrapper.IndexWrapper {
      get {
        IndexWrapper(wrappedInstance.endIndex)
      }
    }

    @objc public var underestimatedCount: Int {
      get {
        wrappedInstance.underestimatedCount
      }
    }

    @objc public var isEmpty: Bool {
      get {
        wrappedInstance.isEmpty
      }
    }

    init(_ wrappedInstance: AttributedString.CharacterView) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc override init() {
      wrappedInstance = AttributedString.CharacterView()
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public func index(after i: AttributedStringWrapper.IndexWrapper) -> AttributedStringWrapper.IndexWrapper {
      let result = wrappedInstance.index(after: i.wrappedInstance)
      return IndexWrapper(result)
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public func index(before i: AttributedStringWrapper.IndexWrapper) -> AttributedStringWrapper.IndexWrapper {
      let result = wrappedInstance.index(before: i.wrappedInstance)
      return IndexWrapper(result)
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public func index(_ i: AttributedStringWrapper.IndexWrapper, offsetBy distance: Int, limitedBy limit: AttributedStringWrapper.IndexWrapper) -> AttributedStringWrapper.IndexWrapper? {
      let result = wrappedInstance.index(i.wrappedInstance, offsetBy: distance, limitedBy: limit.wrappedInstance)
      return result == nil ? nil : IndexWrapper(result!)
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public func index(_ i: AttributedStringWrapper.IndexWrapper, offsetBy distance: Int) -> AttributedStringWrapper.IndexWrapper {
      let result = wrappedInstance.index(i.wrappedInstance, offsetBy: distance)
      return IndexWrapper(result)
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public func distance(from start: AttributedStringWrapper.IndexWrapper, to end: AttributedStringWrapper.IndexWrapper) -> Int {
      return wrappedInstance.distance(from: start.wrappedInstance, to: end.wrappedInstance)
    }

    @objc public func removeFirst(_ k: Int) {
      return wrappedInstance.removeFirst(k)
    }

    @objc public func reserveCapacity(_ n: Int) {
      return wrappedInstance.reserveCapacity(n)
    }

    @objc public func removeLast(_ k: Int) {
      return wrappedInstance.removeLast(k)
    }

  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public class FormattingOptionsWrapper: NSObject {
    var wrappedInstance: AttributedString.FormattingOptions

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc static public var applyReplacementIndexAttribute: AttributedStringWrapper.FormattingOptionsWrapper {
      get {
        FormattingOptionsWrapper(AttributedString.FormattingOptions.applyReplacementIndexAttribute)
      }
    }

    @objc public var isEmpty: Bool {
      get {
        wrappedInstance.isEmpty
      }
    }

    init(_ wrappedInstance: AttributedString.FormattingOptions) {
      self.wrappedInstance = wrappedInstance
    }

    @objc override init() {
      wrappedInstance = AttributedString.FormattingOptions()
    }

  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public class UnicodeScalarViewWrapper: NSObject {
    var wrappedInstance: AttributedString.UnicodeScalarView

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public var startIndex: AttributedStringWrapper.IndexWrapper {
      get {
        IndexWrapper(wrappedInstance.startIndex)
      }
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public var count: Int {
      get {
        wrappedInstance.count
      }
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public var endIndex: AttributedStringWrapper.IndexWrapper {
      get {
        IndexWrapper(wrappedInstance.endIndex)
      }
    }

    @objc public var underestimatedCount: Int {
      get {
        wrappedInstance.underestimatedCount
      }
    }

    @objc public var isEmpty: Bool {
      get {
        wrappedInstance.isEmpty
      }
    }

    init(_ wrappedInstance: AttributedString.UnicodeScalarView) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc override init() {
      wrappedInstance = AttributedString.UnicodeScalarView()
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public func index(after i: AttributedStringWrapper.IndexWrapper) -> AttributedStringWrapper.IndexWrapper {
      let result = wrappedInstance.index(after: i.wrappedInstance)
      return IndexWrapper(result)
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public func index(before i: AttributedStringWrapper.IndexWrapper) -> AttributedStringWrapper.IndexWrapper {
      let result = wrappedInstance.index(before: i.wrappedInstance)
      return IndexWrapper(result)
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public func index(_ i: AttributedStringWrapper.IndexWrapper, offsetBy distance: Int, limitedBy limit: AttributedStringWrapper.IndexWrapper) -> AttributedStringWrapper.IndexWrapper? {
      let result = wrappedInstance.index(i.wrappedInstance, offsetBy: distance, limitedBy: limit.wrappedInstance)
      return result == nil ? nil : IndexWrapper(result!)
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public func index(_ i: AttributedStringWrapper.IndexWrapper, offsetBy distance: Int) -> AttributedStringWrapper.IndexWrapper {
      let result = wrappedInstance.index(i.wrappedInstance, offsetBy: distance)
      return IndexWrapper(result)
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public func distance(from start: AttributedStringWrapper.IndexWrapper, to end: AttributedStringWrapper.IndexWrapper) -> Int {
      return wrappedInstance.distance(from: start.wrappedInstance, to: end.wrappedInstance)
    }

    @objc public func removeFirst(_ k: Int) {
      return wrappedInstance.removeFirst(k)
    }

    @objc public func reserveCapacity(_ n: Int) {
      return wrappedInstance.reserveCapacity(n)
    }

    @objc public func removeLast(_ k: Int) {
      return wrappedInstance.removeLast(k)
    }

  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public class LocalizationOptionsWrapper: NSObject {
    var wrappedInstance: AttributedString.LocalizationOptions

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var applyReplacementIndexAttribute: Bool {
      get {
        wrappedInstance.applyReplacementIndexAttribute
      }
      set {
        wrappedInstance.applyReplacementIndexAttribute = newValue
      }
    }

    @available(macOS, introduced: 15.0)
    @available(watchOS, introduced: 11.0)
    @available(iOS, introduced: 18.0)
    @available(visionOS, introduced: 2.0)
    @available(tvOS, introduced: 18.0)
    @objc public var inflect: Bool {
      get {
        wrappedInstance.inflect
      }
      set {
        wrappedInstance.inflect = newValue
      }
    }

    init(_ wrappedInstance: AttributedString.LocalizationOptions) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc override init() {
      wrappedInstance = AttributedString.LocalizationOptions()
    }

    @available(macOS, introduced: 15.0)
    @available(watchOS, introduced: 11.0)
    @available(iOS, introduced: 18.0)
    @available(tvOS, introduced: 18.0)
    @objc static public func localizedPhraseConcept(_ phrase: String) -> AttributedStringWrapper.LocalizationOptionsWrapper {
      let result = AttributedString.LocalizationOptions.localizedPhraseConcept(phrase)
      return LocalizationOptionsWrapper(result)
    }

  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public class InterpolationOptionsWrapper: NSObject {
    var wrappedInstance: AttributedString.InterpolationOptions

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc static public var insertAttributesWithoutMerging: AttributedStringWrapper.InterpolationOptionsWrapper {
      get {
        InterpolationOptionsWrapper(AttributedString.InterpolationOptions.insertAttributesWithoutMerging)
      }
    }

    @objc public var isEmpty: Bool {
      get {
        wrappedInstance.isEmpty
      }
    }

    init(_ wrappedInstance: AttributedString.InterpolationOptions) {
      self.wrappedInstance = wrappedInstance
    }

    @objc override init() {
      wrappedInstance = AttributedString.InterpolationOptions()
    }

  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public class MarkdownParsingOptionsWrapper: NSObject {
    var wrappedInstance: AttributedString.MarkdownParsingOptions

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public var languageCode: String? {
      get {
        wrappedInstance.languageCode
      }
      set {
        wrappedInstance.languageCode = newValue
      }
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public var allowsExtendedAttributes: Bool {
      get {
        wrappedInstance.allowsExtendedAttributes
      }
      set {
        wrappedInstance.allowsExtendedAttributes = newValue
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var appliesSourcePositionAttributes: Bool {
      get {
        wrappedInstance.appliesSourcePositionAttributes
      }
      set {
        wrappedInstance.appliesSourcePositionAttributes = newValue
      }
    }

    init(_ wrappedInstance: AttributedString.MarkdownParsingOptions) {
      self.wrappedInstance = wrappedInstance
    }

  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public class MarkdownSourcePositionWrapper: NSObject {
    var wrappedInstance: AttributedString.MarkdownSourcePosition

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var startColumn: Int {
      get {
        wrappedInstance.startColumn
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var endLine: Int {
      get {
        wrappedInstance.endLine
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var endColumn: Int {
      get {
        wrappedInstance.endColumn
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var startLine: Int {
      get {
        wrappedInstance.startLine
      }
    }

    init(_ wrappedInstance: AttributedString.MarkdownSourcePosition) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc init(startLine: Int, startColumn: Int, endLine: Int, endColumn: Int) {
      wrappedInstance = AttributedString.MarkdownSourcePosition(startLine: startLine, startColumn: startColumn, endLine: endLine, endColumn: endColumn)
    }

  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public class SingleAttributeTransformerWrapper: NSObject {
    var wrappedInstance: AttributedString.SingleAttributeTransformer

    init(_ wrappedInstance: AttributedString.SingleAttributeTransformer) {
      self.wrappedInstance = wrappedInstance
    }

  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public class AttributeInvalidationConditionWrapper: NSObject {
    var wrappedInstance: AttributedString.AttributeInvalidationCondition

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var textChanged: AttributedStringWrapper.AttributeInvalidationConditionWrapper {
      get {
        AttributeInvalidationConditionWrapper(AttributedString.AttributeInvalidationCondition.textChanged)
      }
    }

    init(_ wrappedInstance: AttributedString.AttributeInvalidationCondition) {
      self.wrappedInstance = wrappedInstance
    }

  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public class RunsWrapper: NSObject {
    var wrappedInstance: AttributedString.Runs

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public var startIndex: RunsWrapper.IndexWrapper {
      get {
        IndexWrapper(wrappedInstance.startIndex)
      }
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public var description: String {
      get {
        wrappedInstance.description
      }
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public var endIndex: RunsWrapper.IndexWrapper {
      get {
        IndexWrapper(wrappedInstance.endIndex)
      }
    }

    @objc public var underestimatedCount: Int {
      get {
        wrappedInstance.underestimatedCount
      }
    }

    @objc public var count: Int {
      get {
        wrappedInstance.count
      }
    }

    @objc public var isEmpty: Bool {
      get {
        wrappedInstance.isEmpty
      }
    }

    init(_ wrappedInstance: AttributedString.Runs) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public func index(after i: RunsWrapper.IndexWrapper) -> RunsWrapper.IndexWrapper {
      let result = wrappedInstance.index(after: i.wrappedInstance)
      return IndexWrapper(result)
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public func index(before i: RunsWrapper.IndexWrapper) -> RunsWrapper.IndexWrapper {
      let result = wrappedInstance.index(before: i.wrappedInstance)
      return IndexWrapper(result)
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public func index(_ i: RunsWrapper.IndexWrapper, offsetBy distance: Int, limitedBy limit: RunsWrapper.IndexWrapper) -> RunsWrapper.IndexWrapper? {
      let result = wrappedInstance.index(i.wrappedInstance, offsetBy: distance, limitedBy: limit.wrappedInstance)
      return result == nil ? nil : IndexWrapper(result!)
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public func index(_ i: RunsWrapper.IndexWrapper, offsetBy distance: Int) -> RunsWrapper.IndexWrapper {
      let result = wrappedInstance.index(i.wrappedInstance, offsetBy: distance)
      return IndexWrapper(result)
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public func distance(from start: RunsWrapper.IndexWrapper, to end: RunsWrapper.IndexWrapper) -> Int {
      return wrappedInstance.distance(from: start.wrappedInstance, to: end.wrappedInstance)
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public class AttributesSlice1Wrapper: NSObject {
      var wrappedInstance: Runs.AttributesSlice1

      @available(macOS, introduced: 12)
      @available(watchOS, introduced: 8)
      @available(iOS, introduced: 15)
      @available(tvOS, introduced: 15)
      @objc public var startIndex: RunsWrapper.AttributesSlice1Wrapper {
        get {
          AttributesSlice1Wrapper(wrappedInstance.startIndex)
        }
      }

      @available(macOS, introduced: 12)
      @available(watchOS, introduced: 8)
      @available(iOS, introduced: 15)
      @available(tvOS, introduced: 15)
      @objc public var endIndex: RunsWrapper.AttributesSlice1Wrapper {
        get {
          AttributesSlice1Wrapper(wrappedInstance.endIndex)
        }
      }

      @objc public var underestimatedCount: Int {
        get {
          wrappedInstance.underestimatedCount
        }
      }

      @objc public var count: Int {
        get {
          wrappedInstance.count
        }
      }

      @objc public var isEmpty: Bool {
        get {
          wrappedInstance.isEmpty
        }
      }

      init(_ wrappedInstance: Runs.AttributesSlice1) {
        self.wrappedInstance = wrappedInstance
      }

      @available(macOS, introduced: 12)
      @available(watchOS, introduced: 8)
      @available(iOS, introduced: 15)
      @available(tvOS, introduced: 15)
      @objc public func makeIterator() -> RunsWrapper.AttributesSlice1Wrapper {
        let result = wrappedInstance.makeIterator()
        return AttributesSlice1Wrapper(result)
      }

      @available(macOS, introduced: 12)
      @available(watchOS, introduced: 8)
      @available(iOS, introduced: 15)
      @available(tvOS, introduced: 15)
      @objc public class IteratorWrapper: NSObject {
        var wrappedInstance: AttributesSlice1.Iterator

        init(_ wrappedInstance: AttributesSlice1.Iterator) {
          self.wrappedInstance = wrappedInstance
        }

        @available(macOS, introduced: 12)
        @available(watchOS, introduced: 8)
        @available(iOS, introduced: 15)
        @available(tvOS, introduced: 15)
        @objc public func next() -> RunsWrapper.AttributesSlice1Wrapper {
          let result = wrappedInstance.next()
          return AttributesSlice1Wrapper(result)
        }

      }

    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public class AttributesSlice2Wrapper: NSObject {
      var wrappedInstance: Runs.AttributesSlice2

      @available(macOS, introduced: 12)
      @available(watchOS, introduced: 8)
      @available(iOS, introduced: 15)
      @available(tvOS, introduced: 15)
      @objc public var startIndex: RunsWrapper.AttributesSlice2Wrapper {
        get {
          AttributesSlice2Wrapper(wrappedInstance.startIndex)
        }
      }

      @available(macOS, introduced: 12)
      @available(watchOS, introduced: 8)
      @available(iOS, introduced: 15)
      @available(tvOS, introduced: 15)
      @objc public var endIndex: RunsWrapper.AttributesSlice2Wrapper {
        get {
          AttributesSlice2Wrapper(wrappedInstance.endIndex)
        }
      }

      @objc public var underestimatedCount: Int {
        get {
          wrappedInstance.underestimatedCount
        }
      }

      @objc public var count: Int {
        get {
          wrappedInstance.count
        }
      }

      @objc public var isEmpty: Bool {
        get {
          wrappedInstance.isEmpty
        }
      }

      init(_ wrappedInstance: Runs.AttributesSlice2) {
        self.wrappedInstance = wrappedInstance
      }

      @available(macOS, introduced: 12)
      @available(watchOS, introduced: 8)
      @available(iOS, introduced: 15)
      @available(tvOS, introduced: 15)
      @objc public func makeIterator() -> RunsWrapper.AttributesSlice2Wrapper {
        let result = wrappedInstance.makeIterator()
        return AttributesSlice2Wrapper(result)
      }

      @available(macOS, introduced: 12)
      @available(watchOS, introduced: 8)
      @available(iOS, introduced: 15)
      @available(tvOS, introduced: 15)
      @objc public class IteratorWrapper: NSObject {
        var wrappedInstance: AttributesSlice2.Iterator

        init(_ wrappedInstance: AttributesSlice2.Iterator) {
          self.wrappedInstance = wrappedInstance
        }

        @available(macOS, introduced: 12)
        @available(watchOS, introduced: 8)
        @available(iOS, introduced: 15)
        @available(tvOS, introduced: 15)
        @objc public func next() -> RunsWrapper.AttributesSlice2Wrapper {
          let result = wrappedInstance.next()
          return AttributesSlice2Wrapper(result)
        }

      }

    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public class AttributesSlice3Wrapper: NSObject {
      var wrappedInstance: Runs.AttributesSlice3

      @available(macOS, introduced: 12)
      @available(watchOS, introduced: 8)
      @available(iOS, introduced: 15)
      @available(tvOS, introduced: 15)
      @objc public var startIndex: RunsWrapper.AttributesSlice3Wrapper {
        get {
          AttributesSlice3Wrapper(wrappedInstance.startIndex)
        }
      }

      @available(macOS, introduced: 12)
      @available(watchOS, introduced: 8)
      @available(iOS, introduced: 15)
      @available(tvOS, introduced: 15)
      @objc public var endIndex: RunsWrapper.AttributesSlice3Wrapper {
        get {
          AttributesSlice3Wrapper(wrappedInstance.endIndex)
        }
      }

      @objc public var underestimatedCount: Int {
        get {
          wrappedInstance.underestimatedCount
        }
      }

      @objc public var count: Int {
        get {
          wrappedInstance.count
        }
      }

      @objc public var isEmpty: Bool {
        get {
          wrappedInstance.isEmpty
        }
      }

      init(_ wrappedInstance: Runs.AttributesSlice3) {
        self.wrappedInstance = wrappedInstance
      }

      @available(macOS, introduced: 12)
      @available(watchOS, introduced: 8)
      @available(iOS, introduced: 15)
      @available(tvOS, introduced: 15)
      @objc public func makeIterator() -> RunsWrapper.AttributesSlice3Wrapper {
        let result = wrappedInstance.makeIterator()
        return AttributesSlice3Wrapper(result)
      }

      @available(macOS, introduced: 12)
      @available(watchOS, introduced: 8)
      @available(iOS, introduced: 15)
      @available(tvOS, introduced: 15)
      @objc public class IteratorWrapper: NSObject {
        var wrappedInstance: AttributesSlice3.Iterator

        init(_ wrappedInstance: AttributesSlice3.Iterator) {
          self.wrappedInstance = wrappedInstance
        }

        @available(macOS, introduced: 12)
        @available(watchOS, introduced: 8)
        @available(iOS, introduced: 15)
        @available(tvOS, introduced: 15)
        @objc public func next() -> RunsWrapper.AttributesSlice3Wrapper {
          let result = wrappedInstance.next()
          return AttributesSlice3Wrapper(result)
        }

      }

    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public class AttributesSlice4Wrapper: NSObject {
      var wrappedInstance: Runs.AttributesSlice4

      @available(macOS, introduced: 12)
      @available(watchOS, introduced: 8)
      @available(iOS, introduced: 15)
      @available(tvOS, introduced: 15)
      @objc public var startIndex: RunsWrapper.AttributesSlice4Wrapper {
        get {
          AttributesSlice4Wrapper(wrappedInstance.startIndex)
        }
      }

      @available(macOS, introduced: 12)
      @available(watchOS, introduced: 8)
      @available(iOS, introduced: 15)
      @available(tvOS, introduced: 15)
      @objc public var endIndex: RunsWrapper.AttributesSlice4Wrapper {
        get {
          AttributesSlice4Wrapper(wrappedInstance.endIndex)
        }
      }

      @objc public var underestimatedCount: Int {
        get {
          wrappedInstance.underestimatedCount
        }
      }

      @objc public var count: Int {
        get {
          wrappedInstance.count
        }
      }

      @objc public var isEmpty: Bool {
        get {
          wrappedInstance.isEmpty
        }
      }

      init(_ wrappedInstance: Runs.AttributesSlice4) {
        self.wrappedInstance = wrappedInstance
      }

      @available(macOS, introduced: 12)
      @available(watchOS, introduced: 8)
      @available(iOS, introduced: 15)
      @available(tvOS, introduced: 15)
      @objc public func makeIterator() -> RunsWrapper.AttributesSlice4Wrapper {
        let result = wrappedInstance.makeIterator()
        return AttributesSlice4Wrapper(result)
      }

      @available(macOS, introduced: 12)
      @available(watchOS, introduced: 8)
      @available(iOS, introduced: 15)
      @available(tvOS, introduced: 15)
      @objc public class IteratorWrapper: NSObject {
        var wrappedInstance: AttributesSlice4.Iterator

        init(_ wrappedInstance: AttributesSlice4.Iterator) {
          self.wrappedInstance = wrappedInstance
        }

        @available(macOS, introduced: 12)
        @available(watchOS, introduced: 8)
        @available(iOS, introduced: 15)
        @available(tvOS, introduced: 15)
        @objc public func next() -> RunsWrapper.AttributesSlice4Wrapper {
          let result = wrappedInstance.next()
          return AttributesSlice4Wrapper(result)
        }

      }

    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public class AttributesSlice5Wrapper: NSObject {
      var wrappedInstance: Runs.AttributesSlice5

      @available(macOS, introduced: 12)
      @available(watchOS, introduced: 8)
      @available(iOS, introduced: 15)
      @available(tvOS, introduced: 15)
      @objc public var startIndex: RunsWrapper.AttributesSlice5Wrapper {
        get {
          AttributesSlice5Wrapper(wrappedInstance.startIndex)
        }
      }

      @available(macOS, introduced: 12)
      @available(watchOS, introduced: 8)
      @available(iOS, introduced: 15)
      @available(tvOS, introduced: 15)
      @objc public var endIndex: RunsWrapper.AttributesSlice5Wrapper {
        get {
          AttributesSlice5Wrapper(wrappedInstance.endIndex)
        }
      }

      @objc public var underestimatedCount: Int {
        get {
          wrappedInstance.underestimatedCount
        }
      }

      @objc public var count: Int {
        get {
          wrappedInstance.count
        }
      }

      @objc public var isEmpty: Bool {
        get {
          wrappedInstance.isEmpty
        }
      }

      init(_ wrappedInstance: Runs.AttributesSlice5) {
        self.wrappedInstance = wrappedInstance
      }

      @available(macOS, introduced: 12)
      @available(watchOS, introduced: 8)
      @available(iOS, introduced: 15)
      @available(tvOS, introduced: 15)
      @objc public func makeIterator() -> RunsWrapper.AttributesSlice5Wrapper {
        let result = wrappedInstance.makeIterator()
        return AttributesSlice5Wrapper(result)
      }

      @available(macOS, introduced: 12)
      @available(watchOS, introduced: 8)
      @available(iOS, introduced: 15)
      @available(tvOS, introduced: 15)
      @objc public class IteratorWrapper: NSObject {
        var wrappedInstance: AttributesSlice5.Iterator

        init(_ wrappedInstance: AttributesSlice5.Iterator) {
          self.wrappedInstance = wrappedInstance
        }

        @available(macOS, introduced: 12)
        @available(watchOS, introduced: 8)
        @available(iOS, introduced: 15)
        @available(tvOS, introduced: 15)
        @objc public func next() -> RunsWrapper.AttributesSlice5Wrapper {
          let result = wrappedInstance.next()
          return AttributesSlice5Wrapper(result)
        }

      }

    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public class RunWrapper: NSObject {
      var wrappedInstance: Runs.Run

      @available(macOS, introduced: 12)
      @available(watchOS, introduced: 8)
      @available(iOS, introduced: 15)
      @available(tvOS, introduced: 15)
      @objc public var attributes: AttributeContainerWrapper {
        get {
          AttributeContainerWrapper(wrappedInstance.attributes)
        }
      }

      @available(macOS, introduced: 12)
      @available(watchOS, introduced: 8)
      @available(iOS, introduced: 15)
      @available(tvOS, introduced: 15)
      @objc public var description: String {
        get {
          wrappedInstance.description
        }
      }

      init(_ wrappedInstance: Runs.Run) {
        self.wrappedInstance = wrappedInstance
      }

    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public class IndexWrapper: NSObject {
      var wrappedInstance: Runs.Index

      init(_ wrappedInstance: Runs.Index) {
        self.wrappedInstance = wrappedInstance
      }

      @available(macOS, introduced: 12)
      @available(watchOS, introduced: 8)
      @available(iOS, introduced: 15)
      @available(tvOS, introduced: 15)
      @objc public func advanced(by n: Int) -> RunsWrapper.IndexWrapper {
        let result = wrappedInstance.advanced(by: n)
        return IndexWrapper(result)
      }

      @available(macOS, introduced: 12)
      @available(watchOS, introduced: 8)
      @available(iOS, introduced: 15)
      @available(tvOS, introduced: 15)
      @objc public func distance(to other: RunsWrapper.IndexWrapper) -> Int {
        return wrappedInstance.distance(to: other.wrappedInstance)
      }

    }

  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public class IndexWrapper: NSObject {
    var wrappedInstance: AttributedString.Index

    init(_ wrappedInstance: AttributedString.Index) {
      self.wrappedInstance = wrappedInstance
    }

  }

}

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class AsyncLineSequenceWrapper: NSObject {
  var wrappedInstance: AsyncLineSequence

  init(_ wrappedInstance: AsyncLineSequence) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func makeAsyncIterator() -> AsyncLineSequenceWrapper {
    let result = wrappedInstance.makeAsyncIterator()
    return AsyncLineSequenceWrapper(result)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class AsyncIteratorWrapper: NSObject {
    var wrappedInstance: AsyncLineSequence.AsyncIterator

    init(_ wrappedInstance: AsyncLineSequence.AsyncIterator) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func next() async -> String? {
      return await wrappedInstance.next()
    }

  }

}

@available(macOS, introduced: 10.10)
@available(watchOS, introduced: 2.0)
@available(iOS, introduced: 8.0)
@available(tvOS, introduced: 9.0)
@objc public class URLResourceValuesWrapper: NSObject {
  var wrappedInstance: URLResourceValues

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isReadable: Bool? {
    get {
      wrappedInstance.isReadable
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isWritable: Bool? {
    get {
      wrappedInstance.isWritable
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeName: String? {
    get {
      wrappedInstance.volumeName
    }
    set {
      wrappedInstance.volumeName = newValue
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isAliasFile: Bool? {
    get {
      wrappedInstance.isAliasFile
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isDirectory: Bool? {
    get {
      wrappedInstance.isDirectory
    }
  }

  @available(macOS, introduced: 11.0)
  @available(watchOS, introduced: 7.0)
  @available(iOS, introduced: 14.0)
  @available(tvOS, introduced: 14.0)
  @objc public var isPurgeable: Bool? {
    get {
      wrappedInstance.isPurgeable
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var labelNumber: Int? {
    get {
      wrappedInstance.labelNumber
    }
    set {
      wrappedInstance.labelNumber = newValue
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var creationDate: DateWrapper? {
    get {
      wrappedInstance.creationDate == nil ? nil : DateWrapper(wrappedInstance.creationDate!)
    }
    set {
      wrappedInstance.creationDate = newValue?.wrappedInstance
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var fileSecurity: NSFileSecurityWrapper? {
    get {
      wrappedInstance.fileSecurity == nil ? nil : NSFileSecurityWrapper(wrappedInstance.fileSecurity!)
    }
    set {
      wrappedInstance.fileSecurity = newValue?.wrappedInstance
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isExecutable: Bool? {
    get {
      wrappedInstance.isExecutable
    }
  }

  @available(macOS, introduced: 10.12)
  @available(watchOS, introduced: 3.0)
  @available(iOS, introduced: 10.0)
  @available(tvOS, introduced: 10.0)
  @objc public var canonicalPath: String? {
    get {
      wrappedInstance.canonicalPath
    }
  }

  @available(macOS, introduced: 10.11)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 9.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isApplication: Bool? {
    get {
      wrappedInstance.isApplication
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isRegularFile: Bool? {
    get {
      wrappedInstance.isRegularFile
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var localizedName: String? {
    get {
      wrappedInstance.localizedName
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var totalFileSize: Int? {
    get {
      wrappedInstance.totalFileSize
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeIsLocal: Bool? {
    get {
      wrappedInstance.volumeIsLocal
    }
  }

  @available(macOS, introduced: 13.3)
  @available(watchOS, introduced: 9.4)
  @available(iOS, introduced: 16.4)
  @available(tvOS, introduced: 16.4)
  @objc public var volumeSubtype: Int? {
    get {
      wrappedInstance.volumeSubtype
    }
  }

  @available(macOS, introduced: 11.0)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 9.0)
  @available(tvOS, introduced: 9.0)
  @objc public var fileProtection: URLFileProtectionWrapper? {
    get {
      wrappedInstance.fileProtection == nil ? nil : URLFileProtectionWrapper(wrappedInstance.fileProtection!)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isMountTrigger: Bool? {
    get {
      wrappedInstance.isMountTrigger
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isSymbolicLink: Bool? {
    get {
      wrappedInstance.isSymbolicLink
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var localizedLabel: String? {
    get {
      wrappedInstance.localizedLabel
    }
  }

  @available(macOS, introduced: 10.10, deprecated: 100000.0)
  @available(watchOS, introduced: 2.0, deprecated: 100000.0)
  @available(iOS, introduced: 8.0, deprecated: 100000.0)
  @available(visionOS, introduced: 1.0, deprecated: 100000.0)
  @available(tvOS, introduced: 9.0, deprecated: 100000.0)
  @objc public var typeIdentifier: String? {
    get {
      wrappedInstance.typeIdentifier
    }
  }

  @available(macOS, introduced: 13.3)
  @available(watchOS, introduced: 9.4)
  @available(iOS, introduced: 16.4)
  @available(tvOS, introduced: 16.4)
  @objc public var volumeTypeName: String? {
    get {
      wrappedInstance.volumeTypeName
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isUserImmutable: Bool? {
    get {
      wrappedInstance.isUserImmutable
    }
    set {
      wrappedInstance.isUserImmutable = newValue
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var parentDirectory: URLWrapper? {
    get {
      wrappedInstance.parentDirectory == nil ? nil : URLWrapper(wrappedInstance.parentDirectory!)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var fileResourceType: URLFileResourceTypeWrapper? {
    get {
      wrappedInstance.fileResourceType == nil ? nil : URLFileResourceTypeWrapper(wrappedInstance.fileResourceType!)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isUbiquitousItem: Bool? {
    get {
      wrappedInstance.isUbiquitousItem
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeIsInternal: Bool? {
    get {
      wrappedInstance.volumeIsInternal
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeIsReadOnly: Bool? {
    get {
      wrappedInstance.volumeIsReadOnly
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeUUIDString: String? {
    get {
      wrappedInstance.volumeUUIDString
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var contentAccessDate: DateWrapper? {
    get {
      wrappedInstance.contentAccessDate == nil ? nil : DateWrapper(wrappedInstance.contentAccessDate!)
    }
    set {
      wrappedInstance.contentAccessDate = newValue?.wrappedInstance
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var fileAllocatedSize: Int? {
    get {
      wrappedInstance.fileAllocatedSize
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isSystemImmutable: Bool? {
    get {
      wrappedInstance.isSystemImmutable
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeIsBrowsable: Bool? {
    get {
      wrappedInstance.volumeIsBrowsable
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeIsEjectable: Bool? {
    get {
      wrappedInstance.volumeIsEjectable
    }
  }

  @available(macOS, introduced: 10.12)
  @available(watchOS, introduced: 3.0)
  @available(iOS, introduced: 10.0)
  @available(tvOS, introduced: 10.0)
  @objc public var volumeIsEncrypted: Bool? {
    get {
      wrappedInstance.volumeIsEncrypted
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeIsRemovable: Bool? {
    get {
      wrappedInstance.volumeIsRemovable
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var documentIdentifier: Int? {
    get {
      wrappedInstance.documentIdentifier
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var hasHiddenExtension: Bool? {
    get {
      wrappedInstance.hasHiddenExtension
    }
    set {
      wrappedInstance.hasHiddenExtension = newValue
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeCreationDate: DateWrapper? {
    get {
      wrappedInstance.volumeCreationDate == nil ? nil : DateWrapper(wrappedInstance.volumeCreationDate!)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeIsJournaling: Bool? {
    get {
      wrappedInstance.volumeIsJournaling
    }
  }

  @available(macOS, introduced: 14.0)
  @available(watchOS, introduced: 10.0)
  @available(iOS, introduced: 17.0)
  @available(tvOS, introduced: 17.0)
  @objc public var directoryEntryCount: Int? {
    get {
      wrappedInstance.directoryEntryCount
    }
  }

  @available(macOS, introduced: 11.0)
  @available(watchOS, introduced: 7.0)
  @available(iOS, introduced: 14.0)
  @available(tvOS, introduced: 14.0)
  @objc public var mayShareFileContent: Bool? {
    get {
      wrappedInstance.mayShareFileContent
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeIsAutomounted: Bool? {
    get {
      wrappedInstance.volumeIsAutomounted
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeLocalizedName: String? {
    get {
      wrappedInstance.volumeLocalizedName
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeResourceCount: Int? {
    get {
      wrappedInstance.volumeResourceCount
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeTotalCapacity: Int? {
    get {
      wrappedInstance.volumeTotalCapacity
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var addedToDirectoryDate: DateWrapper? {
    get {
      wrappedInstance.addedToDirectoryDate == nil ? nil : DateWrapper(wrappedInstance.addedToDirectoryDate!)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isExcludedFromBackup: Bool? {
    get {
      wrappedInstance.isExcludedFromBackup
    }
    set {
      wrappedInstance.isExcludedFromBackup = newValue
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var preferredIOBlockSize: Int? {
    get {
      wrappedInstance.preferredIOBlockSize
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeMaximumFileSize: Int? {
    get {
      wrappedInstance.volumeMaximumFileSize
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var totalFileAllocatedSize: Int? {
    get {
      wrappedInstance.totalFileAllocatedSize
    }
  }

  @available(macOS, introduced: 10.13)
  @available(watchOS, unavailable, introduced: 2.0)
  @available(iOS, introduced: 11.0)
  @available(tvOS, unavailable, introduced: 9.0)
  @objc public var ubiquitousItemIsShared: Bool? {
    get {
      wrappedInstance.ubiquitousItemIsShared
    }
  }

  @available(macOS, introduced: 10.12)
  @available(watchOS, introduced: 3.0)
  @available(iOS, introduced: 10.0)
  @available(tvOS, introduced: 10.0)
  @objc public var volumeIsRootFileSystem: Bool? {
    get {
      wrappedInstance.volumeIsRootFileSystem
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeSupportsRenaming: Bool? {
    get {
      wrappedInstance.volumeSupportsRenaming
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeSupportsZeroRuns: Bool? {
    get {
      wrappedInstance.volumeSupportsZeroRuns
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeURLForRemounting: URLWrapper? {
    get {
      wrappedInstance.volumeURLForRemounting == nil ? nil : URLWrapper(wrappedInstance.volumeURLForRemounting!)
    }
  }

  @available(macOS, introduced: 10.11)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var applicationIsScriptable: Bool? {
    get {
      wrappedInstance.applicationIsScriptable
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var contentModificationDate: DateWrapper? {
    get {
      wrappedInstance.contentModificationDate == nil ? nil : DateWrapper(wrappedInstance.contentModificationDate!)
    }
    set {
      wrappedInstance.contentModificationDate = newValue?.wrappedInstance
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeAvailableCapacity: Int? {
    get {
      wrappedInstance.volumeAvailableCapacity
    }
  }

  @available(macOS, introduced: 13.3)
  @available(watchOS, introduced: 9.4)
  @available(iOS, introduced: 16.4)
  @available(tvOS, introduced: 16.4)
  @objc public var volumeMountFromLocation: String? {
    get {
      wrappedInstance.volumeMountFromLocation
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeSupportsHardLinks: Bool? {
    get {
      wrappedInstance.volumeSupportsHardLinks
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var localizedTypeDescription: String? {
    get {
      wrappedInstance.localizedTypeDescription
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var ubiquitousItemIsUploaded: Bool? {
    get {
      wrappedInstance.ubiquitousItemIsUploaded
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeSupportsJournaling: Bool? {
    get {
      wrappedInstance.volumeSupportsJournaling
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var attributeModificationDate: DateWrapper? {
    get {
      wrappedInstance.attributeModificationDate == nil ? nil : DateWrapper(wrappedInstance.attributeModificationDate!)
    }
  }

  @available(macOS, introduced: 11.0)
  @available(watchOS, introduced: 7.0)
  @available(iOS, introduced: 14.0)
  @available(tvOS, introduced: 14.0)
  @objc public var mayHaveExtendedAttributes: Bool? {
    get {
      wrappedInstance.mayHaveExtendedAttributes
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var ubiquitousItemIsUploading: Bool? {
    get {
      wrappedInstance.ubiquitousItemIsUploading
    }
  }

  @available(macOS, introduced: 10.12)
  @available(watchOS, introduced: 3.0)
  @available(iOS, introduced: 10.0)
  @available(tvOS, introduced: 10.0)
  @objc public var volumeSupportsCompression: Bool? {
    get {
      wrappedInstance.volumeSupportsCompression
    }
  }

  @available(macOS, introduced: 10.12)
  @available(watchOS, introduced: 3.0)
  @available(iOS, introduced: 10.0)
  @available(tvOS, introduced: 10.0)
  @objc public var volumeSupportsFileCloning: Bool? {
    get {
      wrappedInstance.volumeSupportsFileCloning
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeSupportsSparseFiles: Bool? {
    get {
      wrappedInstance.volumeSupportsSparseFiles
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeSupportsVolumeSizes: Bool? {
    get {
      wrappedInstance.volumeSupportsVolumeSizes
    }
  }

  @available(macOS, introduced: 10.12)
  @available(watchOS, introduced: 3.0)
  @available(iOS, introduced: 10.0)
  @available(tvOS, introduced: 10.0)
  @objc public var volumeSupportsSwapRenaming: Bool? {
    get {
      wrappedInstance.volumeSupportsSwapRenaming
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var ubiquitousItemIsDownloading: Bool? {
    get {
      wrappedInstance.ubiquitousItemIsDownloading
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeSupportsPersistentIDs: Bool? {
    get {
      wrappedInstance.volumeSupportsPersistentIDs
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeSupportsSymbolicLinks: Bool? {
    get {
      wrappedInstance.volumeSupportsSymbolicLinks
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var ubiquitousItemUploadingError: NSErrorWrapper? {
    get {
      wrappedInstance.ubiquitousItemUploadingError == nil ? nil : NSErrorWrapper(wrappedInstance.ubiquitousItemUploadingError!)
    }
  }

  @available(macOS, introduced: 10.13)
  @available(watchOS, introduced: 4.0)
  @available(iOS, introduced: 11.0)
  @available(tvOS, introduced: 11.0)
  @objc public var volumeSupportsImmutableFiles: Bool? {
    get {
      wrappedInstance.volumeSupportsImmutableFiles
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var ubiquitousItemDownloadingError: NSErrorWrapper? {
    get {
      wrappedInstance.ubiquitousItemDownloadingError == nil ? nil : NSErrorWrapper(wrappedInstance.ubiquitousItemDownloadingError!)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeSupportsExtendedSecurity: Bool? {
    get {
      wrappedInstance.volumeSupportsExtendedSecurity
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var ubiquitousItemDownloadRequested: Bool? {
    get {
      wrappedInstance.ubiquitousItemDownloadRequested
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var ubiquitousItemDownloadingStatus: URLUbiquitousItemDownloadingStatusWrapper? {
    get {
      wrappedInstance.ubiquitousItemDownloadingStatus == nil ? nil : URLUbiquitousItemDownloadingStatusWrapper(wrappedInstance.ubiquitousItemDownloadingStatus!)
    }
  }

  @available(macOS, introduced: 10.13)
  @available(watchOS, introduced: 4.0)
  @available(iOS, introduced: 11.0)
  @available(tvOS, introduced: 11.0)
  @objc public var volumeSupportsAccessPermissions: Bool? {
    get {
      wrappedInstance.volumeSupportsAccessPermissions
    }
  }

  @available(macOS, introduced: 10.12)
  @available(watchOS, introduced: 3.0)
  @available(iOS, introduced: 10.0)
  @available(tvOS, introduced: 10.0)
  @objc public var volumeSupportsExclusiveRenaming: Bool? {
    get {
      wrappedInstance.volumeSupportsExclusiveRenaming
    }
  }

  @available(macOS, introduced: 11.3)
  @available(watchOS, introduced: 7.4)
  @available(iOS, introduced: 14.5)
  @available(tvOS, introduced: 14.5)
  @objc public var ubiquitousItemIsExcludedFromSync: Bool? {
    get {
      wrappedInstance.ubiquitousItemIsExcludedFromSync
    }
    set {
      wrappedInstance.ubiquitousItemIsExcludedFromSync = newValue
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeLocalizedFormatDescription: String? {
    get {
      wrappedInstance.volumeLocalizedFormatDescription
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeSupportsCasePreservedNames: Bool? {
    get {
      wrappedInstance.volumeSupportsCasePreservedNames
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeSupportsCaseSensitiveNames: Bool? {
    get {
      wrappedInstance.volumeSupportsCaseSensitiveNames
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeSupportsRootDirectoryDates: Bool? {
    get {
      wrappedInstance.volumeSupportsRootDirectoryDates
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volumeSupportsAdvisoryFileLocking: Bool? {
    get {
      wrappedInstance.volumeSupportsAdvisoryFileLocking
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var ubiquitousItemContainerDisplayName: String? {
    get {
      wrappedInstance.ubiquitousItemContainerDisplayName
    }
  }

  @available(macOS, introduced: 10.13)
  @available(watchOS, unavailable, introduced: 2.0)
  @available(iOS, introduced: 11.0)
  @available(tvOS, unavailable, introduced: 9.0)
  @objc public var ubiquitousSharedItemCurrentUserRole: URLUbiquitousSharedItemRoleWrapper? {
    get {
      wrappedInstance.ubiquitousSharedItemCurrentUserRole == nil ? nil : URLUbiquitousSharedItemRoleWrapper(wrappedInstance.ubiquitousSharedItemCurrentUserRole!)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var ubiquitousItemHasUnresolvedConflicts: Bool? {
    get {
      wrappedInstance.ubiquitousItemHasUnresolvedConflicts
    }
  }

  @available(macOS, introduced: 10.13)
  @available(watchOS, unavailable, introduced: 2.0)
  @available(iOS, introduced: 11.0)
  @available(tvOS, unavailable, introduced: 9.0)
  @objc public var ubiquitousSharedItemOwnerNameComponents: PersonNameComponentsWrapper? {
    get {
      wrappedInstance.ubiquitousSharedItemOwnerNameComponents == nil ? nil : PersonNameComponentsWrapper(wrappedInstance.ubiquitousSharedItemOwnerNameComponents!)
    }
  }

  @available(macOS, introduced: 10.13)
  @available(watchOS, unavailable, introduced: 2.0)
  @available(iOS, introduced: 11.0)
  @available(tvOS, unavailable, introduced: 9.0)
  @objc public var ubiquitousSharedItemCurrentUserPermissions: URLUbiquitousSharedItemPermissionsWrapper? {
    get {
      wrappedInstance.ubiquitousSharedItemCurrentUserPermissions == nil ? nil : URLUbiquitousSharedItemPermissionsWrapper(wrappedInstance.ubiquitousSharedItemCurrentUserPermissions!)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var name: String? {
    get {
      wrappedInstance.name
    }
    set {
      wrappedInstance.name = newValue
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var path: String? {
    get {
      wrappedInstance.path
    }
  }

  @available(macOS, introduced: 10.13)
  @available(watchOS, unavailable, introduced: 2.0)
  @available(iOS, introduced: 11.0)
  @available(tvOS, unavailable, introduced: 9.0)
  @objc public var ubiquitousSharedItemMostRecentEditorNameComponents: PersonNameComponentsWrapper? {
    get {
      wrappedInstance.ubiquitousSharedItemMostRecentEditorNameComponents == nil ? nil : PersonNameComponentsWrapper(wrappedInstance.ubiquitousSharedItemMostRecentEditorNameComponents!)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var volume: URLWrapper? {
    get {
      wrappedInstance.volume == nil ? nil : URLWrapper(wrappedInstance.volume!)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var fileSize: Int? {
    get {
      wrappedInstance.fileSize
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isHidden: Bool? {
    get {
      wrappedInstance.isHidden
    }
    set {
      wrappedInstance.isHidden = newValue
    }
  }

  @available(macOS, introduced: 11.0)
  @available(watchOS, introduced: 7.0)
  @available(iOS, introduced: 14.0)
  @available(tvOS, introduced: 14.0)
  @objc public var isSparse: Bool? {
    get {
      wrappedInstance.isSparse
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isVolume: Bool? {
    get {
      wrappedInstance.isVolume
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isPackage: Bool? {
    get {
      wrappedInstance.isPackage
    }
    set {
      wrappedInstance.isPackage = newValue
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var linkCount: Int? {
    get {
      wrappedInstance.linkCount
    }
  }

  init(_ wrappedInstance: URLResourceValues) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc override init() {
    wrappedInstance = URLResourceValues()
  }

}

@available(macOS, introduced: 12)
@available(watchOS, introduced: 8)
@available(iOS, introduced: 15)
@available(tvOS, introduced: 15)
@objc public class AttributeContainerWrapper: NSObject {
  var wrappedInstance: AttributeContainer

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: AttributeContainer) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc override init() {
    wrappedInstance = AttributeContainer()
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public class BuilderWrapper: NSObject {
    var wrappedInstance: AttributeContainer.Builder

    init(_ wrappedInstance: AttributeContainer.Builder) {
      self.wrappedInstance = wrappedInstance
    }

  }

}

@available(macOS, introduced: 12)
@available(watchOS, introduced: 8)
@available(iOS, introduced: 15)
@available(tvOS, introduced: 15)
@objc public class AttributedSubstringWrapper: NSObject {
  var wrappedInstance: AttributedSubstring

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public var characters: AttributedStringWrapper.CharacterViewWrapper {
    get {
      CharacterViewWrapper(wrappedInstance.characters)
    }
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public var startIndex: AttributedStringWrapper.IndexWrapper {
    get {
      IndexWrapper(wrappedInstance.startIndex)
    }
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public var unicodeScalars: AttributedStringWrapper.UnicodeScalarViewWrapper {
    get {
      UnicodeScalarViewWrapper(wrappedInstance.unicodeScalars)
    }
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public var base: AttributedStringWrapper {
    get {
      AttributedStringWrapper(wrappedInstance.base)
    }
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public var runs: AttributedStringWrapper.RunsWrapper {
    get {
      RunsWrapper(wrappedInstance.runs)
    }
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public var endIndex: AttributedStringWrapper.IndexWrapper {
    get {
      IndexWrapper(wrappedInstance.endIndex)
    }
  }

  init(_ wrappedInstance: AttributedSubstring) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc override init() {
    wrappedInstance = AttributedSubstring()
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func setAttributes(_ attributes: AttributeContainerWrapper) {
    return wrappedInstance.setAttributes(attributes.wrappedInstance)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func replaceAttributes(_ attributes: AttributeContainerWrapper, with others: AttributeContainerWrapper) {
    return wrappedInstance.replaceAttributes(attributes.wrappedInstance, with: others.wrappedInstance)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func settingAttributes(_ attributes: AttributeContainerWrapper) -> AttributedStringWrapper {
    let result = wrappedInstance.settingAttributes(attributes.wrappedInstance)
    return AttributedStringWrapper(result)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func replacingAttributes(_ attributes: AttributeContainerWrapper, with others: AttributeContainerWrapper) -> AttributedStringWrapper {
    let result = wrappedInstance.replacingAttributes(attributes.wrappedInstance, with: others.wrappedInstance)
    return AttributedStringWrapper(result)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func index(afterCharacter i: AttributedStringWrapper.IndexWrapper) -> AttributedStringWrapper.IndexWrapper {
    let result = wrappedInstance.index(afterCharacter: i.wrappedInstance)
    return IndexWrapper(result)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func index(beforeCharacter i: AttributedStringWrapper.IndexWrapper) -> AttributedStringWrapper.IndexWrapper {
    let result = wrappedInstance.index(beforeCharacter: i.wrappedInstance)
    return IndexWrapper(result)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func index(afterUnicodeScalar i: AttributedStringWrapper.IndexWrapper) -> AttributedStringWrapper.IndexWrapper {
    let result = wrappedInstance.index(afterUnicodeScalar: i.wrappedInstance)
    return IndexWrapper(result)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func index(beforeUnicodeScalar i: AttributedStringWrapper.IndexWrapper) -> AttributedStringWrapper.IndexWrapper {
    let result = wrappedInstance.index(beforeUnicodeScalar: i.wrappedInstance)
    return IndexWrapper(result)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func index(afterRun i: AttributedStringWrapper.IndexWrapper) -> AttributedStringWrapper.IndexWrapper {
    let result = wrappedInstance.index(afterRun: i.wrappedInstance)
    return IndexWrapper(result)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func index(beforeRun i: AttributedStringWrapper.IndexWrapper) -> AttributedStringWrapper.IndexWrapper {
    let result = wrappedInstance.index(beforeRun: i.wrappedInstance)
    return IndexWrapper(result)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func index(_ i: AttributedStringWrapper.IndexWrapper, offsetByRuns distance: Int) -> AttributedStringWrapper.IndexWrapper {
    let result = wrappedInstance.index(i.wrappedInstance, offsetByRuns: distance)
    return IndexWrapper(result)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func index(_ i: AttributedStringWrapper.IndexWrapper, offsetByCharacters distance: Int) -> AttributedStringWrapper.IndexWrapper {
    let result = wrappedInstance.index(i.wrappedInstance, offsetByCharacters: distance)
    return IndexWrapper(result)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func index(_ i: AttributedStringWrapper.IndexWrapper, offsetByUnicodeScalars distance: Int) -> AttributedStringWrapper.IndexWrapper {
    let result = wrappedInstance.index(i.wrappedInstance, offsetByUnicodeScalars: distance)
    return IndexWrapper(result)
  }

}

@available(macOS, introduced: 10.11)
@available(watchOS, introduced: 2.0)
@available(iOS, introduced: 9.0)
@available(tvOS, introduced: 9.0)
@objc public class PersonNameComponentsWrapper: NSObject {
  var wrappedInstance: PersonNameComponents

  @available(macOS, introduced: 10.11)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 9.0)
  @available(tvOS, introduced: 9.0)
  @objc public var givenName: String? {
    get {
      wrappedInstance.givenName
    }
    set {
      wrappedInstance.givenName = newValue
    }
  }

  @available(macOS, introduced: 10.11)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 9.0)
  @available(tvOS, introduced: 9.0)
  @objc public var familyName: String? {
    get {
      wrappedInstance.familyName
    }
    set {
      wrappedInstance.familyName = newValue
    }
  }

  @available(macOS, introduced: 10.11)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 9.0)
  @available(tvOS, introduced: 9.0)
  @objc public var middleName: String? {
    get {
      wrappedInstance.middleName
    }
    set {
      wrappedInstance.middleName = newValue
    }
  }

  @available(macOS, introduced: 10.11)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 9.0)
  @available(tvOS, introduced: 9.0)
  @objc public var namePrefix: String? {
    get {
      wrappedInstance.namePrefix
    }
    set {
      wrappedInstance.namePrefix = newValue
    }
  }

  @available(macOS, introduced: 10.11)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 9.0)
  @available(tvOS, introduced: 9.0)
  @objc public var nameSuffix: String? {
    get {
      wrappedInstance.nameSuffix
    }
    set {
      wrappedInstance.nameSuffix = newValue
    }
  }

  @available(macOS, introduced: 10.11)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 9.0)
  @available(tvOS, introduced: 9.0)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  @available(macOS, introduced: 10.11)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 9.0)
  @available(tvOS, introduced: 9.0)
  @objc public var debugDescription: String {
    get {
      wrappedInstance.debugDescription
    }
  }

  @available(macOS, introduced: 10.11)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 9.0)
  @available(tvOS, introduced: 9.0)
  @objc public var phoneticRepresentation: PersonNameComponentsWrapper? {
    get {
      wrappedInstance.phoneticRepresentation == nil ? nil : PersonNameComponentsWrapper(wrappedInstance.phoneticRepresentation!)
    }
    set {
      wrappedInstance.phoneticRepresentation = newValue?.wrappedInstance
    }
  }

  @available(macOS, introduced: 10.11)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 9.0)
  @available(tvOS, introduced: 9.0)
  @objc public var nickname: String? {
    get {
      wrappedInstance.nickname
    }
    set {
      wrappedInstance.nickname = newValue
    }
  }

  init(_ wrappedInstance: PersonNameComponents) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.11)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 9.0)
  @available(tvOS, introduced: 9.0)
  @objc override init() {
    wrappedInstance = PersonNameComponents()
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc init(_ value: String) throws {
    wrappedInstance = try PersonNameComponents(value)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func formatted() -> String {
    return wrappedInstance.formatted()
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class FormatStyleWrapper: NSObject {
    var wrappedInstance: PersonNameComponents.FormatStyle

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var attributed: PersonNameComponentsWrapper.AttributedStyleWrapper {
      get {
        AttributedStyleWrapper(wrappedInstance.attributed)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var parseStrategy: PersonNameComponentsWrapper.ParseStrategyWrapper {
      get {
        ParseStrategyWrapper(wrappedInstance.parseStrategy)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var locale: LocaleWrapper {
      get {
        LocaleWrapper(wrappedInstance.locale)
      }
      set {
        wrappedInstance.locale = newValue.wrappedInstance
      }
    }

    init(_ wrappedInstance: PersonNameComponents.FormatStyle) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func format(_ value: PersonNameComponentsWrapper) -> String {
      return wrappedInstance.format(value.wrappedInstance)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func locale(_ locale: LocaleWrapper) -> PersonNameComponentsWrapper.FormatStyleWrapper {
      let result = wrappedInstance.locale(locale.wrappedInstance)
      return FormatStyleWrapper(result)
    }

  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class ParseStrategyWrapper: NSObject {
    var wrappedInstance: PersonNameComponents.ParseStrategy

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var name: PersonNameComponentsWrapper.ParseStrategyWrapper {
      get {
        ParseStrategyWrapper(PersonNameComponents.ParseStrategy.name)
      }
    }

    init(_ wrappedInstance: PersonNameComponents.ParseStrategy) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc override init() {
      wrappedInstance = PersonNameComponents.ParseStrategy()
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func parse(_ value: String) throws -> PersonNameComponentsWrapper {
      let result = try wrappedInstance.parse(value)
      return PersonNameComponentsWrapper(result)
    }

  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class AttributedStyleWrapper: NSObject {
    var wrappedInstance: PersonNameComponents.AttributedStyle

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var locale: LocaleWrapper {
      get {
        LocaleWrapper(wrappedInstance.locale)
      }
      set {
        wrappedInstance.locale = newValue.wrappedInstance
      }
    }

    init(_ wrappedInstance: PersonNameComponents.AttributedStyle) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func format(_ value: PersonNameComponentsWrapper) -> AttributedStringWrapper {
      let result = wrappedInstance.format(value.wrappedInstance)
      return AttributedStringWrapper(result)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func locale(_ locale: LocaleWrapper) -> PersonNameComponentsWrapper.AttributedStyleWrapper {
      let result = wrappedInstance.locale(locale.wrappedInstance)
      return AttributedStyleWrapper(result)
    }

  }

}

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class AsyncCharacterSequenceWrapper: NSObject {
  var wrappedInstance: AsyncCharacterSequence

  init(_ wrappedInstance: AsyncCharacterSequence) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func makeAsyncIterator() -> AsyncCharacterSequenceWrapper {
    let result = wrappedInstance.makeAsyncIterator()
    return AsyncCharacterSequenceWrapper(result)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class AsyncIteratorWrapper: NSObject {
    var wrappedInstance: AsyncCharacterSequence.AsyncIterator

    init(_ wrappedInstance: AsyncCharacterSequence.AsyncIterator) {
      self.wrappedInstance = wrappedInstance
    }

  }

}

@available(macOS, introduced: 13)
@available(watchOS, introduced: 9)
@available(iOS, introduced: 16)
@available(tvOS, introduced: 16)
@objc public class LocalizedStringResourceWrapper: NSObject {
  var wrappedInstance: LocalizedStringResource

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public var localizedStringResource: LocalizedStringResourceWrapper {
    get {
      LocalizedStringResourceWrapper(wrappedInstance.localizedStringResource)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public var key: String {
    get {
      wrappedInstance.key
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public var table: String? {
    get {
      wrappedInstance.table
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public var locale: LocaleWrapper {
    get {
      LocaleWrapper(wrappedInstance.locale)
    }
    set {
      wrappedInstance.locale = newValue.wrappedInstance
    }
  }

  init(_ wrappedInstance: LocalizedStringResource) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init(stringLiteral value: String) {
    wrappedInstance = LocalizedStringResource(stringLiteral: value)
  }

}

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class AsyncUnicodeScalarSequenceWrapper: NSObject {
  var wrappedInstance: AsyncUnicodeScalarSequence

  init(_ wrappedInstance: AsyncUnicodeScalarSequence) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func makeAsyncIterator() -> AsyncUnicodeScalarSequenceWrapper {
    let result = wrappedInstance.makeAsyncIterator()
    return AsyncUnicodeScalarSequenceWrapper(result)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class AsyncIteratorWrapper: NSObject {
    var wrappedInstance: AsyncUnicodeScalarSequence.AsyncIterator

    init(_ wrappedInstance: AsyncUnicodeScalarSequence.AsyncIterator) {
      self.wrappedInstance = wrappedInstance
    }

  }

}

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class FormatStyleCapitalizationContextWrapper: NSObject {
  var wrappedInstance: FormatStyleCapitalizationContext

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var standalone: FormatStyleCapitalizationContextWrapper {
    get {
      FormatStyleCapitalizationContextWrapper(FormatStyleCapitalizationContext.standalone)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var middleOfSentence: FormatStyleCapitalizationContextWrapper {
    get {
      FormatStyleCapitalizationContextWrapper(FormatStyleCapitalizationContext.middleOfSentence)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var beginningOfSentence: FormatStyleCapitalizationContextWrapper {
    get {
      FormatStyleCapitalizationContextWrapper(FormatStyleCapitalizationContext.beginningOfSentence)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var unknown: FormatStyleCapitalizationContextWrapper {
    get {
      FormatStyleCapitalizationContextWrapper(FormatStyleCapitalizationContext.unknown)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var listItem: FormatStyleCapitalizationContextWrapper {
    get {
      FormatStyleCapitalizationContextWrapper(FormatStyleCapitalizationContext.listItem)
    }
  }

  init(_ wrappedInstance: FormatStyleCapitalizationContext) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 12)
@available(watchOS, introduced: 8)
@available(iOS, introduced: 15)
@available(tvOS, introduced: 15)
@objc public class AttributeScopeCodableConfigurationWrapper: NSObject {
  var wrappedInstance: AttributeScopeCodableConfiguration

  init(_ wrappedInstance: AttributeScopeCodableConfiguration) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 10.10)
@available(watchOS, introduced: 2.0)
@available(iOS, introduced: 8.0)
@available(tvOS, introduced: 9.0)
@objc public class URLWrapper: NSObject {
  var wrappedInstance: URL

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var standardizedFileURL: URLWrapper {
    get {
      URLWrapper(wrappedInstance.standardizedFileURL)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var baseURL: URLWrapper? {
    get {
      wrappedInstance.baseURL == nil ? nil : URLWrapper(wrappedInstance.baseURL!)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isFileURL: Bool {
    get {
      wrappedInstance.isFileURL
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var absoluteURL: URLWrapper {
    get {
      URLWrapper(wrappedInstance.absoluteURL)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var relativePath: String {
    get {
      wrappedInstance.relativePath
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var standardized: URLWrapper {
    get {
      URLWrapper(wrappedInstance.standardized)
    }
  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc static public var homeDirectory: URLWrapper {
    get {
      URLWrapper(URL.homeDirectory)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var pathExtension: String {
    get {
      wrappedInstance.pathExtension
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var resourceBytes: URLWrapper.AsyncBytesWrapper {
    get {
      AsyncBytesWrapper(wrappedInstance.resourceBytes)
    }
  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc static public var userDirectory: URLWrapper {
    get {
      URLWrapper(URL.userDirectory)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var absoluteString: String {
    get {
      wrappedInstance.absoluteString
    }
  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc static public var musicDirectory: URLWrapper {
    get {
      URLWrapper(URL.musicDirectory)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var relativeString: String {
    get {
      wrappedInstance.relativeString
    }
  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, unavailable)
  @available(iOS, introduced: 16.0)
  @available(tvOS, unavailable)
  @objc static public var trashDirectory: URLWrapper {
    get {
      URLWrapper(URL.trashDirectory)
    }
  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc static public var cachesDirectory: URLWrapper {
    get {
      URLWrapper(URL.cachesDirectory)
    }
  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc static public var moviesDirectory: URLWrapper {
    get {
      URLWrapper(URL.moviesDirectory)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var debugDescription: String {
    get {
      wrappedInstance.debugDescription
    }
  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc static public var desktopDirectory: URLWrapper {
    get {
      URLWrapper(URL.desktopDirectory)
    }
  }

  @available(macOS, introduced: 10.11)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 9.0)
  @available(tvOS, introduced: 9.0)
  @objc public var hasDirectoryPath: Bool {
    get {
      wrappedInstance.hasDirectoryPath
    }
  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc static public var libraryDirectory: URLWrapper {
    get {
      URLWrapper(URL.libraryDirectory)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var lastPathComponent: String {
    get {
      wrappedInstance.lastPathComponent
    }
  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc static public var picturesDirectory: URLWrapper {
    get {
      URLWrapper(URL.picturesDirectory)
    }
  }

  @available(macOS, introduced: 10.11)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 9.0)
  @available(tvOS, introduced: 9.0)
  @objc public var dataRepresentation: DataWrapper {
    get {
      DataWrapper(wrappedInstance.dataRepresentation)
    }
  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc static public var documentsDirectory: URLWrapper {
    get {
      URLWrapper(URL.documentsDirectory)
    }
  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc static public var downloadsDirectory: URLWrapper {
    get {
      URLWrapper(URL.downloadsDirectory)
    }
  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc static public var temporaryDirectory: URLWrapper {
    get {
      URLWrapper(URL.temporaryDirectory)
    }
  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc static public var applicationDirectory: URLWrapper {
    get {
      URLWrapper(URL.applicationDirectory)
    }
  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc static public var sharedPublicDirectory: URLWrapper {
    get {
      URLWrapper(URL.sharedPublicDirectory)
    }
  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc static public var applicationSupportDirectory: URLWrapper {
    get {
      URLWrapper(URL.applicationSupportDirectory)
    }
  }

  @available(macOS, introduced: 10.10, deprecated: 100000.0)
  @available(watchOS, introduced: 2.0, deprecated: 100000.0)
  @available(iOS, introduced: 8.0, deprecated: 100000.0)
  @available(visionOS, introduced: 1.0, deprecated: 100000.0)
  @available(tvOS, introduced: 9.0, deprecated: 100000.0)
  @objc public var host: String? {
    get {
      wrappedInstance.host
    }
  }

  @available(macOS, introduced: 10.10, deprecated: 100000.0)
  @available(watchOS, introduced: 2.0, deprecated: 100000.0)
  @available(iOS, introduced: 8.0, deprecated: 100000.0)
  @available(visionOS, introduced: 1.0, deprecated: 100000.0)
  @available(tvOS, introduced: 9.0, deprecated: 100000.0)
  @objc public var path: String {
    get {
      wrappedInstance.path
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var port: Int? {
    get {
      wrappedInstance.port
    }
  }

  @available(macOS, introduced: 10.10, deprecated: 100000.0)
  @available(watchOS, introduced: 2.0, deprecated: 100000.0)
  @available(iOS, introduced: 8.0, deprecated: 100000.0)
  @available(visionOS, introduced: 1.0, deprecated: 100000.0)
  @available(tvOS, introduced: 9.0, deprecated: 100000.0)
  @objc public var user: String? {
    get {
      wrappedInstance.user
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var lines: AsyncLineSequenceWrapper {
    get {
      AsyncLineSequenceWrapper(wrappedInstance.lines)
    }
  }

  @available(macOS, introduced: 10.10, deprecated: 100000.0)
  @available(watchOS, introduced: 2.0, deprecated: 100000.0)
  @available(iOS, introduced: 8.0, deprecated: 100000.0)
  @available(visionOS, introduced: 1.0, deprecated: 100000.0)
  @available(tvOS, introduced: 9.0, deprecated: 100000.0)
  @objc public var query: String? {
    get {
      wrappedInstance.query
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var scheme: String? {
    get {
      wrappedInstance.scheme
    }
  }

  @available(macOS, introduced: 10.10, deprecated: 100000.0)
  @available(watchOS, introduced: 2.0, deprecated: 100000.0)
  @available(iOS, introduced: 8.0, deprecated: 100000.0)
  @available(visionOS, introduced: 1.0, deprecated: 100000.0)
  @available(tvOS, introduced: 9.0, deprecated: 100000.0)
  @objc public var fragment: String? {
    get {
      wrappedInstance.fragment
    }
  }

  @available(macOS, introduced: 10.10, deprecated: 100000.0)
  @available(watchOS, introduced: 2.0, deprecated: 100000.0)
  @available(iOS, introduced: 8.0, deprecated: 100000.0)
  @available(visionOS, introduced: 1.0, deprecated: 100000.0)
  @available(tvOS, introduced: 9.0, deprecated: 100000.0)
  @objc public var password: String? {
    get {
      wrappedInstance.password
    }
  }

  init(_ wrappedInstance: URL) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.10, deprecated: 100000.0)
  @available(watchOS, introduced: 2.0, deprecated: 100000.0)
  @available(iOS, introduced: 8.0, deprecated: 100000.0)
  @available(visionOS, introduced: 1.0, deprecated: 100000.0)
  @available(tvOS, introduced: 9.0, deprecated: 100000.0)
  @objc init(fileURLWithPath path: String, relativeTo base: URLWrapper?) {
    wrappedInstance = URL(fileURLWithPath: path, relativeTo: base?.wrappedInstance)
  }

  @available(macOS, introduced: 10.10, deprecated: 100000.0)
  @available(watchOS, introduced: 2.0, deprecated: 100000.0)
  @available(iOS, introduced: 8.0, deprecated: 100000.0)
  @available(visionOS, introduced: 1.0, deprecated: 100000.0)
  @available(tvOS, introduced: 9.0, deprecated: 100000.0)
  @objc init(fileURLWithPath path: String, isDirectory: Bool, relativeTo base: URLWrapper?) {
    wrappedInstance = URL(fileURLWithPath: path, isDirectory: isDirectory, relativeTo: base?.wrappedInstance)
  }

  @available(macOS, introduced: 10.10, deprecated: 100000.0)
  @available(watchOS, introduced: 2.0, deprecated: 100000.0)
  @available(iOS, introduced: 8.0, deprecated: 100000.0)
  @available(visionOS, introduced: 1.0, deprecated: 100000.0)
  @available(tvOS, introduced: 9.0, deprecated: 100000.0)
  @objc init(fileURLWithPath path: String, isDirectory: Bool) {
    wrappedInstance = URL(fileURLWithPath: path, isDirectory: isDirectory)
  }

  @available(macOS, introduced: 10.10, deprecated: 100000.0)
  @available(watchOS, introduced: 2.0, deprecated: 100000.0)
  @available(iOS, introduced: 8.0, deprecated: 100000.0)
  @available(visionOS, introduced: 1.0, deprecated: 100000.0)
  @available(tvOS, introduced: 9.0, deprecated: 100000.0)
  @objc init(fileURLWithPath path: String) {
    wrappedInstance = URL(fileURLWithPath: path)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc init(fileReferenceLiteralResourceName name: String) {
    wrappedInstance = URL(fileReferenceLiteralResourceName: name)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc init?(string: String, relativeTo url: URLWrapper?) {
    if let instance = URL(string: string, relativeTo: url?.wrappedInstance) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @available(macOS, introduced: 14.0)
  @available(watchOS, introduced: 10.0)
  @available(iOS, introduced: 17.0)
  @available(tvOS, introduced: 17.0)
  @objc init?(string: String, encodingInvalidCharacters: Bool) {
    if let instance = URL(string: string, encodingInvalidCharacters: encodingInvalidCharacters) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc init?(string: String) {
    if let instance = URL(string: string) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init?(resource: URLResourceWrapper) {
    if let instance = URL(resource: resource.wrappedInstance) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func standardize() {
    return wrappedInstance.standardize()
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public func bookmarkData(withContentsOf url: URLWrapper) throws -> DataWrapper {
    let result = try URL.bookmarkData(withContentsOf: url.wrappedInstance)
    return DataWrapper(result)
  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc static public func homeDirectory(forUser user: String) -> URLWrapper? {
    let result = URL.homeDirectory(forUser: user)
    return result == nil ? nil : URLWrapper(result!)
  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc static public func currentDirectory() -> URLWrapper {
    let result = URL.currentDirectory()
    return URLWrapper(result)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func setResourceValues(_ values: URLResourceValuesWrapper) throws {
    return try wrappedInstance.setResourceValues(values.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public func writeBookmarkData(_ data: DataWrapper, to url: URLWrapper) throws {
    return try URL.writeBookmarkData(data.wrappedInstance, to: url.wrappedInstance)
  }

  @available(macOS, introduced: 10.10, deprecated: 100000.0)
  @available(watchOS, introduced: 2.0, deprecated: 100000.0)
  @available(iOS, introduced: 8.0, deprecated: 100000.0)
  @available(visionOS, introduced: 1.0, deprecated: 100000.0)
  @available(tvOS, introduced: 9.0, deprecated: 100000.0)
  @objc public func appendPathComponent(_ pathComponent: String, isDirectory: Bool) {
    return wrappedInstance.appendPathComponent(pathComponent, isDirectory: isDirectory)
  }

  @available(macOS, introduced: 10.10, deprecated: 100000.0)
  @available(watchOS, introduced: 2.0, deprecated: 100000.0)
  @available(iOS, introduced: 8.0, deprecated: 100000.0)
  @available(visionOS, introduced: 1.0, deprecated: 100000.0)
  @available(tvOS, introduced: 9.0, deprecated: 100000.0)
  @objc public func appendPathComponent(_ pathComponent: String) {
    return wrappedInstance.appendPathComponent(pathComponent)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func appendPathExtension(_ pathExtension: String) {
    return wrappedInstance.appendPathExtension(pathExtension)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func deletePathExtension() {
    return wrappedInstance.deletePathExtension()
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func deletingPathExtension() -> URLWrapper {
    let result = wrappedInstance.deletingPathExtension()
    return URLWrapper(result)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func resolveSymlinksInPath() {
    return wrappedInstance.resolveSymlinksInPath()
  }

  @available(macOS, introduced: 10.10, deprecated: 100000.0)
  @available(watchOS, introduced: 2.0, deprecated: 100000.0)
  @available(iOS, introduced: 8.0, deprecated: 100000.0)
  @available(visionOS, introduced: 1.0, deprecated: 100000.0)
  @available(tvOS, introduced: 9.0, deprecated: 100000.0)
  @objc public func appendingPathComponent(_ pathComponent: String, isDirectory: Bool) -> URLWrapper {
    let result = wrappedInstance.appendingPathComponent(pathComponent, isDirectory: isDirectory)
    return URLWrapper(result)
  }

  @available(macOS, introduced: 10.10, deprecated: 100000.0)
  @available(watchOS, introduced: 2.0, deprecated: 100000.0)
  @available(iOS, introduced: 8.0, deprecated: 100000.0)
  @available(visionOS, introduced: 1.0, deprecated: 100000.0)
  @available(tvOS, introduced: 9.0, deprecated: 100000.0)
  @objc public func appendingPathComponent(_ pathComponent: String) -> URLWrapper {
    let result = wrappedInstance.appendingPathComponent(pathComponent)
    return URLWrapper(result)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func appendingPathExtension(_ pathExtension: String) -> URLWrapper {
    let result = wrappedInstance.appendingPathExtension(pathExtension)
    return URLWrapper(result)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func deleteLastPathComponent() {
    return wrappedInstance.deleteLastPathComponent()
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func resolvingSymlinksInPath() -> URLWrapper {
    let result = wrappedInstance.resolvingSymlinksInPath()
    return URLWrapper(result)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func checkResourceIsReachable() throws -> BoolWrapper {
    let result = try wrappedInstance.checkResourceIsReachable()
    return BoolWrapper(result)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func deletingLastPathComponent() -> URLWrapper {
    let result = wrappedInstance.deletingLastPathComponent()
    return URLWrapper(result)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func removeCachedResourceValue(forKey key: URLResourceKeyWrapper) {
    return wrappedInstance.removeCachedResourceValue(forKey: key.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func checkPromisedItemIsReachable() throws -> BoolWrapper {
    let result = try wrappedInstance.checkPromisedItemIsReachable()
    return BoolWrapper(result)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func removeAllCachedResourceValues() {
    return wrappedInstance.removeAllCachedResourceValues()
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func stopAccessingSecurityScopedResource() {
    return wrappedInstance.stopAccessingSecurityScopedResource()
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func startAccessingSecurityScopedResource() -> Bool {
    return wrappedInstance.startAccessingSecurityScopedResource()
  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc public func formatted() -> String {
    return wrappedInstance.formatted()
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class AsyncBytesWrapper: NSObject {
    var wrappedInstance: URL.AsyncBytes

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var characters: AsyncCharacterSequenceWrapper {
      get {
        AsyncCharacterSequenceWrapper(wrappedInstance.characters)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var unicodeScalars: AsyncUnicodeScalarSequenceWrapper {
      get {
        AsyncUnicodeScalarSequenceWrapper(wrappedInstance.unicodeScalars)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var lines: AsyncLineSequenceWrapper {
      get {
        AsyncLineSequenceWrapper(wrappedInstance.lines)
      }
    }

    init(_ wrappedInstance: URL.AsyncBytes) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func makeAsyncIterator() -> AsyncBytesWrapper.AsyncIteratorWrapper {
      let result = wrappedInstance.makeAsyncIterator()
      return AsyncIteratorWrapper(result)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public class AsyncIteratorWrapper: NSObject {
      var wrappedInstance: AsyncBytes.AsyncIterator

      init(_ wrappedInstance: AsyncBytes.AsyncIterator) {
        self.wrappedInstance = wrappedInstance
      }

    }

  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc public class FormatStyleWrapper: NSObject {
    var wrappedInstance: URL.FormatStyle

    @available(macOS, introduced: 13.0)
    @available(watchOS, introduced: 9.0)
    @available(iOS, introduced: 16.0)
    @available(tvOS, introduced: 16.0)
    @objc static public var url: URLWrapper.FormatStyleWrapper {
      get {
        FormatStyleWrapper(URL.FormatStyle.url)
      }
    }

    @available(macOS, introduced: 13.0)
    @available(watchOS, introduced: 9.0)
    @available(iOS, introduced: 16.0)
    @available(tvOS, introduced: 16.0)
    @objc static public var url: URLWrapper.FormatStyleWrapper {
      get {
        FormatStyleWrapper(URL.FormatStyle.url)
      }
    }

    @available(macOS, introduced: 13.0)
    @available(watchOS, introduced: 9.0)
    @available(iOS, introduced: 16.0)
    @available(tvOS, introduced: 16.0)
    @objc public var parseStrategy: URLWrapper.ParseStrategyWrapper {
      get {
        ParseStrategyWrapper(wrappedInstance.parseStrategy)
      }
    }

    init(_ wrappedInstance: URL.FormatStyle) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 13.0)
    @available(watchOS, introduced: 9.0)
    @available(iOS, introduced: 16.0)
    @available(tvOS, introduced: 16.0)
    @objc public func format(_ value: URLWrapper) -> String {
      return wrappedInstance.format(value.wrappedInstance)
    }

    @available(macOS, introduced: 13.0)
    @available(watchOS, introduced: 9.0)
    @available(iOS, introduced: 16.0)
    @available(tvOS, introduced: 16.0)
    @objc public class HostDisplayOptionWrapper: NSObject {
      var wrappedInstance: FormatStyle.HostDisplayOption

      @available(macOS, introduced: 13.0)
      @available(watchOS, introduced: 9.0)
      @available(iOS, introduced: 16.0)
      @available(tvOS, introduced: 16.0)
      @objc public var description: String {
        get {
          wrappedInstance.description
        }
      }

      @available(macOS, introduced: 13.0)
      @available(watchOS, introduced: 9.0)
      @available(iOS, introduced: 16.0)
      @available(tvOS, introduced: 16.0)
      @objc static public var omitIfHTTPFamily: FormatStyleWrapper.HostDisplayOptionWrapper {
        get {
          HostDisplayOptionWrapper(FormatStyle.HostDisplayOption.omitIfHTTPFamily)
        }
      }

      @available(macOS, introduced: 13.0)
      @available(watchOS, introduced: 9.0)
      @available(iOS, introduced: 16.0)
      @available(tvOS, introduced: 16.0)
      @objc static public var never: FormatStyleWrapper.HostDisplayOptionWrapper {
        get {
          HostDisplayOptionWrapper(FormatStyle.HostDisplayOption.never)
        }
      }

      @available(macOS, introduced: 13.0)
      @available(watchOS, introduced: 9.0)
      @available(iOS, introduced: 16.0)
      @available(tvOS, introduced: 16.0)
      @objc static public var always: FormatStyleWrapper.HostDisplayOptionWrapper {
        get {
          HostDisplayOptionWrapper(FormatStyle.HostDisplayOption.always)
        }
      }

      init(_ wrappedInstance: FormatStyle.HostDisplayOption) {
        self.wrappedInstance = wrappedInstance
      }

    }

    @available(macOS, introduced: 13.0)
    @available(watchOS, introduced: 9.0)
    @available(iOS, introduced: 16.0)
    @available(tvOS, introduced: 16.0)
    @objc public class ComponentDisplayOptionWrapper: NSObject {
      var wrappedInstance: FormatStyle.ComponentDisplayOption

      @available(macOS, introduced: 13.0)
      @available(watchOS, introduced: 9.0)
      @available(iOS, introduced: 16.0)
      @available(tvOS, introduced: 16.0)
      @objc public var description: String {
        get {
          wrappedInstance.description
        }
      }

      @available(macOS, introduced: 13.0)
      @available(watchOS, introduced: 9.0)
      @available(iOS, introduced: 16.0)
      @available(tvOS, introduced: 16.0)
      @objc static public var omitIfHTTPFamily: FormatStyleWrapper.ComponentDisplayOptionWrapper {
        get {
          ComponentDisplayOptionWrapper(FormatStyle.ComponentDisplayOption.omitIfHTTPFamily)
        }
      }

      @available(macOS, introduced: 13.0)
      @available(watchOS, introduced: 9.0)
      @available(iOS, introduced: 16.0)
      @available(tvOS, introduced: 16.0)
      @objc static public var never: FormatStyleWrapper.ComponentDisplayOptionWrapper {
        get {
          ComponentDisplayOptionWrapper(FormatStyle.ComponentDisplayOption.never)
        }
      }

      @available(macOS, introduced: 13.0)
      @available(watchOS, introduced: 9.0)
      @available(iOS, introduced: 16.0)
      @available(tvOS, introduced: 16.0)
      @objc static public var always: FormatStyleWrapper.ComponentDisplayOptionWrapper {
        get {
          ComponentDisplayOptionWrapper(FormatStyle.ComponentDisplayOption.always)
        }
      }

      init(_ wrappedInstance: FormatStyle.ComponentDisplayOption) {
        self.wrappedInstance = wrappedInstance
      }

    }

  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc public class ParseStrategyWrapper: NSObject {
    var wrappedInstance: URL.ParseStrategy

    @available(macOS, introduced: 13.0)
    @available(watchOS, introduced: 9.0)
    @available(iOS, introduced: 16.0)
    @available(tvOS, introduced: 16.0)
    @objc static public var url: URLWrapper.ParseStrategyWrapper {
      get {
        ParseStrategyWrapper(URL.ParseStrategy.url)
      }
    }

    init(_ wrappedInstance: URL.ParseStrategy) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 13.0)
    @available(watchOS, introduced: 9.0)
    @available(iOS, introduced: 16.0)
    @available(tvOS, introduced: 16.0)
    @objc public func parse(_ value: String) throws -> URLWrapper {
      let result = try wrappedInstance.parse(value)
      return URLWrapper(result)
    }

  }

}

@available(macOS, introduced: 10.10)
@available(watchOS, introduced: 2.0)
@available(iOS, introduced: 8.0)
@available(tvOS, introduced: 9.0)
@objc public class DataWrapper: NSObject {
  var wrappedInstance: Data

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var startIndex: Data.Index {
    get {
      wrappedInstance.startIndex
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var debugDescription: String {
    get {
      wrappedInstance.debugDescription
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var count: Int {
    get {
      wrappedInstance.count
    }
    set {
      wrappedInstance.count = newValue
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var endIndex: Data.Index {
    get {
      wrappedInstance.endIndex
    }
  }

  @objc public var underestimatedCount: Int {
    get {
      wrappedInstance.underestimatedCount
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: Data) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc init(referencing reference: NSDataWrapper) {
    wrappedInstance = Data(referencing: reference.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc init(count: Int) {
    wrappedInstance = Data(count: count)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc init(capacity: Int) {
    wrappedInstance = Data(capacity: capacity)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc override init() {
    wrappedInstance = Data()
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func makeIterator() -> DataWrapper.IteratorWrapper {
    let result = wrappedInstance.makeIterator()
    return IteratorWrapper(result)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func reserveCapacity(_ minimumCapacity: Int) {
    return wrappedInstance.reserveCapacity(minimumCapacity)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func index(after i: Data.Index) -> Data.Index {
    return wrappedInstance.index(after: i)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func index(before i: Data.Index) -> Data.Index {
    return wrappedInstance.index(before: i)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func append(_ other: DataWrapper) {
    return wrappedInstance.append(other.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func advanced(by amount: Int) -> DataWrapper {
    let result = wrappedInstance.advanced(by: amount)
    return DataWrapper(result)
  }

  @objc public func reverse() {
    return wrappedInstance.reverse()
  }

  @objc public func sort() {
    return wrappedInstance.sort()
  }

  @objc public func shuffle() {
    return wrappedInstance.shuffle()
  }

  @objc public func removeFirst(_ k: Int) {
    return wrappedInstance.removeFirst(k)
  }

  @objc public func removeLast(_ k: Int) {
    return wrappedInstance.removeLast(k)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public class IteratorWrapper: NSObject {
    var wrappedInstance: Data.Iterator

    init(_ wrappedInstance: Data.Iterator) {
      self.wrappedInstance = wrappedInstance
    }

  }

}

@available(macOS, introduced: 10.10)
@available(watchOS, introduced: 2.0)
@available(iOS, introduced: 8.0)
@available(tvOS, introduced: 9.0)
@objc public class DateWrapper: NSObject {
  var wrappedInstance: Date

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var timeIntervalSinceReferenceDate: TimeInterval {
    get {
      wrappedInstance.timeIntervalSinceReferenceDate
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var timeIntervalSinceReferenceDate: TimeInterval {
    get {
      Date.timeIntervalSinceReferenceDate
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var timeIntervalBetween1970AndReferenceDate: Double {
    get {
      Date.timeIntervalBetween1970AndReferenceDate
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var distantPast: DateWrapper {
    get {
      DateWrapper(Date.distantPast)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var distantFuture: DateWrapper {
    get {
      DateWrapper(Date.distantFuture)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var debugDescription: String {
    get {
      wrappedInstance.debugDescription
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var timeIntervalSinceNow: TimeInterval {
    get {
      wrappedInstance.timeIntervalSinceNow
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var timeIntervalSince1970: TimeInterval {
    get {
      wrappedInstance.timeIntervalSince1970
    }
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc static public var now: DateWrapper {
    get {
      DateWrapper(Date.now)
    }
  }

  init(_ wrappedInstance: Date) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc init(timeIntervalSinceReferenceDate ti: TimeInterval) {
    wrappedInstance = Date(timeIntervalSinceReferenceDate: ti)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc init(timeInterval: TimeInterval, since date: DateWrapper) {
    wrappedInstance = Date(timeInterval: timeInterval, since: date.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc init(timeIntervalSinceNow: TimeInterval) {
    wrappedInstance = Date(timeIntervalSinceNow: timeIntervalSinceNow)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc init(timeIntervalSince1970: TimeInterval) {
    wrappedInstance = Date(timeIntervalSince1970: timeIntervalSince1970)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc override init() {
    wrappedInstance = Date()
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func description(with locale: LocaleWrapper?) -> String {
    return wrappedInstance.description(with: locale?.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func addTimeInterval(_ timeInterval: TimeInterval) {
    return wrappedInstance.addTimeInterval(timeInterval)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func timeIntervalSince(_ date: DateWrapper) -> TimeInterval {
    return wrappedInstance.timeIntervalSince(date.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func addingTimeInterval(_ timeInterval: TimeInterval) -> DateWrapper {
    let result = wrappedInstance.addingTimeInterval(timeInterval)
    return DateWrapper(result)
  }

  @available(macOS, introduced: 10.15)
  @available(watchOS, introduced: 6.0)
  @available(iOS, introduced: 13.0)
  @available(tvOS, introduced: 13.0)
  @objc public func advanced(by n: TimeInterval) -> DateWrapper {
    let result = wrappedInstance.advanced(by: n)
    return DateWrapper(result)
  }

  @available(macOS, introduced: 10.15)
  @available(watchOS, introduced: 6.0)
  @available(iOS, introduced: 13.0)
  @available(tvOS, introduced: 13.0)
  @objc public func distance(to other: DateWrapper) -> TimeInterval {
    return wrappedInstance.distance(to: other.wrappedInstance)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func formatted(date: FormatStyleWrapper.DateStyleWrapper, time: FormatStyleWrapper.TimeStyleWrapper) -> String {
    return wrappedInstance.formatted(date: date.wrappedInstance, time: time.wrappedInstance)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func formatted() -> String {
    return wrappedInstance.formatted()
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class FormatStyleWrapper: NSObject {
    var wrappedInstance: Date.FormatStyle

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var dateTime: DateWrapper.FormatStyleWrapper {
      get {
        FormatStyleWrapper(Date.FormatStyle.dateTime)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var dateTime: DateWrapper.FormatStyleWrapper {
      get {
        FormatStyleWrapper(Date.FormatStyle.dateTime)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var dateTime: DateWrapper.FormatStyleWrapper {
      get {
        FormatStyleWrapper(Date.FormatStyle.dateTime)
      }
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public var attributedStyle: FormatStyleWrapper.AttributedWrapper {
      get {
        AttributedWrapper(wrappedInstance.attributedStyle)
      }
    }

    @available(macOS, introduced: 12, deprecated: 15)
    @available(watchOS, introduced: 8, deprecated: 11)
    @available(iOS, introduced: 15, deprecated: 18)
    @available(tvOS, introduced: 15, deprecated: 18)
    @objc public var attributed: DateWrapper.AttributedStyleWrapper {
      get {
        AttributedStyleWrapper(wrappedInstance.attributed)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var parseStrategy: DateWrapper.FormatStyleWrapper {
      get {
        FormatStyleWrapper(wrappedInstance.parseStrategy)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var capitalizationContext: FormatStyleCapitalizationContextWrapper {
      get {
        FormatStyleCapitalizationContextWrapper(wrappedInstance.capitalizationContext)
      }
      set {
        wrappedInstance.capitalizationContext = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var locale: LocaleWrapper {
      get {
        LocaleWrapper(wrappedInstance.locale)
      }
      set {
        wrappedInstance.locale = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var calendar: CalendarWrapper {
      get {
        CalendarWrapper(wrappedInstance.calendar)
      }
      set {
        wrappedInstance.calendar = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var timeZone: TimeZoneWrapper {
      get {
        TimeZoneWrapper(wrappedInstance.timeZone)
      }
      set {
        wrappedInstance.timeZone = newValue.wrappedInstance
      }
    }

    init(_ wrappedInstance: Date.FormatStyle) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public func discreteInput(after input: DateWrapper) -> DateWrapper? {
      let result = wrappedInstance.discreteInput(after: input.wrappedInstance)
      return result == nil ? nil : DateWrapper(result!)
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public func discreteInput(before input: DateWrapper) -> DateWrapper? {
      let result = wrappedInstance.discreteInput(before: input.wrappedInstance)
      return result == nil ? nil : DateWrapper(result!)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func secondFraction(_ format: SymbolWrapper.SecondFractionWrapper) -> DateWrapper.FormatStyleWrapper {
      let result = wrappedInstance.secondFraction(format.wrappedInstance)
      return FormatStyleWrapper(result)
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public func input(after input: DateWrapper) -> DateWrapper? {
      let result = wrappedInstance.input(after: input.wrappedInstance)
      return result == nil ? nil : DateWrapper(result!)
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public func input(before input: DateWrapper) -> DateWrapper? {
      let result = wrappedInstance.input(before: input.wrappedInstance)
      return result == nil ? nil : DateWrapper(result!)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func parse(_ value: String) throws -> DateWrapper {
      let result = try wrappedInstance.parse(value)
      return DateWrapper(result)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func format(_ value: DateWrapper) -> String {
      return wrappedInstance.format(value.wrappedInstance)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func locale(_ locale: LocaleWrapper) -> DateWrapper.FormatStyleWrapper {
      let result = wrappedInstance.locale(locale.wrappedInstance)
      return FormatStyleWrapper(result)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public class TimeStyleWrapper: NSObject {
      var wrappedInstance: FormatStyle.TimeStyle

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var omitted: FormatStyleWrapper.TimeStyleWrapper {
        get {
          TimeStyleWrapper(FormatStyle.TimeStyle.omitted)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var complete: FormatStyleWrapper.TimeStyleWrapper {
        get {
          TimeStyleWrapper(FormatStyle.TimeStyle.complete)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var standard: FormatStyleWrapper.TimeStyleWrapper {
        get {
          TimeStyleWrapper(FormatStyle.TimeStyle.standard)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var shortened: FormatStyleWrapper.TimeStyleWrapper {
        get {
          TimeStyleWrapper(FormatStyle.TimeStyle.shortened)
        }
      }

      init(_ wrappedInstance: FormatStyle.TimeStyle) {
        self.wrappedInstance = wrappedInstance
      }

    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public class DateStyleWrapper: NSObject {
      var wrappedInstance: FormatStyle.DateStyle

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var abbreviated: FormatStyleWrapper.DateStyleWrapper {
        get {
          DateStyleWrapper(FormatStyle.DateStyle.abbreviated)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var long: FormatStyleWrapper.DateStyleWrapper {
        get {
          DateStyleWrapper(FormatStyle.DateStyle.long)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var numeric: FormatStyleWrapper.DateStyleWrapper {
        get {
          DateStyleWrapper(FormatStyle.DateStyle.numeric)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var omitted: FormatStyleWrapper.DateStyleWrapper {
        get {
          DateStyleWrapper(FormatStyle.DateStyle.omitted)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var complete: FormatStyleWrapper.DateStyleWrapper {
        get {
          DateStyleWrapper(FormatStyle.DateStyle.complete)
        }
      }

      init(_ wrappedInstance: FormatStyle.DateStyle) {
        self.wrappedInstance = wrappedInstance
      }

    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public class AttributedWrapper: NSObject {
      var wrappedInstance: FormatStyle.Attributed

      init(_ wrappedInstance: FormatStyle.Attributed) {
        self.wrappedInstance = wrappedInstance
      }

      @available(macOS, introduced: 15)
      @available(watchOS, introduced: 11)
      @available(iOS, introduced: 18)
      @available(tvOS, introduced: 18)
      @objc public func discreteInput(after input: DateWrapper) -> DateWrapper? {
        let result = wrappedInstance.discreteInput(after: input.wrappedInstance)
        return result == nil ? nil : DateWrapper(result!)
      }

      @available(macOS, introduced: 15)
      @available(watchOS, introduced: 11)
      @available(iOS, introduced: 18)
      @available(tvOS, introduced: 18)
      @objc public func discreteInput(before input: DateWrapper) -> DateWrapper? {
        let result = wrappedInstance.discreteInput(before: input.wrappedInstance)
        return result == nil ? nil : DateWrapper(result!)
      }

      @available(macOS, introduced: 15)
      @available(watchOS, introduced: 11)
      @available(iOS, introduced: 18)
      @available(tvOS, introduced: 18)
      @objc public func secondFraction(_ format: SymbolWrapper.SecondFractionWrapper) -> FormatStyleWrapper.AttributedWrapper {
        let result = wrappedInstance.secondFraction(format.wrappedInstance)
        return AttributedWrapper(result)
      }

      @available(macOS, introduced: 15)
      @available(watchOS, introduced: 11)
      @available(iOS, introduced: 18)
      @available(tvOS, introduced: 18)
      @objc public func input(after input: DateWrapper) -> DateWrapper? {
        let result = wrappedInstance.input(after: input.wrappedInstance)
        return result == nil ? nil : DateWrapper(result!)
      }

      @available(macOS, introduced: 15)
      @available(watchOS, introduced: 11)
      @available(iOS, introduced: 18)
      @available(tvOS, introduced: 18)
      @objc public func input(before input: DateWrapper) -> DateWrapper? {
        let result = wrappedInstance.input(before: input.wrappedInstance)
        return result == nil ? nil : DateWrapper(result!)
      }

      @available(macOS, introduced: 15)
      @available(watchOS, introduced: 11)
      @available(iOS, introduced: 18)
      @available(tvOS, introduced: 18)
      @objc public func format(_ value: DateWrapper) -> AttributedStringWrapper {
        let result = wrappedInstance.format(value.wrappedInstance)
        return AttributedStringWrapper(result)
      }

      @available(macOS, introduced: 15)
      @available(watchOS, introduced: 11)
      @available(iOS, introduced: 18)
      @available(tvOS, introduced: 18)
      @objc public func locale(_ locale: LocaleWrapper) -> FormatStyleWrapper.AttributedWrapper {
        let result = wrappedInstance.locale(locale.wrappedInstance)
        return AttributedWrapper(result)
      }

    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public class SymbolWrapper: NSObject {
      var wrappedInstance: FormatStyle.Symbol

      init(_ wrappedInstance: FormatStyle.Symbol) {
        self.wrappedInstance = wrappedInstance
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public class YearForWeekOfYearWrapper: NSObject {
        var wrappedInstance: Symbol.YearForWeekOfYear

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var defaultDigits: SymbolWrapper.YearForWeekOfYearWrapper {
          get {
            YearForWeekOfYearWrapper(Symbol.YearForWeekOfYear.defaultDigits)
          }
        }

        @available(macOS, introduced: 15)
        @available(watchOS, introduced: 11)
        @available(iOS, introduced: 18)
        @available(tvOS, introduced: 18)
        @objc static public var omitted: SymbolWrapper.YearForWeekOfYearWrapper {
          get {
            YearForWeekOfYearWrapper(Symbol.YearForWeekOfYear.omitted)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var twoDigits: SymbolWrapper.YearForWeekOfYearWrapper {
          get {
            YearForWeekOfYearWrapper(Symbol.YearForWeekOfYear.twoDigits)
          }
        }

        init(_ wrappedInstance: Symbol.YearForWeekOfYear) {
          self.wrappedInstance = wrappedInstance
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public func padded(_ length: Int) -> SymbolWrapper.YearForWeekOfYearWrapper {
          let result = Symbol.YearForWeekOfYear.padded(length)
          return YearForWeekOfYearWrapper(result)
        }

      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public class CyclicYearWrapper: NSObject {
        var wrappedInstance: Symbol.CyclicYear

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var abbreviated: SymbolWrapper.CyclicYearWrapper {
          get {
            CyclicYearWrapper(Symbol.CyclicYear.abbreviated)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var wide: SymbolWrapper.CyclicYearWrapper {
          get {
            CyclicYearWrapper(Symbol.CyclicYear.wide)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var narrow: SymbolWrapper.CyclicYearWrapper {
          get {
            CyclicYearWrapper(Symbol.CyclicYear.narrow)
          }
        }

        @available(macOS, introduced: 15)
        @available(watchOS, introduced: 11)
        @available(iOS, introduced: 18)
        @available(tvOS, introduced: 18)
        @objc static public var omitted: SymbolWrapper.CyclicYearWrapper {
          get {
            CyclicYearWrapper(Symbol.CyclicYear.omitted)
          }
        }

        init(_ wrappedInstance: Symbol.CyclicYear) {
          self.wrappedInstance = wrappedInstance
        }

      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public class VerbatimHourWrapper: NSObject {
        var wrappedInstance: Symbol.VerbatimHour

        init(_ wrappedInstance: Symbol.VerbatimHour) {
          self.wrappedInstance = wrappedInstance
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public func defaultDigits(clock: VerbatimHourWrapper.ClockWrapper, hourCycle: VerbatimHourWrapper.HourCycleWrapper) -> SymbolWrapper.VerbatimHourWrapper {
          let result = Symbol.VerbatimHour.defaultDigits(clock: clock.wrappedInstance, hourCycle: hourCycle.wrappedInstance)
          return VerbatimHourWrapper(result)
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public func twoDigits(clock: VerbatimHourWrapper.ClockWrapper, hourCycle: VerbatimHourWrapper.HourCycleWrapper) -> SymbolWrapper.VerbatimHourWrapper {
          let result = Symbol.VerbatimHour.twoDigits(clock: clock.wrappedInstance, hourCycle: hourCycle.wrappedInstance)
          return VerbatimHourWrapper(result)
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc public class HourCycleWrapper: NSObject {
          var wrappedInstance: VerbatimHour.HourCycle

          @available(macOS, introduced: 12.0)
          @available(watchOS, introduced: 8.0)
          @available(iOS, introduced: 15.0)
          @available(tvOS, introduced: 15.0)
          @objc static public var oneBased: VerbatimHourWrapper.HourCycleWrapper {
            get {
              HourCycleWrapper(VerbatimHour.HourCycle.oneBased)
            }
          }

          @available(macOS, introduced: 12.0)
          @available(watchOS, introduced: 8.0)
          @available(iOS, introduced: 15.0)
          @available(tvOS, introduced: 15.0)
          @objc static public var zeroBased: VerbatimHourWrapper.HourCycleWrapper {
            get {
              HourCycleWrapper(VerbatimHour.HourCycle.zeroBased)
            }
          }

          init(_ wrappedInstance: VerbatimHour.HourCycle) {
            self.wrappedInstance = wrappedInstance
          }

        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc public class ClockWrapper: NSObject {
          var wrappedInstance: VerbatimHour.Clock

          @available(macOS, introduced: 12.0)
          @available(watchOS, introduced: 8.0)
          @available(iOS, introduced: 15.0)
          @available(tvOS, introduced: 15.0)
          @objc static public var twentyFourHour: VerbatimHourWrapper.ClockWrapper {
            get {
              ClockWrapper(VerbatimHour.Clock.twentyFourHour)
            }
          }

          @available(macOS, introduced: 12.0)
          @available(watchOS, introduced: 8.0)
          @available(iOS, introduced: 15.0)
          @available(tvOS, introduced: 15.0)
          @objc static public var twelveHour: VerbatimHourWrapper.ClockWrapper {
            get {
              ClockWrapper(VerbatimHour.Clock.twelveHour)
            }
          }

          init(_ wrappedInstance: VerbatimHour.Clock) {
            self.wrappedInstance = wrappedInstance
          }

        }

      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public class SecondFractionWrapper: NSObject {
        var wrappedInstance: Symbol.SecondFraction

        @available(macOS, introduced: 15)
        @available(watchOS, introduced: 11)
        @available(iOS, introduced: 18)
        @available(tvOS, introduced: 18)
        @objc static public var omitted: SymbolWrapper.SecondFractionWrapper {
          get {
            SecondFractionWrapper(Symbol.SecondFraction.omitted)
          }
        }

        init(_ wrappedInstance: Symbol.SecondFraction) {
          self.wrappedInstance = wrappedInstance
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public func fractional(_ val: Int) -> SymbolWrapper.SecondFractionWrapper {
          let result = Symbol.SecondFraction.fractional(val)
          return SecondFractionWrapper(result)
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public func milliseconds(_ val: Int) -> SymbolWrapper.SecondFractionWrapper {
          let result = Symbol.SecondFraction.milliseconds(val)
          return SecondFractionWrapper(result)
        }

      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public class StandaloneMonthWrapper: NSObject {
        var wrappedInstance: Symbol.StandaloneMonth

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var abbreviated: SymbolWrapper.StandaloneMonthWrapper {
          get {
            StandaloneMonthWrapper(Symbol.StandaloneMonth.abbreviated)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var defaultDigits: SymbolWrapper.StandaloneMonthWrapper {
          get {
            StandaloneMonthWrapper(Symbol.StandaloneMonth.defaultDigits)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var wide: SymbolWrapper.StandaloneMonthWrapper {
          get {
            StandaloneMonthWrapper(Symbol.StandaloneMonth.wide)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var narrow: SymbolWrapper.StandaloneMonthWrapper {
          get {
            StandaloneMonthWrapper(Symbol.StandaloneMonth.narrow)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var twoDigits: SymbolWrapper.StandaloneMonthWrapper {
          get {
            StandaloneMonthWrapper(Symbol.StandaloneMonth.twoDigits)
          }
        }

        init(_ wrappedInstance: Symbol.StandaloneMonth) {
          self.wrappedInstance = wrappedInstance
        }

      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public class StandaloneQuarterWrapper: NSObject {
        var wrappedInstance: Symbol.StandaloneQuarter

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var abbreviated: SymbolWrapper.StandaloneQuarterWrapper {
          get {
            StandaloneQuarterWrapper(Symbol.StandaloneQuarter.abbreviated)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var wide: SymbolWrapper.StandaloneQuarterWrapper {
          get {
            StandaloneQuarterWrapper(Symbol.StandaloneQuarter.wide)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var narrow: SymbolWrapper.StandaloneQuarterWrapper {
          get {
            StandaloneQuarterWrapper(Symbol.StandaloneQuarter.narrow)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var oneDigit: SymbolWrapper.StandaloneQuarterWrapper {
          get {
            StandaloneQuarterWrapper(Symbol.StandaloneQuarter.oneDigit)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var twoDigits: SymbolWrapper.StandaloneQuarterWrapper {
          get {
            StandaloneQuarterWrapper(Symbol.StandaloneQuarter.twoDigits)
          }
        }

        init(_ wrappedInstance: Symbol.StandaloneQuarter) {
          self.wrappedInstance = wrappedInstance
        }

      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public class StandaloneWeekdayWrapper: NSObject {
        var wrappedInstance: Symbol.StandaloneWeekday

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var abbreviated: SymbolWrapper.StandaloneWeekdayWrapper {
          get {
            StandaloneWeekdayWrapper(Symbol.StandaloneWeekday.abbreviated)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var wide: SymbolWrapper.StandaloneWeekdayWrapper {
          get {
            StandaloneWeekdayWrapper(Symbol.StandaloneWeekday.wide)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var short: SymbolWrapper.StandaloneWeekdayWrapper {
          get {
            StandaloneWeekdayWrapper(Symbol.StandaloneWeekday.short)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var narrow: SymbolWrapper.StandaloneWeekdayWrapper {
          get {
            StandaloneWeekdayWrapper(Symbol.StandaloneWeekday.narrow)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var oneDigit: SymbolWrapper.StandaloneWeekdayWrapper {
          get {
            StandaloneWeekdayWrapper(Symbol.StandaloneWeekday.oneDigit)
          }
        }

        init(_ wrappedInstance: Symbol.StandaloneWeekday) {
          self.wrappedInstance = wrappedInstance
        }

      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public class DayWrapper: NSObject {
        var wrappedInstance: Symbol.Day

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var ordinalOfDayInMonth: SymbolWrapper.DayWrapper {
          get {
            DayWrapper(Symbol.Day.ordinalOfDayInMonth)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var defaultDigits: SymbolWrapper.DayWrapper {
          get {
            DayWrapper(Symbol.Day.defaultDigits)
          }
        }

        @available(macOS, introduced: 15)
        @available(watchOS, introduced: 11)
        @available(iOS, introduced: 18)
        @available(tvOS, introduced: 18)
        @objc static public var omitted: SymbolWrapper.DayWrapper {
          get {
            DayWrapper(Symbol.Day.omitted)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var twoDigits: SymbolWrapper.DayWrapper {
          get {
            DayWrapper(Symbol.Day.twoDigits)
          }
        }

        init(_ wrappedInstance: Symbol.Day) {
          self.wrappedInstance = wrappedInstance
        }

      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public class EraWrapper: NSObject {
        var wrappedInstance: Symbol.Era

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var abbreviated: SymbolWrapper.EraWrapper {
          get {
            EraWrapper(Symbol.Era.abbreviated)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var wide: SymbolWrapper.EraWrapper {
          get {
            EraWrapper(Symbol.Era.wide)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var narrow: SymbolWrapper.EraWrapper {
          get {
            EraWrapper(Symbol.Era.narrow)
          }
        }

        @available(macOS, introduced: 15)
        @available(watchOS, introduced: 11)
        @available(iOS, introduced: 18)
        @available(tvOS, introduced: 18)
        @objc static public var omitted: SymbolWrapper.EraWrapper {
          get {
            EraWrapper(Symbol.Era.omitted)
          }
        }

        init(_ wrappedInstance: Symbol.Era) {
          self.wrappedInstance = wrappedInstance
        }

      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public class HourWrapper: NSObject {
        var wrappedInstance: Symbol.Hour

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var twoDigitsNoAMPM: SymbolWrapper.HourWrapper {
          get {
            HourWrapper(Symbol.Hour.twoDigitsNoAMPM)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var defaultDigitsNoAMPM: SymbolWrapper.HourWrapper {
          get {
            HourWrapper(Symbol.Hour.defaultDigitsNoAMPM)
          }
        }

        @available(macOS, introduced: 15)
        @available(watchOS, introduced: 11)
        @available(iOS, introduced: 18)
        @available(tvOS, introduced: 18)
        @objc static public var omitted: SymbolWrapper.HourWrapper {
          get {
            HourWrapper(Symbol.Hour.omitted)
          }
        }

        init(_ wrappedInstance: Symbol.Hour) {
          self.wrappedInstance = wrappedInstance
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public func defaultDigits(amPM: HourWrapper.AMPMStyleWrapper) -> SymbolWrapper.HourWrapper {
          let result = Symbol.Hour.defaultDigits(amPM: amPM.wrappedInstance)
          return HourWrapper(result)
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public func conversationalTwoDigits(amPM: HourWrapper.AMPMStyleWrapper) -> SymbolWrapper.HourWrapper {
          let result = Symbol.Hour.conversationalTwoDigits(amPM: amPM.wrappedInstance)
          return HourWrapper(result)
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public func conversationalDefaultDigits(amPM: HourWrapper.AMPMStyleWrapper) -> SymbolWrapper.HourWrapper {
          let result = Symbol.Hour.conversationalDefaultDigits(amPM: amPM.wrappedInstance)
          return HourWrapper(result)
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public func twoDigits(amPM: HourWrapper.AMPMStyleWrapper) -> SymbolWrapper.HourWrapper {
          let result = Symbol.Hour.twoDigits(amPM: amPM.wrappedInstance)
          return HourWrapper(result)
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc public class AMPMStyleWrapper: NSObject {
          var wrappedInstance: Hour.AMPMStyle

          @available(macOS, introduced: 12.0)
          @available(watchOS, introduced: 8.0)
          @available(iOS, introduced: 15.0)
          @available(tvOS, introduced: 15.0)
          @objc static public var abbreviated: HourWrapper.AMPMStyleWrapper {
            get {
              AMPMStyleWrapper(Hour.AMPMStyle.abbreviated)
            }
          }

          @available(macOS, introduced: 12.0)
          @available(watchOS, introduced: 8.0)
          @available(iOS, introduced: 15.0)
          @available(tvOS, introduced: 15.0)
          @objc static public var wide: HourWrapper.AMPMStyleWrapper {
            get {
              AMPMStyleWrapper(Hour.AMPMStyle.wide)
            }
          }

          @available(macOS, introduced: 12.0)
          @available(watchOS, introduced: 8.0)
          @available(iOS, introduced: 15.0)
          @available(tvOS, introduced: 15.0)
          @objc static public var narrow: HourWrapper.AMPMStyleWrapper {
            get {
              AMPMStyleWrapper(Hour.AMPMStyle.narrow)
            }
          }

          @available(macOS, introduced: 12.0)
          @available(watchOS, introduced: 8.0)
          @available(iOS, introduced: 15.0)
          @available(tvOS, introduced: 15.0)
          @objc static public var omitted: HourWrapper.AMPMStyleWrapper {
            get {
              AMPMStyleWrapper(Hour.AMPMStyle.omitted)
            }
          }

          init(_ wrappedInstance: Hour.AMPMStyle) {
            self.wrappedInstance = wrappedInstance
          }

        }

      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public class WeekWrapper: NSObject {
        var wrappedInstance: Symbol.Week

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var weekOfMonth: SymbolWrapper.WeekWrapper {
          get {
            WeekWrapper(Symbol.Week.weekOfMonth)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var defaultDigits: SymbolWrapper.WeekWrapper {
          get {
            WeekWrapper(Symbol.Week.defaultDigits)
          }
        }

        @available(macOS, introduced: 15)
        @available(watchOS, introduced: 11)
        @available(iOS, introduced: 18)
        @available(tvOS, introduced: 18)
        @objc static public var omitted: SymbolWrapper.WeekWrapper {
          get {
            WeekWrapper(Symbol.Week.omitted)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var twoDigits: SymbolWrapper.WeekWrapper {
          get {
            WeekWrapper(Symbol.Week.twoDigits)
          }
        }

        init(_ wrappedInstance: Symbol.Week) {
          self.wrappedInstance = wrappedInstance
        }

      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public class YearWrapper: NSObject {
        var wrappedInstance: Symbol.Year

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var defaultDigits: SymbolWrapper.YearWrapper {
          get {
            YearWrapper(Symbol.Year.defaultDigits)
          }
        }

        @available(macOS, introduced: 15)
        @available(watchOS, introduced: 11)
        @available(iOS, introduced: 18)
        @available(tvOS, introduced: 18)
        @objc static public var omitted: SymbolWrapper.YearWrapper {
          get {
            YearWrapper(Symbol.Year.omitted)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var twoDigits: SymbolWrapper.YearWrapper {
          get {
            YearWrapper(Symbol.Year.twoDigits)
          }
        }

        init(_ wrappedInstance: Symbol.Year) {
          self.wrappedInstance = wrappedInstance
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public func padded(_ length: Int) -> SymbolWrapper.YearWrapper {
          let result = Symbol.Year.padded(length)
          return YearWrapper(result)
        }

      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public class MonthWrapper: NSObject {
        var wrappedInstance: Symbol.Month

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var abbreviated: SymbolWrapper.MonthWrapper {
          get {
            MonthWrapper(Symbol.Month.abbreviated)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var defaultDigits: SymbolWrapper.MonthWrapper {
          get {
            MonthWrapper(Symbol.Month.defaultDigits)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var wide: SymbolWrapper.MonthWrapper {
          get {
            MonthWrapper(Symbol.Month.wide)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var narrow: SymbolWrapper.MonthWrapper {
          get {
            MonthWrapper(Symbol.Month.narrow)
          }
        }

        @available(macOS, introduced: 15)
        @available(watchOS, introduced: 11)
        @available(iOS, introduced: 18)
        @available(tvOS, introduced: 18)
        @objc static public var omitted: SymbolWrapper.MonthWrapper {
          get {
            MonthWrapper(Symbol.Month.omitted)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var twoDigits: SymbolWrapper.MonthWrapper {
          get {
            MonthWrapper(Symbol.Month.twoDigits)
          }
        }

        init(_ wrappedInstance: Symbol.Month) {
          self.wrappedInstance = wrappedInstance
        }

      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public class MinuteWrapper: NSObject {
        var wrappedInstance: Symbol.Minute

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var defaultDigits: SymbolWrapper.MinuteWrapper {
          get {
            MinuteWrapper(Symbol.Minute.defaultDigits)
          }
        }

        @available(macOS, introduced: 15)
        @available(watchOS, introduced: 11)
        @available(iOS, introduced: 18)
        @available(tvOS, introduced: 18)
        @objc static public var omitted: SymbolWrapper.MinuteWrapper {
          get {
            MinuteWrapper(Symbol.Minute.omitted)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var twoDigits: SymbolWrapper.MinuteWrapper {
          get {
            MinuteWrapper(Symbol.Minute.twoDigits)
          }
        }

        init(_ wrappedInstance: Symbol.Minute) {
          self.wrappedInstance = wrappedInstance
        }

      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public class SecondWrapper: NSObject {
        var wrappedInstance: Symbol.Second

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var defaultDigits: SymbolWrapper.SecondWrapper {
          get {
            SecondWrapper(Symbol.Second.defaultDigits)
          }
        }

        @available(macOS, introduced: 15)
        @available(watchOS, introduced: 11)
        @available(iOS, introduced: 18)
        @available(tvOS, introduced: 18)
        @objc static public var omitted: SymbolWrapper.SecondWrapper {
          get {
            SecondWrapper(Symbol.Second.omitted)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var twoDigits: SymbolWrapper.SecondWrapper {
          get {
            SecondWrapper(Symbol.Second.twoDigits)
          }
        }

        init(_ wrappedInstance: Symbol.Second) {
          self.wrappedInstance = wrappedInstance
        }

      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public class QuarterWrapper: NSObject {
        var wrappedInstance: Symbol.Quarter

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var abbreviated: SymbolWrapper.QuarterWrapper {
          get {
            QuarterWrapper(Symbol.Quarter.abbreviated)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var wide: SymbolWrapper.QuarterWrapper {
          get {
            QuarterWrapper(Symbol.Quarter.wide)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var narrow: SymbolWrapper.QuarterWrapper {
          get {
            QuarterWrapper(Symbol.Quarter.narrow)
          }
        }

        @available(macOS, introduced: 15)
        @available(watchOS, introduced: 11)
        @available(iOS, introduced: 18)
        @available(tvOS, introduced: 18)
        @objc static public var omitted: SymbolWrapper.QuarterWrapper {
          get {
            QuarterWrapper(Symbol.Quarter.omitted)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var oneDigit: SymbolWrapper.QuarterWrapper {
          get {
            QuarterWrapper(Symbol.Quarter.oneDigit)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var twoDigits: SymbolWrapper.QuarterWrapper {
          get {
            QuarterWrapper(Symbol.Quarter.twoDigits)
          }
        }

        init(_ wrappedInstance: Symbol.Quarter) {
          self.wrappedInstance = wrappedInstance
        }

      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public class WeekdayWrapper: NSObject {
        var wrappedInstance: Symbol.Weekday

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var abbreviated: SymbolWrapper.WeekdayWrapper {
          get {
            WeekdayWrapper(Symbol.Weekday.abbreviated)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var wide: SymbolWrapper.WeekdayWrapper {
          get {
            WeekdayWrapper(Symbol.Weekday.wide)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var short: SymbolWrapper.WeekdayWrapper {
          get {
            WeekdayWrapper(Symbol.Weekday.short)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var narrow: SymbolWrapper.WeekdayWrapper {
          get {
            WeekdayWrapper(Symbol.Weekday.narrow)
          }
        }

        @available(macOS, introduced: 15)
        @available(watchOS, introduced: 11)
        @available(iOS, introduced: 18)
        @available(tvOS, introduced: 18)
        @objc static public var omitted: SymbolWrapper.WeekdayWrapper {
          get {
            WeekdayWrapper(Symbol.Weekday.omitted)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var oneDigit: SymbolWrapper.WeekdayWrapper {
          get {
            WeekdayWrapper(Symbol.Weekday.oneDigit)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var twoDigits: SymbolWrapper.WeekdayWrapper {
          get {
            WeekdayWrapper(Symbol.Weekday.twoDigits)
          }
        }

        init(_ wrappedInstance: Symbol.Weekday) {
          self.wrappedInstance = wrappedInstance
        }

      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public class TimeZoneWrapper: NSObject {
        var wrappedInstance: Symbol.TimeZone

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var genericLocation: SymbolWrapper.TimeZoneWrapper {
          get {
            TimeZoneWrapper(Symbol.TimeZone.genericLocation)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var exemplarLocation: SymbolWrapper.TimeZoneWrapper {
          get {
            TimeZoneWrapper(Symbol.TimeZone.exemplarLocation)
          }
        }

        @available(macOS, introduced: 15)
        @available(watchOS, introduced: 11)
        @available(iOS, introduced: 18)
        @available(tvOS, introduced: 18)
        @objc static public var omitted: SymbolWrapper.TimeZoneWrapper {
          get {
            TimeZoneWrapper(Symbol.TimeZone.omitted)
          }
        }

        init(_ wrappedInstance: Symbol.TimeZone) {
          self.wrappedInstance = wrappedInstance
        }

      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public class DayOfYearWrapper: NSObject {
        var wrappedInstance: Symbol.DayOfYear

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var threeDigits: SymbolWrapper.DayOfYearWrapper {
          get {
            DayOfYearWrapper(Symbol.DayOfYear.threeDigits)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var defaultDigits: SymbolWrapper.DayOfYearWrapper {
          get {
            DayOfYearWrapper(Symbol.DayOfYear.defaultDigits)
          }
        }

        @available(macOS, introduced: 15)
        @available(watchOS, introduced: 11)
        @available(iOS, introduced: 18)
        @available(tvOS, introduced: 18)
        @objc static public var omitted: SymbolWrapper.DayOfYearWrapper {
          get {
            DayOfYearWrapper(Symbol.DayOfYear.omitted)
          }
        }

        @available(macOS, introduced: 12.0)
        @available(watchOS, introduced: 8.0)
        @available(iOS, introduced: 15.0)
        @available(tvOS, introduced: 15.0)
        @objc static public var twoDigits: SymbolWrapper.DayOfYearWrapper {
          get {
            DayOfYearWrapper(Symbol.DayOfYear.twoDigits)
          }
        }

        init(_ wrappedInstance: Symbol.DayOfYear) {
          self.wrappedInstance = wrappedInstance
        }

      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public class DayPeriodWrapper: NSObject {
        var wrappedInstance: Symbol.DayPeriod

        @available(macOS, introduced: 15)
        @available(watchOS, introduced: 11)
        @available(iOS, introduced: 18)
        @available(tvOS, introduced: 18)
        @objc static public var omitted: SymbolWrapper.DayPeriodWrapper {
          get {
            DayPeriodWrapper(Symbol.DayPeriod.omitted)
          }
        }

        init(_ wrappedInstance: Symbol.DayPeriod) {
          self.wrappedInstance = wrappedInstance
        }

      }

    }

  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class FormatStringWrapper: NSObject {
    var wrappedInstance: Date.FormatString

    init(_ wrappedInstance: Date.FormatString) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc init(stringLiteral value: String) {
      wrappedInstance = Date.FormatString(stringLiteral: value)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc init(stringInterpolation: FormatStringWrapper.StringInterpolationWrapper) {
      wrappedInstance = Date.FormatString(stringInterpolation: stringInterpolation.wrappedInstance)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public class StringInterpolationWrapper: NSObject {
      var wrappedInstance: FormatString.StringInterpolation

      init(_ wrappedInstance: FormatString.StringInterpolation) {
        self.wrappedInstance = wrappedInstance
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc init(literalCapacity: Int, interpolationCount: Int) {
        wrappedInstance = FormatString.StringInterpolation(literalCapacity: literalCapacity, interpolationCount: interpolationCount)
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func appendInterpolation(cyclicYear: SymbolWrapper.CyclicYearWrapper) {
        return wrappedInstance.appendInterpolation(cyclicYear: cyclicYear.wrappedInstance)
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func appendInterpolation(secondFraction: SymbolWrapper.SecondFractionWrapper) {
        return wrappedInstance.appendInterpolation(secondFraction: secondFraction.wrappedInstance)
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func appendInterpolation(standaloneMonth: SymbolWrapper.StandaloneMonthWrapper) {
        return wrappedInstance.appendInterpolation(standaloneMonth: standaloneMonth.wrappedInstance)
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func appendInterpolation(standaloneQuarter: SymbolWrapper.StandaloneQuarterWrapper) {
        return wrappedInstance.appendInterpolation(standaloneQuarter: standaloneQuarter.wrappedInstance)
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func appendInterpolation(standaloneWeekday: SymbolWrapper.StandaloneWeekdayWrapper) {
        return wrappedInstance.appendInterpolation(standaloneWeekday: standaloneWeekday.wrappedInstance)
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func appendInterpolation(yearForWeekOfYear: SymbolWrapper.YearForWeekOfYearWrapper) {
        return wrappedInstance.appendInterpolation(yearForWeekOfYear: yearForWeekOfYear.wrappedInstance)
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func appendInterpolation(day: SymbolWrapper.DayWrapper) {
        return wrappedInstance.appendInterpolation(day: day.wrappedInstance)
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func appendInterpolation(era: SymbolWrapper.EraWrapper) {
        return wrappedInstance.appendInterpolation(era: era.wrappedInstance)
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func appendInterpolation(hour: SymbolWrapper.VerbatimHourWrapper) {
        return wrappedInstance.appendInterpolation(hour: hour.wrappedInstance)
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func appendInterpolation(week: SymbolWrapper.WeekWrapper) {
        return wrappedInstance.appendInterpolation(week: week.wrappedInstance)
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func appendInterpolation(year: SymbolWrapper.YearWrapper) {
        return wrappedInstance.appendInterpolation(year: year.wrappedInstance)
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func appendInterpolation(month: SymbolWrapper.MonthWrapper) {
        return wrappedInstance.appendInterpolation(month: month.wrappedInstance)
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func appendInterpolation(minute: SymbolWrapper.MinuteWrapper) {
        return wrappedInstance.appendInterpolation(minute: minute.wrappedInstance)
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func appendInterpolation(second: SymbolWrapper.SecondWrapper) {
        return wrappedInstance.appendInterpolation(second: second.wrappedInstance)
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func appendInterpolation(quarter: SymbolWrapper.QuarterWrapper) {
        return wrappedInstance.appendInterpolation(quarter: quarter.wrappedInstance)
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func appendInterpolation(weekday: SymbolWrapper.WeekdayWrapper) {
        return wrappedInstance.appendInterpolation(weekday: weekday.wrappedInstance)
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func appendInterpolation(timeZone: SymbolWrapper.TimeZoneWrapper) {
        return wrappedInstance.appendInterpolation(timeZone: timeZone.wrappedInstance)
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func appendInterpolation(dayOfYear: SymbolWrapper.DayOfYearWrapper) {
        return wrappedInstance.appendInterpolation(dayOfYear: dayOfYear.wrappedInstance)
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func appendInterpolation(dayPeriod: SymbolWrapper.DayPeriodWrapper) {
        return wrappedInstance.appendInterpolation(dayPeriod: dayPeriod.wrappedInstance)
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc public func appendLiteral(_ literal: String) {
        return wrappedInstance.appendLiteral(literal)
      }

    }

  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class ParseStrategyWrapper: NSObject {
    var wrappedInstance: Date.ParseStrategy

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var twoDigitStartDate: DateWrapper {
      get {
        DateWrapper(wrappedInstance.twoDigitStartDate)
      }
      set {
        wrappedInstance.twoDigitStartDate = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var format: String {
      get {
        wrappedInstance.format
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var locale: LocaleWrapper? {
      get {
        wrappedInstance.locale == nil ? nil : LocaleWrapper(wrappedInstance.locale!)
      }
      set {
        wrappedInstance.locale = newValue?.wrappedInstance
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var calendar: CalendarWrapper {
      get {
        CalendarWrapper(wrappedInstance.calendar)
      }
      set {
        wrappedInstance.calendar = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var timeZone: TimeZoneWrapper {
      get {
        TimeZoneWrapper(wrappedInstance.timeZone)
      }
      set {
        wrappedInstance.timeZone = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var isLenient: Bool {
      get {
        wrappedInstance.isLenient
      }
      set {
        wrappedInstance.isLenient = newValue
      }
    }

    init(_ wrappedInstance: Date.ParseStrategy) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func parse(_ value: String) throws -> DateWrapper {
      let result = try wrappedInstance.parse(value)
      return DateWrapper(result)
    }

  }

  @available(macOS, introduced: 12, deprecated: 15)
  @available(watchOS, introduced: 8, deprecated: 11)
  @available(iOS, introduced: 15, deprecated: 18)
  @available(tvOS, introduced: 15, deprecated: 18)
  @objc public class AttributedStyleWrapper: NSObject {
    var wrappedInstance: Date.AttributedStyle

    init(_ wrappedInstance: Date.AttributedStyle) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 12, deprecated: 15)
    @available(watchOS, introduced: 8, deprecated: 11)
    @available(iOS, introduced: 15, deprecated: 18)
    @available(tvOS, introduced: 15, deprecated: 18)
    @objc public func format(_ value: DateWrapper) -> AttributedStringWrapper {
      let result = wrappedInstance.format(value.wrappedInstance)
      return AttributedStringWrapper(result)
    }

    @available(macOS, introduced: 12, deprecated: 15)
    @available(watchOS, introduced: 8, deprecated: 11)
    @available(iOS, introduced: 15, deprecated: 18)
    @available(tvOS, introduced: 15, deprecated: 18)
    @objc public func locale(_ locale: LocaleWrapper) -> DateWrapper.AttributedStyleWrapper {
      let result = wrappedInstance.locale(locale.wrappedInstance)
      return AttributedStyleWrapper(result)
    }

  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class ISO8601FormatStyleWrapper: NSObject {
    var wrappedInstance: Date.ISO8601FormatStyle

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var iso8601: DateWrapper.ISO8601FormatStyleWrapper {
      get {
        ISO8601FormatStyleWrapper(Date.ISO8601FormatStyle.iso8601)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var iso8601: DateWrapper.ISO8601FormatStyleWrapper {
      get {
        ISO8601FormatStyleWrapper(Date.ISO8601FormatStyle.iso8601)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var iso8601: DateWrapper.ISO8601FormatStyleWrapper {
      get {
        ISO8601FormatStyleWrapper(Date.ISO8601FormatStyle.iso8601)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var parseStrategy: DateWrapper.ISO8601FormatStyleWrapper {
      get {
        ISO8601FormatStyleWrapper(wrappedInstance.parseStrategy)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var includingFractionalSeconds: Bool {
      get {
        wrappedInstance.includingFractionalSeconds
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var timeZone: TimeZoneWrapper {
      get {
        TimeZoneWrapper(wrappedInstance.timeZone)
      }
      set {
        wrappedInstance.timeZone = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 13.0)
    @available(watchOS, introduced: 9.0)
    @available(iOS, introduced: 16.0)
    @available(tvOS, introduced: 16.0)
    @objc static public var iso8601: DateWrapper.ISO8601FormatStyleWrapper {
      get {
        ISO8601FormatStyleWrapper(Date.ISO8601FormatStyle.iso8601)
      }
    }

    init(_ wrappedInstance: Date.ISO8601FormatStyle) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func weekOfYear() -> DateWrapper.ISO8601FormatStyleWrapper {
      let result = wrappedInstance.weekOfYear()
      return ISO8601FormatStyleWrapper(result)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func day() -> DateWrapper.ISO8601FormatStyleWrapper {
      let result = wrappedInstance.day()
      return ISO8601FormatStyleWrapper(result)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func time(includingFractionalSeconds: Bool) -> DateWrapper.ISO8601FormatStyleWrapper {
      let result = wrappedInstance.time(includingFractionalSeconds: includingFractionalSeconds)
      return ISO8601FormatStyleWrapper(result)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func year() -> DateWrapper.ISO8601FormatStyleWrapper {
      let result = wrappedInstance.year()
      return ISO8601FormatStyleWrapper(result)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func month() -> DateWrapper.ISO8601FormatStyleWrapper {
      let result = wrappedInstance.month()
      return ISO8601FormatStyleWrapper(result)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func parse(_ value: String) throws -> DateWrapper {
      let result = try wrappedInstance.parse(value)
      return DateWrapper(result)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func format(_ value: DateWrapper) -> String {
      return wrappedInstance.format(value.wrappedInstance)
    }

  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class IntervalFormatStyleWrapper: NSObject {
    var wrappedInstance: Date.IntervalFormatStyle

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var interval: DateWrapper.IntervalFormatStyleWrapper {
      get {
        IntervalFormatStyleWrapper(Date.IntervalFormatStyle.interval)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var locale: LocaleWrapper {
      get {
        LocaleWrapper(wrappedInstance.locale)
      }
      set {
        wrappedInstance.locale = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var calendar: CalendarWrapper {
      get {
        CalendarWrapper(wrappedInstance.calendar)
      }
      set {
        wrappedInstance.calendar = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var timeZone: TimeZoneWrapper {
      get {
        TimeZoneWrapper(wrappedInstance.timeZone)
      }
      set {
        wrappedInstance.timeZone = newValue.wrappedInstance
      }
    }

    init(_ wrappedInstance: Date.IntervalFormatStyle) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func day() -> DateWrapper.IntervalFormatStyleWrapper {
      let result = wrappedInstance.day()
      return IntervalFormatStyleWrapper(result)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func year() -> DateWrapper.IntervalFormatStyleWrapper {
      let result = wrappedInstance.year()
      return IntervalFormatStyleWrapper(result)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func locale(_ locale: LocaleWrapper) -> DateWrapper.IntervalFormatStyleWrapper {
      let result = wrappedInstance.locale(locale.wrappedInstance)
      return IntervalFormatStyleWrapper(result)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func minute() -> DateWrapper.IntervalFormatStyleWrapper {
      let result = wrappedInstance.minute()
      return IntervalFormatStyleWrapper(result)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func second() -> DateWrapper.IntervalFormatStyleWrapper {
      let result = wrappedInstance.second()
      return IntervalFormatStyleWrapper(result)
    }

  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class RelativeFormatStyleWrapper: NSObject {
    var wrappedInstance: Date.RelativeFormatStyle

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var unitsStyle: RelativeFormatStyleWrapper.UnitsStyleWrapper {
      get {
        UnitsStyleWrapper(wrappedInstance.unitsStyle)
      }
      set {
        wrappedInstance.unitsStyle = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var presentation: RelativeFormatStyleWrapper.PresentationWrapper {
      get {
        PresentationWrapper(wrappedInstance.presentation)
      }
      set {
        wrappedInstance.presentation = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var capitalizationContext: FormatStyleCapitalizationContextWrapper {
      get {
        FormatStyleCapitalizationContextWrapper(wrappedInstance.capitalizationContext)
      }
      set {
        wrappedInstance.capitalizationContext = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var locale: LocaleWrapper {
      get {
        LocaleWrapper(wrappedInstance.locale)
      }
      set {
        wrappedInstance.locale = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var calendar: CalendarWrapper {
      get {
        CalendarWrapper(wrappedInstance.calendar)
      }
      set {
        wrappedInstance.calendar = newValue.wrappedInstance
      }
    }

    init(_ wrappedInstance: Date.RelativeFormatStyle) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func format(_ destDate: DateWrapper) -> String {
      return wrappedInstance.format(destDate.wrappedInstance)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func locale(_ locale: LocaleWrapper) -> DateWrapper.RelativeFormatStyleWrapper {
      let result = wrappedInstance.locale(locale.wrappedInstance)
      return RelativeFormatStyleWrapper(result)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public class UnitsStyleWrapper: NSObject {
      var wrappedInstance: RelativeFormatStyle.UnitsStyle

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var abbreviated: RelativeFormatStyleWrapper.UnitsStyleWrapper {
        get {
          UnitsStyleWrapper(RelativeFormatStyle.UnitsStyle.abbreviated)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var wide: RelativeFormatStyleWrapper.UnitsStyleWrapper {
        get {
          UnitsStyleWrapper(RelativeFormatStyle.UnitsStyle.wide)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var narrow: RelativeFormatStyleWrapper.UnitsStyleWrapper {
        get {
          UnitsStyleWrapper(RelativeFormatStyle.UnitsStyle.narrow)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var spellOut: RelativeFormatStyleWrapper.UnitsStyleWrapper {
        get {
          UnitsStyleWrapper(RelativeFormatStyle.UnitsStyle.spellOut)
        }
      }

      init(_ wrappedInstance: RelativeFormatStyle.UnitsStyle) {
        self.wrappedInstance = wrappedInstance
      }

    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public class PresentationWrapper: NSObject {
      var wrappedInstance: RelativeFormatStyle.Presentation

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var named: RelativeFormatStyleWrapper.PresentationWrapper {
        get {
          PresentationWrapper(RelativeFormatStyle.Presentation.named)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var numeric: RelativeFormatStyleWrapper.PresentationWrapper {
        get {
          PresentationWrapper(RelativeFormatStyle.Presentation.numeric)
        }
      }

      init(_ wrappedInstance: RelativeFormatStyle.Presentation) {
        self.wrappedInstance = wrappedInstance
      }

    }

  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class VerbatimFormatStyleWrapper: NSObject {
    var wrappedInstance: Date.VerbatimFormatStyle

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public var attributedStyle: VerbatimFormatStyleWrapper.AttributedWrapper {
      get {
        AttributedWrapper(wrappedInstance.attributedStyle)
      }
    }

    @available(macOS, introduced: 12, deprecated: 15)
    @available(watchOS, introduced: 8, deprecated: 11)
    @available(iOS, introduced: 15, deprecated: 18)
    @available(tvOS, introduced: 15, deprecated: 18)
    @objc public var attributed: DateWrapper.AttributedStyleWrapper {
      get {
        AttributedStyleWrapper(wrappedInstance.attributed)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var parseStrategy: DateWrapper.ParseStrategyWrapper {
      get {
        ParseStrategyWrapper(wrappedInstance.parseStrategy)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var locale: LocaleWrapper? {
      get {
        wrappedInstance.locale == nil ? nil : LocaleWrapper(wrappedInstance.locale!)
      }
      set {
        wrappedInstance.locale = newValue?.wrappedInstance
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var calendar: CalendarWrapper {
      get {
        CalendarWrapper(wrappedInstance.calendar)
      }
      set {
        wrappedInstance.calendar = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var timeZone: TimeZoneWrapper {
      get {
        TimeZoneWrapper(wrappedInstance.timeZone)
      }
      set {
        wrappedInstance.timeZone = newValue.wrappedInstance
      }
    }

    init(_ wrappedInstance: Date.VerbatimFormatStyle) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public func discreteInput(after input: DateWrapper) -> DateWrapper? {
      let result = wrappedInstance.discreteInput(after: input.wrappedInstance)
      return result == nil ? nil : DateWrapper(result!)
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public func discreteInput(before input: DateWrapper) -> DateWrapper? {
      let result = wrappedInstance.discreteInput(before: input.wrappedInstance)
      return result == nil ? nil : DateWrapper(result!)
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public func input(after input: DateWrapper) -> DateWrapper? {
      let result = wrappedInstance.input(after: input.wrappedInstance)
      return result == nil ? nil : DateWrapper(result!)
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public func input(before input: DateWrapper) -> DateWrapper? {
      let result = wrappedInstance.input(before: input.wrappedInstance)
      return result == nil ? nil : DateWrapper(result!)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func format(_ value: DateWrapper) -> String {
      return wrappedInstance.format(value.wrappedInstance)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func locale(_ locale: LocaleWrapper) -> DateWrapper.VerbatimFormatStyleWrapper {
      let result = wrappedInstance.locale(locale.wrappedInstance)
      return VerbatimFormatStyleWrapper(result)
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public class AttributedWrapper: NSObject {
      var wrappedInstance: VerbatimFormatStyle.Attributed

      init(_ wrappedInstance: VerbatimFormatStyle.Attributed) {
        self.wrappedInstance = wrappedInstance
      }

      @available(macOS, introduced: 15)
      @available(watchOS, introduced: 11)
      @available(iOS, introduced: 18)
      @available(tvOS, introduced: 18)
      @objc public func discreteInput(after input: DateWrapper) -> DateWrapper? {
        let result = wrappedInstance.discreteInput(after: input.wrappedInstance)
        return result == nil ? nil : DateWrapper(result!)
      }

      @available(macOS, introduced: 15)
      @available(watchOS, introduced: 11)
      @available(iOS, introduced: 18)
      @available(tvOS, introduced: 18)
      @objc public func discreteInput(before input: DateWrapper) -> DateWrapper? {
        let result = wrappedInstance.discreteInput(before: input.wrappedInstance)
        return result == nil ? nil : DateWrapper(result!)
      }

      @available(macOS, introduced: 15)
      @available(watchOS, introduced: 11)
      @available(iOS, introduced: 18)
      @available(tvOS, introduced: 18)
      @objc public func input(after input: DateWrapper) -> DateWrapper? {
        let result = wrappedInstance.input(after: input.wrappedInstance)
        return result == nil ? nil : DateWrapper(result!)
      }

      @available(macOS, introduced: 15)
      @available(watchOS, introduced: 11)
      @available(iOS, introduced: 18)
      @available(tvOS, introduced: 18)
      @objc public func input(before input: DateWrapper) -> DateWrapper? {
        let result = wrappedInstance.input(before: input.wrappedInstance)
        return result == nil ? nil : DateWrapper(result!)
      }

      @available(macOS, introduced: 15)
      @available(watchOS, introduced: 11)
      @available(iOS, introduced: 18)
      @available(tvOS, introduced: 18)
      @objc public func format(_ value: DateWrapper) -> AttributedStringWrapper {
        let result = wrappedInstance.format(value.wrappedInstance)
        return AttributedStringWrapper(result)
      }

      @available(macOS, introduced: 15)
      @available(watchOS, introduced: 11)
      @available(iOS, introduced: 18)
      @available(tvOS, introduced: 18)
      @objc public func locale(_ locale: LocaleWrapper) -> VerbatimFormatStyleWrapper.AttributedWrapper {
        let result = wrappedInstance.locale(locale.wrappedInstance)
        return AttributedWrapper(result)
      }

    }

  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class ComponentsFormatStyleWrapper: NSObject {
    var wrappedInstance: Date.ComponentsFormatStyle

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var timeDuration: DateWrapper.ComponentsFormatStyleWrapper {
      get {
        ComponentsFormatStyleWrapper(Date.ComponentsFormatStyle.timeDuration)
      }
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public var isPositive: Bool {
      get {
        wrappedInstance.isPositive
      }
      set {
        wrappedInstance.isPositive = newValue
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var style: ComponentsFormatStyleWrapper.StyleWrapper {
      get {
        StyleWrapper(wrappedInstance.style)
      }
      set {
        wrappedInstance.style = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var locale: LocaleWrapper {
      get {
        LocaleWrapper(wrappedInstance.locale)
      }
      set {
        wrappedInstance.locale = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var calendar: CalendarWrapper {
      get {
        CalendarWrapper(wrappedInstance.calendar)
      }
      set {
        wrappedInstance.calendar = newValue.wrappedInstance
      }
    }

    init(_ wrappedInstance: Date.ComponentsFormatStyle) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func locale(_ locale: LocaleWrapper) -> DateWrapper.ComponentsFormatStyleWrapper {
      let result = wrappedInstance.locale(locale.wrappedInstance)
      return ComponentsFormatStyleWrapper(result)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func calendar(_ calendar: CalendarWrapper) -> DateWrapper.ComponentsFormatStyleWrapper {
      let result = wrappedInstance.calendar(calendar.wrappedInstance)
      return ComponentsFormatStyleWrapper(result)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public class StyleWrapper: NSObject {
      var wrappedInstance: ComponentsFormatStyle.Style

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var abbreviated: ComponentsFormatStyleWrapper.StyleWrapper {
        get {
          StyleWrapper(ComponentsFormatStyle.Style.abbreviated)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var condensedAbbreviated: ComponentsFormatStyleWrapper.StyleWrapper {
        get {
          StyleWrapper(ComponentsFormatStyle.Style.condensedAbbreviated)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var wide: ComponentsFormatStyleWrapper.StyleWrapper {
        get {
          StyleWrapper(ComponentsFormatStyle.Style.wide)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var narrow: ComponentsFormatStyleWrapper.StyleWrapper {
        get {
          StyleWrapper(ComponentsFormatStyle.Style.narrow)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var spellOut: ComponentsFormatStyleWrapper.StyleWrapper {
        get {
          StyleWrapper(ComponentsFormatStyle.Style.spellOut)
        }
      }

      init(_ wrappedInstance: ComponentsFormatStyle.Style) {
        self.wrappedInstance = wrappedInstance
      }

    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public class FieldWrapper: NSObject {
      var wrappedInstance: ComponentsFormatStyle.Field

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var day: ComponentsFormatStyleWrapper.FieldWrapper {
        get {
          FieldWrapper(ComponentsFormatStyle.Field.day)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var hour: ComponentsFormatStyleWrapper.FieldWrapper {
        get {
          FieldWrapper(ComponentsFormatStyle.Field.hour)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var week: ComponentsFormatStyleWrapper.FieldWrapper {
        get {
          FieldWrapper(ComponentsFormatStyle.Field.week)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var year: ComponentsFormatStyleWrapper.FieldWrapper {
        get {
          FieldWrapper(ComponentsFormatStyle.Field.year)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var month: ComponentsFormatStyleWrapper.FieldWrapper {
        get {
          FieldWrapper(ComponentsFormatStyle.Field.month)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var minute: ComponentsFormatStyleWrapper.FieldWrapper {
        get {
          FieldWrapper(ComponentsFormatStyle.Field.minute)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var second: ComponentsFormatStyleWrapper.FieldWrapper {
        get {
          FieldWrapper(ComponentsFormatStyle.Field.second)
        }
      }

      init(_ wrappedInstance: ComponentsFormatStyle.Field) {
        self.wrappedInstance = wrappedInstance
      }

    }

  }

  @available(macOS, introduced: 15)
  @available(watchOS, introduced: 11)
  @available(iOS, introduced: 18)
  @available(tvOS, introduced: 18)
  @objc public class AnchoredRelativeFormatStyleWrapper: NSObject {
    var wrappedInstance: Date.AnchoredRelativeFormatStyle

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public var unitsStyle: RelativeFormatStyleWrapper.UnitsStyleWrapper {
      get {
        UnitsStyleWrapper(wrappedInstance.unitsStyle)
      }
      set {
        wrappedInstance.unitsStyle = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public var presentation: RelativeFormatStyleWrapper.PresentationWrapper {
      get {
        PresentationWrapper(wrappedInstance.presentation)
      }
      set {
        wrappedInstance.presentation = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public var capitalizationContext: FormatStyleCapitalizationContextWrapper {
      get {
        FormatStyleCapitalizationContextWrapper(wrappedInstance.capitalizationContext)
      }
      set {
        wrappedInstance.capitalizationContext = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public var anchor: DateWrapper {
      get {
        DateWrapper(wrappedInstance.anchor)
      }
      set {
        wrappedInstance.anchor = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public var locale: LocaleWrapper {
      get {
        LocaleWrapper(wrappedInstance.locale)
      }
      set {
        wrappedInstance.locale = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public var calendar: CalendarWrapper {
      get {
        CalendarWrapper(wrappedInstance.calendar)
      }
      set {
        wrappedInstance.calendar = newValue.wrappedInstance
      }
    }

    init(_ wrappedInstance: Date.AnchoredRelativeFormatStyle) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public func discreteInput(after input: DateWrapper) -> DateWrapper? {
      let result = wrappedInstance.discreteInput(after: input.wrappedInstance)
      return result == nil ? nil : DateWrapper(result!)
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public func discreteInput(before input: DateWrapper) -> DateWrapper? {
      let result = wrappedInstance.discreteInput(before: input.wrappedInstance)
      return result == nil ? nil : DateWrapper(result!)
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public func input(after input: DateWrapper) -> DateWrapper? {
      let result = wrappedInstance.input(after: input.wrappedInstance)
      return result == nil ? nil : DateWrapper(result!)
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public func input(before input: DateWrapper) -> DateWrapper? {
      let result = wrappedInstance.input(before: input.wrappedInstance)
      return result == nil ? nil : DateWrapper(result!)
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public func format(_ input: DateWrapper) -> String {
      return wrappedInstance.format(input.wrappedInstance)
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public func locale(_ locale: LocaleWrapper) -> DateWrapper.AnchoredRelativeFormatStyleWrapper {
      let result = wrappedInstance.locale(locale.wrappedInstance)
      return AnchoredRelativeFormatStyleWrapper(result)
    }

  }

}

@available(macOS, introduced: 10.10)
@available(watchOS, introduced: 2.0)
@available(iOS, introduced: 8.0)
@available(tvOS, introduced: 9.0)
@objc public class LocaleWrapper: NSObject {
  var wrappedInstance: Locale

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var identifier: String {
    get {
      wrappedInstance.identifier
    }
  }

  @available(macOS, introduced: 10.10, deprecated: 13)
  @available(watchOS, introduced: 2.0, deprecated: 9)
  @available(iOS, introduced: 8.0, deprecated: 16)
  @available(tvOS, introduced: 9.0, deprecated: 16)
  @objc public var regionCode: String? {
    get {
      wrappedInstance.regionCode
    }
  }

  @available(macOS, introduced: 10.10, deprecated: 13)
  @available(watchOS, introduced: 2.0, deprecated: 9)
  @available(iOS, introduced: 8.0, deprecated: 16)
  @available(tvOS, introduced: 9.0, deprecated: 16)
  @objc public var scriptCode: String? {
    get {
      wrappedInstance.scriptCode
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public var subdivision: LocaleWrapper.SubdivisionWrapper? {
    get {
      wrappedInstance.subdivision == nil ? nil : SubdivisionWrapper(wrappedInstance.subdivision!)
    }
  }

  @available(macOS, introduced: 10.10, deprecated: 13)
  @available(watchOS, introduced: 2.0, deprecated: 9)
  @available(iOS, introduced: 8.0, deprecated: 16)
  @available(tvOS, introduced: 9.0, deprecated: 16)
  @objc public var variantCode: String? {
    get {
      wrappedInstance.variantCode
    }
  }

  @available(macOS, introduced: 10.10, deprecated: 13)
  @available(watchOS, introduced: 2.0, deprecated: 9)
  @available(iOS, introduced: 8.0, deprecated: 16)
  @available(tvOS, introduced: 9.0, deprecated: 16)
  @objc public var currencyCode: String? {
    get {
      wrappedInstance.currencyCode
    }
  }

  @available(macOS, introduced: 10.10, deprecated: 13)
  @available(watchOS, introduced: 2.0, deprecated: 9)
  @available(iOS, introduced: 8.0, deprecated: 16)
  @available(tvOS, introduced: 9.0, deprecated: 16)
  @objc public var languageCode: String? {
    get {
      wrappedInstance.languageCode
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var currencySymbol: String? {
    get {
      wrappedInstance.currencySymbol
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public var numberingSystem: LocaleWrapper.NumberingSystemWrapper {
    get {
      NumberingSystemWrapper(wrappedInstance.numberingSystem)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var debugDescription: String {
    get {
      wrappedInstance.debugDescription
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var decimalSeparator: String? {
    get {
      wrappedInstance.decimalSeparator
    }
  }

  @available(macOS, introduced: 10.10, deprecated: 13)
  @available(watchOS, introduced: 2.0, deprecated: 9)
  @available(iOS, introduced: 8.0, deprecated: 16)
  @available(tvOS, introduced: 9.0, deprecated: 16)
  @objc public var usesMetricSystem: Bool {
    get {
      wrappedInstance.usesMetricSystem
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var groupingSeparator: String? {
    get {
      wrappedInstance.groupingSeparator
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public var measurementSystem: LocaleWrapper.MeasurementSystemWrapper {
    get {
      MeasurementSystemWrapper(wrappedInstance.measurementSystem)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var collatorIdentifier: String? {
    get {
      wrappedInstance.collatorIdentifier
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var autoupdatingCurrent: LocaleWrapper {
    get {
      LocaleWrapper(Locale.autoupdatingCurrent)
    }
  }

  @available(macOS, introduced: 10.10, deprecated: 13)
  @available(watchOS, introduced: 2.0, deprecated: 9)
  @available(iOS, introduced: 8.0, deprecated: 16)
  @available(tvOS, introduced: 9.0, deprecated: 16)
  @objc public var collationIdentifier: String? {
    get {
      wrappedInstance.collationIdentifier
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var exemplarCharacterSet: CharacterSetWrapper? {
    get {
      wrappedInstance.exemplarCharacterSet == nil ? nil : CharacterSetWrapper(wrappedInstance.exemplarCharacterSet!)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var quotationEndDelimiter: String? {
    get {
      wrappedInstance.quotationEndDelimiter
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var quotationBeginDelimiter: String? {
    get {
      wrappedInstance.quotationBeginDelimiter
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var alternateQuotationEndDelimiter: String? {
    get {
      wrappedInstance.alternateQuotationEndDelimiter
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var alternateQuotationBeginDelimiter: String? {
    get {
      wrappedInstance.alternateQuotationBeginDelimiter
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public var region: LocaleWrapper.RegionWrapper? {
    get {
      wrappedInstance.region == nil ? nil : RegionWrapper(wrappedInstance.region!)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var current: LocaleWrapper {
    get {
      LocaleWrapper(Locale.current)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public var variant: LocaleWrapper.VariantWrapper? {
    get {
      wrappedInstance.variant == nil ? nil : VariantWrapper(wrappedInstance.variant!)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var calendar: CalendarWrapper {
    get {
      CalendarWrapper(wrappedInstance.calendar)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public var currency: LocaleWrapper.CurrencyWrapper? {
    get {
      wrappedInstance.currency == nil ? nil : CurrencyWrapper(wrappedInstance.currency!)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public var language: LocaleWrapper.LanguageWrapper {
    get {
      LanguageWrapper(wrappedInstance.language)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public var timeZone: TimeZoneWrapper? {
    get {
      wrappedInstance.timeZone == nil ? nil : TimeZoneWrapper(wrappedInstance.timeZone!)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public var collation: LocaleWrapper.CollationWrapper {
    get {
      CollationWrapper(wrappedInstance.collation)
    }
  }

  init(_ wrappedInstance: Locale) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init(components: LocaleWrapper.ComponentsWrapper) {
    wrappedInstance = Locale(components: components.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc init(identifier: String) {
    wrappedInstance = Locale(identifier: identifier)
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init(languageComponents: LanguageWrapper.ComponentsWrapper) {
    wrappedInstance = Locale(languageComponents: languageComponents.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public func windowsLocaleCode(fromIdentifier identifier: String) -> Int? {
    return Locale.windowsLocaleCode(fromIdentifier: identifier)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public func identifier(fromWindowsLocaleCode code: Int) -> String? {
    return Locale.identifier(fromWindowsLocaleCode: code)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func localizedString(forIdentifier identifier: String) -> String? {
    return wrappedInstance.localizedString(forIdentifier: identifier)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func localizedString(forRegionCode regionCode: String) -> String? {
    return wrappedInstance.localizedString(forRegionCode: regionCode)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func localizedString(forScriptCode scriptCode: String) -> String? {
    return wrappedInstance.localizedString(forScriptCode: scriptCode)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func localizedString(forVariantCode variantCode: String) -> String? {
    return wrappedInstance.localizedString(forVariantCode: variantCode)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func localizedString(forCurrencyCode currencyCode: String) -> String? {
    return wrappedInstance.localizedString(forCurrencyCode: currencyCode)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func localizedString(forLanguageCode languageCode: String) -> String? {
    return wrappedInstance.localizedString(forLanguageCode: languageCode)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func localizedString(forCollatorIdentifier collatorIdentifier: String) -> String? {
    return wrappedInstance.localizedString(forCollatorIdentifier: collatorIdentifier)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func localizedString(forCollationIdentifier collationIdentifier: String) -> String? {
    return wrappedInstance.localizedString(forCollationIdentifier: collationIdentifier)
  }

  @available(macOS, introduced: 10.10, deprecated: 13)
  @available(watchOS, introduced: 2.0, deprecated: 9)
  @available(iOS, introduced: 8.0, deprecated: 16)
  @available(tvOS, introduced: 9.0, deprecated: 16)
  @objc static public func canonicalIdentifier(from string: String) -> String {
    return Locale.canonicalIdentifier(from: string)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public func canonicalLanguageIdentifier(from string: String) -> String {
    return Locale.canonicalLanguageIdentifier(from: string)
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public class ComponentsWrapper: NSObject {
    var wrappedInstance: Locale.Components

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var languageComponents: LanguageWrapper.ComponentsWrapper {
      get {
        ComponentsWrapper(wrappedInstance.languageComponents)
      }
      set {
        wrappedInstance.languageComponents = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var subdivision: LocaleWrapper.SubdivisionWrapper? {
      get {
        wrappedInstance.subdivision == nil ? nil : SubdivisionWrapper(wrappedInstance.subdivision!)
      }
      set {
        wrappedInstance.subdivision = newValue?.wrappedInstance
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var numberingSystem: LocaleWrapper.NumberingSystemWrapper? {
      get {
        wrappedInstance.numberingSystem == nil ? nil : NumberingSystemWrapper(wrappedInstance.numberingSystem!)
      }
      set {
        wrappedInstance.numberingSystem = newValue?.wrappedInstance
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var measurementSystem: LocaleWrapper.MeasurementSystemWrapper? {
      get {
        wrappedInstance.measurementSystem == nil ? nil : MeasurementSystemWrapper(wrappedInstance.measurementSystem!)
      }
      set {
        wrappedInstance.measurementSystem = newValue?.wrappedInstance
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var region: LocaleWrapper.RegionWrapper? {
      get {
        wrappedInstance.region == nil ? nil : RegionWrapper(wrappedInstance.region!)
      }
      set {
        wrappedInstance.region = newValue?.wrappedInstance
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var variant: LocaleWrapper.VariantWrapper? {
      get {
        wrappedInstance.variant == nil ? nil : VariantWrapper(wrappedInstance.variant!)
      }
      set {
        wrappedInstance.variant = newValue?.wrappedInstance
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var currency: LocaleWrapper.CurrencyWrapper? {
      get {
        wrappedInstance.currency == nil ? nil : CurrencyWrapper(wrappedInstance.currency!)
      }
      set {
        wrappedInstance.currency = newValue?.wrappedInstance
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var timeZone: TimeZoneWrapper? {
      get {
        wrappedInstance.timeZone == nil ? nil : TimeZoneWrapper(wrappedInstance.timeZone!)
      }
      set {
        wrappedInstance.timeZone = newValue?.wrappedInstance
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var collation: LocaleWrapper.CollationWrapper? {
      get {
        wrappedInstance.collation == nil ? nil : CollationWrapper(wrappedInstance.collation!)
      }
      set {
        wrappedInstance.collation = newValue?.wrappedInstance
      }
    }

    init(_ wrappedInstance: Locale.Components) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc init(identifier: String) {
      wrappedInstance = Locale.Components(identifier: identifier)
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc init(locale: LocaleWrapper) {
      wrappedInstance = Locale.Components(locale: locale.wrappedInstance)
    }

  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public class SubdivisionWrapper: NSObject {
    var wrappedInstance: Locale.Subdivision

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var identifier: String {
      get {
        wrappedInstance.identifier
      }
      set {
        wrappedInstance.identifier = newValue
      }
    }

    @available(macOS, introduced: 14)
    @available(watchOS, introduced: 10)
    @available(iOS, introduced: 17)
    @available(tvOS, introduced: 17)
    @objc public var debugDescription: String {
      get {
        wrappedInstance.debugDescription
      }
    }

    init(_ wrappedInstance: Locale.Subdivision) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc init(stringLiteral value: String) {
      wrappedInstance = Locale.Subdivision(stringLiteral: value)
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc init(_ identifier: String) {
      wrappedInstance = Locale.Subdivision(identifier)
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public func subdivision(for region: LocaleWrapper.RegionWrapper) -> LocaleWrapper.SubdivisionWrapper {
      let result = Locale.Subdivision.subdivision(for: region.wrappedInstance)
      return SubdivisionWrapper(result)
    }

  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public class LanguageCodeWrapper: NSObject {
    var wrappedInstance: Locale.LanguageCode

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var norwegianBokmål: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.norwegianBokmål)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var māori: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.māori)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var belarusian: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.belarusian)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var identifier: String {
      get {
        wrappedInstance.identifier
      }
      set {
        wrappedInstance.identifier = newValue
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var indonesian: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.indonesian)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var lithuanian: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.lithuanian)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var macedonian: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.macedonian)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var portuguese: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.portuguese)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var vietnamese: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.vietnamese)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var azerbaijani: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.azerbaijani)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var unavailable: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.unavailable)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var unidentified: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.unidentified)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var apacheWestern: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.apacheWestern)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var isISOLanguage: Bool {
      get {
        wrappedInstance.isISOLanguage
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var kurdishSorani: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.kurdishSorani)
      }
    }

    @available(macOS, introduced: 14)
    @available(watchOS, introduced: 10)
    @available(iOS, introduced: 17)
    @available(tvOS, introduced: 17)
    @objc public var debugDescription: String {
      get {
        wrappedInstance.debugDescription
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var norwegianNynorsk: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.norwegianNynorsk)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var lao: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.lao)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var ainu: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.ainu)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var bodo: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.bodo)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var fula: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.fula)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var igbo: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.igbo)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var odia: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.odia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var thai: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.thai)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var urdu: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.urdu)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var czech: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.czech)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var dogri: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.dogri)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var dutch: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.dutch)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var greek: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.greek)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var hindi: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.hindi)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var irish: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.irish)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var khmer: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.khmer)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var malay: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.malay)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var tajik: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.tajik)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var tamil: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.tamil)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var uzbek: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.uzbek)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var welsh: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.welsh)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var arabic: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.arabic)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var bangla: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.bangla)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var danish: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.danish)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var french: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.french)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var german: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.german)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var hebrew: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.hebrew)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var kazakh: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.kazakh)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var korean: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.korean)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var kyrgyz: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.kyrgyz)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var navajo: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.navajo)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var nepali: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.nepali)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var pashto: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.pashto)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var polish: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.polish)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var samoan: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.samoan)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var sindhi: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.sindhi)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var slovak: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.slovak)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var telugu: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.telugu)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var tongan: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.tongan)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var uyghur: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.uyghur)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var amharic: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.amharic)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var burmese: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.burmese)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var catalan: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.catalan)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var chinese: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.chinese)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var dhivehi: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.dhivehi)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var english: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.english)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var faroese: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.faroese)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var finnish: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.finnish)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var italian: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.italian)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var kannada: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.kannada)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var konkani: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.konkani)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var kurdish: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.kurdish)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var latvian: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.latvian)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var maltese: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.maltese)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var marathi: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.marathi)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var persian: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.persian)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var punjabi: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.punjabi)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var russian: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.russian)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var santali: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.santali)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var serbian: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.serbian)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var sinhala: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.sinhala)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var spanish: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.spanish)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var swahili: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.swahili)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var swedish: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.swedish)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var tagalog: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.tagalog)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var tibetan: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.tibetan)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var turkish: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.turkish)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var turkmen: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.turkmen)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var uncoded: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.uncoded)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var yiddish: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.yiddish)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var albanian: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.albanian)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var armenian: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.armenian)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var assamese: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.assamese)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var assyrian: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.assyrian)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var cherokee: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.cherokee)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var croatian: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.croatian)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var dzongkha: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.dzongkha)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var estonian: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.estonian)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var georgian: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.georgian)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var gujarati: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.gujarati)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var hawaiian: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.hawaiian)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var japanese: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.japanese)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var kashmiri: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.kashmiri)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var maithili: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.maithili)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var manipuri: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.manipuri)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var multiple: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.multiple)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var rohingya: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.rohingya)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var romanian: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.romanian)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var sanskrit: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.sanskrit)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var bulgarian: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.bulgarian)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var cantonese: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.cantonese)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var hungarian: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.hungarian)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var icelandic: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.icelandic)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var malayalam: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.malayalam)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var mongolian: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.mongolian)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var norwegian: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.norwegian)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var slovenian: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.slovenian)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var ukrainian: LocaleWrapper.LanguageCodeWrapper {
      get {
        LanguageCodeWrapper(Locale.LanguageCode.ukrainian)
      }
    }

    init(_ wrappedInstance: Locale.LanguageCode) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc init(stringLiteral value: String) {
      wrappedInstance = Locale.LanguageCode(stringLiteral: value)
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc init(_ identifier: String) {
      wrappedInstance = Locale.LanguageCode(identifier)
    }

  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public class NumberingSystemWrapper: NSObject {
    var wrappedInstance: Locale.NumberingSystem

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var identifier: String {
      get {
        wrappedInstance.identifier
      }
      set {
        wrappedInstance.identifier = newValue
      }
    }

    @available(macOS, introduced: 14)
    @available(watchOS, introduced: 10)
    @available(iOS, introduced: 17)
    @available(tvOS, introduced: 17)
    @objc public var debugDescription: String {
      get {
        wrappedInstance.debugDescription
      }
    }

    init(_ wrappedInstance: Locale.NumberingSystem) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc init(stringLiteral value: String) {
      wrappedInstance = Locale.NumberingSystem(stringLiteral: value)
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc init(_ identifier: String) {
      wrappedInstance = Locale.NumberingSystem(identifier)
    }

  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public class MeasurementSystemWrapper: NSObject {
    var wrappedInstance: Locale.MeasurementSystem

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var identifier: String {
      get {
        wrappedInstance.identifier
      }
      set {
        wrappedInstance.identifier = newValue
      }
    }

    @available(macOS, introduced: 14)
    @available(watchOS, introduced: 10)
    @available(iOS, introduced: 17)
    @available(tvOS, introduced: 17)
    @objc public var debugDescription: String {
      get {
        wrappedInstance.debugDescription
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var uk: LocaleWrapper.MeasurementSystemWrapper {
      get {
        MeasurementSystemWrapper(Locale.MeasurementSystem.uk)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var us: LocaleWrapper.MeasurementSystemWrapper {
      get {
        MeasurementSystemWrapper(Locale.MeasurementSystem.us)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var metric: LocaleWrapper.MeasurementSystemWrapper {
      get {
        MeasurementSystemWrapper(Locale.MeasurementSystem.metric)
      }
    }

    init(_ wrappedInstance: Locale.MeasurementSystem) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc init(stringLiteral value: String) {
      wrappedInstance = Locale.MeasurementSystem(stringLiteral: value)
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc init(_ identifier: String) {
      wrappedInstance = Locale.MeasurementSystem(identifier)
    }

  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public class RegionWrapper: NSObject {
    var wrappedInstance: Locale.Region

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var curaçao: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.curaçao)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var réunion: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.réunion)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var côteDIvoire: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.côteDIvoire)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var ålandIslands: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.ålandIslands)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var saintBarthélemy: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.saintBarthélemy)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var sãoToméPríncipe: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.sãoToméPríncipe)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var containingRegion: LocaleWrapper.RegionWrapper? {
      get {
        wrappedInstance.containingRegion == nil ? nil : RegionWrapper(wrappedInstance.containingRegion!)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var antarctica: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.antarctica)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var azerbaijan: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.azerbaijan)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var bangladesh: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.bangladesh)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var elSalvador: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.elSalvador)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var guadeloupe: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.guadeloupe)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var identifier: String {
      get {
        wrappedInstance.identifier
      }
      set {
        wrappedInstance.identifier = newValue
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var kazakhstan: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.kazakhstan)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var kyrgyzstan: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.kyrgyzstan)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var luxembourg: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.luxembourg)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var madagascar: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.madagascar)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var martinique: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.martinique)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var mauritania: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.mauritania)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var micronesia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.micronesia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var montenegro: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.montenegro)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var montserrat: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.montserrat)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var mozambique: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.mozambique)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var newZealand: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.newZealand)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var puertoRico: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.puertoRico)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var saintLucia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.saintLucia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var seychelles: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.seychelles)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var southKorea: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.southKorea)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var southSudan: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.southSudan)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var tajikistan: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.tajikistan)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var timorLeste: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.timorLeste)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var uzbekistan: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.uzbekistan)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var afghanistan: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.afghanistan)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var burkinaFaso: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.burkinaFaso)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var cookIslands: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.cookIslands)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var diegoGarcia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.diegoGarcia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var isISORegion: Bool {
      get {
        wrappedInstance.isISORegion
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var netherlands: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.netherlands)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var philippines: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.philippines)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var saintHelena: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.saintHelena)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var saintMartin: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.saintMartin)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var saudiArabia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.saudiArabia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var sierraLeone: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.sierraLeone)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var sintMaarten: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.sintMaarten)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var southAfrica: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.southAfrica)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var switzerland: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.switzerland)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var vaticanCity: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.vaticanCity)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var bouvetIsland: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.bouvetIsland)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var ceutaMelilla: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.ceutaMelilla)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var cocosIslands: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.cocosIslands)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var faroeIslands: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.faroeIslands)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var frenchGuiana: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.frenchGuiana)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var guineaBissau: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.guineaBissau)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var latinAmerica: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.latinAmerica)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var newCaledonia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.newCaledonia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var turkmenistan: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.turkmenistan)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var unitedStates: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.unitedStates)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var wallisFutuna: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.wallisFutuna)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var americanSamoa: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.americanSamoa)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var canaryIslands: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.canaryIslands)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var caymanIslands: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.caymanIslands)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var chinaMainland: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.chinaMainland)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var congoKinshasa: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.congoKinshasa)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var liechtenstein: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.liechtenstein)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var norfolkIsland: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.norfolkIsland)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var unitedKingdom: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.unitedKingdom)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var westernSahara: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.westernSahara)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var antiguaBarbuda: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.antiguaBarbuda)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var northMacedonia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.northMacedonia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var papuaNewGuinea: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.papuaNewGuinea)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var solomonIslands: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.solomonIslands)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var trinidadTobago: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.trinidadTobago)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var tristanDaCunha: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.tristanDaCunha)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var ascensionIsland: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.ascensionIsland)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var christmasIsland: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.christmasIsland)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var falklandIslands: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.falklandIslands)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var frenchPolynesia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.frenchPolynesia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var marshallIslands: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.marshallIslands)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var pitcairnIslands: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.pitcairnIslands)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var saintKittsNevis: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.saintKittsNevis)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var clippertonIsland: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.clippertonIsland)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var congoBrazzaville: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.congoBrazzaville)
      }
    }

    @available(macOS, introduced: 14)
    @available(watchOS, introduced: 10)
    @available(iOS, introduced: 17)
    @available(tvOS, introduced: 17)
    @objc public var debugDescription: String {
      get {
        wrappedInstance.debugDescription
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var equatorialGuinea: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.equatorialGuinea)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var svalbardJanMayen: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.svalbardJanMayen)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var bosniaHerzegovina: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.bosniaHerzegovina)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var chagosArchipelago: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.chagosArchipelago)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var dominicanRepublic: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.dominicanRepublic)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var turksCaicosIslands: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.turksCaicosIslands)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var unitedArabEmirates: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.unitedArabEmirates)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var saintPierreMiquelon: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.saintPierreMiquelon)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var britishVirginIslands: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.britishVirginIslands)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var caribbeanNetherlands: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.caribbeanNetherlands)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var heardMcdonaldIslands: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.heardMcdonaldIslands)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var centralAfricanRepublic: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.centralAfricanRepublic)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var northernMarianaIslands: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.northernMarianaIslands)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var palestinianTerritories: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.palestinianTerritories)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var saintVincentGrenadines: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.saintVincentGrenadines)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var frenchSouthernTerritories: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.frenchSouthernTerritories)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var unitedStatesVirginIslands: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.unitedStatesVirginIslands)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var unitedStatesOutlyingIslands: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.unitedStatesOutlyingIslands)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var southGeorgiaSouthSandwichIslands: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.southGeorgiaSouthSandwichIslands)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var chad: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.chad)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var cuba: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.cuba)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var fiji: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.fiji)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var guam: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.guam)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var iran: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.iran)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var iraq: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.iraq)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var laos: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.laos)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var mali: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.mali)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var niue: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.niue)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var oman: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.oman)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var peru: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.peru)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var togo: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.togo)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var aruba: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.aruba)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var benin: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.benin)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var chile: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.chile)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var egypt: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.egypt)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var gabon: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.gabon)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var ghana: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.ghana)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var haiti: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.haiti)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var india: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.india)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var italy: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.italy)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var japan: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.japan)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var kenya: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.kenya)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var libya: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.libya)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var macao: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.macao)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var malta: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.malta)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var nauru: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.nauru)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var nepal: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.nepal)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var niger: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.niger)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var palau: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.palau)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var qatar: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.qatar)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var samoa: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.samoa)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var spain: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.spain)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var tonga: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.tonga)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var world: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.world)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var yemen: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.yemen)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var angola: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.angola)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var belize: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.belize)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var bhutan: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.bhutan)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var brazil: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.brazil)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var brunei: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.brunei)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var canada: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.canada)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var cyprus: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.cyprus)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var france: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.france)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var gambia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.gambia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var greece: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.greece)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var guinea: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.guinea)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var guyana: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.guyana)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var israel: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.israel)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var jersey: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.jersey)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var jordan: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.jordan)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var kosovo: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.kosovo)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var kuwait: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.kuwait)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var latvia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.latvia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var malawi: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.malawi)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var mexico: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.mexico)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var monaco: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.monaco)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var norway: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.norway)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var panama: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.panama)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var poland: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.poland)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var russia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.russia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var rwanda: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.rwanda)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var serbia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.serbia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var sweden: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.sweden)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var taiwan: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.taiwan)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var turkey: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.turkey)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var tuvalu: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.tuvalu)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var uganda: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.uganda)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var zambia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.zambia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var albania: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.albania)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var algeria: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.algeria)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var andorra: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.andorra)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var armenia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.armenia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var austria: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.austria)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var bahamas: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.bahamas)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var bahrain: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.bahrain)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var belarus: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.belarus)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var belgium: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.belgium)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var bermuda: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.bermuda)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var bolivia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.bolivia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var burundi: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.burundi)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var comoros: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.comoros)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var croatia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.croatia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var czechia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.czechia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var denmark: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.denmark)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var ecuador: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.ecuador)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var eritrea: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.eritrea)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var estonia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.estonia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var finland: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.finland)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var georgia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.georgia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var germany: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.germany)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var grenada: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.grenada)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var hungary: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.hungary)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var iceland: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.iceland)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var ireland: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.ireland)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var jamaica: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.jamaica)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var lebanon: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.lebanon)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var lesotho: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.lesotho)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var liberia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.liberia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var mayotte: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.mayotte)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var moldova: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.moldova)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var morocco: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.morocco)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var myanmar: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.myanmar)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var namibia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.namibia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var nigeria: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.nigeria)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var romania: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.romania)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var senegal: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.senegal)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var somalia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.somalia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var tokelau: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.tokelau)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var tunisia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.tunisia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var ukraine: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.ukraine)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var unknown: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.unknown)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var uruguay: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.uruguay)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var vanuatu: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.vanuatu)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var vietnam: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.vietnam)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var anguilla: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.anguilla)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var barbados: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.barbados)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var botswana: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.botswana)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var bulgaria: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.bulgaria)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var cambodia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.cambodia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var cameroon: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.cameroon)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var colombia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.colombia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var djibouti: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.djibouti)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var dominica: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.dominica)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var eswatini: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.eswatini)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var ethiopia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.ethiopia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var guernsey: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.guernsey)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var honduras: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.honduras)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var hongKong: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.hongKong)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var kiribati: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.kiribati)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var malaysia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.malaysia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var maldives: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.maldives)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var mongolia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.mongolia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var pakistan: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.pakistan)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var paraguay: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.paraguay)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var portugal: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.portugal)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var slovakia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.slovakia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var slovenia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.slovenia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var sriLanka: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.sriLanka)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var suriname: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.suriname)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var tanzania: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.tanzania)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var thailand: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.thailand)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var zimbabwe: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.zimbabwe)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var argentina: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.argentina)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var australia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.australia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var capeVerde: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.capeVerde)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var continent: LocaleWrapper.RegionWrapper? {
      get {
        wrappedInstance.continent == nil ? nil : RegionWrapper(wrappedInstance.continent!)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var costaRica: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.costaRica)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var gibraltar: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.gibraltar)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var greenland: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.greenland)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var guatemala: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.guatemala)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var indonesia: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.indonesia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var isleOfMan: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.isleOfMan)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var lithuania: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.lithuania)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var mauritius: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.mauritius)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var nicaragua: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.nicaragua)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var sanMarino: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.sanMarino)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var singapore: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.singapore)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var venezuela: LocaleWrapper.RegionWrapper {
      get {
        RegionWrapper(Locale.Region.venezuela)
      }
    }

    init(_ wrappedInstance: Locale.Region) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc init(stringLiteral value: String) {
      wrappedInstance = Locale.Region(stringLiteral: value)
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc init(_ identifier: String) {
      wrappedInstance = Locale.Region(identifier)
    }

  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public class ScriptWrapper: NSObject {
    var wrappedInstance: Locale.Script

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var devanagari: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.devanagari)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var identifier: String {
      get {
        wrappedInstance.identifier
      }
      set {
        wrappedInstance.identifier = newValue
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var isISOScript: Bool {
      get {
        wrappedInstance.isISOScript
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var meiteiMayek: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.meiteiMayek)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var hanSimplified: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.hanSimplified)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var arabicNastaliq: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.arabicNastaliq)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var hanTraditional: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.hanTraditional)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var hanifiRohingya: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.hanifiRohingya)
      }
    }

    @available(macOS, introduced: 14)
    @available(watchOS, introduced: 10)
    @available(iOS, introduced: 17)
    @available(tvOS, introduced: 17)
    @objc public var debugDescription: String {
      get {
        wrappedInstance.debugDescription
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var lao: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.lao)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var odia: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.odia)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var thai: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.thai)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var adlam: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.adlam)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var greek: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.greek)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var khmer: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.khmer)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var latin: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.latin)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var tamil: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.tamil)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var arabic: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.arabic)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var bangla: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.bangla)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var hebrew: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.hebrew)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var korean: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.korean)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var syriac: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.syriac)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var telugu: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.telugu)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var thaana: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.thaana)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var kannada: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.kannada)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var myanmar: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.myanmar)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var olChiki: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.olChiki)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var sinhala: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.sinhala)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var tibetan: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.tibetan)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var unknown: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.unknown)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var armenian: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.armenian)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var cherokee: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.cherokee)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var cyrillic: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.cyrillic)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var ethiopic: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.ethiopic)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var georgian: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.georgian)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var gujarati: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.gujarati)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var gurmukhi: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.gurmukhi)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var hiragana: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.hiragana)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var japanese: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.japanese)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var katakana: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.katakana)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var malayalam: LocaleWrapper.ScriptWrapper {
      get {
        ScriptWrapper(Locale.Script.malayalam)
      }
    }

    init(_ wrappedInstance: Locale.Script) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc init(stringLiteral value: String) {
      wrappedInstance = Locale.Script(stringLiteral: value)
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc init(_ identifier: String) {
      wrappedInstance = Locale.Script(identifier)
    }

  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public class VariantWrapper: NSObject {
    var wrappedInstance: Locale.Variant

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var identifier: String {
      get {
        wrappedInstance.identifier
      }
      set {
        wrappedInstance.identifier = newValue
      }
    }

    @available(macOS, introduced: 14)
    @available(watchOS, introduced: 10)
    @available(iOS, introduced: 17)
    @available(tvOS, introduced: 17)
    @objc public var debugDescription: String {
      get {
        wrappedInstance.debugDescription
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var posix: LocaleWrapper.VariantWrapper {
      get {
        VariantWrapper(Locale.Variant.posix)
      }
    }

    init(_ wrappedInstance: Locale.Variant) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc init(stringLiteral value: String) {
      wrappedInstance = Locale.Variant(stringLiteral: value)
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc init(_ identifier: String) {
      wrappedInstance = Locale.Variant(identifier)
    }

  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public class CurrencyWrapper: NSObject {
    var wrappedInstance: Locale.Currency

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var identifier: String {
      get {
        wrappedInstance.identifier
      }
      set {
        wrappedInstance.identifier = newValue
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var isISOCurrency: Bool {
      get {
        wrappedInstance.isISOCurrency
      }
    }

    @available(macOS, introduced: 14)
    @available(watchOS, introduced: 10)
    @available(iOS, introduced: 17)
    @available(tvOS, introduced: 17)
    @objc public var debugDescription: String {
      get {
        wrappedInstance.debugDescription
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var unknown: LocaleWrapper.CurrencyWrapper {
      get {
        CurrencyWrapper(Locale.Currency.unknown)
      }
    }

    init(_ wrappedInstance: Locale.Currency) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc init(stringLiteral value: String) {
      wrappedInstance = Locale.Currency(stringLiteral: value)
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc init(_ identifier: String) {
      wrappedInstance = Locale.Currency(identifier)
    }

  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public class LanguageWrapper: NSObject {
    var wrappedInstance: Locale.Language

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var languageCode: LocaleWrapper.LanguageCodeWrapper? {
      get {
        wrappedInstance.languageCode == nil ? nil : LanguageCodeWrapper(wrappedInstance.languageCode!)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var maximalIdentifier: String {
      get {
        wrappedInstance.maximalIdentifier
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var minimalIdentifier: String {
      get {
        wrappedInstance.minimalIdentifier
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var parent: LocaleWrapper.LanguageWrapper? {
      get {
        wrappedInstance.parent == nil ? nil : LanguageWrapper(wrappedInstance.parent!)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var region: LocaleWrapper.RegionWrapper? {
      get {
        wrappedInstance.region == nil ? nil : RegionWrapper(wrappedInstance.region!)
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var script: LocaleWrapper.ScriptWrapper? {
      get {
        wrappedInstance.script == nil ? nil : ScriptWrapper(wrappedInstance.script!)
      }
    }

    init(_ wrappedInstance: Locale.Language) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc init(components: LanguageWrapper.ComponentsWrapper) {
      wrappedInstance = Locale.Language(components: components.wrappedInstance)
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc init(identifier: String) {
      wrappedInstance = Locale.Language(identifier: identifier)
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public func isEquivalent(to language: LocaleWrapper.LanguageWrapper) -> Bool {
      return wrappedInstance.isEquivalent(to: language.wrappedInstance)
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public func hasCommonParent(with language: LocaleWrapper.LanguageWrapper) -> Bool {
      return wrappedInstance.hasCommonParent(with: language.wrappedInstance)
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public class ComponentsWrapper: NSObject {
      var wrappedInstance: Language.Components

      @available(macOS, introduced: 13)
      @available(watchOS, introduced: 9)
      @available(iOS, introduced: 16)
      @available(tvOS, introduced: 16)
      @objc public var languageCode: LocaleWrapper.LanguageCodeWrapper? {
        get {
          wrappedInstance.languageCode == nil ? nil : LanguageCodeWrapper(wrappedInstance.languageCode!)
        }
        set {
          wrappedInstance.languageCode = newValue?.wrappedInstance
        }
      }

      @available(macOS, introduced: 13)
      @available(watchOS, introduced: 9)
      @available(iOS, introduced: 16)
      @available(tvOS, introduced: 16)
      @objc public var region: LocaleWrapper.RegionWrapper? {
        get {
          wrappedInstance.region == nil ? nil : RegionWrapper(wrappedInstance.region!)
        }
        set {
          wrappedInstance.region = newValue?.wrappedInstance
        }
      }

      @available(macOS, introduced: 13)
      @available(watchOS, introduced: 9)
      @available(iOS, introduced: 16)
      @available(tvOS, introduced: 16)
      @objc public var script: LocaleWrapper.ScriptWrapper? {
        get {
          wrappedInstance.script == nil ? nil : ScriptWrapper(wrappedInstance.script!)
        }
        set {
          wrappedInstance.script = newValue?.wrappedInstance
        }
      }

      init(_ wrappedInstance: Language.Components) {
        self.wrappedInstance = wrappedInstance
      }

      @available(macOS, introduced: 13)
      @available(watchOS, introduced: 9)
      @available(iOS, introduced: 16)
      @available(tvOS, introduced: 16)
      @objc init(identifier: String) {
        wrappedInstance = Language.Components(identifier: identifier)
      }

      @available(macOS, introduced: 13)
      @available(watchOS, introduced: 9)
      @available(iOS, introduced: 16)
      @available(tvOS, introduced: 16)
      @objc init(language: LocaleWrapper.LanguageWrapper) {
        wrappedInstance = Language.Components(language: language.wrappedInstance)
      }

    }

  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public class CollationWrapper: NSObject {
    var wrappedInstance: Locale.Collation

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var identifier: String {
      get {
        wrappedInstance.identifier
      }
      set {
        wrappedInstance.identifier = newValue
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var searchRules: LocaleWrapper.CollationWrapper {
      get {
        CollationWrapper(Locale.Collation.searchRules)
      }
    }

    @available(macOS, introduced: 14)
    @available(watchOS, introduced: 10)
    @available(iOS, introduced: 17)
    @available(tvOS, introduced: 17)
    @objc public var debugDescription: String {
      get {
        wrappedInstance.debugDescription
      }
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var standard: LocaleWrapper.CollationWrapper {
      get {
        CollationWrapper(Locale.Collation.standard)
      }
    }

    init(_ wrappedInstance: Locale.Collation) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc init(stringLiteral value: String) {
      wrappedInstance = Locale.Collation(stringLiteral: value)
    }

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc init(_ identifier: String) {
      wrappedInstance = Locale.Collation(identifier)
    }

  }

}

@available(macOS, introduced: 10.10)
@available(watchOS, introduced: 2.0)
@available(iOS, introduced: 8.0)
@available(tvOS, introduced: 9.0)
@objc public class CalendarWrapper: NSObject {
  var wrappedInstance: Calendar

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var firstWeekday: Int {
    get {
      wrappedInstance.firstWeekday
    }
    set {
      wrappedInstance.firstWeekday = newValue
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var debugDescription: String {
    get {
      wrappedInstance.debugDescription
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var autoupdatingCurrent: CalendarWrapper {
    get {
      CalendarWrapper(Calendar.autoupdatingCurrent)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var minimumDaysInFirstWeek: Int {
    get {
      wrappedInstance.minimumDaysInFirstWeek
    }
    set {
      wrappedInstance.minimumDaysInFirstWeek = newValue
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var locale: LocaleWrapper? {
    get {
      wrappedInstance.locale == nil ? nil : LocaleWrapper(wrappedInstance.locale!)
    }
    set {
      wrappedInstance.locale = newValue?.wrappedInstance
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var current: CalendarWrapper {
    get {
      CalendarWrapper(Calendar.current)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var amSymbol: String {
    get {
      wrappedInstance.amSymbol
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var pmSymbol: String {
    get {
      wrappedInstance.pmSymbol
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var timeZone: TimeZoneWrapper {
    get {
      TimeZoneWrapper(wrappedInstance.timeZone)
    }
    set {
      wrappedInstance.timeZone = newValue.wrappedInstance
    }
  }

  init(_ wrappedInstance: Calendar) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func startOfDay(for date: DateWrapper) -> DateWrapper {
    let result = wrappedInstance.startOfDay(for: date.wrappedInstance)
    return DateWrapper(result)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func isDateInToday(_ date: DateWrapper) -> Bool {
    return wrappedInstance.isDateInToday(date.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func dateComponents(in timeZone: TimeZoneWrapper, from date: DateWrapper) -> DateComponentsWrapper {
    let result = wrappedInstance.dateComponents(in: timeZone.wrappedInstance, from: date.wrappedInstance)
    return DateComponentsWrapper(result)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func isDateInWeekend(_ date: DateWrapper) -> Bool {
    return wrappedInstance.isDateInWeekend(date.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func isDateInTomorrow(_ date: DateWrapper) -> Bool {
    return wrappedInstance.isDateInTomorrow(date.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func isDateInYesterday(_ date: DateWrapper) -> Bool {
    return wrappedInstance.isDateInYesterday(date.wrappedInstance)
  }

  @available(macOS, introduced: 10.12)
  @available(watchOS, introduced: 3.0)
  @available(iOS, introduced: 10.0)
  @available(tvOS, introduced: 10.0)
  @objc public func dateIntervalOfWeekend(containing date: DateWrapper) -> DateIntervalWrapper? {
    let result = wrappedInstance.dateIntervalOfWeekend(containing: date.wrappedInstance)
    return result == nil ? nil : DateIntervalWrapper(result!)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func date(from components: DateComponentsWrapper) -> DateWrapper? {
    let result = wrappedInstance.date(from: components.wrappedInstance)
    return result == nil ? nil : DateWrapper(result!)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func date(_ date: DateWrapper, matchesComponents components: DateComponentsWrapper) -> Bool {
    return wrappedInstance.date(date.wrappedInstance, matchesComponents: components.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func isDate(_ date1: DateWrapper, inSameDayAs date2: DateWrapper) -> Bool {
    return wrappedInstance.isDate(date1.wrappedInstance, inSameDayAs: date2.wrappedInstance)
  }

  @available(macOS, introduced: 15)
  @available(watchOS, introduced: 11)
  @available(iOS, introduced: 18)
  @available(tvOS, introduced: 18)
  @objc public class RecurrenceRuleWrapper: NSObject {
    var wrappedInstance: Calendar.RecurrenceRule

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public var end: RecurrenceRuleWrapper.EndWrapper {
      get {
        EndWrapper(wrappedInstance.end)
      }
      set {
        wrappedInstance.end = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public var calendar: CalendarWrapper {
      get {
        CalendarWrapper(wrappedInstance.calendar)
      }
      set {
        wrappedInstance.calendar = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public var interval: Int {
      get {
        wrappedInstance.interval
      }
      set {
        wrappedInstance.interval = newValue
      }
    }

    init(_ wrappedInstance: Calendar.RecurrenceRule) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public class EndWrapper: NSObject {
      var wrappedInstance: RecurrenceRule.End

      @available(macOS, introduced: 15.2)
      @available(watchOS, introduced: 11.2)
      @available(iOS, introduced: 18.2)
      @available(tvOS, introduced: 18.2)
      @objc public var description: String {
        get {
          wrappedInstance.description
        }
      }

      @available(macOS, introduced: 15.2)
      @available(watchOS, introduced: 11.2)
      @available(iOS, introduced: 18.2)
      @available(tvOS, introduced: 18.2)
      @objc public var occurrences: Int? {
        get {
          wrappedInstance.occurrences
        }
      }

      @available(macOS, introduced: 15.2)
      @available(watchOS, introduced: 11.2)
      @available(iOS, introduced: 18.2)
      @available(tvOS, introduced: 18.2)
      @objc public var date: DateWrapper? {
        get {
          wrappedInstance.date == nil ? nil : DateWrapper(wrappedInstance.date!)
        }
      }

      @available(macOS, introduced: 15)
      @available(watchOS, introduced: 11)
      @available(iOS, introduced: 18)
      @available(tvOS, introduced: 18)
      @objc static public var never: RecurrenceRuleWrapper.EndWrapper {
        get {
          EndWrapper(RecurrenceRule.End.never)
        }
      }

      init(_ wrappedInstance: RecurrenceRule.End) {
        self.wrappedInstance = wrappedInstance
      }

      @available(macOS, introduced: 15)
      @available(watchOS, introduced: 11)
      @available(iOS, introduced: 18)
      @available(tvOS, introduced: 18)
      @objc static public func afterOccurrences(_ count: Int) -> RecurrenceRuleWrapper.EndWrapper {
        let result = RecurrenceRule.End.afterOccurrences(count)
        return EndWrapper(result)
      }

      @available(macOS, introduced: 15)
      @available(watchOS, introduced: 11)
      @available(iOS, introduced: 18)
      @available(tvOS, introduced: 18)
      @objc static public func afterDate(_ date: DateWrapper) -> RecurrenceRuleWrapper.EndWrapper {
        let result = RecurrenceRule.End.afterDate(date.wrappedInstance)
        return EndWrapper(result)
      }

    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public class MonthWrapper: NSObject {
      var wrappedInstance: RecurrenceRule.Month

      @available(macOS, introduced: 15)
      @available(watchOS, introduced: 11)
      @available(iOS, introduced: 18)
      @available(tvOS, introduced: 18)
      @objc public var index: Int {
        get {
          wrappedInstance.index
        }
        set {
          wrappedInstance.index = newValue
        }
      }

      @available(macOS, introduced: 15)
      @available(watchOS, introduced: 11)
      @available(iOS, introduced: 18)
      @available(tvOS, introduced: 18)
      @objc public var isLeap: Bool {
        get {
          wrappedInstance.isLeap
        }
        set {
          wrappedInstance.isLeap = newValue
        }
      }

      init(_ wrappedInstance: RecurrenceRule.Month) {
        self.wrappedInstance = wrappedInstance
      }

      @available(macOS, introduced: 15)
      @available(watchOS, introduced: 11)
      @available(iOS, introduced: 18)
      @available(tvOS, introduced: 18)
      @objc init(integerLiteral value: Int) {
        wrappedInstance = RecurrenceRule.Month(integerLiteral: value)
      }

    }

  }

}

@available(macOS, introduced: 10.10)
@available(watchOS, introduced: 2.0)
@available(iOS, introduced: 8.0)
@available(tvOS, introduced: 9.0)
@objc public class TimeZoneWrapper: NSObject {
  var wrappedInstance: TimeZone

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var nextDaylightSavingTimeTransition: DateWrapper? {
    get {
      wrappedInstance.nextDaylightSavingTimeTransition == nil ? nil : DateWrapper(wrappedInstance.nextDaylightSavingTimeTransition!)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var timeZoneDataVersion: String {
    get {
      TimeZone.timeZoneDataVersion
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var identifier: String {
    get {
      wrappedInstance.identifier
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var debugDescription: String {
    get {
      wrappedInstance.debugDescription
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var autoupdatingCurrent: TimeZoneWrapper {
    get {
      TimeZoneWrapper(TimeZone.autoupdatingCurrent)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var abbreviationDictionary: String {
    get {
      TimeZone.abbreviationDictionary
    }
    set {
      TimeZone.abbreviationDictionary = newValue
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var gmt: TimeZoneWrapper {
    get {
      TimeZoneWrapper(TimeZone.gmt)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var current: TimeZoneWrapper {
    get {
      TimeZoneWrapper(TimeZone.current)
    }
  }

  init(_ wrappedInstance: TimeZone) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc init?(identifier: String) {
    if let instance = TimeZone(identifier: identifier) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc init?(abbreviation: String) {
    if let instance = TimeZone(abbreviation: abbreviation) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc init?(secondsFromGMT seconds: Int) {
    if let instance = TimeZone(secondsFromGMT: seconds) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func nextDaylightSavingTimeTransition(after date: DateWrapper) -> DateWrapper? {
    let result = wrappedInstance.nextDaylightSavingTimeTransition(after: date.wrappedInstance)
    return result == nil ? nil : DateWrapper(result!)
  }

}

@objc public class BoolWrapper: NSObject {
  var wrappedInstance: Bool

  init(_ wrappedInstance: Bool) {
    self.wrappedInstance = wrappedInstance
  }

}

