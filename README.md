## Instructions

This monitoring repo depends on node_exporter from prometheus to work. 
It checks that you are validating blocks from data posted on https://indexer.q.org/.

For other default metrics, please see the section "Geth Metrics".

### Installation

```
wget https://github.com/prometheus/node_exporter/releases/download/v*/node_exporter-*.*-amd64.tar.gz
tar xvfz node_exporter-*.*-amd64.tar.gz
cd node_exporter-*.*-amd64
cp node_exporter /usr/local/bin

git clone https://github.com/chainlayer/q-monitoring.git
cd q-monitoring
cp nodeexporter.service /etc/system/systemd/
systemctl enable nodeexporter.service
systemctl start nodeexporter.service
```

* Copy the .env.example file to .env and edit your validator address
* Add the script to cron, for example:

```
* * * * * /root/q-monitoring/getminedblocks.sh >> /root/q-monitoring/getminedblocks.log 2>>/root/q-monitoring/getminedblocks.err
```

### Prometheus Alert Rule
expr: q_mined_blocks < 1

### Geth Metrics

To enable the default Geth metrics that can be scraped normally using Prometheus.
With these metrics you can check if your node is up/down, behind on blocks and more.

```
nano /mainnet-public-tools/<type>/docker-compose.yaml
```

Edit Services > Node > Entrypoint.
```
entrypoint: ["geth", "--metrics", "--metrics.addr", "0.0.0.0", "--metrics.port", "5054", "--datadir=/data", ...snip...
```

Edit Services > Node > Ports.
```
ports:
- $EXT_PORT:$EXT_PORT/tcp
- $EXT_PORT:$EXT_PORT/udp
- 5054:5054/tcp
- 5054:5054/udp
```