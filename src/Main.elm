module Main exposing (main)

import Browser
import Components.CodeInteractiveElm as CodeInteractiveElm
import Language.InteractiveElm as InteractiveElm
import Result.Extra as Result


type alias Model =
    CodeInteractiveElm.Model


type alias Msg =
    CodeInteractiveElm.Msg


type alias Flags =
    { language : String, source : String }


main : Program Flags Model Msg
main =
    Browser.element
        { init =
            \flags ->
                ( CodeInteractiveElm.init flags.source
                    |> Result.mapError renderError
                    |> Result.merge
                  -- Never using commands
                , Cmd.none
                )
        , view = CodeInteractiveElm.view
        , update =
            \msg model ->
                ( CodeInteractiveElm.update msg model
                  -- Never using commands
                , Cmd.none
                )

        -- Never using subscriptions
        , subscriptions = \_ -> Sub.none
        }


renderError : String -> CodeInteractiveElm.Model
renderError error =
    { expression =
        InteractiveElm.PartialExpression False
            (InteractiveElm.EmptyPicture
                (String.join "\n"
                    [ "{- There was an error parsing this widget's code:"
                    , error
                    , "-}"
                    , ""
                    ]
                )
                ""
            )
    }
