main: func{
    a : Int = 1
    b := func{
        a += 1
        c := func{
            a += 1
            d := func{
                a += 1
            }
            d()
        }
        c()
    }

    b()

    if(a != 4) Exception new("%d vs 4" format(a)) throw()
}
