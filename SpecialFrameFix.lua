--========================================================--
--                Chat tab bind                           --
--                                                        --
-- Author      :  kurapica125@outlook.com                 --
-- Create Date :  2017/11/19                              --
--========================================================--

--========================================================--
Scorpio            "ChatTabBind.SpecialFrameFix"     "1.0.0"
--========================================================--

-- For Skada
SpecialFrameFix["SkadaBarWindow.+"] = function(frame, asbind)
    if IsAddOnLoaded("Skada") then
        if asbind then
            frame:SetPoint("TOPLEFT", 0, - frame.button:GetHeight())
        end

        local p =frame.win.bargroup
        p:SetLength(p:GetWidth())
        p:SortBars()
    end
end

-- For EnhanceBattlefieldMinimap
SpecialFrameFix["BattlefieldMinimapScroll"] = function(frame, asbind)
    if IsAddOnLoaded("EnhanceBattlefieldMinimap") then
        if asbind then
            BattlefieldMinimapTabText.Show = BattlefieldMinimapTabText.Hide
            BattlefieldMinimapTabText:Hide()
        else
            BattlefieldMinimapTabText.Show = nil
            BattlefieldMinimapTabText:Show()
        end
        Delay(0.1, Scorpio("EnhanceBattlefieldMinimap").PLAYER_STARTED_MOVING)
    end
end

-- For ObjectiveTrackerFrame
local ObjectiveTrackerFrameContainer
SpecialFrameFix["ObjectiveTrackerFrame"] = function(frame, asbind, scrollForm)
    if asbind then
        if scrollForm then
            ObjectiveTrackerFrameContainer = ObjectiveTrackerFrameContainer or CreateFrame("Frame")
            ObjectiveTrackerFrameContainer:SetHeight(frame:GetHeight())
            ObjectiveTrackerFrameContainer:SetWidth(frame:GetWidth() + 30)
            ObjectiveTrackerFrameContainer:Show()
            scrollForm:SetScrollChild(ObjectiveTrackerFrameContainer)

            frame:ClearAllPoints()
            frame:SetParent(ObjectiveTrackerFrameContainer)
            frame:SetPoint("TOPLEFT", ObjectiveTrackerFrameContainer, "TOPLEFT", 30, 0)
            frame:SetPoint("BOTTOMRIGHT", ObjectiveTrackerFrameContainer, "BOTTOMRIGHT")
        else
            frame:SetPoint("TOPLEFT", 30, 0)
        end
    elseif ObjectiveTrackerFrameContainer then
        ObjectiveTrackerFrameContainer:Hide()
    end
end

-- For Eska-quest-tracker
SpecialFrameFix["EQT.*TrackerFrame"] = function(frame, asbind, scrollForm)
    if IsAddOnLoaded("EskaQuestTracker") then
        local addon = Scorpio("EskaQuestTracker")
        local bar = addon.ItemBar.frame
        local options = addon.Options

        -- Fix for item bar
        if asbind then
            NoCombat(function()
                local chatFrame = frame:GetParent()
                bar:ClearAllPoints()
                bar:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", chatFrame:GetRight(), chatFrame:GetTop())
                addon.ObjectiveTracker:GetFrameContainer():EnableMouse(false)
            end)
        else
            NoCombat(function()
                addon.ObjectiveTracker:GetFrameContainer():EnableMouse(true)
                addon.CallbackHandlers:Call("itemBar/UpdateAllPosition")
            end)
        end

        options:Set("tracker-width", frame:GetWidth(), true)
    end
end

-- For EskaTracker
SpecialFrameFix["EskaTracker.*"] = function(frame, asbind, scrollForm, parent)
        print("got EskaTracker")
    if IsAddOnLoaded("EskaTracker") then
        -- Fix for item bar
        if asbind then
            NoCombat(function()
                parent:EnableMouse(false)
            end)
        else
            NoCombat(function()
                parent:EnableMouse(true)
            end)
        end
    end
end