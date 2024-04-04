RPClient

```bash
rpcclient -U "" 10.129.252.217 -N -c 'enumdomusers' | grep -oP '\[.*?\]' | grep -v 0x | tr -d '[]'
```
