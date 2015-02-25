foo: class{
    v : Int
    isOdd :Bool {
        get { v % 2 == 1 }
    }

    isEven ::= v %2 == 0

    init: func

    test: func -> Func(Int) {
        return func(a: Int){ a toString() println()}
    }
}

bar := foo new()

a := bar test()
a(1)

bar test()(1)
