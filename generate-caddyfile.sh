#!/bin/bash

# Load environment variables
source .env

# Check if either DOMAIN_DNS or DOMAIN_DASHBOARD is set
if [ -z "${DOMAIN_DNS:-}" ] && [ -z "${DOMAIN_DASHBOARD:-}" ]; then
  echo "❌ Error: Neither DOMAIN_DNS nor DOMAIN_DASHBOARD is configured"
  echo "   Please set at least one domain in your .env file:"
  echo "   DOMAIN_DNS=dns.yourdomain.com"
  echo "   DOMAIN_DASHBOARD=admin.yourdomain.com"
  exit 1
fi

# Ensure the caddy config directory exists
mkdir -p configs/caddy

# Start with empty Caddyfile in the correct location
cat > configs/caddy/Caddyfile <<EOF
# Auto-generated Caddyfile based on environment variables
# Generated on: $(date)
EOF

# Add DoH block OR certificate generation if ENABLE_DOH is true OR DOT_PORT is configured
if [ "${ENABLE_DOH:-false}" = "true" ] || [ -n "${DOT_PORT:-}" ]; then
  # Check if DOMAIN_DNS is set and not empty
  if [ -n "${DOMAIN_DNS:-}" ]; then
    
    # Only add DoH endpoint if ENABLE_DOH is explicitly true
    if [ "${ENABLE_DOH:-false}" = "true" ]; then
      cat >> configs/caddy/Caddyfile <<'EOF'

# DNS over HTTPS endpoint
{$DOMAIN_DNS} {
  encode gzip

  # Handle DoH requests - proxy to dnsdist container port 443
  handle /dns-query* {
    reverse_proxy https://dnsdist:443 {
      transport http {
        tls_insecure_skip_verify
      }
    }
  }

  # Default response for other paths
  handle {
    header Content-Type "text/plain"
    respond "DNS over HTTPS endpoint - Use /dns-query for DNS queries" 200
  }

  # Logging
  log {
    output file /data/logs/dns-access.log {
      roll_size 10MB
      roll_keep 5
    }
  }
}
EOF
      echo "✅ DoH endpoint block added to Caddyfile (${DOMAIN_DNS})"
    
    else
      # DOT_PORT is configured but ENABLE_DOH is false - just generate certificates
      cat >> configs/caddy/Caddyfile <<'EOF'

# Certificate generation for DNS over TLS (DoT)
# This block ensures SSL certificates are generated for DoT service
{$DOMAIN_DNS} {
  # Simple response to generate certificates for DoT
  respond "DNS over TLS (DoT) is available on port 853" 200
  
  # Logging
  log {
    output file /data/logs/dns-access.log {
      roll_size 10MB
      roll_keep 5
    }
  }
}
EOF
      echo "✅ Certificate generation block added for DoT service (${DOMAIN_DNS})"
      echo "   DoT will be available on: ${DOMAIN_DNS}:853"
    fi
    
  else
    # Missing DOMAIN_DNS
    if [ "${ENABLE_DOH:-false}" = "true" ]; then
      echo "⚠️  Warning: ENABLE_DOH is true but DOMAIN_DNS is not configured"
      echo "   Please set DOMAIN_DNS in your .env file (e.g., DOMAIN_DNS=dns.yourdomain.com)"
      echo "   Skipping DoH endpoint configuration"
    fi
    
    if [ -n "${DOT_PORT:-}" ]; then
      echo "⚠️  Warning: DOT_PORT is configured but DOMAIN_DNS is not set"
      echo "   Please set DOMAIN_DNS in your .env file (e.g., DOMAIN_DNS=dns.yourdomain.com)"
      echo "   DoT service needs certificates which require a domain name"
      echo "   Skipping certificate generation for DoT"
    fi
  fi
fi

# Add Dashboard block if ENABLE_DASHBOARD is true
if [ "${ENABLE_DASHBOARD:-false}" = "true" ]; then
  # Check if DOMAIN_DASHBOARD is set and not empty
  if [ -n "${DOMAIN_DASHBOARD:-}" ]; then
    cat >> configs/caddy/Caddyfile <<'EOF'

# Pi-hole Dashboard
{$DOMAIN_DASHBOARD} {
  encode gzip

  # Proxy to Pi-hole web interface
  reverse_proxy http://pihole:80 {
    # Pi-hole specific headers
    header_down -Server
    header_down +X-Frame-Options "SAMEORIGIN"
    header_down +X-Content-Type-Options "nosniff"
  }

  # Logging  
  log {
    output file /data/logs/dashboard-access.log {
      roll_size 10MB
      roll_keep 5
    }
  }
}
EOF
    echo "✅ Dashboard block added to Caddyfile (${DOMAIN_DASHBOARD})"
  else
    echo "⚠️  Warning: ENABLE_DASHBOARD is true but DOMAIN_DASHBOARD is not configured"
    echo "   Please set DOMAIN_DASHBOARD in your .env file (e.g., DOMAIN_DASHBOARD=admin.yourdomain.com)"
    echo "   Skipping Dashboard configuration"
  fi
fi