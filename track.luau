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


    gameWon: boolean,

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

    --------------------------------------------------------
    -- RAW MOUSE POSITION
    --
    -- ONLY fixed-screen UI uses raw pointer coordinates.
    --------------------------------------------------------

    local pointerX =
        event.position.x

    local pointerY =
        event.position.y


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
-- ADVANCE
------------------------------------------------------------

function advance(
    self: Track,
    seconds: number
): boolean


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


    setNumber(
        self.talismanX,
        self.x
    )


    setNumber(
        self.talismanY,
        self.y
    )


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

        gameWon = false,


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