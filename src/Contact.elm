module Contact exposing (Msg, view)

{-| View / logic for the contact us form
-}

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


view : Html msg
view =
    Form.form []
        [ h4 [] [ text "contact flora creative" ]
        , Input.text [ Input.attrs [ placeholder "name" ] ]
        , Input.text [ Input.attrs [ placeholder "email" ] ]
        , submissionTypesRadioButtons
        , Textarea.textarea
            [ Textarea.id "message"
            , Textarea.rows 5
            ]
        ]


type Msg
    = NoOp
    | SubmitForm
    | SetName String
    | SetResponseEmail String
    | SetBodyText String
    | SetFormSubmissionType FormSubmissionType



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
        |> Fieldset.legend [] [ text "Radio buttons" ]
        |> Fieldset.children
            (Radio.radioList "myradios"
                (List.map
                    typeToRadio
                    submissionTypes
                )
            )
        |> Fieldset.view
