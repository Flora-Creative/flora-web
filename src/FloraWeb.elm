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
    }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    ( { history = [ location ]
      , apps = []
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
                    ( model, Cmd.none )

                Ok apps ->
                    ( { model | apps = apps }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    div [] [ navBar model, allAppView model.apps ]


navBar : Model -> Html Msg
navBar model =
    div []
        [ h1 [] [ text "Navigation" ]
        , ul [] (List.map viewLink (List.map appToNameAndLink model.apps))
        ]


appToNameAndLink : IOSApp -> ( String, String )
appToNameAndLink iOSApp =
    ( iOSApp.appName, iOSApp.shortName )


allAppView : List IOSApp -> Html Msg
allAppView iOSAppList =
    div [] (List.map singleAppView iOSAppList)


singleAppView : IOSApp -> Html Msg
singleAppView iOSApp =
    div []
        [ text iOSApp.appName
        , img
            [ src (Maybe.withDefault "" (List.head iOSApp.images)) ]
            []
        ]


viewLink : ( String, String ) -> Html msg
viewLink ( name, linkName ) =
    li [] [ a [ href ("#" ++ linkName) ] [ text name ] ]


viewLocation : Navigation.Location -> Html msg
viewLocation location =
    li [] [ text (location.pathname ++ location.hash) ]
