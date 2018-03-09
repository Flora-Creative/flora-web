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
    [ Options.center
    , style [ ( "width", "90%" ), ( "margin", "auto" ) ] |> Options.attribute
    ]


appImageGridCell : String -> Grid.Cell msg
appImageGridCell url =
    Grid.cell [ Grid.size Grid.All 6, Typo.center ]
        [ img [ src url, style [ ( "width", "90%" ) ] ] [] ]



-- This will return a List of Grid cells for laying out the video, or an empty
-- list if it cannot construct it.


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
                    [ iframe
                        [ src url
                        , style
                            [ ( "class", "vimeo" )
                            , ( "width", "100%" )
                            , ( "height", "100%" )
                            , ( "max-width", "100%" )
                            , ( "margin", "1em 0 1.5em 0" )
                            , ( "allowfullscreen", "true" )
                            ]
                        ]
                        []
                    ]
            )
        |> maybeToSingletonOrEmptyList


maybeToSingletonOrEmptyList : Maybe a -> List a
maybeToSingletonOrEmptyList a =
    a |> Maybe.map List.singleton |> Maybe.withDefault []


appImageGrid : IOSApp -> List (Html msg)
appImageGrid app =
    [ List.map appImageGridCell app.images |> Grid.grid appImageGridStyle ]


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
            , ( "background-color", "#" ++ app.backgroundColor )
            , ( "color", app.foregroundColor )
            , ( "padding-top", "10em" )
            , ( "padding-bottom", "10em" )
            ]
        , id app.shortName
        ]
        [ h2 [ style [] ]
            [ text app.appName ]
        , appCopyStyle app.appDescription
        , appImageVideoGrid app
        ]
