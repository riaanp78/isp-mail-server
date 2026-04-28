-- ============================================================
-- Mailserver Database Schema
-- For Postfix, Dovecot 2.4, and custom admin
-- ============================================================

-- CREATE DATABASE IF NOT EXISTS mailserver
--   CHARACTER SET utf8mb4
--   COLLATE utf8mb4_unicode_ci;

USE mailserver;

-- ============================================================
-- DOMAINS
-- ============================================================
CREATE TABLE IF NOT EXISTS domain (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    domain      VARCHAR(255)    NOT NULL UNIQUE,
    description TEXT,
    -- Per-domain quota ceiling in bytes (default 10 GiB)
    max_quota   BIGINT          DEFAULT 10737418240,
    -- Running total updated by trigger on mailbox insert/update/delete
    quota_used  BIGINT          DEFAULT 0,
    active      TINYINT(1)      DEFAULT 1,
    created     DATETIME        DEFAULT CURRENT_TIMESTAMP,
    modified    DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_domain_active (domain, active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- MAILBOXES (virtual users)
-- ============================================================
CREATE TABLE IF NOT EXISTS mailbox (
    -- Full email address is the primary key — matches Dovecot %{user}
    username        VARCHAR(255)    PRIMARY KEY,
    -- Password hash: store as {BLF-CRYPT}$2y$... prefix for Dovecot
    password        VARCHAR(255)    NOT NULL,
    name            VARCHAR(255),
    domain          VARCHAR(255)    NOT NULL,
    -- Generated column: local part before @ — matches NFS directory name
    local_part      VARCHAR(255)    GENERATED ALWAYS AS (SUBSTRING_INDEX(username, '@', 1)) STORED,
    -- Per-mailbox quota in bytes (0 = unlimited); returned to Dovecot as quota_storage_size
    quota           BIGINT          DEFAULT 1073741824,
    active          TINYINT(1)      DEFAULT 1,
    -- Outbound-only: can send but Postfix will not deliver inbound mail
    send_only       TINYINT(1)      DEFAULT 0,
    last_login      DATETIME        NULL,
    created         DATETIME        DEFAULT CURRENT_TIMESTAMP,
    modified        DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (domain) REFERENCES domain(domain) ON DELETE CASCADE,
    INDEX idx_domain     (domain),
    INDEX idx_active     (active),
    INDEX idx_local_part (local_part)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- QUOTA TRACKING
-- Written by Dovecot dict quota driver (dovecot-dict-sql.conf.ext).
-- The 'count' quota driver enforces limits via userdb quota_storage_size;
-- this table holds the running byte/message count for reporting.
-- ============================================================
CREATE TABLE IF NOT EXISTS quota (
    username    VARCHAR(255)    PRIMARY KEY,
    bytes       BIGINT          DEFAULT 0,
    messages    INT             DEFAULT 0,
    updated     DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (username) REFERENCES mailbox(username) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- ALIASES
-- goto is a comma-separated list of delivery targets
-- ============================================================
CREATE TABLE IF NOT EXISTS alias (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    address     VARCHAR(255)    NOT NULL,
    goto        TEXT            NOT NULL,
    domain      VARCHAR(255)    NOT NULL,
    active      TINYINT(1)      DEFAULT 1,
    created     DATETIME        DEFAULT CURRENT_TIMESTAMP,
    modified    DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (domain) REFERENCES domain(domain) ON DELETE CASCADE,
    INDEX idx_address       (address),
    INDEX idx_domain_active (domain, active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- DOMAIN ALIASES
-- Maps an entire alias domain to a real target domain
-- ============================================================
CREATE TABLE IF NOT EXISTS domain_alias (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    alias_domain    VARCHAR(255)    NOT NULL UNIQUE,
    target_domain   VARCHAR(255)    NOT NULL,
    active          TINYINT(1)      DEFAULT 1,
    created         DATETIME        DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (target_domain) REFERENCES domain(domain) ON DELETE CASCADE,
    INDEX idx_alias  (alias_domain),
    INDEX idx_target (target_domain)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- DOMAIN QUOTA TRIGGERS
-- Keeps domain.quota_used in sync with mailbox quota allocations.
-- Note: this tracks allocated quota, not bytes consumed.
-- Bytes consumed is tracked in the quota table by Dovecot.
-- ============================================================
DELIMITER $$

CREATE TRIGGER trg_mailbox_insert_quota
AFTER INSERT ON mailbox
FOR EACH ROW
BEGIN
    UPDATE domain
       SET quota_used = quota_used + NEW.quota
     WHERE domain = NEW.domain;
END$$

CREATE TRIGGER trg_mailbox_update_quota
AFTER UPDATE ON mailbox
FOR EACH ROW
BEGIN
    IF OLD.quota != NEW.quota THEN
        UPDATE domain
           SET quota_used = quota_used + (NEW.quota - OLD.quota)
         WHERE domain = NEW.domain;
    END IF;
END$$

CREATE TRIGGER trg_mailbox_delete_quota
AFTER DELETE ON mailbox
FOR EACH ROW
BEGIN
    UPDATE domain
       SET quota_used = GREATEST(0, quota_used - OLD.quota)
     WHERE domain = OLD.domain;
END$$

DELIMITER ;

-- ============================================================
-- POSTFIX LOOKUP VIEWS
-- Point Postfix mysql lookup maps at these views.
-- Decouples Postfix config from table structure.
-- ============================================================

-- virtual_mailbox_domains
CREATE OR REPLACE VIEW postfix_domains AS
    SELECT domain
      FROM domain
     WHERE active = 1;

-- virtual_mailbox_maps
CREATE OR REPLACE VIEW postfix_mailboxes AS
    SELECT username,
           CONCAT(domain, '/', local_part, '/Maildir/') AS maildir
      FROM mailbox
     WHERE active = 1
       AND send_only = 0;

-- virtual_alias_maps (explicit aliases + mailbox self-delivery)
CREATE OR REPLACE VIEW postfix_aliases AS
    SELECT address, goto
      FROM alias
     WHERE active = 1
    UNION ALL
    SELECT username AS address,
           username AS goto
      FROM mailbox
     WHERE active = 1
       AND send_only = 0;

-- smtpd_sender_login_maps (prevents sender spoofing)
CREATE OR REPLACE VIEW postfix_sender_login AS
    SELECT username AS sender,
           username AS login
      FROM mailbox
     WHERE active = 1;

-- ============================================================
-- DEFAULT DATA
-- ============================================================

INSERT IGNORE INTO domain (domain, description, max_quota)
    VALUES ('example.com', 'Primary mail domain', 10737418240);

INSERT IGNORE INTO alias (address, goto, domain, active)
    SELECT 'postmaster@example.com', 'admin@example.com', 'example.com', 1
     WHERE EXISTS (SELECT 1 FROM domain WHERE domain = 'example.com');

INSERT IGNORE INTO alias (address, goto, domain, active)
    SELECT 'abuse@example.com', 'admin@example.com', 'example.com', 1
     WHERE EXISTS (SELECT 1 FROM domain WHERE domain = 'example.com');

-- ============================================================
-- VERIFICATION
-- ============================================================
SELECT 'Schema created successfully!' AS Status;
SHOW TABLES;
