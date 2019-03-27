module About exposing (view)

import Html exposing (..)
import Html.Attributes exposing (style)
import StyleSheet


view : Html msg
view =
    div []
        [ div
            [ StyleSheet.avenir
            , StyleSheet.regular
            , style
                [ ( "background-color", "#edeae4" )
                , ( "color", "#2e323f" )
                , ( "text-align", "center" )
                , ( "width", "70%" )
                , ( "margin", "auto" )
                , ( "color", "#605b74" )
                ]
            ]
            [ text floraCreativeCopy ]
        ]


floraCreativeCopy : String
floraCreativeCopy =
    """
In the small city of Wellington, New Zealand - Flora Creative was founded by sound-artists / software developers Timothy J. Barraclough & Paul Mathews.
founded in 2016 as a small project to build affordable, simplistic audio effects for iOS has blossomed into a creative endeavour to build boutique,
utilitarian artwork that enriches the lives of musicians, composers, sound designers and audiences around the world.
  """ |> String.toLower
