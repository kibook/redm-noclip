local Enabled = false
local RelativeMode = Config.RelativeMode
local Speed = Config.Speed

-- Return the player or their vehicle/mount if one exists
function GetNoClipTarget()
	local ped = PlayerPedId()
	local veh = GetVehiclePedIsIn(ped, false)
	local mnt = GetMount(ped)
	return (veh == 0 and (mnt == 0 and ped or mnt) or veh)
end

function EnableNoClip()
	local entity = GetNoClipTarget()
	ClearPedTasksImmediately(entity, false, false)
	FreezeEntityPosition(entity, true)
	Enabled = true
end

function DisableNoClip()
	local entity = GetNoClipTarget()
	ClearPedTasksImmediately(entity, false, false)
	FreezeEntityPosition(entity, false)
	Enabled = false
end

function ToggleNoClip()
	if Enabled then
		DisableNoClip()
	else
		EnableNoClip()
	end
end

RegisterCommand('noclip', ToggleNoClip)

function DrawText(text, x, y, centred)
	SetTextScale(0.35, 0.35)
	SetTextColor(255, 255, 255, 255)
	SetTextCentre(centred)
	SetTextDropshadow(1, 0, 0, 0, 200)
	SetTextFontForCurrentCommand(0)
	DisplayText(CreateVarString(10, "LITERAL_STRING", text), x, y)
end

AddEventHandler('onResourceStop', function(resourceName)
	if GetCurrentResourceName() == resourceName and Enabled then
		DisableNoClip()
	end
end)

CreateThread(function()
	TriggerEvent('chat:addSuggestion', '/noclip', 'Toggle noclip mode', {})

	while true do
		Wait(0)

		if IsControlJustPressed(0, Config.ToggleControl) then
			ToggleNoClip()
		end

		if Enabled then
			-- Get the entity we want to control in noclip mode
			local entity = GetNoClipTarget()

			FreezeEntityPosition(entity, true)

			-- FIXME:
			-- Peds face the opposite direction of their heading
			-- when not playing any animation. This can make
			-- orienting yourself in noclip mode confusing.
			--
			-- This function makes the ped face the right way while
			-- not moving in noclip mode, but while moving they
			-- still flip around.
			TaskStandStill(entity, -1)

			-- Get the position and heading of the entity
			local x, y, z = table.unpack(GetEntityCoords(entity))

			-- Cap the speed between MinSpeed and MaxSpeed
			if Speed > Config.MaxSpeed then
				Speed = Config.MaxSpeed
			end
			if Speed < Config.MinSpeed then
				Speed = Config.MinSpeed
			end

			-- Print the current noclip speed on screen
			DrawText(string.format('NoClip Speed: %.1f', Speed), 0.5, 0.90, true)

			-- Change noclip control mode
			if IsControlJustPressed(0, Config.ToggleModeControl) then
				RelativeMode = not RelativeMode
			end

			-- Increase/decrease speed
			if IsControlPressed(0, Config.IncreaseSpeedControl) then
				Speed = Speed + Config.SpeedIncrement
			end
			if IsControlPressed(0, Config.DecreaseSpeedControl) then
				Speed = Speed - Config.SpeedIncrement
			end

			-- Move up/down
			if IsControlPressed(0, Config.UpControl) then
				SetEntityCoordsNoOffset(entity, x, y, z + Speed)
			end
			if IsControlPressed(0, Config.DownControl) then
				SetEntityCoordsNoOffset(entity, x, y, z - Speed)
			end

			if RelativeMode then
				local h = GetEntityHeading(entity)

				-- Print the coordinates, heading and controls on screen
				DrawText(string.format('Coordinates:\nX: %.2f\nY: %.2f\nZ: %.2f\nHeading: %.0f', x, y, z, h), 0.01, 0.3, false)
				DrawText('W/S - Move, A/D - Rotate, Spacebar/Shift - Up/Down, Page Up/Page Down - Change speed, Q - Absolute mode', 0.5, 0.95, true)

				-- Calculate the change in x and y based on the speed and heading.
				local r = -h * math.pi / 180
				local dx = Speed * math.sin(r)
				local dy = Speed * math.cos(r)

				-- Move forward/backward
				if IsControlPressed(0, Config.ForwardControl) then
					SetEntityCoordsNoOffset(entity, x + dx, y + dy, z)
				end
				if IsControlPressed(0, Config.BackwardControl) then
					SetEntityCoordsNoOffset(entity, x - dx, y - dy, z)
				end

				-- Rotate heading
				if IsControlPressed(0, Config.LeftControl) then
					SetEntityHeading(entity, h + 1)
				end
				if IsControlPressed(0, Config.RightControl) then
					SetEntityHeading(entity, h - 1)
				end
			else
				-- Print the coordinates and controls on screen
				DrawText(string.format('Coordinates:\nX: %.2f\nY: %.2f\nZ: %.2f', x, y, z), 0.01, 0.3, false)
				DrawText('W/A/S/D - Move, Spacebar/Shift - Up/Down, Page Up/Page Down - Change speed, Q - Relative mode', 0.5, 0.95, true)

				SetEntityHeading(entity, 0.0)

				-- Move North
				if IsControlPressed(0, Config.ForwardControl) then
					SetEntityCoordsNoOffset(entity, x, y + Speed, z)
				end

				-- Move South
				if IsControlPressed(0, Config.BackwardControl) then
					SetEntityCoordsNoOffset(entity, x, y - Speed, z)
				end

				-- Move East
				if IsControlPressed(0, Config.LeftControl) then
					SetEntityCoordsNoOffset(entity, x - Speed, y, z)
				end

				-- Move West
				if IsControlPressed(0, Config.RightControl) then
					SetEntityCoordsNoOffset(entity, x + Speed, y, z)
				end
			end
		end
	end
end)
