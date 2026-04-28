# 📬 Distributed Mail Platform (Ansible Managed)

A horizontally scalable, production-grade mail system built with **Postfix, Dovecot, Rspamd, Valkey, MariaDB, and NFS**, fully automated using **Ansible**.

At the very least this setup will help you get going and you can customize to your hearts content

---

# 🧭 Design Principles

* **Separation of Concerns**

  * Each service runs on its own node (SMTP, IMAP, DB, filtering, storage)

* **Horizontal Scalability**

  * Add more Postfix/Dovecot nodes without redesigning the system

* **Stateless Frontends**

  * SMTP and IMAP nodes rely on shared storage + centralized DB

* **Single Source of Truth**

  * MariaDB handles domains, users, and configuration state

* **Automation First**

  * Entire infrastructure is reproducible via Ansible playbooks

* **Observability Built-in**

  * Prometheus + Grafana dashboards included

* **Security by Default**

  * TLS, SASL auth, spam filtering, antivirus, fail2ban

---

# 🎯 Objective of the Design

* Provide a **modular mail platform** that:

  * Supports multi-domain hosting
  * Scales horizontally
  * Is easy to automate and rebuild
  * Includes strong spam filtering and monitoring

* Enable incremental deployment

* Avoid tight coupling between services

---

# 🏗️ Architecture


![Local Image](/docs/architecture.svg)



---

# ⚙️ Requirements

## Infrastructure

* 5–7 Linux servers (recommended separation)
* SSH access between nodes
* Proper DNS (MX, SPF, DKIM, DMARC)

## Software

* Docker
* Ansible 2.14+
* MariaDB 10.11+
* Postfix
* Dovecot
* Rspamd
* Valkey
* NFS server
* Grafana
* Prometheus

---

# 🚀 Setup Instructions

## 1. Clone Repository

```bash
git clone <repo>
cd <repo>
```

## 2. Configure Inventory

Edit `hosts.yml`:

```yaml
mysql_servers:
dovecot_servers:
postfix_servers:
valkey_servers:
nfs_servers:
haproxy_servers:
roundcube_servers:
```

---

## 3. Configure Ansible

`ansible.cfg`:

```ini
[defaults]
inventory = hosts.yml
roles_path = ./roles
host_key_checking = False
```

---

## 4. Deploy Core Services

### NFS

```bash
ansible-playbook playbooks/06-nfs-server.yml --limit nfs_servers
ansible-playbook playbooks/06-nfs-client.yml
```

### Database

```bash
ansible-playbook playbooks/00-mysql.yml --limit mysql_servers
ansible-playbook playbooks/00-mysql-setup.yml
```

### Dovecot

```bash
ansible-playbook playbooks/01-dovecot.yml --limit dovecot_servers
```

### Postfix

```bash
ansible-playbook playbooks/02-postfix.yml --limit postfix_servers
```

### Valkey

```bash
ansible-playbook playbooks/03-valkey.yml --limit valkey_servers
```

### Full Deployment

```bash
ansible-playbook playbooks/site.yml
```

---

# 📦 How to Use

## Create Domains & Users

* Instructions to create domains and users further down in in document
* Stored in SQL

## Test Authentication

```bash
doveadm auth test user@domain
```

## Test Delivery

```bash
doveadm lmtp -d user@domain
```
 
---

# 📈 Scaling

## Add Postfix Node

1. Add to `postfix_servers`
2. Run:

```bash
ansible-playbook playbooks/02-postfix.yml --limit new_host
```

## Add Dovecot Node

1. Add to `dovecot_servers`
2. Ensure:

   * NFS mounted
   * DB access configured

```bash
ansible-playbook playbooks/01-dovecot.yml --limit new_host
```

---

## Scaling Principles

* Storage → NFS (shared)
* Auth → MariaDB (central)
* Filtering → Rspamd + Valkey
* Frontends → Stateless

---

# ⚙️ Service Overview

## MariaDB

* Stores domains, users, aliases
* Used by Postfix, Dovecot, Roundcube

## Dovecot

* IMAP / POP3 / LMTP
* Authentication
* Mail delivery

## Postfix

* SMTP server
* Integrates with Dovecot + Rspamd + MySQL

## Rspamd

* Spam filtering
* DKIM / SPF / DMARC

## Valkey

* Cache + Bayesian filtering

## NFS

* Shared mail storage at `/var/vmail`

---

# 🔧 Configuration Variables

## General

| Variable          | Purpose        |
| ----------------- | -------------- |
| mail_domain       | Default domain |
| mail_user_uid     | Mail user UID  |
| mail_user_gid     | Mail group GID |
| mail_storage_path | Maildir path   |

---

## Database

| Variable       | Purpose     |
| -------------- | ----------- |
| mysql_host     | DB host     |
| mysql_user     | DB user     |
| mysql_password | DB password |
| mysql_db       | DB name     |

---

## Postfix

| Variable              | Purpose          |
| --------------------- | ---------------- |
| postfix_myhostname    | Server hostname  |
| postfix_mynetworks    | Trusted networks |
| postfix_relay_domains | Allowed domains  |
| postfix_sasl_type     | Auth backend     |

---

## Dovecot

| Variable                | Purpose       |
| ----------------------- | ------------- |
| dovecot_mail_location   | Mail storage  |
| dovecot_auth_mechanisms | Login methods |
| dovecot_sql_config      | DB config     |

---

## Rspamd

| Variable            | Purpose      |
| ------------------- | ------------ |
| rspamd_redis_host   | Valkey host  |
| rspamd_dkim_domain  | DKIM domain  |
| rspamd_enable_dmarc | Enable DMARC |

---

# 📊 Monitoring

```bash
ansible-playbook playbooks/08-monitoring-node.yml
ansible-playbook playbooks/09-monitoring-stack.yml
```

Includes:

* Prometheus
* Grafana
* Node Exporter
* Mail dashboards

---

# 🔐 Security

* TLS everywhere
* SASL auth
* Spam filtering (Rspamd)
* Antivirus (ClamAV)
* Fail2ban protection

---

# 🧪 Testing Checklist

* [ ] SMTP works
* [ ] IMAP login works
* [ ] Spam filtering works
* [ ] DKIM valid
* [ ] DMARC passes
* [ ] Mail stored in NFS
* [ ] Monitoring active

---

# 📌 Notes

* Fully automated via Ansible
* Horizontally scalable design
* Services deploy independently
* Minimal downtime scaling




# 🔧 Realistic Configuration Variables (Ansible)

These are closer to what your roles likely use.

## Global

```yaml
mail_domain: example.com
mail_hostname: mail.example.com

vmail_user: vmail
vmail_uid: 5100          # Matches your actual config
vmail_gid: 5100
mail_root: /var/vmail    # NFS mount point
```

---

## MariaDB

```yaml
mysql_host: 192.168.1.230
mysql_port: 3306
db_name: mailserver
db_user: mailuser
db_password: secure_password
db_root_password: root_password

```

---

## Dovecot

```yaml
dovecot_protocols: "imap pop3 lmtp sieve"
dovecot_mail_location: "maildir:/var/vmail/%{user | domain}/%{user | username}/Maildir"
dovecot_auth_mechanisms: "plain login"
dovecot_lmtp_port: 24
dovecot_sasl_port: 12345    # TCP socket for Postfix
dovecot_managesieve_port: 4190
```

---

## Postfix

```yaml
postfix_myhostname: "{{ mail_hostname }}"
postfix_mydomain: "{{ mail_domain }}"
postfix_inet_interfaces: all
postfix_inet_protocols: ipv4

# SASL over TCP (not Unix socket)
postfix_sasl_type: dovecot
postfix_sasl_path: inet:{{ dovecot_host }}:12345

# Rspamd milter
postfix_smtpd_milters: inet:{{ rspamd_host }}:11332
```

---

## Rspamd

```yaml
# Note: Uses Valkey, not Redis
rspamd_controller_port: 11334
rspamd_milter_port: 11332
rspamd_proxy_port: 11333

# Valkey connection (note variable name)
valkey_host: 192.168.1.233
valkey_port: 6379
valkey_password: "Valkey8k7fG9xP2mQ4wR6tY3uV1nB5cX9zL0aM"

# DKIM settings
rspamd_dkim_signing: true
rspamd_dkim_selector: mail
```

---

## Valkey

```yaml
valkey_bind: 0.0.0.0
valkey_port: 6379
valkey_maxmemory: 512mb
valkey_maxmemory_policy: allkeys-lru
valkey_password: "secure_password"  # Required if set
```


## HAProxy

```yml
haproxy_stats_port: 8404
haproxy_stats_user: admin
haproxy_stats_password: "CHANGE_ME_HAPROXY_PASSWORD"

# External ports exposed
haproxy_external_ports:
  - 25   # SMTP
  - 465  # SMTPS
  - 587  # Submission
  - 143  # IMAP
  - 993  # IMAPS
  - 4190 # ManageSieve
  - 80   # HTTP (Roundcube)
  - 443  # HTTPS (Roundcube)
```

## Unbound DNS
```yml
unbound_port: 5354
unbound_cache_size: 512m
unbound_num_threads: 4
unbound_forward_servers:
  - "8.8.8.8"
  - "8.8.4.4"
```

## NFS
```yml
nfs_host: 192.168.1.229
nfs_export: "/srv/vmail"           # Actual export
nfs_mount_point: "/var/vmail"      # Client mount point
nfs_mount_options: "hard,intr,noatime,nordirplus,actimeo=60"
```

---

## NFS

```yaml
nfs_export_path: /var/vmail
nfs_allowed_hosts:
  - 192.168.1.0/24
```

## Unbound DNS

* Local recursive DNS resolver for Rspamd
* Runs on port 5354 (avoids conflict with systemd-resolved)
* Provides DNS resolution for spam filtering
* Configured with DNSSEC validation

## HAProxy

* Load balancer for all mail services
* Terminates TLS for SMTP, IMAP, and webmail
* Provides statistics page (localhost:8404)
* Supports sticky sessions for IMAP

---

# 🛠️ Troubleshooting / Runbook

## 🔴 Mail Not Delivering

### Check Postfix Queue

```bash
postqueue -p
```

Flush queue:

```bash
postqueue -f
```

---

## 🔴 Authentication Fails

### Test Dovecot Auth

```bash
doveadm auth test user@domain
```

### Check logs

```bash
journalctl -u dovecot -f
```

---

## 🔴 SMTP Issues

```bash
journalctl -u postfix -f
```

Test manually:

```bash
telnet localhost 25
```

---

## 🔴 IMAP Issues

```bash
openssl s_client -connect localhost:993
```

---

## 🔴 Rspamd Not Working

Check:

```bash
rspamadm stat
```

Logs:

```bash
journalctl -u rspamd -f
```

---

## 🔴 Redis / Valkey Issues

```bash
redis-cli -h 127.0.0.1 ping
```

Expected:

```text
PONG
```

---

## 🔴 NFS Problems

Check mount:

```bash
mount | grep vmail
```

Test write:

```bash
touch /var/vmail/testfile
```

---

## 🔴 DNS Issues (VERY COMMON)

Check:

```bash
dig MX example.com
dig TXT example.com
```

Verify:

* SPF
* DKIM
* DMARC

---

# 📋 Operational Runbook

## Restart Services

```bash
systemctl restart postfix
systemctl restart dovecot
systemctl restart rspamd
systemctl restart valkey
```

---

## Rolling Restart (Cluster Safe)

1. Restart one node at a time
2. Verify health
3. Move to next node

---

## Add New Domain

1. Via SQL

Example:
```bash
INSERT INTO domain (domain, description, max_quota, active) 
VALUES ('newdomain.com', 'Client domain', 10737418240, 1);
```

2. Verify:

   * MX record exists
   * DKIM configured
3. Test send/receive


## Add New Email User
1. Via SQL

Example:
```bash
INSERT INTO mailbox (username, password, name, domain, quota, active) 
VALUES (
    'user@newdomain.com', 
    '{BLF-CRYPT}$2y$10$...',  -- Use doveadm to generate
    'First Last', 
    'newdomain.com', 
    1073741824, 
    1
);
```

2. You can Generate a password using doveadm
```bash
doveadm pw -s BLF-CRYPT
# Enter password, copy the output including {BLF-CRYPT} prefix
```

## Add Email Alias
1. Via SQL
```bash
INSERT INTO alias (address, goto, domain, active) 
VALUES ('info@newdomain.com', 'user@newdomain.com', 'newdomain.com', 1);
```

## Confirmations

### Domain added
```bash
SELECT * FROM postfix_domains;
```

### Check User Added
```bash
SELECT * FROM postfix_mailboxes;
```

## Test SMTP Auth
```bash
doveadm lmtp -d user@newdomain.com
echo "Test email body" | mailx -s "Test" user@newdomain.com

```



---

## Add New Mail Server

1. Add to `hosts.yml`
2. Run relevant playbook
3. Ensure:

   * DB connectivity
   * NFS mounted
   * DNS updated (if needed)

---

## Backup Strategy

### Database

```bash
mysqldump mailserver > backup.sql
```

### Mail Storage

```bash
rsync -av /var/vmail /backup/
```



## Rspamd Management Scripts

### /usr/local/bin/generate-dkim-keys

What it does:
  * Generates DKIM keys for all domains in your database
  * Stores keys on NFS (shared across all Rspamd nodes)
  * Creates symlinks for Rspamd 4.x compatibility
  * Updates Rspamd signing table automatically

Usage:
```bash

# Generate DKIM for a single domain
generate-dkim-keys -d example.com

# Generate for ALL domains in database
generate-dkim-keys -a

# Force regenerate existing keys
generate-dkim-keys -d example.com -f

# List all domains with DKIM status
generate-dkim-keys -l

# Show DNS records for all domains
generate-dkim-keys -L

# Check if DKIM exists for a domain
generate-dkim-keys -c example.com

# Custom selector and key size
generate-dkim-keys -d example.com -s mail -b 2048
```

###  DKIM Auto-Generation Service (dkim-autogen)

What it does:
  * Runs every 5 minutes via systemd timer
  * Automatically detects new domains added to database
  * Generates missing DKIM keys
  * Includes jitter (random delay) to prevent thundering herd on NFS

Status check:
```bash

# Check if timer is running
systemctl status dkim-autogen.timer

# View recent runs
journalctl -u dkim-autogen.service -n 20

# Manual trigger
systemctl start dkim-autogen.service
```

### Mail Query Tool (mail-query)

Location: /usr/local/bin/mail-query

What it does:
  * Quick database queries without writing SQL
  * Reads configuration from /etc/mailstack/mailstack.conf

Usage:
```bash

# List all domains
mail-query --domains

# List all users
mail-query --users

# List all aliases
mail-query --aliases

# Show database statistics
mail-query --stats

# Show specific domain details
mail-query --domain example.com

# Show specific user details
mail-query --user admin@example.com
```

## Rate Limit Management

```bash
# Check rate limit rules
rspamadm configdump ratelimit

# Clear rate limit for specific IP
rspamc -h localhost:11334 delkey "ratelimit:ip:192.168.1.100"

# Clear rate limit for specific user
rspamc -h localhost:11334 delkey "ratelimit:user:john@example.com"
```


## Bayes Learning
```bash

# Learn spam
rspamc learn_spam /path/to/message.eml

# Learn ham
rspamc learn_ham /path/to/message.eml

# Check Bayes stats
rspamadm stat -b
```

---

## Monitoring Checks

* Prometheus targets up
* Grafana dashboards updating
* No alert spikes

---

# 🚨 Common Pitfalls

* Wrong DB credentials → auth failures
* NFS not mounted → mail loss
* Missing DNS records → rejected mail
* Firewall blocking ports (25, 143, 993, 587)
* Rspamd not reachable → no spam filtering

---

# ✅ Production Tips

* Use HAProxy for SMTP/IMAP load balancing
* Use Let's Encrypt for TLS
* Enable rate limiting in Postfix
* Tune Rspamd scores
* Monitor queue size aggressively

---



## 📊 Quick Reference Card to Add

At the end of your README, add:

```markdown
## 📋 Quick Reference

| Service | Ports | Config Location |
|---------|-------|-----------------|
| Postfix | 25, 465, 587 | `/etc/postfix/` |
| Dovecot | 143, 993, 24, 12345, 4190 | `/etc/dovecot/` |
| Rspamd | 11332, 11334 | `/etc/rspamd/` |
| Valkey | 6379 | `/etc/valkey/` |
| Unbound | 5354 | `/etc/unbound/` |
| HAProxy | 80, 443, 8404 | `/etc/haproxy/` |
| MySQL | 3306 | `/etc/mysql/` |
| NFS | 2049 | `/etc/exports` |
| Roundcube | 80 (container) | `/opt/roundcube/` |
| Grafana | 3000 | Docker container |
| Prometheus | 9090 | Docker container |

**Log Locations:**
- Mail: `/var/log/mail.log`
- Dovecot: `/var/log/dovecot*.log`
- Rspamd: `/var/log/rspamd/rspamd.log`
- HAProxy: `/var/log/haproxy.log`