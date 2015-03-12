import math

Foo: class {
    value: Int
    init: func(=value)

    fassert: func(other: Int){
        if(value != other){
            Exception new("Error %d vs %d" format(value, other)) throw()
        }
    }
}
operator + (left, right: Foo) -> Foo {
    "+" println()
    Foo new(left value + right value)
}
operator - (left, right: Foo) -> Foo {
    "-" println()
    Foo new(left value - right value)
}
operator * (left, right: Foo) -> Foo {
    "*" println()
    Foo new(left value * right value)
}
operator ** (left, right: Foo) -> Foo {
    "**" println()
    Foo new(left value as Double pow(right value) roundLong())
}
operator / (left, right: Foo) -> Foo {
    "/" println()
    Foo new(left value / right value)
}
operator % (left, right: Foo) -> Foo {
    "%" println()
    Foo new(left value % right value)
}
operator >> (left, right: Foo) -> Foo {
    ">>" println()
    Foo new(left value >> right value)
}
operator << (left, right: Foo) -> Foo {
    "<<" println()
    Foo new(left value << right value)
}
operator | (left, right: Foo) -> Foo {
    "|" println()
    Foo new(left value | right value)
}
operator ^ (left, right: Foo) -> Foo {
    "^" println()
    Foo new(left value ^ right value)
}
operator & (left, right: Foo) -> Foo {
    "&" println()
    Foo new(left value & right value)
}

foo := Foo new(1)

(foo = foo + Foo new(2)) fassert(3) // 1 + 2 = 3
(foo += Foo new(3)) fassert(6) // 3 + 3 = 6

(foo = foo - Foo new(2)) fassert(4) // 6 - 2 = 4
(foo -= Foo new(3)) fassert(1)// 4 - 3 = 1

(foo = foo * Foo new(2)) fassert(2) // 1 * 2 = 2
(foo *= Foo new(3)) fassert(6)// 2 * 3 = 6

(foo = foo ** Foo new(2)) fassert(36) // 6 ** 2 = 36
(foo **= Foo new(3)) fassert(46656) // 36 ** 3 = 46656

(foo = foo / Foo new(2)) fassert(23328) // 46656 / 2 = 23328
(foo /= Foo new(3)) fassert(7776) // 23328 / 3 = 7776

(foo = foo % Foo new(2)) fassert(0) // 7776 % 2 = 0
//foo %= Foo new(3)
// error Expected include, import, statement or declaration
foo = Foo new(65535) // 65535 = 0xFFFF

(foo = foo >> Foo new(2)) fassert(16383) // 0xFFFF >> 2 = 0x3FFF
(foo >>= Foo new(3)) fassert(2047) // 0xFF >> 3 = 0x7FF

foo = Foo new(1)

(foo = foo << Foo new(2)) fassert(4) // 1 << 2 = 4
(foo <<= Foo new(3)) fassert(32) // 4 << 3 = 32

(foo = foo | Foo new(2)) fassert(34) // 0x100000 | 0x10 = 0x100010
(foo |= Foo new(3)) fassert(35) // 0x100010 | 0x11 = 0x100011

(foo = foo ^ Foo new(2)) fassert(33) // 0x100011 ^ 0x10 = 0x100001
(foo ^= Foo new(3)) fassert(34) // 0x100001 ^ 0x11 = 0x100010 

(foo = foo & Foo new(2)) fassert(2) // 0x100010 & 0x10 
(foo &= Foo new(3)) fassert(2) // 0x10 & 0x11
