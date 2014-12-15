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
    finish := false

    init: func(=resources){
        thread = Thread new(|| this run())
    }

    code: func (item: T) { }

    run: func{
        while(!resources empty?()) code(resources pop())
    }

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

ThreadPool: class <T> {
    workerMonitor: Thread
    workerDestroy: Thread

    pool: ArrayList<Worker<T>> = ArrayList<Worker<T>> new()
    resourceQueue: ResourceQueue<T>
    lock: Mutex = Mutex new()
    parallelism := System numProcessors()
    newWorker: Func() -> Worker<T>

    terminated := false
    
    init: func(=resourceQueue, =newWorker){
        workerMonitor = Thread new(||addWorker())
        workerDestroy = Thread new(||destroyWorker())
    }

    destroy: func{
        lock destroy()
    }

    addWorker: func{
        while(resourceQueue && !resourceQueue empty?()){
            if(terminated) break

            while(pool size < parallelism){
                tw := newWorker()
                tw start()
                lock lock()
                pool add(tw)
                lock unlock()
            }
        }
    }

    destroyWorker: func{
        while(pool size > 0 || (resourceQueue && !resourceQueue empty?())){
            if(terminated && pool size == 0) break
            if(pool size > 0){
                pool[0] wait()
                lock lock()
                pool removeAt(0)
                lock unlock()
            }
        }
    }

    start: func{
        workerMonitor start()
        workerDestroy start()
    }

    terminate: func{
        terminated = true
        wait()
    }
    
    wait: func{
        workerMonitor wait()
        workerDestroy wait()
    }
}
