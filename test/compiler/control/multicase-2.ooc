
notmatch := func(a: Int){
    match(a){
        case 3 => "yes" println()
        case 4,5 => "yes" println()
        case 7,8 => Exception new("no") throw()
        case 6 => Exception new("no") throw()
        case => "ok" println()
    }
}

notmatch(3)
notmatch(108)


typematch: func<T>(b: T) -> Int{
    match(T){
        case Int, Int32, Int16, Int8, Int64 => return 1
        case String, Char => return 2
        case Float, Double, LDouble => return 3
        case => return 0
    }
    0
}

assert: func(a, b: Int){
    if(a != b) Exception new("Error %d vs %d" format(a, b)) throw()
    "%d == %d, OK!" printfln(a, b)
}

assert(typematch(1), 1)
assert(typematch(100), 1)
assert(typematch(100 as Int64), 1)
assert(typematch(-65535 as Int32), 1)
assert(typematch("This is a string"), 2)
assert(typematch('h'), 2)
assert(typematch(366.666), 3)
assert(typematch(366.666l), 3)
assert(typematch(0 as Long), 0)
