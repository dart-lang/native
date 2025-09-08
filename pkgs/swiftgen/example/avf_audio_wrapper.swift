
import AVFAudio
import Foundation

// This wrapper is a stub. To generate the full wrapper, add AVAudioFormat
// to your config's include function.
@available(macOS, introduced: 10.10)
@objc public class AVAudioFormatWrapper: NSObject {
  var wrappedInstance: AVAudioFormat

  init(_ wrappedInstance: AVAudioFormat) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 10.7)
@objc public class AVAudioPlayerWrapper: NSObject {
  var wrappedInstance: AVAudioPlayer

  @available(macOS, introduced: 10.13)
  @objc public var currentDevice: String? {
    get {
      wrappedInstance.currentDevice
    }
    set {
      wrappedInstance.currentDevice = newValue
    }
  }

  @available(macOS, introduced: 10.7)
  @objc public var currentTime: TimeInterval {
    get {
      wrappedInstance.currentTime
    }
    set {
      wrappedInstance.currentTime = newValue
    }
  }

  @available(macOS, introduced: 10.7)
  @objc public var data: Data? {
    get {
      wrappedInstance.data
    }
  }

  @available(macOS, introduced: 10.7)
  @objc public var deviceCurrentTime: TimeInterval {
    get {
      wrappedInstance.deviceCurrentTime
    }
  }

  @available(macOS, introduced: 10.7)
  @objc public var duration: TimeInterval {
    get {
      wrappedInstance.duration
    }
  }

  @available(macOS, introduced: 10.8)
  @objc public var enableRate: Bool {
    get {
      wrappedInstance.enableRate
    }
    set {
      wrappedInstance.enableRate = newValue
    }
  }

  @available(macOS, introduced: 10.12)
  @objc public var format: AVAudioFormatWrapper {
    get {
      AVAudioFormatWrapper(wrappedInstance.format)
    }
  }

  @available(macOS, introduced: 10.7)
  @objc public var isMeteringEnabled: Bool {
    get {
      wrappedInstance.isMeteringEnabled
    }
    set {
      wrappedInstance.isMeteringEnabled = newValue
    }
  }

  @available(macOS, introduced: 10.7)
  @objc public var numberOfChannels: Int {
    get {
      wrappedInstance.numberOfChannels
    }
  }

  @available(macOS, introduced: 10.7)
  @objc public var numberOfLoops: Int {
    get {
      wrappedInstance.numberOfLoops
    }
    set {
      wrappedInstance.numberOfLoops = newValue
    }
  }

  @available(macOS, introduced: 10.7)
  @objc public var pan: Float {
    get {
      wrappedInstance.pan
    }
    set {
      wrappedInstance.pan = newValue
    }
  }

  @available(macOS, introduced: 10.7)
  @objc public var isPlaying: Bool {
    get {
      wrappedInstance.isPlaying
    }
  }

  @available(macOS, introduced: 10.8)
  @objc public var rate: Float {
    get {
      wrappedInstance.rate
    }
    set {
      wrappedInstance.rate = newValue
    }
  }

  @available(macOS, introduced: 10.7)
  @objc public var url: URL? {
    get {
      wrappedInstance.url
    }
  }

  @available(macOS, introduced: 10.7)
  @objc public var volume: Float {
    get {
      wrappedInstance.volume
    }
    set {
      wrappedInstance.volume = newValue
    }
  }

  init(_ wrappedInstance: AVAudioPlayer) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.7)
  @objc init(contentsOf url: URL) throws {
    wrappedInstance = try AVAudioPlayer(contentsOf: url)
  }

  @available(macOS, introduced: 10.9)
  @objc init(contentsOf url: URL, fileTypeHint utiString: String?) throws {
    wrappedInstance = try AVAudioPlayer(contentsOf: url, fileTypeHint: utiString)
  }

  @available(macOS, introduced: 10.7)
  @objc init(data: Data) throws {
    wrappedInstance = try AVAudioPlayer(data: data)
  }

  @available(macOS, introduced: 10.9)
  @objc init(data: Data, fileTypeHint utiString: String?) throws {
    wrappedInstance = try AVAudioPlayer(data: data, fileTypeHint: utiString)
  }

  @available(macOS, introduced: 10.7)
  @objc public func averagePower(forChannel channelNumber: Int) -> Float {
    return wrappedInstance.averagePower(forChannel: channelNumber)
  }

  @available(macOS, introduced: 10.7)
  @objc public func pause() {
    return wrappedInstance.pause()
  }

  @available(macOS, introduced: 10.7)
  @objc public func peakPower(forChannel channelNumber: Int) -> Float {
    return wrappedInstance.peakPower(forChannel: channelNumber)
  }

  @available(macOS, introduced: 10.7)
  @objc public func play() -> Bool {
    return wrappedInstance.play()
  }

  @available(macOS, introduced: 10.7)
  @objc public func play(atTime time: TimeInterval) -> Bool {
    return wrappedInstance.play(atTime: time)
  }

  @available(macOS, introduced: 10.7)
  @objc public func prepareToPlay() -> Bool {
    return wrappedInstance.prepareToPlay()
  }

  @available(macOS, introduced: 10.12)
  @objc public func setVolume(_ volume: Float, fadeDuration duration: TimeInterval) {
    return wrappedInstance.setVolume(volume, fadeDuration: duration)
  }

  @available(macOS, introduced: 10.7)
  @objc public func stop() {
    return wrappedInstance.stop()
  }

  @available(macOS, introduced: 10.7)
  @objc public func updateMeters() {
    return wrappedInstance.updateMeters()
  }

}

