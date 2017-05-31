module Visual exposing (..)

import Color exposing (rgb, black, darkRed, lightRed, orange)
import Debug exposing (crash)
import Graphics.Collage exposing (..)
import Graphics.Element exposing (..)
import Graphics.Input exposing (button)
import Graphics.Input.Field exposing (Content, Direction(..), Selection, defaultStyle, field, noContent)
import Maybe exposing (withDefault)
import Mouse
import Signal
import Time
import Transform2D exposing (matrix, translation)
import WebAudio exposing (..)
import Window


doOrDie f lst err =
    let
        x =
            f lst
    in
        case x of
            Just x_ ->
                x_

            Nothing ->
                crash err


headOrDie =
    doOrDie List.head


tailOrDie =
    doOrDie List.tail



-- Models


analyser =
    createAnalyserNode DefaultContext |> connectNodes (getDestinationNode DefaultContext) 0 0


filters =
    let
        frequencies =
            [ 31.25, 62.5, 125, 250, 500, 1000, 2000, 4000, 8000, 16000 ]

        makeFilter f =
            createBiquadFilterNode DefaultContext
                |> setFilterType Peaking
                |> tapNode .frequency (\freq -> setValue f freq)

        rlst =
            List.map makeFilter (List.reverse frequencies)

        end =
            headOrDie rlst "no filters"
                |> setFilterType HighShelf
                |> connectNodes analyser 0 0

        lst =
            List.reverse <| List.scanl (\c p -> connectNodes p 0 0 c) end (tailOrDie rlst "no filters")
    in
        case lst of
            x :: xs ->
                (setFilterType LowShelf x) :: xs

            [] ->
                []


mediaStream =
    createHiddenMediaElementAudioSourceNode DefaultContext
        |> setMediaElementIsLooping True
        |> connectNodes (headOrDie filters "no filters") 0 0


sliderSize =
    { w = 20.0, h = 100.0 }


slidersState =
    { dimensions = ( 0, 0 )
    , dragging = False
    , lastPosition = ( 0, 0 )
    , selected = Nothing
    , scale = 1.0
    , move = 0.0
    , changes = False
    }


isSelectedSlider idx state =
    withDefault False <| Maybe.map (\( i, _ ) -> i == idx) state.selected


sliderValueClamp =
    (max -40.0) << (min 40.0)


controlState =
    { playing = False
    , loadTrack = False
    , url = Content "https://soundcloud.com/failemotions/gravity-instrumental" (Selection 0 0 Forward)
    , btnCnt = 0
    }



-- Update


scaleToFit { w, h } desiredW desiredH =
    min (desiredW / w) (desiredH / h)


updateSlidersVisual ( w_, h_ ) isdown pos state =
    let
        ( w, h ) =
            ( toFloat w_, toFloat h_ )

        sliderScale =
            scaleToFit sliderSize (w / 10.0 * 0.9) (h / 2.0 * 0.9)

        sliderMove =
            sliderScale * sliderSize.w / 0.9

        updates =
            updateSliders ( ( w_, h_ ), isdown, pos ) { state | dimensions = ( w_, h_ ), scale = sliderScale, move = sliderMove }
    in
        { updates | changes = True }


handleHitTest x y s f =
    let
        handleLeft =
            (0 - sliderSize.w / 2.0) * s

        handleRight =
            handleLeft + sliderSize.w * s

        posy =
            getValue f.gain

        handleBottom =
            (posy - sliderSize.w / 2.0) * s

        handleTop =
            handleBottom + sliderSize.w * s
    in
        handleLeft <= x && x <= handleRight && handleBottom <= y && y <= handleTop


selectSlider ( w_, h_ ) ( x_, y_ ) state =
    let
        ( w, h ) =
            ( toFloat w_, toFloat h_ )

        x =
            toFloat x_ - w / 2.0 + state.move * 5.0

        y =
            h / 4.0 - toFloat y_

        lst =
            List.indexedMap (,) filters

        filtered =
            List.filter (\( i, f ) -> handleHitTest (x - (toFloat i + 0.5) * state.move) y state.scale f) lst

        selected =
            List.head filtered
    in
        updateSelectedSlider ( x_, y_ ) { state | selected = selected, dragging = True }


updateSelectedSlider pos state =
    case state.selected of
        Just ( _, slider ) ->
            let
                currentVal =
                    getValue slider.gain

                delta =
                    (toFloat (Tuple.second state.lastPosition - Tuple.second pos)) / state.scale

                newVal =
                    sliderValueClamp (currentVal + delta)

                _ =
                    setValue newVal slider.gain
            in
                { state | lastPosition = pos, changes = True }

        Nothing ->
            { state | lastPosition = pos, changes = False }


disableSelectedSlider pos state =
    if state.dragging then
        { state | lastPosition = pos, selected = Nothing, dragging = False, changes = True }
    else
        { state | lastPosition = pos, changes = False }


updateSliders ( dim, isdown, pos ) state =
    if dim /= state.dimensions then
        updateSlidersVisual dim isdown pos state
    else if isdown then
        (if state.dragging then
            (updateSelectedSlider pos state)
         else
            (selectSlider dim pos state)
        )
    else
        disableSelectedSlider pos state


updateTrack =
    playMediaElement << withDefault mediaStream << Maybe.map (\url -> setMediaElementSource url mediaStream)


pauseMusic state =
    let
        _ =
            pauseMediaElement mediaStream
    in
        { state | playing = False, loadTrack = False }


playMusic state =
    { state | loadTrack = True, playing = True }


toggleMusic state =
    if state.playing then
        pauseMusic state
    else
        playMusic state


updateControls ( cnt, url ) state =
    if (cnt /= state.btnCnt) then
        toggleMusic { state | btnCnt = cnt, url = url }
    else
        { state | url = url, loadTrack = False }



-- Input


slidersInput =
    Signal.map3
        (,,)
        Window.dimensions
        Mouse.isDown
        Mouse.position


playButtonInput =
    Signal.mailbox controlState.playing


playButtonCount =
    Signal.foldp (\_ total -> total + 1) 0 playButtonInput.signal


urlFieldInput =
    Signal.mailbox controlState.url


controlInput =
    Signal.map2
        (,)
        playButtonCount
        urlFieldInput.signal


port soundUrl : Signal (Maybe String)



-- Render


renderSlider val selected =
    let
        handleColor =
            if selected then
                lightRed
            else
                darkRed
    in
        [ rect (sliderSize.w / 4.0) (sliderSize.h - sliderSize.w) |> filled black
        , rect sliderSize.w sliderSize.w |> filled handleColor |> moveY val
        ]


renderSliders w h state =
    let
        slider idx filter =
            let
                x =
                    (toFloat idx + 0.5) * state.move

                val =
                    getValue filter.gain

                selected =
                    isSelectedSlider idx state
            in
                groupTransform (matrix state.scale 0 0 state.scale x 0) (renderSlider val selected)
    in
        groupTransform (translation (0 - state.move * 5.0) (h / 2.0)) <| List.indexedMap slider filters


renderControls w state =
    let
        btn =
            button
                (Signal.message playButtonInput.address (not state.playing))
                (if state.playing then
                    "Pause"
                 else
                    "Play"
                )

        url =
            field defaultStyle (Signal.message urlFieldInput.address) "SoundCloud Permalink URL" state.url |> width (round (w / 2) - widthOf btn)
    in
        beside btn url |> toForm


renderAnalyser w h freqdata =
    let
        barWidth =
            w / (toFloat << List.length) freqdata

        draw idx datum =
            let
                barHeight =
                    h * toFloat datum / 255.0
            in
                rect barWidth barHeight |> filled orange |> move ( (toFloat idx + 0.5) * barWidth, (barHeight - h) / 2.0 )
    in
        groupTransform (translation (0 - w / 2.0) (h / -2.0)) <| List.indexedMap draw freqdata


render ( w_, h_ ) sliderState controlState freqdata _ =
    let
        ( w, h ) =
            ( toFloat w_, toFloat h_ )

        halfw =
            w / 2.0

        halfh =
            h / 2.0

        quarterh =
            halfh / 2.0
    in
        collage
            w_
            h_
            [ rect w halfh |> filled (rgb 34 34 34) |> moveY quarterh
            , rect w halfh |> filled black |> moveY (0 - quarterh)
            , renderSliders w halfh sliderState
            , renderAnalyser w halfh freqdata
            , renderControls w controlState
            ]



-- Main


mainMediaStream =
    Signal.map updateTrack soundUrl


mainSliders =
    Signal.foldp updateSliders slidersState slidersInput |> Signal.filter (\m -> m.changes) slidersState


mainControls =
    Signal.foldp updateControls controlState controlInput


port fetchSoundUrl : Signal String
port fetchSoundUrl =
    Signal.map (\{ url } -> url.string) (Signal.filter (\{ loadTrack } -> loadTrack) controlState mainControls)


main =
    Signal.map5
        render
        Window.dimensions
        (mainSliders)
        (mainControls)
        ((Signal.map (\_ -> getByteFrequencyData analyser) (Time.every 50.0)))
        (mainMediaStream)
