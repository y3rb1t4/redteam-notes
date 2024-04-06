## Subdomain Discovery

``` bash
amass enum -brute -active -d example.com -o amass-output.txt
amass enum -active -d example.com | httpx -sc -td -title -silent -o httpx.txt
cat httpx.txt | sed 's/http:\/\/\|https:\/\/\|ftp:\/\///g'
```

``` bash
subfinder -silent -all -d example.com | httpx -silent -sc
subfinder -silent -all -d example.com | httpx | nuclei -s critical,high,medium,low,info
```

``` bash
./sublist3r.py -d example.com | httpx -silent -sc
```

## Directory Bruteforce

``` bash
dirsearch.py -e php -u https://example.com --exclude-status 403,401
dirsearch.py -l taerget.txt --deep-recursive
dirsearch --tor --crawl -u https://example.com --exclude-status 404 --deep-recursive --max-rate=5 -q --format=xml
```

## Parameter Discovery & Batman Matching

``` bash
paramspider -l domains.txt -p batman

cat results/* | while read line; do echo "$line" >> params.txt; done

cat params.txt | while read line; do curl -X GET -s "$line" | grep -oq batman && echo "$line"; done
```

## Get directories + parameters

``` bash
cat domains.txt | gau --o urls.txt
```

## Get directories + Reflected chars

``` bash
cat domains.txt | gau | grep "=" | kxss
cat domains.txt | gau --subs | gf xss | sed 's/=.*/=/' | sed 's/URL: //' | kxss
cat domains.txt | gau | gf xss | dalfox pipe
cat alive_urls.txt | grep "=" | dalfox pipe --waf-evasion --timeout 10
```

## Get Javascript Files

``` bash
cat domains.txt | gau | subjs
```

## Find endpoints in JS Files

``` bash
python3 linkfinder.py -i https://example.com 
```

## Nuclei

``` bash
nuclei -u https://example.com -s critical,high,medium,low,info
```

**Chained with Paramspider & HTTPX** 

``` bash
paramspider -d example.com --exclude png,jpg,gif,jpeg,swf,woff,gif,svg --level high --quiet -o paramfuzzer.txt

cat paramfuzzer.txt | httpx -silent -mc 200,301,302,403 | nuclei -t /home/bara/bugbounty/tools/fuzzing-templates -rl 05
```

**Chained with Katana & HTTPX**

``` bash
katana -list domainsurls.txt -silent -d 6 -rl 25 -jc qurl | httpx -silent -mc 200,301,302,403 | nuclei -t /home/bara/bugbounty/tools/fuzzing-templates/xss/reflected-xss.yaml -rl 25 
```

## Automated

``` bash
osmedeus scan -t fanbox.cc
```

``` bash
nikto -h example.com -ssl
```

