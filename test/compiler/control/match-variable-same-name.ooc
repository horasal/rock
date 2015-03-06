foo: func<T>(a: T){
    match(a){
        case a: Int =>
            a toString() println()
        case => 
    }
}


main: func{
    foo(1)
}
