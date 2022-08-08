# CludFlare DDNS
## bash shell
- ddns-cludflare.sh 파일 참조 +
- ~/ddns-cludflare.sh 위치로 이동

## cron
- crontab 추가

```bash
crontab -e

* * * * * /bin/bash ~/ddns-cludflare
```

---

- cron 로그 확인 방법
```bash
sudo vi /etc/rsyslog.d/50-default.conf

#cron.* # 주석 제거

sudo service rsyslog restart

tail -f /var/log/cron.log
```
