module Contact exposing (Model, Msg, init, update, view)

import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Checkbox as Checkbox
import Bootstrap.Form.Fieldset as Fieldset
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Radio as Radio
import Bootstrap.Form.Select as Select
import Bootstrap.Form.Textarea as Textarea
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Regex exposing (Regex)
import StyleSheet


event s =
    Html.Events.onInput SetName


view : Model -> Html msg
view model =
    div StyleSheet.embeddedContentStyle [ form model ]


form : Model -> Html msg
form model =
    Form.form []
        [ h4 [ style [ ( "text-align", "center" ) ] ] [ text "contact us" ]
        , h6 [ style [ ( "text-align", "center" ) ] ] [ text "we'd love to hear from you." ]
        , br [] []
        , Input.text [ Input.attrs [ placeholder "name" ] ]
        , br [] []
        , Input.email [ Input.attrs [ placeholder "email" ] ]
        , br [] []
        , submissionTypesRadioButtons
        , br [] []
        , Textarea.textarea
            [ Textarea.id "message"
            , Textarea.rows 5
            ]
        , br [] []
        , Button.button [ Button.outlinePrimary, Button.disabled (not (canSubmit model)) ] [ text "submit" ]
        ]


type Msg
    = Submit
    | SetName String
    | SetEmail String
    | SetBodyText String
    | SetFormSubmissionType FormSubmissionType


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetName name ->
            ( { model | name = name, nameIsValid = validateName name }, Cmd.none )

        SetEmail email ->
            ( { model | email = email, emailIsValid = validateEmail email }, Cmd.none )

        SetBodyText body ->
            ( { model | bodyText = body }, Cmd.none )

        SetFormSubmissionType submissionType ->
            ( { model | submissionType = submissionType }, Cmd.none )

        Submit ->
            ( init, Cmd.none )


validateName : String -> Bool
validateName name =
    String.length name > 3


validateEmail : String -> Bool
validateEmail email =
    let
        validEmail =
            "^[a-zA-Z0-9.!#$%&'*+\\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
                |> Regex.regex
                |> Regex.caseInsensitive
    in
    Regex.contains validEmail email


type alias Model =
    { name : String
    , nameIsValid : Bool
    , email : String
    , emailIsValid : Bool
    , submissionType : FormSubmissionType
    , bodyText : String
    , bodyIsValid : Bool
    }


init : Model
init =
    { name = ""
    , nameIsValid = False
    , email = ""
    , emailIsValid = False
    , submissionType = FeatureRequest
    , bodyText = ""
    , bodyIsValid = True
    }


canSubmit : Model -> Bool
canSubmit model =
    model.nameIsValid && model.emailIsValid && model.bodyIsValid



-- | FormResponse (Result Http.Error String)


type FormSubmissionType
    = FeatureRequest
    | Review
    | CrashReport
    | Support
    | Other


submissionTypes : List FormSubmissionType
submissionTypes =
    [ FeatureRequest
    , Review
    , CrashReport
    , Support
    , Other
    ]


submissionTypeIdentifier : FormSubmissionType -> String
submissionTypeIdentifier submissionType =
    case submissionType of
        FeatureRequest ->
            "feature request"

        Review ->
            "review"

        CrashReport ->
            "bug / crash report"

        Support ->
            "support"

        Other ->
            "other"


identifierToSubmissionType : String -> FormSubmissionType
identifierToSubmissionType string =
    case string of
        "feature request" ->
            FeatureRequest

        "review" ->
            Review

        "bug / crash report" ->
            CrashReport

        "support" ->
            Support

        _ ->
            Other


submissionTypesRadioButtons : Html msg
submissionTypesRadioButtons =
    let
        typeToRadio =
            \s -> Radio.create [ Radio.id (submissionTypeIdentifier s) ] (submissionTypeIdentifier s)
    in
    Fieldset.config
        |> Fieldset.asGroup
        |> Fieldset.children
            (Radio.radioList "myradios"
                (List.map
                    typeToRadio
                    submissionTypes
                )
            )
        |> Fieldset.view
