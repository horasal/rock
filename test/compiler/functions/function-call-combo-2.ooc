//!shouldfail

foo: class{
    v : Int
    isOdd :Bool {
        get { v % 2 == 1 }
    }

    isEven ::= v %2 == 0

    init: func

    test: func {}
}

bar := foo new()

bar test()()
