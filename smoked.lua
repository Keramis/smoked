-- Smoked.
-- s m o k e#9116
-- all made by me, no skids here. nope. nahh
util.require_natives(1640181023)
require("smokelib")
require("smoke_colors")
util.toast("loaded smokelib")
require("Universal_WeaponsNamesHashesTable")
util.toast("Loaded Universal Weapons Hashes")
util.keep_running()
local alist = false
local hgui = false
local hgui_enabled = false
--image/textures--
local hgui_smoke = directx.create_texture(filesystem.resources_dir() .. "smoked.png")
local hgui_cigarrette = directx.create_texture(filesystem.resources_dir() .. "cigarrette.png")
local hgui_point = directx.create_texture(filesystem.resources_dir() .. "smoke_point.png")
local hgui_check = directx.create_texture(filesystem.resources_dir() .. "smoke_check.png")
local hgui_x = directx.create_texture(filesystem.resources_dir() .. "smoke_x.png")

--ease of use variables
local menuroot = menu.my_root()
local wait = util.yield
local getEntityCoords = ENTITY.GET_ENTITY_COORDS
local getPlayerPed = PLAYER.GET_PLAYER_PED


--===================================================================================================================
--===================================================================================================================
--===================================================================================================================
-- PLAYER FUNCTIONS NEED TO BE GENERATED AT THE TOP FOR THIS TO WORK!

AIM_BLACKLIST = {}

local function playerFeatures(pid)
    local playerRoot = menu.player_root(pid)
    menu.divider(playerRoot, "Smoked.lua")
    menu.toggle(playerRoot, "Blacklist Player from Aimbot", {"blacklist"}, "", function (toggle)
        AIM_BLACKLIST[pid] = toggle
    end)
end

players.on_join(playerFeatures)
players.dispatch_on_join()

-- >> << -- >> << -- >> << -- >> << -- >> << -- >> << -- >> << -- >> << -- >> << --

menu.divider(menuroot, "Smoked.lua")

local oppressor_aimbot = menu.list(menuroot, "Oppressor Aimbot", {"smokeoppressoraim"}, "")
local missile_speed = 100
local missile_ptfx = false
menu.toggle(oppressor_aimbot, FEATURES[1][2], {}, "", function (on)
    Aimbot = on
    FEATURES[1][1] = on
    STREAMING.REQUEST_NAMED_PTFX_ASSET("core")
    while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("core") do
        STREAMING.REQUEST_NAMED_PTFX_ASSET("core")
        wait()
    end
    local rockethash = util.joaat("w_ex_vehiclemissile_3")
    while Aimbot do
        local localPed = getPlayerPed(players.user())
        local localcoords = getEntityCoords(localPed)
        local Missile = OBJECT.GET_CLOSEST_OBJECT_OF_TYPE(localcoords.x, localcoords.y, localcoords.z, 10, rockethash, false, true, true, true)
        if (Missile ~= 0) then --check for missile here, we will create thread to track it.
            util.create_thread(function ()
                local msl = Missile --set local variable for the global Missile, to be able to target mutliple missiles at once.
                local closestPlayer = GetClosestPlayerWithRange_PIDBlacklist(500, AIM_BLACKLIST)
                if (closestPlayer) and (not PED.IS_PED_DEAD_OR_DYING(closestPlayer)) then
                    local lpc = v3.new(getEntityCoords(closestPlayer))
                    local zcoord = getEntityCoords(closestPlayer).z
                    if ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(localPed, closestPlayer, 17) then
                        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(msl)
                        while ENTITY.DOES_ENTITY_EXIST(msl) do
                            local targetCoords = v3.new(PED.GET_PED_BONE_COORDS(closestPlayer, 20781, 0, 0, 0))
                            local missileCoords = v3.new(getEntityCoords(msl))
                            local look = v3.lookAt(missileCoords, targetCoords) --int v3.lookAt(int a, int b)
                            local dir = v3.toDir(look)
                            local direction = GetTableFromV3Instance(dir)
                            --coordinates done
                            -- aimbot time:
                            ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(msl, 1, direction.x * missile_speed, direction.y * missile_speed, direction.z * missile_speed, true, false, true, true)
                            if missile_ptfx then
                                GRAPHICS.USE_PARTICLE_FX_ASSET("core")
                                GRAPHICS.START_PARTICLE_FX_NON_LOOPED_ON_ENTITY("exp_grd_rpg_lod", msl, 0, 0, 0, 0, 0, 0, 0.8, false, false, false)
                            end
                            --free v3
                            v3.free(targetCoords)
                            v3.free(missileCoords)
                            v3.free(look)
                            v3.free(dir)
                            wait()
                        end
                    end
                end
                util.stop_thread()
            end)
        end
        wait()
    end
end)
menu.slider(oppressor_aimbot, "Missile Speed", {"mslspeed"}, "", 0, 10000, 100, 10, function (val)
    missile_speed = val
end)
menu.toggle(oppressor_aimbot, "Enable PTFX", {}, "Enables PTFX on the missile. Might cause a little lag, but will make it look more legit.", function (toggle)
    missile_ptfx = toggle
end)

local silent_aimbot = menu.list(menuroot, "Better Silent Aimbot", {}, "")
local silent_aimbot_settings = {
    chooseHash = 0,
    chooseWP = "",
    show = false,
    legit = false,
    onlyLegit = false,
    speed = -1,
    dmg = 60,
    head = false,
    body = false,
    pelvis = false,
    legs = false
}
menu.toggle(silent_aimbot, FEATURES[2][2], {"smokesilentaim"}, "Improved silent aimbot, to disable firing upon shooting.", function (on)
    local ourPed = GetLocalPed()
    FEATURES[2][1] = on
    SilentAimbot = on
    while SilentAimbot do
        if silent_aimbot_settings.show then
            DrawText(0.5, 0.05, "Using " .. tostring(silent_aimbot_settings.chooseWP) .. " for Silent Aimbot", 1, 0.5, WhiteText, true)
        end
        if PED.IS_PED_SHOOTING(ourPed) then
            local targetPed = GetClosestPlayerWithRange(400)
            if (not PED.IS_PED_DEAD_OR_DYING(targetPed)) and (not AIM_BLACKLIST[NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED]) then
                SilentAimbotShoot(targetPed, silent_aimbot_settings.legit, silent_aimbot_settings.onlyLegit, silent_aimbot_settings.head, silent_aimbot_settings.body, silent_aimbot_settings.pelvis, silent_aimbot_settings.legs, silent_aimbot_settings.dmg, silent_aimbot_settings.chooseHash, silent_aimbot_settings.speed)
            end
        end
        wait()
    end
end)
menu.divider(silent_aimbot, "-=-=-=-=-=-=-=-=-")
menu.toggle(silent_aimbot, "Draw Text for Weapon", {}, "", function (on)
    silent_aimbot_settings.show = on
end)
menu.toggle(silent_aimbot, "Legit Mode", {}, "Bullets come from your head. Shoots through walls if not in LOS.", function (toggle)
    silent_aimbot_settings.legit = toggle
end)
menu.toggle(silent_aimbot, "Only Legit Mode", {}, "Makes aimbot only work if you have LOS.", function (toggle)
    silent_aimbot_settings.onlyLegit = toggle
end) 
menu.slider(silent_aimbot, "Damage (numbers may not be exact)", {"silentdamage"}, "", 0, 10000, 60, 5, function (val)
    silent_aimbot_settings.dmg = val
end)
menu.slider(silent_aimbot, "Speed", {"silentspeed"}, "", -1, 10000, -1, 10, function (val)
    silent_aimbot_settings.speed = val
end)
local silent_aimbot_hitboxes = menu.list(silent_aimbot, "Pick Hitboxes", {}, "")
menu.toggle(silent_aimbot_hitboxes, "Head", {}, "", function (toggle)
    silent_aimbot_settings.head = toggle
end)
menu.toggle(silent_aimbot_hitboxes, "Body", {}, "", function (toggle)
    silent_aimbot_settings.body = toggle
end)
menu.toggle(silent_aimbot_hitboxes, "Pelvis", {}, "", function (toggle)
    silent_aimbot_settings.pelvis = toggle
end)
menu.toggle(silent_aimbot_hitboxes, "Legs (both calves)", {}, "", function (toggle)
    silent_aimbot_settings.legs = toggle
end)
--Generate actions for picking weapons
local silent_aimbot_weapons = menu.list(silent_aimbot, "Pick Weapon", {}, "")
for i = 1, #GLOBAL_WEAPONS_NAMES_HASHES_TABLE do
    local wpstr = tostring(GLOBAL_WEAPONS_NAMES_HASHES_TABLE[i][2])
    menu.action(silent_aimbot_weapons, wpstr, {"silentaimwp " .. wpstr}, "Pick " .. wpstr .. " for Silent Aimbot", function ()
        local wphash = GetWPHashFromTable(GLOBAL_WEAPONS_NAMES_HASHES_TABLE, wpstr)
        util.toast("Chosen: " .. wpstr)
        util.toast("Chosen: " .. wphash)
        silent_aimbot_settings.chooseHash = wphash
        silent_aimbot_settings.chooseWP = wpstr
    end)
end

--===================================================================================================================
--===================================================================================================================
--===================================================================================================================

menu.divider(menuroot, "-=-=-=Settings=-=-=-")
menu.toggle(menuroot, "Enable ArrayList", {}, "", function (on)
    alist = on
    while alist do
        local ALIST_TBL = {} --set the array list table
        local featuresEnabled = false
        --this will check if any features are enabled
        for i = 1, #FEATURES do
            if FEATURES[i][1] then
                featuresEnabled = true
                print("featenlbd!")
                goto enabled
            end
        end
        ::enabled::
        if featuresEnabled then
            for i = 1, #FEATURES do --check the entire features table
                if FEATURES[i][1] then --if the feature is enabled...
                    table.insert(ALIST_TBL, FEATURES[i][2]) --insert it into the list
                end
            end
            --once inserting is done..
            local newlist = SortTableByStringSize(ALIST_TBL, true, false) --sort the table from longest to shortest
            for i,v in pairs(newlist) do
                local rectPadding = 0.001
                local ww, hh = directx.get_text_size(v, 0.6) --get text size of one of the current displayed string
                local xpadding = 1.0 - ((0.05 + ww)/2) -- text is drawn from the middle, we need to divide padding by 2.
                local rx, ry = GetTopLeftCornerOfText(xpadding, 0.019 * i, v, 0.6)
                DrawRect(rx - rectPadding, ry - rectPadding, ww + (rectPadding * 2), hh + (rectPadding * 2), {r = 0, g = 0, b = 0, a = 0.7})
                DrawText(xpadding, 0.019 * i, v, 1, 0.6, WhiteText, false)
            end
        end
        wait()
    end
    util.toast("Arraylist " .. tostring(alist))
end)

local tab1x, tab1y = 0.2, 0.1
local blackBGAlpha = 0.4
local hgui_freeze = false
local hguilist = menu.list(menuroot, "Hacked Client GUI", {}, "")
local mainGui = {
    midpointx = 0.5,
    midpointy = 0.5,
    widthX = 0.5,
    heightY = 0.6,
    r = 0,
    g = 0,
    b = 0,
    hue = 0
}
local button1_offsets = {x = 0.273, y = 0.232} --this is where it is relative to the screen, our "screen offset"
local button1 = {posX = (mainGui.midpointx - (0.5 - button1_offsets.x)), posY = (mainGui.midpointy - (0.5 - button1_offsets.y)), defaultActive = false}
--doing 0.5 here allows us to get the offset that was originally based off of (0.5)
local function displayCoordB1()
    util.toast(math.floor(button1.posX*1000)/1000 .. " || " .. math.floor(button1.posY*1000)/1000)
end
menu.toggle(hguilist, "Enable Hacked Client GUI", {}, "Bind this to a key.", function (toggle)
    hgui = toggle
    local plrot = ENTITY.GET_ENTITY_ROTATION(localped, 2)
    while hgui do
        DrawBackgroundGUI(hgui_freeze, blackBGAlpha, hgui_smoke)
        --draw shit here

        --
        mainGui.r, mainGui.g, mainGui.b, mainGui.hue = RainbowRGB(mainGui.hue, 1, 1, 3)
        local col = {r = mainGui.r, g = mainGui.g, b = mainGui.b, a = 1.0}
        DrawRectWithOutlineUsingMiddlePoint(mainGui.midpointx, mainGui.midpointy, mainGui.widthX, mainGui.heightY, MainBlackBG, col, 0.001)
        --

        button1.posX, button1.posY, button1.defaultActive = MakeGuiButton_Img(
        button1.posX, button1.posY,
        0.003, 0, GreyInside, MainBlackBG, PureWhite, PureWhite,
        800, 800, 0.01, 0.01, 1920, 1080, hgui_x, hgui_check, 24, 74,
        displayCoordB1, false, button1.defaultActive
        )
        local text1 = {posX = button1.posX + 0.045, posY = button1.posY - 0.01, string = "Oppressor Aimbot", align = 1, scale = 0.4, color = PureWhite}
        DrawText(text1.posX, text1.posY, text1.string, text1.align, text1.scale, text1.color, false)

        ---
        DrawCursorGUI(hgui_point)
        wait()
    end
    ENTITY.FREEZE_ENTITY_POSITION(GetLocalPed(), false)
end)
menu.toggle(hguilist, "Freeze Player Position while in GUI", {}, "", function (tog)
    hgui_freeze = tog
end)
menu.slider(hguilist, "Opacity of black BG (/10)", {"blbgopacity"}, "", 0, 10, 4, 1, function (value)
    blackBGAlpha = value / 10
end)

--[[ What I need to do:
    -check entire features table if said feature is enabled or not
    -if it is, insert it into the new array list table
    -sort said array list table by size of string (longest to shortest)
    -get the text size (for rectangle)
    -draw rectangle under the text
    -draw_text on all of the strings in the sorted array list table, spacing them out.
]]


--[[ Use this to disable firing for legit aimbot.
    -- MANDALORIAN RIFLE & BLASTER --

menu.toggle(menu.my_root(), 'Mandalorian Rifle & Blaster', {'mandoloadout'}, 'Changes Musket and SNS Pistol Mk II\'s ammo from bullets to red blaster rounds.', function(toggle)
    lasers = toggle
    local musket = util.joaat("weapon_musket")
    local blaster = util.joaat("weapon_snspistol_mk2")
    red_rays = 1198256469 --unholy hellbringer weapon hash that has red laser rounds
    while lasers do
        if WEAPON.GET_SELECTED_PED_WEAPON(PLAYER.PLAYER_PED_ID()) == musket or WEAPON.GET_SELECTED_PED_WEAPON(PLAYER.PLAYER_PED_ID()) == blaster then
            if PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) then
                util.create_thread(function()
                    local currentWeapon = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(localPed, false)
                    local pos1 = ENTITY._GET_ENTITY_BONE_POSITION_2(currentWeapon, ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(currentWeapon, "gun_muzzle"))
                    local pos2 = getOffsetFromCam(30.0)
                    PLAYER.DISABLE_PLAYER_FIRING(PLAYER.PLAYER_ID(), true)
                    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z, 200, true, red_rays, PLAYER.PLAYER_PED_ID(), true, false, 1.0)
                end)
            end
        end
        util.yield()
    end
end)
]]