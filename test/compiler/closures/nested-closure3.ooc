func1 := func {
    a := 1
    b := 2
    func2 := func { println((a + b) toString()) }
    func2()
}
func1()
