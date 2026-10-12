local Constants = require("GameConstants")
local GameMath = require("GameMath")


local RouteLogic = {}


------------------------------------------------------------
-- ROUTES
--
-- IMPORTANT:
-- x = screen/world horizontal coordinate
-- y = WORLD vertical coordinate
--
-- Larger Y = lower on wall.
-- Smaller Y = higher on wall.
------------------------------------------------------------

RouteLogic.routes = {

                --------------------------------------------------------
                -- ROUTE 01
                -- MOON LADDER
                --------------------------------------------------------

                {
                id = "route_01",
                name = "Moon Ladder",

                holds = {

                { id = 1,  x = 185, y = 1845, kind = "start" },
                { id = 2,  x = 315, y = 1825, kind = "start" },

                { id = 3,  x = 175, y = 1715, kind = "normal" },
                { id = 4,  x = 300, y = 1605, kind = "normal" },

                { id = 5,  x = 210, y = 1495, kind = "normal" },
                { id = 6,  x = 320, y = 1385, kind = "normal" },

                { id = 7,  x = 225, y = 1275, kind = "normal" },
                { id = 8,  x = 430, y = 1150, kind = "normal" },

                { id = 9,  x = 275, y = 1055, kind = "normal" },
                { id = 10, x = 340, y = 945,  kind = "normal" },

                { id = 11, x = 235, y = 835,  kind = "normal" },

                { id = 12, x = 250, y = 710,  kind = "top" },
                }
                },


                --------------------------------------------------------
                -- ROUTE 02
                -- GHOST TRAVERSE
                --------------------------------------------------------

                {
                id = "route_02",
                name = "Ghost Traverse",

                holds = {

                { id = 1,  x = 180, y = 1845, kind = "start" },
                { id = 2,  x = 305, y = 1825, kind = "start" },

                { id = 3,  x = 145, y = 1715, kind = "normal" },
                { id = 4,  x = 255, y = 1605, kind = "normal" },

                { id = 5,  x = 350, y = 1495, kind = "normal" },
                { id = 6,  x = 275, y = 1385, kind = "normal" },

                { id = 7,  x = 165, y = 1275, kind = "normal" },
                { id = 8,  x = 120, y = 1165, kind = "normal" },

                { id = 9,  x = 230, y = 1055, kind = "normal" },
                { id = 10, x = 340, y = 945,  kind = "normal" },

                { id = 11, x = 270, y = 835,  kind = "normal" },

                { id = 12, x = 250, y = 710,  kind = "top" },
                }
                },


                --------------------------------------------------------
                -- ROUTE 03
                -- COFFIN LINE
                --------------------------------------------------------

                {
                id = "route_03",
                name = "Coffin Line",

                holds = {

                { id = 1,  x = 195, y = 1845, kind = "start" },
                { id = 2,  x = 310, y = 1825, kind = "start" },

                { id = 3,  x = 335, y = 1715, kind = "normal" },
                { id = 4,  x = 235, y = 1605, kind = "normal" },

                { id = 5,  x = 125, y = 1495, kind = "normal" },
                { id = 6,  x = 190, y = 1385, kind = "normal" },

                { id = 7,  x = 315, y = 1275, kind = "normal" },
                { id = 8,  x = 380, y = 1165, kind = "normal" },

                { id = 9,  x = 275, y = 1055, kind = "normal" },
                { id = 10, x = 155, y = 945,  kind = "normal" },

                { id = 11, x = 220, y = 835,  kind = "normal" },

                { id = 12, x = 250, y = 710,  kind = "top" },
                }
                },
}


------------------------------------------------------------
-- RANDOM ROUTE
------------------------------------------------------------

function RouteLogic.pickRandomRoute(
    self: any,
    variation: number?
)

    local count = #RouteLogic.routes
    local index: number

    if variation ~= nil then
        -- Use the variation collected during the intro.
        index = (math.floor(variation) % count) + 1
    else
        -- Fallback for the initial setup.
        index = math.random(1, count)
    end

    self.currentRoute = RouteLogic.routes[index]
    self.currentRouteIndex = index

    print("Selected route:", index, self.currentRoute.name)

end


------------------------------------------------------------
-- GET HOLD
------------------------------------------------------------

function RouteLogic.getHold(
    self: any,
    index: number
): any

    if self.currentRoute == nil then
        return nil
    end


    return
        self.currentRoute.holds[index]

end


------------------------------------------------------------
-- HOLD COUNT
------------------------------------------------------------

function RouteLogic.getHoldCount(
    self: any
): number

    if self.currentRoute == nil then
        return 0
    end


    return
        #self.currentRoute.holds

end


------------------------------------------------------------
-- WORLD -> SCREEN
------------------------------------------------------------

function RouteLogic.getScreenY(
    self: any,
    hold: any
): number

    return
        hold.y - self.cameraY

end


------------------------------------------------------------
-- HIT TEST
--
-- Pointer is SCREEN coordinates.
-- Hold data is WORLD coordinates.
------------------------------------------------------------

function RouteLogic.hitHoldAt(
    self: any,
    x: number,
    y: number
): any

    if self.currentRoute == nil then
        return nil
    end


    for _, hold in self.currentRoute.holds do

        local screenY =
            RouteLogic.getScreenY(
                self,
                hold
            )


        if GameMath.insideEllipse(
            x,
            y,
            hold.x,
            screenY,
            Constants.HOLD_HIT_RADIUS_X,
            Constants.HOLD_HIT_RADIUS_Y
        ) then

            return hold

        end

    end


    return nil

end


------------------------------------------------------------
-- VISUAL SLOT RECYCLING
--
-- Route may contain 20 / 30 / 50 holds.
-- Scene still only has 12 visual Hold Slots.
--
-- Only holds near current viewport are mapped into slots.
------------------------------------------------------------

function RouteLogic.updateVisualSlots(
    self: any
)

    local slotIndex = 1


    if self.currentRoute ~= nil then

        for _, hold in self.currentRoute.holds do

            local screenY =
                RouteLogic.getScreenY(
                    self,
                    hold
                )


            ------------------------------------------------
            -- VISIBLE AROUND VIEWPORT
            ------------------------------------------------

            if
                screenY
                    >= -Constants.HOLD_RENDER_MARGIN
                and
                screenY
                    <= 500
                        + Constants.HOLD_RENDER_MARGIN
            then

                ------------------------------------------------
                -- NO MORE VISUAL SLOTS AVAILABLE
                ------------------------------------------------

                if
                    slotIndex
                    > Constants.MAX_HOLD_SLOTS
                then

                    break

                end


                local xProperty =
                    self.holdSlotX[slotIndex]

                local yProperty =
                    self.holdSlotY[slotIndex]


                if xProperty ~= nil then
                    xProperty.value =
                        hold.x
                end


                if yProperty ~= nil then
                    yProperty.value =
                        screenY
                end


                slotIndex =
                    slotIndex + 1

            end

        end

    end


    ------------------------------------------------------------
    -- HIDE UNUSED VISUAL SLOTS
    ------------------------------------------------------------

    for i =
        slotIndex,
        Constants.MAX_HOLD_SLOTS
    do

        local xProperty =
            self.holdSlotX[i]

        local yProperty =
            self.holdSlotY[i]


        if xProperty ~= nil then
            xProperty.value =
                Constants.OFFSCREEN
        end


        if yProperty ~= nil then
            yProperty.value =
                Constants.OFFSCREEN
        end

    end

end


return RouteLogic