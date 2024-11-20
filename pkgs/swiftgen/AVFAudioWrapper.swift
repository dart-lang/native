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

@objc public class TraitsWrapper: NSObject {
  var wrappedInstance: AVSpeechSynthesisVoice.Traits
  
  @objc static public var isNoveltyVoice: AVSpeechSynthesisVoiceWrapper {
    get {
      AVSpeechSynthesisVoiceWrapper(AVSpeechSynthesisVoice.Traits.isNoveltyVoice)
    }
  }
  
  @objc static public var isPersonalVoice: AVSpeechSynthesisVoiceWrapper {
    get {
      AVSpeechSynthesisVoiceWrapper(AVSpeechSynthesisVoice.Traits.isPersonalVoice)
    }
  }
  
  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }
  
  init(_ wrappedInstance: AVSpeechSynthesisVoice.Traits) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVSpeechSynthesisVoice.Traits()
  }
}

@objc public class AVAudio3DAngularOrientationWrapper: NSObject {
  var wrappedInstance: AVAudio3DAngularOrientation
  
  init(_ wrappedInstance: AVAudio3DAngularOrientation) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVAudio3DAngularOrientation()
  }
}

@objc public class AVAudio3DPointWrapper: NSObject {
  var wrappedInstance: AVAudio3DPoint
  
  init(_ wrappedInstance: AVAudio3DPoint) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVAudio3DPoint()
  }
}

@objc public class AVAudio3DVectorOrientationWrapper: NSObject {
  var wrappedInstance: AVAudio3DVectorOrientation
  
  init(_ wrappedInstance: AVAudio3DVectorOrientation) {
    self.wrappedInstance = wrappedInstance
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

@objc public class AVAudioVoiceProcessingOtherAudioDuckingConfigurationWrapper: NSObject {
  var wrappedInstance: AVAudioVoiceProcessingOtherAudioDuckingConfiguration
  
  @objc public var duckingLevel: AVAudioVoiceProcessingOtherAudioDuckingConfigurationWrapper {
    get {
      AVAudioVoiceProcessingOtherAudioDuckingConfigurationWrapper(wrappedInstance.duckingLevel)
    }
    set {
      wrappedInstance.duckingLevel = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVAudioVoiceProcessingOtherAudioDuckingConfiguration) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVAudioVoiceProcessingOtherAudioDuckingConfiguration()
  }
}

@objc public class InfoDictionaryKeyWrapper: NSObject {
  var wrappedInstance: AVAudioSequencer.InfoDictionaryKey
  
  @objc static public var album: AVAudioSequencerWrapper {
    get {
      AVAudioSequencerWrapper(AVAudioSequencer.InfoDictionaryKey.album)
    }
  }
  
  @objc static public var approximateDurationInSeconds: AVAudioSequencerWrapper {
    get {
      AVAudioSequencerWrapper(AVAudioSequencer.InfoDictionaryKey.approximateDurationInSeconds)
    }
  }
  
  @objc static public var artist: AVAudioSequencerWrapper {
    get {
      AVAudioSequencerWrapper(AVAudioSequencer.InfoDictionaryKey.artist)
    }
  }
  
  @objc static public var channelLayout: AVAudioSequencerWrapper {
    get {
      AVAudioSequencerWrapper(AVAudioSequencer.InfoDictionaryKey.channelLayout)
    }
  }
  
  @objc static public var comments: AVAudioSequencerWrapper {
    get {
      AVAudioSequencerWrapper(AVAudioSequencer.InfoDictionaryKey.comments)
    }
  }
  
  @objc static public var composer: AVAudioSequencerWrapper {
    get {
      AVAudioSequencerWrapper(AVAudioSequencer.InfoDictionaryKey.composer)
    }
  }
  
  @objc static public var copyright: AVAudioSequencerWrapper {
    get {
      AVAudioSequencerWrapper(AVAudioSequencer.InfoDictionaryKey.copyright)
    }
  }
  
  @objc static public var encodingApplication: AVAudioSequencerWrapper {
    get {
      AVAudioSequencerWrapper(AVAudioSequencer.InfoDictionaryKey.encodingApplication)
    }
  }
  
  @objc static public var genre: AVAudioSequencerWrapper {
    get {
      AVAudioSequencerWrapper(AVAudioSequencer.InfoDictionaryKey.genre)
    }
  }
  
  @objc static public var ISRC: AVAudioSequencerWrapper {
    get {
      AVAudioSequencerWrapper(AVAudioSequencer.InfoDictionaryKey.ISRC)
    }
  }
  
  @objc static public var keySignature: AVAudioSequencerWrapper {
    get {
      AVAudioSequencerWrapper(AVAudioSequencer.InfoDictionaryKey.keySignature)
    }
  }
  
  @objc static public var lyricist: AVAudioSequencerWrapper {
    get {
      AVAudioSequencerWrapper(AVAudioSequencer.InfoDictionaryKey.lyricist)
    }
  }
  
  @objc static public var nominalBitRate: AVAudioSequencerWrapper {
    get {
      AVAudioSequencerWrapper(AVAudioSequencer.InfoDictionaryKey.nominalBitRate)
    }
  }
  
  @objc static public var recordedDate: AVAudioSequencerWrapper {
    get {
      AVAudioSequencerWrapper(AVAudioSequencer.InfoDictionaryKey.recordedDate)
    }
  }
  
  @objc static public var sourceBitDepth: AVAudioSequencerWrapper {
    get {
      AVAudioSequencerWrapper(AVAudioSequencer.InfoDictionaryKey.sourceBitDepth)
    }
  }
  
  @objc static public var sourceEncoder: AVAudioSequencerWrapper {
    get {
      AVAudioSequencerWrapper(AVAudioSequencer.InfoDictionaryKey.sourceEncoder)
    }
  }
  
  @objc static public var subTitle: AVAudioSequencerWrapper {
    get {
      AVAudioSequencerWrapper(AVAudioSequencer.InfoDictionaryKey.subTitle)
    }
  }
  
  @objc static public var tempo: AVAudioSequencerWrapper {
    get {
      AVAudioSequencerWrapper(AVAudioSequencer.InfoDictionaryKey.tempo)
    }
  }
  
  @objc static public var timeSignature: AVAudioSequencerWrapper {
    get {
      AVAudioSequencerWrapper(AVAudioSequencer.InfoDictionaryKey.timeSignature)
    }
  }
  
  @objc static public var title: AVAudioSequencerWrapper {
    get {
      AVAudioSequencerWrapper(AVAudioSequencer.InfoDictionaryKey.title)
    }
  }
  
  @objc static public var trackNumber: AVAudioSequencerWrapper {
    get {
      AVAudioSequencerWrapper(AVAudioSequencer.InfoDictionaryKey.trackNumber)
    }
  }
  
  @objc static public var year: AVAudioSequencerWrapper {
    get {
      AVAudioSequencerWrapper(AVAudioSequencer.InfoDictionaryKey.year)
    }
  }
  
  init(_ wrappedInstance: AVAudioSequencer.InfoDictionaryKey) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVAudioSequencer.InfoDictionaryKey(rawValue: rawValue)
  }
}

@objc public class AVAUPresetEventWrapper: NSObject {
  var wrappedInstance: AVAUPresetEvent
  
  init(_ wrappedInstance: AVAUPresetEvent) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAudioApplicationWrapper: NSObject {
  var wrappedInstance: AVAudioApplication
  
  @objc static public var muteStateKey: String {
    get {
      AVAudioApplication.muteStateKey
    }
  }
  
  @objc static public var shared: AVAudioApplicationWrapper {
    get {
      AVAudioApplicationWrapper(AVAudioApplication.shared)
    }
  }
  
  @objc public var isInputMuted: Bool {
    get {
      wrappedInstance.isInputMuted
    }
  }
  
  @objc public var recordPermission: AVAudioApplicationWrapper {
    get {
      AVAudioApplicationWrapper(wrappedInstance.recordPermission)
    }
  }
  
  init(_ wrappedInstance: AVAudioApplication) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc static public func requestRecordPermission(completionHandler response: Bool) -> Void {
    return AVAudioApplication.requestRecordPermission(completionHandler: response)
  }
  
  @objc public func setInputMuteStateChangeHandler(inputMuteHandler: Bool) {
    wrappedInstance.setInputMuteStateChangeHandler(inputMuteHandler: inputMuteHandler)
  }
  
  @objc public func setInputMuted(muted: Bool) {
    wrappedInstance.setInputMuted(muted: muted)
  }
}

@objc public class AVAudioBufferWrapper: NSObject {
  var wrappedInstance: AVAudioBuffer
  
  @objc public var format: AVAudioFormatWrapper {
    get {
      AVAudioFormatWrapper(wrappedInstance.format)
    }
  }
  
  init(_ wrappedInstance: AVAudioBuffer) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAudioChannelLayoutWrapper: NSObject {
  var wrappedInstance: AVAudioChannelLayout
  
  init(_ wrappedInstance: AVAudioChannelLayout) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAudioCompressedBufferWrapper: NSObject {
  var wrappedInstance: AVAudioCompressedBuffer
  
  @objc public var maximumPacketSize: Int {
    get {
      wrappedInstance.maximumPacketSize
    }
  }
  
  init(_ wrappedInstance: AVAudioCompressedBuffer) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAudioConnectionPointWrapper: NSObject {
  var wrappedInstance: AVAudioConnectionPoint
  
  @objc public var node: AVAudioNodeWrapper {
    get {
      AVAudioNodeWrapper(wrappedInstance.node)
    }
  }
  
  init(_ wrappedInstance: AVAudioConnectionPoint) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAudioConverterWrapper: NSObject {
  var wrappedInstance: AVAudioConverter
  
  @objc public var bitRate: Int {
    get {
      wrappedInstance.bitRate
    }
    set {
      wrappedInstance.bitRate = newValue
    }
  }
  
  @objc public var bitRateStrategy: String {
    get {
      wrappedInstance.bitRateStrategy
    }
    set {
      wrappedInstance.bitRateStrategy = newValue
    }
  }
  
  @objc public var dither: Bool {
    get {
      wrappedInstance.dither
    }
    set {
      wrappedInstance.dither = newValue
    }
  }
  
  @objc public var downmix: Bool {
    get {
      wrappedInstance.downmix
    }
    set {
      wrappedInstance.downmix = newValue
    }
  }
  
  @objc public var inputFormat: AVAudioFormatWrapper {
    get {
      AVAudioFormatWrapper(wrappedInstance.inputFormat)
    }
  }
  
  @objc public var maximumOutputPacketSize: Int {
    get {
      wrappedInstance.maximumOutputPacketSize
    }
  }
  
  @objc public var outputFormat: AVAudioFormatWrapper {
    get {
      AVAudioFormatWrapper(wrappedInstance.outputFormat)
    }
  }
  
  @objc public var primeInfo: AVAudioConverterPrimeInfoWrapper {
    get {
      AVAudioConverterPrimeInfoWrapper(wrappedInstance.primeInfo)
    }
    set {
      wrappedInstance.primeInfo = newValue.wrappedInstance
    }
  }
  
  @objc public var sampleRateConverterAlgorithm: String {
    get {
      wrappedInstance.sampleRateConverterAlgorithm
    }
    set {
      wrappedInstance.sampleRateConverterAlgorithm = newValue
    }
  }
  
  @objc public var sampleRateConverterQuality: Int {
    get {
      wrappedInstance.sampleRateConverterQuality
    }
    set {
      wrappedInstance.sampleRateConverterQuality = newValue
    }
  }
  
  init(_ wrappedInstance: AVAudioConverter) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init?(from fromFormat: AVAudioFormatWrapper, to toFormat: AVAudioFormatWrapper) {
    if let instance = AVAudioConverter(from: fromFormat.wrappedInstance, to: toFormat.wrappedInstance) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }
  
  @objc public func convert(to outputBuffer: AVAudioPCMBufferWrapper, from inputBuffer: AVAudioPCMBufferWrapper) {
    wrappedInstance.convert(to: outputBuffer.wrappedInstance, from: inputBuffer.wrappedInstance)
  }
  
  @objc public func reset() -> Void {
    return wrappedInstance.reset()
  }
}

@objc public class AVAudioEngineWrapper: NSObject {
  var wrappedInstance: AVAudioEngine
  
  @objc public var isAutoShutdownEnabled: Bool {
    get {
      wrappedInstance.isAutoShutdownEnabled
    }
    set {
      wrappedInstance.isAutoShutdownEnabled = newValue
    }
  }
  
  @objc public var inputNode: AVAudioInputNodeWrapper {
    get {
      AVAudioInputNodeWrapper(wrappedInstance.inputNode)
    }
  }
  
  @objc public var isInManualRenderingMode: Bool {
    get {
      wrappedInstance.isInManualRenderingMode
    }
  }
  
  @objc public var mainMixerNode: AVAudioMixerNodeWrapper {
    get {
      AVAudioMixerNodeWrapper(wrappedInstance.mainMixerNode)
    }
  }
  
  @objc public var manualRenderingFormat: AVAudioFormatWrapper {
    get {
      AVAudioFormatWrapper(wrappedInstance.manualRenderingFormat)
    }
  }
  
  @objc public var outputNode: AVAudioOutputNodeWrapper {
    get {
      AVAudioOutputNodeWrapper(wrappedInstance.outputNode)
    }
  }
  
  @objc public var isRunning: Bool {
    get {
      wrappedInstance.isRunning
    }
  }
  
  init(_ wrappedInstance: AVAudioEngine) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVAudioEngine()
  }
  
  @objc public func attach(node: AVAudioNodeWrapper) -> Void {
    return wrappedInstance.attach(node: node.wrappedInstance)
  }
  
  @objc public func connect(node1: AVAudioNodeWrapper, to node2: AVAudioNodeWrapper, format: AVAudioFormatWrapper) -> Void {
    return wrappedInstance.connect(node1: node1.wrappedInstance, to: node2.wrappedInstance, format: format.wrappedInstance)
  }
  
  @objc public func detach(node: AVAudioNodeWrapper) -> Void {
    return wrappedInstance.detach(node: node.wrappedInstance)
  }
  
  @objc public func disableManualRenderingMode() -> Void {
    return wrappedInstance.disableManualRenderingMode()
  }
  
  @objc public func disconnectMIDI(sourceNode: AVAudioNodeWrapper, from destinationNode: AVAudioNodeWrapper) -> Void {
    return wrappedInstance.disconnectMIDI(sourceNode: sourceNode.wrappedInstance, from: destinationNode.wrappedInstance)
  }
  
  @objc public func disconnectMIDIInput(node: AVAudioNodeWrapper) -> Void {
    return wrappedInstance.disconnectMIDIInput(node: node.wrappedInstance)
  }
  
  @objc public func disconnectMIDIOutput(node: AVAudioNodeWrapper) -> Void {
    return wrappedInstance.disconnectMIDIOutput(node: node.wrappedInstance)
  }
  
  @objc public func disconnectNodeInput(node: AVAudioNodeWrapper) -> Void {
    return wrappedInstance.disconnectNodeInput(node: node.wrappedInstance)
  }
  
  @objc public func disconnectNodeOutput(node: AVAudioNodeWrapper) -> Void {
    return wrappedInstance.disconnectNodeOutput(node: node.wrappedInstance)
  }
  
  @objc public func pause() -> Void {
    return wrappedInstance.pause()
  }
  
  @objc public func prepare() -> Void {
    return wrappedInstance.prepare()
  }
  
  @objc public func reset() -> Void {
    return wrappedInstance.reset()
  }
  
  @objc public func start() {
    wrappedInstance.start()
  }
  
  @objc public func stop() -> Void {
    return wrappedInstance.stop()
  }
}

@objc public class AVAudioEnvironmentDistanceAttenuationParametersWrapper: NSObject {
  var wrappedInstance: AVAudioEnvironmentDistanceAttenuationParameters
  
  init(_ wrappedInstance: AVAudioEnvironmentDistanceAttenuationParameters) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAudioEnvironmentNodeWrapper: NSObject {
  var wrappedInstance: AVAudioEnvironmentNode
  
  @objc public var distanceAttenuationParameters: AVAudioEnvironmentDistanceAttenuationParametersWrapper {
    get {
      AVAudioEnvironmentDistanceAttenuationParametersWrapper(wrappedInstance.distanceAttenuationParameters)
    }
  }
  
  @objc public var listenerAngularOrientation: AVAudio3DAngularOrientationWrapper {
    get {
      AVAudio3DAngularOrientationWrapper(wrappedInstance.listenerAngularOrientation)
    }
    set {
      wrappedInstance.listenerAngularOrientation = newValue.wrappedInstance
    }
  }
  
  @objc public var listenerPosition: AVAudio3DPointWrapper {
    get {
      AVAudio3DPointWrapper(wrappedInstance.listenerPosition)
    }
    set {
      wrappedInstance.listenerPosition = newValue.wrappedInstance
    }
  }
  
  @objc public var listenerVectorOrientation: AVAudio3DVectorOrientationWrapper {
    get {
      AVAudio3DVectorOrientationWrapper(wrappedInstance.listenerVectorOrientation)
    }
    set {
      wrappedInstance.listenerVectorOrientation = newValue.wrappedInstance
    }
  }
  
  @objc public var reverbParameters: AVAudioEnvironmentReverbParametersWrapper {
    get {
      AVAudioEnvironmentReverbParametersWrapper(wrappedInstance.reverbParameters)
    }
  }
  
  init(_ wrappedInstance: AVAudioEnvironmentNode) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVAudioEnvironmentNode()
  }
}

@objc public class AVAudioEnvironmentReverbParametersWrapper: NSObject {
  var wrappedInstance: AVAudioEnvironmentReverbParameters
  
  @objc public var enable: Bool {
    get {
      wrappedInstance.enable
    }
    set {
      wrappedInstance.enable = newValue
    }
  }
  
  @objc public var filterParameters: AVAudioUnitEQFilterParametersWrapper {
    get {
      AVAudioUnitEQFilterParametersWrapper(wrappedInstance.filterParameters)
    }
  }
  
  init(_ wrappedInstance: AVAudioEnvironmentReverbParameters) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAudioFileWrapper: NSObject {
  var wrappedInstance: AVAudioFile
  
  @objc public var fileFormat: AVAudioFormatWrapper {
    get {
      AVAudioFormatWrapper(wrappedInstance.fileFormat)
    }
  }
  
  @objc public var processingFormat: AVAudioFormatWrapper {
    get {
      AVAudioFormatWrapper(wrappedInstance.processingFormat)
    }
  }
  
  init(_ wrappedInstance: AVAudioFile) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func read(into buffer: AVAudioPCMBufferWrapper) {
    wrappedInstance.read(into: buffer.wrappedInstance)
  }
  
  @objc public func write(from buffer: AVAudioPCMBufferWrapper) {
    wrappedInstance.write(from: buffer.wrappedInstance)
  }
}

@objc public class AVAudioFormatWrapper: NSObject {
  var wrappedInstance: AVAudioFormat
  
  @objc public var channelLayout: AVAudioChannelLayoutWrapper {
    get {
      AVAudioChannelLayoutWrapper(wrappedInstance.channelLayout)
    }
  }
  
  @objc public var isInterleaved: Bool {
    get {
      wrappedInstance.isInterleaved
    }
  }
  
  @objc public var sampleRate: Double {
    get {
      wrappedInstance.sampleRate
    }
  }
  
  @objc public var settings: String {
    get {
      wrappedInstance.settings
    }
  }
  
  @objc public var isStandard: Bool {
    get {
      wrappedInstance.isStandard
    }
  }
  
  init(_ wrappedInstance: AVAudioFormat) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(standardFormatWithSampleRate sampleRate: Double, channelLayout layout: AVAudioChannelLayoutWrapper) {
    wrappedInstance = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channelLayout: layout.wrappedInstance)
  }
  
  @objc init?(settings: String) {
    if let instance = AVAudioFormat(settings: settings) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }
}

@objc public class AVAudioIONodeWrapper: NSObject {
  var wrappedInstance: AVAudioIONode
  
  @objc public var isVoiceProcessingEnabled: Bool {
    get {
      wrappedInstance.isVoiceProcessingEnabled
    }
  }
  
  init(_ wrappedInstance: AVAudioIONode) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func setVoiceProcessingEnabled(enabled: Bool) {
    wrappedInstance.setVoiceProcessingEnabled(enabled: enabled)
  }
}

@objc public class AVAudioInputNodeWrapper: NSObject {
  var wrappedInstance: AVAudioInputNode
  
  @objc public var isVoiceProcessingAGCEnabled: Bool {
    get {
      wrappedInstance.isVoiceProcessingAGCEnabled
    }
    set {
      wrappedInstance.isVoiceProcessingAGCEnabled = newValue
    }
  }
  
  @objc public var isVoiceProcessingBypassed: Bool {
    get {
      wrappedInstance.isVoiceProcessingBypassed
    }
    set {
      wrappedInstance.isVoiceProcessingBypassed = newValue
    }
  }
  
  @objc public var isVoiceProcessingInputMuted: Bool {
    get {
      wrappedInstance.isVoiceProcessingInputMuted
    }
    set {
      wrappedInstance.isVoiceProcessingInputMuted = newValue
    }
  }
  
  @objc public var voiceProcessingOtherAudioDuckingConfiguration: AVAudioVoiceProcessingOtherAudioDuckingConfigurationWrapper {
    get {
      AVAudioVoiceProcessingOtherAudioDuckingConfigurationWrapper(wrappedInstance.voiceProcessingOtherAudioDuckingConfiguration)
    }
    set {
      wrappedInstance.voiceProcessingOtherAudioDuckingConfiguration = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVAudioInputNode) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAudioMixerNodeWrapper: NSObject {
  var wrappedInstance: AVAudioMixerNode
  
  init(_ wrappedInstance: AVAudioMixerNode) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVAudioMixerNode()
  }
}

@objc public class AVAudioMixingDestinationWrapper: NSObject {
  var wrappedInstance: AVAudioMixingDestination
  
  @objc public var connectionPoint: AVAudioConnectionPointWrapper {
    get {
      AVAudioConnectionPointWrapper(wrappedInstance.connectionPoint)
    }
  }
  
  init(_ wrappedInstance: AVAudioMixingDestination) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAudioNodeWrapper: NSObject {
  var wrappedInstance: AVAudioNode
  
  @objc public var engine: AVAudioEngineWrapper {
    get {
      AVAudioEngineWrapper(wrappedInstance.engine)
    }
  }
  
  @objc public var lastRenderTime: AVAudioTimeWrapper {
    get {
      AVAudioTimeWrapper(wrappedInstance.lastRenderTime)
    }
  }
  
  @objc public var numberOfInputs: Int {
    get {
      wrappedInstance.numberOfInputs
    }
  }
  
  @objc public var numberOfOutputs: Int {
    get {
      wrappedInstance.numberOfOutputs
    }
  }
  
  init(_ wrappedInstance: AVAudioNode) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func reset() -> Void {
    return wrappedInstance.reset()
  }
}

@objc public class AVAudioOutputNodeWrapper: NSObject {
  var wrappedInstance: AVAudioOutputNode
  
  init(_ wrappedInstance: AVAudioOutputNode) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAudioPCMBufferWrapper: NSObject {
  var wrappedInstance: AVAudioPCMBuffer
  
  @objc public var stride: Int {
    get {
      wrappedInstance.stride
    }
  }
  
  init(_ wrappedInstance: AVAudioPCMBuffer) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAudioPlayerWrapper: NSObject {
  var wrappedInstance: AVAudioPlayer
  
  @objc public var currentDevice: String {
    get {
      wrappedInstance.currentDevice
    }
    set {
      wrappedInstance.currentDevice = newValue
    }
  }
  
  @objc public var enableRate: Bool {
    get {
      wrappedInstance.enableRate
    }
    set {
      wrappedInstance.enableRate = newValue
    }
  }
  
  @objc public var format: AVAudioFormatWrapper {
    get {
      AVAudioFormatWrapper(wrappedInstance.format)
    }
  }
  
  @objc public var isMeteringEnabled: Bool {
    get {
      wrappedInstance.isMeteringEnabled
    }
    set {
      wrappedInstance.isMeteringEnabled = newValue
    }
  }
  
  @objc public var numberOfChannels: Int {
    get {
      wrappedInstance.numberOfChannels
    }
  }
  
  @objc public var numberOfLoops: Int {
    get {
      wrappedInstance.numberOfLoops
    }
    set {
      wrappedInstance.numberOfLoops = newValue
    }
  }
  
  @objc public var isPlaying: Bool {
    get {
      wrappedInstance.isPlaying
    }
  }
  
  @objc public var settings: String {
    get {
      wrappedInstance.settings
    }
  }
  
  init(_ wrappedInstance: AVAudioPlayer) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func pause() -> Void {
    return wrappedInstance.pause()
  }
  
  @objc public func play() -> Bool {
    return wrappedInstance.play()
  }
  
  @objc public func prepareToPlay() -> Bool {
    return wrappedInstance.prepareToPlay()
  }
  
  @objc public func stop() -> Void {
    return wrappedInstance.stop()
  }
  
  @objc public func updateMeters() -> Void {
    return wrappedInstance.updateMeters()
  }
}

@objc public class AVAudioPlayerNodeWrapper: NSObject {
  var wrappedInstance: AVAudioPlayerNode
  
  @objc public var isPlaying: Bool {
    get {
      wrappedInstance.isPlaying
    }
  }
  
  init(_ wrappedInstance: AVAudioPlayerNode) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVAudioPlayerNode()
  }
  
  @objc public func nodeTime(forPlayerTime playerTime: AVAudioTimeWrapper) -> AVAudioTimeWrapper {
    let result = wrappedInstance.nodeTime(forPlayerTime: playerTime.wrappedInstance)
    return AVAudioTimeWrapper(result)
  }
  
  @objc public func pause() -> Void {
    return wrappedInstance.pause()
  }
  
  @objc public func play() -> Void {
    return wrappedInstance.play()
  }
  
  @objc public func play(at when: AVAudioTimeWrapper) -> Void {
    return wrappedInstance.play(at: when.wrappedInstance)
  }
  
  @objc public func playerTime(forNodeTime nodeTime: AVAudioTimeWrapper) -> AVAudioTimeWrapper {
    let result = wrappedInstance.playerTime(forNodeTime: nodeTime.wrappedInstance)
    return AVAudioTimeWrapper(result)
  }
  
  @objc public func scheduleBuffer(buffer: AVAudioPCMBufferWrapper, at when: AVAudioTimeWrapper, options: AVAudioPlayerNodeBufferOptionsWrapper) -> Void {
    return wrappedInstance.scheduleBuffer(buffer: buffer.wrappedInstance, at: when.wrappedInstance, options: options.wrappedInstance)
  }
  
  @objc public func scheduleFile(file: AVAudioFileWrapper, at when: AVAudioTimeWrapper) -> Void {
    return wrappedInstance.scheduleFile(file: file.wrappedInstance, at: when.wrappedInstance)
  }
  
  @objc public func stop() -> Void {
    return wrappedInstance.stop()
  }
}

@objc public class AVAudioRecorderWrapper: NSObject {
  var wrappedInstance: AVAudioRecorder
  
  @objc public var format: AVAudioFormatWrapper {
    get {
      AVAudioFormatWrapper(wrappedInstance.format)
    }
  }
  
  @objc public var isMeteringEnabled: Bool {
    get {
      wrappedInstance.isMeteringEnabled
    }
    set {
      wrappedInstance.isMeteringEnabled = newValue
    }
  }
  
  @objc public var isRecording: Bool {
    get {
      wrappedInstance.isRecording
    }
  }
  
  @objc public var settings: String {
    get {
      wrappedInstance.settings
    }
  }
  
  init(_ wrappedInstance: AVAudioRecorder) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func deleteRecording() -> Bool {
    return wrappedInstance.deleteRecording()
  }
  
  @objc public func pause() -> Void {
    return wrappedInstance.pause()
  }
  
  @objc public func prepareToRecord() -> Bool {
    return wrappedInstance.prepareToRecord()
  }
  
  @objc public func record() -> Bool {
    return wrappedInstance.record()
  }
  
  @objc public func stop() -> Void {
    return wrappedInstance.stop()
  }
  
  @objc public func updateMeters() -> Void {
    return wrappedInstance.updateMeters()
  }
}

@objc public class AVAudioRoutingArbiterWrapper: NSObject {
  var wrappedInstance: AVAudioRoutingArbiter
  
  @objc static public var shared: AVAudioRoutingArbiterWrapper {
    get {
      AVAudioRoutingArbiterWrapper(AVAudioRoutingArbiter.shared)
    }
  }
  
  init(_ wrappedInstance: AVAudioRoutingArbiter) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func begin(category: AVAudioRoutingArbiterWrapper, completionHandler handler: Bool) -> Void {
    return wrappedInstance.begin(category: category.wrappedInstance, completionHandler: handler)
  }
  
  @objc public func leave() -> Void {
    return wrappedInstance.leave()
  }
}

@objc public class AVAudioSequencerWrapper: NSObject {
  var wrappedInstance: AVAudioSequencer
  
  @objc public var isPlaying: Bool {
    get {
      wrappedInstance.isPlaying
    }
  }
  
  @objc public var tempoTrack: AVMusicTrackWrapper {
    get {
      AVMusicTrackWrapper(wrappedInstance.tempoTrack)
    }
  }
  
  @objc public var tracks: AVMusicTrackWrapper {
    get {
      AVMusicTrackWrapper(wrappedInstance.tracks)
    }
  }
  
  @objc public var userInfo: String {
    get {
      wrappedInstance.userInfo
    }
  }
  
  init(_ wrappedInstance: AVAudioSequencer) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVAudioSequencer()
  }
  
  @objc init(audioEngine engine: AVAudioEngineWrapper) {
    wrappedInstance = AVAudioSequencer(audioEngine: engine.wrappedInstance)
  }
  
  @objc public func createAndAppendTrack() -> AVMusicTrackWrapper {
    let result = wrappedInstance.createAndAppendTrack()
    return AVMusicTrackWrapper(result)
  }
  
  @objc public func prepareToPlay() -> Void {
    return wrappedInstance.prepareToPlay()
  }
  
  @objc public func removeTrack(track: AVMusicTrackWrapper) -> Bool {
    return wrappedInstance.removeTrack(track: track.wrappedInstance)
  }
  
  @objc public func reverseEvents() -> Void {
    return wrappedInstance.reverseEvents()
  }
  
  @objc public func start() {
    wrappedInstance.start()
  }
  
  @objc public func stop() -> Void {
    return wrappedInstance.stop()
  }
}

@objc public class AVAudioSinkNodeWrapper: NSObject {
  var wrappedInstance: AVAudioSinkNode
  
  init(_ wrappedInstance: AVAudioSinkNode) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAudioSourceNodeWrapper: NSObject {
  var wrappedInstance: AVAudioSourceNode
  
  init(_ wrappedInstance: AVAudioSourceNode) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAudioTimeWrapper: NSObject {
  var wrappedInstance: AVAudioTime
  
  @objc public var isHostTimeValid: Bool {
    get {
      wrappedInstance.isHostTimeValid
    }
  }
  
  @objc public var sampleRate: Double {
    get {
      wrappedInstance.sampleRate
    }
  }
  
  @objc public var isSampleTimeValid: Bool {
    get {
      wrappedInstance.isSampleTimeValid
    }
  }
  
  init(_ wrappedInstance: AVAudioTime) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func extrapolateTime(fromAnchor anchorTime: AVAudioTimeWrapper) -> AVAudioTimeWrapper {
    let result = wrappedInstance.extrapolateTime(fromAnchor: anchorTime.wrappedInstance)
    return AVAudioTimeWrapper(result)
  }
}

@objc public class AVAudioUnitWrapper: NSObject {
  var wrappedInstance: AVAudioUnit
  
  @objc public var manufacturerName: String {
    get {
      wrappedInstance.manufacturerName
    }
  }
  
  @objc public var name: String {
    get {
      wrappedInstance.name
    }
  }
  
  @objc public var version: Int {
    get {
      wrappedInstance.version
    }
  }
  
  init(_ wrappedInstance: AVAudioUnit) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAudioUnitComponentWrapper: NSObject {
  var wrappedInstance: AVAudioUnitComponent
  
  @objc public var allTagNames: String {
    get {
      wrappedInstance.allTagNames
    }
  }
  
  @objc public var configurationDictionary: String {
    get {
      wrappedInstance.configurationDictionary
    }
  }
  
  @objc public var hasCustomView: Bool {
    get {
      wrappedInstance.hasCustomView
    }
  }
  
  @objc public var hasMIDIInput: Bool {
    get {
      wrappedInstance.hasMIDIInput
    }
  }
  
  @objc public var hasMIDIOutput: Bool {
    get {
      wrappedInstance.hasMIDIOutput
    }
  }
  
  @objc public var localizedTypeName: String {
    get {
      wrappedInstance.localizedTypeName
    }
  }
  
  @objc public var manufacturerName: String {
    get {
      wrappedInstance.manufacturerName
    }
  }
  
  @objc public var name: String {
    get {
      wrappedInstance.name
    }
  }
  
  @objc public var passesAUVal: Bool {
    get {
      wrappedInstance.passesAUVal
    }
  }
  
  @objc public var isSandboxSafe: Bool {
    get {
      wrappedInstance.isSandboxSafe
    }
  }
  
  @objc public var typeName: String {
    get {
      wrappedInstance.typeName
    }
  }
  
  @objc public var userTagNames: String {
    get {
      wrappedInstance.userTagNames
    }
    set {
      wrappedInstance.userTagNames = newValue
    }
  }
  
  @objc public var version: Int {
    get {
      wrappedInstance.version
    }
  }
  
  @objc public var versionString: String {
    get {
      wrappedInstance.versionString
    }
  }
  
  init(_ wrappedInstance: AVAudioUnitComponent) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func supportsNumberInputChannels(numInputChannels: Int, outputChannels numOutputChannels: Int) -> Bool {
    return wrappedInstance.supportsNumberInputChannels(numInputChannels: numInputChannels, outputChannels: numOutputChannels)
  }
}

@objc public class AVAudioUnitComponentManagerWrapper: NSObject {
  var wrappedInstance: AVAudioUnitComponentManager
  
  @objc public var standardLocalizedTagNames: String {
    get {
      wrappedInstance.standardLocalizedTagNames
    }
  }
  
  @objc public var tagNames: String {
    get {
      wrappedInstance.tagNames
    }
  }
  
  init(_ wrappedInstance: AVAudioUnitComponentManager) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAudioUnitDelayWrapper: NSObject {
  var wrappedInstance: AVAudioUnitDelay
  
  init(_ wrappedInstance: AVAudioUnitDelay) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAudioUnitDistortionWrapper: NSObject {
  var wrappedInstance: AVAudioUnitDistortion
  
  init(_ wrappedInstance: AVAudioUnitDistortion) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAudioUnitEQWrapper: NSObject {
  var wrappedInstance: AVAudioUnitEQ
  
  @objc public var bands: AVAudioUnitEQFilterParametersWrapper {
    get {
      AVAudioUnitEQFilterParametersWrapper(wrappedInstance.bands)
    }
  }
  
  init(_ wrappedInstance: AVAudioUnitEQ) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(numberOfBands: Int) {
    wrappedInstance = AVAudioUnitEQ(numberOfBands: numberOfBands)
  }
}

@objc public class AVAudioUnitEQFilterParametersWrapper: NSObject {
  var wrappedInstance: AVAudioUnitEQFilterParameters
  
  @objc public var bypass: Bool {
    get {
      wrappedInstance.bypass
    }
    set {
      wrappedInstance.bypass = newValue
    }
  }
  
  init(_ wrappedInstance: AVAudioUnitEQFilterParameters) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAudioUnitEffectWrapper: NSObject {
  var wrappedInstance: AVAudioUnitEffect
  
  @objc public var bypass: Bool {
    get {
      wrappedInstance.bypass
    }
    set {
      wrappedInstance.bypass = newValue
    }
  }
  
  init(_ wrappedInstance: AVAudioUnitEffect) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAudioUnitGeneratorWrapper: NSObject {
  var wrappedInstance: AVAudioUnitGenerator
  
  @objc public var bypass: Bool {
    get {
      wrappedInstance.bypass
    }
    set {
      wrappedInstance.bypass = newValue
    }
  }
  
  init(_ wrappedInstance: AVAudioUnitGenerator) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAudioUnitMIDIInstrumentWrapper: NSObject {
  var wrappedInstance: AVAudioUnitMIDIInstrument
  
  init(_ wrappedInstance: AVAudioUnitMIDIInstrument) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAudioUnitReverbWrapper: NSObject {
  var wrappedInstance: AVAudioUnitReverb
  
  init(_ wrappedInstance: AVAudioUnitReverb) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAudioUnitSamplerWrapper: NSObject {
  var wrappedInstance: AVAudioUnitSampler
  
  init(_ wrappedInstance: AVAudioUnitSampler) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAudioUnitTimeEffectWrapper: NSObject {
  var wrappedInstance: AVAudioUnitTimeEffect
  
  @objc public var bypass: Bool {
    get {
      wrappedInstance.bypass
    }
    set {
      wrappedInstance.bypass = newValue
    }
  }
  
  init(_ wrappedInstance: AVAudioUnitTimeEffect) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAudioUnitTimePitchWrapper: NSObject {
  var wrappedInstance: AVAudioUnitTimePitch
  
  init(_ wrappedInstance: AVAudioUnitTimePitch) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAudioUnitVarispeedWrapper: NSObject {
  var wrappedInstance: AVAudioUnitVarispeed
  
  init(_ wrappedInstance: AVAudioUnitVarispeed) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVExtendedNoteOnEventWrapper: NSObject {
  var wrappedInstance: AVExtendedNoteOnEvent
  
  init(_ wrappedInstance: AVExtendedNoteOnEvent) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVExtendedTempoEventWrapper: NSObject {
  var wrappedInstance: AVExtendedTempoEvent
  
  @objc public var tempo: Double {
    get {
      wrappedInstance.tempo
    }
    set {
      wrappedInstance.tempo = newValue
    }
  }
  
  init(_ wrappedInstance: AVExtendedTempoEvent) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(tempo: Double) {
    wrappedInstance = AVExtendedTempoEvent(tempo: tempo)
  }
}

@objc public class AVMIDIChannelEventWrapper: NSObject {
  var wrappedInstance: AVMIDIChannelEvent
  
  init(_ wrappedInstance: AVMIDIChannelEvent) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMIDIChannelPressureEventWrapper: NSObject {
  var wrappedInstance: AVMIDIChannelPressureEvent
  
  init(_ wrappedInstance: AVMIDIChannelPressureEvent) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMIDIControlChangeEventWrapper: NSObject {
  var wrappedInstance: AVMIDIControlChangeEvent
  
  @objc public var messageType: AVMIDIControlChangeEventWrapper {
    get {
      AVMIDIControlChangeEventWrapper(wrappedInstance.messageType)
    }
  }
  
  init(_ wrappedInstance: AVMIDIControlChangeEvent) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMIDIMetaEventWrapper: NSObject {
  var wrappedInstance: AVMIDIMetaEvent
  
  @objc public var type: AVMIDIMetaEventWrapper {
    get {
      AVMIDIMetaEventWrapper(wrappedInstance.type)
    }
  }
  
  init(_ wrappedInstance: AVMIDIMetaEvent) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMIDINoteEventWrapper: NSObject {
  var wrappedInstance: AVMIDINoteEvent
  
  init(_ wrappedInstance: AVMIDINoteEvent) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMIDIPitchBendEventWrapper: NSObject {
  var wrappedInstance: AVMIDIPitchBendEvent
  
  init(_ wrappedInstance: AVMIDIPitchBendEvent) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMIDIPlayerWrapper: NSObject {
  var wrappedInstance: AVMIDIPlayer
  
  @objc public var isPlaying: Bool {
    get {
      wrappedInstance.isPlaying
    }
  }
  
  init(_ wrappedInstance: AVMIDIPlayer) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func prepareToPlay() -> Void {
    return wrappedInstance.prepareToPlay()
  }
  
  @objc public func stop() -> Void {
    return wrappedInstance.stop()
  }
}

@objc public class AVMIDIPolyPressureEventWrapper: NSObject {
  var wrappedInstance: AVMIDIPolyPressureEvent
  
  init(_ wrappedInstance: AVMIDIPolyPressureEvent) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMIDIProgramChangeEventWrapper: NSObject {
  var wrappedInstance: AVMIDIProgramChangeEvent
  
  init(_ wrappedInstance: AVMIDIProgramChangeEvent) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMIDISysexEventWrapper: NSObject {
  var wrappedInstance: AVMIDISysexEvent
  
  init(_ wrappedInstance: AVMIDISysexEvent) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMusicEventWrapper: NSObject {
  var wrappedInstance: AVMusicEvent
  
  init(_ wrappedInstance: AVMusicEvent) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMusicTrackWrapper: NSObject {
  var wrappedInstance: AVMusicTrack
  
  @objc public var destinationAudioUnit: AVAudioUnitWrapper {
    get {
      AVAudioUnitWrapper(wrappedInstance.destinationAudioUnit)
    }
    set {
      wrappedInstance.destinationAudioUnit = newValue.wrappedInstance
    }
  }
  
  @objc public var isLoopingEnabled: Bool {
    get {
      wrappedInstance.isLoopingEnabled
    }
    set {
      wrappedInstance.isLoopingEnabled = newValue
    }
  }
  
  @objc public var isMuted: Bool {
    get {
      wrappedInstance.isMuted
    }
    set {
      wrappedInstance.isMuted = newValue
    }
  }
  
  @objc public var numberOfLoops: Int {
    get {
      wrappedInstance.numberOfLoops
    }
    set {
      wrappedInstance.numberOfLoops = newValue
    }
  }
  
  @objc public var isSoloed: Bool {
    get {
      wrappedInstance.isSoloed
    }
    set {
      wrappedInstance.isSoloed = newValue
    }
  }
  
  @objc public var timeResolution: Int {
    get {
      wrappedInstance.timeResolution
    }
  }
  
  @objc public var usesAutomatedParameters: Bool {
    get {
      wrappedInstance.usesAutomatedParameters
    }
    set {
      wrappedInstance.usesAutomatedParameters = newValue
    }
  }
  
  init(_ wrappedInstance: AVMusicTrack) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMusicUserEventWrapper: NSObject {
  var wrappedInstance: AVMusicUserEvent
  
  init(_ wrappedInstance: AVMusicUserEvent) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVParameterEventWrapper: NSObject {
  var wrappedInstance: AVParameterEvent
  
  init(_ wrappedInstance: AVParameterEvent) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVSpeechSynthesisMarkerWrapper: NSObject {
  var wrappedInstance: AVSpeechSynthesisMarker
  
  @objc public var bookmarkName: String {
    get {
      wrappedInstance.bookmarkName
    }
    set {
      wrappedInstance.bookmarkName = newValue
    }
  }
  
  @objc public var byteSampleOffset: Int {
    get {
      wrappedInstance.byteSampleOffset
    }
    set {
      wrappedInstance.byteSampleOffset = newValue
    }
  }
  
  @objc public var mark: AVSpeechSynthesisMarkerWrapper {
    get {
      AVSpeechSynthesisMarkerWrapper(wrappedInstance.mark)
    }
    set {
      wrappedInstance.mark = newValue.wrappedInstance
    }
  }
  
  @objc public var phoneme: String {
    get {
      wrappedInstance.phoneme
    }
    set {
      wrappedInstance.phoneme = newValue
    }
  }
  
  init(_ wrappedInstance: AVSpeechSynthesisMarker) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(bookmarkName mark: String, atByteSampleOffset byteSampleOffset: Int) {
    wrappedInstance = AVSpeechSynthesisMarker(bookmarkName: mark, atByteSampleOffset: byteSampleOffset)
  }
  
  @objc init(phonemeString phoneme: String, atByteSampleOffset byteSampleOffset: Int) {
    wrappedInstance = AVSpeechSynthesisMarker(phonemeString: phoneme, atByteSampleOffset: byteSampleOffset)
  }
}

@objc public class AVSpeechSynthesisProviderAudioUnitWrapper: NSObject {
  var wrappedInstance: AVSpeechSynthesisProviderAudioUnit
  
  @objc public var speechVoices: AVSpeechSynthesisProviderVoiceWrapper {
    get {
      AVSpeechSynthesisProviderVoiceWrapper(wrappedInstance.speechVoices)
    }
    set {
      wrappedInstance.speechVoices = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVSpeechSynthesisProviderAudioUnit) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func cancelSpeechRequest() -> Void {
    return wrappedInstance.cancelSpeechRequest()
  }
  
  @objc public func synthesizeSpeechRequest(speechRequest: AVSpeechSynthesisProviderRequestWrapper) -> Void {
    return wrappedInstance.synthesizeSpeechRequest(speechRequest: speechRequest.wrappedInstance)
  }
}

@objc public class AVSpeechSynthesisProviderRequestWrapper: NSObject {
  var wrappedInstance: AVSpeechSynthesisProviderRequest
  
  @objc public var ssmlRepresentation: String {
    get {
      wrappedInstance.ssmlRepresentation
    }
  }
  
  @objc public var voice: AVSpeechSynthesisProviderVoiceWrapper {
    get {
      AVSpeechSynthesisProviderVoiceWrapper(wrappedInstance.voice)
    }
  }
  
  init(_ wrappedInstance: AVSpeechSynthesisProviderRequest) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(ssmlRepresentation text: String, voice: AVSpeechSynthesisProviderVoiceWrapper) {
    wrappedInstance = AVSpeechSynthesisProviderRequest(ssmlRepresentation: text, voice: voice.wrappedInstance)
  }
}

@objc public class AVSpeechSynthesisProviderVoiceWrapper: NSObject {
  var wrappedInstance: AVSpeechSynthesisProviderVoice
  
  @objc public var age: Int {
    get {
      wrappedInstance.age
    }
    set {
      wrappedInstance.age = newValue
    }
  }
  
  @objc public var identifier: String {
    get {
      wrappedInstance.identifier
    }
  }
  
  @objc public var name: String {
    get {
      wrappedInstance.name
    }
  }
  
  @objc public var primaryLanguages: String {
    get {
      wrappedInstance.primaryLanguages
    }
  }
  
  @objc public var supportedLanguages: String {
    get {
      wrappedInstance.supportedLanguages
    }
  }
  
  @objc public var version: String {
    get {
      wrappedInstance.version
    }
    set {
      wrappedInstance.version = newValue
    }
  }
  
  init(_ wrappedInstance: AVSpeechSynthesisProviderVoice) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(name: String, identifier: String, primaryLanguages: String, supportedLanguages: String) {
    wrappedInstance = AVSpeechSynthesisProviderVoice(name: name, identifier: identifier, primaryLanguages: primaryLanguages, supportedLanguages: supportedLanguages)
  }
  
  @objc static public func updateSpeechVoices() -> Void {
    return AVSpeechSynthesisProviderVoice.updateSpeechVoices()
  }
}

@objc public class AVSpeechSynthesisVoiceWrapper: NSObject {
  var wrappedInstance: AVSpeechSynthesisVoice
  
  @objc public var audioFileSettings: String {
    get {
      wrappedInstance.audioFileSettings
    }
  }
  
  @objc public var identifier: String {
    get {
      wrappedInstance.identifier
    }
  }
  
  @objc public var language: String {
    get {
      wrappedInstance.language
    }
  }
  
  @objc public var name: String {
    get {
      wrappedInstance.name
    }
  }
  
  @objc public var voiceTraits: AVSpeechSynthesisVoiceWrapper {
    get {
      AVSpeechSynthesisVoiceWrapper(wrappedInstance.voiceTraits)
    }
  }
  
  init(_ wrappedInstance: AVSpeechSynthesisVoice) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init?(identifier: String) {
    if let instance = AVSpeechSynthesisVoice(identifier: identifier) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }
  
  @objc init?(language languageCode: String) {
    if let instance = AVSpeechSynthesisVoice(language: languageCode) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }
  
  @objc static public func currentLanguageCode() -> String {
    return AVSpeechSynthesisVoice.currentLanguageCode()
  }
}

@objc public class AVSpeechSynthesizerWrapper: NSObject {
  var wrappedInstance: AVSpeechSynthesizer
  
  @objc static public var personalVoiceAuthorizationStatus: AVSpeechSynthesizerWrapper {
    get {
      AVSpeechSynthesizerWrapper(AVSpeechSynthesizer.personalVoiceAuthorizationStatus)
    }
  }
  
  @objc public var isPaused: Bool {
    get {
      wrappedInstance.isPaused
    }
  }
  
  @objc public var isSpeaking: Bool {
    get {
      wrappedInstance.isSpeaking
    }
  }
  
  init(_ wrappedInstance: AVSpeechSynthesizer) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc static public func requestPersonalVoiceAuthorization(completionHandler handler: AVSpeechSynthesizerWrapper) -> Void {
    return AVSpeechSynthesizer.requestPersonalVoiceAuthorization(completionHandler: handler.wrappedInstance)
  }
  
  @objc public func continueSpeaking() -> Bool {
    return wrappedInstance.continueSpeaking()
  }
  
  @objc public func speak(utterance: AVSpeechUtteranceWrapper) -> Void {
    return wrappedInstance.speak(utterance: utterance.wrappedInstance)
  }
  
  @objc public func write(utterance: AVSpeechUtteranceWrapper, toBufferCallback bufferCallback: AVSpeechSynthesizerWrapper) -> Void {
    return wrappedInstance.write(utterance: utterance.wrappedInstance, toBufferCallback: bufferCallback.wrappedInstance)
  }
  
  @objc public func write(utterance: AVSpeechUtteranceWrapper, toBufferCallback bufferCallback: AVSpeechSynthesizerWrapper, toMarkerCallback markerCallback: AVSpeechSynthesizerWrapper) -> Void {
    return wrappedInstance.write(utterance: utterance.wrappedInstance, toBufferCallback: bufferCallback.wrappedInstance, toMarkerCallback: markerCallback.wrappedInstance)
  }
}

@objc public class AVSpeechUtteranceWrapper: NSObject {
  var wrappedInstance: AVSpeechUtterance
  
  @objc public var prefersAssistiveTechnologySettings: Bool {
    get {
      wrappedInstance.prefersAssistiveTechnologySettings
    }
    set {
      wrappedInstance.prefersAssistiveTechnologySettings = newValue
    }
  }
  
  @objc public var speechString: String {
    get {
      wrappedInstance.speechString
    }
  }
  
  @objc public var voice: AVSpeechSynthesisVoiceWrapper {
    get {
      AVSpeechSynthesisVoiceWrapper(wrappedInstance.voice)
    }
    set {
      wrappedInstance.voice = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVSpeechUtterance) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init?(ssmlRepresentation string: String) {
    if let instance = AVSpeechUtterance(ssmlRepresentation: string) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }
  
  @objc init(string: String) {
    wrappedInstance = AVSpeechUtterance(string: string)
  }
}

@objc public class GlobalsWrapper: NSObject {
  @objc static public var AVAudioBitRateStrategy_ConstantWrapper: String {
    get {
      AVAudioBitRateStrategy_Constant
    }
  }
  
  @objc static public var AVAudioBitRateStrategy_LongTermAverageWrapper: String {
    get {
      AVAudioBitRateStrategy_LongTermAverage
    }
  }
  
  @objc static public var AVAudioBitRateStrategy_VariableWrapper: String {
    get {
      AVAudioBitRateStrategy_Variable
    }
  }
  
  @objc static public var AVAudioBitRateStrategy_VariableConstrainedWrapper: String {
    get {
      AVAudioBitRateStrategy_VariableConstrained
    }
  }
  
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
  
  @objc static public var AVAudioUnitManufacturerNameAppleWrapper: String {
    get {
      AVAudioUnitManufacturerNameApple
    }
  }
  
  @objc static public var AVAudioUnitTypeEffectWrapper: String {
    get {
      AVAudioUnitTypeEffect
    }
  }
  
  @objc static public var AVAudioUnitTypeFormatConverterWrapper: String {
    get {
      AVAudioUnitTypeFormatConverter
    }
  }
  
  @objc static public var AVAudioUnitTypeGeneratorWrapper: String {
    get {
      AVAudioUnitTypeGenerator
    }
  }
  
  @objc static public var AVAudioUnitTypeMIDIProcessorWrapper: String {
    get {
      AVAudioUnitTypeMIDIProcessor
    }
  }
  
  @objc static public var AVAudioUnitTypeMixerWrapper: String {
    get {
      AVAudioUnitTypeMixer
    }
  }
  
  @objc static public var AVAudioUnitTypeMusicDeviceWrapper: String {
    get {
      AVAudioUnitTypeMusicDevice
    }
  }
  
  @objc static public var AVAudioUnitTypeMusicEffectWrapper: String {
    get {
      AVAudioUnitTypeMusicEffect
    }
  }
  
  @objc static public var AVAudioUnitTypeOfflineEffectWrapper: String {
    get {
      AVAudioUnitTypeOfflineEffect
    }
  }
  
  @objc static public var AVAudioUnitTypeOutputWrapper: String {
    get {
      AVAudioUnitTypeOutput
    }
  }
  
  @objc static public var AVAudioUnitTypePannerWrapper: String {
    get {
      AVAudioUnitTypePanner
    }
  }
  
  @objc static public var AVChannelLayoutKeyWrapper: String {
    get {
      AVChannelLayoutKey
    }
  }
  
  @objc static public var AVEncoderAudioQualityForVBRKeyWrapper: String {
    get {
      AVEncoderAudioQualityForVBRKey
    }
  }
  
  @objc static public var AVEncoderAudioQualityKeyWrapper: String {
    get {
      AVEncoderAudioQualityKey
    }
  }
  
  @objc static public var AVEncoderBitDepthHintKeyWrapper: String {
    get {
      AVEncoderBitDepthHintKey
    }
  }
  
  @objc static public var AVEncoderBitRateKeyWrapper: String {
    get {
      AVEncoderBitRateKey
    }
  }
  
  @objc static public var AVEncoderBitRatePerChannelKeyWrapper: String {
    get {
      AVEncoderBitRatePerChannelKey
    }
  }
  
  @objc static public var AVEncoderBitRateStrategyKeyWrapper: String {
    get {
      AVEncoderBitRateStrategyKey
    }
  }
  
  @objc static public var AVFormatIDKeyWrapper: String {
    get {
      AVFormatIDKey
    }
  }
  
  @objc static public var AVLinearPCMBitDepthKeyWrapper: String {
    get {
      AVLinearPCMBitDepthKey
    }
  }
  
  @objc static public var AVLinearPCMIsBigEndianKeyWrapper: String {
    get {
      AVLinearPCMIsBigEndianKey
    }
  }
  
  @objc static public var AVLinearPCMIsFloatKeyWrapper: String {
    get {
      AVLinearPCMIsFloatKey
    }
  }
  
  @objc static public var AVLinearPCMIsNonInterleavedWrapper: String {
    get {
      AVLinearPCMIsNonInterleaved
    }
  }
  
  @objc static public var AVNumberOfChannelsKeyWrapper: String {
    get {
      AVNumberOfChannelsKey
    }
  }
  
  @objc static public var AVSampleRateConverterAlgorithmKeyWrapper: String {
    get {
      AVSampleRateConverterAlgorithmKey
    }
  }
  
  @objc static public var AVSampleRateConverterAlgorithm_MasteringWrapper: String {
    get {
      AVSampleRateConverterAlgorithm_Mastering
    }
  }
  
  @objc static public var AVSampleRateConverterAlgorithm_MinimumPhaseWrapper: String {
    get {
      AVSampleRateConverterAlgorithm_MinimumPhase
    }
  }
  
  @objc static public var AVSampleRateConverterAlgorithm_NormalWrapper: String {
    get {
      AVSampleRateConverterAlgorithm_Normal
    }
  }
  
  @objc static public var AVSampleRateConverterAudioQualityKeyWrapper: String {
    get {
      AVSampleRateConverterAudioQualityKey
    }
  }
  
  @objc static public var AVSampleRateKeyWrapper: String {
    get {
      AVSampleRateKey
    }
  }
  
  @objc static public var AVSpeechSynthesisIPANotationAttributeWrapper: String {
    get {
      AVSpeechSynthesisIPANotationAttribute
    }
  }
  
  @objc static public var AVSpeechSynthesisVoiceIdentifierAlexWrapper: String {
    get {
      AVSpeechSynthesisVoiceIdentifierAlex
    }
  }
  
  @objc static public var AVMusicTimeStampEndOfTrackWrapper: Double {
    get {
      AVMusicTimeStampEndOfTrack
    }
  }
}
