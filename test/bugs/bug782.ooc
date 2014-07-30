import math

// Does not build
PointCoverA : cover {
    x, y: Float
    Norm ::= (this x pow(2.0f) + this y pow(2.0f)) sqrt()
}

// Builds just fine
PointCoverB: cover {
    x, y: Float
    Norm: Float { get { (this x pow(2.0f) + this y pow(2.0f)) sqrt() } }
}

// Builds just fine
PointClassA: class {
    x, y: Float
    Norm ::= (this x pow(2.0f) + this y pow(2.0f)) sqrt()
}

// Builds just fine
PointClassB: class {
    x, y: Float
    Norm: Float { get { (this x pow(2.0f) + this y pow(2.0f)) sqrt() } }
}
