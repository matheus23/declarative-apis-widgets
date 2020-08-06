module Main exposing (main)

import Browser
import Components.CodeHighlighted as CodeHighlighted
import Components.CodeInteractiveElm as CodeInteractiveElm
import Components.CodeInteractiveJs as CodeInteractiveJs
import Html exposing (Html)
import Result.Extra as Result


type Model
    = Error String
    | InteractiveElm CodeInteractiveElm.Model
    | InteractiveJs CodeInteractiveJs.Model
    | HighlightCode { language : String, source : String }


type Msg
    = InteractiveElmMsg CodeInteractiveElm.Msg
    | InteractiveJsMsg CodeInteractiveJs.Msg


type alias Flags =
    { language : String, source : String }


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update =
            \msg model ->
                ( update msg model
                  -- Never using commands
                , Cmd.none
                )

        -- Never using subscriptions
        , subscriptions = \_ -> Sub.none
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( case flags.language of
        "elm interactive" ->
            CodeInteractiveElm.init flags.source
                |> Result.map InteractiveElm
                |> Result.mapError Error
                |> Result.merge

        "js interactive" ->
            CodeInteractiveJs.init flags.source
                |> Result.map InteractiveJs
                |> Result.mapError Error
                |> Result.merge

        _ ->
            HighlightCode flags
      -- Never using commands
    , Cmd.none
    )


view : Model -> Html Msg
view model =
    case model of
        Error message ->
            Html.pre []
                [ Html.text message ]

        InteractiveElm m ->
            CodeInteractiveElm.view m
                |> Html.map InteractiveElmMsg

        InteractiveJs m ->
            CodeInteractiveJs.view m
                |> Html.map InteractiveJsMsg

        HighlightCode { language, source } ->
            CodeHighlighted.view
                { language = Just language
                , body = source
                }


update : Msg -> Model -> Model
update msg model =
    case ( msg, model ) of
        ( _, Error _ ) ->
            model

        ( InteractiveElmMsg elmMsg, InteractiveElm elmModel ) ->
            InteractiveElm (CodeInteractiveElm.update elmMsg elmModel)

        ( InteractiveJsMsg jsMsg, InteractiveJs jsModel ) ->
            InteractiveJs (CodeInteractiveJs.update jsMsg jsModel)

        ( _, _ ) ->
            model
