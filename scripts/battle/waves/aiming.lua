local Aiming, super = Class(Wave)

function Aiming:onStart()
    -- Get all enemies that selected this wave as their attack
    local attackers = self:getAttackers()

    -- Tell each attacker to play its aiming animation
    for _, attacker in ipairs(attackers) do
        if attacker.playWaveAnimation then
            attacker:playWaveAnimation("aiming")
        end
    end

    -- Every 0.5 seconds...
    self.timer:every(1 / 2, function()
        local attackers = self:getAttackers()
        for _, attacker in ipairs(attackers) do
            local x, y = attacker:getRelativePos(attacker.width / 2, attacker.height / 2)
            local angle = MathUtils.angle(x, y, Game.battle.soul.x, Game.battle.soul.y)
            self:spawnBullet("smallbullet", x, y, angle, 8)
        end
    end)
end

function Aiming:onEnd()
    local attackers = self:getAttackers()
    for _, attacker in ipairs(attackers) do
        if attacker.endWaveAnimation then
            attacker:endWaveAnimation("aiming")
        end
    end
end

function Aiming:update()
    super.update(self)
end

return Aiming