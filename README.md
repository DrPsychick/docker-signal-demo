# [Docker image: signal-demo](https://hub.docker.com/r/drpsychick/signal-demo/)
Handling signals in a docker container

[![Docker image](https://img.shields.io/docker/image-size/drpsychick/signal-demo?sort=date)](https://hub.docker.com/r/drpsychick/signal-demo/tags)
[![Travis build status](https://travis-ci.com/DrPsychick/docker-signal-demo.svg?branch=master)](https://travis-ci.com/DrPsychick/docker-signal-demo)
[![DockerHub pulls](https://img.shields.io/docker/pulls/drpsychick/signal-demo.svg)](https://hub.docker.com/r/drpsychick/signal-demo/)
[![DockerHub stars](https://img.shields.io/docker/stars/drpsychick/signal-demo.svg)](https://hub.docker.com/r/drpsychick/signal-demo/)
[![GitHub stars](https://img.shields.io/github/stars/drpsychick/docker-signal-demo.svg)](https://github.com/drpsychick/docker-signal-demo)

## Purpose
Demo/playground to play with signal handling in docker / kubernetes, additionally along with `tmux` or `screen` sessions.
Some apps **require a terminal**, so it's easiest to run them in a `tmux`/`screen` session.

IMHO `tmux` is a bit easier to automate while I used `screen` a lot "interactively" (quite a while ago). 

## Try it
### Docker
```shell script
docker run -it --rm --name demo drpsychick/signal-demo
# will run and wait for signal

> docker stop demo # in another shell
--> got TERM signal
```

### Kubernetes
```shell script
kubectl apply -f k8s/signal-demo.yml
kubectl logs -f -l app=signal-demo
# will run and wait for signal

> kubectl delete pod -l app=signal-demo # in another shell (k8s will create a new pod)
--> got TERM signal

> kubectl delete -f k8s/signal-demo.yml # in another shell
--> got TERM signal
```

## Sending signals
In interactive mode, the first signal to try is Ctrl-C, it will send an INT signal.

Other signals can be sent through the `exec` commands to PID 1 in the pod:
```shell script
docker exec test kill -HUP 1
kubectl exec deploy/signal-demo-deployment -- kill -USR1 1
```

You'll see the corresponding messages as defined in the trap commands:
```shell script
trap 'echo "--> got signal: TERM - shutdown."; tmux kill-server; screen -X kill' TERM
trap 'echo "--> got signal: INT - shutting down..."; tmux send-keys C-c exit C-m; screen -X kill' INT
trap 'echo "--> got signal: USR1 - stopping tmux"; tmux send-keys C-c exit C-m' USR1
trap 'echo "--> got signal: USR2 - stopping screen"; screen -X kill' USR2
trap 'echo "--> got signal: HUP - status report"; ps faxuwww' HUP
trap 'echo "--> got signal: QUIT/ABRT"' QUIT ABRT
```

## What happens when you use `exec`
```shell script
docker run --rm --name demo -e EXEC_DEMO=yes drpsychick/signal-demo
```
When you `exec <cmd>` then it takes over the running process and the shell script stops at that point. The command executed will be PID #1.

This can be very useful if you have an app that takes over signal handling and cleanup of children as well.
