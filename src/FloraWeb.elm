module FloraWeb exposing (Msg(UrlChanged), init, subscriptions, update, view)

import API exposing (..)
import Html exposing (..)
import Html.Attributes exposing (href)
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
    div [] [ navBar model, viewForCurrentPage model.history ]


navBar : Model -> Html Msg
navBar model =
    div []
        [ h1 [] [ text "Pages" ]
        , ul [] (List.map viewLink [ "phlox", "buttercup", "dogs" ])
        , h1 [] [ text "History" ]
        , ul [] (List.map viewLocation model.history)
        , allAppView model.apps
        ]


allAppView : List IOSApp -> Html Msg
allAppView iOSAppList =
    div [] (List.map singleAppView iOSAppList)


singleAppView : IOSApp -> Html Msg
singleAppView iOSApp =
    div [] [ text iOSApp.appName ]


viewForCurrentPage : List Navigation.Location -> Html Msg
viewForCurrentPage locationNavigationList =
    let
        currentLocation =
            Maybe.withDefault "" (Maybe.map .hash (List.head locationNavigationList))
    in
    if Regex.contains (Regex.regex "buttercup") currentLocation then
        viewButtercup
    else if Regex.contains (Regex.regex "phlox") currentLocation then
        viewPhlox
    else
        text "Home"


viewButtercup : Html Msg
viewButtercup =
    text "buttercup"


viewPhlox : Html Msg
viewPhlox =
    text "phlox"


viewLink : String -> Html msg
viewLink name =
    li [] [ a [ href ("#" ++ name) ] [ text name ] ]


viewLocation : Navigation.Location -> Html msg
viewLocation location =
    li [] [ text (location.pathname ++ location.hash) ]
