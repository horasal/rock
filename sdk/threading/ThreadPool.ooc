import os/System
import threading/Thread
import structs/ArrayList

ThreadPool: class{
    pool: ArrayList<Thread> = ArrayList<Thread> new()
    lock: Mutex = Mutex new()
    parallelism := System numProcessors()

    init: func

    add: func(t: Thread, start: Bool = true){
        _waitForSlot()
        lock lock()
        pool add(t)
        lock unlock()
        if(start) t start()
    }

    startAll: func {
        for(p in pool){
            p start()
        }
    }

    waitAll: func -> Bool{
        isSuc := true
        while(!pool empty?()){
            if(!waitFirst()) isSuc = false
        }
        isSuc
    }

    waitFirst: func -> Bool{
        if(pool empty?()) return true
        lock lock()
        currentThread := pool removeAt(0)
        lock unlock()
        currentThread wait()
    }

    clearPool: func{
        lock lock()
        newpool:= ArrayList<Thread> new()
        for(p in pool){
            if(p alive?()){
                newpool add(p)
            }
        }
        pool = newpool
        lock unlock()
    }

    _waitForSlot: func{
        if(pool size < parallelism) return
        clearPool()
        if(pool size < parallelism) return
        waitFirst()
    }

    destroy: func{
        lock destroy()
    }
}
