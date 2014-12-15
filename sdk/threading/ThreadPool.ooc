import os/[System, Time]
import threading/Thread
import structs/ArrayList

ThreadStatus: enum{
    Idle,
    Work,
    Terminate
}

Worker: class <T> {
    thread: Thread
    task: T
    idleTime := 30

    status: ThreadStatus = ThreadStatus Idle

    init: func{
        thread = Thread new(|| this run())
        thread start()
    }

    code: func { }

    run: func{
        while(status != ThreadStatus Terminate){
            match(status){
                case ThreadStatus Idle => Time sleepMicro(idleTime)
                case ThreadStatus Work =>
                    if(task){
                        code()
                        task = null
                    }
                    status = ThreadStatus Idle
                case ThreadStatus Terminate => return
                case => Time sleepMicro(idleTime)
            }
        }
    }

    terminate: func{
        while(status == ThreadStatus Work) Time sleepMicro(idleTime)
        status = ThreadStatus Terminate
    }

    isIdle?: func -> Bool{
        status == ThreadStatus Idle
    }

    start: func(=task){
        while(status == ThreadStatus Work) Time sleepMicro(idleTime)
        status = ThreadStatus Work
    }

    wait: func -> Bool{
        thread wait()
    }

    wait: func ~times (seconds: Double) -> Bool{
        thread wait(seconds)
    }

    alive?: func -> Bool{
        thread alive?()
    }
}

ThreadPool: class <T> {
    pool: ArrayList<Worker<T>> = ArrayList<Worker<T>> new()
    lock: Mutex = Mutex new()
    parallelism := System numProcessors()
    newWorker: Func() -> Worker<T>

    init: func(=newWorker)

    destroy: func{
        lock destroy()
    }

    addWorker: func -> Worker<T>{
        tw := newWorker()
        lock lock()
        pool add(tw)
        lock unlock()
        tw
    }

    addTask: func(task: T){
        if(pool size < parallelism){
            addWorker() start(task)
        } else {
            w := idleWorker()
            w start(task)
        }
    }

    idleWorker: func -> Worker<T>{
        i := 0
        while(true){
            if(pool[i] isIdle?()){
                return pool[i]
            }
            i += 1
            i = i % pool size
        }
        null
    }

    wait: func{
        while(!pool empty?()){
            pool removeAt(0) terminate(). wait()
        }
    }
}
