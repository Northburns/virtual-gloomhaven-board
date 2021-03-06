module GameSyncTests exposing (suite)

import Array
import BoardMapTile exposing (MapTileRef(..))
import BoardOverlay exposing (BoardOverlay, BoardOverlayDirectionType(..), BoardOverlayType(..), ChestType(..), DoorSubType(..), ObstacleSubType(..), TrapSubType(..), TreasureSubType(..))
import Character exposing (CharacterClass(..))
import Dict
import Expect exposing (equal)
import Game exposing (AIType(..), Expansion(..), GameState, GameStateScenario(..), Piece, PieceType(..), SummonsType(..))
import GameSync exposing (decodeGameState, encodeGameState)
import Json.Decode exposing (decodeString)
import Json.Encode exposing (encode)
import Monster exposing (BossType(..), Monster, MonsterType(..), NormalMonsterType(..))
import Test exposing (Test, describe, test)


encodedJson : String
encodedJson =
    """{
    "scenario": {
        "expansion": "gloomhaven",
        "id": 1
    },
    "players": [
        {
            "class": "brute"
        },
        {
            "class": "cragheart"
        },
        {
            "class": "tinkerer"
        }
    ],
    "updateCount": 2,
    "visibleRooms": [
        "a1b",
        "a2a"
    ],
    "overlays": [
        {
            "ref": {
                "type": "starting-location"
            },
            "direction": "default",
            "cells": [
                [
                    0,
                    1
                ]
            ]
        },
        {
            "ref": {
                "type": "treasure",
                "subType": "chest",
                "id": "goal"
            },
            "direction": "diagonal-right",
            "cells": [
                [
                    1,
                    2
                ]
            ]
        },
        {
            "ref": {
                "type": "treasure",
                "subType": "chest",
                "id": "1"
            },
            "direction": "diagonal-right",
            "cells": [
                [
                    2,
                    2
                ]
            ]
        },
        {
            "ref": {
                "type": "treasure",
                "subType": "coin",
                "amount": 2
            },
            "direction": "diagonal-left",
            "cells": [
                [
                    2,
                    3
                ]
            ]
        },
        {
            "ref": {
                "type": "treasure",
                "subType": "coin",
                "amount": 1
            },
            "direction": "diagonal-left",
            "cells": [
                [
                    2,
                    4
                ]
            ]
        },
        {
            "ref": {
                "type": "door",
                "subType": "stone",
                "links": [
                    "a1a",
                    "a2a"
                ]
            },
            "direction": "horizontal",
            "cells": [
                [
                    6,
                    5
                ]
            ]
        },
        {
            "ref": {
                "type": "trap",
                "subType": "bear"
            },
            "direction": "vertical",
            "cells": [
                [
                    7,
                    5
                ]
            ]
        },
        {
            "ref": {
                "type": "obstacle",
                "subType": "sarcophagus"
            },
            "direction": "horizontal",
            "cells": [
                [
                    6,
                    5
                ],
                [
                    7,
                    5
                ]
            ]
        }
    ],
    "pieces": [
        {
            "ref": {
                "type": "player",
                "class": "cragheart"
            },
            "x": 1,
            "y": 2
        },
        {
            "ref": {
                "type": "monster",
                "class": "cultist",
                "id": 3,
                "level": "normal",
                "wasSummoned": false
            },
            "x": 3,
            "y": 5
        },
        {
            "ref": {
                "type": "monster",
                "class": "inox-shaman",
                "id": 1,
                "level": "elite",
                "wasSummoned": false
            },
            "x": 4,
            "y": 5
        },
        {
            "ref": {
                "type": "monster",
                "class": "jekserah",
                "id": 1,
                "level": "normal",
                "wasSummoned": false
            },
            "x": 4,
            "y": 6
        },
        {
            "ref": {
                "type": "summons",
                "id": 1
            },
            "x": 2,
            "y": 2
        }
    ],
    "availableMonsters": [
        {
            "ref": "cultist",
            "bucket": [
                1
            ]
        }
    ],
    "roomCode": ""
}"""


decodedState : GameState
decodedState =
    GameState
        (InbuiltScenario Gloomhaven 1)
        [ Brute, Cragheart, Tinkerer ]
        2
        [ A1b, A2a ]
        [ BoardOverlay StartingLocation Default [ ( 0, 1 ) ]
        , BoardOverlay (Treasure (Chest Goal)) DiagonalRight [ ( 1, 2 ) ]
        , BoardOverlay (Treasure (Chest (NormalChest 1))) DiagonalRight [ ( 2, 2 ) ]
        , BoardOverlay (Treasure (Coin 2)) DiagonalLeft [ ( 2, 3 ) ]
        , BoardOverlay (Treasure (Coin 1)) DiagonalLeft [ ( 2, 4 ) ]
        , BoardOverlay (Door Stone [ A1a, A2a ]) Horizontal [ ( 6, 5 ) ]
        , BoardOverlay (Trap BearTrap) Vertical [ ( 7, 5 ) ]
        , BoardOverlay (Obstacle Sarcophagus) Horizontal [ ( 6, 5 ), ( 7, 5 ) ]
        ]
        [ Piece (Player Cragheart) 1 2
        , Piece (AI (Enemy (Monster (NormalType Cultist) 3 Monster.Normal False))) 3 5
        , Piece (AI (Enemy (Monster (NormalType InoxShaman) 1 Monster.Elite False))) 4 5
        , Piece (AI (Enemy (Monster (BossType Jekserah) 1 Monster.Normal False))) 4 6
        , Piece (AI (Summons (NormalSummons 1))) 2 2
        ]
        (Dict.fromList [ ( "cultist", Array.fromList [ 1 ] ) ])
        ""


suite : Test
suite =
    describe "The Game Sync module"
        [ describe "GameSync.decodeGameState"
            [ test "should output a game state from JSON" <|
                \_ ->
                    decodeString decodeGameState encodedJson
                        |> Expect.equal (Ok decodedState)
            ]
        , describe "GameSync.encodeGameState"
            [ test "should output a JSON string" <|
                \_ ->
                    encode 4 (encodeGameState decodedState)
                        |> Expect.equal encodedJson
            ]
        ]
