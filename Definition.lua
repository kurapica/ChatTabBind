--========================================================--
--                Definition                              --
--                                                        --
-- Author      :  kurapica125@outlook.com                 --
-- Create Date :  2017/11/19                              --
--========================================================--

--========================================================--
Scorpio            "ChatTabBind.Definition"          "1.0.0"
--========================================================--

namespace "ChatTabBind"

enum "BindOption" {
	"AutoSize",
	"AutoScale",
	"KeepSize",
}

class "ChatFrameScrollForm" (function(_ENV)
	-------------------------------------------
	-- Helper
	-------------------------------------------
	local function Form_OnScrollRangeChanged(self)
		local xrange = math.floor(self:GetHorizontalScrollRange())
		local yrange = math.floor(self:GetVerticalScrollRange())

		if xrange > 0 then
			self.HSlider:Show()
			self.HSlider:SetMinMaxValues(0, xrange)
			self.HSlider:SetValue(self:GetHorizontalScroll() or 0)
			self.HSlider:SetAlpha(1)
		else
			self.HSlider:Hide()
		end

		if yrange > 0 then
			self.VSlider:Show()
			self.VSlider:SetMinMaxValues(0, yrange)
			self.VSlider:SetValue(self:GetVerticalScroll() or 0)
			self.VSlider:SetAlpha(1)
		else
			self.VSlider:Hide()
		end
	end

	local function Slider_OnMouseWheel(self, delta)
		local imin, imax = self:GetMinMaxValues()

		if delta > 0 then
			if IsShiftKeyDown() then
				self:SetValue(imin)
			else
				self:SetValue(math.max(imin, self:GetValue() - self:GetValueStep()))
			end
		else
			if IsShiftKeyDown() then
				self:SetValue(imax)
			else
				self:SetValue(math.min(imax, self:GetValue() + self:GetValueStep()))
			end
		end
	end

	local function Form_OnMouseWheel(self, delta)
		Slider_OnMouseWheel(self.VSlider, delta)
	end

	local function HSlider_OnValueChanged(self)
		self:GetParent():SetHorizontalScroll(self:GetValue())
	end

	local function VSlider_OnValueChanged(self)
		self:GetParent():SetVerticalScroll(self:GetValue())
	end

	__Async__() -- Maybe I should given an __Private__ attribute
	function Slider_OnEnter(self)
		self.OnEnterTask = (self.OnEnterTask or 0) + 1
		local current = self.OnEnterTask

		self:SetAlpha(1)

		Delay(3)

		if current ~= self.OnEnterTask then return end

		while self:IsMouseOver() do Next() end

		local st = GetTime()

		while current == self.OnEnterTask do
			local opacity = (GetTime() - st) / 3.0

	        if opacity < 1 then
	            self:SetAlpha(1 - opacity)
	        else
	            self:SetAlpha(0)
	            return
	        end

	        Next()
		end
	end

	__Async__()
	function Form_OnShow(self)
		self:UpdateScrollChildRect()

		Next()

		if self.HSlider:IsShown() then
			Slider_OnEnter(self.HSlider)
		end
		if self.VSlider:IsShown() then
			Slider_OnEnter(self.VSlider)
		end
	end

	-------------------------------------------
	-- Methods
	-------------------------------------------
	function SetScrollChild(self, frame)
		self.ScrollFrame:SetScrollChild(frame)
		if frame then frame:SetParent(self.ScrollFrame) end
	end

	function GetScrollChild(self)
		return self.ScrollFrame:GetScrollChild()
	end

	function Show(self)
		self.ScrollFrame:Show()
	end

	function Hide(self)
		self.ScrollFrame:Hide()
	end

	-------------------------------------------
	-- Constructor
	-------------------------------------------
	function ChatFrameScrollForm(self, chatFrame)
		-- ScrollFrame
		local scroll = CreateFrame("ScrollFrame", nil, chatFrame)
		scroll:Hide()
		scroll:SetAllPoints(chatFrame)
		scroll:EnableMouseWheel(true)
		scroll:SetScript("OnShow", Form_OnShow)
		scroll:SetScript("OnScrollRangeChanged", Form_OnScrollRangeChanged)
		scroll:SetScript("OnMouseWheel", Form_OnMouseWheel)

		self.ScrollFrame = scroll

		-- Silder
		local hslider = CreateFrame("Slider", nil, scroll)
		hslider:SetFrameStrata("DIALOG")
		hslider:SetPoint("BOTTOMLEFT", 8, 0)
		hslider:SetPoint("BOTTOMRIGHT", -8, 0)
		hslider:SetHeight(12)
		hslider:SetValueStep(24)
		hslider:SetScript("OnEnter", Slider_OnEnter)
		hslider:SetScript("OnValueChanged", HSlider_OnValueChanged)
		hslider:SetScript("OnMouseWheel", Slider_OnMouseWheel)
		hslider:EnableMouse(true)
		hslider:EnableMouseWheel(true)
		hslider:SetOrientation("HORIZONTAL")
		scroll.HSlider= hslider

		local hback   = hslider:CreateTexture(nil, "BACKGROUND")
		hback:SetHeight(1)
		hback:SetPoint("LEFT")
		hback:SetPoint("RIGHT")
		hback:SetColorTexture(1, 1, 1)

		local hthumb  = hslider:CreateTexture(nil, "OVERLAY")
		hthumb:SetSize(12, 8)
		hthumb:SetColorTexture(0, 0, 1)
		hslider:SetThumbTexture(hthumb)

		local vslider = CreateFrame("Slider", nil, scroll)
		vslider:SetFrameStrata("HIGH")
		vslider:SetPoint("TOPRIGHT", 0, -8)
		vslider:SetPoint("BOTTOMRIGHT", 0, 8)
		vslider:SetWidth(12)
		vslider:SetValueStep(24)
		vslider:SetScript("OnEnter", Slider_OnEnter)
		vslider:SetScript("OnValueChanged", VSlider_OnValueChanged)
		vslider:SetScript("OnMouseWheel", Slider_OnMouseWheel)
		vslider:EnableMouse(true)
		hslider:EnableMouseWheel(true)
		vslider:SetOrientation("VERTICAL")
		scroll.VSlider= vslider

		local vback   = vslider:CreateTexture(nil, "BACKGROUND")
		vback:SetWidth(1)
		vback:SetPoint("TOP")
		vback:SetPoint("BOTTOM")
		vback:SetColorTexture(1, 1, 1)

		local vthumb  = vslider:CreateTexture(nil, "OVERLAY")
		vthumb:SetSize(8, 12)
		vthumb:SetColorTexture(0, 0, 1)
		vslider:SetThumbTexture(vthumb)
	end
end)