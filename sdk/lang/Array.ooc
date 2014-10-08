ArrayIterator: class <T> extends Iterator<T>{
    data: T*
    length: SSizeT
    index: SSizeT = 0

    init: func~iter (=data, =length)

    hasNext?: func -> Bool { index < length }

    next: func -> T { 
        index += 1
        data[index-1] 
    }

    hasPrev?: func -> Bool { index > 0 }

    prev: func -> T { 
        index -= 1
        data[index-1] 
    }

    remove: func -> Bool { false }
}

array: cover <T> {
    rlength: SSizeT
    data: T* = null
    length: SSizeT {
        get{ rlength }
        set(l){ 
            rlength = l 
            data = gc_realloc(data, T size * rlength)
        }
    }

    init: func@(=rlength) {
        data = gc_malloc(T size * rlength)
    }

    dispose: func{
        gc_free(data)
    }

    get: func( index: SizeT ) -> T {
        _checkIndex(index)
        data[index]
    }

    set: func@( index: SizeT, value: T) {
        _checkIndex(index)
        data[index] = value
    }

    slice: func( min, max: SSizeT ) -> This<T> {
        if(min<0 || min>=rlength){
            Exception new( \
                "Trying to slice array from %d but the index should be within %d..%d !" \
                format(min, 0, rlength-1)) throw()
        }
        if(max<=0 || max>rlength){
            Exception new( \
                "Trying to slice array to %d but the index should be within %d..%d !" \
                format(min, 1, rlength)) throw()
        }
        if(min > max){
            Exception new( \
                "Max index %d is smaller than min index %d in slice!" \
                format(max, min)) throw()
        }

        retSize := max - min
        ret := This<T> new(retSize)
        memcpy(ret data, data + (min * T size), retSize * T size)
        ret rlength = retSize
        ret
    }

    slice: func~range( r: Range ) -> This<T> {
        slice(r min, r max)
    }

    clone: func -> This<T> {
        slice(0, rlength)
    }

    _checkIndex: func (index: SSizeT) {
        if (index < 0 || index >= length) {
            OutOfBoundsException new(This, index, length) throw()
        }
    }

    append: func (other: This<T>) -> This<T> {
        result := This<T> new(length + other length)
        i := 0
        doAppend := func (v: T) {
            result[i] = v
            i += 1
        }
        each(|v| doAppend(v))
        other each(|v| doAppend(v))
        result
    }

    append: func~elem (other: T) -> This<T> {
        ret := this clone()
        ret length = ret length + 1
        ret data[ret length-1] = other
        ret
    }
 
    each: func (f: Func (T)) {
        for (i in 0..length) {
            f(this[i])
        }
    }

    iterator: func -> ArrayIterator<T> {
        ArrayIterator<T> new(this data, this rlength) 
    }

    operator [] (i: Int) -> T {
        get(i)
    }
 
    operator []= (i: Int, v: T) {
        set(i, v)
    }

    operator [] (r: Range) -> This<T> {
        slice(r)
    }
 
    operator + (other: This<T>) -> This<T> {
        append(other)
    }

    operator + (other: T) -> This<T> {
        append(other)
    }

    // current does not work
    operator as <R> (other: This<R>) -> This<T> {
        ret := This<T> new(other length)
        if(R size == T size){
            memcpy(ret data, other data, other length)
            return ret
        }
        if(R size > T size){
            Exception new( \
                "cast type with size %d to type with size %d may cause overflow" \
                format(R size, T size)) throw()
        }
        for(i in 0..ret length){
            ret[i] = other[i] as T
        }
        ret
    }
}


foo := array<Int8> new(10)

for((i,j) in foo){
    foo[i] = i
}

"each func" println()
foo each(|i| "%d" printfln(i))

"for each" println()
for((i,j) in foo){
    "ind: %d, val: %d" printfln(i,j)
}

"slice[0..3]" println()
foo[0..3] each(|i|"%d" printfln(i))

"append slice[0..4] ~ 1" println()
(foo[0..3]+1) each(|i| "%d" printfln(i))

"dynamic adjust length: " println()
foo length = foo length + 1
foo each(|i| "%d" printfln(i))

"slice[0..1] ~ -1 as SizeT: " println()
bar := (foo[0..1]+(-1)) as array<SizeT>
bar each(|i| "%d" printfln(i))

"foo as SizeT" println()
foo as array<SizeT> each(|i| "%d" printfln(i))

"func " println()
acc: func(a: array<Int>){
    a each(|i| "%d" printfln(i))
}
acc(foo)

"single index foreach" println()
for(i in foo) "%d" printfln(i)

