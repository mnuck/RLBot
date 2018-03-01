import math

from rlplumbing import Vector3, Rotator, Touch, ScoreInfo, PlayerInfo, BallInfo, BoostInfo, GameInfo, GameTickPacket, ControllerState, GlobalGameTickPacket, NewVector3, NewRotator, NewTouch, NewScoreInfo, NewPlayerInfo, NewBallInfo, NewBoostInfo, NewGameInfo, ClearGameTickPacket, SetPlayerIndex, SetBallInfo, SetGameInfo, AddPlayerInfo, AddBoostInfo
  
proc scaleRadians(angle: float): float =
  let rotations = ((abs(angle) - math.PI) / math.TAU).ceil()
  if angle > 0.0:
    return angle - (rotations * math.TAU)
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
  let target = GlobalGameTickPacket.Ball
  #let target = GlobalGameTickPacket.Players[1 - GlobalGameTickPacket.PlayerIndex]
  let intent = (target.Location - car.Location).rotator
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
