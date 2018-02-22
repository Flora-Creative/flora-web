module FloraWeb exposing (Model, Msg(UrlChanged), init, subscriptions, update, view)

import API exposing (..)
import Html exposing (..)
import Html.Attributes exposing (href, src, style)
import Http
import Material
import Material.Color as Color
import Material.Grid as Grid
import Material.Layout as Layout
import Material.Options as Options
import Material.Scheme
import Material.Spinner as Loading
import Navigation
import Regex


-- Model


type alias Model =
    { mdl : Material.Model
    , history : List Navigation.Location
    , apps : List IOSApp
    , hasFinishedLoading : Bool
    }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    ( { mdl = Material.model
      , history = [ location ]
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



-- Update


type Msg
    = UrlChanged Navigation.Location
    | ReceivedAllApps (Result Http.Error (List IOSApp))
    | Mdl (Material.Msg Msg)


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

        Mdl msg_ ->
            Material.update Mdl msg_ model



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- View


type alias Mdl =
    Material.Model


mainContentview : Model -> Html Msg
mainContentview model =
    case model.hasFinishedLoading of
        True ->
            case List.isEmpty model.apps of
                True ->
                    div [] [ appIconNavigationView model, errorView model, footerView ]

                False ->
                    div [] [ appIconNavigationView model, contentView model, footerView ]

        False ->
            loadingView model


backgroundColor : Color.Color
backgroundColor =
    Color.color Color.BlueGrey Color.S50


avenir : Html.Attribute msg
avenir =
    style [ ( "font-family", "\"Avenir\", Times" ) ]


view : Model -> Html Msg
view model =
    Material.Scheme.topWithScheme Color.Grey Color.DeepPurple <|
        Layout.render Mdl
            model.mdl
            [ Layout.fixedHeader
            , Layout.fixedTabs
            ]
            { header =
                [ h1
                    [ style
                        [ ( "padding", "2rem" )
                        , ( "background-color", "#2e3240" )
                        , ( "color", "#d4d1cf" )
                        ]
                    , avenir
                    ]
                    [ text "flora creative" ]
                ]
            , drawer = []
            , tabs =
                ( [ text "apps", text "about", text "blog" ]
                , [ avenir |> Options.attribute
                  , style
                        [ ( "background-color", "#2e3240" )
                        , ( "color", "#d4d1cf" )
                        ]
                        |> Options.attribute
                  ]
                )
            , main = [ mainContentview model ]
            }


errorView : Model -> Html Msg
errorView model =
    div [] [ text "Did encounter error" ]


loadingView : Model -> Html Msg
loadingView model =
    Loading.spinner
        [ Loading.active True
        , Loading.singleColor True
        , Options.center
        ]


footerView : Html Msg
footerView =
    div [ avenir ] [ text "Copyright Flora Creative." ]


contentView : Model -> Html Msg
contentView model =
    case List.head model.history of
        Just location ->
            case
                model.apps
                    |> List.filter (\app -> "#" ++ app.shortName == location.hash)
                    |> List.head
            of
                Just app ->
                    div [] []

                Nothing ->
                    errorView model

        Nothing ->
            div [] []


appIconNavigationView : Model -> Html Msg
appIconNavigationView model =
    appIconViews model.apps |> Grid.grid appIconGridStyle


appIconGridStyle : List (Options.Style a)
appIconGridStyle =
    [ Options.center
    , style [ ( "width", "100%" ), ( "padding", "2rem" ), ( "background-color", "#edeae4" ) ] |> Options.attribute
    ]


appIconViews : List IOSApp -> List (Grid.Cell Msg)
appIconViews apps =
    apps |> List.map appIconView


appIconView : IOSApp -> Grid.Cell Msg
appIconView app =
    Grid.cell [ Grid.size Grid.All 3 ]
        [ img [ src app.appIcon, appIconStyle ] []
        , br [] []
        , div
            [ avenir
            , style
                [ ( "text-align", "center" )
                , ( "width", "50%" )
                , ( "padding", "1em" )
                ]
            ]
            [ text app.appName ]
        ]


appIconStyle : Html.Attribute msg
appIconStyle =
    style [ ( "width", "50%" ), ( "border-radius", "20%" ) ]


viewLink : ( String, String ) -> Html msg
viewLink ( name, linkName ) =
    li [] [ a [ href ("#" ++ linkName) ] [ text name ] ]


viewLocation : Navigation.Location -> Html msg
viewLocation location =
    li [] [ text (location.pathname ++ location.hash) ]
