module App exposing (Model, Msg, init, subscriptions, update, view)

import API exposing (IOSApp)
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Carousel as Carousel
import Bootstrap.Carousel.Slide as Slide
import Bootstrap.Text as Text
import Bootstrap.Utilities.Border as Border
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
    in
    Card.config
        [ alignment
        , Card.attrs
            [ style
                [ ( "width", "85%" )
                , ( "margin", "auto" )
                , ( "border-width", "0px" )
                , ( "-webkit-border-radius", "10px" )
                , ( "-moz-border-radius", "10px" )
                , ( "border-radius", "10px" )
                , ( "backgroundColor", "#" ++ app.backgroundColor )
                , ( "color", app.foregroundColor )

                -- , ( "paddingTop", "3em" )
                -- , ( "paddingBottom", "3em" )
                ]
            , id app.shortName
            ]
        ]
        |> Card.block []
            [ Block.titleH1 [ textPadding, StyleSheet.avenir, StyleSheet.semibold ] [ text app.appName ]
            , Block.custom <| carousel model
            , Block.titleH5 [ textPadding, StyleSheet.avenir, StyleSheet.regular, style [ ( "paddingBottom", "0em" ) ] ] [ text app.appDescription ]
            , Block.link [ style [ ( "float", "center" ) ] ] <| [ appStoreIcon app.itunesUrl ]
            ]
        |> Card.view


appStoreIcon : String -> Html msg
appStoreIcon url =
    a
        [ href url
        , style [ ( "float", "center" ) ]
        , textPadding
        ]
        [ img [ src (cloudinaryURL ++ "assets/app_store.png"), Html.Attributes.width 240 ] []
        ]


textPadding : Attribute msg
textPadding =
    style
        [ ( "paddingTop", "0em" )
        , ( "paddingBottom", "0em" )
        , ( "paddingLeft", "1em" )
        , ( "paddingRight", "1em" )
        ]


carouselPadding : Attribute msg
carouselPadding =
    style
        [ ( "paddingLeft", "1em" )
        , ( "paddingRight", "1em" )
        ]


carousel : Model -> Html Msg
carousel model =
    let
        imageToSlide =
            \url -> Slide.config [] (Slide.image [] url)

        slides =
            List.map videoToSlide model.app.videoLinks ++ makeImages model.app.shortName
    in
    Carousel.config CarouselMsg [ carouselPadding ]
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
    url |> embedVideo |> Slide.customContent |> Slide.config []


embedIframeStyle : Html.Attribute msg
embedIframeStyle =
    style
        [ ( "top", "0" )
        , ( "left", "0" )
        , ( "border", "0" )
        , ( "height", "100%" )
        , ( "width", "100%" )
        , ( "position", "absolute" )
        ]


embedWrapperStyle : Html.Attribute msg
embedWrapperStyle =
    style
        [ ( "overflow", "hidden" )
        , ( "position", "relative" )
        , ( "paddingBottom", "75%" )
        ]


{-| Embed a vimeo video in a responsive wrapper
-}
embedVideo : String -> Html msg
embedVideo url =
    div [ embedWrapperStyle ] [ iframe [ src url, embedIframeStyle ] [] ]
