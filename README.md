# 📬 Distributed Mail Platform (Ansible Managed)

A horizontally scalable, production-grade mail system built with **Postfix, Dovecot, Rspamd, Valkey, MariaDB, and NFS**, fully automated using **Ansible**.

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

* Ansible 2.14+
* Python 3.10+
* MariaDB 10.11+
* Postfix
* Dovecot
* Rspamd
* Valkey
* NFS server

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

* Use PostfixAdmin or SQL directly
* Stored in MariaDB

## Test Authentication

```bash
doveadm auth test user@domain
```

## Test Delivery

```bash
doveadm lmtp -d user@domain
```

## Send Mail

* SMTP ports: 25 / 465 / 587

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
vmail_uid: 5000
vmail_gid: 5000
mail_root: /var/vmail
```

---

## MariaDB

```yaml
mysql_host: 192.168.1.230
mysql_port: 3306

mail_db_name: mailserver
mail_db_user: mailuser
mail_db_password: secure_password
```

---

## Dovecot

```yaml
dovecot_protocols: "imap lmtp"
dovecot_mail_location: "maildir:/var/vmail/%d/%n"

dovecot_auth_mechanisms: "plain login"

dovecot_sql_driver: mysql
dovecot_sql_connect: "host={{ mysql_host }} dbname={{ mail_db_name }} user={{ mail_db_user }} password={{ mail_db_password }}"

dovecot_lmtp_socket: "inet:24"
```

---

## Postfix

```yaml
postfix_myhostname: "{{ mail_hostname }}"
postfix_mydomain: "{{ mail_domain }}"

postfix_inet_interfaces: all
postfix_inet_protocols: ipv4

postfix_smtpd_tls_cert_file: /etc/ssl/certs/mail.pem
postfix_smtpd_tls_key_file: /etc/ssl/private/mail.key

postfix_virtual_mailbox_domains: "mysql:/etc/postfix/mysql-virtual-domains.cf"
postfix_virtual_mailbox_maps: "mysql:/etc/postfix/mysql-virtual-mailboxes.cf"
postfix_virtual_alias_maps: "mysql:/etc/postfix/mysql-virtual-aliases.cf"

postfix_sasl_type: dovecot
postfix_sasl_path: private/auth

postfix_milter_default_action: accept
postfix_milter_protocol: 6
postfix_smtpd_milters: inet:rspamd:11332
```

---

## Rspamd

```yaml
rspamd_bind: 0.0.0.0
rspamd_port: 11332

rspamd_redis_servers: "192.168.1.233:6379"

rspamd_dkim_signing: true
rspamd_dkim_domain: example.com
rspamd_dkim_selector: mail
```

---

## Valkey

```yaml
valkey_bind: 0.0.0.0
valkey_port: 6379
valkey_maxmemory: 512mb
valkey_maxmemory_policy: allkeys-lru
```

---

## NFS

```yaml
nfs_export_path: /var/vmail
nfs_allowed_hosts:
  - 192.168.1.0/24
```

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

1. Add via PostfixAdmin or DB
2. Verify:

   * MX record exists
   * DKIM configured
3. Test send/receive

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
