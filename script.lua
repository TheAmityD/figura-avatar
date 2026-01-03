vanilla_model.PLAYER:setVisible(false)
models:setPrimaryRenderType("TRANSLUCENT")
models:setSecondaryRenderType("EMISSIVE")

vanilla_model.ELYTRA:setVisible(false)

-- Secondary Texture Setup

local fullHealth
local sleeve = models.model.root.RightArm.emissiveSleeve
local filRestStr = "model.sleeve2_e"
local filThinkStr = "model.filThink"
local filHappyStr = "model.filHappy"
local filExcitedStr = "model.filExcited"
local filHealingStr = "model.filHeal"
local filRest = textures[filRestStr]
local filThink = textures[filThinkStr]
local filHappy = textures[filHappyStr]
local filExcited = textures[filExcitedStr]
local filHealing = textures[filHealingStr]
local currentMood = filRest
local currentMoodStr = filRestStr
-- log(filRest)
sleeve:setSecondaryTexture("custom", filRest)

-- Use strings for pings!
function pings.changeMood(moodStr)
    currentMood = textures[moodStr]
    currentMoodStr = moodStr
    if not fullHealth then
        log("Low health; mood change deferred.")
    else
        sounds:playSound("entity.zombie_villager.converted", player:getPos(), 0.2, math.random(8, 12)/10, false)
        sleeve:setSecondaryTexture("custom", textures[moodStr])
    end
end

-- Initialization

-- FOXGaze: Bitslayn, ChloeSpacedOut, vickystxr
local gaze = require("Gaze")
local charGaze = gaze:newGaze()
charGaze:newAnim(animations.model.lookHor, animations.model.lookVer)
charGaze:newBlink(animations.model.blink)

function pings.Gaze(i)
  gazeEnabled = i
  if (gazeEnabled) then
    charGaze:zero()
    charGaze:disable()
  else
    charGaze:enable()
  end
end

function events.ENTITY_INIT()
    --log("Entity initialized.")
    --log("Health: " .. player:getHealth())
    --log("Max Health: " .. player:getMaxHealth())
    charGaze.config.soundInterest = 0.4
    charGaze.config.socialInterest = 0.7
    charGaze.config.faceDirection = false
end

-- Moves
function pings.playAnim(anim)
    animations.model[anim]:play()
end

function checkWingsVisible(bool)
    if bool == not elytraEquipSync then
        pings.wingsVisible(bool)
    end
end

function pings.wingsVisible(bool)
    elytraEquipSync = bool
    models.wings:setVisible(bool)
end
pings.wingsVisible(false)

-- Events
local micState = false
local micOffTime = 0

function events.tick()
  if player.isLoaded then
    Crouching = player:getPose() == "CROUCHING"
    Sprinting = player:isSprinting()
    Blocking = player:isBlocking()
    Fishing = player:isFishing()
    Sleeping = player:getPose() == "SLEEPING"
    Swimming = player:getPose() == "SWIMMING"
    Flying = player:getPose() == "FALL_FLYING"
    Walking = player:getVelocity().xz:length() > .01
  end

  if ((Walking or Crouching or Flying) and (animations.model.inspecting:isPlaying())) then
    animations.model.inspecting:stop()
    models.model.root.Head:setParentType("Head")
    models.model.root.Body:setParentType("Body")
    models.model.root.LeftArm.ArmorPivot:setParentType("LeftArm")
    models.model.root.RightArm.ArmorPivot:setParentType("RightArm")
  end

  local prevMicState = micState
  micOffTime = micOffTime + 1
  micState = micOffTime <= 2
  if prevMicState ~= micState then
    if micState then
        pings.changeMouth("model.mouth-speak", false)
    else
        pings.changeMouth(currentMouth, false)
    end
  end

  if player:getHealth() < player:getMaxHealth()/4 then
        fullHealth = false
        sleeve:setSecondaryTexture("custom", filHealing)
    end
    if player:getHealth() >= player:getMaxHealth()/4 then
        fullHealth = true
        sleeve:setSecondaryTexture("custom", currentMood)
    end

  if player:getItem(5).id == "minecraft:elytra" then
    checkWingsVisible(true)
  else
    checkWingsVisible(false)
  end
  animations.wings.flying:setPlaying(player:getPose() == "FALL_FLYING")
    animations.wings.crouch:setPlaying(Crouching)
end

if client:isModLoaded("figurasvc") and host:isHost() then
    function events.HOST_MICROPHONE(pcm)
        micOffTime = 0
    end
end

-- Action Wheel Setup

local prevPage
local currPage

function switchPage(page)
    prevPage = currPage
    action_wheel:setPage(page)
    currPage = action_wheel:getCurrentPage()
    --log("Switched to page: " .. page:getTitle())
    --log("Previous page: " .. prevPage:getTitle())
end

function backButtonSetup()
local backAction = currPage:newAction(8)
backAction:setTitle("Back")
backAction:setItem("minecraft:arrow")
backAction:onLeftClick(function()
    switchPage(prevPage)
end)
end

local mainPage = action_wheel:newPage("main")
action_wheel:setPage(mainPage)
prevPage = mainPage
currPage = action_wheel:getCurrentPage()

local colorPage = action_wheel:newPage("colors")
local colorPageBtn = mainPage:newAction(1)
colorPageBtn:setTitle("Filament Moods")
colorPageBtn:setItem("minecraft:painting")
colorPageBtn:onLeftClick(function()
    switchPage(colorPage)
    backButtonSetup()
end)

local animPage = action_wheel:newPage("animations")
local animPageBtn = mainPage:newAction(2)
animPageBtn:setTitle("Animations")
animPageBtn:setItem("minecraft:fire_charge")
animPageBtn:onLeftClick(function()
    switchPage(animPage)
    backButtonSetup()
end)

local mouthPage = action_wheel:newPage("faces")
local mouthPageBtn = mainPage:newAction(3)
mouthPageBtn:setTitle("Mouths")
mouthPageBtn:setItem("minecraft:player_head")
mouthPageBtn:onLeftClick(function()
    switchPage(mouthPage)
    backButtonSetup()
end)

local eyesPage = action_wheel:newPage("eyes")
local eyesPageBtn = mainPage:newAction(4)
eyesPageBtn:setTitle("Eyes")
eyesPageBtn:setItem("minecraft:ender_eye")
eyesPageBtn:onLeftClick(function()
    switchPage(eyesPage)
    backButtonSetup()
end)

-- Actions for animation page; ascending index

local inspectAnim = animPage:newAction(2)
inspectAnim:setTitle("Inspect")
inspectAnim:setItem("minecraft:redstone")
inspectAnim:onLeftClick(function()
    pings.playAnim("inspecting")
end)

function inspectParticles()
    particles:newParticle("minecraft:wax_off", sleeve:partToWorldMatrix(2,2,2):apply():add(math.random()-.5,math.random()-.5,math.random()-.5)):setScale(1):setLifetime(20)
    sounds:playSound("block.amethyst_block.resonate", player:getPos(), 1, math.random(8, 12)/10, false)
end

local jawdropAnim = animPage:newAction(3)
jawdropAnim:setTitle("Jaw Drop")
jawdropAnim:setItem("minecraft:bone")
jawdropAnim:onLeftClick(function()
    pings.playAnim("jawdrop")
end)

-- Actions for color page; ascending index

local filRestAction = colorPage:newAction(1)
filRestAction:setTitle("Resting")
filRestAction:setItem("minecraft:light_gray_dye")
filRestAction:onLeftClick(function()
    pings.changeMood(filRestStr)
end)

local filThinkAction = colorPage:newAction(2)
filThinkAction:setTitle("Thinking")
filThinkAction:setItem("minecraft:light_blue_dye")
filThinkAction:onLeftClick(function()
    pings.changeMood(filThinkStr)
end)

local filHappyAction = colorPage:newAction(3)
filHappyAction:setTitle("Happy")
filHappyAction:setItem("minecraft:yellow_dye")
filHappyAction:onLeftClick(function()
    pings.changeMood(filHappyStr)
end)
local filExcitedAction = colorPage:newAction(4)
filExcitedAction:setTitle("Excited")
filExcitedAction:setItem("minecraft:orange_dye")
filExcitedAction:onLeftClick(function()
    pings.changeMood(filExcitedStr)
end)

-- Actions for mouth page; ascending index

function pings.changeMouth(mouthTex, remember)
    if remember == true then
        currentMouth = mouthTex
    end
    if mouthTex == nil then
        models.model.root.Head.mouth.mouth:setVisible(false)
    else
        models.model.root.Head.mouth.mouth:setVisible(true)
        models.model.root.Head.mouth.mouth:setPrimaryTexture("CUSTOM", textures[mouthTex])
    end
end

local uwuMouthAction = mouthPage:newAction(1)
    :setTitle("UwU Mouth")
    :setItem("minecraft:carved_pumpkin")
    uwuMouthAction:onLeftClick(function()
        pings.changeMouth("model.mouth-uwu", true)
    end)

local smileMouthAction = mouthPage:newAction(2)
    :setTitle("Smile Mouth")
    :setItem("minecraft:golden_apple")
    smileMouthAction:onLeftClick(function()
        pings.changeMouth("model.mouth-smile", true)
    end)

local ohMouthAction = mouthPage:newAction(3)
    :setTitle("O Mouth")
    :setItem("minecraft:enchanted_golden_apple")
    ohMouthAction:onLeftClick(function()
        pings.changeMouth("model.mouth-oh", true)
    end)

local frownMouthAction = mouthPage:newAction(4)
    :setTitle("Frown Mouth")
    :setItem("minecraft:rotten_flesh")
    frownMouthAction:onLeftClick(function()
        pings.changeMouth("model.mouth-frown", true)
    end)

local smugMouthAction = mouthPage:newAction(5)
    :setTitle("Smug Mouth")
    :setItem("minecraft:netherite_scrap")
    smugMouthAction:onLeftClick(function()
        pings.changeMouth("model.mouth-smug", true)
    end)

local faceOffAction = mouthPage:newAction(7)
    :setTitle("No Mouth")
    :setItem("minecraft:barrier")
    :onLeftClick(function()
        pings.changeMouth(nil, true)
    end)

-- Actions for eyes page; ascending index

local gazeToggleAction = eyesPage:newAction(1)
    :setTitle("Gaze [Enabled]")
    :setToggleTitle("Gaze [Disabled]")
    :setItem("minecraft:ender_eye")
    :setToggleItem("minecraft:barrier")
    :setOnToggle(pings.Gaze)

function pings.constrictEyes()
    models.model.root.Head.eyes.left:setPos(0.8, 0, 0)
    models.model.root.Head.eyes.right:setPos(-0.8, 0, 0)
    models.model.root.Head.eyes:setScale(0.6, 0.7, 1)
end

local constrictEyesAction = eyesPage:newAction(2)
    :setTitle("Constricted Eyes")
    :setItem("minecraft:spyglass")
    :onLeftClick(function()
        pings.constrictEyes()
    end)

function pings.defaultEyes()
    models.model.root.Head.eyes.left:setPos(0, 0, 0)
    models.model.root.Head.eyes.right:setPos(0, 0, 0)
    models.model.root.Head.eyes:setScale(1, 1, 1)
end

local defaultEyesAction = eyesPage:newAction(7)
    :setTitle("Default Eyes")
    :setItem("minecraft:compass")
    :onLeftClick(function()
        pings.defaultEyes()
    end)

-- Animations on specific tasks. Write in entity_init.

function events.render()
end