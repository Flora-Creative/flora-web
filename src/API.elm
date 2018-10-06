module API exposing (IOSApp, decodeIOSApp, get, getByName)

import Http
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import Json.Encode
import String
import Url


type alias IOSApp =
    { appName : String
    , images : List String
    , videoLinks : List String
    , itunesUrl : String
    , appDescription : String
    , backgroundColor : String
    , foregroundColor : String
    , auIdentifier : String
    , appIcon : String
    , shortName : String
    }


decodeIOSApp : Decoder IOSApp
decodeIOSApp =
    succeed IOSApp
        |> required "appName" string
        |> required "images" (list string)
        |> required "videoLinks" (list string)
        |> required "itunesUrl" string
        |> required "appDescription" string
        |> required "backgroundColor" string
        |> required "foregroundColor" string
        |> required "auIdentifier" string
        |> required "appIcon" string
        |> required "shortName" string


get : String -> Http.Request (List IOSApp)
get urlBase =
    Http.request
        { method =
            "GET"
        , headers =
            []
        , url =
            String.join "/"
                [ urlBase
                ]
        , body =
            Http.emptyBody
        , expect =
            Http.expectJson (list decodeIOSApp)
        , timeout =
            Nothing
        , withCredentials =
            False
        }


getByName : String -> String -> Http.Request IOSApp
getByName urlBase capture_name =
    Http.request
        { method =
            "GET"
        , headers =
            []
        , url =
            String.join "/"
                [ urlBase
                , Url.percentEncode capture_name
                ]
        , body =
            Http.emptyBody
        , expect =
            Http.expectJson decodeIOSApp
        , timeout =
            Nothing
        , withCredentials =
            False
        }
