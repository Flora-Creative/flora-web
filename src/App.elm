module App exposing (Model, Msg, init, subscriptions, update, view)

import API exposing (IOSApp)
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Carousel as Carousel
import Bootstrap.Carousel.Slide as Slide
import Bootstrap.Text as Text
import Bootstrap.Utilities.Border as Border
import Html exposing (..)
import Html.Attributes exposing (href, id, src, style)


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
                , ( "backgroundColor", "#" ++ app.backgroundColor )
                , ( "color", app.foregroundColor )
                , ( "paddingTop", "3em" )
                , ( "paddingBottom", "3em" )
                ]
            , id app.shortName
            , Border.dark
            , Border.rounded
            ]
        ]
        |> Card.block []
            [ Block.titleH1 [] [ text app.appName ]
            , Block.custom <| carousel model
            , Block.titleH5 [] [ text app.appDescription ]
            ]
        |> Card.view


carousel : Model -> Html Msg
carousel model =
    let
        imageToSlide =
            \url -> Slide.config [] (Slide.image [] url)

        slides =
            List.map videoToSlide model.app.videoLinks ++ List.map imageToSlide model.app.images
    in
    Carousel.config CarouselMsg []
        |> Carousel.slides slides
        |> Carousel.view model.carouselState


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

        -- , ( "height", "0" )
        , ( "paddingBottom", "56.25%" )
        ]


{-| Embed a vimeo video in a responsive wrapper
-}
embedVideo : String -> Html msg
embedVideo url =
    div [ embedWrapperStyle ] [ iframe [ src url, embedIframeStyle ] [] ]
