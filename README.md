## Instructions

This monitoring repo depends on node_exporter from prometheus to work

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

