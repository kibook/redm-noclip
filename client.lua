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

-- Translate 180 degrees for peds, as their models face backwards
function TranslateHeading(entity, h)
	if GetEntityType(entity) == 1 then
		return (h + 180) % 360
	else
		return h
	end
end

function EnableNoClip()
	local entity = GetNoClipTarget()
	ClearPedTasksImmediately(entity, false, false)
	FreezeEntityPosition(entity, true)
	SetEntityHeading(entity, TranslateHeading(entity, GetEntityHeading(entity)))
	Enabled = true
end

function DisableNoClip()
	local entity = GetNoClipTarget()
	ClearPedTasksImmediately(entity, false, false)
	FreezeEntityPosition(entity, false)
	SetEntityHeading(entity, TranslateHeading(entity, GetEntityHeading(entity)))
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

			-- Get the position and heading of the entity
			local x, y, z = table.unpack(GetEntityCoords(entity))
			local h = TranslateHeading(entity, GetEntityHeading(entity))

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
				z = z + Speed
			end
			if IsControlPressed(0, Config.DownControl) then
				z = z - Speed
			end

			if RelativeMode then
				-- Print the coordinates, heading and controls on screen
				DrawText(string.format('Coordinates:\nX: %.2f\nY: %.2f\nZ: %.2f\nHeading: %.0f', x, y, z, h), 0.01, 0.3, false)
				DrawText('W/S - Move, A/D - Rotate, Spacebar/Shift - Up/Down, Page Up/Page Down - Change speed, Q - Absolute mode', 0.5, 0.95, true)

				-- Calculate the change in x and y based on the speed and heading.
				local r = -h * math.pi / 180
				local dx = Speed * math.sin(r)
				local dy = Speed * math.cos(r)

				-- Move forward/backward
				if IsControlPressed(0, Config.ForwardControl) then
					x = x + dx
					y = y + dy
				end
				if IsControlPressed(0, Config.BackwardControl) then
					x = x - dx
					y = y - dy
				end

				-- Rotate heading
				if IsControlPressed(0, Config.LeftControl) then
					h = h + 1
				end
				if IsControlPressed(0, Config.RightControl) then
					h = h - 1
				end
			else
				-- Print the coordinates and controls on screen
				DrawText(string.format('Coordinates:\nX: %.2f\nY: %.2f\nZ: %.2f', x, y, z), 0.01, 0.3, false)
				DrawText('W/A/S/D - Move, Spacebar/Shift - Up/Down, Page Up/Page Down - Change speed, Q - Relative mode', 0.5, 0.95, true)

				h = 0.0

				-- Move North
				if IsControlPressed(0, Config.ForwardControl) then
					y = y + Speed
				end

				-- Move South
				if IsControlPressed(0, Config.BackwardControl) then
					y = y - Speed
				end

				-- Move East
				if IsControlPressed(0, Config.LeftControl) then
					x = x - Speed
				end

				-- Move West
				if IsControlPressed(0, Config.RightControl) then
					x = x + Speed
				end
			end

			SetEntityCoordsNoOffset(entity, x, y, z)
			SetEntityHeading(entity, TranslateHeading(entity, h))
		end
	end
end)
