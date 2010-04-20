import io/File
import text/Buffer
import os/Process

import AbstractCompiler
import ../../utils/ShellUtils

BaseCompiler: abstract class extends AbstractCompiler {
    
    init: func ~baseCompiler (.executableName) {
        setExecutable(executableName)
    }
    
    setExecutable: func (=executableName) {
        execFile := File new(executableName)
        
        if (!execFile exists()) {
            execFile = ShellUtils findExecutable(executableName, false)
            if (execFile == null) {
                execFile = ShellUtils findExecutable(executableName + ".exe", false)
                if (execFile == null) {
                    execFile = ShellUtils findExecutable(executableName, true)
                }
            }
        }
        
        executablePath = execFile name()
        if(command isEmpty()) {
            command add(executablePath)
        } else {
            command set(0, executablePath)
        }
    }
    
    launch: func() -> Int {
        proc := Process new(command) 
        return proc execute()
    }
    
    reset: func() {
        command clear()
        command add(executablePath)
    }
    
    getCommandLine: func() -> String {
        commandLine := Buffer new()
                
        for(arg: String in command) {
            commandLine append(arg)
            commandLine append(" ")
        }
                        
        return commandLine toString()
    }
}