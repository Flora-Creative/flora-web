module App exposing (Model, Msg, init, subscriptions, update, view)

import API exposing (IOSApp)
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Carousel as Carousel
import Bootstrap.Carousel.Slide as Slide
import Bootstrap.Text as Text
import Bootstrap.Utilities.Size as Size
import Html exposing (..)
import Html.Attributes exposing (href, id, src, style)
import StyleSheet


type alias Model =
    { index : Int
    , app : IOSApp
    , carouselState : Carousel.State
    }


type Msg
    = CarouselMsg Carousel.Msg



-- Init


init : Int -> IOSApp -> Model
init index iosapp =
    { index = index
    , app = iosapp
    , carouselState = Carousel.initialState
    }



-- Update


update : Msg -> Model -> Model
update msg model =
    case msg of
        CarouselMsg carouselMsg ->
            { model | carouselState = Carousel.update carouselMsg model.carouselState }



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions =
    \model ->
        Carousel.subscriptions model.carouselState CarouselMsg


view : Model -> Html Msg
view model =
    div []
        [ br [] []
        , cardView model
        , br [] []
        ]


cardView : Model -> Html Msg
cardView model =
    let
        app =
            model.app

        alignment =
            case model.index % 2 of
                0 ->
                    Card.align Text.alignXsRight

                _ ->
                    Card.align Text.alignXsLeft

        separator =
            div
                [ defaultPadding ]
                [ StyleSheet.separatorWithColor app.foregroundColor ]
    in
    Card.config
        [ alignment
        , Card.attrs
            [ style
                [ ( "width", "85%" )
                , ( "max-width", "750px" )
                , ( "box-shadow", "0px 2px 5px 3px #222222" )
                , ( "margin", "auto" )
                , ( "border-width", "0px" )
                , ( "-webkit-border-radius", "10px" )
                , ( "-moz-border-radius", "10px" )
                , ( "border-radius", "10px" )
                , ( "letter-spacing", "0.07em" )
                , ( "backgroundColor", "#" ++ app.backgroundColor )
                , ( "color", app.foregroundColor )
                ]
            , id app.shortName
            ]
        ]
        |> Card.block []
            [ Block.custom <| h1 [ defaultPadding, StyleSheet.avenir, StyleSheet.semibold ] [ text app.appName ]
            , Block.custom <| separator
            , Block.custom <| carousel model
            , Block.custom <| separator
            , Block.titleH5 [ defaultPadding, StyleSheet.avenir, StyleSheet.regular ] [ text app.appDescription ]
            , Block.custom <| separator
            , Block.custom <| appStoreIcon app.itunesUrl
            ]
        |> Card.view


appStoreIcon : String -> Html msg
appStoreIcon url =
    a [ href url ]
        [ img
            [ src (cloudinaryURL ++ "assets/app_store.png")
            , style
                [ ( "float", "center" )
                , ( "display", "block" )
                , ( "margin-left", "auto" )
                , ( "margin-right", "auto" )
                , ( "width", "10em" )
                ]
            ]
            []
        ]


defaultPadding : Attribute msg
defaultPadding =
    style
        [ ( "paddingTop", "0em" )
        , ( "paddingBottom", "0em" )
        , ( "paddingLeft", "16px" )
        , ( "paddingRight", "16px" )
        ]


carousel : Model -> Html Msg
carousel model =
    let
        imageToSlide =
            \url -> Slide.config [] (Slide.image [] url)

        slides =
            List.map videoToSlide model.app.videoLinks ++ makeImages model.app.shortName
    in
    Carousel.config CarouselMsg [ defaultPadding ]
        |> Carousel.slides slides
        |> Carousel.view model.carouselState


cloudinaryURL : String
cloudinaryURL =
    "https://res.cloudinary.com/hqlbxtu1v/image/upload/v1540411987/"


makeImages : String -> List (Slide.Config msg)
makeImages appShortname =
    let
        imageURL =
            \s -> cloudinaryURL ++ "apps/" ++ appShortname ++ s

        imageToSlide =
            \url -> Slide.config [ Size.h100, Size.w100 ] (Slide.image [] url)
    in
    [ "/0.png"
    , "/1.png"
    , "/2.png"
    ]
        |> List.map (imageURL >> imageToSlide)


videoToSlide : String -> Slide.Config msg
videoToSlide url =
    let
        wrapperStyle =
            style
                [ ( "overflow", "hidden" )
                , ( "position", "relative" )
                , ( "paddingBottom", "75%" )
                ]

        iframeStyle =
            style
                [ ( "top", "0" )
                , ( "left", "0" )
                , ( "border", "0" )
                , ( "height", "100%" )
                , ( "width", "100%" )
                , ( "position", "absolute" )
                ]

        embedVideo =
            div [ wrapperStyle ] [ iframe [ src url, iframeStyle ] [] ]
    in
    Slide.config [] <| Slide.customContent embedVideo
