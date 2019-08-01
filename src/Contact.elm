module Contact exposing (Model, Msg, init, update, view)

import API exposing (decodeContactForm, encodeContactForm, postContact)
import Bootstrap.Alert as Alert
import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Fieldset as Fieldset
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Radio as Radio
import Bootstrap.Form.Textarea as Textarea
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Regex exposing (Regex)
import StyleSheet


view : Model -> Html Msg
view model =
    case model.submissionPending of
        False ->
            div StyleSheet.embeddedContentStyle [ alert model, form model ]

        True ->
            StyleSheet.loadingView


type alias Model =
    { name : String
    , nameIsValid : Bool
    , email : String
    , emailIsValid : Bool
    , submissionType : FormSubmissionType
    , bodyText : String
    , bodyIsValid : Bool
    , alertVisibility : Alert.Visibility
    , submissionPending : Bool
    }


init : Model
init =
    { name = ""
    , nameIsValid = False
    , email = ""
    , emailIsValid = False
    , submissionType = FeatureRequest
    , bodyText = ""
    , bodyIsValid = False
    , alertVisibility = Alert.closed
    , submissionPending = False
    }


alert : Model -> Html Msg
alert model =
    Alert.config
        |> Alert.info
        |> Alert.dismissable AlertMsg
        |> Alert.children
            [ h6 [ style [ ( "text-align", "center" ) ] ] [ text "contact submission sent" ]
            , p [ style [ ( "text-align", "center" ) ] ] [ text "thanks, we'll get back to you in a bit!" ]
            ]
        |> Alert.view model.alertVisibility


type Msg
    = Submit
    | SetName String
    | SetEmail String
    | SetBodyText String
    | SetFormSubmissionType FormSubmissionType
    | AlertMsg Alert.Visibility
    | FormAPIResponse (Result Http.Error API.ContactForm)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetName name ->
            ( { model | name = name, nameIsValid = characterCountIsGreaterThan 3 name }, Cmd.none )

        SetEmail email ->
            ( { model | email = email, emailIsValid = validateEmail email }, Cmd.none )

        SetBodyText body ->
            ( { model | bodyText = body, bodyIsValid = characterCountIsGreaterThan 8 body }, Cmd.none )

        SetFormSubmissionType submissionType ->
            ( { model | submissionType = submissionType }, Cmd.none )

        Submit ->
            Debug.log "Submitting form"
                ( { model | submissionPending = True }, submitFormCommand model )

        AlertMsg visibility ->
            ( { model | alertVisibility = visibility }, Cmd.none )

        FormAPIResponse result ->
            case result of
                Err error ->
                    Debug.log (toString error)
                        ( model, Cmd.none )

                Ok apps ->
                    Debug.log "Sent contact form successfully."
                        ( { init | alertVisibility = Alert.shown }, Cmd.none )


submitFormCommand : Model -> Cmd Msg
submitFormCommand model =
    let
        contactForm =
            formFromModel model

        postRequest =
            API.postContact "https://flora-api.herokuapp.com" contactForm
    in
    Http.send FormAPIResponse postRequest


formFromModel : Model -> API.ContactForm
formFromModel model =
    { origin = "Website"
    , name = model.name
    , email = model.email
    , subject = submissionTypeIdentifier model.submissionType
    , message = model.bodyText
    , leaveMeBlank = Nothing
    }


form : Model -> Html Msg
form model =
    Form.form []
        [ h4 [ style [ ( "text-align", "center" ) ] ] [ text "contact us" ]
        , h6 [ style [ ( "text-align", "center" ) ] ] [ text "we'd love to hear from you." ]
        , br [] []
        , Input.text [ Input.attrs [ placeholder "name" ], Input.onInput SetName, Input.value model.name ]
        , br [] []
        , Input.email [ Input.attrs [ placeholder "email" ], Input.onInput SetEmail, Input.value model.email ]
        , br [] []
        , submissionTypesRadioButtons model
        , br [] []
        , Textarea.textarea
            [ Textarea.id "message"
            , Textarea.rows 5
            , Textarea.onInput SetBodyText
            , Textarea.value model.bodyText
            ]
        , br [] []
        , Button.button [ Button.outlinePrimary, Button.disabled (not (canSubmit model)), Button.onClick Submit ] [ text "submit" ]
        ]


characterCountIsGreaterThan : Int -> String -> Bool
characterCountIsGreaterThan characterCount string =
    String.length string > characterCount


validateEmail : String -> Bool
validateEmail email =
    let
        validEmail =
            "^[a-zA-Z0-9.!#$%&'*+\\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
                |> Regex.regex
                |> Regex.caseInsensitive
    in
    Regex.contains validEmail email


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


submissionTypesRadioButtons : Model -> Html Msg
submissionTypesRadioButtons model =
    let
        typeToRadio =
            \s -> Radio.create [ Radio.id (submissionTypeIdentifier s), Radio.onClick (SetFormSubmissionType s), Radio.checked (s == model.submissionType) ] (submissionTypeIdentifier s)
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
