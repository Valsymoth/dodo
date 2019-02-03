I think this should be documented.

```
curl -X GET --silent "https://api.digitalocean.com/v2/images?per_page=999" -H "Authorization: Bearer $DO_API_TOKEN"
```

health checks ?

```
ssh-keygen -E md5 -lf ~/.ssh/id_rsa | cut -d " " -f2 | awk -F "MD5:" '{print $2}' > fingerprint

```
