module StyleSheet exposing (..)

import Bootstrap.Progress as Progress
import Html exposing (Attribute, div, h3, hr, text)
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


embeddedContentStyle : List (Html.Attribute msg)
embeddedContentStyle =
    [ style
        [ ( "background-color", mutedMustard )
        , ( "padding", "2em" )
        , ( "width", "85%" )
        , ( "margin", "auto" )
        , ( "color", blueGray )
        , ( "margin-top", "2em" )
        , ( "letter-spacing", "0.05em" )
        , ( "box-shadow", "0px 2px 5px 3px #222222" )
        , ( "margin-bottom", "2em" )
        , ( "border-radius", "15px" )
        ]
    , avenir
    , regular
    ]


navBarStyle : List (Html.Attribute msg)
navBarStyle =
    [ style
        [ ( "background-color", "#7f6f78" )
        , ( "padding", "1em" )
        , ( "margin", "auto" )
        , ( "color", "#605b74" )
        , ( "margin-bottom", "1.5em" )
        , ( "box-shadow", "0px 2px 5px 3px #222222" )
        , ( "width", "85%" )
        , ( "border-bottom-right-radius", "15px" )
        , ( "border-bottom-left-radius", "15px" )
        ]
    , avenir
    , regular
    ]


blueGray : String
blueGray =
    "#2e323f"


mutedMustard : String
mutedMustard =
    "#edeae4"


separatorWithColor : String -> Html.Html msg
separatorWithColor colorString =
    hr [ style [ ( "background-color", colorString ), ( "border", "none" ), ( "height", "1px" ) ] ] []


loadingView : Html.Html msg
loadingView =
    div
        (style [ ( "padding", "5em" ) ] :: embeddedContentStyle)
        [ Progress.progress
            [ Progress.value 100
            , Progress.animated
            ]
        , h3 [ avenir, mainBodyTextStyle ] [ text "just a moment" ]
        ]


mainBodyTextStyle : Attribute msg
mainBodyTextStyle =
    style
        [ ( "text-align", "center" )
        , ( "width", "70%" )
        , ( "margin", "auto" )
        , ( "color", blueGray )
        ]
