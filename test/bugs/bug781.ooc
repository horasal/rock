import math

// Does not build
Point: cover {
    x, y: Float
    norm ::= (this x pow(2.0f) + this y pow(2.0f)) sqrt()
}

main: func -> Int{
    p := (2, 2) as Point
    return 0
}
