module Main exposing (..)

import WebAudio exposing (OscillatorNode, AudioContext(DefaultContext), stopOscillator, setValue, startOscillator, getDestinationNode, connectNodes, OscillatorWaveType(..), createOscillatorNode)
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.App exposing (beginnerProgram)


-- Model


model =
  0



-- Update


type Action
  = Play


startMusic action model =
  let
    _ =
      case action of
        Play ->
          createOscillatorNode DefaultContext Sine
            |> connectNodes (getDestinationNode DefaultContext) 0 0
            |> startOscillator 0.0
            |> stopOscillator 1.0
  in
    model



-- View


view address =
  button [ onClick Play ] [ text "Play" ]



-- Main


main =
  beginnerProgram
    { model = model
    , view = view
    , update = startMusic
    }

