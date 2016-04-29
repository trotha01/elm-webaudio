module Main (..) where

import WebAudio exposing (OscillatorNode, AudioContext(DefaultContext), stopOscillator, setValue, startOscillator, getDestinationNode, connectNodes, OscillatorWaveType(..), createOscillatorNode)
import Graphics.Element exposing (Element, empty)
import StartApp.Simple as StartApp
import Html exposing (text, button)
import Html.Events exposing (onClick)


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


view address model =
  button [ onClick address Play ] [ text "Play" ]



-- Main


main =
  StartApp.start { model = model, view = view, update = startMusic }
