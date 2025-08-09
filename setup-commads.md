# Create directory structure

mkdir -p dns-server/{configs/{dnsdist,caddy},data/{pihole,dnsmasq.d}}
cd dns-server

# Copy your existing Pi-hole configuration (if any)

# cp -r /path/to/existing/etc-pihole/\* ./data/pihole/

# Start the services

docker-compose up -d

# Check logs

docker-compose logs -f

# Check individual service logs

docker-compose logs pihole
docker-compose logs caddy
docker-compose logs dnsdist
