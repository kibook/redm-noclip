Config = {}

-- Configurable controls
Config.ToggleControl        = 0x35957F6C -- F6
Config.IncreaseSpeedControl = 0x446258B6 -- Page Up
Config.DecreaseSpeedControl = 0x3C3DD371 -- Page Down
Config.UpControl            = 0xD9D0E1C0 -- Spacebar
Config.DownControl          = 0x8FFC75D6 -- Shift
Config.ForwardControl       = 0x8FD015D8 -- W
Config.BackwardControl      = 0xD27782E3 -- S
Config.LeftControl          = 0x7065027D -- A
Config.RightControl         = 0xB4E465B4 -- D
Config.ToggleModeControl    = 0xDE794E3E -- Q

-- Maximum speed
Config.MaxSpeed = 10.0

-- Minimum speed
Config.MinSpeed = 0.1

-- How much speed increases by when speed up/down controls are pressed
Config.SpeedIncrement = 0.1

-- Default speed
Config.Speed = 0.1

-- Whether to enable relative mode by default.
--
-- false: Movement is based on the cardinal directions.
-- 	W = North
-- 	S = South
-- 	A = East
-- 	D = West
--
-- true: Movement is based on the current heading.
-- 	W = forward
-- 	S = backwards
-- 	A = rotate left
-- 	D = rotate right
--
Config.RelativeMode = true
