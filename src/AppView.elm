module AppView exposing (view)

import API exposing (IOSApp)
import Html exposing (..)
import Html.Attributes exposing (href, src, style, id)
import Material.Grid as Grid
import Material.Options as Options
import Material.Typography as Typo


appCopyStyle : String -> Html msg
appCopyStyle content =
    Options.styled p
        [ Typo.body1
        , Typo.left
        , style
            [ ( "padding", ".5em" )
            , ( "letter-spacing", "1px" )
            , ( "font-feature-settings", "\"liga\" 0" )
            , ( "font-weight", "200" )
            , ( "width", "70%" )
            , ( "margin", "auto" )
            ]
            |> Options.attribute
        ]
        [ text content ]


appImageGridStyle : List (Options.Style a)
appImageGridStyle =
    [ style
        [ ( "width", "100%" )
        , ( "height", "100%" )
        , ( "margin", "0" )
        , ( "padding", "0" )
        ]
        |> Options.attribute
    , Options.cs "mdl-grid--no-spacing"
    ]


appImageGridCell : Int -> String -> Grid.Cell msg
appImageGridCell cellSize url =
    Grid.cell [ Grid.size Grid.All cellSize, Typo.center ]
        [ img [ src url, style [ ( "width", "95%" ) ] ] [] ]


embedIframeStyle : Html.Attribute msg
embedIframeStyle =
    style
        [ ( "top", "0" )
        , ( "left", "0" )
        , ( "height", "100%" )
        , ( "width", "100%" )
        , ( "position", "absolute" )
        ]


embedWrapperStyle : Html.Attribute msg
embedWrapperStyle =
    style
        [ ( "overflow", "hidden" )
        , ( "position", "relative" )
        , ( "height", "0" )
        , ( "paddingBottom", "56.25%" )
        ]


{-| Embed a vimeo video in a responsive wrapper
-}
embedVideo : String -> Html msg
embedVideo url =
    div [ embedWrapperStyle ] [ iframe [ src url, embedIframeStyle ] [] ]


{-| This will return a List of Grid cells for laying out the video, or an empty
list if it cannot construct it.
-}
appVideoGridCell : IOSApp -> List (Grid.Cell msg)
appVideoGridCell app =
    app.videoLinks
        |> List.head
        |> Maybe.map
            (\urlString ->
                urlString
                    ++ "?color=#"
                    ++ app.backgroundColor
                    ++ "&title=0&byline=0&portrait=0"
            )
        |> Maybe.map
            (\url ->
                Grid.cell [ Grid.size Grid.All 6, Typo.center ]
                    [ embedVideo url
                    ]
            )
        |> maybeToSingletonOrEmptyList


maybeToSingletonOrEmptyList : Maybe a -> List a
maybeToSingletonOrEmptyList a =
    a |> Maybe.map List.singleton |> Maybe.withDefault []


appImageGrid : IOSApp -> List (Html msg)
appImageGrid app =
    let
        cellSize =
            case List.length app.images of
                1 ->
                    8

                2 ->
                    7

                _ ->
                    6
    in
        [ List.map (appImageGridCell cellSize) app.images |> Grid.grid appImageGridStyle ]


appImageVideoGrid : IOSApp -> Html msg
appImageVideoGrid app =
    appVideoGridCell app
        ++ [ Grid.cell [ Grid.size Grid.All 6 ] << appImageGrid <| app ]
        |> Grid.grid appImageGridStyle


view : IOSApp -> Html msg
view app =
    div
        [ style
            [ ( "width", "100%" )
            , ( "backgroundColor", app.foregroundColor )
            , ( "color", "#" ++ app.backgroundColor )
            , ( "paddingTop", "10em" )
            , ( "paddingBottom", "10em" )
            ]
        , id app.shortName
        ]
        [ h2 [ style [ ( "paddingLeft", ".5em" ) ] ]
            [ text app.appName ]
        , appCopyStyle app.appDescription
        , appImageVideoGrid app
        ]
