local Constants = {}


Constants.OFFSCREEN = -500


------------------------------------------------------------
-- INITIAL BODY
------------------------------------------------------------

Constants.INITIAL_BODY_X = 250
Constants.INITIAL_BODY_Y = 380


------------------------------------------------------------
-- INITIAL LIMBS
------------------------------------------------------------

Constants.INITIAL_LEFT_HAND_X = 165
Constants.INITIAL_LEFT_HAND_Y = 355

Constants.INITIAL_RIGHT_HAND_X = 335
Constants.INITIAL_RIGHT_HAND_Y = 355

Constants.INITIAL_LEFT_FOOT_X = 225
Constants.INITIAL_LEFT_FOOT_Y = 485

Constants.INITIAL_RIGHT_FOOT_X = 275
Constants.INITIAL_RIGHT_FOOT_Y = 485


------------------------------------------------------------
-- BODY / CHARACTER OFFSETS
------------------------------------------------------------

Constants.HEAD_OFFSET_X = 0
Constants.HEAD_OFFSET_Y = -105


Constants.LEFT_SHOULDER_OFFSET_X = -40
Constants.LEFT_SHOULDER_OFFSET_Y = -25

Constants.RIGHT_SHOULDER_OFFSET_X = 40
Constants.RIGHT_SHOULDER_OFFSET_Y = -25


Constants.LEFT_HIP_OFFSET_X = -20
Constants.LEFT_HIP_OFFSET_Y = 60

Constants.RIGHT_HIP_OFFSET_X = 20
Constants.RIGHT_HIP_OFFSET_Y = 60


------------------------------------------------------------
-- BODY FOLLOW
------------------------------------------------------------

Constants.BODY_ENDPOINT_Y_OFFSET = 45

Constants.BODY_FOLLOW_SPEED = 6


------------------------------------------------------------
-- REACH
------------------------------------------------------------

Constants.ARM_REACH = 170
Constants.LEG_REACH = 175

------------------------------------------------------------
-- DYNO
------------------------------------------------------------

Constants.DYNO_REACH = 235


------------------------------------------------------------
-- ROUTE / HOLDS
------------------------------------------------------------

Constants.MAX_HOLD_SLOTS = 12

Constants.HOLD_HIT_RADIUS_X = 38
Constants.HOLD_HIT_RADIUS_Y = 30

-- Match / shared hold
Constants.MAX_LIMBS_PER_HOLD = 2


------------------------------------------------------------
-- CAMERA
------------------------------------------------------------

Constants.INITIAL_CAMERA_Y = 1400

Constants.CAMERA_FOLLOW_Y = 300

Constants.HOLD_RENDER_MARGIN = 80


------------------------------------------------------------
-- RESTART BUTTON
------------------------------------------------------------

Constants.RESTART_X = 455
Constants.RESTART_Y = 45

Constants.RESTART_HALF_SIZE = 28


------------------------------------------------------------
-- FREEZE
------------------------------------------------------------

Constants.FREEZE_SECONDS = 3.0

Constants.FREEZE_DOT_Y = 85

Constants.FREEZE_DOT_3_X = 220
Constants.FREEZE_DOT_2_X = 250
Constants.FREEZE_DOT_1_X = 280


return Constants