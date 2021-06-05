# Runnable

Runnable - scans README.md files for runnable commands"

Runnable aims to remove the barrier between code and documentation. Through the use of formatting conventions and bash scripting, it scans documentation for commands, which can then be run. 


```shell
01. $ ./runnable.sh
```

Lists the runnable commands in . "
```shell
02. $ ./runnable.sh .
```

Lists the runnable commands in tests 
```shell
03. $ ./runnable.sh tests
```

Generates the test script file containing all commands for the purpose of testing documentation
```shell
04. $ ./runnable.sh tests 00
``` 

Runs the script file above.
```shell
05. $ ./runnable.sh tests     00  -r 
```
