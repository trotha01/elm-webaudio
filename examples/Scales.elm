module Main exposing (..)

import Graphics.Element exposing (Element, show, flow, down, leftAligned, right, middle, container)
import Graphics.Input exposing (checkbox, button)
import Text
import WebAudio exposing (OscillatorNode, AudioContext(DefaultContext), stopOscillator, setValue, startOscillator, getDestinationNode, connectNodes, OscillatorWaveType(..), createOscillatorNode)
import Signal
import Time exposing (Time)


-- Models


type alias HalfStep =
    Float


type alias Label =
    String


type Tonic
    = Tonic Label HalfStep


type Scale
    = Scale String (List HalfStep)


type MusicState
    = Playing OscillatorNode HalfStep (List HalfStep) Time
    | Paused


tonics =
    [ Tonic "A" 0
    , Tonic "A#/Bb" 1
    , Tonic "B" 2
    , Tonic "C" 3
    , Tonic "C#/Db" 4
    , Tonic "D" 5
    , Tonic "D#/Eb" 6
    , Tonic "E" 7
    , Tonic "F" 8
    , Tonic "F#/Gb" 9
    , Tonic "G" 10
    , Tonic "G#/Ab" 11
    ]


musicalScales =
    [ Scale "Major" [ 0, 2, 2, 1, 2, 2, 2, 1 ]
    , Scale "Minor" [ 0, 2, 1, 2, 2, 1, 2, 2 ]
    ]


headOrDie lst err =
    let
        x =
            List.head lst
    in
        case x of
            Just x_ ->
                x_

            Nothing ->
                Debug.crash err


visualModel =
    { tonic = headOrDie tonics "No tonics defined"
    , scale = headOrDie musicalScales "No scales defined"
    }


musicModel =
    { state = Paused, changed = False, buttonCount = 0 }


getTonicLabel (Tonic label _) =
    label


getTonicHalfStep (Tonic _ halfstep) =
    halfstep


getScaleLabel (Scale label _) =
    label


getScaleSteps (Scale _ steps) =
    steps


isPlaying state =
    case state of
        Paused ->
            False

        _ ->
            True



-- Update


stopMusic oscillator =
    let
        _ =
            stopOscillator 0.0 oscillator
    in
        Paused


updateNote oscillator tonic tones t =
    case tones of
        tone :: remainingTones ->
            let
                currentStep =
                    tonic + tone

                frequency =
                    (220 * (2 ^ (currentStep / 12)))

                _ =
                    setValue frequency oscillator.frequency
            in
                Playing oscillator currentStep remainingTones t

        [] ->
            stopMusic oscillator


startMusic { tonic, scale } t =
    let
        node =
            createOscillatorNode DefaultContext Sine
                |> connectNodes (getDestinationNode DefaultContext) 0 0
                |> startOscillator 0.0
    in
        updateNote node (getTonicHalfStep tonic) (getScaleSteps scale) t


updateMusic ( vmodel, btncnt, t ) mmodel =
    case mmodel.state of
        Playing node tonicStep steps oldt ->
            if btncnt /= mmodel.buttonCount then
                { state = stopMusic node, changed = True, buttonCount = btncnt }
            else
                let
                    newState =
                        updateNote node tonicStep steps t
                in
                    { state = newState, changed = not <| isPlaying newState, buttonCount = btncnt }

        Paused ->
            if btncnt /= mmodel.buttonCount then
                { state = startMusic vmodel t, changed = True, buttonCount = btncnt }
            else
                { mmodel | changed = False }



-- Input


tonicInput : Signal.Mailbox Tonic
tonicInput =
    Signal.mailbox visualModel.tonic


scaleInput : Signal.Mailbox Scale
scaleInput =
    Signal.mailbox visualModel.scale


playInput =
    Signal.mailbox ()


playCount : Signal Int
playCount =
    Signal.foldp (\_ total -> total + 1) 0 playInput.signal


deadLetter =
    Signal.mailbox ()


visualSignal : Signal { scale : Scale, tonic : Tonic }
visualSignal =
    Signal.map2 (\t s -> { tonic = t, scale = s }) tonicInput.signal scaleInput.signal


musicSignal =
    Signal.map3 (,,) visualSignal (playCount) (Time.every 350.0)



-- Render


checkboxWithLabel : String -> (Bool -> Signal.Message) -> Bool -> Element
checkboxWithLabel label handler checked =
    container 70 30 middle <|
        flow
            right
            [ checkbox handler checked
            , leftAligned (Text.monospace (Text.fromString label))
            ]


onOff : Signal.Address a -> a -> Bool -> Signal.Message
onOff addr toSend checked =
    if checked then
        Signal.message addr toSend
    else
        Signal.message deadLetter.address ()


tonicBoxes tonic =
    let
        box t =
            checkboxWithLabel (getTonicLabel t) (onOff tonicInput.address t) (t == tonic)
    in
        flow right <| List.map box tonics


scaleBoxes scale =
    let
        box s =
            checkboxWithLabel (getScaleLabel s) (onOff scaleInput.address s) (s == scale)
    in
        flow right <| List.map box musicalScales


playButton vmodel mmodel =
    button
        (Signal.message playInput.address ())
        (if (isPlaying mmodel.state) then
            "Stop"
         else
            "Play"
        )


render ( vmodel, mmodel ) =
    flow
        down
        [ tonicBoxes vmodel.tonic
        , scaleBoxes vmodel.scale
        , playButton vmodel mmodel
        ]



-- MAIN


mainMusic =
    Signal.foldp updateMusic musicModel musicSignal |> Signal.filter (\m -> m.changed || (isPlaying m.state)) musicModel


main =
    Signal.map render (Signal.map2 (,) visualSignal mainMusic)
