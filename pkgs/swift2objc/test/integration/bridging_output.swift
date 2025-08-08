// Test preamble text

import Foundation

@objc public class GlobalsWrapper: NSObject {
  @objc static public func funcLocaleWrapper() -> Locale? {
    return funcLocale()
  }

  @objc static public func funcStringWrapper() -> String? {
    return funcString()
  }

  @objc static public func funcNSErrorWrapper() -> NSError? {
    return funcNSError()
  }

  @objc static public func funcCalendarWrapper() -> Calendar? {
    return funcCalendar()
  }

  @objc static public func funcIndexSetWrapper() -> IndexSet? {
    return funcIndexSet()
  }

  @objc static public func funcTimeZoneWrapper() -> TimeZone? {
    return funcTimeZone()
  }

  @objc static public func funcIndexPathWrapper() -> IndexPath? {
    return funcIndexPath()
  }

  @objc static public func funcURLRequestWrapper() -> URLRequest? {
    return funcURLRequest()
  }

  @objc static public func funcCharacterSetWrapper() -> CharacterSet? {
    return funcCharacterSet()
  }

  @objc static public func funcDateIntervalWrapper() -> DateInterval? {
    return funcDateInterval()
  }

  @objc static public func funcNotificationWrapper() -> Notification? {
    return funcNotification()
  }

  @objc static public func funcURLQueryItemWrapper() -> URLQueryItem? {
    return funcURLQueryItem()
  }

  @objc static public func funcURLComponentsWrapper() -> URLComponents? {
    return funcURLComponents()
  }

  @objc static public func funcDateComponentsWrapper() -> DateComponents? {
    return funcDateComponents()
  }

  @objc static public func funcAffineTransformWrapper() -> AffineTransform? {
    return funcAffineTransform()
  }

  @objc static public func funcURLWrapper() -> URL? {
    return funcURL()
  }

  @objc static public func funcDataWrapper() -> Data? {
    return funcData()
  }

  @objc static public func funcDateWrapper() -> Date? {
    return funcDate()
  }

  @objc static public func funcUUIDWrapper() -> UUID? {
    return funcUUID()
  }

}

