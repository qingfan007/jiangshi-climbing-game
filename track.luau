local Constants = require("GameConstants")
local LimbLogic = require("LimbLogic")
local BodyLogic = require("BodyLogic")
local FreezeLogic = require("FreezeLogic")
local InteractionLogic = require("InteractionLogic")
local RouteLogic = require("RouteLogic")
local CameraLogic = require("CameraLogic")
local RestartLogic = require("RestartLogic")


------------------------------------------------------------
-- DYNO VISUAL TUNING
--
-- InteractionLogic decides WHETHER a move is a Dyno.
--
-- Track only controls how that Dyno FEELS visually.
------------------------------------------------------------

local DEBUG_ENDING_SHORTCUT = true -- DEBUG BUILD ONLY: click 0..35,0..35 to test the ending without re-climbing.

local DYNO_CROUCH_DURATION =
    0.08

local DYNO_LAUNCH_DURATION =
    0.18

local DYNO_CROUCH_OFFSET_Y =
    10

local DYNO_BODY_TRAVEL =
    48


type Track = {

    size: Vector,

    prologueHeadY: Property<number>?,
    prologueHeadRotation: Property<number>?,

    prologueTimer: number?,

    prologueLeftX: Property<number>?,
    prologueRightX: Property<number>?,
    prologueTextY: Property<number>?,

    cliffY: Property<number>?,

    talismanX: Property<number>?,
    talismanY: Property<number>?,

    headX: Property<number>?,
    headY: Property<number>?,

    selectionHaloX: Property<number>?,
    selectionHaloY: Property<number>?,

    selectedMarkerX: Property<number>?,
    selectedMarkerY: Property<number>?,

    holdHoverX: Property<number>?,
    holdHoverY: Property<number>?,

    confirmHaloX: Property<number>?,
    confirmHaloY: Property<number>?,


    freezeDot3X: Property<number>?,
    freezeDot3Y: Property<number>?,

    freezeDot2X: Property<number>?,
    freezeDot2Y: Property<number>?,

    freezeDot1X: Property<number>?,
    freezeDot1Y: Property<number>?,


    la0x: Property<number>?,
    la0y: Property<number>?,

    la1x: Property<number>?,
    la1y: Property<number>?,

    la2x: Property<number>?,
    la2y: Property<number>?,

    la3x: Property<number>?,
    la3y: Property<number>?,

    la4x: Property<number>?,
    la4y: Property<number>?,

    leftArmVisualX: Property<number>?,
    leftArmVisualY: Property<number>?,
    leftArmVisualRotation: Property<number>?,
    leftArmVisualScaleX: Property<number>?,

    ra0x: Property<number>?,
    ra0y: Property<number>?,

    ra1x: Property<number>?,
    ra1y: Property<number>?,

    ra2x: Property<number>?,
    ra2y: Property<number>?,

    ra3x: Property<number>?,
    ra3y: Property<number>?,

    ra4x: Property<number>?,
    ra4y: Property<number>?,

    rightArmVisualX: Property<number>?,
    rightArmVisualY: Property<number>?,
    rightArmVisualRotation: Property<number>?,
    rightArmVisualScaleX: Property<number>?,

    ll0x: Property<number>?,
    ll0y: Property<number>?,

    ll1x: Property<number>?,
    ll1y: Property<number>?,

    ll2x: Property<number>?,
    ll2y: Property<number>?,

    ll3x: Property<number>?,
    ll3y: Property<number>?,

    ll4x: Property<number>?,
    ll4y: Property<number>?,

    leftLegVisualX: Property<number>?,
    leftLegVisualY: Property<number>?,
    leftLegVisualRotation: Property<number>?,
    leftLegVisualScaleX: Property<number>?,
    leftLegVisualScaleY: Property<number>?,

    leftShoeVisualX: Property<number>?,
    leftShoeVisualY: Property<number>?,
    leftShoeVisualRotation: Property<number>?,
    leftShoeVisualScale: Property<number>?,

    rightShoeVisualX: Property<number>?,
    rightShoeVisualY: Property<number>?,
    rightShoeVisualRotation: Property<number>?,
    rightShoeVisualScale: Property<number>?,

    rl0x: Property<number>?,
    rl0y: Property<number>?,

    rl1x: Property<number>?,
    rl1y: Property<number>?,

    rl2x: Property<number>?,
    rl2y: Property<number>?,

    rl3x: Property<number>?,
    rl3y: Property<number>?,

    rl4x: Property<number>?,
    rl4y: Property<number>?,

    rightLegVisualX: Property<number>?,
    rightLegVisualY: Property<number>?,
    rightLegVisualRotation: Property<number>?,
    rightLegVisualScaleX: Property<number>?,
    rightLegVisualScaleY: Property<number>?,

    x: number,
    y: number,

    targetX: number,
    targetY: number,


    bodyPositionX: number,
    bodyPositionY: number,

    bodyTargetX: number,
    bodyTargetY: number,

    needsBodyTargetUpdate: boolean,


    leftHandX: number,
    leftHandY: number,

    rightHandX: number,
    rightHandY: number,

    leftFootX: number,
    leftFootY: number,

    rightFootX: number,
    rightFootY: number,


    moveTargetX: number,
    moveTargetY: number,

    movingPart: string,

    isMoving: boolean,

    isDyno: boolean,


    --------------------------------------------------------
    -- DYNO VISUAL STATE
    --------------------------------------------------------

    dynoPhase: string,

    dynoTimer: number,

    dynoStartBodyX: number,
    dynoStartBodyY: number,

    dynoJumpBodyX: number,
    dynoJumpBodyY: number,


    --------------------------------------------------------
    -- HOVER / INTERACTION
    --------------------------------------------------------

    hoveredPart: string,

    hoverTargetType: string,

    hoveredHoldId: number,


    selectedPart: string,

    confirmTimer: number,


    isFrozen: boolean,

    freezeTimer: number,


    --------------------------------------------------------
    -- CAMERA
    --------------------------------------------------------

    cameraY: number,


    --------------------------------------------------------
    -- ROUTE
    --------------------------------------------------------

    currentRoute: any,
    currentRouteIndex: number,

    holdSlotX: { Property<number>? },
    holdSlotY: { Property<number>? },

    targetHoldId: number,

    targetHoldKind: string,


    --------------------------------------------------------
    -- SUPPORT STATE
    --------------------------------------------------------

    leftHandHoldId: number,
    rightHandHoldId: number,
    leftFootHoldId: number,
    rightFootHoldId: number,


    caveEffectX: Property<number>?,
    caveDebrisY: Property<number>?,
    caveMouthY: Property<number>?,
    caveCrackY: Property<number>?,
    cinematicRigX: Property<number>?,
    cinematicRigY: Property<number>?,

    exteriorCameraX: Property<number>?,
    exteriorCameraY: Property<number>?,
    exteriorCameraScale: Property<number>?,
    caveRoomX: Property<number>?,
    caveRoomScale: Property<number>?,
    caveLipX: Property<number>?,
    caveLipY: Property<number>?,
    caveLipScale: Property<number>?,
    caveApertureScale: Property<number>?,
    caveFractureScale: Property<number>?,
    cinematicRigScale: Property<number>?,
    cinematicRigRotation: Property<number>?,
    caveLidX: Property<number>?,
    caveLidScale: Property<number>?,
    dawnGlowX: Property<number>?,
    dawnGlowY: Property<number>?,
    dawnGlowScale: Property<number>?,
    dawnCoreX: Property<number>?,
    dawnCoreY: Property<number>?,
    dawnCoreScale: Property<number>?,
    endingResetX0: Property<number>?,
    endingResetX1: Property<number>?,
    endingResetX2: Property<number>?,
    endingResetX3: Property<number>?,
    endingResetX4: Property<number>?,
    endingLogoScale: Property<number>?,
    caveDustX: Property<number>?,
    caveDustScale: Property<number>?,
    caveMouthX: Property<number>?,
    caveSillX: Property<number>?,
    caveSillY: Property<number>?,
    caveSillScale: Property<number>?,
    caveWipeY: Property<number>?,
    caveWipeScale: Property<number>?,
    caveFgX: Property<number>?,
    caveFgY: Property<number>?,
    fallRock1X: Property<number>?,
    fallRock1Y: Property<number>?,
    fallRock1Rotation: Property<number>?,
    fallRock2X: Property<number>?,
    fallRock2Y: Property<number>?,
    fallRock2Rotation: Property<number>?,
    fallRock3X: Property<number>?,
    fallRock3Y: Property<number>?,
    fallRock3Rotation: Property<number>?,
    endingOriginX: number,
    endingOriginY: number,
    endingOriginLHx: number,
    endingOriginLHy: number,
    endingOriginRHx: number,
    endingOriginRHy: number,
    endingOriginLFx: number,
    endingOriginLFy: number,
    endingOriginRFx: number,
    endingOriginRFy: number,
    gameWon: boolean,
    endingPhase: number,
    endingTimer: number,
    endingOverlayY: Property<number>?,
    endingDoorLeftX: Property<number>?,
    endingDoorRightX: Property<number>?,
    endingRoomY: Property<number>?,
    endingCoffinY: Property<number>?,
    endingDawnY: Property<number>?,
    endingSafeY: Property<number>?,
    endingJiangshiY: Property<number>?,
    endingCoffinLidY: Property<number>?,
    endingJiangshiX: Property<number>?,
    endingJiangshiScale: Property<number>?,
    endingJiangshiRotation: Property<number>?,
    endingLidRotation: Property<number>?,
    endingCrackY: Property<number>?,

}


------------------------------------------------------------
-- HELPERS
------------------------------------------------------------

local function setNumber(
    property: Property<number>?,
    value: number
)

    if property ~= nil then
        property.value = value
    end

end


local function clamp(
    value: number,
    minimum: number,
    maximum: number
): number

    if value < minimum then
        return minimum
    end


    if value > maximum then
        return maximum
    end


    return value

end


local function lerp(
    a: number,
    b: number,
    t: number
): number

    return
        a
        + (
            b - a
        ) * t

end


------------------------------------------------------------
-- START DYNO VISUAL
------------------------------------------------------------

local function startDynoVisual(
    self: Track
)

    self.dynoPhase =
        "crouch"


    self.dynoTimer =
        0


    self.dynoStartBodyX =
        self.bodyPositionX

    self.dynoStartBodyY =
        self.bodyPositionY


    --------------------------------------------------------
    -- BODY JUMPS TOWARD THE TARGET HOLD
    --------------------------------------------------------

    local dx =
        self.moveTargetX
        - self.bodyPositionX

    local dy =
        self.moveTargetY
        - self.bodyPositionY


    local length =
        math.sqrt(
            dx * dx
            + dy * dy
        )


    if length > 0.001 then

        self.dynoJumpBodyX =
            self.bodyPositionX
            + (
                dx / length
            ) * DYNO_BODY_TRAVEL


        self.dynoJumpBodyY =
            self.bodyPositionY
            + (
                dy / length
            ) * DYNO_BODY_TRAVEL

    else

        self.dynoJumpBodyX =
            self.bodyPositionX


        self.dynoJumpBodyY =
            self.bodyPositionY
            - DYNO_BODY_TRAVEL

    end

end


------------------------------------------------------------
-- UPDATE DYNO BODY
--
-- Returns true while Dyno owns body movement.
------------------------------------------------------------

local function advanceDynoVisual(
    self: Track,
    seconds: number
): boolean

    if self.dynoPhase == "" then
        return false
    end


    --------------------------------------------------------
    -- CROUCH
    --------------------------------------------------------

    if self.dynoPhase == "crouch" then

        self.dynoTimer =
            self.dynoTimer
            + seconds


        local t =
            clamp(
                self.dynoTimer
                    / DYNO_CROUCH_DURATION,
                0,
                1
            )


        ----------------------------------------------------
        -- Body drops slightly before launch.
        ----------------------------------------------------

        self.bodyPositionX =
            self.dynoStartBodyX


        self.bodyPositionY =
            lerp(
                self.dynoStartBodyY,
                self.dynoStartBodyY
                    + DYNO_CROUCH_OFFSET_Y,
                t
            )


        BodyLogic.updateVisuals(
            self
        )


        if t >= 1 then

            self.dynoPhase =
                "launch"


            self.dynoTimer =
                0

        end


        return true

    end


    --------------------------------------------------------
    -- LAUNCH
    --------------------------------------------------------

    if self.dynoPhase == "launch" then

        self.dynoTimer =
            self.dynoTimer
            + seconds


        local t =
            clamp(
                self.dynoTimer
                    / DYNO_LAUNCH_DURATION,
                0,
                1
            )


        ----------------------------------------------------
        -- Ease-out:
        -- fast launch, softer finish.
        ----------------------------------------------------

        local inverse =
            1 - t


        local eased =
            1
            - inverse
                * inverse
                * inverse


        self.bodyPositionX =
            lerp(
                self.dynoStartBodyX,
                self.dynoJumpBodyX,
                eased
            )


        self.bodyPositionY =
            lerp(
                self.dynoStartBodyY
                    + DYNO_CROUCH_OFFSET_Y,
                self.dynoJumpBodyY,
                eased
            )


        BodyLogic.updateVisuals(
            self
        )


        if t >= 1 then

            self.dynoPhase =
                "hold"


            self.dynoTimer =
                0

        end


        return true

    end


    --------------------------------------------------------
    -- HOLD JUMP POSITION UNTIL HAND FINISHES MOVING
    --------------------------------------------------------

    if self.dynoPhase == "hold" then

        self.bodyPositionX =
            self.dynoJumpBodyX


        self.bodyPositionY =
            self.dynoJumpBodyY


        BodyLogic.updateVisuals(
            self
        )


        ----------------------------------------------------
        -- LimbLogic turns isMoving false when the hand
        -- actually reaches the Dyno hold.
        ----------------------------------------------------

        if not self.isMoving then

            self.dynoPhase =
                ""


            self.dynoTimer =
                0

        end


        return true

    end


    --------------------------------------------------------
    -- SAFETY
    --------------------------------------------------------

    self.dynoPhase =
        ""

    self.dynoTimer =
        0


    return false

end


------------------------------------------------------------
-- POINTER
------------------------------------------------------------

function pointerMove(
    self: Track,
    event: PointerEvent
)

    self.targetX =
        event.position.x

    self.targetY =
        event.position.y

end


function pointerDown(
    self: Track,
    event: PointerEvent
)
    -- No player input during prologue
    if (self.prologueTimer or 0) < 4.8 then
        return
    end

    --------------------------------------------------------
    -- RAW MOUSE POSITION
    --
    -- ONLY fixed-screen UI uses raw pointer coordinates.
    --------------------------------------------------------

    local pointerX =
        event.position.x

    local pointerY =
        event.position.y


    -- Development convenience: explicitly opt in with --debug when installing.
    -- Production has this disabled; normal climbing is unchanged.
    if DEBUG_ENDING_SHORTCUT and pointerX < 36 and pointerY < 36 and not self.gameWon then
        self.cameraY = 485
        self.bodyPositionX, self.bodyPositionY = 250, 305
        self.leftHandX, self.leftHandY = 250, 225
        self.rightHandX, self.rightHandY = 320, 284
        self.leftFootX, self.leftFootY = 220, 404
        self.rightFootX, self.rightFootY = 284, 415
        self.leftHandHoldId, self.rightHandHoldId = 0,0
        self.leftFootHoldId, self.rightFootHoldId = 0,0
        self.isMoving = false
        self.gameWon = true
        self.endingPhase = 0
        return
    end

    --------------------------------------------------------
    -- RETRY BUTTON
    --------------------------------------------------------

    if RestartLogic.hitTest(
        pointerX,
        pointerY
    ) then

        RestartLogic.restart(
            self
        )
        self.endingPhase = 0
        self.endingTimer = 0
        setNumber(self.cinematicRigX,0)
        setNumber(self.cinematicRigY,0)
        setNumber(self.cinematicRigScale,1)
        setNumber(self.cinematicRigRotation,0)
        setNumber(self.exteriorCameraX,0)
        setNumber(self.exteriorCameraY,0)
        setNumber(self.exteriorCameraScale,1)
        -- Clear every cinematic layer before resuming the SAME route.
        local off = -1200
        setNumber(self.caveCrackY,off)
        setNumber(self.caveWipeY,off)
        setNumber(self.caveWipeScale,0.01)
        setNumber(self.caveFgX,off)
        setNumber(self.caveFgY,off)
        setNumber(self.fallRock1X,off)
        setNumber(self.fallRock1Y,off)
        setNumber(self.fallRock2X,off)
        setNumber(self.fallRock2Y,off)
        setNumber(self.fallRock3X,off)
        setNumber(self.fallRock3Y,off)
        setNumber(self.caveMouthY,off)
        -- Restart has no local ending phase or cave coordinates.
        -- Reset these layers unconditionally before normal climbing resumes.
        setNumber(self.caveSillX,off)
        setNumber(self.caveSillY,off)
        setNumber(self.caveSillScale,0.01)
        setNumber(self.caveDebrisY,off)
        setNumber(self.endingCrackY,off)
        setNumber(self.endingOverlayY,off)
        setNumber(self.endingRoomY,off)
        setNumber(self.caveRoomX,off)
        setNumber(self.caveRoomScale,0.01)
        setNumber(self.caveLipX,off)
        setNumber(self.caveLipY,off)
        setNumber(self.caveLipScale,0.01)
        setNumber(self.caveLidX,off)
        setNumber(self.endingCoffinLidY,off)
        setNumber(self.caveLidScale,0.01)
        setNumber(self.dawnGlowX,off)
        setNumber(self.dawnGlowY,off)
        setNumber(self.dawnCoreX,off)
        setNumber(self.dawnCoreY,off)
        setNumber(self.endingSafeY,off)
        setNumber(self.endingDawnY,off)
        setNumber(self.cliffY,1050-self.cameraY)

        ----------------------------------------------------
        -- Clear cached hover action after reset.
        ----------------------------------------------------

        self.hoverTargetType = ""
        self.hoveredPart = ""
        self.hoveredHoldId = 0


        ----------------------------------------------------
        -- Clear Dyno visual state after reset.
        ----------------------------------------------------

        self.dynoPhase = ""
        self.dynoTimer = 0


        return

    end


    --------------------------------------------------------
    -- LOCKED STATE
    --------------------------------------------------------

    if self.gameWon then
        return
    end


    if self.isFrozen then
        return
    end


    if self.isMoving then
        return
    end


    --------------------------------------------------------
    -- IMPORTANT
    --
    -- DO NOT perform Body / Hold hit testing here.
    --
    -- Hover has already decided what the player is
    -- currently looking at.
    --
    -- What you SEE is what you CLICK.
    --------------------------------------------------------


    --------------------------------------------------------
    -- BODY ACTION
    --------------------------------------------------------

    if self.hoverTargetType == "body" then

        local clickedPart: string =
            InteractionLogic.activateHoveredBody(
                self
            )


        ----------------------------------------------------
        -- HEAD = FREEZE
        ----------------------------------------------------

        if clickedPart == "head" then

            self.selectedPart = ""


            InteractionLogic.hideSelectedMarker(
                self
            )


            FreezeLogic.start(
                self
            )


            InteractionLogic.clearHoverTarget(
                self
            )

        end


        return

    end


    --------------------------------------------------------
    -- HOLD ACTION
    --------------------------------------------------------

    if self.hoverTargetType == "hold" then

        InteractionLogic.activateHoveredHold(
            self
        )


        return

    end


    --------------------------------------------------------
    -- NO VISIBLE ACTION TARGET
    --
    -- No circle = click does nothing.
    --------------------------------------------------------

    return

end


------------------------------------------------------------
-- INIT
------------------------------------------------------------

function init(
    self: Track,
    context: Context
): boolean

    local vm =
        context:viewModel()


    if vm == nil then
        return true
    end

    --------------------------------------------------------
    -- PROLOGUE INITIAL STATE
    --------------------------------------------------------

    self.prologueHeadY = vm:getNumber("prologueHeadY")
    self.prologueHeadRotation = vm:getNumber("prologueHeadRotation")

    setNumber(self.prologueHeadY, 85)
    setNumber(self.prologueHeadRotation, 0)

    self.prologueTimer = 0

    self.prologueLeftX = vm:getNumber("prologueLeftX")
    self.prologueRightX = vm:getNumber("prologueRightX")
    self.prologueTextY = vm:getNumber("prologueTextY")

    setNumber(self.prologueLeftX, 125)
    setNumber(self.prologueRightX, 375)
    setNumber(self.prologueTextY, 250)


    --------------------------------------------------------
    -- CORE VM
    --------------------------------------------------------

    self.talismanX =
        vm:getNumber("talismanX")

    self.talismanY =
        vm:getNumber("talismanY")


    self.headX =
        vm:getNumber("headX")

    self.headY =
        vm:getNumber("headY")
    
    self.cliffY =
        vm:getNumber("cliffY")

    self.endingOverlayY = vm:getNumber("endingOverlayY")
    self.endingDoorLeftX = vm:getNumber("endingDoorLeftX")
    self.endingDoorRightX = vm:getNumber("endingDoorRightX")
    self.endingRoomY = vm:getNumber("endingRoomY")
    self.endingCoffinY = vm:getNumber("endingCoffinY")
    self.endingDawnY = vm:getNumber("endingDawnY")
    self.endingSafeY = vm:getNumber("endingSafeY")
    self.endingJiangshiY = vm:getNumber("endingJiangshiY")
    self.endingCoffinLidY = vm:getNumber("endingCoffinLidY")
    self.endingJiangshiX = vm:getNumber("endingJiangshiX")
    self.endingJiangshiScale = vm:getNumber("endingJiangshiScale")
    self.endingJiangshiRotation = vm:getNumber("endingJiangshiRotation")
    self.endingLidRotation = vm:getNumber("endingLidRotation")
    self.endingCrackY = vm:getNumber("endingCrackY")
    self.caveEffectX = vm:getNumber("caveEffectX")
    self.caveDebrisY = vm:getNumber("caveDebrisY")
    self.caveMouthY = vm:getNumber("caveMouthY")
    self.caveCrackY = vm:getNumber("caveCrackY")
    self.cinematicRigX = vm:getNumber("cinematicRigX")
    self.cinematicRigY = vm:getNumber("cinematicRigY")
    -- Cinematic-only bindings.  Climbing ViewModel fields are untouched.
    self.caveWipeY = vm:getNumber("caveWipeY")
    self.caveWipeScale = vm:getNumber("caveWipeScale")
    self.caveFgX = vm:getNumber("caveFgX")
    self.caveFgY = vm:getNumber("caveFgY")
    self.fallRock1X = vm:getNumber("fallRock1X")
    self.fallRock1Y = vm:getNumber("fallRock1Y")
    self.fallRock1Rotation = vm:getNumber("fallRock1Rotation")
    self.fallRock2X = vm:getNumber("fallRock2X")
    self.fallRock2Y = vm:getNumber("fallRock2Y")
    self.fallRock2Rotation = vm:getNumber("fallRock2Rotation")
    self.fallRock3X = vm:getNumber("fallRock3X")
    self.fallRock3Y = vm:getNumber("fallRock3Y")
    self.fallRock3Rotation = vm:getNumber("fallRock3Rotation")

    self.exteriorCameraX = vm:getNumber("exteriorCameraX")
    self.exteriorCameraY = vm:getNumber("exteriorCameraY")
    self.exteriorCameraScale = vm:getNumber("exteriorCameraScale")
    self.caveRoomX = vm:getNumber("caveRoomX")
    self.caveRoomScale = vm:getNumber("caveRoomScale")
    self.caveLipX = vm:getNumber("caveLipX")
    self.caveLipY = vm:getNumber("caveLipY")
    self.caveLipScale = vm:getNumber("caveLipScale")
    self.caveApertureScale = vm:getNumber("caveApertureScale")
    self.caveFractureScale = vm:getNumber("caveFractureScale")
    self.cinematicRigScale = vm:getNumber("cinematicRigScale")
    self.caveLidX = vm:getNumber("caveLidX")
    self.caveLidScale = vm:getNumber("caveLidScale")
    self.dawnGlowX = vm:getNumber("dawnGlowX")
    self.dawnGlowY = vm:getNumber("dawnGlowY")
    self.dawnGlowScale = vm:getNumber("dawnGlowScale")
    self.dawnCoreX = vm:getNumber("dawnCoreX")
    self.dawnCoreY = vm:getNumber("dawnCoreY")
    self.dawnCoreScale = vm:getNumber("dawnCoreScale")
    self.endingResetX0 = vm:getNumber("endingResetX0")
    self.endingResetX1 = vm:getNumber("endingResetX1")
    self.endingResetX2 = vm:getNumber("endingResetX2")
    self.endingResetX3 = vm:getNumber("endingResetX3")
    self.endingResetX4 = vm:getNumber("endingResetX4")
    self.endingLogoScale = vm:getNumber("endingLogoScale")
    self.cinematicRigRotation = vm:getNumber("cinematicRigRotation")
    self.caveDustX = vm:getNumber("caveDustX")
    self.caveDustScale = vm:getNumber("caveDustScale")
    self.caveMouthX = vm:getNumber("caveMouthX")
    self.caveSillX = vm:getNumber("caveSillX")
    self.caveSillY = vm:getNumber("caveSillY")
    self.caveSillScale = vm:getNumber("caveSillScale")



    self.selectionHaloX =
        vm:getNumber("selectionHaloX")

    self.selectionHaloY =
        vm:getNumber("selectionHaloY")


    self.selectedMarkerX =
        vm:getNumber("selectedMarkerX")

    self.selectedMarkerY =
        vm:getNumber("selectedMarkerY")


    self.holdHoverX =
        vm:getNumber("holdHoverX")

    self.holdHoverY =
        vm:getNumber("holdHoverY")


    self.confirmHaloX =
        vm:getNumber("confirmHaloX")

    self.confirmHaloY =
        vm:getNumber("confirmHaloY")


    --------------------------------------------------------
    -- FREEZE
    --------------------------------------------------------

    self.freezeDot3X =
        vm:getNumber("freezeDot3X")

    self.freezeDot3Y =
        vm:getNumber("freezeDot3Y")


    self.freezeDot2X =
        vm:getNumber("freezeDot2X")

    self.freezeDot2Y =
        vm:getNumber("freezeDot2Y")


    self.freezeDot1X =
        vm:getNumber("freezeDot1X")

    self.freezeDot1Y =
        vm:getNumber("freezeDot1Y")


    --------------------------------------------------------
    -- LEFT ARM
    --------------------------------------------------------

    self.la0x = vm:getNumber("la0x")
    self.la0y = vm:getNumber("la0y")
    self.la1x = vm:getNumber("la1x")
    self.la1y = vm:getNumber("la1y")
    self.la2x = vm:getNumber("la2x")
    self.la2y = vm:getNumber("la2y")
    self.la3x = vm:getNumber("la3x")
    self.la3y = vm:getNumber("la3y")
    self.la4x = vm:getNumber("la4x")
    self.la4y = vm:getNumber("la4y")

    self.leftArmVisualX = vm:getNumber("leftArmVisualX")
    self.leftArmVisualY = vm:getNumber("leftArmVisualY")
    self.leftArmVisualRotation = vm:getNumber("leftArmVisualRotation")
    self.leftArmVisualScaleX = vm:getNumber("leftArmVisualScaleX")

    --------------------------------------------------------
    -- RIGHT ARM
    --------------------------------------------------------

    self.ra0x = vm:getNumber("ra0x")
    self.ra0y = vm:getNumber("ra0y")
    self.ra1x = vm:getNumber("ra1x")
    self.ra1y = vm:getNumber("ra1y")
    self.ra2x = vm:getNumber("ra2x")
    self.ra2y = vm:getNumber("ra2y")
    self.ra3x = vm:getNumber("ra3x")
    self.ra3y = vm:getNumber("ra3y")
    self.ra4x = vm:getNumber("ra4x")
    self.ra4y = vm:getNumber("ra4y")

    self.rightArmVisualX = vm:getNumber("rightArmVisualX")
    self.rightArmVisualY = vm:getNumber("rightArmVisualY")
    self.rightArmVisualRotation = vm:getNumber("rightArmVisualRotation")
    self.rightArmVisualScaleX = vm:getNumber("rightArmVisualScaleX")

    --------------------------------------------------------
    -- LEFT LEG
    --------------------------------------------------------

    self.ll0x = vm:getNumber("ll0x")
    self.ll0y = vm:getNumber("ll0y")
    self.ll1x = vm:getNumber("ll1x")
    self.ll1y = vm:getNumber("ll1y")
    self.ll2x = vm:getNumber("ll2x")
    self.ll2y = vm:getNumber("ll2y")
    self.ll3x = vm:getNumber("ll3x")
    self.ll3y = vm:getNumber("ll3y")
    self.ll4x = vm:getNumber("ll4x")
    self.ll4y = vm:getNumber("ll4y")

    self.leftLegVisualX = vm:getNumber("leftLegVisualX")
    self.leftLegVisualY = vm:getNumber("leftLegVisualY")
    self.leftLegVisualRotation = vm:getNumber("leftLegVisualRotation")
    self.leftLegVisualScaleX = vm:getNumber("leftLegVisualScaleX")
    self.leftLegVisualScaleY = vm:getNumber("leftLegVisualScaleY")

    --------------------------------------------------------
    -- RIGHT LEG
    --------------------------------------------------------

    self.rl0x = vm:getNumber("rl0x")
    self.rl0y = vm:getNumber("rl0y")
    self.rl1x = vm:getNumber("rl1x")
    self.rl1y = vm:getNumber("rl1y")
    self.rl2x = vm:getNumber("rl2x")
    self.rl2y = vm:getNumber("rl2y")
    self.rl3x = vm:getNumber("rl3x")
    self.rl3y = vm:getNumber("rl3y")
    self.rl4x = vm:getNumber("rl4x")
    self.rl4y = vm:getNumber("rl4y")

    ----------------------------------------------------
    -- JIANGSHI SPLIT SHOES
    ----------------------------------------------------

    self.leftShoeVisualX = vm:getNumber("leftShoeVisualX")
    self.leftShoeVisualY = vm:getNumber("leftShoeVisualY")
    self.leftShoeVisualRotation = vm:getNumber("leftShoeVisualRotation")
    self.leftShoeVisualScale = vm:getNumber("leftShoeVisualScale")

    self.rightShoeVisualX = vm:getNumber("rightShoeVisualX")
    self.rightShoeVisualY = vm:getNumber("rightShoeVisualY")
    self.rightShoeVisualRotation = vm:getNumber("rightShoeVisualRotation")
    self.rightShoeVisualScale = vm:getNumber("rightShoeVisualScale")

        self.rightLegVisualX = vm:getNumber("rightLegVisualX")
        self.rightLegVisualY = vm:getNumber("rightLegVisualY")
        self.rightLegVisualRotation = vm:getNumber("rightLegVisualRotation")
        self.rightLegVisualScaleX = vm:getNumber("rightLegVisualScaleX")
        self.rightLegVisualScaleY = vm:getNumber("rightLegVisualScaleY")

    --------------------------------------------------------
    -- EFFECT INITIAL STATE
    --------------------------------------------------------

    InteractionLogic.clearHoverTarget(
        self
    )


    InteractionLogic.hideSelectedMarker(
        self
    )


    InteractionLogic.hideConfirm(
        self
    )


    FreezeLogic.hideDots(
        self
    )


    --------------------------------------------------------
    -- CHARACTER INITIAL VISUAL
    --------------------------------------------------------

    BodyLogic.updateVisuals(
        self
    )


    LimbLogic.updateAll(
        self
    )


    --------------------------------------------------------
    -- HOLD VISUAL SLOTS
    --------------------------------------------------------

    self.holdSlotX = {}
    self.holdSlotY = {}


    for i =
        1,
        Constants.MAX_HOLD_SLOTS
    do

        self.holdSlotX[i] =
            vm:getNumber(
                "hold" .. i .. "X"
            )


        self.holdSlotY[i] =
            vm:getNumber(
                "hold" .. i .. "Y"
            )

    end


    --------------------------------------------------------
    -- PICK RANDOM ROUTE
    --------------------------------------------------------

    RouteLogic.pickRandomRoute(
        self
    )


    --------------------------------------------------------
    -- INITIAL VISIBLE HOLDS
    --------------------------------------------------------

    RouteLogic.updateVisualSlots(
        self
    )

    if self.cliffY ~= nil then

        self.cliffY.value =
            1050 - self.cameraY

    end
    -- A newly bound Rive number defaults to zero, but camera scale MUST start 1.
    setNumber(self.exteriorCameraX,0)
    setNumber(self.exteriorCameraY,0)
    setNumber(self.exteriorCameraScale,1)

    return true

end


------------------------------------------------------------
-- RESIZE
------------------------------------------------------------

function resize(
    self: Track,
    size: Vector
)

    self.size =
        size

end


------------------------------------------------------------
-- ENDING CUTSCENE - original climbing character, animated pose,
-- natural cave, coffin, closing cave, dawn on SAME cliff.
-- All of the ordinary move/camera/route functions are deliberately
-- bypassed once gameWon is confirmed. They are NOT modified.
------------------------------------------------------------

local function endEase(v: number): number
    local k = math.max(0,math.min(1,v))
    return k*k*(3-2*k)
end

local function endMix(a: number, b: number, k: number): number
    return a+(b-a)*k
end

-- PURPOSEFUL TWO-SHOT 2D CUTSCENE (not a slideshow / picture zoom).
-- Shot A = unmodified cliff, animated stone fragments + REAL articulated hero leap.
-- Dust briefly covers the lens; while fully hidden we switch to Shot B.
-- Shot B = stationary detailed cave, original animated rig, parallax foreground,
-- second leap and hinged coffin lid. A second dust cover returns to original cliff.
local function advanceCaveEnding(self: Track, seconds: number): boolean
    local p = self.endingPhase

    -- Ending timeline:
    -- 1: crack -> falling rocks -> cave opens
    -- 2: jiangshi jumps into cave -> blackout -> interior
    -- 3: jiangshi jumps into coffin -> lid closes
    -- 4: blackout -> exterior cliff
    -- 5: sunrise -> SAFE

    local speed = 1.65

    if p == 1 then
        speed = 1.25
    elseif p == 2 then
        speed = 1.50
    elseif p == 3 then
        speed = 1.60
    end

    local t = self.endingTimer + math.min(seconds, 0.08) * speed

    local durations = {4.30, 5.25, 4.75, 2.90, 3.70}
    if p < 6 and t >= durations[p] then
        t = t - durations[p]
        p = p + 1
        self.endingPhase = p
    end
    self.endingTimer = t
    local off = -1200

    -- The final hold is in WORLD coordinates. Camera stops when the hand lands.
    local hx,hy=250,225
    if self.currentRoute ~= nil and #self.currentRoute.holds > 0 then
        local top=self.currentRoute.holds[#self.currentRoute.holds]
        hx,hy=top.x,top.y-self.cameraY
    end
    hx=math.max(115,math.min(380,hx))
    hy=math.max(145,math.min(315,hy))
    local ledgeX,ledgeY=hx,hy+32
    -- DIRECTED CAMERA: zooms THE ORIGINAL CLIFF plus its fracture and holds,
    -- not a standalone cave bitmap. At zoom 3.1, the distant left valley leaves view.
    -- The return shot begins at that same close-up and pulls to the original framing.
    local cameraZoom=1.0
    local cameraBlend=0.0
    if p==1 then
        local focus=endEase((t-1.00)/2.20)
        cameraZoom=endMix(1.0,1.48,focus)
        cameraBlend=focus
    elseif p==2 then
        local focus=endEase(t/2.95)
        cameraZoom=endMix(1.48,2.25,focus)
        cameraBlend=1
    elseif p==3 then
        cameraZoom=2.25
        cameraBlend=1
    elseif p==4 then
        cameraZoom=2.25
        cameraBlend=1
    elseif p==5 then
        local pull=endEase(t/3.30)
        cameraZoom=endMix(2.25,1.0,pull)
        cameraBlend=1-pull
    end
    local camX=(250-hx*cameraZoom)*cameraBlend
    local camY=(250-hy*cameraZoom)*cameraBlend
    setNumber(self.exteriorCameraX,camX)
    setNumber(self.exteriorCameraY,camY)
    setNumber(self.exteriorCameraScale,cameraZoom)
    local shake=(p==1) and (math.sin(t*49)*3.0*(1-endEase(t/2.05))) or 0

    -- Exterior stays visible until the blackout covers it.
    local exterior =
        p == 1
        or (p == 2 and t < 3.82)
        or (p == 4 and t >= 1.79)
        or p == 5

    -- The cave MUST NOT appear until the falling rocks finish.
    local opening = 0

    if p == 1 then
        opening = endEase((t - 3.03) / 0.78) * 0.55

    elseif p == 2 then
        opening = 0.55

    elseif p == 4 then
        opening = 0.55

    elseif p == 5 then
        opening = 0.55 * (1 - endEase(t / 2.50))
    end

    setNumber(self.caveEffectX, hx + shake)
    setNumber(self.caveMouthX, hx + shake)

    setNumber(
        self.caveMouthY,
        exterior and opening > 0.02 and hy + shake or off
    )

    setNumber(self.caveApertureScale, opening)

    -- Crack appears first and remains visible during the rockfall.
    -- It disappears just before the cave opens.
    local crackVisible = p == 1 and t >= 0.18 and t < 3.03

    setNumber(
        self.caveCrackY,
        crackVisible and hy + shake or off
    )

    setNumber(
        self.caveFractureScale,
        0.22 + 0.37 * endEase((t - 0.18) / 0.85)
    )
    -- Small front-facing stone lip, but never in front of hero's torso.
    -- Parenthesize the visibility expression BEFORE selecting numeric coordinates.
    -- Luau's `or` would otherwise sometimes return boolean true to setNumber.
    local sillVisible = false -- no separate front wall that bisects character
    setNumber(self.caveSillX,sillVisible and hx or off)
    setNumber(self.caveSillY,sillVisible and hy or off)
    setNumber(self.caveSillScale,sillVisible and 0.70 or 0.01)
    setNumber(self.caveDebrisY,off) -- replaced flat rock sheet with three independently falling fragments
    setNumber(self.caveDustX,hx)
    setNumber(self.caveDustScale,(p==1 and 0.42 or 0.01))
    setNumber(self.endingCrackY,off)
    setNumber(self.endingOverlayY,off)
    setNumber(self.endingDoorLeftX,off)
    setNumber(self.endingDoorRightX,off)

    -- THREE INDEPENDENT stones actually tumble at different speeds and angles.
    local starts={-46,39,2}
    local landingXs={-115,105,-17}
    local delays = {1.30, 1.53, 1.75}
    local lens = {1.15, 1.20, 1.10}
    local rotations={2.8,-2.0,3.4}
    for i=1,3 do
        local active=p==1 and t>=delays[i] and t<=delays[i]+lens[i]
        local k=active and endEase((t-delays[i])/lens[i]) or 0
        local rx=active and hx+endMix(starts[i],landingXs[i],k) or off
        local ry=active and hy-25+260*k*k or off
        local propX,propY,propR=nil,nil,nil
        if i==1 then propX,propY,propR=self.fallRock1X,self.fallRock1Y,self.fallRock1Rotation
        elseif i==2 then propX,propY,propR=self.fallRock2X,self.fallRock2Y,self.fallRock2Rotation
        else propX,propY,propR=self.fallRock3X,self.fallRock3Y,self.fallRock3Rotation end
        setNumber(propX,rx)
        setNumber(propY,ry)
        setNumber(propR,rotations[i]*k)
    end

    -- A purposeful lens cover, not a crossfade between two scaled pictures.
    -- Black/dust grows over the frame, holds fully opaque, then clears to the
    -- interior. The lens stays still while the original world camera pushes in.
    local wipeY=off
    -- Full-frame smoky shutter travels past the lens; shot change is hidden
    -- during the fully covered interval, so no picture grows across the cliff.
        if p == 2 then

        -- The jiangshi finishes entering the cave BEFORE this begins.
        if t >= 2.82 and t < 3.73 then

            -- Black screen moves in.
            wipeY = endMix(
                -500,
                250,
                endEase((t - 2.82) / 0.91)
            )

        elseif t >= 3.73 and t < 4.08 then

            -- Hold the screen fully covered while changing scenes.
            wipeY = 250

        elseif t >= 4.08 and t < 5.05 then

            -- Reveal the cave interior.
            wipeY = endMix(
                250,
                1000,
                endEase((t - 4.08) / 0.97)
            )

        end
    elseif p==4 then
        if t>=0.61 and t<1.51 then
            wipeY=endMix(-500,250,endEase((t-0.61)/0.90))
        elseif t>=1.51 and t<1.96 then
            wipeY=250
        elseif t>=1.96 and t<2.84 then
            wipeY=endMix(250,1000,endEase((t-1.96)/0.88))
        end
    end
    setNumber(self.caveWipeY,wipeY)
    setNumber(self.caveWipeScale,1.0)

    -- Entire interior is a FIXED shot. No image zoom. It swaps beneath the
    -- blackout: no rectangular edge, no scrolling cliff strip under the room.
    local roomVisible =
        (p == 2 and t >= 3.82)
        or p == 3
        or (p == 4 and t < 1.79)
    local roomX,roomY,roomScale=off,off,0.01
    if roomVisible then roomX,roomY,roomScale=250,250,1.00 end
    setNumber(self.caveRoomX,roomX)
    setNumber(self.endingRoomY,roomY)
    setNumber(self.caveRoomScale,roomScale)
    -- No extra foreground mural; it formerly appeared as a rock layer
    -- floating through the middle of the room and obscured the hero's feet.
    setNumber(self.caveFgX,off)
    setNumber(self.caveFgY,off)
    -- Independently extracted opaque coffin facade: align pixel for pixel
    -- with the single full-screen room shot; draw only over the coffin body.
    -- Let the character enter the visible coffin opening first.
    -- Restore the foreground when the character is almost submerged.
    local lipVisible =
        (p == 3 and t >= 2.72)
        or (p == 4 and t < 1.79)

    setNumber(self.caveLipX, lipVisible and 250 or off)
    setNumber(self.caveLipY, lipVisible and 250 or off)

    setNumber(self.caveLipScale,roomVisible and 1.0 or 0.01)
    setNumber(self.endingCoffinY,roomY)

    -- Coffin lid:
    -- Do not show it until the jiangshi has disappeared.

    local lidX, lidY, lidScale = off, off, 0.01
    local lidRot = 0

    local lidVisible =
        (p == 3 and t >= 3.30)
        or (p == 4 and t < 1.79)

    if lidVisible then

        -- Character disappears at t=3.14.
        -- Lid appears later, then closes.
        local shut = 1

        if p == 3 then
            shut = endEase((t - 3.42) / 0.42)
        end

        -- Small bounce after closing.
        local bounce = 0

        if p == 3 and t >= 3.84 and t < 4.02 then
            bounce =
                math.sin((t - 3.84) / 0.18 * math.pi) * 3
        end

        lidX = 250
        lidY = 304 + 34 * shut - bounce
        lidScale = 0.63 * (0.75 + 0.18 * shut)
        lidRot = -0.18 * (1 - shut)

    end
    setNumber(self.caveLidX,lidX)
    setNumber(self.endingCoffinLidY,lidY)
    setNumber(self.caveLidScale,lidScale)
    setNumber(self.endingLidRotation,lidRot)

    -- REUSE EXISTING RIG AND ALL ITS INDEPENDENT ARTICULATED BODY PARTS.
    -- Local pose actively changes hands + feet. Outer rig travels along two arcs.
    local ox,oy=self.endingOriginX,self.endingOriginY
    local x,y=ox,oy
    local heroScale=1
    local pose=0
    local jump=0
    local squat=0
    local showRig=true
    if p == 1 then

        ----------------------------------------------------
        -- STAGE 1:
        -- Wait while the cliff cracks, rocks fall,
        -- and the cave entrance opens.
        -- DO NOT jump yet.
        ----------------------------------------------------

        x = ox
        y = oy
        heroScale = 1

        pose = 0
        jump = 0
        squat = 0

    elseif p == 2 then

        ----------------------------------------------------
        -- STAGE 2:
        -- The cave is fully open.
        -- Prepare, jump, and disappear into the opening.
        ----------------------------------------------------

        pose = endEase((t - 0.40) / 0.35)

        -- Brief anticipation.
        squat =
            endEase((t - 0.20) / 0.35)
            * (1 - endEase((t - 0.65) / 0.20))

        -- One deliberate jump toward the cave.
        local flight = endEase((t - 0.68) / 1.76)

        if t >= 0.68 and t < 2.44 then
            jump = math.sin(math.pi * flight)
        else
            jump = 0
        end

        -- Move directly from the final climbing position
        -- toward the center of the cave entrance.
        x = endMix(ox, hx + 8, flight)

        y =
            endMix(oy, hy + 4, flight)
            - 55 * jump
            + 6 * squat

        -- Shrink into the cave instead of disappearing suddenly.
        heroScale = endMix(1.0, 0.03, flight)

        -- The character has entered before the blackout.
        if t >= 2.60 and t < 3.82 then
            showRig = false
        end

        -- Scene changes ONLY while the screen is black.
        if t >= 3.82 then
            -- Enter the cave and land on the lower-left floor.
            x = 105
            y = 365
            heroScale = 0.58
            showRig = true
        end
    elseif p == 3 then

    ----------------------------------------------------
    -- JUMP INTO THE COFFIN
    ----------------------------------------------------

    pose = 1

    -- Prepare to jump.
    squat =
        endEase((t - 0.56) / 0.26)
        * (1 - endEase((t - 1.01) / 0.16))

    -- Jump from the lower-left floor.
    local leap = endEase((t - 1.05) / 1.25)

    if t > 1.05 and t < 2.30 then
        jump = math.sin(math.pi * leap)
    else
        jump = 0
    end

    -- Move toward the center of the coffin opening.
    x = endMix(105, 255, leap)

    y = endMix(365, 375, leap)
        - 62 * jump
        + 7 * squat

    heroScale = 0.58

    ----------------------------------------------------
    -- BRIEF LANDING, THEN SINK
    ----------------------------------------------------

    -- Short pause after landing.
    -- Then move down into the coffin.
    local sink = endEase((t - 2.52) / 0.62)

    y = y + 50 * sink

    -- Only hide after the sinking animation completes.
    if t >= 3.14 then
        showRig = false
    end

    elseif p==4 then
        pose=1
        showRig=false
    else
        pose=1
        showRig=false
    end
    -- Individual wrist / foot endpoints flow from the exact LAST-HOLD pose.
    local lhx,lhy=endMix(self.endingOriginLHx,ox-63,pose),endMix(self.endingOriginLHy,oy-18,pose)
    local rhx,rhy=endMix(self.endingOriginRHx,ox+63,pose),endMix(self.endingOriginRHy,oy-18,pose)
    local lfx,lfy=endMix(self.endingOriginLFx,ox-29,pose),endMix(self.endingOriginLFy,oy+95,pose)
    local rfx,rfy=endMix(self.endingOriginRFx,ox+29,pose),endMix(self.endingOriginRFy,oy+95,pose)
    -- Crouch shortens apparent legs; takeoff lifts hands and pulls up feet.
    lhy=lhy-12*squat-46*jump
    rhy=rhy-12*squat-46*jump
    lfy=lfy-18*squat-20*jump
    rfy=rfy-18*squat-20*jump
    lfx=lfx+8*jump
    rfx=rfx-8*jump
    -- Finish before releasing grips; base climb modules never run during cutscene.
    if p >= 2 then
        self.leftHandHoldId,self.rightHandHoldId=0,0
        self.leftFootHoldId,self.rightFootHoldId=0,0
    end
    self.bodyPositionX,self.bodyPositionY=ox,oy
    self.leftHandX,self.leftHandY=lhx,lhy
    self.rightHandX,self.rightHandY=rhx,rhy
    self.leftFootX,self.leftFootY=lfx,lfy
    self.rightFootX,self.rightFootY=rfx,rfy
    BodyLogic.updateVisuals(self)
    LimbLogic.updateAll(self)
    -- Coffin opacity mask is in front of the real articulated figure. No
    -- independently hidden pant legs or shoes: the entire body sinks behind it.
    -- The hero is a sibling of the exterior world in the RML draw tree.
    -- Apply identical directed camera math while outside; otherwise the
    -- original rig moves in a different coordinate frame from the ledge.
    local inInterior =
        (p == 3)
        or (p == 2 and t >= 3.82)
    local z=inInterior and 1 or cameraZoom
    local viewX=inInterior and 0 or camX
    local viewY=inInterior and 0 or camY
    local renderedScale=heroScale
    if not inInterior then
        renderedScale=math.min(1.10,heroScale*z)
    end
    setNumber(self.cinematicRigScale,renderedScale)
    setNumber(self.cinematicRigRotation,0.065*jump - 0.025*squat)
    -- Numeric-only coordinates: avoid a boolean/number union from and/or.
    local rigX: number = off
    local rigY: number = off

    if showRig then

        if inInterior then

            -- Interior:
            -- Position the actual character body at (x, y).
            -- The rig's original body coordinates are (ox, oy).
            rigX = x - ox * renderedScale
            rigY = y - oy * renderedScale

        else

            -- Exterior:
            -- Keep the original camera behavior unchanged.
            rigX = x * z + viewX - x * renderedScale
            rigY = y * z + viewY - y * renderedScale

        end

    end
    setNumber(self.cinematicRigX,rigX)
    setNumber(self.cinematicRigY,rigY)

    -- Shot C: return to the same original world, lighting gradually wakes up.
    local dawn=(p==5) and endEase(t/2.7) or (p>=6 and 1 or 0)
    if dawn>0 then
        setNumber(self.dawnGlowX,endMix(-110,260,dawn))
        setNumber(self.dawnGlowY,endMix(-35,150,dawn))
        setNumber(self.dawnGlowScale,0.04+1.9*dawn)
        setNumber(self.dawnCoreX,endMix(40,295,dawn))
        setNumber(self.dawnCoreY,endMix(-50,100,dawn))
        setNumber(self.dawnCoreScale,0.02+1.28*dawn)
    else
        setNumber(self.dawnGlowX,off)
        setNumber(self.dawnGlowY,off)
        setNumber(self.dawnGlowScale,0.01)
        setNumber(self.dawnCoreX,off)
        setNumber(self.dawnCoreY,off)
        setNumber(self.dawnCoreScale,0.01)
    end
    setNumber(self.endingDawnY,off)
    setNumber(self.endingSafeY,p>=6 and 255 or off)
    local safe=(p==6) and endEase(t/0.70) or 0
    setNumber(self.endingLogoScale,0.40+0.13*safe)

    -- Hide gameplay HUD during cinematic; hide floating holds once cut to room.
    setNumber(self.talismanX,off)
    setNumber(self.talismanY,off)
    setNumber(self.selectionHaloX,off)
    setNumber(self.selectionHaloY,off)
    setNumber(self.selectedMarkerX,off)
    setNumber(self.selectedMarkerY,off)
    setNumber(self.holdHoverX,off)
    setNumber(self.holdHoverY,off)
    setNumber(self.confirmHaloX,off)
    setNumber(self.confirmHaloY,off)
    setNumber(self.freezeDot1X,off)
    setNumber(self.freezeDot2X,off)
    setNumber(self.freezeDot3X,off)
    if (p==2 and t>=2.06) or p>=3 then
        for i=1,Constants.MAX_HOLD_SLOTS do
            setNumber(self.holdSlotX[i],off)
            setNumber(self.holdSlotY[i],off)
        end
    end
    local resetXs={455,455,466,454,441}
    local resetProps={self.endingResetX0,self.endingResetX1,self.endingResetX2,self.endingResetX3,self.endingResetX4}
    for i=1,5 do setNumber(resetProps[i],p>=6 and resetXs[i] or off) end
    setNumber(self.cliffY,1050-self.cameraY)
    return true
end


------------------------------------------------------------
-- ADVANCE
------------------------------------------------------------

function advance(
    self: Track,
    seconds: number
): boolean

    --------------------------------------------------------
    -- PROLOGUE: STORY -> CURTAINS OPEN -> GAME
    --------------------------------------------------------

    local t: number = self.prologueTimer or 0

    if t < 4.8 then

        t = math.min(4.8, t + seconds)
        self.prologueTimer = t

        -- Gentle head sway during the opening.
        setNumber(
            self.prologueHeadRotation,
            math.sin(t * 2.5) * 0.055
        )

        -- Head stays during the opening, disappears before gameplay.
        if t < 3.1 then
            setNumber(self.prologueHeadY, 85)
        else
            setNumber(self.prologueHeadY, -1200)
        end

        -- Show story image for 3.1 seconds.
        if t < 3.1 then
            setNumber(self.prologueTextY, 250)
        else
            -- Hide story before opening the doors.
            setNumber(self.prologueTextY, -1200)
        end

        -- Smooth door opening from 3.1s to 4.6s.
        local p = math.max(
            0,
            math.min(1, (t - 3.1) / 1.5)
        )

        -- Smoothstep easing
        p = p * p * (3 - 2 * p)

        -- Doors separate from the center.
        setNumber(
            self.prologueLeftX,
            125 - 260 * p
        )

        setNumber(
            self.prologueRightX,
            375 + 260 * p
        )

        return true
    end


    -- Win is raised ONLY by existing LimbLogic.checkWin after a HAND FINISHES on the top hold.
    -- Start once on the following tick, then leave all climbing systems untouched.
    if self.gameWon and self.endingPhase == 0 then
        self.endingPhase = 1
        self.endingTimer = 0
        self.endingOriginX = self.bodyPositionX
        self.endingOriginY = self.bodyPositionY
        self.endingOriginLHx, self.endingOriginLHy = self.leftHandX, self.leftHandY
        self.endingOriginRHx, self.endingOriginRHy = self.rightHandX, self.rightHandY
        self.endingOriginLFx, self.endingOriginLFy = self.leftFootX, self.leftFootY
        self.endingOriginRFx, self.endingOriginRFy = self.rightFootX, self.rightFootY
        self.isMoving = false
        self.dynoPhase = ""
    end

    if self.endingPhase > 0 then
        return advanceCaveEnding(self, seconds)
    end

    -- Normal climbing has a true 1:1 exterior camera. It is only directed after victory.
    setNumber(self.exteriorCameraX,0)
    setNumber(self.exteriorCameraY,0)
    setNumber(self.exteriorCameraScale,1)
    -- No runtime cinematic updates before the win; all images are offscreen initially.
    setNumber(self.cinematicRigX,0)
    setNumber(self.cinematicRigY,0)
    setNumber(self.cinematicRigScale,1)
    setNumber(self.cinematicRigRotation,0)
    setNumber(self.endingResetX0,455)
    setNumber(self.endingResetX1,455)
    setNumber(self.endingResetX2,466)
    setNumber(self.endingResetX3,454)
    setNumber(self.endingResetX4,441)
    --------------------------------------------------------
    -- TALISMAN
    --------------------------------------------------------

    local pointerK =
        1 - math.exp(
            -12 * seconds
        )


    self.x =
        self.x
        + (
            self.targetX
            - self.x
        ) * pointerK


    self.y =
        self.y
        + (
            self.targetY
            - self.y
        ) * pointerK


    if self.isFrozen then
        -- 符咒固定在帽檐上，不跟随鼠标
        setNumber(
            self.talismanX,
            self.bodyPositionX + Constants.HEAD_OFFSET_X
        )

        setNumber(
            self.talismanY,
            self.bodyPositionY + Constants.HEAD_OFFSET_Y + 20
        )
    else
        -- 正常状态：继续跟随鼠标
        setNumber(self.talismanX, self.x)
        setNumber(self.talismanY, self.y)
    end


    --------------------------------------------------------
    -- FREEZE
    --
    -- Camera does not move during freeze.
    --------------------------------------------------------

    if FreezeLogic.advance(
        self,
        seconds
    ) then

        InteractionLogic.clearHoverTarget(
            self
        )


        InteractionLogic.hideSelectedMarker(
            self
        )


        return true

    end


    --------------------------------------------------------
    -- START DYNO VISUAL
    --
    -- InteractionLogic has already classified this move
    -- by setting self.isDyno = true.
    --------------------------------------------------------

    if
        self.isDyno
        and
        self.isMoving
        and
        self.dynoPhase == ""
    then

        startDynoVisual(
            self
        )

    end


    --------------------------------------------------------
    -- LIMB MOVEMENT
    --------------------------------------------------------

    if self.isMoving then

        LimbLogic.updateMovement(
            self,
            seconds
        )

    end


    --------------------------------------------------------
    -- NEW BODY TARGET
    --------------------------------------------------------

    if self.needsBodyTargetUpdate then

        BodyLogic.recalculateTarget(
            self
        )


        self.needsBodyTargetUpdate =
            false

    end


    --------------------------------------------------------
    -- DYNO BODY ANIMATION
    --------------------------------------------------------

    local dynoControlsBody =
        advanceDynoVisual(
            self,
            seconds
        )


    --------------------------------------------------------
    -- NORMAL BODY FOLLOW
    --
    -- While Dyno owns body movement, normal follow is
    -- temporarily paused.
    --------------------------------------------------------

    if not dynoControlsBody then

        BodyLogic.advance(
            self,
            seconds
        )

    end


    --------------------------------------------------------
    -- CAMERA FOLLOW
    --
    -- Keep camera still during the very short Dyno jump.
    -- This makes the jump readable and avoids camera/body
    -- fighting each other.
    --------------------------------------------------------

    local cameraMoved =
        false


    if not dynoControlsBody then

        cameraMoved =
            CameraLogic.advance(
                self
            )

    end


    --------------------------------------------------------
    -- CAMERA MAY HAVE SHIFTED CHARACTER
    --------------------------------------------------------

    if cameraMoved then

        BodyLogic.updateVisuals(
            self
        )

    end


    --------------------------------------------------------
    -- SHOULDER / HIP + LIMB VISUALS
    --------------------------------------------------------

    LimbLogic.updateAll(
        self
    )


    --------------------------------------------------------
    -- SCROLL / RECYCLE HOLD SLOTS
    --------------------------------------------------------

    RouteLogic.updateVisualSlots(
        self
    )

    --------------------------------------------------------
    -- CLIFF WORLD -> SCREEN
    --------------------------------------------------------

    if self.cliffY ~= nil then

        self.cliffY.value =
            1050 - self.cameraY

    end


    --------------------------------------------------------
    -- SELECTED MARKER
    --------------------------------------------------------

    InteractionLogic.refreshSelectedMarker(
        self
    )


    --------------------------------------------------------
    -- NORMAL INTERACTION
    --------------------------------------------------------

    if not self.isMoving then

        ----------------------------------------------------
        -- Every frame begins with NO assumed action.
        --
        -- Then Hover decides exactly one visible action.
        ----------------------------------------------------

        InteractionLogic.clearHoverTarget(
            self
        )


        ----------------------------------------------------
        -- Body gets first opportunity.
        ----------------------------------------------------

        InteractionLogic.updateBodyHover(
            self
        )


        ----------------------------------------------------
        -- A valid Hold may override Body Hover.
        --
        -- If Hold circle becomes visible:
        -- hoverTargetType becomes "hold".
        --
        -- Otherwise Body remains the target.
        ----------------------------------------------------

        InteractionLogic.updateHoldHover(
            self
        )

    end


    --------------------------------------------------------
    -- CONFIRM
    --------------------------------------------------------

    InteractionLogic.advanceConfirm(
        self,
        seconds
    )


    return true

end


------------------------------------------------------------
-- INSTANCE
------------------------------------------------------------

return function(
    context: Context
): Layout<Track>

    return {

        size =
            Vector.xy(0, 0),


        ----------------------------------------------------
        -- VM
        ----------------------------------------------------

        talismanX = nil,
        talismanY = nil,

        headX = nil,
        headY = nil,

        cliffY = nil,

        selectionHaloX = nil,
        selectionHaloY = nil,

        selectedMarkerX = nil,
        selectedMarkerY = nil,

        holdHoverX = nil,
        holdHoverY = nil,

        confirmHaloX = nil,
        confirmHaloY = nil,


        freezeDot3X = nil,
        freezeDot3Y = nil,

        freezeDot2X = nil,
        freezeDot2Y = nil,

        freezeDot1X = nil,
        freezeDot1Y = nil,


        la0x = nil,
        la0y = nil,
        la1x = nil,
        la1y = nil,
        la2x = nil,
        la2y = nil,
        la3x = nil,
        la3y = nil,
        la4x = nil,
        la4y = nil,

        leftArmVisualX = nil,
        leftArmVisualY = nil,
        leftArmVisualRotation = nil,
        leftArmVisualScaleX = nil,

        ra0x = nil,
        ra0y = nil,
        ra1x = nil,
        ra1y = nil,
        ra2x = nil,
        ra2y = nil,
        ra3x = nil,
        ra3y = nil,
        ra4x = nil,
        ra4y = nil,


        ll0x = nil,
        ll0y = nil,
        ll1x = nil,
        ll1y = nil,
        ll2x = nil,
        ll2y = nil,
        ll3x = nil,
        ll3y = nil,
        ll4x = nil,
        ll4y = nil,

        leftLegVisualX = nil,
        leftLegVisualY = nil,
        leftLegVisualRotation = nil,
        leftLegVisualScaleX = nil,
        leftLegVisualScaleY = nil,

        rl0x = nil,
        rl0y = nil,
        rl1x = nil,
        rl1y = nil,
        rl2x = nil,
        rl2y = nil,
        rl3x = nil,
        rl3y = nil,
        rl4x = nil,
        rl4y = nil,

        leftShoeVisualX = nil,
        leftShoeVisualY = nil,
        leftShoeVisualRotation = nil,
        leftShoeVisualScale = nil,

        rightShoeVisualX = nil,
        rightShoeVisualY = nil,
        rightShoeVisualRotation = nil,
        rightShoeVisualScale = nil,

        rightLegVisualX = nil,
        rightLegVisualY = nil,
        rightLegVisualRotation = nil,
        rightLegVisualScaleX = nil,
        rightLegVisualScaleY = nil,

        ----------------------------------------------------
        -- POINTER
        ----------------------------------------------------

        x = 250,
        y = 250,

        targetX = 250,
        targetY = 250,


        ----------------------------------------------------
        -- CHARACTER
        ----------------------------------------------------

        bodyPositionX =
            Constants.INITIAL_BODY_X,

        bodyPositionY =
            Constants.INITIAL_BODY_Y,


        bodyTargetX =
            Constants.INITIAL_BODY_X,

        bodyTargetY =
            Constants.INITIAL_BODY_Y,


        needsBodyTargetUpdate =
            false,


        leftHandX =
            Constants.INITIAL_LEFT_HAND_X,

        leftHandY =
            Constants.INITIAL_LEFT_HAND_Y,


        rightHandX =
            Constants.INITIAL_RIGHT_HAND_X,

        rightHandY =
            Constants.INITIAL_RIGHT_HAND_Y,


        leftFootX =
            Constants.INITIAL_LEFT_FOOT_X,

        leftFootY =
            Constants.INITIAL_LEFT_FOOT_Y,


        rightFootX =
            Constants.INITIAL_RIGHT_FOOT_X,

        rightFootY =
            Constants.INITIAL_RIGHT_FOOT_Y,


        ----------------------------------------------------
        -- MOVEMENT
        ----------------------------------------------------

        moveTargetX = 0,
        moveTargetY = 0,

        movingPart = "",

        isMoving = false,

        isDyno = false,


        ----------------------------------------------------
        -- DYNO VISUAL
        ----------------------------------------------------

        dynoPhase = "",

        dynoTimer = 0,

        dynoStartBodyX =
            Constants.INITIAL_BODY_X,

        dynoStartBodyY =
            Constants.INITIAL_BODY_Y,

        dynoJumpBodyX =
            Constants.INITIAL_BODY_X,

        dynoJumpBodyY =
            Constants.INITIAL_BODY_Y,


        ----------------------------------------------------
        -- INTERACTION
        ----------------------------------------------------

        hoveredPart = "",

        hoverTargetType = "",

        hoveredHoldId = 0,


        selectedPart = "",

        confirmTimer = 0,


        ----------------------------------------------------
        -- FREEZE
        ----------------------------------------------------

        isFrozen = false,

        freezeTimer = 0,


        ----------------------------------------------------
        -- CAMERA
        ----------------------------------------------------

        cameraY =
            Constants.INITIAL_CAMERA_Y,


        ----------------------------------------------------
        -- ROUTE
        ----------------------------------------------------

        currentRoute = nil,

        currentRouteIndex = 0,


        holdSlotX = {},

        holdSlotY = {},


        targetHoldId = 0,

        targetHoldKind = "",


        ----------------------------------------------------
        -- SUPPORTS
        ----------------------------------------------------

        leftHandHoldId = 0,

        rightHandHoldId = 0,

        leftFootHoldId = 0,

        rightFootHoldId = 0,


        ----------------------------------------------------
        -- GAME
        ----------------------------------------------------

        caveEffectX = nil,
        caveDebrisY = nil,
        caveMouthY = nil,
        caveCrackY = nil,
        cinematicRigX = nil,
        cinematicRigY = nil,
        exteriorCameraX = nil,
        exteriorCameraY = nil,
        exteriorCameraScale = nil,
        caveRoomX = nil,
        caveRoomScale = nil,
        caveLipX = nil,
        caveLipY = nil,
        caveLipScale = nil,
        caveApertureScale = nil,
        caveFractureScale = nil,
        cinematicRigScale = nil,
        caveLidX = nil,
        caveLidScale = nil,
        dawnGlowX = nil,
        dawnGlowY = nil,
        dawnGlowScale = nil,
        dawnCoreX = nil,
        dawnCoreY = nil,
        dawnCoreScale = nil,
        endingResetX0 = nil,
        endingResetX1 = nil,
        endingResetX2 = nil,
        endingResetX3 = nil,
        endingResetX4 = nil,
        endingLogoScale = nil,
        cinematicRigRotation = nil,
        caveDustX = nil,
        caveDustScale = nil,
        caveMouthX = nil,
    caveSillX = nil,
    caveSillY = nil,
    caveSillScale = nil,
        caveWipeY = nil,
        caveWipeScale = nil,
        caveFgX = nil,
        caveFgY = nil,
        fallRock1X = nil,
        fallRock1Y = nil,
        fallRock1Rotation = nil,
        fallRock2X = nil,
        fallRock2Y = nil,
        fallRock2Rotation = nil,
        fallRock3X = nil,
        fallRock3Y = nil,
        fallRock3Rotation = nil,
        endingOriginX = 250,
        endingOriginY = 300,
        endingOriginLHx = 0,
        endingOriginLHy = 0,
        endingOriginRHx = 0,
        endingOriginRHy = 0,
        endingOriginLFx = 0,
        endingOriginLFy = 0,
        endingOriginRFx = 0,
        endingOriginRFy = 0,
        gameWon = false,
        endingPhase = 0,
        endingTimer = 0,
        endingOverlayY = nil,
        endingDoorLeftX = nil,
        endingDoorRightX = nil,
        endingRoomY = nil,
        endingCoffinY = nil,
        endingDawnY = nil,
        endingSafeY = nil,
        endingJiangshiY = nil,
        endingCoffinLidY = nil,
        endingJiangshiX = nil,
        endingJiangshiScale = nil,
        endingJiangshiRotation = nil,
        endingLidRotation = nil,
        endingCrackY = nil,


        ----------------------------------------------------
        -- CALLBACKS
        ----------------------------------------------------

        init = init,

        resize = resize,

        advance = advance,

        pointerMove = pointerMove,

        pointerDown = pointerDown,

    }

end