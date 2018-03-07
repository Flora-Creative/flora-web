module FloraWeb exposing (Model, Msg(UrlChanged), init, subscriptions, update, view)

import API exposing (..)
import AppView
import Html exposing (..)
import Html.Attributes exposing (href, src, style)
import Http
import Material
import Material.Button as Button
import Material.Color as Color
import Material.Grid as Grid
import Material.Layout as Layout
import Material.Options as Options
import Material.Scheme
import Material.Spinner as Loading
import Material.Tabs as Tabs
import Material.Typography as Typo
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
                    div [] [ errorView model, footerView ]

                False ->
                    div [] [ floraAppView model, footerView ]

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
            [ Layout.fixedTabs
            , Layout.fixedHeader
            , Layout.waterfall True
            , Layout.transparentHeader
            ]
            { header =
                [ h1
                    [ style
                        [ ( "background-color", "#2e3240" )
                        , ( "color", "#d4d1cf" )
                        , ( "text-align", "center" )
                        , ( "letter-spacing", "7px" )
                        ]
                    , avenir
                    ]
                    [ text "flora creative" ]
                ]
            , drawer = []
            , tabs =
                ( [ "flora project", "about", "contact" ] |> List.map tabStyling
                , [ avenir
                        |> Options.attribute
                  , style
                        [ ( "background-color", "#2e3240" )
                        , ( "color", "#edeae4" )
                        , ( "text-decoration", "none" )
                        , ( "letter-spacing", "2px" )
                        , ( "font-feature-settings", "\"liga\" 0" )
                        , ( "font-weight", "200" )
                        ]
                        |> Options.attribute
                  ]
                )
            , main = [ mainContentview model ]
            }


tabStyling : String -> Html Msg
tabStyling tabName =
    Options.styled p
        [ Typo.subhead
        , Typo.center
        , avenir |> Options.attribute
        , style
            [ ( "color", "#edeae4" ), ( "text-align", "center" ), ( "vertical-align", "middle" ) ]
            |> Options.attribute
        ]
        [ text tabName ]


errorView : Model -> Html Msg
errorView model =
    div
        [ style
            [ ( "background-color", "#edeae4" )
            , ( "padding-top", "15em" )
            , ( "padding-bottom", "15em" )
            ]
        ]
        [ mainCopyStyle "Something has gone wrong. We'll be back up soon." ]


loadingView : Model -> Html Msg
loadingView model =
    div
        [ style
            [ ( "background-color", "#edeae4" )
            , ( "padding", "15em" )
            ]
        ]
        [ Loading.spinner
            [ Loading.active True
            , Loading.singleColor True
            , Options.center
            , style [ ( "margin", "auto" ) ] |> Options.attribute
            ]
        ]


footerView : Html Msg
footerView =
    Options.styled
        p
        [ Typo.subhead
        , Typo.center
        , avenir |> Options.attribute
        , style
            [ ( "color", "#edeae4" ), ( "text-align", "center" ), ( "vertical-align", "middle" ) ]
            |> Options.attribute
        ]
        [ text ("Copyright Flora Creative " ++ currentYear ++ ".") ]



-- TODO -- make this a task with `Date` from Core


currentYear : String
currentYear =
    "2018"


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
                    div [] []

        Nothing ->
            div [] []


floraAppView : Model -> Html Msg
floraAppView model =
    div []
        (appIconNavigationView model :: List.map AppView.view model.apps)


appIconNavigationView : Model -> Html Msg
appIconNavigationView model =
    div
        [ style
            [ ( "width", "100%" )
            , ( "background-color", "#edeae4" )
            , ( "text-align", "center" )
            , ( "color", "#605b74" )
            ]
        ]
        [ floraProjectTitle model
        , appIconViews model |> Grid.grid appIconGridStyle
        ]


floraProjectTitle : Model -> Html Msg
floraProjectTitle model =
    div []
        [ Options.styled p
            [ Typo.display3
            , Typo.center
            , style [ ( "padding", "1em" ), ( "letter-spacing", "7px" ), ( "font-feature-settings", "\"liga\" 0" ) ] |> Options.attribute
            ]
            [ text "flora project" ]
        , Options.styled p
            [ Typo.display1
            , Typo.center
            , style [ ( "padding-bottom", "1em" ), ( "letter-spacing", "4px" ), ( "font-feature-settings", "\"liga\" 0" ) ] |> Options.attribute
            ]
            [ text "audio effects" ]
        , floraProjectDescription model
        ]


mainCopyStyle : String -> Html Msg
mainCopyStyle content =
    Options.styled p
        [ Typo.subhead
        , Typo.center
        , style
            [ ( "padding", "1em" )
            , ( "text-align", "center" )
            , ( "letter-spacing", "2px" )
            , ( "font-feature-settings", "\"liga\" 0" )
            , ( "font-weight", "200" )
            , ( "width", "70%" )
            , ( "margin", "auto" )
            ]
            |> Options.attribute
        ]
        [ text content ]


floraProjectDescription : Model -> Html Msg
floraProjectDescription model =
    mainCopyStyle """
    the flora project was conceived as a suite of beautifully simple, cpu-effective audio effects for ios devices, reminiscent of stomp-box style effects.


    a simple, consistent and intuitive interface is presented with just the right number of parameters to allow users to quickly dial in the perfect sound.
    """


appIconGridStyle : List (Options.Style a)
appIconGridStyle =
    [ Options.center
    , style
        [ ( "width", "90%" )
        , ( "background-color", "#edeae4" )
        , ( "margin", "auto" )
        ]
        |> Options.attribute
    ]


appIconViews : Model -> List (Grid.Cell Msg)
appIconViews model =
    model.apps
        |> List.map (\app -> ( app, model ))
        |> List.map appIconView


appIconView : ( IOSApp, Model ) -> Grid.Cell Msg
appIconView ( app, model ) =
    Grid.cell [ Grid.size Grid.All 4, Typo.center, Typo.title ]
        [ appIconButton app model
        ]


appIconButton : IOSApp -> Model -> Html Msg
appIconButton app model =
    Button.render Mdl
        [ 0 ]
        model.mdl
        [ Button.flat
        , style [ ( "height", "18em" ) ] |> Options.attribute
        ]
        [ img [ src app.appIcon, appIconStyle ] []
        , br [] []
        , div
            [ avenir
            , style [ ( "color", "#444140" ) ]
            ]
            [ text app.appName ]
        ]


appIconStyle : Html.Attribute msg
appIconStyle =
    style
        [ ( "width", "35%" )
        , ( "border-radius", "20%" )
        , ( "display", "block" )
        , ( "margin", "0 auto" )
        ]


viewLink : ( String, String ) -> Html msg
viewLink ( name, linkName ) =
    li [] [ a [ href ("#" ++ linkName) ] [ text name ] ]


viewLocation : Navigation.Location -> Html msg
viewLocation location =
    li [] [ text (location.pathname ++ location.hash) ]
