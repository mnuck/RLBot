import math

### Types

type Vector3 {.exportc.} = object
    X: float
    Y: float
    Z: float

  
type Rotator {.exportc.} = object
    Yaw: float
    Pitch: float
    Roll: float
  
type Touch {.exportc.} = object
    PlayerName: cstring
    GameSeconds: float
    Location: Vector3
    Normal: Vector3

type ScoreInfo {.exportc.} = object
    Score: int32
    Goals: int32
    OwnGoals: int32
    Assists: int32
    Saves: int32
    Shots: int32
    Demolitions: int32

type PlayerInfo {.exportc.} = object
    Location: Vector3
    Rotation: Rotator
    Velocity: Vector3
    AngularVelocity: Vector3
    ScoreInfo: ScoreInfo
    IsDemolished: bool
    IsMidair: bool
    IsSuperSonic: bool
    IsBot: bool
    Jumped: bool
    DoubleJumped: bool
    Name: cstring
    Team: int32
    Boost: int32

type BallInfo {.exportc.} = object
    Location: Vector3
    Rotation: Rotator
    Velocity: Vector3
    AngularVelocity: Vector3
    Acceleration: Vector3
    LatestTouch: Touch

type BoostInfo {.exportc.} = object
    Location: Vector3
    IsActive: bool
    Timer: int32

type GameInfo {.exportc.} = object
    SecondsElapsed: float
    GameTimeRemaining: float
    IsOverTime: bool
    IsUnlimitedTime: bool
    IsRoundActive: bool
    IsKickoffPause: bool
    IsMatchEnded: bool

type GameTickPacket {.exportc.} = object
    Players: seq[PlayerInfo] not nil
    PlayerIndex: int32
    BoostPads: seq[BoostInfo] not nil
    Ball: BallInfo
    Game: GameInfo

type ControllerState {.exportc.} = object
    Throttle: float
    Steer: float
    Pitch: float
    Yaw: float
    Roll: float
    Jump: bool
    Boost: bool
    Handbrake: bool
    
### Business Logic

var
  GlobalGameTickPacket: GameTickPacket
  
proc scaleRadians(angle: float): float =
  if angle > 0.0:
    let rotations = ((angle + math.PI) / math.TAU).floor()
    return angle - (rotations * math.TAU)
  let rotations = ((angle - math.PI) / math.TAU).ceil()
  return angle + (rotations * math.TAU)

proc `+` (a, b: Rotator): Rotator =
  result.Yaw = scaleRadians(a.Yaw + b.Yaw)
  result.Pitch = scaleRadians(a.Pitch + b.Pitch)
  result.Roll = scaleRadians(a.Roll + b.Roll)

proc `-` (a, b: Rotator): Rotator =
  result.Yaw = scaleRadians(a.Yaw - b.Yaw)
  result.Pitch = scaleRadians(a.Pitch - b.Pitch)
  result.Roll = scaleRadians(a.Roll - b.Roll)

proc `+` (a, b: Vector3): Vector3 =
  result.X = a.X + b.X
  result.Y = a.Y + b.Y
  result.Z = a.Z + b.Z

proc `-` (a, b: Vector3): Vector3 =
  result.X = a.X - b.X
  result.Y = a.Y - b.Y
  result.Z = a.Z - b.Z

proc magnitude(a: Vector3): float =
  result = math.sqrt(a.X * a.X + a.Y * a.Y + a.Z * a.Z)

proc unit(a: Vector3): Vector3 =
  let divisor = a.magnitude
  if divisor == 0.0:
    return Vector3()
  result.X = a.X / divisor
  result.Y = a.Y / divisor
  result.Z = a.Z / divisor

proc rotator(v: Vector3): Rotator =
  result.Yaw = scaleRadians(math.arctan2(v.Y, v.X))
  result.Pitch = scaleRadians(math.arctan2(math.sqrt(v.X * v.X + v.Y * v.Y), v.Z))
  result.Roll = 0.0

proc GetControllerState*(): ControllerState {.stdcall, exportc, dynlib.} =
  let car = GlobalGameTickPacket.Players[GlobalGameTickPacket.PlayerIndex]
  let opponent = GlobalGameTickPacket.Players[1 - GlobalGameTickPacket.PlayerIndex]
  let intent = (opponent.Location - car.Location).rotator
  let correction = intent - car.Rotation

  let turnMultiplier = 3.0
  result.Steer = correction.Yaw * turnMultiplier
  if result.Steer < -1.0:
    result.Steer = -1.0
  if result.Steer > 1.0:
    result.Steer = 1.0

  let brakeLimit = math.PI / 2.0
  result.Handbrake = false
  if correction.Yaw < - brakeLimit or correction.Yaw > brakeLimit:
    result.Handbrake = true

  result.Boost = false
  if car.Velocity.magnitude > 1300 and abs(correction.Yaw) < 0.5:
    result.Boost = true
    
  result.Yaw = result.Steer
  result.Throttle = 1.0
  result.Boost = true
  

### Plumbing

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
