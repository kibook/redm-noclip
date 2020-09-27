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

function ToggleNoClip()
	local ped = PlayerPedId()

	if Enabled then
		FreezeEntityPosition(ped, false)
		Enabled = false
	else
		FreezeEntityPosition(ped, true)
		Enabled = true
	end
end

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
			local ped = PlayerPedId()
			local x, y, z = table.unpack(GetEntityCoords(ped))

			DrawText(string.format('NoClip Speed: %.1f', Speed), 0.5, 0.90, true)
			DrawText('W/A/S/D - Move, Spacebar/Shift - Up/Down, Page Up/Page Down - Change speed', 0.5, 0.95, true)

			ClearPedTasksImmediately(ped, false, false)
			SetEntityHeading(ped, 180.0)

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
				SetEntityCoords(ped, x, y + Speed, z - 1)
			end
			if IsControlPressed(0, CONTROL_S) then
				SetEntityCoords(ped, x, y - Speed, z - 1)
			end
			if IsControlPressed(0, CONTROL_A) then
				SetEntityCoords(ped, x - Speed, y, z - 1)
			end
			if IsControlPressed(0, CONTROL_D) then
				SetEntityCoords(ped, x + Speed, y, z - 1)
			end
			if IsControlPressed(0, CONTROL_SHIFT) then
				SetEntityCoords(ped, x, y, z - Speed - 1)
			end
			if IsControlPressed(0, CONTROL_SPACEBAR) then
				SetEntityCoords(ped, x, y, z + Speed - 1)
			end

			DrawText(string.format('Coordinates:\nX: %.2f\nY: %.2f\nZ: %.2f', x, y, z), 0.01, 0.3, false)
		end
	end
end)
