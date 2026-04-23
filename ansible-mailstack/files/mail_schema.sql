-- Mailserver Database Schema
-- For Postfix, Dovecot, and PostfixAdmin

USE mailserver;

-- ============================================
-- DOMAINS
-- ============================================
CREATE TABLE IF NOT EXISTS domain (
    id INT AUTO_INCREMENT PRIMARY KEY,
    domain VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    max_quota BIGINT DEFAULT 10737418240,
    quota_used BIGINT DEFAULT 0,
    active TINYINT(1) DEFAULT 1,
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_domain_active (domain, active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- MAILBOXES (users)
-- ============================================
CREATE TABLE IF NOT EXISTS mailbox (
    username VARCHAR(255) PRIMARY KEY,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(255),
    domain VARCHAR(255) NOT NULL,
    local_part VARCHAR(255) GENERATED ALWAYS AS (SUBSTRING_INDEX(username, '@', 1)) STORED,
    quota BIGINT DEFAULT 1073741824,
    bytes_stored BIGINT DEFAULT 0,
    messages_stored INT DEFAULT 0,
    active TINYINT(1) DEFAULT 1,
    send_only TINYINT(1) DEFAULT 0,
    last_login DATETIME,
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (domain) REFERENCES domain(domain) ON DELETE CASCADE,
    INDEX idx_domain (domain),
    INDEX idx_active (active),
    INDEX idx_local_part (local_part)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- ALIASES
-- ============================================
CREATE TABLE IF NOT EXISTS alias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    address VARCHAR(255) NOT NULL,
    goto TEXT NOT NULL,
    domain VARCHAR(255) NOT NULL,
    active TINYINT(1) DEFAULT 1,
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (domain) REFERENCES domain(domain) ON DELETE CASCADE,
    INDEX idx_address (address),
    INDEX idx_domain_active (domain, active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- DOMAIN ALIASES
-- ============================================
CREATE TABLE IF NOT EXISTS domain_alias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    alias_domain VARCHAR(255) NOT NULL UNIQUE,
    target_domain VARCHAR(255) NOT NULL,
    active TINYINT(1) DEFAULT 1,
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (target_domain) REFERENCES domain(domain) ON DELETE CASCADE,
    INDEX idx_alias (alias_domain),
    INDEX idx_target (target_domain)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- QUOTA TRACKING (for Dovecot dict)
-- ============================================
CREATE TABLE IF NOT EXISTS quota (
    username VARCHAR(255) PRIMARY KEY,
    bytes BIGINT DEFAULT 0,
    count INT DEFAULT 0,
    updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (username) REFERENCES mailbox(username) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- DEFAULT DATA
-- ============================================

-- Insert your primary domain (change example.com to your actual domain)
INSERT IGNORE INTO domain (domain, description, max_quota) 
VALUES ('example.com', 'Primary mail domain', 10737418240);

-- Insert postmaster alias (required by RFC)
INSERT IGNORE INTO alias (address, goto, domain, active) 
SELECT 'postmaster@example.com', 'admin@example.com', 'example.com', 1
WHERE EXISTS (SELECT 1 FROM domain WHERE domain = 'example.com');

-- Insert abuse alias (required by RFC)
INSERT IGNORE INTO alias (address, goto, domain, active) 
SELECT 'abuse@example.com', 'admin@example.com', 'example.com', 1
WHERE EXISTS (SELECT 1 FROM domain WHERE domain = 'example.com');

-- ============================================
-- VERIFICATION
-- ============================================
SELECT 'Schema created successfully!' AS Status;
SHOW TABLES;