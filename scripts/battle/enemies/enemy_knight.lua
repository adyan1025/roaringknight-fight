local Knight, super = Class(EnemyBattler)

function Knight:init()
    super.init(self)

    -- Enemy name
    self.name = "Knight"
    -- Sets the actor, which handles the enemy's sprites (see scripts/data/actors/dummy.lua)
    self:setActor("actor_knight")

    -- Enemy health
    self.max_health = 7300
    self.health = 7300
    -- Enemy attack (determines bullet damage)
    self.attack = 40
    -- Enemy defense (usually 0)
    self.defense = 0
    -- Enemy reward
    self.money = 100

    -- Mercy given when sparing this enemy before its spareable (20% for basic enemies)
    self.spare_points = 0

    -- List of possible wave ids, randomly picked each turn
    self.waves = {
        "basic",
        "aiming",
        "movingarena"
    }

    -- Check text (automatically has "ENEMY NAME - " at the start)
    self.check = "AT 4 DF 0\n* Cotton heart and button eye\n* Looks just like a fluffy guy."

    -- Text randomly displayed at the bottom of the screen each turn
    self.text = {
        "* The dummy gives you a soft\nsmile.",
        "* The power of fluffy boys is\nin the air.",
        "* Smells like cardboard.",
    }
    -- Text displayed at the bottom of the screen when the enemy has low health
    self.low_health_text = "* The dummy looks like it's\nabout to fall over."

    -- Register act called "Smile"
    self:registerAct("Smile")
    -- Register party act with Ralsei called "Tell Story"
    -- (second argument is description, usually empty)
    self:registerAct("Tell Story", "", {"ralsei"})

    self.float_timer = 0
    self.float_amount = 4 -- pixels
    self.float_speed = 2  -- speed multiplier

    -- CLONE SETTINGS
    self.clones = {}
    self.clone_spawn_timer = 0
    self.clone_spawn_rate = 4    -- spawn a new clone every N frames
    self.clone_lifetime = 30     -- frames before a clone fully fades out
    self.clone_speed = 1.5       -- pixels per frame drifting right
    self.clone_max_alpha = 0.5   -- starting opacity of a freshly spawned clone
end

function Knight:onAct(battler, name)
    if name == "Smile" then
        -- Give the enemy 100% mercy
        self:addMercy(100)
        -- Change this enemy's dialogue for 1 turn
        self.dialogue_override = "... ^^"
        -- Act text (since it's a list, multiple textboxes)
        return {
            "* You smile.[wait:5]\n* The dummy smiles back.",
            "* It seems the dummy just wanted\nto see you happy."
        }

    elseif name == "Tell Story" then
        -- Loop through all enemies
        for _, enemy in ipairs(Game.battle.enemies) do
            -- Make the enemy tired
            enemy:setTired(true)
        end
        return "* You and Ralsei told the dummy\na bedtime story.\n* The enemies became [color:blue]TIRED[color:reset]..."

    elseif name == "Standard" then --X-Action
        -- Give the enemy 50% mercy
        self:addMercy(50)
        if battler.chara.id == "ralsei" then
            -- R-Action text
            return "* Ralsei bowed politely.\n* The dummy spiritually bowed\nin return."
        elseif battler.chara.id == "susie" then
            -- S-Action: start a cutscene (see scripts/battle/cutscenes/dummy.lua)
            Game.battle:startActCutscene("dummy", "susie_punch")
            return
        else
            -- Text for any other character (like Noelle)
            return "* "..battler.chara:getName().." straightened the\ndummy's hat."
        end
    end

    -- If the act is none of the above, run the base onAct function
    -- (this handles the Check act)
    return super.onAct(self, battler, name)
end

function Knight:update()
    super.update(self)

    -- float logic
    self.float_timer = self.float_timer + DT
    local offset = math.sin(self.float_timer * self.float_speed) * self.float_amount

    if self.sprite then
        self.sprite.y = offset
    end

    -- SPAWN NEW CLONES
    self.clone_spawn_timer = self.clone_spawn_timer + 1
    if self.clone_spawn_timer >= self.clone_spawn_rate then
        self.clone_spawn_timer = 0
        table.insert(self.clones, {
            y = offset,
            age = 0
        })
    end

    -- UPDATE EXISTING CLONES
    for i = #self.clones, 1, -1 do
        local c = self.clones[i]
        c.age = c.age + 1

        if c.age >= self.clone_lifetime then
            table.remove(self.clones, i)
        end
    end
end

function Knight:draw()
    if self.sprite then
        for _, c in ipairs(self.clones) do
            local progress = c.age / self.clone_lifetime
            local x_pos = c.age * self.clone_speed
            local alpha = self.clone_max_alpha * (1 - progress)

            love.graphics.push()
            love.graphics.translate(x_pos, c.y)
            self.sprite:setColor(1, 1, 1, alpha)
            self.sprite:draw()
            love.graphics.pop()
        end

        self.sprite:setColor(1, 1, 1, 1)
    end

    super.draw(self)
end

function Knight:playWaveAnimation(wave_id)
    if wave_id == "aiming" then
        self:setAnimation("pointing")
    end
end

function Knight:endWaveAnimation(wave_id)
    if wave_id == "aiming" then
        self:setAnimation("idle")
    end
end

return Knight