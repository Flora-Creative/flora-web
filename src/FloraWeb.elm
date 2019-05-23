module FloraWeb exposing (Model, Msg(UrlChanged), init, subscriptions, update, view)

import API exposing (..)
import About
import App
import Array exposing (..)
import Bootstrap.CDN as CDN
import Bootstrap.Navbar as Navbar
import Bootstrap.Progress as Progress
import Contact as Contact
import Date exposing (Date)
import Html exposing (..)
import Html.Attributes exposing (href, id, src, style)
import Http
import Navigation
import Platform.Cmd
import Privacy exposing (..)
import StyleSheet
import Task


-- Model


type alias Model =
    { history : List Navigation.Location
    , apps : Array App.Model
    , hasFinishedLoading : Bool
    , navState : Navbar.State
    , contactModel : Contact.Model
    , date : Maybe Date
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
      , contactModel = Contact.init
      , date = Nothing
      }
    , Cmd.batch [ navCmd, fetchAllApps, now ]
    )


fetchAllApps : Cmd Msg
fetchAllApps =
    Http.send
        ReceivedAllApps
        (API.get "https://flora-api.herokuapp.com/")



-- Update


type Msg
    = UrlChanged Navigation.Location
    | ReceivedAllApps (Result Http.Error (List IOSApp))
    | NavMsg Navbar.State
    | AppMsg App.Model App.Msg
    | ContactFormUpdated Contact.Msg
    | SetDate (Maybe Date)


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

        ContactFormUpdated formMsg ->
            let
                ( updated, _ ) =
                    Contact.update formMsg model.contactModel
            in
            ( { model | contactModel = updated }, Cmd.none )

        SetDate date ->
            ( { model | date = date }, Cmd.none )



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
    | Privacy
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

        "#privacy" ->
            Privacy

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
            errorView

        FloraApp ->
            floraProjectContentView model

        IndividualApp appModel ->
            floraProjectContentView model

        About ->
            About.view

        Privacy ->
            Privacy.view

        Contact ->
            Html.map ContactFormUpdated (Contact.view model.contactModel)


floraProjectContentView : Model -> Html Msg
floraProjectContentView model =
    case model.hasFinishedLoading of
        True ->
            case Array.isEmpty model.apps of
                True ->
                    errorView

                False ->
                    div [] [ floraAppView model ]

        False ->
            loadingView model


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
    let
        logoStyle =
            [ h1
                [ StyleSheet.avenir
                , StyleSheet.semibold
                , style [ ( "color", StyleSheet.blueGray ), ( "text-color", StyleSheet.blueGray ) ]
                ]
                [ text "flora creative" ]
            ]
    in
    Navbar.config NavMsg
        |> Navbar.attrs StyleSheet.navBarStyle
        |> Navbar.withAnimation
        |> Navbar.lightCustomClass StyleSheet.mutedMustard
        |> Navbar.collapseMedium
        |> Navbar.brand [ href "" ] logoStyle
        |> Navbar.items
            [ navigationItem "#flora" "flora project"
            , navigationItem "#about" "about"
            , navigationItem "#contact" "contact"
            , navigationItem "#privacy" "privacy"
            ]
        |> Navbar.view model.navState


navigationItem : String -> String -> Navbar.Item Msg
navigationItem itemLink itemTitle =
    Navbar.itemLink [ href itemLink ] [ h5 [ StyleSheet.avenir, StyleSheet.regular ] [ text itemTitle ] ]


errorView : Html Msg
errorView =
    div
        StyleSheet.embeddedContentStyle
        [ h3 [ StyleSheet.avenir, mainBodyTextStyle ] [ text "Something has gone wrong. We'll be back up soon." ] ]


loadingView : Model -> Html Msg
loadingView model =
    div
        (style [ ( "padding", "5em" ) ] :: StyleSheet.embeddedContentStyle)
        [ Progress.progress
            [ Progress.value 100
            , Progress.animated
            ]
        , h3 [ StyleSheet.avenir, mainBodyTextStyle ] [ text "just a moment" ]
        ]


footerView : Model -> Html Msg
footerView model =
    let
        currentYear =
            Maybe.map (Date.year >> toString) model.date

        footerText =
            "Copyright Flora Creative " ++ Maybe.withDefault "2019" currentYear ++ "."
    in
    div []
        [ br [] []
        , h6
            [ StyleSheet.avenir, StyleSheet.regular, style [ ( "color", StyleSheet.mutedMustard ), ( "text-align", "center" ), ( "margin-bottom", "2em" ) ] ]
            [ text footerText ]
        ]



-- TODO -- make this a task with `Date` from Core


now : Cmd Msg
now =
    Task.perform (Just >> SetDate) Date.now


floraAppView : Model -> Html Msg
floraAppView model =
    let
        projectOverview =
            [ floraProjectDescriptionView model ]

        appContent =
            model.apps |> Array.map appMsg |> Array.toList

        appMsg =
            \appModel -> Html.map (AppMsg appModel) (App.view appModel)
    in
    div [] (projectOverview ++ appContent)


floraProjectDescriptionView : Model -> Html Msg
floraProjectDescriptionView model =
    let
        descriptionStyle =
            style
                [ ( "text-align", "center" )
                , ( "color", StyleSheet.blueGray )
                ]
                :: StyleSheet.embeddedContentStyle
    in
    div descriptionStyle (floraProjectTitle model)


floraProjectTitle : Model -> List (Html Msg)
floraProjectTitle model =
    [ h1 [ StyleSheet.avenir, StyleSheet.semibold ] [ text "flora project" ]
    , h3 [ StyleSheet.avenir ] [ text "audio effects" ]
    , StyleSheet.separatorWithColor StyleSheet.blueGray
    , h6 [ StyleSheet.avenir, StyleSheet.regular, style [ ( "text-align", "center" ) ] ] [ text floraProjectDescription ]
    , StyleSheet.separatorWithColor StyleSheet.blueGray
    ]


mainBodyTextStyle : Attribute msg
mainBodyTextStyle =
    style
        [ ( "text-align", "center" )
        , ( "width", "70%" )
        , ( "margin", "auto" )
        , ( "color", StyleSheet.blueGray )
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
