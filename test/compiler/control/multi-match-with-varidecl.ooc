
(min, max) := (1, 5)

matches?: func <T> (other: T) -> Bool{
    match(other){
        case a:Int, a:Int64, a:Int32, a:Int16, a:Int8, a:UInt, a:UInt64, a:UInt32, a:UInt16, a:UInt8, a:ULong, a:ULLong, a:Long, a:LLong, a:SSizeT, a:SizeT => 
            return min <= a && a < max
        case => Exception new("Can not match %s with range" format(T name)) throw()
    }
    false
}

assert: func(a, b: Bool) {
    if(a == b) "pass" println()
    else Exception new("error") throw()
}

assert(matches?(1 as Int64), true)
assert(matches?(2 as Int32), true)
assert(matches?(3 as UInt32), true)
assert(matches?(4 as UInt64), true)
assert(matches?(5 as UInt8), false)
