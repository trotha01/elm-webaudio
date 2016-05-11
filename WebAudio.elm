module WebAudio exposing (..)

{-| A module for accessing the Web Audio API via Elm.

# Getting Started

First, you will need an `AudioContext`. There are two types of contexts:
a standard context (which outputs to the user's audio device - speakers,
headphones, etc), and an "offline" context which renders audio to a buffer.
It is fairly rare that you would need more than one standard context, and, so
this library provides a convenience context called the `DefaultContext`. Think
of the `DefaultContext` as a singleton for a standard context.

I highly recommend you read through the Web Audio API documentation to
familiarize yourself with the concepts. You can find the documentation here:
http://webaudio.github.io/web-audio-api/

@docs AudioContext, createContext, createOfflineContext, getSampleRate, getCurrentTime

# Special Notes

Most "set" functions take the object whose value is being set as the last
parameter, and then the function returns that same object to facilitate
function chaining using the "|>" operator.

# Audio Params

Most parameters for various Audio Nodes are actually "AudioParams". These
allow you to either set a constant value, or schedule changes to the value at
appropriate times. All times are relative to the AudioContext's current time.
If you try to schedule a change for a time that has already passed, the change
will take effect immediately.

The documentation below will note if the node has any AudioParams that you can
modify in the form of a bulleted list. These params can be accessed using the
record notation. For example, a Biquad Filter Node has a "frequency" param. It
could be accessed with: `node.frequency`

@docs AudioParam, setValue, getValue, setValueAtTime, linearRampToValue, exponentialRampToValue, setTargetAtTime, setValueCurveAtTime, cancelScheduledValues

# Adding missing functions
@docs MediaStreamAudioSourceNode, OfflineAudioContext, startOfflineRendering

# Audio Buffers

An `AudioBuffer` stores audio data in memory in a PCM format with a range of
-1 to 1. AudioBuffers may contain multiple channels. Typically, AudioBuffers
are used for "short" audio clips (less than a minute) because the entire file
must be loaded before the audio can be played. An HTMLMediaElement, such as
the HTML `audio` tag handled by the MediaElementAudioSourceNode, is typically
used for longer audio clips because it supports streaming.

There are many ways to create AudioBuffers, some of which are beyond the scope
of this library. However, this library does have a few functions available to
load audio files into buffers. If you have a need to create an AudioBuffer in a
way this library does not directly support, the Native library contains a
function called `createAudioBuffer` that takes an AudioBuffer and returns an
AudioBuffer compatible with this library.

@docs AudioBuffer, getBufferSampleRate, getBufferLength, getBufferDuration, getBufferNumberOfChannels, getChannelData, getChannelDataSlice, setChannelDataSlice

# Audio Nodes

Once you have your AudioContext, you can begin to build your graph of Audio
Nodes.

@docs AudioNode, ChannelCountMode, ChannelInterpretation, connectNodes, connectToParam, getChannelCount, setChannelCount, getChannelCountMode, setChannelCountMode, getChannelInterpretation, setChannelInterpretation, tapNode

# Analyser Nodes

@docs AnalyserNode, createAnalyserNode, getFFTSize, setFFTSize, getMaxDecibels, setMaxDecibels, getMinDecibels, setMinDecibels, getSmoothingConstant, setSmoothingConstant, getByteFrequencyData, getByteTimeDomainData, getFloatFrequencyData, getFloatTimeDomainData

# Audio Buffer Source Nodes

@docs AudioBufferSourceNode, createAudioBufferSourceNode, getAudioBufferFromNode, setAudioBufferForNode, getAudioBufferIsLooping, setAudioBufferIsLooping, getAudioBufferLoopStart, setAudioBufferLoopStart, getAudioBufferLoopEnd, setAudioBufferLoopEnd, startAudioBufferNode, stopAudioBufferNode

# Audio Destination Nodes

Each Audio Context has only one Audio Destination Node.

@docs AudioDestinationNode, getDestinationNode, getMaxChannelCount

# Audio Worker Node

These nodes are currently unimplemented.

# Biquad Filter Nodes

Biquad Filter Nodes have the following AudioParams:

* frequency
* detune
* q
* gain

@docs BiquadFilterNode, BiquadFilterType, createBiquadFilterNode, getFilterType, setFilterType

# Channel Merger Nodes

@docs ChannelMergerNode, createChannelMergerNode

# Channel Splitter Nodes

@docs ChannelSplitterNode, createChannelSplitterNode

# Convolver Nodes

These nodes are currently unimplemented.

# Delay Nodes

Delay Nodes have the following AudioParams:

* delayTime

@docs DelayNode, createDelayNode

# Dynamics Compressor Nodes

Dynamics Compressor Nodes have the following AudioParams:

* threshold
* knee
* ratio
* reduction
* attack
* release

@docs DynamicsCompressorNode, createDynamicsCompressorNode

# Gain Nodes

Gain Nodes have the following AudioParams:

* gain

@docs GainNode, createGainNode

# Media Element Audio Source Nodes

Media Element Audio Source Nodes connect HTMLMediaElements to the audio graph.
This is the preferred way to connect a "long" audio file to the audio graph.
HTMLMediaElements are things like the HTML video or audio tags, and creating
these tags is a bit beyond the scope of this library. However, this library
does have a convenience method for creating a "hidden" audio tag that will not
be added to the page, but will load an audio file via the HTMLMediaElement
interface thus gaining the benefits of streaming, etc.

The Native library also includes a function called `createMediaElementSourceNode`
that takes an instance of HTMLMediaElement (which you might get from doing a
`document.getElementById()` or from creating an element with `document.createElement`)
and returns a MediaElementAudioSourceNode. You could use this in your own code
to create a MediaElementAudioSourceNode from an audio (or video) tag that you
have created using other means.

@docs MediaElementAudioSourceNode, createHiddenMediaElementAudioSourceNode, getMediaElementIsLooping, setMediaElementIsLooping, getMediaElementSource, setMediaElementSource, playMediaElement, pauseMediaElement

# Media Stream Audio Destination Nodes

These nodes are currently unimplemented.

# Media Stream Audio Source Nodes

These nodes are currently unimplemented.

# Oscillator Nodes

Oscillator Nodes have the following AudioParams:

* frequency
* detune

@docs OscillatorNode, OscillatorWaveType, createOscillatorNode, getOscillatorWaveType, setOscillatorWaveType, startOscillator, stopOscillator

# Panner Nodes

@docs PannerNode, PanningModel, DistanceModel, createPannerNode, getPanningModel, setPanningModel, getDistanceModel, setDistanceModel, getReferenceDistance, setReferenceDistance, getMaxDistance, setMaxDistance, getRolloffFactor, setRolloffFactor, getConeInnerAngle, setConeInnerAngle, getConeOuterAngle, setConeOuterAngle, getConeOuterGain, setConeOuterGain, setPosition, setOrientation, setVelocity

# Script Processor Nodes

These nodes are deprecated and, thus, unimplemented. See: Audio Worker Nodes

# Wave Shaper Nodes

These nodes are currently unimplemented.

-}

import Native.WebAudio
-- import UserMedia exposing (MediaStream)


{-| The AudioContext

Think of the `DefaultContext` as a global singleton. Just use the `DefaultContext`
unless there's some reason you need to have more than one context.
-}
type AudioContext
  = AudioContext
  | DefaultContext


{-| Create a new AudioContext

Instead of creating a context, you can use the `DefaultContext`. The
`DefaultContext` is like a singleton instance of an AudioContext and would be
sufficient for most people.
-}
createContext : () -> AudioContext
createContext =
  Native.WebAudio.createContext


{-| Get the context's sample rate
-}
getSampleRate : AudioContext -> Float
getSampleRate =
  Native.WebAudio.getSampleRate


{-| Get the context's current time
-}
getCurrentTime : AudioContext -> Float
getCurrentTime =
  Native.WebAudio.getCurrentTime


{-| The OfflineAudioContext
-}
type alias OfflineAudioContext =
  { context : AudioContext, signal : (Maybe AudioBuffer) }


{-| Create a new Offline AudioContext

Parameters are: the number of channels, length of the buffer in sample frames,
and the sample rate in Hz. Offline Audio Contexts return a record with two
fields:

* returnedValue.context is the AudioContext
* returnedValue.signal is a signal that is raised when the Offline Audio
  Context has finished rendering audio to the AudioBuffer
-}
createOfflineContext : Int -> Int -> Float -> OfflineAudioContext
createOfflineContext =
  Native.WebAudio.createOfflineContext


{-| Begin rendering audio in an Offline Audio Context

When rendering has finished, the context.signal `Signal` will raise.
-}
startOfflineRendering : OfflineAudioContext -> OfflineAudioContext
startOfflineRendering =
  Native.WebAudio.startOfflineRendering


{-| AudioParams

An AudioParam is used in a lot of places to allow you to either set a static
value (such as a frequency, gain, etc), or to schedule changes over time.
-}
type AudioParam
  = AudioParam String


{-| Set the static value of the param
-}
setValue : Float -> AudioParam -> AudioParam
setValue =
  Native.WebAudio.setValue


{-| Get the current value of the param
-}
getValue : AudioParam -> Float
getValue =
  Native.WebAudio.getValue


{-| Schedule the AudioParam to change values at a specific time
-}
setValueAtTime : Float -> Float -> AudioParam -> AudioParam
setValueAtTime =
  Native.WebAudio.setValueAtTime


{-| Schedule the AudioParam to linearly ramp to a new value, finishing at the
specified time.
-}
linearRampToValue : Float -> Float -> AudioParam -> AudioParam
linearRampToValue =
  Native.WebAudio.linearRampToValue


{-| Schedule the AudioParam to exponentially ramp to a new value, finishing at
the specified time.
-}
exponentialRampToValue : Float -> Float -> AudioParam -> AudioParam
exponentialRampToValue =
  Native.WebAudio.exponentialRampToValue


{-| Schedule the AudioParam to exponentially approach the target, starting at
the specified time. The "constant" determines how quickly the value changes
with the value changing roughly 63.2% in the first time constant.
-}
setTargetAtTime : Float -> Float -> Float -> AudioParam -> AudioParam
setTargetAtTime =
  Native.WebAudio.setTargetAtTime


{-| Schedule a curve of values to start at the given time and run for the
specified duration. Each value will take effect for N / duration seconds.
-}
setValueCurveAtTime : List Float -> Float -> Float -> AudioParam -> AudioParam
setValueCurveAtTime =
  Native.WebAudio.setValueCurveAtTime


{-| Cancel all scheduled changes at and after the specified time.
-}
cancelScheduledValues : Float -> AudioParam -> AudioParam
cancelScheduledValues =
  Native.WebAudio.cancelScheduledValues


{-| AudioBuffers
-}
type AudioBuffer
  = AudioBuffer


{- Load an Audio Buffer from a URL
loadAudioBufferFromUrl : AudioContext -> String -> Signal (Maybe AudioBuffer)
loadAudioBufferFromUrl =
  Native.WebAudio.loadAudioBufferFromUrl
-}


{-| Retrieve the sample rate of the AudioBuffer
-}
getBufferSampleRate : AudioBuffer -> Float
getBufferSampleRate =
  Native.WebAudio.getBufferSampleRate


{-| Get the length of the AudioBuffer in sample frames
-}
getBufferLength : AudioBuffer -> Int
getBufferLength =
  Native.WebAudio.getBufferLength


{-| Get the duration of the AudioBuffer in seconds
-}
getBufferDuration : AudioBuffer -> Float
getBufferDuration =
  Native.WebAudio.getBufferDuration


{-| Retrieve the number of channels in the AudioBuffer
-}
getBufferNumberOfChannels : AudioBuffer -> Int
getBufferNumberOfChannels =
  Native.WebAudio.getBufferNumberOfChannels


{-| Get the buffer's data for the specified channel into an array
-}
getChannelData : Int -> AudioBuffer -> List Float
getChannelData =
  Native.WebAudio.getChannelData


{-| Get a slice of channel data from the buffer.

This is more efficient than getting all of the channel data if you only need
a small chunk of it. Parameters are:

* Channel number, starting with 0
* What sample frame to start with
* How many frames to return
* The AudioBuffer
-}
getChannelDataSlice : Int -> Int -> Int -> AudioBuffer -> List Float
getChannelDataSlice =
  Native.WebAudio.getChannelDataSlice


{-| Set a slice of channel data in the buffer.

This method allows you to modify the channel data. Parameters are:

* Channel number, starting with 0
* The starting frame to modify
* The new channel data
* The AudioBuffer
-}
setChannelDataSlice : Int -> Int -> List Float -> AudioBuffer -> AudioBuffer
setChannelDataSlice =
  Native.WebAudio.setChannelDataSlice


{-| AudioNodes

AudioNodes make up the building blocks of your audio signal graph. There are
source nodes which produce an audio stream, destination nodes which can create
sound from the stream, and processing nodes which allow you to modify the
stream such as filters, delays, and effects.

Audio Nodes have the following properties:
  * inputs: The number of inputs for this node. 0 means this is a source node.
  * outputs: The number of outputs for this node. 0 means this is a destination
    node.
-}
type alias AudioNode a =
  { a | inputs : Int, outputs : Int }


{-| How channels are counted during up-mixing and down-mixing
-}
type ChannelCountMode
  = Max
  | ClampedMax
  | Explicit


{-| How individual channels are treated when up-mixing and down-mixing
-}
type ChannelInterpretation
  = Speakers
  | Discrete


{-| Connect Audio Nodes

An output of node1 will be connected to an input of node2. You may specify the
index of the output to connect, and the index of the input. These indexes are
zero based. Fan-in and fan-out are both supported, so the output of a node can
be connected to multiple nodes, and multiple nodes can be connected to a single
input. This function will return node1 for chaining.
-}
connectNodes : AudioNode b -> Int -> Int -> AudioNode a -> AudioNode a
connectNodes =
  Native.WebAudio.connectNodes


{-| Connect an Audio Node to an Audio Param

The signal from an AudioNode may be fed into an AudioParam to control the
parameter value. You may also specify which output index to connect. The index
is zero based. Fan-in and fan-out are both supported, so the output of a node
can be connected to multiple AudioParams, and multiple AudioParams can be
connected to a single node. This function will return the node for chaining.
-}
connectToParam : AudioParam b -> Int -> AudioNode a -> AudioNode a
connectToParam =
  Native.WebAudio.connectToParam


{-| Get a Node's Channel Count

The number of channels used when up-mixing or down-mixing inputs. The default
is 2 for most nodes, but some nodes determine this based on other settings. If
the node has no inputs, this setting has no effect.
-}
getChannelCount : AudioNode a -> Int
getChannelCount =
  Native.WebAudio.getChannelCount


{-| Set a Node's Channel Count

The number of channels used when up-mixing or down-mixing inputs. The default
is 2 for most nodes, but some nodes determine this based on other settings. If
the node has no inputs, this setting has no effect.
-}
setChannelCount : Int -> AudioNode a -> AudioNode a
setChannelCount =
  Native.WebAudio.setChannelCount


{-| Get a Node's Channel Count Mode
@docs ChannelCountMode
-}
getChannelCountMode : AudioNode a -> ChannelCountMode
getChannelCountMode =
  Native.WebAudio.getChannelCountMode


{-| Set a Node's Channel Count Mode - returns the node itself for chaining.
@docs ChannelCountMode
-}
setChannelCountMode : ChannelCountMode -> AudioNode a -> AudioNode a
setChannelCountMode =
  Native.WebAudio.setChannelCountMode


{-| Get a Node's Channel Interpretation
@docs ChannelInterpretation
-}
getChannelInterpretation : AudioNode a -> ChannelInterpretation
getChannelInterpretation =
  Native.WebAudio.getChannelInterpretation


{-| Set a Node's Channel Interpretation - returns the node itself for chaining.
@docs ChannelInterpretation
-}
setChannelInterpretation : ChannelInterpretation -> AudioNode a -> AudioNode a
setChannelInterpretation =
  Native.WebAudio.setChannelInterpretation


{-| "Tap" a node

This is a convenience function, making it easy to access one of the node's
AudioParam properties and then return the node itself at the end so you can
continue to chain more functions.

For example, if "node" is an OscillatorNode:

```haskell
tapNode .frequency (\f -> setValue 440.0 f) node |> startOscillator 0.0
```
-}
tapNode : (a -> b) -> (b -> c) -> a -> a
tapNode f t n =
  let
    _ =
      t <| f n
  in
    n


{-| Type of an AnalyserNode
-}
type alias AnalyserNode =
  AudioNode {}


{-| Create an AnalyserNode
-}
createAnalyserNode : AudioContext -> AnalyserNode
createAnalyserNode =
  Native.WebAudio.createAnalyserNode


{-| Get the FFT Size of an Analyser Node
-}
getFFTSize : AnalyserNode -> Int
getFFTSize =
  Native.WebAudio.getFFTSize


{-| Set the FFT Size of an Analyser Node

The FFT Size must be a power of 2 between 32 to 2048. Default is 2048. This
function returns the AnalyserNode for chaining
-}
setFFTSize : Int -> AnalyserNode -> AnalyserNode
setFFTSize =
  Native.WebAudio.setFFTSize


{-| Get the maximum power in the scaling range of the AnalyserNode
-}
getMaxDecibels : AnalyserNode -> Float
getMaxDecibels =
  Native.WebAudio.getMaxDecibels


{-| Set the maximum power in the scaling range of the AnalyserNode

The default is -30. This function returns the AnalyserNode for chaining.
-}
setMaxDecibels : Float -> AnalyserNode -> AnalyserNode
setMaxDecibels =
  Native.WebAudio.setMaxDecibels


{-| Get the minimum power in the scaling range of the AnalyserNode
-}
getMinDecibels : AnalyserNode -> Float
getMinDecibels =
  Native.WebAudio.getMinDecibels


{-| Set the minimum power in the scaling range of the AnalyserNode

The default is -100. This function returns the AnalyserNode for chaining.
-}
setMinDecibels : Float -> AnalyserNode -> AnalyserNode
setMinDecibels =
  Native.WebAudio.setMinDecibels


{-| Get the smoothing constant for the AnalyserNode
-}
getSmoothingConstant : AnalyserNode -> Float
getSmoothingConstant =
  Native.WebAudio.getSmoothingConstant


{-| Set the smoothing constant for the AnalyserNode

A value from 0 to 1, where 0 represents no averaging. Default is 0.8. This
function returns the AnalyserNode for chaining.
-}
setSmoothingConstant : Float -> AnalyserNode -> AnalyserNode
setSmoothingConstant =
  Native.WebAudio.setSmoothingConstant


{-| Get frequency data from the AnalyserNode

A value of 0 equals the minDecibels setting, and a value of 255 equals the
maxDecibels setting.
-}
getByteFrequencyData : AnalyserNode -> List Int
getByteFrequencyData =
  Native.WebAudio.getByteFrequencyData


{-| Get time domain data from the AnalyserNode

A value of 0 equals the minDecibels setting, and a value of 255 equals the
maxDecibels setting.
-}
getByteTimeDomainData : AnalyserNode -> List Int
getByteTimeDomainData =
  Native.WebAudio.getByteTimeDomainData


{-| Get frequency data from the AnalyserNode

Values are in the range of minDecibels to maxDecibels.
-}
getFloatFrequencyData : AnalyserNode -> List Float
getFloatFrequencyData =
  Native.WebAudio.getFloatFrequencyData


{-| Get time domain data from the AnalyserNode

Values are in the range of minDecibels to maxDecibels.
-}
getFloatTimeDomainData : AnalyserNode -> List Float
getFloatTimeDomainData =
  Native.WebAudio.getFloatTimeDomainData


{-| Type of an AudioBufferSourceNode
-}
type alias AudioBufferSourceNode =
  AudioNode { playbackRate : AudioParam, ended : Bool }


{-| Create an AudioBufferSourceNode
-}
createAudioBufferSourceNode : AudioContext -> AudioBufferSourceNode
createAudioBufferSourceNode =
  Native.WebAudio.createAudioBufferSourceNode


{-| Get the AudioBuffer associated with the AudioBufferSourceNode
-}
getAudioBufferFromNode : AudioBufferSourceNode -> AudioBuffer
getAudioBufferFromNode =
  Native.WebAudio.getAudioBufferFromNode


{-| Set the AudioBuffer associated with the AudioBufferSourceNode
-}
setAudioBufferForNode : AudioBuffer -> AudioBufferSourceNode -> AudioBufferSourceNode
setAudioBufferForNode =
  Native.WebAudio.setAudioBufferForNode


{-| Get whether or not the AudioBufferSourceNode is looping.
-}
getAudioBufferIsLooping : AudioBufferSourceNode -> Bool
getAudioBufferIsLooping =
  Native.WebAudio.getAudioBufferIsLooping


{-| Set whether or not the AudioBufferSourceNode should loop.
-}
setAudioBufferIsLooping : Bool -> AudioBufferSourceNode -> AudioBufferSourceNode
setAudioBufferIsLooping =
  Native.WebAudio.setAudioBufferIsLooping


{-| Get the starting point for looping in seconds.
-}
getAudioBufferLoopStart : AudioBufferSourceNode -> Float
getAudioBufferLoopStart =
  Native.WebAudio.getAudioBufferLoopStart


{-| Set the starting point for looping in seconds.
-}
setAudioBufferLoopStart : Float -> AudioBufferSourceNode -> AudioBufferSourceNode
setAudioBufferLoopStart =
  Native.WebAudio.setAudioBufferLoopStart


{-| Get the ending point for the looping in seconds.
-}
getAudioBufferLoopEnd : AudioBufferSourceNode -> Float
getAudioBufferLoopEnd =
  Native.WebAudio.getAudioBufferLoopEnd


{-| Set the ending point for the looping in seconds.
-}
setAudioBufferLoopEnd : Float -> AudioBufferSourceNode -> AudioBufferSourceNode
setAudioBufferLoopEnd =
  Native.WebAudio.setAudioBufferLoopEnd


{-| Start the AudioBufferSourceNode

The parameters are:
* The start time, relative to the context's current time
* The offset into the AudioBuffer to start at, in seconds
* The duration to play - if Nothing, plays until the end
-}
startAudioBufferNode : Float -> Float -> Maybe Float -> AudioBufferSourceNode -> AudioBufferSourceNode
startAudioBufferNode =
  Native.WebAudio.startAudioBufferNode


{-| Stops the AudioBufferSourceNode

You may specify when to stop it.
-}
stopAudioBufferNode : Float -> AudioBufferSourceNode -> AudioBufferSourceNode
stopAudioBufferNode =
  Native.WebAudio.stopAudioBufferNode


{-| Type of an AudioDestinationNode
-}
type alias AudioDestinationNode =
  AudioNode {}


{-| Get the AudioDestinationNode for the given context

Each context has only one AudioDestinationNode.
-}
getDestinationNode : AudioContext -> AudioDestinationNode
getDestinationNode =
  Native.WebAudio.getDestinationNode


{-| Get the maximum number of channels
-}
getMaxChannelCount : AudioDestinationNode -> Int
getMaxChannelCount =
  Native.WebAudio.getMaxChannelCount



{- TODO: Type of an AudioWorkerNode -}


{-| Type of a BiquadFilterNode
-}
type alias BiquadFilterNode =
  AudioNode { frequency : AudioParam, detune : AudioParam, q : AudioParam, gain : AudioParam }


{-| Biquad Filter Type
-}
type BiquadFilterType
  = LowPass
  | HighPass
  | BandPass
  | LowShelf
  | HighShelf
  | Peaking
  | Notch
  | AllPass


{-| Create a BiquadFilterNode
-}
createBiquadFilterNode : AudioContext -> BiquadFilterNode
createBiquadFilterNode =
  Native.WebAudio.createBiquadFilterNode


{-| Get the type of the BiquadFilterNode
-}
getFilterType : BiquadFilterNode -> BiquadFilterType
getFilterType =
  Native.WebAudio.getFilterType


{-| Set the type of the BiquadFilterNode

The type of filter determines what the parameters mean. This function returns
the BiquadFilterNode for chaining.
-}
setFilterType : BiquadFilterType -> BiquadFilterNode -> BiquadFilterNode
setFilterType =
  Native.WebAudio.setFilterType


{-| Type of a ChannelMergerNode
-}
type alias ChannelMergerNode =
  AudioNode {}


{-| Create a ChannelMergerNode

You may specify the number of inputs as the second parameter.
-}
createChannelMergerNode : AudioContext -> Int -> ChannelMergerNode
createChannelMergerNode =
  Native.WebAudio.createChannelMergerNode


{-| Type of a ChannelSplitterNode
-}
type alias ChannelSplitterNode =
  AudioNode {}


{-| Create a ChannelSplitterNode

You may specify the number of outputs as the second parameter
-}
createChannelSplitterNode : AudioContext -> Int -> ChannelSplitterNode
createChannelSplitterNode =
  Native.WebAudio.createChannelSplitterNode



{- TODO: Type of a ConvolverNode -}


{-| Type of a DelayNode
-}
type alias DelayNode =
  AudioNode { delayTime : AudioParam }


{-| Create a DelayNode

You may specify the maximum delay time as the second parameter.
-}
createDelayNode : AudioContext -> Float -> DelayNode
createDelayNode =
  Native.WebAudio.createDelayNode


{-| Type of a DynamicsCompressorNode
-}
type alias DynamicsCompressorNode =
  AudioNode { threshold : AudioParam, knee : AudioParam, ratio : AudioParam, reduction : AudioParam, attack : AudioParam, release : AudioParam }


{-| Create a DynamicsCompressorNode
-}
createDynamicsCompressorNode : AudioContext -> DynamicsCompressorNode
createDynamicsCompressorNode =
  Native.WebAudio.createDynamicsCompressorNode


{-| Type of a GainNode
-}
type alias GainNode =
  AudioNode { gain : AudioParam }


{-| Create a GainNode
-}
createGainNode : AudioContext -> GainNode
createGainNode =
  Native.WebAudio.createGainNode


{-| Type of a MediaElementAudioSourceNode
-}
type alias MediaElementAudioSourceNode =
  AudioNode {}


{-| Create a MediaElementAudioSourceNode using a hidden audio tag
-}
createHiddenMediaElementAudioSourceNode : AudioContext -> MediaElementAudioSourceNode
createHiddenMediaElementAudioSourceNode =
  Native.WebAudio.createHiddenMediaElementAudioSourceNode


{-| Get whether or not the MediaElementAudioSourceNode should loop
-}
getMediaElementIsLooping : MediaElementAudioSourceNode -> Bool
getMediaElementIsLooping =
  Native.WebAudio.getMediaElementIsLooping


{-| Set whether or not the MediaElementAudioSourceNode should loop
-}
setMediaElementIsLooping : Bool -> MediaElementAudioSourceNode -> MediaElementAudioSourceNode
setMediaElementIsLooping =
  Native.WebAudio.setMediaElementIsLooping


{-| Get the source of the MediaElementAudioSourceNode
-}
getMediaElementSource : MediaElementAudioSourceNode -> String
getMediaElementSource =
  Native.WebAudio.getMediaElementSource


{-| Set the source of the MediaElementAudioSourceNode
-}
setMediaElementSource : String -> MediaElementAudioSourceNode -> MediaElementAudioSourceNode
setMediaElementSource =
  Native.WebAudio.setMediaElementSource


{-| Play the MediaElementAudioSourceNode
-}
playMediaElement : MediaElementAudioSourceNode -> MediaElementAudioSourceNode
playMediaElement =
  Native.WebAudio.playMediaElement


{-| Pause the MediaElementAudioSourceNode
-}
pauseMediaElement : MediaElementAudioSourceNode -> MediaElementAudioSourceNode
pauseMediaElement =
  Native.WebAudio.pauseMediaElement


{-| TODO: add documentation here
-}
type alias MediaStreamAudioSourceNode =
  AudioNode {}


{- TODO: add documentation here
createMediaStreamAudioSourceNode : AudioContext -> MediaStream -> MediaStreamAudioSourceNode
createMediaStreamAudioSourceNode =
  Native.WebAudio.createMediaStreamAudioSourceNode
-}



{- TODO: Type of a MediaStreamAudioDestinationNode -}


{-| Type of an OscillatorNode
-}
type alias OscillatorNode =
  AudioNode { frequency : AudioParam, detune : AudioParam }


{-| Wave types for OscillatorNodes

TODO: Custom
-}
type OscillatorWaveType
  = Sine
  | Square
  | Sawtooth
  | Triangle


{-| Create an OscillatorNode

Second parameter is the wave type of the oscillator
-}
createOscillatorNode : AudioContext -> OscillatorWaveType -> OscillatorNode
createOscillatorNode =
  Native.WebAudio.createOscillatorNode


{-| Get the oscillator wave type
-}
getOscillatorWaveType : OscillatorNode -> OscillatorWaveType
getOscillatorWaveType =
  Native.WebAudio.getOscillatorWaveType


{-| Set the oscillator wave type

This function returns the oscillator for chaining.
-}
setOscillatorWaveType : OscillatorWaveType -> OscillatorNode -> OscillatorNode
setOscillatorWaveType =
  Native.WebAudio.setOscillatorWaveType


{-| Schedule the Oscillator to start

This method returns the oscillator for chaining.
-}
startOscillator : Float -> OscillatorNode -> OscillatorNode
startOscillator =
  Native.WebAudio.startOscillator


{-| Schedule a stop time for the Oscillator.

WARNING:
After an end time has been set, the oscillator can no longer be started. Since
an oscillator can no longer be started after it has been stopped, the
oscillator is essentially useless. The system is supposed to automatically clean
up AudioNodes that are no longer in use, provided that the node meets a couple
requirements - one of which is that there are no more references to it.
Therefore, Elm.WebAudio will automatically free the reference to the underlying
javascript object as soon as a stop has been scheduled. What this means, from a
practical standpoint, is that any further attempt to manipulate the Oscillator
will result in a javascript error. It's not pretty, but, honestly, neither is
the WebAudio Javascript API.
-}
stopOscillator : Float -> OscillatorNode -> ()
stopOscillator =
  Native.WebAudio.stopOscillator


{-| Type of a PannerNode
-}
type alias PannerNode =
  AudioNode {}


{-| Panning Model
-}
type PanningModel
  = EqualPower
  | HRTF


{-| Distance Model
-}
type DistanceModel
  = Linear
  | Inverse
  | Exponential


{-| Create a PannerNode
-}
createPannerNode : AudioContext -> PannerNode
createPannerNode =
  Native.WebAudio.createPannerNode


{-| Get the Panning Model of the Panner
-}
getPanningModel : PannerNode -> PanningModel
getPanningModel =
  Native.WebAudio.getPanningModel


{-| Set the Panning Model of the Panner

This function returns the PannerNode for chaining.
-}
setPanningModel : PanningModel -> PannerNode -> PannerNode
setPanningModel =
  Native.WebAudio.setPanningModel


{-| Get the Distance Model of the Panner
-}
getDistanceModel : PannerNode -> DistanceModel
getDistanceModel =
  Native.WebAudio.getDistanceModel


{-| Set the Distance Model of the Panner

This function returns the PannerNode for chaining.
-}
setDistanceModel : DistanceModel -> PannerNode -> PannerNode
setDistanceModel =
  Native.WebAudio.setDistanceModel


{-| Get the reference distance of the panner
-}
getReferenceDistance : PannerNode -> Float
getReferenceDistance =
  Native.WebAudio.getReferenceDistance


{-| Set the reference distance of the panner
-}
setReferenceDistance : Float -> PannerNode -> PannerNode
setReferenceDistance =
  Native.WebAudio.setReferenceDistance


{-| Get the max distance of the panner
-}
getMaxDistance : PannerNode -> Float
getMaxDistance =
  Native.WebAudio.getMaxDistance


{-| Set the max distance of the pannel
-}
setMaxDistance : Float -> PannerNode -> PannerNode
setMaxDistance =
  Native.WebAudio.setMaxDistance


{-| Get the rolloff factor for the panner
-}
getRolloffFactor : PannerNode -> Float
getRolloffFactor =
  Native.WebAudio.getRolloffFactor


{-| Set the rolloff factor for the panner
-}
setRolloffFactor : Float -> PannerNode -> PannerNode
setRolloffFactor =
  Native.WebAudio.setRolloffFactor


{-| Get the cone inner angle for the panner
-}
getConeInnerAngle : PannerNode -> Float
getConeInnerAngle =
  Native.WebAudio.getConeInnerAngle


{-| Set the cone inner angle for the panner
-}
setConeInnerAngle : Float -> PannerNode -> PannerNode
setConeInnerAngle =
  Native.WebAudio.setConeInnerAngle


{-| Get the cone outer angle for the panner
-}
getConeOuterAngle : PannerNode -> Float
getConeOuterAngle =
  Native.WebAudio.getConeOuterAngle


{-| Set the cone outer angle for the panner
-}
setConeOuterAngle : Float -> PannerNode -> PannerNode
setConeOuterAngle =
  Native.WebAudio.setConeOuterAngle


{-| Get the cone outer gain for the panner
-}
getConeOuterGain : PannerNode -> Float
getConeOuterGain =
  Native.WebAudio.getConeOuterGain


{-| Set the cone outer gain for the panner
-}
setConeOuterGain : Float -> PannerNode -> PannerNode
setConeOuterGain =
  Native.WebAudio.setConeOuterGain


{-| Set the listener position for the panner
-}
setPosition : Float -> Float -> Float -> PannerNode -> PannerNode
setPosition =
  Native.WebAudio.setPosition


{-| Set the listener orientation for the panner
-}
setOrientation : Float -> Float -> Float -> PannerNode -> PannerNode
setOrientation =
  Native.WebAudio.setOrientation


{-| Set the listener velocity for the panner
-}
setVelocity : Float -> Float -> Float -> PannerNode -> PannerNode
setVelocity =
  Native.WebAudio.setVelocity



{- TODO: Type of a ScriptProcessorNode -}
{- TODO: Type of a WaveShaperNode -}
