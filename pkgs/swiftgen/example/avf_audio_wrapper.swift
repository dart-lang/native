
import AVFAudio
import Foundation

@objc public class AVAudioPlayerNodeBufferOptionsWrapper: NSObject {
  var wrappedInstance: AVAudioPlayerNodeBufferOptions

  @objc static public var interrupts: AVAudioPlayerNodeBufferOptionsWrapper {
    get {
      AVAudioPlayerNodeBufferOptionsWrapper(AVAudioPlayerNodeBufferOptions.interrupts)
    }
  }

  @objc static public var interruptsAtLoop: AVAudioPlayerNodeBufferOptionsWrapper {
    get {
      AVAudioPlayerNodeBufferOptionsWrapper(AVAudioPlayerNodeBufferOptions.interruptsAtLoop)
    }
  }

  @objc static public var loops: AVAudioPlayerNodeBufferOptionsWrapper {
    get {
      AVAudioPlayerNodeBufferOptionsWrapper(AVAudioPlayerNodeBufferOptions.loops)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: AVAudioPlayerNodeBufferOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = AVAudioPlayerNodeBufferOptions()
  }

}

@objc public class AVAudioSessionActivationOptionsWrapper: NSObject {
  var wrappedInstance: AVAudioSessionActivationOptions

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: AVAudioSessionActivationOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = AVAudioSessionActivationOptions()
  }

}

@objc public class AVMusicSequenceLoadOptionsWrapper: NSObject {
  var wrappedInstance: AVMusicSequenceLoadOptions

  @objc static public var smf_ChannelsToTracks: AVMusicSequenceLoadOptionsWrapper {
    get {
      AVMusicSequenceLoadOptionsWrapper(AVMusicSequenceLoadOptions.smf_ChannelsToTracks)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: AVMusicSequenceLoadOptions) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = AVMusicSequenceLoadOptions()
  }

}

@available(macOS, introduced: 14.0)
@objc public class TraitsWrapper: NSObject {
  var wrappedInstance: Traits

  @available(macOS, introduced: 14.0)
  @objc static public var isNoveltyVoice: TraitsWrapper {
    get {
      TraitsWrapper(Traits.isNoveltyVoice)
    }
  }

  @available(macOS, introduced: 14.0)
  @objc static public var isPersonalVoice: TraitsWrapper {
    get {
      TraitsWrapper(Traits.isPersonalVoice)
    }
  }

  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }

  init(_ wrappedInstance: Traits) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = Traits()
  }

}

@objc public class AVAudio3DAngularOrientationWrapper: NSObject {
  var wrappedInstance: AVAudio3DAngularOrientation

  @objc public var pitch: Float {
    get {
      wrappedInstance.pitch
    }
    set {
      wrappedInstance.pitch = newValue
    }
  }

  @objc public var roll: Float {
    get {
      wrappedInstance.roll
    }
    set {
      wrappedInstance.roll = newValue
    }
  }

  @objc public var yaw: Float {
    get {
      wrappedInstance.yaw
    }
    set {
      wrappedInstance.yaw = newValue
    }
  }

  init(_ wrappedInstance: AVAudio3DAngularOrientation) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(yaw: Float, pitch: Float, roll: Float) {
    wrappedInstance = AVAudio3DAngularOrientation(yaw: yaw, pitch: pitch, roll: roll)
  }

  @objc override init() {
    wrappedInstance = AVAudio3DAngularOrientation()
  }

}

@objc public class AVAudio3DPointWrapper: NSObject {
  var wrappedInstance: AVAudio3DPoint

  @objc public var x: Float {
    get {
      wrappedInstance.x
    }
    set {
      wrappedInstance.x = newValue
    }
  }

  @objc public var y: Float {
    get {
      wrappedInstance.y
    }
    set {
      wrappedInstance.y = newValue
    }
  }

  @objc public var z: Float {
    get {
      wrappedInstance.z
    }
    set {
      wrappedInstance.z = newValue
    }
  }

  init(_ wrappedInstance: AVAudio3DPoint) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(x: Float, y: Float, z: Float) {
    wrappedInstance = AVAudio3DPoint(x: x, y: y, z: z)
  }

  @objc override init() {
    wrappedInstance = AVAudio3DPoint()
  }

}

@objc public class AVAudio3DVectorOrientationWrapper: NSObject {
  var wrappedInstance: AVAudio3DVectorOrientation

  @objc public var forward: AVAudio3DPointWrapper {
    get {
      AVAudio3DPointWrapper(wrappedInstance.forward)
    }
    set {
      wrappedInstance.forward = newValue.wrappedInstance
    }
  }

  @objc public var up: AVAudio3DPointWrapper {
    get {
      AVAudio3DPointWrapper(wrappedInstance.up)
    }
    set {
      wrappedInstance.up = newValue.wrappedInstance
    }
  }

  init(_ wrappedInstance: AVAudio3DVectorOrientation) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(forward: AVAudio3DPointWrapper, up: AVAudio3DPointWrapper) {
    wrappedInstance = AVAudio3DVectorOrientation(forward: forward.wrappedInstance, up: up.wrappedInstance)
  }

  @objc override init() {
    wrappedInstance = AVAudio3DVectorOrientation()
  }

}

@objc public class AVAudioConverterPrimeInfoWrapper: NSObject {
  var wrappedInstance: AVAudioConverterPrimeInfo

  init(_ wrappedInstance: AVAudioConverterPrimeInfo) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = AVAudioConverterPrimeInfo()
  }

}

@available(macOS, introduced: 14.0)
@objc public class AVAudioVoiceProcessingOtherAudioDuckingConfigurationWrapper: NSObject {
  var wrappedInstance: AVAudioVoiceProcessingOtherAudioDuckingConfiguration

  init(_ wrappedInstance: AVAudioVoiceProcessingOtherAudioDuckingConfiguration) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 14.0)
  @objc override init() {
    wrappedInstance = AVAudioVoiceProcessingOtherAudioDuckingConfiguration()
  }

}

@available(macOS, introduced: 13.0)
@objc public class InfoDictionaryKeyWrapper: NSObject {
  var wrappedInstance: InfoDictionaryKey

  @available(macOS, introduced: 13.0)
  @objc static public var album: InfoDictionaryKeyWrapper {
    get {
      InfoDictionaryKeyWrapper(InfoDictionaryKey.album)
    }
  }

  @available(macOS, introduced: 13.0)
  @objc static public var approximateDurationInSeconds: InfoDictionaryKeyWrapper {
    get {
      InfoDictionaryKeyWrapper(InfoDictionaryKey.approximateDurationInSeconds)
    }
  }

  @available(macOS, introduced: 13.0)
  @objc static public var artist: InfoDictionaryKeyWrapper {
    get {
      InfoDictionaryKeyWrapper(InfoDictionaryKey.artist)
    }
  }

  @available(macOS, introduced: 13.0)
  @objc static public var channelLayout: InfoDictionaryKeyWrapper {
    get {
      InfoDictionaryKeyWrapper(InfoDictionaryKey.channelLayout)
    }
  }

  @available(macOS, introduced: 13.0)
  @objc static public var comments: InfoDictionaryKeyWrapper {
    get {
      InfoDictionaryKeyWrapper(InfoDictionaryKey.comments)
    }
  }

  @available(macOS, introduced: 13.0)
  @objc static public var composer: InfoDictionaryKeyWrapper {
    get {
      InfoDictionaryKeyWrapper(InfoDictionaryKey.composer)
    }
  }

  @available(macOS, introduced: 13.0)
  @objc static public var copyright: InfoDictionaryKeyWrapper {
    get {
      InfoDictionaryKeyWrapper(InfoDictionaryKey.copyright)
    }
  }

  @available(macOS, introduced: 13.0)
  @objc static public var encodingApplication: InfoDictionaryKeyWrapper {
    get {
      InfoDictionaryKeyWrapper(InfoDictionaryKey.encodingApplication)
    }
  }

  @available(macOS, introduced: 13.0)
  @objc static public var genre: InfoDictionaryKeyWrapper {
    get {
      InfoDictionaryKeyWrapper(InfoDictionaryKey.genre)
    }
  }

  @available(macOS, introduced: 13.0)
  @objc static public var ISRC: InfoDictionaryKeyWrapper {
    get {
      InfoDictionaryKeyWrapper(InfoDictionaryKey.ISRC)
    }
  }

  @available(macOS, introduced: 13.0)
  @objc static public var keySignature: InfoDictionaryKeyWrapper {
    get {
      InfoDictionaryKeyWrapper(InfoDictionaryKey.keySignature)
    }
  }

  @available(macOS, introduced: 13.0)
  @objc static public var lyricist: InfoDictionaryKeyWrapper {
    get {
      InfoDictionaryKeyWrapper(InfoDictionaryKey.lyricist)
    }
  }

  @available(macOS, introduced: 13.0)
  @objc static public var nominalBitRate: InfoDictionaryKeyWrapper {
    get {
      InfoDictionaryKeyWrapper(InfoDictionaryKey.nominalBitRate)
    }
  }

  @available(macOS, introduced: 13.0)
  @objc static public var recordedDate: InfoDictionaryKeyWrapper {
    get {
      InfoDictionaryKeyWrapper(InfoDictionaryKey.recordedDate)
    }
  }

  @available(macOS, introduced: 13.0)
  @objc static public var sourceBitDepth: InfoDictionaryKeyWrapper {
    get {
      InfoDictionaryKeyWrapper(InfoDictionaryKey.sourceBitDepth)
    }
  }

  @available(macOS, introduced: 13.0)
  @objc static public var sourceEncoder: InfoDictionaryKeyWrapper {
    get {
      InfoDictionaryKeyWrapper(InfoDictionaryKey.sourceEncoder)
    }
  }

  @available(macOS, introduced: 13.0)
  @objc static public var subTitle: InfoDictionaryKeyWrapper {
    get {
      InfoDictionaryKeyWrapper(InfoDictionaryKey.subTitle)
    }
  }

  @available(macOS, introduced: 13.0)
  @objc static public var tempo: InfoDictionaryKeyWrapper {
    get {
      InfoDictionaryKeyWrapper(InfoDictionaryKey.tempo)
    }
  }

  @available(macOS, introduced: 13.0)
  @objc static public var timeSignature: InfoDictionaryKeyWrapper {
    get {
      InfoDictionaryKeyWrapper(InfoDictionaryKey.timeSignature)
    }
  }

  @available(macOS, introduced: 13.0)
  @objc static public var title: InfoDictionaryKeyWrapper {
    get {
      InfoDictionaryKeyWrapper(InfoDictionaryKey.title)
    }
  }

  @available(macOS, introduced: 13.0)
  @objc static public var trackNumber: InfoDictionaryKeyWrapper {
    get {
      InfoDictionaryKeyWrapper(InfoDictionaryKey.trackNumber)
    }
  }

  @available(macOS, introduced: 13.0)
  @objc static public var year: InfoDictionaryKeyWrapper {
    get {
      InfoDictionaryKeyWrapper(InfoDictionaryKey.year)
    }
  }

  init(_ wrappedInstance: InfoDictionaryKey) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 13.0)
  @objc init(rawValue: String) {
    wrappedInstance = InfoDictionaryKey(rawValue: rawValue)
  }

}

@objc public class GlobalsWrapper: NSObject {
  @available(macOS, introduced: 10.9)
  @objc static public var AVAudioBitRateStrategy_ConstantWrapper: String {
    get {
      AVAudioBitRateStrategy_Constant
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var AVAudioBitRateStrategy_LongTermAverageWrapper: String {
    get {
      AVAudioBitRateStrategy_LongTermAverage
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var AVAudioBitRateStrategy_VariableWrapper: String {
    get {
      AVAudioBitRateStrategy_Variable
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var AVAudioBitRateStrategy_VariableConstrainedWrapper: String {
    get {
      AVAudioBitRateStrategy_VariableConstrained
    }
  }

  @available(macOS, introduced: 10.13)
  @objc static public var AVAudioFileTypeKeyWrapper: String {
    get {
      AVAudioFileTypeKey
    }
  }

  @objc static public var AVAudioSessionInterruptionWasSuspendedKeyWrapper: String {
    get {
      AVAudioSessionInterruptionWasSuspendedKey
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var AVAudioUnitManufacturerNameAppleWrapper: String {
    get {
      AVAudioUnitManufacturerNameApple
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var AVAudioUnitTypeEffectWrapper: String {
    get {
      AVAudioUnitTypeEffect
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var AVAudioUnitTypeFormatConverterWrapper: String {
    get {
      AVAudioUnitTypeFormatConverter
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var AVAudioUnitTypeGeneratorWrapper: String {
    get {
      AVAudioUnitTypeGenerator
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var AVAudioUnitTypeMIDIProcessorWrapper: String {
    get {
      AVAudioUnitTypeMIDIProcessor
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var AVAudioUnitTypeMixerWrapper: String {
    get {
      AVAudioUnitTypeMixer
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var AVAudioUnitTypeMusicDeviceWrapper: String {
    get {
      AVAudioUnitTypeMusicDevice
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var AVAudioUnitTypeMusicEffectWrapper: String {
    get {
      AVAudioUnitTypeMusicEffect
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var AVAudioUnitTypeOfflineEffectWrapper: String {
    get {
      AVAudioUnitTypeOfflineEffect
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var AVAudioUnitTypeOutputWrapper: String {
    get {
      AVAudioUnitTypeOutput
    }
  }

  @available(macOS, introduced: 10.10)
  @objc static public var AVAudioUnitTypePannerWrapper: String {
    get {
      AVAudioUnitTypePanner
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var AVChannelLayoutKeyWrapper: String {
    get {
      AVChannelLayoutKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var AVEncoderAudioQualityForVBRKeyWrapper: String {
    get {
      AVEncoderAudioQualityForVBRKey
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var AVEncoderAudioQualityKeyWrapper: String {
    get {
      AVEncoderAudioQualityKey
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var AVEncoderBitDepthHintKeyWrapper: String {
    get {
      AVEncoderBitDepthHintKey
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var AVEncoderBitRateKeyWrapper: String {
    get {
      AVEncoderBitRateKey
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var AVEncoderBitRatePerChannelKeyWrapper: String {
    get {
      AVEncoderBitRatePerChannelKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var AVEncoderBitRateStrategyKeyWrapper: String {
    get {
      AVEncoderBitRateStrategyKey
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var AVFormatIDKeyWrapper: String {
    get {
      AVFormatIDKey
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var AVLinearPCMBitDepthKeyWrapper: String {
    get {
      AVLinearPCMBitDepthKey
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var AVLinearPCMIsBigEndianKeyWrapper: String {
    get {
      AVLinearPCMIsBigEndianKey
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var AVLinearPCMIsFloatKeyWrapper: String {
    get {
      AVLinearPCMIsFloatKey
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var AVLinearPCMIsNonInterleavedWrapper: String {
    get {
      AVLinearPCMIsNonInterleaved
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var AVNumberOfChannelsKeyWrapper: String {
    get {
      AVNumberOfChannelsKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var AVSampleRateConverterAlgorithmKeyWrapper: String {
    get {
      AVSampleRateConverterAlgorithmKey
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var AVSampleRateConverterAlgorithm_MasteringWrapper: String {
    get {
      AVSampleRateConverterAlgorithm_Mastering
    }
  }

  @available(macOS, introduced: 10.12)
  @objc static public var AVSampleRateConverterAlgorithm_MinimumPhaseWrapper: String {
    get {
      AVSampleRateConverterAlgorithm_MinimumPhase
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var AVSampleRateConverterAlgorithm_NormalWrapper: String {
    get {
      AVSampleRateConverterAlgorithm_Normal
    }
  }

  @available(macOS, introduced: 10.9)
  @objc static public var AVSampleRateConverterAudioQualityKeyWrapper: String {
    get {
      AVSampleRateConverterAudioQualityKey
    }
  }

  @available(macOS, introduced: 10.7)
  @objc static public var AVSampleRateKeyWrapper: String {
    get {
      AVSampleRateKey
    }
  }

  @available(macOS, introduced: 10.14)
  @objc static public var AVSpeechSynthesisIPANotationAttributeWrapper: String {
    get {
      AVSpeechSynthesisIPANotationAttribute
    }
  }

  @available(macOS, introduced: 10.14)
  @objc static public var AVSpeechSynthesisVoiceIdentifierAlexWrapper: String {
    get {
      AVSpeechSynthesisVoiceIdentifierAlex
    }
  }

  @available(macOS, introduced: 10.14)
  @objc static public var AVSpeechUtteranceDefaultSpeechRateWrapper: Float {
    get {
      AVSpeechUtteranceDefaultSpeechRate
    }
  }

  @available(macOS, introduced: 10.14)
  @objc static public var AVSpeechUtteranceMaximumSpeechRateWrapper: Float {
    get {
      AVSpeechUtteranceMaximumSpeechRate
    }
  }

  @available(macOS, introduced: 10.14)
  @objc static public var AVSpeechUtteranceMinimumSpeechRateWrapper: Float {
    get {
      AVSpeechUtteranceMinimumSpeechRate
    }
  }

  @objc static public var AVMusicTimeStampEndOfTrackWrapper: Double {
    get {
      AVMusicTimeStampEndOfTrack
    }
  }

  @objc static public func AVAudioMake3DAngularOrientationWrapper(_ yaw: Float, _ pitch: Float, _ roll: Float) -> AVAudio3DAngularOrientationWrapper {
    let result = AVAudioMake3DAngularOrientation(yaw, pitch, roll)
    return AVAudio3DAngularOrientationWrapper(result)
  }

  @objc static public func AVAudioMake3DPointWrapper(_ x: Float, _ y: Float, _ z: Float) -> AVAudio3DPointWrapper {
    let result = AVAudioMake3DPoint(x, y, z)
    return AVAudio3DPointWrapper(result)
  }

  @objc static public func AVAudioMake3DVectorWrapper(_ x: Float, _ y: Float, _ z: Float) -> AVAudio3DPointWrapper {
    let result = AVAudioMake3DVector(x, y, z)
    return AVAudio3DPointWrapper(result)
  }

  @objc static public func AVAudioMake3DVectorOrientationWrapper(_ forward: AVAudio3DPointWrapper, _ up: AVAudio3DPointWrapper) -> AVAudio3DVectorOrientationWrapper {
    let result = AVAudioMake3DVectorOrientation(forward.wrappedInstance, up.wrappedInstance)
    return AVAudio3DVectorOrientationWrapper(result)
  }

}

