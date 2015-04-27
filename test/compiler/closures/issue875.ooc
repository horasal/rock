myFunc: Func(Int) 
myFunc_imp: func (i: Int) { "%d" printfln(i) } 
main: func {
    myFunc = myFunc_imp 
    myFunc(10) 
}
