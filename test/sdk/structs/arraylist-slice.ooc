import structs/ArrayList

printArrayList: func(a: ArrayList<Int>){
    a each(|x| "%d, " printf(x))
    println()
}

myarr := [1, 2 ,3 ,4, 5] as ArrayList<Int>

if(! myarr[0..2] size == 2) Exception new("Slice error !") throw()
printArrayList(myarr)
printArrayList(myarr[0..0])
printArrayList(myarr[0..1])
printArrayList(myarr[0..2])
printArrayList(myarr[0..3])
printArrayList(myarr[2..4])
printArrayList(myarr[2..5])
