local CONTROL_F6 = 0x3C0A40F2
local CONTROL_PAGE_UP = 0x446258B6
local CONTROL_PAGE_DOWN = 0x3C3DD371
local CONTROL_W = 0x8FD015D8
local CONTROL_A = 0x7065027D
local CONTROL_S = 0xD27782E3
local CONTROL_D = 0xB4E465B4
local CONTROL_SPACEBAR = 0xD9D0E1C0
local CONTROL_SHIFT = 0x8FFC75D6

local NoClipToggleControl = CONTROL_F6
local Speed = 0.1
local MaxSpeed = 10.0
local MinSpeed = 0.1

local Enabled = false

function GetNoClipTarget()
	local ped = PlayerPedId()
	local veh = GetVehiclePedIsIn(ped, false)
	local mnt = GetMount(ped)
	return (veh == 0 and (mnt == 0 and ped or mnt) or veh)
end

-- Either GetEntityCoords or SetEntityCoords offsets the Z coordinate by some
-- amount depending on the entity. This causes the entity to slowly move
-- upwards when you set to the same Z you get.
--
-- This function determines what that offset is by moving the entity and
-- calculating the difference in the Z coordinate.
--
-- Although it seems to work fine in practice, moving the entity constantly
-- feels like a kludge, so if the offset is related to some property of the
-- entity (height, size), that would be better to use.
function GetOffset(entity)
	local x1, y1, z1 = table.unpack(GetEntityCoords(entity))
	SetEntityCoords(entity, x1, y1, z1)
	x2, y2, z2 = table.unpack(GetEntityCoords(entity))
	local offset = z2 - z1
	SetEntityCoords(entity, x1, y1, z1 - offset)
	return offset
end

function ToggleNoClip()
	local entity = GetNoClipTarget()

	if Enabled then
		FreezeEntityPosition(entity, false)
		Enabled = false
	else
		FreezeEntityPosition(entity, true)
		Enabled = true
	end
end

RegisterCommand('noclip', ToggleNoClip)
TriggerEvent('chat:addSuggestion', '/noclip', 'Toggle noclip mode', {})

function DrawText(text, x, y, centred)
	SetTextScale(0.35, 0.35)
	SetTextColor(255, 255, 255, 255)
	SetTextCentre(centred)
	SetTextDropshadow(1, 0, 0, 0, 200)
	SetTextFontForCurrentCommand(0)
	DisplayText(CreateVarString(10, "LITERAL_STRING", text), x, y)
end

CreateThread(function()
	while true do
		Wait(0)

		if IsControlJustPressed(0, NoClipToggleControl) then
			ToggleNoClip()
		end

		if Enabled then
			local entity = GetNoClipTarget()
			local x, y, z = table.unpack(GetEntityCoords(entity))

			-- See GetOffset above for why this offset on the Z coordinate is necessary.
			local offset = GetOffset(entity)

			DrawText(string.format('NoClip Speed: %.1f', Speed), 0.5, 0.90, true)
			DrawText('W/A/S/D - Move, Spacebar/Shift - Up/Down, Page Up/Page Down - Change speed', 0.5, 0.95, true)

			ClearPedTasksImmediately(entity, false, false)
			SetEntityHeading(entity, 180.0)

			if Speed > MaxSpeed then
				Speed = MaxSpeed
			end
			if Speed < MinSpeed then
				Speed = MinSpeed
			end

			if IsControlPressed(0, CONTROL_PAGE_UP) then
				Speed = Speed + 0.1
			end
			if IsControlPressed(0, CONTROL_PAGE_DOWN) then
				Speed = Speed - 0.1
			end
			if IsControlPressed(0, CONTROL_W) then
				SetEntityCoords(entity, x, y + Speed, z - offset)
			end
			if IsControlPressed(0, CONTROL_S) then
				SetEntityCoords(entity, x, y - Speed, z - offset)
			end
			if IsControlPressed(0, CONTROL_A) then
				SetEntityCoords(entity, x - Speed, y, z - offset)
			end
			if IsControlPressed(0, CONTROL_D) then
				SetEntityCoords(entity, x + Speed, y, z - offset)
			end
			if IsControlPressed(0, CONTROL_SHIFT) then
				SetEntityCoords(entity, x, y, z - Speed - offset)
			end
			if IsControlPressed(0, CONTROL_SPACEBAR) then
				SetEntityCoords(entity, x, y, z + Speed - offset)
			end

			DrawText(string.format('Coordinates:\nX: %.2f\nY: %.2f\nZ: %.2f', x, y, z), 0.01, 0.3, false)
		end
	end
end)
