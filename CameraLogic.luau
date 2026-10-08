local Constants = require("GameConstants")


local CameraLogic = {}


------------------------------------------------------------
-- SHIFT CHARACTER SCREEN SPACE
------------------------------------------------------------

local function shiftCharacterDown(
    self: any,
    amount: number
)

    if amount <= 0 then
        return
    end


    --------------------------------------------------------
    -- BODY
    --------------------------------------------------------

    self.bodyPositionY =
        self.bodyPositionY + amount


    self.bodyTargetY =
        self.bodyTargetY + amount


    --------------------------------------------------------
    -- LIMB ENDPOINTS
    --------------------------------------------------------

    self.leftHandY =
        self.leftHandY + amount


    self.rightHandY =
        self.rightHandY + amount


    self.leftFootY =
        self.leftFootY + amount


    self.rightFootY =
        self.rightFootY + amount


    --------------------------------------------------------
    -- ACTIVE MOVE TARGET
    --------------------------------------------------------

    if self.isMoving then

        self.moveTargetY =
            self.moveTargetY + amount

    end


    --------------------------------------------------------
    -- CONFIRM EFFECT
    --
    -- Confirm exists in screen space.
    -- Keep it attached while camera scrolls.
    --------------------------------------------------------

    if
        self.confirmTimer > 0
        and
        self.confirmHaloY ~= nil
    then

        self.confirmHaloY.value =
            self.confirmHaloY.value + amount

    end

end


------------------------------------------------------------
-- CAMERA FOLLOW
------------------------------------------------------------

function CameraLogic.advance(
    self: any
): boolean

    --------------------------------------------------------
    -- Already at top of world.
    --------------------------------------------------------

    if self.cameraY <= 0 then

        self.cameraY = 0

        return false

    end


    --------------------------------------------------------
    -- Character has not crossed follow line yet.
    --------------------------------------------------------

    if
        self.bodyPositionY
        >= Constants.CAMERA_FOLLOW_Y
    then

        return false

    end


    --------------------------------------------------------
    -- How far body moved above camera follow line.
    --------------------------------------------------------

    local desiredShift =
        Constants.CAMERA_FOLLOW_Y
        - self.bodyPositionY


    --------------------------------------------------------
    -- Camera cannot go above world Y = 0.
    --------------------------------------------------------

    local newCameraY =
        math.max(
            0,
            self.cameraY - desiredShift
        )


    local actualShift =
        self.cameraY - newCameraY


    if actualShift <= 0 then
        return false
    end


    --------------------------------------------------------
    -- MOVE CAMERA UP THROUGH WORLD
    --------------------------------------------------------

    self.cameraY =
        newCameraY


    --------------------------------------------------------
    -- COMPENSATE CHARACTER SCREEN POSITION
    --------------------------------------------------------

    shiftCharacterDown(
        self,
        actualShift
    )


    return true

end


return CameraLogic