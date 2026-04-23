#!/bin/bash
# Mail Query Tool for MailStack
# Installed on Rspamd server by Ansible
# Reads configuration from /etc/mailstack/mailstack.conf

set -e

MAILSTACK_CONFIG="/etc/mailstack/mailstack.conf"
MYSQL_CONFIG="/etc/mysql/mailstack.cnf"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

usage() {
    echo "Usage: mail-query [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -d, --domains          List all domains"
    echo "  -u, --users            List all users"
    echo "  -a, --aliases          List all aliases"
    echo "  -s, --stats            Show database statistics"
    echo "  -D, --domain DOMAIN    Show details for specific domain"
    echo "  -U, --user EMAIL       Show details for specific user"
    echo "  -h, --help             Show this help"
    echo ""
    echo "Examples:"
    echo "  mail-query --domains"
    echo "  mail-query --user test2@example.com"
    echo "  mail-query --domain example.com"
}

# Install MySQL client if needed
if ! command -v mysql &> /dev/null; then
    apt update && apt install -y default-mysql-client
fi

# Check if MySQL config exists
if [ ! -f "$MYSQL_CONFIG" ]; then
    echo -e "${RED}Error: MySQL config not found. Run Ansible playbook first.${NC}"
    exit 1
fi

case "$1" in
    -d|--domains)
        echo -e "${GREEN}=== Domains ===${NC}"
        mysql --defaults-extra-file="$MYSQL_CONFIG" -e "SELECT domain, active, DATE_FORMAT(created, '%Y-%m-%d') as created FROM domain ORDER BY domain;"
        ;;
    -u|--users)
        echo -e "${GREEN}=== Users ===${NC}"
        mysql --defaults-extra-file="$MYSQL_CONFIG" -e "SELECT username, domain, active, DATE_FORMAT(created, '%Y-%m-%d') as created FROM mailbox ORDER BY domain, username;"
        ;;
    -a|--aliases)
        echo -e "${GREEN}=== Aliases ===${NC}"
        mysql --defaults-extra-file="$MYSQL_CONFIG" -e "SELECT address, goto, domain, active FROM alias ORDER BY domain, address;"
        ;;
    -s|--stats)
        echo -e "${GREEN}=== Statistics ===${NC}"
        mysql --defaults-extra-file="$MYSQL_CONFIG" -e "
            SELECT 'Domains' as Type, COUNT(*) as Count FROM domain
            UNION SELECT 'Mailboxes', COUNT(*) FROM mailbox
            UNION SELECT 'Aliases', COUNT(*) FROM alias;"
        ;;
    -D|--domain)
        if [ -z "$2" ]; then
            echo -e "${RED}Please specify a domain${NC}"
            exit 1
        fi
        echo -e "${GREEN}=== Domain: $2 ===${NC}"
        mysql --defaults-extra-file="$MYSQL_CONFIG" -e "SELECT * FROM domain WHERE domain='$2';"
        ;;
    -U|--user)
        if [ -z "$2" ]; then
            echo -e "${RED}Please specify an email${NC}"
            exit 1
        fi
        echo -e "${GREEN}=== User: $2 ===${NC}"
        mysql --defaults-extra-file="$MYSQL_CONFIG" -e "SELECT * FROM mailbox WHERE username='$2';"
        ;;
    -h|--help)
        usage
        ;;
    *)
        usage
        ;;
esac