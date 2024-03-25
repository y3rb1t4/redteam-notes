# Ports

Related to ports and how to interact with them.

## Check open ports

```bash
ss -tunl
netstat -tunl
```

## Port forwarding

[read](https://phoenixnap.com/kb/ssh-port-forwarding)

```bash
ssh -L <LOCAL_PORT>:<REMOTE_HOST>:<REMOTE_PORT> <USER>@<GATEWAY>
ssh -L 1111:127.0.0.1:8080 matthew@surveillance.htb
```