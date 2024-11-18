import AVFoundation

import AVFoundation

import Foundation

@objc public class AVAssetReferenceRestrictionsWrapper: NSObject {
  var wrappedInstance: AVAssetReferenceRestrictions
  
  @objc static public var defaultPolicy: AVAssetReferenceRestrictionsWrapper {
    get {
      AVAssetReferenceRestrictionsWrapper(AVAssetReferenceRestrictions.defaultPolicy)
    }
  }
  
  @objc static public var forbidAll: AVAssetReferenceRestrictionsWrapper {
    get {
      AVAssetReferenceRestrictionsWrapper(AVAssetReferenceRestrictions.forbidAll)
    }
  }
  
  @objc static public var forbidCrossSiteReference: AVAssetReferenceRestrictionsWrapper {
    get {
      AVAssetReferenceRestrictionsWrapper(AVAssetReferenceRestrictions.forbidCrossSiteReference)
    }
  }
  
  @objc static public var forbidLocalReferenceToLocal: AVAssetReferenceRestrictionsWrapper {
    get {
      AVAssetReferenceRestrictionsWrapper(AVAssetReferenceRestrictions.forbidLocalReferenceToLocal)
    }
  }
  
  @objc static public var forbidLocalReferenceToRemote: AVAssetReferenceRestrictionsWrapper {
    get {
      AVAssetReferenceRestrictionsWrapper(AVAssetReferenceRestrictions.forbidLocalReferenceToRemote)
    }
  }
  
  @objc static public var forbidRemoteReferenceToLocal: AVAssetReferenceRestrictionsWrapper {
    get {
      AVAssetReferenceRestrictionsWrapper(AVAssetReferenceRestrictions.forbidRemoteReferenceToLocal)
    }
  }
  
  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }
  
  init(_ wrappedInstance: AVAssetReferenceRestrictions) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVAssetReferenceRestrictions()
  }
}

@objc public class AVAssetTrackGroupOutputHandlingWrapper: NSObject {
  var wrappedInstance: AVAssetTrackGroupOutputHandling
  
  @objc static public var preserveAlternateTracks: AVAssetTrackGroupOutputHandlingWrapper {
    get {
      AVAssetTrackGroupOutputHandlingWrapper(AVAssetTrackGroupOutputHandling.preserveAlternateTracks)
    }
  }
  
  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }
  
  init(_ wrappedInstance: AVAssetTrackGroupOutputHandling) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVAssetTrackGroupOutputHandling()
  }
}

@objc public class AVAudioSpatializationFormatsWrapper: NSObject {
  var wrappedInstance: AVAudioSpatializationFormats
  
  @objc static public var monoAndStereo: AVAudioSpatializationFormatsWrapper {
    get {
      AVAudioSpatializationFormatsWrapper(AVAudioSpatializationFormats.monoAndStereo)
    }
  }
  
  @objc static public var monoStereoAndMultichannel: AVAudioSpatializationFormatsWrapper {
    get {
      AVAudioSpatializationFormatsWrapper(AVAudioSpatializationFormats.monoStereoAndMultichannel)
    }
  }
  
  @objc static public var multichannel: AVAudioSpatializationFormatsWrapper {
    get {
      AVAudioSpatializationFormatsWrapper(AVAudioSpatializationFormats.multichannel)
    }
  }
  
  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }
  
  init(_ wrappedInstance: AVAudioSpatializationFormats) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVAudioSpatializationFormats()
  }
}

@objc public class DecorationWrapper: NSObject {
  var wrappedInstance: AVCaption.Decoration
  
  @objc static public var lineThrough: AVCaptionWrapper {
    get {
      AVCaptionWrapper(AVCaption.Decoration.lineThrough)
    }
  }
  
  @objc static public var overline: AVCaptionWrapper {
    get {
      AVCaptionWrapper(AVCaption.Decoration.overline)
    }
  }
  
  @objc static public var underline: AVCaptionWrapper {
    get {
      AVCaptionWrapper(AVCaption.Decoration.underline)
    }
  }
  
  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }
  
  init(_ wrappedInstance: AVCaption.Decoration) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVCaption.Decoration()
  }
}

@objc public class PrimaryConstituentDeviceRestrictedSwitchingBehaviorConditionsWrapper: NSObject {
  var wrappedInstance: AVCaptureDevice.PrimaryConstituentDeviceRestrictedSwitchingBehaviorConditions
  
  @objc static public var exposureModeChanged: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(AVCaptureDevice.PrimaryConstituentDeviceRestrictedSwitchingBehaviorConditions.exposureModeChanged)
    }
  }
  
  @objc static public var focusModeChanged: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(AVCaptureDevice.PrimaryConstituentDeviceRestrictedSwitchingBehaviorConditions.focusModeChanged)
    }
  }
  
  @objc static public var videoZoomChanged: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(AVCaptureDevice.PrimaryConstituentDeviceRestrictedSwitchingBehaviorConditions.videoZoomChanged)
    }
  }
  
  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }
  
  init(_ wrappedInstance: AVCaptureDevice.PrimaryConstituentDeviceRestrictedSwitchingBehaviorConditions) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVCaptureDevice.PrimaryConstituentDeviceRestrictedSwitchingBehaviorConditions()
  }
}

@objc public class AVDelegatingPlaybackCoordinatorRateChangeOptionsWrapper: NSObject {
  var wrappedInstance: AVDelegatingPlaybackCoordinatorRateChangeOptions
  
  @objc static public var playImmediately: AVDelegatingPlaybackCoordinatorRateChangeOptionsWrapper {
    get {
      AVDelegatingPlaybackCoordinatorRateChangeOptionsWrapper(AVDelegatingPlaybackCoordinatorRateChangeOptions.playImmediately)
    }
  }
  
  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }
  
  init(_ wrappedInstance: AVDelegatingPlaybackCoordinatorRateChangeOptions) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVDelegatingPlaybackCoordinatorRateChangeOptions()
  }
}

@objc public class AVDelegatingPlaybackCoordinatorSeekOptionsWrapper: NSObject {
  var wrappedInstance: AVDelegatingPlaybackCoordinatorSeekOptions
  
  @objc static public var resumeImmediately: AVDelegatingPlaybackCoordinatorSeekOptionsWrapper {
    get {
      AVDelegatingPlaybackCoordinatorSeekOptionsWrapper(AVDelegatingPlaybackCoordinatorSeekOptions.resumeImmediately)
    }
  }
  
  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }
  
  init(_ wrappedInstance: AVDelegatingPlaybackCoordinatorSeekOptions) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVDelegatingPlaybackCoordinatorSeekOptions()
  }
}

@objc public class AVMovieWritingOptionsWrapper: NSObject {
  var wrappedInstance: AVMovieWritingOptions
  
  @objc static public var addMovieHeaderToDestination: AVMovieWritingOptionsWrapper {
    get {
      AVMovieWritingOptionsWrapper(AVMovieWritingOptions.addMovieHeaderToDestination)
    }
  }
  
  @objc static public var truncateDestinationToMovieHeaderOnly: AVMovieWritingOptionsWrapper {
    get {
      AVMovieWritingOptionsWrapper(AVMovieWritingOptions.truncateDestinationToMovieHeaderOnly)
    }
  }
  
  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }
  
  init(_ wrappedInstance: AVMovieWritingOptions) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVMovieWritingOptions()
  }
}

@objc public class RestrictionsWrapper: NSObject {
  var wrappedInstance: AVPlayerInterstitialEvent.Restrictions
  
  @objc static public var constrainsSeekingForwardInPrimaryContent: AVPlayerInterstitialEventWrapper {
    get {
      AVPlayerInterstitialEventWrapper(AVPlayerInterstitialEvent.Restrictions.constrainsSeekingForwardInPrimaryContent)
    }
  }
  
  @objc static public var requiresPlaybackAtPreferredRateForAdvancement: AVPlayerInterstitialEventWrapper {
    get {
      AVPlayerInterstitialEventWrapper(AVPlayerInterstitialEvent.Restrictions.requiresPlaybackAtPreferredRateForAdvancement)
    }
  }
  
  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }
  
  init(_ wrappedInstance: AVPlayerInterstitialEvent.Restrictions) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVPlayerInterstitialEvent.Restrictions()
  }
}

@objc public class AVVariantPreferencesWrapper: NSObject {
  var wrappedInstance: AVVariantPreferences
  
  @objc static public var scalabilityToLosslessAudio: AVVariantPreferencesWrapper {
    get {
      AVVariantPreferencesWrapper(AVVariantPreferences.scalabilityToLosslessAudio)
    }
  }
  
  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }
  
  init(_ wrappedInstance: AVVariantPreferences) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVVariantPreferences()
  }
}

@objc public class AVCaptionDimensionWrapper: NSObject {
  var wrappedInstance: AVCaptionDimension
  
  init(_ wrappedInstance: AVCaptionDimension) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVCaptionDimension()
  }
}

@objc public class AVCaptionPointWrapper: NSObject {
  var wrappedInstance: AVCaptionPoint
  
  @objc public var x: AVCaptionDimensionWrapper {
    get {
      AVCaptionDimensionWrapper(wrappedInstance.x)
    }
    set {
      wrappedInstance.x = newValue.wrappedInstance
    }
  }
  
  @objc public var y: AVCaptionDimensionWrapper {
    get {
      AVCaptionDimensionWrapper(wrappedInstance.y)
    }
    set {
      wrappedInstance.y = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVCaptionPoint) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(x: AVCaptionDimensionWrapper, y: AVCaptionDimensionWrapper) {
    wrappedInstance = AVCaptionPoint(x: x.wrappedInstance, y: y.wrappedInstance)
  }
  
  @objc override init() {
    wrappedInstance = AVCaptionPoint()
  }
}

@objc public class AVCaptionSizeWrapper: NSObject {
  var wrappedInstance: AVCaptionSize
  
  @objc public var height: AVCaptionDimensionWrapper {
    get {
      AVCaptionDimensionWrapper(wrappedInstance.height)
    }
    set {
      wrappedInstance.height = newValue.wrappedInstance
    }
  }
  
  @objc public var width: AVCaptionDimensionWrapper {
    get {
      AVCaptionDimensionWrapper(wrappedInstance.width)
    }
    set {
      wrappedInstance.width = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVCaptionSize) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(width: AVCaptionDimensionWrapper, height: AVCaptionDimensionWrapper) {
    wrappedInstance = AVCaptionSize(width: width.wrappedInstance, height: height.wrappedInstance)
  }
  
  @objc override init() {
    wrappedInstance = AVCaptionSize()
  }
}

@objc public class AVEdgeWidthsWrapper: NSObject {
  var wrappedInstance: AVEdgeWidths
  
  init(_ wrappedInstance: AVEdgeWidths) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVEdgeWidths()
  }
}

@objc public class AVPixelAspectRatioWrapper: NSObject {
  var wrappedInstance: AVPixelAspectRatio
  
  @objc public var horizontalSpacing: Int {
    get {
      wrappedInstance.horizontalSpacing
    }
    set {
      wrappedInstance.horizontalSpacing = newValue
    }
  }
  
  @objc public var verticalSpacing: Int {
    get {
      wrappedInstance.verticalSpacing
    }
    set {
      wrappedInstance.verticalSpacing = newValue
    }
  }
  
  init(_ wrappedInstance: AVPixelAspectRatio) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(horizontalSpacing: Int, verticalSpacing: Int) {
    wrappedInstance = AVPixelAspectRatio(horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing)
  }
  
  @objc override init() {
    wrappedInstance = AVPixelAspectRatio()
  }
}

@objc public class AVSampleCursorAudioDependencyInfoWrapper: NSObject {
  var wrappedInstance: AVSampleCursorAudioDependencyInfo
  
  @objc public var audioSamplePacketRefreshCount: Int {
    get {
      wrappedInstance.audioSamplePacketRefreshCount
    }
    set {
      wrappedInstance.audioSamplePacketRefreshCount = newValue
    }
  }
  
  init(_ wrappedInstance: AVSampleCursorAudioDependencyInfo) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVSampleCursorAudioDependencyInfo()
  }
}

@objc public class AVSampleCursorChunkInfoWrapper: NSObject {
  var wrappedInstance: AVSampleCursorChunkInfo
  
  init(_ wrappedInstance: AVSampleCursorChunkInfo) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVSampleCursorChunkInfo()
  }
}

@objc public class AVSampleCursorDependencyInfoWrapper: NSObject {
  var wrappedInstance: AVSampleCursorDependencyInfo
  
  init(_ wrappedInstance: AVSampleCursorDependencyInfo) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVSampleCursorDependencyInfo()
  }
}

@objc public class AVSampleCursorStorageRangeWrapper: NSObject {
  var wrappedInstance: AVSampleCursorStorageRange
  
  init(_ wrappedInstance: AVSampleCursorStorageRange) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVSampleCursorStorageRange()
  }
}

@objc public class AVSampleCursorSyncInfoWrapper: NSObject {
  var wrappedInstance: AVSampleCursorSyncInfo
  
  init(_ wrappedInstance: AVSampleCursorSyncInfo) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVSampleCursorSyncInfo()
  }
}

@objc public class AVAssetDownloadedAssetEvictionPriorityWrapper: NSObject {
  var wrappedInstance: AVAssetDownloadedAssetEvictionPriority
  
  @objc static public var `default`: AVAssetDownloadedAssetEvictionPriorityWrapper {
    get {
      AVAssetDownloadedAssetEvictionPriorityWrapper(AVAssetDownloadedAssetEvictionPriority.`default`)
    }
  }
  
  @objc static public var important: AVAssetDownloadedAssetEvictionPriorityWrapper {
    get {
      AVAssetDownloadedAssetEvictionPriorityWrapper(AVAssetDownloadedAssetEvictionPriority.important)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVAssetDownloadedAssetEvictionPriority) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVAssetDownloadedAssetEvictionPriority(rawValue: rawValue)
  }
}

@objc public class ApertureModeWrapper: NSObject {
  var wrappedInstance: AVAssetImageGenerator.ApertureMode
  
  @objc static public var cleanAperture: AVAssetImageGeneratorWrapper {
    get {
      AVAssetImageGeneratorWrapper(AVAssetImageGenerator.ApertureMode.cleanAperture)
    }
  }
  
  @objc static public var encodedPixels: AVAssetImageGeneratorWrapper {
    get {
      AVAssetImageGeneratorWrapper(AVAssetImageGenerator.ApertureMode.encodedPixels)
    }
  }
  
  @objc static public var productionAperture: AVAssetImageGeneratorWrapper {
    get {
      AVAssetImageGeneratorWrapper(AVAssetImageGenerator.ApertureMode.productionAperture)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVAssetImageGenerator.ApertureMode) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVAssetImageGenerator.ApertureMode(rawValue: rawValue)
  }
}

@objc public class AVAssetPlaybackConfigurationOptionWrapper: NSObject {
  var wrappedInstance: AVAssetPlaybackConfigurationOption
  
  @objc static public var stereoMultiviewVideo: AVAssetPlaybackConfigurationOptionWrapper {
    get {
      AVAssetPlaybackConfigurationOptionWrapper(AVAssetPlaybackConfigurationOption.stereoMultiviewVideo)
    }
  }
  
  @objc static public var stereoVideo: AVAssetPlaybackConfigurationOptionWrapper {
    get {
      AVAssetPlaybackConfigurationOptionWrapper(AVAssetPlaybackConfigurationOption.stereoVideo)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVAssetPlaybackConfigurationOption) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVAssetPlaybackConfigurationOption(rawValue: rawValue)
  }
}

@objc public class MediaDataLocationWrapper: NSObject {
  var wrappedInstance: AVAssetWriterInput.MediaDataLocation
  
  @objc static public var beforeMainMediaDataNotInterleaved: AVAssetWriterInputWrapper {
    get {
      AVAssetWriterInputWrapper(AVAssetWriterInput.MediaDataLocation.beforeMainMediaDataNotInterleaved)
    }
  }
  
  @objc static public var interleavedWithMainMediaData: AVAssetWriterInputWrapper {
    get {
      AVAssetWriterInputWrapper(AVAssetWriterInput.MediaDataLocation.interleavedWithMainMediaData)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVAssetWriterInput.MediaDataLocation) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVAssetWriterInput.MediaDataLocation(rawValue: rawValue)
  }
}

@objc public class AVAudioTimePitchAlgorithmWrapper: NSObject {
  var wrappedInstance: AVAudioTimePitchAlgorithm
  
  @objc static public var spectral: AVAudioTimePitchAlgorithmWrapper {
    get {
      AVAudioTimePitchAlgorithmWrapper(AVAudioTimePitchAlgorithm.spectral)
    }
  }
  
  @objc static public var timeDomain: AVAudioTimePitchAlgorithmWrapper {
    get {
      AVAudioTimePitchAlgorithmWrapper(AVAudioTimePitchAlgorithm.timeDomain)
    }
  }
  
  @objc static public var varispeed: AVAudioTimePitchAlgorithmWrapper {
    get {
      AVAudioTimePitchAlgorithmWrapper(AVAudioTimePitchAlgorithm.varispeed)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVAudioTimePitchAlgorithm) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVAudioTimePitchAlgorithm(rawValue: rawValue)
  }
}

@objc public class AdjustmentTypeWrapper: NSObject {
  var wrappedInstance: AVCaptionConversionAdjustment.AdjustmentType
  
  @objc static public var timeRange: AVCaptionConversionAdjustmentWrapper {
    get {
      AVCaptionConversionAdjustmentWrapper(AVCaptionConversionAdjustment.AdjustmentType.timeRange)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVCaptionConversionAdjustment.AdjustmentType) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVCaptionConversionAdjustment.AdjustmentType(rawValue: rawValue)
  }
}

@objc public class WarningTypeWrapper: NSObject {
  var wrappedInstance: AVCaptionConversionWarning.WarningType
  
  @objc static public var excessMediaData: AVCaptionConversionWarningWrapper {
    get {
      AVCaptionConversionWarningWrapper(AVCaptionConversionWarning.WarningType.excessMediaData)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVCaptionConversionWarning.WarningType) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVCaptionConversionWarning.WarningType(rawValue: rawValue)
  }
}

@objc public class AVCaptionSettingsKeyWrapper: NSObject {
  var wrappedInstance: AVCaptionSettingsKey
  
  @objc static public var mediaSubType: AVCaptionSettingsKeyWrapper {
    get {
      AVCaptionSettingsKeyWrapper(AVCaptionSettingsKey.mediaSubType)
    }
  }
  
  @objc static public var mediaType: AVCaptionSettingsKeyWrapper {
    get {
      AVCaptionSettingsKeyWrapper(AVCaptionSettingsKey.mediaType)
    }
  }
  
  @objc static public var timeCodeFrameDuration: AVCaptionSettingsKeyWrapper {
    get {
      AVCaptionSettingsKeyWrapper(AVCaptionSettingsKey.timeCodeFrameDuration)
    }
  }
  
  @objc static public var useDropFrameTimeCode: AVCaptionSettingsKeyWrapper {
    get {
      AVCaptionSettingsKeyWrapper(AVCaptionSettingsKey.useDropFrameTimeCode)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVCaptionSettingsKey) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVCaptionSettingsKey(rawValue: rawValue)
  }
}

@objc public class DeviceTypeWrapper: NSObject {
  var wrappedInstance: AVCaptureDevice.DeviceType
  
  @objc static public var builtInMicrophone: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(AVCaptureDevice.DeviceType.builtInMicrophone)
    }
  }
  
  @objc static public var builtInWideAngleCamera: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(AVCaptureDevice.DeviceType.builtInWideAngleCamera)
    }
  }
  
  @objc static public var continuityCamera: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(AVCaptureDevice.DeviceType.continuityCamera)
    }
  }
  
  @objc static public var deskViewCamera: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(AVCaptureDevice.DeviceType.deskViewCamera)
    }
  }
  
  @objc static public var external: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(AVCaptureDevice.DeviceType.external)
    }
  }
  
  @objc static public var externalUnknown: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(AVCaptureDevice.DeviceType.externalUnknown)
    }
  }
  
  @objc static public var microphone: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(AVCaptureDevice.DeviceType.microphone)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVCaptureDevice.DeviceType) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVCaptureDevice.DeviceType(rawValue: rawValue)
  }
}

@objc public class AVCaptureReactionTypeWrapper: NSObject {
  var wrappedInstance: AVCaptureReactionType
  
  @objc static public var balloons: AVCaptureReactionTypeWrapper {
    get {
      AVCaptureReactionTypeWrapper(AVCaptureReactionType.balloons)
    }
  }
  
  @objc static public var confetti: AVCaptureReactionTypeWrapper {
    get {
      AVCaptureReactionTypeWrapper(AVCaptureReactionType.confetti)
    }
  }
  
  @objc static public var fireworks: AVCaptureReactionTypeWrapper {
    get {
      AVCaptureReactionTypeWrapper(AVCaptureReactionType.fireworks)
    }
  }
  
  @objc static public var heart: AVCaptureReactionTypeWrapper {
    get {
      AVCaptureReactionTypeWrapper(AVCaptureReactionType.heart)
    }
  }
  
  @objc static public var lasers: AVCaptureReactionTypeWrapper {
    get {
      AVCaptureReactionTypeWrapper(AVCaptureReactionType.lasers)
    }
  }
  
  @objc static public var rain: AVCaptureReactionTypeWrapper {
    get {
      AVCaptureReactionTypeWrapper(AVCaptureReactionType.rain)
    }
  }
  
  @objc static public var thumbsDown: AVCaptureReactionTypeWrapper {
    get {
      AVCaptureReactionTypeWrapper(AVCaptureReactionType.thumbsDown)
    }
  }
  
  @objc static public var thumbsUp: AVCaptureReactionTypeWrapper {
    get {
      AVCaptureReactionTypeWrapper(AVCaptureReactionType.thumbsUp)
    }
  }
  
  @objc public var systemImageName: String {
    get {
      wrappedInstance.systemImageName
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVCaptureReactionType) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVCaptureReactionType(rawValue: rawValue)
  }
}

@objc public class PresetWrapper: NSObject {
  var wrappedInstance: AVCaptureSession.Preset
  
  @objc static public var hd1280x720: AVCaptureSessionWrapper {
    get {
      AVCaptureSessionWrapper(AVCaptureSession.Preset.hd1280x720)
    }
  }
  
  @objc static public var hd1920x1080: AVCaptureSessionWrapper {
    get {
      AVCaptureSessionWrapper(AVCaptureSession.Preset.hd1920x1080)
    }
  }
  
  @objc static public var qvga320x240: AVCaptureSessionWrapper {
    get {
      AVCaptureSessionWrapper(AVCaptureSession.Preset.qvga320x240)
    }
  }
  
  @objc static public var cif352x288: AVCaptureSessionWrapper {
    get {
      AVCaptureSessionWrapper(AVCaptureSession.Preset.cif352x288)
    }
  }
  
  @objc static public var hd4K3840x2160: AVCaptureSessionWrapper {
    get {
      AVCaptureSessionWrapper(AVCaptureSession.Preset.hd4K3840x2160)
    }
  }
  
  @objc static public var vga640x480: AVCaptureSessionWrapper {
    get {
      AVCaptureSessionWrapper(AVCaptureSession.Preset.vga640x480)
    }
  }
  
  @objc static public var qHD960x540: AVCaptureSessionWrapper {
    get {
      AVCaptureSessionWrapper(AVCaptureSession.Preset.qHD960x540)
    }
  }
  
  @objc static public var high: AVCaptureSessionWrapper {
    get {
      AVCaptureSessionWrapper(AVCaptureSession.Preset.high)
    }
  }
  
  @objc static public var low: AVCaptureSessionWrapper {
    get {
      AVCaptureSessionWrapper(AVCaptureSession.Preset.low)
    }
  }
  
  @objc static public var medium: AVCaptureSessionWrapper {
    get {
      AVCaptureSessionWrapper(AVCaptureSession.Preset.medium)
    }
  }
  
  @objc static public var photo: AVCaptureSessionWrapper {
    get {
      AVCaptureSessionWrapper(AVCaptureSession.Preset.photo)
    }
  }
  
  @objc static public var iFrame1280x720: AVCaptureSessionWrapper {
    get {
      AVCaptureSessionWrapper(AVCaptureSession.Preset.iFrame1280x720)
    }
  }
  
  @objc static public var iFrame960x540: AVCaptureSessionWrapper {
    get {
      AVCaptureSessionWrapper(AVCaptureSession.Preset.iFrame960x540)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVCaptureSession.Preset) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVCaptureSession.Preset(rawValue: rawValue)
  }
}

@objc public class RetryReasonWrapper: NSObject {
  var wrappedInstance: AVContentKeyRequest.RetryReason
  
  @objc static public var receivedObsoleteContentKey: AVContentKeyRequestWrapper {
    get {
      AVContentKeyRequestWrapper(AVContentKeyRequest.RetryReason.receivedObsoleteContentKey)
    }
  }
  
  @objc static public var receivedResponseWithExpiredLease: AVContentKeyRequestWrapper {
    get {
      AVContentKeyRequestWrapper(AVContentKeyRequest.RetryReason.receivedResponseWithExpiredLease)
    }
  }
  
  @objc static public var timedOut: AVContentKeyRequestWrapper {
    get {
      AVContentKeyRequestWrapper(AVContentKeyRequest.RetryReason.timedOut)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVContentKeyRequest.RetryReason) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVContentKeyRequest.RetryReason(rawValue: rawValue)
  }
}

@objc public class AVContentKeySessionServerPlaybackContextOptionWrapper: NSObject {
  var wrappedInstance: AVContentKeySessionServerPlaybackContextOption
  
  @objc static public var protocolVersions: AVContentKeySessionServerPlaybackContextOptionWrapper {
    get {
      AVContentKeySessionServerPlaybackContextOptionWrapper(AVContentKeySessionServerPlaybackContextOption.protocolVersions)
    }
  }
  
  @objc static public var serverChallenge: AVContentKeySessionServerPlaybackContextOptionWrapper {
    get {
      AVContentKeySessionServerPlaybackContextOptionWrapper(AVContentKeySessionServerPlaybackContextOption.serverChallenge)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVContentKeySessionServerPlaybackContextOption) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVContentKeySessionServerPlaybackContextOption(rawValue: rawValue)
  }
}

@objc public class AVContentKeySystemWrapper: NSObject {
  var wrappedInstance: AVContentKeySystem
  
  @objc static public var authorizationToken: AVContentKeySystemWrapper {
    get {
      AVContentKeySystemWrapper(AVContentKeySystem.authorizationToken)
    }
  }
  
  @objc static public var clearKey: AVContentKeySystemWrapper {
    get {
      AVContentKeySystemWrapper(AVContentKeySystem.clearKey)
    }
  }
  
  @objc static public var fairPlayStreaming: AVContentKeySystemWrapper {
    get {
      AVContentKeySystemWrapper(AVContentKeySystem.fairPlayStreaming)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVContentKeySystem) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVContentKeySystem(rawValue: rawValue)
  }
}

@objc public class ReasonWrapper: NSObject {
  var wrappedInstance: AVCoordinatedPlaybackSuspension.Reason
  
  @objc static public var audioSessionInterrupted: AVCoordinatedPlaybackSuspensionWrapper {
    get {
      AVCoordinatedPlaybackSuspensionWrapper(AVCoordinatedPlaybackSuspension.Reason.audioSessionInterrupted)
    }
  }
  
  @objc static public var coordinatedPlaybackNotPossible: AVCoordinatedPlaybackSuspensionWrapper {
    get {
      AVCoordinatedPlaybackSuspensionWrapper(AVCoordinatedPlaybackSuspension.Reason.coordinatedPlaybackNotPossible)
    }
  }
  
  @objc static public var playingInterstitial: AVCoordinatedPlaybackSuspensionWrapper {
    get {
      AVCoordinatedPlaybackSuspensionWrapper(AVCoordinatedPlaybackSuspension.Reason.playingInterstitial)
    }
  }
  
  @objc static public var stallRecovery: AVCoordinatedPlaybackSuspensionWrapper {
    get {
      AVCoordinatedPlaybackSuspensionWrapper(AVCoordinatedPlaybackSuspension.Reason.stallRecovery)
    }
  }
  
  @objc static public var userActionRequired: AVCoordinatedPlaybackSuspensionWrapper {
    get {
      AVCoordinatedPlaybackSuspensionWrapper(AVCoordinatedPlaybackSuspension.Reason.userActionRequired)
    }
  }
  
  @objc static public var userIsChangingCurrentTime: AVCoordinatedPlaybackSuspensionWrapper {
    get {
      AVCoordinatedPlaybackSuspensionWrapper(AVCoordinatedPlaybackSuspension.Reason.userIsChangingCurrentTime)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVCoordinatedPlaybackSuspension.Reason) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVCoordinatedPlaybackSuspension.Reason(rawValue: rawValue)
  }
  
  @objc init(_ rawValue: String) {
    wrappedInstance = AVCoordinatedPlaybackSuspension.Reason(_: rawValue)
  }
}

@objc public class AVFileTypeWrapper: NSObject {
  var wrappedInstance: AVFileType
  
  @objc static public var mobile3GPP: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(AVFileType.mobile3GPP)
    }
  }
  
  @objc static public var mobile3GPP2: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(AVFileType.mobile3GPP2)
    }
  }
  
  @objc static public var ac3: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(AVFileType.ac3)
    }
  }
  
  @objc static public var AHAP: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(AVFileType.AHAP)
    }
  }
  
  @objc static public var aifc: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(AVFileType.aifc)
    }
  }
  
  @objc static public var aiff: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(AVFileType.aiff)
    }
  }
  
  @objc static public var amr: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(AVFileType.amr)
    }
  }
  
  @objc static public var avci: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(AVFileType.avci)
    }
  }
  
  @objc static public var m4a: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(AVFileType.m4a)
    }
  }
  
  @objc static public var m4v: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(AVFileType.m4v)
    }
  }
  
  @objc static public var appleiTT: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(AVFileType.appleiTT)
    }
  }
  
  @objc static public var caf: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(AVFileType.caf)
    }
  }
  
  @objc static public var dng: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(AVFileType.dng)
    }
  }
  
  @objc static public var eac3: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(AVFileType.eac3)
    }
  }
  
  @objc static public var heic: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(AVFileType.heic)
    }
  }
  
  @objc static public var heif: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(AVFileType.heif)
    }
  }
  
  @objc static public var jpg: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(AVFileType.jpg)
    }
  }
  
  @objc static public var mp4: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(AVFileType.mp4)
    }
  }
  
  @objc static public var mp3: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(AVFileType.mp3)
    }
  }
  
  @objc static public var mov: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(AVFileType.mov)
    }
  }
  
  @objc static public var SCC: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(AVFileType.SCC)
    }
  }
  
  @objc static public var au: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(AVFileType.au)
    }
  }
  
  @objc static public var tif: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(AVFileType.tif)
    }
  }
  
  @objc static public var wav: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(AVFileType.wav)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVFileType) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVFileType(rawValue: rawValue)
  }
  
  @objc init(_ rawValue: String) {
    wrappedInstance = AVFileType(_: rawValue)
  }
}

@objc public class AVFileTypeProfileWrapper: NSObject {
  var wrappedInstance: AVFileTypeProfile
  
  @objc static public var mpeg4AppleHLS: AVFileTypeProfileWrapper {
    get {
      AVFileTypeProfileWrapper(AVFileTypeProfile.mpeg4AppleHLS)
    }
  }
  
  @objc static public var mpeg4CMAFCompliant: AVFileTypeProfileWrapper {
    get {
      AVFileTypeProfileWrapper(AVFileTypeProfile.mpeg4CMAFCompliant)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVFileTypeProfile) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVFileTypeProfile(rawValue: rawValue)
  }
}

@objc public class AVLayerVideoGravityWrapper: NSObject {
  var wrappedInstance: AVLayerVideoGravity
  
  @objc static public var resize: AVLayerVideoGravityWrapper {
    get {
      AVLayerVideoGravityWrapper(AVLayerVideoGravity.resize)
    }
  }
  
  @objc static public var resizeAspect: AVLayerVideoGravityWrapper {
    get {
      AVLayerVideoGravityWrapper(AVLayerVideoGravity.resizeAspect)
    }
  }
  
  @objc static public var resizeAspectFill: AVLayerVideoGravityWrapper {
    get {
      AVLayerVideoGravityWrapper(AVLayerVideoGravity.resizeAspectFill)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVLayerVideoGravity) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVLayerVideoGravity(rawValue: rawValue)
  }
}

@objc public class AVMediaCharacteristicWrapper: NSObject {
  var wrappedInstance: AVMediaCharacteristic
  
  @objc static public var audible: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(AVMediaCharacteristic.audible)
    }
  }
  
  @objc static public var carriesVideoStereoMetadata: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(AVMediaCharacteristic.carriesVideoStereoMetadata)
    }
  }
  
  @objc static public var containsAlphaChannel: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(AVMediaCharacteristic.containsAlphaChannel)
    }
  }
  
  @objc static public var containsHDRVideo: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(AVMediaCharacteristic.containsHDRVideo)
    }
  }
  
  @objc static public var containsOnlyForcedSubtitles: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(AVMediaCharacteristic.containsOnlyForcedSubtitles)
    }
  }
  
  @objc static public var containsStereoMultiviewVideo: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(AVMediaCharacteristic.containsStereoMultiviewVideo)
    }
  }
  
  @objc static public var describesMusicAndSoundForAccessibility: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(AVMediaCharacteristic.describesMusicAndSoundForAccessibility)
    }
  }
  
  @objc static public var describesVideoForAccessibility: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(AVMediaCharacteristic.describesVideoForAccessibility)
    }
  }
  
  @objc static public var dubbedTranslation: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(AVMediaCharacteristic.dubbedTranslation)
    }
  }
  
  @objc static public var easyToRead: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(AVMediaCharacteristic.easyToRead)
    }
  }
  
  @objc static public var enhancesSpeechIntelligibility: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(AVMediaCharacteristic.enhancesSpeechIntelligibility)
    }
  }
  
  @objc static public var frameBased: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(AVMediaCharacteristic.frameBased)
    }
  }
  
  @objc static public var indicatesHorizontalFieldOfView: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(AVMediaCharacteristic.indicatesHorizontalFieldOfView)
    }
  }
  
  @objc static public var isAuxiliaryContent: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(AVMediaCharacteristic.isAuxiliaryContent)
    }
  }
  
  @objc static public var isMainProgramContent: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(AVMediaCharacteristic.isMainProgramContent)
    }
  }
  
  @objc static public var isOriginalContent: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(AVMediaCharacteristic.isOriginalContent)
    }
  }
  
  @objc static public var languageTranslation: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(AVMediaCharacteristic.languageTranslation)
    }
  }
  
  @objc static public var legible: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(AVMediaCharacteristic.legible)
    }
  }
  
  @objc static public var tactileMinimal: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(AVMediaCharacteristic.tactileMinimal)
    }
  }
  
  @objc static public var transcribesSpokenDialogForAccessibility: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(AVMediaCharacteristic.transcribesSpokenDialogForAccessibility)
    }
  }
  
  @objc static public var usesWideGamutColorSpace: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(AVMediaCharacteristic.usesWideGamutColorSpace)
    }
  }
  
  @objc static public var visual: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(AVMediaCharacteristic.visual)
    }
  }
  
  @objc static public var voiceOverTranslation: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(AVMediaCharacteristic.voiceOverTranslation)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVMediaCharacteristic) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVMediaCharacteristic(rawValue: rawValue)
  }
  
  @objc init(_ rawValue: String) {
    wrappedInstance = AVMediaCharacteristic(_: rawValue)
  }
}

@objc public class AVMediaTypeWrapper: NSObject {
  var wrappedInstance: AVMediaType
  
  @objc static public var audio: AVMediaTypeWrapper {
    get {
      AVMediaTypeWrapper(AVMediaType.audio)
    }
  }
  
  @objc static public var closedCaption: AVMediaTypeWrapper {
    get {
      AVMediaTypeWrapper(AVMediaType.closedCaption)
    }
  }
  
  @objc static public var depthData: AVMediaTypeWrapper {
    get {
      AVMediaTypeWrapper(AVMediaType.depthData)
    }
  }
  
  @objc static public var haptic: AVMediaTypeWrapper {
    get {
      AVMediaTypeWrapper(AVMediaType.haptic)
    }
  }
  
  @objc static public var metadata: AVMediaTypeWrapper {
    get {
      AVMediaTypeWrapper(AVMediaType.metadata)
    }
  }
  
  @objc static public var muxed: AVMediaTypeWrapper {
    get {
      AVMediaTypeWrapper(AVMediaType.muxed)
    }
  }
  
  @objc static public var subtitle: AVMediaTypeWrapper {
    get {
      AVMediaTypeWrapper(AVMediaType.subtitle)
    }
  }
  
  @objc static public var text: AVMediaTypeWrapper {
    get {
      AVMediaTypeWrapper(AVMediaType.text)
    }
  }
  
  @objc static public var timecode: AVMediaTypeWrapper {
    get {
      AVMediaTypeWrapper(AVMediaType.timecode)
    }
  }
  
  @objc static public var video: AVMediaTypeWrapper {
    get {
      AVMediaTypeWrapper(AVMediaType.video)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVMediaType) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVMediaType(rawValue: rawValue)
  }
  
  @objc init(_ rawValue: String) {
    wrappedInstance = AVMediaType(_: rawValue)
  }
}

@objc public class AVMetadataExtraAttributeKeyWrapper: NSObject {
  var wrappedInstance: AVMetadataExtraAttributeKey
  
  @objc static public var baseURI: AVMetadataExtraAttributeKeyWrapper {
    get {
      AVMetadataExtraAttributeKeyWrapper(AVMetadataExtraAttributeKey.baseURI)
    }
  }
  
  @objc static public var info: AVMetadataExtraAttributeKeyWrapper {
    get {
      AVMetadataExtraAttributeKeyWrapper(AVMetadataExtraAttributeKey.info)
    }
  }
  
  @objc static public var valueURI: AVMetadataExtraAttributeKeyWrapper {
    get {
      AVMetadataExtraAttributeKeyWrapper(AVMetadataExtraAttributeKey.valueURI)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVMetadataExtraAttributeKey) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVMetadataExtraAttributeKey(rawValue: rawValue)
  }
  
  @objc init(_ rawValue: String) {
    wrappedInstance = AVMetadataExtraAttributeKey(_: rawValue)
  }
}

@objc public class AVMetadataFormatWrapper: NSObject {
  var wrappedInstance: AVMetadataFormat
  
  @objc static public var hlsMetadata: AVMetadataFormatWrapper {
    get {
      AVMetadataFormatWrapper(AVMetadataFormat.hlsMetadata)
    }
  }
  
  @objc static public var id3Metadata: AVMetadataFormatWrapper {
    get {
      AVMetadataFormatWrapper(AVMetadataFormat.id3Metadata)
    }
  }
  
  @objc static public var isoUserData: AVMetadataFormatWrapper {
    get {
      AVMetadataFormatWrapper(AVMetadataFormat.isoUserData)
    }
  }
  
  @objc static public var quickTimeMetadata: AVMetadataFormatWrapper {
    get {
      AVMetadataFormatWrapper(AVMetadataFormat.quickTimeMetadata)
    }
  }
  
  @objc static public var quickTimeUserData: AVMetadataFormatWrapper {
    get {
      AVMetadataFormatWrapper(AVMetadataFormat.quickTimeUserData)
    }
  }
  
  @objc static public var unknown: AVMetadataFormatWrapper {
    get {
      AVMetadataFormatWrapper(AVMetadataFormat.unknown)
    }
  }
  
  @objc static public var iTunesMetadata: AVMetadataFormatWrapper {
    get {
      AVMetadataFormatWrapper(AVMetadataFormat.iTunesMetadata)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVMetadataFormat) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVMetadataFormat(rawValue: rawValue)
  }
}

@objc public class AVMetadataIdentifierWrapper: NSObject {
  var wrappedInstance: AVMetadataIdentifier
  
  @objc static public var commonIdentifierAccessibilityDescription: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.commonIdentifierAccessibilityDescription)
    }
  }
  
  @objc static public var commonIdentifierAlbumName: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.commonIdentifierAlbumName)
    }
  }
  
  @objc static public var commonIdentifierArtist: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.commonIdentifierArtist)
    }
  }
  
  @objc static public var commonIdentifierArtwork: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.commonIdentifierArtwork)
    }
  }
  
  @objc static public var commonIdentifierAssetIdentifier: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.commonIdentifierAssetIdentifier)
    }
  }
  
  @objc static public var commonIdentifierAuthor: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.commonIdentifierAuthor)
    }
  }
  
  @objc static public var commonIdentifierContributor: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.commonIdentifierContributor)
    }
  }
  
  @objc static public var commonIdentifierCopyrights: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.commonIdentifierCopyrights)
    }
  }
  
  @objc static public var commonIdentifierCreationDate: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.commonIdentifierCreationDate)
    }
  }
  
  @objc static public var commonIdentifierCreator: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.commonIdentifierCreator)
    }
  }
  
  @objc static public var commonIdentifierDescription: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.commonIdentifierDescription)
    }
  }
  
  @objc static public var commonIdentifierFormat: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.commonIdentifierFormat)
    }
  }
  
  @objc static public var commonIdentifierLanguage: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.commonIdentifierLanguage)
    }
  }
  
  @objc static public var commonIdentifierLastModifiedDate: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.commonIdentifierLastModifiedDate)
    }
  }
  
  @objc static public var commonIdentifierLocation: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.commonIdentifierLocation)
    }
  }
  
  @objc static public var commonIdentifierMake: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.commonIdentifierMake)
    }
  }
  
  @objc static public var commonIdentifierModel: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.commonIdentifierModel)
    }
  }
  
  @objc static public var commonIdentifierPublisher: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.commonIdentifierPublisher)
    }
  }
  
  @objc static public var commonIdentifierRelation: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.commonIdentifierRelation)
    }
  }
  
  @objc static public var commonIdentifierSoftware: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.commonIdentifierSoftware)
    }
  }
  
  @objc static public var commonIdentifierSource: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.commonIdentifierSource)
    }
  }
  
  @objc static public var commonIdentifierSubject: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.commonIdentifierSubject)
    }
  }
  
  @objc static public var commonIdentifierTitle: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.commonIdentifierTitle)
    }
  }
  
  @objc static public var commonIdentifierType: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.commonIdentifierType)
    }
  }
  
  @objc static public var identifier3GPUserDataAlbumAndTrack: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.identifier3GPUserDataAlbumAndTrack)
    }
  }
  
  @objc static public var identifier3GPUserDataAuthor: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.identifier3GPUserDataAuthor)
    }
  }
  
  @objc static public var identifier3GPUserDataCollection: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.identifier3GPUserDataCollection)
    }
  }
  
  @objc static public var identifier3GPUserDataCopyright: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.identifier3GPUserDataCopyright)
    }
  }
  
  @objc static public var identifier3GPUserDataDescription: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.identifier3GPUserDataDescription)
    }
  }
  
  @objc static public var identifier3GPUserDataGenre: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.identifier3GPUserDataGenre)
    }
  }
  
  @objc static public var identifier3GPUserDataKeywordList: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.identifier3GPUserDataKeywordList)
    }
  }
  
  @objc static public var identifier3GPUserDataLocation: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.identifier3GPUserDataLocation)
    }
  }
  
  @objc static public var identifier3GPUserDataMediaClassification: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.identifier3GPUserDataMediaClassification)
    }
  }
  
  @objc static public var identifier3GPUserDataMediaRating: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.identifier3GPUserDataMediaRating)
    }
  }
  
  @objc static public var identifier3GPUserDataPerformer: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.identifier3GPUserDataPerformer)
    }
  }
  
  @objc static public var identifier3GPUserDataRecordingYear: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.identifier3GPUserDataRecordingYear)
    }
  }
  
  @objc static public var identifier3GPUserDataThumbnail: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.identifier3GPUserDataThumbnail)
    }
  }
  
  @objc static public var identifier3GPUserDataTitle: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.identifier3GPUserDataTitle)
    }
  }
  
  @objc static public var identifier3GPUserDataUserRating: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.identifier3GPUserDataUserRating)
    }
  }
  
  @objc static public var id3MetadataAlbumSortOrder: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataAlbumSortOrder)
    }
  }
  
  @objc static public var id3MetadataAlbumTitle: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataAlbumTitle)
    }
  }
  
  @objc static public var id3MetadataAttachedPicture: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataAttachedPicture)
    }
  }
  
  @objc static public var id3MetadataAudioEncryption: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataAudioEncryption)
    }
  }
  
  @objc static public var id3MetadataAudioSeekPointIndex: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataAudioSeekPointIndex)
    }
  }
  
  @objc static public var id3MetadataBand: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataBand)
    }
  }
  
  @objc static public var id3MetadataBeatsPerMinute: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataBeatsPerMinute)
    }
  }
  
  @objc static public var id3MetadataComments: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataComments)
    }
  }
  
  @objc static public var id3MetadataCommercial: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataCommercial)
    }
  }
  
  @objc static public var id3MetadataCommercialInformation: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataCommercialInformation)
    }
  }
  
  @objc static public var id3MetadataCommerical: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataCommerical)
    }
  }
  
  @objc static public var id3MetadataComposer: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataComposer)
    }
  }
  
  @objc static public var id3MetadataConductor: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataConductor)
    }
  }
  
  @objc static public var id3MetadataContentGroupDescription: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataContentGroupDescription)
    }
  }
  
  @objc static public var id3MetadataContentType: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataContentType)
    }
  }
  
  @objc static public var id3MetadataCopyright: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataCopyright)
    }
  }
  
  @objc static public var id3MetadataCopyrightInformation: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataCopyrightInformation)
    }
  }
  
  @objc static public var id3MetadataDate: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataDate)
    }
  }
  
  @objc static public var id3MetadataEncodedBy: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataEncodedBy)
    }
  }
  
  @objc static public var id3MetadataEncodedWith: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataEncodedWith)
    }
  }
  
  @objc static public var id3MetadataEncodingTime: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataEncodingTime)
    }
  }
  
  @objc static public var id3MetadataEncryption: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataEncryption)
    }
  }
  
  @objc static public var id3MetadataEqualization: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataEqualization)
    }
  }
  
  @objc static public var id3MetadataEqualization2: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataEqualization2)
    }
  }
  
  @objc static public var id3MetadataEventTimingCodes: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataEventTimingCodes)
    }
  }
  
  @objc static public var id3MetadataFileOwner: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataFileOwner)
    }
  }
  
  @objc static public var id3MetadataFileType: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataFileType)
    }
  }
  
  @objc static public var id3MetadataGeneralEncapsulatedObject: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataGeneralEncapsulatedObject)
    }
  }
  
  @objc static public var id3MetadataGroupIdentifier: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataGroupIdentifier)
    }
  }
  
  @objc static public var id3MetadataInitialKey: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataInitialKey)
    }
  }
  
  @objc static public var id3MetadataInternationalStandardRecordingCode: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataInternationalStandardRecordingCode)
    }
  }
  
  @objc static public var id3MetadataInternetRadioStationName: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataInternetRadioStationName)
    }
  }
  
  @objc static public var id3MetadataInternetRadioStationOwner: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataInternetRadioStationOwner)
    }
  }
  
  @objc static public var id3MetadataInvolvedPeopleList_v23: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataInvolvedPeopleList_v23)
    }
  }
  
  @objc static public var id3MetadataInvolvedPeopleList_v24: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataInvolvedPeopleList_v24)
    }
  }
  
  @objc static public var id3MetadataLanguage: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataLanguage)
    }
  }
  
  @objc static public var id3MetadataLeadPerformer: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataLeadPerformer)
    }
  }
  
  @objc static public var id3MetadataLength: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataLength)
    }
  }
  
  @objc static public var id3MetadataLink: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataLink)
    }
  }
  
  @objc static public var id3MetadataLyricist: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataLyricist)
    }
  }
  
  @objc static public var id3MetadataMPEGLocationLookupTable: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataMPEGLocationLookupTable)
    }
  }
  
  @objc static public var id3MetadataMediaType: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataMediaType)
    }
  }
  
  @objc static public var id3MetadataModifiedBy: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataModifiedBy)
    }
  }
  
  @objc static public var id3MetadataMood: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataMood)
    }
  }
  
  @objc static public var id3MetadataMusicCDIdentifier: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataMusicCDIdentifier)
    }
  }
  
  @objc static public var id3MetadataMusicianCreditsList: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataMusicianCreditsList)
    }
  }
  
  @objc static public var id3MetadataOfficialArtistWebpage: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataOfficialArtistWebpage)
    }
  }
  
  @objc static public var id3MetadataOfficialAudioFileWebpage: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataOfficialAudioFileWebpage)
    }
  }
  
  @objc static public var id3MetadataOfficialAudioSourceWebpage: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataOfficialAudioSourceWebpage)
    }
  }
  
  @objc static public var id3MetadataOfficialInternetRadioStationHomepage: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataOfficialInternetRadioStationHomepage)
    }
  }
  
  @objc static public var id3MetadataOfficialPublisherWebpage: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataOfficialPublisherWebpage)
    }
  }
  
  @objc static public var id3MetadataOriginalAlbumTitle: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataOriginalAlbumTitle)
    }
  }
  
  @objc static public var id3MetadataOriginalArtist: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataOriginalArtist)
    }
  }
  
  @objc static public var id3MetadataOriginalFilename: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataOriginalFilename)
    }
  }
  
  @objc static public var id3MetadataOriginalLyricist: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataOriginalLyricist)
    }
  }
  
  @objc static public var id3MetadataOriginalReleaseTime: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataOriginalReleaseTime)
    }
  }
  
  @objc static public var id3MetadataOriginalReleaseYear: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataOriginalReleaseYear)
    }
  }
  
  @objc static public var id3MetadataOwnership: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataOwnership)
    }
  }
  
  @objc static public var id3MetadataPartOfASet: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataPartOfASet)
    }
  }
  
  @objc static public var id3MetadataPayment: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataPayment)
    }
  }
  
  @objc static public var id3MetadataPerformerSortOrder: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataPerformerSortOrder)
    }
  }
  
  @objc static public var id3MetadataPlayCounter: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataPlayCounter)
    }
  }
  
  @objc static public var id3MetadataPlaylistDelay: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataPlaylistDelay)
    }
  }
  
  @objc static public var id3MetadataPopularimeter: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataPopularimeter)
    }
  }
  
  @objc static public var id3MetadataPositionSynchronization: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataPositionSynchronization)
    }
  }
  
  @objc static public var id3MetadataPrivate: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataPrivate)
    }
  }
  
  @objc static public var id3MetadataProducedNotice: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataProducedNotice)
    }
  }
  
  @objc static public var id3MetadataPublisher: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataPublisher)
    }
  }
  
  @objc static public var id3MetadataRecommendedBufferSize: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataRecommendedBufferSize)
    }
  }
  
  @objc static public var id3MetadataRecordingDates: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataRecordingDates)
    }
  }
  
  @objc static public var id3MetadataRecordingTime: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataRecordingTime)
    }
  }
  
  @objc static public var id3MetadataRelativeVolumeAdjustment: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataRelativeVolumeAdjustment)
    }
  }
  
  @objc static public var id3MetadataRelativeVolumeAdjustment2: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataRelativeVolumeAdjustment2)
    }
  }
  
  @objc static public var id3MetadataReleaseTime: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataReleaseTime)
    }
  }
  
  @objc static public var id3MetadataReverb: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataReverb)
    }
  }
  
  @objc static public var id3MetadataSeek: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataSeek)
    }
  }
  
  @objc static public var id3MetadataSetSubtitle: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataSetSubtitle)
    }
  }
  
  @objc static public var id3MetadataSignature: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataSignature)
    }
  }
  
  @objc static public var id3MetadataSize: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataSize)
    }
  }
  
  @objc static public var id3MetadataSubTitle: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataSubTitle)
    }
  }
  
  @objc static public var id3MetadataSynchronizedLyric: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataSynchronizedLyric)
    }
  }
  
  @objc static public var id3MetadataSynchronizedTempoCodes: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataSynchronizedTempoCodes)
    }
  }
  
  @objc static public var id3MetadataTaggingTime: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataTaggingTime)
    }
  }
  
  @objc static public var id3MetadataTermsOfUse: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataTermsOfUse)
    }
  }
  
  @objc static public var id3MetadataTime: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataTime)
    }
  }
  
  @objc static public var id3MetadataTitleDescription: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataTitleDescription)
    }
  }
  
  @objc static public var id3MetadataTitleSortOrder: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataTitleSortOrder)
    }
  }
  
  @objc static public var id3MetadataTrackNumber: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataTrackNumber)
    }
  }
  
  @objc static public var id3MetadataUniqueFileIdentifier: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataUniqueFileIdentifier)
    }
  }
  
  @objc static public var id3MetadataUnsynchronizedLyric: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataUnsynchronizedLyric)
    }
  }
  
  @objc static public var id3MetadataUserText: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataUserText)
    }
  }
  
  @objc static public var id3MetadataUserURL: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataUserURL)
    }
  }
  
  @objc static public var id3MetadataYear: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.id3MetadataYear)
    }
  }
  
  @objc static public var isoUserDataAccessibilityDescription: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.isoUserDataAccessibilityDescription)
    }
  }
  
  @objc static public var isoUserDataCopyright: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.isoUserDataCopyright)
    }
  }
  
  @objc static public var isoUserDataDate: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.isoUserDataDate)
    }
  }
  
  @objc static public var isoUserDataTaggedCharacteristic: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.isoUserDataTaggedCharacteristic)
    }
  }
  
  @objc static public var icyMetadataStreamTitle: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.icyMetadataStreamTitle)
    }
  }
  
  @objc static public var icyMetadataStreamURL: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.icyMetadataStreamURL)
    }
  }
  
  @objc static public var quickTimeMetadataAccessibilityDescription: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataAccessibilityDescription)
    }
  }
  
  @objc static public var quickTimeMetadataAlbum: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataAlbum)
    }
  }
  
  @objc static public var quickTimeMetadataArranger: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataArranger)
    }
  }
  
  @objc static public var quickTimeMetadataArtist: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataArtist)
    }
  }
  
  @objc static public var quickTimeMetadataArtwork: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataArtwork)
    }
  }
  
  @objc static public var quickTimeMetadataAuthor: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataAuthor)
    }
  }
  
  @objc static public var quickTimeMetadataAutoLivePhoto: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataAutoLivePhoto)
    }
  }
  
  @objc static public var quickTimeMetadataCameraFrameReadoutTime: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataCameraFrameReadoutTime)
    }
  }
  
  @objc static public var quickTimeMetadataCameraIdentifier: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataCameraIdentifier)
    }
  }
  
  @objc static public var quickTimeMetadataCollectionUser: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataCollectionUser)
    }
  }
  
  @objc static public var quickTimeMetadataComment: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataComment)
    }
  }
  
  @objc static public var quickTimeMetadataComposer: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataComposer)
    }
  }
  
  @objc static public var quickTimeMetadataContentIdentifier: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataContentIdentifier)
    }
  }
  
  @objc static public var quickTimeMetadataCopyright: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataCopyright)
    }
  }
  
  @objc static public var quickTimeMetadataCreationDate: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataCreationDate)
    }
  }
  
  @objc static public var quickTimeMetadataCredits: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataCredits)
    }
  }
  
  @objc static public var quickTimeMetadataDescription: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataDescription)
    }
  }
  
  @objc static public var quickTimeMetadataDetectedCatBody: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataDetectedCatBody)
    }
  }
  
  @objc static public var quickTimeMetadataDetectedDogBody: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataDetectedDogBody)
    }
  }
  
  @objc static public var quickTimeMetadataDetectedFace: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataDetectedFace)
    }
  }
  
  @objc static public var quickTimeMetadataDetectedHumanBody: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataDetectedHumanBody)
    }
  }
  
  @objc static public var quickTimeMetadataDetectedSalientObject: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataDetectedSalientObject)
    }
  }
  
  @objc static public var quickTimeMetadataDirectionFacing: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataDirectionFacing)
    }
  }
  
  @objc static public var quickTimeMetadataDirectionMotion: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataDirectionMotion)
    }
  }
  
  @objc static public var quickTimeMetadataDirector: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataDirector)
    }
  }
  
  @objc static public var quickTimeMetadataDisplayName: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataDisplayName)
    }
  }
  
  @objc static public var quickTimeMetadataEncodedBy: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataEncodedBy)
    }
  }
  
  @objc static public var quickTimeMetadataGenre: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataGenre)
    }
  }
  
  @objc static public var quickTimeMetadataInformation: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataInformation)
    }
  }
  
  @objc static public var quickTimeMetadataIsMontage: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataIsMontage)
    }
  }
  
  @objc static public var quickTimeMetadataKeywords: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataKeywords)
    }
  }
  
  @objc static public var quickTimeMetadataLivePhotoVitalityScore: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataLivePhotoVitalityScore)
    }
  }
  
  @objc static public var quickTimeMetadataLivePhotoVitalityScoringVersion: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataLivePhotoVitalityScoringVersion)
    }
  }
  
  @objc static public var quickTimeMetadataLocationBody: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataLocationBody)
    }
  }
  
  @objc static public var quickTimeMetadataLocationDate: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataLocationDate)
    }
  }
  
  @objc static public var quickTimeMetadataLocationHorizontalAccuracyInMeters: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataLocationHorizontalAccuracyInMeters)
    }
  }
  
  @objc static public var quickTimeMetadataLocationISO6709: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataLocationISO6709)
    }
  }
  
  @objc static public var quickTimeMetadataLocationName: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataLocationName)
    }
  }
  
  @objc static public var quickTimeMetadataLocationNote: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataLocationNote)
    }
  }
  
  @objc static public var quickTimeMetadataLocationRole: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataLocationRole)
    }
  }
  
  @objc static public var quickTimeMetadataMake: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataMake)
    }
  }
  
  @objc static public var quickTimeMetadataModel: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataModel)
    }
  }
  
  @objc static public var quickTimeMetadataOriginalArtist: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataOriginalArtist)
    }
  }
  
  @objc static public var quickTimeMetadataPerformer: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataPerformer)
    }
  }
  
  @objc static public var quickTimeMetadataPhonogramRights: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataPhonogramRights)
    }
  }
  
  @objc static public var quickTimeMetadataPreferredAffineTransform: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataPreferredAffineTransform)
    }
  }
  
  @objc static public var quickTimeMetadataProducer: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataProducer)
    }
  }
  
  @objc static public var quickTimeMetadataPublisher: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataPublisher)
    }
  }
  
  @objc static public var quickTimeMetadataRatingUser: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataRatingUser)
    }
  }
  
  @objc static public var quickTimeMetadataSoftware: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataSoftware)
    }
  }
  
  @objc static public var quickTimeMetadataSpatialOverCaptureQualityScore: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataSpatialOverCaptureQualityScore)
    }
  }
  
  @objc static public var quickTimeMetadataSpatialOverCaptureQualityScoringVersion: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataSpatialOverCaptureQualityScoringVersion)
    }
  }
  
  @objc static public var quickTimeMetadataTitle: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataTitle)
    }
  }
  
  @objc static public var quickTimeMetadataVideoOrientation: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataVideoOrientation)
    }
  }
  
  @objc static public var quickTimeMetadataYear: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataYear)
    }
  }
  
  @objc static public var quickTimeMetadataiXML: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeMetadataiXML)
    }
  }
  
  @objc static public var quickTimeUserDataAccessibilityDescription: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataAccessibilityDescription)
    }
  }
  
  @objc static public var quickTimeUserDataAlbum: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataAlbum)
    }
  }
  
  @objc static public var quickTimeUserDataArranger: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataArranger)
    }
  }
  
  @objc static public var quickTimeUserDataArtist: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataArtist)
    }
  }
  
  @objc static public var quickTimeUserDataAuthor: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataAuthor)
    }
  }
  
  @objc static public var quickTimeUserDataChapter: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataChapter)
    }
  }
  
  @objc static public var quickTimeUserDataComment: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataComment)
    }
  }
  
  @objc static public var quickTimeUserDataComposer: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataComposer)
    }
  }
  
  @objc static public var quickTimeUserDataCopyright: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataCopyright)
    }
  }
  
  @objc static public var quickTimeUserDataCreationDate: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataCreationDate)
    }
  }
  
  @objc static public var quickTimeUserDataCredits: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataCredits)
    }
  }
  
  @objc static public var quickTimeUserDataDescription: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataDescription)
    }
  }
  
  @objc static public var quickTimeUserDataDirector: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataDirector)
    }
  }
  
  @objc static public var quickTimeUserDataDisclaimer: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataDisclaimer)
    }
  }
  
  @objc static public var quickTimeUserDataEncodedBy: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataEncodedBy)
    }
  }
  
  @objc static public var quickTimeUserDataFullName: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataFullName)
    }
  }
  
  @objc static public var quickTimeUserDataGenre: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataGenre)
    }
  }
  
  @objc static public var quickTimeUserDataHostComputer: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataHostComputer)
    }
  }
  
  @objc static public var quickTimeUserDataInformation: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataInformation)
    }
  }
  
  @objc static public var quickTimeUserDataKeywords: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataKeywords)
    }
  }
  
  @objc static public var quickTimeUserDataLocationISO6709: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataLocationISO6709)
    }
  }
  
  @objc static public var quickTimeUserDataMake: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataMake)
    }
  }
  
  @objc static public var quickTimeUserDataModel: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataModel)
    }
  }
  
  @objc static public var quickTimeUserDataOriginalArtist: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataOriginalArtist)
    }
  }
  
  @objc static public var quickTimeUserDataOriginalFormat: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataOriginalFormat)
    }
  }
  
  @objc static public var quickTimeUserDataOriginalSource: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataOriginalSource)
    }
  }
  
  @objc static public var quickTimeUserDataPerformers: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataPerformers)
    }
  }
  
  @objc static public var quickTimeUserDataPhonogramRights: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataPhonogramRights)
    }
  }
  
  @objc static public var quickTimeUserDataProducer: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataProducer)
    }
  }
  
  @objc static public var quickTimeUserDataProduct: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataProduct)
    }
  }
  
  @objc static public var quickTimeUserDataPublisher: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataPublisher)
    }
  }
  
  @objc static public var quickTimeUserDataSoftware: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataSoftware)
    }
  }
  
  @objc static public var quickTimeUserDataSpecialPlaybackRequirements: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataSpecialPlaybackRequirements)
    }
  }
  
  @objc static public var quickTimeUserDataTaggedCharacteristic: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataTaggedCharacteristic)
    }
  }
  
  @objc static public var quickTimeUserDataTrack: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataTrack)
    }
  }
  
  @objc static public var quickTimeUserDataTrackName: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataTrackName)
    }
  }
  
  @objc static public var quickTimeUserDataURLLink: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataURLLink)
    }
  }
  
  @objc static public var quickTimeUserDataWarning: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataWarning)
    }
  }
  
  @objc static public var quickTimeUserDataWriter: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.quickTimeUserDataWriter)
    }
  }
  
  @objc static public var iTunesMetadataAccountKind: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataAccountKind)
    }
  }
  
  @objc static public var iTunesMetadataAcknowledgement: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataAcknowledgement)
    }
  }
  
  @objc static public var iTunesMetadataAlbum: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataAlbum)
    }
  }
  
  @objc static public var iTunesMetadataAlbumArtist: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataAlbumArtist)
    }
  }
  
  @objc static public var iTunesMetadataAppleID: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataAppleID)
    }
  }
  
  @objc static public var iTunesMetadataArranger: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataArranger)
    }
  }
  
  @objc static public var iTunesMetadataArtDirector: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataArtDirector)
    }
  }
  
  @objc static public var iTunesMetadataArtist: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataArtist)
    }
  }
  
  @objc static public var iTunesMetadataArtistID: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataArtistID)
    }
  }
  
  @objc static public var iTunesMetadataAuthor: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataAuthor)
    }
  }
  
  @objc static public var iTunesMetadataBeatsPerMin: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataBeatsPerMin)
    }
  }
  
  @objc static public var iTunesMetadataComposer: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataComposer)
    }
  }
  
  @objc static public var iTunesMetadataConductor: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataConductor)
    }
  }
  
  @objc static public var iTunesMetadataContentRating: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataContentRating)
    }
  }
  
  @objc static public var iTunesMetadataCopyright: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataCopyright)
    }
  }
  
  @objc static public var iTunesMetadataCoverArt: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataCoverArt)
    }
  }
  
  @objc static public var iTunesMetadataCredits: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataCredits)
    }
  }
  
  @objc static public var iTunesMetadataDescription: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataDescription)
    }
  }
  
  @objc static public var iTunesMetadataDirector: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataDirector)
    }
  }
  
  @objc static public var iTunesMetadataDiscCompilation: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataDiscCompilation)
    }
  }
  
  @objc static public var iTunesMetadataDiscNumber: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataDiscNumber)
    }
  }
  
  @objc static public var iTunesMetadataEQ: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataEQ)
    }
  }
  
  @objc static public var iTunesMetadataEncodedBy: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataEncodedBy)
    }
  }
  
  @objc static public var iTunesMetadataEncodingTool: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataEncodingTool)
    }
  }
  
  @objc static public var iTunesMetadataExecProducer: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataExecProducer)
    }
  }
  
  @objc static public var iTunesMetadataGenreID: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataGenreID)
    }
  }
  
  @objc static public var iTunesMetadataGrouping: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataGrouping)
    }
  }
  
  @objc static public var iTunesMetadataLinerNotes: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataLinerNotes)
    }
  }
  
  @objc static public var iTunesMetadataLyrics: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataLyrics)
    }
  }
  
  @objc static public var iTunesMetadataOnlineExtras: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataOnlineExtras)
    }
  }
  
  @objc static public var iTunesMetadataOriginalArtist: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataOriginalArtist)
    }
  }
  
  @objc static public var iTunesMetadataPerformer: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataPerformer)
    }
  }
  
  @objc static public var iTunesMetadataPhonogramRights: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataPhonogramRights)
    }
  }
  
  @objc static public var iTunesMetadataPlaylistID: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataPlaylistID)
    }
  }
  
  @objc static public var iTunesMetadataPredefinedGenre: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataPredefinedGenre)
    }
  }
  
  @objc static public var iTunesMetadataProducer: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataProducer)
    }
  }
  
  @objc static public var iTunesMetadataPublisher: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataPublisher)
    }
  }
  
  @objc static public var iTunesMetadataRecordCompany: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataRecordCompany)
    }
  }
  
  @objc static public var iTunesMetadataReleaseDate: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataReleaseDate)
    }
  }
  
  @objc static public var iTunesMetadataSoloist: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataSoloist)
    }
  }
  
  @objc static public var iTunesMetadataSongID: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataSongID)
    }
  }
  
  @objc static public var iTunesMetadataSongName: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataSongName)
    }
  }
  
  @objc static public var iTunesMetadataSoundEngineer: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataSoundEngineer)
    }
  }
  
  @objc static public var iTunesMetadataThanks: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataThanks)
    }
  }
  
  @objc static public var iTunesMetadataTrackNumber: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataTrackNumber)
    }
  }
  
  @objc static public var iTunesMetadataTrackSubTitle: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataTrackSubTitle)
    }
  }
  
  @objc static public var iTunesMetadataUserComment: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataUserComment)
    }
  }
  
  @objc static public var iTunesMetadataUserGenre: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(AVMetadataIdentifier.iTunesMetadataUserGenre)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVMetadataIdentifier) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVMetadataIdentifier(rawValue: rawValue)
  }
  
  @objc init(_ rawValue: String) {
    wrappedInstance = AVMetadataIdentifier(_: rawValue)
  }
}

@objc public class AVMetadataKeyWrapper: NSObject {
  var wrappedInstance: AVMetadataKey
  
  @objc static public var metadata3GPUserDataKeyAlbumAndTrack: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.metadata3GPUserDataKeyAlbumAndTrack)
    }
  }
  
  @objc static public var metadata3GPUserDataKeyAuthor: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.metadata3GPUserDataKeyAuthor)
    }
  }
  
  @objc static public var metadata3GPUserDataKeyCollection: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.metadata3GPUserDataKeyCollection)
    }
  }
  
  @objc static public var metadata3GPUserDataKeyCopyright: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.metadata3GPUserDataKeyCopyright)
    }
  }
  
  @objc static public var metadata3GPUserDataKeyDescription: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.metadata3GPUserDataKeyDescription)
    }
  }
  
  @objc static public var metadata3GPUserDataKeyGenre: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.metadata3GPUserDataKeyGenre)
    }
  }
  
  @objc static public var metadata3GPUserDataKeyKeywordList: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.metadata3GPUserDataKeyKeywordList)
    }
  }
  
  @objc static public var metadata3GPUserDataKeyLocation: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.metadata3GPUserDataKeyLocation)
    }
  }
  
  @objc static public var metadata3GPUserDataKeyMediaClassification: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.metadata3GPUserDataKeyMediaClassification)
    }
  }
  
  @objc static public var metadata3GPUserDataKeyMediaRating: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.metadata3GPUserDataKeyMediaRating)
    }
  }
  
  @objc static public var metadata3GPUserDataKeyPerformer: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.metadata3GPUserDataKeyPerformer)
    }
  }
  
  @objc static public var metadata3GPUserDataKeyRecordingYear: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.metadata3GPUserDataKeyRecordingYear)
    }
  }
  
  @objc static public var metadata3GPUserDataKeyThumbnail: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.metadata3GPUserDataKeyThumbnail)
    }
  }
  
  @objc static public var metadata3GPUserDataKeyTitle: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.metadata3GPUserDataKeyTitle)
    }
  }
  
  @objc static public var metadata3GPUserDataKeyUserRating: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.metadata3GPUserDataKeyUserRating)
    }
  }
  
  @objc static public var commonKeyAccessibilityDescription: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.commonKeyAccessibilityDescription)
    }
  }
  
  @objc static public var commonKeyAlbumName: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.commonKeyAlbumName)
    }
  }
  
  @objc static public var commonKeyArtist: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.commonKeyArtist)
    }
  }
  
  @objc static public var commonKeyArtwork: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.commonKeyArtwork)
    }
  }
  
  @objc static public var commonKeyAuthor: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.commonKeyAuthor)
    }
  }
  
  @objc static public var commonKeyContributor: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.commonKeyContributor)
    }
  }
  
  @objc static public var commonKeyCopyrights: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.commonKeyCopyrights)
    }
  }
  
  @objc static public var commonKeyCreationDate: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.commonKeyCreationDate)
    }
  }
  
  @objc static public var commonKeyCreator: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.commonKeyCreator)
    }
  }
  
  @objc static public var commonKeyDescription: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.commonKeyDescription)
    }
  }
  
  @objc static public var commonKeyFormat: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.commonKeyFormat)
    }
  }
  
  @objc static public var commonKeyIdentifier: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.commonKeyIdentifier)
    }
  }
  
  @objc static public var commonKeyLanguage: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.commonKeyLanguage)
    }
  }
  
  @objc static public var commonKeyLastModifiedDate: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.commonKeyLastModifiedDate)
    }
  }
  
  @objc static public var commonKeyLocation: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.commonKeyLocation)
    }
  }
  
  @objc static public var commonKeyMake: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.commonKeyMake)
    }
  }
  
  @objc static public var commonKeyModel: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.commonKeyModel)
    }
  }
  
  @objc static public var commonKeyPublisher: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.commonKeyPublisher)
    }
  }
  
  @objc static public var commonKeyRelation: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.commonKeyRelation)
    }
  }
  
  @objc static public var commonKeySoftware: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.commonKeySoftware)
    }
  }
  
  @objc static public var commonKeySource: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.commonKeySource)
    }
  }
  
  @objc static public var commonKeySubject: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.commonKeySubject)
    }
  }
  
  @objc static public var commonKeyTitle: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.commonKeyTitle)
    }
  }
  
  @objc static public var commonKeyType: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.commonKeyType)
    }
  }
  
  @objc static public var id3MetadataKeyAlbumSortOrder: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyAlbumSortOrder)
    }
  }
  
  @objc static public var id3MetadataKeyAlbumTitle: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyAlbumTitle)
    }
  }
  
  @objc static public var id3MetadataKeyAttachedPicture: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyAttachedPicture)
    }
  }
  
  @objc static public var id3MetadataKeyAudioEncryption: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyAudioEncryption)
    }
  }
  
  @objc static public var id3MetadataKeyAudioSeekPointIndex: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyAudioSeekPointIndex)
    }
  }
  
  @objc static public var id3MetadataKeyBand: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyBand)
    }
  }
  
  @objc static public var id3MetadataKeyBeatsPerMinute: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyBeatsPerMinute)
    }
  }
  
  @objc static public var id3MetadataKeyComments: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyComments)
    }
  }
  
  @objc static public var id3MetadataKeyCommercial: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyCommercial)
    }
  }
  
  @objc static public var id3MetadataKeyCommercialInformation: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyCommercialInformation)
    }
  }
  
  @objc static public var id3MetadataKeyCommerical: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyCommerical)
    }
  }
  
  @objc static public var id3MetadataKeyComposer: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyComposer)
    }
  }
  
  @objc static public var id3MetadataKeyConductor: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyConductor)
    }
  }
  
  @objc static public var id3MetadataKeyContentGroupDescription: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyContentGroupDescription)
    }
  }
  
  @objc static public var id3MetadataKeyContentType: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyContentType)
    }
  }
  
  @objc static public var id3MetadataKeyCopyright: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyCopyright)
    }
  }
  
  @objc static public var id3MetadataKeyCopyrightInformation: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyCopyrightInformation)
    }
  }
  
  @objc static public var id3MetadataKeyDate: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyDate)
    }
  }
  
  @objc static public var id3MetadataKeyEncodedBy: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyEncodedBy)
    }
  }
  
  @objc static public var id3MetadataKeyEncodedWith: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyEncodedWith)
    }
  }
  
  @objc static public var id3MetadataKeyEncodingTime: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyEncodingTime)
    }
  }
  
  @objc static public var id3MetadataKeyEncryption: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyEncryption)
    }
  }
  
  @objc static public var id3MetadataKeyEqualization: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyEqualization)
    }
  }
  
  @objc static public var id3MetadataKeyEqualization2: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyEqualization2)
    }
  }
  
  @objc static public var id3MetadataKeyEventTimingCodes: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyEventTimingCodes)
    }
  }
  
  @objc static public var id3MetadataKeyFileOwner: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyFileOwner)
    }
  }
  
  @objc static public var id3MetadataKeyFileType: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyFileType)
    }
  }
  
  @objc static public var id3MetadataKeyGeneralEncapsulatedObject: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyGeneralEncapsulatedObject)
    }
  }
  
  @objc static public var id3MetadataKeyGroupIdentifier: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyGroupIdentifier)
    }
  }
  
  @objc static public var id3MetadataKeyInitialKey: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyInitialKey)
    }
  }
  
  @objc static public var id3MetadataKeyInternationalStandardRecordingCode: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyInternationalStandardRecordingCode)
    }
  }
  
  @objc static public var id3MetadataKeyInternetRadioStationName: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyInternetRadioStationName)
    }
  }
  
  @objc static public var id3MetadataKeyInternetRadioStationOwner: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyInternetRadioStationOwner)
    }
  }
  
  @objc static public var id3MetadataKeyInvolvedPeopleList_v23: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyInvolvedPeopleList_v23)
    }
  }
  
  @objc static public var id3MetadataKeyInvolvedPeopleList_v24: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyInvolvedPeopleList_v24)
    }
  }
  
  @objc static public var id3MetadataKeyLanguage: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyLanguage)
    }
  }
  
  @objc static public var id3MetadataKeyLeadPerformer: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyLeadPerformer)
    }
  }
  
  @objc static public var id3MetadataKeyLength: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyLength)
    }
  }
  
  @objc static public var id3MetadataKeyLink: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyLink)
    }
  }
  
  @objc static public var id3MetadataKeyLyricist: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyLyricist)
    }
  }
  
  @objc static public var id3MetadataKeyMPEGLocationLookupTable: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyMPEGLocationLookupTable)
    }
  }
  
  @objc static public var id3MetadataKeyMediaType: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyMediaType)
    }
  }
  
  @objc static public var id3MetadataKeyModifiedBy: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyModifiedBy)
    }
  }
  
  @objc static public var id3MetadataKeyMood: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyMood)
    }
  }
  
  @objc static public var id3MetadataKeyMusicCDIdentifier: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyMusicCDIdentifier)
    }
  }
  
  @objc static public var id3MetadataKeyMusicianCreditsList: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyMusicianCreditsList)
    }
  }
  
  @objc static public var id3MetadataKeyOfficialArtistWebpage: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyOfficialArtistWebpage)
    }
  }
  
  @objc static public var id3MetadataKeyOfficialAudioFileWebpage: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyOfficialAudioFileWebpage)
    }
  }
  
  @objc static public var id3MetadataKeyOfficialAudioSourceWebpage: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyOfficialAudioSourceWebpage)
    }
  }
  
  @objc static public var id3MetadataKeyOfficialInternetRadioStationHomepage: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyOfficialInternetRadioStationHomepage)
    }
  }
  
  @objc static public var id3MetadataKeyOfficialPublisherWebpage: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyOfficialPublisherWebpage)
    }
  }
  
  @objc static public var id3MetadataKeyOriginalAlbumTitle: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyOriginalAlbumTitle)
    }
  }
  
  @objc static public var id3MetadataKeyOriginalArtist: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyOriginalArtist)
    }
  }
  
  @objc static public var id3MetadataKeyOriginalFilename: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyOriginalFilename)
    }
  }
  
  @objc static public var id3MetadataKeyOriginalLyricist: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyOriginalLyricist)
    }
  }
  
  @objc static public var id3MetadataKeyOriginalReleaseTime: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyOriginalReleaseTime)
    }
  }
  
  @objc static public var id3MetadataKeyOriginalReleaseYear: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyOriginalReleaseYear)
    }
  }
  
  @objc static public var id3MetadataKeyOwnership: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyOwnership)
    }
  }
  
  @objc static public var id3MetadataKeyPartOfASet: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyPartOfASet)
    }
  }
  
  @objc static public var id3MetadataKeyPayment: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyPayment)
    }
  }
  
  @objc static public var id3MetadataKeyPerformerSortOrder: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyPerformerSortOrder)
    }
  }
  
  @objc static public var id3MetadataKeyPlayCounter: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyPlayCounter)
    }
  }
  
  @objc static public var id3MetadataKeyPlaylistDelay: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyPlaylistDelay)
    }
  }
  
  @objc static public var id3MetadataKeyPopularimeter: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyPopularimeter)
    }
  }
  
  @objc static public var id3MetadataKeyPositionSynchronization: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyPositionSynchronization)
    }
  }
  
  @objc static public var id3MetadataKeyPrivate: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyPrivate)
    }
  }
  
  @objc static public var id3MetadataKeyProducedNotice: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyProducedNotice)
    }
  }
  
  @objc static public var id3MetadataKeyPublisher: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyPublisher)
    }
  }
  
  @objc static public var id3MetadataKeyRecommendedBufferSize: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyRecommendedBufferSize)
    }
  }
  
  @objc static public var id3MetadataKeyRecordingDates: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyRecordingDates)
    }
  }
  
  @objc static public var id3MetadataKeyRecordingTime: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyRecordingTime)
    }
  }
  
  @objc static public var id3MetadataKeyRelativeVolumeAdjustment: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyRelativeVolumeAdjustment)
    }
  }
  
  @objc static public var id3MetadataKeyRelativeVolumeAdjustment2: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyRelativeVolumeAdjustment2)
    }
  }
  
  @objc static public var id3MetadataKeyReleaseTime: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyReleaseTime)
    }
  }
  
  @objc static public var id3MetadataKeyReverb: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyReverb)
    }
  }
  
  @objc static public var id3MetadataKeySeek: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeySeek)
    }
  }
  
  @objc static public var id3MetadataKeySetSubtitle: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeySetSubtitle)
    }
  }
  
  @objc static public var id3MetadataKeySignature: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeySignature)
    }
  }
  
  @objc static public var id3MetadataKeySize: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeySize)
    }
  }
  
  @objc static public var id3MetadataKeySubTitle: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeySubTitle)
    }
  }
  
  @objc static public var id3MetadataKeySynchronizedLyric: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeySynchronizedLyric)
    }
  }
  
  @objc static public var id3MetadataKeySynchronizedTempoCodes: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeySynchronizedTempoCodes)
    }
  }
  
  @objc static public var id3MetadataKeyTaggingTime: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyTaggingTime)
    }
  }
  
  @objc static public var id3MetadataKeyTermsOfUse: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyTermsOfUse)
    }
  }
  
  @objc static public var id3MetadataKeyTime: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyTime)
    }
  }
  
  @objc static public var id3MetadataKeyTitleDescription: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyTitleDescription)
    }
  }
  
  @objc static public var id3MetadataKeyTitleSortOrder: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyTitleSortOrder)
    }
  }
  
  @objc static public var id3MetadataKeyTrackNumber: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyTrackNumber)
    }
  }
  
  @objc static public var id3MetadataKeyUniqueFileIdentifier: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyUniqueFileIdentifier)
    }
  }
  
  @objc static public var id3MetadataKeyUnsynchronizedLyric: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyUnsynchronizedLyric)
    }
  }
  
  @objc static public var id3MetadataKeyUserText: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyUserText)
    }
  }
  
  @objc static public var id3MetadataKeyUserURL: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyUserURL)
    }
  }
  
  @objc static public var id3MetadataKeyYear: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.id3MetadataKeyYear)
    }
  }
  
  @objc static public var isoUserDataKeyAccessibilityDescription: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.isoUserDataKeyAccessibilityDescription)
    }
  }
  
  @objc static public var isoUserDataKeyCopyright: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.isoUserDataKeyCopyright)
    }
  }
  
  @objc static public var isoUserDataKeyDate: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.isoUserDataKeyDate)
    }
  }
  
  @objc static public var isoUserDataKeyTaggedCharacteristic: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.isoUserDataKeyTaggedCharacteristic)
    }
  }
  
  @objc static public var icyMetadataKeyStreamTitle: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.icyMetadataKeyStreamTitle)
    }
  }
  
  @objc static public var icyMetadataKeyStreamURL: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.icyMetadataKeyStreamURL)
    }
  }
  
  @objc static public var quickTimeMetadataKeyAccessibilityDescription: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyAccessibilityDescription)
    }
  }
  
  @objc static public var quickTimeMetadataKeyAlbum: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyAlbum)
    }
  }
  
  @objc static public var quickTimeMetadataKeyArranger: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyArranger)
    }
  }
  
  @objc static public var quickTimeMetadataKeyArtist: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyArtist)
    }
  }
  
  @objc static public var quickTimeMetadataKeyArtwork: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyArtwork)
    }
  }
  
  @objc static public var quickTimeMetadataKeyAuthor: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyAuthor)
    }
  }
  
  @objc static public var quickTimeMetadataKeyCameraFrameReadoutTime: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyCameraFrameReadoutTime)
    }
  }
  
  @objc static public var quickTimeMetadataKeyCameraIdentifier: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyCameraIdentifier)
    }
  }
  
  @objc static public var quickTimeMetadataKeyCollectionUser: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyCollectionUser)
    }
  }
  
  @objc static public var quickTimeMetadataKeyComment: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyComment)
    }
  }
  
  @objc static public var quickTimeMetadataKeyComposer: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyComposer)
    }
  }
  
  @objc static public var quickTimeMetadataKeyContentIdentifier: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyContentIdentifier)
    }
  }
  
  @objc static public var quickTimeMetadataKeyCopyright: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyCopyright)
    }
  }
  
  @objc static public var quickTimeMetadataKeyCreationDate: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyCreationDate)
    }
  }
  
  @objc static public var quickTimeMetadataKeyCredits: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyCredits)
    }
  }
  
  @objc static public var quickTimeMetadataKeyDescription: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyDescription)
    }
  }
  
  @objc static public var quickTimeMetadataKeyDirectionFacing: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyDirectionFacing)
    }
  }
  
  @objc static public var quickTimeMetadataKeyDirectionMotion: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyDirectionMotion)
    }
  }
  
  @objc static public var quickTimeMetadataKeyDirector: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyDirector)
    }
  }
  
  @objc static public var quickTimeMetadataKeyDisplayName: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyDisplayName)
    }
  }
  
  @objc static public var quickTimeMetadataKeyEncodedBy: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyEncodedBy)
    }
  }
  
  @objc static public var quickTimeMetadataKeyGenre: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyGenre)
    }
  }
  
  @objc static public var quickTimeMetadataKeyInformation: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyInformation)
    }
  }
  
  @objc static public var quickTimeMetadataKeyIsMontage: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyIsMontage)
    }
  }
  
  @objc static public var quickTimeMetadataKeyKeywords: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyKeywords)
    }
  }
  
  @objc static public var quickTimeMetadataKeyLocationBody: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyLocationBody)
    }
  }
  
  @objc static public var quickTimeMetadataKeyLocationDate: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyLocationDate)
    }
  }
  
  @objc static public var quickTimeMetadataKeyLocationISO6709: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyLocationISO6709)
    }
  }
  
  @objc static public var quickTimeMetadataKeyLocationName: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyLocationName)
    }
  }
  
  @objc static public var quickTimeMetadataKeyLocationNote: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyLocationNote)
    }
  }
  
  @objc static public var quickTimeMetadataKeyLocationRole: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyLocationRole)
    }
  }
  
  @objc static public var quickTimeMetadataKeyMake: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyMake)
    }
  }
  
  @objc static public var quickTimeMetadataKeyModel: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyModel)
    }
  }
  
  @objc static public var quickTimeMetadataKeyOriginalArtist: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyOriginalArtist)
    }
  }
  
  @objc static public var quickTimeMetadataKeyPerformer: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyPerformer)
    }
  }
  
  @objc static public var quickTimeMetadataKeyPhonogramRights: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyPhonogramRights)
    }
  }
  
  @objc static public var quickTimeMetadataKeyProducer: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyProducer)
    }
  }
  
  @objc static public var quickTimeMetadataKeyPublisher: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyPublisher)
    }
  }
  
  @objc static public var quickTimeMetadataKeyRatingUser: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyRatingUser)
    }
  }
  
  @objc static public var quickTimeMetadataKeySoftware: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeySoftware)
    }
  }
  
  @objc static public var quickTimeMetadataKeyTitle: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyTitle)
    }
  }
  
  @objc static public var quickTimeMetadataKeyYear: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyYear)
    }
  }
  
  @objc static public var quickTimeMetadataKeyiXML: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeMetadataKeyiXML)
    }
  }
  
  @objc static public var quickTimeUserDataKeyAccessibilityDescription: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyAccessibilityDescription)
    }
  }
  
  @objc static public var quickTimeUserDataKeyAlbum: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyAlbum)
    }
  }
  
  @objc static public var quickTimeUserDataKeyArranger: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyArranger)
    }
  }
  
  @objc static public var quickTimeUserDataKeyArtist: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyArtist)
    }
  }
  
  @objc static public var quickTimeUserDataKeyAuthor: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyAuthor)
    }
  }
  
  @objc static public var quickTimeUserDataKeyChapter: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyChapter)
    }
  }
  
  @objc static public var quickTimeUserDataKeyComment: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyComment)
    }
  }
  
  @objc static public var quickTimeUserDataKeyComposer: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyComposer)
    }
  }
  
  @objc static public var quickTimeUserDataKeyCopyright: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyCopyright)
    }
  }
  
  @objc static public var quickTimeUserDataKeyCreationDate: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyCreationDate)
    }
  }
  
  @objc static public var quickTimeUserDataKeyCredits: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyCredits)
    }
  }
  
  @objc static public var quickTimeUserDataKeyDescription: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyDescription)
    }
  }
  
  @objc static public var quickTimeUserDataKeyDirector: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyDirector)
    }
  }
  
  @objc static public var quickTimeUserDataKeyDisclaimer: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyDisclaimer)
    }
  }
  
  @objc static public var quickTimeUserDataKeyEncodedBy: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyEncodedBy)
    }
  }
  
  @objc static public var quickTimeUserDataKeyFullName: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyFullName)
    }
  }
  
  @objc static public var quickTimeUserDataKeyGenre: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyGenre)
    }
  }
  
  @objc static public var quickTimeUserDataKeyHostComputer: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyHostComputer)
    }
  }
  
  @objc static public var quickTimeUserDataKeyInformation: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyInformation)
    }
  }
  
  @objc static public var quickTimeUserDataKeyKeywords: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyKeywords)
    }
  }
  
  @objc static public var quickTimeUserDataKeyLocationISO6709: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyLocationISO6709)
    }
  }
  
  @objc static public var quickTimeUserDataKeyMake: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyMake)
    }
  }
  
  @objc static public var quickTimeUserDataKeyModel: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyModel)
    }
  }
  
  @objc static public var quickTimeUserDataKeyOriginalArtist: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyOriginalArtist)
    }
  }
  
  @objc static public var quickTimeUserDataKeyOriginalFormat: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyOriginalFormat)
    }
  }
  
  @objc static public var quickTimeUserDataKeyOriginalSource: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyOriginalSource)
    }
  }
  
  @objc static public var quickTimeUserDataKeyPerformers: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyPerformers)
    }
  }
  
  @objc static public var quickTimeUserDataKeyPhonogramRights: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyPhonogramRights)
    }
  }
  
  @objc static public var quickTimeUserDataKeyProducer: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyProducer)
    }
  }
  
  @objc static public var quickTimeUserDataKeyProduct: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyProduct)
    }
  }
  
  @objc static public var quickTimeUserDataKeyPublisher: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyPublisher)
    }
  }
  
  @objc static public var quickTimeUserDataKeySoftware: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeySoftware)
    }
  }
  
  @objc static public var quickTimeUserDataKeySpecialPlaybackRequirements: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeySpecialPlaybackRequirements)
    }
  }
  
  @objc static public var quickTimeUserDataKeyTaggedCharacteristic: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyTaggedCharacteristic)
    }
  }
  
  @objc static public var quickTimeUserDataKeyTrack: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyTrack)
    }
  }
  
  @objc static public var quickTimeUserDataKeyTrackName: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyTrackName)
    }
  }
  
  @objc static public var quickTimeUserDataKeyURLLink: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyURLLink)
    }
  }
  
  @objc static public var quickTimeUserDataKeyWarning: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyWarning)
    }
  }
  
  @objc static public var quickTimeUserDataKeyWriter: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.quickTimeUserDataKeyWriter)
    }
  }
  
  @objc static public var iTunesMetadataKeyAccountKind: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyAccountKind)
    }
  }
  
  @objc static public var iTunesMetadataKeyAcknowledgement: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyAcknowledgement)
    }
  }
  
  @objc static public var iTunesMetadataKeyAlbum: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyAlbum)
    }
  }
  
  @objc static public var iTunesMetadataKeyAlbumArtist: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyAlbumArtist)
    }
  }
  
  @objc static public var iTunesMetadataKeyAppleID: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyAppleID)
    }
  }
  
  @objc static public var iTunesMetadataKeyArranger: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyArranger)
    }
  }
  
  @objc static public var iTunesMetadataKeyArtDirector: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyArtDirector)
    }
  }
  
  @objc static public var iTunesMetadataKeyArtist: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyArtist)
    }
  }
  
  @objc static public var iTunesMetadataKeyArtistID: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyArtistID)
    }
  }
  
  @objc static public var iTunesMetadataKeyAuthor: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyAuthor)
    }
  }
  
  @objc static public var iTunesMetadataKeyBeatsPerMin: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyBeatsPerMin)
    }
  }
  
  @objc static public var iTunesMetadataKeyComposer: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyComposer)
    }
  }
  
  @objc static public var iTunesMetadataKeyConductor: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyConductor)
    }
  }
  
  @objc static public var iTunesMetadataKeyContentRating: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyContentRating)
    }
  }
  
  @objc static public var iTunesMetadataKeyCopyright: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyCopyright)
    }
  }
  
  @objc static public var iTunesMetadataKeyCoverArt: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyCoverArt)
    }
  }
  
  @objc static public var iTunesMetadataKeyCredits: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyCredits)
    }
  }
  
  @objc static public var iTunesMetadataKeyDescription: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyDescription)
    }
  }
  
  @objc static public var iTunesMetadataKeyDirector: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyDirector)
    }
  }
  
  @objc static public var iTunesMetadataKeyDiscCompilation: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyDiscCompilation)
    }
  }
  
  @objc static public var iTunesMetadataKeyDiscNumber: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyDiscNumber)
    }
  }
  
  @objc static public var iTunesMetadataKeyEQ: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyEQ)
    }
  }
  
  @objc static public var iTunesMetadataKeyEncodedBy: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyEncodedBy)
    }
  }
  
  @objc static public var iTunesMetadataKeyEncodingTool: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyEncodingTool)
    }
  }
  
  @objc static public var iTunesMetadataKeyExecProducer: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyExecProducer)
    }
  }
  
  @objc static public var iTunesMetadataKeyGenreID: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyGenreID)
    }
  }
  
  @objc static public var iTunesMetadataKeyGrouping: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyGrouping)
    }
  }
  
  @objc static public var iTunesMetadataKeyLinerNotes: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyLinerNotes)
    }
  }
  
  @objc static public var iTunesMetadataKeyLyrics: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyLyrics)
    }
  }
  
  @objc static public var iTunesMetadataKeyOnlineExtras: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyOnlineExtras)
    }
  }
  
  @objc static public var iTunesMetadataKeyOriginalArtist: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyOriginalArtist)
    }
  }
  
  @objc static public var iTunesMetadataKeyPerformer: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyPerformer)
    }
  }
  
  @objc static public var iTunesMetadataKeyPhonogramRights: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyPhonogramRights)
    }
  }
  
  @objc static public var iTunesMetadataKeyPlaylistID: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyPlaylistID)
    }
  }
  
  @objc static public var iTunesMetadataKeyPredefinedGenre: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyPredefinedGenre)
    }
  }
  
  @objc static public var iTunesMetadataKeyProducer: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyProducer)
    }
  }
  
  @objc static public var iTunesMetadataKeyPublisher: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyPublisher)
    }
  }
  
  @objc static public var iTunesMetadataKeyRecordCompany: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyRecordCompany)
    }
  }
  
  @objc static public var iTunesMetadataKeyReleaseDate: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyReleaseDate)
    }
  }
  
  @objc static public var iTunesMetadataKeySoloist: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeySoloist)
    }
  }
  
  @objc static public var iTunesMetadataKeySongID: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeySongID)
    }
  }
  
  @objc static public var iTunesMetadataKeySongName: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeySongName)
    }
  }
  
  @objc static public var iTunesMetadataKeySoundEngineer: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeySoundEngineer)
    }
  }
  
  @objc static public var iTunesMetadataKeyThanks: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyThanks)
    }
  }
  
  @objc static public var iTunesMetadataKeyTrackNumber: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyTrackNumber)
    }
  }
  
  @objc static public var iTunesMetadataKeyTrackSubTitle: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyTrackSubTitle)
    }
  }
  
  @objc static public var iTunesMetadataKeyUserComment: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyUserComment)
    }
  }
  
  @objc static public var iTunesMetadataKeyUserGenre: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(AVMetadataKey.iTunesMetadataKeyUserGenre)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVMetadataKey) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVMetadataKey(rawValue: rawValue)
  }
  
  @objc init(_ rawValue: String) {
    wrappedInstance = AVMetadataKey(_: rawValue)
  }
}

@objc public class AVMetadataKeySpaceWrapper: NSObject {
  var wrappedInstance: AVMetadataKeySpace
  
  @objc static public var audioFile: AVMetadataKeySpaceWrapper {
    get {
      AVMetadataKeySpaceWrapper(AVMetadataKeySpace.audioFile)
    }
  }
  
  @objc static public var common: AVMetadataKeySpaceWrapper {
    get {
      AVMetadataKeySpaceWrapper(AVMetadataKeySpace.common)
    }
  }
  
  @objc static public var hlsDateRange: AVMetadataKeySpaceWrapper {
    get {
      AVMetadataKeySpaceWrapper(AVMetadataKeySpace.hlsDateRange)
    }
  }
  
  @objc static public var id3: AVMetadataKeySpaceWrapper {
    get {
      AVMetadataKeySpaceWrapper(AVMetadataKeySpace.id3)
    }
  }
  
  @objc static public var isoUserData: AVMetadataKeySpaceWrapper {
    get {
      AVMetadataKeySpaceWrapper(AVMetadataKeySpace.isoUserData)
    }
  }
  
  @objc static public var icy: AVMetadataKeySpaceWrapper {
    get {
      AVMetadataKeySpaceWrapper(AVMetadataKeySpace.icy)
    }
  }
  
  @objc static public var quickTimeMetadata: AVMetadataKeySpaceWrapper {
    get {
      AVMetadataKeySpaceWrapper(AVMetadataKeySpace.quickTimeMetadata)
    }
  }
  
  @objc static public var quickTimeUserData: AVMetadataKeySpaceWrapper {
    get {
      AVMetadataKeySpaceWrapper(AVMetadataKeySpace.quickTimeUserData)
    }
  }
  
  @objc static public var iTunes: AVMetadataKeySpaceWrapper {
    get {
      AVMetadataKeySpaceWrapper(AVMetadataKeySpace.iTunes)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVMetadataKeySpace) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVMetadataKeySpace(rawValue: rawValue)
  }
  
  @objc init(_ rawValue: String) {
    wrappedInstance = AVMetadataKeySpace(_: rawValue)
  }
}

@objc public class ObjectTypeWrapper: NSObject {
  var wrappedInstance: AVMetadataObject.ObjectType
  
  @objc static public var aztec: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(AVMetadataObject.ObjectType.aztec)
    }
  }
  
  @objc static public var catBody: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(AVMetadataObject.ObjectType.catBody)
    }
  }
  
  @objc static public var codabar: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(AVMetadataObject.ObjectType.codabar)
    }
  }
  
  @objc static public var code128: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(AVMetadataObject.ObjectType.code128)
    }
  }
  
  @objc static public var code39: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(AVMetadataObject.ObjectType.code39)
    }
  }
  
  @objc static public var code39Mod43: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(AVMetadataObject.ObjectType.code39Mod43)
    }
  }
  
  @objc static public var code93: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(AVMetadataObject.ObjectType.code93)
    }
  }
  
  @objc static public var dataMatrix: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(AVMetadataObject.ObjectType.dataMatrix)
    }
  }
  
  @objc static public var dogBody: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(AVMetadataObject.ObjectType.dogBody)
    }
  }
  
  @objc static public var ean13: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(AVMetadataObject.ObjectType.ean13)
    }
  }
  
  @objc static public var ean8: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(AVMetadataObject.ObjectType.ean8)
    }
  }
  
  @objc static public var face: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(AVMetadataObject.ObjectType.face)
    }
  }
  
  @objc static public var gs1DataBar: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(AVMetadataObject.ObjectType.gs1DataBar)
    }
  }
  
  @objc static public var gs1DataBarExpanded: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(AVMetadataObject.ObjectType.gs1DataBarExpanded)
    }
  }
  
  @objc static public var gs1DataBarLimited: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(AVMetadataObject.ObjectType.gs1DataBarLimited)
    }
  }
  
  @objc static public var humanBody: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(AVMetadataObject.ObjectType.humanBody)
    }
  }
  
  @objc static public var humanFullBody: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(AVMetadataObject.ObjectType.humanFullBody)
    }
  }
  
  @objc static public var itf14: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(AVMetadataObject.ObjectType.itf14)
    }
  }
  
  @objc static public var interleaved2of5: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(AVMetadataObject.ObjectType.interleaved2of5)
    }
  }
  
  @objc static public var microPDF417: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(AVMetadataObject.ObjectType.microPDF417)
    }
  }
  
  @objc static public var microQR: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(AVMetadataObject.ObjectType.microQR)
    }
  }
  
  @objc static public var pdf417: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(AVMetadataObject.ObjectType.pdf417)
    }
  }
  
  @objc static public var qr: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(AVMetadataObject.ObjectType.qr)
    }
  }
  
  @objc static public var salientObject: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(AVMetadataObject.ObjectType.salientObject)
    }
  }
  
  @objc static public var upce: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(AVMetadataObject.ObjectType.upce)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVMetadataObject.ObjectType) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVMetadataObject.ObjectType(rawValue: rawValue)
  }
}

@objc public class AVOutputSettingsPresetWrapper: NSObject {
  var wrappedInstance: AVOutputSettingsPreset
  
  @objc static public var preset1280x720: AVOutputSettingsPresetWrapper {
    get {
      AVOutputSettingsPresetWrapper(AVOutputSettingsPreset.preset1280x720)
    }
  }
  
  @objc static public var preset1920x1080: AVOutputSettingsPresetWrapper {
    get {
      AVOutputSettingsPresetWrapper(AVOutputSettingsPreset.preset1920x1080)
    }
  }
  
  @objc static public var preset3840x2160: AVOutputSettingsPresetWrapper {
    get {
      AVOutputSettingsPresetWrapper(AVOutputSettingsPreset.preset3840x2160)
    }
  }
  
  @objc static public var preset640x480: AVOutputSettingsPresetWrapper {
    get {
      AVOutputSettingsPresetWrapper(AVOutputSettingsPreset.preset640x480)
    }
  }
  
  @objc static public var preset960x540: AVOutputSettingsPresetWrapper {
    get {
      AVOutputSettingsPresetWrapper(AVOutputSettingsPreset.preset960x540)
    }
  }
  
  @objc static public var hevc1920x1080: AVOutputSettingsPresetWrapper {
    get {
      AVOutputSettingsPresetWrapper(AVOutputSettingsPreset.hevc1920x1080)
    }
  }
  
  @objc static public var hevc1920x1080WithAlpha: AVOutputSettingsPresetWrapper {
    get {
      AVOutputSettingsPresetWrapper(AVOutputSettingsPreset.hevc1920x1080WithAlpha)
    }
  }
  
  @objc static public var hevc3840x2160: AVOutputSettingsPresetWrapper {
    get {
      AVOutputSettingsPresetWrapper(AVOutputSettingsPreset.hevc3840x2160)
    }
  }
  
  @objc static public var hevc3840x2160WithAlpha: AVOutputSettingsPresetWrapper {
    get {
      AVOutputSettingsPresetWrapper(AVOutputSettingsPreset.hevc3840x2160WithAlpha)
    }
  }
  
  @objc static public var hevc7680x4320: AVOutputSettingsPresetWrapper {
    get {
      AVOutputSettingsPresetWrapper(AVOutputSettingsPreset.hevc7680x4320)
    }
  }
  
  @objc static public var mvhevc1440x1440: AVOutputSettingsPresetWrapper {
    get {
      AVOutputSettingsPresetWrapper(AVOutputSettingsPreset.mvhevc1440x1440)
    }
  }
  
  @objc static public var mvhevc960x960: AVOutputSettingsPresetWrapper {
    get {
      AVOutputSettingsPresetWrapper(AVOutputSettingsPreset.mvhevc960x960)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVOutputSettingsPreset) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVOutputSettingsPreset(rawValue: rawValue)
  }
}

@objc public class CueWrapper: NSObject {
  var wrappedInstance: AVPlayerInterstitialEvent.Cue
  
  @objc static public var joinCue: AVPlayerInterstitialEventWrapper {
    get {
      AVPlayerInterstitialEventWrapper(AVPlayerInterstitialEvent.Cue.joinCue)
    }
  }
  
  @objc static public var leaveCue: AVPlayerInterstitialEventWrapper {
    get {
      AVPlayerInterstitialEventWrapper(AVPlayerInterstitialEvent.Cue.leaveCue)
    }
  }
  
  @objc static public var noCue: AVPlayerInterstitialEventWrapper {
    get {
      AVPlayerInterstitialEventWrapper(AVPlayerInterstitialEvent.Cue.noCue)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVPlayerInterstitialEvent.Cue) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVPlayerInterstitialEvent.Cue(rawValue: rawValue)
  }
}

@objc public class TextStylingResolutionWrapper: NSObject {
  var wrappedInstance: AVPlayerItemLegibleOutput.TextStylingResolution
  
  @objc static public var `default`: AVPlayerItemLegibleOutputWrapper {
    get {
      AVPlayerItemLegibleOutputWrapper(AVPlayerItemLegibleOutput.TextStylingResolution.`default`)
    }
  }
  
  @objc static public var sourceAndRulesOnly: AVPlayerItemLegibleOutputWrapper {
    get {
      AVPlayerItemLegibleOutputWrapper(AVPlayerItemLegibleOutput.TextStylingResolution.sourceAndRulesOnly)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVPlayerItemLegibleOutput.TextStylingResolution) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVPlayerItemLegibleOutput.TextStylingResolution(rawValue: rawValue)
  }
}

@objc public class RateDidChangeReasonWrapper: NSObject {
  var wrappedInstance: AVPlayer.RateDidChangeReason
  
  @objc static public var appBackgrounded: AVPlayerWrapper {
    get {
      AVPlayerWrapper(AVPlayer.RateDidChangeReason.appBackgrounded)
    }
  }
  
  @objc static public var audioSessionInterrupted: AVPlayerWrapper {
    get {
      AVPlayerWrapper(AVPlayer.RateDidChangeReason.audioSessionInterrupted)
    }
  }
  
  @objc static public var setRateCalled: AVPlayerWrapper {
    get {
      AVPlayerWrapper(AVPlayer.RateDidChangeReason.setRateCalled)
    }
  }
  
  @objc static public var setRateFailed: AVPlayerWrapper {
    get {
      AVPlayerWrapper(AVPlayer.RateDidChangeReason.setRateFailed)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVPlayer.RateDidChangeReason) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVPlayer.RateDidChangeReason(rawValue: rawValue)
  }
}

@objc public class WaitingReasonWrapper: NSObject {
  var wrappedInstance: AVPlayer.WaitingReason
  
  @objc static public var interstitialEvent: AVPlayerWrapper {
    get {
      AVPlayerWrapper(AVPlayer.WaitingReason.interstitialEvent)
    }
  }
  
  @objc static public var waitingForCoordinatedPlayback: AVPlayerWrapper {
    get {
      AVPlayerWrapper(AVPlayer.WaitingReason.waitingForCoordinatedPlayback)
    }
  }
  
  @objc static public var toMinimizeStalls: AVPlayerWrapper {
    get {
      AVPlayerWrapper(AVPlayer.WaitingReason.toMinimizeStalls)
    }
  }
  
  @objc static public var evaluatingBufferingRate: AVPlayerWrapper {
    get {
      AVPlayerWrapper(AVPlayer.WaitingReason.evaluatingBufferingRate)
    }
  }
  
  @objc static public var noItemToPlay: AVPlayerWrapper {
    get {
      AVPlayerWrapper(AVPlayer.WaitingReason.noItemToPlay)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVPlayer.WaitingReason) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVPlayer.WaitingReason(rawValue: rawValue)
  }
}

@objc public class MatteTypeWrapper: NSObject {
  var wrappedInstance: AVSemanticSegmentationMatte.MatteType
  
  @objc static public var glasses: AVSemanticSegmentationMatteWrapper {
    get {
      AVSemanticSegmentationMatteWrapper(AVSemanticSegmentationMatte.MatteType.glasses)
    }
  }
  
  @objc static public var hair: AVSemanticSegmentationMatteWrapper {
    get {
      AVSemanticSegmentationMatteWrapper(AVSemanticSegmentationMatte.MatteType.hair)
    }
  }
  
  @objc static public var skin: AVSemanticSegmentationMatteWrapper {
    get {
      AVSemanticSegmentationMatteWrapper(AVSemanticSegmentationMatte.MatteType.skin)
    }
  }
  
  @objc static public var teeth: AVSemanticSegmentationMatteWrapper {
    get {
      AVSemanticSegmentationMatteWrapper(AVSemanticSegmentationMatte.MatteType.teeth)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVSemanticSegmentationMatte.MatteType) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVSemanticSegmentationMatte.MatteType(rawValue: rawValue)
  }
}

@objc public class AssociationTypeWrapper: NSObject {
  var wrappedInstance: AVAssetTrack.AssociationType
  
  @objc static public var audioFallback: AVAssetTrackWrapper {
    get {
      AVAssetTrackWrapper(AVAssetTrack.AssociationType.audioFallback)
    }
  }
  
  @objc static public var chapterList: AVAssetTrackWrapper {
    get {
      AVAssetTrackWrapper(AVAssetTrack.AssociationType.chapterList)
    }
  }
  
  @objc static public var forcedSubtitlesOnly: AVAssetTrackWrapper {
    get {
      AVAssetTrackWrapper(AVAssetTrack.AssociationType.forcedSubtitlesOnly)
    }
  }
  
  @objc static public var metadataReferent: AVAssetTrackWrapper {
    get {
      AVAssetTrackWrapper(AVAssetTrack.AssociationType.metadataReferent)
    }
  }
  
  @objc static public var selectionFollower: AVAssetTrackWrapper {
    get {
      AVAssetTrackWrapper(AVAssetTrack.AssociationType.selectionFollower)
    }
  }
  
  @objc static public var timecode: AVAssetTrackWrapper {
    get {
      AVAssetTrackWrapper(AVAssetTrack.AssociationType.timecode)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVAssetTrack.AssociationType) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVAssetTrack.AssociationType(rawValue: rawValue)
  }
}

@objc public class AVVideoApertureModeWrapper: NSObject {
  var wrappedInstance: AVVideoApertureMode
  
  @objc static public var cleanAperture: AVVideoApertureModeWrapper {
    get {
      AVVideoApertureModeWrapper(AVVideoApertureMode.cleanAperture)
    }
  }
  
  @objc static public var encodedPixels: AVVideoApertureModeWrapper {
    get {
      AVVideoApertureModeWrapper(AVVideoApertureMode.encodedPixels)
    }
  }
  
  @objc static public var productionAperture: AVVideoApertureModeWrapper {
    get {
      AVVideoApertureModeWrapper(AVVideoApertureMode.productionAperture)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVVideoApertureMode) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVVideoApertureMode(rawValue: rawValue)
  }
}

@objc public class AVVideoCodecTypeWrapper: NSObject {
  var wrappedInstance: AVVideoCodecType
  
  @objc static public var proRes422: AVVideoCodecTypeWrapper {
    get {
      AVVideoCodecTypeWrapper(AVVideoCodecType.proRes422)
    }
  }
  
  @objc static public var proRes422HQ: AVVideoCodecTypeWrapper {
    get {
      AVVideoCodecTypeWrapper(AVVideoCodecType.proRes422HQ)
    }
  }
  
  @objc static public var proRes422LT: AVVideoCodecTypeWrapper {
    get {
      AVVideoCodecTypeWrapper(AVVideoCodecType.proRes422LT)
    }
  }
  
  @objc static public var proRes422Proxy: AVVideoCodecTypeWrapper {
    get {
      AVVideoCodecTypeWrapper(AVVideoCodecType.proRes422Proxy)
    }
  }
  
  @objc static public var proRes4444: AVVideoCodecTypeWrapper {
    get {
      AVVideoCodecTypeWrapper(AVVideoCodecType.proRes4444)
    }
  }
  
  @objc static public var h264: AVVideoCodecTypeWrapper {
    get {
      AVVideoCodecTypeWrapper(AVVideoCodecType.h264)
    }
  }
  
  @objc static public var hevc: AVVideoCodecTypeWrapper {
    get {
      AVVideoCodecTypeWrapper(AVVideoCodecType.hevc)
    }
  }
  
  @objc static public var hevcWithAlpha: AVVideoCodecTypeWrapper {
    get {
      AVVideoCodecTypeWrapper(AVVideoCodecType.hevcWithAlpha)
    }
  }
  
  @objc static public var jpeg: AVVideoCodecTypeWrapper {
    get {
      AVVideoCodecTypeWrapper(AVVideoCodecType.jpeg)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVVideoCodecType) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVVideoCodecType(rawValue: rawValue)
  }
}

@objc public class PerFrameHDRDisplayMetadataPolicyWrapper: NSObject {
  var wrappedInstance: AVVideoComposition.PerFrameHDRDisplayMetadataPolicy
  
  @objc static public var generate: AVVideoCompositionWrapper {
    get {
      AVVideoCompositionWrapper(AVVideoComposition.PerFrameHDRDisplayMetadataPolicy.generate)
    }
  }
  
  @objc static public var propagate: AVVideoCompositionWrapper {
    get {
      AVVideoCompositionWrapper(AVVideoComposition.PerFrameHDRDisplayMetadataPolicy.propagate)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVVideoComposition.PerFrameHDRDisplayMetadataPolicy) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVVideoComposition.PerFrameHDRDisplayMetadataPolicy(rawValue: rawValue)
  }
}

@objc public class AVVideoRangeWrapper: NSObject {
  var wrappedInstance: AVVideoRange
  
  @objc static public var hlg: AVVideoRangeWrapper {
    get {
      AVVideoRangeWrapper(AVVideoRange.hlg)
    }
  }
  
  @objc static public var pq: AVVideoRangeWrapper {
    get {
      AVVideoRangeWrapper(AVVideoRange.pq)
    }
  }
  
  @objc static public var sdr: AVVideoRangeWrapper {
    get {
      AVVideoRangeWrapper(AVVideoRange.sdr)
    }
  }
  
  @objc public var hashValue: Int {
    get {
      wrappedInstance.hashValue
    }
  }
  
  init(_ wrappedInstance: AVVideoRange) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(rawValue: String) {
    wrappedInstance = AVVideoRange(rawValue: rawValue)
  }
}

@objc public class AVAggregateAssetDownloadTaskWrapper: NSObject {
  var wrappedInstance: AVAggregateAssetDownloadTask
  
  @objc public var urlAsset: AVURLAssetWrapper {
    get {
      AVURLAssetWrapper(wrappedInstance.urlAsset)
    }
  }
  
  init(_ wrappedInstance: AVAggregateAssetDownloadTask) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAssetWrapper: NSObject {
  var wrappedInstance: AVAsset
  
  @objc public var allMediaSelections: AVMediaSelectionWrapper {
    get {
      AVMediaSelectionWrapper(wrappedInstance.allMediaSelections)
    }
  }
  
  @objc public var availableMediaCharacteristicsWithMediaSelectionOptions: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(wrappedInstance.availableMediaCharacteristicsWithMediaSelectionOptions)
    }
  }
  
  @objc public var availableMetadataFormats: AVMetadataFormatWrapper {
    get {
      AVMetadataFormatWrapper(wrappedInstance.availableMetadataFormats)
    }
  }
  
  @objc public var canContainFragments: Bool {
    get {
      wrappedInstance.canContainFragments
    }
  }
  
  @objc public var commonMetadata: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.commonMetadata)
    }
  }
  
  @objc public var isCompatibleWithAirPlayVideo: Bool {
    get {
      wrappedInstance.isCompatibleWithAirPlayVideo
    }
  }
  
  @objc public var isComposable: Bool {
    get {
      wrappedInstance.isComposable
    }
  }
  
  @objc public var containsFragments: Bool {
    get {
      wrappedInstance.containsFragments
    }
  }
  
  @objc public var creationDate: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.creationDate)
    }
  }
  
  @objc public var isExportable: Bool {
    get {
      wrappedInstance.isExportable
    }
  }
  
  @objc public var hasProtectedContent: Bool {
    get {
      wrappedInstance.hasProtectedContent
    }
  }
  
  @objc public var lyrics: String {
    get {
      wrappedInstance.lyrics
    }
  }
  
  @objc public var metadata: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.metadata)
    }
  }
  
  @objc public var isPlayable: Bool {
    get {
      wrappedInstance.isPlayable
    }
  }
  
  @objc public var preferredMediaSelection: AVMediaSelectionWrapper {
    get {
      AVMediaSelectionWrapper(wrappedInstance.preferredMediaSelection)
    }
  }
  
  @objc public var providesPreciseDurationAndTiming: Bool {
    get {
      wrappedInstance.providesPreciseDurationAndTiming
    }
  }
  
  @objc public var isReadable: Bool {
    get {
      wrappedInstance.isReadable
    }
  }
  
  @objc public var referenceRestrictions: AVAssetReferenceRestrictionsWrapper {
    get {
      AVAssetReferenceRestrictionsWrapper(wrappedInstance.referenceRestrictions)
    }
  }
  
  @objc public var trackGroups: AVAssetTrackGroupWrapper {
    get {
      AVAssetTrackGroupWrapper(wrappedInstance.trackGroups)
    }
  }
  
  @objc public var tracks: AVAssetTrackWrapper {
    get {
      AVAssetTrackWrapper(wrappedInstance.tracks)
    }
  }
  
  init(_ wrappedInstance: AVAsset) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func cancelLoading() -> Void {
    return wrappedInstance.cancelLoading()
  }
  
  @objc public func loadMediaSelectionGroup(for mediaCharacteristic: AVMediaCharacteristicWrapper) -> AVMediaSelectionGroupWrapper {
    let result = wrappedInstance.loadMediaSelectionGroup(for: mediaCharacteristic.wrappedInstance)
    return AVMediaSelectionGroupWrapper(result)
  }
  
  @objc public func loadMediaSelectionGroup(for mediaCharacteristic: AVMediaCharacteristicWrapper) -> AVMediaSelectionGroupWrapper {
    let result = wrappedInstance.loadMediaSelectionGroup(for: mediaCharacteristic.wrappedInstance)
    return AVMediaSelectionGroupWrapper(result)
  }
  
  @objc public func loadMetadata(for format: AVMetadataFormatWrapper, completionHandler: AVMetadataItemWrapper) -> Void {
    return wrappedInstance.loadMetadata(for: format.wrappedInstance, completionHandler: completionHandler.wrappedInstance)
  }
  
  @objc public func loadMetadata(for format: AVMetadataFormatWrapper, completionHandler: AVMetadataItemWrapper) -> Void {
    return wrappedInstance.loadMetadata(for: format.wrappedInstance, completionHandler: completionHandler.wrappedInstance)
  }
  
  @objc public func loadTracks(withMediaType mediaType: AVMediaTypeWrapper, completionHandler: AVAssetTrackWrapper) -> Void {
    return wrappedInstance.loadTracks(withMediaType: mediaType.wrappedInstance, completionHandler: completionHandler.wrappedInstance)
  }
  
  @objc public func loadTracks(withMediaType mediaType: AVMediaTypeWrapper, completionHandler: AVAssetTrackWrapper) -> Void {
    return wrappedInstance.loadTracks(withMediaType: mediaType.wrappedInstance, completionHandler: completionHandler.wrappedInstance)
  }
  
  @objc public func mediaSelectionGroup(forMediaCharacteristic mediaCharacteristic: AVMediaCharacteristicWrapper) -> AVMediaSelectionGroupWrapper {
    let result = wrappedInstance.mediaSelectionGroup(forMediaCharacteristic: mediaCharacteristic.wrappedInstance)
    return AVMediaSelectionGroupWrapper(result)
  }
  
  @objc public func status(of property: AVAsyncPropertyWrapper) -> AVAsyncPropertyWrapper {
    let result = wrappedInstance.status(of: property.wrappedInstance)
    return AVAsyncPropertyWrapper(result)
  }
}

@objc public class AVAssetCacheWrapper: NSObject {
  var wrappedInstance: AVAssetCache
  
  @objc public var isPlayableOffline: Bool {
    get {
      wrappedInstance.isPlayableOffline
    }
  }
  
  init(_ wrappedInstance: AVAssetCache) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAssetDownloadConfigurationWrapper: NSObject {
  var wrappedInstance: AVAssetDownloadConfiguration
  
  @objc public var auxiliaryContentConfigurations: AVAssetDownloadContentConfigurationWrapper {
    get {
      AVAssetDownloadContentConfigurationWrapper(wrappedInstance.auxiliaryContentConfigurations)
    }
    set {
      wrappedInstance.auxiliaryContentConfigurations = newValue.wrappedInstance
    }
  }
  
  @objc public var optimizesAuxiliaryContentConfigurations: Bool {
    get {
      wrappedInstance.optimizesAuxiliaryContentConfigurations
    }
    set {
      wrappedInstance.optimizesAuxiliaryContentConfigurations = newValue
    }
  }
  
  @objc public var primaryContentConfiguration: AVAssetDownloadContentConfigurationWrapper {
    get {
      AVAssetDownloadContentConfigurationWrapper(wrappedInstance.primaryContentConfiguration)
    }
  }
  
  init(_ wrappedInstance: AVAssetDownloadConfiguration) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(asset: AVURLAssetWrapper, title: String) {
    wrappedInstance = AVAssetDownloadConfiguration(asset: asset.wrappedInstance, title: title)
  }
}

@objc public class AVAssetDownloadContentConfigurationWrapper: NSObject {
  var wrappedInstance: AVAssetDownloadContentConfiguration
  
  @objc public var mediaSelections: AVMediaSelectionWrapper {
    get {
      AVMediaSelectionWrapper(wrappedInstance.mediaSelections)
    }
    set {
      wrappedInstance.mediaSelections = newValue.wrappedInstance
    }
  }
  
  @objc public var variantQualifiers: AVAssetVariantQualifierWrapper {
    get {
      AVAssetVariantQualifierWrapper(wrappedInstance.variantQualifiers)
    }
    set {
      wrappedInstance.variantQualifiers = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVAssetDownloadContentConfiguration) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAssetDownloadStorageManagementPolicyWrapper: NSObject {
  var wrappedInstance: AVAssetDownloadStorageManagementPolicy
  
  @objc public var priority: AVAssetDownloadedAssetEvictionPriorityWrapper {
    get {
      AVAssetDownloadedAssetEvictionPriorityWrapper(wrappedInstance.priority)
    }
  }
  
  init(_ wrappedInstance: AVAssetDownloadStorageManagementPolicy) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAssetDownloadStorageManagerWrapper: NSObject {
  var wrappedInstance: AVAssetDownloadStorageManager
  
  init(_ wrappedInstance: AVAssetDownloadStorageManager) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc static public func shared() -> AVAssetDownloadStorageManagerWrapper {
    let result = AVAssetDownloadStorageManager.shared()
    return AVAssetDownloadStorageManagerWrapper(result)
  }
}

@objc public class AVAssetDownloadTaskWrapper: NSObject {
  var wrappedInstance: AVAssetDownloadTask
  
  @objc public var urlAsset: AVURLAssetWrapper {
    get {
      AVURLAssetWrapper(wrappedInstance.urlAsset)
    }
  }
  
  @objc public var options: String {
    get {
      wrappedInstance.options
    }
  }
  
  init(_ wrappedInstance: AVAssetDownloadTask) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAssetDownloadURLSessionWrapper: NSObject {
  var wrappedInstance: AVAssetDownloadURLSession
  
  init(_ wrappedInstance: AVAssetDownloadURLSession) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func makeAssetDownloadTask(downloadConfiguration: AVAssetDownloadConfigurationWrapper) -> AVAssetDownloadTaskWrapper {
    let result = wrappedInstance.makeAssetDownloadTask(downloadConfiguration: downloadConfiguration.wrappedInstance)
    return AVAssetDownloadTaskWrapper(result)
  }
}

@objc public class AVAssetExportSessionWrapper: NSObject {
  var wrappedInstance: AVAssetExportSession
  
  @objc public var allowsParallelizedExport: Bool {
    get {
      wrappedInstance.allowsParallelizedExport
    }
    set {
      wrappedInstance.allowsParallelizedExport = newValue
    }
  }
  
  @objc public var asset: AVAssetWrapper {
    get {
      AVAssetWrapper(wrappedInstance.asset)
    }
  }
  
  @objc public var audioMix: AVAudioMixWrapper {
    get {
      AVAudioMixWrapper(wrappedInstance.audioMix)
    }
    set {
      wrappedInstance.audioMix = newValue.wrappedInstance
    }
  }
  
  @objc public var audioTimePitchAlgorithm: AVAudioTimePitchAlgorithmWrapper {
    get {
      AVAudioTimePitchAlgorithmWrapper(wrappedInstance.audioTimePitchAlgorithm)
    }
    set {
      wrappedInstance.audioTimePitchAlgorithm = newValue.wrappedInstance
    }
  }
  
  @objc public var audioTrackGroupHandling: AVAssetTrackGroupOutputHandlingWrapper {
    get {
      AVAssetTrackGroupOutputHandlingWrapper(wrappedInstance.audioTrackGroupHandling)
    }
    set {
      wrappedInstance.audioTrackGroupHandling = newValue.wrappedInstance
    }
  }
  
  @objc public var canPerformMultiplePassesOverSourceMediaData: Bool {
    get {
      wrappedInstance.canPerformMultiplePassesOverSourceMediaData
    }
    set {
      wrappedInstance.canPerformMultiplePassesOverSourceMediaData = newValue
    }
  }
  
  @objc public var metadata: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.metadata)
    }
    set {
      wrappedInstance.metadata = newValue.wrappedInstance
    }
  }
  
  @objc public var metadataItemFilter: AVMetadataItemFilterWrapper {
    get {
      AVMetadataItemFilterWrapper(wrappedInstance.metadataItemFilter)
    }
    set {
      wrappedInstance.metadataItemFilter = newValue.wrappedInstance
    }
  }
  
  @objc public var outputFileType: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(wrappedInstance.outputFileType)
    }
    set {
      wrappedInstance.outputFileType = newValue.wrappedInstance
    }
  }
  
  @objc public var presetName: String {
    get {
      wrappedInstance.presetName
    }
  }
  
  @objc public var shouldOptimizeForNetworkUse: Bool {
    get {
      wrappedInstance.shouldOptimizeForNetworkUse
    }
    set {
      wrappedInstance.shouldOptimizeForNetworkUse = newValue
    }
  }
  
  @objc public var status: AVAssetExportSessionWrapper {
    get {
      AVAssetExportSessionWrapper(wrappedInstance.status)
    }
  }
  
  @objc public var supportedFileTypes: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(wrappedInstance.supportedFileTypes)
    }
  }
  
  @objc public var videoComposition: AVVideoCompositionWrapper {
    get {
      AVVideoCompositionWrapper(wrappedInstance.videoComposition)
    }
    set {
      wrappedInstance.videoComposition = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVAssetExportSession) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(asset: AVAssetWrapper, presetName: String) {
    wrappedInstance = AVAssetExportSession(asset: asset.wrappedInstance, presetName: presetName)
  }
  
  @objc static public func compatibility(ofExportPreset presetName: String, with asset: AVAssetWrapper, outputFileType: AVFileTypeWrapper) -> Bool {
    return AVAssetExportSession.compatibility(ofExportPreset: presetName, with: asset.wrappedInstance, outputFileType: outputFileType.wrappedInstance)
  }
  
  @objc static public func compatibility(ofExportPreset presetName: String, with asset: AVAssetWrapper, outputFileType: AVFileTypeWrapper) -> Bool {
    return AVAssetExportSession.compatibility(ofExportPreset: presetName, with: asset.wrappedInstance, outputFileType: outputFileType.wrappedInstance)
  }
  
  @objc public func cancelExport() -> Void {
    return wrappedInstance.cancelExport()
  }
  
  @objc public func determineCompatibleFileTypes(completionHandler handler: AVFileTypeWrapper) -> Void {
    return wrappedInstance.determineCompatibleFileTypes(completionHandler: handler.wrappedInstance)
  }
  
  @objc public func determineCompatibleFileTypes(completionHandler handler: AVFileTypeWrapper) -> Void {
    return wrappedInstance.determineCompatibleFileTypes(completionHandler: handler.wrappedInstance)
  }
  
  @objc public func exportAsynchronously(completionHandler handler: Void) -> Void {
    return wrappedInstance.exportAsynchronously(completionHandler: handler)
  }
  
  @objc public func exportAsynchronously(completionHandler handler: Void) -> Void {
    return wrappedInstance.exportAsynchronously(completionHandler: handler)
  }
}

@objc public class AVAssetImageGeneratorWrapper: NSObject {
  var wrappedInstance: AVAssetImageGenerator
  
  @objc public var apertureMode: AVAssetImageGeneratorWrapper {
    get {
      AVAssetImageGeneratorWrapper(wrappedInstance.apertureMode)
    }
    set {
      wrappedInstance.apertureMode = newValue.wrappedInstance
    }
  }
  
  @objc public var appliesPreferredTrackTransform: Bool {
    get {
      wrappedInstance.appliesPreferredTrackTransform
    }
    set {
      wrappedInstance.appliesPreferredTrackTransform = newValue
    }
  }
  
  @objc public var asset: AVAssetWrapper {
    get {
      AVAssetWrapper(wrappedInstance.asset)
    }
  }
  
  @objc public var videoComposition: AVVideoCompositionWrapper {
    get {
      AVVideoCompositionWrapper(wrappedInstance.videoComposition)
    }
    set {
      wrappedInstance.videoComposition = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVAssetImageGenerator) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(asset: AVAssetWrapper) {
    wrappedInstance = AVAssetImageGenerator(asset: asset.wrappedInstance)
  }
  
  @objc public func cancelAllCGImageGeneration() -> Void {
    return wrappedInstance.cancelAllCGImageGeneration()
  }
}

@objc public class AVAssetPlaybackAssistantWrapper: NSObject {
  var wrappedInstance: AVAssetPlaybackAssistant
  
  @objc public var playbackConfigurationOptions: AVAssetPlaybackConfigurationOptionWrapper {
    get {
      AVAssetPlaybackConfigurationOptionWrapper(wrappedInstance.playbackConfigurationOptions)
    }
  }
  
  @objc public var playbackConfigurationOptions: AVAssetPlaybackConfigurationOptionWrapper {
    get {
      AVAssetPlaybackConfigurationOptionWrapper(wrappedInstance.playbackConfigurationOptions)
    }
  }
  
  init(_ wrappedInstance: AVAssetPlaybackAssistant) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(asset: AVAssetWrapper) {
    wrappedInstance = AVAssetPlaybackAssistant(asset: asset.wrappedInstance)
  }
}

@objc public class AVAssetReaderWrapper: NSObject {
  var wrappedInstance: AVAssetReader
  
  @objc public var asset: AVAssetWrapper {
    get {
      AVAssetWrapper(wrappedInstance.asset)
    }
  }
  
  @objc public var outputs: AVAssetReaderOutputWrapper {
    get {
      AVAssetReaderOutputWrapper(wrappedInstance.outputs)
    }
  }
  
  @objc public var status: AVAssetReaderWrapper {
    get {
      AVAssetReaderWrapper(wrappedInstance.status)
    }
  }
  
  init(_ wrappedInstance: AVAssetReader) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(asset: AVAssetWrapper) {
    wrappedInstance = AVAssetReader(asset: asset.wrappedInstance)
  }
  
  @objc public func add(output: AVAssetReaderOutputWrapper) -> Void {
    return wrappedInstance.add(output: output.wrappedInstance)
  }
  
  @objc public func canAdd(output: AVAssetReaderOutputWrapper) -> Bool {
    return wrappedInstance.canAdd(output: output.wrappedInstance)
  }
  
  @objc public func cancelReading() -> Void {
    return wrappedInstance.cancelReading()
  }
  
  @objc public func startReading() -> Bool {
    return wrappedInstance.startReading()
  }
}

@objc public class AVAssetReaderAudioMixOutputWrapper: NSObject {
  var wrappedInstance: AVAssetReaderAudioMixOutput
  
  @objc public var audioMix: AVAudioMixWrapper {
    get {
      AVAudioMixWrapper(wrappedInstance.audioMix)
    }
    set {
      wrappedInstance.audioMix = newValue.wrappedInstance
    }
  }
  
  @objc public var audioSettings: String {
    get {
      wrappedInstance.audioSettings
    }
  }
  
  @objc public var audioTimePitchAlgorithm: AVAudioTimePitchAlgorithmWrapper {
    get {
      AVAudioTimePitchAlgorithmWrapper(wrappedInstance.audioTimePitchAlgorithm)
    }
    set {
      wrappedInstance.audioTimePitchAlgorithm = newValue.wrappedInstance
    }
  }
  
  @objc public var audioTracks: AVAssetTrackWrapper {
    get {
      AVAssetTrackWrapper(wrappedInstance.audioTracks)
    }
  }
  
  init(_ wrappedInstance: AVAssetReaderAudioMixOutput) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(audioTracks: AVAssetTrackWrapper, audioSettings: String) {
    wrappedInstance = AVAssetReaderAudioMixOutput(audioTracks: audioTracks.wrappedInstance, audioSettings: audioSettings)
  }
}

@objc public class AVAssetReaderOutputWrapper: NSObject {
  var wrappedInstance: AVAssetReaderOutput
  
  @objc public var alwaysCopiesSampleData: Bool {
    get {
      wrappedInstance.alwaysCopiesSampleData
    }
    set {
      wrappedInstance.alwaysCopiesSampleData = newValue
    }
  }
  
  @objc public var mediaType: AVMediaTypeWrapper {
    get {
      AVMediaTypeWrapper(wrappedInstance.mediaType)
    }
  }
  
  @objc public var supportsRandomAccess: Bool {
    get {
      wrappedInstance.supportsRandomAccess
    }
    set {
      wrappedInstance.supportsRandomAccess = newValue
    }
  }
  
  init(_ wrappedInstance: AVAssetReaderOutput) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func markConfigurationAsFinal() -> Void {
    return wrappedInstance.markConfigurationAsFinal()
  }
}

@objc public class AVAssetReaderOutputCaptionAdaptorWrapper: NSObject {
  var wrappedInstance: AVAssetReaderOutputCaptionAdaptor
  
  @objc public var assetReaderTrackOutput: AVAssetReaderTrackOutputWrapper {
    get {
      AVAssetReaderTrackOutputWrapper(wrappedInstance.assetReaderTrackOutput)
    }
  }
  
  init(_ wrappedInstance: AVAssetReaderOutputCaptionAdaptor) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(assetReaderTrackOutput trackOutput: AVAssetReaderTrackOutputWrapper) {
    wrappedInstance = AVAssetReaderOutputCaptionAdaptor(assetReaderTrackOutput: trackOutput.wrappedInstance)
  }
  
  @objc public func nextCaptionGroup() -> AVCaptionGroupWrapper {
    let result = wrappedInstance.nextCaptionGroup()
    return AVCaptionGroupWrapper(result)
  }
}

@objc public class AVAssetReaderOutputMetadataAdaptorWrapper: NSObject {
  var wrappedInstance: AVAssetReaderOutputMetadataAdaptor
  
  @objc public var assetReaderTrackOutput: AVAssetReaderTrackOutputWrapper {
    get {
      AVAssetReaderTrackOutputWrapper(wrappedInstance.assetReaderTrackOutput)
    }
  }
  
  init(_ wrappedInstance: AVAssetReaderOutputMetadataAdaptor) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(assetReaderTrackOutput trackOutput: AVAssetReaderTrackOutputWrapper) {
    wrappedInstance = AVAssetReaderOutputMetadataAdaptor(assetReaderTrackOutput: trackOutput.wrappedInstance)
  }
  
  @objc public func nextTimedMetadataGroup() -> AVTimedMetadataGroupWrapper {
    let result = wrappedInstance.nextTimedMetadataGroup()
    return AVTimedMetadataGroupWrapper(result)
  }
}

@objc public class AVAssetReaderSampleReferenceOutputWrapper: NSObject {
  var wrappedInstance: AVAssetReaderSampleReferenceOutput
  
  @objc public var track: AVAssetTrackWrapper {
    get {
      AVAssetTrackWrapper(wrappedInstance.track)
    }
  }
  
  init(_ wrappedInstance: AVAssetReaderSampleReferenceOutput) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(track: AVAssetTrackWrapper) {
    wrappedInstance = AVAssetReaderSampleReferenceOutput(track: track.wrappedInstance)
  }
}

@objc public class AVAssetReaderTrackOutputWrapper: NSObject {
  var wrappedInstance: AVAssetReaderTrackOutput
  
  @objc public var audioTimePitchAlgorithm: AVAudioTimePitchAlgorithmWrapper {
    get {
      AVAudioTimePitchAlgorithmWrapper(wrappedInstance.audioTimePitchAlgorithm)
    }
    set {
      wrappedInstance.audioTimePitchAlgorithm = newValue.wrappedInstance
    }
  }
  
  @objc public var outputSettings: String {
    get {
      wrappedInstance.outputSettings
    }
  }
  
  @objc public var track: AVAssetTrackWrapper {
    get {
      AVAssetTrackWrapper(wrappedInstance.track)
    }
  }
  
  init(_ wrappedInstance: AVAssetReaderTrackOutput) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(track: AVAssetTrackWrapper, outputSettings: String) {
    wrappedInstance = AVAssetReaderTrackOutput(track: track.wrappedInstance, outputSettings: outputSettings)
  }
}

@objc public class AVAssetReaderVideoCompositionOutputWrapper: NSObject {
  var wrappedInstance: AVAssetReaderVideoCompositionOutput
  
  @objc public var videoComposition: AVVideoCompositionWrapper {
    get {
      AVVideoCompositionWrapper(wrappedInstance.videoComposition)
    }
    set {
      wrappedInstance.videoComposition = newValue.wrappedInstance
    }
  }
  
  @objc public var videoSettings: String {
    get {
      wrappedInstance.videoSettings
    }
  }
  
  @objc public var videoTracks: AVAssetTrackWrapper {
    get {
      AVAssetTrackWrapper(wrappedInstance.videoTracks)
    }
  }
  
  init(_ wrappedInstance: AVAssetReaderVideoCompositionOutput) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(videoTracks: AVAssetTrackWrapper, videoSettings: String) {
    wrappedInstance = AVAssetReaderVideoCompositionOutput(videoTracks: videoTracks.wrappedInstance, videoSettings: videoSettings)
  }
}

@objc public class AVAssetResourceLoaderWrapper: NSObject {
  var wrappedInstance: AVAssetResourceLoader
  
  @objc public var preloadsEligibleContentKeys: Bool {
    get {
      wrappedInstance.preloadsEligibleContentKeys
    }
    set {
      wrappedInstance.preloadsEligibleContentKeys = newValue
    }
  }
  
  init(_ wrappedInstance: AVAssetResourceLoader) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAssetResourceLoadingContentInformationRequestWrapper: NSObject {
  var wrappedInstance: AVAssetResourceLoadingContentInformationRequest
  
  @objc public var allowedContentTypes: String {
    get {
      wrappedInstance.allowedContentTypes
    }
  }
  
  @objc public var isByteRangeAccessSupported: Bool {
    get {
      wrappedInstance.isByteRangeAccessSupported
    }
    set {
      wrappedInstance.isByteRangeAccessSupported = newValue
    }
  }
  
  @objc public var contentType: String {
    get {
      wrappedInstance.contentType
    }
    set {
      wrappedInstance.contentType = newValue
    }
  }
  
  @objc public var isEntireLengthAvailableOnDemand: Bool {
    get {
      wrappedInstance.isEntireLengthAvailableOnDemand
    }
    set {
      wrappedInstance.isEntireLengthAvailableOnDemand = newValue
    }
  }
  
  init(_ wrappedInstance: AVAssetResourceLoadingContentInformationRequest) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAssetResourceLoadingDataRequestWrapper: NSObject {
  var wrappedInstance: AVAssetResourceLoadingDataRequest
  
  @objc public var requestedLength: Int {
    get {
      wrappedInstance.requestedLength
    }
  }
  
  @objc public var requestsAllDataToEndOfResource: Bool {
    get {
      wrappedInstance.requestsAllDataToEndOfResource
    }
  }
  
  init(_ wrappedInstance: AVAssetResourceLoadingDataRequest) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAssetResourceLoadingRequestWrapper: NSObject {
  var wrappedInstance: AVAssetResourceLoadingRequest
  
  @objc public var isCancelled: Bool {
    get {
      wrappedInstance.isCancelled
    }
  }
  
  @objc public var contentInformationRequest: AVAssetResourceLoadingContentInformationRequestWrapper {
    get {
      AVAssetResourceLoadingContentInformationRequestWrapper(wrappedInstance.contentInformationRequest)
    }
  }
  
  @objc public var dataRequest: AVAssetResourceLoadingDataRequestWrapper {
    get {
      AVAssetResourceLoadingDataRequestWrapper(wrappedInstance.dataRequest)
    }
  }
  
  @objc public var isFinished: Bool {
    get {
      wrappedInstance.isFinished
    }
  }
  
  @objc public var requestor: AVAssetResourceLoadingRequestorWrapper {
    get {
      AVAssetResourceLoadingRequestorWrapper(wrappedInstance.requestor)
    }
  }
  
  init(_ wrappedInstance: AVAssetResourceLoadingRequest) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func finishLoading() -> Void {
    return wrappedInstance.finishLoading()
  }
}

@objc public class AVAssetResourceLoadingRequestorWrapper: NSObject {
  var wrappedInstance: AVAssetResourceLoadingRequestor
  
  @objc public var providesExpiredSessionReports: Bool {
    get {
      wrappedInstance.providesExpiredSessionReports
    }
  }
  
  init(_ wrappedInstance: AVAssetResourceLoadingRequestor) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAssetResourceRenewalRequestWrapper: NSObject {
  var wrappedInstance: AVAssetResourceRenewalRequest
  
  init(_ wrappedInstance: AVAssetResourceRenewalRequest) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAssetSegmentReportWrapper: NSObject {
  var wrappedInstance: AVAssetSegmentReport
  
  @objc public var trackReports: AVAssetSegmentTrackReportWrapper {
    get {
      AVAssetSegmentTrackReportWrapper(wrappedInstance.trackReports)
    }
  }
  
  init(_ wrappedInstance: AVAssetSegmentReport) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAssetSegmentReportSampleInformationWrapper: NSObject {
  var wrappedInstance: AVAssetSegmentReportSampleInformation
  
  @objc public var isSyncSample: Bool {
    get {
      wrappedInstance.isSyncSample
    }
  }
  
  @objc public var length: Int {
    get {
      wrappedInstance.length
    }
  }
  
  @objc public var offset: Int {
    get {
      wrappedInstance.offset
    }
  }
  
  init(_ wrappedInstance: AVAssetSegmentReportSampleInformation) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAssetSegmentTrackReportWrapper: NSObject {
  var wrappedInstance: AVAssetSegmentTrackReport
  
  @objc public var firstVideoSampleInformation: AVAssetSegmentReportSampleInformationWrapper {
    get {
      AVAssetSegmentReportSampleInformationWrapper(wrappedInstance.firstVideoSampleInformation)
    }
  }
  
  @objc public var mediaType: AVMediaTypeWrapper {
    get {
      AVMediaTypeWrapper(wrappedInstance.mediaType)
    }
  }
  
  init(_ wrappedInstance: AVAssetSegmentTrackReport) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAssetTrackWrapper: NSObject {
  var wrappedInstance: AVAssetTrack
  
  @objc public var asset: AVAssetWrapper {
    get {
      AVAssetWrapper(wrappedInstance.asset)
    }
  }
  
  @objc public var availableMetadataFormats: AVMetadataFormatWrapper {
    get {
      AVMetadataFormatWrapper(wrappedInstance.availableMetadataFormats)
    }
  }
  
  @objc public var availableTrackAssociationTypes: AVAssetTrackWrapper {
    get {
      AVAssetTrackWrapper(wrappedInstance.availableTrackAssociationTypes)
    }
  }
  
  @objc public var canProvideSampleCursors: Bool {
    get {
      wrappedInstance.canProvideSampleCursors
    }
  }
  
  @objc public var commonMetadata: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.commonMetadata)
    }
  }
  
  @objc public var isDecodable: Bool {
    get {
      wrappedInstance.isDecodable
    }
  }
  
  @objc public var isEnabled: Bool {
    get {
      wrappedInstance.isEnabled
    }
  }
  
  @objc public var extendedLanguageTag: String {
    get {
      wrappedInstance.extendedLanguageTag
    }
  }
  
  @objc public var hasAudioSampleDependencies: Bool {
    get {
      wrappedInstance.hasAudioSampleDependencies
    }
  }
  
  @objc public var languageCode: String {
    get {
      wrappedInstance.languageCode
    }
  }
  
  @objc public var mediaType: AVMediaTypeWrapper {
    get {
      AVMediaTypeWrapper(wrappedInstance.mediaType)
    }
  }
  
  @objc public var metadata: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.metadata)
    }
  }
  
  @objc public var isPlayable: Bool {
    get {
      wrappedInstance.isPlayable
    }
  }
  
  @objc public var requiresFrameReordering: Bool {
    get {
      wrappedInstance.requiresFrameReordering
    }
  }
  
  @objc public var segments: AVAssetTrackSegmentWrapper {
    get {
      AVAssetTrackSegmentWrapper(wrappedInstance.segments)
    }
  }
  
  @objc public var isSelfContained: Bool {
    get {
      wrappedInstance.isSelfContained
    }
  }
  
  init(_ wrappedInstance: AVAssetTrack) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func hasMediaCharacteristic(mediaCharacteristic: AVMediaCharacteristicWrapper) -> Bool {
    return wrappedInstance.hasMediaCharacteristic(mediaCharacteristic: mediaCharacteristic.wrappedInstance)
  }
  
  @objc public func loadMetadata(for format: AVMetadataFormatWrapper, completionHandler: AVMetadataItemWrapper) -> Void {
    return wrappedInstance.loadMetadata(for: format.wrappedInstance, completionHandler: completionHandler.wrappedInstance)
  }
  
  @objc public func loadMetadata(for format: AVMetadataFormatWrapper, completionHandler: AVMetadataItemWrapper) -> Void {
    return wrappedInstance.loadMetadata(for: format.wrappedInstance, completionHandler: completionHandler.wrappedInstance)
  }
  
  @objc public func makeSampleCursorAtFirstSampleInDecodeOrder() -> AVSampleCursorWrapper {
    let result = wrappedInstance.makeSampleCursorAtFirstSampleInDecodeOrder()
    return AVSampleCursorWrapper(result)
  }
  
  @objc public func makeSampleCursorAtLastSampleInDecodeOrder() -> AVSampleCursorWrapper {
    let result = wrappedInstance.makeSampleCursorAtLastSampleInDecodeOrder()
    return AVSampleCursorWrapper(result)
  }
  
  @objc public func status(of property: AVAsyncPropertyWrapper) -> AVAsyncPropertyWrapper {
    let result = wrappedInstance.status(of: property.wrappedInstance)
    return AVAsyncPropertyWrapper(result)
  }
}

@objc public class AVAssetTrackGroupWrapper: NSObject {
  var wrappedInstance: AVAssetTrackGroup
  
  init(_ wrappedInstance: AVAssetTrackGroup) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAssetTrackSegmentWrapper: NSObject {
  var wrappedInstance: AVAssetTrackSegment
  
  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }
  
  init(_ wrappedInstance: AVAssetTrackSegment) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAssetVariantWrapper: NSObject {
  var wrappedInstance: AVAssetVariant
  
  @objc public var audioAttributes: AVAssetVariantWrapper {
    get {
      AVAssetVariantWrapper(wrappedInstance.audioAttributes)
    }
  }
  
  @objc public var videoAttributes: AVAssetVariantWrapper {
    get {
      AVAssetVariantWrapper(wrappedInstance.videoAttributes)
    }
  }
  
  @objc public var peakBitRate: Double {
    get {
      wrappedInstance.peakBitRate
    }
  }
  
  @objc public var averageBitRate: Double {
    get {
      wrappedInstance.averageBitRate
    }
  }
  
  init(_ wrappedInstance: AVAssetVariant) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AudioAttributesWrapper: NSObject {
  var wrappedInstance: AVAssetVariant.AudioAttributes
  
  init(_ wrappedInstance: AVAssetVariant.AudioAttributes) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func renditionSpecificAttributes(for mediaSelectionOption: AVMediaSelectionOptionWrapper) -> AVAssetVariantWrapper {
    let result = wrappedInstance.renditionSpecificAttributes(for: mediaSelectionOption.wrappedInstance)
    return AVAssetVariantWrapper(result)
  }
}

@objc public class RenditionSpecificAttributesWrapper: NSObject {
  var wrappedInstance: AVAssetVariant.AudioAttributes.RenditionSpecificAttributes
  
  @objc public var isBinaural: Bool {
    get {
      wrappedInstance.isBinaural
    }
  }
  
  @objc public var isDownmix: Bool {
    get {
      wrappedInstance.isDownmix
    }
  }
  
  @objc public var isImmersive: Bool {
    get {
      wrappedInstance.isImmersive
    }
  }
  
  @objc public var channelCount: Int {
    get {
      wrappedInstance.channelCount
    }
  }
  
  init(_ wrappedInstance: AVAssetVariant.AudioAttributes.RenditionSpecificAttributes) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAssetVariantQualifierWrapper: NSObject {
  var wrappedInstance: AVAssetVariantQualifier
  
  init(_ wrappedInstance: AVAssetVariantQualifier) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(variant: AVAssetVariantWrapper) {
    wrappedInstance = AVAssetVariantQualifier(variant: variant.wrappedInstance)
  }
}

@objc public class VideoAttributesWrapper: NSObject {
  var wrappedInstance: AVAssetVariant.VideoAttributes
  
  @objc public var videoLayoutAttributes: AVAssetVariantWrapper {
    get {
      AVAssetVariantWrapper(wrappedInstance.videoLayoutAttributes)
    }
  }
  
  @objc public var videoRange: AVVideoRangeWrapper {
    get {
      AVVideoRangeWrapper(wrappedInstance.videoRange)
    }
  }
  
  @objc public var nominalFrameRate: Double {
    get {
      wrappedInstance.nominalFrameRate
    }
  }
  
  init(_ wrappedInstance: AVAssetVariant.VideoAttributes) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class LayoutAttributesWrapper: NSObject {
  var wrappedInstance: AVAssetVariant.VideoAttributes.LayoutAttributes
  
  init(_ wrappedInstance: AVAssetVariant.VideoAttributes.LayoutAttributes) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAssetWriterWrapper: NSObject {
  var wrappedInstance: AVAssetWriter
  
  @objc public var availableMediaTypes: AVMediaTypeWrapper {
    get {
      AVMediaTypeWrapper(wrappedInstance.availableMediaTypes)
    }
  }
  
  @objc public var initialMovieFragmentSequenceNumber: Int {
    get {
      wrappedInstance.initialMovieFragmentSequenceNumber
    }
    set {
      wrappedInstance.initialMovieFragmentSequenceNumber = newValue
    }
  }
  
  @objc public var inputGroups: AVAssetWriterInputGroupWrapper {
    get {
      AVAssetWriterInputGroupWrapper(wrappedInstance.inputGroups)
    }
  }
  
  @objc public var inputs: AVAssetWriterInputWrapper {
    get {
      AVAssetWriterInputWrapper(wrappedInstance.inputs)
    }
  }
  
  @objc public var metadata: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.metadata)
    }
    set {
      wrappedInstance.metadata = newValue.wrappedInstance
    }
  }
  
  @objc public var outputFileType: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(wrappedInstance.outputFileType)
    }
  }
  
  @objc public var outputFileTypeProfile: AVFileTypeProfileWrapper {
    get {
      AVFileTypeProfileWrapper(wrappedInstance.outputFileTypeProfile)
    }
    set {
      wrappedInstance.outputFileTypeProfile = newValue.wrappedInstance
    }
  }
  
  @objc public var producesCombinableFragments: Bool {
    get {
      wrappedInstance.producesCombinableFragments
    }
    set {
      wrappedInstance.producesCombinableFragments = newValue
    }
  }
  
  @objc public var shouldOptimizeForNetworkUse: Bool {
    get {
      wrappedInstance.shouldOptimizeForNetworkUse
    }
    set {
      wrappedInstance.shouldOptimizeForNetworkUse = newValue
    }
  }
  
  @objc public var status: AVAssetWriterWrapper {
    get {
      AVAssetWriterWrapper(wrappedInstance.status)
    }
  }
  
  init(_ wrappedInstance: AVAssetWriter) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func add(input: AVAssetWriterInputWrapper) -> Void {
    return wrappedInstance.add(input: input.wrappedInstance)
  }
  
  @objc public func add(inputGroup: AVAssetWriterInputGroupWrapper) -> Void {
    return wrappedInstance.add(inputGroup: inputGroup.wrappedInstance)
  }
  
  @objc public func canAdd(input: AVAssetWriterInputWrapper) -> Bool {
    return wrappedInstance.canAdd(input: input.wrappedInstance)
  }
  
  @objc public func canAdd(inputGroup: AVAssetWriterInputGroupWrapper) -> Bool {
    return wrappedInstance.canAdd(inputGroup: inputGroup.wrappedInstance)
  }
  
  @objc public func canApply(outputSettings: String, forMediaType mediaType: AVMediaTypeWrapper) -> Bool {
    return wrappedInstance.canApply(outputSettings: outputSettings, forMediaType: mediaType.wrappedInstance)
  }
  
  @objc public func cancelWriting() -> Void {
    return wrappedInstance.cancelWriting()
  }
  
  @objc public func finishWriting() -> Void {
    return wrappedInstance.finishWriting()
  }
  
  @objc public func finishWriting() -> Void {
    return wrappedInstance.finishWriting()
  }
  
  @objc public func flushSegment() -> Void {
    return wrappedInstance.flushSegment()
  }
  
  @objc public func startWriting() -> Bool {
    return wrappedInstance.startWriting()
  }
}

@objc public class AVAssetWriterInputWrapper: NSObject {
  var wrappedInstance: AVAssetWriterInput
  
  @objc public var canPerformMultiplePasses: Bool {
    get {
      wrappedInstance.canPerformMultiplePasses
    }
  }
  
  @objc public var currentPassDescription: AVAssetWriterInputPassDescriptionWrapper {
    get {
      AVAssetWriterInputPassDescriptionWrapper(wrappedInstance.currentPassDescription)
    }
  }
  
  @objc public var expectsMediaDataInRealTime: Bool {
    get {
      wrappedInstance.expectsMediaDataInRealTime
    }
    set {
      wrappedInstance.expectsMediaDataInRealTime = newValue
    }
  }
  
  @objc public var extendedLanguageTag: String {
    get {
      wrappedInstance.extendedLanguageTag
    }
    set {
      wrappedInstance.extendedLanguageTag = newValue
    }
  }
  
  @objc public var languageCode: String {
    get {
      wrappedInstance.languageCode
    }
    set {
      wrappedInstance.languageCode = newValue
    }
  }
  
  @objc public var marksOutputTrackAsEnabled: Bool {
    get {
      wrappedInstance.marksOutputTrackAsEnabled
    }
    set {
      wrappedInstance.marksOutputTrackAsEnabled = newValue
    }
  }
  
  @objc public var mediaDataLocation: AVAssetWriterInputWrapper {
    get {
      AVAssetWriterInputWrapper(wrappedInstance.mediaDataLocation)
    }
    set {
      wrappedInstance.mediaDataLocation = newValue.wrappedInstance
    }
  }
  
  @objc public var mediaType: AVMediaTypeWrapper {
    get {
      AVMediaTypeWrapper(wrappedInstance.mediaType)
    }
  }
  
  @objc public var metadata: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.metadata)
    }
    set {
      wrappedInstance.metadata = newValue.wrappedInstance
    }
  }
  
  @objc public var outputSettings: String {
    get {
      wrappedInstance.outputSettings
    }
  }
  
  @objc public var performsMultiPassEncodingIfSupported: Bool {
    get {
      wrappedInstance.performsMultiPassEncodingIfSupported
    }
    set {
      wrappedInstance.performsMultiPassEncodingIfSupported = newValue
    }
  }
  
  @objc public var preferredMediaChunkAlignment: Int {
    get {
      wrappedInstance.preferredMediaChunkAlignment
    }
    set {
      wrappedInstance.preferredMediaChunkAlignment = newValue
    }
  }
  
  @objc public var isReadyForMoreMediaData: Bool {
    get {
      wrappedInstance.isReadyForMoreMediaData
    }
  }
  
  init(_ wrappedInstance: AVAssetWriterInput) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(mediaType: AVMediaTypeWrapper, outputSettings: String) {
    wrappedInstance = AVAssetWriterInput(mediaType: mediaType.wrappedInstance, outputSettings: outputSettings)
  }
  
  @objc public func addTrackAssociation(withTrackOf input: AVAssetWriterInputWrapper, type trackAssociationType: String) -> Void {
    return wrappedInstance.addTrackAssociation(withTrackOf: input.wrappedInstance, type: trackAssociationType)
  }
  
  @objc public func canAddTrackAssociation(withTrackOf input: AVAssetWriterInputWrapper, type trackAssociationType: String) -> Bool {
    return wrappedInstance.canAddTrackAssociation(withTrackOf: input.wrappedInstance, type: trackAssociationType)
  }
  
  @objc public func markAsFinished() -> Void {
    return wrappedInstance.markAsFinished()
  }
  
  @objc public func markCurrentPassAsFinished() -> Void {
    return wrappedInstance.markCurrentPassAsFinished()
  }
}

@objc public class AVAssetWriterInputCaptionAdaptorWrapper: NSObject {
  var wrappedInstance: AVAssetWriterInputCaptionAdaptor
  
  @objc public var assetWriterInput: AVAssetWriterInputWrapper {
    get {
      AVAssetWriterInputWrapper(wrappedInstance.assetWriterInput)
    }
  }
  
  init(_ wrappedInstance: AVAssetWriterInputCaptionAdaptor) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(assetWriterInput input: AVAssetWriterInputWrapper) {
    wrappedInstance = AVAssetWriterInputCaptionAdaptor(assetWriterInput: input.wrappedInstance)
  }
  
  @objc public func append(caption: AVCaptionWrapper) -> Bool {
    return wrappedInstance.append(caption: caption.wrappedInstance)
  }
  
  @objc public func append(captionGroup: AVCaptionGroupWrapper) -> Bool {
    return wrappedInstance.append(captionGroup: captionGroup.wrappedInstance)
  }
}

@objc public class AVAssetWriterInputGroupWrapper: NSObject {
  var wrappedInstance: AVAssetWriterInputGroup
  
  @objc public var defaultInput: AVAssetWriterInputWrapper {
    get {
      AVAssetWriterInputWrapper(wrappedInstance.defaultInput)
    }
  }
  
  @objc public var inputs: AVAssetWriterInputWrapper {
    get {
      AVAssetWriterInputWrapper(wrappedInstance.inputs)
    }
  }
  
  init(_ wrappedInstance: AVAssetWriterInputGroup) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(inputs: AVAssetWriterInputWrapper, defaultInput: AVAssetWriterInputWrapper) {
    wrappedInstance = AVAssetWriterInputGroup(inputs: inputs.wrappedInstance, defaultInput: defaultInput.wrappedInstance)
  }
}

@objc public class AVAssetWriterInputMetadataAdaptorWrapper: NSObject {
  var wrappedInstance: AVAssetWriterInputMetadataAdaptor
  
  @objc public var assetWriterInput: AVAssetWriterInputWrapper {
    get {
      AVAssetWriterInputWrapper(wrappedInstance.assetWriterInput)
    }
  }
  
  init(_ wrappedInstance: AVAssetWriterInputMetadataAdaptor) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(assetWriterInput input: AVAssetWriterInputWrapper) {
    wrappedInstance = AVAssetWriterInputMetadataAdaptor(assetWriterInput: input.wrappedInstance)
  }
  
  @objc public func append(timedMetadataGroup: AVTimedMetadataGroupWrapper) -> Bool {
    return wrappedInstance.append(timedMetadataGroup: timedMetadataGroup.wrappedInstance)
  }
}

@objc public class AVAssetWriterInputPassDescriptionWrapper: NSObject {
  var wrappedInstance: AVAssetWriterInputPassDescription
  
  init(_ wrappedInstance: AVAssetWriterInputPassDescription) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAssetWriterInputPixelBufferAdaptorWrapper: NSObject {
  var wrappedInstance: AVAssetWriterInputPixelBufferAdaptor
  
  @objc public var assetWriterInput: AVAssetWriterInputWrapper {
    get {
      AVAssetWriterInputWrapper(wrappedInstance.assetWriterInput)
    }
  }
  
  @objc public var sourcePixelBufferAttributes: String {
    get {
      wrappedInstance.sourcePixelBufferAttributes
    }
  }
  
  init(_ wrappedInstance: AVAssetWriterInputPixelBufferAdaptor) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(assetWriterInput input: AVAssetWriterInputWrapper, sourcePixelBufferAttributes: String) {
    wrappedInstance = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input.wrappedInstance, sourcePixelBufferAttributes: sourcePixelBufferAttributes)
  }
}

@objc public class AVAssetWriterInputTaggedPixelBufferGroupAdaptorWrapper: NSObject {
  var wrappedInstance: AVAssetWriterInputTaggedPixelBufferGroupAdaptor
  
  @objc public var assetWriterInput: AVAssetWriterInputWrapper {
    get {
      AVAssetWriterInputWrapper(wrappedInstance.assetWriterInput)
    }
  }
  
  @objc public var sourcePixelBufferAttributes: String {
    get {
      wrappedInstance.sourcePixelBufferAttributes
    }
  }
  
  init(_ wrappedInstance: AVAssetWriterInputTaggedPixelBufferGroupAdaptor) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(assetWriterInput input: AVAssetWriterInputWrapper, sourcePixelBufferAttributes: String) {
    wrappedInstance = AVAssetWriterInputTaggedPixelBufferGroupAdaptor(assetWriterInput: input.wrappedInstance, sourcePixelBufferAttributes: sourcePixelBufferAttributes)
  }
}

@objc public class AVAsynchronousCIImageFilteringRequestWrapper: NSObject {
  var wrappedInstance: AVAsynchronousCIImageFilteringRequest
  
  init(_ wrappedInstance: AVAsynchronousCIImageFilteringRequest) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAsynchronousVideoCompositionRequestWrapper: NSObject {
  var wrappedInstance: AVAsynchronousVideoCompositionRequest
  
  @objc public var renderContext: AVVideoCompositionRenderContextWrapper {
    get {
      AVVideoCompositionRenderContextWrapper(wrappedInstance.renderContext)
    }
  }
  
  init(_ wrappedInstance: AVAsynchronousVideoCompositionRequest) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func finishCancelledRequest() -> Void {
    return wrappedInstance.finishCancelledRequest()
  }
}

@objc public class AVAudioMixWrapper: NSObject {
  var wrappedInstance: AVAudioMix
  
  @objc public var inputParameters: AVAudioMixInputParametersWrapper {
    get {
      AVAudioMixInputParametersWrapper(wrappedInstance.inputParameters)
    }
  }
  
  init(_ wrappedInstance: AVAudioMix) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAudioMixInputParametersWrapper: NSObject {
  var wrappedInstance: AVAudioMixInputParameters
  
  @objc public var audioTimePitchAlgorithm: AVAudioTimePitchAlgorithmWrapper {
    get {
      AVAudioTimePitchAlgorithmWrapper(wrappedInstance.audioTimePitchAlgorithm)
    }
  }
  
  init(_ wrappedInstance: AVAudioMixInputParameters) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVCameraCalibrationDataWrapper: NSObject {
  var wrappedInstance: AVCameraCalibrationData
  
  init(_ wrappedInstance: AVCameraCalibrationData) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVCaptionWrapper: NSObject {
  var wrappedInstance: AVCaption
  
  @objc public var animation: AVCaptionWrapper {
    get {
      AVCaptionWrapper(wrappedInstance.animation)
    }
  }
  
  @objc public var region: AVCaptionRegionWrapper {
    get {
      AVCaptionRegionWrapper(wrappedInstance.region)
    }
  }
  
  @objc public var text: String {
    get {
      wrappedInstance.text
    }
  }
  
  @objc public var textAlignment: AVCaptionWrapper {
    get {
      AVCaptionWrapper(wrappedInstance.textAlignment)
    }
  }
  
  init(_ wrappedInstance: AVCaption) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVCaptionConversionAdjustmentWrapper: NSObject {
  var wrappedInstance: AVCaptionConversionAdjustment
  
  @objc public var adjustmentType: AVCaptionConversionAdjustmentWrapper {
    get {
      AVCaptionConversionAdjustmentWrapper(wrappedInstance.adjustmentType)
    }
  }
  
  init(_ wrappedInstance: AVCaptionConversionAdjustment) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVCaptionConversionTimeRangeAdjustmentWrapper: NSObject {
  var wrappedInstance: AVCaptionConversionTimeRangeAdjustment
  
  init(_ wrappedInstance: AVCaptionConversionTimeRangeAdjustment) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVCaptionConversionValidatorWrapper: NSObject {
  var wrappedInstance: AVCaptionConversionValidator
  
  @objc public var captions: AVCaptionWrapper {
    get {
      AVCaptionWrapper(wrappedInstance.captions)
    }
  }
  
  @objc public var status: AVCaptionConversionValidatorWrapper {
    get {
      AVCaptionConversionValidatorWrapper(wrappedInstance.status)
    }
  }
  
  @objc public var warnings: AVCaptionConversionWarningWrapper {
    get {
      AVCaptionConversionWarningWrapper(wrappedInstance.warnings)
    }
  }
  
  init(_ wrappedInstance: AVCaptionConversionValidator) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func stopValidating() -> Void {
    return wrappedInstance.stopValidating()
  }
  
  @objc public func validateCaptionConversion(warningHandler handler: AVCaptionConversionWarningWrapper) -> Void {
    return wrappedInstance.validateCaptionConversion(warningHandler: handler.wrappedInstance)
  }
}

@objc public class AVCaptionConversionWarningWrapper: NSObject {
  var wrappedInstance: AVCaptionConversionWarning
  
  @objc public var adjustment: AVCaptionConversionAdjustmentWrapper {
    get {
      AVCaptionConversionAdjustmentWrapper(wrappedInstance.adjustment)
    }
  }
  
  @objc public var warningType: AVCaptionConversionWarningWrapper {
    get {
      AVCaptionConversionWarningWrapper(wrappedInstance.warningType)
    }
  }
  
  init(_ wrappedInstance: AVCaptionConversionWarning) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVCaptionFormatConformerWrapper: NSObject {
  var wrappedInstance: AVCaptionFormatConformer
  
  @objc public var conformsCaptionsToTimeRange: Bool {
    get {
      wrappedInstance.conformsCaptionsToTimeRange
    }
    set {
      wrappedInstance.conformsCaptionsToTimeRange = newValue
    }
  }
  
  init(_ wrappedInstance: AVCaptionFormatConformer) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(conversionSettings: AVCaptionSettingsKeyWrapper) {
    wrappedInstance = AVCaptionFormatConformer(conversionSettings: conversionSettings.wrappedInstance)
  }
  
  @objc public func conformedCaption(for caption: AVCaptionWrapper) -> AVCaptionWrapper {
    let result = wrappedInstance.conformedCaption(for: caption.wrappedInstance)
    return AVCaptionWrapper(result)
  }
}

@objc public class AVCaptionGroupWrapper: NSObject {
  var wrappedInstance: AVCaptionGroup
  
  @objc public var captions: AVCaptionWrapper {
    get {
      AVCaptionWrapper(wrappedInstance.captions)
    }
  }
  
  init(_ wrappedInstance: AVCaptionGroup) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVCaptionGrouperWrapper: NSObject {
  var wrappedInstance: AVCaptionGrouper
  
  init(_ wrappedInstance: AVCaptionGrouper) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func add(input: AVCaptionWrapper) -> Void {
    return wrappedInstance.add(input: input.wrappedInstance)
  }
}

@objc public class AVCaptionRegionWrapper: NSObject {
  var wrappedInstance: AVCaptionRegion
  
  @objc static public var appleITTBottom: AVCaptionRegionWrapper {
    get {
      AVCaptionRegionWrapper(AVCaptionRegion.appleITTBottom)
    }
  }
  
  @objc static public var appleITTLeft: AVCaptionRegionWrapper {
    get {
      AVCaptionRegionWrapper(AVCaptionRegion.appleITTLeft)
    }
  }
  
  @objc static public var appleITTRight: AVCaptionRegionWrapper {
    get {
      AVCaptionRegionWrapper(AVCaptionRegion.appleITTRight)
    }
  }
  
  @objc static public var appleITTTop: AVCaptionRegionWrapper {
    get {
      AVCaptionRegionWrapper(AVCaptionRegion.appleITTTop)
    }
  }
  
  @objc static public var subRipTextBottom: AVCaptionRegionWrapper {
    get {
      AVCaptionRegionWrapper(AVCaptionRegion.subRipTextBottom)
    }
  }
  
  @objc public var displayAlignment: AVCaptionRegionWrapper {
    get {
      AVCaptionRegionWrapper(wrappedInstance.displayAlignment)
    }
  }
  
  @objc public var identifier: String {
    get {
      wrappedInstance.identifier
    }
  }
  
  @objc public var origin: AVCaptionPointWrapper {
    get {
      AVCaptionPointWrapper(wrappedInstance.origin)
    }
  }
  
  @objc public var scroll: AVCaptionRegionWrapper {
    get {
      AVCaptionRegionWrapper(wrappedInstance.scroll)
    }
  }
  
  @objc public var size: AVCaptionSizeWrapper {
    get {
      AVCaptionSizeWrapper(wrappedInstance.size)
    }
  }
  
  @objc public var writingMode: AVCaptionRegionWrapper {
    get {
      AVCaptionRegionWrapper(wrappedInstance.writingMode)
    }
  }
  
  init(_ wrappedInstance: AVCaptionRegion) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVCaptionRendererWrapper: NSObject {
  var wrappedInstance: AVCaptionRenderer
  
  @objc public var captions: AVCaptionWrapper {
    get {
      AVCaptionWrapper(wrappedInstance.captions)
    }
    set {
      wrappedInstance.captions = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVCaptionRenderer) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class SceneWrapper: NSObject {
  var wrappedInstance: AVCaptionRenderer.Scene
  
  @objc public var hasActiveCaptions: Bool {
    get {
      wrappedInstance.hasActiveCaptions
    }
  }
  
  @objc public var needsPeriodicRefresh: Bool {
    get {
      wrappedInstance.needsPeriodicRefresh
    }
  }
  
  init(_ wrappedInstance: AVCaptionRenderer.Scene) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class RubyWrapper: NSObject {
  var wrappedInstance: AVCaption.Ruby
  
  @objc public var text: String {
    get {
      wrappedInstance.text
    }
  }
  
  init(_ wrappedInstance: AVCaption.Ruby) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(text: String) {
    wrappedInstance = AVCaption.Ruby(text: text)
  }
}

@objc public class AVCaptureAudioChannelWrapper: NSObject {
  var wrappedInstance: AVCaptureAudioChannel
  
  @objc public var isEnabled: Bool {
    get {
      wrappedInstance.isEnabled
    }
    set {
      wrappedInstance.isEnabled = newValue
    }
  }
  
  init(_ wrappedInstance: AVCaptureAudioChannel) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVCaptureAudioDataOutputWrapper: NSObject {
  var wrappedInstance: AVCaptureAudioDataOutput
  
  @objc public var audioSettings: String {
    get {
      wrappedInstance.audioSettings
    }
    set {
      wrappedInstance.audioSettings = newValue
    }
  }
  
  init(_ wrappedInstance: AVCaptureAudioDataOutput) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVCaptureAudioDataOutput()
  }
}

@objc public class AVCaptureAudioFileOutputWrapper: NSObject {
  var wrappedInstance: AVCaptureAudioFileOutput
  
  @objc public var audioSettings: String {
    get {
      wrappedInstance.audioSettings
    }
    set {
      wrappedInstance.audioSettings = newValue
    }
  }
  
  @objc public var metadata: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.metadata)
    }
    set {
      wrappedInstance.metadata = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVCaptureAudioFileOutput) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVCaptureAudioFileOutput()
  }
}

@objc public class AVCaptureAudioPreviewOutputWrapper: NSObject {
  var wrappedInstance: AVCaptureAudioPreviewOutput
  
  @objc public var outputDeviceUniqueID: String {
    get {
      wrappedInstance.outputDeviceUniqueID
    }
    set {
      wrappedInstance.outputDeviceUniqueID = newValue
    }
  }
  
  init(_ wrappedInstance: AVCaptureAudioPreviewOutput) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVCaptureAudioPreviewOutput()
  }
}

@objc public class AVCaptureConnectionWrapper: NSObject {
  var wrappedInstance: AVCaptureConnection
  
  @objc public var isActive: Bool {
    get {
      wrappedInstance.isActive
    }
  }
  
  @objc public var audioChannels: AVCaptureAudioChannelWrapper {
    get {
      AVCaptureAudioChannelWrapper(wrappedInstance.audioChannels)
    }
  }
  
  @objc public var automaticallyAdjustsVideoMirroring: Bool {
    get {
      wrappedInstance.automaticallyAdjustsVideoMirroring
    }
    set {
      wrappedInstance.automaticallyAdjustsVideoMirroring = newValue
    }
  }
  
  @objc public var isEnabled: Bool {
    get {
      wrappedInstance.isEnabled
    }
    set {
      wrappedInstance.isEnabled = newValue
    }
  }
  
  @objc public var inputPorts: AVCaptureInputWrapper {
    get {
      AVCaptureInputWrapper(wrappedInstance.inputPorts)
    }
  }
  
  @objc public var output: AVCaptureOutputWrapper {
    get {
      AVCaptureOutputWrapper(wrappedInstance.output)
    }
  }
  
  @objc public var isVideoFieldModeSupported: Bool {
    get {
      wrappedInstance.isVideoFieldModeSupported
    }
  }
  
  @objc public var isVideoMaxFrameDurationSupported: Bool {
    get {
      wrappedInstance.isVideoMaxFrameDurationSupported
    }
  }
  
  @objc public var isVideoMinFrameDurationSupported: Bool {
    get {
      wrappedInstance.isVideoMinFrameDurationSupported
    }
  }
  
  @objc public var isVideoMirroringSupported: Bool {
    get {
      wrappedInstance.isVideoMirroringSupported
    }
  }
  
  @objc public var isVideoOrientationSupported: Bool {
    get {
      wrappedInstance.isVideoOrientationSupported
    }
  }
  
  @objc public var isVideoMirrored: Bool {
    get {
      wrappedInstance.isVideoMirrored
    }
    set {
      wrappedInstance.isVideoMirrored = newValue
    }
  }
  
  @objc public var videoPreviewLayer: AVCaptureVideoPreviewLayerWrapper {
    get {
      AVCaptureVideoPreviewLayerWrapper(wrappedInstance.videoPreviewLayer)
    }
  }
  
  init(_ wrappedInstance: AVCaptureConnection) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVCaptureDeskViewApplicationWrapper: NSObject {
  var wrappedInstance: AVCaptureDeskViewApplication
  
  init(_ wrappedInstance: AVCaptureDeskViewApplication) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func present() -> Void {
    return wrappedInstance.present()
  }
  
  @objc public func present() -> Void {
    return wrappedInstance.present()
  }
}

@objc public class LaunchConfigurationWrapper: NSObject {
  var wrappedInstance: AVCaptureDeskViewApplication.LaunchConfiguration
  
  @objc public var requiresSetUpModeCompletion: Bool {
    get {
      wrappedInstance.requiresSetUpModeCompletion
    }
    set {
      wrappedInstance.requiresSetUpModeCompletion = newValue
    }
  }
  
  init(_ wrappedInstance: AVCaptureDeskViewApplication.LaunchConfiguration) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVCaptureDeviceWrapper: NSObject {
  var wrappedInstance: AVCaptureDevice
  
  @objc static public var activeMicrophoneMode: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(AVCaptureDevice.activeMicrophoneMode)
    }
  }
  
  @objc static public var centerStageControlMode: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(AVCaptureDevice.centerStageControlMode)
    }
    set {
      AVCaptureDevice.centerStageControlMode = newValue.wrappedInstance
    }
  }
  
  @objc static public var isCenterStageEnabled: Bool {
    get {
      AVCaptureDevice.isCenterStageEnabled
    }
    set {
      AVCaptureDevice.isCenterStageEnabled = newValue
    }
  }
  
  @objc static public var isPortraitEffectEnabled: Bool {
    get {
      AVCaptureDevice.isPortraitEffectEnabled
    }
  }
  
  @objc static public var preferredMicrophoneMode: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(AVCaptureDevice.preferredMicrophoneMode)
    }
  }
  
  @objc static public var reactionEffectGesturesEnabled: Bool {
    get {
      AVCaptureDevice.reactionEffectGesturesEnabled
    }
  }
  
  @objc static public var reactionEffectsEnabled: Bool {
    get {
      AVCaptureDevice.reactionEffectsEnabled
    }
  }
  
  @objc static public var isStudioLightEnabled: Bool {
    get {
      AVCaptureDevice.isStudioLightEnabled
    }
  }
  
  @objc static public var systemPreferredCamera: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(AVCaptureDevice.systemPreferredCamera)
    }
  }
  
  @objc static public var userPreferredCamera: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(AVCaptureDevice.userPreferredCamera)
    }
    set {
      AVCaptureDevice.userPreferredCamera = newValue.wrappedInstance
    }
  }
  
  @objc public var activeFormat: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.activeFormat)
    }
    set {
      wrappedInstance.activeFormat = newValue.wrappedInstance
    }
  }
  
  @objc public var activeInputSource: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.activeInputSource)
    }
    set {
      wrappedInstance.activeInputSource = newValue.wrappedInstance
    }
  }
  
  @objc public var activePrimaryConstituent: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.activePrimaryConstituent)
    }
  }
  
  @objc public var activePrimaryConstituentDeviceRestrictedSwitchingBehaviorConditions: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.activePrimaryConstituentDeviceRestrictedSwitchingBehaviorConditions)
    }
  }
  
  @objc public var activePrimaryConstituentDeviceSwitchingBehavior: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.activePrimaryConstituentDeviceSwitchingBehavior)
    }
  }
  
  @objc public var isAdjustingExposure: Bool {
    get {
      wrappedInstance.isAdjustingExposure
    }
  }
  
  @objc public var isAdjustingFocus: Bool {
    get {
      wrappedInstance.isAdjustingFocus
    }
  }
  
  @objc public var isAdjustingWhiteBalance: Bool {
    get {
      wrappedInstance.isAdjustingWhiteBalance
    }
  }
  
  @objc public var canPerformReactionEffects: Bool {
    get {
      wrappedInstance.canPerformReactionEffects
    }
  }
  
  @objc public var isCenterStageActive: Bool {
    get {
      wrappedInstance.isCenterStageActive
    }
  }
  
  @objc public var companionDeskViewCamera: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.companionDeskViewCamera)
    }
  }
  
  @objc public var isConnected: Bool {
    get {
      wrappedInstance.isConnected
    }
  }
  
  @objc public var isContinuityCamera: Bool {
    get {
      wrappedInstance.isContinuityCamera
    }
  }
  
  @objc public var deviceType: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.deviceType)
    }
  }
  
  @objc public var exposureMode: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.exposureMode)
    }
    set {
      wrappedInstance.exposureMode = newValue.wrappedInstance
    }
  }
  
  @objc public var isExposurePointOfInterestSupported: Bool {
    get {
      wrappedInstance.isExposurePointOfInterestSupported
    }
  }
  
  @objc public var fallbackPrimaryConstituentDevices: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.fallbackPrimaryConstituentDevices)
    }
    set {
      wrappedInstance.fallbackPrimaryConstituentDevices = newValue.wrappedInstance
    }
  }
  
  @objc public var isFlashAvailable: Bool {
    get {
      wrappedInstance.isFlashAvailable
    }
  }
  
  @objc public var flashMode: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.flashMode)
    }
    set {
      wrappedInstance.flashMode = newValue.wrappedInstance
    }
  }
  
  @objc public var focusMode: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.focusMode)
    }
    set {
      wrappedInstance.focusMode = newValue.wrappedInstance
    }
  }
  
  @objc public var isFocusPointOfInterestSupported: Bool {
    get {
      wrappedInstance.isFocusPointOfInterestSupported
    }
  }
  
  @objc public var formats: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.formats)
    }
  }
  
  @objc public var hasFlash: Bool {
    get {
      wrappedInstance.hasFlash
    }
  }
  
  @objc public var hasTorch: Bool {
    get {
      wrappedInstance.hasTorch
    }
  }
  
  @objc public var isInUseByAnotherApplication: Bool {
    get {
      wrappedInstance.isInUseByAnotherApplication
    }
  }
  
  @objc public var inputSources: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.inputSources)
    }
  }
  
  @objc public var linkedDevices: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.linkedDevices)
    }
  }
  
  @objc public var localizedName: String {
    get {
      wrappedInstance.localizedName
    }
  }
  
  @objc public var manufacturer: String {
    get {
      wrappedInstance.manufacturer
    }
  }
  
  @objc public var minimumFocusDistance: Int {
    get {
      wrappedInstance.minimumFocusDistance
    }
  }
  
  @objc public var modelID: String {
    get {
      wrappedInstance.modelID
    }
  }
  
  @objc public var isPortraitEffectActive: Bool {
    get {
      wrappedInstance.isPortraitEffectActive
    }
  }
  
  @objc public var position: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.position)
    }
  }
  
  @objc public var primaryConstituentDeviceRestrictedSwitchingBehaviorConditions: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.primaryConstituentDeviceRestrictedSwitchingBehaviorConditions)
    }
  }
  
  @objc public var primaryConstituentDeviceSwitchingBehavior: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.primaryConstituentDeviceSwitchingBehavior)
    }
  }
  
  @objc public var reactionEffectsInProgress: AVCaptureReactionEffectStateWrapper {
    get {
      AVCaptureReactionEffectStateWrapper(wrappedInstance.reactionEffectsInProgress)
    }
  }
  
  @objc public var isStudioLightActive: Bool {
    get {
      wrappedInstance.isStudioLightActive
    }
  }
  
  @objc public var supportedFallbackPrimaryConstituentDevices: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.supportedFallbackPrimaryConstituentDevices)
    }
  }
  
  @objc public var isSuspended: Bool {
    get {
      wrappedInstance.isSuspended
    }
  }
  
  @objc public var isTorchActive: Bool {
    get {
      wrappedInstance.isTorchActive
    }
  }
  
  @objc public var isTorchAvailable: Bool {
    get {
      wrappedInstance.isTorchAvailable
    }
  }
  
  @objc public var torchMode: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.torchMode)
    }
    set {
      wrappedInstance.torchMode = newValue.wrappedInstance
    }
  }
  
  @objc public var transportControlsPlaybackMode: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.transportControlsPlaybackMode)
    }
  }
  
  @objc public var transportControlsSpeed: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.transportControlsSpeed)
    }
  }
  
  @objc public var transportControlsSupported: Bool {
    get {
      wrappedInstance.transportControlsSupported
    }
  }
  
  @objc public var uniqueID: String {
    get {
      wrappedInstance.uniqueID
    }
  }
  
  @objc public var whiteBalanceMode: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.whiteBalanceMode)
    }
    set {
      wrappedInstance.whiteBalanceMode = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVCaptureDevice) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(uniqueID deviceUniqueID: String) {
    wrappedInstance = AVCaptureDevice(uniqueID: deviceUniqueID)
  }
  
  @objc static public func `default`(deviceType: AVCaptureDeviceWrapper, for mediaType: AVMediaTypeWrapper, position: AVCaptureDeviceWrapper) -> AVCaptureDeviceWrapper {
    let result = AVCaptureDevice.`default`(deviceType: deviceType.wrappedInstance, for: mediaType.wrappedInstance, position: position.wrappedInstance)
    return AVCaptureDeviceWrapper(result)
  }
  
  @objc static public func `default`(for mediaType: AVMediaTypeWrapper) -> AVCaptureDeviceWrapper {
    let result = AVCaptureDevice.`default`(for: mediaType.wrappedInstance)
    return AVCaptureDeviceWrapper(result)
  }
  
  @objc static public func requestAccess(for mediaType: AVMediaTypeWrapper, completionHandler handler: Bool) -> Void {
    return AVCaptureDevice.requestAccess(for: mediaType.wrappedInstance, completionHandler: handler)
  }
  
  @objc static public func requestAccess(for mediaType: AVMediaTypeWrapper, completionHandler handler: Bool) -> Void {
    return AVCaptureDevice.requestAccess(for: mediaType.wrappedInstance, completionHandler: handler)
  }
  
  @objc static public func showSystemUserInterface(systemUserInterface: AVCaptureDeviceWrapper) -> Void {
    return AVCaptureDevice.showSystemUserInterface(systemUserInterface: systemUserInterface.wrappedInstance)
  }
  
  @objc public func hasMediaType(mediaType: AVMediaTypeWrapper) -> Bool {
    return wrappedInstance.hasMediaType(mediaType: mediaType.wrappedInstance)
  }
  
  @objc public func isExposureModeSupported(exposureMode: AVCaptureDeviceWrapper) -> Bool {
    return wrappedInstance.isExposureModeSupported(exposureMode: exposureMode.wrappedInstance)
  }
  
  @objc public func isFlashModeSupported(flashMode: AVCaptureDeviceWrapper) -> Bool {
    return wrappedInstance.isFlashModeSupported(flashMode: flashMode.wrappedInstance)
  }
  
  @objc public func isFocusModeSupported(focusMode: AVCaptureDeviceWrapper) -> Bool {
    return wrappedInstance.isFocusModeSupported(focusMode: focusMode.wrappedInstance)
  }
  
  @objc public func isTorchModeSupported(torchMode: AVCaptureDeviceWrapper) -> Bool {
    return wrappedInstance.isTorchModeSupported(torchMode: torchMode.wrappedInstance)
  }
  
  @objc public func isWhiteBalanceModeSupported(whiteBalanceMode: AVCaptureDeviceWrapper) -> Bool {
    return wrappedInstance.isWhiteBalanceModeSupported(whiteBalanceMode: whiteBalanceMode.wrappedInstance)
  }
  
  @objc public func lockForConfiguration() {
    wrappedInstance.lockForConfiguration()
  }
  
  @objc public func performEffect(for reactionType: AVCaptureReactionTypeWrapper) -> Void {
    return wrappedInstance.performEffect(for: reactionType.wrappedInstance)
  }
  
  @objc public func setPrimaryConstituentDeviceSwitchingBehavior(switchingBehavior: AVCaptureDeviceWrapper, restrictedSwitchingBehaviorConditions: AVCaptureDeviceWrapper) -> Void {
    return wrappedInstance.setPrimaryConstituentDeviceSwitchingBehavior(switchingBehavior: switchingBehavior.wrappedInstance, restrictedSwitchingBehaviorConditions: restrictedSwitchingBehaviorConditions.wrappedInstance)
  }
  
  @objc public func setTransportControlsPlaybackMode(mode: AVCaptureDeviceWrapper, speed: AVCaptureDeviceWrapper) -> Void {
    return wrappedInstance.setTransportControlsPlaybackMode(mode: mode.wrappedInstance, speed: speed.wrappedInstance)
  }
  
  @objc public func supportsSessionPreset(preset: AVCaptureSessionWrapper) -> Bool {
    return wrappedInstance.supportsSessionPreset(preset: preset.wrappedInstance)
  }
  
  @objc public func unlockForConfiguration() -> Void {
    return wrappedInstance.unlockForConfiguration()
  }
}

@objc public class DiscoverySessionWrapper: NSObject {
  var wrappedInstance: AVCaptureDevice.DiscoverySession
  
  @objc public var devices: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.devices)
    }
  }
  
  init(_ wrappedInstance: AVCaptureDevice.DiscoverySession) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class FormatWrapper: NSObject {
  var wrappedInstance: AVCaptureDevice.Format
  
  @objc public var autoFocusSystem: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.autoFocusSystem)
    }
  }
  
  @objc public var isCenterStageSupported: Bool {
    get {
      wrappedInstance.isCenterStageSupported
    }
  }
  
  @objc public var isHighPhotoQualitySupported: Bool {
    get {
      wrappedInstance.isHighPhotoQualitySupported
    }
  }
  
  @objc public var mediaType: AVMediaTypeWrapper {
    get {
      AVMediaTypeWrapper(wrappedInstance.mediaType)
    }
  }
  
  @objc public var isPortraitEffectSupported: Bool {
    get {
      wrappedInstance.isPortraitEffectSupported
    }
  }
  
  @objc public var reactionEffectsSupported: Bool {
    get {
      wrappedInstance.reactionEffectsSupported
    }
  }
  
  @objc public var isStudioLightSupported: Bool {
    get {
      wrappedInstance.isStudioLightSupported
    }
  }
  
  @objc public var videoFrameRateRangeForCenterStage: AVFrameRateRangeWrapper {
    get {
      AVFrameRateRangeWrapper(wrappedInstance.videoFrameRateRangeForCenterStage)
    }
  }
  
  @objc public var videoFrameRateRangeForPortraitEffect: AVFrameRateRangeWrapper {
    get {
      AVFrameRateRangeWrapper(wrappedInstance.videoFrameRateRangeForPortraitEffect)
    }
  }
  
  @objc public var videoFrameRateRangeForReactionEffectsInProgress: AVFrameRateRangeWrapper {
    get {
      AVFrameRateRangeWrapper(wrappedInstance.videoFrameRateRangeForReactionEffectsInProgress)
    }
  }
  
  @objc public var videoFrameRateRangeForStudioLight: AVFrameRateRangeWrapper {
    get {
      AVFrameRateRangeWrapper(wrappedInstance.videoFrameRateRangeForStudioLight)
    }
  }
  
  @objc public var videoSupportedFrameRateRanges: AVFrameRateRangeWrapper {
    get {
      AVFrameRateRangeWrapper(wrappedInstance.videoSupportedFrameRateRanges)
    }
  }
  
  init(_ wrappedInstance: AVCaptureDevice.Format) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVCaptureDeviceInputWrapper: NSObject {
  var wrappedInstance: AVCaptureDeviceInput
  
  @objc public var device: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.device)
    }
  }
  
  init(_ wrappedInstance: AVCaptureDeviceInput) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(device: AVCaptureDeviceWrapper) {
    wrappedInstance = AVCaptureDeviceInput(device: device.wrappedInstance)
  }
}

@objc public class InputSourceWrapper: NSObject {
  var wrappedInstance: AVCaptureDevice.InputSource
  
  @objc public var inputSourceID: String {
    get {
      wrappedInstance.inputSourceID
    }
  }
  
  @objc public var localizedName: String {
    get {
      wrappedInstance.localizedName
    }
  }
  
  init(_ wrappedInstance: AVCaptureDevice.InputSource) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class RotationCoordinatorWrapper: NSObject {
  var wrappedInstance: AVCaptureDevice.RotationCoordinator
  
  @objc public var device: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.device)
    }
  }
  
  init(_ wrappedInstance: AVCaptureDevice.RotationCoordinator) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVCaptureFileOutputWrapper: NSObject {
  var wrappedInstance: AVCaptureFileOutput
  
  @objc public var isRecording: Bool {
    get {
      wrappedInstance.isRecording
    }
  }
  
  @objc public var isRecordingPaused: Bool {
    get {
      wrappedInstance.isRecordingPaused
    }
  }
  
  init(_ wrappedInstance: AVCaptureFileOutput) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func pauseRecording() -> Void {
    return wrappedInstance.pauseRecording()
  }
  
  @objc public func resumeRecording() -> Void {
    return wrappedInstance.resumeRecording()
  }
  
  @objc public func stopRecording() -> Void {
    return wrappedInstance.stopRecording()
  }
}

@objc public class AVCaptureInputWrapper: NSObject {
  var wrappedInstance: AVCaptureInput
  
  @objc public var ports: AVCaptureInputWrapper {
    get {
      AVCaptureInputWrapper(wrappedInstance.ports)
    }
  }
  
  init(_ wrappedInstance: AVCaptureInput) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class PortWrapper: NSObject {
  var wrappedInstance: AVCaptureInput.Port
  
  @objc public var isEnabled: Bool {
    get {
      wrappedInstance.isEnabled
    }
    set {
      wrappedInstance.isEnabled = newValue
    }
  }
  
  @objc public var input: AVCaptureInputWrapper {
    get {
      AVCaptureInputWrapper(wrappedInstance.input)
    }
  }
  
  @objc public var mediaType: AVMediaTypeWrapper {
    get {
      AVMediaTypeWrapper(wrappedInstance.mediaType)
    }
  }
  
  init(_ wrappedInstance: AVCaptureInput.Port) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVCaptureMetadataOutputWrapper: NSObject {
  var wrappedInstance: AVCaptureMetadataOutput
  
  @objc public var availableMetadataObjectTypes: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(wrappedInstance.availableMetadataObjectTypes)
    }
  }
  
  @objc public var metadataObjectTypes: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(wrappedInstance.metadataObjectTypes)
    }
    set {
      wrappedInstance.metadataObjectTypes = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVCaptureMetadataOutput) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVCaptureMetadataOutput()
  }
}

@objc public class AVCaptureMovieFileOutputWrapper: NSObject {
  var wrappedInstance: AVCaptureMovieFileOutput
  
  @objc public var metadata: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.metadata)
    }
    set {
      wrappedInstance.metadata = newValue.wrappedInstance
    }
  }
  
  @objc public var primaryConstituentDeviceRestrictedSwitchingBehaviorConditionsForRecording: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.primaryConstituentDeviceRestrictedSwitchingBehaviorConditionsForRecording)
    }
  }
  
  @objc public var primaryConstituentDeviceSwitchingBehaviorForRecording: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.primaryConstituentDeviceSwitchingBehaviorForRecording)
    }
  }
  
  @objc public var isPrimaryConstituentDeviceSwitchingBehaviorForRecordingEnabled: Bool {
    get {
      wrappedInstance.isPrimaryConstituentDeviceSwitchingBehaviorForRecordingEnabled
    }
    set {
      wrappedInstance.isPrimaryConstituentDeviceSwitchingBehaviorForRecordingEnabled = newValue
    }
  }
  
  init(_ wrappedInstance: AVCaptureMovieFileOutput) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVCaptureMovieFileOutput()
  }
  
  @objc public func setOutputSettings(outputSettings: String, for connection: AVCaptureConnectionWrapper) -> Void {
    return wrappedInstance.setOutputSettings(outputSettings: outputSettings, for: connection.wrappedInstance)
  }
  
  @objc public func setPrimaryConstituentDeviceSwitchingBehaviorForRecording(switchingBehavior: AVCaptureDeviceWrapper, restrictedSwitchingBehaviorConditions: AVCaptureDeviceWrapper) -> Void {
    return wrappedInstance.setPrimaryConstituentDeviceSwitchingBehaviorForRecording(switchingBehavior: switchingBehavior.wrappedInstance, restrictedSwitchingBehaviorConditions: restrictedSwitchingBehaviorConditions.wrappedInstance)
  }
}

@objc public class AVCaptureOutputWrapper: NSObject {
  var wrappedInstance: AVCaptureOutput
  
  @objc public var connections: AVCaptureConnectionWrapper {
    get {
      AVCaptureConnectionWrapper(wrappedInstance.connections)
    }
  }
  
  init(_ wrappedInstance: AVCaptureOutput) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func connection(with mediaType: AVMediaTypeWrapper) -> AVCaptureConnectionWrapper {
    let result = wrappedInstance.connection(with: mediaType.wrappedInstance)
    return AVCaptureConnectionWrapper(result)
  }
  
  @objc public func transformedMetadataObject(for metadataObject: AVMetadataObjectWrapper, connection: AVCaptureConnectionWrapper) -> AVMetadataObjectWrapper {
    let result = wrappedInstance.transformedMetadataObject(for: metadataObject.wrappedInstance, connection: connection.wrappedInstance)
    return AVMetadataObjectWrapper(result)
  }
}

@objc public class AVCapturePhotoWrapper: NSObject {
  var wrappedInstance: AVCapturePhoto
  
  @objc public var photoCount: Int {
    get {
      wrappedInstance.photoCount
    }
  }
  
  @objc public var resolvedSettings: AVCaptureResolvedPhotoSettingsWrapper {
    get {
      AVCaptureResolvedPhotoSettingsWrapper(wrappedInstance.resolvedSettings)
    }
  }
  
  init(_ wrappedInstance: AVCapturePhoto) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVCapturePhotoOutputWrapper: NSObject {
  var wrappedInstance: AVCapturePhotoOutput
  
  @objc public var availablePhotoCodecTypes: AVVideoCodecTypeWrapper {
    get {
      AVVideoCodecTypeWrapper(wrappedInstance.availablePhotoCodecTypes)
    }
  }
  
  @objc public var availablePhotoFileTypes: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(wrappedInstance.availablePhotoFileTypes)
    }
  }
  
  @objc public var captureReadiness: AVCapturePhotoOutputWrapper {
    get {
      AVCapturePhotoOutputWrapper(wrappedInstance.captureReadiness)
    }
  }
  
  @objc public var isFastCapturePrioritizationEnabled: Bool {
    get {
      wrappedInstance.isFastCapturePrioritizationEnabled
    }
    set {
      wrappedInstance.isFastCapturePrioritizationEnabled = newValue
    }
  }
  
  @objc public var isFastCapturePrioritizationSupported: Bool {
    get {
      wrappedInstance.isFastCapturePrioritizationSupported
    }
    set {
      wrappedInstance.isFastCapturePrioritizationSupported = newValue
    }
  }
  
  @objc public var isHighResolutionCaptureEnabled: Bool {
    get {
      wrappedInstance.isHighResolutionCaptureEnabled
    }
    set {
      wrappedInstance.isHighResolutionCaptureEnabled = newValue
    }
  }
  
  @objc public var maxPhotoQualityPrioritization: AVCapturePhotoOutputWrapper {
    get {
      AVCapturePhotoOutputWrapper(wrappedInstance.maxPhotoQualityPrioritization)
    }
    set {
      wrappedInstance.maxPhotoQualityPrioritization = newValue.wrappedInstance
    }
  }
  
  @objc public var preservesLivePhotoCaptureSuspendedOnSessionStop: Bool {
    get {
      wrappedInstance.preservesLivePhotoCaptureSuspendedOnSessionStop
    }
    set {
      wrappedInstance.preservesLivePhotoCaptureSuspendedOnSessionStop = newValue
    }
  }
  
  @objc public var isResponsiveCaptureEnabled: Bool {
    get {
      wrappedInstance.isResponsiveCaptureEnabled
    }
    set {
      wrappedInstance.isResponsiveCaptureEnabled = newValue
    }
  }
  
  @objc public var isResponsiveCaptureSupported: Bool {
    get {
      wrappedInstance.isResponsiveCaptureSupported
    }
  }
  
  @objc public var isZeroShutterLagEnabled: Bool {
    get {
      wrappedInstance.isZeroShutterLagEnabled
    }
    set {
      wrappedInstance.isZeroShutterLagEnabled = newValue
    }
  }
  
  @objc public var isZeroShutterLagSupported: Bool {
    get {
      wrappedInstance.isZeroShutterLagSupported
    }
  }
  
  @objc public var supportedFlashModes: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.supportedFlashModes)
    }
  }
  
  init(_ wrappedInstance: AVCapturePhotoOutput) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVCapturePhotoOutput()
  }
}

@objc public class AVCapturePhotoOutputReadinessCoordinatorWrapper: NSObject {
  var wrappedInstance: AVCapturePhotoOutputReadinessCoordinator
  
  @objc public var captureReadiness: AVCapturePhotoOutputWrapper {
    get {
      AVCapturePhotoOutputWrapper(wrappedInstance.captureReadiness)
    }
  }
  
  init(_ wrappedInstance: AVCapturePhotoOutputReadinessCoordinator) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(photoOutput: AVCapturePhotoOutputWrapper) {
    wrappedInstance = AVCapturePhotoOutputReadinessCoordinator(photoOutput: photoOutput.wrappedInstance)
  }
  
  @objc public func startTrackingCaptureRequest(using settings: AVCapturePhotoSettingsWrapper) -> Void {
    return wrappedInstance.startTrackingCaptureRequest(using: settings.wrappedInstance)
  }
}

@objc public class AVCapturePhotoSettingsWrapper: NSObject {
  var wrappedInstance: AVCapturePhotoSettings
  
  @objc public var flashMode: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.flashMode)
    }
    set {
      wrappedInstance.flashMode = newValue.wrappedInstance
    }
  }
  
  @objc public var format: String {
    get {
      wrappedInstance.format
    }
  }
  
  @objc public var isHighResolutionPhotoEnabled: Bool {
    get {
      wrappedInstance.isHighResolutionPhotoEnabled
    }
    set {
      wrappedInstance.isHighResolutionPhotoEnabled = newValue
    }
  }
  
  @objc public var photoQualityPrioritization: AVCapturePhotoOutputWrapper {
    get {
      AVCapturePhotoOutputWrapper(wrappedInstance.photoQualityPrioritization)
    }
    set {
      wrappedInstance.photoQualityPrioritization = newValue.wrappedInstance
    }
  }
  
  @objc public var processedFileType: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(wrappedInstance.processedFileType)
    }
  }
  
  init(_ wrappedInstance: AVCapturePhotoSettings) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(from photoSettings: AVCapturePhotoSettingsWrapper) {
    wrappedInstance = AVCapturePhotoSettings(from: photoSettings.wrappedInstance)
  }
  
  @objc init(fromPhotoSettings photoSettings: AVCapturePhotoSettingsWrapper) {
    wrappedInstance = AVCapturePhotoSettings(fromPhotoSettings: photoSettings.wrappedInstance)
  }
  
  @objc init(format: String) {
    wrappedInstance = AVCapturePhotoSettings(format: format)
  }
}

@objc public class AVCaptureReactionEffectStateWrapper: NSObject {
  var wrappedInstance: AVCaptureReactionEffectState
  
  @objc public var reactionType: AVCaptureReactionTypeWrapper {
    get {
      AVCaptureReactionTypeWrapper(wrappedInstance.reactionType)
    }
  }
  
  init(_ wrappedInstance: AVCaptureReactionEffectState) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVCaptureResolvedPhotoSettingsWrapper: NSObject {
  var wrappedInstance: AVCaptureResolvedPhotoSettings
  
  @objc public var expectedPhotoCount: Int {
    get {
      wrappedInstance.expectedPhotoCount
    }
  }
  
  @objc public var isFastCapturePrioritizationEnabled: Bool {
    get {
      wrappedInstance.isFastCapturePrioritizationEnabled
    }
  }
  
  init(_ wrappedInstance: AVCaptureResolvedPhotoSettings) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVCaptureScreenInputWrapper: NSObject {
  var wrappedInstance: AVCaptureScreenInput
  
  @objc public var capturesCursor: Bool {
    get {
      wrappedInstance.capturesCursor
    }
    set {
      wrappedInstance.capturesCursor = newValue
    }
  }
  
  @objc public var capturesMouseClicks: Bool {
    get {
      wrappedInstance.capturesMouseClicks
    }
    set {
      wrappedInstance.capturesMouseClicks = newValue
    }
  }
  
  @objc public var removesDuplicateFrames: Bool {
    get {
      wrappedInstance.removesDuplicateFrames
    }
    set {
      wrappedInstance.removesDuplicateFrames = newValue
    }
  }
  
  init(_ wrappedInstance: AVCaptureScreenInput) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVCaptureScreenInput()
  }
}

@objc public class AVCaptureSessionWrapper: NSObject {
  var wrappedInstance: AVCaptureSession
  
  @objc public var connections: AVCaptureConnectionWrapper {
    get {
      AVCaptureConnectionWrapper(wrappedInstance.connections)
    }
  }
  
  @objc public var inputs: AVCaptureInputWrapper {
    get {
      AVCaptureInputWrapper(wrappedInstance.inputs)
    }
  }
  
  @objc public var outputs: AVCaptureOutputWrapper {
    get {
      AVCaptureOutputWrapper(wrappedInstance.outputs)
    }
  }
  
  @objc public var isRunning: Bool {
    get {
      wrappedInstance.isRunning
    }
  }
  
  @objc public var sessionPreset: AVCaptureSessionWrapper {
    get {
      AVCaptureSessionWrapper(wrappedInstance.sessionPreset)
    }
    set {
      wrappedInstance.sessionPreset = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVCaptureSession) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func addConnection(connection: AVCaptureConnectionWrapper) -> Void {
    return wrappedInstance.addConnection(connection: connection.wrappedInstance)
  }
  
  @objc public func addInput(input: AVCaptureInputWrapper) -> Void {
    return wrappedInstance.addInput(input: input.wrappedInstance)
  }
  
  @objc public func addInputWithNoConnections(input: AVCaptureInputWrapper) -> Void {
    return wrappedInstance.addInputWithNoConnections(input: input.wrappedInstance)
  }
  
  @objc public func addOutput(output: AVCaptureOutputWrapper) -> Void {
    return wrappedInstance.addOutput(output: output.wrappedInstance)
  }
  
  @objc public func addOutputWithNoConnections(output: AVCaptureOutputWrapper) -> Void {
    return wrappedInstance.addOutputWithNoConnections(output: output.wrappedInstance)
  }
  
  @objc public func beginConfiguration() -> Void {
    return wrappedInstance.beginConfiguration()
  }
  
  @objc public func canAddConnection(connection: AVCaptureConnectionWrapper) -> Bool {
    return wrappedInstance.canAddConnection(connection: connection.wrappedInstance)
  }
  
  @objc public func canAddInput(input: AVCaptureInputWrapper) -> Bool {
    return wrappedInstance.canAddInput(input: input.wrappedInstance)
  }
  
  @objc public func canAddOutput(output: AVCaptureOutputWrapper) -> Bool {
    return wrappedInstance.canAddOutput(output: output.wrappedInstance)
  }
  
  @objc public func canSetSessionPreset(preset: AVCaptureSessionWrapper) -> Bool {
    return wrappedInstance.canSetSessionPreset(preset: preset.wrappedInstance)
  }
  
  @objc public func commitConfiguration() -> Void {
    return wrappedInstance.commitConfiguration()
  }
  
  @objc public func removeConnection(connection: AVCaptureConnectionWrapper) -> Void {
    return wrappedInstance.removeConnection(connection: connection.wrappedInstance)
  }
  
  @objc public func removeInput(input: AVCaptureInputWrapper) -> Void {
    return wrappedInstance.removeInput(input: input.wrappedInstance)
  }
  
  @objc public func removeOutput(output: AVCaptureOutputWrapper) -> Void {
    return wrappedInstance.removeOutput(output: output.wrappedInstance)
  }
  
  @objc public func startRunning() -> Void {
    return wrappedInstance.startRunning()
  }
  
  @objc public func stopRunning() -> Void {
    return wrappedInstance.stopRunning()
  }
}

@objc public class AVCaptureStillImageOutputWrapper: NSObject {
  var wrappedInstance: AVCaptureStillImageOutput
  
  @objc public var availableImageDataCodecTypes: AVVideoCodecTypeWrapper {
    get {
      AVVideoCodecTypeWrapper(wrappedInstance.availableImageDataCodecTypes)
    }
  }
  
  @objc public var isCapturingStillImage: Bool {
    get {
      wrappedInstance.isCapturingStillImage
    }
  }
  
  @objc public var isHighResolutionStillImageOutputEnabled: Bool {
    get {
      wrappedInstance.isHighResolutionStillImageOutputEnabled
    }
    set {
      wrappedInstance.isHighResolutionStillImageOutputEnabled = newValue
    }
  }
  
  @objc public var outputSettings: String {
    get {
      wrappedInstance.outputSettings
    }
    set {
      wrappedInstance.outputSettings = newValue
    }
  }
  
  init(_ wrappedInstance: AVCaptureStillImageOutput) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVCaptureStillImageOutput()
  }
}

@objc public class AVCaptureVideoDataOutputWrapper: NSObject {
  var wrappedInstance: AVCaptureVideoDataOutput
  
  @objc public var alwaysDiscardsLateVideoFrames: Bool {
    get {
      wrappedInstance.alwaysDiscardsLateVideoFrames
    }
    set {
      wrappedInstance.alwaysDiscardsLateVideoFrames = newValue
    }
  }
  
  @objc public var availableVideoCodecTypes: AVVideoCodecTypeWrapper {
    get {
      AVVideoCodecTypeWrapper(wrappedInstance.availableVideoCodecTypes)
    }
  }
  
  @objc public var videoSettings: String {
    get {
      wrappedInstance.videoSettings
    }
    set {
      wrappedInstance.videoSettings = newValue
    }
  }
  
  init(_ wrappedInstance: AVCaptureVideoDataOutput) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVCaptureVideoDataOutput()
  }
}

@objc public class AVCaptureVideoPreviewLayerWrapper: NSObject {
  var wrappedInstance: AVCaptureVideoPreviewLayer
  
  @objc public var connection: AVCaptureConnectionWrapper {
    get {
      AVCaptureConnectionWrapper(wrappedInstance.connection)
    }
  }
  
  @objc public var session: AVCaptureSessionWrapper {
    get {
      AVCaptureSessionWrapper(wrappedInstance.session)
    }
    set {
      wrappedInstance.session = newValue.wrappedInstance
    }
  }
  
  @objc public var videoGravity: AVLayerVideoGravityWrapper {
    get {
      AVLayerVideoGravityWrapper(wrappedInstance.videoGravity)
    }
    set {
      wrappedInstance.videoGravity = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVCaptureVideoPreviewLayer) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(session: AVCaptureSessionWrapper) {
    wrappedInstance = AVCaptureVideoPreviewLayer(session: session.wrappedInstance)
  }
  
  @objc init(sessionWithNoConnection session: AVCaptureSessionWrapper) {
    wrappedInstance = AVCaptureVideoPreviewLayer(sessionWithNoConnection: session.wrappedInstance)
  }
  
  @objc public func setSessionWithNoConnection(session: AVCaptureSessionWrapper) -> Void {
    return wrappedInstance.setSessionWithNoConnection(session: session.wrappedInstance)
  }
  
  @objc public func transformedMetadataObject(for metadataObject: AVMetadataObjectWrapper) -> AVMetadataObjectWrapper {
    let result = wrappedInstance.transformedMetadataObject(for: metadataObject.wrappedInstance)
    return AVMetadataObjectWrapper(result)
  }
}

@objc public class AVCompositionWrapper: NSObject {
  var wrappedInstance: AVComposition
  
  @objc public var urlAssetInitializationOptions: String {
    get {
      wrappedInstance.urlAssetInitializationOptions
    }
  }
  
  @objc public var allMediaSelections: AVMediaSelectionWrapper {
    get {
      AVMediaSelectionWrapper(wrappedInstance.allMediaSelections)
    }
  }
  
  @objc public var availableMediaCharacteristicsWithMediaSelectionOptions: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(wrappedInstance.availableMediaCharacteristicsWithMediaSelectionOptions)
    }
  }
  
  @objc public var availableMetadataFormats: AVMetadataFormatWrapper {
    get {
      AVMetadataFormatWrapper(wrappedInstance.availableMetadataFormats)
    }
  }
  
  @objc public var canContainFragments: Bool {
    get {
      wrappedInstance.canContainFragments
    }
  }
  
  @objc public var commonMetadata: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.commonMetadata)
    }
  }
  
  @objc public var isCompatibleWithAirPlayVideo: Bool {
    get {
      wrappedInstance.isCompatibleWithAirPlayVideo
    }
  }
  
  @objc public var isComposable: Bool {
    get {
      wrappedInstance.isComposable
    }
  }
  
  @objc public var containsFragments: Bool {
    get {
      wrappedInstance.containsFragments
    }
  }
  
  @objc public var creationDate: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.creationDate)
    }
  }
  
  @objc public var isExportable: Bool {
    get {
      wrappedInstance.isExportable
    }
  }
  
  @objc public var hasProtectedContent: Bool {
    get {
      wrappedInstance.hasProtectedContent
    }
  }
  
  @objc public var lyrics: String {
    get {
      wrappedInstance.lyrics
    }
  }
  
  @objc public var metadata: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.metadata)
    }
  }
  
  @objc public var isPlayable: Bool {
    get {
      wrappedInstance.isPlayable
    }
  }
  
  @objc public var preferredMediaSelection: AVMediaSelectionWrapper {
    get {
      AVMediaSelectionWrapper(wrappedInstance.preferredMediaSelection)
    }
  }
  
  @objc public var providesPreciseDurationAndTiming: Bool {
    get {
      wrappedInstance.providesPreciseDurationAndTiming
    }
  }
  
  @objc public var isReadable: Bool {
    get {
      wrappedInstance.isReadable
    }
  }
  
  @objc public var trackGroups: AVAssetTrackGroupWrapper {
    get {
      AVAssetTrackGroupWrapper(wrappedInstance.trackGroups)
    }
  }
  
  @objc public var tracks: AVCompositionTrackWrapper {
    get {
      AVCompositionTrackWrapper(wrappedInstance.tracks)
    }
  }
  
  init(_ wrappedInstance: AVComposition) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func mediaSelectionGroup(forMediaCharacteristic mediaCharacteristic: AVMediaCharacteristicWrapper) -> AVMediaSelectionGroupWrapper {
    let result = wrappedInstance.mediaSelectionGroup(forMediaCharacteristic: mediaCharacteristic.wrappedInstance)
    return AVMediaSelectionGroupWrapper(result)
  }
}

@objc public class AVCompositionTrackWrapper: NSObject {
  var wrappedInstance: AVCompositionTrack
  
  @objc public var availableMetadataFormats: AVMetadataFormatWrapper {
    get {
      AVMetadataFormatWrapper(wrappedInstance.availableMetadataFormats)
    }
  }
  
  @objc public var availableTrackAssociationTypes: AVAssetTrackWrapper {
    get {
      AVAssetTrackWrapper(wrappedInstance.availableTrackAssociationTypes)
    }
  }
  
  @objc public var canProvideSampleCursors: Bool {
    get {
      wrappedInstance.canProvideSampleCursors
    }
  }
  
  @objc public var commonMetadata: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.commonMetadata)
    }
  }
  
  @objc public var isDecodable: Bool {
    get {
      wrappedInstance.isDecodable
    }
  }
  
  @objc public var isEnabled: Bool {
    get {
      wrappedInstance.isEnabled
    }
  }
  
  @objc public var extendedLanguageTag: String {
    get {
      wrappedInstance.extendedLanguageTag
    }
  }
  
  @objc public var formatDescriptionReplacements: AVCompositionTrackFormatDescriptionReplacementWrapper {
    get {
      AVCompositionTrackFormatDescriptionReplacementWrapper(wrappedInstance.formatDescriptionReplacements)
    }
  }
  
  @objc public var hasAudioSampleDependencies: Bool {
    get {
      wrappedInstance.hasAudioSampleDependencies
    }
  }
  
  @objc public var languageCode: String {
    get {
      wrappedInstance.languageCode
    }
  }
  
  @objc public var metadata: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.metadata)
    }
  }
  
  @objc public var isPlayable: Bool {
    get {
      wrappedInstance.isPlayable
    }
  }
  
  @objc public var requiresFrameReordering: Bool {
    get {
      wrappedInstance.requiresFrameReordering
    }
  }
  
  @objc public var segments: AVCompositionTrackSegmentWrapper {
    get {
      AVCompositionTrackSegmentWrapper(wrappedInstance.segments)
    }
  }
  
  @objc public var isSelfContained: Bool {
    get {
      wrappedInstance.isSelfContained
    }
  }
  
  init(_ wrappedInstance: AVCompositionTrack) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func hasMediaCharacteristic(mediaCharacteristic: AVMediaCharacteristicWrapper) -> Bool {
    return wrappedInstance.hasMediaCharacteristic(mediaCharacteristic: mediaCharacteristic.wrappedInstance)
  }
}

@objc public class AVCompositionTrackFormatDescriptionReplacementWrapper: NSObject {
  var wrappedInstance: AVCompositionTrackFormatDescriptionReplacement
  
  init(_ wrappedInstance: AVCompositionTrackFormatDescriptionReplacement) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVCompositionTrackSegmentWrapper: NSObject {
  var wrappedInstance: AVCompositionTrackSegment
  
  @objc public var isEmpty: Bool {
    get {
      wrappedInstance.isEmpty
    }
  }
  
  init(_ wrappedInstance: AVCompositionTrackSegment) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVContentKeyWrapper: NSObject {
  var wrappedInstance: AVContentKey
  
  @objc public var contentKeySpecifier: AVContentKeySpecifierWrapper {
    get {
      AVContentKeySpecifierWrapper(wrappedInstance.contentKeySpecifier)
    }
  }
  
  init(_ wrappedInstance: AVContentKey) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVContentKeyRequestWrapper: NSObject {
  var wrappedInstance: AVContentKeyRequest
  
  @objc public var canProvidePersistableContentKey: Bool {
    get {
      wrappedInstance.canProvidePersistableContentKey
    }
  }
  
  @objc public var contentKey: AVContentKeyWrapper {
    get {
      AVContentKeyWrapper(wrappedInstance.contentKey)
    }
  }
  
  @objc public var contentKeySpecifier: AVContentKeySpecifierWrapper {
    get {
      AVContentKeySpecifierWrapper(wrappedInstance.contentKeySpecifier)
    }
  }
  
  @objc public var options: String {
    get {
      wrappedInstance.options
    }
  }
  
  @objc public var renewsExpiringResponseData: Bool {
    get {
      wrappedInstance.renewsExpiringResponseData
    }
  }
  
  @objc public var status: AVContentKeyRequestWrapper {
    get {
      AVContentKeyRequestWrapper(wrappedInstance.status)
    }
  }
  
  init(_ wrappedInstance: AVContentKeyRequest) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func processContentKeyResponse(keyResponse: AVContentKeyResponseWrapper) -> Void {
    return wrappedInstance.processContentKeyResponse(keyResponse: keyResponse.wrappedInstance)
  }
  
  @objc public func respondByRequestingPersistableContentKeyRequest() {
    wrappedInstance.respondByRequestingPersistableContentKeyRequest()
  }
}

@objc public class AVContentKeyResponseWrapper: NSObject {
  var wrappedInstance: AVContentKeyResponse
  
  init(_ wrappedInstance: AVContentKeyResponse) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVContentKeySessionWrapper: NSObject {
  var wrappedInstance: AVContentKeySession
  
  @objc public var keySystem: AVContentKeySystemWrapper {
    get {
      AVContentKeySystemWrapper(wrappedInstance.keySystem)
    }
  }
  
  init(_ wrappedInstance: AVContentKeySession) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(keySystem: AVContentKeySystemWrapper) {
    wrappedInstance = AVContentKeySession(keySystem: keySystem.wrappedInstance)
  }
  
  @objc public func expire() -> Void {
    return wrappedInstance.expire()
  }
  
  @objc public func renewExpiringResponseData(for contentKeyRequest: AVContentKeyRequestWrapper) -> Void {
    return wrappedInstance.renewExpiringResponseData(for: contentKeyRequest.wrappedInstance)
  }
}

@objc public class AVContentKeySpecifierWrapper: NSObject {
  var wrappedInstance: AVContentKeySpecifier
  
  @objc public var keySystem: AVContentKeySystemWrapper {
    get {
      AVContentKeySystemWrapper(wrappedInstance.keySystem)
    }
  }
  
  @objc public var options: String {
    get {
      wrappedInstance.options
    }
  }
  
  init(_ wrappedInstance: AVContentKeySpecifier) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVCoordinatedPlaybackParticipantWrapper: NSObject {
  var wrappedInstance: AVCoordinatedPlaybackParticipant
  
  @objc public var isReadyToPlay: Bool {
    get {
      wrappedInstance.isReadyToPlay
    }
  }
  
  @objc public var suspensionReasons: AVCoordinatedPlaybackSuspensionWrapper {
    get {
      AVCoordinatedPlaybackSuspensionWrapper(wrappedInstance.suspensionReasons)
    }
  }
  
  init(_ wrappedInstance: AVCoordinatedPlaybackParticipant) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVCoordinatedPlaybackSuspensionWrapper: NSObject {
  var wrappedInstance: AVCoordinatedPlaybackSuspension
  
  @objc public var reason: AVCoordinatedPlaybackSuspensionWrapper {
    get {
      AVCoordinatedPlaybackSuspensionWrapper(wrappedInstance.reason)
    }
  }
  
  init(_ wrappedInstance: AVCoordinatedPlaybackSuspension) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func end() -> Void {
    return wrappedInstance.end()
  }
}

@objc public class AVDateRangeMetadataGroupWrapper: NSObject {
  var wrappedInstance: AVDateRangeMetadataGroup
  
  @objc public var items: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.items)
    }
  }
  
  init(_ wrappedInstance: AVDateRangeMetadataGroup) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVDelegatingPlaybackCoordinatorWrapper: NSObject {
  var wrappedInstance: AVDelegatingPlaybackCoordinator
  
  @objc public var currentItemIdentifier: String {
    get {
      wrappedInstance.currentItemIdentifier
    }
  }
  
  init(_ wrappedInstance: AVDelegatingPlaybackCoordinator) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func reapplyCurrentItemStateToPlaybackControlDelegate() -> Void {
    return wrappedInstance.reapplyCurrentItemStateToPlaybackControlDelegate()
  }
}

@objc public class AVDelegatingPlaybackCoordinatorBufferingCommandWrapper: NSObject {
  var wrappedInstance: AVDelegatingPlaybackCoordinatorBufferingCommand
  
  init(_ wrappedInstance: AVDelegatingPlaybackCoordinatorBufferingCommand) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVDelegatingPlaybackCoordinatorPauseCommandWrapper: NSObject {
  var wrappedInstance: AVDelegatingPlaybackCoordinatorPauseCommand
  
  @objc public var shouldBufferInAnticipationOfPlayback: Bool {
    get {
      wrappedInstance.shouldBufferInAnticipationOfPlayback
    }
  }
  
  init(_ wrappedInstance: AVDelegatingPlaybackCoordinatorPauseCommand) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVDelegatingPlaybackCoordinatorPlayCommandWrapper: NSObject {
  var wrappedInstance: AVDelegatingPlaybackCoordinatorPlayCommand
  
  init(_ wrappedInstance: AVDelegatingPlaybackCoordinatorPlayCommand) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVDelegatingPlaybackCoordinatorPlaybackControlCommandWrapper: NSObject {
  var wrappedInstance: AVDelegatingPlaybackCoordinatorPlaybackControlCommand
  
  @objc public var expectedCurrentItemIdentifier: String {
    get {
      wrappedInstance.expectedCurrentItemIdentifier
    }
  }
  
  @objc public var originator: AVCoordinatedPlaybackParticipantWrapper {
    get {
      AVCoordinatedPlaybackParticipantWrapper(wrappedInstance.originator)
    }
  }
  
  init(_ wrappedInstance: AVDelegatingPlaybackCoordinatorPlaybackControlCommand) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVDelegatingPlaybackCoordinatorSeekCommandWrapper: NSObject {
  var wrappedInstance: AVDelegatingPlaybackCoordinatorSeekCommand
  
  @objc public var shouldBufferInAnticipationOfPlayback: Bool {
    get {
      wrappedInstance.shouldBufferInAnticipationOfPlayback
    }
  }
  
  init(_ wrappedInstance: AVDelegatingPlaybackCoordinatorSeekCommand) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVDepthDataWrapper: NSObject {
  var wrappedInstance: AVDepthData
  
  @objc public var cameraCalibrationData: AVCameraCalibrationDataWrapper {
    get {
      AVCameraCalibrationDataWrapper(wrappedInstance.cameraCalibrationData)
    }
  }
  
  @objc public var depthDataAccuracy: AVDepthDataWrapper {
    get {
      AVDepthDataWrapper(wrappedInstance.depthDataAccuracy)
    }
  }
  
  @objc public var isDepthDataFiltered: Bool {
    get {
      wrappedInstance.isDepthDataFiltered
    }
  }
  
  @objc public var depthDataQuality: AVDepthDataWrapper {
    get {
      AVDepthDataWrapper(wrappedInstance.depthDataQuality)
    }
  }
  
  init(_ wrappedInstance: AVDepthData) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVExternalStorageDeviceWrapper: NSObject {
  var wrappedInstance: AVExternalStorageDevice
  
  @objc public var isConnected: Bool {
    get {
      wrappedInstance.isConnected
    }
  }
  
  @objc public var displayName: String {
    get {
      wrappedInstance.displayName
    }
  }
  
  @objc public var freeSize: Int {
    get {
      wrappedInstance.freeSize
    }
  }
  
  @objc public var isNotRecommendedForCaptureUse: Bool {
    get {
      wrappedInstance.isNotRecommendedForCaptureUse
    }
  }
  
  @objc public var totalSize: Int {
    get {
      wrappedInstance.totalSize
    }
  }
  
  init(_ wrappedInstance: AVExternalStorageDevice) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc static public func requestAccess(completionHandler handler: Bool) -> Void {
    return AVExternalStorageDevice.requestAccess(completionHandler: handler)
  }
  
  @objc static public func requestAccess(completionHandler handler: Bool) -> Void {
    return AVExternalStorageDevice.requestAccess(completionHandler: handler)
  }
}

@objc public class AVExternalStorageDeviceDiscoverySessionWrapper: NSObject {
  var wrappedInstance: AVExternalStorageDeviceDiscoverySession
  
  @objc static public var shared: AVExternalStorageDeviceDiscoverySessionWrapper {
    get {
      AVExternalStorageDeviceDiscoverySessionWrapper(AVExternalStorageDeviceDiscoverySession.shared)
    }
  }
  
  @objc static public var isSupported: Bool {
    get {
      AVExternalStorageDeviceDiscoverySession.isSupported
    }
  }
  
  @objc public var externalStorageDevices: AVExternalStorageDeviceWrapper {
    get {
      AVExternalStorageDeviceWrapper(wrappedInstance.externalStorageDevices)
    }
  }
  
  init(_ wrappedInstance: AVExternalStorageDeviceDiscoverySession) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVFragmentedAssetWrapper: NSObject {
  var wrappedInstance: AVFragmentedAsset
  
  @objc public var tracks: AVFragmentedAssetTrackWrapper {
    get {
      AVFragmentedAssetTrackWrapper(wrappedInstance.tracks)
    }
  }
  
  init(_ wrappedInstance: AVFragmentedAsset) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func loadTracks(withMediaType mediaType: AVMediaTypeWrapper, completionHandler: AVFragmentedAssetTrackWrapper) -> Void {
    return wrappedInstance.loadTracks(withMediaType: mediaType.wrappedInstance, completionHandler: completionHandler.wrappedInstance)
  }
  
  @objc public func loadTracks(withMediaType mediaType: AVMediaTypeWrapper, completionHandler: AVFragmentedAssetTrackWrapper) -> Void {
    return wrappedInstance.loadTracks(withMediaType: mediaType.wrappedInstance, completionHandler: completionHandler.wrappedInstance)
  }
}

@objc public class AVFragmentedAssetMinderWrapper: NSObject {
  var wrappedInstance: AVFragmentedAssetMinder
  
  @objc public var assets: AVAssetWrapper {
    get {
      AVAssetWrapper(wrappedInstance.assets)
    }
  }
  
  init(_ wrappedInstance: AVFragmentedAssetMinder) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func addFragmentedAsset(asset: AVAssetWrapper) -> Void {
    return wrappedInstance.addFragmentedAsset(asset: asset.wrappedInstance)
  }
  
  @objc public func removeFragmentedAsset(asset: AVAssetWrapper) -> Void {
    return wrappedInstance.removeFragmentedAsset(asset: asset.wrappedInstance)
  }
}

@objc public class AVFragmentedAssetTrackWrapper: NSObject {
  var wrappedInstance: AVFragmentedAssetTrack
  
  init(_ wrappedInstance: AVFragmentedAssetTrack) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVFragmentedMovieWrapper: NSObject {
  var wrappedInstance: AVFragmentedMovie
  
  @objc public var tracks: AVFragmentedMovieTrackWrapper {
    get {
      AVFragmentedMovieTrackWrapper(wrappedInstance.tracks)
    }
  }
  
  init(_ wrappedInstance: AVFragmentedMovie) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func loadTracks(withMediaCharacteristic mediaCharacteristic: AVMediaCharacteristicWrapper, completionHandler: AVFragmentedMovieTrackWrapper) -> Void {
    return wrappedInstance.loadTracks(withMediaCharacteristic: mediaCharacteristic.wrappedInstance, completionHandler: completionHandler.wrappedInstance)
  }
  
  @objc public func loadTracks(withMediaCharacteristic mediaCharacteristic: AVMediaCharacteristicWrapper, completionHandler: AVFragmentedMovieTrackWrapper) -> Void {
    return wrappedInstance.loadTracks(withMediaCharacteristic: mediaCharacteristic.wrappedInstance, completionHandler: completionHandler.wrappedInstance)
  }
}

@objc public class AVFragmentedMovieMinderWrapper: NSObject {
  var wrappedInstance: AVFragmentedMovieMinder
  
  @objc public var movies: AVFragmentedMovieWrapper {
    get {
      AVFragmentedMovieWrapper(wrappedInstance.movies)
    }
  }
  
  init(_ wrappedInstance: AVFragmentedMovieMinder) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func add(movie: AVFragmentedMovieWrapper) -> Void {
    return wrappedInstance.add(movie: movie.wrappedInstance)
  }
  
  @objc public func remove(movie: AVFragmentedMovieWrapper) -> Void {
    return wrappedInstance.remove(movie: movie.wrappedInstance)
  }
}

@objc public class AVFragmentedMovieTrackWrapper: NSObject {
  var wrappedInstance: AVFragmentedMovieTrack
  
  init(_ wrappedInstance: AVFragmentedMovieTrack) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVFrameRateRangeWrapper: NSObject {
  var wrappedInstance: AVFrameRateRange
  
  init(_ wrappedInstance: AVFrameRateRange) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMediaDataStorageWrapper: NSObject {
  var wrappedInstance: AVMediaDataStorage
  
  init(_ wrappedInstance: AVMediaDataStorage) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMediaSelectionWrapper: NSObject {
  var wrappedInstance: AVMediaSelection
  
  @objc public var asset: AVAssetWrapper {
    get {
      AVAssetWrapper(wrappedInstance.asset)
    }
  }
  
  init(_ wrappedInstance: AVMediaSelection) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func mediaSelectionCriteriaCanBeAppliedAutomatically(to mediaSelectionGroup: AVMediaSelectionGroupWrapper) -> Bool {
    return wrappedInstance.mediaSelectionCriteriaCanBeAppliedAutomatically(to: mediaSelectionGroup.wrappedInstance)
  }
  
  @objc public func selectedMediaOption(in mediaSelectionGroup: AVMediaSelectionGroupWrapper) -> AVMediaSelectionOptionWrapper {
    let result = wrappedInstance.selectedMediaOption(in: mediaSelectionGroup.wrappedInstance)
    return AVMediaSelectionOptionWrapper(result)
  }
}

@objc public class AVMediaSelectionGroupWrapper: NSObject {
  var wrappedInstance: AVMediaSelectionGroup
  
  @objc public var allowsEmptySelection: Bool {
    get {
      wrappedInstance.allowsEmptySelection
    }
  }
  
  @objc public var defaultOption: AVMediaSelectionOptionWrapper {
    get {
      AVMediaSelectionOptionWrapper(wrappedInstance.defaultOption)
    }
  }
  
  @objc public var options: AVMediaSelectionOptionWrapper {
    get {
      AVMediaSelectionOptionWrapper(wrappedInstance.options)
    }
  }
  
  init(_ wrappedInstance: AVMediaSelectionGroup) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMediaSelectionOptionWrapper: NSObject {
  var wrappedInstance: AVMediaSelectionOption
  
  @objc public var availableMetadataFormats: String {
    get {
      wrappedInstance.availableMetadataFormats
    }
  }
  
  @objc public var commonMetadata: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.commonMetadata)
    }
  }
  
  @objc public var displayName: String {
    get {
      wrappedInstance.displayName
    }
  }
  
  @objc public var extendedLanguageTag: String {
    get {
      wrappedInstance.extendedLanguageTag
    }
  }
  
  @objc public var mediaType: AVMediaTypeWrapper {
    get {
      AVMediaTypeWrapper(wrappedInstance.mediaType)
    }
  }
  
  @objc public var isPlayable: Bool {
    get {
      wrappedInstance.isPlayable
    }
  }
  
  init(_ wrappedInstance: AVMediaSelectionOption) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func associatedMediaSelectionOption(in mediaSelectionGroup: AVMediaSelectionGroupWrapper) -> AVMediaSelectionOptionWrapper {
    let result = wrappedInstance.associatedMediaSelectionOption(in: mediaSelectionGroup.wrappedInstance)
    return AVMediaSelectionOptionWrapper(result)
  }
  
  @objc public func hasMediaCharacteristic(mediaCharacteristic: AVMediaCharacteristicWrapper) -> Bool {
    return wrappedInstance.hasMediaCharacteristic(mediaCharacteristic: mediaCharacteristic.wrappedInstance)
  }
}

@objc public class AVMetadataBodyObjectWrapper: NSObject {
  var wrappedInstance: AVMetadataBodyObject
  
  @objc public var bodyID: Int {
    get {
      wrappedInstance.bodyID
    }
  }
  
  init(_ wrappedInstance: AVMetadataBodyObject) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMetadataCatBodyObjectWrapper: NSObject {
  var wrappedInstance: AVMetadataCatBodyObject
  
  init(_ wrappedInstance: AVMetadataCatBodyObject) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMetadataDogBodyObjectWrapper: NSObject {
  var wrappedInstance: AVMetadataDogBodyObject
  
  init(_ wrappedInstance: AVMetadataDogBodyObject) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMetadataFaceObjectWrapper: NSObject {
  var wrappedInstance: AVMetadataFaceObject
  
  @objc public var faceID: Int {
    get {
      wrappedInstance.faceID
    }
  }
  
  @objc public var hasRollAngle: Bool {
    get {
      wrappedInstance.hasRollAngle
    }
  }
  
  @objc public var hasYawAngle: Bool {
    get {
      wrappedInstance.hasYawAngle
    }
  }
  
  init(_ wrappedInstance: AVMetadataFaceObject) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMetadataGroupWrapper: NSObject {
  var wrappedInstance: AVMetadataGroup
  
  @objc public var classifyingLabel: String {
    get {
      wrappedInstance.classifyingLabel
    }
  }
  
  @objc public var items: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.items)
    }
  }
  
  @objc public var uniqueID: String {
    get {
      wrappedInstance.uniqueID
    }
  }
  
  init(_ wrappedInstance: AVMetadataGroup) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMetadataHumanBodyObjectWrapper: NSObject {
  var wrappedInstance: AVMetadataHumanBodyObject
  
  init(_ wrappedInstance: AVMetadataHumanBodyObject) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMetadataHumanFullBodyObjectWrapper: NSObject {
  var wrappedInstance: AVMetadataHumanFullBodyObject
  
  init(_ wrappedInstance: AVMetadataHumanFullBodyObject) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMetadataItemWrapper: NSObject {
  var wrappedInstance: AVMetadataItem
  
  @objc public var commonKey: AVMetadataKeyWrapper {
    get {
      AVMetadataKeyWrapper(wrappedInstance.commonKey)
    }
  }
  
  @objc public var dataType: String {
    get {
      wrappedInstance.dataType
    }
  }
  
  @objc public var extendedLanguageTag: String {
    get {
      wrappedInstance.extendedLanguageTag
    }
  }
  
  @objc public var extraAttributes: AVMetadataExtraAttributeKeyWrapper {
    get {
      AVMetadataExtraAttributeKeyWrapper(wrappedInstance.extraAttributes)
    }
  }
  
  @objc public var identifier: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(wrappedInstance.identifier)
    }
  }
  
  @objc public var keySpace: AVMetadataKeySpaceWrapper {
    get {
      AVMetadataKeySpaceWrapper(wrappedInstance.keySpace)
    }
  }
  
  @objc public var stringValue: String {
    get {
      wrappedInstance.stringValue
    }
  }
  
  init(_ wrappedInstance: AVMetadataItem) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc static public func keySpace(forIdentifier identifier: AVMetadataIdentifierWrapper) -> AVMetadataKeySpaceWrapper {
    let result = AVMetadataItem.keySpace(forIdentifier: identifier.wrappedInstance)
    return AVMetadataKeySpaceWrapper(result)
  }
  
  @objc public func status(of property: AVAsyncPropertyWrapper) -> AVAsyncPropertyWrapper {
    let result = wrappedInstance.status(of: property.wrappedInstance)
    return AVAsyncPropertyWrapper(result)
  }
}

@objc public class AVMetadataItemFilterWrapper: NSObject {
  var wrappedInstance: AVMetadataItemFilter
  
  init(_ wrappedInstance: AVMetadataItemFilter) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc static public func forSharing() -> AVMetadataItemFilterWrapper {
    let result = AVMetadataItemFilter.forSharing()
    return AVMetadataItemFilterWrapper(result)
  }
}

@objc public class AVMetadataItemValueRequestWrapper: NSObject {
  var wrappedInstance: AVMetadataItemValueRequest
  
  @objc public var metadataItem: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.metadataItem)
    }
  }
  
  init(_ wrappedInstance: AVMetadataItemValueRequest) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMetadataMachineReadableCodeObjectWrapper: NSObject {
  var wrappedInstance: AVMetadataMachineReadableCodeObject
  
  @objc public var stringValue: String {
    get {
      wrappedInstance.stringValue
    }
  }
  
  init(_ wrappedInstance: AVMetadataMachineReadableCodeObject) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMetadataObjectWrapper: NSObject {
  var wrappedInstance: AVMetadataObject
  
  @objc public var type: AVMetadataObjectWrapper {
    get {
      AVMetadataObjectWrapper(wrappedInstance.type)
    }
  }
  
  init(_ wrappedInstance: AVMetadataObject) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMetadataSalientObjectWrapper: NSObject {
  var wrappedInstance: AVMetadataSalientObject
  
  @objc public var objectID: Int {
    get {
      wrappedInstance.objectID
    }
  }
  
  init(_ wrappedInstance: AVMetadataSalientObject) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMovieWrapper: NSObject {
  var wrappedInstance: AVMovie
  
  @objc public var canContainMovieFragments: Bool {
    get {
      wrappedInstance.canContainMovieFragments
    }
  }
  
  @objc public var containsMovieFragments: Bool {
    get {
      wrappedInstance.containsMovieFragments
    }
  }
  
  @objc public var defaultMediaDataStorage: AVMediaDataStorageWrapper {
    get {
      AVMediaDataStorageWrapper(wrappedInstance.defaultMediaDataStorage)
    }
  }
  
  @objc public var tracks: AVMovieTrackWrapper {
    get {
      AVMovieTrackWrapper(wrappedInstance.tracks)
    }
  }
  
  init(_ wrappedInstance: AVMovie) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func `is`(compatibleWithFileType fileType: AVFileTypeWrapper) -> Bool {
    return wrappedInstance.`is`(compatibleWithFileType: fileType.wrappedInstance)
  }
  
  @objc public func loadTracks(withMediaCharacteristic mediaCharacteristic: AVMediaCharacteristicWrapper, completionHandler: AVMovieTrackWrapper) -> Void {
    return wrappedInstance.loadTracks(withMediaCharacteristic: mediaCharacteristic.wrappedInstance, completionHandler: completionHandler.wrappedInstance)
  }
  
  @objc public func loadTracks(withMediaCharacteristic mediaCharacteristic: AVMediaCharacteristicWrapper, completionHandler: AVMovieTrackWrapper) -> Void {
    return wrappedInstance.loadTracks(withMediaCharacteristic: mediaCharacteristic.wrappedInstance, completionHandler: completionHandler.wrappedInstance)
  }
  
  @objc public func loadTracks(withMediaType mediaType: AVMediaTypeWrapper, completionHandler: AVMovieTrackWrapper) -> Void {
    return wrappedInstance.loadTracks(withMediaType: mediaType.wrappedInstance, completionHandler: completionHandler.wrappedInstance)
  }
  
  @objc public func loadTracks(withMediaType mediaType: AVMediaTypeWrapper, completionHandler: AVMovieTrackWrapper) -> Void {
    return wrappedInstance.loadTracks(withMediaType: mediaType.wrappedInstance, completionHandler: completionHandler.wrappedInstance)
  }
}

@objc public class AVMovieTrackWrapper: NSObject {
  var wrappedInstance: AVMovieTrack
  
  @objc public var alternateGroupID: Int {
    get {
      wrappedInstance.alternateGroupID
    }
  }
  
  @objc public var mediaDataStorage: AVMediaDataStorageWrapper {
    get {
      AVMediaDataStorageWrapper(wrappedInstance.mediaDataStorage)
    }
  }
  
  init(_ wrappedInstance: AVMovieTrack) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMutableAssetDownloadStorageManagementPolicyWrapper: NSObject {
  var wrappedInstance: AVMutableAssetDownloadStorageManagementPolicy
  
  @objc public var priority: AVAssetDownloadedAssetEvictionPriorityWrapper {
    get {
      AVAssetDownloadedAssetEvictionPriorityWrapper(wrappedInstance.priority)
    }
    set {
      wrappedInstance.priority = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVMutableAssetDownloadStorageManagementPolicy) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMutableAudioMixWrapper: NSObject {
  var wrappedInstance: AVMutableAudioMix
  
  @objc public var inputParameters: AVAudioMixInputParametersWrapper {
    get {
      AVAudioMixInputParametersWrapper(wrappedInstance.inputParameters)
    }
    set {
      wrappedInstance.inputParameters = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVMutableAudioMix) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMutableAudioMixInputParametersWrapper: NSObject {
  var wrappedInstance: AVMutableAudioMixInputParameters
  
  @objc public var audioTimePitchAlgorithm: AVAudioTimePitchAlgorithmWrapper {
    get {
      AVAudioTimePitchAlgorithmWrapper(wrappedInstance.audioTimePitchAlgorithm)
    }
    set {
      wrappedInstance.audioTimePitchAlgorithm = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVMutableAudioMixInputParameters) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(track: AVAssetTrackWrapper) {
    wrappedInstance = AVMutableAudioMixInputParameters(track: track.wrappedInstance)
  }
}

@objc public class AVMutableCaptionWrapper: NSObject {
  var wrappedInstance: AVMutableCaption
  
  @objc public var animation: AVCaptionWrapper {
    get {
      AVCaptionWrapper(wrappedInstance.animation)
    }
    set {
      wrappedInstance.animation = newValue.wrappedInstance
    }
  }
  
  @objc public var region: AVCaptionRegionWrapper {
    get {
      AVCaptionRegionWrapper(wrappedInstance.region)
    }
    set {
      wrappedInstance.region = newValue.wrappedInstance
    }
  }
  
  @objc public var text: String {
    get {
      wrappedInstance.text
    }
    set {
      wrappedInstance.text = newValue
    }
  }
  
  @objc public var textAlignment: AVCaptionWrapper {
    get {
      AVCaptionWrapper(wrappedInstance.textAlignment)
    }
    set {
      wrappedInstance.textAlignment = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVMutableCaption) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMutableCaptionRegionWrapper: NSObject {
  var wrappedInstance: AVMutableCaptionRegion
  
  @objc public var displayAlignment: AVCaptionRegionWrapper {
    get {
      AVCaptionRegionWrapper(wrappedInstance.displayAlignment)
    }
    set {
      wrappedInstance.displayAlignment = newValue.wrappedInstance
    }
  }
  
  @objc public var origin: AVCaptionPointWrapper {
    get {
      AVCaptionPointWrapper(wrappedInstance.origin)
    }
    set {
      wrappedInstance.origin = newValue.wrappedInstance
    }
  }
  
  @objc public var scroll: AVCaptionRegionWrapper {
    get {
      AVCaptionRegionWrapper(wrappedInstance.scroll)
    }
    set {
      wrappedInstance.scroll = newValue.wrappedInstance
    }
  }
  
  @objc public var size: AVCaptionSizeWrapper {
    get {
      AVCaptionSizeWrapper(wrappedInstance.size)
    }
    set {
      wrappedInstance.size = newValue.wrappedInstance
    }
  }
  
  @objc public var writingMode: AVCaptionRegionWrapper {
    get {
      AVCaptionRegionWrapper(wrappedInstance.writingMode)
    }
    set {
      wrappedInstance.writingMode = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVMutableCaptionRegion) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc override init() {
    wrappedInstance = AVMutableCaptionRegion()
  }
  
  @objc init(identifier: String) {
    wrappedInstance = AVMutableCaptionRegion(identifier: identifier)
  }
}

@objc public class AVMutableCompositionWrapper: NSObject {
  var wrappedInstance: AVMutableComposition
  
  @objc public var tracks: AVMutableCompositionTrackWrapper {
    get {
      AVMutableCompositionTrackWrapper(wrappedInstance.tracks)
    }
  }
  
  init(_ wrappedInstance: AVMutableComposition) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(urlAssetInitializationOptions URLAssetInitializationOptions: String) {
    wrappedInstance = AVMutableComposition(urlAssetInitializationOptions: URLAssetInitializationOptions)
  }
  
  @objc init(URLAssetInitializationOptions: String) {
    wrappedInstance = AVMutableComposition(URLAssetInitializationOptions: URLAssetInitializationOptions)
  }
  
  @objc public func loadTracks(withMediaType mediaType: AVMediaTypeWrapper, completionHandler: AVMutableCompositionTrackWrapper) -> Void {
    return wrappedInstance.loadTracks(withMediaType: mediaType.wrappedInstance, completionHandler: completionHandler.wrappedInstance)
  }
  
  @objc public func loadTracks(withMediaType mediaType: AVMediaTypeWrapper, completionHandler: AVMutableCompositionTrackWrapper) -> Void {
    return wrappedInstance.loadTracks(withMediaType: mediaType.wrappedInstance, completionHandler: completionHandler.wrappedInstance)
  }
  
  @objc public func mutableTrack(compatibleWith track: AVAssetTrackWrapper) -> AVMutableCompositionTrackWrapper {
    let result = wrappedInstance.mutableTrack(compatibleWith: track.wrappedInstance)
    return AVMutableCompositionTrackWrapper(result)
  }
  
  @objc public func removeTrack(track: AVCompositionTrackWrapper) -> Void {
    return wrappedInstance.removeTrack(track: track.wrappedInstance)
  }
}

@objc public class AVMutableCompositionTrackWrapper: NSObject {
  var wrappedInstance: AVMutableCompositionTrack
  
  @objc public var isEnabled: Bool {
    get {
      wrappedInstance.isEnabled
    }
    set {
      wrappedInstance.isEnabled = newValue
    }
  }
  
  @objc public var extendedLanguageTag: String {
    get {
      wrappedInstance.extendedLanguageTag
    }
    set {
      wrappedInstance.extendedLanguageTag = newValue
    }
  }
  
  @objc public var languageCode: String {
    get {
      wrappedInstance.languageCode
    }
    set {
      wrappedInstance.languageCode = newValue
    }
  }
  
  @objc public var segments: AVCompositionTrackSegmentWrapper {
    get {
      AVCompositionTrackSegmentWrapper(wrappedInstance.segments)
    }
    set {
      wrappedInstance.segments = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVMutableCompositionTrack) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func addTrackAssociation(to compositionTrack: AVCompositionTrackWrapper, type trackAssociationType: AVAssetTrackWrapper) -> Void {
    return wrappedInstance.addTrackAssociation(to: compositionTrack.wrappedInstance, type: trackAssociationType.wrappedInstance)
  }
  
  @objc public func removeTrackAssociation(to compositionTrack: AVCompositionTrackWrapper, type trackAssociationType: AVAssetTrackWrapper) -> Void {
    return wrappedInstance.removeTrackAssociation(to: compositionTrack.wrappedInstance, type: trackAssociationType.wrappedInstance)
  }
  
  @objc public func validateSegments(trackSegments: AVCompositionTrackSegmentWrapper) {
    wrappedInstance.validateSegments(trackSegments: trackSegments.wrappedInstance)
  }
}

@objc public class AVMutableDateRangeMetadataGroupWrapper: NSObject {
  var wrappedInstance: AVMutableDateRangeMetadataGroup
  
  @objc public var items: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.items)
    }
    set {
      wrappedInstance.items = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVMutableDateRangeMetadataGroup) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMutableMediaSelectionWrapper: NSObject {
  var wrappedInstance: AVMutableMediaSelection
  
  init(_ wrappedInstance: AVMutableMediaSelection) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func select(mediaSelectionOption: AVMediaSelectionOptionWrapper, in mediaSelectionGroup: AVMediaSelectionGroupWrapper) -> Void {
    return wrappedInstance.select(mediaSelectionOption: mediaSelectionOption.wrappedInstance, in: mediaSelectionGroup.wrappedInstance)
  }
}

@objc public class AVMutableMetadataItemWrapper: NSObject {
  var wrappedInstance: AVMutableMetadataItem
  
  @objc public var dataType: String {
    get {
      wrappedInstance.dataType
    }
    set {
      wrappedInstance.dataType = newValue
    }
  }
  
  @objc public var extendedLanguageTag: String {
    get {
      wrappedInstance.extendedLanguageTag
    }
    set {
      wrappedInstance.extendedLanguageTag = newValue
    }
  }
  
  @objc public var extraAttributes: AVMetadataExtraAttributeKeyWrapper {
    get {
      AVMetadataExtraAttributeKeyWrapper(wrappedInstance.extraAttributes)
    }
    set {
      wrappedInstance.extraAttributes = newValue.wrappedInstance
    }
  }
  
  @objc public var identifier: AVMetadataIdentifierWrapper {
    get {
      AVMetadataIdentifierWrapper(wrappedInstance.identifier)
    }
    set {
      wrappedInstance.identifier = newValue.wrappedInstance
    }
  }
  
  @objc public var keySpace: AVMetadataKeySpaceWrapper {
    get {
      AVMetadataKeySpaceWrapper(wrappedInstance.keySpace)
    }
    set {
      wrappedInstance.keySpace = newValue.wrappedInstance
    }
  }
  
  @objc public var stringValue: String {
    get {
      wrappedInstance.stringValue
    }
  }
  
  init(_ wrappedInstance: AVMutableMetadataItem) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMutableMovieWrapper: NSObject {
  var wrappedInstance: AVMutableMovie
  
  @objc public var allMediaSelections: AVMediaSelectionWrapper {
    get {
      AVMediaSelectionWrapper(wrappedInstance.allMediaSelections)
    }
  }
  
  @objc public var availableMediaCharacteristicsWithMediaSelectionOptions: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(wrappedInstance.availableMediaCharacteristicsWithMediaSelectionOptions)
    }
  }
  
  @objc public var availableMetadataFormats: AVMetadataFormatWrapper {
    get {
      AVMetadataFormatWrapper(wrappedInstance.availableMetadataFormats)
    }
  }
  
  @objc public var canContainFragments: Bool {
    get {
      wrappedInstance.canContainFragments
    }
  }
  
  @objc public var commonMetadata: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.commonMetadata)
    }
  }
  
  @objc public var isCompatibleWithAirPlayVideo: Bool {
    get {
      wrappedInstance.isCompatibleWithAirPlayVideo
    }
  }
  
  @objc public var isComposable: Bool {
    get {
      wrappedInstance.isComposable
    }
  }
  
  @objc public var containsFragments: Bool {
    get {
      wrappedInstance.containsFragments
    }
  }
  
  @objc public var creationDate: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.creationDate)
    }
  }
  
  @objc public var defaultMediaDataStorage: AVMediaDataStorageWrapper {
    get {
      AVMediaDataStorageWrapper(wrappedInstance.defaultMediaDataStorage)
    }
    set {
      wrappedInstance.defaultMediaDataStorage = newValue.wrappedInstance
    }
  }
  
  @objc public var isExportable: Bool {
    get {
      wrappedInstance.isExportable
    }
  }
  
  @objc public var hasProtectedContent: Bool {
    get {
      wrappedInstance.hasProtectedContent
    }
  }
  
  @objc public var lyrics: String {
    get {
      wrappedInstance.lyrics
    }
  }
  
  @objc public var metadata: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.metadata)
    }
    set {
      wrappedInstance.metadata = newValue.wrappedInstance
    }
  }
  
  @objc public var isModified: Bool {
    get {
      wrappedInstance.isModified
    }
    set {
      wrappedInstance.isModified = newValue
    }
  }
  
  @objc public var isPlayable: Bool {
    get {
      wrappedInstance.isPlayable
    }
  }
  
  @objc public var preferredMediaSelection: AVMediaSelectionWrapper {
    get {
      AVMediaSelectionWrapper(wrappedInstance.preferredMediaSelection)
    }
  }
  
  @objc public var providesPreciseDurationAndTiming: Bool {
    get {
      wrappedInstance.providesPreciseDurationAndTiming
    }
  }
  
  @objc public var isReadable: Bool {
    get {
      wrappedInstance.isReadable
    }
  }
  
  @objc public var trackGroups: AVAssetTrackGroupWrapper {
    get {
      AVAssetTrackGroupWrapper(wrappedInstance.trackGroups)
    }
  }
  
  @objc public var tracks: AVMutableMovieTrackWrapper {
    get {
      AVMutableMovieTrackWrapper(wrappedInstance.tracks)
    }
  }
  
  init(_ wrappedInstance: AVMutableMovie) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(settingsFromMovie movie: AVMovieWrapper, options: String) {
    wrappedInstance = AVMutableMovie(settingsFromMovie: movie.wrappedInstance, options: options)
  }
  
  @objc init(settingsFrom movie: AVMovieWrapper, options: String) {
    wrappedInstance = AVMutableMovie(settingsFrom: movie.wrappedInstance, options: options)
  }
  
  @objc init(settingsFromMovie movie: AVMovieWrapper, options: String) {
    wrappedInstance = AVMutableMovie(settingsFromMovie: movie.wrappedInstance, options: options)
  }
  
  @objc public func addMutableTrack(withMediaType mediaType: AVMediaTypeWrapper, copySettingsFrom track: AVAssetTrackWrapper, options: String) -> AVMutableMovieTrackWrapper {
    let result = wrappedInstance.addMutableTrack(withMediaType: mediaType.wrappedInstance, copySettingsFrom: track.wrappedInstance, options: options)
    return AVMutableMovieTrackWrapper(result)
  }
  
  @objc public func loadTracks(withMediaCharacteristic mediaCharacteristic: AVMediaCharacteristicWrapper, completionHandler: AVMutableMovieTrackWrapper) -> Void {
    return wrappedInstance.loadTracks(withMediaCharacteristic: mediaCharacteristic.wrappedInstance, completionHandler: completionHandler.wrappedInstance)
  }
  
  @objc public func loadTracks(withMediaCharacteristic mediaCharacteristic: AVMediaCharacteristicWrapper, completionHandler: AVMutableMovieTrackWrapper) -> Void {
    return wrappedInstance.loadTracks(withMediaCharacteristic: mediaCharacteristic.wrappedInstance, completionHandler: completionHandler.wrappedInstance)
  }
  
  @objc public func mediaSelectionGroup(forMediaCharacteristic mediaCharacteristic: AVMediaCharacteristicWrapper) -> AVMediaSelectionGroupWrapper {
    let result = wrappedInstance.mediaSelectionGroup(forMediaCharacteristic: mediaCharacteristic.wrappedInstance)
    return AVMediaSelectionGroupWrapper(result)
  }
  
  @objc public func mutableTrack(compatibleWith track: AVAssetTrackWrapper) -> AVMutableMovieTrackWrapper {
    let result = wrappedInstance.mutableTrack(compatibleWith: track.wrappedInstance)
    return AVMutableMovieTrackWrapper(result)
  }
  
  @objc public func removeTrack(track: AVMovieTrackWrapper) -> Void {
    return wrappedInstance.removeTrack(track: track.wrappedInstance)
  }
}

@objc public class AVMutableMovieTrackWrapper: NSObject {
  var wrappedInstance: AVMutableMovieTrack
  
  @objc public var alternateGroupID: Int {
    get {
      wrappedInstance.alternateGroupID
    }
    set {
      wrappedInstance.alternateGroupID = newValue
    }
  }
  
  @objc public var availableMetadataFormats: AVMetadataFormatWrapper {
    get {
      AVMetadataFormatWrapper(wrappedInstance.availableMetadataFormats)
    }
  }
  
  @objc public var availableTrackAssociationTypes: AVAssetTrackWrapper {
    get {
      AVAssetTrackWrapper(wrappedInstance.availableTrackAssociationTypes)
    }
  }
  
  @objc public var canProvideSampleCursors: Bool {
    get {
      wrappedInstance.canProvideSampleCursors
    }
  }
  
  @objc public var commonMetadata: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.commonMetadata)
    }
  }
  
  @objc public var isDecodable: Bool {
    get {
      wrappedInstance.isDecodable
    }
  }
  
  @objc public var isEnabled: Bool {
    get {
      wrappedInstance.isEnabled
    }
    set {
      wrappedInstance.isEnabled = newValue
    }
  }
  
  @objc public var extendedLanguageTag: String {
    get {
      wrappedInstance.extendedLanguageTag
    }
    set {
      wrappedInstance.extendedLanguageTag = newValue
    }
  }
  
  @objc public var hasAudioSampleDependencies: Bool {
    get {
      wrappedInstance.hasAudioSampleDependencies
    }
  }
  
  @objc public var hasProtectedContent: Bool {
    get {
      wrappedInstance.hasProtectedContent
    }
  }
  
  @objc public var languageCode: String {
    get {
      wrappedInstance.languageCode
    }
    set {
      wrappedInstance.languageCode = newValue
    }
  }
  
  @objc public var layer: Int {
    get {
      wrappedInstance.layer
    }
    set {
      wrappedInstance.layer = newValue
    }
  }
  
  @objc public var mediaDataStorage: AVMediaDataStorageWrapper {
    get {
      AVMediaDataStorageWrapper(wrappedInstance.mediaDataStorage)
    }
    set {
      wrappedInstance.mediaDataStorage = newValue.wrappedInstance
    }
  }
  
  @objc public var metadata: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.metadata)
    }
    set {
      wrappedInstance.metadata = newValue.wrappedInstance
    }
  }
  
  @objc public var isModified: Bool {
    get {
      wrappedInstance.isModified
    }
    set {
      wrappedInstance.isModified = newValue
    }
  }
  
  @objc public var isPlayable: Bool {
    get {
      wrappedInstance.isPlayable
    }
  }
  
  @objc public var preferredMediaChunkAlignment: Int {
    get {
      wrappedInstance.preferredMediaChunkAlignment
    }
    set {
      wrappedInstance.preferredMediaChunkAlignment = newValue
    }
  }
  
  @objc public var preferredMediaChunkSize: Int {
    get {
      wrappedInstance.preferredMediaChunkSize
    }
    set {
      wrappedInstance.preferredMediaChunkSize = newValue
    }
  }
  
  @objc public var requiresFrameReordering: Bool {
    get {
      wrappedInstance.requiresFrameReordering
    }
  }
  
  @objc public var segments: AVAssetTrackSegmentWrapper {
    get {
      AVAssetTrackSegmentWrapper(wrappedInstance.segments)
    }
  }
  
  @objc public var isSelfContained: Bool {
    get {
      wrappedInstance.isSelfContained
    }
  }
  
  init(_ wrappedInstance: AVMutableMovieTrack) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func addTrackAssociation(to movieTrack: AVMovieTrackWrapper, type trackAssociationType: AVAssetTrackWrapper) -> Void {
    return wrappedInstance.addTrackAssociation(to: movieTrack.wrappedInstance, type: trackAssociationType.wrappedInstance)
  }
  
  @objc public func hasMediaCharacteristic(mediaCharacteristic: AVMediaCharacteristicWrapper) -> Bool {
    return wrappedInstance.hasMediaCharacteristic(mediaCharacteristic: mediaCharacteristic.wrappedInstance)
  }
  
  @objc public func removeTrackAssociation(to movieTrack: AVMovieTrackWrapper, type trackAssociationType: AVAssetTrackWrapper) -> Void {
    return wrappedInstance.removeTrackAssociation(to: movieTrack.wrappedInstance, type: trackAssociationType.wrappedInstance)
  }
}

@objc public class AVMutableTimedMetadataGroupWrapper: NSObject {
  var wrappedInstance: AVMutableTimedMetadataGroup
  
  @objc public var items: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.items)
    }
    set {
      wrappedInstance.items = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVMutableTimedMetadataGroup) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMutableVideoCompositionWrapper: NSObject {
  var wrappedInstance: AVMutableVideoComposition
  
  @objc public var animationTool: AVVideoCompositionCoreAnimationToolWrapper {
    get {
      AVVideoCompositionCoreAnimationToolWrapper(wrappedInstance.animationTool)
    }
    set {
      wrappedInstance.animationTool = newValue.wrappedInstance
    }
  }
  
  @objc public var colorPrimaries: String {
    get {
      wrappedInstance.colorPrimaries
    }
    set {
      wrappedInstance.colorPrimaries = newValue
    }
  }
  
  @objc public var colorTransferFunction: String {
    get {
      wrappedInstance.colorTransferFunction
    }
    set {
      wrappedInstance.colorTransferFunction = newValue
    }
  }
  
  @objc public var colorYCbCrMatrix: String {
    get {
      wrappedInstance.colorYCbCrMatrix
    }
    set {
      wrappedInstance.colorYCbCrMatrix = newValue
    }
  }
  
  @objc public var perFrameHDRDisplayMetadataPolicy: AVVideoCompositionWrapper {
    get {
      AVVideoCompositionWrapper(wrappedInstance.perFrameHDRDisplayMetadataPolicy)
    }
    set {
      wrappedInstance.perFrameHDRDisplayMetadataPolicy = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVMutableVideoComposition) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(propertiesOf asset: AVAssetWrapper) {
    wrappedInstance = AVMutableVideoComposition(propertiesOf: asset.wrappedInstance)
  }
  
  @objc init(propertiesOf asset: AVAssetWrapper, prototypeInstruction: AVVideoCompositionInstructionWrapper) {
    wrappedInstance = AVMutableVideoComposition(propertiesOf: asset.wrappedInstance, prototypeInstruction: prototypeInstruction.wrappedInstance)
  }
  
  @objc init(propertiesOfAsset asset: AVAssetWrapper, prototypeInstruction: AVVideoCompositionInstructionWrapper) {
    wrappedInstance = AVMutableVideoComposition(propertiesOfAsset: asset.wrappedInstance, prototypeInstruction: prototypeInstruction.wrappedInstance)
  }
  
  @objc static public func videoComposition(with asset: AVAssetWrapper, applyingCIFiltersWithHandler applier: AVAsynchronousCIImageFilteringRequestWrapper) -> AVMutableVideoCompositionWrapper {
    let result = AVMutableVideoComposition.videoComposition(with: asset.wrappedInstance, applyingCIFiltersWithHandler: applier.wrappedInstance)
    return AVMutableVideoCompositionWrapper(result)
  }
  
  @objc static public func videoComposition(with asset: AVAssetWrapper, applyingCIFiltersWithHandler applier: AVAsynchronousCIImageFilteringRequestWrapper) -> AVMutableVideoCompositionWrapper {
    let result = AVMutableVideoComposition.videoComposition(with: asset.wrappedInstance, applyingCIFiltersWithHandler: applier.wrappedInstance)
    return AVMutableVideoCompositionWrapper(result)
  }
  
  @objc static public func videoComposition(withPropertiesOf asset: AVAssetWrapper) -> AVMutableVideoCompositionWrapper {
    let result = AVMutableVideoComposition.videoComposition(withPropertiesOf: asset.wrappedInstance)
    return AVMutableVideoCompositionWrapper(result)
  }
  
  @objc static public func videoComposition(withPropertiesOf asset: AVAssetWrapper) -> AVMutableVideoCompositionWrapper {
    let result = AVMutableVideoComposition.videoComposition(withPropertiesOf: asset.wrappedInstance)
    return AVMutableVideoCompositionWrapper(result)
  }
  
  @objc static public func videoComposition(withPropertiesOf asset: AVAssetWrapper, prototypeInstruction: AVVideoCompositionInstructionWrapper) -> AVMutableVideoCompositionWrapper {
    let result = AVMutableVideoComposition.videoComposition(withPropertiesOf: asset.wrappedInstance, prototypeInstruction: prototypeInstruction.wrappedInstance)
    return AVMutableVideoCompositionWrapper(result)
  }
  
  @objc static public func videoComposition(withPropertiesOf asset: AVAssetWrapper, prototypeInstruction: AVVideoCompositionInstructionWrapper) -> AVMutableVideoCompositionWrapper {
    let result = AVMutableVideoComposition.videoComposition(withPropertiesOf: asset.wrappedInstance, prototypeInstruction: prototypeInstruction.wrappedInstance)
    return AVMutableVideoCompositionWrapper(result)
  }
}

@objc public class AVMutableVideoCompositionInstructionWrapper: NSObject {
  var wrappedInstance: AVMutableVideoCompositionInstruction
  
  @objc public var enablePostProcessing: Bool {
    get {
      wrappedInstance.enablePostProcessing
    }
    set {
      wrappedInstance.enablePostProcessing = newValue
    }
  }
  
  @objc public var layerInstructions: AVVideoCompositionLayerInstructionWrapper {
    get {
      AVVideoCompositionLayerInstructionWrapper(wrappedInstance.layerInstructions)
    }
    set {
      wrappedInstance.layerInstructions = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVMutableVideoCompositionInstruction) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVMutableVideoCompositionLayerInstructionWrapper: NSObject {
  var wrappedInstance: AVMutableVideoCompositionLayerInstruction
  
  init(_ wrappedInstance: AVMutableVideoCompositionLayerInstruction) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(assetTrack track: AVAssetTrackWrapper) {
    wrappedInstance = AVMutableVideoCompositionLayerInstruction(assetTrack: track.wrappedInstance)
  }
}

@objc public class AVOutputSettingsAssistantWrapper: NSObject {
  var wrappedInstance: AVOutputSettingsAssistant
  
  @objc public var audioSettings: String {
    get {
      wrappedInstance.audioSettings
    }
  }
  
  @objc public var outputFileType: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(wrappedInstance.outputFileType)
    }
  }
  
  @objc public var videoSettings: String {
    get {
      wrappedInstance.videoSettings
    }
  }
  
  init(_ wrappedInstance: AVOutputSettingsAssistant) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(preset presetIdentifier: AVOutputSettingsPresetWrapper) {
    wrappedInstance = AVOutputSettingsAssistant(preset: presetIdentifier.wrappedInstance)
  }
}

@objc public class AVPersistableContentKeyRequestWrapper: NSObject {
  var wrappedInstance: AVPersistableContentKeyRequest
  
  init(_ wrappedInstance: AVPersistableContentKeyRequest) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVPlaybackCoordinatorWrapper: NSObject {
  var wrappedInstance: AVPlaybackCoordinator
  
  @objc public var otherParticipants: AVCoordinatedPlaybackParticipantWrapper {
    get {
      AVCoordinatedPlaybackParticipantWrapper(wrappedInstance.otherParticipants)
    }
  }
  
  @objc public var pauseSnapsToMediaTimeOfOriginator: Bool {
    get {
      wrappedInstance.pauseSnapsToMediaTimeOfOriginator
    }
    set {
      wrappedInstance.pauseSnapsToMediaTimeOfOriginator = newValue
    }
  }
  
  @objc public var suspensionReasons: AVCoordinatedPlaybackSuspensionWrapper {
    get {
      AVCoordinatedPlaybackSuspensionWrapper(wrappedInstance.suspensionReasons)
    }
  }
  
  @objc public var suspensionReasonsThatTriggerWaiting: AVCoordinatedPlaybackSuspensionWrapper {
    get {
      AVCoordinatedPlaybackSuspensionWrapper(wrappedInstance.suspensionReasonsThatTriggerWaiting)
    }
    set {
      wrappedInstance.suspensionReasonsThatTriggerWaiting = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVPlaybackCoordinator) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func beginSuspension(for suspensionReason: AVCoordinatedPlaybackSuspensionWrapper) -> AVCoordinatedPlaybackSuspensionWrapper {
    let result = wrappedInstance.beginSuspension(for: suspensionReason.wrappedInstance)
    return AVCoordinatedPlaybackSuspensionWrapper(result)
  }
  
  @objc public func participantLimitForWaitingOutSuspensions(withReason reason: AVCoordinatedPlaybackSuspensionWrapper) -> Int {
    return wrappedInstance.participantLimitForWaitingOutSuspensions(withReason: reason.wrappedInstance)
  }
  
  @objc public func setParticipantLimit(participantLimit: Int, forWaitingOutSuspensionsWithReason reason: AVCoordinatedPlaybackSuspensionWrapper) -> Void {
    return wrappedInstance.setParticipantLimit(participantLimit: participantLimit, forWaitingOutSuspensionsWithReason: reason.wrappedInstance)
  }
}

@objc public class AVPlayerWrapper: NSObject {
  var wrappedInstance: AVPlayer
  
  @objc static public var rateDidChangeOriginatingParticipantKey: String {
    get {
      AVPlayer.rateDidChangeOriginatingParticipantKey
    }
  }
  
  @objc static public var rateDidChangeReasonKey: String {
    get {
      AVPlayer.rateDidChangeReasonKey
    }
  }
  
  @objc static public var eligibleForHDRPlayback: Bool {
    get {
      AVPlayer.eligibleForHDRPlayback
    }
  }
  
  @objc public var actionAtItemEnd: AVPlayerWrapper {
    get {
      AVPlayerWrapper(wrappedInstance.actionAtItemEnd)
    }
    set {
      wrappedInstance.actionAtItemEnd = newValue.wrappedInstance
    }
  }
  
  @objc public var allowsExternalPlayback: Bool {
    get {
      wrappedInstance.allowsExternalPlayback
    }
    set {
      wrappedInstance.allowsExternalPlayback = newValue
    }
  }
  
  @objc public var appliesMediaSelectionCriteriaAutomatically: Bool {
    get {
      wrappedInstance.appliesMediaSelectionCriteriaAutomatically
    }
    set {
      wrappedInstance.appliesMediaSelectionCriteriaAutomatically = newValue
    }
  }
  
  @objc public var audioOutputDeviceUniqueID: String {
    get {
      wrappedInstance.audioOutputDeviceUniqueID
    }
    set {
      wrappedInstance.audioOutputDeviceUniqueID = newValue
    }
  }
  
  @objc public var automaticallyWaitsToMinimizeStalling: Bool {
    get {
      wrappedInstance.automaticallyWaitsToMinimizeStalling
    }
    set {
      wrappedInstance.automaticallyWaitsToMinimizeStalling = newValue
    }
  }
  
  @objc public var isClosedCaptionDisplayEnabled: Bool {
    get {
      wrappedInstance.isClosedCaptionDisplayEnabled
    }
    set {
      wrappedInstance.isClosedCaptionDisplayEnabled = newValue
    }
  }
  
  @objc public var currentItem: AVPlayerItemWrapper {
    get {
      AVPlayerItemWrapper(wrappedInstance.currentItem)
    }
  }
  
  @objc public var isExternalPlaybackActive: Bool {
    get {
      wrappedInstance.isExternalPlaybackActive
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
  
  @objc public var isOutputObscuredDueToInsufficientExternalProtection: Bool {
    get {
      wrappedInstance.isOutputObscuredDueToInsufficientExternalProtection
    }
  }
  
  @objc public var playbackCoordinator: AVPlayerPlaybackCoordinatorWrapper {
    get {
      AVPlayerPlaybackCoordinatorWrapper(wrappedInstance.playbackCoordinator)
    }
  }
  
  @objc public var preventsDisplaySleepDuringVideoPlayback: Bool {
    get {
      wrappedInstance.preventsDisplaySleepDuringVideoPlayback
    }
    set {
      wrappedInstance.preventsDisplaySleepDuringVideoPlayback = newValue
    }
  }
  
  @objc public var reasonForWaitingToPlay: AVPlayerWrapper {
    get {
      AVPlayerWrapper(wrappedInstance.reasonForWaitingToPlay)
    }
  }
  
  @objc public var status: AVPlayerWrapper {
    get {
      AVPlayerWrapper(wrappedInstance.status)
    }
  }
  
  @objc public var timeControlStatus: AVPlayerWrapper {
    get {
      AVPlayerWrapper(wrappedInstance.timeControlStatus)
    }
  }
  
  init(_ wrappedInstance: AVPlayer) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(playerItem item: AVPlayerItemWrapper) {
    wrappedInstance = AVPlayer(playerItem: item.wrappedInstance)
  }
  
  @objc public func cancelPendingPrerolls() -> Void {
    return wrappedInstance.cancelPendingPrerolls()
  }
  
  @objc public func mediaSelectionCriteria(forMediaCharacteristic mediaCharacteristic: AVMediaCharacteristicWrapper) -> AVPlayerMediaSelectionCriteriaWrapper {
    let result = wrappedInstance.mediaSelectionCriteria(forMediaCharacteristic: mediaCharacteristic.wrappedInstance)
    return AVPlayerMediaSelectionCriteriaWrapper(result)
  }
  
  @objc public func pause() -> Void {
    return wrappedInstance.pause()
  }
  
  @objc public func play() -> Void {
    return wrappedInstance.play()
  }
  
  @objc public func replaceCurrentItem(with item: AVPlayerItemWrapper) -> Void {
    return wrappedInstance.replaceCurrentItem(with: item.wrappedInstance)
  }
  
  @objc public func setMediaSelectionCriteria(criteria: AVPlayerMediaSelectionCriteriaWrapper, forMediaCharacteristic mediaCharacteristic: AVMediaCharacteristicWrapper) -> Void {
    return wrappedInstance.setMediaSelectionCriteria(criteria: criteria.wrappedInstance, forMediaCharacteristic: mediaCharacteristic.wrappedInstance)
  }
}

@objc public class AVPlayerInterstitialEventWrapper: NSObject {
  var wrappedInstance: AVPlayerInterstitialEvent
  
  @objc public var alignsResumptionWithPrimarySegmentBoundary: Bool {
    get {
      wrappedInstance.alignsResumptionWithPrimarySegmentBoundary
    }
    set {
      wrappedInstance.alignsResumptionWithPrimarySegmentBoundary = newValue
    }
  }
  
  @objc public var alignsStartWithPrimarySegmentBoundary: Bool {
    get {
      wrappedInstance.alignsStartWithPrimarySegmentBoundary
    }
    set {
      wrappedInstance.alignsStartWithPrimarySegmentBoundary = newValue
    }
  }
  
  @objc public var cue: AVPlayerInterstitialEventWrapper {
    get {
      AVPlayerInterstitialEventWrapper(wrappedInstance.cue)
    }
    set {
      wrappedInstance.cue = newValue.wrappedInstance
    }
  }
  
  @objc public var identifier: String {
    get {
      wrappedInstance.identifier
    }
    set {
      wrappedInstance.identifier = newValue
    }
  }
  
  @objc public var primaryItem: AVPlayerItemWrapper {
    get {
      AVPlayerItemWrapper(wrappedInstance.primaryItem)
    }
  }
  
  @objc public var restrictions: AVPlayerInterstitialEventWrapper {
    get {
      AVPlayerInterstitialEventWrapper(wrappedInstance.restrictions)
    }
    set {
      wrappedInstance.restrictions = newValue.wrappedInstance
    }
  }
  
  @objc public var templateItems: AVPlayerItemWrapper {
    get {
      AVPlayerItemWrapper(wrappedInstance.templateItems)
    }
    set {
      wrappedInstance.templateItems = newValue.wrappedInstance
    }
  }
  
  @objc public var willPlayOnce: Bool {
    get {
      wrappedInstance.willPlayOnce
    }
    set {
      wrappedInstance.willPlayOnce = newValue
    }
  }
  
  init(_ wrappedInstance: AVPlayerInterstitialEvent) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVPlayerInterstitialEventControllerWrapper: NSObject {
  var wrappedInstance: AVPlayerInterstitialEventController
  
  @objc public var events: AVPlayerInterstitialEventWrapper {
    get {
      AVPlayerInterstitialEventWrapper(wrappedInstance.events)
    }
    set {
      wrappedInstance.events = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVPlayerInterstitialEventController) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(primaryPlayer: AVPlayerWrapper) {
    wrappedInstance = AVPlayerInterstitialEventController(primaryPlayer: primaryPlayer.wrappedInstance)
  }
}

@objc public class AVPlayerInterstitialEventMonitorWrapper: NSObject {
  var wrappedInstance: AVPlayerInterstitialEventMonitor
  
  @objc public var currentEvent: AVPlayerInterstitialEventWrapper {
    get {
      AVPlayerInterstitialEventWrapper(wrappedInstance.currentEvent)
    }
  }
  
  @objc public var events: AVPlayerInterstitialEventWrapper {
    get {
      AVPlayerInterstitialEventWrapper(wrappedInstance.events)
    }
  }
  
  @objc public var interstitialPlayer: AVQueuePlayerWrapper {
    get {
      AVQueuePlayerWrapper(wrappedInstance.interstitialPlayer)
    }
  }
  
  @objc public var primaryPlayer: AVPlayerWrapper {
    get {
      AVPlayerWrapper(wrappedInstance.primaryPlayer)
    }
  }
  
  init(_ wrappedInstance: AVPlayerInterstitialEventMonitor) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(primaryPlayer: AVPlayerWrapper) {
    wrappedInstance = AVPlayerInterstitialEventMonitor(primaryPlayer: primaryPlayer.wrappedInstance)
  }
}

@objc public class AVPlayerItemWrapper: NSObject {
  var wrappedInstance: AVPlayerItem
  
  @objc static public var timeJumpedOriginatingParticipantKey: String {
    get {
      AVPlayerItem.timeJumpedOriginatingParticipantKey
    }
  }
  
  @objc public var allowedAudioSpatializationFormats: AVAudioSpatializationFormatsWrapper {
    get {
      AVAudioSpatializationFormatsWrapper(wrappedInstance.allowedAudioSpatializationFormats)
    }
    set {
      wrappedInstance.allowedAudioSpatializationFormats = newValue.wrappedInstance
    }
  }
  
  @objc public var isApplicationAuthorizedForPlayback: Bool {
    get {
      wrappedInstance.isApplicationAuthorizedForPlayback
    }
  }
  
  @objc public var appliesPerFrameHDRDisplayMetadata: Bool {
    get {
      wrappedInstance.appliesPerFrameHDRDisplayMetadata
    }
    set {
      wrappedInstance.appliesPerFrameHDRDisplayMetadata = newValue
    }
  }
  
  @objc public var asset: AVAssetWrapper {
    get {
      AVAssetWrapper(wrappedInstance.asset)
    }
  }
  
  @objc public var audioMix: AVAudioMixWrapper {
    get {
      AVAudioMixWrapper(wrappedInstance.audioMix)
    }
    set {
      wrappedInstance.audioMix = newValue.wrappedInstance
    }
  }
  
  @objc public var isAudioSpatializationAllowed: Bool {
    get {
      wrappedInstance.isAudioSpatializationAllowed
    }
    set {
      wrappedInstance.isAudioSpatializationAllowed = newValue
    }
  }
  
  @objc public var audioTimePitchAlgorithm: AVAudioTimePitchAlgorithmWrapper {
    get {
      AVAudioTimePitchAlgorithmWrapper(wrappedInstance.audioTimePitchAlgorithm)
    }
    set {
      wrappedInstance.audioTimePitchAlgorithm = newValue.wrappedInstance
    }
  }
  
  @objc public var isAuthorizationRequiredForPlayback: Bool {
    get {
      wrappedInstance.isAuthorizationRequiredForPlayback
    }
  }
  
  @objc public var automaticallyHandlesInterstitialEvents: Bool {
    get {
      wrappedInstance.automaticallyHandlesInterstitialEvents
    }
    set {
      wrappedInstance.automaticallyHandlesInterstitialEvents = newValue
    }
  }
  
  @objc public var automaticallyLoadedAssetKeys: String {
    get {
      wrappedInstance.automaticallyLoadedAssetKeys
    }
  }
  
  @objc public var automaticallyPreservesTimeOffsetFromLive: Bool {
    get {
      wrappedInstance.automaticallyPreservesTimeOffsetFromLive
    }
    set {
      wrappedInstance.automaticallyPreservesTimeOffsetFromLive = newValue
    }
  }
  
  @objc public var canPlayFastForward: Bool {
    get {
      wrappedInstance.canPlayFastForward
    }
  }
  
  @objc public var canPlayFastReverse: Bool {
    get {
      wrappedInstance.canPlayFastReverse
    }
  }
  
  @objc public var canPlayReverse: Bool {
    get {
      wrappedInstance.canPlayReverse
    }
  }
  
  @objc public var canPlaySlowForward: Bool {
    get {
      wrappedInstance.canPlaySlowForward
    }
  }
  
  @objc public var canPlaySlowReverse: Bool {
    get {
      wrappedInstance.canPlaySlowReverse
    }
  }
  
  @objc public var canStepBackward: Bool {
    get {
      wrappedInstance.canStepBackward
    }
  }
  
  @objc public var canStepForward: Bool {
    get {
      wrappedInstance.canStepForward
    }
  }
  
  @objc public var canUseNetworkResourcesForLiveStreamingWhilePaused: Bool {
    get {
      wrappedInstance.canUseNetworkResourcesForLiveStreamingWhilePaused
    }
    set {
      wrappedInstance.canUseNetworkResourcesForLiveStreamingWhilePaused = newValue
    }
  }
  
  @objc public var isContentAuthorizedForPlayback: Bool {
    get {
      wrappedInstance.isContentAuthorizedForPlayback
    }
  }
  
  @objc public var currentMediaSelection: AVMediaSelectionWrapper {
    get {
      AVMediaSelectionWrapper(wrappedInstance.currentMediaSelection)
    }
  }
  
  @objc public var mediaDataCollectors: AVPlayerItemMediaDataCollectorWrapper {
    get {
      AVPlayerItemMediaDataCollectorWrapper(wrappedInstance.mediaDataCollectors)
    }
  }
  
  @objc public var outputs: AVPlayerItemOutputWrapper {
    get {
      AVPlayerItemOutputWrapper(wrappedInstance.outputs)
    }
  }
  
  @objc public var isPlaybackBufferEmpty: Bool {
    get {
      wrappedInstance.isPlaybackBufferEmpty
    }
  }
  
  @objc public var isPlaybackBufferFull: Bool {
    get {
      wrappedInstance.isPlaybackBufferFull
    }
  }
  
  @objc public var isPlaybackLikelyToKeepUp: Bool {
    get {
      wrappedInstance.isPlaybackLikelyToKeepUp
    }
  }
  
  @objc public var preferredPeakBitRate: Double {
    get {
      wrappedInstance.preferredPeakBitRate
    }
    set {
      wrappedInstance.preferredPeakBitRate = newValue
    }
  }
  
  @objc public var preferredPeakBitRateForExpensiveNetworks: Double {
    get {
      wrappedInstance.preferredPeakBitRateForExpensiveNetworks
    }
    set {
      wrappedInstance.preferredPeakBitRateForExpensiveNetworks = newValue
    }
  }
  
  @objc public var seekingWaitsForVideoCompositionRendering: Bool {
    get {
      wrappedInstance.seekingWaitsForVideoCompositionRendering
    }
    set {
      wrappedInstance.seekingWaitsForVideoCompositionRendering = newValue
    }
  }
  
  @objc public var startsOnFirstEligibleVariant: Bool {
    get {
      wrappedInstance.startsOnFirstEligibleVariant
    }
    set {
      wrappedInstance.startsOnFirstEligibleVariant = newValue
    }
  }
  
  @objc public var status: AVPlayerItemWrapper {
    get {
      AVPlayerItemWrapper(wrappedInstance.status)
    }
  }
  
  @objc public var template: AVPlayerItemWrapper {
    get {
      AVPlayerItemWrapper(wrappedInstance.template)
    }
  }
  
  @objc public var textStyleRules: AVTextStyleRuleWrapper {
    get {
      AVTextStyleRuleWrapper(wrappedInstance.textStyleRules)
    }
    set {
      wrappedInstance.textStyleRules = newValue.wrappedInstance
    }
  }
  
  @objc public var timedMetadata: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.timedMetadata)
    }
  }
  
  @objc public var tracks: AVPlayerItemTrackWrapper {
    get {
      AVPlayerItemTrackWrapper(wrappedInstance.tracks)
    }
  }
  
  @objc public var variantPreferences: AVVariantPreferencesWrapper {
    get {
      AVVariantPreferencesWrapper(wrappedInstance.variantPreferences)
    }
    set {
      wrappedInstance.variantPreferences = newValue.wrappedInstance
    }
  }
  
  @objc public var videoApertureMode: AVVideoApertureModeWrapper {
    get {
      AVVideoApertureModeWrapper(wrappedInstance.videoApertureMode)
    }
    set {
      wrappedInstance.videoApertureMode = newValue.wrappedInstance
    }
  }
  
  @objc public var videoComposition: AVVideoCompositionWrapper {
    get {
      AVVideoCompositionWrapper(wrappedInstance.videoComposition)
    }
    set {
      wrappedInstance.videoComposition = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVPlayerItem) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(asset: AVAssetWrapper) {
    wrappedInstance = AVPlayerItem(asset: asset.wrappedInstance)
  }
  
  @objc init(asset: AVAssetWrapper, automaticallyLoadedAssetKeys: String) {
    wrappedInstance = AVPlayerItem(asset: asset.wrappedInstance, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
  }
  
  @objc public func accessLog() -> AVPlayerItemAccessLogWrapper {
    let result = wrappedInstance.accessLog()
    return AVPlayerItemAccessLogWrapper(result)
  }
  
  @objc public func add(collector: AVPlayerItemMediaDataCollectorWrapper) -> Void {
    return wrappedInstance.add(collector: collector.wrappedInstance)
  }
  
  @objc public func add(output: AVPlayerItemOutputWrapper) -> Void {
    return wrappedInstance.add(output: output.wrappedInstance)
  }
  
  @objc public func cancelContentAuthorizationRequest() -> Void {
    return wrappedInstance.cancelContentAuthorizationRequest()
  }
  
  @objc public func cancelPendingSeeks() -> Void {
    return wrappedInstance.cancelPendingSeeks()
  }
  
  @objc public func errorLog() -> AVPlayerItemErrorLogWrapper {
    let result = wrappedInstance.errorLog()
    return AVPlayerItemErrorLogWrapper(result)
  }
  
  @objc public func remove(collector: AVPlayerItemMediaDataCollectorWrapper) -> Void {
    return wrappedInstance.remove(collector: collector.wrappedInstance)
  }
  
  @objc public func remove(output: AVPlayerItemOutputWrapper) -> Void {
    return wrappedInstance.remove(output: output.wrappedInstance)
  }
  
  @objc public func select(mediaSelectionOption: AVMediaSelectionOptionWrapper, in mediaSelectionGroup: AVMediaSelectionGroupWrapper) -> Void {
    return wrappedInstance.select(mediaSelectionOption: mediaSelectionOption.wrappedInstance, in: mediaSelectionGroup.wrappedInstance)
  }
  
  @objc public func selectMediaOptionAutomatically(in mediaSelectionGroup: AVMediaSelectionGroupWrapper) -> Void {
    return wrappedInstance.selectMediaOptionAutomatically(in: mediaSelectionGroup.wrappedInstance)
  }
  
  @objc public func selectedMediaOption(in mediaSelectionGroup: AVMediaSelectionGroupWrapper) -> AVMediaSelectionOptionWrapper {
    let result = wrappedInstance.selectedMediaOption(in: mediaSelectionGroup.wrappedInstance)
    return AVMediaSelectionOptionWrapper(result)
  }
  
  @objc public func step(byCount stepCount: Int) -> Void {
    return wrappedInstance.step(byCount: stepCount)
  }
}

@objc public class AVPlayerItemAccessLogWrapper: NSObject {
  var wrappedInstance: AVPlayerItemAccessLog
  
  @objc public var events: AVPlayerItemAccessLogEventWrapper {
    get {
      AVPlayerItemAccessLogEventWrapper(wrappedInstance.events)
    }
  }
  
  init(_ wrappedInstance: AVPlayerItemAccessLog) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVPlayerItemAccessLogEventWrapper: NSObject {
  var wrappedInstance: AVPlayerItemAccessLogEvent
  
  @objc public var uri: String {
    get {
      wrappedInstance.uri
    }
  }
  
  @objc public var averageAudioBitrate: Double {
    get {
      wrappedInstance.averageAudioBitrate
    }
  }
  
  @objc public var averageVideoBitrate: Double {
    get {
      wrappedInstance.averageVideoBitrate
    }
  }
  
  @objc public var downloadOverdue: Int {
    get {
      wrappedInstance.downloadOverdue
    }
  }
  
  @objc public var indicatedAverageBitrate: Double {
    get {
      wrappedInstance.indicatedAverageBitrate
    }
  }
  
  @objc public var indicatedBitrate: Double {
    get {
      wrappedInstance.indicatedBitrate
    }
  }
  
  @objc public var mediaRequestsWWAN: Int {
    get {
      wrappedInstance.mediaRequestsWWAN
    }
  }
  
  @objc public var numberOfDroppedVideoFrames: Int {
    get {
      wrappedInstance.numberOfDroppedVideoFrames
    }
  }
  
  @objc public var numberOfMediaRequests: Int {
    get {
      wrappedInstance.numberOfMediaRequests
    }
  }
  
  @objc public var numberOfServerAddressChanges: Int {
    get {
      wrappedInstance.numberOfServerAddressChanges
    }
  }
  
  @objc public var numberOfStalls: Int {
    get {
      wrappedInstance.numberOfStalls
    }
  }
  
  @objc public var observedBitrate: Double {
    get {
      wrappedInstance.observedBitrate
    }
  }
  
  @objc public var observedBitrateStandardDeviation: Double {
    get {
      wrappedInstance.observedBitrateStandardDeviation
    }
  }
  
  @objc public var observedMaxBitrate: Double {
    get {
      wrappedInstance.observedMaxBitrate
    }
  }
  
  @objc public var observedMinBitrate: Double {
    get {
      wrappedInstance.observedMinBitrate
    }
  }
  
  @objc public var playbackSessionID: String {
    get {
      wrappedInstance.playbackSessionID
    }
  }
  
  @objc public var playbackType: String {
    get {
      wrappedInstance.playbackType
    }
  }
  
  @objc public var serverAddress: String {
    get {
      wrappedInstance.serverAddress
    }
  }
  
  @objc public var switchBitrate: Double {
    get {
      wrappedInstance.switchBitrate
    }
  }
  
  init(_ wrappedInstance: AVPlayerItemAccessLogEvent) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVPlayerItemErrorLogWrapper: NSObject {
  var wrappedInstance: AVPlayerItemErrorLog
  
  @objc public var events: AVPlayerItemErrorLogEventWrapper {
    get {
      AVPlayerItemErrorLogEventWrapper(wrappedInstance.events)
    }
  }
  
  init(_ wrappedInstance: AVPlayerItemErrorLog) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVPlayerItemErrorLogEventWrapper: NSObject {
  var wrappedInstance: AVPlayerItemErrorLogEvent
  
  @objc public var uri: String {
    get {
      wrappedInstance.uri
    }
  }
  
  @objc public var errorComment: String {
    get {
      wrappedInstance.errorComment
    }
  }
  
  @objc public var errorDomain: String {
    get {
      wrappedInstance.errorDomain
    }
  }
  
  @objc public var errorStatusCode: Int {
    get {
      wrappedInstance.errorStatusCode
    }
  }
  
  @objc public var playbackSessionID: String {
    get {
      wrappedInstance.playbackSessionID
    }
  }
  
  @objc public var serverAddress: String {
    get {
      wrappedInstance.serverAddress
    }
  }
  
  init(_ wrappedInstance: AVPlayerItemErrorLogEvent) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVPlayerItemLegibleOutputWrapper: NSObject {
  var wrappedInstance: AVPlayerItemLegibleOutput
  
  @objc public var textStylingResolution: AVPlayerItemLegibleOutputWrapper {
    get {
      AVPlayerItemLegibleOutputWrapper(wrappedInstance.textStylingResolution)
    }
    set {
      wrappedInstance.textStylingResolution = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVPlayerItemLegibleOutput) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVPlayerItemMediaDataCollectorWrapper: NSObject {
  var wrappedInstance: AVPlayerItemMediaDataCollector
  
  init(_ wrappedInstance: AVPlayerItemMediaDataCollector) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVPlayerItemMetadataCollectorWrapper: NSObject {
  var wrappedInstance: AVPlayerItemMetadataCollector
  
  init(_ wrappedInstance: AVPlayerItemMetadataCollector) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(identifiers: String, classifyingLabels: String) {
    wrappedInstance = AVPlayerItemMetadataCollector(identifiers: identifiers, classifyingLabels: classifyingLabels)
  }
}

@objc public class AVPlayerItemMetadataOutputWrapper: NSObject {
  var wrappedInstance: AVPlayerItemMetadataOutput
  
  init(_ wrappedInstance: AVPlayerItemMetadataOutput) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(identifiers: String) {
    wrappedInstance = AVPlayerItemMetadataOutput(identifiers: identifiers)
  }
}

@objc public class AVPlayerItemOutputWrapper: NSObject {
  var wrappedInstance: AVPlayerItemOutput
  
  @objc public var suppressesPlayerRendering: Bool {
    get {
      wrappedInstance.suppressesPlayerRendering
    }
    set {
      wrappedInstance.suppressesPlayerRendering = newValue
    }
  }
  
  init(_ wrappedInstance: AVPlayerItemOutput) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVPlayerItemTrackWrapper: NSObject {
  var wrappedInstance: AVPlayerItemTrack
  
  @objc public var assetTrack: AVAssetTrackWrapper {
    get {
      AVAssetTrackWrapper(wrappedInstance.assetTrack)
    }
  }
  
  @objc public var isEnabled: Bool {
    get {
      wrappedInstance.isEnabled
    }
    set {
      wrappedInstance.isEnabled = newValue
    }
  }
  
  @objc public var videoFieldMode: String {
    get {
      wrappedInstance.videoFieldMode
    }
    set {
      wrappedInstance.videoFieldMode = newValue
    }
  }
  
  init(_ wrappedInstance: AVPlayerItemTrack) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVPlayerItemVideoOutputWrapper: NSObject {
  var wrappedInstance: AVPlayerItemVideoOutput
  
  init(_ wrappedInstance: AVPlayerItemVideoOutput) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(outputSettings: String) {
    wrappedInstance = AVPlayerItemVideoOutput(outputSettings: outputSettings)
  }
  
  @objc init(pixelBufferAttributes: String) {
    wrappedInstance = AVPlayerItemVideoOutput(pixelBufferAttributes: pixelBufferAttributes)
  }
}

@objc public class AVPlayerLayerWrapper: NSObject {
  var wrappedInstance: AVPlayerLayer
  
  @objc public var pixelBufferAttributes: String {
    get {
      wrappedInstance.pixelBufferAttributes
    }
    set {
      wrappedInstance.pixelBufferAttributes = newValue
    }
  }
  
  @objc public var player: AVPlayerWrapper {
    get {
      AVPlayerWrapper(wrappedInstance.player)
    }
    set {
      wrappedInstance.player = newValue.wrappedInstance
    }
  }
  
  @objc public var isReadyForDisplay: Bool {
    get {
      wrappedInstance.isReadyForDisplay
    }
  }
  
  @objc public var videoGravity: AVLayerVideoGravityWrapper {
    get {
      AVLayerVideoGravityWrapper(wrappedInstance.videoGravity)
    }
    set {
      wrappedInstance.videoGravity = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVPlayerLayer) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(player: AVPlayerWrapper) {
    wrappedInstance = AVPlayerLayer(player: player.wrappedInstance)
  }
}

@objc public class AVPlayerLooperWrapper: NSObject {
  var wrappedInstance: AVPlayerLooper
  
  @objc public var loopCount: Int {
    get {
      wrappedInstance.loopCount
    }
  }
  
  @objc public var loopingPlayerItems: AVPlayerItemWrapper {
    get {
      AVPlayerItemWrapper(wrappedInstance.loopingPlayerItems)
    }
  }
  
  @objc public var status: AVPlayerLooperWrapper {
    get {
      AVPlayerLooperWrapper(wrappedInstance.status)
    }
  }
  
  init(_ wrappedInstance: AVPlayerLooper) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(player: AVQueuePlayerWrapper, templateItem itemToLoop: AVPlayerItemWrapper) {
    wrappedInstance = AVPlayerLooper(player: player.wrappedInstance, templateItem: itemToLoop.wrappedInstance)
  }
  
  @objc public func disableLooping() -> Void {
    return wrappedInstance.disableLooping()
  }
}

@objc public class AVPlayerMediaSelectionCriteriaWrapper: NSObject {
  var wrappedInstance: AVPlayerMediaSelectionCriteria
  
  @objc public var preferredLanguages: String {
    get {
      wrappedInstance.preferredLanguages
    }
  }
  
  @objc public var preferredMediaCharacteristics: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(wrappedInstance.preferredMediaCharacteristics)
    }
  }
  
  @objc public var principalMediaCharacteristics: AVMediaCharacteristicWrapper {
    get {
      AVMediaCharacteristicWrapper(wrappedInstance.principalMediaCharacteristics)
    }
  }
  
  init(_ wrappedInstance: AVPlayerMediaSelectionCriteria) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(preferredLanguages: String, preferredMediaCharacteristics: AVMediaCharacteristicWrapper) {
    wrappedInstance = AVPlayerMediaSelectionCriteria(preferredLanguages: preferredLanguages, preferredMediaCharacteristics: preferredMediaCharacteristics.wrappedInstance)
  }
  
  @objc init(principalMediaCharacteristics: AVMediaCharacteristicWrapper, preferredLanguages: String, preferredMediaCharacteristics: AVMediaCharacteristicWrapper) {
    wrappedInstance = AVPlayerMediaSelectionCriteria(principalMediaCharacteristics: principalMediaCharacteristics.wrappedInstance, preferredLanguages: preferredLanguages, preferredMediaCharacteristics: preferredMediaCharacteristics.wrappedInstance)
  }
}

@objc public class AVPlayerPlaybackCoordinatorWrapper: NSObject {
  var wrappedInstance: AVPlayerPlaybackCoordinator
  
  @objc public var player: AVPlayerWrapper {
    get {
      AVPlayerWrapper(wrappedInstance.player)
    }
  }
  
  init(_ wrappedInstance: AVPlayerPlaybackCoordinator) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVPortraitEffectsMatteWrapper: NSObject {
  var wrappedInstance: AVPortraitEffectsMatte
  
  init(_ wrappedInstance: AVPortraitEffectsMatte) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVQueuePlayerWrapper: NSObject {
  var wrappedInstance: AVQueuePlayer
  
  init(_ wrappedInstance: AVQueuePlayer) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(items: AVPlayerItemWrapper) {
    wrappedInstance = AVQueuePlayer(items: items.wrappedInstance)
  }
  
  @objc public func advanceToNextItem() -> Void {
    return wrappedInstance.advanceToNextItem()
  }
  
  @objc public func canInsert(item: AVPlayerItemWrapper, after afterItem: AVPlayerItemWrapper) -> Bool {
    return wrappedInstance.canInsert(item: item.wrappedInstance, after: afterItem.wrappedInstance)
  }
  
  @objc public func insert(item: AVPlayerItemWrapper, after afterItem: AVPlayerItemWrapper) -> Void {
    return wrappedInstance.insert(item: item.wrappedInstance, after: afterItem.wrappedInstance)
  }
  
  @objc public func removeAllItems() -> Void {
    return wrappedInstance.removeAllItems()
  }
  
  @objc public func remove(item: AVPlayerItemWrapper) -> Void {
    return wrappedInstance.remove(item: item.wrappedInstance)
  }
}

@objc public class AVRouteDetectorWrapper: NSObject {
  var wrappedInstance: AVRouteDetector
  
  @objc public var multipleRoutesDetected: Bool {
    get {
      wrappedInstance.multipleRoutesDetected
    }
  }
  
  @objc public var isRouteDetectionEnabled: Bool {
    get {
      wrappedInstance.isRouteDetectionEnabled
    }
    set {
      wrappedInstance.isRouteDetectionEnabled = newValue
    }
  }
  
  init(_ wrappedInstance: AVRouteDetector) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVSampleBufferAudioRendererWrapper: NSObject {
  var wrappedInstance: AVSampleBufferAudioRenderer
  
  @objc public var allowedAudioSpatializationFormats: AVAudioSpatializationFormatsWrapper {
    get {
      AVAudioSpatializationFormatsWrapper(wrappedInstance.allowedAudioSpatializationFormats)
    }
    set {
      wrappedInstance.allowedAudioSpatializationFormats = newValue.wrappedInstance
    }
  }
  
  @objc public var audioOutputDeviceUniqueID: String {
    get {
      wrappedInstance.audioOutputDeviceUniqueID
    }
    set {
      wrappedInstance.audioOutputDeviceUniqueID = newValue
    }
  }
  
  @objc public var audioTimePitchAlgorithm: AVAudioTimePitchAlgorithmWrapper {
    get {
      AVAudioTimePitchAlgorithmWrapper(wrappedInstance.audioTimePitchAlgorithm)
    }
    set {
      wrappedInstance.audioTimePitchAlgorithm = newValue.wrappedInstance
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
  
  init(_ wrappedInstance: AVSampleBufferAudioRenderer) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVSampleBufferDisplayLayerWrapper: NSObject {
  var wrappedInstance: AVSampleBufferDisplayLayer
  
  @objc public var hasSufficientMediaDataForReliablePlaybackStart: Bool {
    get {
      wrappedInstance.hasSufficientMediaDataForReliablePlaybackStart
    }
  }
  
  @objc public var isOutputObscuredDueToInsufficientExternalProtection: Bool {
    get {
      wrappedInstance.isOutputObscuredDueToInsufficientExternalProtection
    }
  }
  
  @objc public var preventsCapture: Bool {
    get {
      wrappedInstance.preventsCapture
    }
    set {
      wrappedInstance.preventsCapture = newValue
    }
  }
  
  @objc public var preventsDisplaySleepDuringVideoPlayback: Bool {
    get {
      wrappedInstance.preventsDisplaySleepDuringVideoPlayback
    }
    set {
      wrappedInstance.preventsDisplaySleepDuringVideoPlayback = newValue
    }
  }
  
  @objc public var isReadyForMoreMediaData: Bool {
    get {
      wrappedInstance.isReadyForMoreMediaData
    }
  }
  
  @objc public var requiresFlushToResumeDecoding: Bool {
    get {
      wrappedInstance.requiresFlushToResumeDecoding
    }
  }
  
  @objc public var sampleBufferRenderer: AVSampleBufferVideoRendererWrapper {
    get {
      AVSampleBufferVideoRendererWrapper(wrappedInstance.sampleBufferRenderer)
    }
  }
  
  @objc public var videoGravity: AVLayerVideoGravityWrapper {
    get {
      AVLayerVideoGravityWrapper(wrappedInstance.videoGravity)
    }
    set {
      wrappedInstance.videoGravity = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVSampleBufferDisplayLayer) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func flush() -> Void {
    return wrappedInstance.flush()
  }
  
  @objc public func flushAndRemoveImage() -> Void {
    return wrappedInstance.flushAndRemoveImage()
  }
  
  @objc public func stopRequestingMediaData() -> Void {
    return wrappedInstance.stopRequestingMediaData()
  }
}

@objc public class AVSampleBufferGeneratorWrapper: NSObject {
  var wrappedInstance: AVSampleBufferGenerator
  
  init(_ wrappedInstance: AVSampleBufferGenerator) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func makeBatch() -> AVSampleBufferGeneratorBatchWrapper {
    let result = wrappedInstance.makeBatch()
    return AVSampleBufferGeneratorBatchWrapper(result)
  }
}

@objc public class AVSampleBufferGeneratorBatchWrapper: NSObject {
  var wrappedInstance: AVSampleBufferGeneratorBatch
  
  init(_ wrappedInstance: AVSampleBufferGeneratorBatch) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func cancel() -> Void {
    return wrappedInstance.cancel()
  }
}

@objc public class AVSampleBufferRenderSynchronizerWrapper: NSObject {
  var wrappedInstance: AVSampleBufferRenderSynchronizer
  
  @objc public var delaysRateChangeUntilHasSufficientMediaData: Bool {
    get {
      wrappedInstance.delaysRateChangeUntilHasSufficientMediaData
    }
    set {
      wrappedInstance.delaysRateChangeUntilHasSufficientMediaData = newValue
    }
  }
  
  init(_ wrappedInstance: AVSampleBufferRenderSynchronizer) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVSampleBufferRequestWrapper: NSObject {
  var wrappedInstance: AVSampleBufferRequest
  
  @objc public var direction: AVSampleBufferRequestWrapper {
    get {
      AVSampleBufferRequestWrapper(wrappedInstance.direction)
    }
    set {
      wrappedInstance.direction = newValue.wrappedInstance
    }
  }
  
  @objc public var limitCursor: AVSampleCursorWrapper {
    get {
      AVSampleCursorWrapper(wrappedInstance.limitCursor)
    }
    set {
      wrappedInstance.limitCursor = newValue.wrappedInstance
    }
  }
  
  @objc public var maxSampleCount: Int {
    get {
      wrappedInstance.maxSampleCount
    }
    set {
      wrappedInstance.maxSampleCount = newValue
    }
  }
  
  @objc public var mode: AVSampleBufferRequestWrapper {
    get {
      AVSampleBufferRequestWrapper(wrappedInstance.mode)
    }
    set {
      wrappedInstance.mode = newValue.wrappedInstance
    }
  }
  
  @objc public var preferredMinSampleCount: Int {
    get {
      wrappedInstance.preferredMinSampleCount
    }
    set {
      wrappedInstance.preferredMinSampleCount = newValue
    }
  }
  
  @objc public var startCursor: AVSampleCursorWrapper {
    get {
      AVSampleCursorWrapper(wrappedInstance.startCursor)
    }
  }
  
  init(_ wrappedInstance: AVSampleBufferRequest) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(start startCursor: AVSampleCursorWrapper) {
    wrappedInstance = AVSampleBufferRequest(start: startCursor.wrappedInstance)
  }
  
  @objc init(startCursor: AVSampleCursorWrapper) {
    wrappedInstance = AVSampleBufferRequest(startCursor: startCursor.wrappedInstance)
  }
}

@objc public class AVSampleBufferVideoRendererWrapper: NSObject {
  var wrappedInstance: AVSampleBufferVideoRenderer
  
  @objc static public var didFailToDecodeNotificationErrorKey: String {
    get {
      AVSampleBufferVideoRenderer.didFailToDecodeNotificationErrorKey
    }
  }
  
  @objc public var requiresFlushToResumeDecoding: Bool {
    get {
      wrappedInstance.requiresFlushToResumeDecoding
    }
  }
  
  init(_ wrappedInstance: AVSampleBufferVideoRenderer) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func flush(removingDisplayedImage removeDisplayedImage: Bool, completionHandler handler: Void) -> Void {
    return wrappedInstance.flush(removingDisplayedImage: removeDisplayedImage, completionHandler: handler)
  }
  
  @objc public func flush(removingDisplayedImage removeDisplayedImage: Bool, completionHandler handler: Void) -> Void {
    return wrappedInstance.flush(removingDisplayedImage: removeDisplayedImage, completionHandler: handler)
  }
}

@objc public class AVSampleCursorWrapper: NSObject {
  var wrappedInstance: AVSampleCursor
  
  @objc public var currentChunkInfo: AVSampleCursorChunkInfoWrapper {
    get {
      AVSampleCursorChunkInfoWrapper(wrappedInstance.currentChunkInfo)
    }
  }
  
  @objc public var currentChunkStorageRange: AVSampleCursorStorageRangeWrapper {
    get {
      AVSampleCursorStorageRangeWrapper(wrappedInstance.currentChunkStorageRange)
    }
  }
  
  @objc public var currentSampleAudioDependencyInfo: AVSampleCursorAudioDependencyInfoWrapper {
    get {
      AVSampleCursorAudioDependencyInfoWrapper(wrappedInstance.currentSampleAudioDependencyInfo)
    }
  }
  
  @objc public var currentSampleDependencyInfo: AVSampleCursorDependencyInfoWrapper {
    get {
      AVSampleCursorDependencyInfoWrapper(wrappedInstance.currentSampleDependencyInfo)
    }
  }
  
  @objc public var currentSampleStorageRange: AVSampleCursorStorageRangeWrapper {
    get {
      AVSampleCursorStorageRangeWrapper(wrappedInstance.currentSampleStorageRange)
    }
  }
  
  @objc public var currentSampleSyncInfo: AVSampleCursorSyncInfoWrapper {
    get {
      AVSampleCursorSyncInfoWrapper(wrappedInstance.currentSampleSyncInfo)
    }
  }
  
  @objc public var samplesRequiredForDecoderRefresh: Int {
    get {
      wrappedInstance.samplesRequiredForDecoderRefresh
    }
  }
  
  init(_ wrappedInstance: AVSampleCursor) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func maySamplesWithEarlierDecodeTimeStampsHavePresentationTimeStamps(laterThan cursor: AVSampleCursorWrapper) -> Bool {
    return wrappedInstance.maySamplesWithEarlierDecodeTimeStampsHavePresentationTimeStamps(laterThan: cursor.wrappedInstance)
  }
  
  @objc public func maySamplesWithLaterDecodeTimeStampsHavePresentationTimeStamps(earlierThan cursor: AVSampleCursorWrapper) -> Bool {
    return wrappedInstance.maySamplesWithLaterDecodeTimeStampsHavePresentationTimeStamps(earlierThan: cursor.wrappedInstance)
  }
}

@objc public class AVSemanticSegmentationMatteWrapper: NSObject {
  var wrappedInstance: AVSemanticSegmentationMatte
  
  @objc public var matteType: AVSemanticSegmentationMatteWrapper {
    get {
      AVSemanticSegmentationMatteWrapper(wrappedInstance.matteType)
    }
  }
  
  init(_ wrappedInstance: AVSemanticSegmentationMatte) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVSynchronizedLayerWrapper: NSObject {
  var wrappedInstance: AVSynchronizedLayer
  
  @objc public var playerItem: AVPlayerItemWrapper {
    get {
      AVPlayerItemWrapper(wrappedInstance.playerItem)
    }
    set {
      wrappedInstance.playerItem = newValue.wrappedInstance
    }
  }
  
  init(_ wrappedInstance: AVSynchronizedLayer) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(playerItem: AVPlayerItemWrapper) {
    wrappedInstance = AVSynchronizedLayer(playerItem: playerItem.wrappedInstance)
  }
}

@objc public class AVTextStyleRuleWrapper: NSObject {
  var wrappedInstance: AVTextStyleRule
  
  @objc public var textMarkupAttributes: String {
    get {
      wrappedInstance.textMarkupAttributes
    }
  }
  
  @objc public var textSelector: String {
    get {
      wrappedInstance.textSelector
    }
  }
  
  init(_ wrappedInstance: AVTextStyleRule) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(textMarkupAttributes: String) {
    wrappedInstance = AVTextStyleRule(textMarkupAttributes: textMarkupAttributes)
  }
  
  @objc init(textMarkupAttributes: String, textSelector: String) {
    wrappedInstance = AVTextStyleRule(textMarkupAttributes: textMarkupAttributes, textSelector: textSelector)
  }
}

@objc public class AVTimedMetadataGroupWrapper: NSObject {
  var wrappedInstance: AVTimedMetadataGroup
  
  @objc public var items: AVMetadataItemWrapper {
    get {
      AVMetadataItemWrapper(wrappedInstance.items)
    }
  }
  
  init(_ wrappedInstance: AVTimedMetadataGroup) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVURLAssetWrapper: NSObject {
  var wrappedInstance: AVURLAsset
  
  @objc public var assetCache: AVAssetCacheWrapper {
    get {
      AVAssetCacheWrapper(wrappedInstance.assetCache)
    }
  }
  
  @objc public var mayRequireContentKeysForMediaDataProcessing: Bool {
    get {
      wrappedInstance.mayRequireContentKeysForMediaDataProcessing
    }
  }
  
  @objc public var resourceLoader: AVAssetResourceLoaderWrapper {
    get {
      AVAssetResourceLoaderWrapper(wrappedInstance.resourceLoader)
    }
  }
  
  @objc public var variants: AVAssetVariantWrapper {
    get {
      AVAssetVariantWrapper(wrappedInstance.variants)
    }
  }
  
  init(_ wrappedInstance: AVURLAsset) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc static public func isPlayableExtendedMIMEType(extendedMIMEType: String) -> Bool {
    return AVURLAsset.isPlayableExtendedMIMEType(extendedMIMEType: extendedMIMEType)
  }
  
  @objc public func compatibleTrack(for compositionTrack: AVCompositionTrackWrapper) -> AVAssetTrackWrapper {
    let result = wrappedInstance.compatibleTrack(for: compositionTrack.wrappedInstance)
    return AVAssetTrackWrapper(result)
  }
  
  @objc public func findCompatibleTrack(for compositionTrack: AVCompositionTrackWrapper) -> AVAssetTrackWrapper {
    let result = wrappedInstance.findCompatibleTrack(for: compositionTrack.wrappedInstance)
    return AVAssetTrackWrapper(result)
  }
  
  @objc public func findCompatibleTrack(for compositionTrack: AVCompositionTrackWrapper) -> AVAssetTrackWrapper {
    let result = wrappedInstance.findCompatibleTrack(for: compositionTrack.wrappedInstance)
    return AVAssetTrackWrapper(result)
  }
}

@objc public class AVVideoCompositionWrapper: NSObject {
  var wrappedInstance: AVVideoComposition
  
  @objc public var animationTool: AVVideoCompositionCoreAnimationToolWrapper {
    get {
      AVVideoCompositionCoreAnimationToolWrapper(wrappedInstance.animationTool)
    }
  }
  
  @objc public var colorPrimaries: String {
    get {
      wrappedInstance.colorPrimaries
    }
  }
  
  @objc public var colorTransferFunction: String {
    get {
      wrappedInstance.colorTransferFunction
    }
  }
  
  @objc public var colorYCbCrMatrix: String {
    get {
      wrappedInstance.colorYCbCrMatrix
    }
  }
  
  @objc public var perFrameHDRDisplayMetadataPolicy: AVVideoCompositionWrapper {
    get {
      AVVideoCompositionWrapper(wrappedInstance.perFrameHDRDisplayMetadataPolicy)
    }
  }
  
  init(_ wrappedInstance: AVVideoComposition) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc init(propertiesOf asset: AVAssetWrapper) {
    wrappedInstance = AVVideoComposition(propertiesOf: asset.wrappedInstance)
  }
  
  @objc init(propertiesOfAsset asset: AVAssetWrapper) {
    wrappedInstance = AVVideoComposition(propertiesOfAsset: asset.wrappedInstance)
  }
  
  @objc static public func videoComposition(with asset: AVAssetWrapper, applyingCIFiltersWithHandler applier: AVAsynchronousCIImageFilteringRequestWrapper, completionHandler: AVVideoCompositionWrapper) -> Void {
    return AVVideoComposition.videoComposition(with: asset.wrappedInstance, applyingCIFiltersWithHandler: applier.wrappedInstance, completionHandler: completionHandler.wrappedInstance)
  }
  
  @objc static public func videoComposition(with asset: AVAssetWrapper, applyingCIFiltersWithHandler applier: AVAsynchronousCIImageFilteringRequestWrapper, completionHandler: AVVideoCompositionWrapper) -> Void {
    return AVVideoComposition.videoComposition(with: asset.wrappedInstance, applyingCIFiltersWithHandler: applier.wrappedInstance, completionHandler: completionHandler.wrappedInstance)
  }
  
  @objc static public func videoComposition(withPropertiesOf asset: AVAssetWrapper, completionHandler: AVVideoCompositionWrapper) -> Void {
    return AVVideoComposition.videoComposition(withPropertiesOf: asset.wrappedInstance, completionHandler: completionHandler.wrappedInstance)
  }
  
  @objc static public func videoComposition(withPropertiesOf asset: AVAssetWrapper, completionHandler: AVVideoCompositionWrapper) -> Void {
    return AVVideoComposition.videoComposition(withPropertiesOf: asset.wrappedInstance, completionHandler: completionHandler.wrappedInstance)
  }
}

@objc public class AVVideoCompositionCoreAnimationToolWrapper: NSObject {
  var wrappedInstance: AVVideoCompositionCoreAnimationTool
  
  init(_ wrappedInstance: AVVideoCompositionCoreAnimationTool) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVVideoCompositionInstructionWrapper: NSObject {
  var wrappedInstance: AVVideoCompositionInstruction
  
  @objc public var enablePostProcessing: Bool {
    get {
      wrappedInstance.enablePostProcessing
    }
  }
  
  @objc public var layerInstructions: AVVideoCompositionLayerInstructionWrapper {
    get {
      AVVideoCompositionLayerInstructionWrapper(wrappedInstance.layerInstructions)
    }
  }
  
  init(_ wrappedInstance: AVVideoCompositionInstruction) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVVideoCompositionLayerInstructionWrapper: NSObject {
  var wrappedInstance: AVVideoCompositionLayerInstruction
  
  init(_ wrappedInstance: AVVideoCompositionLayerInstruction) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVVideoCompositionRenderContextWrapper: NSObject {
  var wrappedInstance: AVVideoCompositionRenderContext
  
  @objc public var edgeWidths: AVEdgeWidthsWrapper {
    get {
      AVEdgeWidthsWrapper(wrappedInstance.edgeWidths)
    }
  }
  
  @objc public var highQualityRendering: Bool {
    get {
      wrappedInstance.highQualityRendering
    }
  }
  
  @objc public var pixelAspectRatio: AVPixelAspectRatioWrapper {
    get {
      AVPixelAspectRatioWrapper(wrappedInstance.pixelAspectRatio)
    }
  }
  
  @objc public var videoComposition: AVVideoCompositionWrapper {
    get {
      AVVideoCompositionWrapper(wrappedInstance.videoComposition)
    }
  }
  
  init(_ wrappedInstance: AVVideoCompositionRenderContext) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVVideoCompositionRenderHintWrapper: NSObject {
  var wrappedInstance: AVVideoCompositionRenderHint
  
  init(_ wrappedInstance: AVVideoCompositionRenderHint) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class GlobalsWrapper: NSObject {
  @objc static public var AVAssetDownloadTaskMediaSelectionKeyWrapper: String {
    get {
      AVAssetDownloadTaskMediaSelectionKey
    }
  }
  
  @objc static public var AVAssetDownloadTaskMediaSelectionPrefersMultichannelKeyWrapper: String {
    get {
      AVAssetDownloadTaskMediaSelectionPrefersMultichannelKey
    }
  }
  
  @objc static public var AVAssetDownloadTaskMinimumRequiredMediaBitrateKeyWrapper: String {
    get {
      AVAssetDownloadTaskMinimumRequiredMediaBitrateKey
    }
  }
  
  @objc static public var AVAssetDownloadTaskMinimumRequiredPresentationSizeKeyWrapper: String {
    get {
      AVAssetDownloadTaskMinimumRequiredPresentationSizeKey
    }
  }
  
  @objc static public var AVAssetDownloadTaskPrefersHDRKeyWrapper: String {
    get {
      AVAssetDownloadTaskPrefersHDRKey
    }
  }
  
  @objc static public var AVAssetDownloadTaskPrefersLosslessAudioKeyWrapper: String {
    get {
      AVAssetDownloadTaskPrefersLosslessAudioKey
    }
  }
  
  @objc static public var AVAssetExportPreset1280x720Wrapper: String {
    get {
      AVAssetExportPreset1280x720
    }
  }
  
  @objc static public var AVAssetExportPreset1920x1080Wrapper: String {
    get {
      AVAssetExportPreset1920x1080
    }
  }
  
  @objc static public var AVAssetExportPreset3840x2160Wrapper: String {
    get {
      AVAssetExportPreset3840x2160
    }
  }
  
  @objc static public var AVAssetExportPreset640x480Wrapper: String {
    get {
      AVAssetExportPreset640x480
    }
  }
  
  @objc static public var AVAssetExportPreset960x540Wrapper: String {
    get {
      AVAssetExportPreset960x540
    }
  }
  
  @objc static public var AVAssetExportPresetAppleM4AWrapper: String {
    get {
      AVAssetExportPresetAppleM4A
    }
  }
  
  @objc static public var AVAssetExportPresetAppleM4V1080pHDWrapper: String {
    get {
      AVAssetExportPresetAppleM4V1080pHD
    }
  }
  
  @objc static public var AVAssetExportPresetAppleM4V480pSDWrapper: String {
    get {
      AVAssetExportPresetAppleM4V480pSD
    }
  }
  
  @objc static public var AVAssetExportPresetAppleM4V720pHDWrapper: String {
    get {
      AVAssetExportPresetAppleM4V720pHD
    }
  }
  
  @objc static public var AVAssetExportPresetAppleM4VAppleTVWrapper: String {
    get {
      AVAssetExportPresetAppleM4VAppleTV
    }
  }
  
  @objc static public var AVAssetExportPresetAppleM4VCellularWrapper: String {
    get {
      AVAssetExportPresetAppleM4VCellular
    }
  }
  
  @objc static public var AVAssetExportPresetAppleM4VWiFiWrapper: String {
    get {
      AVAssetExportPresetAppleM4VWiFi
    }
  }
  
  @objc static public var AVAssetExportPresetAppleM4ViPodWrapper: String {
    get {
      AVAssetExportPresetAppleM4ViPod
    }
  }
  
  @objc static public var AVAssetExportPresetAppleProRes422LPCMWrapper: String {
    get {
      AVAssetExportPresetAppleProRes422LPCM
    }
  }
  
  @objc static public var AVAssetExportPresetAppleProRes4444LPCMWrapper: String {
    get {
      AVAssetExportPresetAppleProRes4444LPCM
    }
  }
  
  @objc static public var AVAssetExportPresetHEVC1920x1080Wrapper: String {
    get {
      AVAssetExportPresetHEVC1920x1080
    }
  }
  
  @objc static public var AVAssetExportPresetHEVC1920x1080WithAlphaWrapper: String {
    get {
      AVAssetExportPresetHEVC1920x1080WithAlpha
    }
  }
  
  @objc static public var AVAssetExportPresetHEVC3840x2160Wrapper: String {
    get {
      AVAssetExportPresetHEVC3840x2160
    }
  }
  
  @objc static public var AVAssetExportPresetHEVC3840x2160WithAlphaWrapper: String {
    get {
      AVAssetExportPresetHEVC3840x2160WithAlpha
    }
  }
  
  @objc static public var AVAssetExportPresetHEVC7680x4320Wrapper: String {
    get {
      AVAssetExportPresetHEVC7680x4320
    }
  }
  
  @objc static public var AVAssetExportPresetHEVCHighestQualityWrapper: String {
    get {
      AVAssetExportPresetHEVCHighestQuality
    }
  }
  
  @objc static public var AVAssetExportPresetHEVCHighestQualityWithAlphaWrapper: String {
    get {
      AVAssetExportPresetHEVCHighestQualityWithAlpha
    }
  }
  
  @objc static public var AVAssetExportPresetHighestQualityWrapper: String {
    get {
      AVAssetExportPresetHighestQuality
    }
  }
  
  @objc static public var AVAssetExportPresetLowQualityWrapper: String {
    get {
      AVAssetExportPresetLowQuality
    }
  }
  
  @objc static public var AVAssetExportPresetMVHEVC1440x1440Wrapper: String {
    get {
      AVAssetExportPresetMVHEVC1440x1440
    }
  }
  
  @objc static public var AVAssetExportPresetMVHEVC960x960Wrapper: String {
    get {
      AVAssetExportPresetMVHEVC960x960
    }
  }
  
  @objc static public var AVAssetExportPresetMediumQualityWrapper: String {
    get {
      AVAssetExportPresetMediumQuality
    }
  }
  
  @objc static public var AVAssetExportPresetPassthroughWrapper: String {
    get {
      AVAssetExportPresetPassthrough
    }
  }
  
  @objc static public var AVAssetResourceLoadingRequestStreamingContentKeyRequestRequiresPersistentKeyWrapper: String {
    get {
      AVAssetResourceLoadingRequestStreamingContentKeyRequestRequiresPersistentKey
    }
  }
  
  @objc static public var AVCaptureSessionErrorKeyWrapper: String {
    get {
      AVCaptureSessionErrorKey
    }
  }
  
  @objc static public var AVContentKeyRequestProtocolVersionsKeyWrapper: String {
    get {
      AVContentKeyRequestProtocolVersionsKey
    }
  }
  
  @objc static public var AVContentKeyRequestRequiresValidationDataInSecureTokenKeyWrapper: String {
    get {
      AVContentKeyRequestRequiresValidationDataInSecureTokenKey
    }
  }
  
  @objc static public var AVErrorDeviceKeyWrapper: String {
    get {
      AVErrorDeviceKey
    }
  }
  
  @objc static public var AVErrorDiscontinuityFlagsKeyWrapper: String {
    get {
      AVErrorDiscontinuityFlagsKey
    }
  }
  
  @objc static public var AVErrorFileSizeKeyWrapper: String {
    get {
      AVErrorFileSizeKey
    }
  }
  
  @objc static public var AVErrorFileTypeKeyWrapper: String {
    get {
      AVErrorFileTypeKey
    }
  }
  
  @objc static public var AVErrorMediaSubTypeKeyWrapper: String {
    get {
      AVErrorMediaSubTypeKey
    }
  }
  
  @objc static public var AVErrorMediaTypeKeyWrapper: String {
    get {
      AVErrorMediaTypeKey
    }
  }
  
  @objc static public var AVErrorPIDKeyWrapper: String {
    get {
      AVErrorPIDKey
    }
  }
  
  @objc static public var AVErrorPersistentTrackIDKeyWrapper: String {
    get {
      AVErrorPersistentTrackIDKey
    }
  }
  
  @objc static public var AVErrorPresentationTimeStampKeyWrapper: String {
    get {
      AVErrorPresentationTimeStampKey
    }
  }
  
  @objc static public var AVErrorRecordingSuccessfullyFinishedKeyWrapper: String {
    get {
      AVErrorRecordingSuccessfullyFinishedKey
    }
  }
  
  @objc static public var AVErrorTimeKeyWrapper: String {
    get {
      AVErrorTimeKey
    }
  }
  
  @objc static public var AVFoundationErrorDomainWrapper: String {
    get {
      AVFoundationErrorDomain
    }
  }
  
  @objc static public var AVMovieReferenceRestrictionsKeyWrapper: String {
    get {
      AVMovieReferenceRestrictionsKey
    }
  }
  
  @objc static public var AVMovieShouldSupportAliasDataReferencesKeyWrapper: String {
    get {
      AVMovieShouldSupportAliasDataReferencesKey
    }
  }
  
  @objc static public var AVPlayerInterstitialEventMonitorAssetListResponseStatusDidChangeErrorKeyWrapper: String {
    get {
      AVPlayerInterstitialEventMonitorAssetListResponseStatusDidChangeErrorKey
    }
  }
  
  @objc static public var AVPlayerInterstitialEventMonitorAssetListResponseStatusDidChangeEventKeyWrapper: String {
    get {
      AVPlayerInterstitialEventMonitorAssetListResponseStatusDidChangeEventKey
    }
  }
  
  @objc static public var AVPlayerInterstitialEventMonitorAssetListResponseStatusDidChangeStatusKeyWrapper: String {
    get {
      AVPlayerInterstitialEventMonitorAssetListResponseStatusDidChangeStatusKey
    }
  }
  
  @objc static public var AVPlayerItemFailedToPlayToEndTimeErrorKeyWrapper: String {
    get {
      AVPlayerItemFailedToPlayToEndTimeErrorKey
    }
  }
  
  @objc static public var AVPlayerItemTrackVideoFieldModeDeinterlaceFieldsWrapper: String {
    get {
      AVPlayerItemTrackVideoFieldModeDeinterlaceFields
    }
  }
  
  @objc static public var AVSampleBufferAudioRendererFlushTimeKeyWrapper: String {
    get {
      AVSampleBufferAudioRendererFlushTimeKey
    }
  }
  
  @objc static public var AVSampleBufferDisplayLayerFailedToDecodeNotificationErrorKeyWrapper: String {
    get {
      AVSampleBufferDisplayLayerFailedToDecodeNotificationErrorKey
    }
  }
  
  @objc static public var AVStreamingKeyDeliveryContentKeyTypeWrapper: String {
    get {
      AVStreamingKeyDeliveryContentKeyType
    }
  }
  
  @objc static public var AVStreamingKeyDeliveryPersistentContentKeyTypeWrapper: String {
    get {
      AVStreamingKeyDeliveryPersistentContentKeyType
    }
  }
  
  @objc static public var AVURLAssetAllowsCellularAccessKeyWrapper: String {
    get {
      AVURLAssetAllowsCellularAccessKey
    }
  }
  
  @objc static public var AVURLAssetAllowsConstrainedNetworkAccessKeyWrapper: String {
    get {
      AVURLAssetAllowsConstrainedNetworkAccessKey
    }
  }
  
  @objc static public var AVURLAssetAllowsExpensiveNetworkAccessKeyWrapper: String {
    get {
      AVURLAssetAllowsExpensiveNetworkAccessKey
    }
  }
  
  @objc static public var AVURLAssetHTTPCookiesKeyWrapper: String {
    get {
      AVURLAssetHTTPCookiesKey
    }
  }
  
  @objc static public var AVURLAssetHTTPUserAgentKeyWrapper: String {
    get {
      AVURLAssetHTTPUserAgentKey
    }
  }
  
  @objc static public var AVURLAssetOverrideMIMETypeKeyWrapper: String {
    get {
      AVURLAssetOverrideMIMETypeKey
    }
  }
  
  @objc static public var AVURLAssetPreferPreciseDurationAndTimingKeyWrapper: String {
    get {
      AVURLAssetPreferPreciseDurationAndTimingKey
    }
  }
  
  @objc static public var AVURLAssetPrimarySessionIdentifierKeyWrapper: String {
    get {
      AVURLAssetPrimarySessionIdentifierKey
    }
  }
  
  @objc static public var AVURLAssetReferenceRestrictionsKeyWrapper: String {
    get {
      AVURLAssetReferenceRestrictionsKey
    }
  }
  
  @objc static public var AVURLAssetShouldSupportAliasDataReferencesKeyWrapper: String {
    get {
      AVURLAssetShouldSupportAliasDataReferencesKey
    }
  }
  
  @objc static public var AVURLAssetURLRequestAttributionKeyWrapper: String {
    get {
      AVURLAssetURLRequestAttributionKey
    }
  }
  
  @objc static public var AVVideoAllowFrameReorderingKeyWrapper: String {
    get {
      AVVideoAllowFrameReorderingKey
    }
  }
  
  @objc static public var AVVideoAllowWideColorKeyWrapper: String {
    get {
      AVVideoAllowWideColorKey
    }
  }
  
  @objc static public var AVVideoAppleProRAWBitDepthKeyWrapper: String {
    get {
      AVVideoAppleProRAWBitDepthKey
    }
  }
  
  @objc static public var AVVideoAverageBitRateKeyWrapper: String {
    get {
      AVVideoAverageBitRateKey
    }
  }
  
  @objc static public var AVVideoAverageNonDroppableFrameRateKeyWrapper: String {
    get {
      AVVideoAverageNonDroppableFrameRateKey
    }
  }
  
  @objc static public var AVVideoCleanApertureHeightKeyWrapper: String {
    get {
      AVVideoCleanApertureHeightKey
    }
  }
  
  @objc static public var AVVideoCleanApertureHorizontalOffsetKeyWrapper: String {
    get {
      AVVideoCleanApertureHorizontalOffsetKey
    }
  }
  
  @objc static public var AVVideoCleanApertureKeyWrapper: String {
    get {
      AVVideoCleanApertureKey
    }
  }
  
  @objc static public var AVVideoCleanApertureVerticalOffsetKeyWrapper: String {
    get {
      AVVideoCleanApertureVerticalOffsetKey
    }
  }
  
  @objc static public var AVVideoCleanApertureWidthKeyWrapper: String {
    get {
      AVVideoCleanApertureWidthKey
    }
  }
  
  @objc static public var AVVideoCodecAppleProRes422Wrapper: String {
    get {
      AVVideoCodecAppleProRes422
    }
  }
  
  @objc static public var AVVideoCodecAppleProRes4444Wrapper: String {
    get {
      AVVideoCodecAppleProRes4444
    }
  }
  
  @objc static public var AVVideoCodecH264Wrapper: String {
    get {
      AVVideoCodecH264
    }
  }
  
  @objc static public var AVVideoCodecHEVCWrapper: String {
    get {
      AVVideoCodecHEVC
    }
  }
  
  @objc static public var AVVideoCodecJPEGWrapper: String {
    get {
      AVVideoCodecJPEG
    }
  }
  
  @objc static public var AVVideoCodecKeyWrapper: String {
    get {
      AVVideoCodecKey
    }
  }
  
  @objc static public var AVVideoColorPrimariesKeyWrapper: String {
    get {
      AVVideoColorPrimariesKey
    }
  }
  
  @objc static public var AVVideoColorPrimaries_EBU_3213Wrapper: String {
    get {
      AVVideoColorPrimaries_EBU_3213
    }
  }
  
  @objc static public var AVVideoColorPrimaries_ITU_R_2020Wrapper: String {
    get {
      AVVideoColorPrimaries_ITU_R_2020
    }
  }
  
  @objc static public var AVVideoColorPrimaries_ITU_R_709_2Wrapper: String {
    get {
      AVVideoColorPrimaries_ITU_R_709_2
    }
  }
  
  @objc static public var AVVideoColorPrimaries_P3_D65Wrapper: String {
    get {
      AVVideoColorPrimaries_P3_D65
    }
  }
  
  @objc static public var AVVideoColorPrimaries_SMPTE_CWrapper: String {
    get {
      AVVideoColorPrimaries_SMPTE_C
    }
  }
  
  @objc static public var AVVideoColorPropertiesKeyWrapper: String {
    get {
      AVVideoColorPropertiesKey
    }
  }
  
  @objc static public var AVVideoCompressionPropertiesKeyWrapper: String {
    get {
      AVVideoCompressionPropertiesKey
    }
  }
  
  @objc static public var AVVideoDecompressionPropertiesKeyWrapper: String {
    get {
      AVVideoDecompressionPropertiesKey
    }
  }
  
  @objc static public var AVVideoEncoderSpecificationKeyWrapper: String {
    get {
      AVVideoEncoderSpecificationKey
    }
  }
  
  @objc static public var AVVideoExpectedSourceFrameRateKeyWrapper: String {
    get {
      AVVideoExpectedSourceFrameRateKey
    }
  }
  
  @objc static public var AVVideoH264EntropyModeCABACWrapper: String {
    get {
      AVVideoH264EntropyModeCABAC
    }
  }
  
  @objc static public var AVVideoH264EntropyModeCAVLCWrapper: String {
    get {
      AVVideoH264EntropyModeCAVLC
    }
  }
  
  @objc static public var AVVideoH264EntropyModeKeyWrapper: String {
    get {
      AVVideoH264EntropyModeKey
    }
  }
  
  @objc static public var AVVideoHeightKeyWrapper: String {
    get {
      AVVideoHeightKey
    }
  }
  
  @objc static public var AVVideoMaxKeyFrameIntervalDurationKeyWrapper: String {
    get {
      AVVideoMaxKeyFrameIntervalDurationKey
    }
  }
  
  @objc static public var AVVideoMaxKeyFrameIntervalKeyWrapper: String {
    get {
      AVVideoMaxKeyFrameIntervalKey
    }
  }
  
  @objc static public var AVVideoPixelAspectRatioHorizontalSpacingKeyWrapper: String {
    get {
      AVVideoPixelAspectRatioHorizontalSpacingKey
    }
  }
  
  @objc static public var AVVideoPixelAspectRatioKeyWrapper: String {
    get {
      AVVideoPixelAspectRatioKey
    }
  }
  
  @objc static public var AVVideoPixelAspectRatioVerticalSpacingKeyWrapper: String {
    get {
      AVVideoPixelAspectRatioVerticalSpacingKey
    }
  }
  
  @objc static public var AVVideoProfileLevelH264Baseline30Wrapper: String {
    get {
      AVVideoProfileLevelH264Baseline30
    }
  }
  
  @objc static public var AVVideoProfileLevelH264Baseline31Wrapper: String {
    get {
      AVVideoProfileLevelH264Baseline31
    }
  }
  
  @objc static public var AVVideoProfileLevelH264Baseline41Wrapper: String {
    get {
      AVVideoProfileLevelH264Baseline41
    }
  }
  
  @objc static public var AVVideoProfileLevelH264BaselineAutoLevelWrapper: String {
    get {
      AVVideoProfileLevelH264BaselineAutoLevel
    }
  }
  
  @objc static public var AVVideoProfileLevelH264High40Wrapper: String {
    get {
      AVVideoProfileLevelH264High40
    }
  }
  
  @objc static public var AVVideoProfileLevelH264High41Wrapper: String {
    get {
      AVVideoProfileLevelH264High41
    }
  }
  
  @objc static public var AVVideoProfileLevelH264HighAutoLevelWrapper: String {
    get {
      AVVideoProfileLevelH264HighAutoLevel
    }
  }
  
  @objc static public var AVVideoProfileLevelH264Main30Wrapper: String {
    get {
      AVVideoProfileLevelH264Main30
    }
  }
  
  @objc static public var AVVideoProfileLevelH264Main31Wrapper: String {
    get {
      AVVideoProfileLevelH264Main31
    }
  }
  
  @objc static public var AVVideoProfileLevelH264Main32Wrapper: String {
    get {
      AVVideoProfileLevelH264Main32
    }
  }
  
  @objc static public var AVVideoProfileLevelH264Main41Wrapper: String {
    get {
      AVVideoProfileLevelH264Main41
    }
  }
  
  @objc static public var AVVideoProfileLevelH264MainAutoLevelWrapper: String {
    get {
      AVVideoProfileLevelH264MainAutoLevel
    }
  }
  
  @objc static public var AVVideoProfileLevelKeyWrapper: String {
    get {
      AVVideoProfileLevelKey
    }
  }
  
  @objc static public var AVVideoQualityKeyWrapper: String {
    get {
      AVVideoQualityKey
    }
  }
  
  @objc static public var AVVideoScalingModeFitWrapper: String {
    get {
      AVVideoScalingModeFit
    }
  }
  
  @objc static public var AVVideoScalingModeKeyWrapper: String {
    get {
      AVVideoScalingModeKey
    }
  }
  
  @objc static public var AVVideoScalingModeResizeWrapper: String {
    get {
      AVVideoScalingModeResize
    }
  }
  
  @objc static public var AVVideoScalingModeResizeAspectWrapper: String {
    get {
      AVVideoScalingModeResizeAspect
    }
  }
  
  @objc static public var AVVideoScalingModeResizeAspectFillWrapper: String {
    get {
      AVVideoScalingModeResizeAspectFill
    }
  }
  
  @objc static public var AVVideoTransferFunctionKeyWrapper: String {
    get {
      AVVideoTransferFunctionKey
    }
  }
  
  @objc static public var AVVideoTransferFunction_ITU_R_2100_HLGWrapper: String {
    get {
      AVVideoTransferFunction_ITU_R_2100_HLG
    }
  }
  
  @objc static public var AVVideoTransferFunction_ITU_R_709_2Wrapper: String {
    get {
      AVVideoTransferFunction_ITU_R_709_2
    }
  }
  
  @objc static public var AVVideoTransferFunction_LinearWrapper: String {
    get {
      AVVideoTransferFunction_Linear
    }
  }
  
  @objc static public var AVVideoTransferFunction_SMPTE_240M_1995Wrapper: String {
    get {
      AVVideoTransferFunction_SMPTE_240M_1995
    }
  }
  
  @objc static public var AVVideoTransferFunction_SMPTE_ST_2084_PQWrapper: String {
    get {
      AVVideoTransferFunction_SMPTE_ST_2084_PQ
    }
  }
  
  @objc static public var AVVideoWidthKeyWrapper: String {
    get {
      AVVideoWidthKey
    }
  }
  
  @objc static public var AVVideoYCbCrMatrixKeyWrapper: String {
    get {
      AVVideoYCbCrMatrixKey
    }
  }
  
  @objc static public var AVVideoYCbCrMatrix_ITU_R_2020Wrapper: String {
    get {
      AVVideoYCbCrMatrix_ITU_R_2020
    }
  }
  
  @objc static public var AVVideoYCbCrMatrix_ITU_R_601_4Wrapper: String {
    get {
      AVVideoYCbCrMatrix_ITU_R_601_4
    }
  }
  
  @objc static public var AVVideoYCbCrMatrix_ITU_R_709_2Wrapper: String {
    get {
      AVVideoYCbCrMatrix_ITU_R_709_2
    }
  }
  
  @objc static public var AVVideoYCbCrMatrix_SMPTE_240M_1995Wrapper: String {
    get {
      AVVideoYCbCrMatrix_SMPTE_240M_1995
    }
  }
}

@objc public class AVAsyncPropertyWrapper: NSObject {
  var wrappedInstance: AVAsyncProperty
  
  init(_ wrappedInstance: AVAsyncProperty) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVAnyAsyncPropertyWrapper: NSObject {
  var wrappedInstance: AVAnyAsyncProperty
  
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }
  
  init(_ wrappedInstance: AVAnyAsyncProperty) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVPartialAsyncPropertyWrapper: NSObject {
  var wrappedInstance: AVPartialAsyncProperty
  
  @objc public var description: String {
    get {
      wrappedInstance.description
    }
  }
  
  @objc static public var tracks: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.tracks)
    }
  }
  
  @objc static public var variants: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.variants)
    }
  }
  
  @objc static public var availableTrackAssociationTypes: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.availableTrackAssociationTypes)
    }
  }
  
  @objc static public var isPlayable: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.isPlayable)
    }
  }
  
  @objc static public var isDecodable: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.isDecodable)
    }
  }
  
  @objc static public var naturalSize: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.naturalSize)
    }
  }
  
  @objc static public var languageCode: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.languageCode)
    }
  }
  
  @objc static public var commonMetadata: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.commonMetadata)
    }
  }
  
  @objc static public var isSelfContained: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.isSelfContained)
    }
  }
  
  @objc static public var preferredVolume: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.preferredVolume)
    }
  }
  
  @objc static public var minFrameDuration: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.minFrameDuration)
    }
  }
  
  @objc static public var naturalTimeScale: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.naturalTimeScale)
    }
  }
  
  @objc static public var nominalFrameRate: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.nominalFrameRate)
    }
  }
  
  @objc static public var estimatedDataRate: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.estimatedDataRate)
    }
  }
  
  @objc static public var formatDescriptions: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.formatDescriptions)
    }
  }
  
  @objc static public var preferredTransform: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.preferredTransform)
    }
  }
  
  @objc static public var extendedLanguageTag: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.extendedLanguageTag)
    }
  }
  
  @objc static public var mediaCharacteristics: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.mediaCharacteristics)
    }
  }
  
  @objc static public var totalSampleDataLength: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.totalSampleDataLength)
    }
  }
  
  @objc static public var canProvideSampleCursors: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.canProvideSampleCursors)
    }
  }
  
  @objc static public var requiresFrameReordering: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.requiresFrameReordering)
    }
  }
  
  @objc static public var availableMetadataFormats: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.availableMetadataFormats)
    }
  }
  
  @objc static public var hasAudioSampleDependencies: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.hasAudioSampleDependencies)
    }
  }
  
  @objc static public var metadata: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.metadata)
    }
  }
  
  @objc static public var segments: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.segments)
    }
  }
  
  @objc static public var isEnabled: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.isEnabled)
    }
  }
  
  @objc static public var timeRange: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.timeRange)
    }
  }
  
  @objc static public var tracks: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.tracks)
    }
  }
  
  @objc static public var numberValue: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.numberValue)
    }
  }
  
  @objc static public var stringValue: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.stringValue)
    }
  }
  
  @objc static public var extraAttributes: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.extraAttributes)
    }
  }
  
  @objc static public var value: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.value)
    }
  }
  
  @objc static public var dataValue: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.dataValue)
    }
  }
  
  @objc static public var dateValue: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.dateValue)
    }
  }
  
  @objc static public var tracks: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.tracks)
    }
  }
  
  @objc static public var tracks: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.tracks)
    }
  }
  
  @objc static public var tracks: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.tracks)
    }
  }
  
  @objc static public var tracks: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.tracks)
    }
  }
  
  @objc static public var availableMediaCharacteristicsWithMediaSelectionOptions: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.availableMediaCharacteristicsWithMediaSelectionOptions)
    }
  }
  
  @objc static public var isPlayable: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.isPlayable)
    }
  }
  
  @objc static public var isReadable: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.isReadable)
    }
  }
  
  @objc static public var trackGroups: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.trackGroups)
    }
  }
  
  @objc static public var creationDate: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.creationDate)
    }
  }
  
  @objc static public var isComposable: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.isComposable)
    }
  }
  
  @objc static public var isExportable: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.isExportable)
    }
  }
  
  @objc static public var preferredRate: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.preferredRate)
    }
  }
  
  @objc static public var commonMetadata: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.commonMetadata)
    }
  }
  
  @objc static public var preferredVolume: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.preferredVolume)
    }
  }
  
  @objc static public var containsFragments: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.containsFragments)
    }
  }
  
  @objc static public var allMediaSelections: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.allMediaSelections)
    }
  }
  
  @objc static public var preferredTransform: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.preferredTransform)
    }
  }
  
  @objc static public var canContainFragments: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.canContainFragments)
    }
  }
  
  @objc static public var hasProtectedContent: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.hasProtectedContent)
    }
  }
  
  @objc static public var overallDurationHint: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.overallDurationHint)
    }
  }
  
  @objc static public var availableChapterLocales: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.availableChapterLocales)
    }
  }
  
  @objc static public var preferredMediaSelection: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.preferredMediaSelection)
    }
  }
  
  @objc static public var availableMetadataFormats: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.availableMetadataFormats)
    }
  }
  
  @objc static public var minimumTimeOffsetFromLive: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.minimumTimeOffsetFromLive)
    }
  }
  
  @objc static public var isCompatibleWithAirPlayVideo: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.isCompatibleWithAirPlayVideo)
    }
  }
  
  @objc static public var providesPreciseDurationAndTiming: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.providesPreciseDurationAndTiming)
    }
  }
  
  @objc static public var lyrics: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.lyrics)
    }
  }
  
  @objc static public var tracks: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.tracks)
    }
  }
  
  @objc static public var duration: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.duration)
    }
  }
  
  @objc static public var metadata: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.metadata)
    }
  }
  
  @objc static public var tracks: AVAsyncPropertyWrapper {
    get {
      AVAsyncPropertyWrapper(AVPartialAsyncProperty.tracks)
    }
  }
  
  init(_ wrappedInstance: AVPartialAsyncProperty) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class AVErrorWrapper: NSObject {
  var wrappedInstance: AVError
  
  @objc static public var errorDomain: String {
    get {
      AVError.errorDomain
    }
  }
  
  @objc static public var errorDomain: String {
    get {
      AVError.errorDomain
    }
  }
  
  @objc static public var outOfMemory: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.outOfMemory)
    }
  }
  
  @objc public var mediaSubtypes: Int {
    get {
      wrappedInstance.mediaSubtypes
    }
  }
  
  @objc public var recordingSuccessfullyFinished: Bool {
    get {
      wrappedInstance.recordingSuccessfullyFinished
    }
  }
  
  @objc public var device: String {
    get {
      wrappedInstance.device
    }
  }
  
  @objc public var device: AVCaptureDeviceWrapper {
    get {
      AVCaptureDeviceWrapper(wrappedInstance.device)
    }
  }
  
  @objc public var fileType: AVFileTypeWrapper {
    get {
      AVFileTypeWrapper(wrappedInstance.fileType)
    }
  }
  
  @objc public var mediaType: String {
    get {
      wrappedInstance.mediaType
    }
  }
  
  @objc public var mediaType: AVMediaTypeWrapper {
    get {
      AVMediaTypeWrapper(wrappedInstance.mediaType)
    }
  }
  
  @objc public var processID: Int {
    get {
      wrappedInstance.processID
    }
  }
  
  @objc static public var decodeFailed: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.decodeFailed)
    }
  }
  
  @objc static public var encodeFailed: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.encodeFailed)
    }
  }
  
  @objc static public var exportFailed: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.exportFailed)
    }
  }
  
  @objc static public var mediaChanged: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.mediaChanged)
    }
  }
  
  @objc static public var failedToParse: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.failedToParse)
    }
  }
  
  @objc static public var noImageAtTime: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.noImageAtTime)
    }
  }
  
  @objc static public var noSourceTrack: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.noSourceTrack)
    }
  }
  
  @objc static public var malformedDepth: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.malformedDepth)
    }
  }
  
  @objc static public var noDataCaptured: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.noDataCaptured)
    }
  }
  
  @objc static public var decoderNotFound: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.decoderNotFound)
    }
  }
  
  @objc static public var encoderNotFound: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.encoderNotFound)
    }
  }
  
  @objc static public var noLongerPlayable: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.noLongerPlayable)
    }
  }
  
  @objc static public var contentNotUpdated: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.contentNotUpdated)
    }
  }
  
  @objc static public var fileAlreadyExists: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.fileAlreadyExists)
    }
  }
  
  @objc static public var fileFailedToParse: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.fileFailedToParse)
    }
  }
  
  @objc static public var formatUnsupported: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.formatUnsupported)
    }
  }
  
  @objc static public var incompatibleAsset: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.incompatibleAsset)
    }
  }
  
  @objc static public var sessionNotRunning: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.sessionNotRunning)
    }
  }
  
  @objc static public var contentIsProtected: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.contentIsProtected)
    }
  }
  
  @objc static public var deviceNotConnected: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.deviceNotConnected)
    }
  }
  
  @objc static public var displayWasDisabled: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.displayWasDisabled)
    }
  }
  
  @objc static public var invalidSourceMedia: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.invalidSourceMedia)
    }
  }
  
  @objc static public var mediaDiscontinuity: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.mediaDiscontinuity)
    }
  }
  
  @objc static public var operationCancelled: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.operationCancelled)
    }
  }
  
  @objc static public var invalidSampleCursor: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.invalidSampleCursor)
    }
  }
  
  @objc static public var operationNotAllowed: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.operationNotAllowed)
    }
  }
  
  @objc static public var rosettaNotInstalled: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.rosettaNotInstalled)
    }
  }
  
  @objc static public var screenCaptureFailed: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.screenCaptureFailed)
    }
  }
  
  @objc static public var contentIsUnavailable: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.contentIsUnavailable)
    }
  }
  
  @objc static public var undecodableMediaData: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.undecodableMediaData)
    }
  }
  
  @objc static public var deviceWasDisconnected: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.deviceWasDisconnected)
    }
  }
  
  @objc static public var failedToLoadMediaData: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.failedToLoadMediaData)
    }
  }
  
  @objc static public var incorrectlyConfigured: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.incorrectlyConfigured)
    }
  }
  
  @objc static public var torchLevelUnavailable: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.torchLevelUnavailable)
    }
  }
  
  @objc static public var videoCompositorFailed: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.videoCompositorFailed)
    }
  }
  
  @objc static public var contentIsNotAuthorized: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.contentIsNotAuthorized)
    }
  }
  
  @objc static public var failedToLoadSampleData: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.failedToLoadSampleData)
    }
  }
  
  @objc static public var maximumDurationReached: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.maximumDurationReached)
    }
  }
  
  @objc static public var maximumFileSizeReached: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.maximumFileSizeReached)
    }
  }
  
  @objc static public var sandboxExtensionDenied: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.sandboxExtensionDenied)
    }
  }
  
  @objc static public var fileFormatNotRecognized: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.fileFormatNotRecognized)
    }
  }
  
  @objc static public var invalidVideoComposition: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.invalidVideoComposition)
    }
  }
  
  @objc static public var unsupportedOutputSettings: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.unsupportedOutputSettings)
    }
  }
  
  @objc static public var applicationIsNotAuthorized: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.applicationIsNotAuthorized)
    }
  }
  
  @objc static public var contentKeyRequestCancelled: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.contentKeyRequestCancelled)
    }
  }
  
  @objc static public var serverIncorrectlyConfigured: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.serverIncorrectlyConfigured)
    }
  }
  
  @objc static public var sessionConfigurationChanged: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.sessionConfigurationChanged)
    }
  }
  
  @objc static public var createContentKeyRequestFailed: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.createContentKeyRequestFailed)
    }
  }
  
  @objc static public var decoderTemporarilyUnavailable: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.decoderTemporarilyUnavailable)
    }
  }
  
  @objc static public var encoderTemporarilyUnavailable: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.encoderTemporarilyUnavailable)
    }
  }
  
  @objc static public var invalidOutputURLPathExtension: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.invalidOutputURLPathExtension)
    }
  }
  
  @objc static public var operationNotSupportedForAsset: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.operationNotSupportedForAsset)
    }
  }
  
  @objc static public var operationNotSupportedForPreset: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.operationNotSupportedForPreset)
    }
  }
  
  @objc static public var airPlayReceiverRequiresInternet: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.airPlayReceiverRequiresInternet)
    }
  }
  
  @objc static public var deviceInUseByAnotherApplication: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.deviceInUseByAnotherApplication)
    }
  }
  
  @objc static public var segmentStartedWithNonSyncSample: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.segmentStartedWithNonSyncSample)
    }
  }
  
  @objc static public var airPlayControllerRequiresInternet: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.airPlayControllerRequiresInternet)
    }
  }
  
  @objc static public var deviceAlreadyUsedByAnotherSession: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.deviceAlreadyUsedByAnotherSession)
    }
  }
  
  @objc static public var referenceForbiddenByReferencePolicy: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.referenceForbiddenByReferencePolicy)
    }
  }
  
  @objc static public var externalPlaybackNotSupportedForAsset: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.externalPlaybackNotSupportedForAsset)
    }
  }
  
  @objc static public var airPlayReceiverTemporarilyUnavailable: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.airPlayReceiverTemporarilyUnavailable)
    }
  }
  
  @objc static public var applicationIsNotAuthorizedToUseDevice: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.applicationIsNotAuthorizedToUseDevice)
    }
  }
  
  @objc static public var compositionTrackSegmentsNotContiguous: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.compositionTrackSegmentsNotContiguous)
    }
  }
  
  @objc static public var fileTypeDoesNotSupportSampleReferences: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.fileTypeDoesNotSupportSampleReferences)
    }
  }
  
  @objc static public var invalidCompositionTrackSegmentDuration: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.invalidCompositionTrackSegmentDuration)
    }
  }
  
  @objc static public var maximumStillImageCaptureRequestsExceeded: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.maximumStillImageCaptureRequestsExceeded)
    }
  }
  
  @objc static public var noCompatibleAlternatesForExternalDisplay: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.noCompatibleAlternatesForExternalDisplay)
    }
  }
  
  @objc static public var maximumNumberOfSamplesForFileFormatReached: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.maximumNumberOfSamplesForFileFormatReached)
    }
  }
  
  @objc static public var deviceLockedForConfigurationByAnotherProcess: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.deviceLockedForConfigurationByAnotherProcess)
    }
  }
  
  @objc static public var invalidCompositionTrackSegmentSourceDuration: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.invalidCompositionTrackSegmentSourceDuration)
    }
  }
  
  @objc static public var invalidCompositionTrackSegmentSourceStartTime: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.invalidCompositionTrackSegmentSourceStartTime)
    }
  }
  
  @objc static public var unknown: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.unknown)
    }
  }
  
  @objc static public var diskFull: AVErrorWrapper {
    get {
      AVErrorWrapper(AVError.diskFull)
    }
  }
  
  @objc public var localizedDescription: String {
    get {
      wrappedInstance.localizedDescription
    }
  }
  
  init(_ wrappedInstance: AVError) {
    self.wrappedInstance = wrappedInstance
  }
}

@objc public class ImagesWrapper: NSObject {
  var wrappedInstance: AVAssetImageGenerator.Images
  
  init(_ wrappedInstance: AVAssetImageGenerator.Images) {
    self.wrappedInstance = wrappedInstance
  }
  
  @objc public func makeAsyncIterator() -> AVAssetImageGeneratorWrapper {
    let result = wrappedInstance.makeAsyncIterator()
    return AVAssetImageGeneratorWrapper(result)
  }
  
  @objc public func next() -> AVAssetImageGeneratorWrapper {
    let result = wrappedInstance.next()
    return AVAssetImageGeneratorWrapper(result)
  }
}
