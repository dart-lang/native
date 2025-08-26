// Test preamble text

import Foundation

@available(macOS, introduced: 10.9)
@objc public class ActivityOptionsWrapper: NSObject {
  var wrappedInstance: ActivityOptions

  @available(macOS, introduced: 13.0)
  @objc static public var animationTrackingEnabled: ActivityOptionsWrapper {
    get {
      ActivityOptionsWrapper(ActivityOptions.animationTrackingEnabled)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var automaticTerminationDisabled: ActivityOptionsWrapper {
    get {
      ActivityOptionsWrapper(ActivityOptions.automaticTerminationDisabled)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var background: ActivityOptionsWrapper {
    get {
      ActivityOptionsWrapper(ActivityOptions.background)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var idleDisplaySleepDisabled: ActivityOptionsWrapper {
    get {
      ActivityOptionsWrapper(ActivityOptions.idleDisplaySleepDisabled)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var idleSystemSleepDisabled: ActivityOptionsWrapper {
    get {
      ActivityOptionsWrapper(ActivityOptions.idleSystemSleepDisabled)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var latencyCritical: ActivityOptionsWrapper {
    get {
      ActivityOptionsWrapper(ActivityOptions.latencyCritical)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var suddenTerminationDisabled: ActivityOptionsWrapper {
    get {
      ActivityOptionsWrapper(ActivityOptions.suddenTerminationDisabled)
    }
  }

  @available(macOS, introduced: 13.0)
  @objc static public var trackingEnabled: ActivityOptionsWrapper {
    get {
      ActivityOptionsWrapper(ActivityOptions.trackingEnabled)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var userInitiated: ActivityOptionsWrapper {
    get {
      ActivityOptionsWrapper(ActivityOptions.userInitiated)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var userInitiatedAllowingIdleSystemSleep: ActivityOptionsWrapper {
    get {
      ActivityOptionsWrapper(ActivityOptions.userInitiatedAllowingIdleSystemSleep)
    }
  }

  @available(macOS, introduced: 13.0)
  @objc static public var userInteractive: ActivityOptionsWrapper {
    get {
      ActivityOptionsWrapper(ActivityOptions.userInteractive)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: ActivityOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = ActivityOptions()
  }

}

@objc public class AlignmentOptionsWrapper: NSObject {
  var wrappedInstance: AlignmentOptions

  @objc static public var alignAllEdgesInward: AlignmentOptionsWrapper {
    get {
      AlignmentOptionsWrapper(AlignmentOptions.alignAllEdgesInward)
    }
  }

  @objc static public var alignAllEdgesNearest: AlignmentOptionsWrapper {
    get {
      AlignmentOptionsWrapper(AlignmentOptions.alignAllEdgesNearest)
    }
  }

  @objc static public var alignAllEdgesOutward: AlignmentOptionsWrapper {
    get {
      AlignmentOptionsWrapper(AlignmentOptions.alignAllEdgesOutward)
    }
  }

  @objc static public var alignHeightInward: AlignmentOptionsWrapper {
    get {
      AlignmentOptionsWrapper(AlignmentOptions.alignHeightInward)
    }
  }

  @objc static public var alignHeightNearest: AlignmentOptionsWrapper {
    get {
      AlignmentOptionsWrapper(AlignmentOptions.alignHeightNearest)
    }
  }

  @objc static public var alignHeightOutward: AlignmentOptionsWrapper {
    get {
      AlignmentOptionsWrapper(AlignmentOptions.alignHeightOutward)
    }
  }

  @objc static public var alignMaxXInward: AlignmentOptionsWrapper {
    get {
      AlignmentOptionsWrapper(AlignmentOptions.alignMaxXInward)
    }
  }

  @objc static public var alignMaxXNearest: AlignmentOptionsWrapper {
    get {
      AlignmentOptionsWrapper(AlignmentOptions.alignMaxXNearest)
    }
  }

  @objc static public var alignMaxXOutward: AlignmentOptionsWrapper {
    get {
      AlignmentOptionsWrapper(AlignmentOptions.alignMaxXOutward)
    }
  }

  @objc static public var alignMaxYInward: AlignmentOptionsWrapper {
    get {
      AlignmentOptionsWrapper(AlignmentOptions.alignMaxYInward)
    }
  }

  @objc static public var alignMaxYNearest: AlignmentOptionsWrapper {
    get {
      AlignmentOptionsWrapper(AlignmentOptions.alignMaxYNearest)
    }
  }

  @objc static public var alignMaxYOutward: AlignmentOptionsWrapper {
    get {
      AlignmentOptionsWrapper(AlignmentOptions.alignMaxYOutward)
    }
  }

  @objc static public var alignMinXInward: AlignmentOptionsWrapper {
    get {
      AlignmentOptionsWrapper(AlignmentOptions.alignMinXInward)
    }
  }

  @objc static public var alignMinXNearest: AlignmentOptionsWrapper {
    get {
      AlignmentOptionsWrapper(AlignmentOptions.alignMinXNearest)
    }
  }

  @objc static public var alignMinXOutward: AlignmentOptionsWrapper {
    get {
      AlignmentOptionsWrapper(AlignmentOptions.alignMinXOutward)
    }
  }

  @objc static public var alignMinYInward: AlignmentOptionsWrapper {
    get {
      AlignmentOptionsWrapper(AlignmentOptions.alignMinYInward)
    }
  }

  @objc static public var alignMinYNearest: AlignmentOptionsWrapper {
    get {
      AlignmentOptionsWrapper(AlignmentOptions.alignMinYNearest)
    }
  }

  @objc static public var alignMinYOutward: AlignmentOptionsWrapper {
    get {
      AlignmentOptionsWrapper(AlignmentOptions.alignMinYOutward)
    }
  }

  @objc static public var alignRectFlipped: AlignmentOptionsWrapper {
    get {
      AlignmentOptionsWrapper(AlignmentOptions.alignRectFlipped)
    }
  }

  @objc static public var alignWidthInward: AlignmentOptionsWrapper {
    get {
      AlignmentOptionsWrapper(AlignmentOptions.alignWidthInward)
    }
  }

  @objc static public var alignWidthNearest: AlignmentOptionsWrapper {
    get {
      AlignmentOptionsWrapper(AlignmentOptions.alignWidthNearest)
    }
  }

  @objc static public var alignWidthOutward: AlignmentOptionsWrapper {
    get {
      AlignmentOptionsWrapper(AlignmentOptions.alignWidthOutward)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: AlignmentOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = AlignmentOptions()
  }

}

@available(macOS, introduced: 10.11)
@objc public class SendOptionsWrapper: NSObject {
  var wrappedInstance: SendOptions

  @available(macOS, introduced: 10.11)
  @objc static public var alwaysInteract: SendOptionsWrapper {
    get {
      SendOptionsWrapper(SendOptions.alwaysInteract)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var canInteract: SendOptionsWrapper {
    get {
      SendOptionsWrapper(SendOptions.canInteract)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var canSwitchLayer: SendOptionsWrapper {
    get {
      SendOptionsWrapper(SendOptions.canSwitchLayer)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var defaultOptions: SendOptionsWrapper {
    get {
      SendOptionsWrapper(SendOptions.defaultOptions)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var dontAnnotate: SendOptionsWrapper {
    get {
      SendOptionsWrapper(SendOptions.dontAnnotate)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var dontExecute: SendOptionsWrapper {
    get {
      SendOptionsWrapper(SendOptions.dontExecute)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var dontRecord: SendOptionsWrapper {
    get {
      SendOptionsWrapper(SendOptions.dontRecord)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var neverInteract: SendOptionsWrapper {
    get {
      SendOptionsWrapper(SendOptions.neverInteract)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var noReply: SendOptionsWrapper {
    get {
      SendOptionsWrapper(SendOptions.noReply)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var queueReply: SendOptionsWrapper {
    get {
      SendOptionsWrapper(SendOptions.queueReply)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var waitForReply: SendOptionsWrapper {
    get {
      SendOptionsWrapper(SendOptions.waitForReply)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: SendOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = SendOptions()
  }

}

@objc public class EnumerationOptionsWrapper: NSObject {
  var wrappedInstance: EnumerationOptions

  @objc static public var longestEffectiveRangeNotRequired: EnumerationOptionsWrapper {
    get {
      EnumerationOptionsWrapper(EnumerationOptions.longestEffectiveRangeNotRequired)
    }
  }

  @objc static public var reverse: EnumerationOptionsWrapper {
    get {
      EnumerationOptionsWrapper(EnumerationOptions.reverse)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: EnumerationOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = EnumerationOptions()
  }

}

@objc public class NSBinarySearchingOptionsWrapper: NSObject {
  var wrappedInstance: NSBinarySearchingOptions

  @objc static public var firstEqual: NSBinarySearchingOptionsWrapper {
    get {
      NSBinarySearchingOptionsWrapper(NSBinarySearchingOptions.firstEqual)
    }
  }

  @objc static public var insertionIndex: NSBinarySearchingOptionsWrapper {
    get {
      NSBinarySearchingOptionsWrapper(NSBinarySearchingOptions.insertionIndex)
    }
  }

  @objc static public var lastEqual: NSBinarySearchingOptionsWrapper {
    get {
      NSBinarySearchingOptionsWrapper(NSBinarySearchingOptions.lastEqual)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: NSBinarySearchingOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = NSBinarySearchingOptions()
  }

}

@objc public class UnitsWrapper: NSObject {
  var wrappedInstance: Units

  @objc static public var useAll: UnitsWrapper {
    get {
      UnitsWrapper(Units.useAll)
    }
  }

  @objc static public var useBytes: UnitsWrapper {
    get {
      UnitsWrapper(Units.useBytes)
    }
  }

  @objc static public var useEB: UnitsWrapper {
    get {
      UnitsWrapper(Units.useEB)
    }
  }

  @objc static public var useGB: UnitsWrapper {
    get {
      UnitsWrapper(Units.useGB)
    }
  }

  @objc static public var useKB: UnitsWrapper {
    get {
      UnitsWrapper(Units.useKB)
    }
  }

  @objc static public var useMB: UnitsWrapper {
    get {
      UnitsWrapper(Units.useMB)
    }
  }

  @objc static public var usePB: UnitsWrapper {
    get {
      UnitsWrapper(Units.usePB)
    }
  }

  @objc static public var useTB: UnitsWrapper {
    get {
      UnitsWrapper(Units.useTB)
    }
  }

  @objc static public var useYBOrHigher: UnitsWrapper {
    get {
      UnitsWrapper(Units.useYBOrHigher)
    }
  }

  @objc static public var useZB: UnitsWrapper {
    get {
      UnitsWrapper(Units.useZB)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: Units) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = Units()
  }

}

@objc public class OptionsWrapper1: NSObject {
  var wrappedInstance: Options

  @available(macOS, introduced: 10.9)
  @objc static public var matchFirst: OptionsWrapper1 {
    get {
      OptionsWrapper1(Options.matchFirst)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var matchLast: OptionsWrapper1 {
    get {
      OptionsWrapper1(Options.matchLast)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var matchNextTime: OptionsWrapper1 {
    get {
      OptionsWrapper1(Options.matchNextTime)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var matchNextTimePreservingSmallerUnits: OptionsWrapper1 {
    get {
      OptionsWrapper1(Options.matchNextTimePreservingSmallerUnits)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var matchPreviousTimePreservingSmallerUnits: OptionsWrapper1 {
    get {
      OptionsWrapper1(Options.matchPreviousTimePreservingSmallerUnits)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var matchStrictly: OptionsWrapper1 {
    get {
      OptionsWrapper1(Options.matchStrictly)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var searchBackwards: OptionsWrapper1 {
    get {
      OptionsWrapper1(Options.searchBackwards)
    }
  }

  @objc static public var wrapComponents: OptionsWrapper1 {
    get {
      OptionsWrapper1(Options.wrapComponents)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: Options) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = Options()
  }

}

@objc public class UnitWrapper: NSObject {
  var wrappedInstance: Unit

  @available(macOS, introduced: 10.7, deprecated: 10.10)
  @objc static public var NSCalendarCalendarUnit: UnitWrapper {
    get {
      UnitWrapper(Unit.NSCalendarCalendarUnit)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var calendar: UnitWrapper {
    get {
      UnitWrapper(Unit.calendar)
    }
  }

  @objc static public var day: UnitWrapper {
    get {
      UnitWrapper(Unit.day)
    }
  }

  @available(macOS, introduced: 15.0)
  @objc static public var dayOfYear: UnitWrapper {
    get {
      UnitWrapper(Unit.dayOfYear)
    }
  }

  @objc static public var era: UnitWrapper {
    get {
      UnitWrapper(Unit.era)
    }
  }

  @objc static public var hour: UnitWrapper {
    get {
      UnitWrapper(Unit.hour)
    }
  }

  @objc static public var minute: UnitWrapper {
    get {
      UnitWrapper(Unit.minute)
    }
  }

  @objc static public var month: UnitWrapper {
    get {
      UnitWrapper(Unit.month)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var nanosecond: UnitWrapper {
    get {
      UnitWrapper(Unit.nanosecond)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var quarter: UnitWrapper {
    get {
      UnitWrapper(Unit.quarter)
    }
  }

  @objc static public var second: UnitWrapper {
    get {
      UnitWrapper(Unit.second)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var timeZone: UnitWrapper {
    get {
      UnitWrapper(Unit.timeZone)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var weekOfMonth: UnitWrapper {
    get {
      UnitWrapper(Unit.weekOfMonth)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var weekOfYear: UnitWrapper {
    get {
      UnitWrapper(Unit.weekOfYear)
    }
  }

  @objc static public var weekday: UnitWrapper {
    get {
      UnitWrapper(Unit.weekday)
    }
  }

  @objc static public var weekdayOrdinal: UnitWrapper {
    get {
      UnitWrapper(Unit.weekdayOrdinal)
    }
  }

  @objc static public var year: UnitWrapper {
    get {
      UnitWrapper(Unit.year)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var yearForWeekOfYear: UnitWrapper {
    get {
      UnitWrapper(Unit.yearForWeekOfYear)
    }
  }

  @available(macOS, introduced: 10.4, deprecated: 10.10)
  @objc static public var NSDayCalendarUnit: UnitWrapper {
    get {
      UnitWrapper(Unit.NSDayCalendarUnit)
    }
  }

  @available(macOS, introduced: 10.4, deprecated: 10.10)
  @objc static public var NSEraCalendarUnit: UnitWrapper {
    get {
      UnitWrapper(Unit.NSEraCalendarUnit)
    }
  }

  @available(macOS, introduced: 10.4, deprecated: 10.10)
  @objc static public var NSHourCalendarUnit: UnitWrapper {
    get {
      UnitWrapper(Unit.NSHourCalendarUnit)
    }
  }

  @available(macOS, introduced: 10.4, deprecated: 10.10)
  @objc static public var NSMinuteCalendarUnit: UnitWrapper {
    get {
      UnitWrapper(Unit.NSMinuteCalendarUnit)
    }
  }

  @available(macOS, introduced: 10.4, deprecated: 10.10)
  @objc static public var NSMonthCalendarUnit: UnitWrapper {
    get {
      UnitWrapper(Unit.NSMonthCalendarUnit)
    }
  }

  @available(macOS, introduced: 10.6, deprecated: 10.10)
  @objc static public var NSQuarterCalendarUnit: UnitWrapper {
    get {
      UnitWrapper(Unit.NSQuarterCalendarUnit)
    }
  }

  @available(macOS, introduced: 10.4, deprecated: 10.10)
  @objc static public var NSSecondCalendarUnit: UnitWrapper {
    get {
      UnitWrapper(Unit.NSSecondCalendarUnit)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 10.10)
  @objc static public var NSTimeZoneCalendarUnit: UnitWrapper {
    get {
      UnitWrapper(Unit.NSTimeZoneCalendarUnit)
    }
  }

  @available(macOS, introduced: 10.4, deprecated: 10.10)
  @objc static public var NSWeekCalendarUnit: UnitWrapper {
    get {
      UnitWrapper(Unit.NSWeekCalendarUnit)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 10.10)
  @objc static public var NSWeekOfMonthCalendarUnit: UnitWrapper {
    get {
      UnitWrapper(Unit.NSWeekOfMonthCalendarUnit)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 10.10)
  @objc static public var NSWeekOfYearCalendarUnit: UnitWrapper {
    get {
      UnitWrapper(Unit.NSWeekOfYearCalendarUnit)
    }
  }

  @available(macOS, introduced: 10.4, deprecated: 10.10)
  @objc static public var NSWeekdayCalendarUnit: UnitWrapper {
    get {
      UnitWrapper(Unit.NSWeekdayCalendarUnit)
    }
  }

  @available(macOS, introduced: 10.4, deprecated: 10.10)
  @objc static public var NSWeekdayOrdinalCalendarUnit: UnitWrapper {
    get {
      UnitWrapper(Unit.NSWeekdayOrdinalCalendarUnit)
    }
  }

  @available(macOS, introduced: 10.4, deprecated: 10.10)
  @objc static public var NSYearCalendarUnit: UnitWrapper {
    get {
      UnitWrapper(Unit.NSYearCalendarUnit)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 10.10)
  @objc static public var NSYearForWeekOfYearCalendarUnit: UnitWrapper {
    get {
      UnitWrapper(Unit.NSYearForWeekOfYearCalendarUnit)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: Unit) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = Unit()
  }

}

@objc public class OptionsWrapper9: NSObject {
  var wrappedInstance: Options

  @objc static public var caseInsensitive: OptionsWrapper9 {
    get {
      OptionsWrapper9(Options.caseInsensitive)
    }
  }

  @objc static public var diacriticInsensitive: OptionsWrapper9 {
    get {
      OptionsWrapper9(Options.diacriticInsensitive)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var normalized: OptionsWrapper9 {
    get {
      OptionsWrapper9(Options.normalized)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: Options) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = Options()
  }

}

@available(macOS, introduced: 10.9)
@objc public class Base64DecodingOptionsWrapper: NSObject {
  var wrappedInstance: Base64DecodingOptions

  @available(macOS, introduced: 10.9)
  @objc static public var ignoreUnknownCharacters: Base64DecodingOptionsWrapper {
    get {
      Base64DecodingOptionsWrapper(Base64DecodingOptions.ignoreUnknownCharacters)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: Base64DecodingOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = Base64DecodingOptions()
  }

}

@available(macOS, introduced: 10.9)
@objc public class Base64EncodingOptionsWrapper: NSObject {
  var wrappedInstance: Base64EncodingOptions

  @available(macOS, introduced: 10.9)
  @objc static public var lineLength64Characters: Base64EncodingOptionsWrapper {
    get {
      Base64EncodingOptionsWrapper(Base64EncodingOptions.lineLength64Characters)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var lineLength76Characters: Base64EncodingOptionsWrapper {
    get {
      Base64EncodingOptionsWrapper(Base64EncodingOptions.lineLength76Characters)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var endLineWithCarriageReturn: Base64EncodingOptionsWrapper {
    get {
      Base64EncodingOptionsWrapper(Base64EncodingOptions.endLineWithCarriageReturn)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var endLineWithLineFeed: Base64EncodingOptionsWrapper {
    get {
      Base64EncodingOptionsWrapper(Base64EncodingOptions.endLineWithLineFeed)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: Base64EncodingOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = Base64EncodingOptions()
  }

}

@objc public class ReadingOptionsWrapper3: NSObject {
  var wrappedInstance: ReadingOptions

  @available(macOS, introduced: 10.0, deprecated: 100000)
  @objc static public var dataReadingMapped: ReadingOptionsWrapper3 {
    get {
      ReadingOptionsWrapper3(ReadingOptions.dataReadingMapped)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var alwaysMapped: ReadingOptionsWrapper3 {
    get {
      ReadingOptionsWrapper3(ReadingOptions.alwaysMapped)
    }
  }

  @objc static public var mappedIfSafe: ReadingOptionsWrapper3 {
    get {
      ReadingOptionsWrapper3(ReadingOptions.mappedIfSafe)
    }
  }

  @objc static public var uncached: ReadingOptionsWrapper3 {
    get {
      ReadingOptionsWrapper3(ReadingOptions.uncached)
    }
  }

  @available(macOS, introduced: 10.0, deprecated: 100000)
  @objc static public var mappedRead: ReadingOptionsWrapper3 {
    get {
      ReadingOptionsWrapper3(ReadingOptions.mappedRead)
    }
  }

  @available(macOS, introduced: 10.0, deprecated: 100000)
  @objc static public var uncachedRead: ReadingOptionsWrapper3 {
    get {
      ReadingOptionsWrapper3(ReadingOptions.uncachedRead)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: ReadingOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = ReadingOptions()
  }

}

@available(macOS, introduced: 10.6)
@objc public class SearchOptionsWrapper: NSObject {
  var wrappedInstance: SearchOptions

  @available(macOS, introduced: 10.6)
  @objc static public var anchored: SearchOptionsWrapper {
    get {
      SearchOptionsWrapper(SearchOptions.anchored)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var backwards: SearchOptionsWrapper {
    get {
      SearchOptionsWrapper(SearchOptions.backwards)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: SearchOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = SearchOptions()
  }

}

@objc public class WritingOptionsWrapper3: NSObject {
  var wrappedInstance: WritingOptions

  @available(macOS, introduced: 10.0, deprecated: 100000)
  @objc static public var atomicWrite: WritingOptionsWrapper3 {
    get {
      WritingOptionsWrapper3(WritingOptions.atomicWrite)
    }
  }

  @objc static public var atomic: WritingOptionsWrapper3 {
    get {
      WritingOptionsWrapper3(WritingOptions.atomic)
    }
  }

  @available(macOS, introduced: 11.0)
  @objc static public var completeFileProtection: WritingOptionsWrapper3 {
    get {
      WritingOptionsWrapper3(WritingOptions.completeFileProtection)
    }
  }

  @available(macOS, introduced: 11.0)
  @objc static public var completeFileProtectionUnlessOpen: WritingOptionsWrapper3 {
    get {
      WritingOptionsWrapper3(WritingOptions.completeFileProtectionUnlessOpen)
    }
  }

  @available(macOS, introduced: 11.0)
  @objc static public var completeFileProtectionUntilFirstUserAuthentication: WritingOptionsWrapper3 {
    get {
      WritingOptionsWrapper3(WritingOptions.completeFileProtectionUntilFirstUserAuthentication)
    }
  }

  @available(macOS, introduced: 11.0)
  @objc static public var fileProtectionMask: WritingOptionsWrapper3 {
    get {
      WritingOptionsWrapper3(WritingOptions.fileProtectionMask)
    }
  }

  @available(macOS, introduced: 11.0)
  @objc static public var noFileProtection: WritingOptionsWrapper3 {
    get {
      WritingOptionsWrapper3(WritingOptions.noFileProtection)
    }
  }

  @available(macOS, introduced: 10.8)
  @objc static public var withoutOverwriting: WritingOptionsWrapper3 {
    get {
      WritingOptionsWrapper3(WritingOptions.withoutOverwriting)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: WritingOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = WritingOptions()
  }

}

@available(macOS, introduced: 10.10)
@objc public class ZeroFormattingBehaviorWrapper: NSObject {
  var wrappedInstance: ZeroFormattingBehavior

  @available(macOS, introduced: 10.10)
  @objc static public var `default`: ZeroFormattingBehaviorWrapper {
    get {
      ZeroFormattingBehaviorWrapper(ZeroFormattingBehavior.`default`)
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var dropAll: ZeroFormattingBehaviorWrapper {
    get {
      ZeroFormattingBehaviorWrapper(ZeroFormattingBehavior.dropAll)
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var dropLeading: ZeroFormattingBehaviorWrapper {
    get {
      ZeroFormattingBehaviorWrapper(ZeroFormattingBehavior.dropLeading)
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var dropMiddle: ZeroFormattingBehaviorWrapper {
    get {
      ZeroFormattingBehaviorWrapper(ZeroFormattingBehavior.dropMiddle)
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var dropTrailing: ZeroFormattingBehaviorWrapper {
    get {
      ZeroFormattingBehaviorWrapper(ZeroFormattingBehavior.dropTrailing)
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var pad: ZeroFormattingBehaviorWrapper {
    get {
      ZeroFormattingBehaviorWrapper(ZeroFormattingBehavior.pad)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: ZeroFormattingBehavior) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = ZeroFormattingBehavior()
  }

}

@available(macOS, introduced: 10.6)
@objc public class DirectoryEnumerationOptionsWrapper: NSObject {
  var wrappedInstance: DirectoryEnumerationOptions

  @available(macOS, introduced: 10.15)
  @objc static public var includesDirectoriesPostOrder: DirectoryEnumerationOptionsWrapper {
    get {
      DirectoryEnumerationOptionsWrapper(DirectoryEnumerationOptions.includesDirectoriesPostOrder)
    }
  }

  @available(macOS, introduced: 10.15)
  @objc static public var producesRelativePathURLs: DirectoryEnumerationOptionsWrapper {
    get {
      DirectoryEnumerationOptionsWrapper(DirectoryEnumerationOptions.producesRelativePathURLs)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var skipsHiddenFiles: DirectoryEnumerationOptionsWrapper {
    get {
      DirectoryEnumerationOptionsWrapper(DirectoryEnumerationOptions.skipsHiddenFiles)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var skipsPackageDescendants: DirectoryEnumerationOptionsWrapper {
    get {
      DirectoryEnumerationOptionsWrapper(DirectoryEnumerationOptions.skipsPackageDescendants)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var skipsSubdirectoryDescendants: DirectoryEnumerationOptionsWrapper {
    get {
      DirectoryEnumerationOptionsWrapper(DirectoryEnumerationOptions.skipsSubdirectoryDescendants)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: DirectoryEnumerationOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = DirectoryEnumerationOptions()
  }

}

@objc public class OptionsWrapper5: NSObject {
  var wrappedInstance: Options

  @objc static public var deliverImmediately: OptionsWrapper5 {
    get {
      OptionsWrapper5(Options.deliverImmediately)
    }
  }

  @objc static public var postToAllSessions: OptionsWrapper5 {
    get {
      OptionsWrapper5(Options.postToAllSessions)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: Options) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = Options()
  }

}

@objc public class NSEnumerationOptionsWrapper: NSObject {
  var wrappedInstance: NSEnumerationOptions

  @objc static public var concurrent: NSEnumerationOptionsWrapper {
    get {
      NSEnumerationOptionsWrapper(NSEnumerationOptions.concurrent)
    }
  }

  @objc static public var reverse: NSEnumerationOptionsWrapper {
    get {
      NSEnumerationOptionsWrapper(NSEnumerationOptions.reverse)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: NSEnumerationOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = NSEnumerationOptions()
  }

}

@objc public class ReadingOptionsWrapper2: NSObject {
  var wrappedInstance: ReadingOptions

  @available(macOS, introduced: 10.10)
  @objc static public var forUploading: ReadingOptionsWrapper2 {
    get {
      ReadingOptionsWrapper2(ReadingOptions.forUploading)
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var immediatelyAvailableMetadataOnly: ReadingOptionsWrapper2 {
    get {
      ReadingOptionsWrapper2(ReadingOptions.immediatelyAvailableMetadataOnly)
    }
  }

  @objc static public var resolvesSymbolicLink: ReadingOptionsWrapper2 {
    get {
      ReadingOptionsWrapper2(ReadingOptions.resolvesSymbolicLink)
    }
  }

  @objc static public var withoutChanges: ReadingOptionsWrapper2 {
    get {
      ReadingOptionsWrapper2(ReadingOptions.withoutChanges)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: ReadingOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = ReadingOptions()
  }

}

@objc public class WritingOptionsWrapper: NSObject {
  var wrappedInstance: WritingOptions

  @available(macOS, introduced: 10.10)
  @objc static public var contentIndependentMetadataOnly: WritingOptionsWrapper {
    get {
      WritingOptionsWrapper(WritingOptions.contentIndependentMetadataOnly)
    }
  }

  @objc static public var forDeleting: WritingOptionsWrapper {
    get {
      WritingOptionsWrapper(WritingOptions.forDeleting)
    }
  }

  @objc static public var forMerging: WritingOptionsWrapper {
    get {
      WritingOptionsWrapper(WritingOptions.forMerging)
    }
  }

  @objc static public var forMoving: WritingOptionsWrapper {
    get {
      WritingOptionsWrapper(WritingOptions.forMoving)
    }
  }

  @objc static public var forReplacing: WritingOptionsWrapper {
    get {
      WritingOptionsWrapper(WritingOptions.forReplacing)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: WritingOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = WritingOptions()
  }

}

@available(macOS, introduced: 10.6)
@objc public class ItemReplacementOptionsWrapper: NSObject {
  var wrappedInstance: ItemReplacementOptions

  @available(macOS, introduced: 10.6)
  @objc static public var usingNewMetadataOnly: ItemReplacementOptionsWrapper {
    get {
      ItemReplacementOptionsWrapper(ItemReplacementOptions.usingNewMetadataOnly)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var withoutDeletingBackupItem: ItemReplacementOptionsWrapper {
    get {
      ItemReplacementOptionsWrapper(ItemReplacementOptions.withoutDeletingBackupItem)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: ItemReplacementOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = ItemReplacementOptions()
  }

}

@available(macOS, introduced: 10.11)
@objc public class UnmountOptionsWrapper: NSObject {
  var wrappedInstance: UnmountOptions

  @available(macOS, introduced: 10.11)
  @objc static public var allPartitionsAndEjectDisk: UnmountOptionsWrapper {
    get {
      UnmountOptionsWrapper(UnmountOptions.allPartitionsAndEjectDisk)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var withoutUI: UnmountOptionsWrapper {
    get {
      UnmountOptionsWrapper(UnmountOptions.withoutUI)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: UnmountOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = UnmountOptions()
  }

}

@objc public class AddingOptionsWrapper: NSObject {
  var wrappedInstance: AddingOptions

  @objc static public var byMoving: AddingOptionsWrapper {
    get {
      AddingOptionsWrapper(AddingOptions.byMoving)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: AddingOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = AddingOptions()
  }

}

@objc public class ReplacingOptionsWrapper: NSObject {
  var wrappedInstance: ReplacingOptions

  @objc static public var byMoving: ReplacingOptionsWrapper {
    get {
      ReplacingOptionsWrapper(ReplacingOptions.byMoving)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: ReplacingOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = ReplacingOptions()
  }

}

@available(macOS, introduced: 10.6)
@objc public class ReadingOptionsWrapper: NSObject {
  var wrappedInstance: ReadingOptions

  @available(macOS, introduced: 10.6)
  @objc static public var immediate: ReadingOptionsWrapper {
    get {
      ReadingOptionsWrapper(ReadingOptions.immediate)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var withoutMapping: ReadingOptionsWrapper {
    get {
      ReadingOptionsWrapper(ReadingOptions.withoutMapping)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: ReadingOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = ReadingOptions()
  }

}

@available(macOS, introduced: 10.6)
@objc public class WritingOptionsWrapper1: NSObject {
  var wrappedInstance: WritingOptions

  @available(macOS, introduced: 10.6)
  @objc static public var atomic: WritingOptionsWrapper1 {
    get {
      WritingOptionsWrapper1(WritingOptions.atomic)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var withNameUpdating: WritingOptionsWrapper1 {
    get {
      WritingOptionsWrapper1(WritingOptions.withNameUpdating)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: WritingOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = WritingOptions()
  }

}

@objc public class OptionsWrapper10: NSObject {
  var wrappedInstance: Options

  @available(macOS, introduced: 10.12)
  @objc static public var withColonSeparatorInTime: OptionsWrapper10 {
    get {
      OptionsWrapper10(Options.withColonSeparatorInTime)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var withColonSeparatorInTimeZone: OptionsWrapper10 {
    get {
      OptionsWrapper10(Options.withColonSeparatorInTimeZone)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var withDashSeparatorInDate: OptionsWrapper10 {
    get {
      OptionsWrapper10(Options.withDashSeparatorInDate)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var withDay: OptionsWrapper10 {
    get {
      OptionsWrapper10(Options.withDay)
    }
  }

  @available(macOS, introduced: 10.13)
  @objc static public var withFractionalSeconds: OptionsWrapper10 {
    get {
      OptionsWrapper10(Options.withFractionalSeconds)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var withFullDate: OptionsWrapper10 {
    get {
      OptionsWrapper10(Options.withFullDate)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var withFullTime: OptionsWrapper10 {
    get {
      OptionsWrapper10(Options.withFullTime)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var withInternetDateTime: OptionsWrapper10 {
    get {
      OptionsWrapper10(Options.withInternetDateTime)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var withMonth: OptionsWrapper10 {
    get {
      OptionsWrapper10(Options.withMonth)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var withSpaceBetweenDateAndTime: OptionsWrapper10 {
    get {
      OptionsWrapper10(Options.withSpaceBetweenDateAndTime)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var withTime: OptionsWrapper10 {
    get {
      OptionsWrapper10(Options.withTime)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var withTimeZone: OptionsWrapper10 {
    get {
      OptionsWrapper10(Options.withTimeZone)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var withWeekOfYear: OptionsWrapper10 {
    get {
      OptionsWrapper10(Options.withWeekOfYear)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var withYear: OptionsWrapper10 {
    get {
      OptionsWrapper10(Options.withYear)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: Options) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = Options()
  }

}

@available(macOS, introduced: 12.0)
@objc public class InlinePresentationIntentWrapper: NSObject {
  var wrappedInstance: InlinePresentationIntent

  @available(macOS, introduced: 12.0)
  @objc static public var blockHTML: InlinePresentationIntentWrapper {
    get {
      InlinePresentationIntentWrapper(InlinePresentationIntent.blockHTML)
    }
  }

  @available(macOS, introduced: 12.0)
  @objc static public var code: InlinePresentationIntentWrapper {
    get {
      InlinePresentationIntentWrapper(InlinePresentationIntent.code)
    }
  }

  @available(macOS, introduced: 12.0)
  @objc static public var emphasized: InlinePresentationIntentWrapper {
    get {
      InlinePresentationIntentWrapper(InlinePresentationIntent.emphasized)
    }
  }

  @available(macOS, introduced: 12.0)
  @objc static public var inlineHTML: InlinePresentationIntentWrapper {
    get {
      InlinePresentationIntentWrapper(InlinePresentationIntent.inlineHTML)
    }
  }

  @available(macOS, introduced: 12.0)
  @objc static public var lineBreak: InlinePresentationIntentWrapper {
    get {
      InlinePresentationIntentWrapper(InlinePresentationIntent.lineBreak)
    }
  }

  @available(macOS, introduced: 12.0)
  @objc static public var softBreak: InlinePresentationIntentWrapper {
    get {
      InlinePresentationIntentWrapper(InlinePresentationIntent.softBreak)
    }
  }

  @available(macOS, introduced: 12.0)
  @objc static public var strikethrough: InlinePresentationIntentWrapper {
    get {
      InlinePresentationIntentWrapper(InlinePresentationIntent.strikethrough)
    }
  }

  @available(macOS, introduced: 12.0)
  @objc static public var stronglyEmphasized: InlinePresentationIntentWrapper {
    get {
      InlinePresentationIntentWrapper(InlinePresentationIntent.stronglyEmphasized)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: InlinePresentationIntent) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = InlinePresentationIntent()
  }

}

@available(macOS, introduced: 10.13)
@objc public class NSItemProviderFileOptionsWrapper: NSObject {
  var wrappedInstance: NSItemProviderFileOptions

  @available(macOS, introduced: 10.13)
  @objc static public var openInPlace: NSItemProviderFileOptionsWrapper {
    get {
      NSItemProviderFileOptionsWrapper(NSItemProviderFileOptions.openInPlace)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: NSItemProviderFileOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.13)
  @objc init(rawValue: Int) {
    wrappedInstance = NSItemProviderFileOptions(rawValue: rawValue)
  }

  @objc override init() {
    wrappedInstance = NSItemProviderFileOptions()
  }

}

@available(macOS, introduced: 10.7)
@objc public class ReadingOptionsWrapper1: NSObject {
  var wrappedInstance: ReadingOptions

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var allowFragments: ReadingOptionsWrapper1 {
    get {
      ReadingOptionsWrapper1(ReadingOptions.allowFragments)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var fragmentsAllowed: ReadingOptionsWrapper1 {
    get {
      ReadingOptionsWrapper1(ReadingOptions.fragmentsAllowed)
    }
  }

  @available(macOS, introduced: 12.0)
  @objc static public var json5Allowed: ReadingOptionsWrapper1 {
    get {
      ReadingOptionsWrapper1(ReadingOptions.json5Allowed)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var mutableContainers: ReadingOptionsWrapper1 {
    get {
      ReadingOptionsWrapper1(ReadingOptions.mutableContainers)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var mutableLeaves: ReadingOptionsWrapper1 {
    get {
      ReadingOptionsWrapper1(ReadingOptions.mutableLeaves)
    }
  }

  @available(macOS, introduced: 12.0)
  @objc static public var topLevelDictionaryAssumed: ReadingOptionsWrapper1 {
    get {
      ReadingOptionsWrapper1(ReadingOptions.topLevelDictionaryAssumed)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: ReadingOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = ReadingOptions()
  }

}

@available(macOS, introduced: 10.7)
@objc public class WritingOptionsWrapper2: NSObject {
  var wrappedInstance: WritingOptions

  @available(macOS, introduced: 10.7)
  @objc static public var fragmentsAllowed: WritingOptionsWrapper2 {
    get {
      WritingOptionsWrapper2(WritingOptions.fragmentsAllowed)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var prettyPrinted: WritingOptionsWrapper2 {
    get {
      WritingOptionsWrapper2(WritingOptions.prettyPrinted)
    }
  }

  @available(macOS, introduced: 10.13)
  @objc static public var sortedKeys: WritingOptionsWrapper2 {
    get {
      WritingOptionsWrapper2(WritingOptions.sortedKeys)
    }
  }

  @available(macOS, introduced: 10.15)
  @objc static public var withoutEscapingSlashes: WritingOptionsWrapper2 {
    get {
      WritingOptionsWrapper2(WritingOptions.withoutEscapingSlashes)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: WritingOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = WritingOptions()
  }

}

@objc public class NSKeyValueObservingOptionsWrapper: NSObject {
  var wrappedInstance: NSKeyValueObservingOptions

  @available(macOS, introduced: 10.5)
  @objc static public var initial: NSKeyValueObservingOptionsWrapper {
    get {
      NSKeyValueObservingOptionsWrapper(NSKeyValueObservingOptions.initial)
    }
  }

  @objc static public var new: NSKeyValueObservingOptionsWrapper {
    get {
      NSKeyValueObservingOptionsWrapper(NSKeyValueObservingOptions.new)
    }
  }

  @objc static public var old: NSKeyValueObservingOptionsWrapper {
    get {
      NSKeyValueObservingOptionsWrapper(NSKeyValueObservingOptions.old)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var prior: NSKeyValueObservingOptionsWrapper {
    get {
      NSKeyValueObservingOptionsWrapper(NSKeyValueObservingOptions.prior)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: NSKeyValueObservingOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = NSKeyValueObservingOptions()
  }

}

@objc public class OptionsWrapper3: NSObject {
  var wrappedInstance: Options

  @objc static public var joinNames: OptionsWrapper3 {
    get {
      OptionsWrapper3(Options.joinNames)
    }
  }

  @objc static public var omitOther: OptionsWrapper3 {
    get {
      OptionsWrapper3(Options.omitOther)
    }
  }

  @objc static public var omitPunctuation: OptionsWrapper3 {
    get {
      OptionsWrapper3(Options.omitPunctuation)
    }
  }

  @objc static public var omitWhitespace: OptionsWrapper3 {
    get {
      OptionsWrapper3(Options.omitWhitespace)
    }
  }

  @objc static public var omitWords: OptionsWrapper3 {
    get {
      OptionsWrapper3(Options.omitWords)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: Options) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = Options()
  }

}

@available(macOS, introduced: 10.5)
@objc public class OptionsWrapper4: NSObject {
  var wrappedInstance: Options

  @available(macOS, introduced: 10.5)
  @objc static public var deallocateReceiveRight: OptionsWrapper4 {
    get {
      OptionsWrapper4(Options.deallocateReceiveRight)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var deallocateSendRight: OptionsWrapper4 {
    get {
      OptionsWrapper4(Options.deallocateSendRight)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: Options) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = Options()
  }

}

@objc public class MatchingFlagsWrapper: NSObject {
  var wrappedInstance: MatchingFlags

  @objc static public var completed: MatchingFlagsWrapper {
    get {
      MatchingFlagsWrapper(MatchingFlags.completed)
    }
  }

  @objc static public var hitEnd: MatchingFlagsWrapper {
    get {
      MatchingFlagsWrapper(MatchingFlags.hitEnd)
    }
  }

  @objc static public var internalError: MatchingFlagsWrapper {
    get {
      MatchingFlagsWrapper(MatchingFlags.internalError)
    }
  }

  @objc static public var progress: MatchingFlagsWrapper {
    get {
      MatchingFlagsWrapper(MatchingFlags.progress)
    }
  }

  @objc static public var requiredEnd: MatchingFlagsWrapper {
    get {
      MatchingFlagsWrapper(MatchingFlags.requiredEnd)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: MatchingFlags) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = MatchingFlags()
  }

}

@objc public class MatchingOptionsWrapper: NSObject {
  var wrappedInstance: MatchingOptions

  @objc static public var anchored: MatchingOptionsWrapper {
    get {
      MatchingOptionsWrapper(MatchingOptions.anchored)
    }
  }

  @objc static public var reportCompletion: MatchingOptionsWrapper {
    get {
      MatchingOptionsWrapper(MatchingOptions.reportCompletion)
    }
  }

  @objc static public var reportProgress: MatchingOptionsWrapper {
    get {
      MatchingOptionsWrapper(MatchingOptions.reportProgress)
    }
  }

  @objc static public var withTransparentBounds: MatchingOptionsWrapper {
    get {
      MatchingOptionsWrapper(MatchingOptions.withTransparentBounds)
    }
  }

  @objc static public var withoutAnchoringBounds: MatchingOptionsWrapper {
    get {
      MatchingOptionsWrapper(MatchingOptions.withoutAnchoringBounds)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: MatchingOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = MatchingOptions()
  }

}

@available(macOS, introduced: 10.12)
@objc public class UnitOptionsWrapper: NSObject {
  var wrappedInstance: UnitOptions

  @available(macOS, introduced: 10.12)
  @objc static public var naturalScale: UnitOptionsWrapper {
    get {
      UnitOptionsWrapper(UnitOptions.naturalScale)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var providedUnit: UnitOptionsWrapper {
    get {
      UnitOptionsWrapper(UnitOptions.providedUnit)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var temperatureWithoutUnit: UnitOptionsWrapper {
    get {
      UnitOptionsWrapper(UnitOptions.temperatureWithoutUnit)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: UnitOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = UnitOptions()
  }

}

@available(macOS, introduced: 10.2)
@objc public class OptionsWrapper7: NSObject {
  var wrappedInstance: Options

  @available(macOS, introduced: 10.9)
  @objc static public var listenForConnections: OptionsWrapper7 {
    get {
      OptionsWrapper7(Options.listenForConnections)
    }
  }

  @available(macOS, introduced: 10.2)
  @objc static public var noAutoRename: OptionsWrapper7 {
    get {
      OptionsWrapper7(Options.noAutoRename)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: Options) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = Options()
  }

}

@objc public class NotificationCoalescingWrapper: NSObject {
  var wrappedInstance: NotificationCoalescing

  @objc static public var onName: NotificationCoalescingWrapper {
    get {
      NotificationCoalescingWrapper(NotificationCoalescing.onName)
    }
  }

  @objc static public var onSender: NotificationCoalescingWrapper {
    get {
      NotificationCoalescingWrapper(NotificationCoalescing.onSender)
    }
  }

  @objc static public var none: NotificationCoalescingWrapper {
    get {
      NotificationCoalescingWrapper(NotificationCoalescing.none)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: NotificationCoalescing) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = NotificationCoalescing()
  }

}

@available(macOS, introduced: 10.15)
@objc public class NSOrderedCollectionDifferenceCalculationOptionsWrapper: NSObject {
  var wrappedInstance: NSOrderedCollectionDifferenceCalculationOptions

  @available(macOS, introduced: 10.15)
  @objc static public var inferMoves: NSOrderedCollectionDifferenceCalculationOptionsWrapper {
    get {
      NSOrderedCollectionDifferenceCalculationOptionsWrapper(NSOrderedCollectionDifferenceCalculationOptions.inferMoves)
    }
  }

  @available(macOS, introduced: 10.15)
  @objc static public var omitInsertedObjects: NSOrderedCollectionDifferenceCalculationOptionsWrapper {
    get {
      NSOrderedCollectionDifferenceCalculationOptionsWrapper(NSOrderedCollectionDifferenceCalculationOptions.omitInsertedObjects)
    }
  }

  @available(macOS, introduced: 10.15)
  @objc static public var omitRemovedObjects: NSOrderedCollectionDifferenceCalculationOptionsWrapper {
    get {
      NSOrderedCollectionDifferenceCalculationOptionsWrapper(NSOrderedCollectionDifferenceCalculationOptions.omitRemovedObjects)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: NSOrderedCollectionDifferenceCalculationOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = NSOrderedCollectionDifferenceCalculationOptions()
  }

}

@available(macOS, introduced: 10.11)
@objc public class OptionsWrapper2: NSObject {
  var wrappedInstance: Options

  @available(macOS, introduced: 10.11)
  @objc static public var phonetic: OptionsWrapper2 {
    get {
      OptionsWrapper2(Options.phonetic)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: Options) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = Options()
  }

}

@objc public class OptionsWrapper: NSObject {
  var wrappedInstance: Options

  @available(macOS, introduced: 10.5)
  @objc static public var cStringPersonality: OptionsWrapper {
    get {
      OptionsWrapper(Options.cStringPersonality)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var copyIn: OptionsWrapper {
    get {
      OptionsWrapper(Options.copyIn)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var integerPersonality: OptionsWrapper {
    get {
      OptionsWrapper(Options.integerPersonality)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var machVirtualMemory: OptionsWrapper {
    get {
      OptionsWrapper(Options.machVirtualMemory)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var mallocMemory: OptionsWrapper {
    get {
      OptionsWrapper(Options.mallocMemory)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var objectPersonality: OptionsWrapper {
    get {
      OptionsWrapper(Options.objectPersonality)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var objectPointerPersonality: OptionsWrapper {
    get {
      OptionsWrapper(Options.objectPointerPersonality)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var opaqueMemory: OptionsWrapper {
    get {
      OptionsWrapper(Options.opaqueMemory)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var opaquePersonality: OptionsWrapper {
    get {
      OptionsWrapper(Options.opaquePersonality)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var strongMemory: OptionsWrapper {
    get {
      OptionsWrapper(Options.strongMemory)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var structPersonality: OptionsWrapper {
    get {
      OptionsWrapper(Options.structPersonality)
    }
  }

  @available(macOS, introduced: 10.8)
  @objc static public var weakMemory: OptionsWrapper {
    get {
      OptionsWrapper(Options.weakMemory)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: Options) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = Options()
  }

}

@objc public class MutabilityOptionsWrapper: NSObject {
  var wrappedInstance: MutabilityOptions

  @objc static public var mutableContainers: MutabilityOptionsWrapper {
    get {
      MutabilityOptionsWrapper(MutabilityOptions.mutableContainers)
    }
  }

  @objc static public var mutableContainersAndLeaves: MutabilityOptionsWrapper {
    get {
      MutabilityOptionsWrapper(MutabilityOptions.mutableContainersAndLeaves)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: MutabilityOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = MutabilityOptions()
  }

}

@objc public class OptionsWrapper11: NSObject {
  var wrappedInstance: Options

  @objc static public var allowCommentsAndWhitespace: OptionsWrapper11 {
    get {
      OptionsWrapper11(Options.allowCommentsAndWhitespace)
    }
  }

  @objc static public var anchorsMatchLines: OptionsWrapper11 {
    get {
      OptionsWrapper11(Options.anchorsMatchLines)
    }
  }

  @objc static public var caseInsensitive: OptionsWrapper11 {
    get {
      OptionsWrapper11(Options.caseInsensitive)
    }
  }

  @objc static public var dotMatchesLineSeparators: OptionsWrapper11 {
    get {
      OptionsWrapper11(Options.dotMatchesLineSeparators)
    }
  }

  @objc static public var ignoreMetacharacters: OptionsWrapper11 {
    get {
      OptionsWrapper11(Options.ignoreMetacharacters)
    }
  }

  @objc static public var useUnicodeWordBoundaries: OptionsWrapper11 {
    get {
      OptionsWrapper11(Options.useUnicodeWordBoundaries)
    }
  }

  @objc static public var useUnixLineSeparators: OptionsWrapper11 {
    get {
      OptionsWrapper11(Options.useUnixLineSeparators)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: Options) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = Options()
  }

}

@objc public class SearchPathDomainMaskWrapper: NSObject {
  var wrappedInstance: SearchPathDomainMask

  @objc static public var allDomainsMask: SearchPathDomainMaskWrapper {
    get {
      SearchPathDomainMaskWrapper(SearchPathDomainMask.allDomainsMask)
    }
  }

  @objc static public var localDomainMask: SearchPathDomainMaskWrapper {
    get {
      SearchPathDomainMaskWrapper(SearchPathDomainMask.localDomainMask)
    }
  }

  @objc static public var networkDomainMask: SearchPathDomainMaskWrapper {
    get {
      SearchPathDomainMaskWrapper(SearchPathDomainMask.networkDomainMask)
    }
  }

  @objc static public var systemDomainMask: SearchPathDomainMaskWrapper {
    get {
      SearchPathDomainMaskWrapper(SearchPathDomainMask.systemDomainMask)
    }
  }

  @objc static public var userDomainMask: SearchPathDomainMaskWrapper {
    get {
      SearchPathDomainMaskWrapper(SearchPathDomainMask.userDomainMask)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: SearchPathDomainMask) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = SearchPathDomainMask()
  }

}

@objc public class NSSortOptionsWrapper: NSObject {
  var wrappedInstance: NSSortOptions

  @objc static public var concurrent: NSSortOptionsWrapper {
    get {
      NSSortOptionsWrapper(NSSortOptions.concurrent)
    }
  }

  @objc static public var stable: NSSortOptionsWrapper {
    get {
      NSSortOptionsWrapper(NSSortOptions.stable)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: NSSortOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = NSSortOptions()
  }

}

@objc public class EventWrapper: NSObject {
  var wrappedInstance: Event

  @objc static public var endEncountered: EventWrapper {
    get {
      EventWrapper(Event.endEncountered)
    }
  }

  @objc static public var errorOccurred: EventWrapper {
    get {
      EventWrapper(Event.errorOccurred)
    }
  }

  @objc static public var hasBytesAvailable: EventWrapper {
    get {
      EventWrapper(Event.hasBytesAvailable)
    }
  }

  @objc static public var hasSpaceAvailable: EventWrapper {
    get {
      EventWrapper(Event.hasSpaceAvailable)
    }
  }

  @objc static public var openCompleted: EventWrapper {
    get {
      EventWrapper(Event.openCompleted)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: Event) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = Event()
  }

}

@objc public class CompareOptionsWrapper: NSObject {
  var wrappedInstance: CompareOptions

  @objc static public var anchored: CompareOptionsWrapper {
    get {
      CompareOptionsWrapper(CompareOptions.anchored)
    }
  }

  @objc static public var backwards: CompareOptionsWrapper {
    get {
      CompareOptionsWrapper(CompareOptions.backwards)
    }
  }

  @objc static public var caseInsensitive: CompareOptionsWrapper {
    get {
      CompareOptionsWrapper(CompareOptions.caseInsensitive)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var diacriticInsensitive: CompareOptionsWrapper {
    get {
      CompareOptionsWrapper(CompareOptions.diacriticInsensitive)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var forcedOrdering: CompareOptionsWrapper {
    get {
      CompareOptionsWrapper(CompareOptions.forcedOrdering)
    }
  }

  @objc static public var literal: CompareOptionsWrapper {
    get {
      CompareOptionsWrapper(CompareOptions.literal)
    }
  }

  @objc static public var numeric: CompareOptionsWrapper {
    get {
      CompareOptionsWrapper(CompareOptions.numeric)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var regularExpression: CompareOptionsWrapper {
    get {
      CompareOptionsWrapper(CompareOptions.regularExpression)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var widthInsensitive: CompareOptionsWrapper {
    get {
      CompareOptionsWrapper(CompareOptions.widthInsensitive)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: CompareOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = CompareOptions()
  }

}

@objc public class EncodingConversionOptionsWrapper: NSObject {
  var wrappedInstance: EncodingConversionOptions

  @objc static public var allowLossy: EncodingConversionOptionsWrapper {
    get {
      EncodingConversionOptionsWrapper(EncodingConversionOptions.allowLossy)
    }
  }

  @objc static public var externalRepresentation: EncodingConversionOptionsWrapper {
    get {
      EncodingConversionOptionsWrapper(EncodingConversionOptions.externalRepresentation)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: EncodingConversionOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = EncodingConversionOptions()
  }

}

@objc public class EnumerationOptionsWrapper1: NSObject {
  var wrappedInstance: EnumerationOptions

  @available(macOS, introduced: 11.0)
  @objc static public var byCaretPositions: EnumerationOptionsWrapper1 {
    get {
      EnumerationOptionsWrapper1(EnumerationOptions.byCaretPositions)
    }
  }

  @objc static public var byComposedCharacterSequences: EnumerationOptionsWrapper1 {
    get {
      EnumerationOptionsWrapper1(EnumerationOptions.byComposedCharacterSequences)
    }
  }

  @available(macOS, introduced: 11.0)
  @objc static public var byDeletionClusters: EnumerationOptionsWrapper1 {
    get {
      EnumerationOptionsWrapper1(EnumerationOptions.byDeletionClusters)
    }
  }

  @objc static public var byLines: EnumerationOptionsWrapper1 {
    get {
      EnumerationOptionsWrapper1(EnumerationOptions.byLines)
    }
  }

  @objc static public var byParagraphs: EnumerationOptionsWrapper1 {
    get {
      EnumerationOptionsWrapper1(EnumerationOptions.byParagraphs)
    }
  }

  @objc static public var bySentences: EnumerationOptionsWrapper1 {
    get {
      EnumerationOptionsWrapper1(EnumerationOptions.bySentences)
    }
  }

  @objc static public var byWords: EnumerationOptionsWrapper1 {
    get {
      EnumerationOptionsWrapper1(EnumerationOptions.byWords)
    }
  }

  @objc static public var localized: EnumerationOptionsWrapper1 {
    get {
      EnumerationOptionsWrapper1(EnumerationOptions.localized)
    }
  }

  @objc static public var reverse: EnumerationOptionsWrapper1 {
    get {
      EnumerationOptionsWrapper1(EnumerationOptions.reverse)
    }
  }

  @objc static public var substringNotRequired: EnumerationOptionsWrapper1 {
    get {
      EnumerationOptionsWrapper1(EnumerationOptions.substringNotRequired)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: EnumerationOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = EnumerationOptions()
  }

}

@objc public class CheckingTypeWrapper: NSObject {
  var wrappedInstance: CheckingType

  @objc static public var address: CheckingTypeWrapper {
    get {
      CheckingTypeWrapper(CheckingType.address)
    }
  }

  @objc static public var correction: CheckingTypeWrapper {
    get {
      CheckingTypeWrapper(CheckingType.correction)
    }
  }

  @objc static public var dash: CheckingTypeWrapper {
    get {
      CheckingTypeWrapper(CheckingType.dash)
    }
  }

  @objc static public var date: CheckingTypeWrapper {
    get {
      CheckingTypeWrapper(CheckingType.date)
    }
  }

  @objc static public var grammar: CheckingTypeWrapper {
    get {
      CheckingTypeWrapper(CheckingType.grammar)
    }
  }

  @objc static public var link: CheckingTypeWrapper {
    get {
      CheckingTypeWrapper(CheckingType.link)
    }
  }

  @objc static public var orthography: CheckingTypeWrapper {
    get {
      CheckingTypeWrapper(CheckingType.orthography)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var phoneNumber: CheckingTypeWrapper {
    get {
      CheckingTypeWrapper(CheckingType.phoneNumber)
    }
  }

  @objc static public var quote: CheckingTypeWrapper {
    get {
      CheckingTypeWrapper(CheckingType.quote)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var regularExpression: CheckingTypeWrapper {
    get {
      CheckingTypeWrapper(CheckingType.regularExpression)
    }
  }

  @objc static public var replacement: CheckingTypeWrapper {
    get {
      CheckingTypeWrapper(CheckingType.replacement)
    }
  }

  @objc static public var spelling: CheckingTypeWrapper {
    get {
      CheckingTypeWrapper(CheckingType.spelling)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var transitInformation: CheckingTypeWrapper {
    get {
      CheckingTypeWrapper(CheckingType.transitInformation)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var allCustomTypes: CheckingTypeWrapper {
    get {
      CheckingTypeWrapper(CheckingType.allCustomTypes)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var allSystemTypes: CheckingTypeWrapper {
    get {
      CheckingTypeWrapper(CheckingType.allSystemTypes)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var allTypes: CheckingTypeWrapper {
    get {
      CheckingTypeWrapper(CheckingType.allTypes)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: CheckingType) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = CheckingType()
  }

}

@available(macOS, introduced: 10.6)
@objc public class BookmarkCreationOptionsWrapper: NSObject {
  var wrappedInstance: BookmarkCreationOptions

  @available(macOS, introduced: 10.6)
  @objc static public var minimalBookmark: BookmarkCreationOptionsWrapper {
    get {
      BookmarkCreationOptionsWrapper(BookmarkCreationOptions.minimalBookmark)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var securityScopeAllowOnlyReadAccess: BookmarkCreationOptionsWrapper {
    get {
      BookmarkCreationOptionsWrapper(BookmarkCreationOptions.securityScopeAllowOnlyReadAccess)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var suitableForBookmarkFile: BookmarkCreationOptionsWrapper {
    get {
      BookmarkCreationOptionsWrapper(BookmarkCreationOptions.suitableForBookmarkFile)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var withSecurityScope: BookmarkCreationOptionsWrapper {
    get {
      BookmarkCreationOptionsWrapper(BookmarkCreationOptions.withSecurityScope)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var withoutImplicitSecurityScope: BookmarkCreationOptionsWrapper {
    get {
      BookmarkCreationOptionsWrapper(BookmarkCreationOptions.withoutImplicitSecurityScope)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: BookmarkCreationOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = BookmarkCreationOptions()
  }

}

@available(macOS, introduced: 10.6)
@objc public class BookmarkResolutionOptionsWrapper: NSObject {
  var wrappedInstance: BookmarkResolutionOptions

  @available(macOS, introduced: 10.7)
  @objc static public var withSecurityScope: BookmarkResolutionOptionsWrapper {
    get {
      BookmarkResolutionOptionsWrapper(BookmarkResolutionOptions.withSecurityScope)
    }
  }

  @available(macOS, introduced: 11.2)
  @objc static public var withoutImplicitStartAccessing: BookmarkResolutionOptionsWrapper {
    get {
      BookmarkResolutionOptionsWrapper(BookmarkResolutionOptions.withoutImplicitStartAccessing)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var withoutMounting: BookmarkResolutionOptionsWrapper {
    get {
      BookmarkResolutionOptionsWrapper(BookmarkResolutionOptions.withoutMounting)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var withoutUI: BookmarkResolutionOptionsWrapper {
    get {
      BookmarkResolutionOptionsWrapper(BookmarkResolutionOptions.withoutUI)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: BookmarkResolutionOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = BookmarkResolutionOptions()
  }

}

@available(macOS, introduced: 10.6)
@objc public class VolumeEnumerationOptionsWrapper: NSObject {
  var wrappedInstance: VolumeEnumerationOptions

  @available(macOS, introduced: 10.6)
  @objc static public var produceFileReferenceURLs: VolumeEnumerationOptionsWrapper {
    get {
      VolumeEnumerationOptionsWrapper(VolumeEnumerationOptions.produceFileReferenceURLs)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var skipHiddenVolumes: VolumeEnumerationOptionsWrapper {
    get {
      VolumeEnumerationOptionsWrapper(VolumeEnumerationOptions.skipHiddenVolumes)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: VolumeEnumerationOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = VolumeEnumerationOptions()
  }

}

@objc public class OptionsWrapper8: NSObject {
  var wrappedInstance: Options

  @objc static public var documentIncludeContentTypeDeclaration: OptionsWrapper8 {
    get {
      OptionsWrapper8(Options.documentIncludeContentTypeDeclaration)
    }
  }

  @objc static public var documentTidyHTML: OptionsWrapper8 {
    get {
      OptionsWrapper8(Options.documentTidyHTML)
    }
  }

  @objc static public var documentTidyXML: OptionsWrapper8 {
    get {
      OptionsWrapper8(Options.documentTidyXML)
    }
  }

  @objc static public var documentValidate: OptionsWrapper8 {
    get {
      OptionsWrapper8(Options.documentValidate)
    }
  }

  @objc static public var documentXInclude: OptionsWrapper8 {
    get {
      OptionsWrapper8(Options.documentXInclude)
    }
  }

  @objc static public var nodeCompactEmptyElement: OptionsWrapper8 {
    get {
      OptionsWrapper8(Options.nodeCompactEmptyElement)
    }
  }

  @objc static public var nodeExpandEmptyElement: OptionsWrapper8 {
    get {
      OptionsWrapper8(Options.nodeExpandEmptyElement)
    }
  }

  @objc static public var nodeIsCDATA: OptionsWrapper8 {
    get {
      OptionsWrapper8(Options.nodeIsCDATA)
    }
  }

  @objc static public var nodeLoadExternalEntitiesAlways: OptionsWrapper8 {
    get {
      OptionsWrapper8(Options.nodeLoadExternalEntitiesAlways)
    }
  }

  @objc static public var nodeLoadExternalEntitiesNever: OptionsWrapper8 {
    get {
      OptionsWrapper8(Options.nodeLoadExternalEntitiesNever)
    }
  }

  @objc static public var nodeLoadExternalEntitiesSameOriginOnly: OptionsWrapper8 {
    get {
      OptionsWrapper8(Options.nodeLoadExternalEntitiesSameOriginOnly)
    }
  }

  @objc static public var nodeNeverEscapeContents: OptionsWrapper8 {
    get {
      OptionsWrapper8(Options.nodeNeverEscapeContents)
    }
  }

  @objc static public var nodePreserveAll: OptionsWrapper8 {
    get {
      OptionsWrapper8(Options.nodePreserveAll)
    }
  }

  @objc static public var nodePreserveAttributeOrder: OptionsWrapper8 {
    get {
      OptionsWrapper8(Options.nodePreserveAttributeOrder)
    }
  }

  @objc static public var nodePreserveCDATA: OptionsWrapper8 {
    get {
      OptionsWrapper8(Options.nodePreserveCDATA)
    }
  }

  @objc static public var nodePreserveCharacterReferences: OptionsWrapper8 {
    get {
      OptionsWrapper8(Options.nodePreserveCharacterReferences)
    }
  }

  @objc static public var nodePreserveDTD: OptionsWrapper8 {
    get {
      OptionsWrapper8(Options.nodePreserveDTD)
    }
  }

  @objc static public var nodePreserveEmptyElements: OptionsWrapper8 {
    get {
      OptionsWrapper8(Options.nodePreserveEmptyElements)
    }
  }

  @objc static public var nodePreserveEntities: OptionsWrapper8 {
    get {
      OptionsWrapper8(Options.nodePreserveEntities)
    }
  }

  @objc static public var nodePreserveNamespaceOrder: OptionsWrapper8 {
    get {
      OptionsWrapper8(Options.nodePreserveNamespaceOrder)
    }
  }

  @objc static public var nodePreservePrefixes: OptionsWrapper8 {
    get {
      OptionsWrapper8(Options.nodePreservePrefixes)
    }
  }

  @objc static public var nodePreserveQuotes: OptionsWrapper8 {
    get {
      OptionsWrapper8(Options.nodePreserveQuotes)
    }
  }

  @objc static public var nodePreserveWhitespace: OptionsWrapper8 {
    get {
      OptionsWrapper8(Options.nodePreserveWhitespace)
    }
  }

  @objc static public var nodePrettyPrint: OptionsWrapper8 {
    get {
      OptionsWrapper8(Options.nodePrettyPrint)
    }
  }

  @objc static public var nodePromoteSignificantWhitespace: OptionsWrapper8 {
    get {
      OptionsWrapper8(Options.nodePromoteSignificantWhitespace)
    }
  }

  @objc static public var nodeUseDoubleQuotes: OptionsWrapper8 {
    get {
      OptionsWrapper8(Options.nodeUseDoubleQuotes)
    }
  }

  @objc static public var nodeUseSingleQuotes: OptionsWrapper8 {
    get {
      OptionsWrapper8(Options.nodeUseSingleQuotes)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: Options) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = Options()
  }

}

@available(macOS, introduced: 10.8)
@objc public class OptionsWrapper6: NSObject {
  var wrappedInstance: Options

  @available(macOS, introduced: 10.8)
  @objc static public var privileged: OptionsWrapper6 {
    get {
      OptionsWrapper6(Options.privileged)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: Options) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = Options()
  }

}

@available(macOS, introduced: 10.10)
@available(watchOS, introduced: 2.0)
@available(iOS, introduced: 8.0)
@available(tvOS, introduced: 9.0)
@objc public class NSKeyValueObservationWrapper: NSObject {
  var wrappedInstance: NSKeyValueObservation

  init(_ wrappedInstance: NSKeyValueObservation) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class NSEdgeInsetsWrapper: NSObject {
  var wrappedInstance: NSEdgeInsets

  @objc public var bottom: Double {
    get {
      wrappedInstance.bottom
    }
    set {
      wrappedInstance.bottom = newValue
    }
  }

  @objc public var left: Double {
    get {
      wrappedInstance.left
    }
    set {
      wrappedInstance.left = newValue
    }
  }

  @objc public var right: Double {
    get {
      wrappedInstance.right
    }
    set {
      wrappedInstance.right = newValue
    }
  }

  @objc public var top: Double {
    get {
      wrappedInstance.top
    }
    set {
      wrappedInstance.top = newValue
    }
  }

  init(_ wrappedInstance: NSEdgeInsets) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(top: Double, left: Double, bottom: Double, right: Double) {
    wrappedInstance = NSEdgeInsets(top: top, left: left, bottom: bottom, right: right)
  }

  @objc override init() {
    wrappedInstance = NSEdgeInsets()
  }

}

@objc public class NSAffineTransformStructWrapper: NSObject {
  var wrappedInstance: NSAffineTransformStruct

  @objc public var m11: Double {
    get {
      wrappedInstance.m11
    }
    set {
      wrappedInstance.m11 = newValue
    }
  }

  @objc public var m12: Double {
    get {
      wrappedInstance.m12
    }
    set {
      wrappedInstance.m12 = newValue
    }
  }

  @objc public var m21: Double {
    get {
      wrappedInstance.m21
    }
    set {
      wrappedInstance.m21 = newValue
    }
  }

  @objc public var m22: Double {
    get {
      wrappedInstance.m22
    }
    set {
      wrappedInstance.m22 = newValue
    }
  }

  @objc public var tX: Double {
    get {
      wrappedInstance.tX
    }
    set {
      wrappedInstance.tX = newValue
    }
  }

  @objc public var tY: Double {
    get {
      wrappedInstance.tY
    }
    set {
      wrappedInstance.tY = newValue
    }
  }

  init(_ wrappedInstance: NSAffineTransformStruct) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(m11: Double, m12: Double, m21: Double, m22: Double, tX: Double, tY: Double) {
    wrappedInstance = NSAffineTransformStruct(m11: m11, m12: m12, m21: m21, m22: m22, tX: tX, tY: tY)
  }

  @objc override init() {
    wrappedInstance = NSAffineTransformStruct()
  }

}

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
    @objc public var locale: Locale {
      get {
        wrappedInstance.locale
      }
      set {
        wrappedInstance.locale = newValue
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
    @objc public func locale(_ locale: Locale) -> DecimalWrapper.FormatStyleWrapper {
      let result = wrappedInstance.locale(locale)
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
      @objc public func locale(_ locale: Locale) -> FormatStyleWrapper.AttributedWrapper {
        let result = wrappedInstance.locale(locale)
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
      @objc public var locale: Locale {
        get {
          wrappedInstance.locale
        }
        set {
          wrappedInstance.locale = newValue
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
      @objc public func locale(_ locale: Locale) -> FormatStyleWrapper.PercentWrapper {
        let result = wrappedInstance.locale(locale)
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
      @objc public var locale: Locale {
        get {
          wrappedInstance.locale
        }
        set {
          wrappedInstance.locale = newValue
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
      @objc public func locale(_ locale: Locale) -> FormatStyleWrapper.CurrencyWrapper {
        let result = wrappedInstance.locale(locale)
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

@objc public class NSFastEnumerationStateWrapper: NSObject {
  var wrappedInstance: NSFastEnumerationState

  init(_ wrappedInstance: NSFastEnumerationState) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = NSFastEnumerationState()
  }

}

@objc public class NSHashEnumeratorWrapper: NSObject {
  var wrappedInstance: NSHashEnumerator

  init(_ wrappedInstance: NSHashEnumerator) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = NSHashEnumerator()
  }

}

@objc public class NSHashTableCallBacksWrapper: NSObject {
  var wrappedInstance: NSHashTableCallBacks

  init(_ wrappedInstance: NSHashTableCallBacks) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = NSHashTableCallBacks()
  }

}

@objc public class NSMapEnumeratorWrapper: NSObject {
  var wrappedInstance: NSMapEnumerator

  init(_ wrappedInstance: NSMapEnumerator) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = NSMapEnumerator()
  }

}

@objc public class NSMapTableKeyCallBacksWrapper: NSObject {
  var wrappedInstance: NSMapTableKeyCallBacks

  init(_ wrappedInstance: NSMapTableKeyCallBacks) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = NSMapTableKeyCallBacks()
  }

}

@objc public class NSMapTableValueCallBacksWrapper: NSObject {
  var wrappedInstance: NSMapTableValueCallBacks

  init(_ wrappedInstance: NSMapTableValueCallBacks) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = NSMapTableValueCallBacks()
  }

}

@objc public class OperatingSystemVersionWrapper: NSObject {
  var wrappedInstance: OperatingSystemVersion

  @objc public var majorVersion: Int {
    get {
      wrappedInstance.majorVersion
    }
    set {
      wrappedInstance.majorVersion = newValue
    }
  }

  @objc public var minorVersion: Int {
    get {
      wrappedInstance.minorVersion
    }
    set {
      wrappedInstance.minorVersion = newValue
    }
  }

  @objc public var patchVersion: Int {
    get {
      wrappedInstance.patchVersion
    }
    set {
      wrappedInstance.patchVersion = newValue
    }
  }

  init(_ wrappedInstance: OperatingSystemVersion) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(majorVersion: Int, minorVersion: Int, patchVersion: Int) {
    wrappedInstance = OperatingSystemVersion(majorVersion: majorVersion, minorVersion: minorVersion, patchVersion: patchVersion)
  }

  @objc override init() {
    wrappedInstance = OperatingSystemVersion()
  }

}

@objc public class NSSwappedDoubleWrapper: NSObject {
  var wrappedInstance: NSSwappedDouble

  init(_ wrappedInstance: NSSwappedDouble) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = NSSwappedDouble()
  }

}

@objc public class NSSwappedFloatWrapper: NSObject {
  var wrappedInstance: NSSwappedFloat

  init(_ wrappedInstance: NSSwappedFloat) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = NSSwappedFloat()
  }

}

@objc public class NSAttributedStringFormattingContextKeyWrapper: NSObject {
  var wrappedInstance: NSAttributedStringFormattingContextKey

  @available(macOS, introduced: 14.0)
  @objc static public var inflectionConceptsKey: NSAttributedStringFormattingContextKeyWrapper {
    get {
      NSAttributedStringFormattingContextKeyWrapper(NSAttributedStringFormattingContextKey.inflectionConceptsKey)
    }
  }

  init(_ wrappedInstance: NSAttributedStringFormattingContextKey) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = NSAttributedStringFormattingContextKey(rawValue: rawValue)
  }

  @objc init(_ rawValue: String) {
    wrappedInstance = NSAttributedStringFormattingContextKey(rawValue)
  }

}

@objc public class KeyWrapper1: NSObject {
  var wrappedInstance: Key

  @available(macOS, introduced: 12.0)
  @objc static public var alternateDescription: KeyWrapper1 {
    get {
      KeyWrapper1(Key.alternateDescription)
    }
  }

  @available(macOS, introduced: 12.0)
  @objc static public var imageURL: KeyWrapper1 {
    get {
      KeyWrapper1(Key.imageURL)
    }
  }

  @available(macOS, introduced: 14.0)
  @objc static public var agreeWithArgument: KeyWrapper1 {
    get {
      KeyWrapper1(Key.agreeWithArgument)
    }
  }

  @available(macOS, introduced: 14.0)
  @objc static public var agreeWithConcept: KeyWrapper1 {
    get {
      KeyWrapper1(Key.agreeWithConcept)
    }
  }

  @available(macOS, introduced: 12.0)
  @objc static public var inflectionAlternative: KeyWrapper1 {
    get {
      KeyWrapper1(Key.inflectionAlternative)
    }
  }

  @available(macOS, introduced: 14.0)
  @objc static public var referentConcept: KeyWrapper1 {
    get {
      KeyWrapper1(Key.referentConcept)
    }
  }

  @available(macOS, introduced: 12.0)
  @objc static public var inflectionRule: KeyWrapper1 {
    get {
      KeyWrapper1(Key.inflectionRule)
    }
  }

  @available(macOS, introduced: 12.0)
  @objc static public var inlinePresentationIntent: KeyWrapper1 {
    get {
      KeyWrapper1(Key.inlinePresentationIntent)
    }
  }

  @available(macOS, introduced: 12.0)
  @objc static public var languageIdentifier: KeyWrapper1 {
    get {
      KeyWrapper1(Key.languageIdentifier)
    }
  }

  @available(macOS, introduced: 15.0)
  @objc static public var localizedNumberFormat: KeyWrapper1 {
    get {
      KeyWrapper1(Key.localizedNumberFormat)
    }
  }

  @available(macOS, introduced: 13.0)
  @objc static public var markdownSourcePosition: KeyWrapper1 {
    get {
      KeyWrapper1(Key.markdownSourcePosition)
    }
  }

  @available(macOS, introduced: 12.0)
  @objc static public var morphology: KeyWrapper1 {
    get {
      KeyWrapper1(Key.morphology)
    }
  }

  @available(macOS, introduced: 12.0)
  @objc static public var presentationIntentAttributeName: KeyWrapper1 {
    get {
      KeyWrapper1(Key.presentationIntentAttributeName)
    }
  }

  @available(macOS, introduced: 12.0)
  @objc static public var replacementIndex: KeyWrapper1 {
    get {
      KeyWrapper1(Key.replacementIndex)
    }
  }

  init(_ wrappedInstance: Key) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = Key(rawValue: rawValue)
  }

  @objc init(_ rawValue: String) {
    wrappedInstance = Key(rawValue)
  }

}

@objc public class IdentifierWrapper: NSObject {
  var wrappedInstance: Identifier

  @available(macOS, introduced: 10.6)
  @objc static public var buddhist: IdentifierWrapper {
    get {
      IdentifierWrapper(Identifier.buddhist)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var chinese: IdentifierWrapper {
    get {
      IdentifierWrapper(Identifier.chinese)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var coptic: IdentifierWrapper {
    get {
      IdentifierWrapper(Identifier.coptic)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var ethiopicAmeteAlem: IdentifierWrapper {
    get {
      IdentifierWrapper(Identifier.ethiopicAmeteAlem)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var ethiopicAmeteMihret: IdentifierWrapper {
    get {
      IdentifierWrapper(Identifier.ethiopicAmeteMihret)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var gregorian: IdentifierWrapper {
    get {
      IdentifierWrapper(Identifier.gregorian)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var hebrew: IdentifierWrapper {
    get {
      IdentifierWrapper(Identifier.hebrew)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var ISO8601: IdentifierWrapper {
    get {
      IdentifierWrapper(Identifier.ISO8601)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var indian: IdentifierWrapper {
    get {
      IdentifierWrapper(Identifier.indian)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var islamic: IdentifierWrapper {
    get {
      IdentifierWrapper(Identifier.islamic)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var islamicCivil: IdentifierWrapper {
    get {
      IdentifierWrapper(Identifier.islamicCivil)
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var islamicTabular: IdentifierWrapper {
    get {
      IdentifierWrapper(Identifier.islamicTabular)
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var islamicUmmAlQura: IdentifierWrapper {
    get {
      IdentifierWrapper(Identifier.islamicUmmAlQura)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var japanese: IdentifierWrapper {
    get {
      IdentifierWrapper(Identifier.japanese)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var persian: IdentifierWrapper {
    get {
      IdentifierWrapper(Identifier.persian)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var republicOfChina: IdentifierWrapper {
    get {
      IdentifierWrapper(Identifier.republicOfChina)
    }
  }

  init(_ wrappedInstance: Identifier) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = Identifier(rawValue: rawValue)
  }

  @objc init(_ rawValue: String) {
    wrappedInstance = Identifier(rawValue)
  }

}

@objc public class CenterTypeWrapper: NSObject {
  var wrappedInstance: CenterType

  @objc static public var localNotificationCenterType: CenterTypeWrapper {
    get {
      CenterTypeWrapper(CenterType.localNotificationCenterType)
    }
  }

  init(_ wrappedInstance: CenterType) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = CenterType(rawValue: rawValue)
  }

  @objc init(_ rawValue: String) {
    wrappedInstance = CenterType(rawValue)
  }

}

@objc public class NSExceptionNameWrapper: NSObject {
  var wrappedInstance: NSExceptionName

  @objc static public var characterConversionException: NSExceptionNameWrapper {
    get {
      NSExceptionNameWrapper(NSExceptionName.characterConversionException)
    }
  }

  @objc static public var decimalNumberDivideByZeroException: NSExceptionNameWrapper {
    get {
      NSExceptionNameWrapper(NSExceptionName.decimalNumberDivideByZeroException)
    }
  }

  @objc static public var decimalNumberExactnessException: NSExceptionNameWrapper {
    get {
      NSExceptionNameWrapper(NSExceptionName.decimalNumberExactnessException)
    }
  }

  @objc static public var decimalNumberOverflowException: NSExceptionNameWrapper {
    get {
      NSExceptionNameWrapper(NSExceptionName.decimalNumberOverflowException)
    }
  }

  @objc static public var decimalNumberUnderflowException: NSExceptionNameWrapper {
    get {
      NSExceptionNameWrapper(NSExceptionName.decimalNumberUnderflowException)
    }
  }

  @objc static public var destinationInvalidException: NSExceptionNameWrapper {
    get {
      NSExceptionNameWrapper(NSExceptionName.destinationInvalidException)
    }
  }

  @objc static public var fileHandleOperationException: NSExceptionNameWrapper {
    get {
      NSExceptionNameWrapper(NSExceptionName.fileHandleOperationException)
    }
  }

  @objc static public var genericException: NSExceptionNameWrapper {
    get {
      NSExceptionNameWrapper(NSExceptionName.genericException)
    }
  }

  @objc static public var inconsistentArchiveException: NSExceptionNameWrapper {
    get {
      NSExceptionNameWrapper(NSExceptionName.inconsistentArchiveException)
    }
  }

  @objc static public var internalInconsistencyException: NSExceptionNameWrapper {
    get {
      NSExceptionNameWrapper(NSExceptionName.internalInconsistencyException)
    }
  }

  @objc static public var invalidArchiveOperationException: NSExceptionNameWrapper {
    get {
      NSExceptionNameWrapper(NSExceptionName.invalidArchiveOperationException)
    }
  }

  @objc static public var invalidArgumentException: NSExceptionNameWrapper {
    get {
      NSExceptionNameWrapper(NSExceptionName.invalidArgumentException)
    }
  }

  @objc static public var invalidReceivePortException: NSExceptionNameWrapper {
    get {
      NSExceptionNameWrapper(NSExceptionName.invalidReceivePortException)
    }
  }

  @objc static public var invalidSendPortException: NSExceptionNameWrapper {
    get {
      NSExceptionNameWrapper(NSExceptionName.invalidSendPortException)
    }
  }

  @objc static public var invalidUnarchiveOperationException: NSExceptionNameWrapper {
    get {
      NSExceptionNameWrapper(NSExceptionName.invalidUnarchiveOperationException)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var invocationOperationCancelledException: NSExceptionNameWrapper {
    get {
      NSExceptionNameWrapper(NSExceptionName.invocationOperationCancelledException)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var invocationOperationVoidResultException: NSExceptionNameWrapper {
    get {
      NSExceptionNameWrapper(NSExceptionName.invocationOperationVoidResultException)
    }
  }

  @objc static public var mallocException: NSExceptionNameWrapper {
    get {
      NSExceptionNameWrapper(NSExceptionName.mallocException)
    }
  }

  @objc static public var objectInaccessibleException: NSExceptionNameWrapper {
    get {
      NSExceptionNameWrapper(NSExceptionName.objectInaccessibleException)
    }
  }

  @objc static public var objectNotAvailableException: NSExceptionNameWrapper {
    get {
      NSExceptionNameWrapper(NSExceptionName.objectNotAvailableException)
    }
  }

  @objc static public var oldStyleException: NSExceptionNameWrapper {
    get {
      NSExceptionNameWrapper(NSExceptionName.oldStyleException)
    }
  }

  @objc static public var parseErrorException: NSExceptionNameWrapper {
    get {
      NSExceptionNameWrapper(NSExceptionName.parseErrorException)
    }
  }

  @objc static public var portReceiveException: NSExceptionNameWrapper {
    get {
      NSExceptionNameWrapper(NSExceptionName.portReceiveException)
    }
  }

  @objc static public var portSendException: NSExceptionNameWrapper {
    get {
      NSExceptionNameWrapper(NSExceptionName.portSendException)
    }
  }

  @objc static public var portTimeoutException: NSExceptionNameWrapper {
    get {
      NSExceptionNameWrapper(NSExceptionName.portTimeoutException)
    }
  }

  @objc static public var rangeException: NSExceptionNameWrapper {
    get {
      NSExceptionNameWrapper(NSExceptionName.rangeException)
    }
  }

  @objc static public var undefinedKeyException: NSExceptionNameWrapper {
    get {
      NSExceptionNameWrapper(NSExceptionName.undefinedKeyException)
    }
  }

  init(_ wrappedInstance: NSExceptionName) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = NSExceptionName(rawValue: rawValue)
  }

  @objc init(_ rawValue: String) {
    wrappedInstance = NSExceptionName(rawValue)
  }

}

@objc public class FileAttributeKeyWrapper: NSObject {
  var wrappedInstance: FileAttributeKey

  @objc static public var appendOnly: FileAttributeKeyWrapper {
    get {
      FileAttributeKeyWrapper(FileAttributeKey.appendOnly)
    }
  }

  @objc static public var busy: FileAttributeKeyWrapper {
    get {
      FileAttributeKeyWrapper(FileAttributeKey.busy)
    }
  }

  @objc static public var creationDate: FileAttributeKeyWrapper {
    get {
      FileAttributeKeyWrapper(FileAttributeKey.creationDate)
    }
  }

  @objc static public var deviceIdentifier: FileAttributeKeyWrapper {
    get {
      FileAttributeKeyWrapper(FileAttributeKey.deviceIdentifier)
    }
  }

  @objc static public var extensionHidden: FileAttributeKeyWrapper {
    get {
      FileAttributeKeyWrapper(FileAttributeKey.extensionHidden)
    }
  }

  @objc static public var groupOwnerAccountID: FileAttributeKeyWrapper {
    get {
      FileAttributeKeyWrapper(FileAttributeKey.groupOwnerAccountID)
    }
  }

  @objc static public var groupOwnerAccountName: FileAttributeKeyWrapper {
    get {
      FileAttributeKeyWrapper(FileAttributeKey.groupOwnerAccountName)
    }
  }

  @objc static public var hfsCreatorCode: FileAttributeKeyWrapper {
    get {
      FileAttributeKeyWrapper(FileAttributeKey.hfsCreatorCode)
    }
  }

  @objc static public var hfsTypeCode: FileAttributeKeyWrapper {
    get {
      FileAttributeKeyWrapper(FileAttributeKey.hfsTypeCode)
    }
  }

  @objc static public var immutable: FileAttributeKeyWrapper {
    get {
      FileAttributeKeyWrapper(FileAttributeKey.immutable)
    }
  }

  @objc static public var modificationDate: FileAttributeKeyWrapper {
    get {
      FileAttributeKeyWrapper(FileAttributeKey.modificationDate)
    }
  }

  @objc static public var ownerAccountID: FileAttributeKeyWrapper {
    get {
      FileAttributeKeyWrapper(FileAttributeKey.ownerAccountID)
    }
  }

  @objc static public var ownerAccountName: FileAttributeKeyWrapper {
    get {
      FileAttributeKeyWrapper(FileAttributeKey.ownerAccountName)
    }
  }

  @objc static public var posixPermissions: FileAttributeKeyWrapper {
    get {
      FileAttributeKeyWrapper(FileAttributeKey.posixPermissions)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var protectionKey: FileAttributeKeyWrapper {
    get {
      FileAttributeKeyWrapper(FileAttributeKey.protectionKey)
    }
  }

  @objc static public var referenceCount: FileAttributeKeyWrapper {
    get {
      FileAttributeKeyWrapper(FileAttributeKey.referenceCount)
    }
  }

  @objc static public var size: FileAttributeKeyWrapper {
    get {
      FileAttributeKeyWrapper(FileAttributeKey.size)
    }
  }

  @objc static public var systemFileNumber: FileAttributeKeyWrapper {
    get {
      FileAttributeKeyWrapper(FileAttributeKey.systemFileNumber)
    }
  }

  @objc static public var systemFreeNodes: FileAttributeKeyWrapper {
    get {
      FileAttributeKeyWrapper(FileAttributeKey.systemFreeNodes)
    }
  }

  @objc static public var systemFreeSize: FileAttributeKeyWrapper {
    get {
      FileAttributeKeyWrapper(FileAttributeKey.systemFreeSize)
    }
  }

  @objc static public var systemNodes: FileAttributeKeyWrapper {
    get {
      FileAttributeKeyWrapper(FileAttributeKey.systemNodes)
    }
  }

  @objc static public var systemNumber: FileAttributeKeyWrapper {
    get {
      FileAttributeKeyWrapper(FileAttributeKey.systemNumber)
    }
  }

  @objc static public var systemSize: FileAttributeKeyWrapper {
    get {
      FileAttributeKeyWrapper(FileAttributeKey.systemSize)
    }
  }

  @objc static public var type: FileAttributeKeyWrapper {
    get {
      FileAttributeKeyWrapper(FileAttributeKey.type)
    }
  }

  init(_ wrappedInstance: FileAttributeKey) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = FileAttributeKey(rawValue: rawValue)
  }

  @objc init(_ rawValue: String) {
    wrappedInstance = FileAttributeKey(rawValue)
  }

}

@objc public class FileAttributeTypeWrapper: NSObject {
  var wrappedInstance: FileAttributeType

  @objc static public var typeBlockSpecial: FileAttributeTypeWrapper {
    get {
      FileAttributeTypeWrapper(FileAttributeType.typeBlockSpecial)
    }
  }

  @objc static public var typeCharacterSpecial: FileAttributeTypeWrapper {
    get {
      FileAttributeTypeWrapper(FileAttributeType.typeCharacterSpecial)
    }
  }

  @objc static public var typeDirectory: FileAttributeTypeWrapper {
    get {
      FileAttributeTypeWrapper(FileAttributeType.typeDirectory)
    }
  }

  @objc static public var typeRegular: FileAttributeTypeWrapper {
    get {
      FileAttributeTypeWrapper(FileAttributeType.typeRegular)
    }
  }

  @objc static public var typeSocket: FileAttributeTypeWrapper {
    get {
      FileAttributeTypeWrapper(FileAttributeType.typeSocket)
    }
  }

  @objc static public var typeSymbolicLink: FileAttributeTypeWrapper {
    get {
      FileAttributeTypeWrapper(FileAttributeType.typeSymbolicLink)
    }
  }

  @objc static public var typeUnknown: FileAttributeTypeWrapper {
    get {
      FileAttributeTypeWrapper(FileAttributeType.typeUnknown)
    }
  }

  init(_ wrappedInstance: FileAttributeType) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = FileAttributeType(rawValue: rawValue)
  }

}

@objc public class FileProtectionTypeWrapper: NSObject {
  var wrappedInstance: FileProtectionType

  @available(macOS, introduced: 10.6)
  @objc static public var complete: FileProtectionTypeWrapper {
    get {
      FileProtectionTypeWrapper(FileProtectionType.complete)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var completeUnlessOpen: FileProtectionTypeWrapper {
    get {
      FileProtectionTypeWrapper(FileProtectionType.completeUnlessOpen)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var completeUntilFirstUserAuthentication: FileProtectionTypeWrapper {
    get {
      FileProtectionTypeWrapper(FileProtectionType.completeUntilFirstUserAuthentication)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var none: FileProtectionTypeWrapper {
    get {
      FileProtectionTypeWrapper(FileProtectionType.none)
    }
  }

  init(_ wrappedInstance: FileProtectionType) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = FileProtectionType(rawValue: rawValue)
  }

}

@objc public class NSFileProviderServiceNameWrapper: NSObject {
  var wrappedInstance: NSFileProviderServiceName

  init(_ wrappedInstance: NSFileProviderServiceName) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = NSFileProviderServiceName(rawValue: rawValue)
  }

  @objc init(_ rawValue: String) {
    wrappedInstance = NSFileProviderServiceName(rawValue)
  }

}

@objc public class HTTPCookiePropertyKeyWrapper: NSObject {
  var wrappedInstance: HTTPCookiePropertyKey

  @available(macOS, introduced: 10.2)
  @objc static public var comment: HTTPCookiePropertyKeyWrapper {
    get {
      HTTPCookiePropertyKeyWrapper(HTTPCookiePropertyKey.comment)
    }
  }

  @available(macOS, introduced: 10.2)
  @objc static public var commentURL: HTTPCookiePropertyKeyWrapper {
    get {
      HTTPCookiePropertyKeyWrapper(HTTPCookiePropertyKey.commentURL)
    }
  }

  @available(macOS, introduced: 10.2)
  @objc static public var discard: HTTPCookiePropertyKeyWrapper {
    get {
      HTTPCookiePropertyKeyWrapper(HTTPCookiePropertyKey.discard)
    }
  }

  @available(macOS, introduced: 10.2)
  @objc static public var domain: HTTPCookiePropertyKeyWrapper {
    get {
      HTTPCookiePropertyKeyWrapper(HTTPCookiePropertyKey.domain)
    }
  }

  @available(macOS, introduced: 10.2)
  @objc static public var expires: HTTPCookiePropertyKeyWrapper {
    get {
      HTTPCookiePropertyKeyWrapper(HTTPCookiePropertyKey.expires)
    }
  }

  @available(macOS, introduced: 10.2)
  @objc static public var maximumAge: HTTPCookiePropertyKeyWrapper {
    get {
      HTTPCookiePropertyKeyWrapper(HTTPCookiePropertyKey.maximumAge)
    }
  }

  @available(macOS, introduced: 10.2)
  @objc static public var name: HTTPCookiePropertyKeyWrapper {
    get {
      HTTPCookiePropertyKeyWrapper(HTTPCookiePropertyKey.name)
    }
  }

  @available(macOS, introduced: 10.2)
  @objc static public var originURL: HTTPCookiePropertyKeyWrapper {
    get {
      HTTPCookiePropertyKeyWrapper(HTTPCookiePropertyKey.originURL)
    }
  }

  @available(macOS, introduced: 10.2)
  @objc static public var path: HTTPCookiePropertyKeyWrapper {
    get {
      HTTPCookiePropertyKeyWrapper(HTTPCookiePropertyKey.path)
    }
  }

  @available(macOS, introduced: 10.2)
  @objc static public var port: HTTPCookiePropertyKeyWrapper {
    get {
      HTTPCookiePropertyKeyWrapper(HTTPCookiePropertyKey.port)
    }
  }

  @available(macOS, introduced: 10.15)
  @objc static public var sameSitePolicy: HTTPCookiePropertyKeyWrapper {
    get {
      HTTPCookiePropertyKeyWrapper(HTTPCookiePropertyKey.sameSitePolicy)
    }
  }

  @available(macOS, introduced: 10.2)
  @objc static public var secure: HTTPCookiePropertyKeyWrapper {
    get {
      HTTPCookiePropertyKeyWrapper(HTTPCookiePropertyKey.secure)
    }
  }

  @available(macOS, introduced: 15.2)
  @objc static public var setByJavaScript: HTTPCookiePropertyKeyWrapper {
    get {
      HTTPCookiePropertyKeyWrapper(HTTPCookiePropertyKey.setByJavaScript)
    }
  }

  @available(macOS, introduced: 10.2)
  @objc static public var value: HTTPCookiePropertyKeyWrapper {
    get {
      HTTPCookiePropertyKeyWrapper(HTTPCookiePropertyKey.value)
    }
  }

  @available(macOS, introduced: 10.2)
  @objc static public var version: HTTPCookiePropertyKeyWrapper {
    get {
      HTTPCookiePropertyKeyWrapper(HTTPCookiePropertyKey.version)
    }
  }

  init(_ wrappedInstance: HTTPCookiePropertyKey) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = HTTPCookiePropertyKey(rawValue: rawValue)
  }

  @objc init(_ rawValue: String) {
    wrappedInstance = HTTPCookiePropertyKey(rawValue)
  }

}

@objc public class HTTPCookieStringPolicyWrapper: NSObject {
  var wrappedInstance: HTTPCookieStringPolicy

  @available(macOS, introduced: 10.15)
  @objc static public var sameSiteLax: HTTPCookieStringPolicyWrapper {
    get {
      HTTPCookieStringPolicyWrapper(HTTPCookieStringPolicy.sameSiteLax)
    }
  }

  @available(macOS, introduced: 10.15)
  @objc static public var sameSiteStrict: HTTPCookieStringPolicyWrapper {
    get {
      HTTPCookieStringPolicyWrapper(HTTPCookieStringPolicy.sameSiteStrict)
    }
  }

  init(_ wrappedInstance: HTTPCookieStringPolicy) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = HTTPCookieStringPolicy(rawValue: rawValue)
  }

}

@objc public class NSKeyValueChangeKeyWrapper: NSObject {
  var wrappedInstance: NSKeyValueChangeKey

  @objc static public var indexesKey: NSKeyValueChangeKeyWrapper {
    get {
      NSKeyValueChangeKeyWrapper(NSKeyValueChangeKey.indexesKey)
    }
  }

  @objc static public var kindKey: NSKeyValueChangeKeyWrapper {
    get {
      NSKeyValueChangeKeyWrapper(NSKeyValueChangeKey.kindKey)
    }
  }

  @objc static public var newKey: NSKeyValueChangeKeyWrapper {
    get {
      NSKeyValueChangeKeyWrapper(NSKeyValueChangeKey.newKey)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var notificationIsPriorKey: NSKeyValueChangeKeyWrapper {
    get {
      NSKeyValueChangeKeyWrapper(NSKeyValueChangeKey.notificationIsPriorKey)
    }
  }

  @objc static public var oldKey: NSKeyValueChangeKeyWrapper {
    get {
      NSKeyValueChangeKeyWrapper(NSKeyValueChangeKey.oldKey)
    }
  }

  init(_ wrappedInstance: NSKeyValueChangeKey) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = NSKeyValueChangeKey(rawValue: rawValue)
  }

}

@objc public class NSKeyValueOperatorWrapper: NSObject {
  var wrappedInstance: NSKeyValueOperator

  @objc static public var averageKeyValueOperator: NSKeyValueOperatorWrapper {
    get {
      NSKeyValueOperatorWrapper(NSKeyValueOperator.averageKeyValueOperator)
    }
  }

  @objc static public var countKeyValueOperator: NSKeyValueOperatorWrapper {
    get {
      NSKeyValueOperatorWrapper(NSKeyValueOperator.countKeyValueOperator)
    }
  }

  @objc static public var distinctUnionOfArraysKeyValueOperator: NSKeyValueOperatorWrapper {
    get {
      NSKeyValueOperatorWrapper(NSKeyValueOperator.distinctUnionOfArraysKeyValueOperator)
    }
  }

  @objc static public var distinctUnionOfObjectsKeyValueOperator: NSKeyValueOperatorWrapper {
    get {
      NSKeyValueOperatorWrapper(NSKeyValueOperator.distinctUnionOfObjectsKeyValueOperator)
    }
  }

  @objc static public var distinctUnionOfSetsKeyValueOperator: NSKeyValueOperatorWrapper {
    get {
      NSKeyValueOperatorWrapper(NSKeyValueOperator.distinctUnionOfSetsKeyValueOperator)
    }
  }

  @objc static public var maximumKeyValueOperator: NSKeyValueOperatorWrapper {
    get {
      NSKeyValueOperatorWrapper(NSKeyValueOperator.maximumKeyValueOperator)
    }
  }

  @objc static public var minimumKeyValueOperator: NSKeyValueOperatorWrapper {
    get {
      NSKeyValueOperatorWrapper(NSKeyValueOperator.minimumKeyValueOperator)
    }
  }

  @objc static public var sumKeyValueOperator: NSKeyValueOperatorWrapper {
    get {
      NSKeyValueOperatorWrapper(NSKeyValueOperator.sumKeyValueOperator)
    }
  }

  @objc static public var unionOfArraysKeyValueOperator: NSKeyValueOperatorWrapper {
    get {
      NSKeyValueOperatorWrapper(NSKeyValueOperator.unionOfArraysKeyValueOperator)
    }
  }

  @objc static public var unionOfObjectsKeyValueOperator: NSKeyValueOperatorWrapper {
    get {
      NSKeyValueOperatorWrapper(NSKeyValueOperator.unionOfObjectsKeyValueOperator)
    }
  }

  @objc static public var unionOfSetsKeyValueOperator: NSKeyValueOperatorWrapper {
    get {
      NSKeyValueOperatorWrapper(NSKeyValueOperator.unionOfSetsKeyValueOperator)
    }
  }

  init(_ wrappedInstance: NSKeyValueOperator) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = NSKeyValueOperator(rawValue: rawValue)
  }

}

@objc public class NSLinguisticTagWrapper: NSObject {
  var wrappedInstance: NSLinguisticTag

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var adjective: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.adjective)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var adverb: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.adverb)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var classifier: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.classifier)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var closeParenthesis: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.closeParenthesis)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var closeQuote: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.closeQuote)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var conjunction: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.conjunction)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var dash: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.dash)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var determiner: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.determiner)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var idiom: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.idiom)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var interjection: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.interjection)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var noun: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.noun)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var number: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.number)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var openParenthesis: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.openParenthesis)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var openQuote: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.openQuote)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var organizationName: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.organizationName)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var other: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.other)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var otherPunctuation: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.otherPunctuation)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var otherWhitespace: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.otherWhitespace)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var otherWord: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.otherWord)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var paragraphBreak: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.paragraphBreak)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var particle: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.particle)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var personalName: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.personalName)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var placeName: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.placeName)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var preposition: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.preposition)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var pronoun: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.pronoun)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var punctuation: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.punctuation)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var sentenceTerminator: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.sentenceTerminator)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var verb: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.verb)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var whitespace: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.whitespace)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var word: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.word)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var wordJoiner: NSLinguisticTagWrapper {
    get {
      NSLinguisticTagWrapper(NSLinguisticTag.wordJoiner)
    }
  }

  init(_ wrappedInstance: NSLinguisticTag) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = NSLinguisticTag(rawValue: rawValue)
  }

  @objc init(_ rawValue: String) {
    wrappedInstance = NSLinguisticTag(rawValue)
  }

}

@objc public class NSLinguisticTagSchemeWrapper: NSObject {
  var wrappedInstance: NSLinguisticTagScheme

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var language: NSLinguisticTagSchemeWrapper {
    get {
      NSLinguisticTagSchemeWrapper(NSLinguisticTagScheme.language)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var lemma: NSLinguisticTagSchemeWrapper {
    get {
      NSLinguisticTagSchemeWrapper(NSLinguisticTagScheme.lemma)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var lexicalClass: NSLinguisticTagSchemeWrapper {
    get {
      NSLinguisticTagSchemeWrapper(NSLinguisticTagScheme.lexicalClass)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var nameType: NSLinguisticTagSchemeWrapper {
    get {
      NSLinguisticTagSchemeWrapper(NSLinguisticTagScheme.nameType)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var nameTypeOrLexicalClass: NSLinguisticTagSchemeWrapper {
    get {
      NSLinguisticTagSchemeWrapper(NSLinguisticTagScheme.nameTypeOrLexicalClass)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var script: NSLinguisticTagSchemeWrapper {
    get {
      NSLinguisticTagSchemeWrapper(NSLinguisticTagScheme.script)
    }
  }

  @available(macOS, introduced: 10.7, deprecated: 100000)
  @objc static public var tokenType: NSLinguisticTagSchemeWrapper {
    get {
      NSLinguisticTagSchemeWrapper(NSLinguisticTagScheme.tokenType)
    }
  }

  init(_ wrappedInstance: NSLinguisticTagScheme) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = NSLinguisticTagScheme(rawValue: rawValue)
  }

  @objc init(_ rawValue: String) {
    wrappedInstance = NSLinguisticTagScheme(rawValue)
  }

}

@objc public class KeyWrapper: NSObject {
  var wrappedInstance: Key

  @available(macOS, introduced: 10.6)
  @objc static public var alternateQuotationBeginDelimiterKey: KeyWrapper {
    get {
      KeyWrapper(Key.alternateQuotationBeginDelimiterKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var alternateQuotationEndDelimiterKey: KeyWrapper {
    get {
      KeyWrapper(Key.alternateQuotationEndDelimiterKey)
    }
  }

  @objc static public var calendar: KeyWrapper {
    get {
      KeyWrapper(Key.calendar)
    }
  }

  @objc static public var collationIdentifier: KeyWrapper {
    get {
      KeyWrapper(Key.collationIdentifier)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var collatorIdentifier: KeyWrapper {
    get {
      KeyWrapper(Key.collatorIdentifier)
    }
  }

  @objc static public var countryCode: KeyWrapper {
    get {
      KeyWrapper(Key.countryCode)
    }
  }

  @objc static public var currencyCode: KeyWrapper {
    get {
      KeyWrapper(Key.currencyCode)
    }
  }

  @objc static public var currencySymbol: KeyWrapper {
    get {
      KeyWrapper(Key.currencySymbol)
    }
  }

  @objc static public var decimalSeparator: KeyWrapper {
    get {
      KeyWrapper(Key.decimalSeparator)
    }
  }

  @objc static public var exemplarCharacterSet: KeyWrapper {
    get {
      KeyWrapper(Key.exemplarCharacterSet)
    }
  }

  @objc static public var groupingSeparator: KeyWrapper {
    get {
      KeyWrapper(Key.groupingSeparator)
    }
  }

  @objc static public var identifier: KeyWrapper {
    get {
      KeyWrapper(Key.identifier)
    }
  }

  @objc static public var languageCode: KeyWrapper {
    get {
      KeyWrapper(Key.languageCode)
    }
  }

  @objc static public var measurementSystem: KeyWrapper {
    get {
      KeyWrapper(Key.measurementSystem)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var quotationBeginDelimiterKey: KeyWrapper {
    get {
      KeyWrapper(Key.quotationBeginDelimiterKey)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var quotationEndDelimiterKey: KeyWrapper {
    get {
      KeyWrapper(Key.quotationEndDelimiterKey)
    }
  }

  @objc static public var scriptCode: KeyWrapper {
    get {
      KeyWrapper(Key.scriptCode)
    }
  }

  @objc static public var usesMetricSystem: KeyWrapper {
    get {
      KeyWrapper(Key.usesMetricSystem)
    }
  }

  @objc static public var variantCode: KeyWrapper {
    get {
      KeyWrapper(Key.variantCode)
    }
  }

  init(_ wrappedInstance: Key) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = Key(rawValue: rawValue)
  }

}

@objc public class NameWrapper: NSObject {
  var wrappedInstance: Name

  @objc static public var NSAppleEventManagerWillProcessFirstEvent: NameWrapper {
    get {
      NameWrapper(Name.NSAppleEventManagerWillProcessFirstEvent)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSCalendarDayChanged: NameWrapper {
    get {
      NameWrapper(Name.NSCalendarDayChanged)
    }
  }

  @objc static public var NSClassDescriptionNeededForClass: NameWrapper {
    get {
      NameWrapper(Name.NSClassDescriptionNeededForClass)
    }
  }

  @objc static public var NSDidBecomeSingleThreaded: NameWrapper {
    get {
      NameWrapper(Name.NSDidBecomeSingleThreaded)
    }
  }

  @objc static public var NSFileHandleConnectionAccepted: NameWrapper {
    get {
      NameWrapper(Name.NSFileHandleConnectionAccepted)
    }
  }

  @objc static public var NSFileHandleDataAvailable: NameWrapper {
    get {
      NameWrapper(Name.NSFileHandleDataAvailable)
    }
  }

  @objc static public var NSFileHandleReadToEndOfFileCompletion: NameWrapper {
    get {
      NameWrapper(Name.NSFileHandleReadToEndOfFileCompletion)
    }
  }

  @available(macOS, introduced: 10.2)
  @objc static public var NSHTTPCookieManagerAcceptPolicyChanged: NameWrapper {
    get {
      NameWrapper(Name.NSHTTPCookieManagerAcceptPolicyChanged)
    }
  }

  @available(macOS, introduced: 10.2)
  @objc static public var NSHTTPCookieManagerCookiesChanged: NameWrapper {
    get {
      NameWrapper(Name.NSHTTPCookieManagerCookiesChanged)
    }
  }

  @available(macOS, introduced: 10.4)
  @objc static public var NSMetadataQueryDidFinishGathering: NameWrapper {
    get {
      NameWrapper(Name.NSMetadataQueryDidFinishGathering)
    }
  }

  @available(macOS, introduced: 10.4)
  @objc static public var NSMetadataQueryDidStartGathering: NameWrapper {
    get {
      NameWrapper(Name.NSMetadataQueryDidStartGathering)
    }
  }

  @available(macOS, introduced: 10.4)
  @objc static public var NSMetadataQueryDidUpdate: NameWrapper {
    get {
      NameWrapper(Name.NSMetadataQueryDidUpdate)
    }
  }

  @available(macOS, introduced: 10.4)
  @objc static public var NSMetadataQueryGatheringProgress: NameWrapper {
    get {
      NameWrapper(Name.NSMetadataQueryGatheringProgress)
    }
  }

  @available(macOS, introduced: 12.0)
  @objc static public var NSProcessInfoPowerStateDidChange: NameWrapper {
    get {
      NameWrapper(Name.NSProcessInfoPowerStateDidChange)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var NSSystemClockDidChange: NameWrapper {
    get {
      NameWrapper(Name.NSSystemClockDidChange)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSSystemTimeZoneDidChange: NameWrapper {
    get {
      NameWrapper(Name.NSSystemTimeZoneDidChange)
    }
  }

  @objc static public var NSThreadWillExit: NameWrapper {
    get {
      NameWrapper(Name.NSThreadWillExit)
    }
  }

  @available(macOS, introduced: 10.2)
  @objc static public var NSURLCredentialStorageChanged: NameWrapper {
    get {
      NameWrapper(Name.NSURLCredentialStorageChanged)
    }
  }

  @available(macOS, introduced: 10.8)
  @objc static public var NSUbiquityIdentityDidChange: NameWrapper {
    get {
      NameWrapper(Name.NSUbiquityIdentityDidChange)
    }
  }

  @available(macOS, introduced: 10.0)
  @objc static public var NSUndoManagerCheckpoint: NameWrapper {
    get {
      NameWrapper(Name.NSUndoManagerCheckpoint)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSUndoManagerDidCloseUndoGroup: NameWrapper {
    get {
      NameWrapper(Name.NSUndoManagerDidCloseUndoGroup)
    }
  }

  @available(macOS, introduced: 10.0)
  @objc static public var NSUndoManagerDidOpenUndoGroup: NameWrapper {
    get {
      NameWrapper(Name.NSUndoManagerDidOpenUndoGroup)
    }
  }

  @available(macOS, introduced: 10.0)
  @objc static public var NSUndoManagerDidRedoChange: NameWrapper {
    get {
      NameWrapper(Name.NSUndoManagerDidRedoChange)
    }
  }

  @available(macOS, introduced: 10.0)
  @objc static public var NSUndoManagerDidUndoChange: NameWrapper {
    get {
      NameWrapper(Name.NSUndoManagerDidUndoChange)
    }
  }

  @available(macOS, introduced: 10.0)
  @objc static public var NSUndoManagerWillCloseUndoGroup: NameWrapper {
    get {
      NameWrapper(Name.NSUndoManagerWillCloseUndoGroup)
    }
  }

  @available(macOS, introduced: 10.0)
  @objc static public var NSUndoManagerWillRedoChange: NameWrapper {
    get {
      NameWrapper(Name.NSUndoManagerWillRedoChange)
    }
  }

  @available(macOS, introduced: 10.0)
  @objc static public var NSUndoManagerWillUndoChange: NameWrapper {
    get {
      NameWrapper(Name.NSUndoManagerWillUndoChange)
    }
  }

  @objc static public var NSWillBecomeMultiThreaded: NameWrapper {
    get {
      NameWrapper(Name.NSWillBecomeMultiThreaded)
    }
  }

  init(_ wrappedInstance: Name) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = Name(rawValue: rawValue)
  }

  @objc init(_ rawValue: String) {
    wrappedInstance = Name(rawValue)
  }

}

@objc public class FileOperationKindWrapper: NSObject {
  var wrappedInstance: FileOperationKind

  @available(macOS, introduced: 10.9)
  @objc static public var copying: FileOperationKindWrapper {
    get {
      FileOperationKindWrapper(FileOperationKind.copying)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var decompressingAfterDownloading: FileOperationKindWrapper {
    get {
      FileOperationKindWrapper(FileOperationKind.decompressingAfterDownloading)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var downloading: FileOperationKindWrapper {
    get {
      FileOperationKindWrapper(FileOperationKind.downloading)
    }
  }

  @available(macOS, introduced: 12.0)
  @objc static public var duplicating: FileOperationKindWrapper {
    get {
      FileOperationKindWrapper(FileOperationKind.duplicating)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var receiving: FileOperationKindWrapper {
    get {
      FileOperationKindWrapper(FileOperationKind.receiving)
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var uploading: FileOperationKindWrapper {
    get {
      FileOperationKindWrapper(FileOperationKind.uploading)
    }
  }

  init(_ wrappedInstance: FileOperationKind) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = FileOperationKind(rawValue: rawValue)
  }

  @objc init(_ rawValue: String) {
    wrappedInstance = FileOperationKind(rawValue)
  }

}

@objc public class ProgressKindWrapper: NSObject {
  var wrappedInstance: ProgressKind

  @available(macOS, introduced: 10.9)
  @objc static public var file: ProgressKindWrapper {
    get {
      ProgressKindWrapper(ProgressKind.file)
    }
  }

  init(_ wrappedInstance: ProgressKind) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = ProgressKind(rawValue: rawValue)
  }

  @objc init(_ rawValue: String) {
    wrappedInstance = ProgressKind(rawValue)
  }

}

@objc public class ProgressUserInfoKeyWrapper: NSObject {
  var wrappedInstance: ProgressUserInfoKey

  @available(macOS, introduced: 10.9)
  @objc static public var estimatedTimeRemainingKey: ProgressUserInfoKeyWrapper {
    get {
      ProgressUserInfoKeyWrapper(ProgressUserInfoKey.estimatedTimeRemainingKey)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var fileAnimationImageKey: ProgressUserInfoKeyWrapper {
    get {
      ProgressUserInfoKeyWrapper(ProgressUserInfoKey.fileAnimationImageKey)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var fileAnimationImageOriginalRectKey: ProgressUserInfoKeyWrapper {
    get {
      ProgressUserInfoKeyWrapper(ProgressUserInfoKey.fileAnimationImageOriginalRectKey)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var fileCompletedCountKey: ProgressUserInfoKeyWrapper {
    get {
      ProgressUserInfoKeyWrapper(ProgressUserInfoKey.fileCompletedCountKey)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var fileIconKey: ProgressUserInfoKeyWrapper {
    get {
      ProgressUserInfoKeyWrapper(ProgressUserInfoKey.fileIconKey)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var fileOperationKindKey: ProgressUserInfoKeyWrapper {
    get {
      ProgressUserInfoKeyWrapper(ProgressUserInfoKey.fileOperationKindKey)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var fileTotalCountKey: ProgressUserInfoKeyWrapper {
    get {
      ProgressUserInfoKeyWrapper(ProgressUserInfoKey.fileTotalCountKey)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var fileURLKey: ProgressUserInfoKeyWrapper {
    get {
      ProgressUserInfoKeyWrapper(ProgressUserInfoKey.fileURLKey)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var throughputKey: ProgressUserInfoKeyWrapper {
    get {
      ProgressUserInfoKeyWrapper(ProgressUserInfoKey.throughputKey)
    }
  }

  init(_ wrappedInstance: ProgressUserInfoKey) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = ProgressUserInfoKey(rawValue: rawValue)
  }

  @objc init(_ rawValue: String) {
    wrappedInstance = ProgressUserInfoKey(rawValue)
  }

}

@objc public class ModeWrapper: NSObject {
  var wrappedInstance: Mode

  @objc static public var `default`: ModeWrapper {
    get {
      ModeWrapper(Mode.`default`)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var common: ModeWrapper {
    get {
      ModeWrapper(Mode.common)
    }
  }

  init(_ wrappedInstance: Mode) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = Mode(rawValue: rawValue)
  }

  @objc init(_ rawValue: String) {
    wrappedInstance = Mode(rawValue)
  }

}

@objc public class StreamNetworkServiceTypeValueWrapper: NSObject {
  var wrappedInstance: StreamNetworkServiceTypeValue

  @available(macOS, introduced: 10.7)
  @objc static public var background: StreamNetworkServiceTypeValueWrapper {
    get {
      StreamNetworkServiceTypeValueWrapper(StreamNetworkServiceTypeValue.background)
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var callSignaling: StreamNetworkServiceTypeValueWrapper {
    get {
      StreamNetworkServiceTypeValueWrapper(StreamNetworkServiceTypeValue.callSignaling)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var video: StreamNetworkServiceTypeValueWrapper {
    get {
      StreamNetworkServiceTypeValueWrapper(StreamNetworkServiceTypeValue.video)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var voIP: StreamNetworkServiceTypeValueWrapper {
    get {
      StreamNetworkServiceTypeValueWrapper(StreamNetworkServiceTypeValue.voIP)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var voice: StreamNetworkServiceTypeValueWrapper {
    get {
      StreamNetworkServiceTypeValueWrapper(StreamNetworkServiceTypeValue.voice)
    }
  }

  init(_ wrappedInstance: StreamNetworkServiceTypeValue) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = StreamNetworkServiceTypeValue(rawValue: rawValue)
  }

}

@objc public class PropertyKeyWrapper: NSObject {
  var wrappedInstance: PropertyKey

  @available(macOS, introduced: 10.3)
  @objc static public var dataWrittenToMemoryStreamKey: PropertyKeyWrapper {
    get {
      PropertyKeyWrapper(PropertyKey.dataWrittenToMemoryStreamKey)
    }
  }

  @available(macOS, introduced: 10.3)
  @objc static public var fileCurrentOffsetKey: PropertyKeyWrapper {
    get {
      PropertyKeyWrapper(PropertyKey.fileCurrentOffsetKey)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var networkServiceType: PropertyKeyWrapper {
    get {
      PropertyKeyWrapper(PropertyKey.networkServiceType)
    }
  }

  @available(macOS, introduced: 10.3)
  @objc static public var socksProxyConfigurationKey: PropertyKeyWrapper {
    get {
      PropertyKeyWrapper(PropertyKey.socksProxyConfigurationKey)
    }
  }

  @available(macOS, introduced: 10.3)
  @objc static public var socketSecurityLevelKey: PropertyKeyWrapper {
    get {
      PropertyKeyWrapper(PropertyKey.socketSecurityLevelKey)
    }
  }

  init(_ wrappedInstance: PropertyKey) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = PropertyKey(rawValue: rawValue)
  }

  @objc init(_ rawValue: String) {
    wrappedInstance = PropertyKey(rawValue)
  }

}

@objc public class StreamSOCKSProxyConfigurationWrapper: NSObject {
  var wrappedInstance: StreamSOCKSProxyConfiguration

  @available(macOS, introduced: 10.3)
  @objc static public var hostKey: StreamSOCKSProxyConfigurationWrapper {
    get {
      StreamSOCKSProxyConfigurationWrapper(StreamSOCKSProxyConfiguration.hostKey)
    }
  }

  @available(macOS, introduced: 10.3)
  @objc static public var passwordKey: StreamSOCKSProxyConfigurationWrapper {
    get {
      StreamSOCKSProxyConfigurationWrapper(StreamSOCKSProxyConfiguration.passwordKey)
    }
  }

  @available(macOS, introduced: 10.3)
  @objc static public var portKey: StreamSOCKSProxyConfigurationWrapper {
    get {
      StreamSOCKSProxyConfigurationWrapper(StreamSOCKSProxyConfiguration.portKey)
    }
  }

  @available(macOS, introduced: 10.3)
  @objc static public var userKey: StreamSOCKSProxyConfigurationWrapper {
    get {
      StreamSOCKSProxyConfigurationWrapper(StreamSOCKSProxyConfiguration.userKey)
    }
  }

  @available(macOS, introduced: 10.3)
  @objc static public var versionKey: StreamSOCKSProxyConfigurationWrapper {
    get {
      StreamSOCKSProxyConfigurationWrapper(StreamSOCKSProxyConfiguration.versionKey)
    }
  }

  init(_ wrappedInstance: StreamSOCKSProxyConfiguration) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = StreamSOCKSProxyConfiguration(rawValue: rawValue)
  }

}

@objc public class StreamSOCKSProxyVersionWrapper: NSObject {
  var wrappedInstance: StreamSOCKSProxyVersion

  @available(macOS, introduced: 10.3)
  @objc static public var version4: StreamSOCKSProxyVersionWrapper {
    get {
      StreamSOCKSProxyVersionWrapper(StreamSOCKSProxyVersion.version4)
    }
  }

  @available(macOS, introduced: 10.3)
  @objc static public var version5: StreamSOCKSProxyVersionWrapper {
    get {
      StreamSOCKSProxyVersionWrapper(StreamSOCKSProxyVersion.version5)
    }
  }

  init(_ wrappedInstance: StreamSOCKSProxyVersion) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = StreamSOCKSProxyVersion(rawValue: rawValue)
  }

}

@objc public class StreamSocketSecurityLevelWrapper: NSObject {
  var wrappedInstance: StreamSocketSecurityLevel

  @available(macOS, introduced: 10.3)
  @objc static public var negotiatedSSL: StreamSocketSecurityLevelWrapper {
    get {
      StreamSocketSecurityLevelWrapper(StreamSocketSecurityLevel.negotiatedSSL)
    }
  }

  @available(macOS, introduced: 10.3)
  @objc static public var none: StreamSocketSecurityLevelWrapper {
    get {
      StreamSocketSecurityLevelWrapper(StreamSocketSecurityLevel.none)
    }
  }

  @available(macOS, introduced: 10.3)
  @objc static public var ssLv2: StreamSocketSecurityLevelWrapper {
    get {
      StreamSocketSecurityLevelWrapper(StreamSocketSecurityLevel.ssLv2)
    }
  }

  @available(macOS, introduced: 10.3)
  @objc static public var ssLv3: StreamSocketSecurityLevelWrapper {
    get {
      StreamSocketSecurityLevelWrapper(StreamSocketSecurityLevel.ssLv3)
    }
  }

  @available(macOS, introduced: 10.3)
  @objc static public var tlSv1: StreamSocketSecurityLevelWrapper {
    get {
      StreamSocketSecurityLevelWrapper(StreamSocketSecurityLevel.tlSv1)
    }
  }

  init(_ wrappedInstance: StreamSocketSecurityLevel) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = StreamSocketSecurityLevel(rawValue: rawValue)
  }

}

@objc public class StringEncodingDetectionOptionsKeyWrapper: NSObject {
  var wrappedInstance: StringEncodingDetectionOptionsKey

  @available(macOS, introduced: 10.10)
  @objc static public var allowLossyKey: StringEncodingDetectionOptionsKeyWrapper {
    get {
      StringEncodingDetectionOptionsKeyWrapper(StringEncodingDetectionOptionsKey.allowLossyKey)
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var disallowedEncodingsKey: StringEncodingDetectionOptionsKeyWrapper {
    get {
      StringEncodingDetectionOptionsKeyWrapper(StringEncodingDetectionOptionsKey.disallowedEncodingsKey)
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var fromWindowsKey: StringEncodingDetectionOptionsKeyWrapper {
    get {
      StringEncodingDetectionOptionsKeyWrapper(StringEncodingDetectionOptionsKey.fromWindowsKey)
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var likelyLanguageKey: StringEncodingDetectionOptionsKeyWrapper {
    get {
      StringEncodingDetectionOptionsKeyWrapper(StringEncodingDetectionOptionsKey.likelyLanguageKey)
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var lossySubstitutionKey: StringEncodingDetectionOptionsKeyWrapper {
    get {
      StringEncodingDetectionOptionsKeyWrapper(StringEncodingDetectionOptionsKey.lossySubstitutionKey)
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var suggestedEncodingsKey: StringEncodingDetectionOptionsKeyWrapper {
    get {
      StringEncodingDetectionOptionsKeyWrapper(StringEncodingDetectionOptionsKey.suggestedEncodingsKey)
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var useOnlySuggestedEncodingsKey: StringEncodingDetectionOptionsKeyWrapper {
    get {
      StringEncodingDetectionOptionsKeyWrapper(StringEncodingDetectionOptionsKey.useOnlySuggestedEncodingsKey)
    }
  }

  init(_ wrappedInstance: StringEncodingDetectionOptionsKey) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = StringEncodingDetectionOptionsKey(rawValue: rawValue)
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

@objc public class NSTextCheckingKeyWrapper: NSObject {
  var wrappedInstance: NSTextCheckingKey

  @available(macOS, introduced: 10.7)
  @objc static public var airline: NSTextCheckingKeyWrapper {
    get {
      NSTextCheckingKeyWrapper(NSTextCheckingKey.airline)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var city: NSTextCheckingKeyWrapper {
    get {
      NSTextCheckingKeyWrapper(NSTextCheckingKey.city)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var country: NSTextCheckingKeyWrapper {
    get {
      NSTextCheckingKeyWrapper(NSTextCheckingKey.country)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var flight: NSTextCheckingKeyWrapper {
    get {
      NSTextCheckingKeyWrapper(NSTextCheckingKey.flight)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var jobTitle: NSTextCheckingKeyWrapper {
    get {
      NSTextCheckingKeyWrapper(NSTextCheckingKey.jobTitle)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var name: NSTextCheckingKeyWrapper {
    get {
      NSTextCheckingKeyWrapper(NSTextCheckingKey.name)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var organization: NSTextCheckingKeyWrapper {
    get {
      NSTextCheckingKeyWrapper(NSTextCheckingKey.organization)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var phone: NSTextCheckingKeyWrapper {
    get {
      NSTextCheckingKeyWrapper(NSTextCheckingKey.phone)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var state: NSTextCheckingKeyWrapper {
    get {
      NSTextCheckingKeyWrapper(NSTextCheckingKey.state)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var street: NSTextCheckingKeyWrapper {
    get {
      NSTextCheckingKeyWrapper(NSTextCheckingKey.street)
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var zip: NSTextCheckingKeyWrapper {
    get {
      NSTextCheckingKeyWrapper(NSTextCheckingKey.zip)
    }
  }

  init(_ wrappedInstance: NSTextCheckingKey) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = NSTextCheckingKey(rawValue: rawValue)
  }

  @objc init(_ rawValue: String) {
    wrappedInstance = NSTextCheckingKey(rawValue)
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

@objc public class URLThumbnailDictionaryItemWrapper: NSObject {
  var wrappedInstance: URLThumbnailDictionaryItem

  @available(macOS, introduced: 10.10, deprecated: 12.0)
  @objc static public var NSThumbnail1024x1024SizeKey: URLThumbnailDictionaryItemWrapper {
    get {
      URLThumbnailDictionaryItemWrapper(URLThumbnailDictionaryItem.NSThumbnail1024x1024SizeKey)
    }
  }

  init(_ wrappedInstance: URLThumbnailDictionaryItem) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = URLThumbnailDictionaryItem(rawValue: rawValue)
  }

  @objc init(_ rawValue: String) {
    wrappedInstance = URLThumbnailDictionaryItem(rawValue)
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

@available(macOS, introduced: 15.0)
@objc public class UserInfoKeyWrapper: NSObject {
  var wrappedInstance: UserInfoKey

  init(_ wrappedInstance: UserInfoKey) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 15.0)
  @objc init(rawValue: String) {
    wrappedInstance = UserInfoKey(rawValue: rawValue)
  }

  @available(macOS, introduced: 15.0)
  @objc init(_ rawValue: String) {
    wrappedInstance = UserInfoKey(rawValue)
  }

}

@objc public class NSValueTransformerNameWrapper: NSObject {
  var wrappedInstance: NSValueTransformerName

  @available(macOS, introduced: 10.3)
  @objc static public var isNilTransformerName: NSValueTransformerNameWrapper {
    get {
      NSValueTransformerNameWrapper(NSValueTransformerName.isNilTransformerName)
    }
  }

  @available(macOS, introduced: 10.3)
  @objc static public var isNotNilTransformerName: NSValueTransformerNameWrapper {
    get {
      NSValueTransformerNameWrapper(NSValueTransformerName.isNotNilTransformerName)
    }
  }

  @available(macOS, introduced: 10.3, deprecated: 10.14)
  @objc static public var keyedUnarchiveFromDataTransformerName: NSValueTransformerNameWrapper {
    get {
      NSValueTransformerNameWrapper(NSValueTransformerName.keyedUnarchiveFromDataTransformerName)
    }
  }

  @available(macOS, introduced: 10.3)
  @objc static public var negateBooleanTransformerName: NSValueTransformerNameWrapper {
    get {
      NSValueTransformerNameWrapper(NSValueTransformerName.negateBooleanTransformerName)
    }
  }

  @available(macOS, introduced: 10.14)
  @objc static public var secureUnarchiveFromDataTransformerName: NSValueTransformerNameWrapper {
    get {
      NSValueTransformerNameWrapper(NSValueTransformerName.secureUnarchiveFromDataTransformerName)
    }
  }

  @available(macOS, introduced: 10.3, deprecated: 10.14)
  @objc static public var unarchiveFromDataTransformerName: NSValueTransformerNameWrapper {
    get {
      NSValueTransformerNameWrapper(NSValueTransformerName.unarchiveFromDataTransformerName)
    }
  }

  init(_ wrappedInstance: NSValueTransformerName) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(rawValue: String) {
    wrappedInstance = NSValueTransformerName(rawValue: rawValue)
  }

  @objc init(_ rawValue: String) {
    wrappedInstance = NSValueTransformerName(rawValue)
  }

}

@objc public class GlobalsWrapper: NSObject {
  @available(macOS, introduced: 11.0)
  @objc static public var NSBundleExecutableArchitectureARM64Wrapper: Int {
    get {
      NSBundleExecutableArchitectureARM64
    }
  }

  @objc static public var NSBundleExecutableArchitectureI386Wrapper: Int {
    get {
      NSBundleExecutableArchitectureI386
    }
  }

  @objc static public var NSBundleExecutableArchitecturePPCWrapper: Int {
    get {
      NSBundleExecutableArchitecturePPC
    }
  }

  @objc static public var NSBundleExecutableArchitecturePPC64Wrapper: Int {
    get {
      NSBundleExecutableArchitecturePPC64
    }
  }

  @objc static public var NSBundleExecutableArchitectureX86_64Wrapper: Int {
    get {
      NSBundleExecutableArchitectureX86_64
    }
  }

  @objc static public var NSDateComponentUndefinedWrapper: Int {
    get {
      NSDateComponentUndefined
    }
  }

  @available(macOS, introduced: 10.4, deprecated: 10.10)
  @objc static public var NSUndefinedDateComponentWrapper: Int {
    get {
      NSUndefinedDateComponent
    }
  }

  @objc static public var NSArgumentEvaluationScriptErrorWrapper: Int {
    get {
      NSArgumentEvaluationScriptError
    }
  }

  @objc static public var NSArgumentsWrongScriptErrorWrapper: Int {
    get {
      NSArgumentsWrongScriptError
    }
  }

  @objc static public var NSCannotCreateScriptCommandErrorWrapper: Int {
    get {
      NSCannotCreateScriptCommandError
    }
  }

  @objc static public var NSInternalScriptErrorWrapper: Int {
    get {
      NSInternalScriptError
    }
  }

  @objc static public var NSKeySpecifierEvaluationScriptErrorWrapper: Int {
    get {
      NSKeySpecifierEvaluationScriptError
    }
  }

  @objc static public var NSNoScriptErrorWrapper: Int {
    get {
      NSNoScriptError
    }
  }

  @objc static public var NSOperationNotSupportedForKeyScriptErrorWrapper: Int {
    get {
      NSOperationNotSupportedForKeyScriptError
    }
  }

  @objc static public var NSReceiverEvaluationScriptErrorWrapper: Int {
    get {
      NSReceiverEvaluationScriptError
    }
  }

  @objc static public var NSReceiversCantHandleCommandScriptErrorWrapper: Int {
    get {
      NSReceiversCantHandleCommandScriptError
    }
  }

  @objc static public var NSRequiredArgumentsMissingScriptErrorWrapper: Int {
    get {
      NSRequiredArgumentsMissingScriptError
    }
  }

  @objc static public var NSUnknownKeyScriptErrorWrapper: Int {
    get {
      NSUnknownKeyScriptError
    }
  }

  @objc static public var NSContainerSpecifierErrorWrapper: Int {
    get {
      NSContainerSpecifierError
    }
  }

  @objc static public var NSInternalSpecifierErrorWrapper: Int {
    get {
      NSInternalSpecifierError
    }
  }

  @objc static public var NSInvalidIndexSpecifierErrorWrapper: Int {
    get {
      NSInvalidIndexSpecifierError
    }
  }

  @objc static public var NSNoSpecifierErrorWrapper: Int {
    get {
      NSNoSpecifierError
    }
  }

  @objc static public var NSNoTopLevelContainersSpecifierErrorWrapper: Int {
    get {
      NSNoTopLevelContainersSpecifierError
    }
  }

  @objc static public var NSOperationNotSupportedForKeySpecifierErrorWrapper: Int {
    get {
      NSOperationNotSupportedForKeySpecifierError
    }
  }

  @objc static public var NSUnknownKeySpecifierErrorWrapper: Int {
    get {
      NSUnknownKeySpecifierError
    }
  }

  @objc static public var NSOpenStepUnicodeReservedBaseWrapper: Int {
    get {
      NSOpenStepUnicodeReservedBase
    }
  }

  @objc static public var NSCollectorDisabledOptionWrapper: Int {
    get {
      NSCollectorDisabledOption
    }
  }

  @objc static public var NSScannedOptionWrapper: Int {
    get {
      NSScannedOption
    }
  }

  @objc static public var NSURLErrorCancelledReasonBackgroundUpdatesDisabledWrapper: Int {
    get {
      NSURLErrorCancelledReasonBackgroundUpdatesDisabled
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var NSURLErrorCancelledReasonInsufficientSystemResourcesWrapper: Int {
    get {
      NSURLErrorCancelledReasonInsufficientSystemResources
    }
  }

  @objc static public var NSURLErrorCancelledReasonUserForceQuitApplicationWrapper: Int {
    get {
      NSURLErrorCancelledReasonUserForceQuitApplication
    }
  }

  @available(macOS, introduced: 10.8)
  @objc static public var NSUbiquitousKeyValueStoreAccountChangeWrapper: Int {
    get {
      NSUbiquitousKeyValueStoreAccountChange
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSUbiquitousKeyValueStoreInitialSyncChangeWrapper: Int {
    get {
      NSUbiquitousKeyValueStoreInitialSyncChange
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSUbiquitousKeyValueStoreQuotaViolationChangeWrapper: Int {
    get {
      NSUbiquitousKeyValueStoreQuotaViolationChange
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSUbiquitousKeyValueStoreServerChangeWrapper: Int {
    get {
      NSUbiquitousKeyValueStoreServerChange
    }
  }

  @objc static public var NSHPUXOperatingSystemWrapper: Int {
    get {
      NSHPUXOperatingSystem
    }
  }

  @objc static public var NSMACHOperatingSystemWrapper: Int {
    get {
      NSMACHOperatingSystem
    }
  }

  @objc static public var NSOSF1OperatingSystemWrapper: Int {
    get {
      NSOSF1OperatingSystem
    }
  }

  @objc static public var NSSolarisOperatingSystemWrapper: Int {
    get {
      NSSolarisOperatingSystem
    }
  }

  @objc static public var NSSunOSOperatingSystemWrapper: Int {
    get {
      NSSunOSOperatingSystem
    }
  }

  @objc static public var NSWindows95OperatingSystemWrapper: Int {
    get {
      NSWindows95OperatingSystem
    }
  }

  @objc static public var NSWindowsNTOperatingSystemWrapper: Int {
    get {
      NSWindowsNTOperatingSystem
    }
  }

  @available(macOS, introduced: 10.4, deprecated: 10.10)
  @objc static public var NSWrapCalendarComponentsWrapper: Int {
    get {
      NSWrapCalendarComponents
    }
  }

  @objc static public var NS_BigEndianWrapper: Int {
    get {
      NS_BigEndian
    }
  }

  @objc static public var NS_LittleEndianWrapper: Int {
    get {
      NS_LittleEndian
    }
  }

  @objc static public var NS_UnknownByteOrderWrapper: Int {
    get {
      NS_UnknownByteOrder
    }
  }

  @objc static public var NSAppleEventTimeOutDefaultWrapper: Double {
    get {
      NSAppleEventTimeOutDefault
    }
  }

  @objc static public var NSAppleEventTimeOutNoneWrapper: Double {
    get {
      NSAppleEventTimeOutNone
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var NSAssertionHandlerKeyWrapper: String {
    get {
      NSAssertionHandlerKey
    }
  }

  @available(macOS, introduced: 10.4, deprecated: 10.10)
  @objc static public var NSBuddhistCalendarWrapper: String {
    get {
      NSBuddhistCalendar
    }
  }

  @available(macOS, introduced: 10.4, deprecated: 10.10)
  @objc static public var NSChineseCalendarWrapper: String {
    get {
      NSChineseCalendar
    }
  }

  @objc static public var NSCocoaErrorDomainWrapper: String {
    get {
      NSCocoaErrorDomain
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSDebugDescriptionErrorKeyWrapper: String {
    get {
      NSDebugDescriptionErrorKey
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var NSEdgeInsetsZeroWrapper: NSEdgeInsetsWrapper {
    get {
      NSEdgeInsetsWrapper(NSEdgeInsetsZero)
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var NSExtensionItemAttachmentsKeyWrapper: String {
    get {
      NSExtensionItemAttachmentsKey
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var NSExtensionItemAttributedContentTextKeyWrapper: String {
    get {
      NSExtensionItemAttributedContentTextKey
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var NSExtensionItemAttributedTitleKeyWrapper: String {
    get {
      NSExtensionItemAttributedTitleKey
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var NSExtensionItemsAndErrorsKeyWrapper: String {
    get {
      NSExtensionItemsAndErrorsKey
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var NSExtensionJavaScriptPreprocessingResultsKeyWrapper: String {
    get {
      NSExtensionJavaScriptPreprocessingResultsKey
    }
  }

  @objc static public var NSFileHandleNotificationDataItemWrapper: String {
    get {
      NSFileHandleNotificationDataItem
    }
  }

  @objc static public var NSFileHandleNotificationFileHandleItemWrapper: String {
    get {
      NSFileHandleNotificationFileHandleItem
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var NSFileManagerUnmountDissentingProcessIdentifierErrorKeyWrapper: String {
    get {
      NSFileManagerUnmountDissentingProcessIdentifierErrorKey
    }
  }

  @objc static public var NSFilePathErrorKeyWrapper: String {
    get {
      NSFilePathErrorKey
    }
  }

  @objc static public var NSFoundationVersionNumberWrapper: Double {
    get {
      NSFoundationVersionNumber
    }
    set {
      NSFoundationVersionNumber = newValue
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSGrammarCorrectionsWrapper: String {
    get {
      NSGrammarCorrections
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSGrammarRangeWrapper: String {
    get {
      NSGrammarRange
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSGrammarUserDescriptionWrapper: String {
    get {
      NSGrammarUserDescription
    }
  }

  @available(macOS, introduced: 10.4, deprecated: 10.10)
  @objc static public var NSGregorianCalendarWrapper: String {
    get {
      NSGregorianCalendar
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSHashTableCopyInWrapper: OptionsWrapper {
    get {
      OptionsWrapper(NSHashTableCopyIn)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSHashTableObjectPointerPersonalityWrapper: OptionsWrapper {
    get {
      OptionsWrapper(NSHashTableObjectPointerPersonality)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSHashTableStrongMemoryWrapper: OptionsWrapper {
    get {
      OptionsWrapper(NSHashTableStrongMemory)
    }
  }

  @available(macOS, introduced: 10.8)
  @objc static public var NSHashTableWeakMemoryWrapper: OptionsWrapper {
    get {
      OptionsWrapper(NSHashTableWeakMemory)
    }
  }

  @available(macOS, introduced: 10.4, deprecated: 10.10)
  @objc static public var NSHebrewCalendarWrapper: String {
    get {
      NSHebrewCalendar
    }
  }

  @objc static public var NSHelpAnchorErrorKeyWrapper: String {
    get {
      NSHelpAnchorErrorKey
    }
  }

  @available(macOS, introduced: 10.6, deprecated: 10.10)
  @objc static public var NSISO8601CalendarWrapper: String {
    get {
      NSISO8601Calendar
    }
  }

  @available(macOS, introduced: 10.6, deprecated: 10.10)
  @objc static public var NSIndianCalendarWrapper: String {
    get {
      NSIndianCalendar
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSIntegerHashCallBacksWrapper: NSHashTableCallBacksWrapper {
    get {
      NSHashTableCallBacksWrapper(NSIntegerHashCallBacks)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSIntegerMapKeyCallBacksWrapper: NSMapTableKeyCallBacksWrapper {
    get {
      NSMapTableKeyCallBacksWrapper(NSIntegerMapKeyCallBacks)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSIntegerMapValueCallBacksWrapper: NSMapTableValueCallBacksWrapper {
    get {
      NSMapTableValueCallBacksWrapper(NSIntegerMapValueCallBacks)
    }
  }

  @available(macOS, introduced: 10.4, deprecated: 10.10)
  @objc static public var NSIslamicCalendarWrapper: String {
    get {
      NSIslamicCalendar
    }
  }

  @available(macOS, introduced: 10.4, deprecated: 10.10)
  @objc static public var NSIslamicCivilCalendarWrapper: String {
    get {
      NSIslamicCivilCalendar
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var NSItemProviderPreferredImageSizeKeyWrapper: String {
    get {
      NSItemProviderPreferredImageSizeKey
    }
  }

  @available(macOS, introduced: 10.4, deprecated: 10.10)
  @objc static public var NSJapaneseCalendarWrapper: String {
    get {
      NSJapaneseCalendar
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSKeyedArchiveRootObjectKeyWrapper: String {
    get {
      NSKeyedArchiveRootObjectKey
    }
  }

  @objc static public var NSLoadedClassesWrapper: String {
    get {
      NSLoadedClasses
    }
  }

  @objc static public var NSLocalizedDescriptionKeyWrapper: String {
    get {
      NSLocalizedDescriptionKey
    }
  }

  @available(macOS, introduced: 10.13)
  @objc static public var NSLocalizedFailureErrorKeyWrapper: String {
    get {
      NSLocalizedFailureErrorKey
    }
  }

  @objc static public var NSLocalizedFailureReasonErrorKeyWrapper: String {
    get {
      NSLocalizedFailureReasonErrorKey
    }
  }

  @objc static public var NSLocalizedRecoveryOptionsErrorKeyWrapper: String {
    get {
      NSLocalizedRecoveryOptionsErrorKey
    }
  }

  @objc static public var NSLocalizedRecoverySuggestionErrorKeyWrapper: String {
    get {
      NSLocalizedRecoverySuggestionErrorKey
    }
  }

  @objc static public var NSMachErrorDomainWrapper: String {
    get {
      NSMachErrorDomain
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSMapTableCopyInWrapper: OptionsWrapper {
    get {
      OptionsWrapper(NSMapTableCopyIn)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSMapTableObjectPointerPersonalityWrapper: OptionsWrapper {
    get {
      OptionsWrapper(NSMapTableObjectPointerPersonality)
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSMapTableStrongMemoryWrapper: OptionsWrapper {
    get {
      OptionsWrapper(NSMapTableStrongMemory)
    }
  }

  @available(macOS, introduced: 10.8)
  @objc static public var NSMapTableWeakMemoryWrapper: OptionsWrapper {
    get {
      OptionsWrapper(NSMapTableWeakMemory)
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemAcquisitionMakeKeyWrapper: String {
    get {
      NSMetadataItemAcquisitionMakeKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemAcquisitionModelKeyWrapper: String {
    get {
      NSMetadataItemAcquisitionModelKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemAlbumKeyWrapper: String {
    get {
      NSMetadataItemAlbumKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemAltitudeKeyWrapper: String {
    get {
      NSMetadataItemAltitudeKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemApertureKeyWrapper: String {
    get {
      NSMetadataItemApertureKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemAppleLoopDescriptorsKeyWrapper: String {
    get {
      NSMetadataItemAppleLoopDescriptorsKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemAppleLoopsKeyFilterTypeKeyWrapper: String {
    get {
      NSMetadataItemAppleLoopsKeyFilterTypeKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemAppleLoopsLoopModeKeyWrapper: String {
    get {
      NSMetadataItemAppleLoopsLoopModeKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemAppleLoopsRootKeyKeyWrapper: String {
    get {
      NSMetadataItemAppleLoopsRootKeyKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemApplicationCategoriesKeyWrapper: String {
    get {
      NSMetadataItemApplicationCategoriesKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemAttributeChangeDateKeyWrapper: String {
    get {
      NSMetadataItemAttributeChangeDateKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemAudiencesKeyWrapper: String {
    get {
      NSMetadataItemAudiencesKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemAudioBitRateKeyWrapper: String {
    get {
      NSMetadataItemAudioBitRateKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemAudioChannelCountKeyWrapper: String {
    get {
      NSMetadataItemAudioChannelCountKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemAudioEncodingApplicationKeyWrapper: String {
    get {
      NSMetadataItemAudioEncodingApplicationKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemAudioSampleRateKeyWrapper: String {
    get {
      NSMetadataItemAudioSampleRateKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemAudioTrackNumberKeyWrapper: String {
    get {
      NSMetadataItemAudioTrackNumberKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemAuthorAddressesKeyWrapper: String {
    get {
      NSMetadataItemAuthorAddressesKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemAuthorEmailAddressesKeyWrapper: String {
    get {
      NSMetadataItemAuthorEmailAddressesKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemAuthorsKeyWrapper: String {
    get {
      NSMetadataItemAuthorsKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemBitsPerSampleKeyWrapper: String {
    get {
      NSMetadataItemBitsPerSampleKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemCFBundleIdentifierKeyWrapper: String {
    get {
      NSMetadataItemCFBundleIdentifierKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemCameraOwnerKeyWrapper: String {
    get {
      NSMetadataItemCameraOwnerKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemCityKeyWrapper: String {
    get {
      NSMetadataItemCityKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemCodecsKeyWrapper: String {
    get {
      NSMetadataItemCodecsKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemColorSpaceKeyWrapper: String {
    get {
      NSMetadataItemColorSpaceKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemCommentKeyWrapper: String {
    get {
      NSMetadataItemCommentKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemComposerKeyWrapper: String {
    get {
      NSMetadataItemComposerKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemContactKeywordsKeyWrapper: String {
    get {
      NSMetadataItemContactKeywordsKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemContentCreationDateKeyWrapper: String {
    get {
      NSMetadataItemContentCreationDateKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemContentModificationDateKeyWrapper: String {
    get {
      NSMetadataItemContentModificationDateKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemContentTypeKeyWrapper: String {
    get {
      NSMetadataItemContentTypeKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemContentTypeTreeKeyWrapper: String {
    get {
      NSMetadataItemContentTypeTreeKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemContributorsKeyWrapper: String {
    get {
      NSMetadataItemContributorsKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemCopyrightKeyWrapper: String {
    get {
      NSMetadataItemCopyrightKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemCountryKeyWrapper: String {
    get {
      NSMetadataItemCountryKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemCoverageKeyWrapper: String {
    get {
      NSMetadataItemCoverageKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemCreatorKeyWrapper: String {
    get {
      NSMetadataItemCreatorKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemDateAddedKeyWrapper: String {
    get {
      NSMetadataItemDateAddedKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemDeliveryTypeKeyWrapper: String {
    get {
      NSMetadataItemDeliveryTypeKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemDescriptionKeyWrapper: String {
    get {
      NSMetadataItemDescriptionKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemDirectorKeyWrapper: String {
    get {
      NSMetadataItemDirectorKey
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSMetadataItemDisplayNameKeyWrapper: String {
    get {
      NSMetadataItemDisplayNameKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemDownloadedDateKeyWrapper: String {
    get {
      NSMetadataItemDownloadedDateKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemDueDateKeyWrapper: String {
    get {
      NSMetadataItemDueDateKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemDurationSecondsKeyWrapper: String {
    get {
      NSMetadataItemDurationSecondsKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemEXIFGPSVersionKeyWrapper: String {
    get {
      NSMetadataItemEXIFGPSVersionKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemEXIFVersionKeyWrapper: String {
    get {
      NSMetadataItemEXIFVersionKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemEditorsKeyWrapper: String {
    get {
      NSMetadataItemEditorsKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemEmailAddressesKeyWrapper: String {
    get {
      NSMetadataItemEmailAddressesKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemEncodingApplicationsKeyWrapper: String {
    get {
      NSMetadataItemEncodingApplicationsKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemExecutableArchitecturesKeyWrapper: String {
    get {
      NSMetadataItemExecutableArchitecturesKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemExecutablePlatformKeyWrapper: String {
    get {
      NSMetadataItemExecutablePlatformKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemExposureModeKeyWrapper: String {
    get {
      NSMetadataItemExposureModeKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemExposureProgramKeyWrapper: String {
    get {
      NSMetadataItemExposureProgramKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemExposureTimeSecondsKeyWrapper: String {
    get {
      NSMetadataItemExposureTimeSecondsKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemExposureTimeStringKeyWrapper: String {
    get {
      NSMetadataItemExposureTimeStringKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemFNumberKeyWrapper: String {
    get {
      NSMetadataItemFNumberKey
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSMetadataItemFSContentChangeDateKeyWrapper: String {
    get {
      NSMetadataItemFSContentChangeDateKey
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSMetadataItemFSCreationDateKeyWrapper: String {
    get {
      NSMetadataItemFSCreationDateKey
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSMetadataItemFSNameKeyWrapper: String {
    get {
      NSMetadataItemFSNameKey
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSMetadataItemFSSizeKeyWrapper: String {
    get {
      NSMetadataItemFSSizeKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemFinderCommentKeyWrapper: String {
    get {
      NSMetadataItemFinderCommentKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemFlashOnOffKeyWrapper: String {
    get {
      NSMetadataItemFlashOnOffKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemFocalLength35mmKeyWrapper: String {
    get {
      NSMetadataItemFocalLength35mmKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemFocalLengthKeyWrapper: String {
    get {
      NSMetadataItemFocalLengthKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemFontsKeyWrapper: String {
    get {
      NSMetadataItemFontsKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemGPSAreaInformationKeyWrapper: String {
    get {
      NSMetadataItemGPSAreaInformationKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemGPSDOPKeyWrapper: String {
    get {
      NSMetadataItemGPSDOPKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemGPSDateStampKeyWrapper: String {
    get {
      NSMetadataItemGPSDateStampKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemGPSDestBearingKeyWrapper: String {
    get {
      NSMetadataItemGPSDestBearingKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemGPSDestDistanceKeyWrapper: String {
    get {
      NSMetadataItemGPSDestDistanceKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemGPSDestLatitudeKeyWrapper: String {
    get {
      NSMetadataItemGPSDestLatitudeKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemGPSDestLongitudeKeyWrapper: String {
    get {
      NSMetadataItemGPSDestLongitudeKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemGPSDifferentalKeyWrapper: String {
    get {
      NSMetadataItemGPSDifferentalKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemGPSMapDatumKeyWrapper: String {
    get {
      NSMetadataItemGPSMapDatumKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemGPSMeasureModeKeyWrapper: String {
    get {
      NSMetadataItemGPSMeasureModeKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemGPSProcessingMethodKeyWrapper: String {
    get {
      NSMetadataItemGPSProcessingMethodKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemGPSStatusKeyWrapper: String {
    get {
      NSMetadataItemGPSStatusKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemGPSTrackKeyWrapper: String {
    get {
      NSMetadataItemGPSTrackKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemGenreKeyWrapper: String {
    get {
      NSMetadataItemGenreKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemHasAlphaChannelKeyWrapper: String {
    get {
      NSMetadataItemHasAlphaChannelKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemHeadlineKeyWrapper: String {
    get {
      NSMetadataItemHeadlineKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemISOSpeedKeyWrapper: String {
    get {
      NSMetadataItemISOSpeedKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemIdentifierKeyWrapper: String {
    get {
      NSMetadataItemIdentifierKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemImageDirectionKeyWrapper: String {
    get {
      NSMetadataItemImageDirectionKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemInformationKeyWrapper: String {
    get {
      NSMetadataItemInformationKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemInstantMessageAddressesKeyWrapper: String {
    get {
      NSMetadataItemInstantMessageAddressesKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemInstructionsKeyWrapper: String {
    get {
      NSMetadataItemInstructionsKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemIsApplicationManagedKeyWrapper: String {
    get {
      NSMetadataItemIsApplicationManagedKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemIsGeneralMIDISequenceKeyWrapper: String {
    get {
      NSMetadataItemIsGeneralMIDISequenceKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemIsLikelyJunkKeyWrapper: String {
    get {
      NSMetadataItemIsLikelyJunkKey
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSMetadataItemIsUbiquitousKeyWrapper: String {
    get {
      NSMetadataItemIsUbiquitousKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemKeySignatureKeyWrapper: String {
    get {
      NSMetadataItemKeySignatureKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemKeywordsKeyWrapper: String {
    get {
      NSMetadataItemKeywordsKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemKindKeyWrapper: String {
    get {
      NSMetadataItemKindKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemLanguagesKeyWrapper: String {
    get {
      NSMetadataItemLanguagesKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemLastUsedDateKeyWrapper: String {
    get {
      NSMetadataItemLastUsedDateKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemLatitudeKeyWrapper: String {
    get {
      NSMetadataItemLatitudeKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemLayerNamesKeyWrapper: String {
    get {
      NSMetadataItemLayerNamesKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemLensModelKeyWrapper: String {
    get {
      NSMetadataItemLensModelKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemLongitudeKeyWrapper: String {
    get {
      NSMetadataItemLongitudeKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemLyricistKeyWrapper: String {
    get {
      NSMetadataItemLyricistKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemMaxApertureKeyWrapper: String {
    get {
      NSMetadataItemMaxApertureKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemMediaTypesKeyWrapper: String {
    get {
      NSMetadataItemMediaTypesKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemMeteringModeKeyWrapper: String {
    get {
      NSMetadataItemMeteringModeKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemMusicalGenreKeyWrapper: String {
    get {
      NSMetadataItemMusicalGenreKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemMusicalInstrumentCategoryKeyWrapper: String {
    get {
      NSMetadataItemMusicalInstrumentCategoryKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemMusicalInstrumentNameKeyWrapper: String {
    get {
      NSMetadataItemMusicalInstrumentNameKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemNamedLocationKeyWrapper: String {
    get {
      NSMetadataItemNamedLocationKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemNumberOfPagesKeyWrapper: String {
    get {
      NSMetadataItemNumberOfPagesKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemOrganizationsKeyWrapper: String {
    get {
      NSMetadataItemOrganizationsKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemOrientationKeyWrapper: String {
    get {
      NSMetadataItemOrientationKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemOriginalFormatKeyWrapper: String {
    get {
      NSMetadataItemOriginalFormatKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemOriginalSourceKeyWrapper: String {
    get {
      NSMetadataItemOriginalSourceKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemPageHeightKeyWrapper: String {
    get {
      NSMetadataItemPageHeightKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemPageWidthKeyWrapper: String {
    get {
      NSMetadataItemPageWidthKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemParticipantsKeyWrapper: String {
    get {
      NSMetadataItemParticipantsKey
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSMetadataItemPathKeyWrapper: String {
    get {
      NSMetadataItemPathKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemPerformersKeyWrapper: String {
    get {
      NSMetadataItemPerformersKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemPhoneNumbersKeyWrapper: String {
    get {
      NSMetadataItemPhoneNumbersKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemPixelCountKeyWrapper: String {
    get {
      NSMetadataItemPixelCountKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemPixelHeightKeyWrapper: String {
    get {
      NSMetadataItemPixelHeightKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemPixelWidthKeyWrapper: String {
    get {
      NSMetadataItemPixelWidthKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemProducerKeyWrapper: String {
    get {
      NSMetadataItemProducerKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemProfileNameKeyWrapper: String {
    get {
      NSMetadataItemProfileNameKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemProjectsKeyWrapper: String {
    get {
      NSMetadataItemProjectsKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemPublishersKeyWrapper: String {
    get {
      NSMetadataItemPublishersKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemRecipientAddressesKeyWrapper: String {
    get {
      NSMetadataItemRecipientAddressesKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemRecipientEmailAddressesKeyWrapper: String {
    get {
      NSMetadataItemRecipientEmailAddressesKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemRecipientsKeyWrapper: String {
    get {
      NSMetadataItemRecipientsKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemRecordingDateKeyWrapper: String {
    get {
      NSMetadataItemRecordingDateKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemRecordingYearKeyWrapper: String {
    get {
      NSMetadataItemRecordingYearKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemRedEyeOnOffKeyWrapper: String {
    get {
      NSMetadataItemRedEyeOnOffKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemResolutionHeightDPIKeyWrapper: String {
    get {
      NSMetadataItemResolutionHeightDPIKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemResolutionWidthDPIKeyWrapper: String {
    get {
      NSMetadataItemResolutionWidthDPIKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemRightsKeyWrapper: String {
    get {
      NSMetadataItemRightsKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemSecurityMethodKeyWrapper: String {
    get {
      NSMetadataItemSecurityMethodKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemSpeedKeyWrapper: String {
    get {
      NSMetadataItemSpeedKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemStarRatingKeyWrapper: String {
    get {
      NSMetadataItemStarRatingKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemStateOrProvinceKeyWrapper: String {
    get {
      NSMetadataItemStateOrProvinceKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemStreamableKeyWrapper: String {
    get {
      NSMetadataItemStreamableKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemSubjectKeyWrapper: String {
    get {
      NSMetadataItemSubjectKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemTempoKeyWrapper: String {
    get {
      NSMetadataItemTempoKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemTextContentKeyWrapper: String {
    get {
      NSMetadataItemTextContentKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemThemeKeyWrapper: String {
    get {
      NSMetadataItemThemeKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemTimeSignatureKeyWrapper: String {
    get {
      NSMetadataItemTimeSignatureKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemTimestampKeyWrapper: String {
    get {
      NSMetadataItemTimestampKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemTitleKeyWrapper: String {
    get {
      NSMetadataItemTitleKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemTotalBitRateKeyWrapper: String {
    get {
      NSMetadataItemTotalBitRateKey
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSMetadataItemURLKeyWrapper: String {
    get {
      NSMetadataItemURLKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemVersionKeyWrapper: String {
    get {
      NSMetadataItemVersionKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemVideoBitRateKeyWrapper: String {
    get {
      NSMetadataItemVideoBitRateKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemWhereFromsKeyWrapper: String {
    get {
      NSMetadataItemWhereFromsKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataItemWhiteBalanceKeyWrapper: String {
    get {
      NSMetadataItemWhiteBalanceKey
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var NSMetadataQueryAccessibleUbiquitousExternalDocumentsScopeWrapper: String {
    get {
      NSMetadataQueryAccessibleUbiquitousExternalDocumentsScope
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataQueryIndexedLocalComputerScopeWrapper: String {
    get {
      NSMetadataQueryIndexedLocalComputerScope
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataQueryIndexedNetworkScopeWrapper: String {
    get {
      NSMetadataQueryIndexedNetworkScope
    }
  }

  @available(macOS, introduced: 10.4)
  @objc static public var NSMetadataQueryLocalComputerScopeWrapper: String {
    get {
      NSMetadataQueryLocalComputerScope
    }
  }

  @available(macOS, introduced: 10.4)
  @objc static public var NSMetadataQueryNetworkScopeWrapper: String {
    get {
      NSMetadataQueryNetworkScope
    }
  }

  @available(macOS, introduced: 10.4)
  @objc static public var NSMetadataQueryResultContentRelevanceAttributeWrapper: String {
    get {
      NSMetadataQueryResultContentRelevanceAttribute
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSMetadataQueryUbiquitousDataScopeWrapper: String {
    get {
      NSMetadataQueryUbiquitousDataScope
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSMetadataQueryUbiquitousDocumentsScopeWrapper: String {
    get {
      NSMetadataQueryUbiquitousDocumentsScope
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataQueryUpdateAddedItemsKeyWrapper: String {
    get {
      NSMetadataQueryUpdateAddedItemsKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataQueryUpdateChangedItemsKeyWrapper: String {
    get {
      NSMetadataQueryUpdateChangedItemsKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataQueryUpdateRemovedItemsKeyWrapper: String {
    get {
      NSMetadataQueryUpdateRemovedItemsKey
    }
  }

  @available(macOS, introduced: 10.4)
  @objc static public var NSMetadataQueryUserHomeScopeWrapper: String {
    get {
      NSMetadataQueryUserHomeScope
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var NSMetadataUbiquitousItemContainerDisplayNameKeyWrapper: String {
    get {
      NSMetadataUbiquitousItemContainerDisplayNameKey
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var NSMetadataUbiquitousItemDownloadRequestedKeyWrapper: String {
    get {
      NSMetadataUbiquitousItemDownloadRequestedKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataUbiquitousItemDownloadingErrorKeyWrapper: String {
    get {
      NSMetadataUbiquitousItemDownloadingErrorKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataUbiquitousItemDownloadingStatusCurrentWrapper: String {
    get {
      NSMetadataUbiquitousItemDownloadingStatusCurrent
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataUbiquitousItemDownloadingStatusDownloadedWrapper: String {
    get {
      NSMetadataUbiquitousItemDownloadingStatusDownloaded
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataUbiquitousItemDownloadingStatusKeyWrapper: String {
    get {
      NSMetadataUbiquitousItemDownloadingStatusKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataUbiquitousItemDownloadingStatusNotDownloadedWrapper: String {
    get {
      NSMetadataUbiquitousItemDownloadingStatusNotDownloaded
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSMetadataUbiquitousItemHasUnresolvedConflictsKeyWrapper: String {
    get {
      NSMetadataUbiquitousItemHasUnresolvedConflictsKey
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSMetadataUbiquitousItemIsDownloadingKeyWrapper: String {
    get {
      NSMetadataUbiquitousItemIsDownloadingKey
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var NSMetadataUbiquitousItemIsExternalDocumentKeyWrapper: String {
    get {
      NSMetadataUbiquitousItemIsExternalDocumentKey
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var NSMetadataUbiquitousItemIsSharedKeyWrapper: String {
    get {
      NSMetadataUbiquitousItemIsSharedKey
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSMetadataUbiquitousItemIsUploadedKeyWrapper: String {
    get {
      NSMetadataUbiquitousItemIsUploadedKey
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSMetadataUbiquitousItemIsUploadingKeyWrapper: String {
    get {
      NSMetadataUbiquitousItemIsUploadingKey
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSMetadataUbiquitousItemPercentDownloadedKeyWrapper: String {
    get {
      NSMetadataUbiquitousItemPercentDownloadedKey
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSMetadataUbiquitousItemPercentUploadedKeyWrapper: String {
    get {
      NSMetadataUbiquitousItemPercentUploadedKey
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var NSMetadataUbiquitousItemURLInLocalContainerKeyWrapper: String {
    get {
      NSMetadataUbiquitousItemURLInLocalContainerKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSMetadataUbiquitousItemUploadingErrorKeyWrapper: String {
    get {
      NSMetadataUbiquitousItemUploadingErrorKey
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var NSMetadataUbiquitousSharedItemCurrentUserPermissionsKeyWrapper: String {
    get {
      NSMetadataUbiquitousSharedItemCurrentUserPermissionsKey
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var NSMetadataUbiquitousSharedItemCurrentUserRoleKeyWrapper: String {
    get {
      NSMetadataUbiquitousSharedItemCurrentUserRoleKey
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var NSMetadataUbiquitousSharedItemMostRecentEditorNameComponentsKeyWrapper: String {
    get {
      NSMetadataUbiquitousSharedItemMostRecentEditorNameComponentsKey
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var NSMetadataUbiquitousSharedItemOwnerNameComponentsKeyWrapper: String {
    get {
      NSMetadataUbiquitousSharedItemOwnerNameComponentsKey
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var NSMetadataUbiquitousSharedItemPermissionsReadOnlyWrapper: String {
    get {
      NSMetadataUbiquitousSharedItemPermissionsReadOnly
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var NSMetadataUbiquitousSharedItemPermissionsReadWriteWrapper: String {
    get {
      NSMetadataUbiquitousSharedItemPermissionsReadWrite
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var NSMetadataUbiquitousSharedItemRoleOwnerWrapper: String {
    get {
      NSMetadataUbiquitousSharedItemRoleOwner
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var NSMetadataUbiquitousSharedItemRoleParticipantWrapper: String {
    get {
      NSMetadataUbiquitousSharedItemRoleParticipant
    }
  }

  @available(macOS, introduced: 11.3)
  @objc static public var NSMultipleUnderlyingErrorsKeyWrapper: String {
    get {
      NSMultipleUnderlyingErrorsKey
    }
  }

  @objc static public var NSNonOwnedPointerHashCallBacksWrapper: NSHashTableCallBacksWrapper {
    get {
      NSHashTableCallBacksWrapper(NSNonOwnedPointerHashCallBacks)
    }
  }

  @objc static public var NSNonOwnedPointerMapKeyCallBacksWrapper: NSMapTableKeyCallBacksWrapper {
    get {
      NSMapTableKeyCallBacksWrapper(NSNonOwnedPointerMapKeyCallBacks)
    }
  }

  @objc static public var NSNonOwnedPointerMapValueCallBacksWrapper: NSMapTableValueCallBacksWrapper {
    get {
      NSMapTableValueCallBacksWrapper(NSNonOwnedPointerMapValueCallBacks)
    }
  }

  @objc static public var NSNonOwnedPointerOrNullMapKeyCallBacksWrapper: NSMapTableKeyCallBacksWrapper {
    get {
      NSMapTableKeyCallBacksWrapper(NSNonOwnedPointerOrNullMapKeyCallBacks)
    }
  }

  @objc static public var NSNonRetainedObjectHashCallBacksWrapper: NSHashTableCallBacksWrapper {
    get {
      NSHashTableCallBacksWrapper(NSNonRetainedObjectHashCallBacks)
    }
  }

  @objc static public var NSNonRetainedObjectMapKeyCallBacksWrapper: NSMapTableKeyCallBacksWrapper {
    get {
      NSMapTableKeyCallBacksWrapper(NSNonRetainedObjectMapKeyCallBacks)
    }
  }

  @objc static public var NSNonRetainedObjectMapValueCallBacksWrapper: NSMapTableValueCallBacksWrapper {
    get {
      NSMapTableValueCallBacksWrapper(NSNonRetainedObjectMapValueCallBacks)
    }
  }

  @objc static public var NSNotFoundWrapper: Int {
    get {
      NSNotFound
    }
  }

  @objc static public var NSNotificationDeliverImmediatelyWrapper: OptionsWrapper5 {
    get {
      OptionsWrapper5(NSNotificationDeliverImmediately)
    }
  }

  @objc static public var NSNotificationPostToAllSessionsWrapper: OptionsWrapper5 {
    get {
      OptionsWrapper5(NSNotificationPostToAllSessions)
    }
  }

  @objc static public var NSOSStatusErrorDomainWrapper: String {
    get {
      NSOSStatusErrorDomain
    }
  }

  @objc static public var NSObjectHashCallBacksWrapper: NSHashTableCallBacksWrapper {
    get {
      NSHashTableCallBacksWrapper(NSObjectHashCallBacks)
    }
  }

  @objc static public var NSObjectMapKeyCallBacksWrapper: NSMapTableKeyCallBacksWrapper {
    get {
      NSMapTableKeyCallBacksWrapper(NSObjectMapKeyCallBacks)
    }
  }

  @objc static public var NSObjectMapValueCallBacksWrapper: NSMapTableValueCallBacksWrapper {
    get {
      NSMapTableValueCallBacksWrapper(NSObjectMapValueCallBacks)
    }
  }

  @objc static public var NSOperationNotSupportedForKeyExceptionWrapper: String {
    get {
      NSOperationNotSupportedForKeyException
    }
  }

  @objc static public var NSOwnedObjectIdentityHashCallBacksWrapper: NSHashTableCallBacksWrapper {
    get {
      NSHashTableCallBacksWrapper(NSOwnedObjectIdentityHashCallBacks)
    }
  }

  @objc static public var NSOwnedPointerHashCallBacksWrapper: NSHashTableCallBacksWrapper {
    get {
      NSHashTableCallBacksWrapper(NSOwnedPointerHashCallBacks)
    }
  }

  @objc static public var NSOwnedPointerMapKeyCallBacksWrapper: NSMapTableKeyCallBacksWrapper {
    get {
      NSMapTableKeyCallBacksWrapper(NSOwnedPointerMapKeyCallBacks)
    }
  }

  @objc static public var NSOwnedPointerMapValueCallBacksWrapper: NSMapTableValueCallBacksWrapper {
    get {
      NSMapTableValueCallBacksWrapper(NSOwnedPointerMapValueCallBacks)
    }
  }

  @objc static public var NSPOSIXErrorDomainWrapper: String {
    get {
      NSPOSIXErrorDomain
    }
  }

  @available(macOS, introduced: 10.6, deprecated: 10.10)
  @objc static public var NSPersianCalendarWrapper: String {
    get {
      NSPersianCalendar
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var NSPersonNameComponentDelimiterWrapper: String {
    get {
      NSPersonNameComponentDelimiter
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var NSPersonNameComponentFamilyNameWrapper: String {
    get {
      NSPersonNameComponentFamilyName
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var NSPersonNameComponentGivenNameWrapper: String {
    get {
      NSPersonNameComponentGivenName
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var NSPersonNameComponentKeyWrapper: String {
    get {
      NSPersonNameComponentKey
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var NSPersonNameComponentMiddleNameWrapper: String {
    get {
      NSPersonNameComponentMiddleName
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var NSPersonNameComponentNicknameWrapper: String {
    get {
      NSPersonNameComponentNickname
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var NSPersonNameComponentPrefixWrapper: String {
    get {
      NSPersonNameComponentPrefix
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var NSPersonNameComponentSuffixWrapper: String {
    get {
      NSPersonNameComponentSuffix
    }
  }

  @objc static public var NSPointerToStructHashCallBacksWrapper: NSHashTableCallBacksWrapper {
    get {
      NSHashTableCallBacksWrapper(NSPointerToStructHashCallBacks)
    }
  }

  @objc static public var NSRecoveryAttempterErrorKeyWrapper: String {
    get {
      NSRecoveryAttempterErrorKey
    }
  }

  @available(macOS, introduced: 10.6, deprecated: 10.10)
  @objc static public var NSRepublicOfChinaCalendarWrapper: String {
    get {
      NSRepublicOfChinaCalendar
    }
  }

  @available(macOS, introduced: 10.3)
  @objc static public var NSStreamSOCKSErrorDomainWrapper: String {
    get {
      NSStreamSOCKSErrorDomain
    }
  }

  @available(macOS, introduced: 10.3)
  @objc static public var NSStreamSocketSSLErrorDomainWrapper: String {
    get {
      NSStreamSocketSSLErrorDomain
    }
  }

  @objc static public var NSStringEncodingErrorKeyWrapper: String {
    get {
      NSStringEncodingErrorKey
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var NSURLAuthenticationMethodClientCertificateWrapper: String {
    get {
      NSURLAuthenticationMethodClientCertificate
    }
  }

  @available(macOS, introduced: 10.2)
  @objc static public var NSURLAuthenticationMethodDefaultWrapper: String {
    get {
      NSURLAuthenticationMethodDefault
    }
  }

  @available(macOS, introduced: 10.2)
  @objc static public var NSURLAuthenticationMethodHTMLFormWrapper: String {
    get {
      NSURLAuthenticationMethodHTMLForm
    }
  }

  @available(macOS, introduced: 10.2)
  @objc static public var NSURLAuthenticationMethodHTTPBasicWrapper: String {
    get {
      NSURLAuthenticationMethodHTTPBasic
    }
  }

  @available(macOS, introduced: 10.2)
  @objc static public var NSURLAuthenticationMethodHTTPDigestWrapper: String {
    get {
      NSURLAuthenticationMethodHTTPDigest
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSURLAuthenticationMethodNTLMWrapper: String {
    get {
      NSURLAuthenticationMethodNTLM
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSURLAuthenticationMethodNegotiateWrapper: String {
    get {
      NSURLAuthenticationMethodNegotiate
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var NSURLAuthenticationMethodServerTrustWrapper: String {
    get {
      NSURLAuthenticationMethodServerTrust
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSURLCredentialStorageRemoveSynchronizableCredentialsWrapper: String {
    get {
      NSURLCredentialStorageRemoveSynchronizableCredentials
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var NSURLErrorBackgroundTaskCancelledReasonKeyWrapper: String {
    get {
      NSURLErrorBackgroundTaskCancelledReasonKey
    }
  }

  @objc static public var NSURLErrorDomainWrapper: String {
    get {
      NSURLErrorDomain
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var NSURLErrorFailingURLErrorKeyWrapper: String {
    get {
      NSURLErrorFailingURLErrorKey
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var NSURLErrorFailingURLPeerTrustErrorKeyWrapper: String {
    get {
      NSURLErrorFailingURLPeerTrustErrorKey
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var NSURLErrorFailingURLStringErrorKeyWrapper: String {
    get {
      NSURLErrorFailingURLStringErrorKey
    }
  }

  @objc static public var NSURLErrorKeyWrapper: String {
    get {
      NSURLErrorKey
    }
  }

  @available(macOS, introduced: 10.15)
  @objc static public var NSURLErrorNetworkUnavailableReasonKeyWrapper: String {
    get {
      NSURLErrorNetworkUnavailableReasonKey
    }
  }

  @objc static public var NSURLFileSchemeWrapper: String {
    get {
      NSURLFileScheme
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSURLProtectionSpaceFTPWrapper: String {
    get {
      NSURLProtectionSpaceFTP
    }
  }

  @available(macOS, introduced: 10.2)
  @objc static public var NSURLProtectionSpaceFTPProxyWrapper: String {
    get {
      NSURLProtectionSpaceFTPProxy
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSURLProtectionSpaceHTTPWrapper: String {
    get {
      NSURLProtectionSpaceHTTP
    }
  }

  @available(macOS, introduced: 10.2)
  @objc static public var NSURLProtectionSpaceHTTPProxyWrapper: String {
    get {
      NSURLProtectionSpaceHTTPProxy
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSURLProtectionSpaceHTTPSWrapper: String {
    get {
      NSURLProtectionSpaceHTTPS
    }
  }

  @available(macOS, introduced: 10.2)
  @objc static public var NSURLProtectionSpaceHTTPSProxyWrapper: String {
    get {
      NSURLProtectionSpaceHTTPSProxy
    }
  }

  @available(macOS, introduced: 10.2)
  @objc static public var NSURLProtectionSpaceSOCKSProxyWrapper: String {
    get {
      NSURLProtectionSpaceSOCKSProxy
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSURLSessionDownloadTaskResumeDataWrapper: String {
    get {
      NSURLSessionDownloadTaskResumeData
    }
  }

  @available(macOS, introduced: 14.0)
  @objc static public var NSURLSessionUploadTaskResumeDataWrapper: String {
    get {
      NSURLSessionUploadTaskResumeData
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSUbiquitousKeyValueStoreChangeReasonKeyWrapper: String {
    get {
      NSUbiquitousKeyValueStoreChangeReasonKey
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSUbiquitousKeyValueStoreChangedKeysKeyWrapper: String {
    get {
      NSUbiquitousKeyValueStoreChangedKeysKey
    }
  }

  @objc static public var NSUnderlyingErrorKeyWrapper: String {
    get {
      NSUnderlyingErrorKey
    }
  }

  @objc static public var NSUndoCloseGroupingRunLoopOrderingWrapper: Int {
    get {
      NSUndoCloseGroupingRunLoopOrdering
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSUndoManagerGroupIsDiscardableKeyWrapper: String {
    get {
      NSUndoManagerGroupIsDiscardableKey
    }
  }

  @objc static public var NSUserActivityTypeBrowsingWebWrapper: String {
    get {
      NSUserActivityTypeBrowsingWeb
    }
  }

  @available(macOS, introduced: 10.8, deprecated: 11.0)
  @objc static public var NSUserNotificationDefaultSoundNameWrapper: String {
    get {
      NSUserNotificationDefaultSoundName
    }
  }

  @objc static public var NSFoundationVersionNumber10_0Wrapper: Double {
    get {
      NSFoundationVersionNumber10_0
    }
  }

  @objc static public var NSFoundationVersionNumber10_1Wrapper: Double {
    get {
      NSFoundationVersionNumber10_1
    }
  }

  @objc static public var NSFoundationVersionNumber10_10Wrapper: Double {
    get {
      NSFoundationVersionNumber10_10
    }
  }

  @objc static public var NSFoundationVersionNumber10_10_1Wrapper: Double {
    get {
      NSFoundationVersionNumber10_10_1
    }
  }

  @objc static public var NSFoundationVersionNumber10_10_2Wrapper: Double {
    get {
      NSFoundationVersionNumber10_10_2
    }
  }

  @objc static public var NSFoundationVersionNumber10_10_3Wrapper: Double {
    get {
      NSFoundationVersionNumber10_10_3
    }
  }

  @objc static public var NSFoundationVersionNumber10_10_4Wrapper: Double {
    get {
      NSFoundationVersionNumber10_10_4
    }
  }

  @objc static public var NSFoundationVersionNumber10_11_1Wrapper: Double {
    get {
      NSFoundationVersionNumber10_11_1
    }
  }

  @objc static public var NSFoundationVersionNumber10_11_2Wrapper: Double {
    get {
      NSFoundationVersionNumber10_11_2
    }
  }

  @objc static public var NSFoundationVersionNumber10_11_3Wrapper: Double {
    get {
      NSFoundationVersionNumber10_11_3
    }
  }

  @objc static public var NSFoundationVersionNumber10_1_1Wrapper: Double {
    get {
      NSFoundationVersionNumber10_1_1
    }
  }

  @objc static public var NSFoundationVersionNumber10_1_2Wrapper: Double {
    get {
      NSFoundationVersionNumber10_1_2
    }
  }

  @objc static public var NSFoundationVersionNumber10_1_3Wrapper: Double {
    get {
      NSFoundationVersionNumber10_1_3
    }
  }

  @objc static public var NSFoundationVersionNumber10_1_4Wrapper: Double {
    get {
      NSFoundationVersionNumber10_1_4
    }
  }

  @objc static public var NSFoundationVersionNumber10_2Wrapper: Double {
    get {
      NSFoundationVersionNumber10_2
    }
  }

  @objc static public var NSFoundationVersionNumber10_2_1Wrapper: Double {
    get {
      NSFoundationVersionNumber10_2_1
    }
  }

  @objc static public var NSFoundationVersionNumber10_2_2Wrapper: Double {
    get {
      NSFoundationVersionNumber10_2_2
    }
  }

  @objc static public var NSFoundationVersionNumber10_2_3Wrapper: Double {
    get {
      NSFoundationVersionNumber10_2_3
    }
  }

  @objc static public var NSFoundationVersionNumber10_2_4Wrapper: Double {
    get {
      NSFoundationVersionNumber10_2_4
    }
  }

  @objc static public var NSFoundationVersionNumber10_2_5Wrapper: Double {
    get {
      NSFoundationVersionNumber10_2_5
    }
  }

  @objc static public var NSFoundationVersionNumber10_2_6Wrapper: Double {
    get {
      NSFoundationVersionNumber10_2_6
    }
  }

  @objc static public var NSFoundationVersionNumber10_2_7Wrapper: Double {
    get {
      NSFoundationVersionNumber10_2_7
    }
  }

  @objc static public var NSFoundationVersionNumber10_2_8Wrapper: Double {
    get {
      NSFoundationVersionNumber10_2_8
    }
  }

  @objc static public var NSFoundationVersionNumber10_3Wrapper: Double {
    get {
      NSFoundationVersionNumber10_3
    }
  }

  @objc static public var NSFoundationVersionNumber10_3_1Wrapper: Double {
    get {
      NSFoundationVersionNumber10_3_1
    }
  }

  @objc static public var NSFoundationVersionNumber10_3_2Wrapper: Double {
    get {
      NSFoundationVersionNumber10_3_2
    }
  }

  @objc static public var NSFoundationVersionNumber10_3_3Wrapper: Double {
    get {
      NSFoundationVersionNumber10_3_3
    }
  }

  @objc static public var NSFoundationVersionNumber10_3_4Wrapper: Double {
    get {
      NSFoundationVersionNumber10_3_4
    }
  }

  @objc static public var NSFoundationVersionNumber10_3_5Wrapper: Double {
    get {
      NSFoundationVersionNumber10_3_5
    }
  }

  @objc static public var NSFoundationVersionNumber10_3_6Wrapper: Double {
    get {
      NSFoundationVersionNumber10_3_6
    }
  }

  @objc static public var NSFoundationVersionNumber10_3_7Wrapper: Double {
    get {
      NSFoundationVersionNumber10_3_7
    }
  }

  @objc static public var NSFoundationVersionNumber10_3_8Wrapper: Double {
    get {
      NSFoundationVersionNumber10_3_8
    }
  }

  @objc static public var NSFoundationVersionNumber10_3_9Wrapper: Double {
    get {
      NSFoundationVersionNumber10_3_9
    }
  }

  @objc static public var NSFoundationVersionNumber10_4Wrapper: Double {
    get {
      NSFoundationVersionNumber10_4
    }
  }

  @objc static public var NSFoundationVersionNumber10_4_1Wrapper: Double {
    get {
      NSFoundationVersionNumber10_4_1
    }
  }

  @objc static public var NSFoundationVersionNumber10_4_10Wrapper: Double {
    get {
      NSFoundationVersionNumber10_4_10
    }
  }

  @objc static public var NSFoundationVersionNumber10_4_11Wrapper: Double {
    get {
      NSFoundationVersionNumber10_4_11
    }
  }

  @objc static public var NSFoundationVersionNumber10_4_2Wrapper: Double {
    get {
      NSFoundationVersionNumber10_4_2
    }
  }

  @objc static public var NSFoundationVersionNumber10_4_3Wrapper: Double {
    get {
      NSFoundationVersionNumber10_4_3
    }
  }

  @objc static public var NSFoundationVersionNumber10_4_4_IntelWrapper: Double {
    get {
      NSFoundationVersionNumber10_4_4_Intel
    }
  }

  @objc static public var NSFoundationVersionNumber10_4_4_PowerPCWrapper: Double {
    get {
      NSFoundationVersionNumber10_4_4_PowerPC
    }
  }

  @objc static public var NSFoundationVersionNumber10_4_5Wrapper: Double {
    get {
      NSFoundationVersionNumber10_4_5
    }
  }

  @objc static public var NSFoundationVersionNumber10_4_6Wrapper: Double {
    get {
      NSFoundationVersionNumber10_4_6
    }
  }

  @objc static public var NSFoundationVersionNumber10_4_7Wrapper: Double {
    get {
      NSFoundationVersionNumber10_4_7
    }
  }

  @objc static public var NSFoundationVersionNumber10_4_8Wrapper: Double {
    get {
      NSFoundationVersionNumber10_4_8
    }
  }

  @objc static public var NSFoundationVersionNumber10_4_9Wrapper: Double {
    get {
      NSFoundationVersionNumber10_4_9
    }
  }

  @objc static public var NSFoundationVersionNumber10_5Wrapper: Double {
    get {
      NSFoundationVersionNumber10_5
    }
  }

  @objc static public var NSFoundationVersionNumber10_5_1Wrapper: Double {
    get {
      NSFoundationVersionNumber10_5_1
    }
  }

  @objc static public var NSFoundationVersionNumber10_5_2Wrapper: Double {
    get {
      NSFoundationVersionNumber10_5_2
    }
  }

  @objc static public var NSFoundationVersionNumber10_5_3Wrapper: Double {
    get {
      NSFoundationVersionNumber10_5_3
    }
  }

  @objc static public var NSFoundationVersionNumber10_5_4Wrapper: Double {
    get {
      NSFoundationVersionNumber10_5_4
    }
  }

  @objc static public var NSFoundationVersionNumber10_5_5Wrapper: Double {
    get {
      NSFoundationVersionNumber10_5_5
    }
  }

  @objc static public var NSFoundationVersionNumber10_5_6Wrapper: Double {
    get {
      NSFoundationVersionNumber10_5_6
    }
  }

  @objc static public var NSFoundationVersionNumber10_5_7Wrapper: Double {
    get {
      NSFoundationVersionNumber10_5_7
    }
  }

  @objc static public var NSFoundationVersionNumber10_5_8Wrapper: Double {
    get {
      NSFoundationVersionNumber10_5_8
    }
  }

  @objc static public var NSFoundationVersionNumber10_6Wrapper: Double {
    get {
      NSFoundationVersionNumber10_6
    }
  }

  @objc static public var NSFoundationVersionNumber10_6_1Wrapper: Double {
    get {
      NSFoundationVersionNumber10_6_1
    }
  }

  @objc static public var NSFoundationVersionNumber10_6_2Wrapper: Double {
    get {
      NSFoundationVersionNumber10_6_2
    }
  }

  @objc static public var NSFoundationVersionNumber10_6_3Wrapper: Double {
    get {
      NSFoundationVersionNumber10_6_3
    }
  }

  @objc static public var NSFoundationVersionNumber10_6_4Wrapper: Double {
    get {
      NSFoundationVersionNumber10_6_4
    }
  }

  @objc static public var NSFoundationVersionNumber10_6_5Wrapper: Double {
    get {
      NSFoundationVersionNumber10_6_5
    }
  }

  @objc static public var NSFoundationVersionNumber10_6_6Wrapper: Double {
    get {
      NSFoundationVersionNumber10_6_6
    }
  }

  @objc static public var NSFoundationVersionNumber10_6_7Wrapper: Double {
    get {
      NSFoundationVersionNumber10_6_7
    }
  }

  @objc static public var NSFoundationVersionNumber10_6_8Wrapper: Double {
    get {
      NSFoundationVersionNumber10_6_8
    }
  }

  @objc static public var NSFoundationVersionNumber10_7Wrapper: Double {
    get {
      NSFoundationVersionNumber10_7
    }
  }

  @objc static public var NSFoundationVersionNumber10_7_1Wrapper: Double {
    get {
      NSFoundationVersionNumber10_7_1
    }
  }

  @objc static public var NSFoundationVersionNumber10_7_2Wrapper: Double {
    get {
      NSFoundationVersionNumber10_7_2
    }
  }

  @objc static public var NSFoundationVersionNumber10_7_3Wrapper: Double {
    get {
      NSFoundationVersionNumber10_7_3
    }
  }

  @objc static public var NSFoundationVersionNumber10_7_4Wrapper: Double {
    get {
      NSFoundationVersionNumber10_7_4
    }
  }

  @objc static public var NSFoundationVersionNumber10_8Wrapper: Double {
    get {
      NSFoundationVersionNumber10_8
    }
  }

  @objc static public var NSFoundationVersionNumber10_8_1Wrapper: Double {
    get {
      NSFoundationVersionNumber10_8_1
    }
  }

  @objc static public var NSFoundationVersionNumber10_8_2Wrapper: Double {
    get {
      NSFoundationVersionNumber10_8_2
    }
  }

  @objc static public var NSFoundationVersionNumber10_8_3Wrapper: Double {
    get {
      NSFoundationVersionNumber10_8_3
    }
  }

  @objc static public var NSFoundationVersionNumber10_8_4Wrapper: Double {
    get {
      NSFoundationVersionNumber10_8_4
    }
  }

  @objc static public var NSFoundationVersionNumber10_9_2Wrapper: Double {
    get {
      NSFoundationVersionNumber10_9_2
    }
  }

  @objc static public var NSTimeIntervalSince1970Wrapper: Double {
    get {
      NSTimeIntervalSince1970
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var NSNotFoundWrapper1: Int {
    get {
      NSNotFound
    }
  }

  @objc static public var NSURLErrorBadURLWrapper: Int {
    get {
      NSURLErrorBadURL
    }
  }

  @objc static public var NSFormattingErrorWrapper: Int {
    get {
      NSFormattingError
    }
  }

  @objc static public var NSURLErrorUnknownWrapper: Int {
    get {
      NSURLErrorUnknown
    }
  }

  @objc static public var NSFileErrorMaximumWrapper: Int {
    get {
      NSFileErrorMaximum
    }
  }

  @objc static public var NSFileErrorMinimumWrapper: Int {
    get {
      NSFileErrorMinimum
    }
  }

  @objc static public var NSFileLockingErrorWrapper: Int {
    get {
      NSFileLockingError
    }
  }

  @objc static public var NSURLErrorTimedOutWrapper: Int {
    get {
      NSURLErrorTimedOut
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var NSCoderErrorMaximumWrapper: Int {
    get {
      NSCoderErrorMaximum
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var NSCoderErrorMinimumWrapper: Int {
    get {
      NSCoderErrorMinimum
    }
  }

  @objc static public var NSURLErrorCancelledWrapper: Int {
    get {
      NSURLErrorCancelled
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var NSBundleErrorMaximumWrapper: Int {
    get {
      NSBundleErrorMaximum
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var NSBundleErrorMinimumWrapper: Int {
    get {
      NSBundleErrorMinimum
    }
  }

  @objc static public var NSUserCancelledErrorWrapper: Int {
    get {
      NSUserCancelledError
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSExecutableLinkErrorWrapper: Int {
    get {
      NSExecutableLinkError
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSExecutableLoadErrorWrapper: Int {
    get {
      NSExecutableLoadError
    }
  }

  @objc static public var NSFileNoSuchFileErrorWrapper: Int {
    get {
      NSFileNoSuchFileError
    }
  }

  @objc static public var NSFileReadUnknownErrorWrapper: Int {
    get {
      NSFileReadUnknownError
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSURLErrorCallIsActiveWrapper: Int {
    get {
      NSURLErrorCallIsActive
    }
  }

  @available(macOS, introduced: 10.8)
  @objc static public var NSXPCConnectionInvalidWrapper: Int {
    get {
      NSXPCConnectionInvalid
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var NSCoderReadCorruptErrorWrapper: Int {
    get {
      NSCoderReadCorruptError
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSFileReadTooLargeErrorWrapper: Int {
    get {
      NSFileReadTooLargeError
    }
  }

  @objc static public var NSFileWriteUnknownErrorWrapper: Int {
    get {
      NSFileWriteUnknownError
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var NSCloudSharingOtherErrorWrapper: Int {
    get {
      NSCloudSharingOtherError
    }
  }

  @available(macOS, introduced: 10.13)
  @objc static public var NSCoderInvalidValueErrorWrapper: Int {
    get {
      NSCoderInvalidValueError
    }
  }

  @available(macOS, introduced: 10.15)
  @objc static public var NSCompressionFailedErrorWrapper: Int {
    get {
      NSCompressionFailedError
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSExecutableErrorMaximumWrapper: Int {
    get {
      NSExecutableErrorMaximum
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSExecutableErrorMinimumWrapper: Int {
    get {
      NSExecutableErrorMinimum
    }
  }

  @objc static public var NSFormattingErrorMaximumWrapper: Int {
    get {
      NSFormattingErrorMaximum
    }
  }

  @objc static public var NSFormattingErrorMinimumWrapper: Int {
    get {
      NSFormattingErrorMinimum
    }
  }

  @objc static public var NSURLErrorCannotFindHostWrapper: Int {
    get {
      NSURLErrorCannotFindHost
    }
  }

  @objc static public var NSURLErrorCannotMoveFileWrapper: Int {
    get {
      NSURLErrorCannotMoveFile
    }
  }

  @objc static public var NSURLErrorCannotOpenFileWrapper: Int {
    get {
      NSURLErrorCannotOpenFile
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSURLErrorDataNotAllowedWrapper: Int {
    get {
      NSURLErrorDataNotAllowed
    }
  }

  @objc static public var NSURLErrorUnsupportedURLWrapper: Int {
    get {
      NSURLErrorUnsupportedURL
    }
  }

  @objc static public var NSValidationErrorMaximumWrapper: Int {
    get {
      NSValidationErrorMaximum
    }
  }

  @objc static public var NSValidationErrorMinimumWrapper: Int {
    get {
      NSValidationErrorMinimum
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var NSCoderValueNotFoundErrorWrapper: Int {
    get {
      NSCoderValueNotFoundError
    }
  }

  @available(macOS, introduced: 10.15)
  @objc static public var NSCompressionErrorMaximumWrapper: Int {
    get {
      NSCompressionErrorMaximum
    }
  }

  @available(macOS, introduced: 10.15)
  @objc static public var NSCompressionErrorMinimumWrapper: Int {
    get {
      NSCompressionErrorMinimum
    }
  }

  @available(macOS, introduced: 10.8)
  @objc static public var NSFeatureUnsupportedErrorWrapper: Int {
    get {
      NSFeatureUnsupportedError
    }
  }

  @objc static public var NSFileReadNoSuchFileErrorWrapper: Int {
    get {
      NSFileReadNoSuchFileError
    }
  }

  @objc static public var NSKeyValueValidationErrorWrapper: Int {
    get {
      NSKeyValueValidationError
    }
  }

  @objc static public var NSURLErrorCannotCloseFileWrapper: Int {
    get {
      NSURLErrorCannotCloseFile
    }
  }

  @objc static public var NSURLErrorDNSLookupFailedWrapper: Int {
    get {
      NSURLErrorDNSLookupFailed
    }
  }

  @objc static public var NSURLErrorFileIsDirectoryWrapper: Int {
    get {
      NSURLErrorFileIsDirectory
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var NSCloudSharingErrorMaximumWrapper: Int {
    get {
      NSCloudSharingErrorMaximum
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var NSCloudSharingErrorMinimumWrapper: Int {
    get {
      NSCloudSharingErrorMinimum
    }
  }

  @available(macOS, introduced: 10.15)
  @objc static public var NSDecompressionFailedErrorWrapper: Int {
    get {
      NSDecompressionFailedError
    }
  }

  @objc static public var NSFileReadCorruptFileErrorWrapper: Int {
    get {
      NSFileReadCorruptFileError
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSFileWriteFileExistsErrorWrapper: Int {
    get {
      NSFileWriteFileExistsError
    }
  }

  @objc static public var NSFileWriteOutOfSpaceErrorWrapper: Int {
    get {
      NSFileWriteOutOfSpaceError
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var NSPropertyListErrorMaximumWrapper: Int {
    get {
      NSPropertyListErrorMaximum
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var NSPropertyListErrorMinimumWrapper: Int {
    get {
      NSPropertyListErrorMinimum
    }
  }

  @objc static public var NSURLErrorCannotCreateFileWrapper: Int {
    get {
      NSURLErrorCannotCreateFile
    }
  }

  @objc static public var NSURLErrorCannotRemoveFileWrapper: Int {
    get {
      NSURLErrorCannotRemoveFile
    }
  }

  @objc static public var NSURLErrorFileDoesNotExistWrapper: Int {
    get {
      NSURLErrorFileDoesNotExist
    }
  }

  @objc static public var NSURLErrorZeroByteResourceWrapper: Int {
    get {
      NSURLErrorZeroByteResource
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var NSUserActivityErrorMaximumWrapper: Int {
    get {
      NSUserActivityErrorMaximum
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var NSUserActivityErrorMinimumWrapper: Int {
    get {
      NSUserActivityErrorMinimum
    }
  }

  @available(macOS, introduced: 10.8)
  @objc static public var NSXPCConnectionInterruptedWrapper: Int {
    get {
      NSXPCConnectionInterrupted
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var NSCloudSharingConflictErrorWrapper: Int {
    get {
      NSCloudSharingConflictError
    }
  }

  @objc static public var NSFileReadNoPermissionErrorWrapper: Int {
    get {
      NSFileReadNoPermissionError
    }
  }

  @objc static public var NSURLErrorBadServerResponseWrapper: Int {
    get {
      NSURLErrorBadServerResponse
    }
  }

  @objc static public var NSURLErrorCannotWriteToFileWrapper: Int {
    get {
      NSURLErrorCannotWriteToFile
    }
  }

  @available(macOS, introduced: 10.8)
  @objc static public var NSXPCConnectionErrorMaximumWrapper: Int {
    get {
      NSXPCConnectionErrorMaximum
    }
  }

  @available(macOS, introduced: 10.8)
  @objc static public var NSXPCConnectionErrorMinimumWrapper: Int {
    get {
      NSXPCConnectionErrorMinimum
    }
  }

  @available(macOS, introduced: 10.8)
  @objc static public var NSXPCConnectionReplyInvalidWrapper: Int {
    get {
      NSXPCConnectionReplyInvalid
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSExecutableNotLoadableErrorWrapper: Int {
    get {
      NSExecutableNotLoadableError
    }
  }

  @objc static public var NSFileWriteNoPermissionErrorWrapper: Int {
    get {
      NSFileWriteNoPermissionError
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSUbiquitousFileErrorMaximumWrapper: Int {
    get {
      NSUbiquitousFileErrorMaximum
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSUbiquitousFileErrorMinimumWrapper: Int {
    get {
      NSUbiquitousFileErrorMinimum
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var NSFileManagerUnmountBusyErrorWrapper: Int {
    get {
      NSFileManagerUnmountBusyError
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var NSPropertyListReadStreamErrorWrapper: Int {
    get {
      NSPropertyListReadStreamError
    }
  }

  @objc static public var NSURLErrorCannotConnectToHostWrapper: Int {
    get {
      NSURLErrorCannotConnectToHost
    }
  }

  @objc static public var NSURLErrorCannotDecodeRawDataWrapper: Int {
    get {
      NSURLErrorCannotDecodeRawData
    }
  }

  @objc static public var NSURLErrorCannotParseResponseWrapper: Int {
    get {
      NSURLErrorCannotParseResponse
    }
  }

  @available(macOS, introduced: 10.12.4)
  @objc static public var NSURLErrorFileOutsideSafeAreaWrapper: Int {
    get {
      NSURLErrorFileOutsideSafeArea
    }
  }

  @objc static public var NSURLErrorResourceUnavailableWrapper: Int {
    get {
      NSURLErrorResourceUnavailable
    }
  }

  @objc static public var NSFileReadInvalidFileNameErrorWrapper: Int {
    get {
      NSFileReadInvalidFileNameError
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var NSFileWriteVolumeReadOnlyErrorWrapper: Int {
    get {
      NSFileWriteVolumeReadOnlyError
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var NSPropertyListReadCorruptErrorWrapper: Int {
    get {
      NSPropertyListReadCorruptError
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var NSPropertyListWriteStreamErrorWrapper: Int {
    get {
      NSPropertyListWriteStreamError
    }
  }

  @objc static public var NSURLErrorHTTPTooManyRedirectsWrapper: Int {
    get {
      NSURLErrorHTTPTooManyRedirects
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var NSCloudSharingNoPermissionErrorWrapper: Int {
    get {
      NSCloudSharingNoPermissionError
    }
  }

  @objc static public var NSFileWriteInvalidFileNameErrorWrapper: Int {
    get {
      NSFileWriteInvalidFileNameError
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var NSPropertyListWriteInvalidErrorWrapper: Int {
    get {
      NSPropertyListWriteInvalidError
    }
  }

  @objc static public var NSURLErrorCannotLoadFromNetworkWrapper: Int {
    get {
      NSURLErrorCannotLoadFromNetwork
    }
  }

  @objc static public var NSURLErrorNetworkConnectionLostWrapper: Int {
    get {
      NSURLErrorNetworkConnectionLost
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var NSCloudSharingQuotaExceededErrorWrapper: Int {
    get {
      NSCloudSharingQuotaExceededError
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSExecutableRuntimeMismatchErrorWrapper: Int {
    get {
      NSExecutableRuntimeMismatchError
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var NSFileManagerUnmountUnknownErrorWrapper: Int {
    get {
      NSFileManagerUnmountUnknownError
    }
  }

  @objc static public var NSFileReadUnsupportedSchemeErrorWrapper: Int {
    get {
      NSFileReadUnsupportedSchemeError
    }
  }

  @objc static public var NSURLErrorNotConnectedToInternetWrapper: Int {
    get {
      NSURLErrorNotConnectedToInternet
    }
  }

  @objc static public var NSURLErrorSecureConnectionFailedWrapper: Int {
    get {
      NSURLErrorSecureConnectionFailed
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSUbiquitousFileUnavailableErrorWrapper: Int {
    get {
      NSUbiquitousFileUnavailableError
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var NSUserActivityHandoffFailedErrorWrapper: Int {
    get {
      NSUserActivityHandoffFailedError
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var NSCloudSharingNetworkFailureErrorWrapper: Int {
    get {
      NSCloudSharingNetworkFailureError
    }
  }

  @objc static public var NSFileWriteUnsupportedSchemeErrorWrapper: Int {
    get {
      NSFileWriteUnsupportedSchemeError
    }
  }

  @objc static public var NSURLErrorCannotDecodeContentDataWrapper: Int {
    get {
      NSURLErrorCannotDecodeContentData
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSURLErrorInternationalRoamingOffWrapper: Int {
    get {
      NSURLErrorInternationalRoamingOff
    }
  }

  @objc static public var NSURLErrorNoPermissionsToReadFileWrapper: Int {
    get {
      NSURLErrorNoPermissionsToReadFile
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSURLErrorDataLengthExceedsMaximumWrapper: Int {
    get {
      NSURLErrorDataLengthExceedsMaximum
    }
  }

  @objc static public var NSURLErrorClientCertificateRejectedWrapper: Int {
    get {
      NSURLErrorClientCertificateRejected
    }
  }

  @objc static public var NSURLErrorClientCertificateRequiredWrapper: Int {
    get {
      NSURLErrorClientCertificateRequired
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSFileReadUnknownStringEncodingErrorWrapper: Int {
    get {
      NSFileReadUnknownStringEncodingError
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var NSURLErrorRequestBodyStreamExhaustedWrapper: Int {
    get {
      NSURLErrorRequestBodyStreamExhausted
    }
  }

  @objc static public var NSURLErrorServerCertificateUntrustedWrapper: Int {
    get {
      NSURLErrorServerCertificateUntrusted
    }
  }

  @objc static public var NSURLErrorUserAuthenticationRequiredWrapper: Int {
    get {
      NSURLErrorUserAuthenticationRequired
    }
  }

  @available(macOS, introduced: 10.5)
  @objc static public var NSExecutableArchitectureMismatchErrorWrapper: Int {
    get {
      NSExecutableArchitectureMismatchError
    }
  }

  @available(macOS, introduced: 10.6)
  @objc static public var NSPropertyListReadUnknownVersionErrorWrapper: Int {
    get {
      NSPropertyListReadUnknownVersionError
    }
  }

  @objc static public var NSURLErrorServerCertificateHasBadDateWrapper: Int {
    get {
      NSURLErrorServerCertificateHasBadDate
    }
  }

  @objc static public var NSURLErrorUserCancelledAuthenticationWrapper: Int {
    get {
      NSURLErrorUserCancelledAuthentication
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var NSCloudSharingTooManyParticipantsErrorWrapper: Int {
    get {
      NSCloudSharingTooManyParticipantsError
    }
  }

  @objc static public var NSURLErrorServerCertificateNotYetValidWrapper: Int {
    get {
      NSURLErrorServerCertificateNotYetValid
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var NSBundleOnDemandResourceInvalidTagErrorWrapper: Int {
    get {
      NSBundleOnDemandResourceInvalidTagError
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var NSBundleOnDemandResourceOutOfSpaceErrorWrapper: Int {
    get {
      NSBundleOnDemandResourceOutOfSpaceError
    }
  }

  @objc static public var NSURLErrorRedirectToNonExistentLocationWrapper: Int {
    get {
      NSURLErrorRedirectToNonExistentLocation
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var NSUserActivityConnectionUnavailableErrorWrapper: Int {
    get {
      NSUserActivityConnectionUnavailableError
    }
  }

  @objc static public var NSFileReadInapplicableStringEncodingErrorWrapper: Int {
    get {
      NSFileReadInapplicableStringEncodingError
    }
  }

  @objc static public var NSURLErrorDownloadDecodingFailedMidStreamWrapper: Int {
    get {
      NSURLErrorDownloadDecodingFailedMidStream
    }
  }

  @objc static public var NSURLErrorServerCertificateHasUnknownRootWrapper: Int {
    get {
      NSURLErrorServerCertificateHasUnknownRoot
    }
  }

  @objc static public var NSFileWriteInapplicableStringEncodingErrorWrapper: Int {
    get {
      NSFileWriteInapplicableStringEncodingError
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var NSURLErrorBackgroundSessionWasDisconnectedWrapper: Int {
    get {
      NSURLErrorBackgroundSessionWasDisconnected
    }
  }

  @objc static public var NSURLErrorDownloadDecodingFailedToCompleteWrapper: Int {
    get {
      NSURLErrorDownloadDecodingFailedToComplete
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSUbiquitousFileNotUploadedDueToQuotaErrorWrapper: Int {
    get {
      NSUbiquitousFileNotUploadedDueToQuotaError
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var NSUbiquitousFileUbiquityServerNotAvailableWrapper: Int {
    get {
      NSUbiquitousFileUbiquityServerNotAvailable
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var NSUserActivityHandoffUserInfoTooLargeErrorWrapper: Int {
    get {
      NSUserActivityHandoffUserInfoTooLargeError
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var NSUserActivityRemoteApplicationTimedOutErrorWrapper: Int {
    get {
      NSUserActivityRemoteApplicationTimedOutError
    }
  }

  @available(macOS, introduced: 13.0)
  @objc static public var NSXPCConnectionCodeSigningRequirementFailureWrapper: Int {
    get {
      NSXPCConnectionCodeSigningRequirementFailure
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var NSBundleOnDemandResourceExceededMaximumSizeErrorWrapper: Int {
    get {
      NSBundleOnDemandResourceExceededMaximumSizeError
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var NSURLErrorBackgroundSessionInUseByAnotherProcessWrapper: Int {
    get {
      NSURLErrorBackgroundSessionInUseByAnotherProcess
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var NSURLErrorBackgroundSessionRequiresSharedContainerWrapper: Int {
    get {
      NSURLErrorBackgroundSessionRequiresSharedContainer
    }
  }

  @available(macOS, introduced: 10.11)
  @objc static public var NSURLErrorAppTransportSecurityRequiresSecureConnectionWrapper: Int {
    get {
      NSURLErrorAppTransportSecurityRequiresSecureConnection
    }
  }

  @objc static public func NSConvertHostDoubleToSwappedWrapper(_ x: Double) -> NSSwappedDoubleWrapper {
    let result = NSConvertHostDoubleToSwapped(x)
    return NSSwappedDoubleWrapper(result)
  }

  @objc static public func NSConvertHostFloatToSwappedWrapper(_ x: Float) -> NSSwappedFloatWrapper {
    let result = NSConvertHostFloatToSwapped(x)
    return NSSwappedFloatWrapper(result)
  }

  @objc static public func NSConvertSwappedDoubleToHostWrapper(_ x: NSSwappedDoubleWrapper) -> Double {
    return NSConvertSwappedDoubleToHost(x.wrappedInstance)
  }

  @objc static public func NSConvertSwappedFloatToHostWrapper(_ x: NSSwappedFloatWrapper) -> Float {
    return NSConvertSwappedFloatToHost(x.wrappedInstance)
  }

  @objc static public func NSCreateHashTableWrapper(_ callBacks: NSHashTableCallBacksWrapper, _ capacity: Int) -> NSHashTable {
    return NSCreateHashTable(callBacks.wrappedInstance, capacity)
  }

  @objc static public func NSCreateMapTableWrapper(_ keyCallBacks: NSMapTableKeyCallBacksWrapper, _ valueCallBacks: NSMapTableValueCallBacksWrapper, _ capacity: Int) -> NSMapTable {
    return NSCreateMapTable(keyCallBacks.wrappedInstance, valueCallBacks.wrappedInstance, capacity)
  }

  @available(macOS, introduced: 10.10)
  @objc static public func NSEdgeInsetsEqualWrapper(_ aInsets: NSEdgeInsetsWrapper, _ bInsets: NSEdgeInsetsWrapper) -> Bool {
    return NSEdgeInsetsEqual(aInsets.wrappedInstance, bInsets.wrappedInstance)
  }

  @objc static public func NSEdgeInsetsMakeWrapper(_ top: Double, _ left: Double, _ bottom: Double, _ right: Double) -> NSEdgeInsetsWrapper {
    let result = NSEdgeInsetsMake(top, left, bottom, right)
    return NSEdgeInsetsWrapper(result)
  }

  @objc static public func NSFullUserNameWrapper() -> String {
    return NSFullUserName()
  }

  @objc static public func NSHomeDirectoryWrapper() -> String {
    return NSHomeDirectory()
  }

  @objc static public func NSHomeDirectoryForUserWrapper(_ userName: String?) -> String? {
    return NSHomeDirectoryForUser(userName)
  }

  @objc static public func NSHostByteOrderWrapper() -> Int {
    return NSHostByteOrder()
  }

  @objc static public func NSLogPageSizeWrapper() -> Int {
    return NSLogPageSize()
  }

  @objc static public func NSOpenStepRootDirectoryWrapper() -> String {
    return NSOpenStepRootDirectory()
  }

  @objc static public func NSPageSizeWrapper() -> Int {
    return NSPageSize()
  }

  @objc static public func NSRoundDownToMultipleOfPageSizeWrapper(_ bytes: Int) -> Int {
    return NSRoundDownToMultipleOfPageSize(bytes)
  }

  @objc static public func NSRoundUpToMultipleOfPageSizeWrapper(_ bytes: Int) -> Int {
    return NSRoundUpToMultipleOfPageSize(bytes)
  }

  @objc static public func NSSwapBigDoubleToHostWrapper(_ x: NSSwappedDoubleWrapper) -> Double {
    return NSSwapBigDoubleToHost(x.wrappedInstance)
  }

  @objc static public func NSSwapBigFloatToHostWrapper(_ x: NSSwappedFloatWrapper) -> Float {
    return NSSwapBigFloatToHost(x.wrappedInstance)
  }

  @objc static public func NSSwapDoubleWrapper(_ x: NSSwappedDoubleWrapper) -> NSSwappedDoubleWrapper {
    let result = NSSwapDouble(x.wrappedInstance)
    return NSSwappedDoubleWrapper(result)
  }

  @objc static public func NSSwapFloatWrapper(_ x: NSSwappedFloatWrapper) -> NSSwappedFloatWrapper {
    let result = NSSwapFloat(x.wrappedInstance)
    return NSSwappedFloatWrapper(result)
  }

  @objc static public func NSSwapHostDoubleToBigWrapper(_ x: Double) -> NSSwappedDoubleWrapper {
    let result = NSSwapHostDoubleToBig(x)
    return NSSwappedDoubleWrapper(result)
  }

  @objc static public func NSSwapHostDoubleToLittleWrapper(_ x: Double) -> NSSwappedDoubleWrapper {
    let result = NSSwapHostDoubleToLittle(x)
    return NSSwappedDoubleWrapper(result)
  }

  @objc static public func NSSwapHostFloatToBigWrapper(_ x: Float) -> NSSwappedFloatWrapper {
    let result = NSSwapHostFloatToBig(x)
    return NSSwappedFloatWrapper(result)
  }

  @objc static public func NSSwapHostFloatToLittleWrapper(_ x: Float) -> NSSwappedFloatWrapper {
    let result = NSSwapHostFloatToLittle(x)
    return NSSwappedFloatWrapper(result)
  }

  @objc static public func NSSwapLittleDoubleToHostWrapper(_ x: NSSwappedDoubleWrapper) -> Double {
    return NSSwapLittleDoubleToHost(x.wrappedInstance)
  }

  @objc static public func NSSwapLittleFloatToHostWrapper(_ x: NSSwappedFloatWrapper) -> Float {
    return NSSwapLittleFloatToHost(x.wrappedInstance)
  }

  @objc static public func NSTemporaryDirectoryWrapper() -> String {
    return NSTemporaryDirectory()
  }

  @objc static public func NSUserNameWrapper() -> String {
    return NSUserName()
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public func powWrapper(_ x: DecimalWrapper, _ y: Int) -> DecimalWrapper {
    let result = pow(x.wrappedInstance, y)
    return DecimalWrapper(result)
  }

  @objc static public func urlFuncWrapper(url: NSURL) -> NSURL {
    return urlFunc(url: url)
  }

}

@available(macOS, introduced: 10.10)
@available(watchOS, introduced: 2.0)
@available(iOS, introduced: 8.0)
@available(tvOS, introduced: 9.0)
@objc public class CocoaErrorWrapper: NSObject {
  var wrappedInstance: CocoaError

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var formattingError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.formattingError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileLockingError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileLockingError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isExecutableError: Bool {
    get {
      wrappedInstance.isExecutableError
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isFormattingError: Bool {
    get {
      wrappedInstance.isFormattingError
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isValidationError: Bool {
    get {
      wrappedInstance.isValidationError
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var userCancelledError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.userCancelledError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var executableLinkError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.executableLinkError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var executableLoadError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.executableLoadError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileNoSuchFileError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileNoSuchFileError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isPropertyListError: Bool {
    get {
      wrappedInstance.isPropertyListError
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isUserActivityError: Bool {
    get {
      wrappedInstance.isUserActivityError
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileReadUnknownError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileReadUnknownError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isXPCConnectionError: Bool {
    get {
      wrappedInstance.isXPCConnectionError
    }
  }

  @available(macOS, introduced: 10.11)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 9.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var coderReadCorruptError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.coderReadCorruptError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileReadTooLargeError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileReadTooLargeError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileWriteUnknownError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileWriteUnknownError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isUbiquitousFileError: Bool {
    get {
      wrappedInstance.isUbiquitousFileError
    }
  }

  @available(macOS, introduced: 10.11)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 9.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var coderValueNotFoundError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.coderValueNotFoundError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var featureUnsupportedError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.featureUnsupportedError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileReadNoSuchFileError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileReadNoSuchFileError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var keyValueValidationError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.keyValueValidationError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileReadCorruptFileError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileReadCorruptFileError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileWriteFileExistsError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileWriteFileExistsError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileWriteOutOfSpaceError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileWriteOutOfSpaceError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileReadNoPermissionError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileReadNoPermissionError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var executableNotLoadableError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.executableNotLoadableError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileWriteNoPermissionError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileWriteNoPermissionError)
    }
  }

  @available(macOS, introduced: 10.11)
  @available(watchOS, introduced: 2.0)
  @available(iOS, unavailable, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileManagerUnmountBusyError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileManagerUnmountBusyError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var propertyListReadStreamError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.propertyListReadStreamError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileReadInvalidFileNameError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileReadInvalidFileNameError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileWriteVolumeReadOnlyError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileWriteVolumeReadOnlyError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var propertyListReadCorruptError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.propertyListReadCorruptError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var propertyListWriteStreamError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.propertyListWriteStreamError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileWriteInvalidFileNameError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileWriteInvalidFileNameError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var propertyListWriteInvalidError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.propertyListWriteInvalidError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var executableRuntimeMismatchError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.executableRuntimeMismatchError)
    }
  }

  @available(macOS, introduced: 10.11)
  @available(watchOS, introduced: 2.0)
  @available(iOS, unavailable, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileManagerUnmountUnknownError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileManagerUnmountUnknownError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileReadUnsupportedSchemeError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileReadUnsupportedSchemeError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var ubiquitousFileUnavailableError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.ubiquitousFileUnavailableError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var userActivityHandoffFailedError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.userActivityHandoffFailedError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileWriteUnsupportedSchemeError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileWriteUnsupportedSchemeError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileReadUnknownStringEncodingError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileReadUnknownStringEncodingError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var executableArchitectureMismatchError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.executableArchitectureMismatchError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var propertyListReadUnknownVersionError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.propertyListReadUnknownVersionError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var userActivityConnectionUnavailableError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.userActivityConnectionUnavailableError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileReadInapplicableStringEncodingError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileReadInapplicableStringEncodingError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileWriteInapplicableStringEncodingError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileWriteInapplicableStringEncodingError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var ubiquitousFileNotUploadedDueToQuotaError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.ubiquitousFileNotUploadedDueToQuotaError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var userActivityHandoffUserInfoTooLargeError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.userActivityHandoffUserInfoTooLargeError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var userActivityRemoteApplicationTimedOutError: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.userActivityRemoteApplicationTimedOutError)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isFileError: Bool {
    get {
      wrappedInstance.isFileError
    }
  }

  @available(macOS, introduced: 10.11)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 9.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isCoderError: Bool {
    get {
      wrappedInstance.isCoderError
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var formatting: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.formatting)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var errorDomain: String {
    get {
      CocoaError.errorDomain
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileLocking: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileLocking)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var userCancelled: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.userCancelled)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var executableLink: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.executableLink)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var executableLoad: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.executableLoad)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileNoSuchFile: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileNoSuchFile)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileReadUnknown: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileReadUnknown)
    }
  }

  @available(macOS, introduced: 10.11)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 9.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var coderReadCorrupt: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.coderReadCorrupt)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileReadTooLarge: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileReadTooLarge)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileWriteUnknown: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileWriteUnknown)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var coderInvalidValue: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.coderInvalidValue)
    }
  }

  @available(macOS, introduced: 10.11)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 9.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var coderValueNotFound: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.coderValueNotFound)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var featureUnsupported: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.featureUnsupported)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileReadNoSuchFile: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileReadNoSuchFile)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var keyValueValidation: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.keyValueValidation)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileReadCorruptFile: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileReadCorruptFile)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileWriteFileExists: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileWriteFileExists)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileWriteOutOfSpace: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileWriteOutOfSpace)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileReadNoPermission: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileReadNoPermission)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var xpcConnectionInvalid: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.xpcConnectionInvalid)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var executableNotLoadable: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.executableNotLoadable)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileWriteNoPermission: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileWriteNoPermission)
    }
  }

  @available(macOS, introduced: 10.11)
  @available(watchOS, introduced: 2.0)
  @available(iOS, unavailable, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileManagerUnmountBusy: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileManagerUnmountBusy)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var propertyListReadStream: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.propertyListReadStream)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileReadInvalidFileName: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileReadInvalidFileName)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileWriteVolumeReadOnly: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileWriteVolumeReadOnly)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var propertyListReadCorrupt: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.propertyListReadCorrupt)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var propertyListWriteStream: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.propertyListWriteStream)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileWriteInvalidFileName: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileWriteInvalidFileName)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var propertyListWriteInvalid: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.propertyListWriteInvalid)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var xpcConnectionInterrupted: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.xpcConnectionInterrupted)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var executableRuntimeMismatch: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.executableRuntimeMismatch)
    }
  }

  @available(macOS, introduced: 10.11)
  @available(watchOS, introduced: 2.0)
  @available(iOS, unavailable, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileManagerUnmountUnknown: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileManagerUnmountUnknown)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileReadUnsupportedScheme: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileReadUnsupportedScheme)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var ubiquitousFileUnavailable: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.ubiquitousFileUnavailable)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var userActivityHandoffFailed: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.userActivityHandoffFailed)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var xpcConnectionReplyInvalid: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.xpcConnectionReplyInvalid)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileWriteUnsupportedScheme: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileWriteUnsupportedScheme)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileReadUnknownStringEncoding: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileReadUnknownStringEncoding)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var executableArchitectureMismatch: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.executableArchitectureMismatch)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var propertyListReadUnknownVersion: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.propertyListReadUnknownVersion)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var userActivityConnectionUnavailable: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.userActivityConnectionUnavailable)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileReadInapplicableStringEncoding: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileReadInapplicableStringEncoding)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileWriteInapplicableStringEncoding: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.fileWriteInapplicableStringEncoding)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var ubiquitousFileNotUploadedDueToQuota: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.ubiquitousFileNotUploadedDueToQuota)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var userActivityHandoffUserInfoTooLarge: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.userActivityHandoffUserInfoTooLarge)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var userActivityRemoteApplicationTimedOut: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.userActivityRemoteApplicationTimedOut)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var url: URL? {
    get {
      wrappedInstance.url
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var ubiquitousFileUbiquityServerNotAvailable: CocoaErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(CocoaError.ubiquitousFileUbiquityServerNotAvailable)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var filePath: String? {
    get {
      wrappedInstance.filePath
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var errorDomain: String {
    get {
      CocoaError.errorDomain
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var localizedDescription: String {
    get {
      wrappedInstance.localizedDescription
    }
  }

  init(_ wrappedInstance: CocoaError) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public class CodeWrapper: NSObject {
    var wrappedInstance: CocoaError.Code

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var formattingError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.formattingError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileLockingError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileLockingError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var userCancelledError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.userCancelledError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var executableLinkError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.executableLinkError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var executableLoadError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.executableLoadError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileNoSuchFileError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileNoSuchFileError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileReadUnknownError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileReadUnknownError)
      }
    }

    @available(macOS, introduced: 10.11)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 9.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var coderReadCorruptError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.coderReadCorruptError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileReadTooLargeError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileReadTooLargeError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileWriteUnknownError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileWriteUnknownError)
      }
    }

    @available(macOS, introduced: 10.11)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 9.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var coderValueNotFoundError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.coderValueNotFoundError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var featureUnsupportedError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.featureUnsupportedError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileReadNoSuchFileError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileReadNoSuchFileError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var keyValueValidationError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.keyValueValidationError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileReadCorruptFileError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileReadCorruptFileError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileWriteFileExistsError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileWriteFileExistsError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileWriteOutOfSpaceError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileWriteOutOfSpaceError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileReadNoPermissionError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileReadNoPermissionError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var executableNotLoadableError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.executableNotLoadableError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileWriteNoPermissionError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileWriteNoPermissionError)
      }
    }

    @available(macOS, introduced: 10.11)
    @available(watchOS, introduced: 2.0)
    @available(iOS, unavailable, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileManagerUnmountBusyError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileManagerUnmountBusyError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var propertyListReadStreamError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.propertyListReadStreamError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileReadInvalidFileNameError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileReadInvalidFileNameError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileWriteVolumeReadOnlyError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileWriteVolumeReadOnlyError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var propertyListReadCorruptError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.propertyListReadCorruptError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var propertyListWriteStreamError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.propertyListWriteStreamError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileWriteInvalidFileNameError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileWriteInvalidFileNameError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var propertyListWriteInvalidError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.propertyListWriteInvalidError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var executableRuntimeMismatchError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.executableRuntimeMismatchError)
      }
    }

    @available(macOS, introduced: 10.11)
    @available(watchOS, introduced: 2.0)
    @available(iOS, unavailable, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileManagerUnmountUnknownError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileManagerUnmountUnknownError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileReadUnsupportedSchemeError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileReadUnsupportedSchemeError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var ubiquitousFileUnavailableError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.ubiquitousFileUnavailableError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var userActivityHandoffFailedError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.userActivityHandoffFailedError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileWriteUnsupportedSchemeError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileWriteUnsupportedSchemeError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileReadUnknownStringEncodingError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileReadUnknownStringEncodingError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var executableArchitectureMismatchError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.executableArchitectureMismatchError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var propertyListReadUnknownVersionError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.propertyListReadUnknownVersionError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var userActivityConnectionUnavailableError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.userActivityConnectionUnavailableError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileReadInapplicableStringEncodingError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileReadInapplicableStringEncodingError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileWriteInapplicableStringEncodingError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileWriteInapplicableStringEncodingError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var ubiquitousFileNotUploadedDueToQuotaError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.ubiquitousFileNotUploadedDueToQuotaError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var userActivityHandoffUserInfoTooLargeError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.userActivityHandoffUserInfoTooLargeError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var userActivityRemoteApplicationTimedOutError: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.userActivityRemoteApplicationTimedOutError)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var formatting: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.formatting)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileLocking: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileLocking)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var userCancelled: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.userCancelled)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var executableLink: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.executableLink)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var executableLoad: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.executableLoad)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileNoSuchFile: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileNoSuchFile)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileReadUnknown: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileReadUnknown)
      }
    }

    @available(macOS, introduced: 10.11)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 9.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var coderReadCorrupt: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.coderReadCorrupt)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileReadTooLarge: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileReadTooLarge)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileWriteUnknown: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileWriteUnknown)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var coderInvalidValue: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.coderInvalidValue)
      }
    }

    @available(macOS, introduced: 10.11)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 9.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var coderValueNotFound: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.coderValueNotFound)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var featureUnsupported: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.featureUnsupported)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileReadNoSuchFile: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileReadNoSuchFile)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var keyValueValidation: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.keyValueValidation)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileReadCorruptFile: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileReadCorruptFile)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileWriteFileExists: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileWriteFileExists)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileWriteOutOfSpace: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileWriteOutOfSpace)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileReadNoPermission: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileReadNoPermission)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var xpcConnectionInvalid: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.xpcConnectionInvalid)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var executableNotLoadable: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.executableNotLoadable)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileWriteNoPermission: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileWriteNoPermission)
      }
    }

    @available(macOS, introduced: 10.11)
    @available(watchOS, introduced: 2.0)
    @available(iOS, unavailable, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileManagerUnmountBusy: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileManagerUnmountBusy)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var propertyListReadStream: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.propertyListReadStream)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileReadInvalidFileName: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileReadInvalidFileName)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileWriteVolumeReadOnly: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileWriteVolumeReadOnly)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var propertyListReadCorrupt: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.propertyListReadCorrupt)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var propertyListWriteStream: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.propertyListWriteStream)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileWriteInvalidFileName: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileWriteInvalidFileName)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var propertyListWriteInvalid: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.propertyListWriteInvalid)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var xpcConnectionInterrupted: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.xpcConnectionInterrupted)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var executableRuntimeMismatch: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.executableRuntimeMismatch)
      }
    }

    @available(macOS, introduced: 10.11)
    @available(watchOS, introduced: 2.0)
    @available(iOS, unavailable, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileManagerUnmountUnknown: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileManagerUnmountUnknown)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileReadUnsupportedScheme: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileReadUnsupportedScheme)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var ubiquitousFileUnavailable: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.ubiquitousFileUnavailable)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var userActivityHandoffFailed: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.userActivityHandoffFailed)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var xpcConnectionReplyInvalid: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.xpcConnectionReplyInvalid)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileWriteUnsupportedScheme: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileWriteUnsupportedScheme)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileReadUnknownStringEncoding: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileReadUnknownStringEncoding)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var executableArchitectureMismatch: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.executableArchitectureMismatch)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var propertyListReadUnknownVersion: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.propertyListReadUnknownVersion)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var userActivityConnectionUnavailable: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.userActivityConnectionUnavailable)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileReadInapplicableStringEncoding: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileReadInapplicableStringEncoding)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileWriteInapplicableStringEncoding: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.fileWriteInapplicableStringEncoding)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var ubiquitousFileNotUploadedDueToQuota: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.ubiquitousFileNotUploadedDueToQuota)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var userActivityHandoffUserInfoTooLarge: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.userActivityHandoffUserInfoTooLarge)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var userActivityRemoteApplicationTimedOut: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.userActivityRemoteApplicationTimedOut)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var ubiquitousFileUbiquityServerNotAvailable: CocoaErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(CocoaError.Code.ubiquitousFileUbiquityServerNotAvailable)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc public var rawValue: Int {
      get {
        wrappedInstance.rawValue
      }
    }

    init(_ wrappedInstance: CocoaError.Code) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc init(rawValue: Int) {
      wrappedInstance = CocoaError.Code(rawValue: rawValue)
    }

  }

}

@available(macOS, introduced: 15)
@available(watchOS, introduced: 11)
@available(iOS, introduced: 18)
@available(tvOS, introduced: 18)
@objc public class ExpressionWrapper: NSObject {
  var wrappedInstance: Expression

  @available(macOS, introduced: 15)
  @available(watchOS, introduced: 11)
  @available(iOS, introduced: 18)
  @available(tvOS, introduced: 18)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  @available(macOS, introduced: 15)
  @available(watchOS, introduced: 11)
  @available(iOS, introduced: 18)
  @available(tvOS, introduced: 18)
  @objc public var debugDescription: String {
    get {
      wrappedInstance.debugDescription
    }
  }

  init(_ wrappedInstance: Expression) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class MorphologyWrapper: NSObject {
  var wrappedInstance: Morphology

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public var isUnspecified: Bool {
    get {
      wrappedInstance.isUnspecified
    }
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc static public var user: MorphologyWrapper {
    get {
      MorphologyWrapper(Morphology.user)
    }
  }

  init(_ wrappedInstance: Morphology) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc override init() {
    wrappedInstance = Morphology()
  }

  @available(macOS, introduced: 12.0, deprecated: 14.0)
  @available(watchOS, introduced: 8.0, deprecated: 10.0)
  @available(iOS, introduced: 15.0, deprecated: 17.0)
  @available(tvOS, introduced: 15.0, deprecated: 17.0)
  @objc public func customPronoun(forLanguage language: String) -> MorphologyWrapper.CustomPronounWrapper? {
    let result = wrappedInstance.customPronoun(forLanguage: language)
    return result == nil ? nil : CustomPronounWrapper(result!)
  }

  @available(macOS, introduced: 12.0, deprecated: 14.0)
  @available(watchOS, introduced: 8.0, deprecated: 10.0)
  @available(iOS, introduced: 15.0, deprecated: 17.0)
  @available(tvOS, introduced: 15.0, deprecated: 17.0)
  @objc public func setCustomPronoun(_ pronoun: MorphologyWrapper.CustomPronounWrapper?, forLanguage language: String) throws {
    return try wrappedInstance.setCustomPronoun(pronoun?.wrappedInstance, forLanguage: language)
  }

  @available(macOS, introduced: 12.0, deprecated: 14.0)
  @available(watchOS, introduced: 8.0, deprecated: 10.0)
  @available(iOS, introduced: 15.0, deprecated: 17.0)
  @available(tvOS, introduced: 15.0, deprecated: 17.0)
  @objc public class CustomPronounWrapper: NSObject {
    var wrappedInstance: Morphology.CustomPronoun

    @available(macOS, introduced: 12.0, deprecated: 14.0)
    @available(watchOS, introduced: 8.0, deprecated: 10.0)
    @available(iOS, introduced: 15.0, deprecated: 17.0)
    @available(tvOS, introduced: 15.0, deprecated: 17.0)
    @objc public var objectForm: String? {
      get {
        wrappedInstance.objectForm
      }
      set {
        wrappedInstance.objectForm = newValue
      }
    }

    @available(macOS, introduced: 12.0, deprecated: 14.0)
    @available(watchOS, introduced: 8.0, deprecated: 10.0)
    @available(iOS, introduced: 15.0, deprecated: 17.0)
    @available(tvOS, introduced: 15.0, deprecated: 17.0)
    @objc public var subjectForm: String? {
      get {
        wrappedInstance.subjectForm
      }
      set {
        wrappedInstance.subjectForm = newValue
      }
    }

    @available(macOS, introduced: 12.0, deprecated: 14.0)
    @available(watchOS, introduced: 8.0, deprecated: 10.0)
    @available(iOS, introduced: 15.0, deprecated: 17.0)
    @available(tvOS, introduced: 15.0, deprecated: 17.0)
    @objc public var reflexiveForm: String? {
      get {
        wrappedInstance.reflexiveForm
      }
      set {
        wrappedInstance.reflexiveForm = newValue
      }
    }

    @available(macOS, introduced: 12.0, deprecated: 14.0)
    @available(watchOS, introduced: 8.0, deprecated: 10.0)
    @available(iOS, introduced: 15.0, deprecated: 17.0)
    @available(tvOS, introduced: 15.0, deprecated: 17.0)
    @objc public var possessiveForm: String? {
      get {
        wrappedInstance.possessiveForm
      }
      set {
        wrappedInstance.possessiveForm = newValue
      }
    }

    @available(macOS, introduced: 12.0, deprecated: 14.0)
    @available(watchOS, introduced: 8.0, deprecated: 10.0)
    @available(iOS, introduced: 15.0, deprecated: 17.0)
    @available(tvOS, introduced: 15.0, deprecated: 17.0)
    @objc public var possessiveAdjectiveForm: String? {
      get {
        wrappedInstance.possessiveAdjectiveForm
      }
      set {
        wrappedInstance.possessiveAdjectiveForm = newValue
      }
    }

    init(_ wrappedInstance: Morphology.CustomPronoun) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 12.0, deprecated: 14.0)
    @available(watchOS, introduced: 8.0, deprecated: 10.0)
    @available(iOS, introduced: 15.0, deprecated: 17.0)
    @available(tvOS, introduced: 15.0, deprecated: 17.0)
    @objc override init() {
      wrappedInstance = Morphology.CustomPronoun()
    }

    @available(macOS, introduced: 12.0, deprecated: 14.0)
    @available(watchOS, introduced: 8.0, deprecated: 10.0)
    @available(iOS, introduced: 15.0, deprecated: 17.0)
    @available(tvOS, introduced: 15.0, deprecated: 17.0)
    @objc static public func isSupported(forLanguage language: String) -> Bool {
      return Morphology.CustomPronoun.isSupported(forLanguage: language)
    }

  }

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 10)
  @available(iOS, introduced: 17)
  @available(tvOS, introduced: 17)
  @objc public class PronounWrapper: NSObject {
    var wrappedInstance: Morphology.Pronoun

    @available(macOS, introduced: 14)
    @available(watchOS, introduced: 10)
    @available(iOS, introduced: 17)
    @available(tvOS, introduced: 17)
    @objc public var dependentMorphology: MorphologyWrapper? {
      get {
        wrappedInstance.dependentMorphology == nil ? nil : MorphologyWrapper(wrappedInstance.dependentMorphology!)
      }
      set {
        wrappedInstance.dependentMorphology = newValue?.wrappedInstance
      }
    }

    @available(macOS, introduced: 14)
    @available(watchOS, introduced: 10)
    @available(iOS, introduced: 17)
    @available(tvOS, introduced: 17)
    @objc public var morphology: MorphologyWrapper {
      get {
        MorphologyWrapper(wrappedInstance.morphology)
      }
      set {
        wrappedInstance.morphology = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 14)
    @available(watchOS, introduced: 10)
    @available(iOS, introduced: 17)
    @available(tvOS, introduced: 17)
    @objc public var pronoun: String {
      get {
        wrappedInstance.pronoun
      }
      set {
        wrappedInstance.pronoun = newValue
      }
    }

    init(_ wrappedInstance: Morphology.Pronoun) {
      self.wrappedInstance = wrappedInstance
    }

  }

}

@available(macOS, introduced: 10.10)
@available(watchOS, introduced: 2.0)
@available(iOS, introduced: 8.0)
@available(tvOS, introduced: 9.0)
@objc public class POSIXErrorWrapper: NSObject {
  var wrappedInstance: POSIXError

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var errorDomain: String {
    get {
      POSIXError.errorDomain
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var errorDomain: String {
    get {
      POSIXError.errorDomain
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var localizedDescription: String {
    get {
      wrappedInstance.localizedDescription
    }
  }

  init(_ wrappedInstance: POSIXError) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 10.10)
@available(watchOS, introduced: 2.0)
@available(iOS, introduced: 8.0)
@available(tvOS, introduced: 9.0)
@objc public class JSONDecoderWrapper: NSObject {
  var wrappedInstance: JSONDecoder

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var allowsJSON5: Bool {
    get {
      wrappedInstance.allowsJSON5
    }
    set {
      wrappedInstance.allowsJSON5 = newValue
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var assumesTopLevelDictionary: Bool {
    get {
      wrappedInstance.assumesTopLevelDictionary
    }
    set {
      wrappedInstance.assumesTopLevelDictionary = newValue
    }
  }

  init(_ wrappedInstance: JSONDecoder) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc override init() {
    wrappedInstance = JSONDecoder()
  }

}

@available(macOS, introduced: 10.10)
@available(watchOS, introduced: 2.0)
@available(iOS, introduced: 8.0)
@available(tvOS, introduced: 9.0)
@objc public class JSONEncoderWrapper: NSObject {
  var wrappedInstance: JSONEncoder

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var outputFormatting: JSONEncoderWrapper.OutputFormattingWrapper {
    get {
      OutputFormattingWrapper(wrappedInstance.outputFormatting)
    }
    set {
      wrappedInstance.outputFormatting = newValue.wrappedInstance
    }
  }

  init(_ wrappedInstance: JSONEncoder) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc override init() {
    wrappedInstance = JSONEncoder()
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public class OutputFormattingWrapper: NSObject {
    var wrappedInstance: JSONEncoder.OutputFormatting

    @available(macOS, introduced: 10.13)
    @available(watchOS, introduced: 4.0)
    @available(iOS, introduced: 11.0)
    @available(tvOS, introduced: 11.0)
    @objc static public var sortedKeys: JSONEncoderWrapper.OutputFormattingWrapper {
      get {
        OutputFormattingWrapper(JSONEncoder.OutputFormatting.sortedKeys)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var prettyPrinted: JSONEncoderWrapper.OutputFormattingWrapper {
      get {
        OutputFormattingWrapper(JSONEncoder.OutputFormatting.prettyPrinted)
      }
    }

    @available(macOS, introduced: 10.15)
    @available(watchOS, introduced: 6.0)
    @available(iOS, introduced: 13.0)
    @available(tvOS, introduced: 13.0)
    @objc static public var withoutEscapingSlashes: JSONEncoderWrapper.OutputFormattingWrapper {
      get {
        OutputFormattingWrapper(JSONEncoder.OutputFormatting.withoutEscapingSlashes)
      }
    }

    @objc public var isEmpty: Bool {
      get {
        wrappedInstance.isEmpty
      }
    }

    init(_ wrappedInstance: JSONEncoder.OutputFormatting) {
      self.wrappedInstance = wrappedInstance
    }

    @objc override init() {
      wrappedInstance = JSONEncoder.OutputFormatting()
    }

  }

}

@available(macOS, introduced: 10.12)
@available(watchOS, introduced: 3.0)
@available(iOS, introduced: 10.0)
@available(tvOS, introduced: 10.0)
@objc public class MeasurementWrapper: NSObject {
  var wrappedInstance: Measurement

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
  @objc public var value: Double {
    get {
      wrappedInstance.value
    }
    set {
      wrappedInstance.value = newValue
    }
  }

  init(_ wrappedInstance: Measurement) {
    self.wrappedInstance = wrappedInstance
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
    var wrappedInstance: Measurement.FormatStyle

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var numberFormatStyle: FloatingPointFormatStyleWrapper {
      get {
        FloatingPointFormatStyleWrapper(wrappedInstance.numberFormatStyle)
      }
      set {
        wrappedInstance.numberFormatStyle = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var attributed: MeasurementWrapper {
      get {
        MeasurementWrapper(wrappedInstance.attributed)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var usage: MeasurementFormatUnitUsageWrapper {
      get {
        MeasurementFormatUnitUsageWrapper(wrappedInstance.usage)
      }
      set {
        wrappedInstance.usage = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var width: MeasurementWrapper {
      get {
        MeasurementWrapper(wrappedInstance.width)
      }
      set {
        wrappedInstance.width = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var locale: Locale {
      get {
        wrappedInstance.locale
      }
      set {
        wrappedInstance.locale = newValue
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var hidesScaleName: Bool {
      get {
        wrappedInstance.hidesScaleName
      }
      set {
        wrappedInstance.hidesScaleName = newValue
      }
    }

    init(_ wrappedInstance: Measurement.FormatStyle) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func locale(_ locale: Locale) -> MeasurementWrapper {
      let result = wrappedInstance.locale(locale)
      return MeasurementWrapper(result)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public class UnitWidthWrapper: NSObject {
      var wrappedInstance: FormatStyle.UnitWidth

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var abbreviated: MeasurementWrapper {
        get {
          MeasurementWrapper(FormatStyle.UnitWidth.abbreviated)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var wide: MeasurementWrapper {
        get {
          MeasurementWrapper(FormatStyle.UnitWidth.wide)
        }
      }

      @available(macOS, introduced: 12.0)
      @available(watchOS, introduced: 8.0)
      @available(iOS, introduced: 15.0)
      @available(tvOS, introduced: 15.0)
      @objc static public var narrow: MeasurementWrapper {
        get {
          MeasurementWrapper(FormatStyle.UnitWidth.narrow)
        }
      }

      init(_ wrappedInstance: FormatStyle.UnitWidth) {
        self.wrappedInstance = wrappedInstance
      }

    }

    @available(macOS, introduced: 13.0)
    @available(watchOS, introduced: 9.0)
    @available(iOS, introduced: 16.0)
    @available(tvOS, introduced: 16.0)
    @objc public class ByteCountWrapper: NSObject {
      var wrappedInstance: FormatStyle.ByteCount

      @available(macOS, introduced: 13.0)
      @available(watchOS, introduced: 9.0)
      @available(iOS, introduced: 16.0)
      @available(tvOS, introduced: 16.0)
      @objc public var includesActualByteCount: Bool {
        get {
          wrappedInstance.includesActualByteCount
        }
        set {
          wrappedInstance.includesActualByteCount = newValue
        }
      }

      @available(macOS, introduced: 13.0)
      @available(watchOS, introduced: 9.0)
      @available(iOS, introduced: 16.0)
      @available(tvOS, introduced: 16.0)
      @objc public var attributed: MeasurementWrapper {
        get {
          MeasurementWrapper(wrappedInstance.attributed)
        }
      }

      @available(macOS, introduced: 13.0)
      @available(watchOS, introduced: 9.0)
      @available(iOS, introduced: 16.0)
      @available(tvOS, introduced: 16.0)
      @objc public var allowedUnits: MeasurementWrapper {
        get {
          MeasurementWrapper(wrappedInstance.allowedUnits)
        }
        set {
          wrappedInstance.allowedUnits = newValue.wrappedInstance
        }
      }

      @available(macOS, introduced: 13.0)
      @available(watchOS, introduced: 9.0)
      @available(iOS, introduced: 16.0)
      @available(tvOS, introduced: 16.0)
      @objc public var spellsOutZero: Bool {
        get {
          wrappedInstance.spellsOutZero
        }
        set {
          wrappedInstance.spellsOutZero = newValue
        }
      }

      @available(macOS, introduced: 13.0)
      @available(watchOS, introduced: 9.0)
      @available(iOS, introduced: 16.0)
      @available(tvOS, introduced: 16.0)
      @objc public var style: MeasurementWrapper {
        get {
          MeasurementWrapper(wrappedInstance.style)
        }
        set {
          wrappedInstance.style = newValue.wrappedInstance
        }
      }

      @available(macOS, introduced: 13.0)
      @available(watchOS, introduced: 9.0)
      @available(iOS, introduced: 16.0)
      @available(tvOS, introduced: 16.0)
      @objc public var locale: Locale {
        get {
          wrappedInstance.locale
        }
        set {
          wrappedInstance.locale = newValue
        }
      }

      init(_ wrappedInstance: FormatStyle.ByteCount) {
        self.wrappedInstance = wrappedInstance
      }

      @available(macOS, introduced: 13.0)
      @available(watchOS, introduced: 9.0)
      @available(iOS, introduced: 16.0)
      @available(tvOS, introduced: 16.0)
      @objc public func locale(_ locale: Locale) -> MeasurementWrapper {
        let result = wrappedInstance.locale(locale)
        return MeasurementWrapper(result)
      }

    }

  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class AttributedStyleWrapper: NSObject {
    var wrappedInstance: Measurement.AttributedStyle

    init(_ wrappedInstance: Measurement.AttributedStyle) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func locale(_ locale: Locale) -> MeasurementWrapper {
      let result = wrappedInstance.locale(locale)
      return MeasurementWrapper(result)
    }

    @available(macOS, introduced: 13.0)
    @available(watchOS, introduced: 9.0)
    @available(iOS, introduced: 16.0)
    @available(tvOS, introduced: 16.0)
    @objc public class ByteCountWrapper: NSObject {
      var wrappedInstance: AttributedStyle.ByteCount

      @available(macOS, introduced: 13.0)
      @available(watchOS, introduced: 9.0)
      @available(iOS, introduced: 16.0)
      @available(tvOS, introduced: 16.0)
      @objc public var includesActualByteCount: Bool {
        get {
          wrappedInstance.includesActualByteCount
        }
        set {
          wrappedInstance.includesActualByteCount = newValue
        }
      }

      @available(macOS, introduced: 13.0)
      @available(watchOS, introduced: 9.0)
      @available(iOS, introduced: 16.0)
      @available(tvOS, introduced: 16.0)
      @objc public var allowedUnits: MeasurementWrapper {
        get {
          MeasurementWrapper(wrappedInstance.allowedUnits)
        }
        set {
          wrappedInstance.allowedUnits = newValue.wrappedInstance
        }
      }

      @available(macOS, introduced: 13.0)
      @available(watchOS, introduced: 9.0)
      @available(iOS, introduced: 16.0)
      @available(tvOS, introduced: 16.0)
      @objc public var spellsOutZero: Bool {
        get {
          wrappedInstance.spellsOutZero
        }
        set {
          wrappedInstance.spellsOutZero = newValue
        }
      }

      @available(macOS, introduced: 13.0)
      @available(watchOS, introduced: 9.0)
      @available(iOS, introduced: 16.0)
      @available(tvOS, introduced: 16.0)
      @objc public var style: MeasurementWrapper {
        get {
          MeasurementWrapper(wrappedInstance.style)
        }
        set {
          wrappedInstance.style = newValue.wrappedInstance
        }
      }

      @available(macOS, introduced: 13.0)
      @available(watchOS, introduced: 9.0)
      @available(iOS, introduced: 16.0)
      @available(tvOS, introduced: 16.0)
      @objc public var locale: Locale {
        get {
          wrappedInstance.locale
        }
        set {
          wrappedInstance.locale = newValue
        }
      }

      init(_ wrappedInstance: AttributedStyle.ByteCount) {
        self.wrappedInstance = wrappedInstance
      }

      @available(macOS, introduced: 13.0)
      @available(watchOS, introduced: 9.0)
      @available(iOS, introduced: 16.0)
      @available(tvOS, introduced: 16.0)
      @objc public func locale(_ locale: Locale) -> MeasurementWrapper {
        let result = wrappedInstance.locale(locale)
        return MeasurementWrapper(result)
      }

    }

  }

}

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class StringStyleWrapper: NSObject {
  var wrappedInstance: StringStyle

  init(_ wrappedInstance: StringStyle) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func format(_ value: String) -> String {
    return wrappedInstance.format(value)
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
  @objc public var bundle: Bundle {
    get {
      wrappedInstance.bundle
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public var locale: Locale {
    get {
      wrappedInstance.locale
    }
    set {
      wrappedInstance.locale = newValue
    }
  }

  init(_ wrappedInstance: URLResource) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class TermOfAddressWrapper: NSObject {
  var wrappedInstance: TermOfAddress

  @available(macOS, introduced: 15)
  @available(watchOS, introduced: 11)
  @available(iOS, introduced: 18)
  @available(visionOS, introduced: 2)
  @available(tvOS, introduced: 18)
  @objc static public var currentUser: TermOfAddressWrapper {
    get {
      TermOfAddressWrapper(TermOfAddress.currentUser)
    }
  }

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 10)
  @available(iOS, introduced: 17)
  @available(tvOS, introduced: 17)
  @objc static public var neutral: TermOfAddressWrapper {
    get {
      TermOfAddressWrapper(TermOfAddress.neutral)
    }
  }

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 10)
  @available(iOS, introduced: 17)
  @available(tvOS, introduced: 17)
  @objc static public var feminine: TermOfAddressWrapper {
    get {
      TermOfAddressWrapper(TermOfAddress.feminine)
    }
  }

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 10)
  @available(iOS, introduced: 17)
  @available(tvOS, introduced: 17)
  @objc public var language: LanguageWrapper? {
    get {
      wrappedInstance.language == nil ? nil : LanguageWrapper(wrappedInstance.language!)
    }
  }

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 10)
  @available(iOS, introduced: 17)
  @available(tvOS, introduced: 17)
  @objc static public var masculine: TermOfAddressWrapper {
    get {
      TermOfAddressWrapper(TermOfAddress.masculine)
    }
  }

  init(_ wrappedInstance: TermOfAddress) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class PredicateErrorWrapper: NSObject {
  var wrappedInstance: PredicateError

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 10)
  @available(iOS, introduced: 17)
  @available(tvOS, introduced: 17)
  @objc static public var invalidInput: PredicateErrorWrapper {
    get {
      PredicateErrorWrapper(PredicateError.invalidInput)
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

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 10)
  @available(iOS, introduced: 17)
  @available(tvOS, introduced: 17)
  @objc static public var forceCastFailure: PredicateErrorWrapper {
    get {
      PredicateErrorWrapper(PredicateError.forceCastFailure)
    }
  }

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 10)
  @available(iOS, introduced: 17)
  @available(tvOS, introduced: 17)
  @objc static public var undefinedVariable: PredicateErrorWrapper {
    get {
      PredicateErrorWrapper(PredicateError.undefinedVariable)
    }
  }

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 10)
  @available(iOS, introduced: 17)
  @available(tvOS, introduced: 17)
  @objc static public var forceUnwrapFailure: PredicateErrorWrapper {
    get {
      PredicateErrorWrapper(PredicateError.forceUnwrapFailure)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var localizedDescription: String {
    get {
      wrappedInstance.localizedDescription
    }
  }

  init(_ wrappedInstance: PredicateError) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class SortDescriptorWrapper: NSObject {
  var wrappedInstance: SortDescriptor

  init(_ wrappedInstance: SortDescriptor) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 12)
@available(watchOS, introduced: 8)
@available(iOS, introduced: 15)
@available(tvOS, introduced: 15)
@objc public class FoundationAttributesWrapper: NSObject {
  var wrappedInstance: FoundationAttributes

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc static public var decodingConfiguration: AttributeScopeCodableConfigurationWrapper {
    get {
      AttributeScopeCodableConfigurationWrapper(FoundationAttributes.decodingConfiguration)
    }
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc static public var encodingConfiguration: AttributeScopeCodableConfigurationWrapper {
    get {
      AttributeScopeCodableConfigurationWrapper(FoundationAttributes.encodingConfiguration)
    }
  }

  init(_ wrappedInstance: FoundationAttributes) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public class MeasurementAttributeWrapper: NSObject {
    var wrappedInstance: FoundationAttributes.MeasurementAttribute

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc static public var name: String {
      get {
        FoundationAttributes.MeasurementAttribute.name
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

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc static public var inheritedByAddedText: Bool {
      get {
        FoundationAttributes.MeasurementAttribute.inheritedByAddedText
      }
    }

    init(_ wrappedInstance: FoundationAttributes.MeasurementAttribute) {
      self.wrappedInstance = wrappedInstance
    }

  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public class NumberFormatAttributesWrapper: NSObject {
    var wrappedInstance: FoundationAttributes.NumberFormatAttributes

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc static public var decodingConfiguration: AttributeScopeCodableConfigurationWrapper {
      get {
        AttributeScopeCodableConfigurationWrapper(FoundationAttributes.NumberFormatAttributes.decodingConfiguration)
      }
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc static public var encodingConfiguration: AttributeScopeCodableConfigurationWrapper {
      get {
        AttributeScopeCodableConfigurationWrapper(FoundationAttributes.NumberFormatAttributes.encodingConfiguration)
      }
    }

    init(_ wrappedInstance: FoundationAttributes.NumberFormatAttributes) {
      self.wrappedInstance = wrappedInstance
    }

  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public class LocalizedStringArgumentAttributesWrapper: NSObject {
    var wrappedInstance: FoundationAttributes.LocalizedStringArgumentAttributes

    init(_ wrappedInstance: FoundationAttributes.LocalizedStringArgumentAttributes) {
      self.wrappedInstance = wrappedInstance
    }

  }

}

@available(macOS, introduced: 15)
@available(watchOS, introduced: 11)
@available(iOS, introduced: 18)
@available(tvOS, introduced: 18)
@objc public class ValueWrapper1: NSObject {
  var wrappedInstance: Value

  init(_ wrappedInstance: Value) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class ListFormatStyleWrapper: NSObject {
  var wrappedInstance: ListFormatStyle

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var width: ListFormatStyleWrapper {
    get {
      ListFormatStyleWrapper(wrappedInstance.width)
    }
    set {
      wrappedInstance.width = newValue.wrappedInstance
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var locale: Locale {
    get {
      wrappedInstance.locale
    }
    set {
      wrappedInstance.locale = newValue
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var listType: ListFormatStyleWrapper {
    get {
      ListFormatStyleWrapper(wrappedInstance.listType)
    }
    set {
      wrappedInstance.listType = newValue.wrappedInstance
    }
  }

  init(_ wrappedInstance: ListFormatStyle) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func locale(_ locale: Locale) -> ListFormatStyleWrapper {
    let result = wrappedInstance.locale(locale)
    return ListFormatStyleWrapper(result)
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

@available(macOS, introduced: 10.10)
@available(watchOS, introduced: 2.0)
@available(iOS, introduced: 8.0)
@available(tvOS, introduced: 9.0)
@objc public class ErrorUserInfoKeyWrapper: NSObject {
  var wrappedInstance: ErrorUserInfoKey

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var NSURLErrorKey: ErrorUserInfoKeyWrapper {
    get {
      ErrorUserInfoKeyWrapper(ErrorUserInfoKey.NSURLErrorKey)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var helpAnchorErrorKey: ErrorUserInfoKeyWrapper {
    get {
      ErrorUserInfoKeyWrapper(ErrorUserInfoKey.helpAnchorErrorKey)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var underlyingErrorKey: ErrorUserInfoKeyWrapper {
    get {
      ErrorUserInfoKeyWrapper(ErrorUserInfoKey.underlyingErrorKey)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var stringEncodingErrorKey: ErrorUserInfoKeyWrapper {
    get {
      ErrorUserInfoKeyWrapper(ErrorUserInfoKey.stringEncodingErrorKey)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var recoveryAttempterErrorKey: ErrorUserInfoKeyWrapper {
    get {
      ErrorUserInfoKeyWrapper(ErrorUserInfoKey.recoveryAttempterErrorKey)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var localizedDescriptionKey: ErrorUserInfoKeyWrapper {
    get {
      ErrorUserInfoKeyWrapper(ErrorUserInfoKey.localizedDescriptionKey)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var localizedFailureReasonErrorKey: ErrorUserInfoKeyWrapper {
    get {
      ErrorUserInfoKeyWrapper(ErrorUserInfoKey.localizedFailureReasonErrorKey)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var localizedRecoveryOptionsErrorKey: ErrorUserInfoKeyWrapper {
    get {
      ErrorUserInfoKeyWrapper(ErrorUserInfoKey.localizedRecoveryOptionsErrorKey)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var localizedRecoverySuggestionErrorKey: ErrorUserInfoKeyWrapper {
    get {
      ErrorUserInfoKeyWrapper(ErrorUserInfoKey.localizedRecoverySuggestionErrorKey)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var filePathErrorKey: ErrorUserInfoKeyWrapper {
    get {
      ErrorUserInfoKeyWrapper(ErrorUserInfoKey.filePathErrorKey)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var rawValue: String {
    get {
      wrappedInstance.rawValue
    }
    set {
      wrappedInstance.rawValue = newValue
    }
  }

  init(_ wrappedInstance: ErrorUserInfoKey) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc init(rawValue: String) {
    wrappedInstance = ErrorUserInfoKey(rawValue: rawValue)
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

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class KeyPathComparatorWrapper: NSObject {
  var wrappedInstance: KeyPathComparator

  init(_ wrappedInstance: KeyPathComparator) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class PredicateBindingsWrapper: NSObject {
  var wrappedInstance: PredicateBindings

  init(_ wrappedInstance: PredicateBindings) {
    self.wrappedInstance = wrappedInstance
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
  @objc public var creationDate: Date? {
    get {
      wrappedInstance.creationDate
    }
    set {
      wrappedInstance.creationDate = newValue
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var fileSecurity: NSFileSecurity? {
    get {
      wrappedInstance.fileSecurity
    }
    set {
      wrappedInstance.fileSecurity = newValue
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
  @objc public var parentDirectory: URL? {
    get {
      wrappedInstance.parentDirectory
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
  @objc public var contentAccessDate: Date? {
    get {
      wrappedInstance.contentAccessDate
    }
    set {
      wrappedInstance.contentAccessDate = newValue
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
  @objc public var volumeCreationDate: Date? {
    get {
      wrappedInstance.volumeCreationDate
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
  @objc public var addedToDirectoryDate: Date? {
    get {
      wrappedInstance.addedToDirectoryDate
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
  @objc public var volumeURLForRemounting: URL? {
    get {
      wrappedInstance.volumeURLForRemounting
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
  @objc public var contentModificationDate: Date? {
    get {
      wrappedInstance.contentModificationDate
    }
    set {
      wrappedInstance.contentModificationDate = newValue
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
  @objc public var attributeModificationDate: Date? {
    get {
      wrappedInstance.attributeModificationDate
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
  @objc public var ubiquitousItemUploadingError: NSError? {
    get {
      wrappedInstance.ubiquitousItemUploadingError
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
  @objc public var ubiquitousItemDownloadingError: NSError? {
    get {
      wrappedInstance.ubiquitousItemDownloadingError
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
  @objc public var volume: URL? {
    get {
      wrappedInstance.volume
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

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class IntegerFormatStyleWrapper: NSObject {
  var wrappedInstance: IntegerFormatStyle

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var number: IntegerFormatStyleWrapper {
    get {
      IntegerFormatStyleWrapper(IntegerFormatStyle.number)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var number: IntegerFormatStyleWrapper {
    get {
      IntegerFormatStyleWrapper(IntegerFormatStyle.number)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var number: IntegerFormatStyleWrapper {
    get {
      IntegerFormatStyleWrapper(IntegerFormatStyle.number)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var number: IntegerFormatStyleWrapper {
    get {
      IntegerFormatStyleWrapper(IntegerFormatStyle.number)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var number: IntegerFormatStyleWrapper {
    get {
      IntegerFormatStyleWrapper(IntegerFormatStyle.number)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var number: IntegerFormatStyleWrapper {
    get {
      IntegerFormatStyleWrapper(IntegerFormatStyle.number)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var number: IntegerFormatStyleWrapper {
    get {
      IntegerFormatStyleWrapper(IntegerFormatStyle.number)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var number: IntegerFormatStyleWrapper {
    get {
      IntegerFormatStyleWrapper(IntegerFormatStyle.number)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var number: IntegerFormatStyleWrapper {
    get {
      IntegerFormatStyleWrapper(IntegerFormatStyle.number)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var number: IntegerFormatStyleWrapper {
    get {
      IntegerFormatStyleWrapper(IntegerFormatStyle.number)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var attributed: IntegerFormatStyleWrapper {
    get {
      IntegerFormatStyleWrapper(wrappedInstance.attributed)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var parseStrategy: IntegerParseStrategyWrapper {
    get {
      IntegerParseStrategyWrapper(wrappedInstance.parseStrategy)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var locale: Locale {
    get {
      wrappedInstance.locale
    }
    set {
      wrappedInstance.locale = newValue
    }
  }

  init(_ wrappedInstance: IntegerFormatStyle) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func scale(_ multiplicand: Double) -> IntegerFormatStyleWrapper {
    let result = wrappedInstance.scale(multiplicand)
    return IntegerFormatStyleWrapper(result)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func locale(_ locale: Locale) -> IntegerFormatStyleWrapper {
    let result = wrappedInstance.locale(locale)
    return IntegerFormatStyleWrapper(result)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class AttributedWrapper: NSObject {
    var wrappedInstance: IntegerFormatStyle.Attributed

    init(_ wrappedInstance: IntegerFormatStyle.Attributed) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func locale(_ locale: Locale) -> IntegerFormatStyleWrapper {
      let result = wrappedInstance.locale(locale)
      return IntegerFormatStyleWrapper(result)
    }

  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class PercentWrapper: NSObject {
    var wrappedInstance: IntegerFormatStyle.Percent

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var percent: IntegerFormatStyleWrapper {
      get {
        IntegerFormatStyleWrapper(IntegerFormatStyle.Percent.percent)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var percent: IntegerFormatStyleWrapper {
      get {
        IntegerFormatStyleWrapper(IntegerFormatStyle.Percent.percent)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var percent: IntegerFormatStyleWrapper {
      get {
        IntegerFormatStyleWrapper(IntegerFormatStyle.Percent.percent)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var percent: IntegerFormatStyleWrapper {
      get {
        IntegerFormatStyleWrapper(IntegerFormatStyle.Percent.percent)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var percent: IntegerFormatStyleWrapper {
      get {
        IntegerFormatStyleWrapper(IntegerFormatStyle.Percent.percent)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var percent: IntegerFormatStyleWrapper {
      get {
        IntegerFormatStyleWrapper(IntegerFormatStyle.Percent.percent)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var percent: IntegerFormatStyleWrapper {
      get {
        IntegerFormatStyleWrapper(IntegerFormatStyle.Percent.percent)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var percent: IntegerFormatStyleWrapper {
      get {
        IntegerFormatStyleWrapper(IntegerFormatStyle.Percent.percent)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var percent: IntegerFormatStyleWrapper {
      get {
        IntegerFormatStyleWrapper(IntegerFormatStyle.Percent.percent)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var percent: IntegerFormatStyleWrapper {
      get {
        IntegerFormatStyleWrapper(IntegerFormatStyle.Percent.percent)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var attributed: IntegerFormatStyleWrapper {
      get {
        IntegerFormatStyleWrapper(wrappedInstance.attributed)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var parseStrategy: IntegerParseStrategyWrapper {
      get {
        IntegerParseStrategyWrapper(wrappedInstance.parseStrategy)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var locale: Locale {
      get {
        wrappedInstance.locale
      }
      set {
        wrappedInstance.locale = newValue
      }
    }

    init(_ wrappedInstance: IntegerFormatStyle.Percent) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func scale(_ multiplicand: Double) -> IntegerFormatStyleWrapper {
      let result = wrappedInstance.scale(multiplicand)
      return IntegerFormatStyleWrapper(result)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func locale(_ locale: Locale) -> IntegerFormatStyleWrapper {
      let result = wrappedInstance.locale(locale)
      return IntegerFormatStyleWrapper(result)
    }

  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class CurrencyWrapper: NSObject {
    var wrappedInstance: IntegerFormatStyle.Currency

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var attributed: IntegerFormatStyleWrapper {
      get {
        IntegerFormatStyleWrapper(wrappedInstance.attributed)
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
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var parseStrategy: IntegerParseStrategyWrapper {
      get {
        IntegerParseStrategyWrapper(wrappedInstance.parseStrategy)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var locale: Locale {
      get {
        wrappedInstance.locale
      }
      set {
        wrappedInstance.locale = newValue
      }
    }

    init(_ wrappedInstance: IntegerFormatStyle.Currency) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func scale(_ multiplicand: Double) -> IntegerFormatStyleWrapper {
      let result = wrappedInstance.scale(multiplicand)
      return IntegerFormatStyleWrapper(result)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func locale(_ locale: Locale) -> IntegerFormatStyleWrapper {
      let result = wrappedInstance.locale(locale)
      return IntegerFormatStyleWrapper(result)
    }

  }

}

@available(macOS, introduced: 10.10)
@available(watchOS, introduced: 2.0)
@available(iOS, introduced: 8.0)
@available(tvOS, introduced: 9.0)
@objc public class NSIndexSetIteratorWrapper: NSObject {
  var wrappedInstance: NSIndexSetIterator

  init(_ wrappedInstance: NSIndexSetIterator) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func next() -> Int? {
    return wrappedInstance.next()
  }

}

@available(macOS, introduced: 12)
@available(watchOS, introduced: 8)
@available(iOS, introduced: 15)
@available(tvOS, introduced: 15)
@objc public class PresentationIntentWrapper: NSObject {
  var wrappedInstance: PresentationIntent

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public var debugDescription: String {
    get {
      wrappedInstance.debugDescription
    }
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public var indentationLevel: Int {
    get {
      wrappedInstance.indentationLevel
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
  @objc public var isValid: Bool {
    get {
      wrappedInstance.isValid
    }
  }

  init(_ wrappedInstance: PresentationIntent) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public class IntentTypeWrapper: NSObject {
    var wrappedInstance: PresentationIntent.IntentType

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public var debugDescription: String {
      get {
        wrappedInstance.debugDescription
      }
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public var identity: Int {
      get {
        wrappedInstance.identity
      }
      set {
        wrappedInstance.identity = newValue
      }
    }

    init(_ wrappedInstance: PresentationIntent.IntentType) {
      self.wrappedInstance = wrappedInstance
    }

  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public class TableColumnWrapper: NSObject {
    var wrappedInstance: PresentationIntent.TableColumn

    init(_ wrappedInstance: PresentationIntent.TableColumn) {
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

@available(macOS, introduced: 10.10)
@available(watchOS, introduced: 2.0)
@available(iOS, introduced: 8.0)
@available(tvOS, introduced: 9.0)
@objc public class PropertyListDecoderWrapper: NSObject {
  var wrappedInstance: PropertyListDecoder

  init(_ wrappedInstance: PropertyListDecoder) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc override init() {
    wrappedInstance = PropertyListDecoder()
  }

}

@available(macOS, introduced: 10.10)
@available(watchOS, introduced: 2.0)
@available(iOS, introduced: 8.0)
@available(tvOS, introduced: 9.0)
@objc public class PropertyListEncoderWrapper: NSObject {
  var wrappedInstance: PropertyListEncoder

  init(_ wrappedInstance: PropertyListEncoder) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc override init() {
    wrappedInstance = PropertyListEncoder()
  }

}

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class ByteCountFormatStyleWrapper: NSObject {
  var wrappedInstance: ByteCountFormatStyle

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var includesActualByteCount: Bool {
    get {
      wrappedInstance.includesActualByteCount
    }
    set {
      wrappedInstance.includesActualByteCount = newValue
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var attributed: ByteCountFormatStyleWrapper.AttributedWrapper {
    get {
      AttributedWrapper(wrappedInstance.attributed)
    }
    set {
      wrappedInstance.attributed = newValue.wrappedInstance
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var allowedUnits: ByteCountFormatStyleWrapper.UnitsWrapper {
    get {
      UnitsWrapper(wrappedInstance.allowedUnits)
    }
    set {
      wrappedInstance.allowedUnits = newValue.wrappedInstance
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var spellsOutZero: Bool {
    get {
      wrappedInstance.spellsOutZero
    }
    set {
      wrappedInstance.spellsOutZero = newValue
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var locale: Locale {
    get {
      wrappedInstance.locale
    }
    set {
      wrappedInstance.locale = newValue
    }
  }

  init(_ wrappedInstance: ByteCountFormatStyle) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func locale(_ locale: Locale) -> ByteCountFormatStyleWrapper {
    let result = wrappedInstance.locale(locale)
    return ByteCountFormatStyleWrapper(result)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class AttributedWrapper: NSObject {
    var wrappedInstance: ByteCountFormatStyle.Attributed

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var includesActualByteCount: Bool {
      get {
        wrappedInstance.includesActualByteCount
      }
      set {
        wrappedInstance.includesActualByteCount = newValue
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var allowedUnits: ByteCountFormatStyleWrapper.UnitsWrapper {
      get {
        UnitsWrapper(wrappedInstance.allowedUnits)
      }
      set {
        wrappedInstance.allowedUnits = newValue.wrappedInstance
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var spellsOutZero: Bool {
      get {
        wrappedInstance.spellsOutZero
      }
      set {
        wrappedInstance.spellsOutZero = newValue
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var locale: Locale {
      get {
        wrappedInstance.locale
      }
      set {
        wrappedInstance.locale = newValue
      }
    }

    init(_ wrappedInstance: ByteCountFormatStyle.Attributed) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func locale(_ locale: Locale) -> ByteCountFormatStyleWrapper.AttributedWrapper {
      let result = wrappedInstance.locale(locale)
      return AttributedWrapper(result)
    }

  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class UnitsWrapper: NSObject {
    var wrappedInstance: ByteCountFormatStyle.Units

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var ybOrHigher: ByteCountFormatStyleWrapper.UnitsWrapper {
      get {
        UnitsWrapper(ByteCountFormatStyle.Units.ybOrHigher)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var eb: ByteCountFormatStyleWrapper.UnitsWrapper {
      get {
        UnitsWrapper(ByteCountFormatStyle.Units.eb)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var gb: ByteCountFormatStyleWrapper.UnitsWrapper {
      get {
        UnitsWrapper(ByteCountFormatStyle.Units.gb)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var kb: ByteCountFormatStyleWrapper.UnitsWrapper {
      get {
        UnitsWrapper(ByteCountFormatStyle.Units.kb)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var mb: ByteCountFormatStyleWrapper.UnitsWrapper {
      get {
        UnitsWrapper(ByteCountFormatStyle.Units.mb)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var pb: ByteCountFormatStyleWrapper.UnitsWrapper {
      get {
        UnitsWrapper(ByteCountFormatStyle.Units.pb)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var tb: ByteCountFormatStyleWrapper.UnitsWrapper {
      get {
        UnitsWrapper(ByteCountFormatStyle.Units.tb)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var zb: ByteCountFormatStyleWrapper.UnitsWrapper {
      get {
        UnitsWrapper(ByteCountFormatStyle.Units.zb)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var all: ByteCountFormatStyleWrapper.UnitsWrapper {
      get {
        UnitsWrapper(ByteCountFormatStyle.Units.all)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var bytes: ByteCountFormatStyleWrapper.UnitsWrapper {
      get {
        UnitsWrapper(ByteCountFormatStyle.Units.bytes)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var `default`: ByteCountFormatStyleWrapper.UnitsWrapper {
      get {
        UnitsWrapper(ByteCountFormatStyle.Units.`default`)
      }
    }

    @objc public var isEmpty: Bool {
      get {
        wrappedInstance.isEmpty
      }
    }

    init(_ wrappedInstance: ByteCountFormatStyle.Units) {
      self.wrappedInstance = wrappedInstance
    }

    @objc override init() {
      wrappedInstance = ByteCountFormatStyle.Units()
    }

  }

}

@available(macOS, introduced: 12)
@available(watchOS, introduced: 8)
@available(iOS, introduced: 15)
@available(tvOS, introduced: 15)
@objc public class CodableConfigurationWrapper: NSObject {
  var wrappedInstance: CodableConfiguration

  init(_ wrappedInstance: CodableConfiguration) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class ComparableComparatorWrapper: NSObject {
  var wrappedInstance: ComparableComparator

  init(_ wrappedInstance: ComparableComparator) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class IntegerParseStrategyWrapper: NSObject {
  var wrappedInstance: IntegerParseStrategy

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

  init(_ wrappedInstance: IntegerParseStrategy) {
    self.wrappedInstance = wrappedInstance
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
    @objc public var locale: Locale {
      get {
        wrappedInstance.locale
      }
      set {
        wrappedInstance.locale = newValue
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
    @objc public func locale(_ locale: Locale) -> PersonNameComponentsWrapper.FormatStyleWrapper {
      let result = wrappedInstance.locale(locale)
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
    @objc public var locale: Locale {
      get {
        wrappedInstance.locale
      }
      set {
        wrappedInstance.locale = newValue
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
    @objc public func locale(_ locale: Locale) -> PersonNameComponentsWrapper.AttributedStyleWrapper {
      let result = wrappedInstance.locale(locale)
      return AttributedStyleWrapper(result)
    }

  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class CollectionContainsCollectionWrapper: NSObject {
  var wrappedInstance: CollectionContainsCollection

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: CollectionContainsCollection) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 10)
  @available(iOS, introduced: 17)
  @available(tvOS, introduced: 17)
  @objc public func evaluate(_ bindings: PredicateBindingsWrapper) throws -> BoolWrapper {
    let result = try wrappedInstance.evaluate(bindings.wrappedInstance)
    return BoolWrapper(result)
  }

}

@available(macOS, introduced: 15)
@available(watchOS, introduced: 11)
@available(iOS, introduced: 18)
@available(tvOS, introduced: 18)
@objc public class PredicateRegexWrapper: NSObject {
  var wrappedInstance: PredicateRegex

  @available(macOS, introduced: 15)
  @available(watchOS, introduced: 11)
  @available(iOS, introduced: 18)
  @available(tvOS, introduced: 18)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  @available(macOS, introduced: 15)
  @available(watchOS, introduced: 11)
  @available(iOS, introduced: 18)
  @available(tvOS, introduced: 18)
  @objc public var stringRepresentation: String {
    get {
      wrappedInstance.stringRepresentation
    }
  }

  init(_ wrappedInstance: PredicateRegex) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14.4)
@available(watchOS, introduced: 10.4)
@available(iOS, introduced: 17.4)
@available(tvOS, introduced: 17.4)
@objc public class PredicateEvaluateWrapper: NSObject {
  var wrappedInstance: PredicateEvaluate

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: PredicateEvaluate) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class ArithmeticWrapper: NSObject {
  var wrappedInstance: Arithmetic

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: Arithmetic) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class ComparisonWrapper: NSObject {
  var wrappedInstance: Comparison

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: Comparison) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 10)
  @available(iOS, introduced: 17)
  @available(tvOS, introduced: 17)
  @objc public func evaluate(_ bindings: PredicateBindingsWrapper) throws -> BoolWrapper {
    let result = try wrappedInstance.evaluate(bindings.wrappedInstance)
    return BoolWrapper(result)
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class NilLiteralWrapper: NSObject {
  var wrappedInstance: NilLiteral

  init(_ wrappedInstance: NilLiteral) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 10)
  @available(iOS, introduced: 17)
  @available(tvOS, introduced: 17)
  @objc override init() {
    wrappedInstance = NilLiteral()
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class UnaryMinusWrapper: NSObject {
  var wrappedInstance: UnaryMinus

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: UnaryMinus) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class VariableIDWrapper: NSObject {
  var wrappedInstance: VariableID

  init(_ wrappedInstance: VariableID) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class ClosedRangeWrapper: NSObject {
  var wrappedInstance: ClosedRange

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: ClosedRange) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class ConditionalWrapper: NSObject {
  var wrappedInstance: Conditional

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: Conditional) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class ConjunctionWrapper: NSObject {
  var wrappedInstance: Conjunction

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: Conjunction) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 10)
  @available(iOS, introduced: 17)
  @available(tvOS, introduced: 17)
  @objc public func evaluate(_ bindings: PredicateBindingsWrapper) throws -> BoolWrapper {
    let result = try wrappedInstance.evaluate(bindings.wrappedInstance)
    return BoolWrapper(result)
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class DisjunctionWrapper: NSObject {
  var wrappedInstance: Disjunction

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: Disjunction) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 10)
  @available(iOS, introduced: 17)
  @available(tvOS, introduced: 17)
  @objc public func evaluate(_ bindings: PredicateBindingsWrapper) throws -> BoolWrapper {
    let result = try wrappedInstance.evaluate(bindings.wrappedInstance)
    return BoolWrapper(result)
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class IntDivisionWrapper: NSObject {
  var wrappedInstance: IntDivision

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: IntDivision) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class NilCoalesceWrapper: NSObject {
  var wrappedInstance: NilCoalesce

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: NilCoalesce) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class ForcedUnwrapWrapper: NSObject {
  var wrappedInstance: ForcedUnwrap

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: ForcedUnwrap) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class IntRemainderWrapper: NSObject {
  var wrappedInstance: IntRemainder

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: IntRemainder) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class FloatDivisionWrapper: NSObject {
  var wrappedInstance: FloatDivision

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: FloatDivision) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class ConditionalCastWrapper: NSObject {
  var wrappedInstance: ConditionalCast

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: ConditionalCast) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class OptionalFlatMapWrapper: NSObject {
  var wrappedInstance: OptionalFlatMap

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: OptionalFlatMap) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class SequenceMaximumWrapper: NSObject {
  var wrappedInstance: SequenceMaximum

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: SequenceMaximum) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class SequenceMinimumWrapper: NSObject {
  var wrappedInstance: SequenceMinimum

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: SequenceMinimum) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class SequenceContainsWrapper: NSObject {
  var wrappedInstance: SequenceContains

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: SequenceContains) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 10)
  @available(iOS, introduced: 17)
  @available(tvOS, introduced: 17)
  @objc public func evaluate(_ bindings: PredicateBindingsWrapper) throws -> BoolWrapper {
    let result = try wrappedInstance.evaluate(bindings.wrappedInstance)
    return BoolWrapper(result)
  }

}

@available(macOS, introduced: 15)
@available(watchOS, introduced: 11)
@available(iOS, introduced: 18)
@available(tvOS, introduced: 18)
@objc public class ExpressionEvaluateWrapper: NSObject {
  var wrappedInstance: ExpressionEvaluate

  @available(macOS, introduced: 15)
  @available(watchOS, introduced: 11)
  @available(iOS, introduced: 18)
  @available(tvOS, introduced: 18)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: ExpressionEvaluate) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class SequenceAllSatisfyWrapper: NSObject {
  var wrappedInstance: SequenceAllSatisfy

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: SequenceAllSatisfy) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class SequenceStartsWithWrapper: NSObject {
  var wrappedInstance: SequenceStartsWith

  init(_ wrappedInstance: SequenceStartsWith) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 10)
  @available(iOS, introduced: 17)
  @available(tvOS, introduced: 17)
  @objc public func evaluate(_ bindings: PredicateBindingsWrapper) throws -> BoolWrapper {
    let result = try wrappedInstance.evaluate(bindings.wrappedInstance)
    return BoolWrapper(result)
  }

}

@available(macOS, introduced: 15)
@available(watchOS, introduced: 11)
@available(iOS, introduced: 18)
@available(tvOS, introduced: 18)
@objc public class StringContainsRegexWrapper: NSObject {
  var wrappedInstance: StringContainsRegex

  @available(macOS, introduced: 15)
  @available(watchOS, introduced: 11)
  @available(iOS, introduced: 18)
  @available(tvOS, introduced: 18)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: StringContainsRegex) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 15)
  @available(watchOS, introduced: 11)
  @available(iOS, introduced: 18)
  @available(tvOS, introduced: 18)
  @objc public func evaluate(_ bindings: PredicateBindingsWrapper) throws -> BoolWrapper {
    let result = try wrappedInstance.evaluate(bindings.wrappedInstance)
    return BoolWrapper(result)
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class SequenceContainsWhereWrapper: NSObject {
  var wrappedInstance: SequenceContainsWhere

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: SequenceContainsWhere) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class DictionaryKeySubscriptWrapper: NSObject {
  var wrappedInstance: DictionaryKeySubscript

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: DictionaryKeySubscript) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class StringLocalizedCompareWrapper: NSObject {
  var wrappedInstance: StringLocalizedCompare

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: StringLocalizedCompare) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class RangeExpressionContainsWrapper: NSObject {
  var wrappedInstance: RangeExpressionContains

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: RangeExpressionContains) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class CollectionIndexSubscriptWrapper: NSObject {
  var wrappedInstance: CollectionIndexSubscript

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: CollectionIndexSubscript) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class CollectionRangeSubscriptWrapper: NSObject {
  var wrappedInstance: CollectionRangeSubscript

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: CollectionRangeSubscript) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class StringCaseInsensitiveCompareWrapper: NSObject {
  var wrappedInstance: StringCaseInsensitiveCompare

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: StringCaseInsensitiveCompare) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class StringLocalizedStandardContainsWrapper: NSObject {
  var wrappedInstance: StringLocalizedStandardContains

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: StringLocalizedStandardContains) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class DictionaryKeyDefaultValueSubscriptWrapper: NSObject {
  var wrappedInstance: DictionaryKeyDefaultValueSubscript

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: DictionaryKeyDefaultValueSubscript) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class EqualWrapper: NSObject {
  var wrappedInstance: Equal

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: Equal) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 10)
  @available(iOS, introduced: 17)
  @available(tvOS, introduced: 17)
  @objc public func evaluate(_ bindings: PredicateBindingsWrapper) throws -> BoolWrapper {
    let result = try wrappedInstance.evaluate(bindings.wrappedInstance)
    return BoolWrapper(result)
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class RangeWrapper: NSObject {
  var wrappedInstance: Range

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: Range) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class ValueWrapper: NSObject {
  var wrappedInstance: Value

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: Value) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class FilterWrapper: NSObject {
  var wrappedInstance: Filter

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: Filter) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class KeyPathWrapper: NSObject {
  var wrappedInstance: KeyPath

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: KeyPath) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class NegationWrapper: NSObject {
  var wrappedInstance: Negation

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: Negation) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 10)
  @available(iOS, introduced: 17)
  @available(tvOS, introduced: 17)
  @objc public func evaluate(_ bindings: PredicateBindingsWrapper) throws -> BoolWrapper {
    let result = try wrappedInstance.evaluate(bindings.wrappedInstance)
    return BoolWrapper(result)
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class NotEqualWrapper: NSObject {
  var wrappedInstance: NotEqual

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: NotEqual) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 10)
  @available(iOS, introduced: 17)
  @available(tvOS, introduced: 17)
  @objc public func evaluate(_ bindings: PredicateBindingsWrapper) throws -> BoolWrapper {
    let result = try wrappedInstance.evaluate(bindings.wrappedInstance)
    return BoolWrapper(result)
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class VariableWrapper: NSObject {
  var wrappedInstance: Variable

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: Variable) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 10)
  @available(iOS, introduced: 17)
  @available(tvOS, introduced: 17)
  @objc override init() {
    wrappedInstance = Variable()
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class ForceCastWrapper: NSObject {
  var wrappedInstance: ForceCast

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: ForceCast) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class TypeCheckWrapper: NSObject {
  var wrappedInstance: TypeCheck

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: TypeCheck) {
    self.wrappedInstance = wrappedInstance
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
  @objc public var locale: Locale {
    get {
      wrappedInstance.locale
    }
    set {
      wrappedInstance.locale = newValue
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
@objc public class FloatingPointFormatStyleWrapper: NSObject {
  var wrappedInstance: FloatingPointFormatStyle

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var number: FloatingPointFormatStyleWrapper {
    get {
      FloatingPointFormatStyleWrapper(FloatingPointFormatStyle.number)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var number: FloatingPointFormatStyleWrapper {
    get {
      FloatingPointFormatStyleWrapper(FloatingPointFormatStyle.number)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var attributed: FloatingPointFormatStyleWrapper {
    get {
      FloatingPointFormatStyleWrapper(wrappedInstance.attributed)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var parseStrategy: FloatingPointParseStrategyWrapper {
    get {
      FloatingPointParseStrategyWrapper(wrappedInstance.parseStrategy)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var locale: Locale {
    get {
      wrappedInstance.locale
    }
    set {
      wrappedInstance.locale = newValue
    }
  }

  init(_ wrappedInstance: FloatingPointFormatStyle) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func scale(_ multiplicand: Double) -> FloatingPointFormatStyleWrapper {
    let result = wrappedInstance.scale(multiplicand)
    return FloatingPointFormatStyleWrapper(result)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func locale(_ locale: Locale) -> FloatingPointFormatStyleWrapper {
    let result = wrappedInstance.locale(locale)
    return FloatingPointFormatStyleWrapper(result)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class AttributedWrapper: NSObject {
    var wrappedInstance: FloatingPointFormatStyle.Attributed

    init(_ wrappedInstance: FloatingPointFormatStyle.Attributed) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func locale(_ locale: Locale) -> FloatingPointFormatStyleWrapper {
      let result = wrappedInstance.locale(locale)
      return FloatingPointFormatStyleWrapper(result)
    }

  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class PercentWrapper: NSObject {
    var wrappedInstance: FloatingPointFormatStyle.Percent

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var percent: FloatingPointFormatStyleWrapper {
      get {
        FloatingPointFormatStyleWrapper(FloatingPointFormatStyle.Percent.percent)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc static public var percent: FloatingPointFormatStyleWrapper {
      get {
        FloatingPointFormatStyleWrapper(FloatingPointFormatStyle.Percent.percent)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var attributed: FloatingPointFormatStyleWrapper {
      get {
        FloatingPointFormatStyleWrapper(wrappedInstance.attributed)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var parseStrategy: FloatingPointParseStrategyWrapper {
      get {
        FloatingPointParseStrategyWrapper(wrappedInstance.parseStrategy)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var locale: Locale {
      get {
        wrappedInstance.locale
      }
      set {
        wrappedInstance.locale = newValue
      }
    }

    init(_ wrappedInstance: FloatingPointFormatStyle.Percent) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func scale(_ multiplicand: Double) -> FloatingPointFormatStyleWrapper {
      let result = wrappedInstance.scale(multiplicand)
      return FloatingPointFormatStyleWrapper(result)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func locale(_ locale: Locale) -> FloatingPointFormatStyleWrapper {
      let result = wrappedInstance.locale(locale)
      return FloatingPointFormatStyleWrapper(result)
    }

  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class CurrencyWrapper: NSObject {
    var wrappedInstance: FloatingPointFormatStyle.Currency

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var attributed: FloatingPointFormatStyleWrapper {
      get {
        FloatingPointFormatStyleWrapper(wrappedInstance.attributed)
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
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var parseStrategy: FloatingPointParseStrategyWrapper {
      get {
        FloatingPointParseStrategyWrapper(wrappedInstance.parseStrategy)
      }
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public var locale: Locale {
      get {
        wrappedInstance.locale
      }
      set {
        wrappedInstance.locale = newValue
      }
    }

    init(_ wrappedInstance: FloatingPointFormatStyle.Currency) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func scale(_ multiplicand: Double) -> FloatingPointFormatStyleWrapper {
      let result = wrappedInstance.scale(multiplicand)
      return FloatingPointFormatStyleWrapper(result)
    }

    @available(macOS, introduced: 12.0)
    @available(watchOS, introduced: 8.0)
    @available(iOS, introduced: 15.0)
    @available(tvOS, introduced: 15.0)
    @objc public func locale(_ locale: Locale) -> FloatingPointFormatStyleWrapper {
      let result = wrappedInstance.locale(locale)
      return FloatingPointFormatStyleWrapper(result)
    }

  }

}

@available(macOS, introduced: 10.10)
@available(watchOS, introduced: 2.0)
@available(iOS, introduced: 8.0)
@available(tvOS, introduced: 9.0)
@objc public class NSKeyValueObservedChangeWrapper: NSObject {
  var wrappedInstance: NSKeyValueObservedChange

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var kind: NSKeyValueObservedChangeWrapper {
    get {
      NSKeyValueObservedChangeWrapper(wrappedInstance.kind)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var indexes: IndexSet? {
    get {
      wrappedInstance.indexes
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var isPrior: Bool {
    get {
      wrappedInstance.isPrior
    }
  }

  init(_ wrappedInstance: NSKeyValueObservedChange) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 12)
@available(watchOS, introduced: 8)
@available(iOS, introduced: 15)
@available(tvOS, introduced: 15)
@objc public class ScopedAttributeContainerWrapper: NSObject {
  var wrappedInstance: ScopedAttributeContainer

  init(_ wrappedInstance: ScopedAttributeContainer) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 10.10)
@available(watchOS, introduced: 2.0)
@available(iOS, introduced: 8.0)
@available(tvOS, introduced: 9.0)
@objc public class NSFastEnumerationIteratorWrapper: NSObject {
  var wrappedInstance: NSFastEnumerationIterator

  init(_ wrappedInstance: NSFastEnumerationIterator) {
    self.wrappedInstance = wrappedInstance
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
@objc public class FloatingPointParseStrategyWrapper: NSObject {
  var wrappedInstance: FloatingPointParseStrategy

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

  init(_ wrappedInstance: FloatingPointParseStrategy) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class MeasurementFormatUnitUsageWrapper: NSObject {
  var wrappedInstance: MeasurementFormatUnitUsage

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var asProvided: MeasurementFormatUnitUsageWrapper {
    get {
      MeasurementFormatUnitUsageWrapper(MeasurementFormatUnitUsage.asProvided)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var general: MeasurementFormatUnitUsageWrapper {
    get {
      MeasurementFormatUnitUsageWrapper(MeasurementFormatUnitUsage.general)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var personWeight: MeasurementFormatUnitUsageWrapper {
    get {
      MeasurementFormatUnitUsageWrapper(MeasurementFormatUnitUsage.personWeight)
    }
  }

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 17)
  @objc static public var wind: MeasurementFormatUnitUsageWrapper {
    get {
      MeasurementFormatUnitUsageWrapper(MeasurementFormatUnitUsage.wind)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var food: MeasurementFormatUnitUsageWrapper {
    get {
      MeasurementFormatUnitUsageWrapper(MeasurementFormatUnitUsage.food)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var workout: MeasurementFormatUnitUsageWrapper {
    get {
      MeasurementFormatUnitUsageWrapper(MeasurementFormatUnitUsage.workout)
    }
  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc static public var focalLength: MeasurementFormatUnitUsageWrapper {
    get {
      MeasurementFormatUnitUsageWrapper(MeasurementFormatUnitUsage.focalLength)
    }
  }

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 17)
  @objc static public var visibility: MeasurementFormatUnitUsageWrapper {
    get {
      MeasurementFormatUnitUsageWrapper(MeasurementFormatUnitUsage.visibility)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var personHeight: MeasurementFormatUnitUsageWrapper {
    get {
      MeasurementFormatUnitUsageWrapper(MeasurementFormatUnitUsage.personHeight)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var road: MeasurementFormatUnitUsageWrapper {
    get {
      MeasurementFormatUnitUsageWrapper(MeasurementFormatUnitUsage.road)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var person: MeasurementFormatUnitUsageWrapper {
    get {
      MeasurementFormatUnitUsageWrapper(MeasurementFormatUnitUsage.person)
    }
  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc static public var rainfall: MeasurementFormatUnitUsageWrapper {
    get {
      MeasurementFormatUnitUsageWrapper(MeasurementFormatUnitUsage.rainfall)
    }
  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc static public var snowfall: MeasurementFormatUnitUsageWrapper {
    get {
      MeasurementFormatUnitUsageWrapper(MeasurementFormatUnitUsage.snowfall)
    }
  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc static public var liquid: MeasurementFormatUnitUsageWrapper {
    get {
      MeasurementFormatUnitUsageWrapper(MeasurementFormatUnitUsage.liquid)
    }
  }

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 17)
  @objc static public var barometric: MeasurementFormatUnitUsageWrapper {
    get {
      MeasurementFormatUnitUsageWrapper(MeasurementFormatUnitUsage.barometric)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var person: MeasurementFormatUnitUsageWrapper {
    get {
      MeasurementFormatUnitUsageWrapper(MeasurementFormatUnitUsage.person)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var weather: MeasurementFormatUnitUsageWrapper {
    get {
      MeasurementFormatUnitUsageWrapper(MeasurementFormatUnitUsage.weather)
    }
  }

  init(_ wrappedInstance: MeasurementFormatUnitUsage) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class PredicateCodableConfigurationWrapper: NSObject {
  var wrappedInstance: PredicateCodableConfiguration

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 10)
  @available(iOS, introduced: 17)
  @available(tvOS, introduced: 17)
  @objc static public var standardConfiguration: PredicateCodableConfigurationWrapper {
    get {
      PredicateCodableConfigurationWrapper(PredicateCodableConfiguration.standardConfiguration)
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

  init(_ wrappedInstance: PredicateCodableConfiguration) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 10)
  @available(iOS, introduced: 17)
  @available(tvOS, introduced: 17)
  @objc override init() {
    wrappedInstance = PredicateCodableConfiguration()
  }

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 10)
  @available(iOS, introduced: 17)
  @available(tvOS, introduced: 17)
  @objc public func allow(_ other: PredicateCodableConfigurationWrapper) {
    return wrappedInstance.allow(other.wrappedInstance)
  }

}

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class SignDisplayStrategyWrapper: NSObject {
  var wrappedInstance: SignDisplayStrategy

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: SignDisplayStrategy) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class DecimalSeparatorDisplayStrategyWrapper: NSObject {
  var wrappedInstance: DecimalSeparatorDisplayStrategy

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: DecimalSeparatorDisplayStrategy) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class GroupingWrapper: NSObject {
  var wrappedInstance: Grouping

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: Grouping) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class NotationWrapper: NSObject {
  var wrappedInstance: Notation

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: Notation) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class PrecisionWrapper: NSObject {
  var wrappedInstance: Precision

  init(_ wrappedInstance: Precision) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class PresentationWrapper2: NSObject {
  var wrappedInstance: Presentation

  init(_ wrappedInstance: Presentation) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class SignDisplayStrategyWrapper1: NSObject {
  var wrappedInstance: SignDisplayStrategy

  init(_ wrappedInstance: SignDisplayStrategy) {
    self.wrappedInstance = wrappedInstance
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

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class PresentationWrapper1: NSObject {
  var wrappedInstance: Presentation

  init(_ wrappedInstance: Presentation) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class AsyncBytesWrapper2: NSObject {
  var wrappedInstance: AsyncBytes

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

  init(_ wrappedInstance: AsyncBytes) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func makeAsyncIterator() -> AsyncBytesWrapper2.AsyncIteratorWrapper {
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
@objc public class FormatStyleWrapper1: NSObject {
  var wrappedInstance: FormatStyle

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc static public var url: FormatStyleWrapper1 {
    get {
      FormatStyleWrapper1(FormatStyle.url)
    }
  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc static public var url: FormatStyleWrapper1 {
    get {
      FormatStyleWrapper1(FormatStyle.url)
    }
  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc public var parseStrategy: ParseStrategyWrapper1 {
    get {
      ParseStrategyWrapper1(wrappedInstance.parseStrategy)
    }
  }

  init(_ wrappedInstance: FormatStyle) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc public func format(_ value: URL) -> String {
    return wrappedInstance.format(value)
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
    @objc static public var omitIfHTTPFamily: FormatStyleWrapper1.HostDisplayOptionWrapper {
      get {
        HostDisplayOptionWrapper(FormatStyle.HostDisplayOption.omitIfHTTPFamily)
      }
    }

    @available(macOS, introduced: 13.0)
    @available(watchOS, introduced: 9.0)
    @available(iOS, introduced: 16.0)
    @available(tvOS, introduced: 16.0)
    @objc static public var never: FormatStyleWrapper1.HostDisplayOptionWrapper {
      get {
        HostDisplayOptionWrapper(FormatStyle.HostDisplayOption.never)
      }
    }

    @available(macOS, introduced: 13.0)
    @available(watchOS, introduced: 9.0)
    @available(iOS, introduced: 16.0)
    @available(tvOS, introduced: 16.0)
    @objc static public var always: FormatStyleWrapper1.HostDisplayOptionWrapper {
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
    @objc static public var omitIfHTTPFamily: FormatStyleWrapper1.ComponentDisplayOptionWrapper {
      get {
        ComponentDisplayOptionWrapper(FormatStyle.ComponentDisplayOption.omitIfHTTPFamily)
      }
    }

    @available(macOS, introduced: 13.0)
    @available(watchOS, introduced: 9.0)
    @available(iOS, introduced: 16.0)
    @available(tvOS, introduced: 16.0)
    @objc static public var never: FormatStyleWrapper1.ComponentDisplayOptionWrapper {
      get {
        ComponentDisplayOptionWrapper(FormatStyle.ComponentDisplayOption.never)
      }
    }

    @available(macOS, introduced: 13.0)
    @available(watchOS, introduced: 9.0)
    @available(iOS, introduced: 16.0)
    @available(tvOS, introduced: 16.0)
    @objc static public var always: FormatStyleWrapper1.ComponentDisplayOptionWrapper {
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
@objc public class ParseStrategyWrapper1: NSObject {
  var wrappedInstance: ParseStrategy

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc static public var url: ParseStrategyWrapper1 {
    get {
      ParseStrategyWrapper1(ParseStrategy.url)
    }
  }

  init(_ wrappedInstance: ParseStrategy) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc public func parse(_ value: String) throws -> URL {
    return try wrappedInstance.parse(value)
  }

}

@available(macOS, introduced: 10.10)
@available(watchOS, introduced: 2.0)
@available(iOS, introduced: 8.0)
@available(tvOS, introduced: 9.0)
@objc public class IteratorWrapper1: NSObject {
  var wrappedInstance: Iterator

  init(_ wrappedInstance: Iterator) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class FormatStyleWrapper: NSObject {
  var wrappedInstance: FormatStyle

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var dateTime: FormatStyleWrapper {
    get {
      FormatStyleWrapper(FormatStyle.dateTime)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var dateTime: FormatStyleWrapper {
    get {
      FormatStyleWrapper(FormatStyle.dateTime)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var dateTime: FormatStyleWrapper {
    get {
      FormatStyleWrapper(FormatStyle.dateTime)
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
  @objc public var attributed: AttributedStyleWrapper {
    get {
      AttributedStyleWrapper(wrappedInstance.attributed)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var parseStrategy: FormatStyleWrapper {
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
  @objc public var locale: Locale {
    get {
      wrappedInstance.locale
    }
    set {
      wrappedInstance.locale = newValue
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var calendar: Calendar {
    get {
      wrappedInstance.calendar
    }
    set {
      wrappedInstance.calendar = newValue
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var timeZone: TimeZone {
    get {
      wrappedInstance.timeZone
    }
    set {
      wrappedInstance.timeZone = newValue
    }
  }

  init(_ wrappedInstance: FormatStyle) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 15)
  @available(watchOS, introduced: 11)
  @available(iOS, introduced: 18)
  @available(tvOS, introduced: 18)
  @objc public func discreteInput(after input: Date) -> Date? {
    return wrappedInstance.discreteInput(after: input)
  }

  @available(macOS, introduced: 15)
  @available(watchOS, introduced: 11)
  @available(iOS, introduced: 18)
  @available(tvOS, introduced: 18)
  @objc public func discreteInput(before input: Date) -> Date? {
    return wrappedInstance.discreteInput(before: input)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func secondFraction(_ format: SymbolWrapper.SecondFractionWrapper) -> FormatStyleWrapper {
    let result = wrappedInstance.secondFraction(format.wrappedInstance)
    return FormatStyleWrapper(result)
  }

  @available(macOS, introduced: 15)
  @available(watchOS, introduced: 11)
  @available(iOS, introduced: 18)
  @available(tvOS, introduced: 18)
  @objc public func input(after input: Date) -> Date? {
    return wrappedInstance.input(after: input)
  }

  @available(macOS, introduced: 15)
  @available(watchOS, introduced: 11)
  @available(iOS, introduced: 18)
  @available(tvOS, introduced: 18)
  @objc public func input(before input: Date) -> Date? {
    return wrappedInstance.input(before: input)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func parse(_ value: String) throws -> Date {
    return try wrappedInstance.parse(value)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func format(_ value: Date) -> String {
    return wrappedInstance.format(value)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func locale(_ locale: Locale) -> FormatStyleWrapper {
    let result = wrappedInstance.locale(locale)
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
    @objc public func discreteInput(after input: Date) -> Date? {
      return wrappedInstance.discreteInput(after: input)
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public func discreteInput(before input: Date) -> Date? {
      return wrappedInstance.discreteInput(before: input)
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
    @objc public func input(after input: Date) -> Date? {
      return wrappedInstance.input(after: input)
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public func input(before input: Date) -> Date? {
      return wrappedInstance.input(before: input)
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public func format(_ value: Date) -> AttributedStringWrapper {
      let result = wrappedInstance.format(value)
      return AttributedStringWrapper(result)
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public func locale(_ locale: Locale) -> FormatStyleWrapper.AttributedWrapper {
      let result = wrappedInstance.locale(locale)
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
  var wrappedInstance: FormatString

  init(_ wrappedInstance: FormatString) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc init(stringLiteral value: String) {
    wrappedInstance = FormatString(stringLiteral: value)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc init(stringInterpolation: FormatStringWrapper.StringInterpolationWrapper) {
    wrappedInstance = FormatString(stringInterpolation: stringInterpolation.wrappedInstance)
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
  var wrappedInstance: ParseStrategy

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var twoDigitStartDate: Date {
    get {
      wrappedInstance.twoDigitStartDate
    }
    set {
      wrappedInstance.twoDigitStartDate = newValue
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
  @objc public var locale: Locale? {
    get {
      wrappedInstance.locale
    }
    set {
      wrappedInstance.locale = newValue
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var calendar: Calendar {
    get {
      wrappedInstance.calendar
    }
    set {
      wrappedInstance.calendar = newValue
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var timeZone: TimeZone {
    get {
      wrappedInstance.timeZone
    }
    set {
      wrappedInstance.timeZone = newValue
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

  init(_ wrappedInstance: ParseStrategy) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func parse(_ value: String) throws -> Date {
    return try wrappedInstance.parse(value)
  }

}

@available(macOS, introduced: 12, deprecated: 15)
@available(watchOS, introduced: 8, deprecated: 11)
@available(iOS, introduced: 15, deprecated: 18)
@available(tvOS, introduced: 15, deprecated: 18)
@objc public class AttributedStyleWrapper: NSObject {
  var wrappedInstance: AttributedStyle

  init(_ wrappedInstance: AttributedStyle) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 12, deprecated: 15)
  @available(watchOS, introduced: 8, deprecated: 11)
  @available(iOS, introduced: 15, deprecated: 18)
  @available(tvOS, introduced: 15, deprecated: 18)
  @objc public func format(_ value: Date) -> AttributedStringWrapper {
    let result = wrappedInstance.format(value)
    return AttributedStringWrapper(result)
  }

  @available(macOS, introduced: 12, deprecated: 15)
  @available(watchOS, introduced: 8, deprecated: 11)
  @available(iOS, introduced: 15, deprecated: 18)
  @available(tvOS, introduced: 15, deprecated: 18)
  @objc public func locale(_ locale: Locale) -> AttributedStyleWrapper {
    let result = wrappedInstance.locale(locale)
    return AttributedStyleWrapper(result)
  }

}

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class ISO8601FormatStyleWrapper: NSObject {
  var wrappedInstance: ISO8601FormatStyle

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var iso8601: ISO8601FormatStyleWrapper {
    get {
      ISO8601FormatStyleWrapper(ISO8601FormatStyle.iso8601)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var iso8601: ISO8601FormatStyleWrapper {
    get {
      ISO8601FormatStyleWrapper(ISO8601FormatStyle.iso8601)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var iso8601: ISO8601FormatStyleWrapper {
    get {
      ISO8601FormatStyleWrapper(ISO8601FormatStyle.iso8601)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var parseStrategy: ISO8601FormatStyleWrapper {
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
  @objc public var timeZone: TimeZone {
    get {
      wrappedInstance.timeZone
    }
    set {
      wrappedInstance.timeZone = newValue
    }
  }

  @available(macOS, introduced: 13.0)
  @available(watchOS, introduced: 9.0)
  @available(iOS, introduced: 16.0)
  @available(tvOS, introduced: 16.0)
  @objc static public var iso8601: ISO8601FormatStyleWrapper {
    get {
      ISO8601FormatStyleWrapper(ISO8601FormatStyle.iso8601)
    }
  }

  init(_ wrappedInstance: ISO8601FormatStyle) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func weekOfYear() -> ISO8601FormatStyleWrapper {
    let result = wrappedInstance.weekOfYear()
    return ISO8601FormatStyleWrapper(result)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func day() -> ISO8601FormatStyleWrapper {
    let result = wrappedInstance.day()
    return ISO8601FormatStyleWrapper(result)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func time(includingFractionalSeconds: Bool) -> ISO8601FormatStyleWrapper {
    let result = wrappedInstance.time(includingFractionalSeconds: includingFractionalSeconds)
    return ISO8601FormatStyleWrapper(result)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func year() -> ISO8601FormatStyleWrapper {
    let result = wrappedInstance.year()
    return ISO8601FormatStyleWrapper(result)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func month() -> ISO8601FormatStyleWrapper {
    let result = wrappedInstance.month()
    return ISO8601FormatStyleWrapper(result)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func parse(_ value: String) throws -> Date {
    return try wrappedInstance.parse(value)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func format(_ value: Date) -> String {
    return wrappedInstance.format(value)
  }

}

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class IntervalFormatStyleWrapper: NSObject {
  var wrappedInstance: IntervalFormatStyle

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var interval: IntervalFormatStyleWrapper {
    get {
      IntervalFormatStyleWrapper(IntervalFormatStyle.interval)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var locale: Locale {
    get {
      wrappedInstance.locale
    }
    set {
      wrappedInstance.locale = newValue
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var calendar: Calendar {
    get {
      wrappedInstance.calendar
    }
    set {
      wrappedInstance.calendar = newValue
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var timeZone: TimeZone {
    get {
      wrappedInstance.timeZone
    }
    set {
      wrappedInstance.timeZone = newValue
    }
  }

  init(_ wrappedInstance: IntervalFormatStyle) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func day() -> IntervalFormatStyleWrapper {
    let result = wrappedInstance.day()
    return IntervalFormatStyleWrapper(result)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func year() -> IntervalFormatStyleWrapper {
    let result = wrappedInstance.year()
    return IntervalFormatStyleWrapper(result)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func locale(_ locale: Locale) -> IntervalFormatStyleWrapper {
    let result = wrappedInstance.locale(locale)
    return IntervalFormatStyleWrapper(result)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func minute() -> IntervalFormatStyleWrapper {
    let result = wrappedInstance.minute()
    return IntervalFormatStyleWrapper(result)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func second() -> IntervalFormatStyleWrapper {
    let result = wrappedInstance.second()
    return IntervalFormatStyleWrapper(result)
  }

}

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class RelativeFormatStyleWrapper: NSObject {
  var wrappedInstance: RelativeFormatStyle

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
  @objc public var locale: Locale {
    get {
      wrappedInstance.locale
    }
    set {
      wrappedInstance.locale = newValue
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var calendar: Calendar {
    get {
      wrappedInstance.calendar
    }
    set {
      wrappedInstance.calendar = newValue
    }
  }

  init(_ wrappedInstance: RelativeFormatStyle) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func format(_ destDate: Date) -> String {
    return wrappedInstance.format(destDate)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func locale(_ locale: Locale) -> RelativeFormatStyleWrapper {
    let result = wrappedInstance.locale(locale)
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
  var wrappedInstance: VerbatimFormatStyle

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
  @objc public var attributed: AttributedStyleWrapper {
    get {
      AttributedStyleWrapper(wrappedInstance.attributed)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var parseStrategy: ParseStrategyWrapper {
    get {
      ParseStrategyWrapper(wrappedInstance.parseStrategy)
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var locale: Locale? {
    get {
      wrappedInstance.locale
    }
    set {
      wrappedInstance.locale = newValue
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var calendar: Calendar {
    get {
      wrappedInstance.calendar
    }
    set {
      wrappedInstance.calendar = newValue
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var timeZone: TimeZone {
    get {
      wrappedInstance.timeZone
    }
    set {
      wrappedInstance.timeZone = newValue
    }
  }

  init(_ wrappedInstance: VerbatimFormatStyle) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 15)
  @available(watchOS, introduced: 11)
  @available(iOS, introduced: 18)
  @available(tvOS, introduced: 18)
  @objc public func discreteInput(after input: Date) -> Date? {
    return wrappedInstance.discreteInput(after: input)
  }

  @available(macOS, introduced: 15)
  @available(watchOS, introduced: 11)
  @available(iOS, introduced: 18)
  @available(tvOS, introduced: 18)
  @objc public func discreteInput(before input: Date) -> Date? {
    return wrappedInstance.discreteInput(before: input)
  }

  @available(macOS, introduced: 15)
  @available(watchOS, introduced: 11)
  @available(iOS, introduced: 18)
  @available(tvOS, introduced: 18)
  @objc public func input(after input: Date) -> Date? {
    return wrappedInstance.input(after: input)
  }

  @available(macOS, introduced: 15)
  @available(watchOS, introduced: 11)
  @available(iOS, introduced: 18)
  @available(tvOS, introduced: 18)
  @objc public func input(before input: Date) -> Date? {
    return wrappedInstance.input(before: input)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func format(_ value: Date) -> String {
    return wrappedInstance.format(value)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func locale(_ locale: Locale) -> VerbatimFormatStyleWrapper {
    let result = wrappedInstance.locale(locale)
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
    @objc public func discreteInput(after input: Date) -> Date? {
      return wrappedInstance.discreteInput(after: input)
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public func discreteInput(before input: Date) -> Date? {
      return wrappedInstance.discreteInput(before: input)
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public func input(after input: Date) -> Date? {
      return wrappedInstance.input(after: input)
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public func input(before input: Date) -> Date? {
      return wrappedInstance.input(before: input)
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public func format(_ value: Date) -> AttributedStringWrapper {
      let result = wrappedInstance.format(value)
      return AttributedStringWrapper(result)
    }

    @available(macOS, introduced: 15)
    @available(watchOS, introduced: 11)
    @available(iOS, introduced: 18)
    @available(tvOS, introduced: 18)
    @objc public func locale(_ locale: Locale) -> VerbatimFormatStyleWrapper.AttributedWrapper {
      let result = wrappedInstance.locale(locale)
      return AttributedWrapper(result)
    }

  }

}

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class ComponentsFormatStyleWrapper: NSObject {
  var wrappedInstance: ComponentsFormatStyle

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc static public var timeDuration: ComponentsFormatStyleWrapper {
    get {
      ComponentsFormatStyleWrapper(ComponentsFormatStyle.timeDuration)
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
  @objc public var locale: Locale {
    get {
      wrappedInstance.locale
    }
    set {
      wrappedInstance.locale = newValue
    }
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var calendar: Calendar {
    get {
      wrappedInstance.calendar
    }
    set {
      wrappedInstance.calendar = newValue
    }
  }

  init(_ wrappedInstance: ComponentsFormatStyle) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func locale(_ locale: Locale) -> ComponentsFormatStyleWrapper {
    let result = wrappedInstance.locale(locale)
    return ComponentsFormatStyleWrapper(result)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func calendar(_ calendar: Calendar) -> ComponentsFormatStyleWrapper {
    let result = wrappedInstance.calendar(calendar)
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
  var wrappedInstance: AnchoredRelativeFormatStyle

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
  @objc public var anchor: Date {
    get {
      wrappedInstance.anchor
    }
    set {
      wrappedInstance.anchor = newValue
    }
  }

  @available(macOS, introduced: 15)
  @available(watchOS, introduced: 11)
  @available(iOS, introduced: 18)
  @available(tvOS, introduced: 18)
  @objc public var locale: Locale {
    get {
      wrappedInstance.locale
    }
    set {
      wrappedInstance.locale = newValue
    }
  }

  @available(macOS, introduced: 15)
  @available(watchOS, introduced: 11)
  @available(iOS, introduced: 18)
  @available(tvOS, introduced: 18)
  @objc public var calendar: Calendar {
    get {
      wrappedInstance.calendar
    }
    set {
      wrappedInstance.calendar = newValue
    }
  }

  init(_ wrappedInstance: AnchoredRelativeFormatStyle) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 15)
  @available(watchOS, introduced: 11)
  @available(iOS, introduced: 18)
  @available(tvOS, introduced: 18)
  @objc public func discreteInput(after input: Date) -> Date? {
    return wrappedInstance.discreteInput(after: input)
  }

  @available(macOS, introduced: 15)
  @available(watchOS, introduced: 11)
  @available(iOS, introduced: 18)
  @available(tvOS, introduced: 18)
  @objc public func discreteInput(before input: Date) -> Date? {
    return wrappedInstance.discreteInput(before: input)
  }

  @available(macOS, introduced: 15)
  @available(watchOS, introduced: 11)
  @available(iOS, introduced: 18)
  @available(tvOS, introduced: 18)
  @objc public func input(after input: Date) -> Date? {
    return wrappedInstance.input(after: input)
  }

  @available(macOS, introduced: 15)
  @available(watchOS, introduced: 11)
  @available(iOS, introduced: 18)
  @available(tvOS, introduced: 18)
  @objc public func input(before input: Date) -> Date? {
    return wrappedInstance.input(before: input)
  }

  @available(macOS, introduced: 15)
  @available(watchOS, introduced: 11)
  @available(iOS, introduced: 18)
  @available(tvOS, introduced: 18)
  @objc public func format(_ input: Date) -> String {
    return wrappedInstance.format(input)
  }

  @available(macOS, introduced: 15)
  @available(watchOS, introduced: 11)
  @available(iOS, introduced: 18)
  @available(tvOS, introduced: 18)
  @objc public func locale(_ locale: Locale) -> AnchoredRelativeFormatStyleWrapper {
    let result = wrappedInstance.locale(locale)
    return AnchoredRelativeFormatStyleWrapper(result)
  }

}

@available(macOS, introduced: 13)
@available(watchOS, introduced: 9)
@available(iOS, introduced: 16)
@available(tvOS, introduced: 16)
@objc public class ComponentsWrapper: NSObject {
  var wrappedInstance: Components

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public var languageComponents: LanguageWrapper.ComponentsWrapper1 {
    get {
      ComponentsWrapper1(wrappedInstance.languageComponents)
    }
    set {
      wrappedInstance.languageComponents = newValue.wrappedInstance
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public var subdivision: SubdivisionWrapper? {
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
  @objc public var numberingSystem: NumberingSystemWrapper? {
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
  @objc public var measurementSystem: MeasurementSystemWrapper? {
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
  @objc public var region: RegionWrapper? {
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
  @objc public var variant: VariantWrapper? {
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
  @objc public var currency: CurrencyWrapper? {
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
  @objc public var timeZone: TimeZone? {
    get {
      wrappedInstance.timeZone
    }
    set {
      wrappedInstance.timeZone = newValue
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public var collation: CollationWrapper? {
    get {
      wrappedInstance.collation == nil ? nil : CollationWrapper(wrappedInstance.collation!)
    }
    set {
      wrappedInstance.collation = newValue?.wrappedInstance
    }
  }

  init(_ wrappedInstance: Components) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init(identifier: String) {
    wrappedInstance = Components(identifier: identifier)
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init(locale: Locale) {
    wrappedInstance = Components(locale: locale)
  }

}

@available(macOS, introduced: 13)
@available(watchOS, introduced: 9)
@available(iOS, introduced: 16)
@available(tvOS, introduced: 16)
@objc public class SubdivisionWrapper: NSObject {
  var wrappedInstance: Subdivision

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

  init(_ wrappedInstance: Subdivision) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init(stringLiteral value: String) {
    wrappedInstance = Subdivision(stringLiteral: value)
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init(_ identifier: String) {
    wrappedInstance = Subdivision(identifier)
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public func subdivision(for region: RegionWrapper) -> SubdivisionWrapper {
    let result = Subdivision.subdivision(for: region.wrappedInstance)
    return SubdivisionWrapper(result)
  }

}

@available(macOS, introduced: 13)
@available(watchOS, introduced: 9)
@available(iOS, introduced: 16)
@available(tvOS, introduced: 16)
@objc public class LanguageCodeWrapper: NSObject {
  var wrappedInstance: LanguageCode

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var norwegianBokmål: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.norwegianBokmål)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var māori: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.māori)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var belarusian: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.belarusian)
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
  @objc static public var indonesian: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.indonesian)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var lithuanian: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.lithuanian)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var macedonian: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.macedonian)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var portuguese: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.portuguese)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var vietnamese: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.vietnamese)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var azerbaijani: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.azerbaijani)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var unavailable: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.unavailable)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var unidentified: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.unidentified)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var apacheWestern: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.apacheWestern)
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
  @objc static public var kurdishSorani: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.kurdishSorani)
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
  @objc static public var norwegianNynorsk: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.norwegianNynorsk)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var lao: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.lao)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var ainu: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.ainu)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var bodo: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.bodo)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var fula: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.fula)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var igbo: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.igbo)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var odia: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.odia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var thai: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.thai)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var urdu: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.urdu)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var czech: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.czech)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var dogri: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.dogri)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var dutch: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.dutch)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var greek: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.greek)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var hindi: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.hindi)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var irish: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.irish)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var khmer: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.khmer)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var malay: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.malay)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var tajik: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.tajik)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var tamil: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.tamil)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var uzbek: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.uzbek)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var welsh: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.welsh)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var arabic: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.arabic)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var bangla: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.bangla)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var danish: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.danish)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var french: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.french)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var german: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.german)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var hebrew: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.hebrew)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var kazakh: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.kazakh)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var korean: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.korean)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var kyrgyz: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.kyrgyz)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var navajo: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.navajo)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var nepali: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.nepali)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var pashto: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.pashto)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var polish: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.polish)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var samoan: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.samoan)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var sindhi: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.sindhi)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var slovak: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.slovak)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var telugu: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.telugu)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var tongan: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.tongan)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var uyghur: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.uyghur)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var amharic: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.amharic)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var burmese: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.burmese)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var catalan: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.catalan)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var chinese: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.chinese)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var dhivehi: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.dhivehi)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var english: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.english)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var faroese: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.faroese)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var finnish: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.finnish)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var italian: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.italian)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var kannada: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.kannada)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var konkani: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.konkani)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var kurdish: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.kurdish)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var latvian: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.latvian)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var maltese: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.maltese)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var marathi: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.marathi)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var persian: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.persian)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var punjabi: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.punjabi)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var russian: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.russian)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var santali: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.santali)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var serbian: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.serbian)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var sinhala: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.sinhala)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var spanish: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.spanish)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var swahili: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.swahili)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var swedish: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.swedish)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var tagalog: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.tagalog)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var tibetan: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.tibetan)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var turkish: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.turkish)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var turkmen: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.turkmen)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var uncoded: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.uncoded)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var yiddish: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.yiddish)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var albanian: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.albanian)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var armenian: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.armenian)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var assamese: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.assamese)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var assyrian: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.assyrian)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var cherokee: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.cherokee)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var croatian: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.croatian)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var dzongkha: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.dzongkha)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var estonian: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.estonian)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var georgian: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.georgian)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var gujarati: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.gujarati)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var hawaiian: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.hawaiian)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var japanese: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.japanese)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var kashmiri: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.kashmiri)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var maithili: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.maithili)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var manipuri: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.manipuri)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var multiple: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.multiple)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var rohingya: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.rohingya)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var romanian: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.romanian)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var sanskrit: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.sanskrit)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var bulgarian: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.bulgarian)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var cantonese: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.cantonese)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var hungarian: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.hungarian)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var icelandic: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.icelandic)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var malayalam: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.malayalam)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var mongolian: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.mongolian)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var norwegian: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.norwegian)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var slovenian: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.slovenian)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var ukrainian: LanguageCodeWrapper {
    get {
      LanguageCodeWrapper(LanguageCode.ukrainian)
    }
  }

  init(_ wrappedInstance: LanguageCode) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init(stringLiteral value: String) {
    wrappedInstance = LanguageCode(stringLiteral: value)
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init(_ identifier: String) {
    wrappedInstance = LanguageCode(identifier)
  }

}

@available(macOS, introduced: 13)
@available(watchOS, introduced: 9)
@available(iOS, introduced: 16)
@available(tvOS, introduced: 16)
@objc public class NumberingSystemWrapper: NSObject {
  var wrappedInstance: NumberingSystem

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

  init(_ wrappedInstance: NumberingSystem) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init(stringLiteral value: String) {
    wrappedInstance = NumberingSystem(stringLiteral: value)
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init(_ identifier: String) {
    wrappedInstance = NumberingSystem(identifier)
  }

}

@available(macOS, introduced: 13)
@available(watchOS, introduced: 9)
@available(iOS, introduced: 16)
@available(tvOS, introduced: 16)
@objc public class MeasurementSystemWrapper: NSObject {
  var wrappedInstance: MeasurementSystem

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
  @objc static public var uk: MeasurementSystemWrapper {
    get {
      MeasurementSystemWrapper(MeasurementSystem.uk)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var us: MeasurementSystemWrapper {
    get {
      MeasurementSystemWrapper(MeasurementSystem.us)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var metric: MeasurementSystemWrapper {
    get {
      MeasurementSystemWrapper(MeasurementSystem.metric)
    }
  }

  init(_ wrappedInstance: MeasurementSystem) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init(stringLiteral value: String) {
    wrappedInstance = MeasurementSystem(stringLiteral: value)
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init(_ identifier: String) {
    wrappedInstance = MeasurementSystem(identifier)
  }

}

@available(macOS, introduced: 13)
@available(watchOS, introduced: 9)
@available(iOS, introduced: 16)
@available(tvOS, introduced: 16)
@objc public class RegionWrapper: NSObject {
  var wrappedInstance: Region

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var curaçao: RegionWrapper {
    get {
      RegionWrapper(Region.curaçao)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var réunion: RegionWrapper {
    get {
      RegionWrapper(Region.réunion)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var côteDIvoire: RegionWrapper {
    get {
      RegionWrapper(Region.côteDIvoire)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var ålandIslands: RegionWrapper {
    get {
      RegionWrapper(Region.ålandIslands)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var saintBarthélemy: RegionWrapper {
    get {
      RegionWrapper(Region.saintBarthélemy)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var sãoToméPríncipe: RegionWrapper {
    get {
      RegionWrapper(Region.sãoToméPríncipe)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public var containingRegion: RegionWrapper? {
    get {
      wrappedInstance.containingRegion == nil ? nil : RegionWrapper(wrappedInstance.containingRegion!)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var antarctica: RegionWrapper {
    get {
      RegionWrapper(Region.antarctica)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var azerbaijan: RegionWrapper {
    get {
      RegionWrapper(Region.azerbaijan)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var bangladesh: RegionWrapper {
    get {
      RegionWrapper(Region.bangladesh)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var elSalvador: RegionWrapper {
    get {
      RegionWrapper(Region.elSalvador)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var guadeloupe: RegionWrapper {
    get {
      RegionWrapper(Region.guadeloupe)
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
  @objc static public var kazakhstan: RegionWrapper {
    get {
      RegionWrapper(Region.kazakhstan)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var kyrgyzstan: RegionWrapper {
    get {
      RegionWrapper(Region.kyrgyzstan)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var luxembourg: RegionWrapper {
    get {
      RegionWrapper(Region.luxembourg)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var madagascar: RegionWrapper {
    get {
      RegionWrapper(Region.madagascar)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var martinique: RegionWrapper {
    get {
      RegionWrapper(Region.martinique)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var mauritania: RegionWrapper {
    get {
      RegionWrapper(Region.mauritania)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var micronesia: RegionWrapper {
    get {
      RegionWrapper(Region.micronesia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var montenegro: RegionWrapper {
    get {
      RegionWrapper(Region.montenegro)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var montserrat: RegionWrapper {
    get {
      RegionWrapper(Region.montserrat)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var mozambique: RegionWrapper {
    get {
      RegionWrapper(Region.mozambique)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var newZealand: RegionWrapper {
    get {
      RegionWrapper(Region.newZealand)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var puertoRico: RegionWrapper {
    get {
      RegionWrapper(Region.puertoRico)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var saintLucia: RegionWrapper {
    get {
      RegionWrapper(Region.saintLucia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var seychelles: RegionWrapper {
    get {
      RegionWrapper(Region.seychelles)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var southKorea: RegionWrapper {
    get {
      RegionWrapper(Region.southKorea)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var southSudan: RegionWrapper {
    get {
      RegionWrapper(Region.southSudan)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var tajikistan: RegionWrapper {
    get {
      RegionWrapper(Region.tajikistan)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var timorLeste: RegionWrapper {
    get {
      RegionWrapper(Region.timorLeste)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var uzbekistan: RegionWrapper {
    get {
      RegionWrapper(Region.uzbekistan)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var afghanistan: RegionWrapper {
    get {
      RegionWrapper(Region.afghanistan)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var burkinaFaso: RegionWrapper {
    get {
      RegionWrapper(Region.burkinaFaso)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var cookIslands: RegionWrapper {
    get {
      RegionWrapper(Region.cookIslands)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var diegoGarcia: RegionWrapper {
    get {
      RegionWrapper(Region.diegoGarcia)
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
  @objc static public var netherlands: RegionWrapper {
    get {
      RegionWrapper(Region.netherlands)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var philippines: RegionWrapper {
    get {
      RegionWrapper(Region.philippines)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var saintHelena: RegionWrapper {
    get {
      RegionWrapper(Region.saintHelena)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var saintMartin: RegionWrapper {
    get {
      RegionWrapper(Region.saintMartin)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var saudiArabia: RegionWrapper {
    get {
      RegionWrapper(Region.saudiArabia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var sierraLeone: RegionWrapper {
    get {
      RegionWrapper(Region.sierraLeone)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var sintMaarten: RegionWrapper {
    get {
      RegionWrapper(Region.sintMaarten)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var southAfrica: RegionWrapper {
    get {
      RegionWrapper(Region.southAfrica)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var switzerland: RegionWrapper {
    get {
      RegionWrapper(Region.switzerland)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var vaticanCity: RegionWrapper {
    get {
      RegionWrapper(Region.vaticanCity)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var bouvetIsland: RegionWrapper {
    get {
      RegionWrapper(Region.bouvetIsland)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var ceutaMelilla: RegionWrapper {
    get {
      RegionWrapper(Region.ceutaMelilla)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var cocosIslands: RegionWrapper {
    get {
      RegionWrapper(Region.cocosIslands)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var faroeIslands: RegionWrapper {
    get {
      RegionWrapper(Region.faroeIslands)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var frenchGuiana: RegionWrapper {
    get {
      RegionWrapper(Region.frenchGuiana)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var guineaBissau: RegionWrapper {
    get {
      RegionWrapper(Region.guineaBissau)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var latinAmerica: RegionWrapper {
    get {
      RegionWrapper(Region.latinAmerica)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var newCaledonia: RegionWrapper {
    get {
      RegionWrapper(Region.newCaledonia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var turkmenistan: RegionWrapper {
    get {
      RegionWrapper(Region.turkmenistan)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var unitedStates: RegionWrapper {
    get {
      RegionWrapper(Region.unitedStates)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var wallisFutuna: RegionWrapper {
    get {
      RegionWrapper(Region.wallisFutuna)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var americanSamoa: RegionWrapper {
    get {
      RegionWrapper(Region.americanSamoa)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var canaryIslands: RegionWrapper {
    get {
      RegionWrapper(Region.canaryIslands)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var caymanIslands: RegionWrapper {
    get {
      RegionWrapper(Region.caymanIslands)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var chinaMainland: RegionWrapper {
    get {
      RegionWrapper(Region.chinaMainland)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var congoKinshasa: RegionWrapper {
    get {
      RegionWrapper(Region.congoKinshasa)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var liechtenstein: RegionWrapper {
    get {
      RegionWrapper(Region.liechtenstein)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var norfolkIsland: RegionWrapper {
    get {
      RegionWrapper(Region.norfolkIsland)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var unitedKingdom: RegionWrapper {
    get {
      RegionWrapper(Region.unitedKingdom)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var westernSahara: RegionWrapper {
    get {
      RegionWrapper(Region.westernSahara)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var antiguaBarbuda: RegionWrapper {
    get {
      RegionWrapper(Region.antiguaBarbuda)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var northMacedonia: RegionWrapper {
    get {
      RegionWrapper(Region.northMacedonia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var papuaNewGuinea: RegionWrapper {
    get {
      RegionWrapper(Region.papuaNewGuinea)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var solomonIslands: RegionWrapper {
    get {
      RegionWrapper(Region.solomonIslands)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var trinidadTobago: RegionWrapper {
    get {
      RegionWrapper(Region.trinidadTobago)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var tristanDaCunha: RegionWrapper {
    get {
      RegionWrapper(Region.tristanDaCunha)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var ascensionIsland: RegionWrapper {
    get {
      RegionWrapper(Region.ascensionIsland)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var christmasIsland: RegionWrapper {
    get {
      RegionWrapper(Region.christmasIsland)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var falklandIslands: RegionWrapper {
    get {
      RegionWrapper(Region.falklandIslands)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var frenchPolynesia: RegionWrapper {
    get {
      RegionWrapper(Region.frenchPolynesia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var marshallIslands: RegionWrapper {
    get {
      RegionWrapper(Region.marshallIslands)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var pitcairnIslands: RegionWrapper {
    get {
      RegionWrapper(Region.pitcairnIslands)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var saintKittsNevis: RegionWrapper {
    get {
      RegionWrapper(Region.saintKittsNevis)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var clippertonIsland: RegionWrapper {
    get {
      RegionWrapper(Region.clippertonIsland)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var congoBrazzaville: RegionWrapper {
    get {
      RegionWrapper(Region.congoBrazzaville)
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
  @objc static public var equatorialGuinea: RegionWrapper {
    get {
      RegionWrapper(Region.equatorialGuinea)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var svalbardJanMayen: RegionWrapper {
    get {
      RegionWrapper(Region.svalbardJanMayen)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var bosniaHerzegovina: RegionWrapper {
    get {
      RegionWrapper(Region.bosniaHerzegovina)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var chagosArchipelago: RegionWrapper {
    get {
      RegionWrapper(Region.chagosArchipelago)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var dominicanRepublic: RegionWrapper {
    get {
      RegionWrapper(Region.dominicanRepublic)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var turksCaicosIslands: RegionWrapper {
    get {
      RegionWrapper(Region.turksCaicosIslands)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var unitedArabEmirates: RegionWrapper {
    get {
      RegionWrapper(Region.unitedArabEmirates)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var saintPierreMiquelon: RegionWrapper {
    get {
      RegionWrapper(Region.saintPierreMiquelon)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var britishVirginIslands: RegionWrapper {
    get {
      RegionWrapper(Region.britishVirginIslands)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var caribbeanNetherlands: RegionWrapper {
    get {
      RegionWrapper(Region.caribbeanNetherlands)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var heardMcdonaldIslands: RegionWrapper {
    get {
      RegionWrapper(Region.heardMcdonaldIslands)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var centralAfricanRepublic: RegionWrapper {
    get {
      RegionWrapper(Region.centralAfricanRepublic)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var northernMarianaIslands: RegionWrapper {
    get {
      RegionWrapper(Region.northernMarianaIslands)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var palestinianTerritories: RegionWrapper {
    get {
      RegionWrapper(Region.palestinianTerritories)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var saintVincentGrenadines: RegionWrapper {
    get {
      RegionWrapper(Region.saintVincentGrenadines)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var frenchSouthernTerritories: RegionWrapper {
    get {
      RegionWrapper(Region.frenchSouthernTerritories)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var unitedStatesVirginIslands: RegionWrapper {
    get {
      RegionWrapper(Region.unitedStatesVirginIslands)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var unitedStatesOutlyingIslands: RegionWrapper {
    get {
      RegionWrapper(Region.unitedStatesOutlyingIslands)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var southGeorgiaSouthSandwichIslands: RegionWrapper {
    get {
      RegionWrapper(Region.southGeorgiaSouthSandwichIslands)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var chad: RegionWrapper {
    get {
      RegionWrapper(Region.chad)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var cuba: RegionWrapper {
    get {
      RegionWrapper(Region.cuba)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var fiji: RegionWrapper {
    get {
      RegionWrapper(Region.fiji)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var guam: RegionWrapper {
    get {
      RegionWrapper(Region.guam)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var iran: RegionWrapper {
    get {
      RegionWrapper(Region.iran)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var iraq: RegionWrapper {
    get {
      RegionWrapper(Region.iraq)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var laos: RegionWrapper {
    get {
      RegionWrapper(Region.laos)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var mali: RegionWrapper {
    get {
      RegionWrapper(Region.mali)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var niue: RegionWrapper {
    get {
      RegionWrapper(Region.niue)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var oman: RegionWrapper {
    get {
      RegionWrapper(Region.oman)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var peru: RegionWrapper {
    get {
      RegionWrapper(Region.peru)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var togo: RegionWrapper {
    get {
      RegionWrapper(Region.togo)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var aruba: RegionWrapper {
    get {
      RegionWrapper(Region.aruba)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var benin: RegionWrapper {
    get {
      RegionWrapper(Region.benin)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var chile: RegionWrapper {
    get {
      RegionWrapper(Region.chile)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var egypt: RegionWrapper {
    get {
      RegionWrapper(Region.egypt)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var gabon: RegionWrapper {
    get {
      RegionWrapper(Region.gabon)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var ghana: RegionWrapper {
    get {
      RegionWrapper(Region.ghana)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var haiti: RegionWrapper {
    get {
      RegionWrapper(Region.haiti)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var india: RegionWrapper {
    get {
      RegionWrapper(Region.india)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var italy: RegionWrapper {
    get {
      RegionWrapper(Region.italy)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var japan: RegionWrapper {
    get {
      RegionWrapper(Region.japan)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var kenya: RegionWrapper {
    get {
      RegionWrapper(Region.kenya)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var libya: RegionWrapper {
    get {
      RegionWrapper(Region.libya)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var macao: RegionWrapper {
    get {
      RegionWrapper(Region.macao)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var malta: RegionWrapper {
    get {
      RegionWrapper(Region.malta)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var nauru: RegionWrapper {
    get {
      RegionWrapper(Region.nauru)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var nepal: RegionWrapper {
    get {
      RegionWrapper(Region.nepal)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var niger: RegionWrapper {
    get {
      RegionWrapper(Region.niger)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var palau: RegionWrapper {
    get {
      RegionWrapper(Region.palau)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var qatar: RegionWrapper {
    get {
      RegionWrapper(Region.qatar)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var samoa: RegionWrapper {
    get {
      RegionWrapper(Region.samoa)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var spain: RegionWrapper {
    get {
      RegionWrapper(Region.spain)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var tonga: RegionWrapper {
    get {
      RegionWrapper(Region.tonga)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var world: RegionWrapper {
    get {
      RegionWrapper(Region.world)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var yemen: RegionWrapper {
    get {
      RegionWrapper(Region.yemen)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var angola: RegionWrapper {
    get {
      RegionWrapper(Region.angola)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var belize: RegionWrapper {
    get {
      RegionWrapper(Region.belize)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var bhutan: RegionWrapper {
    get {
      RegionWrapper(Region.bhutan)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var brazil: RegionWrapper {
    get {
      RegionWrapper(Region.brazil)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var brunei: RegionWrapper {
    get {
      RegionWrapper(Region.brunei)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var canada: RegionWrapper {
    get {
      RegionWrapper(Region.canada)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var cyprus: RegionWrapper {
    get {
      RegionWrapper(Region.cyprus)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var france: RegionWrapper {
    get {
      RegionWrapper(Region.france)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var gambia: RegionWrapper {
    get {
      RegionWrapper(Region.gambia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var greece: RegionWrapper {
    get {
      RegionWrapper(Region.greece)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var guinea: RegionWrapper {
    get {
      RegionWrapper(Region.guinea)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var guyana: RegionWrapper {
    get {
      RegionWrapper(Region.guyana)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var israel: RegionWrapper {
    get {
      RegionWrapper(Region.israel)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var jersey: RegionWrapper {
    get {
      RegionWrapper(Region.jersey)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var jordan: RegionWrapper {
    get {
      RegionWrapper(Region.jordan)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var kosovo: RegionWrapper {
    get {
      RegionWrapper(Region.kosovo)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var kuwait: RegionWrapper {
    get {
      RegionWrapper(Region.kuwait)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var latvia: RegionWrapper {
    get {
      RegionWrapper(Region.latvia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var malawi: RegionWrapper {
    get {
      RegionWrapper(Region.malawi)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var mexico: RegionWrapper {
    get {
      RegionWrapper(Region.mexico)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var monaco: RegionWrapper {
    get {
      RegionWrapper(Region.monaco)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var norway: RegionWrapper {
    get {
      RegionWrapper(Region.norway)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var panama: RegionWrapper {
    get {
      RegionWrapper(Region.panama)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var poland: RegionWrapper {
    get {
      RegionWrapper(Region.poland)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var russia: RegionWrapper {
    get {
      RegionWrapper(Region.russia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var rwanda: RegionWrapper {
    get {
      RegionWrapper(Region.rwanda)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var serbia: RegionWrapper {
    get {
      RegionWrapper(Region.serbia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var sweden: RegionWrapper {
    get {
      RegionWrapper(Region.sweden)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var taiwan: RegionWrapper {
    get {
      RegionWrapper(Region.taiwan)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var turkey: RegionWrapper {
    get {
      RegionWrapper(Region.turkey)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var tuvalu: RegionWrapper {
    get {
      RegionWrapper(Region.tuvalu)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var uganda: RegionWrapper {
    get {
      RegionWrapper(Region.uganda)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var zambia: RegionWrapper {
    get {
      RegionWrapper(Region.zambia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var albania: RegionWrapper {
    get {
      RegionWrapper(Region.albania)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var algeria: RegionWrapper {
    get {
      RegionWrapper(Region.algeria)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var andorra: RegionWrapper {
    get {
      RegionWrapper(Region.andorra)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var armenia: RegionWrapper {
    get {
      RegionWrapper(Region.armenia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var austria: RegionWrapper {
    get {
      RegionWrapper(Region.austria)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var bahamas: RegionWrapper {
    get {
      RegionWrapper(Region.bahamas)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var bahrain: RegionWrapper {
    get {
      RegionWrapper(Region.bahrain)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var belarus: RegionWrapper {
    get {
      RegionWrapper(Region.belarus)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var belgium: RegionWrapper {
    get {
      RegionWrapper(Region.belgium)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var bermuda: RegionWrapper {
    get {
      RegionWrapper(Region.bermuda)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var bolivia: RegionWrapper {
    get {
      RegionWrapper(Region.bolivia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var burundi: RegionWrapper {
    get {
      RegionWrapper(Region.burundi)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var comoros: RegionWrapper {
    get {
      RegionWrapper(Region.comoros)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var croatia: RegionWrapper {
    get {
      RegionWrapper(Region.croatia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var czechia: RegionWrapper {
    get {
      RegionWrapper(Region.czechia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var denmark: RegionWrapper {
    get {
      RegionWrapper(Region.denmark)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var ecuador: RegionWrapper {
    get {
      RegionWrapper(Region.ecuador)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var eritrea: RegionWrapper {
    get {
      RegionWrapper(Region.eritrea)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var estonia: RegionWrapper {
    get {
      RegionWrapper(Region.estonia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var finland: RegionWrapper {
    get {
      RegionWrapper(Region.finland)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var georgia: RegionWrapper {
    get {
      RegionWrapper(Region.georgia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var germany: RegionWrapper {
    get {
      RegionWrapper(Region.germany)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var grenada: RegionWrapper {
    get {
      RegionWrapper(Region.grenada)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var hungary: RegionWrapper {
    get {
      RegionWrapper(Region.hungary)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var iceland: RegionWrapper {
    get {
      RegionWrapper(Region.iceland)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var ireland: RegionWrapper {
    get {
      RegionWrapper(Region.ireland)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var jamaica: RegionWrapper {
    get {
      RegionWrapper(Region.jamaica)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var lebanon: RegionWrapper {
    get {
      RegionWrapper(Region.lebanon)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var lesotho: RegionWrapper {
    get {
      RegionWrapper(Region.lesotho)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var liberia: RegionWrapper {
    get {
      RegionWrapper(Region.liberia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var mayotte: RegionWrapper {
    get {
      RegionWrapper(Region.mayotte)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var moldova: RegionWrapper {
    get {
      RegionWrapper(Region.moldova)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var morocco: RegionWrapper {
    get {
      RegionWrapper(Region.morocco)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var myanmar: RegionWrapper {
    get {
      RegionWrapper(Region.myanmar)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var namibia: RegionWrapper {
    get {
      RegionWrapper(Region.namibia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var nigeria: RegionWrapper {
    get {
      RegionWrapper(Region.nigeria)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var romania: RegionWrapper {
    get {
      RegionWrapper(Region.romania)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var senegal: RegionWrapper {
    get {
      RegionWrapper(Region.senegal)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var somalia: RegionWrapper {
    get {
      RegionWrapper(Region.somalia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var tokelau: RegionWrapper {
    get {
      RegionWrapper(Region.tokelau)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var tunisia: RegionWrapper {
    get {
      RegionWrapper(Region.tunisia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var ukraine: RegionWrapper {
    get {
      RegionWrapper(Region.ukraine)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var unknown: RegionWrapper {
    get {
      RegionWrapper(Region.unknown)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var uruguay: RegionWrapper {
    get {
      RegionWrapper(Region.uruguay)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var vanuatu: RegionWrapper {
    get {
      RegionWrapper(Region.vanuatu)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var vietnam: RegionWrapper {
    get {
      RegionWrapper(Region.vietnam)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var anguilla: RegionWrapper {
    get {
      RegionWrapper(Region.anguilla)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var barbados: RegionWrapper {
    get {
      RegionWrapper(Region.barbados)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var botswana: RegionWrapper {
    get {
      RegionWrapper(Region.botswana)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var bulgaria: RegionWrapper {
    get {
      RegionWrapper(Region.bulgaria)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var cambodia: RegionWrapper {
    get {
      RegionWrapper(Region.cambodia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var cameroon: RegionWrapper {
    get {
      RegionWrapper(Region.cameroon)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var colombia: RegionWrapper {
    get {
      RegionWrapper(Region.colombia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var djibouti: RegionWrapper {
    get {
      RegionWrapper(Region.djibouti)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var dominica: RegionWrapper {
    get {
      RegionWrapper(Region.dominica)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var eswatini: RegionWrapper {
    get {
      RegionWrapper(Region.eswatini)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var ethiopia: RegionWrapper {
    get {
      RegionWrapper(Region.ethiopia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var guernsey: RegionWrapper {
    get {
      RegionWrapper(Region.guernsey)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var honduras: RegionWrapper {
    get {
      RegionWrapper(Region.honduras)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var hongKong: RegionWrapper {
    get {
      RegionWrapper(Region.hongKong)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var kiribati: RegionWrapper {
    get {
      RegionWrapper(Region.kiribati)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var malaysia: RegionWrapper {
    get {
      RegionWrapper(Region.malaysia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var maldives: RegionWrapper {
    get {
      RegionWrapper(Region.maldives)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var mongolia: RegionWrapper {
    get {
      RegionWrapper(Region.mongolia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var pakistan: RegionWrapper {
    get {
      RegionWrapper(Region.pakistan)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var paraguay: RegionWrapper {
    get {
      RegionWrapper(Region.paraguay)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var portugal: RegionWrapper {
    get {
      RegionWrapper(Region.portugal)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var slovakia: RegionWrapper {
    get {
      RegionWrapper(Region.slovakia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var slovenia: RegionWrapper {
    get {
      RegionWrapper(Region.slovenia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var sriLanka: RegionWrapper {
    get {
      RegionWrapper(Region.sriLanka)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var suriname: RegionWrapper {
    get {
      RegionWrapper(Region.suriname)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var tanzania: RegionWrapper {
    get {
      RegionWrapper(Region.tanzania)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var thailand: RegionWrapper {
    get {
      RegionWrapper(Region.thailand)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var zimbabwe: RegionWrapper {
    get {
      RegionWrapper(Region.zimbabwe)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var argentina: RegionWrapper {
    get {
      RegionWrapper(Region.argentina)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var australia: RegionWrapper {
    get {
      RegionWrapper(Region.australia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var capeVerde: RegionWrapper {
    get {
      RegionWrapper(Region.capeVerde)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public var continent: RegionWrapper? {
    get {
      wrappedInstance.continent == nil ? nil : RegionWrapper(wrappedInstance.continent!)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var costaRica: RegionWrapper {
    get {
      RegionWrapper(Region.costaRica)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var gibraltar: RegionWrapper {
    get {
      RegionWrapper(Region.gibraltar)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var greenland: RegionWrapper {
    get {
      RegionWrapper(Region.greenland)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var guatemala: RegionWrapper {
    get {
      RegionWrapper(Region.guatemala)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var indonesia: RegionWrapper {
    get {
      RegionWrapper(Region.indonesia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var isleOfMan: RegionWrapper {
    get {
      RegionWrapper(Region.isleOfMan)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var lithuania: RegionWrapper {
    get {
      RegionWrapper(Region.lithuania)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var mauritius: RegionWrapper {
    get {
      RegionWrapper(Region.mauritius)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var nicaragua: RegionWrapper {
    get {
      RegionWrapper(Region.nicaragua)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var sanMarino: RegionWrapper {
    get {
      RegionWrapper(Region.sanMarino)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var singapore: RegionWrapper {
    get {
      RegionWrapper(Region.singapore)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var venezuela: RegionWrapper {
    get {
      RegionWrapper(Region.venezuela)
    }
  }

  init(_ wrappedInstance: Region) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init(stringLiteral value: String) {
    wrappedInstance = Region(stringLiteral: value)
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init(_ identifier: String) {
    wrappedInstance = Region(identifier)
  }

}

@available(macOS, introduced: 13)
@available(watchOS, introduced: 9)
@available(iOS, introduced: 16)
@available(tvOS, introduced: 16)
@objc public class ScriptWrapper: NSObject {
  var wrappedInstance: Script

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var devanagari: ScriptWrapper {
    get {
      ScriptWrapper(Script.devanagari)
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
  @objc static public var meiteiMayek: ScriptWrapper {
    get {
      ScriptWrapper(Script.meiteiMayek)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var hanSimplified: ScriptWrapper {
    get {
      ScriptWrapper(Script.hanSimplified)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var arabicNastaliq: ScriptWrapper {
    get {
      ScriptWrapper(Script.arabicNastaliq)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var hanTraditional: ScriptWrapper {
    get {
      ScriptWrapper(Script.hanTraditional)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var hanifiRohingya: ScriptWrapper {
    get {
      ScriptWrapper(Script.hanifiRohingya)
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
  @objc static public var lao: ScriptWrapper {
    get {
      ScriptWrapper(Script.lao)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var odia: ScriptWrapper {
    get {
      ScriptWrapper(Script.odia)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var thai: ScriptWrapper {
    get {
      ScriptWrapper(Script.thai)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var adlam: ScriptWrapper {
    get {
      ScriptWrapper(Script.adlam)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var greek: ScriptWrapper {
    get {
      ScriptWrapper(Script.greek)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var khmer: ScriptWrapper {
    get {
      ScriptWrapper(Script.khmer)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var latin: ScriptWrapper {
    get {
      ScriptWrapper(Script.latin)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var tamil: ScriptWrapper {
    get {
      ScriptWrapper(Script.tamil)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var arabic: ScriptWrapper {
    get {
      ScriptWrapper(Script.arabic)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var bangla: ScriptWrapper {
    get {
      ScriptWrapper(Script.bangla)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var hebrew: ScriptWrapper {
    get {
      ScriptWrapper(Script.hebrew)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var korean: ScriptWrapper {
    get {
      ScriptWrapper(Script.korean)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var syriac: ScriptWrapper {
    get {
      ScriptWrapper(Script.syriac)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var telugu: ScriptWrapper {
    get {
      ScriptWrapper(Script.telugu)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var thaana: ScriptWrapper {
    get {
      ScriptWrapper(Script.thaana)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var kannada: ScriptWrapper {
    get {
      ScriptWrapper(Script.kannada)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var myanmar: ScriptWrapper {
    get {
      ScriptWrapper(Script.myanmar)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var olChiki: ScriptWrapper {
    get {
      ScriptWrapper(Script.olChiki)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var sinhala: ScriptWrapper {
    get {
      ScriptWrapper(Script.sinhala)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var tibetan: ScriptWrapper {
    get {
      ScriptWrapper(Script.tibetan)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var unknown: ScriptWrapper {
    get {
      ScriptWrapper(Script.unknown)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var armenian: ScriptWrapper {
    get {
      ScriptWrapper(Script.armenian)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var cherokee: ScriptWrapper {
    get {
      ScriptWrapper(Script.cherokee)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var cyrillic: ScriptWrapper {
    get {
      ScriptWrapper(Script.cyrillic)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var ethiopic: ScriptWrapper {
    get {
      ScriptWrapper(Script.ethiopic)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var georgian: ScriptWrapper {
    get {
      ScriptWrapper(Script.georgian)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var gujarati: ScriptWrapper {
    get {
      ScriptWrapper(Script.gujarati)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var gurmukhi: ScriptWrapper {
    get {
      ScriptWrapper(Script.gurmukhi)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var hiragana: ScriptWrapper {
    get {
      ScriptWrapper(Script.hiragana)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var japanese: ScriptWrapper {
    get {
      ScriptWrapper(Script.japanese)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var katakana: ScriptWrapper {
    get {
      ScriptWrapper(Script.katakana)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc static public var malayalam: ScriptWrapper {
    get {
      ScriptWrapper(Script.malayalam)
    }
  }

  init(_ wrappedInstance: Script) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init(stringLiteral value: String) {
    wrappedInstance = Script(stringLiteral: value)
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init(_ identifier: String) {
    wrappedInstance = Script(identifier)
  }

}

@available(macOS, introduced: 13)
@available(watchOS, introduced: 9)
@available(iOS, introduced: 16)
@available(tvOS, introduced: 16)
@objc public class VariantWrapper: NSObject {
  var wrappedInstance: Variant

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
  @objc static public var posix: VariantWrapper {
    get {
      VariantWrapper(Variant.posix)
    }
  }

  init(_ wrappedInstance: Variant) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init(stringLiteral value: String) {
    wrappedInstance = Variant(stringLiteral: value)
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init(_ identifier: String) {
    wrappedInstance = Variant(identifier)
  }

}

@available(macOS, introduced: 13)
@available(watchOS, introduced: 9)
@available(iOS, introduced: 16)
@available(tvOS, introduced: 16)
@objc public class CurrencyWrapper: NSObject {
  var wrappedInstance: Currency

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
  @objc static public var unknown: CurrencyWrapper {
    get {
      CurrencyWrapper(Currency.unknown)
    }
  }

  init(_ wrappedInstance: Currency) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init(stringLiteral value: String) {
    wrappedInstance = Currency(stringLiteral: value)
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init(_ identifier: String) {
    wrappedInstance = Currency(identifier)
  }

}

@available(macOS, introduced: 13)
@available(watchOS, introduced: 9)
@available(iOS, introduced: 16)
@available(tvOS, introduced: 16)
@objc public class LanguageWrapper: NSObject {
  var wrappedInstance: Language

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public var languageCode: LanguageCodeWrapper? {
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
  @objc public var parent: LanguageWrapper? {
    get {
      wrappedInstance.parent == nil ? nil : LanguageWrapper(wrappedInstance.parent!)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public var region: RegionWrapper? {
    get {
      wrappedInstance.region == nil ? nil : RegionWrapper(wrappedInstance.region!)
    }
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public var script: ScriptWrapper? {
    get {
      wrappedInstance.script == nil ? nil : ScriptWrapper(wrappedInstance.script!)
    }
  }

  init(_ wrappedInstance: Language) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init(components: LanguageWrapper.ComponentsWrapper1) {
    wrappedInstance = Language(components: components.wrappedInstance)
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init(identifier: String) {
    wrappedInstance = Language(identifier: identifier)
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public func isEquivalent(to language: LanguageWrapper) -> Bool {
    return wrappedInstance.isEquivalent(to: language.wrappedInstance)
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public func hasCommonParent(with language: LanguageWrapper) -> Bool {
    return wrappedInstance.hasCommonParent(with: language.wrappedInstance)
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc public class ComponentsWrapper1: NSObject {
    var wrappedInstance: Language.Components

    @available(macOS, introduced: 13)
    @available(watchOS, introduced: 9)
    @available(iOS, introduced: 16)
    @available(tvOS, introduced: 16)
    @objc public var languageCode: LanguageCodeWrapper? {
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
    @objc public var region: RegionWrapper? {
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
    @objc public var script: ScriptWrapper? {
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
    @objc init(language: LanguageWrapper) {
      wrappedInstance = Language.Components(language: language.wrappedInstance)
    }

  }

}

@available(macOS, introduced: 13)
@available(watchOS, introduced: 9)
@available(iOS, introduced: 16)
@available(tvOS, introduced: 16)
@objc public class CollationWrapper: NSObject {
  var wrappedInstance: Collation

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
  @objc static public var searchRules: CollationWrapper {
    get {
      CollationWrapper(Collation.searchRules)
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
  @objc static public var standard: CollationWrapper {
    get {
      CollationWrapper(Collation.standard)
    }
  }

  init(_ wrappedInstance: Collation) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init(stringLiteral value: String) {
    wrappedInstance = Collation(stringLiteral: value)
  }

  @available(macOS, introduced: 13)
  @available(watchOS, introduced: 9)
  @available(iOS, introduced: 16)
  @available(tvOS, introduced: 16)
  @objc init(_ identifier: String) {
    wrappedInstance = Collation(identifier)
  }

}

@available(macOS, introduced: 15)
@available(watchOS, introduced: 11)
@available(iOS, introduced: 18)
@available(tvOS, introduced: 18)
@objc public class RecurrenceRuleWrapper: NSObject {
  var wrappedInstance: RecurrenceRule

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
  @objc public var calendar: Calendar {
    get {
      wrappedInstance.calendar
    }
    set {
      wrappedInstance.calendar = newValue
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

  init(_ wrappedInstance: RecurrenceRule) {
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
    @objc public var date: Date? {
      get {
        wrappedInstance.date
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
    @objc static public func afterDate(_ date: Date) -> RecurrenceRuleWrapper.EndWrapper {
      let result = RecurrenceRule.End.afterDate(date)
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

@available(macOS, introduced: 10.10)
@available(watchOS, introduced: 2.0)
@available(iOS, introduced: 8.0)
@available(tvOS, introduced: 9.0)
@objc public class IndexWrapper: NSObject {
  var wrappedInstance: Index

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  init(_ wrappedInstance: Index) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 10.10)
@available(watchOS, introduced: 2.0)
@available(iOS, introduced: 8.0)
@available(tvOS, introduced: 9.0)
@objc public class RangeViewWrapper: NSObject {
  var wrappedInstance: RangeView

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var endIndex: RangeView.Index {
    get {
      wrappedInstance.endIndex
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var startIndex: RangeView.Index {
    get {
      wrappedInstance.startIndex
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

  init(_ wrappedInstance: RangeView) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func index(after i: RangeView.Index) -> RangeView.Index {
    return wrappedInstance.index(after: i)
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public func index(before i: RangeView.Index) -> RangeView.Index {
    return wrappedInstance.index(before: i)
  }

}

@available(macOS, introduced: 10.10)
@available(watchOS, introduced: 2.0)
@available(iOS, introduced: 8.0)
@available(tvOS, introduced: 9.0)
@objc public class URLErrorWrapper: NSObject {
  var wrappedInstance: URLError

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var errorDomain: String {
    get {
      URLError.errorDomain
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var failingURL: URL? {
    get {
      wrappedInstance.failingURL
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var errorDomain: String {
    get {
      URLError.errorDomain
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var callIsActive: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.callIsActive)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var cannotFindHost: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.cannotFindHost)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var cannotMoveFile: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.cannotMoveFile)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var cannotOpenFile: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.cannotOpenFile)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var dataNotAllowed: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.dataNotAllowed)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var unsupportedURL: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.unsupportedURL)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var cannotCloseFile: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.cannotCloseFile)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var dnsLookupFailed: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.dnsLookupFailed)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileIsDirectory: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.fileIsDirectory)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var cannotCreateFile: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.cannotCreateFile)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var cannotRemoveFile: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.cannotRemoveFile)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var failureURLString: String? {
    get {
      wrappedInstance.failureURLString
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var fileDoesNotExist: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.fileDoesNotExist)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var zeroByteResource: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.zeroByteResource)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var badServerResponse: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.badServerResponse)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var cannotWriteToFile: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.cannotWriteToFile)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var cannotConnectToHost: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.cannotConnectToHost)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var cannotDecodeRawData: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.cannotDecodeRawData)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var cannotParseResponse: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.cannotParseResponse)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var resourceUnavailable: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.resourceUnavailable)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var httpTooManyRedirects: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.httpTooManyRedirects)
    }
  }

  @available(macOS, introduced: 14.0)
  @available(watchOS, introduced: 10.0)
  @available(iOS, introduced: 17.0)
  @available(tvOS, introduced: 17.0)
  @objc public var uploadTaskResumeData: Data? {
    get {
      wrappedInstance.uploadTaskResumeData
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var cannotLoadFromNetwork: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.cannotLoadFromNetwork)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var networkConnectionLost: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.networkConnectionLost)
    }
  }

  @available(macOS, introduced: 10.15)
  @available(watchOS, introduced: 6.0)
  @available(iOS, introduced: 13.0)
  @available(tvOS, introduced: 13.0)
  @objc public var downloadTaskResumeData: Data? {
    get {
      wrappedInstance.downloadTaskResumeData
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var notConnectedToInternet: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.notConnectedToInternet)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var secureConnectionFailed: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.secureConnectionFailed)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var cannotDecodeContentData: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.cannotDecodeContentData)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var internationalRoamingOff: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.internationalRoamingOff)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var noPermissionsToReadFile: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.noPermissionsToReadFile)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var dataLengthExceedsMaximum: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.dataLengthExceedsMaximum)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var clientCertificateRejected: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.clientCertificateRejected)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var clientCertificateRequired: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.clientCertificateRequired)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var requestBodyStreamExhausted: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.requestBodyStreamExhausted)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var serverCertificateUntrusted: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.serverCertificateUntrusted)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var userAuthenticationRequired: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.userAuthenticationRequired)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var serverCertificateHasBadDate: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.serverCertificateHasBadDate)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var userCancelledAuthentication: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.userCancelledAuthentication)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var serverCertificateNotYetValid: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.serverCertificateNotYetValid)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var redirectToNonExistentLocation: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.redirectToNonExistentLocation)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var downloadDecodingFailedMidStream: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.downloadDecodingFailedMidStream)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var serverCertificateHasUnknownRoot: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.serverCertificateHasUnknownRoot)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var backgroundSessionWasDisconnected: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.backgroundSessionWasDisconnected)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var downloadDecodingFailedToComplete: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.downloadDecodingFailedToComplete)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var backgroundSessionInUseByAnotherProcess: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.backgroundSessionInUseByAnotherProcess)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var backgroundSessionRequiresSharedContainer: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.backgroundSessionRequiresSharedContainer)
    }
  }

  @available(macOS, introduced: 10.11)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 9.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var appTransportSecurityRequiresSecureConnection: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.appTransportSecurityRequiresSecureConnection)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var badURL: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.badURL)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var unknown: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.unknown)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var timedOut: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.timedOut)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var cancelled: URLErrorWrapper.CodeWrapper {
    get {
      CodeWrapper(URLError.cancelled)
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var localizedDescription: String {
    get {
      wrappedInstance.localizedDescription
    }
  }

  init(_ wrappedInstance: URLError) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public class CodeWrapper: NSObject {
    var wrappedInstance: URLError.Code

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var callIsActive: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.callIsActive)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var cannotFindHost: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.cannotFindHost)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var cannotMoveFile: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.cannotMoveFile)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var cannotOpenFile: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.cannotOpenFile)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var dataNotAllowed: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.dataNotAllowed)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var unsupportedURL: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.unsupportedURL)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var cannotCloseFile: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.cannotCloseFile)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var dnsLookupFailed: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.dnsLookupFailed)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileIsDirectory: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.fileIsDirectory)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var cannotCreateFile: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.cannotCreateFile)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var cannotRemoveFile: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.cannotRemoveFile)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var fileDoesNotExist: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.fileDoesNotExist)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var zeroByteResource: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.zeroByteResource)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var badServerResponse: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.badServerResponse)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var cannotWriteToFile: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.cannotWriteToFile)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var cannotConnectToHost: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.cannotConnectToHost)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var cannotDecodeRawData: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.cannotDecodeRawData)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var cannotParseResponse: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.cannotParseResponse)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var resourceUnavailable: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.resourceUnavailable)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var httpTooManyRedirects: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.httpTooManyRedirects)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var cannotLoadFromNetwork: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.cannotLoadFromNetwork)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var networkConnectionLost: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.networkConnectionLost)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var notConnectedToInternet: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.notConnectedToInternet)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var secureConnectionFailed: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.secureConnectionFailed)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var cannotDecodeContentData: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.cannotDecodeContentData)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var internationalRoamingOff: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.internationalRoamingOff)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var noPermissionsToReadFile: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.noPermissionsToReadFile)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var dataLengthExceedsMaximum: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.dataLengthExceedsMaximum)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var clientCertificateRejected: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.clientCertificateRejected)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var clientCertificateRequired: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.clientCertificateRequired)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var requestBodyStreamExhausted: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.requestBodyStreamExhausted)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var serverCertificateUntrusted: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.serverCertificateUntrusted)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var userAuthenticationRequired: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.userAuthenticationRequired)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var serverCertificateHasBadDate: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.serverCertificateHasBadDate)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var userCancelledAuthentication: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.userCancelledAuthentication)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var serverCertificateNotYetValid: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.serverCertificateNotYetValid)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var redirectToNonExistentLocation: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.redirectToNonExistentLocation)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var downloadDecodingFailedMidStream: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.downloadDecodingFailedMidStream)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var serverCertificateHasUnknownRoot: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.serverCertificateHasUnknownRoot)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var backgroundSessionWasDisconnected: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.backgroundSessionWasDisconnected)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var downloadDecodingFailedToComplete: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.downloadDecodingFailedToComplete)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var backgroundSessionInUseByAnotherProcess: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.backgroundSessionInUseByAnotherProcess)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var backgroundSessionRequiresSharedContainer: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.backgroundSessionRequiresSharedContainer)
      }
    }

    @available(macOS, introduced: 10.11)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 9.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var appTransportSecurityRequiresSecureConnection: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.appTransportSecurityRequiresSecureConnection)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var badURL: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.badURL)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var unknown: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.unknown)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc public var rawValue: Int {
      get {
        wrappedInstance.rawValue
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var timedOut: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.timedOut)
      }
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc static public var cancelled: URLErrorWrapper.CodeWrapper {
      get {
        CodeWrapper(URLError.Code.cancelled)
      }
    }

    init(_ wrappedInstance: URLError.Code) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 10.10)
    @available(watchOS, introduced: 2.0)
    @available(iOS, introduced: 8.0)
    @available(tvOS, introduced: 9.0)
    @objc init(rawValue: Int) {
      wrappedInstance = URLError.Code(rawValue: rawValue)
    }

  }

}

@available(macOS, introduced: 10.10)
@available(watchOS, introduced: 2.0)
@available(iOS, introduced: 8.0)
@available(tvOS, introduced: 9.0)
@objc public class MachErrorWrapper: NSObject {
  var wrappedInstance: MachError

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var errorDomain: String {
    get {
      MachError.errorDomain
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc static public var errorDomain: String {
    get {
      MachError.errorDomain
    }
  }

  @available(macOS, introduced: 10.10)
  @available(watchOS, introduced: 2.0)
  @available(iOS, introduced: 8.0)
  @available(tvOS, introduced: 9.0)
  @objc public var localizedDescription: String {
    get {
      wrappedInstance.localizedDescription
    }
  }

  init(_ wrappedInstance: MachError) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14)
@available(watchOS, introduced: 10)
@available(iOS, introduced: 17)
@available(tvOS, introduced: 17)
@objc public class PredicateWrapper: NSObject {
  var wrappedInstance: Predicate

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }

  @available(macOS, introduced: 14.4)
  @available(watchOS, introduced: 10.4)
  @available(iOS, introduced: 17.4)
  @available(tvOS, introduced: 17.4)
  @objc public var debugDescription: String {
    get {
      wrappedInstance.debugDescription
    }
  }

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 10)
  @available(iOS, introduced: 17)
  @available(tvOS, introduced: 17)
  @objc static public var `true`: PredicateWrapper {
    get {
      PredicateWrapper(Predicate.`true`)
    }
  }

  @available(macOS, introduced: 14)
  @available(watchOS, introduced: 10)
  @available(iOS, introduced: 17)
  @available(tvOS, introduced: 17)
  @objc static public var `false`: PredicateWrapper {
    get {
      PredicateWrapper(Predicate.`false`)
    }
  }

  init(_ wrappedInstance: Predicate) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class BoolWrapper: NSObject {
  var wrappedInstance: Bool

  init(_ wrappedInstance: Bool) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 10.10)
@available(watchOS, introduced: 2.0)
@available(iOS, introduced: 8.0)
@available(tvOS, introduced: 9.0)
@objc public class IteratorWrapper: NSObject {
  var wrappedInstance: Iterator

  init(_ wrappedInstance: Iterator) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class AsyncBytesWrapper: NSObject {
  var wrappedInstance: AsyncBytes

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

  init(_ wrappedInstance: AsyncBytes) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func makeAsyncIterator() -> AsyncBytesWrapper.IteratorWrapper {
    let result = wrappedInstance.makeAsyncIterator()
    return IteratorWrapper(result)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class IteratorWrapper: NSObject {
    var wrappedInstance: AsyncBytes.Iterator

    init(_ wrappedInstance: AsyncBytes.Iterator) {
      self.wrappedInstance = wrappedInstance
    }

  }

}

@available(macOS, introduced: 12.0)
@available(watchOS, introduced: 8.0)
@available(iOS, introduced: 15.0)
@available(tvOS, introduced: 15.0)
@objc public class AsyncBytesWrapper1: NSObject {
  var wrappedInstance: AsyncBytes

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

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public var task: URLSessionDataTask {
    get {
      wrappedInstance.task
    }
  }

  init(_ wrappedInstance: AsyncBytes) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public func makeAsyncIterator() -> AsyncBytesWrapper1.IteratorWrapper {
    let result = wrappedInstance.makeAsyncIterator()
    return IteratorWrapper(result)
  }

  @available(macOS, introduced: 12.0)
  @available(watchOS, introduced: 8.0)
  @available(iOS, introduced: 15.0)
  @available(tvOS, introduced: 15.0)
  @objc public class IteratorWrapper: NSObject {
    var wrappedInstance: AsyncBytes.Iterator

    init(_ wrappedInstance: AsyncBytes.Iterator) {
      self.wrappedInstance = wrappedInstance
    }

  }

}

@available(macOS, introduced: 10.15)
@available(watchOS, introduced: 6.0)
@available(iOS, introduced: 13.0)
@available(tvOS, introduced: 13.0)
@objc public class DataTaskPublisherWrapper: NSObject {
  var wrappedInstance: DataTaskPublisher

  @available(macOS, introduced: 10.15)
  @available(watchOS, introduced: 6.0)
  @available(iOS, introduced: 13.0)
  @available(tvOS, introduced: 13.0)
  @objc public var request: URLRequest {
    get {
      wrappedInstance.request
    }
  }

  @available(macOS, introduced: 10.15)
  @available(watchOS, introduced: 6.0)
  @available(iOS, introduced: 13.0)
  @available(tvOS, introduced: 13.0)
  @objc public var session: URLSession {
    get {
      wrappedInstance.session
    }
  }

  init(_ wrappedInstance: DataTaskPublisher) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.15)
  @available(watchOS, introduced: 6.0)
  @available(iOS, introduced: 13.0)
  @available(tvOS, introduced: 13.0)
  @objc init(request: URLRequest, session: URLSession) {
    wrappedInstance = DataTaskPublisher(request: request, session: session)
  }

}

@available(macOS, introduced: 10.15)
@available(watchOS, introduced: 6.0)
@available(iOS, introduced: 13.0)
@available(tvOS, introduced: 13.0)
@objc public class SchedulerOptionsWrapper1: NSObject {
  var wrappedInstance: SchedulerOptions

  init(_ wrappedInstance: SchedulerOptions) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 10.15)
@available(watchOS, introduced: 6.0)
@available(iOS, introduced: 13.0)
@available(tvOS, introduced: 13.0)
@objc public class SchedulerTimeTypeWrapper1: NSObject {
  var wrappedInstance: SchedulerTimeType

  @available(macOS, introduced: 10.15)
  @available(watchOS, introduced: 6.0)
  @available(iOS, introduced: 13.0)
  @available(tvOS, introduced: 13.0)
  @objc public var date: Date {
    get {
      wrappedInstance.date
    }
    set {
      wrappedInstance.date = newValue
    }
  }

  init(_ wrappedInstance: SchedulerTimeType) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.15)
  @available(watchOS, introduced: 6.0)
  @available(iOS, introduced: 13.0)
  @available(tvOS, introduced: 13.0)
  @objc init(_ date: Date) {
    wrappedInstance = SchedulerTimeType(date)
  }

  @available(macOS, introduced: 10.15)
  @available(watchOS, introduced: 6.0)
  @available(iOS, introduced: 13.0)
  @available(tvOS, introduced: 13.0)
  @objc public func advanced(by n: SchedulerTimeTypeWrapper1.StrideWrapper) -> SchedulerTimeTypeWrapper1 {
    let result = wrappedInstance.advanced(by: n.wrappedInstance)
    return SchedulerTimeTypeWrapper1(result)
  }

  @available(macOS, introduced: 10.15)
  @available(watchOS, introduced: 6.0)
  @available(iOS, introduced: 13.0)
  @available(tvOS, introduced: 13.0)
  @objc public func distance(to other: SchedulerTimeTypeWrapper1) -> SchedulerTimeTypeWrapper1.StrideWrapper {
    let result = wrappedInstance.distance(to: other.wrappedInstance)
    return StrideWrapper(result)
  }

  @available(macOS, introduced: 10.15)
  @available(watchOS, introduced: 6.0)
  @available(iOS, introduced: 13.0)
  @available(tvOS, introduced: 13.0)
  @objc public class StrideWrapper: NSObject {
    var wrappedInstance: SchedulerTimeType.Stride

    @available(macOS, introduced: 10.15)
    @available(watchOS, introduced: 6.0)
    @available(iOS, introduced: 13.0)
    @available(tvOS, introduced: 13.0)
    @objc public var timeInterval: TimeInterval {
      get {
        wrappedInstance.timeInterval
      }
    }

    @available(macOS, introduced: 10.15)
    @available(watchOS, introduced: 6.0)
    @available(iOS, introduced: 13.0)
    @available(tvOS, introduced: 13.0)
    @objc public var magnitude: TimeInterval {
      get {
        wrappedInstance.magnitude
      }
      set {
        wrappedInstance.magnitude = newValue
      }
    }

    init(_ wrappedInstance: SchedulerTimeType.Stride) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 10.15)
    @available(watchOS, introduced: 6.0)
    @available(iOS, introduced: 13.0)
    @available(tvOS, introduced: 13.0)
    @objc init(floatLiteral value: TimeInterval) {
      wrappedInstance = SchedulerTimeType.Stride(floatLiteral: value)
    }

    @available(macOS, introduced: 10.15)
    @available(watchOS, introduced: 6.0)
    @available(iOS, introduced: 13.0)
    @available(tvOS, introduced: 13.0)
    @objc init(integerLiteral value: TimeInterval) {
      wrappedInstance = SchedulerTimeType.Stride(integerLiteral: value)
    }

    @available(macOS, introduced: 10.15)
    @available(watchOS, introduced: 6.0)
    @available(iOS, introduced: 13.0)
    @available(tvOS, introduced: 13.0)
    @objc init(_ timeInterval: TimeInterval) {
      wrappedInstance = SchedulerTimeType.Stride(timeInterval)
    }

    @available(macOS, introduced: 10.15)
    @available(watchOS, introduced: 6.0)
    @available(iOS, introduced: 13.0)
    @available(tvOS, introduced: 13.0)
    @objc static public func nanoseconds(_ ns: Int) -> SchedulerTimeTypeWrapper1.StrideWrapper {
      let result = SchedulerTimeType.Stride.nanoseconds(ns)
      return StrideWrapper(result)
    }

    @available(macOS, introduced: 10.15)
    @available(watchOS, introduced: 6.0)
    @available(iOS, introduced: 13.0)
    @available(tvOS, introduced: 13.0)
    @objc static public func microseconds(_ us: Int) -> SchedulerTimeTypeWrapper1.StrideWrapper {
      let result = SchedulerTimeType.Stride.microseconds(us)
      return StrideWrapper(result)
    }

    @available(macOS, introduced: 10.15)
    @available(watchOS, introduced: 6.0)
    @available(iOS, introduced: 13.0)
    @available(tvOS, introduced: 13.0)
    @objc static public func milliseconds(_ ms: Int) -> SchedulerTimeTypeWrapper1.StrideWrapper {
      let result = SchedulerTimeType.Stride.milliseconds(ms)
      return StrideWrapper(result)
    }

    @available(macOS, introduced: 10.15)
    @available(watchOS, introduced: 6.0)
    @available(iOS, introduced: 13.0)
    @available(tvOS, introduced: 13.0)
    @objc static public func seconds(_ s: Int) -> SchedulerTimeTypeWrapper1.StrideWrapper {
      let result = SchedulerTimeType.Stride.seconds(s)
      return StrideWrapper(result)
    }

    @objc public func negate() {
      return wrappedInstance.negate()
    }

  }

}

@available(macOS, introduced: 12)
@available(watchOS, introduced: 8)
@available(iOS, introduced: 15)
@available(tvOS, introduced: 15)
@objc public class NotificationsWrapper: NSObject {
  var wrappedInstance: Notifications

  init(_ wrappedInstance: Notifications) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public func makeAsyncIterator() -> NotificationsWrapper.IteratorWrapper {
    let result = wrappedInstance.makeAsyncIterator()
    return IteratorWrapper(result)
  }

  @available(macOS, introduced: 12)
  @available(watchOS, introduced: 8)
  @available(iOS, introduced: 15)
  @available(tvOS, introduced: 15)
  @objc public class IteratorWrapper: NSObject {
    var wrappedInstance: Notifications.Iterator

    init(_ wrappedInstance: Notifications.Iterator) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 12)
    @available(watchOS, introduced: 8)
    @available(iOS, introduced: 15)
    @available(tvOS, introduced: 15)
    @objc public func next() async -> Notification? {
      return await wrappedInstance.next()
    }

  }

}

@available(macOS, introduced: 10.15)
@available(watchOS, introduced: 6.0)
@available(iOS, introduced: 13.0)
@available(tvOS, introduced: 13.0)
@objc public class PublisherWrapper: NSObject {
  var wrappedInstance: Publisher

  @available(macOS, introduced: 10.15)
  @available(watchOS, introduced: 6.0)
  @available(iOS, introduced: 13.0)
  @available(tvOS, introduced: 13.0)
  @objc public var name: NameWrapper {
    get {
      NameWrapper(wrappedInstance.name)
    }
  }

  @available(macOS, introduced: 10.15)
  @available(watchOS, introduced: 6.0)
  @available(iOS, introduced: 13.0)
  @available(tvOS, introduced: 13.0)
  @objc public var center: NotificationCenter {
    get {
      wrappedInstance.center
    }
  }

  init(_ wrappedInstance: Publisher) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 10.15)
@available(watchOS, introduced: 6.0)
@available(iOS, introduced: 13.0)
@available(tvOS, introduced: 13.0)
@objc public class TimerPublisherWrapper: NSObject {
  var wrappedInstance: TimerPublisher

  @available(macOS, introduced: 10.15)
  @available(watchOS, introduced: 6.0)
  @available(iOS, introduced: 13.0)
  @available(tvOS, introduced: 13.0)
  @objc public var mode: ModeWrapper {
    get {
      ModeWrapper(wrappedInstance.mode)
    }
  }

  @available(macOS, introduced: 10.15)
  @available(watchOS, introduced: 6.0)
  @available(iOS, introduced: 13.0)
  @available(tvOS, introduced: 13.0)
  @objc public var options: SchedulerOptionsWrapper? {
    get {
      wrappedInstance.options == nil ? nil : SchedulerOptionsWrapper(wrappedInstance.options!)
    }
  }

  @available(macOS, introduced: 10.15)
  @available(watchOS, introduced: 6.0)
  @available(iOS, introduced: 13.0)
  @available(tvOS, introduced: 13.0)
  @objc public var runLoop: RunLoop {
    get {
      wrappedInstance.runLoop
    }
  }

  @available(macOS, introduced: 10.15)
  @available(watchOS, introduced: 6.0)
  @available(iOS, introduced: 13.0)
  @available(tvOS, introduced: 13.0)
  @objc public var interval: TimeInterval {
    get {
      wrappedInstance.interval
    }
  }

  @available(macOS, introduced: 10.15)
  @available(watchOS, introduced: 6.0)
  @available(iOS, introduced: 13.0)
  @available(tvOS, introduced: 13.0)
  @objc public var tolerance: TimeInterval? {
    get {
      wrappedInstance.tolerance
    }
  }

  init(_ wrappedInstance: TimerPublisher) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 10.15)
@available(watchOS, introduced: 6.0)
@available(iOS, introduced: 13.0)
@available(tvOS, introduced: 13.0)
@objc public class SchedulerOptionsWrapper: NSObject {
  var wrappedInstance: SchedulerOptions

  init(_ wrappedInstance: SchedulerOptions) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 10.15)
@available(watchOS, introduced: 6.0)
@available(iOS, introduced: 13.0)
@available(tvOS, introduced: 13.0)
@objc public class SchedulerTimeTypeWrapper: NSObject {
  var wrappedInstance: SchedulerTimeType

  @available(macOS, introduced: 10.15)
  @available(watchOS, introduced: 6.0)
  @available(iOS, introduced: 13.0)
  @available(tvOS, introduced: 13.0)
  @objc public var date: Date {
    get {
      wrappedInstance.date
    }
    set {
      wrappedInstance.date = newValue
    }
  }

  init(_ wrappedInstance: SchedulerTimeType) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.15)
  @available(watchOS, introduced: 6.0)
  @available(iOS, introduced: 13.0)
  @available(tvOS, introduced: 13.0)
  @objc init(_ date: Date) {
    wrappedInstance = SchedulerTimeType(date)
  }

  @available(macOS, introduced: 10.15)
  @available(watchOS, introduced: 6.0)
  @available(iOS, introduced: 13.0)
  @available(tvOS, introduced: 13.0)
  @objc public func advanced(by n: SchedulerTimeTypeWrapper.StrideWrapper) -> SchedulerTimeTypeWrapper {
    let result = wrappedInstance.advanced(by: n.wrappedInstance)
    return SchedulerTimeTypeWrapper(result)
  }

  @available(macOS, introduced: 10.15)
  @available(watchOS, introduced: 6.0)
  @available(iOS, introduced: 13.0)
  @available(tvOS, introduced: 13.0)
  @objc public func distance(to other: SchedulerTimeTypeWrapper) -> SchedulerTimeTypeWrapper.StrideWrapper {
    let result = wrappedInstance.distance(to: other.wrappedInstance)
    return StrideWrapper(result)
  }

  @available(macOS, introduced: 10.15)
  @available(watchOS, introduced: 6.0)
  @available(iOS, introduced: 13.0)
  @available(tvOS, introduced: 13.0)
  @objc public class StrideWrapper: NSObject {
    var wrappedInstance: SchedulerTimeType.Stride

    @available(macOS, introduced: 10.15)
    @available(watchOS, introduced: 6.0)
    @available(iOS, introduced: 13.0)
    @available(tvOS, introduced: 13.0)
    @objc public var timeInterval: TimeInterval {
      get {
        wrappedInstance.timeInterval
      }
    }

    @available(macOS, introduced: 10.15)
    @available(watchOS, introduced: 6.0)
    @available(iOS, introduced: 13.0)
    @available(tvOS, introduced: 13.0)
    @objc public var magnitude: TimeInterval {
      get {
        wrappedInstance.magnitude
      }
      set {
        wrappedInstance.magnitude = newValue
      }
    }

    init(_ wrappedInstance: SchedulerTimeType.Stride) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 10.15)
    @available(watchOS, introduced: 6.0)
    @available(iOS, introduced: 13.0)
    @available(tvOS, introduced: 13.0)
    @objc init(floatLiteral value: TimeInterval) {
      wrappedInstance = SchedulerTimeType.Stride(floatLiteral: value)
    }

    @available(macOS, introduced: 10.15)
    @available(watchOS, introduced: 6.0)
    @available(iOS, introduced: 13.0)
    @available(tvOS, introduced: 13.0)
    @objc init(integerLiteral value: TimeInterval) {
      wrappedInstance = SchedulerTimeType.Stride(integerLiteral: value)
    }

    @available(macOS, introduced: 10.15)
    @available(watchOS, introduced: 6.0)
    @available(iOS, introduced: 13.0)
    @available(tvOS, introduced: 13.0)
    @objc init(_ timeInterval: TimeInterval) {
      wrappedInstance = SchedulerTimeType.Stride(timeInterval)
    }

    @available(macOS, introduced: 10.15)
    @available(watchOS, introduced: 6.0)
    @available(iOS, introduced: 13.0)
    @available(tvOS, introduced: 13.0)
    @objc static public func nanoseconds(_ ns: Int) -> SchedulerTimeTypeWrapper.StrideWrapper {
      let result = SchedulerTimeType.Stride.nanoseconds(ns)
      return StrideWrapper(result)
    }

    @available(macOS, introduced: 10.15)
    @available(watchOS, introduced: 6.0)
    @available(iOS, introduced: 13.0)
    @available(tvOS, introduced: 13.0)
    @objc static public func microseconds(_ us: Int) -> SchedulerTimeTypeWrapper.StrideWrapper {
      let result = SchedulerTimeType.Stride.microseconds(us)
      return StrideWrapper(result)
    }

    @available(macOS, introduced: 10.15)
    @available(watchOS, introduced: 6.0)
    @available(iOS, introduced: 13.0)
    @available(tvOS, introduced: 13.0)
    @objc static public func milliseconds(_ ms: Int) -> SchedulerTimeTypeWrapper.StrideWrapper {
      let result = SchedulerTimeType.Stride.milliseconds(ms)
      return StrideWrapper(result)
    }

    @available(macOS, introduced: 10.15)
    @available(watchOS, introduced: 6.0)
    @available(iOS, introduced: 13.0)
    @available(tvOS, introduced: 13.0)
    @objc static public func seconds(_ s: Double) -> SchedulerTimeTypeWrapper.StrideWrapper {
      let result = SchedulerTimeType.Stride.seconds(s)
      return StrideWrapper(result)
    }

    @objc public func negate() {
      return wrappedInstance.negate()
    }

  }

}

