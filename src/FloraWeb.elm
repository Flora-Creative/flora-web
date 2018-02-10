module FloraWeb exposing (Msg(UrlChange), init, subscriptions, update, view)

import Html exposing (..)
import Html.Attributes exposing (href)
import Navigation
import Regex


type alias Model =
    { history : List Navigation.Location
    }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    ( { history = [ location ]
      }
    , Cmd.none
    )


type Msg
    = UrlChange Navigation.Location


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChange location ->
            ( { model | history = location :: model.history }, Cmd.none )


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
        ]


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
