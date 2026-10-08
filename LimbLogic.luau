local Constants = require("GameConstants")


local LimbLogic = {}


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


local function lerp(
    a: number,
    b: number,
    t: number
): number

    return a + (b - a) * t

end


local function distance(
    x1: number,
    y1: number,
    x2: number,
    y2: number
): number

    local dx = x2 - x1
    local dy = y2 - y1

    return math.sqrt(
        dx * dx
        + dy * dy
    )

end


------------------------------------------------------------
-- CURRENT ANCHORS
------------------------------------------------------------

local function getLeftShoulder(
    self: any
): (number, number)

    return
        self.bodyPositionX
            + Constants.LEFT_SHOULDER_OFFSET_X,

        self.bodyPositionY
            + Constants.LEFT_SHOULDER_OFFSET_Y

end


local function getRightShoulder(
    self: any
): (number, number)

    return
        self.bodyPositionX
            + Constants.RIGHT_SHOULDER_OFFSET_X,

        self.bodyPositionY
            + Constants.RIGHT_SHOULDER_OFFSET_Y

end


local function getLeftHip(
    self: any
): (number, number)

    return
        self.bodyPositionX
            + Constants.LEFT_HIP_OFFSET_X,

        self.bodyPositionY
            + Constants.LEFT_HIP_OFFSET_Y

end


local function getRightHip(
    self: any
): (number, number)

    return
        self.bodyPositionX
            + Constants.RIGHT_HIP_OFFSET_X,

        self.bodyPositionY
            + Constants.RIGHT_HIP_OFFSET_Y

end


------------------------------------------------------------
-- WRITE LIMB
------------------------------------------------------------

local function writeLimb(
    x0: Property<number>?,
    y0: Property<number>?,

    x1: Property<number>?,
    y1: Property<number>?,

    x2: Property<number>?,
    y2: Property<number>?,

    x3: Property<number>?,
    y3: Property<number>?,

    x4: Property<number>?,
    y4: Property<number>?,

    anchorX: number,
    anchorY: number,

    endX: number,
    endY: number
)

    setNumber(x0, anchorX)
    setNumber(y0, anchorY)

    setNumber(
        x1,
        lerp(anchorX, endX, 0.25)
    )

    setNumber(
        y1,
        lerp(anchorY, endY, 0.25)
    )

    setNumber(
        x2,
        lerp(anchorX, endX, 0.5)
    )

    setNumber(
        y2,
        lerp(anchorY, endY, 0.5)
    )

    setNumber(
        x3,
        lerp(anchorX, endX, 0.75)
    )

    setNumber(
        y3,
        lerp(anchorY, endY, 0.75)
    )

    setNumber(x4, endX)
    setNumber(y4, endY)

end


------------------------------------------------------------
-- PART POSITION
------------------------------------------------------------

local function setPartPosition(
    self: any,
    part: string,
    x: number,
    y: number
)

    if part == "leftArm" then

        self.leftHandX = x
        self.leftHandY = y


    elseif part == "rightArm" then

        self.rightHandX = x
        self.rightHandY = y


    elseif part == "leftLeg" then

        self.leftFootX = x
        self.leftFootY = y


    elseif part == "rightLeg" then

        self.rightFootX = x
        self.rightFootY = y

    end

end


------------------------------------------------------------
-- MATCHED HOLD POSITIONING
--
-- If one limb occupies a hold:
--     stay exactly at hold center.
--
-- If two limbs occupy the same hold:
--     move them slightly apart so they remain selectable.
--
-- These are REAL endpoint positions, not visual-only offsets.
-- Therefore hover / click / selected marker stay aligned.
------------------------------------------------------------

local function syncMatchedHoldPositions(
    self: any
)

    if self.currentRoute == nil then
        return
    end


    for _, hold in self.currentRoute.holds do

        local occupants = {}


        --------------------------------------------------------
        -- FIND LIMBS ATTACHED TO THIS HOLD
        --------------------------------------------------------

        if self.leftHandHoldId == hold.id then

            occupants[#occupants + 1] =
                "leftArm"

        end


        if self.rightHandHoldId == hold.id then

            occupants[#occupants + 1] =
                "rightArm"

        end


        if self.leftFootHoldId == hold.id then

            occupants[#occupants + 1] =
                "leftLeg"

        end


        if self.rightFootHoldId == hold.id then

            occupants[#occupants + 1] =
                "rightLeg"

        end


        local count =
            #occupants


        if count == 0 then
            continue
        end


        --------------------------------------------------------
        -- WORLD HOLD -> SCREEN Y
        --------------------------------------------------------

        local holdScreenY =
            hold.y - self.cameraY


        --------------------------------------------------------
        -- ONE LIMB
        --
        -- Stay centered on the hold.
        --------------------------------------------------------

        if count == 1 then

            setPartPosition(
                self,
                occupants[1],
                hold.x,
                holdScreenY
            )


        --------------------------------------------------------
        -- TWO LIMBS
        --
        -- Slight stagger:
        --
        -- first  = upper-left
        -- second = lower-right
        --
        -- Enough separation to click either one,
        -- but still visually reads as both using same hold.
        --------------------------------------------------------

        elseif count >= 2 then

            local offsetX = 12
            local offsetY = 5


            setPartPosition(
                self,
                occupants[1],
                hold.x - offsetX,
                holdScreenY - offsetY
            )


            setPartPosition(
                self,
                occupants[2],
                hold.x + offsetX,
                holdScreenY + offsetY
            )

        end

    end

end


------------------------------------------------------------
-- UPDATE ALL
------------------------------------------------------------

function LimbLogic.updateAll(
    self: any
)

    --------------------------------------------------------
    -- KEEP ATTACHED LIMBS ALIGNED WITH THEIR HOLDS
    --
    -- This also:
    -- 1. separates two limbs sharing one hold
    -- 2. recenters the remaining limb when the other leaves
    -- 3. keeps endpoints correct while camera moves
    --------------------------------------------------------

    syncMatchedHoldPositions(
        self
    )


    local leftShoulderX,
        leftShoulderY =
        getLeftShoulder(self)


    writeLimb(
        self.la0x,
        self.la0y,

        self.la1x,
        self.la1y,

        self.la2x,
        self.la2y,

        self.la3x,
        self.la3y,

        self.la4x,
        self.la4y,

        leftShoulderX,
        leftShoulderY,

        self.leftHandX,
        self.leftHandY
    )


    local rightShoulderX,
        rightShoulderY =
        getRightShoulder(self)


    writeLimb(
        self.ra0x,
        self.ra0y,

        self.ra1x,
        self.ra1y,

        self.ra2x,
        self.ra2y,

        self.ra3x,
        self.ra3y,

        self.ra4x,
        self.ra4y,

        rightShoulderX,
        rightShoulderY,

        self.rightHandX,
        self.rightHandY
    )


    local leftHipX,
        leftHipY =
        getLeftHip(self)


    writeLimb(
        self.ll0x,
        self.ll0y,

        self.ll1x,
        self.ll1y,

        self.ll2x,
        self.ll2y,

        self.ll3x,
        self.ll3y,

        self.ll4x,
        self.ll4y,

        leftHipX,
        leftHipY,

        self.leftFootX,
        self.leftFootY
    )


    local rightHipX,
        rightHipY =
        getRightHip(self)


    writeLimb(
        self.rl0x,
        self.rl0y,

        self.rl1x,
        self.rl1y,

        self.rl2x,
        self.rl2y,

        self.rl3x,
        self.rl3y,

        self.rl4x,
        self.rl4y,

        rightHipX,
        rightHipY,

        self.rightFootX,
        self.rightFootY
    )

end


------------------------------------------------------------
-- REACHABILITY
------------------------------------------------------------

function LimbLogic.isReachable(
    self: any,
    part: string,
    holdX: number,
    holdY: number
): boolean

    if part == "leftArm" then

        local x, y =
            getLeftShoulder(self)

        return distance(
            x,
            y,
            holdX,
            holdY
        ) <= Constants.ARM_REACH

    end


    if part == "rightArm" then

        local x, y =
            getRightShoulder(self)

        return distance(
            x,
            y,
            holdX,
            holdY
        ) <= Constants.ARM_REACH

    end


    if part == "leftLeg" then

        local x, y =
            getLeftHip(self)

        return distance(
            x,
            y,
            holdX,
            holdY
        ) <= Constants.LEG_REACH

    end


    if part == "rightLeg" then

        local x, y =
            getRightHip(self)

        return distance(
            x,
            y,
            holdX,
            holdY
        ) <= Constants.LEG_REACH

    end


    return false

end

------------------------------------------------------------
-- DYNO REACHABILITY
--
-- Dyno is HAND ONLY.
--
-- It must be:
--     outside normal arm reach
--     but inside DYNO_REACH.
------------------------------------------------------------

function LimbLogic.isDynoReachable(
    self: any,
    part: string,
    holdX: number,
    holdY: number
): boolean

    --------------------------------------------------------
    -- HANDS ONLY
    --------------------------------------------------------

    if
        part ~= "leftArm"
        and
        part ~= "rightArm"
    then

        return false

    end


    local anchorX = 0
    local anchorY = 0


    if part == "leftArm" then

        anchorX, anchorY =
            getLeftShoulder(
                self
            )


    elseif part == "rightArm" then

        anchorX, anchorY =
            getRightShoulder(
                self
            )

    end


    local d =
        distance(
            anchorX,
            anchorY,
            holdX,
            holdY
        )


    --------------------------------------------------------
    -- NORMAL REACH IS NOT DYNO
    --------------------------------------------------------

    if d <= Constants.ARM_REACH then
        return false
    end


    --------------------------------------------------------
    -- DYNO WINDOW
    --------------------------------------------------------

    return
        d <= Constants.DYNO_REACH

end


------------------------------------------------------------
-- ATTACH
------------------------------------------------------------

local function attachMovingPartToHold(
    self: any
)

    if self.targetHoldId == 0 then
        return
    end


    if self.movingPart == "leftArm" then

        self.leftHandHoldId =
            self.targetHoldId


    elseif self.movingPart == "rightArm" then

        self.rightHandHoldId =
            self.targetHoldId


    elseif self.movingPart == "leftLeg" then

        self.leftFootHoldId =
            self.targetHoldId


    elseif self.movingPart == "rightLeg" then

        self.rightFootHoldId =
            self.targetHoldId

    end


    --------------------------------------------------------
    -- IMMEDIATELY APPLY MATCH POSITION
    --
    -- This makes body target calculation use the final
    -- staggered positions on the same frame.
    --------------------------------------------------------

    syncMatchedHoldPositions(
        self
    )

end


------------------------------------------------------------
-- WIN
------------------------------------------------------------

local function checkWin(
    self: any
)

    if self.targetHoldKind ~= "top" then
        return
    end


    if
        self.movingPart ~= "leftArm"
        and
        self.movingPart ~= "rightArm"
    then

        return

    end


    --------------------------------------------------------
    -- WIN
    --------------------------------------------------------

    self.gameWon =
        true


    self.selectedPart =
        ""


    --------------------------------------------------------
    -- HIDE NORMAL EFFECTS
    --------------------------------------------------------

    setNumber(
        self.selectionHaloX,
        Constants.OFFSCREEN
    )

    setNumber(
        self.selectionHaloY,
        Constants.OFFSCREEN
    )


    setNumber(
        self.holdHoverX,
        Constants.OFFSCREEN
    )

    setNumber(
        self.holdHoverY,
        Constants.OFFSCREEN
    )


    setNumber(
        self.selectedMarkerX,
        Constants.OFFSCREEN
    )

    setNumber(
        self.selectedMarkerY,
        Constants.OFFSCREEN
    )


    --------------------------------------------------------
    -- KEEP CONFIRM HALO ON TOP HOLD
    --
    -- Temporary prototype win feedback.
    --------------------------------------------------------

    setNumber(
        self.confirmHaloX,
        self.moveTargetX
    )

    setNumber(
        self.confirmHaloY,
        self.moveTargetY
    )


    self.confirmTimer =
        -1

end


------------------------------------------------------------
-- UPDATE MOVEMENT
------------------------------------------------------------

function LimbLogic.updateMovement(
    self: any,
    seconds: number
)

    if not self.isMoving then
        return
    end


    local movementSpeed =
        8


    if self.isDyno then

        movementSpeed =
            15

    end


    local k =
        1 - math.exp(
            -movementSpeed * seconds
        )


    --------------------------------------------------------
    -- MOVE ENDPOINT
    --------------------------------------------------------

    if self.movingPart == "leftArm" then

        self.leftHandX =
            self.leftHandX
            + (
                self.moveTargetX
                - self.leftHandX
            ) * k


        self.leftHandY =
            self.leftHandY
            + (
                self.moveTargetY
                - self.leftHandY
            ) * k


    elseif self.movingPart == "rightArm" then

        self.rightHandX =
            self.rightHandX
            + (
                self.moveTargetX
                - self.rightHandX
            ) * k


        self.rightHandY =
            self.rightHandY
            + (
                self.moveTargetY
                - self.rightHandY
            ) * k


    elseif self.movingPart == "leftLeg" then

        self.leftFootX =
            self.leftFootX
            + (
                self.moveTargetX
                - self.leftFootX
            ) * k


        self.leftFootY =
            self.leftFootY
            + (
                self.moveTargetY
                - self.leftFootY
            ) * k


    elseif self.movingPart == "rightLeg" then

        self.rightFootX =
            self.rightFootX
            + (
                self.moveTargetX
                - self.rightFootX
            ) * k


        self.rightFootY =
            self.rightFootY
            + (
                self.moveTargetY
                - self.rightFootY
            ) * k

    end


    --------------------------------------------------------
    -- CURRENT ENDPOINT
    --------------------------------------------------------

    local currentX = 0
    local currentY = 0


    if self.movingPart == "leftArm" then

        currentX = self.leftHandX
        currentY = self.leftHandY


    elseif self.movingPart == "rightArm" then

        currentX = self.rightHandX
        currentY = self.rightHandY


    elseif self.movingPart == "leftLeg" then

        currentX = self.leftFootX
        currentY = self.leftFootY


    elseif self.movingPart == "rightLeg" then

        currentX = self.rightFootX
        currentY = self.rightFootY

    end


    local remaining =
        distance(
            currentX,
            currentY,
            self.moveTargetX,
            self.moveTargetY
        )


    --------------------------------------------------------
    -- ARRIVED
    --------------------------------------------------------

    if remaining <= 1 then

        ----------------------------------------------------
        -- SNAP EXACTLY TO HOLD CENTER FIRST
        ----------------------------------------------------

        if self.movingPart == "leftArm" then

            self.leftHandX =
                self.moveTargetX

            self.leftHandY =
                self.moveTargetY


        elseif self.movingPart == "rightArm" then

            self.rightHandX =
                self.moveTargetX

            self.rightHandY =
                self.moveTargetY


        elseif self.movingPart == "leftLeg" then

            self.leftFootX =
                self.moveTargetX

            self.leftFootY =
                self.moveTargetY


        elseif self.movingPart == "rightLeg" then

            self.rightFootX =
                self.moveTargetX

            self.rightFootY =
                self.moveTargetY

        end


        ----------------------------------------------------
        -- ATTACH NEW SUPPORT
        --
        -- attachMovingPartToHold() also applies match
        -- offsets if another limb already uses this hold.
        ----------------------------------------------------

        attachMovingPartToHold(
            self
        )


        ----------------------------------------------------
        -- CHECK TOP / WIN
        ----------------------------------------------------

        checkWin(
            self
        )


        ----------------------------------------------------
        -- BODY FOLLOWS NEW CONFIGURATION
        ----------------------------------------------------

        self.needsBodyTargetUpdate =
            true


        ----------------------------------------------------
        -- FINISH MOVEMENT
        ----------------------------------------------------

        self.isMoving =
            false


        self.movingPart =
            ""


        self.targetHoldId =
            0


        self.targetHoldKind =
            ""
        
        self.isDyno =
            false

    end


    LimbLogic.updateAll(
        self
    )

end


return LimbLogic