import os/System
import threading/Thread
import structs/ArrayList

Worker: class {
    thread: Thread

    init: func{
        thread = Thread new(|| this run())
    }

    run: func{ }

    start: func -> Bool{
        if(thread) return thread start()
        false
    }

    wait: func -> Bool{
        if(thread) return thread wait()
        true
    }

    wait: func ~times (seconds: Double) -> Bool{
        if(thread) return thread wait(seconds)
        true
    }

    alive?: func -> Bool{
        if(thread) return thread alive?()
        false
    }
}

ThreadPool: class{
    pool: ArrayList<Worker> = ArrayList<Worker> new()
    lock: Mutex = Mutex new()
    parallelism := System numProcessors()

    init: func

    add: func(t: Worker){
        _waitForSlot()
        lock lock()
        pool add(t)
        lock unlock()
        t start()
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
        newpool:= ArrayList<Worker> new()
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
