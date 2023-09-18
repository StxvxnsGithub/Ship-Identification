-- External
local CollectionService = game:GetService("CollectionService")
local Maid = require(game:GetService("ServerScriptService").FederalsSystems.Utils:WaitForChild("Maid"))
local GetShipData = game:GetService("ReplicatedStorage").FederalsSystems.Remotes:WaitForChild("GetShipData")
local ShipAssets = require(script.ShipAssets)

-- Variables
local inactiveColor = Color3.fromRGB(89, 85, 90)
local weldingColor = Color3.fromRGB(196, 40, 28)
local weldedColor = Color3.fromRGB(0,0,0)
local holdRadius = 15

----------------------------------------------

local function giveUI(identification)
	local prompt = identification.PromptPart.ProximityPrompt
	local firstMaid = Maid.new()
	local secondMaid = Maid.new()
	local currentShipName = ""
	
	firstMaid:GiveTask(prompt.Triggered:Connect(function(player)
		if not player.PlayerGui:FindFirstChild("IdentificationUI") then
			local UI = script.IdentificationUI:Clone()
			UI.Frame.TextBox.Text = currentShipName
			UI.Parent = player.PlayerGui
			
			secondMaid:GiveTask(UI.Frame.Button.MouseButton1Click:Connect(function()
				GetShipData:FireClient(player, ShipAssets, identification)
				
				local connection
				
				connection = GetShipData.OnServerEvent:Connect(function(eventCaller, receivedIdentification, shipName, shipData)
					if receivedIdentification == identification and eventCaller == player then
						print(player.Name .. " has changed " .. currentShipName .. " to " .. shipName)
						
						currentShipName = shipName
						
						local deckCodes = identification:FindFirstChild("DeckCodes")
						local portDeckCode = deckCodes:FindFirstChild("DeckCodePort")
						local starDeckCode = deckCodes:FindFirstChild("DeckCodeStar")
						
						if portDeckCode then portDeckCode.SurfaceGui.TextLabel.Text = shipData[1] end
						if starDeckCode then starDeckCode.SurfaceGui.TextLabel.Text = shipData[2] end
						
						for _, pennant in identification.Pennants:GetChildren() do
							pennant.SurfaceGui.TextLabel.Text = shipData[3]
						end
						
						for _, name in identification.Names:GetChildren() do
							name.SurfaceGui.TextLabel.Text = shipData[4]
						end
						
						for _, crest in identification.Crests:GetChildren() do
							crest.ShipCrest.Texture = shipData[5]
						end
						
						connection:Disconnect()
					end
				end)
				
				secondMaid:Destroy()
				UI:Destroy()
			end))
		end
	end))
	
	firstMaid:GiveTask(CollectionService:GetInstanceRemovedSignal("FedsShipID"):Connect(function()
		print("Ship identification cleaned up")
		firstMaid:Destroy()
		secondMaid:Destroy()
	end))
end

CollectionService:GetInstanceAddedSignal("FedsShipID"):Connect(function(instance) 
	giveUI(instance) 
end)
