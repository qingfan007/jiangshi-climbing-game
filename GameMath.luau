local GameMath = {}


function GameMath.insideEllipse(
    x: number,
    y: number,
    cx: number,
    cy: number,
    rx: number,
    ry: number
): boolean

    local dx = (x - cx) / rx
    local dy = (y - cy) / ry

    return dx * dx + dy * dy <= 1
end


function GameMath.distance(
    x1: number,
    y1: number,
    x2: number,
    y2: number
): number

    local dx = x2 - x1
    local dy = y2 - y1

    return math.sqrt(
        dx * dx + dy * dy
    )
end


function GameMath.lerp(
    a: number,
    b: number,
    t: number
): number

    return a + (b - a) * t
end


return GameMath