--[[
Copyright © 2021, Zero Serenity
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Zero Serenity nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Zero Serenity BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'Facing'
_addon.version = '0.3.1'
_addon.author = 'Zero Serenity, Rubenator, modified by Nattack'
_addon.language = 'english'
_addon.commands = {'facing', 'face'}

require('vectors')
config = require('config')
local texts = require('texts')

local _defaults = {
    isVisible=true,
    max_ws_angle = 42,
    text_settings = {
        draggable = true,
        pos = {
            x = 800,
            y = 1000,
        },
        bg = {
            alpha = 255,
            red = 0,
            green = 0,
            blue = 0,
            visible = false,
        },
        flags = {
            draggable = true,
            italic = false,
            bold = true,
            bottom = false,
            right = false,
        },
        padding = 2,
        text = {
            font = "Consolas",
            size = 20,
            red = 255,
            green = 255,
            blue = 255,
            stroke = {
                width = 2,
                visible = true,
                red = 0,
                green = 0,
                blue = 0,
                alpha = 150,
            },
        },
        text_with_tp = {
            font = "Consolas",
            size = 20,
            red = 0,
            green = 255,
            blue = 0,
            stroke =
            {
                width = 2,
                visible = true,
                red = 255,
                green = 255,
                blue = 255,
                alpha = 150,
            },
        },
        text_without_tp = {
            font = "Consolas",
            size = 20,
            red = 255,
            green = 255,
            blue = 0,
            stroke =
            {
                width = 2,
                visible = true,
                red = 255,
                green = 255,
                blue = 255,
                alpha = 150,
            },
        },
    },
}

local directions = {
    west = math.pi,
    westwestsouth = 5 * math.pi / 6 ,
    southwest = 3 * math.pi / 4,
    southsouthwest = 2 * math.pi / 3,
    south = math.pi / 2,
    southsoutheast = math.pi / 3,
    southeast = math.pi/4,
    easteastsouth = math.pi/6,
    east = 0,
    easteastnorth = 11*math.pi/6,
    northeast = 7 * math.pi / 4,
    northnortheast = 5 * math.pi / 3,
    north = 3 * math.pi / 2,
    northnorthwest = 4 * math.pi / 3,
    northwest = 5 * math.pi / 4,
    westwestnorth = 7 * math.pi / 6,
    -- this is how big of a step turning left or right will do. 
    step = math.pi/4
}


local settings = config.load(_defaults)
local text = texts.new("${left}${angle}${right}",settings.text_settings,settings)
text:register_event("reload",function()
    init()
end)
function init()
    local windower_settings = windower.get_windower_settings()
    pos = settings.text_settings.pos
    pos.x = pos.x < -10 and 0 or pos.x >= windower_settings.ui_x_res and windower_settings.ui_x_res - 100 or pos.x
    pos.y = pos.y < -5 and 0 or pos.y >= windower_settings.ui_y_res and windower_settings.ui_y_res - 100 or pos.y
    text:pos(settings.text_settings.pos.x, settings.text_settings.pos.y)
    isVisible = settings.isVisible
    lastcheck = 0
end
init()

function getMe()
    return windower.ffxi.get_mob_by_target('me')
end

function getTarget()
    return (windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('t'))
end

function getAngle(me,point)
    local dir = V{point.x, point.y} - V{me.x, me.y}
    local heading = V{}.from_radian(me.facing)
    local angle = V{}.angle(dir, heading) * (dir[1]*heading[2]-dir[2]*heading[1] < 0 and -1 or 1)
    return angle
end

function setFacing(angle)
    windower.ffxi.turn(angle)
end

function setFacingToTarget(me, target)
    local _me = me or getMe()
    local _target = target or getTarget()
    if (_me and _target) and _me ~= _target then
        setFacing(getAngle(_me, _target) + _me.facing)
    end
end

windower.register_event('prerender', function()
    if isVisible then
        local clock = os.clock()
        if lastcheck + 0.1 > clock then return end
        lastcheck = clock
        local me = getMe()
        local target = getTarget()
        if not me or not target or me.id == target.id then
            text:hide()
            return
        end
    
        local degrees = math.deg(getAngle(me, target))
        text.left = degrees < settings.max_ws_angle * -1 and "<" or degrees > settings.max_ws_angle and " " or "|"
        text.right = degrees > settings.max_ws_angle and ">" or degrees < settings.max_ws_angle * -1 and " " or "|"
        text.angle = "%03.0f":format(math.floor(degrees:abs()+0.5))

        if degrees:abs() < settings.max_ws_angle then
            if windower.ffxi.get_player().vitals.tp >= 1000 then
                text:color(settings.text_settings.text_with_tp.red,settings.text_settings.text_with_tp.green,settings.text_settings.text_with_tp.blue)
            else
                text:color(settings.text_settings.text_without_tp.red,settings.text_settings.text_without_tp.green,settings.text_settings.text_without_tp.blue)
            end
        else
            text:color(settings.text_settings.text.red,settings.text_settings.text.green,settings.text_settings.text.blue)
        end
        text:show()
    end
    
end)

windower.register_event('addon command', function(command, arg)
    local function echo(color, ...)
        for _,msg in ipairs(arg) do
            windower.add_to_chat(color, msg)
        end
    end
    local col = 17

    command = command and command:lower() or 'help'
    -- turning commands
    if S{'f', 'ft','face','target'}:contains(command) then 
        local me = getMe()
        local target = getTarget()
        if target and me ~= target then
            setFacing(getAngle(me, target) + me.facing)
        end
    elseif S{'a', 'away', 'petrifaction'}:contains(command) then
        local me = getMe()
        local target = getTarget()
        if target and me ~= target then
            setFacing(getAngle(me, target) + me.facing + math.pi)
        end
    elseif S{'t', 'turn'}:contains(command) then
        local me = getMe()
        setFacing(me.facing + math.pi)
    elseif S{'left', 'right'}:contains(command) then
        local me = getMe()
        local direction  = 0
        if command == 'left' then
            direction = directions.step * -1
        else
            direction = directions.step
        end
        setFacing(me.facing + direction)
    
    elseif S{'west', 'w'}:contains(command) then
        setFacing(directions.west)
    elseif S{'westsouthwest', 'wsw'}:contains(command) then
        setFacing(directions.westwestsouth)
    elseif S{'southwest', 'sw'}:contains(command) then
        setFacing(directions.southwest)
    elseif S{'southsouthwest', 'ssw'}:contains(command) then
        setFacing(directions.southsouthwest)
    elseif S{'south', 's'}:contains(command) then
        setFacing(directions.south)
    elseif S{'southsoutheast', 'sse'}:contains(command) then
        setFacing(directions.southsoutheast)
    elseif S{'southeast', 'se'}:contains(command) then
        setFacing(directions.southeast)
    elseif S{'eastsoutheast', 'ese'}:contains(command) then
        setFacing(directions.easteastsouth)
    elseif S{'east', 'se'}:contains(command) then
        setFacing(directions.east)
    elseif S{'eastnortheast', 'ene'}:contains(command) then
        setFacing(directions.easteastnorth)
    elseif S{'northeast', 'ne'}:contains(command) then
        setFacing(directions.northeast)
    elseif S{'northnortheast', 'nne'}:contains(command) then
        setFacing(directions.northnortheast)
    elseif S{'north', 'n'}:contains(command) then
        setFacing(directions.north)
    elseif S{'northnorthwest', 'nnw'}:contains(command) then
        setFacing(directions.northnorthwest)
    elseif S{'northwest', 'nw'}:contains(command) then
        setFacing(directions.northwest)
    elseif S{'westnorthwest', 'wnw'}:contains(command) then
        setFacing(directions.westwestnorth)

    -- visibility options
    elseif S{'hide'}:contains(command) then
        isVisible = false
        text:hide()
        echo(col, 'Facing: disabling display')

    elseif S{'show'}:contains(command) then 
        isVisible = true
        echo(col, 'Facing: enabling display')

    elseif S{'v', 'visible'}:contains(command) then
        isVisible = not isVisible
        if isVisible then
            echo(col, 'Facing: toggled display on')
        else
            text:hide()
            echo(col, 'Facing: toggled display off')
        end
    -- misc
    elseif S{'save'}:contains(command) then
        settings.isVisible = isVisible
        config.save(settings)
    elseif S{'?', 'h', 'help'}:contains(command) then 
        local col = 17
        echo(col,
            'Facing v' .. _addon.version,
            'Usage: facing [options]',
            'OPTIONS: ',
            '   face, f, ft',
            '       face target',
            '   away, a',
            '       face away from target',
            '   turn, t',
            '       turn about face'
            '   left, right',
            '       turn left or right'
            '   n, ne, e, se, s, sw, w, nw',
            '       face a cardinal direction',
            '   hide, show, visible, v',
            '       hide, show, or toggle visibility',
            '   save',
            '       save state',
            '   help, h',
            '       this help menu.'
        )
    else
        local col = 17
        echo(col, 'Facing: Unknown command: ' .. command)
    end
end)


