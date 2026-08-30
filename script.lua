vanilla_model.PLAYER:setVisible(false)
models:setPrimaryRenderType("TRANSLUCENT")
models:setSecondaryRenderType("EMISSIVE")

vanilla_model.ELYTRA:setVisible(false)
vanilla_model.ARMOR:setVisible(false)

models.model.root.Head.eyes.leftGlowingSclera:setPrimaryRenderType("EMISSIVE")
models.model.root.Head.eyes.rightGlowingSclera:setPrimaryRenderType("EMISSIVE")

avatar:setColor(vectors.hexToRGB("#005748"), "donator")

-- Secondary Texture Setup

local fullHealth
local sleeve = models.model.root.RightArm.filaments.emissiveSleeve
local filRestStr = "model.sleeve2_e"
local filThinkStr = "model.filThink"
local filHappyStr = "model.filHappy"
local filExcitedStr = "model.filExcited"
local filHealingStr = "model.filHeal"
--local filRest = textures[filRestStr]
--local filThink = textures[filThinkStr]
--local filHappy = textures[filHappyStr]
--local filExcited = textures[filExcitedStr]
--local filHealing = textures[filHealingStr]
--local currentMood = filRest
local currentMoodStr = filRestStr
local currentClothes = "model.blightHand-trans"
local sleepStatus = false
local eyesClosed = false
local eyesGlowing = false
local chatOpen = false
-- log(filRest, filThink, filHappy, filExcited, filHealing)
sleeve:setSecondaryTexture("custom", textures[filRestStr])

-- Use strings for pings!
function pings.changeMood(moodStr)
    --currentMood = textures[moodStr]
    currentMoodStr = moodStr
    if not fullHealth then
        log("Low health; mood change deferred.")
    else
        sounds:playSound("entity.zombie_villager.converted", player:getPos(), 0.2, math.random(8, 12)/10, false)
        sleeve:setSecondaryTexture("custom", textures[moodStr])
    end
end

function pings.moodOnDamage(i)
    if i then
        filHealingEnabled = true
        sleeve:setSecondaryTexture("custom", textures[filHealingStr])
        -- log("Health low; switching to healing mood.")
    else
        filHealingEnabled = false
        sleeve:setSecondaryTexture("custom", textures[currentMoodStr])
    -- Revert to current mood after a short delay
    end
end

function pings.restoreHeldItem()
    vanilla_model.HELD_ITEMS:setVisible(true)
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

local NameplateGradients = require("NameplateGradients")

function events.ENTITY_INIT()
    --log("Entity initialized.")
    --log("Health: " .. player:getHealth())
    --log("Max Health: " .. player:getMaxHealth())
    charGaze.config.soundInterest = 0.4
    charGaze.config.socialInterest = 0.7
    charGaze.config.faceDirection = false

    NameplateGradients.SetNameplate({
         text = "AmityD",
         colors = {
             type = "bezier",
             [0] = "#13ba9d",
             [0.5] = "#005748",
             [1] = "#17816f"
         },
         backgroundColor = "#000000",
         backgroundOpacity = 0.11,
         scrollSpeed = 1,
         glowing = true,
         visible = true,
         outline = true,
         shadow = true,
         italic = false,
         bold = false,
         underlined = false,
         strikethrough = false,
         obfuscated = false
    })
end

-- Moves
function pings.playAnim(anim)
    animations.model[anim]:play()
end

function pings.stopAnim(anim)
    animations.model[anim]:stop()
end

function pings.danceLoop(start, anim, sound)
    --animations.model[start]:play()
    animations.model[anim]:play()
    if sound then
        sounds:playSound(sound, player:getPos(), 0.5, 1, true)
    end
end

local textingBubble = models.model.root.Body:newText("textBubble")
textingBubble:setText(":texting_animated:")
:setPos(0, 10, -9)
:setAlignment("CENTER")
:setLight(15, 15)
:setVisible(false)

local zzzBubble = models.model.root.Body:newText("zzzBubble")
zzzBubble:setText(":zzz:")
:setPos(0, 16, -5)
:setAlignment("CENTER")
:setLight(15, 15)
:setVisible(false)

texting = false

function pings.chatAnim(bool)
    if bool then
        models.model.root.Head:setParentType("HelmetPivot")
        models.model.root.Body:setParentType("ChestplateBodyPivot")
        models.model.root.LeftArm.ArmorPivot:setParentType("LeftShoulderPivot")
        models.model.root.RightArm.ArmorPivot:setParentType("RightShoulderPivot")
        models.model.root.RightArm.phone:setVisible(true)
        textingBubble:setVisible(true)
        animations.model.texting:play()
        animations.model.texting2:play()
        texting = true
    else
        models.model.root.Head:setParentType("Head")
        models.model.root.Body:setParentType("Body")
        models.model.root.LeftArm.ArmorPivot:setParentType("LeftArm")
        models.model.root.RightArm.ArmorPivot:setParentType("RightArm")
        models.model.root.RightArm.phone:setVisible(false)
        textingBubble:setVisible(false)
        animations.model.texting:stop()
        animations.model.texting2:stop()
        texting = false
    end
end

function checkWingsVisible(bool)
    if bool == not elytraEquipSync then
        pings.wingsVisible(bool)
    end
end

function pings.wingsVisible(bool)
    elytraEquipSync = bool
    models.wings.Body:setVisible(bool)
end

pings.wingsVisible(false)

-- Events

function armorPivot(bool)
    if bool then
        models.model.root.Head:setParentType("HelmetPivot")
        models.model.root.Body:setParentType("ChestplateBodyPivot")
        models.model.root.LeftArm.ArmorPivot:setParentType("LeftShoulderPivot")
        models.model.root.RightArm.ArmorPivot:setParentType("RightShoulderPivot")
        models.model.root.Body.ArmorPivot:setParentType("BeltPivot")
        models.model.root.LeftLeg:setParentType("LeftLeggingPivot")
        models.model.root.RightLeg:setParentType("RightLeggingPivot")
        models.model.root.LeftLeg.ArmorPivot:setParentType("LeftBootPivot")
        models.model.root.RightLeg.ArmorPivot:setParentType("RightBootPivot")
    else
        models.model.root.Head:setParentType("Head")
        models.model.root.Body:setParentType("Body")
        models.model.root.LeftArm.ArmorPivot:setParentType("LeftArm")
        models.model.root.RightArm.ArmorPivot:setParentType("RightArm")
        models.model.root.Body.ArmorPivot:setParentType("Body")
        models.model.root.LeftLeg:setParentType("LeftLeg")
        models.model.root.RightLeg:setParentType("RightLeg")
        models.model.root.LeftLeg.ArmorPivot:setParentType("LeftLeg")
        models.model.root.RightLeg.ArmorPivot:setParentType("RightLeg")
    end
end

local micState = false
local micOffTime = 0

local appearanceSyncTimer = 0
local sleepIdleTimer = 0
local sleepIdleThreshold = 6000 -- default 6000 (5 minutes). set to 100 (5 seconds) for debug
local textRandomTimer = 0

local hb
local heartbeatTimer = 0
local minBPM
local maxBPM

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

  -- syncs clothes & mouth every 15 seconds in case of desync; can be changed to be more or less frequent
  --print(appearanceSyncTimer)
  if appearanceSyncTimer == 300 then
    appearanceSyncTimer = 0
    pings.syncAppearance(currentClothes, currentMouth, currentMoodStr, isArmorVisible, isGlassesVisible)
  else
    appearanceSyncTimer = appearanceSyncTimer + 1
  end

  --print(heartbeatTimer)
  hb = (20 - player:getHealth()) / (20 - 1)
  minBPM = math.floor((50 + hb * (160 - 50)), 0.5)   -- 50 → 160
  maxBPM = math.floor((60 + hb * (200 - 60)), 0.5) -- 60 → 200
  -- print("Heartbeat: " .. minBPM .. " → " .. maxBPM)
  if player:isAlive() and heartbeatTimer >= math.random(1200/maxBPM, 1200/minBPM) then
    heartbeatTimer = 0
    avatar:setColor(vectors.hexToRGB("#770000"), "donator")
  elseif player:isAlive() then
    heartbeatTimer = heartbeatTimer + 1
    avatar:setColor(vectors.hexToRGB("#005748"), "donator")
  else
    heartbeatTimer = 0
    avatar:setColor(vectors.hexToRGB("#000000"), "donator")
  end

  --print("Light Level: " .. world.getLightLevel(player:getPos()))
  if world.getLightLevel(player:getPos()) < 7 then
    if not eyesGlowing then
        eyesGlowing = true
        models.model.root.Head.eyes.leftGlowingSclera:setVisible(true)
        models.model.root.Head.eyes.rightGlowingSclera:setVisible(true)
        models.model.root.Head.eyes.left.leftIris:setPrimaryRenderType("EMISSIVE_SOLID")
        models.model.root.Head.eyes.right.rightIris:setPrimaryRenderType("EMISSIVE_SOLID")
        models.model.root.Head.eyes.left.leftIris:setUV(1/16, 0)
        models.model.root.Head.eyes.right.rightIris:setUV(1/16, 0)
    end
  else
    if eyesGlowing then
        eyesGlowing = false
        models.model.root.Head.eyes.leftGlowingSclera:setVisible(false)
        models.model.root.Head.eyes.rightGlowingSclera:setVisible(false)
        models.model.root.Head.eyes.left.leftIris:setPrimaryRenderType("TRANSLUCENT")
        models.model.root.Head.eyes.right.rightIris:setPrimaryRenderType("TRANSLUCENT")
        models.model.root.Head.eyes.left.leftIris:setUV(0, 0)
        models.model.root.Head.eyes.right.rightIris:setUV(0, 0)
    end
  end

  --print(textRandomTimer)
  if texting and textRandomTimer >= math.random(2, 6) then
    sounds:playSound("sounds.type", player:getPos(), 0.5, math.random(8, 12)/10, false)
    textRandomTimer = 0
  elseif texting == true then
    textRandomTimer = textRandomTimer + 1
  elseif not texting and textRandomTimer > 0 then
    textRandomTimer = 0
  end

--print(sleepIdleTimer)
--print("closeeyes" .. animations.model.closeEyes:getTime())
--print(eyesClosed)
  if sleepIdleTimer == sleepIdleThreshold then
    if not (Crouching or Sprinting or Flying or Walking or Swimming or Sleeping or Blocking or Fishing) and not eyesClosed and not (animations.model.inspecting:isPlaying() or animations.model.oddloop:isPlaying()) then
        --pings.playAnim("sleeping")
        animations.model["sleeping"]:play()
        animations.model["closeEyes"]:play()
        zzzBubble:setVisible(true)
        armorPivot(true)
        vanilla_model.HELD_ITEMS:setVisible(false)
        vanilla_model.CAPE_MODEL:setVisible(false)
    end
  else
    sleepIdleTimer = sleepIdleTimer + 1
  end
  if (Crouching or Sprinting or Flying or Walking or Swimming or Sleeping or Blocking or Fishing or animations.model.inspecting:isPlaying() or animations.model.oddloop:isPlaying() or animations.model.texting2:isPlaying()) then
    sleepIdleTimer = 0
    zzzBubble:setVisible(false)
    --pings.stopAnim("sleeping")
    animations.model["sleeping"]:stop()
    if not eyesClosed then
        animations.model["closeEyes"]:stop()
    end
    if not (animations.model.inspecting:isPlaying() or animations.model.oddloop:isPlaying() or animations.model.texting2:isPlaying()) then
        armorPivot(false)
        vanilla_model.HELD_ITEMS:setVisible(true)
        vanilla_model.CAPE_MODEL:setVisible(true)
    end
  end

  if host:isChatOpen() and player:getPose() ~= "SLEEPING" then
    if not chatOpen then
        --print("host:" .. tostring(host:isChatOpen()))
        --print("chatOpen:" .. tostring(chatOpen))
        chatOpen = true
        pings.chatAnim(true)
    end
    else if chatOpen then
        --print("host:" .. tostring(host:isChatOpen()))
        --print("chatOpen:" .. tostring(chatOpen))
        chatOpen = false
        pings.chatAnim(false)
        pings.restoreHeldItem()
    end
  end

  if ((Walking or Crouching or Flying) and (animations.model.inspecting:isPlaying() or animations.model.oddloop:isPlaying())) then
    animations.model.inspecting:stop()
    animations.model.oddloop:stop()
    sounds:stopSound()
    armorPivot(false)
    pings.restoreHeldItem()
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
        -- sleeve:setSecondaryTexture("custom", filHealing)
        if not filHealingEnabled then
            pings.moodOnDamage(true)
        end
    end
    if player:getHealth() >= player:getMaxHealth()/4 then
        fullHealth = true
        -- sleeve:setSecondaryTexture("custom", currentMood)
        if filHealingEnabled then
            pings.moodOnDamage(false)
        end
    end

    if player:getPose() == "SLEEPING" then
        if not sleepStatus then
            sleepStatus = true
            pings.Gaze(true)
            if not eyesClosed then
                pings.playAnim("closeEyes")
            end
        end
    else
        if sleepStatus and not eyesClosed then
            sleepStatus = false
            pings.stopAnim("closeEyes")
            pings.playAnim("openEyes")
            pings.Gaze(false)
        end
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
:setTitle("Back")
:setItem("minecraft:arrow")
:onLeftClick(function()
    switchPage(prevPage)
end)
end

local mainPage = action_wheel:newPage("main")
action_wheel:setPage(mainPage)
prevPage = mainPage
currPage = action_wheel:getCurrentPage()

local colorPage = action_wheel:newPage("colors")
local colorPageBtn = mainPage:newAction(1)
:setTitle("Filament Moods")
:setItem("minecraft:painting")
:onLeftClick(function()
    switchPage(colorPage)
    backButtonSetup()
end)

local animPage = action_wheel:newPage("animations")
local animPageBtn = mainPage:newAction(2)
:setTitle("Emotes")
:setItem("minecraft:fire_charge")
:onLeftClick(function()
    switchPage(animPage)
    backButtonSetup()
end)

local mouthPage = action_wheel:newPage("faces")
local mouthPageBtn = mainPage:newAction(3)
:setTitle("Mouths")
:setItem("minecraft:player_head")
:onLeftClick(function()
    switchPage(mouthPage)
    backButtonSetup()
end)

local eyesPage = action_wheel:newPage("eyes")
local eyesPageBtn = mainPage:newAction(4)
:setTitle("Eyes")
:setItem("minecraft:ender_eye")
:onLeftClick(function()
    switchPage(eyesPage)
    backButtonSetup()
end)

local clothesPage = action_wheel:newPage("clothes")
local clothesPageBtn = mainPage:newAction(5)
:setTitle("Clothes")
:setItem("minecraft:leather_chestplate")
:onLeftClick(function()
    switchPage(clothesPage)
    backButtonSetup()
end)

-- armor toggle

isArmorVisible = false

function armorVisible(i)
    if i then
        isArmorVisible = true
    else
        isArmorVisible = false
    end
    --print(isArmorVisible)
    pings.armorVisible(isArmorVisible)
end

function pings.armorVisible(i)
    vanilla_model.ARMOR:setVisible(i)
end

local armorToggle = mainPage:newAction(6)
:setTitle("Toggle Armor [Off]")
:setToggleTitle("Toggle Armor [On]")
:setItem("minecraft:iron_chestplate")
:setToggleItem("minecraft:chainmail_chestplate")
:setColor(1, 0, 0)
:setToggleColor(0, 1, 0)
:setOnToggle(armorVisible)

-- Actions for animation page; ascending index

local inspectAnim = animPage:newAction(2)
:setTitle("Inspect")
:setItem("minecraft:redstone")
:onLeftClick(function()
    pings.playAnim("inspecting")
end)

function inspectParticles()
    particles:newParticle("minecraft:wax_off", sleeve:partToWorldMatrix(2,2,2):apply():add(math.random()-.5,math.random()-.5,math.random()-.5)):setScale(1):setLifetime(20)
    sounds:playSound("block.amethyst_block.resonate", player:getPos(), 1, math.random(8, 12)/10, false)
end

local jawdropAnim = animPage:newAction(3)
:setTitle("Jaw Drop")
:setItem("minecraft:bone")
:onLeftClick(function()
    pings.playAnim("jawdrop")
end)

local danceAnim = animPage:newAction(4)
:setTitle("Oddloop")
:setItem("minecraft:music_disc_cat")
:onLeftClick(function()
    pings.danceLoop("oddloop-start", "oddloop")
    -- (C) 2014 MASH A&R / A-SKETCH INC. Sample used non-commercially and experimentally. Not included in distribution. The file's too big, anyways.
end)

-- Actions for color page; ascending index

local filRestAction = colorPage:newAction(1)
:setTitle("Resting")
:setItem("minecraft:light_gray_dye")
:onLeftClick(function()
    pings.changeMood(filRestStr)
end)

local filThinkAction = colorPage:newAction(2)
:setTitle("Thinking")
:setItem("minecraft:light_blue_dye")
:onLeftClick(function()
    pings.changeMood(filThinkStr)
end)

local filHappyAction = colorPage:newAction(3)
:setTitle("Happy")
:setItem("minecraft:yellow_dye")
:onLeftClick(function()
    pings.changeMood(filHappyStr)
end)
local filExcitedAction = colorPage:newAction(4)
:setTitle("Excited")
:setItem("minecraft:orange_dye")
:onLeftClick(function()
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
    :onLeftClick(function()
        pings.changeMouth("model.mouth-uwu", true)
    end)

local smileMouthAction = mouthPage:newAction(2)
    :setTitle("Smile Mouth")
    :setItem("minecraft:golden_apple")
    :onLeftClick(function()
        pings.changeMouth("model.mouth-smile", true)
    end)

local ohMouthAction = mouthPage:newAction(3)
    :setTitle("O Mouth")
    :setItem("minecraft:enchanted_golden_apple")
    :onLeftClick(function()
        pings.changeMouth("model.mouth-oh", true)
    end)

local frownMouthAction = mouthPage:newAction(4)
    :setTitle("Frown Mouth")
    :setItem("minecraft:rotten_flesh")
    :onLeftClick(function()
        pings.changeMouth("model.mouth-frown", true)
    end)

local smugMouthAction = mouthPage:newAction(5)
    :setTitle("Smug Mouth")
    :setItem("minecraft:netherite_scrap")
    :onLeftClick(function()
        pings.changeMouth("model.mouth-smug", true)
    end)

local faceOffAction = mouthPage:newAction(7)
    :setTitle("No Mouth")
    :setItem("minecraft:barrier")
    :onLeftClick(function()
        pings.changeMouth(nil, true)
    end)

-- Actions for eyes page; ascending index

-- local gazeToggleAction = eyesPage:newAction(1)
--     :setTitle("Reset Gaze")
--     :setItem("minecraft:ender_eye")
--     :setToggleItem("minecraft:barrier")
--     :onLeftClick(function()
--         pings.Gaze(false)
--     end)
--     :onRightClick(function()
--         pings.Gaze(true)
--     end)

-- "Enable Gaze" is disabled czu of some interference and the fact tha im not turning it off anyway

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

function pings.closeEyes(bool)
    if bool then
        if not eyesClosed then
            animations.model["closeEyes"]:play()
            eyesClosed = true
        end
    else
        if eyesClosed then
            animations.model["closeEyes"]:stop()
            animations.model["openEyes"]:play()
            eyesClosed = false
        end
    end
end

-- below may be unnecessary

--local closeEyesAction = eyesPage:newAction(3)
--    :setTitle("Closed Eyes")
--    :setToggleTitle("Open Eyes (enables Gaze!)")
--    :setItem("minecraft:ender_pearl")
--    :setToggleItem("minecraft:ender_eye")
--    :setOnToggle(pings.Gaze)
--    :onLeftClick(function()
--        if not eyesClosed then
--            --pings.playAnim("closeEyes")
--            --eyesClosed = true
--            pings.closeEyes(true)
--        else
--            --pings.stopAnim("closeEyes")
--            --pings.playAnim("openEyes")
--            --eyesClosed = false
--            pings.closeEyes(false)
--        end
--    end)

-- glasses!

isGlassesVisible = true

function pings.glassesVisible(i)
    models.model.root.Head.glasses:setVisible(i)
end

function glassesVisible(i)
    if i then
        isGlassesVisible = false
    else
        isGlassesVisible = true
    end
    pings.glassesVisible(isGlassesVisible)
    -- print(isGlassesVisible)
end

local glassesToggle = eyesPage:newAction(4)
    :setTitle("Toggle Glasses")
    :setToggleTitle("Toggle Glasses [Off]")
    :setItem("minecraft:glow_ink_sac")
    :setToggleItem("minecraft:ink_sac")
    :setColor(0, 1, 0)
    :setToggleColor(1, 0, 0)
    :setOnToggle(glassesVisible)

-- Actions for clothes page; ascending index

function pings.changeClothes(clothesTex, sound)
    -- log(textures[clothesTex])
    if sound then
        sounds:playSound("item.armor.equip_leather", player:getPos(), 0.5, math.random(8, 12)/10, false)
    end
    models.model.root.Head.Head:setPrimaryTexture("CUSTOM", textures[clothesTex])
    models.model.root.Head.Hat:setPrimaryTexture("CUSTOM", textures[clothesTex])
    models.model.root.Body.Body:setPrimaryTexture("CUSTOM", textures[clothesTex])
    models.model.root.Body.Jacket:setPrimaryTexture("CUSTOM", textures[clothesTex])
    models.model.root.LeftArm.LeftArm:setPrimaryTexture("CUSTOM", textures[clothesTex])
    models.model.root.LeftArm.LeftSleeve:setPrimaryTexture("CUSTOM", textures[clothesTex])
    models.model.root.RightArm.RightArm:setPrimaryTexture("CUSTOM", textures[clothesTex])
    models.model.root.RightArm.RightSleeve:setPrimaryTexture("CUSTOM", textures[clothesTex])
    models.model.root.LeftLeg.LeftLeg:setPrimaryTexture("CUSTOM", textures[clothesTex])
    models.model.root.LeftLeg.LeftPants:setPrimaryTexture("CUSTOM", textures[clothesTex])
    models.model.root.RightLeg.RightLeg:setPrimaryTexture("CUSTOM", textures[clothesTex])
    models.model.root.RightLeg.RightPants:setPrimaryTexture("CUSTOM", textures[clothesTex])
end

function pings.syncAppearance(syncClothes, syncMouth, syncMoodStr, syncArmor, syncGlasses)
    --print("Current Clothes: ", currentClothes)
    --print("Current Mouth: ", currentMouth)
    --print("Current Mood: ", currentMoodStr)
    --print("Is Armor Visible: ", isArmorVisible)
    --print("Is Glasses Visible: ", isGlassesVisible)

    --print("Sync Clothes: ", syncClothes)
    --print("Sync Mouth: ", syncMouth)
    --print("Sync Mood: ", syncMoodStr)
    --print("Sync Armor: ", syncArmor)
    --print("Sync Glasses: ", syncGlasses)

    --pings.changeClothes(currentClothes)
    --clothes section
    models.model.root.Head.Head:setPrimaryTexture("CUSTOM", textures[syncClothes])
    models.model.root.Body.Body:setPrimaryTexture("CUSTOM", textures[syncClothes])
    models.model.root.Body.Jacket:setPrimaryTexture("CUSTOM", textures[syncClothes])
    models.model.root.LeftArm.LeftArm:setPrimaryTexture("CUSTOM", textures[syncClothes])
    models.model.root.LeftArm.LeftSleeve:setPrimaryTexture("CUSTOM", textures[syncClothes])
    models.model.root.RightArm.RightArm:setPrimaryTexture("CUSTOM", textures[syncClothes])
    models.model.root.RightArm.RightSleeve:setPrimaryTexture("CUSTOM", textures[syncClothes])
    models.model.root.LeftLeg.LeftLeg:setPrimaryTexture("CUSTOM", textures[syncClothes])
    models.model.root.LeftLeg.LeftPants:setPrimaryTexture("CUSTOM", textures[syncClothes])
    models.model.root.RightLeg.RightLeg:setPrimaryTexture("CUSTOM", textures[syncClothes])
    models.model.root.RightLeg.RightPants:setPrimaryTexture("CUSTOM", textures[syncClothes])

    --pings.changeMouth(currentMouth, false)
    --mouth section
    if syncMouth == nil then
        models.model.root.Head.mouth.mouth:setVisible(false)
    else
        models.model.root.Head.mouth.mouth:setVisible(true)
        models.model.root.Head.mouth.mouth:setPrimaryTexture("CUSTOM", textures[syncMouth])
    end

    --filement mood section
    if fullHealth then
        sleeve:setSecondaryTexture("custom", textures[syncMoodStr])
    end

    --pings.armorVisible(syncArmor)
    --armor section
    vanilla_model.ARMOR:setVisible(syncArmor)
    --pings.glassesVisible(syncGlasses)
    --glasses section
    models.model.root.Head.glasses:setVisible(syncGlasses)
end

local defaultClothesAction = clothesPage:newAction(1)
    :setTitle("Default Clothes")
    :setItem("minecraft:leather_chestplate")
    :onLeftClick(function()
        currentClothes = "model.blightHand-trans"
        pings.changeClothes("model.blightHand-trans", true)
    end)

local frogFemboyClothesAction = clothesPage:newAction(2)
    :setTitle("Femboy Hoodie")
    :setItem("minecraft:white_tulip")
    :onLeftClick(function()
        currentClothes = "model.femboyHoodie"
        pings.changeClothes("model.femboyHoodie", true)
    end)

local labCoatClothesAction = clothesPage:newAction(3)
    :setTitle("Lab Coat")
    :setItem("minecraft:white_wool")
    :onLeftClick(function()
        currentClothes = "model.labCoat"
        pings.changeClothes("model.labCoat", true)
    end)

local festiveClothesAction = clothesPage:newAction(4)
    :setTitle("Baju Melayu")
    :setItem("minecraft:green_wool")
    :onLeftClick(function()
        currentClothes = "model.bajuRaya"
        pings.changeClothes("model.bajuRaya", true)
    end)

local agnesTachyonClothesAction = clothesPage:newAction(5)
    :setTitle("Agnes Tachyon Cosplay")
    :setItem("minecraft:orange_wool")
    :onLeftClick(function()
        currentClothes = "model.agnesTachyon"
        pings.changeClothes("model.agnesTachyon", true)
    end)

local sholmesClothesAction = clothesPage:newAction(6)
    :setTitle("Herlock Sholmes Cosplay")
    :setItem("minecraft:brown_wool")
    :onLeftClick(function()
        currentClothes = "model.sholmes"
        pings.changeClothes("model.sholmes", true)
    end)

-- Animations on specific tasks. Write in entity_init.

function events.render()
end