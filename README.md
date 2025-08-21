# Self-hosted Private DNS (Pi-hole + Dnsdist + Caddy)

![Pi-hole Dashboard Screenshot](docs/images/pihole-dashboard.png)

Run your own **private DNS resolver** with advanced filtering, DNS over HTTPS (DoH), and DNS over TLS (DoT) — all in a simple Docker setup.  
Pi-hole provides customizable DNS filtering and query logging, dnsdist handles DNS/DoT/DoH backends, and Caddy manages HTTPS with automatic Let's Encrypt certificates.

## ✨ Features

- **Custom DNS filtering**: Centralized control over which domains are resolved
- **Secure DNS**: DoH at `https://<DOMAIN_DNS>/dns-query` and DoT on port `853`
- **Automatic TLS**: Caddy obtains and renews certificates via Let's Encrypt
- **Dashboard**: Full query visibility and management at `https://<DOMAIN_DNS>/admin/login`
- **Persistence & health checks**: Data volumes and restart policies included

## 🔧 Prerequisites

- **A/AAAA DNS records** pointing both domains to your server’s public IP:
  - `DOMAIN_DNS` → e.g., `dns.example.com`
  - `DOMAIN_DASHBOARD` → e.g., `dashboard.example.com`
- **Open ports** on your server:
  - `80, 443` → Caddy (HTTP/HTTPS)
  - `53/tcp+udp` → DNS
  - `853/tcp` → DoT
- **Docker & Docker Compose** installed

## 🚀 Quick start

1. Clone and enter the project:

```bash
git clone --depth=1 --branch active https://github.com/allenhack638/dns-server.git
cd dns-server
```

2. Copy the environment file and edit values:

```bash
cp env.example .env
```

3. Start the stack:

```bash
docker compose up -d
```

## 📜 Logs & Troubleshooting

You can check logs to verify everything is running correctly or to debug issues.

### View all service logs (live)

```bash
docker compose logs
```

### View individual service logs

```bash
docker compose logs dns-pihole
```

```bash
docker compose logs dns-caddy
```

```bash
docker compose logs dns-dnsdist
```

## ⚙️ Environment variables

| Variable                         | Description                               |
| -------------------------------- | ----------------------------------------- |
| `TZ`                             | Timezone (e.g., `Asia/Kolkata`)           |
| `FTLCONF_webserver_api_password` | Dashboard login password                  |
| `DOMAIN_DNS`                     | Public domain for DoH/DoT (TLS via Caddy) |
| `DOMAIN_DASHBOARD`               | Public domain for the dashboard           |

👉 Timezone in tz database format (e.g., `America/New_York`, `Asia/Kolkata`) – see the full list in the [tz database time zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).

## 💾 Data & persistence

- Pi-hole configuration and DNSMasq data persist in the `data/` directory
- Certificates are stored under `data/caddy-data/`
- Certificates are also copied to `data/shared-certs/` for dnsdist

## 📡 Usage

| Protocol  | Address / URL                       | Port |
| --------- | ----------------------------------- | ---- |
| DoH       | `https://<DOMAIN_DNS>/dns-query`    | 443  |
| DoT       | `<DOMAIN_DNS>`                      | 853  |
| DNS       | `<SERVER_IP>`                       | 53   |
| Dashboard | `https://<DOMAIN_DASHBOARD>/admin/` | 443  |

## 📍 Ports

| Port(s)        | Service                 |
| -------------- | ----------------------- |
| 80 / 443       | Caddy (HTTP/HTTPS)      |
| 53/tcp, 53/udp | DNS (dnsdist → Pi-hole) |
| 853/tcp        | DoT (dnsdist)           |

### Learn how to open ports:

- **On Linux (ufw, firewalld, or iptables)** — see the [DigitalOcean guide on opening ports](https://www.digitalocean.com/community/tutorials/opening-a-port-on-linux) :contentReference[oaicite:2]{index=2}
- **On Windows (Windows Defender Firewall)** — follow this [step-by-step article from Liquid Web](https://www.liquidweb.com/blog/open-a-port-in-windows-firewall-easily-safely/) :contentReference[oaicite:3]{index=3}

> Tip: Always follow your local IT/security policies when opening firewall ports.

## 📝 Notes

- Ensure your domain DNS records are configured **before starting**, so Caddy can obtain certificates.
- Set a strong password for **`FTLCONF_webserver_api_password`**.

## 🙌 Credits

This project would not be possible without the following open-source software:

- [Pi-hole](https://pi-hole.net/) – Network-level DNS filtering and management
- [dnsdist](https://dnsdist.org/) – Highly DNS-, DoS- and abuse-aware load-balancer
- [Caddy](https://caddyserver.com/) – Powerful, enterprise-ready web server with automatic HTTPS

## 🤝 Contributing & Issues

If you encounter any issues, have questions, or would like to suggest new features, please feel free to open an issue or start a discussion in this repository. Contributions and feedback are always welcome!

## 📖 Advanced Configuration

Need more than the default setup? I can help you with:

- Custom ACLs and fine-grained access control
- Advanced dnsdist load-balancing strategies
- Conditional forwarding rules
- Integration with upstream/external resolvers
- Enterprise-grade scaling and security hardening

📬 Contact: [allenbenny038@gmail.com](mailto:allenbenny038@gmail.com)
