type Vector3* {.exportc.} = object
    X*: float
    Y*: float
    Z*: float
  
type Rotator* {.exportc.} = object
    Yaw*: float
    Pitch*: float
    Roll*: float
  
type Touch* {.exportc.} = object
    PlayerName*: cstring
    GameSeconds*: float
    Location*: Vector3
    Normal*: Vector3

type ScoreInfo* {.exportc.} = object
    Score*: int32
    Goals*: int32
    OwnGoals*: int32
    Assists*: int32
    Saves*: int32
    Shots*: int32
    Demolitions*: int32

type PlayerInfo* {.exportc.} = object
    Location*: Vector3
    Rotation*: Rotator
    Velocity*: Vector3
    AngularVelocity*: Vector3
    ScoreInfo*: ScoreInfo
    IsDemolished*: bool
    IsMidair*: bool
    IsSuperSonic*: bool
    IsBot*: bool
    Jumped*: bool
    DoubleJumped*: bool
    Name*: cstring
    Team*: int32
    Boost*: int32

type BallInfo* {.exportc.} = object
    Location*: Vector3
    Rotation*: Rotator
    Velocity*: Vector3
    AngularVelocity*: Vector3
    Acceleration*: Vector3
    LatestTouch*: Touch

type BoostInfo* {.exportc.} = object
    Location*: Vector3
    IsActive*: bool
    Timer*: int32

type GameInfo* {.exportc.} = object
    SecondsElapsed*: float
    GameTimeRemaining*: float
    IsOverTime*: bool
    IsUnlimitedTime*: bool
    IsRoundActive*: bool
    IsKickoffPause*: bool
    IsMatchEnded*: bool

type GameTickPacket* {.exportc.} = object
    Players*: seq[PlayerInfo] not nil
    PlayerIndex*: int32
    BoostPads*: seq[BoostInfo] not nil
    Ball*: BallInfo
    Game*: GameInfo

type ControllerState* {.exportc.} = object
    Throttle*: float
    Steer*: float
    Pitch*: float
    Yaw*: float
    Roll*: float
    Jump*: bool
    Boost*: bool
    Handbrake*: bool

var GlobalGameTickPacket*: GameTickPacket
  
proc NewVector3*(): Vector3  {.stdcall, exportc, dynlib.} =
  result = Vector3()

proc NewRotator*(): Rotator {.stdcall, exportc, dynlib.} =
  result = Rotator()

proc NewTouch*(): Touch  {.stdcall, exportc, dynlib.} =
  result = Touch()
  
proc NewScoreInfo*(): ScoreInfo {.stdcall, exportc, dynlib.} =
  result = ScoreInfo()
  
proc NewPlayerInfo*(): PlayerInfo {.stdcall, exportc, dynlib.} =
  result = PlayerInfo()

proc NewBallInfo*(): BallInfo {.stdcall, exportc, dynlib.} =
  result = BallInfo()

proc NewBoostInfo*(): BoostInfo {.stdcall, exportc, dynlib.} =
  result = BoostInfo()

proc NewGameInfo*(): GameInfo {.stdcall, exportc, dynlib.} =
  result = GameInfo()

proc ClearGameTickPacket*() {.stdcall, exportc, dynlib.} =
  GlobalGameTickPacket = GameTickPacket(Players: @[], BoostPads: @[])
  
proc SetPlayerIndex*(index: int32) {.stdcall, exportc, dynlib.} =
  GlobalGameTickPacket.PlayerIndex = index

proc SetBallInfo*(ball: BallInfo) {.stdcall, exportc, dynlib.} =
  GlobalGameTickPacket.Ball = ball

proc SetGameInfo*(game: GameInfo) {.stdcall, exportc, dynlib.} =
  GlobalGameTickPacket.Game = game

proc AddPlayerInfo*(player: PlayerInfo) {.stdcall, exportc, dynlib.} =
  GlobalGameTickPacket.Players.add(player)

proc AddBoostInfo*(boost: BoostInfo) {.stdcall, exportc, dynlib.} =
  GlobalGameTickPacket.BoostPads.add(boost)
