display.setStatusBar(display.HiddenStatusBar)

---------------------------------------------------------------------------------------
-- 1. VARIABLES BASE Y RÉCORD
---------------------------------------------------------------------------------------
local CX, CY = display.contentCenterX, display.contentCenterY
local W, H   = display.contentWidth, display.contentHeight
math.randomseed(os.time())

local minSide = math.min(W, H)
local SAFE_MARGIN = math.floor(minSide * 0.08)
local birdSize = math.floor(minSide * 0.18)
local initialAppleSize = math.floor(minSide * 0.14)
local appleSize = initialAppleSize
local HIT_PAD = math.floor(minSide * 0.04) 

-- Lógica de Juego
local score = 0
local highScore = 0
local lives = 3
local timeLeft = 60
local comboCount = 0
local appleSpeed = 4
local appleBusy = false
local gameActive = true

---------------------------------------------------------------------------------------
-- 2. ELEMENTOS VISUALES
---------------------------------------------------------------------------------------
local fondo = display.newImageRect("bosque.jpg", W, H)
fondo.x, fondo.y = CX, CY

local scoreTxt = display.newText("Manzanas: 0", SAFE_MARGIN, SAFE_MARGIN, native.systemFontBold, 20)
scoreTxt.anchorX = 0
local highTxt = display.newText("Récord: 0", W - SAFE_MARGIN, SAFE_MARGIN, native.systemFont, 16)
highTxt.anchorX = 1
local livesTxt = display.newText("Vidas: 3", CX, SAFE_MARGIN, native.systemFontBold, 20)
local timerTxt = display.newText("Tiempo: 60", CX, SAFE_MARGIN + 30, native.systemFont, 18)

local apple = display.newImageRect("apple.png", appleSize, appleSize)
local birdGroup = display.newGroup()
birdGroup.x, birdGroup.y = CX, CY
local birdA = display.newImageRect(birdGroup, "parrot-a.png", birdSize, birdSize)
local birdB = display.newImageRect(birdGroup, "parrot-b.png", birdSize, birdSize)
birdB.alpha = 0

-- Botón Reiniciar (oculto al inicio)
local btnRestart = display.newGroup()
local rectBtn = display.newRoundedRect(btnRestart, CX, CY + 100, 150, 50, 10)
rectBtn:setFillColor(0.2, 0.6, 0.2)
local txtBtn = display.newText(btnRestart, "REINICIAR", CX, CY + 100, native.systemFontBold, 18)
btnRestart.isVisible = false

-- Audio
local biteSound = audio.loadSound("Bite.mp3")
local comboSound = audio.loadSound("Combo.mp3") -- Asegúrate de tener este archivo o usa el mismo

---------------------------------------------------------------------------------------
-- 3. FUNCIONES DE LÓGICA
---------------------------------------------------------------------------------------

local function randomApplePosition()
    if apple then
        apple.x = math.random(SAFE_MARGIN, W - SAFE_MARGIN)
        apple.y = -appleSize
        apple.width, apple.height = appleSize, appleSize -- Actualiza tamaño
    end
end

local function updateUI()
    scoreTxt.text = "Manzanas: " .. score
    livesTxt.text = "Vidas: " .. lives
    timerTxt.text = "Tiempo: " .. timeLeft
    highTxt.text = "Récord: " .. highScore
end

local function gameOver()
    gameActive = false
    btnRestart.isVisible = true
    if score > highScore then highScore = score end
    updateUI()
end

local function biteApple()
    if appleBusy or not gameActive then return end
    appleBusy = true
    
    score = score + 1
    comboCount = comboCount + 1

    -- Combo cada 3 aciertos
    if comboCount >= 3 then
        audio.play(comboSound)
        score = score + 2 -- Bono de puntos
        comboCount = 0
    else
        audio.play(biteSound)
    end

    -- Reducir tamaño cada 5 puntos
    if score % 5 == 0 and appleSize > 20 then
        appleSize = appleSize - 5
    end

    apple.fill = { type="image", filename="apple2.png" }
    timer.performWithDelay(300, function()
        apple.fill = { type="image", filename="apple.png" }
        randomApplePosition()
        appleBusy = false
    end)
    updateUI()
end

local function loseLife()
    lives = lives - 1
    comboCount = 0 -- Rompe el combo
    updateUI()
    if lives <= 0 then gameOver() end
    randomApplePosition()
end

---------------------------------------------------------------------------------------
-- 4. CONTROLES Y TEMPORIZADOR
---------------------------------------------------------------------------------------

local targetX, targetY = CX, CY

local function resetGame()
    score = 0
    lives = 3
    timeLeft = 60
    appleSize = initialAppleSize
    comboCount = 0
    gameActive = true
    btnRestart.isVisible = false
    randomApplePosition()
    updateUI()
end

btnRestart:addEventListener("tap", resetGame)

-- Temporizador
timer.performWithDelay(1000, function()
    if gameActive then
        timeLeft = timeLeft - 1
        updateUI()
        if timeLeft <= 0 then gameOver() end
    end
end, 0)

Runtime:addEventListener("tap", function(e)
    targetX, targetY = e.x, e.y
end)

---------------------------------------------------------------------------------------
-- 5. LOOP PRINCIPAL (GLIDE Y HIT_PAD)
---------------------------------------------------------------------------------------

local function hit(a, b)
    local A, B = a.contentBounds, b.contentBounds
    -- HIT_PAD aumenta el área de colisión para que sea más fácil atraparla en tablets
    return not (
        (A.xMax + HIT_PAD) < (B.xMin - HIT_PAD) or
        (A.xMin - HIT_PAD) > (B.xMax + HIT_PAD) or
        (A.yMax + HIT_PAD) < (B.yMin - HIT_PAD) or
        (A.yMin - HIT_PAD) > (B.yMax + HIT_PAD)
    )
end

Runtime:addEventListener("enterFrame", function()
    if not gameActive then return end

    -- GLIDE: El personaje no salta, se desliza suavemente hacia el objetivo
    birdGroup.x = birdGroup.x + (targetX - birdGroup.x) * 0.12
    birdGroup.y = birdGroup.y + (targetY - birdGroup.y) * 0.12

    if apple and not appleBusy then
        apple.y = apple.y + appleSpeed
        if apple.y > H + appleSize then loseLife() end
        if hit(birdGroup, apple) then biteApple() end
    end
end)

randomApplePosition()
