display.setStatusBar(display.HiddenStatusBar)

---------------------------------------------------------------------------------------
-- VARIABLES BASE
---------------------------------------------------------------------------------------
local CX, CY = display.contentCenterX, display.contentCenterY
local W, H   = display.contentWidth, display.contentHeight
math.randomseed(os.time())

local minSide = math.min(W, H)
local SAFE_MARGIN = math.floor(minSide * 0.06)
local birdSize  = math.floor(minSide * 0.22)
local appleSize = math.floor(minSide * 0.16)
local HIT_PAD = math.floor(minSide * 0.02)

local score = 0
local appleBusy = false

-- TEMPORIZADOR Y VELOCIDAD
local timeLeft = 60 
local gameActive = true
local appleSpeed = 6 -- ¡Subimos la velocidad aquí!

---------------------------------------------------------------------------------------
-- FONDO Y TEXTOS
---------------------------------------------------------------------------------------
local fondo = display.newImageRect("bosque.jpg", W, H)
fondo.x, fondo.y = CX, CY

local scoreTxt = display.newText({
    text = "Manzanas: 0",
    x = SAFE_MARGIN,
    y = SAFE_MARGIN,
    font = native.systemFontBold,
    fontSize = math.floor(minSide * 0.05)
})
scoreTxt.anchorX, scoreTxt.anchorY = 0, 0

local timerTxt = display.newText({
    text = "Tiempo: 60",
    x = W - SAFE_MARGIN,
    y = SAFE_MARGIN,
    font = native.systemFontBold,
    fontSize = math.floor(minSide * 0.05)
})
timerTxt.anchorX, timerTxt.anchorY = 1, 0

---------------------------------------------------------------------------------------
-- FUNCIONES LÓGICAS
---------------------------------------------------------------------------------------
local function updateScore()
    scoreTxt.text = "Manzanas: " .. score
end

local function updateTimer()
    if gameActive then
        timeLeft = timeLeft - 1
        timerTxt.text = "Tiempo: " .. timeLeft
        if timeLeft <= 0 then
            gameActive = false
            timerTxt.text = "¡FIN!"
            timerTxt:setFillColor(1, 0, 0)
        end
    end
end
timer.performWithDelay(1000, updateTimer, 0)

---------------------------------------------------------------------------------------
-- PERSONAJES Y ANIMACIÓN
---------------------------------------------------------------------------------------
local apple = display.newImageRect("apple.png", appleSize, appleSize)

local function randomApplePosition()
    apple.x = math.random(SAFE_MARGIN, W - SAFE_MARGIN)
    apple.y = -appleSize
end

local birdGroup = display.newGroup()
birdGroup.x, birdGroup.y = CX, CY
local birdA = display.newImageRect(birdGroup, "parrot-a.png", birdSize, birdSize)
local birdB = display.newImageRect(birdGroup, "parrot-b.png", birdSize, birdSize)
birdB.alpha = 0

-- RECUPERAMOS LA ANIMACIÓN DEL ALETEO
local flapState = false
timer.performWithDelay(160, function()
    if gameActive then
        flapState = not flapState
        if flapState then
            birdA.alpha, birdB.alpha = 1, 0
        else
            birdA.alpha, birdB.alpha = 0, 1
        end
    end
end, 0)

local biteSound = audio.loadSound("Bite.mp3")

---------------------------------------------------------------------------------------
-- COLISIÓN Y MOVIMIENTO
---------------------------------------------------------------------------------------
local function hit(a, b)
    local A, B = a.contentBounds, b.contentBounds
    return not (
        (A.xMax + HIT_PAD) < (B.xMin - HIT_PAD) or
        (A.xMin - HIT_PAD) > (B.xMax + HIT_PAD) or
        (A.yMax + HIT_PAD) < (B.yMin - HIT_PAD) or
        (A.yMin - HIT_PAD) > (B.yMax + HIT_PAD)
    )
end

local function biteApple()
    if appleBusy or not gameActive then return end
    appleBusy = true
    score = score + 1
    updateScore()
    if biteSound then audio.play(biteSound) end
    apple.fill = { type="image", filename="apple2.png" }
    
    timer.performWithDelay(500, function()
        apple.fill = { type="image", filename="apple.png" }
        randomApplePosition()
        appleBusy = false
    end)
end

local targetX, targetY = CX, CY
Runtime:addEventListener("tap", function(e)
    if gameActive then targetX, targetY = e.x, e.y end
end)

Runtime:addEventListener("enterFrame", function()
    if not gameActive then return end

    -- Glide (Movimiento suave)
    birdGroup.x = birdGroup.x + (targetX - birdGroup.x) * 0.12
    birdGroup.y = birdGroup.y + (targetY - birdGroup.y) * 0.12

    -- Caída de manzana
    if apple and not appleBusy then
        apple.y = apple.y + appleSpeed -- Ahora cae con appleSpeed
        if apple.y > H + appleSize then randomApplePosition() end
        if hit(birdGroup, apple) then biteApple() end
    end
end)

randomApplePosition()
