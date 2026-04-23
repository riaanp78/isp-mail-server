#!/bin/bash
# DKIM Key Generator for MailStack - Rspamd 4.x
# Stores keys on NFS shared storage for distributed access
# Maintains signing_table for multi-domain DKIM signing

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration file
MAILSTACK_CONFIG="/etc/mailstack/mailstack.conf"
MYSQL_CONFIG="/etc/mysql/mailstack.cnf"

# Rspamd 4.x signing table location
SIGNING_TABLE="/etc/rspamd/maps.d/dkim_signing.map"
SIGNING_TABLE_DIR="/etc/rspamd/maps.d"

# Default values
SELECTOR="mail"
KEY_SIZE="2048"
DO_ALL=false
FORCE=false
LIST_DOMAINS=false
LIST_ALL=false
CHECK_DOMAIN=""
MAIL_DOMAIN=""
VMAIL_HOME=""

# Function to read config value
get_config() {
    local section=$1
    local key=$2
    grep -A10 "^\[$section\]" "$MAILSTACK_CONFIG" | grep "^$key" | cut -d'=' -f2- | tr -d ' '
}

# Function to show usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -d, --domain DOMAIN    Domain name (default: from config)"
    echo "  -s, --selector SELECT  DKIM selector (default: mail)"
    echo "  -b, --bits BITS        Key size in bits (default: 2048)"
    echo "  -f, --force            Force regenerate existing keys"
    echo "  -a, --all              Generate for all domains in database"
    echo "  -l, --list-domains     List all domains with DKIM status"
    echo "  -L, --list-all         List all domains with DKIM DNS records"
    echo "  -c, --check DOMAIN     Check if DKIM key exists for domain"
    echo "  -h, --help             Show this help"
    exit 0
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root (sudo)${NC}"
    exit 1
fi

# Check if configuration exists
if [ ! -f "$MAILSTACK_CONFIG" ]; then
    echo -e "${RED}Error: Configuration file not found: $MAILSTACK_CONFIG${NC}"
    exit 1
fi

# Read default values from config
MAIL_DOMAIN=$(get_config mailstack mail_domain)
VMAIL_HOME=$(get_config mailstack vmail_home)

# DKIM storage paths
DKIM_NFS_DIR="$VMAIL_HOME/dkim"
DKIM_LOCAL_DIR="/var/lib/rspamd/dkim"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--domain)
            MAIL_DOMAIN="$2"
            shift 2
            ;;
        -s|--selector)
            SELECTOR="$2"
            shift 2
            ;;
        -b|--bits)
            KEY_SIZE="$2"
            shift 2
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -a|--all)
            DO_ALL=true
            shift
            ;;
        -l|--list-domains)
            LIST_DOMAINS=true
            shift
            ;;
        -L|--list-all)
            LIST_ALL=true
            shift
            ;;
        -c|--check)
            CHECK_DOMAIN="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            ;;
    esac
done

# Function to create directories with correct permissions for Rspamd 4.x
create_dkim_dirs() {
    # Create NFS directory if it doesn't exist
    if [ ! -d "$DKIM_NFS_DIR" ]; then
        echo -e "${YELLOW}Creating NFS DKIM directory: $DKIM_NFS_DIR${NC}"
        mkdir -p "$DKIM_NFS_DIR"
        chown _rspamd:_rspamd "$DKIM_NFS_DIR"
        chmod 755 "$DKIM_NFS_DIR"
    fi
    
    # Create local symlink directory if it doesn't exist
    if [ ! -d "$DKIM_LOCAL_DIR" ]; then
        echo -e "${YELLOW}Creating local DKIM directory: $DKIM_LOCAL_DIR${NC}"
        mkdir -p "$DKIM_LOCAL_DIR"
        chown _rspamd:_rspamd "$DKIM_LOCAL_DIR"
        chmod 755 "$DKIM_LOCAL_DIR"
    fi
    
    # Create maps.d directory for signing table
    if [ ! -d "$SIGNING_TABLE_DIR" ]; then
        echo -e "${YELLOW}Creating signing table directory: $SIGNING_TABLE_DIR${NC}"
        mkdir -p "$SIGNING_TABLE_DIR"
        chown _rspamd:_rspamd "$SIGNING_TABLE_DIR"
        chmod 755 "$SIGNING_TABLE_DIR"
    fi
}

# Function to create symlink with correct permissions for Rspamd 4.x
create_symlink() {
    local domain=$1
    local selector=$2
    local nfs_key_file="$DKIM_NFS_DIR/$domain.$selector.key"
    local local_key_file="$DKIM_LOCAL_DIR/$domain.$selector.key"
    
    # Remove existing file or symlink
    if [ -L "$local_key_file" ] || [ -f "$local_key_file" ]; then
        rm -f "$local_key_file"
    fi
    
    # Create symlink
    ln -sf "$nfs_key_file" "$local_key_file"
    
    # CRITICAL: Fix symlink ownership for Rspamd 4.x
    # Rspamd needs the symlink to be owned by _rspamd to follow it
    chown -h _rspamd:_rspamd "$local_key_file"
    
    # Ensure target key file is readable by Rspamd
    if [ -f "$nfs_key_file" ]; then
        chown _rspamd:_rspamd "$nfs_key_file"
        chmod 600 "$nfs_key_file"
    fi
    
    echo -e "${GREEN}✓ Symlink created: $local_key_file -> $nfs_key_file${NC}"
}

# Function to verify Rspamd can read the key
verify_key_access() {
    local domain=$1
    local selector=$2
    local local_key_file="$DKIM_LOCAL_DIR/$domain.$selector.key"
    
    if sudo -u _rspamd test -r "$local_key_file" 2>/dev/null; then
        echo -e "${GREEN}✓ Rspamd can read key for $domain${NC}"
        return 0
    else
        echo -e "${RED}✗ Rspamd CANNOT read key for $domain${NC}"
        return 1
    fi
}

# Function to update signing table (Rspamd 4.x)
update_signing_table() {
    echo -e "${BLUE}Updating Rspamd 4.x signing table...${NC}"
    
    mkdir -p "$SIGNING_TABLE_DIR"
    chown _rspamd:_rspamd "$SIGNING_TABLE_DIR"
    
    local temp_map="${SIGNING_TABLE}.tmp"
    > "$temp_map"
    
    if [ -d "$DKIM_NFS_DIR" ]; then
        shopt -s nullglob
        for key_file in "$DKIM_NFS_DIR"/*."$SELECTOR".key; do
            if [ -f "$key_file" ]; then
                local domain=$(basename "$key_file" | sed "s/\.$SELECTOR\.key$//")
                local local_key_path="$DKIM_LOCAL_DIR/$domain.$SELECTOR.key"
                echo "$domain:$SELECTOR:$local_key_path" >> "$temp_map"
                echo -e "${GREEN}  Added: $domain${NC}"
            fi
        done
        shopt -u nullglob
    fi
    
    # Always create the file (even if empty)
    mv "$temp_map" "$SIGNING_TABLE"
    chown _rspamd:_rspamd "$SIGNING_TABLE" 2>/dev/null || true
    chmod 644 "$SIGNING_TABLE"
    
    local domain_count=$(cat "$SIGNING_TABLE" 2>/dev/null | wc -l)
    echo -e "${GREEN}✓ Signing table created: $domain_count domains${NC}"
    
    if [ $domain_count -gt 0 ]; then
        echo "Contents:"
        cat "$SIGNING_TABLE"
    fi
}

# Function to check if DKIM key exists
check_dkim_exists() {
    local domain=$1
    local selector=$2
    local key_file="$DKIM_NFS_DIR/$domain.$selector.key"
    
    if [ -f "$key_file" ]; then
        echo -e "${GREEN}✓ DKIM key exists for $domain${NC}"
        echo -e "  Key file: $key_file (on NFS)"
        echo -e "  Selector: $selector"
        echo -e "  Created: $(stat -c %y "$key_file" 2>/dev/null || echo 'unknown')"
        
        # Check if symlink exists locally
        local local_key="$DKIM_LOCAL_DIR/$domain.$selector.key"
        if [ -L "$local_key" ]; then
            echo -e "  Local symlink: ${GREEN}OK${NC}"
        else
            echo -e "  Local symlink: ${YELLOW}MISSING - run script again to create${NC}"
        fi
        return 0
    else
        echo -e "${YELLOW}✗ DKIM key does NOT exist for $domain${NC}"
        return 1
    fi
}

# Function to list domains with status
list_domains() {
    echo -e "${BLUE}=== Domains in Database ===${NC}"
    if [ ! -f "$MYSQL_CONFIG" ]; then
        echo -e "${RED}Error: MySQL config not found: $MYSQL_CONFIG${NC}"
        exit 1
    fi
    
    echo ""
    printf "%-30s %-10s %-20s %-20s\n" "Domain" "Active" "DKIM Status" "In Signing Table"
    echo "--------------------------------------------------------------------------------"
    
    mysql --defaults-extra-file="$MYSQL_CONFIG" -B -N -e "SELECT domain, active FROM domain ORDER BY domain;" 2>/dev/null | while read domain active; do
        local key_file="$DKIM_NFS_DIR/$domain.$SELECTOR.key"
        local in_table=""
        
        if [ -f "$key_file" ]; then
            dkim_status="${GREEN}EXISTS${NC}"
            if grep -q "^$domain:$SELECTOR:" "$SIGNING_TABLE" 2>/dev/null; then
                in_table="${GREEN}YES${NC}"
            else
                in_table="${RED}NO${NC}"
            fi
        else
            dkim_status="${RED}MISSING${NC}"
            in_table="${RED}N/A${NC}"
        fi
        printf "%-30s %-10s ${dkim_status}      ${in_table}\n" "$domain" "$active"
    done
    echo ""
}

# Function to list all DKIM DNS records
list_all_dns_records() {
    echo -e "${BLUE}=== DKIM DNS Records for All Domains ===${NC}"
    echo ""
    echo -e "${YELLOW}Note: Keys are stored on NFS at $DKIM_NFS_DIR${NC}"
    echo ""
    
    if [ ! -f "$MYSQL_CONFIG" ]; then
        echo -e "${RED}Error: MySQL config not found: $MYSQL_CONFIG${NC}"
        exit 1
    fi
    
    # Install MySQL client if not present
    if ! command -v mysql &> /dev/null; then
        echo -e "${YELLOW}MySQL client not found. Installing...${NC}"
        apt update && apt install -y default-mysql-client
    fi
    
    # Get list of domains from database
    DOMAINS=$(mysql --defaults-extra-file="$MYSQL_CONFIG" -B -N -e "SELECT domain FROM domain WHERE active=1 ORDER BY domain;" 2>/dev/null)
    
    if [ -z "$DOMAINS" ]; then
        echo -e "${YELLOW}No domains found in database.${NC}"
        return
    fi
    
    local missing_count=0
    local existing_count=0
    
    for domain in $DOMAINS; do
        local key_file="$DKIM_NFS_DIR/$domain.$SELECTOR.key"
        
        if [ -f "$key_file" ]; then
            echo -e "${GREEN}=== $domain ===${NC}"
            echo -e "Selector: $SELECTOR"
            echo -e "Key size: $KEY_SIZE bits"
            echo -e "Storage: NFS ($DKIM_NFS_DIR)"
            echo -e "DNS Record:"
            echo ""
            rspamadm dkim_keygen -d "$domain" -s "$SELECTOR" -k "$key_file" 2>/dev/null
            echo ""
            ((existing_count++))
        else
            echo -e "${RED}=== $domain ===${NC}"
            echo -e "${YELLOW}⚠ DKIM key not generated yet${NC}"
            echo -e "Run: $0 -d $domain"
            echo ""
            ((missing_count++))
        fi
    done
    
    echo -e "${BLUE}=== Summary ===${NC}"
    echo -e "Total domains: $(echo "$DOMAINS" | wc -l)"
    echo -e "DKIM configured: ${GREEN}$existing_count${NC}"
    echo -e "DKIM missing: ${RED}$missing_count${NC}"
    echo -e "NFS DKIM directory: $DKIM_NFS_DIR"
    echo ""
}

# Function to check a specific domain
check_domain() {
    local domain=$1
    echo -e "${BLUE}=== DKIM Check for domain: $domain ===${NC}"
    echo ""
    check_dkim_exists "$domain" "$SELECTOR"
    
    # Check if in signing table
    if [ -f "$SIGNING_TABLE" ]; then
        if grep -q "^$domain:$SELECTOR:" "$SIGNING_TABLE"; then
            echo -e "${GREEN}✓ Domain is in Rspamd signing table${NC}"
        else
            echo -e "${YELLOW}⚠ Domain is NOT in Rspamd signing table${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ Signing table does not exist yet${NC}"
    fi
    
    # Show DNS record if exists
    local key_file="$DKIM_NFS_DIR/$domain.$SELECTOR.key"
    if [ -f "$key_file" ]; then
        echo ""
        echo -e "${YELLOW}DNS Record for $domain:${NC}"
        echo ""
        rspamadm dkim_keygen -d "$domain" -s "$SELECTOR" -k "$key_file" 2>/dev/null
    fi
}

# Function to generate DKIM for a domain
generate_dkim() {
    local domain=$1
    local selector=$2
    local key_size=$3
    local key_file="$DKIM_NFS_DIR/$domain.$selector.key"
    local force_gen=$4
    
    echo -e "${GREEN}=== Processing domain: $domain ===${NC}"
    
    # Create directories first
    create_dkim_dirs
    
    # Check if key already exists
    if [ -f "$key_file" ] && [ "$force_gen" != "true" ]; then
        echo -e "${YELLOW}DKIM key already exists for $domain on NFS${NC}"
        echo -e "  Key file: $key_file"
        echo -e "  Use -f or --force to regenerate"
        # Still ensure symlink exists
        create_symlink "$domain" "$selector"
        verify_key_access "$domain" "$selector"
        echo ""
        return 0
    fi
    
    if [ -f "$key_file" ] && [ "$force_gen" == "true" ]; then
        echo -e "${YELLOW}Force regenerating DKIM key for $domain...${NC}"
        # Backup old key
        backup_file="${key_file}.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$key_file" "$backup_file"
        echo -e "  Backup saved to: $backup_file"
    fi
    
    # Generate key on NFS
    echo -e "${YELLOW}Generating DKIM key on NFS...${NC}"
    rspamadm dkim_keygen -d "$domain" -s "$selector" -b "$key_size" -k "$key_file"
    chown _rspamd:_rspamd "$key_file"
    chmod 600 "$key_file"
    
    echo -e "${GREEN}✓ DKIM key generated: $key_file${NC}"
    
    # Create symlink from local directory to NFS
    create_symlink "$domain" "$selector"
    
    # Verify Rspamd can read the key
    verify_key_access "$domain" "$selector"
    
    # Display DNS record
    echo -e "${YELLOW}DNS TXT record for $domain:${NC}"
    echo ""
    rspamadm dkim_keygen -d "$domain" -s "$selector" -k "$key_file" 2>/dev/null | grep -A1 "DNS record:" | tail -1
    echo ""
}

# Function to generate DKIM for all domains
generate_all_domains() {
    echo -e "${BLUE}=== Generating DKIM for domains ===${NC}"
    echo -e "Force mode: ${YELLOW}$FORCE${NC}"
    echo -e "NFS DKIM directory: $DKIM_NFS_DIR"
    echo ""
    
    if [ ! -f "$MYSQL_CONFIG" ]; then
        echo -e "${RED}Error: MySQL config not found: $MYSQL_CONFIG${NC}"
        echo "Make sure MySQL client is installed and configuration exists."
        exit 1
    fi
    
    # Install MySQL client if not present
    if ! command -v mysql &> /dev/null; then
        echo -e "${YELLOW}MySQL client not found. Installing...${NC}"
        apt update && apt install -y default-mysql-client
    fi
    
    # Get list of domains from database
    DOMAINS=$(mysql --defaults-extra-file="$MYSQL_CONFIG" -B -N -e "SELECT domain FROM domain WHERE active=1;" 2>/dev/null)
    
    if [ -z "$DOMAINS" ]; then
        echo -e "${YELLOW}No domains found in database.${NC}"
        update_signing_table
        return
    fi
    
    local generated_count=0
    local skipped_count=0
    
    for domain in $DOMAINS; do
        echo ""
        local key_file="$DKIM_NFS_DIR/$domain.$SELECTOR.key"
        
        if [ -f "$key_file" ] && [ "$FORCE" != "true" ]; then
            echo -e "${YELLOW}⚠ Skipping $domain (DKIM already exists on NFS, use -f to force)${NC}"
            # Still ensure symlink exists
            create_symlink "$domain" "$SELECTOR"
            verify_key_access "$domain" "$SELECTOR"
            ((skipped_count++))
        else
            generate_dkim "$domain" "$SELECTOR" "$KEY_SIZE" "$FORCE"
            ((generated_count++))
        fi
    done
    
    # Update signing table after all domains processed
    echo ""
    update_signing_table
    
    # Reload Rspamd if any changes were made
    if [ $generated_count -gt 0 ] || [ ! -f "$SIGNING_TABLE" ]; then
        echo -e "${YELLOW}Reloading Rspamd to apply signing table changes...${NC}"
        systemctl reload rspamd
        echo -e "${GREEN}✓ Rspamd reloaded${NC}"
    else
        echo -e "${GREEN}No signing table changes, Rspamd reload not needed${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}=== Summary ===${NC}"
    echo -e "Domains processed: $(echo "$DOMAINS" | wc -l)"
    echo -e "New keys generated: ${GREEN}$generated_count${NC}"
    echo -e "Skipped (existing): ${YELLOW}$skipped_count${NC}"
}

# Main execution
if [ -n "$CHECK_DOMAIN" ]; then
    check_domain "$CHECK_DOMAIN"
    exit 0
fi

if [ "$LIST_ALL" = true ]; then
    list_all_dns_records
    exit 0
fi

if [ "$LIST_DOMAINS" = true ]; then
    list_domains
    exit 0
fi

if [ "$DO_ALL" = true ]; then
    generate_all_domains
else
    if [ -z "$MAIL_DOMAIN" ]; then
        echo -e "${RED}Error: No domain specified${NC}"
        usage
        exit 1
    fi
    
    generate_dkim "$MAIL_DOMAIN" "$SELECTOR" "$KEY_SIZE" "$FORCE"
    
    # Update signing table and reload Rspamd
    echo ""
    update_signing_table
    echo -e "${YELLOW}Reloading Rspamd to apply signing table changes...${NC}"
    systemctl reload rspamd
    echo -e "${GREEN}✓ Rspamd reloaded${NC}"
fi

echo ""
echo -e "${GREEN}=== DKIM Setup Complete ===${NC}"
echo ""
echo "DKIM keys are stored on NFS at: $DKIM_NFS_DIR"
echo "Rspamd 4.x signing table: $SIGNING_TABLE"
echo ""
echo "Next steps:"
echo "1. Add the DNS TXT records shown above to each domain"
echo "2. Wait for DNS propagation"
echo "3. Test DKIM signing: rspamadm dkim_keygen -d $MAIL_DOMAIN -s $SELECTOR -v"
echo ""
echo "Useful commands:"
echo "  Check DKIM existence:   $0 -c example.com"
echo "  List domains status:    $0 -l"
echo "  List all DNS records:   $0 -L"
echo "  Force regenerate:       $0 -d example.com -f"
echo "  Generate all missing:   $0 -a"
echo "  Force regenerate all:   $0 -a -f"
echo "  View signing table:     cat $SIGNING_TABLE"