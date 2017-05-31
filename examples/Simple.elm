module Main exposing (..)

import WebAudio exposing (OscillatorNode, AudioContext(DefaultContext), tapNode, stopOscillator, setValue, startOscillator, getDestinationNode, connectNodes, OscillatorWaveType(..), createOscillatorNode)
import Html exposing (..)
import Html.Events exposing (onClick)


-- Model


type alias Model =
    { currentlyPlaying : Maybe.Maybe OscillatorNode
    }


model : Model
model =
    { currentlyPlaying = Maybe.Nothing
    }



-- Update


type Msg
    = PlayOneSecond
    | StartPlaying
    | StopPlaying


update : Msg -> Model -> Model
update msg model =
    case msg of
        -- The button that plays a tone for one second
        PlayOneSecond ->
            let
                _ =
                    -- side effect block hacked in :(
                    createOscillatorNode DefaultContext Sine
                        |> connectNodes (getDestinationNode DefaultContext) 0 0
                        |> startOscillator 0.0
                        |> stopOscillator 1.0
            in
                model

        StartPlaying ->
            { model
                | currentlyPlaying =
                    createOscillatorNode DefaultContext Sine
                        |> connectNodes (getDestinationNode DefaultContext) 0 0
                        |> tapNode .frequency (\f -> setValue 220.0 f)
                        |> startOscillator 0.0
                        |> Maybe.Just
            }

        StopPlaying ->
            { model
                | currentlyPlaying =
                    case model.currentlyPlaying of
                        Maybe.Nothing ->
                            Maybe.Nothing

                        Maybe.Just node ->
                            let
                                _ =
                                    -- again, hacked-in side effect block :(
                                    -- if there was a manual way to handle OscillatorNode cleanup, here is where we would do it :(
                                    stopOscillator 0.0 node
                            in
                                Maybe.Nothing
            }



-- View


view : Model -> Html Msg
view model =
    let
        isCurrentlyPlaying =
            model.currentlyPlaying /= Maybe.Nothing
    in
        div []
            [ button [ onClick PlayOneSecond ] [ text "Play One Second" ]
            , button
                [ onClick
                    (if isCurrentlyPlaying then
                        StopPlaying
                     else
                        StartPlaying
                    )
                ]
                [ text
                    (if isCurrentlyPlaying then
                        "Stop"
                     else
                        "Play"
                    )
                ]
            ]



-- Main


main =
    beginnerProgram
        { model = model
        , view = view
        , update = update
        }
