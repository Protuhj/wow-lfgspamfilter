local _, addon = ...
local options, private = addon.module('ui', 'options')

function options.toggle(open)
    if open == nil then
        open = not options.isOpen()
    end

    LFGSpamFilter_Options:SetShown(open)
end

function options.isOpen()
    return LFGSpamFilter_Options:IsShown()
end

function options.load()
    -- filter category
    LFGSpamFilter_Options.FilterCategory.Checkbox:SetChecked(
        not addon.config.isIgnoredCategory(addon.ui.getCurrentLfgCategory())
    )

    -- no voice
    LFGSpamFilter_Options.NoVoice.Checkbox:SetChecked(addon.config.db.noVoice)    

    -- no war mode
    LFGSpamFilter_Options.NoWarMode.Checkbox:SetChecked(addon.config.db.noWarMode)

    -- max age
    if addon.config.db.maxAge then
        LFGSpamFilter_Options.MaxAge.EditBox:SetText(tostring(addon.config.db.maxAge / 60))
    else
        LFGSpamFilter_Options.MaxAge.EditBox:SetText('')
    end

    -- ban button
    LFGSpamFilter_Options.BanButton.Checkbox:SetChecked(addon.config.db.banButton)

    -- report helper
    LFGSpamFilter_Options.ReportHelper.Checkbox:SetChecked(addon.config.db.reportHelper)

    -- filter banned
    LFGSpamFilter_Options.FilterBanned.Checkbox:SetChecked(addon.config.db.filterBanned)
end

function options.apply()
    -- filter category
    local filterCategory = LFGSpamFilter_Options.FilterCategory.Checkbox:GetChecked()
    addon.config.setIgnoredCategory(addon.ui.getCurrentLfgCategory(), not filterCategory)

    -- no voice
    addon.config.db.noVoice = LFGSpamFilter_Options.NoVoice.Checkbox:GetChecked()

    -- no war mode
    addon.config.db.noWarMode = LFGSpamFilter_Options.NoWarMode.Checkbox:GetChecked()

    -- max age
    local maxAgeInput = tonumber(LFGSpamFilter_Options.MaxAge.EditBox:GetText())

    if maxAgeInput and maxAgeInput >= 0 then
        addon.config.db.maxAge = maxAgeInput * 60
    else
        addon.config.db.maxAge = nil
    end

    -- ban button
    addon.config.db.banButton = LFGSpamFilter_Options.BanButton.Checkbox:GetChecked()

    -- report helper
    addon.config.db.reportHelper = LFGSpamFilter_Options.ReportHelper.Checkbox:GetChecked()

    -- filter banned
    addon.config.db.filterBanned = LFGSpamFilter_Options.FilterBanned.Checkbox:GetChecked()

    -- update results with new options
    addon.ui.updateLfgResults()
end

function options.updateState()
    -- banned players heading
    LFGSpamFilter_Options.BannedPlayersHeading:SetText(string.format(
        'Banned players (%d)',
        addon.config.db.numberOfBannedPlayers
    ))

    -- report helper
    local banButtonEnabled = LFGSpamFilter_Options.BanButton.Checkbox:GetChecked()

    LFGSpamFilter_Options.ReportHelper:SetAlpha(banButtonEnabled and 1 or 0.5)
    LFGSpamFilter_Options.ReportHelper.Checkbox:SetEnabled(banButtonEnabled)
end

function options.onUnbanAllClick()
    if not IsShiftKeyDown() then
        addon.ui.errorMessage('Hold SHIFT while clicking the "Unban all" button')

        return
    end

    local num = addon.config.db.numberOfBannedPlayers

    if num > 0 then
        addon.config.unbanAllPlayers()
        addon.ui.message('Unbanned %d players\n\n(recently reported groups will not be visible)', num)
        options.updateState()
    else
        addon.ui.errorMessage('There\'s noone to unban')
    end
end

function options.onUnbanLastClick()
    local name = addon.config.db.lastBan

    if name and addon.config.isBannedPlayer(name) then
        addon.config.unbanPlayer(name)
        addon.ui.message('Unbanned %s\n\n(recently reported group will not be visible)', name)
        options.updateState()
    else
        addon.ui.errorMessage('There\'s noone to unban')
    end
end
