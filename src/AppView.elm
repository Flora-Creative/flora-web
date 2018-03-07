module AppView exposing (view)

import API exposing (IOSApp)
import Html exposing (..)
import Html.Attributes exposing (href, src, style)
import Material.Options as Options
import Material.Typography as Typo
import Material.Grid as Grid


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
            , ( "width", "100%" )
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
    Grid.cell [ Grid.size Grid.All 4, Typo.center ]
        [ img [ src url, style [ ( "width", "100%" ) ] ] [] ]


appImageGrid : IOSApp -> Html msg
appImageGrid app =
    app.images
        |> List.map appImageGridCell
        |> Grid.grid appImageGridStyle


view : IOSApp -> Html msg
view app =
    div
        [ style
            [ ( "width", "100%" )
            , ( "background-color", "#" ++ app.backgroundColor )
            , ( "color", app.foregroundColor )
            ]
        ]
        [ h2 [ style [] ]
            [ text app.appName ]
        , appCopyStyle app.appDescription
        , appImageGrid app
        ]
