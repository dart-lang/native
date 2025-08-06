
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
@objc public class AVAUPresetEventWrapper: NSObject {
  var wrappedInstance: AVAUPresetEvent

  init(_ wrappedInstance: AVAUPresetEvent) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 14.0)
@objc public class AVAudioApplicationWrapper: NSObject {
  var wrappedInstance: AVAudioApplication

  @available(macOS, introduced: 14.0)
  @objc static public var muteStateKey: String {
    get {
      AVAudioApplication.muteStateKey
    }
  }

  @available(macOS, introduced: 14.0)
  @objc static public var shared: AVAudioApplicationWrapper {
    get {
      AVAudioApplicationWrapper(AVAudioApplication.shared)
    }
  }

  @available(macOS, introduced: 14.0)
  @objc public var isInputMuted: Bool {
    get {
      wrappedInstance.isInputMuted
    }
  }

  init(_ wrappedInstance: AVAudioApplication) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 14.0)
  @objc public func setInputMuted(_ muted: Bool) throws {
    return try wrappedInstance.setInputMuted(muted)
  }

}

@available(macOS, introduced: 10.10)
@objc public class AVAudioBufferWrapper: NSObject {
  var wrappedInstance: AVAudioBuffer

  @available(macOS, introduced: 10.10)
  @objc public var format: AVAudioFormatWrapper {
    get {
      AVAudioFormatWrapper(wrappedInstance.format)
    }
  }

  init(_ wrappedInstance: AVAudioBuffer) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 10.10)
@objc public class AVAudioChannelLayoutWrapper: NSObject {
  var wrappedInstance: AVAudioChannelLayout

  init(_ wrappedInstance: AVAudioChannelLayout) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 10.11)
@objc public class AVAudioCompressedBufferWrapper: NSObject {
  var wrappedInstance: AVAudioCompressedBuffer

  @available(macOS, introduced: 10.11)
  @objc public var maximumPacketSize: Int {
    get {
      wrappedInstance.maximumPacketSize
    }
  }

  init(_ wrappedInstance: AVAudioCompressedBuffer) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 10.11)
@objc public class AVAudioConnectionPointWrapper: NSObject {
  var wrappedInstance: AVAudioConnectionPoint

  @available(macOS, introduced: 10.11)
  @objc public var bus: AVAudioNodeBus {
    get {
      wrappedInstance.bus
    }
  }

  @available(macOS, introduced: 10.11)
  @objc public weak var node: AVAudioNodeWrapper? {
    get {
      wrappedInstance.node == nil ? nil : AVAudioNodeWrapper(wrappedInstance.node!)
    }
  }

  init(_ wrappedInstance: AVAudioConnectionPoint) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.11)
  @objc init(node: AVAudioNodeWrapper, bus: AVAudioNodeBus) {
    wrappedInstance = AVAudioConnectionPoint(node: node.wrappedInstance, bus: bus)
  }

}

@available(macOS, introduced: 10.11)
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

  @available(macOS, introduced: 10.11)
  @objc public var dither: Bool {
    get {
      wrappedInstance.dither
    }
    set {
      wrappedInstance.dither = newValue
    }
  }

  @available(macOS, introduced: 10.11)
  @objc public var downmix: Bool {
    get {
      wrappedInstance.downmix
    }
    set {
      wrappedInstance.downmix = newValue
    }
  }

  @available(macOS, introduced: 10.11)
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

  @available(macOS, introduced: 10.11)
  @objc public var outputFormat: AVAudioFormatWrapper {
    get {
      AVAudioFormatWrapper(wrappedInstance.outputFormat)
    }
  }

  @available(macOS, introduced: 10.11)
  @objc public var primeInfo: AVAudioConverterPrimeInfoWrapper {
    get {
      AVAudioConverterPrimeInfoWrapper(wrappedInstance.primeInfo)
    }
    set {
      wrappedInstance.primeInfo = newValue.wrappedInstance
    }
  }

  @available(macOS, introduced: 10.11)
  @objc public var sampleRateConverterAlgorithm: String? {
    get {
      wrappedInstance.sampleRateConverterAlgorithm
    }
    set {
      wrappedInstance.sampleRateConverterAlgorithm = newValue
    }
  }

  @available(macOS, introduced: 10.11)
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

  @available(macOS, introduced: 10.11)
  @objc init?(from fromFormat: AVAudioFormatWrapper, to toFormat: AVAudioFormatWrapper) {
    if let instance = AVAudioConverter(from: fromFormat.wrappedInstance, to: toFormat.wrappedInstance) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @available(macOS, introduced: 10.11)
  @objc public func convert(to outputBuffer: AVAudioPCMBufferWrapper, from inputBuffer: AVAudioPCMBufferWrapper) throws {
    return try wrappedInstance.convert(to: outputBuffer.wrappedInstance, from: inputBuffer.wrappedInstance)
  }

  @available(macOS, introduced: 10.11)
  @objc public func reset() {
    return wrappedInstance.reset()
  }

}

@available(macOS, introduced: 10.10)
@objc public class AVAudioEngineWrapper: NSObject {
  var wrappedInstance: AVAudioEngine

  @available(macOS, introduced: 10.13)
  @objc public var isAutoShutdownEnabled: Bool {
    get {
      wrappedInstance.isAutoShutdownEnabled
    }
    set {
      wrappedInstance.isAutoShutdownEnabled = newValue
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var inputNode: AVAudioInputNodeWrapper {
    get {
      AVAudioInputNodeWrapper(wrappedInstance.inputNode)
    }
  }

  @available(macOS, introduced: 10.13)
  @objc public var isInManualRenderingMode: Bool {
    get {
      wrappedInstance.isInManualRenderingMode
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var mainMixerNode: AVAudioMixerNodeWrapper {
    get {
      AVAudioMixerNodeWrapper(wrappedInstance.mainMixerNode)
    }
  }

  @available(macOS, introduced: 10.13)
  @objc public var manualRenderingFormat: AVAudioFormatWrapper {
    get {
      AVAudioFormatWrapper(wrappedInstance.manualRenderingFormat)
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var outputNode: AVAudioOutputNodeWrapper {
    get {
      AVAudioOutputNodeWrapper(wrappedInstance.outputNode)
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var isRunning: Bool {
    get {
      wrappedInstance.isRunning
    }
  }

  init(_ wrappedInstance: AVAudioEngine) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.10)
  @objc override init() {
    wrappedInstance = AVAudioEngine()
  }

  @available(macOS, introduced: 10.10)
  @objc public func attach(_ node: AVAudioNodeWrapper) {
    return wrappedInstance.attach(node.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @objc public func connect(_ node1: AVAudioNodeWrapper, to node2: AVAudioNodeWrapper, format: AVAudioFormatWrapper?) {
    return wrappedInstance.connect(node1.wrappedInstance, to: node2.wrappedInstance, format: format?.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @objc public func connect(_ node1: AVAudioNodeWrapper, to node2: AVAudioNodeWrapper, fromBus bus1: AVAudioNodeBus, toBus bus2: AVAudioNodeBus, format: AVAudioFormatWrapper?) {
    return wrappedInstance.connect(node1.wrappedInstance, to: node2.wrappedInstance, fromBus: bus1, toBus: bus2, format: format?.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @objc public func detach(_ node: AVAudioNodeWrapper) {
    return wrappedInstance.detach(node.wrappedInstance)
  }

  @available(macOS, introduced: 10.13)
  @objc public func disableManualRenderingMode() {
    return wrappedInstance.disableManualRenderingMode()
  }

  @available(macOS, introduced: 10.14)
  @objc public func disconnectMIDI(_ sourceNode: AVAudioNodeWrapper, from destinationNode: AVAudioNodeWrapper) {
    return wrappedInstance.disconnectMIDI(sourceNode.wrappedInstance, from: destinationNode.wrappedInstance)
  }

  @available(macOS, introduced: 10.14)
  @objc public func disconnectMIDIInput(_ node: AVAudioNodeWrapper) {
    return wrappedInstance.disconnectMIDIInput(node.wrappedInstance)
  }

  @available(macOS, introduced: 10.14)
  @objc public func disconnectMIDIOutput(_ node: AVAudioNodeWrapper) {
    return wrappedInstance.disconnectMIDIOutput(node.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @objc public func disconnectNodeInput(_ node: AVAudioNodeWrapper) {
    return wrappedInstance.disconnectNodeInput(node.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @objc public func disconnectNodeInput(_ node: AVAudioNodeWrapper, bus: AVAudioNodeBus) {
    return wrappedInstance.disconnectNodeInput(node.wrappedInstance, bus: bus)
  }

  @available(macOS, introduced: 10.10)
  @objc public func disconnectNodeOutput(_ node: AVAudioNodeWrapper) {
    return wrappedInstance.disconnectNodeOutput(node.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @objc public func disconnectNodeOutput(_ node: AVAudioNodeWrapper, bus: AVAudioNodeBus) {
    return wrappedInstance.disconnectNodeOutput(node.wrappedInstance, bus: bus)
  }

  @available(macOS, introduced: 10.11)
  @objc public func inputConnectionPoint(for node: AVAudioNodeWrapper, inputBus bus: AVAudioNodeBus) -> AVAudioConnectionPointWrapper? {
    let result = wrappedInstance.inputConnectionPoint(for: node.wrappedInstance, inputBus: bus)
    return result == nil ? nil : AVAudioConnectionPointWrapper(result!)
  }

  @available(macOS, introduced: 10.10)
  @objc public func pause() {
    return wrappedInstance.pause()
  }

  @available(macOS, introduced: 10.10)
  @objc public func prepare() {
    return wrappedInstance.prepare()
  }

  @available(macOS, introduced: 10.10)
  @objc public func reset() {
    return wrappedInstance.reset()
  }

  @available(macOS, introduced: 10.10)
  @objc public func start() throws {
    return try wrappedInstance.start()
  }

  @available(macOS, introduced: 10.10)
  @objc public func stop() {
    return wrappedInstance.stop()
  }

}

@available(macOS, introduced: 10.10)
@objc public class AVAudioEnvironmentDistanceAttenuationParametersWrapper: NSObject {
  var wrappedInstance: AVAudioEnvironmentDistanceAttenuationParameters

  @available(macOS, introduced: 10.10)
  @objc public var maximumDistance: Float {
    get {
      wrappedInstance.maximumDistance
    }
    set {
      wrappedInstance.maximumDistance = newValue
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var referenceDistance: Float {
    get {
      wrappedInstance.referenceDistance
    }
    set {
      wrappedInstance.referenceDistance = newValue
    }
  }

  @available(macOS, introduced: 10.10)
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

@available(macOS, introduced: 10.10)
@objc public class AVAudioEnvironmentNodeWrapper: NSObject {
  var wrappedInstance: AVAudioEnvironmentNode

  @available(macOS, introduced: 10.10)
  @objc public var distanceAttenuationParameters: AVAudioEnvironmentDistanceAttenuationParametersWrapper {
    get {
      AVAudioEnvironmentDistanceAttenuationParametersWrapper(wrappedInstance.distanceAttenuationParameters)
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var listenerAngularOrientation: AVAudio3DAngularOrientationWrapper {
    get {
      AVAudio3DAngularOrientationWrapper(wrappedInstance.listenerAngularOrientation)
    }
    set {
      wrappedInstance.listenerAngularOrientation = newValue.wrappedInstance
    }
  }

  @available(macOS, introduced: 15.0)
  @objc public var isListenerHeadTrackingEnabled: Bool {
    get {
      wrappedInstance.isListenerHeadTrackingEnabled
    }
    set {
      wrappedInstance.isListenerHeadTrackingEnabled = newValue
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var listenerPosition: AVAudio3DPointWrapper {
    get {
      AVAudio3DPointWrapper(wrappedInstance.listenerPosition)
    }
    set {
      wrappedInstance.listenerPosition = newValue.wrappedInstance
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var listenerVectorOrientation: AVAudio3DVectorOrientationWrapper {
    get {
      AVAudio3DVectorOrientationWrapper(wrappedInstance.listenerVectorOrientation)
    }
    set {
      wrappedInstance.listenerVectorOrientation = newValue.wrappedInstance
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var nextAvailableInputBus: AVAudioNodeBus {
    get {
      wrappedInstance.nextAvailableInputBus
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var outputVolume: Float {
    get {
      wrappedInstance.outputVolume
    }
    set {
      wrappedInstance.outputVolume = newValue
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var reverbParameters: AVAudioEnvironmentReverbParametersWrapper {
    get {
      AVAudioEnvironmentReverbParametersWrapper(wrappedInstance.reverbParameters)
    }
  }

  init(_ wrappedInstance: AVAudioEnvironmentNode) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.10)
  @objc override init() {
    wrappedInstance = AVAudioEnvironmentNode()
  }

}

@available(macOS, introduced: 10.10)
@objc public class AVAudioEnvironmentReverbParametersWrapper: NSObject {
  var wrappedInstance: AVAudioEnvironmentReverbParameters

  @available(macOS, introduced: 10.10)
  @objc public var enable: Bool {
    get {
      wrappedInstance.enable
    }
    set {
      wrappedInstance.enable = newValue
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var filterParameters: AVAudioUnitEQFilterParametersWrapper {
    get {
      AVAudioUnitEQFilterParametersWrapper(wrappedInstance.filterParameters)
    }
  }

  @available(macOS, introduced: 10.10)
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

@available(macOS, introduced: 10.10)
@objc public class AVAudioFileWrapper: NSObject {
  var wrappedInstance: AVAudioFile

  @available(macOS, introduced: 10.10)
  @objc public var fileFormat: AVAudioFormatWrapper {
    get {
      AVAudioFormatWrapper(wrappedInstance.fileFormat)
    }
  }

  @available(macOS, introduced: 15.0)
  @objc public var isOpen: Bool {
    get {
      wrappedInstance.isOpen
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var processingFormat: AVAudioFormatWrapper {
    get {
      AVAudioFormatWrapper(wrappedInstance.processingFormat)
    }
  }

  init(_ wrappedInstance: AVAudioFile) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 15.0)
  @objc public func close() {
    return wrappedInstance.close()
  }

  @available(macOS, introduced: 10.10)
  @objc public func read(into buffer: AVAudioPCMBufferWrapper) throws {
    return try wrappedInstance.read(into: buffer.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @objc public func write(from buffer: AVAudioPCMBufferWrapper) throws {
    return try wrappedInstance.write(from: buffer.wrappedInstance)
  }

}

@available(macOS, introduced: 10.10)
@objc public class AVAudioFormatWrapper: NSObject {
  var wrappedInstance: AVAudioFormat

  @available(macOS, introduced: 10.10)
  @objc public var channelLayout: AVAudioChannelLayoutWrapper? {
    get {
      wrappedInstance.channelLayout == nil ? nil : AVAudioChannelLayoutWrapper(wrappedInstance.channelLayout!)
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var isInterleaved: Bool {
    get {
      wrappedInstance.isInterleaved
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var sampleRate: Double {
    get {
      wrappedInstance.sampleRate
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var isStandard: Bool {
    get {
      wrappedInstance.isStandard
    }
  }

  init(_ wrappedInstance: AVAudioFormat) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.10)
  @objc init(standardFormatWithSampleRate sampleRate: Double, channelLayout layout: AVAudioChannelLayoutWrapper) {
    wrappedInstance = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channelLayout: layout.wrappedInstance)
  }

}

@available(macOS, introduced: 10.10)
@objc public class AVAudioIONodeWrapper: NSObject {
  var wrappedInstance: AVAudioIONode

  @available(macOS, introduced: 10.15)
  @objc public var isVoiceProcessingEnabled: Bool {
    get {
      wrappedInstance.isVoiceProcessingEnabled
    }
  }

  init(_ wrappedInstance: AVAudioIONode) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.15)
  @objc public func setVoiceProcessingEnabled(_ enabled: Bool) throws {
    return try wrappedInstance.setVoiceProcessingEnabled(enabled)
  }

}

@available(macOS, introduced: 10.10)
@objc public class AVAudioInputNodeWrapper: NSObject {
  var wrappedInstance: AVAudioInputNode

  @available(macOS, introduced: 10.15)
  @objc public var isVoiceProcessingAGCEnabled: Bool {
    get {
      wrappedInstance.isVoiceProcessingAGCEnabled
    }
    set {
      wrappedInstance.isVoiceProcessingAGCEnabled = newValue
    }
  }

  @available(macOS, introduced: 10.15)
  @objc public var isVoiceProcessingBypassed: Bool {
    get {
      wrappedInstance.isVoiceProcessingBypassed
    }
    set {
      wrappedInstance.isVoiceProcessingBypassed = newValue
    }
  }

  @available(macOS, introduced: 10.15)
  @objc public var isVoiceProcessingInputMuted: Bool {
    get {
      wrappedInstance.isVoiceProcessingInputMuted
    }
    set {
      wrappedInstance.isVoiceProcessingInputMuted = newValue
    }
  }

  @available(macOS, introduced: 14.0)
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

@available(macOS, introduced: 10.10)
@objc public class AVAudioMixerNodeWrapper: NSObject {
  var wrappedInstance: AVAudioMixerNode

  @available(macOS, introduced: 10.10)
  @objc public var nextAvailableInputBus: AVAudioNodeBus {
    get {
      wrappedInstance.nextAvailableInputBus
    }
  }

  @available(macOS, introduced: 10.10)
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

  @available(macOS, introduced: 10.10)
  @objc override init() {
    wrappedInstance = AVAudioMixerNode()
  }

}

@available(macOS, introduced: 10.11)
@objc public class AVAudioMixingDestinationWrapper: NSObject {
  var wrappedInstance: AVAudioMixingDestination

  @available(macOS, introduced: 10.11)
  @objc public var connectionPoint: AVAudioConnectionPointWrapper {
    get {
      AVAudioConnectionPointWrapper(wrappedInstance.connectionPoint)
    }
  }

  init(_ wrappedInstance: AVAudioMixingDestination) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 10.10)
@objc public class AVAudioNodeWrapper: NSObject {
  var wrappedInstance: AVAudioNode

  @available(macOS, introduced: 10.10)
  @objc public var engine: AVAudioEngineWrapper? {
    get {
      wrappedInstance.engine == nil ? nil : AVAudioEngineWrapper(wrappedInstance.engine!)
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var lastRenderTime: AVAudioTimeWrapper? {
    get {
      wrappedInstance.lastRenderTime == nil ? nil : AVAudioTimeWrapper(wrappedInstance.lastRenderTime!)
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var numberOfInputs: Int {
    get {
      wrappedInstance.numberOfInputs
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var numberOfOutputs: Int {
    get {
      wrappedInstance.numberOfOutputs
    }
  }

  init(_ wrappedInstance: AVAudioNode) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.10)
  @objc public func inputFormat(forBus bus: AVAudioNodeBus) -> AVAudioFormatWrapper {
    let result = wrappedInstance.inputFormat(forBus: bus)
    return AVAudioFormatWrapper(result)
  }

  @available(macOS, introduced: 10.10)
  @objc public func name(forInputBus bus: AVAudioNodeBus) -> String? {
    return wrappedInstance.name(forInputBus: bus)
  }

  @available(macOS, introduced: 10.10)
  @objc public func name(forOutputBus bus: AVAudioNodeBus) -> String? {
    return wrappedInstance.name(forOutputBus: bus)
  }

  @available(macOS, introduced: 10.10)
  @objc public func outputFormat(forBus bus: AVAudioNodeBus) -> AVAudioFormatWrapper {
    let result = wrappedInstance.outputFormat(forBus: bus)
    return AVAudioFormatWrapper(result)
  }

  @available(macOS, introduced: 10.10)
  @objc public func removeTap(onBus bus: AVAudioNodeBus) {
    return wrappedInstance.removeTap(onBus: bus)
  }

  @available(macOS, introduced: 10.10)
  @objc public func reset() {
    return wrappedInstance.reset()
  }

}

@available(macOS, introduced: 10.10)
@objc public class AVAudioOutputNodeWrapper: NSObject {
  var wrappedInstance: AVAudioOutputNode

  init(_ wrappedInstance: AVAudioOutputNode) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 10.10)
@objc public class AVAudioPCMBufferWrapper: NSObject {
  var wrappedInstance: AVAudioPCMBuffer

  @available(macOS, introduced: 10.10)
  @objc public var stride: Int {
    get {
      wrappedInstance.stride
    }
  }

  init(_ wrappedInstance: AVAudioPCMBuffer) {
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
  @objc public func prepareToPlay() -> Bool {
    return wrappedInstance.prepareToPlay()
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

@available(macOS, introduced: 10.10)
@objc public class AVAudioPlayerNodeWrapper: NSObject {
  var wrappedInstance: AVAudioPlayerNode

  @available(macOS, introduced: 10.10)
  @objc public var isPlaying: Bool {
    get {
      wrappedInstance.isPlaying
    }
  }

  init(_ wrappedInstance: AVAudioPlayerNode) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.10)
  @objc override init() {
    wrappedInstance = AVAudioPlayerNode()
  }

  @available(macOS, introduced: 10.10)
  @objc public func nodeTime(forPlayerTime playerTime: AVAudioTimeWrapper) -> AVAudioTimeWrapper? {
    let result = wrappedInstance.nodeTime(forPlayerTime: playerTime.wrappedInstance)
    return result == nil ? nil : AVAudioTimeWrapper(result!)
  }

  @available(macOS, introduced: 10.10)
  @objc public func pause() {
    return wrappedInstance.pause()
  }

  @available(macOS, introduced: 10.10)
  @objc public func play() {
    return wrappedInstance.play()
  }

  @available(macOS, introduced: 10.10)
  @objc public func play(at when: AVAudioTimeWrapper?) {
    return wrappedInstance.play(at: when?.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @objc public func playerTime(forNodeTime nodeTime: AVAudioTimeWrapper) -> AVAudioTimeWrapper? {
    let result = wrappedInstance.playerTime(forNodeTime: nodeTime.wrappedInstance)
    return result == nil ? nil : AVAudioTimeWrapper(result!)
  }

  @available(macOS, introduced: 10.10)
  @objc public func scheduleFile(_ file: AVAudioFileWrapper, at when: AVAudioTimeWrapper?) async {
    return await wrappedInstance.scheduleFile(file.wrappedInstance, at: when?.wrappedInstance)
  }

  @available(macOS, introduced: 10.10)
  @objc public func stop() {
    return wrappedInstance.stop()
  }

}

@available(macOS, introduced: 10.7)
@objc public class AVAudioRecorderWrapper: NSObject {
  var wrappedInstance: AVAudioRecorder

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
  @objc public var isRecording: Bool {
    get {
      wrappedInstance.isRecording
    }
  }

  init(_ wrappedInstance: AVAudioRecorder) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.7)
  @objc public func averagePower(forChannel channelNumber: Int) -> Float {
    return wrappedInstance.averagePower(forChannel: channelNumber)
  }

  @available(macOS, introduced: 10.7)
  @objc public func deleteRecording() -> Bool {
    return wrappedInstance.deleteRecording()
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
  @objc public func prepareToRecord() -> Bool {
    return wrappedInstance.prepareToRecord()
  }

  @available(macOS, introduced: 10.7)
  @objc public func record() -> Bool {
    return wrappedInstance.record()
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

@available(macOS, introduced: 11.0)
@objc public class AVAudioRoutingArbiterWrapper: NSObject {
  var wrappedInstance: AVAudioRoutingArbiter

  @available(macOS, introduced: 11.0)
  @objc static public var shared: AVAudioRoutingArbiterWrapper {
    get {
      AVAudioRoutingArbiterWrapper(AVAudioRoutingArbiter.shared)
    }
  }

  init(_ wrappedInstance: AVAudioRoutingArbiter) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 11.0)
  @objc public func leave() {
    return wrappedInstance.leave()
  }

}

@available(macOS, introduced: 10.11)
@objc public class AVAudioSequencerWrapper: NSObject {
  var wrappedInstance: AVAudioSequencer

  @available(macOS, introduced: 10.11)
  @objc public var isPlaying: Bool {
    get {
      wrappedInstance.isPlaying
    }
  }

  @available(macOS, introduced: 10.11)
  @objc public var rate: Float {
    get {
      wrappedInstance.rate
    }
    set {
      wrappedInstance.rate = newValue
    }
  }

  @available(macOS, introduced: 10.11)
  @objc public var tempoTrack: AVMusicTrackWrapper {
    get {
      AVMusicTrackWrapper(wrappedInstance.tempoTrack)
    }
  }

  init(_ wrappedInstance: AVAudioSequencer) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.11)
  @objc override init() {
    wrappedInstance = AVAudioSequencer()
  }

  @available(macOS, introduced: 10.11)
  @objc init(audioEngine engine: AVAudioEngineWrapper) {
    wrappedInstance = AVAudioSequencer(audioEngine: engine.wrappedInstance)
  }

  @available(macOS, introduced: 13.0)
  @objc public func createAndAppendTrack() -> AVMusicTrackWrapper {
    let result = wrappedInstance.createAndAppendTrack()
    return AVMusicTrackWrapper(result)
  }

  @available(macOS, introduced: 10.11)
  @objc public func prepareToPlay() {
    return wrappedInstance.prepareToPlay()
  }

  @available(macOS, introduced: 13.0)
  @objc public func removeTrack(_ track: AVMusicTrackWrapper) -> Bool {
    return wrappedInstance.removeTrack(track.wrappedInstance)
  }

  @available(macOS, introduced: 13.0)
  @objc public func reverseEvents() {
    return wrappedInstance.reverseEvents()
  }

  @available(macOS, introduced: 10.11)
  @objc public func start() throws {
    return try wrappedInstance.start()
  }

  @available(macOS, introduced: 10.11)
  @objc public func stop() {
    return wrappedInstance.stop()
  }

  @available(macOS, introduced: 13.0)
  @objc public class InfoDictionaryKeyWrapper: NSObject {
    var wrappedInstance: AVAudioSequencer.InfoDictionaryKey

    @available(macOS, introduced: 13.0)
    @objc static public var album: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.album)
      }
    }

    @available(macOS, introduced: 13.0)
    @objc static public var approximateDurationInSeconds: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.approximateDurationInSeconds)
      }
    }

    @available(macOS, introduced: 13.0)
    @objc static public var artist: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.artist)
      }
    }

    @available(macOS, introduced: 13.0)
    @objc static public var channelLayout: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.channelLayout)
      }
    }

    @available(macOS, introduced: 13.0)
    @objc static public var comments: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.comments)
      }
    }

    @available(macOS, introduced: 13.0)
    @objc static public var composer: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.composer)
      }
    }

    @available(macOS, introduced: 13.0)
    @objc static public var copyright: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.copyright)
      }
    }

    @available(macOS, introduced: 13.0)
    @objc static public var encodingApplication: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.encodingApplication)
      }
    }

    @available(macOS, introduced: 13.0)
    @objc static public var genre: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.genre)
      }
    }

    @available(macOS, introduced: 13.0)
    @objc static public var ISRC: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.ISRC)
      }
    }

    @available(macOS, introduced: 13.0)
    @objc static public var keySignature: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.keySignature)
      }
    }

    @available(macOS, introduced: 13.0)
    @objc static public var lyricist: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.lyricist)
      }
    }

    @available(macOS, introduced: 13.0)
    @objc static public var nominalBitRate: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.nominalBitRate)
      }
    }

    @available(macOS, introduced: 13.0)
    @objc static public var recordedDate: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.recordedDate)
      }
    }

    @available(macOS, introduced: 13.0)
    @objc static public var sourceBitDepth: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.sourceBitDepth)
      }
    }

    @available(macOS, introduced: 13.0)
    @objc static public var sourceEncoder: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.sourceEncoder)
      }
    }

    @available(macOS, introduced: 13.0)
    @objc static public var subTitle: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.subTitle)
      }
    }

    @available(macOS, introduced: 13.0)
    @objc static public var tempo: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.tempo)
      }
    }

    @available(macOS, introduced: 13.0)
    @objc static public var timeSignature: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.timeSignature)
      }
    }

    @available(macOS, introduced: 13.0)
    @objc static public var title: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.title)
      }
    }

    @available(macOS, introduced: 13.0)
    @objc static public var trackNumber: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.trackNumber)
      }
    }

    @available(macOS, introduced: 13.0)
    @objc static public var year: AVAudioSequencerWrapper.InfoDictionaryKeyWrapper {
      get {
        InfoDictionaryKeyWrapper(AVAudioSequencer.InfoDictionaryKey.year)
      }
    }

    init(_ wrappedInstance: AVAudioSequencer.InfoDictionaryKey) {
      self.wrappedInstance = wrappedInstance
    }

    @available(macOS, introduced: 13.0)
    @objc init(rawValue: String) {
      wrappedInstance = AVAudioSequencer.InfoDictionaryKey(rawValue: rawValue)
    }

  }

}

@available(macOS, introduced: 10.15)
@objc public class AVAudioSinkNodeWrapper: NSObject {
  var wrappedInstance: AVAudioSinkNode

  init(_ wrappedInstance: AVAudioSinkNode) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 10.15)
@objc public class AVAudioSourceNodeWrapper: NSObject {
  var wrappedInstance: AVAudioSourceNode

  init(_ wrappedInstance: AVAudioSourceNode) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 10.10)
@objc public class AVAudioTimeWrapper: NSObject {
  var wrappedInstance: AVAudioTime

  @available(macOS, introduced: 10.10)
  @objc public var isHostTimeValid: Bool {
    get {
      wrappedInstance.isHostTimeValid
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var sampleRate: Double {
    get {
      wrappedInstance.sampleRate
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var isSampleTimeValid: Bool {
    get {
      wrappedInstance.isSampleTimeValid
    }
  }

  init(_ wrappedInstance: AVAudioTime) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.10)
  @objc public func extrapolateTime(fromAnchor anchorTime: AVAudioTimeWrapper) -> AVAudioTimeWrapper? {
    let result = wrappedInstance.extrapolateTime(fromAnchor: anchorTime.wrappedInstance)
    return result == nil ? nil : AVAudioTimeWrapper(result!)
  }

}

@available(macOS, introduced: 10.10)
@objc public class AVAudioUnitWrapper: NSObject {
  var wrappedInstance: AVAudioUnit

  @available(macOS, introduced: 10.10)
  @objc public var manufacturerName: String {
    get {
      wrappedInstance.manufacturerName
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var name: String {
    get {
      wrappedInstance.name
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var version: Int {
    get {
      wrappedInstance.version
    }
  }

  init(_ wrappedInstance: AVAudioUnit) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 10.10)
@objc public class AVAudioUnitComponentWrapper: NSObject {
  var wrappedInstance: AVAudioUnitComponent

  @available(macOS, introduced: 10.10)
  @objc public var hasCustomView: Bool {
    get {
      wrappedInstance.hasCustomView
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var hasMIDIInput: Bool {
    get {
      wrappedInstance.hasMIDIInput
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var hasMIDIOutput: Bool {
    get {
      wrappedInstance.hasMIDIOutput
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var localizedTypeName: String {
    get {
      wrappedInstance.localizedTypeName
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var manufacturerName: String {
    get {
      wrappedInstance.manufacturerName
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var name: String {
    get {
      wrappedInstance.name
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var passesAUVal: Bool {
    get {
      wrappedInstance.passesAUVal
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var isSandboxSafe: Bool {
    get {
      wrappedInstance.isSandboxSafe
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var typeName: String {
    get {
      wrappedInstance.typeName
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var version: Int {
    get {
      wrappedInstance.version
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var versionString: String {
    get {
      wrappedInstance.versionString
    }
  }

  init(_ wrappedInstance: AVAudioUnitComponent) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.10)
  @objc public func supportsNumberInputChannels(_ numInputChannels: Int, outputChannels numOutputChannels: Int) -> Bool {
    return wrappedInstance.supportsNumberInputChannels(numInputChannels, outputChannels: numOutputChannels)
  }

}

@available(macOS, introduced: 10.10)
@objc public class AVAudioUnitComponentManagerWrapper: NSObject {
  var wrappedInstance: AVAudioUnitComponentManager

  init(_ wrappedInstance: AVAudioUnitComponentManager) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 10.10)
@objc public class AVAudioUnitDelayWrapper: NSObject {
  var wrappedInstance: AVAudioUnitDelay

  @available(macOS, introduced: 10.10)
  @objc public var feedback: Float {
    get {
      wrappedInstance.feedback
    }
    set {
      wrappedInstance.feedback = newValue
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var lowPassCutoff: Float {
    get {
      wrappedInstance.lowPassCutoff
    }
    set {
      wrappedInstance.lowPassCutoff = newValue
    }
  }

  @available(macOS, introduced: 10.10)
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

@available(macOS, introduced: 10.10)
@objc public class AVAudioUnitDistortionWrapper: NSObject {
  var wrappedInstance: AVAudioUnitDistortion

  @available(macOS, introduced: 10.10)
  @objc public var preGain: Float {
    get {
      wrappedInstance.preGain
    }
    set {
      wrappedInstance.preGain = newValue
    }
  }

  @available(macOS, introduced: 10.10)
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

@available(macOS, introduced: 10.10)
@objc public class AVAudioUnitEQWrapper: NSObject {
  var wrappedInstance: AVAudioUnitEQ

  @available(macOS, introduced: 10.10)
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

  @available(macOS, introduced: 10.10)
  @objc init(numberOfBands: Int) {
    wrappedInstance = AVAudioUnitEQ(numberOfBands: numberOfBands)
  }

}

@available(macOS, introduced: 10.10)
@objc public class AVAudioUnitEQFilterParametersWrapper: NSObject {
  var wrappedInstance: AVAudioUnitEQFilterParameters

  @available(macOS, introduced: 10.10)
  @objc public var bandwidth: Float {
    get {
      wrappedInstance.bandwidth
    }
    set {
      wrappedInstance.bandwidth = newValue
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var bypass: Bool {
    get {
      wrappedInstance.bypass
    }
    set {
      wrappedInstance.bypass = newValue
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var frequency: Float {
    get {
      wrappedInstance.frequency
    }
    set {
      wrappedInstance.frequency = newValue
    }
  }

  @available(macOS, introduced: 10.10)
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

@available(macOS, introduced: 10.10)
@objc public class AVAudioUnitEffectWrapper: NSObject {
  var wrappedInstance: AVAudioUnitEffect

  @available(macOS, introduced: 10.10)
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

@available(macOS, introduced: 10.10)
@objc public class AVAudioUnitGeneratorWrapper: NSObject {
  var wrappedInstance: AVAudioUnitGenerator

  @available(macOS, introduced: 10.10)
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

@available(macOS, introduced: 10.10)
@objc public class AVAudioUnitMIDIInstrumentWrapper: NSObject {
  var wrappedInstance: AVAudioUnitMIDIInstrument

  init(_ wrappedInstance: AVAudioUnitMIDIInstrument) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 10.10)
@objc public class AVAudioUnitReverbWrapper: NSObject {
  var wrappedInstance: AVAudioUnitReverb

  @available(macOS, introduced: 10.10)
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

@available(macOS, introduced: 10.10)
@objc public class AVAudioUnitSamplerWrapper: NSObject {
  var wrappedInstance: AVAudioUnitSampler

  @available(macOS, introduced: 10.10)
  @objc public var globalTuning: Float {
    get {
      wrappedInstance.globalTuning
    }
    set {
      wrappedInstance.globalTuning = newValue
    }
  }

  @available(macOS, introduced: 10.10, deprecated: 12.0)
  @objc public var masterGain: Float {
    get {
      wrappedInstance.masterGain
    }
    set {
      wrappedInstance.masterGain = newValue
    }
  }

  @available(macOS, introduced: 12.0)
  @objc public var overallGain: Float {
    get {
      wrappedInstance.overallGain
    }
    set {
      wrappedInstance.overallGain = newValue
    }
  }

  @available(macOS, introduced: 10.10)
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

}

@available(macOS, introduced: 10.10)
@objc public class AVAudioUnitTimeEffectWrapper: NSObject {
  var wrappedInstance: AVAudioUnitTimeEffect

  @available(macOS, introduced: 10.10)
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

@available(macOS, introduced: 10.10)
@objc public class AVAudioUnitTimePitchWrapper: NSObject {
  var wrappedInstance: AVAudioUnitTimePitch

  @available(macOS, introduced: 10.10)
  @objc public var overlap: Float {
    get {
      wrappedInstance.overlap
    }
    set {
      wrappedInstance.overlap = newValue
    }
  }

  @available(macOS, introduced: 10.10)
  @objc public var pitch: Float {
    get {
      wrappedInstance.pitch
    }
    set {
      wrappedInstance.pitch = newValue
    }
  }

  @available(macOS, introduced: 10.10)
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

@available(macOS, introduced: 10.10)
@objc public class AVAudioUnitVarispeedWrapper: NSObject {
  var wrappedInstance: AVAudioUnitVarispeed

  @available(macOS, introduced: 10.10)
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

@available(macOS, introduced: 13.0)
@objc public class AVExtendedNoteOnEventWrapper: NSObject {
  var wrappedInstance: AVExtendedNoteOnEvent

  @available(macOS, introduced: 13.0)
  @objc public var duration: AVMusicTimeStamp {
    get {
      wrappedInstance.duration
    }
    set {
      wrappedInstance.duration = newValue
    }
  }

  @available(macOS, introduced: 13.0)
  @objc public var midiNote: Float {
    get {
      wrappedInstance.midiNote
    }
    set {
      wrappedInstance.midiNote = newValue
    }
  }

  @available(macOS, introduced: 13.0)
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

@available(macOS, introduced: 13.0)
@objc public class AVExtendedTempoEventWrapper: NSObject {
  var wrappedInstance: AVExtendedTempoEvent

  @available(macOS, introduced: 13.0)
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

  @available(macOS, introduced: 13.0)
  @objc init(tempo: Double) {
    wrappedInstance = AVExtendedTempoEvent(tempo: tempo)
  }

}

@available(macOS, introduced: 13.0)
@objc public class AVMIDIChannelEventWrapper: NSObject {
  var wrappedInstance: AVMIDIChannelEvent

  init(_ wrappedInstance: AVMIDIChannelEvent) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 13.0)
@objc public class AVMIDIChannelPressureEventWrapper: NSObject {
  var wrappedInstance: AVMIDIChannelPressureEvent

  init(_ wrappedInstance: AVMIDIChannelPressureEvent) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 13.0)
@objc public class AVMIDIControlChangeEventWrapper: NSObject {
  var wrappedInstance: AVMIDIControlChangeEvent

  init(_ wrappedInstance: AVMIDIControlChangeEvent) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 13.0)
@objc public class AVMIDIMetaEventWrapper: NSObject {
  var wrappedInstance: AVMIDIMetaEvent

  init(_ wrappedInstance: AVMIDIMetaEvent) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 13.0)
@objc public class AVMIDINoteEventWrapper: NSObject {
  var wrappedInstance: AVMIDINoteEvent

  @available(macOS, introduced: 13.0)
  @objc public var duration: AVMusicTimeStamp {
    get {
      wrappedInstance.duration
    }
    set {
      wrappedInstance.duration = newValue
    }
  }

  init(_ wrappedInstance: AVMIDINoteEvent) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 13.0)
@objc public class AVMIDIPitchBendEventWrapper: NSObject {
  var wrappedInstance: AVMIDIPitchBendEvent

  init(_ wrappedInstance: AVMIDIPitchBendEvent) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 10.10)
@objc public class AVMIDIPlayerWrapper: NSObject {
  var wrappedInstance: AVMIDIPlayer

  @available(macOS, introduced: 10.10)
  @objc public var isPlaying: Bool {
    get {
      wrappedInstance.isPlaying
    }
  }

  @available(macOS, introduced: 10.10)
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

  @available(macOS, introduced: 10.10)
  @objc public func prepareToPlay() {
    return wrappedInstance.prepareToPlay()
  }

  @available(macOS, introduced: 10.10)
  @objc public func stop() {
    return wrappedInstance.stop()
  }

}

@available(macOS, introduced: 13.0)
@objc public class AVMIDIPolyPressureEventWrapper: NSObject {
  var wrappedInstance: AVMIDIPolyPressureEvent

  init(_ wrappedInstance: AVMIDIPolyPressureEvent) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 13.0)
@objc public class AVMIDIProgramChangeEventWrapper: NSObject {
  var wrappedInstance: AVMIDIProgramChangeEvent

  init(_ wrappedInstance: AVMIDIProgramChangeEvent) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 13.0)
@objc public class AVMIDISysexEventWrapper: NSObject {
  var wrappedInstance: AVMIDISysexEvent

  init(_ wrappedInstance: AVMIDISysexEvent) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 13.0)
@objc public class AVMusicEventWrapper: NSObject {
  var wrappedInstance: AVMusicEvent

  init(_ wrappedInstance: AVMusicEvent) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 10.11)
@objc public class AVMusicTrackWrapper: NSObject {
  var wrappedInstance: AVMusicTrack

  @available(macOS, introduced: 10.11)
  @objc public var destinationAudioUnit: AVAudioUnitWrapper? {
    get {
      wrappedInstance.destinationAudioUnit == nil ? nil : AVAudioUnitWrapper(wrappedInstance.destinationAudioUnit!)
    }
    set {
      wrappedInstance.destinationAudioUnit = newValue?.wrappedInstance
    }
  }

  @available(macOS, introduced: 10.11)
  @objc public var lengthInBeats: AVMusicTimeStamp {
    get {
      wrappedInstance.lengthInBeats
    }
    set {
      wrappedInstance.lengthInBeats = newValue
    }
  }

  @available(macOS, introduced: 10.11)
  @objc public var isLoopingEnabled: Bool {
    get {
      wrappedInstance.isLoopingEnabled
    }
    set {
      wrappedInstance.isLoopingEnabled = newValue
    }
  }

  @available(macOS, introduced: 10.11)
  @objc public var isMuted: Bool {
    get {
      wrappedInstance.isMuted
    }
    set {
      wrappedInstance.isMuted = newValue
    }
  }

  @available(macOS, introduced: 10.11)
  @objc public var numberOfLoops: Int {
    get {
      wrappedInstance.numberOfLoops
    }
    set {
      wrappedInstance.numberOfLoops = newValue
    }
  }

  @available(macOS, introduced: 10.11)
  @objc public var offsetTime: AVMusicTimeStamp {
    get {
      wrappedInstance.offsetTime
    }
    set {
      wrappedInstance.offsetTime = newValue
    }
  }

  @available(macOS, introduced: 10.11)
  @objc public var isSoloed: Bool {
    get {
      wrappedInstance.isSoloed
    }
    set {
      wrappedInstance.isSoloed = newValue
    }
  }

  @available(macOS, introduced: 10.11)
  @objc public var timeResolution: Int {
    get {
      wrappedInstance.timeResolution
    }
  }

  @available(macOS, introduced: 13.0)
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

  @available(macOS, introduced: 13.0)
  @objc public func addEvent(_ event: AVMusicEventWrapper, at beat: AVMusicTimeStamp) {
    return wrappedInstance.addEvent(event.wrappedInstance, at: beat)
  }

}

@available(macOS, introduced: 13.0)
@objc public class AVMusicUserEventWrapper: NSObject {
  var wrappedInstance: AVMusicUserEvent

  init(_ wrappedInstance: AVMusicUserEvent) {
    self.wrappedInstance = wrappedInstance
  }

}

@available(macOS, introduced: 13.0)
@objc public class AVParameterEventWrapper: NSObject {
  var wrappedInstance: AVParameterEvent

  @available(macOS, introduced: 13.0)
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

@available(macOS, introduced: 13.0)
@objc public class AVSpeechSynthesisMarkerWrapper: NSObject {
  var wrappedInstance: AVSpeechSynthesisMarker

  @available(macOS, introduced: 14.0)
  @objc public var bookmarkName: String {
    get {
      wrappedInstance.bookmarkName
    }
    set {
      wrappedInstance.bookmarkName = newValue
    }
  }

  @available(macOS, introduced: 13.0)
  @objc public var byteSampleOffset: Int {
    get {
      wrappedInstance.byteSampleOffset
    }
    set {
      wrappedInstance.byteSampleOffset = newValue
    }
  }

  @available(macOS, introduced: 14.0)
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

  @available(macOS, introduced: 14.0)
  @objc init(bookmarkName mark: String, atByteSampleOffset byteSampleOffset: Int) {
    wrappedInstance = AVSpeechSynthesisMarker(bookmarkName: mark, atByteSampleOffset: byteSampleOffset)
  }

  @available(macOS, introduced: 14.0)
  @objc init(phonemeString phoneme: String, atByteSampleOffset byteSampleOffset: Int) {
    wrappedInstance = AVSpeechSynthesisMarker(phonemeString: phoneme, atByteSampleOffset: byteSampleOffset)
  }

}

@available(macOS, introduced: 13.0)
@objc public class AVSpeechSynthesisProviderAudioUnitWrapper: NSObject {
  var wrappedInstance: AVSpeechSynthesisProviderAudioUnit

  init(_ wrappedInstance: AVSpeechSynthesisProviderAudioUnit) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 13.0)
  @objc public func cancelSpeechRequest() {
    return wrappedInstance.cancelSpeechRequest()
  }

  @available(macOS, introduced: 13.0)
  @objc public func synthesizeSpeechRequest(_ speechRequest: AVSpeechSynthesisProviderRequestWrapper) {
    return wrappedInstance.synthesizeSpeechRequest(speechRequest.wrappedInstance)
  }

}

@available(macOS, introduced: 13.0)
@objc public class AVSpeechSynthesisProviderRequestWrapper: NSObject {
  var wrappedInstance: AVSpeechSynthesisProviderRequest

  @available(macOS, introduced: 13.0)
  @objc public var ssmlRepresentation: String {
    get {
      wrappedInstance.ssmlRepresentation
    }
  }

  @available(macOS, introduced: 13.0)
  @objc public var voice: AVSpeechSynthesisProviderVoiceWrapper {
    get {
      AVSpeechSynthesisProviderVoiceWrapper(wrappedInstance.voice)
    }
  }

  init(_ wrappedInstance: AVSpeechSynthesisProviderRequest) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 13.0)
  @objc init(ssmlRepresentation text: String, voice: AVSpeechSynthesisProviderVoiceWrapper) {
    wrappedInstance = AVSpeechSynthesisProviderRequest(ssmlRepresentation: text, voice: voice.wrappedInstance)
  }

}

@available(macOS, introduced: 13.0)
@objc public class AVSpeechSynthesisProviderVoiceWrapper: NSObject {
  var wrappedInstance: AVSpeechSynthesisProviderVoice

  @available(macOS, introduced: 13.0)
  @objc public var age: Int {
    get {
      wrappedInstance.age
    }
    set {
      wrappedInstance.age = newValue
    }
  }

  @available(macOS, introduced: 13.0)
  @objc public var identifier: String {
    get {
      wrappedInstance.identifier
    }
  }

  @available(macOS, introduced: 13.0)
  @objc public var name: String {
    get {
      wrappedInstance.name
    }
  }

  @available(macOS, introduced: 13.0)
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

  @available(macOS, introduced: 13.0)
  @objc static public func updateSpeechVoices() {
    return AVSpeechSynthesisProviderVoice.updateSpeechVoices()
  }

}

@available(macOS, introduced: 10.14)
@objc public class AVSpeechSynthesisVoiceWrapper: NSObject {
  var wrappedInstance: AVSpeechSynthesisVoice

  @available(macOS, introduced: 10.14)
  @objc public var identifier: String {
    get {
      wrappedInstance.identifier
    }
  }

  @available(macOS, introduced: 10.14)
  @objc public var language: String {
    get {
      wrappedInstance.language
    }
  }

  @available(macOS, introduced: 10.14)
  @objc public var name: String {
    get {
      wrappedInstance.name
    }
  }

  @available(macOS, introduced: 14.0)
  @objc public var voiceTraits: AVSpeechSynthesisVoiceWrapper.TraitsWrapper {
    get {
      TraitsWrapper(wrappedInstance.voiceTraits)
    }
  }

  init(_ wrappedInstance: AVSpeechSynthesisVoice) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.14)
  @objc init?(identifier: String) {
    if let instance = AVSpeechSynthesisVoice(identifier: identifier) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @available(macOS, introduced: 10.14)
  @objc init?(language languageCode: String?) {
    if let instance = AVSpeechSynthesisVoice(language: languageCode) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @available(macOS, introduced: 10.14)
  @objc static public func currentLanguageCode() -> String {
    return AVSpeechSynthesisVoice.currentLanguageCode()
  }

  @available(macOS, introduced: 14.0)
  @objc public class TraitsWrapper: NSObject {
    var wrappedInstance: AVSpeechSynthesisVoice.Traits

    @available(macOS, introduced: 14.0)
    @objc static public var isNoveltyVoice: AVSpeechSynthesisVoiceWrapper.TraitsWrapper {
      get {
        TraitsWrapper(AVSpeechSynthesisVoice.Traits.isNoveltyVoice)
      }
    }

    @available(macOS, introduced: 14.0)
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

@available(macOS, introduced: 10.14)
@objc public class AVSpeechSynthesizerWrapper: NSObject {
  var wrappedInstance: AVSpeechSynthesizer

  @available(macOS, introduced: 10.14)
  @objc public var isPaused: Bool {
    get {
      wrappedInstance.isPaused
    }
  }

  @available(macOS, introduced: 10.14)
  @objc public var isSpeaking: Bool {
    get {
      wrappedInstance.isSpeaking
    }
  }

  init(_ wrappedInstance: AVSpeechSynthesizer) {
    self.wrappedInstance = wrappedInstance
  }

  @available(macOS, introduced: 10.14)
  @objc public func continueSpeaking() -> Bool {
    return wrappedInstance.continueSpeaking()
  }

  @available(macOS, introduced: 10.14)
  @objc public func speak(_ utterance: AVSpeechUtteranceWrapper) {
    return wrappedInstance.speak(utterance.wrappedInstance)
  }

}

@available(macOS, introduced: 10.14)
@objc public class AVSpeechUtteranceWrapper: NSObject {
  var wrappedInstance: AVSpeechUtterance

  @available(macOS, introduced: 10.14)
  @objc public var pitchMultiplier: Float {
    get {
      wrappedInstance.pitchMultiplier
    }
    set {
      wrappedInstance.pitchMultiplier = newValue
    }
  }

  @available(macOS, introduced: 11.0)
  @objc public var prefersAssistiveTechnologySettings: Bool {
    get {
      wrappedInstance.prefersAssistiveTechnologySettings
    }
    set {
      wrappedInstance.prefersAssistiveTechnologySettings = newValue
    }
  }

  @available(macOS, introduced: 10.14)
  @objc public var rate: Float {
    get {
      wrappedInstance.rate
    }
    set {
      wrappedInstance.rate = newValue
    }
  }

  @available(macOS, introduced: 10.14)
  @objc public var speechString: String {
    get {
      wrappedInstance.speechString
    }
  }

  @available(macOS, introduced: 10.14)
  @objc public var voice: AVSpeechSynthesisVoiceWrapper? {
    get {
      wrappedInstance.voice == nil ? nil : AVSpeechSynthesisVoiceWrapper(wrappedInstance.voice!)
    }
    set {
      wrappedInstance.voice = newValue?.wrappedInstance
    }
  }

  @available(macOS, introduced: 10.14)
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

  @available(macOS, introduced: 13.0)
  @objc init?(ssmlRepresentation string: String) {
    if let instance = AVSpeechUtterance(ssmlRepresentation: string) {
      wrappedInstance = instance
    } else {
      return nil
    }
  }

  @available(macOS, introduced: 10.14)
  @objc init(string: String) {
    wrappedInstance = AVSpeechUtterance(string: string)
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

