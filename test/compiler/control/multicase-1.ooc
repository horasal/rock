testmatch := func(myint: Int){
    match(myint){
        case 1, 2, 3 => "true" println()
        case 4, 5, 6 => Exception new("false") throw()
        case =>  Exception new("error") throw()
    }
}

testmatch1 := func(mystring: String){
    match(mystring){
        case "typo", "bugs", "coffee" => Exception new("false") throw()
        case "kuma", "rabbit" => "true" println()
        case "love the world" => "true" println()
        case =>  Exception new("error") throw()
    }
}

testmatch(1)
testmatch(2)
testmatch(3)

testmatch1("kuma")
testmatch1("rabbit")
testmatch1("love the world")
