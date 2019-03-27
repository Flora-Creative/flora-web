module StyleSheet exposing (..)

import Html exposing (Attribute)
import Html.Attributes exposing (style)


avenir : Html.Attribute msg
avenir =
    style
        [ ( "font-family", "\"Avenir\", Times" )
        , ( "font-feature-settings", "\"liga\" 0" )
        ]


semibold : Html.Attribute msg
semibold =
    style [ ( "font-weight", "bold" ) ]


regular : Html.Attribute msg
regular =
    style [ ( "font-weight", "normal" ) ]
