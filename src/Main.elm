module Main exposing (..)

import FloraWeb exposing (..)
import Navigation


main =
    Navigation.program UrlChanged
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
