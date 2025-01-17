module Tests exposing (suite)

import Data.Audience as A
import Data.AudienceFolder as F
import DataParser as P
import Expect
import Fuzz
import Json.Decode as Jd
import Json.Encode as Je
import Test as T


suite : T.Test
suite =
    T.describe "all tests"
        [ T.describe "audience decoder" audienceDecoder
        , T.describe "folder decoder" folderDecoder
        ]


folderDecoder : List T.Test
folderDecoder =
    [ T.test "simple folder decoder" <|
        \_ ->
            Expect.ok <|
                Jd.decodeString
                    P.decodeFolders
                    F.audienceFoldersJSON
    , T.fuzz folderFuzz "fuzz encode-decode for folder" <|
        \randomFolder ->
            Expect.ok <|
                Jd.decodeString
                    P.decodeOneFolder
                    (encodeFolder randomFolder)
    ]


audienceDecoder : List T.Test
audienceDecoder =
    [ T.test "simple decode audiences" <|
        \_ ->
            Expect.ok <|
                Jd.decodeString
                    P.decodeAudiences
                    A.audiencesJSON
    , T.fuzz audienceFuzz "fuzz encode-decode for audience" <|
        \randomAudience ->
            Expect.ok <|
                Jd.decodeString
                    P.decodeOneAudience
                    (encodeAudience randomAudience)
    ]


audienceFuzz : Fuzz.Fuzzer A.Audience
audienceFuzz =
    Fuzz.map4 A.Audience
        Fuzz.int
        Fuzz.string
        (Fuzz.oneOf <|
            List.map Fuzz.constant [ A.Curated, A.Shared, A.Authored ]
        )
        (Fuzz.maybe Fuzz.int)


folderFuzz : Fuzz.Fuzzer F.AudienceFolder
folderFuzz =
    Fuzz.map3 F.AudienceFolder
        Fuzz.int
        Fuzz.string
        (Fuzz.maybe Fuzz.int)


encodeType : A.AudienceType -> Je.Value
encodeType type_ =
    case type_ of
        A.Authored ->
            Je.string "user"

        A.Shared ->
            Je.string "shared"

        A.Curated ->
            Je.string "curated"


encodeFolder : F.AudienceFolder -> String
encodeFolder { id, name, parent } =
    Je.encode 4 <|
        Je.object <|
            [ ( "id", Je.int id )
            , ( "name", Je.string name )
            , ( "parent", encodeParent parent )
            ]


encodeParent : Maybe Int -> Je.Value
encodeParent maybe =
    case maybe of
        Nothing ->
            Je.null

        Just parent ->
            Je.int parent


encodeAudience : A.Audience -> String
encodeAudience { id, name, type_, folder } =
    Je.encode 4 <|
        Je.object <|
            [ ( "id", Je.int id )
            , ( "name", Je.string name )
            , ( "type", encodeType type_ )
            ]
                ++ (case folder of
                        Nothing ->
                            []

                        Just i ->
                            [ ( "folder", Je.int i ) ]
                   )
