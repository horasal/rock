Point2D: class {
    x, y: Float
    init: func(=x, =y)
    operator - (other: This) -> This { This new(this x - other x, this y - other y) }
    operator - -> This { This new(-this x, -this y) }
    operator + -> This { This new(this x, this y) }
    operator + (other: This) -> This { This new(this x + other x, this y + other y) }

    toString: func -> String{ "%f %f" format(x, y) }

    fassert: func(a,b : Float){ if(x != a || y != b) Exception new("fail") throw() }
}

p := Point2D new(1.0f, 1.0f)
p fassert(1., 1.)
p2 := Point2D new(2.0f, 2.0f)
p2 fassert(2., 2.)
p toString() println()
p2 toString() println()
p -= p2
p2 fassert(2., 2.)
p fassert(-1., -1.)
(-p) fassert(1., 1.)
(+p) fassert(-1., -1.)
p += p2
(+p) fassert(1., 1.)
(-p) fassert(-1., -1.)
p toString() println()
(-p) toString() println()
