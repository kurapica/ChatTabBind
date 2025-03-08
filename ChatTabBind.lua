--========================================================--
--                Chat tab bind                           --
--                                                        --
-- Author      :  kurapica125@outlook.com                 --
-- Create Date :  2017/11/19                              --
--========================================================--

--========================================================--
Scorpio            "ChatTabBind"                      "1.0.0"
--========================================================--

namespace "ChatTabBind"

SpecialFrameFix = {}
FrameMap = {}
SecureInited = {}
ScrollFormInited = {}

----------------------------------------------
--------------- Choose Frame Mask ------------
----------------------------------------------
local _MaskMode = false
local _ChooseFrame
local _MouseFocusInitFrame
local _MouseFocusFrame

local _Mask = CreateFrame("Button", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
_Mask:Hide()
_Mask:SetToplevel(true)
_Mask:SetFrameStrata("TOOLTIP")
_Mask:EnableMouse(true)
_Mask:EnableMouseWheel(true)
_Mask:RegisterForClicks("AnyUp")
_Mask:SetBackdrop{
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 8,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
}
_Mask:SetBackdropColor(0, 1, 0, 0.8)

_Mask:SetScript("OnClick", function(self, btn)
    if btn == "LeftButton" then
        _ChooseFrame = _MouseFocusFrame
    else
        _ChooseFrame = nil
    end
    _MaskMode = nil
end)

_Mask:SetScript("OnMouseWheel", function(self, wheel)
    if wheel > 0 then
        if _MouseFocusFrame then
            local parent = _MouseFocusFrame:GetParent()
            if parent and parent ~= UIParent and parent ~= WorldFrame and parent:GetName() then
                _MouseFocusFrame = parent
                ShowGameTooltip()
            end
        end
    else
        if _MouseFocusInitFrame then
            _MouseFocusFrame = _MouseFocusInitFrame
            ShowGameTooltip()
        end
    end
end)

----------------------------------------------
-------------- Addon Event Handler -----------
----------------------------------------------
local _LoadedTab = 1

function OnLoad(self)
    _SVDB = SVManager.SVCharManager("ChatTabBind_DB")
    _SVDB:SetDefault {
        LabelMap = {},
        LabelOpt = {},
        EnableSwitchKey = true,
    }
end

function OnEnable(self)
    FCF_OpenTemporaryWindow()
end

function OnQuit(self)
    wipe(_SVDB.LabelMap)
    wipe(_SVDB.LabelOpt)

    _SVDB.LastSelectedTab = _G.SELECTED_CHAT_FRAME.name

    for k, m in pairs(FrameMap) do
        k:SetParent(m.OriginalPar)

        _SVDB.LabelMap[k:GetName(true)] = m.Label
        _SVDB.LabelOpt[k:GetName(true)] = m.Option

        FCF_Close(m.ChatFrame)
    end
end

----------------------------------------------
-------------- Addon Slash Command -----------
----------------------------------------------
__SlashCmd__"chatbind"
__SlashCmd__ "ctb"
__Async__()
function ChooseFrame(msg)
    if not msg or strtrim(msg) == "" then return ShowHelp() end

    msg = strtrim(msg)

    local label, option

    if msg:match("%s+autoscale$") or msg:match("%s+keepsize$") then
        label, option = msg:match("(.*)%s+(%w+)$")

        if option == "autoscale" then
            option = BindOption.AutoScale
        else
            option = BindOption.KeepSize
        end
    else
        label = msg
        option = BindOption.AutoSize
    end

    if not label or strtrim(label) == "" then return ShowHelp() end
    label = strtrim(label)

    for k, m in pairs(FrameMap) do
        if label == m.Label then
            return print("/chatbind label [autoscale|keepsize] - the label is already used")
        end
    end

    _MaskMode = true
    _ChooseFrame = nil
    _MouseFocusInitFrame = nil
    _MouseFocusFrame = nil

    while _MaskMode and not InCombatLockdown() do
        local frame = GetMouseFocus()

        if frame ~= _Mask then
            while frame and not frame:GetName() do
                frame = frame:GetParent()
            end

            if _MouseFocusInitFrame ~= frame then
                if frame == UIParent or frame == WorldFrame then
                    if _MouseFocusInitFrame then
                        _MouseFocusInitFrame = nil
                        _MouseFocusFrame = nil
                        _Mask:ClearAllPoints()
                        _Mask:Hide()
                        _Mask:SetParent(nil)
                        HideGameTooltip()
                    end
                else
                    _MouseFocusInitFrame = frame
                    _MouseFocusFrame = frame
                    _Mask:SetParent(frame)
                    _Mask:SetAllPoints(frame)
                    _Mask:Show()
                    Next()
                    ShowGameTooltip()
                end
            end
        end

        Next()
    end

    _MaskMode = false
    _Mask:Hide()
    HideGameTooltip()

    if _ChooseFrame then
        BindFrameToChatFrame(_ChooseFrame, label, option)
    end
end

__SlashCmd__"chatbind" "help"
__SlashCmd__ "ctb" "help"
function ShowHelp()
    print("--=======================--")
    print("/chatbind label - Bind a frame to chat tab(auto-size)")
    print("/chatbind label autoscale - Bind a frame to chat tab(auto-scale)")
    print("/chatbind label keepsize - Bind a frame to chat tab(with scroll control)")
    print("/chatbindopt keyswitch on/off - toggle the key switch")
    print("--=======================--")
end

__SlashCmd__ "chatbindopt" "keyswitch" " - on/off toggle the key switch"
function SwitchKey(opt)
    if opt == "on" then
        _SVDB.EnableSwitchKey = true
    elseif opt == "off" then
        _SVDB.EnableSwitchKey = false
    else
        return false
    end
end

----------------------------------------------
-------------- System Event Handler ----------
----------------------------------------------
__Async__() __SystemEvent__()
function PLAYER_ENTERING_WORLD(self)
    _M:UnregisterEvent("PLAYER_ENTERING_WORLD")

    Delay(1)

    local map = _SVDB.LabelMap
    local opt = _SVDB.LabelOpt
    local tab = _G.SELECTED_CHAT_FRAME
    while next(map) do
        Delay(0.1)

        for k, v in pairs(map) do
            local frm = Scorpio.UI.UIObject.FromName(k)

            if v and frm and (not InCombatLockdown() or not frm:IsProtected()) then
                local ntab = BindFrameToChatFrame(frm, v, opt[k] or BindOption.AutoSize)
                if v == _SVDB.LastSelectedTab then tab = ntab end
                map[k] = nil
                opt[k] = nil
            end
        end

        FCF_Tab_OnClick(tab, "LeftButton")

        if not next(map) then return end

        Wait("PLAYER_REGEN_ENABLED", "ADDON_LOADED")
    end
end

----------------------------------------------
-------------- Secure Hook Handler -----------
----------------------------------------------
function FCF_Tab_OnMouseWheel(self, delta)
    local dock = _G.GENERAL_CHAT_DOCK
    local frames = dock.DOCKED_CHAT_FRAMES
    for index, chatFrame in ipairs(frames) do
        if ( chatFrame == FCFDock_GetSelectedWindow(_G.GENERAL_CHAT_DOCK) ) then
            index = index + (delta > 0 and -1 or 1)
            if index == 0 then index = #frames end
            if index == #frames + 1 then index = 1 end
            if frames[index] then
                FCF_Tab_OnClick(_G[frames[index]:GetName().."Tab"], "LeftButton")
            end
            return
        end
    end
end

function FCF_Tab_OnKeyDown(self, key)
    if not _SVDB.EnableSwitchKey or not key then return end
    key = "^" .. key:upper()

    for i=1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame"..i]

        if _G.SELECTED_CHAT_FRAME ~= chatFrame and chatFrame.name and chatFrame.name:upper():match(key) then
            return FCF_Tab_OnClick(_G["ChatFrame"..i .. "Tab"], "LeftButton")
        end
    end
end

__Async__()
function FCF_Tab_OnEnter(self)
    if not _SVDB.EnableSwitchKey then return end
    self:EnableKeyboard(true)

    while self:IsVisible() and self:IsMouseOver() do
        Next()
    end

    self:EnableKeyboard(false)
end

__SecureHook__()
function FCF_OpenTemporaryWindow()
    while _G["ChatFrame" .. _LoadedTab] do
        local tab = _G["ChatFrame" .. _LoadedTab.."Tab"]

        tab:EnableMouseWheel(true)
        tab:HookScript("OnMouseWheel", FCF_Tab_OnMouseWheel)
        tab:HookScript("OnEnter", FCF_Tab_OnEnter)
        tab:HookScript("OnKeyDown", FCF_Tab_OnKeyDown)
        tab:EnableKeyboard(false)

        _LoadedTab = _LoadedTab + 1
    end
end

__SecureHook__ "FCF_Close"
function UnbindChatFrame(frame, fallback)
    if ( fallback ) then
        frame=fallback
    end
    for f, m in pairs(FrameMap) do
        if m.ChatFrame == frame then
            FrameMap[f] = nil

            if ScrollFormInited[frame] then
                ScrollFormInited[frame]:SetScrollChild(nil)
                ScrollFormInited[frame]:Hide()
            end

            RunFixCode(f, false, nil, m.OriginalPar)

            f:SetParent(m.OriginalPar)

            f:ClearAllPoints()
            for i, anchor in ipairs(m.OriginalLoc) do
                f:SetPoint(unpack(anchor))
            end

            f:SetSize(unpack(m.OriginalSize))
            f:SetScale(m.OriginalScal or 1)

            break
        end
    end
end

----------------------------------------------
------------------ Addon Helper --------------
----------------------------------------------
function ShowGameTooltip()
    if _Mask:IsVisible() and _MouseFocusFrame then
        GameTooltip:SetOwner(_Mask, "ANCHOR_BOTTOMRIGHT")
        GameTooltip:SetText(_MouseFocusFrame:GetName())
        GameTooltip:Show()
    end
end

function HideGameTooltip()
    GameTooltip:Hide()
end

function BindFrameToChatFrame(frame, name, option)
    local tabStatus = {}
    local canAdd = false

    for i=1, NUM_CHAT_WINDOWS do
        local _, _, _, _, _, _, shown = FCF_GetChatWindowInfo(i)
        local chatFrame = _G["ChatFrame"..i]

        tabStatus[i] = (not shown and not chatFrame.isDocked)
        if tabStatus[i] then canAdd = true end
    end

    if not canAdd then
        return print(_Locale["Can't create new chat tab."])
    end

    FCF_OpenNewWindow(name)

    print(_Locale["Add Chat tab %q for %q"]:format(name, frame:GetName()))

    for i=1, NUM_CHAT_WINDOWS do
        local _, _, _, _, _, _, shown = FCF_GetChatWindowInfo(i)
        local chatFrame = _G["ChatFrame"..i]

        if tabStatus[i] and shown and chatFrame.name == name then
            -- clear stale messages
            chatFrame:Clear()

            -- Listen to the standard messages
            ChatFrame_RemoveAllMessageGroups(chatFrame)
            ChatFrame_RemoveAllChannels(chatFrame)
            ChatFrame_ReceiveAllPrivateMessages(chatFrame)
            FCF_SetWindowAlpha(chatFrame, _G["ChatFrame1"].oldAlpha or _G.DEFAULT_CHATFRAME_ALPHA)

            -- Save Location
            local loc = {}

            for i = 1, frame:GetNumPoints() do
                loc[i] = { frame:GetPoint(i) }
            end

            FrameMap[frame] = {
                Label       = chatFrame.name,
                Option      = option,
                ChatFrame   = chatFrame,
                OriginalPar = frame:GetParent(),
                OriginalLoc = loc,
                OriginalScal= frame:GetScale(),
                OriginalSize= { frame:GetSize() },
            }

            if not SecureInited[chatFrame] then
                SecureInited[chatFrame] = true
                chatFrame:HookScript("OnShow", ChatFrame_OnShow)
            end

            ChatFrame_OnShow(chatFrame)

            return _G[chatFrame:GetName() .. "Tab"]
        end
    end
end

function ChatFrame_OnShow(self)
    for f, m in pairs(FrameMap) do
        if m.ChatFrame == self then
            local scrollForm

            if m.Option == BindOption.AutoSize then
                f:SetParent(self)
                f:ClearAllPoints()
                f:SetAllPoints()
                if ScrollFormInited[self] then
                    ScrollFormInited[self]:Hide()
                end
            elseif m.Option == BindOption.AutoScale then
                local cw, ch = self:GetSize()
                local tw, th = unpack(m.OriginalSize)

                f:SetParent(self)
                f:ClearAllPoints()
                f:SetPoint("TOPLEFT")
                if tw / th * ch < cw then
                    -- full height
                    f:SetScale(ch / th)
                else
                    -- full width
                    f:SetScale(cw / tw)
                end
                if ScrollFormInited[self] then
                    ScrollFormInited[self]:Hide()
                end
            elseif m.Option == BindOption.KeepSize then
                -- Use ScrollForm
                scrollForm = ScrollFormInited[self]
                if not scrollForm then
                    scrollForm = ChatFrameScrollForm(self)
                    ScrollFormInited[self] = scrollForm
                end

                if f ~= scrollForm:GetScrollChild() then
                    scrollForm:SetScrollChild(f)
                end
                scrollForm:Show()
            end

            RunFixCode(f, true, scrollForm, m.OriginalPar)

            break
        end
    end
end

function RunFixCode(frame, asbind, scrollForm, parent)
    local name = frame:GetName()

    for pattern, fix in pairs(SpecialFrameFix) do
        if name:match(pattern) then
            return fix(frame, asbind, scrollForm, parent)
        end
    end
end