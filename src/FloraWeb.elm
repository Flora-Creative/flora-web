module FloraWeb exposing (Model, Msg(UrlChanged), init, subscriptions, update, view)

import API exposing (..)
import About
import App
import Array exposing (..)
import Bootstrap.CDN as CDN
import Bootstrap.Navbar as Navbar
import Bootstrap.Progress as Progress
import Html exposing (..)
import Html.Attributes exposing (href, id, src, style)
import Http
import Navigation
import Platform.Cmd


-- Model


type alias Model =
    { history : List Navigation.Location
    , apps : Array App.Model
    , hasFinishedLoading : Bool
    , navState : Navbar.State
    }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        ( navState, navCmd ) =
            Navbar.initialState NavMsg
    in
    ( { history = [ location ]
      , apps = Array.empty
      , hasFinishedLoading = False
      , navState = navState
      }
    , Cmd.batch [ navCmd, fetchAllApps ]
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
    | NavMsg Navbar.State
    | AppMsg App.Model App.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged location ->
            ( { model | history = location :: model.history }, Cmd.none )

        NavMsg state ->
            ( { model | navState = state }, Cmd.none )

        ReceivedAllApps result ->
            case result of
                Err error ->
                    Debug.log (toString error)
                        ( { model | hasFinishedLoading = True }, Cmd.none )

                Ok apps ->
                    ( { model | apps = List.indexedMap App.init apps |> Array.fromList, hasFinishedLoading = True }, Cmd.none )

        AppMsg appModel appMsg ->
            ( { model | apps = Array.set appModel.index (App.update appMsg appModel) model.apps }, Cmd.none )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        appSubscription =
            \app -> Sub.map (AppMsg app) (App.subscriptions app)

        allAppSubscriptions =
            model.apps
                |> Array.map appSubscription
                |> Array.toList
    in
    [ Navbar.subscriptions model.navState NavMsg ]
        ++ allAppSubscriptions
        |> Sub.batch


type Page
    = FloraApp
    | IndividualApp App.Model
    | About
    | Contact
    | Unknown


currentPage : Model -> Page
currentPage model =
    let
        currentLocationHash =
            model.history |> List.head |> Maybe.map (\l -> l.hash) |> Maybe.withDefault ""

        appFromHash =
            model.apps
                |> Array.filter (\appModel -> appModel.app.shortName == currentLocationHash)
                |> Array.toList
                |> List.head
    in
    case currentLocationHash of
        "" ->
            FloraApp

        "#flora" ->
            FloraApp

        "#about" ->
            About

        "#contact" ->
            Contact

        _ ->
            -- Either a hash for an individual app or an unkown hash
            appFromHash
                |> Maybe.map IndividualApp
                |> Maybe.withDefault Unknown



-- View


mainContentView : Model -> Html Msg
mainContentView model =
    case currentPage model of
        Unknown ->
            div [] [ errorView ]

        FloraApp ->
            floraProjectContentView model

        IndividualApp appModel ->
            floraProjectContentView model

        About ->
            div [] [ textViewWithText About.floraCreativeCopy ]

        Contact ->
            div [] [ textViewWithText "Contact us coming soon." ]


floraProjectContentView : Model -> Html Msg
floraProjectContentView model =
    case model.hasFinishedLoading of
        True ->
            case Array.isEmpty model.apps of
                True ->
                    div [] [ errorView ]

                False ->
                    div [] [ floraAppView model ]

        False ->
            loadingView model


avenir : Html.Attribute msg
avenir =
    style
        [ ( "font-family", "\"Avenir\", Times" )
        , ( "font-feature-settings", "\"liga\" 0" )
        ]


view : Model -> Html Msg
view model =
    div []
        [ CDN.stylesheet
        , menu model
        , mainContentView model
        , footerView model
        ]


menu : Model -> Html Msg
menu model =
    Navbar.config NavMsg
        |> Navbar.withAnimation
        |> Navbar.brand [ href "" ] [ h1 [ avenir ] [ text "flora creative" ] ]
        |> Navbar.items
            [ navigationItem "#flora" "flora project"
            , navigationItem "#about" "about"
            , navigationItem "#contact" "contact"
            ]
        |> Navbar.view model.navState


navigationItem : String -> String -> Navbar.Item Msg
navigationItem itemLink itemTitle =
    Navbar.itemLink [ href itemLink ] [ h5 [ avenir ] [ text itemTitle ] ]


errorView : Html Msg
errorView =
    div
        [ style
            [ ( "background-color", "#edeae4" )
            , ( "padding-top", "15em" )
            , ( "padding-bottom", "15em" )
            ]
        ]
        [ h3 [ mainBodyTextStyle ] [ text "Something has gone wrong. We'll be back up soon." ] ]


textViewWithText : String -> Html Msg
textViewWithText copy =
    div
        [ style
            [ ( "background-color", "#edeae4" )
            , ( "padding-top", "15em" )
            , ( "padding-bottom", "15em" )
            ]
        ]
        [ h3 [ mainBodyTextStyle ] [ text copy ] ]


loadingView : Model -> Html Msg
loadingView model =
    div
        [ style
            [ ( "background-color", "#edeae4" )
            , ( "padding", "15em" )
            ]
        ]
        [ Progress.progress
            [ Progress.value 100
            , Progress.animated
            ]
        , h3 [ mainBodyTextStyle ] [ text "just a moment" ]
        ]


footerView : Model -> Html Msg
footerView model =
    let
        footerText =
            "Copyright Flora Creative " ++ currentYear ++ "."
    in
    div []
        [ br [] []
        , h6
            [ avenir ]
            [ text footerText ]
        ]



-- TODO -- make this a task with `Date` from Core


currentYear : String
currentYear =
    "2018"


floraAppView : Model -> Html Msg
floraAppView model =
    let
        projectOverview =
            [ appIconNavigationView model ]

        appContent =
            model.apps |> Array.map appMsg |> Array.toList

        appMsg =
            \appModel -> Html.map (AppMsg appModel) (App.view appModel)
    in
    div [] (projectOverview ++ appContent)


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
        ]


floraProjectTitle : Model -> Html Msg
floraProjectTitle model =
    div []
        [ br [] []
        , br [] []
        , h1 [ avenir ] [ text "flora project" ]
        , br [] []
        , br [] []
        , h2 [ avenir ] [ text "audio effects" ]
        , br [] []
        , br [] []
        , h5 [ avenir, mainBodyTextStyle ] [ text floraProjectDescription ]
        , br [] []
        , br [] []
        ]


mainBodyTextStyle : Attribute msg
mainBodyTextStyle =
    style
        [ ( "text-align", "center" )
        , ( "letter-spacing", "1px" )
        , ( "width", "70%" )
        , ( "margin", "auto" )
        ]


floraProjectDescription : String
floraProjectDescription =
    """
    the flora project was conceived as a suite of beautifully simple, cpu-effective audio effects for ios devices, reminiscent of stomp-box style effects.


    a simple, consistent and intuitive interface is presented with just the right number of parameters to allow users to quickly dial in the perfect sound.
    """


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
