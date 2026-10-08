local Constants = require("GameConstants")


local BodyLogic = {}


local function setNumber(
    property: Property<number>?,
    value: number
)

    if property ~= nil then
        property.value = value
    end

end


------------------------------------------------------------
-- CALCULATE BODY TARGET
------------------------------------------------------------

function BodyLogic.recalculateTarget(
    self: any
)

    local averageX =
        (
            self.leftHandX
            + self.rightHandX
            + self.leftFootX
            + self.rightFootX
        ) / 4


    local averageY =
        (
            self.leftHandY
            + self.rightHandY
            + self.leftFootY
            + self.rightFootY
        ) / 4


    self.bodyTargetX =
        averageX


    self.bodyTargetY =
        averageY
        - Constants.BODY_ENDPOINT_Y_OFFSET

end


------------------------------------------------------------
-- VISUAL ROOT
------------------------------------------------------------

function BodyLogic.updateVisuals(
    self: any
)

    setNumber(
        self.headX,
        self.bodyPositionX
            + Constants.HEAD_OFFSET_X
    )


    setNumber(
        self.headY,
        self.bodyPositionY
            + Constants.HEAD_OFFSET_Y
    )

end


------------------------------------------------------------
-- BODY FOLLOW
------------------------------------------------------------

function BodyLogic.advance(
    self: any,
    seconds: number
)

    local k =
        1 - math.exp(
            -Constants.BODY_FOLLOW_SPEED
            * seconds
        )


    self.bodyPositionX =
        self.bodyPositionX
        + (
            self.bodyTargetX
            - self.bodyPositionX
        ) * k


    self.bodyPositionY =
        self.bodyPositionY
        + (
            self.bodyTargetY
            - self.bodyPositionY
        ) * k


    BodyLogic.updateVisuals(self)

end


return BodyLogic