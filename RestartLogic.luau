local Constants = require("GameConstants")
local BodyLogic = require("BodyLogic")
local LimbLogic = require("LimbLogic")
local RouteLogic = require("RouteLogic")
local FreezeLogic = require("FreezeLogic")
local InteractionLogic = require("InteractionLogic")


local RestartLogic = {}


------------------------------------------------------------
-- HIT TEST
------------------------------------------------------------

function RestartLogic.hitTest(
    x: number,
    y: number
): boolean

    return
        x >= Constants.RESTART_X - Constants.RESTART_HALF_SIZE
        and
        x <= Constants.RESTART_X + Constants.RESTART_HALF_SIZE
        and
        y >= Constants.RESTART_Y - Constants.RESTART_HALF_SIZE
        and
        y <= Constants.RESTART_Y + Constants.RESTART_HALF_SIZE

end


------------------------------------------------------------
-- RESTART CURRENT CLIMB
--
-- IMPORTANT:
-- Route does NOT change.
-- Future sunrise timer / elapsed game time must NOT be reset here.
------------------------------------------------------------

function RestartLogic.restart(
    self: any
)

    --------------------------------------------------------
    -- CAMERA
    --------------------------------------------------------

    self.cameraY =
        Constants.INITIAL_CAMERA_Y


    --------------------------------------------------------
    -- BODY
    --------------------------------------------------------

    self.bodyPositionX =
        Constants.INITIAL_BODY_X

    self.bodyPositionY =
        Constants.INITIAL_BODY_Y


    self.bodyTargetX =
        Constants.INITIAL_BODY_X

    self.bodyTargetY =
        Constants.INITIAL_BODY_Y


    self.needsBodyTargetUpdate =
        false


    --------------------------------------------------------
    -- LIMB ENDPOINTS
    --------------------------------------------------------

    self.leftHandX =
        Constants.INITIAL_LEFT_HAND_X

    self.leftHandY =
        Constants.INITIAL_LEFT_HAND_Y


    self.rightHandX =
        Constants.INITIAL_RIGHT_HAND_X

    self.rightHandY =
        Constants.INITIAL_RIGHT_HAND_Y


    self.leftFootX =
        Constants.INITIAL_LEFT_FOOT_X

    self.leftFootY =
        Constants.INITIAL_LEFT_FOOT_Y


    self.rightFootX =
        Constants.INITIAL_RIGHT_FOOT_X

    self.rightFootY =
        Constants.INITIAL_RIGHT_FOOT_Y


    --------------------------------------------------------
    -- SUPPORT STATE
    --------------------------------------------------------

    self.leftHandHoldId = 0
    self.rightHandHoldId = 0
    self.leftFootHoldId = 0
    self.rightFootHoldId = 0


    --------------------------------------------------------
    -- MOVEMENT
    --------------------------------------------------------

    self.moveTargetX = 0
    self.moveTargetY = 0

    self.movingPart = ""

    self.targetHoldId = 0
    self.targetHoldKind = ""

    self.isMoving = false


    --------------------------------------------------------
    -- SELECTION
    --------------------------------------------------------

    self.hoveredPart = ""
    self.selectedPart = ""


    --------------------------------------------------------
    -- FREEZE
    --------------------------------------------------------

    self.isFrozen = false
    self.freezeTimer = 0

    FreezeLogic.hideDots(
        self
    )


    --------------------------------------------------------
    -- WIN
    --------------------------------------------------------

    self.gameWon = false


    --------------------------------------------------------
    -- EFFECTS
    --------------------------------------------------------

    self.confirmTimer = 0

    InteractionLogic.hideHover(
        self
    )

    InteractionLogic.hideSelectedMarker(
        self
    )

    InteractionLogic.hideHold(
        self
    )

    InteractionLogic.hideConfirm(
        self
    )


    --------------------------------------------------------
    -- CHARACTER VISUAL
    --------------------------------------------------------

    BodyLogic.updateVisuals(
        self
    )

    LimbLogic.updateAll(
        self
    )


    --------------------------------------------------------
    -- SAME ROUTE, BACK TO BOTTOM
    --------------------------------------------------------

    RouteLogic.updateVisualSlots(
        self
    )

end


return RestartLogic