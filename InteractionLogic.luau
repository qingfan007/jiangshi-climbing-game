local Constants = require("GameConstants")
local GameMath = require("GameMath")
local LimbLogic = require("LimbLogic")
local RouteLogic = require("RouteLogic")


local InteractionLogic = {}


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


local function setPosition(
    px: Property<number>?,
    py: Property<number>?,
    x: number,
    y: number
)

    setNumber(px, x)
    setNumber(py, y)

end


------------------------------------------------------------
-- CURRENT HEAD POSITION
------------------------------------------------------------

local function getHeadPosition(
    self: any
): (number, number)

    return
        self.bodyPositionX
            + Constants.HEAD_OFFSET_X,

        self.bodyPositionY
            + Constants.HEAD_OFFSET_Y

end


------------------------------------------------------------
-- CURRENT BODY PART POSITION
------------------------------------------------------------

local function getPartPosition(
    self: any,
    part: string
): (number, number)

    if part == "head" then

        return getHeadPosition(self)


    elseif part == "leftArm" then

        return
            self.leftHandX,
            self.leftHandY


    elseif part == "rightArm" then

        return
            self.rightHandX,
            self.rightHandY


    elseif part == "leftLeg" then

        return
            self.leftFootX,
            self.leftFootY


    elseif part == "rightLeg" then

        return
            self.rightFootX,
            self.rightFootY

    end


    return
        Constants.OFFSCREEN,
        Constants.OFFSCREEN

end


------------------------------------------------------------
-- BODY HIT TEST
--
-- If multiple body parts overlap,
-- choose the one closest to the mouse.
------------------------------------------------------------

local function hitPartAt(
    self: any,
    x: number,
    y: number
): string

    local bestPart =
        ""

    local bestDistance =
        math.huge


    local function considerPart(
        part: string,
        cx: number,
        cy: number,
        rx: number,
        ry: number
    )

        if not GameMath.insideEllipse(
            x,
            y,
            cx,
            cy,
            rx,
            ry
        ) then

            return

        end


        local dx =
            x - cx

        local dy =
            y - cy


        local d =
            dx * dx
            + dy * dy


        if d < bestDistance then

            bestDistance =
                d

            bestPart =
                part

        end

    end


    --------------------------------------------------------
    -- HEAD
    --------------------------------------------------------

    local headX, headY =
        getHeadPosition(
            self
        )


    considerPart(
        "head",
        headX,
        headY,
        42,
        42
    )


    --------------------------------------------------------
    -- HANDS
    --
    -- Slightly larger interaction area so hands near
    -- the chest are easier to select.
    --------------------------------------------------------

    considerPart(
        "leftArm",
        self.leftHandX,
        self.leftHandY,
        40,
        40
    )


    considerPart(
        "rightArm",
        self.rightHandX,
        self.rightHandY,
        40,
        40
    )


    --------------------------------------------------------
    -- FEET
    --------------------------------------------------------

    considerPart(
        "leftLeg",
        self.leftFootX,
        self.leftFootY,
        30,
        30
    )


    considerPart(
        "rightLeg",
        self.rightFootX,
        self.rightFootY,
        30,
        30
    )


    return
        bestPart

end


------------------------------------------------------------
-- SUPPORT STATE
------------------------------------------------------------

local function getSupportCount(
    self: any
): number

    local count =
        0


    if self.leftHandHoldId ~= 0 then
        count = count + 1
    end


    if self.rightHandHoldId ~= 0 then
        count = count + 1
    end


    if self.leftFootHoldId ~= 0 then
        count = count + 1
    end


    if self.rightFootHoldId ~= 0 then
        count = count + 1
    end


    return
        count

end


local function getPartHoldId(
    self: any,
    part: string
): number

    if part == "leftArm" then
        return self.leftHandHoldId
    end


    if part == "rightArm" then
        return self.rightHandHoldId
    end


    if part == "leftLeg" then
        return self.leftFootHoldId
    end


    if part == "rightLeg" then
        return self.rightFootHoldId
    end


    return 0

end


------------------------------------------------------------
-- HOLD OCCUPANCY
------------------------------------------------------------

local function getHoldOccupancy(
    self: any,
    holdId: number
): number

    local count =
        0


    if self.leftHandHoldId == holdId then
        count = count + 1
    end


    if self.rightHandHoldId == holdId then
        count = count + 1
    end


    if self.leftFootHoldId == holdId then
        count = count + 1
    end


    if self.rightFootHoldId == holdId then
        count = count + 1
    end


    return
        count

end


------------------------------------------------------------
-- FIND HOLD BY ID
------------------------------------------------------------

local function findHoldById(
    self: any,
    holdId: number
): any

    if self.currentRoute == nil then
        return nil
    end


    for _, hold in self.currentRoute.holds do

        if hold.id == holdId then
            return hold
        end

    end


    return nil

end


------------------------------------------------------------
-- MOVEMENT RULE
------------------------------------------------------------

local function canMovePart(
    self: any,
    part: string
): boolean

    local currentHoldId =
        getPartHoldId(
            self,
            part
        )


    --------------------------------------------------------
    -- FREE LIMB
    --------------------------------------------------------

    if currentHoldId == 0 then
        return true
    end


    --------------------------------------------------------
    -- SUPPORTED LIMB
    --
    -- Only release when all four limbs are supported.
    --------------------------------------------------------

    return
        getSupportCount(self) >= 4

end


------------------------------------------------------------
-- DETACH
------------------------------------------------------------

local function detachPartFromHold(
    self: any,
    part: string
)

    if part == "leftArm" then

        self.leftHandHoldId =
            0


    elseif part == "rightArm" then

        self.rightHandHoldId =
            0


    elseif part == "leftLeg" then

        self.leftFootHoldId =
            0


    elseif part == "rightLeg" then

        self.rightFootHoldId =
            0

    end

end


------------------------------------------------------------
-- BODY HOVER VISUAL
------------------------------------------------------------

local function showHover(
    self: any,
    x: number,
    y: number
)

    setPosition(
        self.selectionHaloX,
        self.selectionHaloY,
        x,
        y
    )

end


function InteractionLogic.hideHover(
    self: any
)

    setPosition(
        self.selectionHaloX,
        self.selectionHaloY,
        Constants.OFFSCREEN,
        Constants.OFFSCREEN
    )

end


------------------------------------------------------------
-- HOLD HOVER VISUAL
------------------------------------------------------------

local function showHold(
    self: any,
    x: number,
    y: number
)

    setPosition(
        self.holdHoverX,
        self.holdHoverY,
        x,
        y
    )

end


function InteractionLogic.hideHold(
    self: any
)

    setPosition(
        self.holdHoverX,
        self.holdHoverY,
        Constants.OFFSCREEN,
        Constants.OFFSCREEN
    )

end


------------------------------------------------------------
-- CLEAR CURRENT HOVER ACTION
------------------------------------------------------------

function InteractionLogic.clearHoverTarget(
    self: any
)

    self.hoverTargetType =
        ""

    self.hoveredPart =
        ""

    self.hoveredHoldId =
        0


    InteractionLogic.hideHover(
        self
    )


    InteractionLogic.hideHold(
        self
    )

end


------------------------------------------------------------
-- CONFIRM
------------------------------------------------------------

local function showConfirm(
    self: any,
    x: number,
    y: number
)

    setPosition(
        self.confirmHaloX,
        self.confirmHaloY,
        x,
        y
    )


    self.confirmTimer =
        0.25

end


function InteractionLogic.hideConfirm(
    self: any
)

    setPosition(
        self.confirmHaloX,
        self.confirmHaloY,
        Constants.OFFSCREEN,
        Constants.OFFSCREEN
    )

end


------------------------------------------------------------
-- SELECTED MARKER
------------------------------------------------------------

function InteractionLogic.hideSelectedMarker(
    self: any
)

    setPosition(
        self.selectedMarkerX,
        self.selectedMarkerY,
        Constants.OFFSCREEN,
        Constants.OFFSCREEN
    )

end


function InteractionLogic.refreshSelectedMarker(
    self: any
)

    if self.selectedPart == "" then

        InteractionLogic.hideSelectedMarker(
            self
        )

        return

    end


    local x, y =
        getPartPosition(
            self,
            self.selectedPart
        )


    setPosition(
        self.selectedMarkerX,
        self.selectedMarkerY,
        x,
        y
    )

end


------------------------------------------------------------
-- POINTER MOVE
------------------------------------------------------------

function InteractionLogic.pointerMove(
    self: any,
    event: PointerEvent
)

    self.targetX =
        event.position.x

    self.targetY =
        event.position.y

end


------------------------------------------------------------
-- UPDATE HOVER TARGET
--
-- IMPORTANT:
--
-- Mouse position decides what object is currently targeted.
--
-- BODY only:
--     body hover
--
-- HOLD only:
--     hold hover, if current selected limb may move there
--
-- BODY + HOLD overlap:
--     close to body center -> BODY
--     outside body core -> HOLD, if valid
------------------------------------------------------------

function InteractionLogic.updateBodyHover(
    self: any
)

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
    -- RAW POINTER POSITION
    --
    -- Interaction follows the actual mouse,
    -- not the smoothed talisman position.
    --------------------------------------------------------

    local x =
        self.targetX

    local y =
        self.targetY


    --------------------------------------------------------
    -- BODY
    --------------------------------------------------------

    local part =
        hitPartAt(
            self,
            x,
            y
        )


    --------------------------------------------------------
    -- HOLD
    --------------------------------------------------------

    local hold =
        nil


    if self.selectedPart ~= "" then

        hold =
            RouteLogic.hitHoldAt(
                self,
                x,
                y
            )

    end


    --------------------------------------------------------
    -- CHECK WHETHER THE HOLD IS CURRENTLY VALID
    --
    -- Hover should not advertise an impossible move.
    --------------------------------------------------------

    local holdIsValid =
        false

    local holdScreenY =
        0


    if
        hold ~= nil
        and
        self.selectedPart ~= ""
    then

        holdScreenY =
            RouteLogic.getScreenY(
                self,
                hold
            )


        if canMovePart(
            self,
            self.selectedPart
        ) then

            local normalReach =
                LimbLogic.isReachable(
                    self,
                    self.selectedPart,
                    hold.x,
                    holdScreenY
                )


            local dynoReach =
                false


            ------------------------------------------------
            -- DYNO
            --
            -- Hand only.
            -- Must be outside normal reach,
            -- inside dyno reach,
            -- and all 4 limbs must currently be supported.
            ------------------------------------------------

            if
                not normalReach
                and
                getSupportCount(self) >= 4
            then

                dynoReach =
                    LimbLogic.isDynoReachable(
                        self,
                        self.selectedPart,
                        hold.x,
                        holdScreenY
                    )

            end


            if
                normalReach
                or
                dynoReach
            then

                local currentHoldId =
                    getPartHoldId(
                        self,
                        self.selectedPart
                    )


                ------------------------------------------------
                -- SAME HOLD IS NOT A MOVE
                ------------------------------------------------

                if currentHoldId ~= hold.id then

                    ------------------------------------------------
                    -- HOLD OCCUPANCY
                    ------------------------------------------------

                    if
                        getHoldOccupancy(
                            self,
                            hold.id
                        )
                        < Constants.MAX_LIMBS_PER_HOLD
                    then

                        ------------------------------------------------
                        -- TOP RULE
                        ------------------------------------------------

                        if hold.kind == "top" then

                            if
                                self.selectedPart == "leftArm"
                                or
                                self.selectedPart == "rightArm"
                            then

                                holdIsValid =
                                    true

                            end

                        else

                            holdIsValid =
                                true

                        end

                    end

                end

            end

        end

    end


    --------------------------------------------------------
    -- NOTHING
    --------------------------------------------------------

    if
        part == ""
        and
        not holdIsValid
    then

        return

    end


    --------------------------------------------------------
    -- BODY ONLY
    --
    -- This also covers:
    -- body + invalid hold.
    --------------------------------------------------------

    if
        part ~= ""
        and
        not holdIsValid
    then

        local bodyX, bodyY =
            getPartPosition(
                self,
                part
            )


        self.hoverTargetType =
            "body"

        self.hoveredPart =
            part

        self.hoveredHoldId =
            0


        showHover(
            self,
            bodyX,
            bodyY
        )


        return

    end


    --------------------------------------------------------
    -- HOLD ONLY
    --------------------------------------------------------

    if
        part == ""
        and
        holdIsValid
    then

        self.hoverTargetType =
            "hold"

        self.hoveredPart =
            ""

        self.hoveredHoldId =
            hold.id


        showHold(
            self,
            hold.x,
            holdScreenY
        )


        return

    end


    --------------------------------------------------------
    -- BODY + VALID HOLD OVERLAP
    --------------------------------------------------------

    local bodyX, bodyY =
        getPartPosition(
            self,
            part
        )


    --------------------------------------------------------
    -- BODY PRIORITY CORE
    --
    -- Body hit area may be 40px for easy hand selection.
    --
    -- But only the inner 18px steals hover from a hold.
    --------------------------------------------------------

    local dx =
        x - bodyX

    local dy =
        y - bodyY


    local bodyCenterDistanceSquared =
        dx * dx
        + dy * dy


    local bodyPriorityRadius =
        18


    --------------------------------------------------------
    -- VERY CLOSE TO BODY CENTER
    --------------------------------------------------------

    if
        bodyCenterDistanceSquared
        <= bodyPriorityRadius
            * bodyPriorityRadius
    then

        self.hoverTargetType =
            "body"

        self.hoveredPart =
            part

        self.hoveredHoldId =
            0


        showHover(
            self,
            bodyX,
            bodyY
        )


        return

    end


    --------------------------------------------------------
    -- OUTSIDE BODY CORE:
    -- HOLD WINS
    --------------------------------------------------------

    self.hoverTargetType =
        "hold"

    self.hoveredPart =
        ""

    self.hoveredHoldId =
        hold.id


    showHold(
        self,
        hold.x,
        holdScreenY
    )

end


------------------------------------------------------------
-- HOLD HOVER
--
-- Hover resolution is now completely handled inside
-- updateBodyHover().
--
-- Kept because track.luau already calls this function.
------------------------------------------------------------

function InteractionLogic.updateHoldHover(
    self: any
)

end


------------------------------------------------------------
-- ACTIVATE HOVERED BODY
--
-- No hit test here.
------------------------------------------------------------

function InteractionLogic.activateHoveredBody(
    self: any
): string

    if self.gameWon then
        return ""
    end


    if self.hoverTargetType ~= "body" then
        return ""
    end


    local part =
        self.hoveredPart


    if part == "" then
        return ""
    end


    --------------------------------------------------------
    -- HEAD
    --------------------------------------------------------

    if part == "head" then
        return "head"
    end


    --------------------------------------------------------
    -- SELECT LIMB
    --------------------------------------------------------

    self.selectedPart =
        part


    InteractionLogic.refreshSelectedMarker(
        self
    )


    return
        part

end


------------------------------------------------------------
-- ACTIVATE HOVERED HOLD
--
-- Hover already chose the hold.
--
-- Click validates the rules again before movement.
------------------------------------------------------------

function InteractionLogic.activateHoveredHold(
    self: any
): boolean

    if self.gameWon then
        return false
    end


    if self.hoverTargetType ~= "hold" then
        return false
    end


    if self.hoveredHoldId == 0 then
        return false
    end


    if self.selectedPart == "" then
        return false
    end


    --------------------------------------------------------
    -- SUPPORT
    --------------------------------------------------------

    if not canMovePart(
        self,
        self.selectedPart
    ) then

        return false

    end


    --------------------------------------------------------
    -- EXACT HOLD CHOSEN BY HOVER
    --------------------------------------------------------

    local hold =
        findHoldById(
            self,
            self.hoveredHoldId
        )


    if hold == nil then
        return false
    end


    --------------------------------------------------------
    -- SAME HOLD
    --------------------------------------------------------

    local currentHoldId =
        getPartHoldId(
            self,
            self.selectedPart
        )


    if currentHoldId == hold.id then
        return false
    end


    --------------------------------------------------------
    -- MAX 2 LIMBS PER HOLD
    --------------------------------------------------------

    if
        getHoldOccupancy(
            self,
            hold.id
        )
        >= Constants.MAX_LIMBS_PER_HOLD
    then

        return false

    end


    --------------------------------------------------------
    -- TOP = HAND ONLY
    --------------------------------------------------------

    if hold.kind == "top" then

        if
            self.selectedPart ~= "leftArm"
            and
            self.selectedPart ~= "rightArm"
        then

            return false

        end

    end


    --------------------------------------------------------
    -- WORLD -> SCREEN
    --------------------------------------------------------

    local holdScreenY =
        RouteLogic.getScreenY(
            self,
            hold
        )


    --------------------------------------------------------
    -- NORMAL OR DYNO REACH
    --------------------------------------------------------

    local normalReach =
        LimbLogic.isReachable(
            self,
            self.selectedPart,
            hold.x,
            holdScreenY
        )


    local dynoReach =
        false


    if
        not normalReach
        and
        getSupportCount(self) >= 4
    then

        dynoReach =
            LimbLogic.isDynoReachable(
                self,
                self.selectedPart,
                hold.x,
                holdScreenY
            )

    end


    if
        not normalReach
        and
        not dynoReach
    then

        return false

    end


    self.isDyno =
        dynoReach


    --------------------------------------------------------
    -- RELEASE OLD HOLD
    --------------------------------------------------------

    detachPartFromHold(
        self,
        self.selectedPart
    )


    --------------------------------------------------------
    -- START MOVEMENT
    --------------------------------------------------------

    self.movingPart =
        self.selectedPart


    self.moveTargetX =
        hold.x


    self.moveTargetY =
        holdScreenY


    self.targetHoldId =
        hold.id


    self.targetHoldKind =
        hold.kind


    self.isMoving =
        true


    --------------------------------------------------------
    -- EFFECTS
    --------------------------------------------------------

    InteractionLogic.hideHover(
        self
    )


    InteractionLogic.hideHold(
        self
    )


    showConfirm(
        self,
        hold.x,
        holdScreenY
    )


    return true

end


------------------------------------------------------------
-- CLICK BODY
--
-- Kept for compatibility.
------------------------------------------------------------

function InteractionLogic.clickBody(
    self: any,
    x: number,
    y: number
): string

    if self.gameWon then
        return ""
    end


    local part =
        hitPartAt(
            self,
            x,
            y
        )


    if part == "" then
        return ""
    end


    if part == "head" then
        return "head"
    end


    self.selectedPart =
        part


    InteractionLogic.refreshSelectedMarker(
        self
    )


    return
        part

end


------------------------------------------------------------
-- CLICK HOLD
--
-- Kept for compatibility.
------------------------------------------------------------

function InteractionLogic.clickHold(
    self: any,
    x: number,
    y: number
): boolean

    if self.gameWon then
        return false
    end


    if self.selectedPart == "" then
        return false
    end


    --------------------------------------------------------
    -- SUPPORT
    --------------------------------------------------------

    if not canMovePart(
        self,
        self.selectedPart
    ) then

        return false

    end


    --------------------------------------------------------
    -- FIND HOLD
    --------------------------------------------------------

    local hold =
        RouteLogic.hitHoldAt(
            self,
            x,
            y
        )


    if hold == nil then
        return false
    end


    --------------------------------------------------------
    -- SAME HOLD
    --------------------------------------------------------

    local currentHoldId =
        getPartHoldId(
            self,
            self.selectedPart
        )


    if currentHoldId == hold.id then
        return false
    end


    --------------------------------------------------------
    -- MAX 2 LIMBS
    --------------------------------------------------------

    if
        getHoldOccupancy(
            self,
            hold.id
        )
        >= Constants.MAX_LIMBS_PER_HOLD
    then

        return false

    end


    --------------------------------------------------------
    -- TOP
    --------------------------------------------------------

    if hold.kind == "top" then

        if
            self.selectedPart ~= "leftArm"
            and
            self.selectedPart ~= "rightArm"
        then

            return false

        end

    end


    --------------------------------------------------------
    -- WORLD -> SCREEN
    --------------------------------------------------------

    local holdScreenY =
        RouteLogic.getScreenY(
            self,
            hold
        )


    --------------------------------------------------------
    -- NORMAL OR DYNO REACH
    --------------------------------------------------------

    local normalReach =
        LimbLogic.isReachable(
            self,
            self.selectedPart,
            hold.x,
            holdScreenY
        )


    local dynoReach =
        false


    if
        not normalReach
        and
        getSupportCount(self) >= 4
    then

        dynoReach =
            LimbLogic.isDynoReachable(
                self,
                self.selectedPart,
                hold.x,
                holdScreenY
            )

    end


    if
        not normalReach
        and
        not dynoReach
    then

        return false

    end


    self.isDyno =
        dynoReach


    --------------------------------------------------------
    -- DETACH
    --------------------------------------------------------

    detachPartFromHold(
        self,
        self.selectedPart
    )


    --------------------------------------------------------
    -- MOVE
    --------------------------------------------------------

    self.movingPart =
        self.selectedPart


    self.moveTargetX =
        hold.x


    self.moveTargetY =
        holdScreenY


    self.targetHoldId =
        hold.id


    self.targetHoldKind =
        hold.kind


    self.isMoving =
        true


    --------------------------------------------------------
    -- EFFECTS
    --------------------------------------------------------

    InteractionLogic.hideHover(
        self
    )


    InteractionLogic.hideHold(
        self
    )


    showConfirm(
        self,
        hold.x,
        holdScreenY
    )


    return true

end


------------------------------------------------------------
-- CONFIRM TIMER
------------------------------------------------------------

function InteractionLogic.advanceConfirm(
    self: any,
    seconds: number
)

    if self.gameWon then
        return
    end


    if self.confirmTimer <= 0 then
        return
    end


    self.confirmTimer =
        self.confirmTimer
        - seconds


    if self.confirmTimer <= 0 then

        self.confirmTimer =
            0


        InteractionLogic.hideConfirm(
            self
        )

    end

end


return InteractionLogic