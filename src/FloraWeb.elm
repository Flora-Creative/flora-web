module FloraWeb exposing (Msg(UrlChanged), init, subscriptions, update, view)

import API exposing (..)
import Html exposing (..)
import Html.Attributes exposing (href, src)
import Http
import Navigation
import Regex


type alias Model =
    { history : List Navigation.Location
    , apps : List IOSApp
    , hasFinishedLoading : Bool
    }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    ( { history = [ location ]
      , apps = []
      , hasFinishedLoading = False
      }
    , fetchAllApps
    )


fetchAllApps : Cmd Msg
fetchAllApps =
    Http.send
        ReceivedAllApps
        (API.get "http://localhost:1234")


type Msg
    = UrlChanged Navigation.Location
    | ReceivedAllApps (Result Http.Error (List IOSApp))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged location ->
            ( { model | history = location :: model.history }, Cmd.none )

        ReceivedAllApps result ->
            case result of
                Err error ->
                    Debug.log (toString error)
                        ( { model | hasFinishedLoading = True }, Cmd.none )

                Ok apps ->
                    ( { model | apps = apps, hasFinishedLoading = True }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    case model.hasFinishedLoading of
        True ->
            case List.isEmpty model.apps of
                True ->
                    div [] [ navBar model, errorView model, footerView ]

                False ->
                    div [] [ navBar model, contentView model, footerView ]

        False ->
            loadingView model


errorView : Model -> Html Msg
errorView model =
    div [] [ text "Did encounter error" ]


loadingView : Model -> Html Msg
loadingView model =
    div [] [ text "we are loading" ]


footerView : Html Msg
footerView =
    div [ basicStyle ] [ text "Copyright Flora Creative." ]


contentView : Model -> Html Msg
contentView model =
    case List.head model.history of
        Just location ->
            case
                List.head
                    (List.filter (\app -> "#" ++ app.shortName == location.hash)
                        model.apps
                    )
            of
                Just app ->
                    singleAppView app

                Nothing ->
                    div [ basicStyle ] [ text "No content yet!" ]

        Nothing ->
            allAppView model.apps


navBar : Model -> Html Msg
navBar model =
    div []
        [ h1 [ basicStyle ] [ text "Navigation" ]
        , div [ basicStyle ] (List.map viewLink (List.map appToNameAndLink model.apps))
        ]


basicStyle : Attribute Msg
basicStyle =
    Html.Attributes.style
        [ ( "width", "100%" )
        , ( "font-size", "2em" )
        , ( "text-align", "center" )
        ]


appToNameAndLink : IOSApp -> ( String, String )
appToNameAndLink iOSApp =
    ( iOSApp.appName, iOSApp.shortName )


allAppView : List IOSApp -> Html Msg
allAppView iOSAppList =
    div [] (List.map singleAppView iOSAppList)


singleAppView : IOSApp -> Html Msg
singleAppView iOSApp =
    div [ basicStyle ]
        [ text iOSApp.appName
        , text iOSApp.appDescription
        , button [] []
        , img
            [ src iOSApp.appIcon ]
            []
        ]


viewLink : ( String, String ) -> Html msg
viewLink ( name, linkName ) =
    li [] [ a [ href ("#" ++ linkName) ] [ text name ] ]


viewLocation : Navigation.Location -> Html msg
viewLocation location =
    li [] [ text (location.pathname ++ location.hash) ]
