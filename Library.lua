local Library = {} 
Library.__index = Library do 
	function Library.new(name)
		local Assets  = game:GetObjects("rbxassetid://90339940104169") -- Use Getobjects for this and the line below
		local Objects = game:GetObjects("rbxassetid://76529102355225");

		Objects.Parent = game.CoreGui;
		Objects["Main"]:WaitForChild("Title").Text = name

		local UserInputService = game:GetService("UserInputService")
		local runService = (game:GetService("RunService"));

		local gui = Objects["Main"]

		local dragging
		local dragInput
		local dragStart
		local startPos

		local function Lerp(a, b, m)
			return a + (b - a) * m
		end;

		local lastMousePos
		local lastGoalPos
		local DRAG_SPEED = (8);

		local function Update(dt)
			if not (startPos) then return end;
			if not (dragging) and (lastGoalPos) then
				gui.Position = UDim2.new(startPos.X.Scale, Lerp(gui.Position.X.Offset, lastGoalPos.X.Offset, dt * DRAG_SPEED), startPos.Y.Scale, Lerp(gui.Position.Y.Offset, lastGoalPos.Y.Offset, dt * DRAG_SPEED))
				return 
			end;

			local delta = (lastMousePos - UserInputService:GetMouseLocation())
			local xGoal = (startPos.X.Offset - delta.X);
			local yGoal = (startPos.Y.Offset - delta.Y);
			lastGoalPos = UDim2.new(startPos.X.Scale, xGoal, startPos.Y.Scale, yGoal)
			gui.Position = UDim2.new(startPos.X.Scale, Lerp(gui.Position.X.Offset, xGoal, dt * DRAG_SPEED), startPos.Y.Scale, Lerp(gui.Position.Y.Offset, yGoal, dt * DRAG_SPEED))
		end;

		gui.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = gui.Position
				lastMousePos = UserInputService:GetMouseLocation()

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)

		gui.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)

		runService.Heartbeat:Connect(Update)

		local self = setmetatable({}, Library); 
		self.Library = Objects -- Empty main ui that will be populated
		self.lName = name -- Self explanatory

		self.Pages = {}; -- Where pages will be stored
		self.Tabs  = {}; -- Where tab buttons will be stored (just incase)

		self.Alpha = { -- Alphabet for alphabetical component ordering
			'a', 'b', 'c', 
			'd', 'e', 'f', 
			'g', 'h', 'i', 
			'j', 'k', 'l', 
			'm', 'n', 'o', 
			'p', 'q','r',
			's', 't', 'u',
			'v', 'w', 'x',
			'y', 'z'
		}

		self.Tween = function(parent, info, props, yield)
			local Tween = game:GetService("TweenService"):Create(parent, TweenInfo.new(info.Time, info.EasingStyle, info.EasingDirection), props) do 
				Tween:Play(); if yield then Tween.Completed:Wait() end
			end return Tween
		end

		self.Components = { -- All the component templates that will be used in their respective fields
			FComponents = {
				Button = Assets.TemplateButton,
				Slider = Assets.TemplateSlider,
				Toggle = Assets.TemplateToggle,
				Dropdown = {
					Dropdown = Assets.TemplateDropdown,
					Options  = Assets.Template_DropdownContents,
					Option   = Assets.OptionTemplate
				}
			},
			Tab  = Assets.TemplateTab;
			Page = Assets.Page;
		}

		self.Paths = {
			Tabs  = self.Library["Main"].Tabs,
			Pages = self.Library["Main"].Container
		}

		self.Enum = {
			ToggleColors = {
				[true]  = {StrokeCorner = Color3.fromRGB(123, 194, 126); Display      = Color3.fromRGB(87, 199, 75)},
				[false] = {StrokeCorner = Color3.fromRGB(178, 25, 13);   Display      = Color3.fromRGB(185, 63, 58)}
			},
			SliderConstraints = {
				Min = .306;
				Max = 1.004;
			}
		}

		return self
	end

	function Library:Tab(tabName)
		local ObjectSetups = {}

		local function SwitchPage(Page)
			for pageN = 1,#self.Pages do 
				local Object = self.Pages[pageN];
				if not (Object == Page) then
					Object.Visible = false
				else Object.Visible = true end
			end
		end

		local Page = self.Components.Page:Clone();
		Page.Parent = self.Paths.Pages

		table.insert(self.Pages, Page)

		if #self.Pages < 2 then
			SwitchPage(Page)
		end

		local tabButton  = self.Components.Tab:Clone();
		tabButton.Parent = self.Paths.Tabs.ScrollingFrame
		tabButton.TabDisplay.Text = tabName;

		(tabButton.InternalButton :: TextButton).MouseButton1Click:Connect(function()
			SwitchPage(Page)
		end)

		function ObjectSetups.Button(Page, ...)
			local Functs = {}
			local Connection;

			local Name, Callback = ...;

			local letterLabel = self.Alpha[#Page:GetChildren()]

			local ButtonObject = self.Components.FComponents.Button:Clone();
			ButtonObject.Parent = Page
			ButtonObject.Name = letterLabel .. "_" .. string.gsub(Name, "%s+", "");
			ButtonObject.Display.Text = Name

			Connection = (ButtonObject :: TextButton).InternalButton.MouseButton1Click:Connect(function()
				Callback(Functs)
			end)

			function Functs:updateLabel(n)
				ButtonObject.Display.Text = n
				ButtonObject.Name = letterLabel .. "_" .. string.gsub(n, "%s+", "");
			end

			function Functs:Destroy()
				Connection:Disconnect();
				ButtonObject :Destroy();
			end

			return Functs
		end

		function ObjectSetups.Toggle(Page, ...)
			local Functs = {}
			local Connection;

			local Toggled = false;

			local Name, Callback = ...;

			local letterLabel = self.Alpha[#Page:GetChildren()]

			local ToggleObject = self.Components.FComponents.Toggle:Clone();
			ToggleObject.Parent = Page
			ToggleObject.Name = letterLabel .. "_" .. string.gsub(Name, "%s+", "");
			ToggleObject.Display.Text = Name;

			ToggleObject.DisplayF.BackgroundColor3 = self.Enum.ToggleColors[false].Display;
			ToggleObject.DisplayF.StrokeCorner.Color = self.Enum.ToggleColors[false].StrokeCorner;

			Connection = (ToggleObject :: TextButton).InternalButton.MouseButton1Click:Connect(function()
				Toggled = not Toggled;

				self.Tween(ToggleObject.DisplayF, {Time = 0.3, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.InOut}, {
					BackgroundColor3 = self.Enum.ToggleColors[Toggled].Display;
				})

				self.Tween(ToggleObject.DisplayF.StrokeCorner, {Time = 0.3, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.InOut}, {
					Color = self.Enum.ToggleColors[Toggled].StrokeCorner
				}, true)

				Callback(Toggled, Functs);
			end)

			function Functs:updateLabel(n)
				ToggleObject.Display.Text = n
				ToggleObject.Name = letterLabel .. "_" .. string.gsub(n, "%s+", "");
			end

			function Functs:Destroy()
				Connection:Disconnect();
				ToggleObject :Destroy();
			end

			return Functs
		end

		function ObjectSetups.Dropdown(Page, ...)
			local Functs = {}
			local Connections = {};

			local Name, Options, Callback = ...;

			local letterLabel = self.Alpha[#Page:GetChildren()]

			local DropdownA = self.Components.FComponents.Dropdown.Dropdown:Clone();
			DropdownA.Parent = Page
			DropdownA.Name = letterLabel .. "_" .. string.gsub(Name, "%s+", "");
			DropdownA.DisplayF.Text = Name;

			local DropdownB = self.Components.FComponents.Dropdown.Options:Clone();
			DropdownB.Parent = Page 
			DropdownB.Name = letterLabel .. "_" .. string.gsub(Name, "%s+", "");

			Connections["ButtonConnect"] = (DropdownA.InternalButton :: TextButton).MouseButton1Click:Connect(function()
				DropdownB.Visible = not DropdownB.Visible
				if DropdownB.Visible then 
					task.spawn(function()
						for i, Option in pairs(DropdownB.ScrollingFrame:GetChildren()) do 
							if Option:IsA("Frame") then 
								Option.StrokeCorner.Transparency = 1;
								Option.BackgroundTransparency    = 1;
								Option.Display.TextTransparency  = 1;
							end
						end
					end)

					for i, Option in pairs(DropdownB.ScrollingFrame:GetChildren()) do 
						if Option:IsA("Frame") then 
							self.Tween(Option.StrokeCorner, {Time = 0.15, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.InOut}, {
								Transparency = 0
							})
							self.Tween(Option.Display, {Time = 0.15, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.InOut}, {
								TextTransparency = 0
							})
							self.Tween(Option, {Time = 0.15, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.InOut}, {
								BackgroundTransparency = 0
							}, true)
						end
					end
				end
			end)

			for i, Option in pairs(Options) do 
				local DropdownC = self.Components.FComponents.Dropdown.Option:Clone();
				DropdownC.Parent = DropdownB.ScrollingFrame
				DropdownC.Name = Option.Text
				DropdownC.Display.Text = Option.Text;
				DropdownC.Display.TextColor3 = Option.Color;

				Connections[i] = (DropdownC.InternalButton :: TextButton).MouseButton1Click:Connect(function()
					DropdownA.Display.TDisplay.Text = Option.Text; 
					DropdownA.Display.TDisplay.TextColor3 = Option.Color;

					Callback(Option.Text, Functs)
				end)
			end

			function Functs:Destroy()
				for index, Connection in pairs(Connections) do 
					Connection:Disconnect()
				end 
				DropdownA:Destroy();
				DropdownB:Destroy();
			end
		end

		function ObjectSetups.Slider(Page, ...)
			local Functs = {}
			local Connections = {};

			local Constraints, Name, Callback = ...;
			local Dragging = false

			local function lerp(start, goal, alpha)
				return start + (goal - start) * alpha
			end

			local letterLabel = self.Alpha[#Page:GetChildren()]

			local SliderObject = self.Components.FComponents.Slider:Clone();
			SliderObject.Parent = Page
			SliderObject.Name = letterLabel .. "_" .. string.gsub(Name, "%s+", "");
			SliderObject.Display.Text = Name

			local Scroller = SliderObject.DisplayS.Scroller;

			Connections["DragBegan"] = (SliderObject.InternalButton :: TextButton).MouseButton1Down:Connect(function()
				Dragging = true
			end)

			Connections["DragEnded"] = (SliderObject.InternalButton :: TextButton).MouseButton1Up:Connect(function()
				Dragging = false
			end)

			local Elapsed = 0;
			local Timer   = 100--ms
			local Last    = tick()

			Connections["InputBegan"] = game.Players.LocalPlayer:GetMouse().Move:Connect(function()
				if Dragging then
					local min, max = self.Enum.SliderConstraints.Min, self.Enum.SliderConstraints.Max;
					local mouseX   = game:GetService("UserInputService"):GetMouseLocation().X-(Scroller.AbsoluteSize.X/2)
					local clamp    = math.clamp((mouseX-SliderObject.DisplayS.AbsolutePosition.X)/SliderObject.DisplayS.AbsoluteSize.X, min, max)
					local normal   = (clamp-min)/(max-min)
					local value    = lerp(Constraints[1], Constraints[2], normal) 

					Scroller.Position = UDim2.new(clamp, 0, 0.316, -1)

					Scroller.Display.Text = math.floor(value) .. "/" .. Constraints[2]

					if Elapsed >= Timer then
						Elapsed = 0
						Callback(value, Functs)
					end Elapsed += (tick() - Last);
				end
			end)

			function Functs:updateLabel(n)
				SliderObject.Display.Text = n
				SliderObject.Name = letterLabel .. "_" .. string.gsub(n, "%s+", "");
			end

			function Functs:Destroy()
				for index, Connection in pairs(Connections) do 
					Connection:Disconnect()
				end 
				SliderObject:Destroy();
			end

			return Functs
		end

		local Tab = {} do 
			function Tab:Element(Type, x)
				return ObjectSetups[Type](Page, unpack(x));
			end
		end return Tab;
	end
end return Library
