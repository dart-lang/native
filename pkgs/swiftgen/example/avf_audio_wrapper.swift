
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

  init(_ wrappedInstance: AVAudioVoiceProcessingOtherAudioDuckingConfiguration) {
    self.wrappedInstance = wrappedInstance
  }

  @objc override init() {
    wrappedInstance = AVAudioVoiceProcessingOtherAudioDuckingConfiguration()
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

  init(_ wrappedInstance: AVAudioApplication) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func setInputMuted(_ muted: Bool) throws {
    return try wrappedInstance.setInputMuted(muted)
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

  @objc public var node: AVAudioNodeWrapper? {
    get {
      wrappedInstance.node == nil ? nil : AVAudioNodeWrapper(wrappedInstance.node!)
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

  @objc public var bitRateStrategy: String? {
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

  @objc public var sampleRateConverterAlgorithm: String? {
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

  @objc public func convert(to outputBuffer: AVAudioPCMBufferWrapper, from inputBuffer: AVAudioPCMBufferWrapper) throws {
    return try wrappedInstance.convert(to: outputBuffer.wrappedInstance, from: inputBuffer.wrappedInstance)
  }

  @objc public func reset() {
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

  @objc public func attach(_ node: AVAudioNodeWrapper) {
    return wrappedInstance.attach(node.wrappedInstance)
  }

  @objc public func connect(_ node1: AVAudioNodeWrapper, to node2: AVAudioNodeWrapper, format: AVAudioFormatWrapper?) {
    return wrappedInstance.connect(node1.wrappedInstance, to: node2.wrappedInstance, format: format?.wrappedInstance)
  }

  @objc public func detach(_ node: AVAudioNodeWrapper) {
    return wrappedInstance.detach(node.wrappedInstance)
  }

  @objc public func disableManualRenderingMode() {
    return wrappedInstance.disableManualRenderingMode()
  }

  @objc public func disconnectMIDI(_ sourceNode: AVAudioNodeWrapper, from destinationNode: AVAudioNodeWrapper) {
    return wrappedInstance.disconnectMIDI(sourceNode.wrappedInstance, from: destinationNode.wrappedInstance)
  }

  @objc public func disconnectMIDIInput(_ node: AVAudioNodeWrapper) {
    return wrappedInstance.disconnectMIDIInput(node.wrappedInstance)
  }

  @objc public func disconnectMIDIOutput(_ node: AVAudioNodeWrapper) {
    return wrappedInstance.disconnectMIDIOutput(node.wrappedInstance)
  }

  @objc public func disconnectNodeInput(_ node: AVAudioNodeWrapper) {
    return wrappedInstance.disconnectNodeInput(node.wrappedInstance)
  }

  @objc public func disconnectNodeOutput(_ node: AVAudioNodeWrapper) {
    return wrappedInstance.disconnectNodeOutput(node.wrappedInstance)
  }

  @objc public func pause() {
    return wrappedInstance.pause()
  }

  @objc public func prepare() {
    return wrappedInstance.prepare()
  }

  @objc public func reset() {
    return wrappedInstance.reset()
  }

  @objc public func start() throws {
    return try wrappedInstance.start()
  }

  @objc public func stop() {
    return wrappedInstance.stop()
  }

}

@objc public class AVAudioEnvironmentDistanceAttenuationParametersWrapper: NSObject {
  var wrappedInstance: AVAudioEnvironmentDistanceAttenuationParameters

  @objc public var maximumDistance: Float {
    get {
      wrappedInstance.maximumDistance
    }
    set {
      wrappedInstance.maximumDistance = newValue
    }
  }

  @objc public var referenceDistance: Float {
    get {
      wrappedInstance.referenceDistance
    }
    set {
      wrappedInstance.referenceDistance = newValue
    }
  }

  @objc public var rolloffFactor: Float {
    get {
      wrappedInstance.rolloffFactor
    }
    set {
      wrappedInstance.rolloffFactor = newValue
    }
  }

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

  @objc public var outputVolume: Float {
    get {
      wrappedInstance.outputVolume
    }
    set {
      wrappedInstance.outputVolume = newValue
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

  @objc public var level: Float {
    get {
      wrappedInstance.level
    }
    set {
      wrappedInstance.level = newValue
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

  @objc public var url: URL {
    get {
      wrappedInstance.url
    }
  }

  init(_ wrappedInstance: AVAudioFile) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(forReading fileURL: URL) throws {
    wrappedInstance = try AVAudioFile(forReading: fileURL)
  }

  @objc public func read(into buffer: AVAudioPCMBufferWrapper) throws {
    return try wrappedInstance.read(into: buffer.wrappedInstance)
  }

  @objc public func write(from buffer: AVAudioPCMBufferWrapper) throws {
    return try wrappedInstance.write(from: buffer.wrappedInstance)
  }

}

@objc public class AVAudioFormatWrapper: NSObject {
  var wrappedInstance: AVAudioFormat

  @objc public var channelLayout: AVAudioChannelLayoutWrapper? {
    get {
      wrappedInstance.channelLayout == nil ? nil : AVAudioChannelLayoutWrapper(wrappedInstance.channelLayout!)
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

}

@objc public class AVAudioIONodeWrapper: NSObject {
  var wrappedInstance: AVAudioIONode

  @objc public var presentationLatency: TimeInterval {
    get {
      wrappedInstance.presentationLatency
    }
  }

  @objc public var isVoiceProcessingEnabled: Bool {
    get {
      wrappedInstance.isVoiceProcessingEnabled
    }
  }

  init(_ wrappedInstance: AVAudioIONode) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func setVoiceProcessingEnabled(_ enabled: Bool) throws {
    return try wrappedInstance.setVoiceProcessingEnabled(enabled)
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

  @objc public var outputVolume: Float {
    get {
      wrappedInstance.outputVolume
    }
    set {
      wrappedInstance.outputVolume = newValue
    }
  }

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

  @objc public var engine: AVAudioEngineWrapper? {
    get {
      wrappedInstance.engine == nil ? nil : AVAudioEngineWrapper(wrappedInstance.engine!)
    }
  }

  @objc public var lastRenderTime: AVAudioTimeWrapper? {
    get {
      wrappedInstance.lastRenderTime == nil ? nil : AVAudioTimeWrapper(wrappedInstance.lastRenderTime!)
    }
  }

  @objc public var latency: TimeInterval {
    get {
      wrappedInstance.latency
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

  @objc public var outputPresentationLatency: TimeInterval {
    get {
      wrappedInstance.outputPresentationLatency
    }
  }

  init(_ wrappedInstance: AVAudioNode) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func reset() {
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

  @objc public var currentDevice: String? {
    get {
      wrappedInstance.currentDevice
    }
    set {
      wrappedInstance.currentDevice = newValue
    }
  }

  @objc public var currentTime: TimeInterval {
    get {
      wrappedInstance.currentTime
    }
    set {
      wrappedInstance.currentTime = newValue
    }
  }

  @objc public var deviceCurrentTime: TimeInterval {
    get {
      wrappedInstance.deviceCurrentTime
    }
  }

  @objc public var duration: TimeInterval {
    get {
      wrappedInstance.duration
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

  @objc public var pan: Float {
    get {
      wrappedInstance.pan
    }
    set {
      wrappedInstance.pan = newValue
    }
  }

  @objc public var isPlaying: Bool {
    get {
      wrappedInstance.isPlaying
    }
  }

  @objc public var rate: Float {
    get {
      wrappedInstance.rate
    }
    set {
      wrappedInstance.rate = newValue
    }
  }

  @objc public var url: URL? {
    get {
      wrappedInstance.url
    }
  }

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

  @objc init(contentsOf url: URL) throws {
    wrappedInstance = try AVAudioPlayer(contentsOf: url)
  }

  @objc init(contentsOf url: URL, fileTypeHint utiString: String?) throws {
    wrappedInstance = try AVAudioPlayer(contentsOf: url, fileTypeHint: utiString)
  }

  @objc public func averagePower(forChannel channelNumber: Int) -> Float {
    return wrappedInstance.averagePower(forChannel: channelNumber)
  }

  @objc public func pause() {
    return wrappedInstance.pause()
  }

  @objc public func peakPower(forChannel channelNumber: Int) -> Float {
    return wrappedInstance.peakPower(forChannel: channelNumber)
  }

  @objc public func play() -> Bool {
    return wrappedInstance.play()
  }

  @objc public func play(atTime time: TimeInterval) -> Bool {
    return wrappedInstance.play(atTime: time)
  }

  @objc public func prepareToPlay() -> Bool {
    return wrappedInstance.prepareToPlay()
  }

  @objc public func setVolume(_ volume: Float, fadeDuration duration: TimeInterval) {
    return wrappedInstance.setVolume(volume, fadeDuration: duration)
  }

  @objc public func stop() {
    return wrappedInstance.stop()
  }

  @objc public func updateMeters() {
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

  @objc public func nodeTime(forPlayerTime playerTime: AVAudioTimeWrapper) -> AVAudioTimeWrapper? {
    let result = wrappedInstance.nodeTime(forPlayerTime: playerTime.wrappedInstance)
    return result == nil ? nil : AVAudioTimeWrapper(result!)
  }

  @objc public func pause() {
    return wrappedInstance.pause()
  }

  @objc public func play() {
    return wrappedInstance.play()
  }

  @objc public func play(at when: AVAudioTimeWrapper?) {
    return wrappedInstance.play(at: when?.wrappedInstance)
  }

  @objc public func playerTime(forNodeTime nodeTime: AVAudioTimeWrapper) -> AVAudioTimeWrapper? {
    let result = wrappedInstance.playerTime(forNodeTime: nodeTime.wrappedInstance)
    return result == nil ? nil : AVAudioTimeWrapper(result!)
  }

  @objc public func scheduleBuffer(_ buffer: AVAudioPCMBufferWrapper) async {
    return await wrappedInstance.scheduleBuffer(buffer.wrappedInstance)
  }

  @objc public func scheduleFile(_ file: AVAudioFileWrapper, at when: AVAudioTimeWrapper?) async {
    return await wrappedInstance.scheduleFile(file.wrappedInstance, at: when?.wrappedInstance)
  }

  @objc public func stop() {
    return wrappedInstance.stop()
  }

}

@objc public class AVAudioRecorderWrapper: NSObject {
  var wrappedInstance: AVAudioRecorder

  @objc public var currentTime: TimeInterval {
    get {
      wrappedInstance.currentTime
    }
  }

  @objc public var deviceCurrentTime: TimeInterval {
    get {
      wrappedInstance.deviceCurrentTime
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

  @objc public var isRecording: Bool {
    get {
      wrappedInstance.isRecording
    }
  }

  @objc public var url: URL {
    get {
      wrappedInstance.url
    }
  }

  init(_ wrappedInstance: AVAudioRecorder) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(url: URL, format: AVAudioFormatWrapper) throws {
    wrappedInstance = try AVAudioRecorder(url: url, format: format.wrappedInstance)
  }

  @objc public func averagePower(forChannel channelNumber: Int) -> Float {
    return wrappedInstance.averagePower(forChannel: channelNumber)
  }

  @objc public func deleteRecording() -> Bool {
    return wrappedInstance.deleteRecording()
  }

  @objc public func pause() {
    return wrappedInstance.pause()
  }

  @objc public func peakPower(forChannel channelNumber: Int) -> Float {
    return wrappedInstance.peakPower(forChannel: channelNumber)
  }

  @objc public func prepareToRecord() -> Bool {
    return wrappedInstance.prepareToRecord()
  }

  @objc public func record() -> Bool {
    return wrappedInstance.record()
  }

  @objc public func record(atTime time: TimeInterval) -> Bool {
    return wrappedInstance.record(atTime: time)
  }

  @objc public func record(atTime time: TimeInterval, forDuration duration: TimeInterval) -> Bool {
    return wrappedInstance.record(atTime: time, forDuration: duration)
  }

  @objc public func record(forDuration duration: TimeInterval) -> Bool {
    return wrappedInstance.record(forDuration: duration)
  }

  @objc public func stop() {
    return wrappedInstance.stop()
  }

  @objc public func updateMeters() {
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

  @objc public func leave() {
    return wrappedInstance.leave()
  }

}

@objc public class AVAudioSequencerWrapper: NSObject {
  var wrappedInstance: AVAudioSequencer

  @objc public var currentPositionInBeats: TimeInterval {
    get {
      wrappedInstance.currentPositionInBeats
    }
    set {
      wrappedInstance.currentPositionInBeats = newValue
    }
  }

  @objc public var currentPositionInSeconds: TimeInterval {
    get {
      wrappedInstance.currentPositionInSeconds
    }
    set {
      wrappedInstance.currentPositionInSeconds = newValue
    }
  }

  @objc public var isPlaying: Bool {
    get {
      wrappedInstance.isPlaying
    }
  }

  @objc public var rate: Float {
    get {
      wrappedInstance.rate
    }
    set {
      wrappedInstance.rate = newValue
    }
  }

  @objc public var tempoTrack: AVMusicTrackWrapper {
    get {
      AVMusicTrackWrapper(wrappedInstance.tempoTrack)
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

  @objc public func prepareToPlay() {
    return wrappedInstance.prepareToPlay()
  }

  @objc public func removeTrack(_ track: AVMusicTrackWrapper) -> Bool {
    return wrappedInstance.removeTrack(track.wrappedInstance)
  }

  @objc public func reverseEvents() {
    return wrappedInstance.reverseEvents()
  }

  @objc public func start() throws {
    return try wrappedInstance.start()
  }

  @objc public func stop() {
    return wrappedInstance.stop()
  }

  @objc public func write(to fileURL: URL, smpteResolution resolution: Int, replaceExisting replace: Bool) throws {
    return try wrappedInstance.write(to: fileURL, smpteResolution: resolution, replaceExisting: replace)
  }

  @objc public class InfoDictionaryKeyWrapper: NSObject {
    var wrappedInstance: AVAudioSequencer.InfoDictionaryKey

    @objc static public var album: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.album)
      }
    }

    @objc static public var approximateDurationInSeconds: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.approximateDurationInSeconds)
      }
    }

    @objc static public var artist: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.artist)
      }
    }

    @objc static public var channelLayout: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.channelLayout)
      }
    }

    @objc static public var comments: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.comments)
      }
    }

    @objc static public var composer: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.composer)
      }
    }

    @objc static public var copyright: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.copyright)
      }
    }

    @objc static public var encodingApplication: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.encodingApplication)
      }
    }

    @objc static public var genre: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.genre)
      }
    }

    @objc static public var ISRC: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.ISRC)
      }
    }

    @objc static public var keySignature: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.keySignature)
      }
    }

    @objc static public var lyricist: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.lyricist)
      }
    }

    @objc static public var nominalBitRate: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.nominalBitRate)
      }
    }

    @objc static public var recordedDate: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.recordedDate)
      }
    }

    @objc static public var sourceBitDepth: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.sourceBitDepth)
      }
    }

    @objc static public var sourceEncoder: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.sourceEncoder)
      }
    }

    @objc static public var subTitle: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.subTitle)
      }
    }

    @objc static public var tempo: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.tempo)
      }
    }

    @objc static public var timeSignature: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.timeSignature)
      }
    }

    @objc static public var title: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.title)
      }
    }

    @objc static public var trackNumber: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.trackNumber)
      }
    }

    @objc static public var year: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.year)
      }
    }

    init(_ wrappedInstance: AVAudioSequencer.InfoDictionaryKey) {
      self.wrappedInstance = wrappedInstance
    }

    @objc init(rawValue: String) {
      wrappedInstance = AVAudioSequencer.InfoDictionaryKey(rawValue: rawValue)
    }

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

  @objc public func extrapolateTime(fromAnchor anchorTime: AVAudioTimeWrapper) -> AVAudioTimeWrapper? {
    let result = wrappedInstance.extrapolateTime(fromAnchor: anchorTime.wrappedInstance)
    return result == nil ? nil : AVAudioTimeWrapper(result!)
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

  @objc public func loadPreset(at url: URL) throws {
    return try wrappedInstance.loadPreset(at: url)
  }

}

@objc public class AVAudioUnitComponentWrapper: NSObject {
  var wrappedInstance: AVAudioUnitComponent

  @objc public var componentURL: URL? {
    get {
      wrappedInstance.componentURL
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

  @objc public var iconURL: URL? {
    get {
      wrappedInstance.iconURL
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

  @objc public func supportsNumberInputChannels(_ numInputChannels: Int, outputChannels numOutputChannels: Int) -> Bool {
    return wrappedInstance.supportsNumberInputChannels(numInputChannels, outputChannels: numOutputChannels)
  }

}

@objc public class AVAudioUnitComponentManagerWrapper: NSObject {
  var wrappedInstance: AVAudioUnitComponentManager

  init(_ wrappedInstance: AVAudioUnitComponentManager) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class AVAudioUnitDelayWrapper: NSObject {
  var wrappedInstance: AVAudioUnitDelay

  @objc public var delayTime: TimeInterval {
    get {
      wrappedInstance.delayTime
    }
    set {
      wrappedInstance.delayTime = newValue
    }
  }

  @objc public var feedback: Float {
    get {
      wrappedInstance.feedback
    }
    set {
      wrappedInstance.feedback = newValue
    }
  }

  @objc public var lowPassCutoff: Float {
    get {
      wrappedInstance.lowPassCutoff
    }
    set {
      wrappedInstance.lowPassCutoff = newValue
    }
  }

  @objc public var wetDryMix: Float {
    get {
      wrappedInstance.wetDryMix
    }
    set {
      wrappedInstance.wetDryMix = newValue
    }
  }

  init(_ wrappedInstance: AVAudioUnitDelay) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class AVAudioUnitDistortionWrapper: NSObject {
  var wrappedInstance: AVAudioUnitDistortion

  @objc public var preGain: Float {
    get {
      wrappedInstance.preGain
    }
    set {
      wrappedInstance.preGain = newValue
    }
  }

  @objc public var wetDryMix: Float {
    get {
      wrappedInstance.wetDryMix
    }
    set {
      wrappedInstance.wetDryMix = newValue
    }
  }

  init(_ wrappedInstance: AVAudioUnitDistortion) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class AVAudioUnitEQWrapper: NSObject {
  var wrappedInstance: AVAudioUnitEQ

  @objc public var globalGain: Float {
    get {
      wrappedInstance.globalGain
    }
    set {
      wrappedInstance.globalGain = newValue
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

  @objc public var bandwidth: Float {
    get {
      wrappedInstance.bandwidth
    }
    set {
      wrappedInstance.bandwidth = newValue
    }
  }

  @objc public var bypass: Bool {
    get {
      wrappedInstance.bypass
    }
    set {
      wrappedInstance.bypass = newValue
    }
  }

  @objc public var frequency: Float {
    get {
      wrappedInstance.frequency
    }
    set {
      wrappedInstance.frequency = newValue
    }
  }

  @objc public var gain: Float {
    get {
      wrappedInstance.gain
    }
    set {
      wrappedInstance.gain = newValue
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

  @objc public var wetDryMix: Float {
    get {
      wrappedInstance.wetDryMix
    }
    set {
      wrappedInstance.wetDryMix = newValue
    }
  }

  init(_ wrappedInstance: AVAudioUnitReverb) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class AVAudioUnitSamplerWrapper: NSObject {
  var wrappedInstance: AVAudioUnitSampler

  @objc public var globalTuning: Float {
    get {
      wrappedInstance.globalTuning
    }
    set {
      wrappedInstance.globalTuning = newValue
    }
  }

  @objc public var masterGain: Float {
    get {
      wrappedInstance.masterGain
    }
    set {
      wrappedInstance.masterGain = newValue
    }
  }

  @objc public var overallGain: Float {
    get {
      wrappedInstance.overallGain
    }
    set {
      wrappedInstance.overallGain = newValue
    }
  }

  @objc public var stereoPan: Float {
    get {
      wrappedInstance.stereoPan
    }
    set {
      wrappedInstance.stereoPan = newValue
    }
  }

  init(_ wrappedInstance: AVAudioUnitSampler) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func loadInstrument(at instrumentURL: URL) throws {
    return try wrappedInstance.loadInstrument(at: instrumentURL)
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

  @objc public var overlap: Float {
    get {
      wrappedInstance.overlap
    }
    set {
      wrappedInstance.overlap = newValue
    }
  }

  @objc public var pitch: Float {
    get {
      wrappedInstance.pitch
    }
    set {
      wrappedInstance.pitch = newValue
    }
  }

  @objc public var rate: Float {
    get {
      wrappedInstance.rate
    }
    set {
      wrappedInstance.rate = newValue
    }
  }

  init(_ wrappedInstance: AVAudioUnitTimePitch) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class AVAudioUnitVarispeedWrapper: NSObject {
  var wrappedInstance: AVAudioUnitVarispeed

  @objc public var rate: Float {
    get {
      wrappedInstance.rate
    }
    set {
      wrappedInstance.rate = newValue
    }
  }

  init(_ wrappedInstance: AVAudioUnitVarispeed) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class AVExtendedNoteOnEventWrapper: NSObject {
  var wrappedInstance: AVExtendedNoteOnEvent

  @objc public var midiNote: Float {
    get {
      wrappedInstance.midiNote
    }
    set {
      wrappedInstance.midiNote = newValue
    }
  }

  @objc public var velocity: Float {
    get {
      wrappedInstance.velocity
    }
    set {
      wrappedInstance.velocity = newValue
    }
  }

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

  init(_ wrappedInstance: AVMIDIControlChangeEvent) {
    self.wrappedInstance = wrappedInstance
  }

}

@objc public class AVMIDIMetaEventWrapper: NSObject {
  var wrappedInstance: AVMIDIMetaEvent

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

  @objc public var currentPosition: TimeInterval {
    get {
      wrappedInstance.currentPosition
    }
    set {
      wrappedInstance.currentPosition = newValue
    }
  }

  @objc public var duration: TimeInterval {
    get {
      wrappedInstance.duration
    }
  }

  @objc public var isPlaying: Bool {
    get {
      wrappedInstance.isPlaying
    }
  }

  @objc public var rate: Float {
    get {
      wrappedInstance.rate
    }
    set {
      wrappedInstance.rate = newValue
    }
  }

  init(_ wrappedInstance: AVMIDIPlayer) {
    self.wrappedInstance = wrappedInstance
  }

  @objc init(contentsOf inURL: URL, soundBankURL bankURL: URL?) throws {
    wrappedInstance = try AVMIDIPlayer(contentsOf: inURL, soundBankURL: bankURL)
  }

  @objc public func prepareToPlay() {
    return wrappedInstance.prepareToPlay()
  }

  @objc public func stop() {
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

  @objc public var destinationAudioUnit: AVAudioUnitWrapper? {
    get {
      wrappedInstance.destinationAudioUnit == nil ? nil : AVAudioUnitWrapper(wrappedInstance.destinationAudioUnit!)
    }
    set {
      wrappedInstance.destinationAudioUnit = newValue?.wrappedInstance
    }
  }

  @objc public var lengthInSeconds: TimeInterval {
    get {
      wrappedInstance.lengthInSeconds
    }
    set {
      wrappedInstance.lengthInSeconds = newValue
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

  @objc public var value: Float {
    get {
      wrappedInstance.value
    }
    set {
      wrappedInstance.value = newValue
    }
  }

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

  init(_ wrappedInstance: AVSpeechSynthesisProviderAudioUnit) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public func cancelSpeechRequest() {
    return wrappedInstance.cancelSpeechRequest()
  }

  @objc public func synthesizeSpeechRequest(_ speechRequest: AVSpeechSynthesisProviderRequestWrapper) {
    return wrappedInstance.synthesizeSpeechRequest(speechRequest.wrappedInstance)
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

  @objc static public func updateSpeechVoices() {
    return AVSpeechSynthesisProviderVoice.updateSpeechVoices()
  }

}

@objc public class AVSpeechSynthesisVoiceWrapper: NSObject {
  var wrappedInstance: AVSpeechSynthesisVoice

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

  @objc public var voiceTraits: AVSpeechSynthesisVoiceWrapper.TraitsWrapper {
    get {
      TraitsWrapper(wrappedInstance.voiceTraits)
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

  @objc init?(language languageCode: String?) {
    if let instance = AVSpeechSynthesisVoice(language: languageCode) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @objc static public func currentLanguageCode() -> String {
    return AVSpeechSynthesisVoice.currentLanguageCode()
  }

  @objc public class TraitsWrapper: NSObject {
    var wrappedInstance: AVSpeechSynthesisVoice.Traits

    @objc static public var isNoveltyVoice: AVSpeechSynthesisVoiceWrapper.TraitsWrapper {
      get {
        TraitsWrapper(AVSpeechSynthesisVoice.Traits.isNoveltyVoice)
      }
    }

    @objc static public var isPersonalVoice: AVSpeechSynthesisVoiceWrapper.TraitsWrapper {
      get {
        TraitsWrapper(AVSpeechSynthesisVoice.Traits.isPersonalVoice)
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

}

@objc public class AVSpeechSynthesizerWrapper: NSObject {
  var wrappedInstance: AVSpeechSynthesizer

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

  @objc public func continueSpeaking() -> Bool {
    return wrappedInstance.continueSpeaking()
  }

  @objc public func speak(_ utterance: AVSpeechUtteranceWrapper) {
    return wrappedInstance.speak(utterance.wrappedInstance)
  }

}

@objc public class AVSpeechUtteranceWrapper: NSObject {
  var wrappedInstance: AVSpeechUtterance

  @objc public var pitchMultiplier: Float {
    get {
      wrappedInstance.pitchMultiplier
    }
    set {
      wrappedInstance.pitchMultiplier = newValue
    }
  }

  @objc public var postUtteranceDelay: TimeInterval {
    get {
      wrappedInstance.postUtteranceDelay
    }
    set {
      wrappedInstance.postUtteranceDelay = newValue
    }
  }

  @objc public var preUtteranceDelay: TimeInterval {
    get {
      wrappedInstance.preUtteranceDelay
    }
    set {
      wrappedInstance.preUtteranceDelay = newValue
    }
  }

  @objc public var prefersAssistiveTechnologySettings: Bool {
    get {
      wrappedInstance.prefersAssistiveTechnologySettings
    }
    set {
      wrappedInstance.prefersAssistiveTechnologySettings = newValue
    }
  }

  @objc public var rate: Float {
    get {
      wrappedInstance.rate
    }
    set {
      wrappedInstance.rate = newValue
    }
  }

  @objc public var speechString: String {
    get {
      wrappedInstance.speechString
    }
  }

  @objc public var voice: AVSpeechSynthesisVoiceWrapper? {
    get {
      wrappedInstance.voice == nil ? nil : AVSpeechSynthesisVoiceWrapper(wrappedInstance.voice!)
    }
    set {
      wrappedInstance.voice = newValue?.wrappedInstance
    }
  }

  @objc public var volume: Float {
    get {
      wrappedInstance.volume
    }
    set {
      wrappedInstance.volume = newValue
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

  @objc static public var AVSpeechUtteranceDefaultSpeechRateWrapper: Float {
    get {
      AVSpeechUtteranceDefaultSpeechRate
    }
  }

  @objc static public var AVSpeechUtteranceMaximumSpeechRateWrapper: Float {
    get {
      AVSpeechUtteranceMaximumSpeechRate
    }
  }

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

}

