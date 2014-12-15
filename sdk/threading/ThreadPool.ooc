import os/System
import threading/Thread
import structs/ArrayList

ResourceQueue: class <T>{
    pool: ArrayList<T> = ArrayList<T> new()
    lock: Mutex = Mutex new()

    init: func

    destroy: func{ lock destroy() }

    add: func(item: T){
        lock lock()
        pool add(item)
        lock unlock()
    }

    pop: func -> T{
        lock lock()
        if(!pool empty?()){
            data := pool removeAt(0)
            lock unlock()
            return data
        }
        lock unlock()
        null
    }

    empty?: func -> Bool{
        pool empty?()
    }
}

Worker: class <T> {
    thread: Thread
    resources: ResourceQueue<T>

    init: func(=resources){
        thread = Thread new(|| this run())
    }

    code: func (item: T) { }

    run: func{
        while(!resources empty?()) code(resources pop())
    }

    start: func -> Bool{
        thread start()
    }

    wait: func -> Bool{
        thread wait()
    }

    wait: func ~times (seconds: Double) -> Bool{
        thread wait(seconds)
    }

    alive?: func -> Bool{
        thread alive?()
        false
    }
}

ThreadPool: class <T> {
    pool: ArrayList<Worker<T>> = ArrayList<Worker<T>> new()
    resourceQueue: ResourceQueue<T>
    lock: Mutex = Mutex new()
    parallelism := System numProcessors()
    newWorker: Func() -> Worker<T>

    init: func(=resourceQueue, =newWorker)

    destroy: func{
        lock destroy()
    }

    addWorker: func{
        while(pool size < parallelism){
            tw := newWorker()
            tw start()
            lock lock()
            pool add(tw)
            lock unlock()
        }
    }

    start: func{
        addWorker()
    }

    wait: func{
        while(!pool empty?()){
            pool removeAt(0) wait()
        }
    }
}
