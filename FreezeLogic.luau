local Constants = require("GameConstants")


local FreezeLogic = {}


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
-- FREEZE DOT POSITIONS
------------------------------------------------------------

local function getDotPositions(
    self: any
): (
    number,
    number,
    number,
    number
)

    local headX, headY =
        getHeadPosition(self)


    local dotY =
        headY - 60


    local leftX =
        headX - 30


    local middleX =
        headX


    local rightX =
        headX + 30


    return
        leftX,
        middleX,
        rightX,
        dotY

end


------------------------------------------------------------
-- HIDE DOTS
------------------------------------------------------------

function FreezeLogic.hideDots(
    self: any
)

    setPosition(
        self.freezeDot3X,
        self.freezeDot3Y,
        Constants.OFFSCREEN,
        Constants.OFFSCREEN
    )


    setPosition(
        self.freezeDot2X,
        self.freezeDot2Y,
        Constants.OFFSCREEN,
        Constants.OFFSCREEN
    )


    setPosition(
        self.freezeDot1X,
        self.freezeDot1Y,
        Constants.OFFSCREEN,
        Constants.OFFSCREEN
    )

end


------------------------------------------------------------
-- SHOW 3 DOTS
------------------------------------------------------------

function FreezeLogic.showAllDots(
    self: any
)

    local leftX,
        middleX,
        rightX,
        dotY =
        getDotPositions(self)


    setPosition(
        self.freezeDot3X,
        self.freezeDot3Y,
        leftX,
        dotY
    )


    setPosition(
        self.freezeDot2X,
        self.freezeDot2Y,
        middleX,
        dotY
    )


    setPosition(
        self.freezeDot1X,
        self.freezeDot1Y,
        rightX,
        dotY
    )

end


------------------------------------------------------------
-- UPDATE DOTS
------------------------------------------------------------

function FreezeLogic.updateDots(
    self: any
)

    local leftX,
        middleX,
        rightX,
        dotY =
        getDotPositions(self)


    --------------------------------------------------------
    -- 3 DOTS
    --------------------------------------------------------

    if self.freezeTimer > 2 then

        setPosition(
            self.freezeDot3X,
            self.freezeDot3Y,
            leftX,
            dotY
        )


        setPosition(
            self.freezeDot2X,
            self.freezeDot2Y,
            middleX,
            dotY
        )


        setPosition(
            self.freezeDot1X,
            self.freezeDot1Y,
            rightX,
            dotY
        )


        return

    end


    --------------------------------------------------------
    -- 2 DOTS
    --------------------------------------------------------

    if self.freezeTimer > 1 then

        setPosition(
            self.freezeDot3X,
            self.freezeDot3Y,
            Constants.OFFSCREEN,
            Constants.OFFSCREEN
        )


        setPosition(
            self.freezeDot2X,
            self.freezeDot2Y,
            middleX - 15,
            dotY
        )


        setPosition(
            self.freezeDot1X,
            self.freezeDot1Y,
            middleX + 15,
            dotY
        )


        return

    end


    --------------------------------------------------------
    -- 1 DOT
    --------------------------------------------------------

    if self.freezeTimer > 0 then

        setPosition(
            self.freezeDot3X,
            self.freezeDot3Y,
            Constants.OFFSCREEN,
            Constants.OFFSCREEN
        )


        setPosition(
            self.freezeDot2X,
            self.freezeDot2Y,
            Constants.OFFSCREEN,
            Constants.OFFSCREEN
        )


        setPosition(
            self.freezeDot1X,
            self.freezeDot1Y,
            middleX,
            dotY
        )


        return

    end


    FreezeLogic.hideDots(self)

end


------------------------------------------------------------
-- START FREEZE
------------------------------------------------------------

function FreezeLogic.start(
    self: any
)

    self.isFrozen = true

    self.freezeTimer =
        Constants.FREEZE_SECONDS


    self.selectedPart = ""


    FreezeLogic.showAllDots(
        self
    )

end


------------------------------------------------------------
-- ADVANCE
------------------------------------------------------------

function FreezeLogic.advance(
    self: any,
    seconds: number
): boolean

    if not self.isFrozen then
        return false
    end


    self.freezeTimer =
        self.freezeTimer - seconds


    FreezeLogic.updateDots(
        self
    )


    if self.freezeTimer <= 0 then

        self.freezeTimer = 0

        self.isFrozen = false


        FreezeLogic.hideDots(
            self
        )

    end


    return true

end


return FreezeLogic