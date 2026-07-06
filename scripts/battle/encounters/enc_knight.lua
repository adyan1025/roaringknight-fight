local Knight, super = Class(Encounter)

function Knight:init()
    super.init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text = "* The Roaring Knight appears."

    -- Battle music ("battle" is rude buster)
    self.music = "black_knife"
    -- Enables the purple grid battle background
    self.background = true

    -- Add the dummy enemy to the encounter
    self:addEnemy("enemy_knight")

    --- Uncomment this line to add another!
    --self:addEnemy("dummy")
end

return Knight
