#!/bin/bash

# Bei Fehlern abbrechen
set -e

# Versionsnummern festlegen
MONGO_VERSION="4.4.18"
OPENSSL_VERSION="1.1.1o"

# Installationspfade definieren
INSTALL_DIR="/opt/mongodb"
OPENSSL_DIR="/opt/openssl-$OPENSSL_VERSION"
DBPATH="/data/db"

echo "[+] Erstelle Verzeichnisse..."
mkdir -p $INSTALL_DIR $OPENSSL_DIR $DBPATH
mkdir -p /var/log/mongodb
chmod 777 $DBPATH

echo "[+] Lade MongoDB $MONGO_VERSION herunter..."
cd /tmp
wget -q https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu1804-${MONGO_VERSION}.tgz
tar -xvzf mongodb-linux-x86_64-ubuntu1804-${MONGO_VERSION}.tgz
mv mongodb-linux-x86_64-ubuntu1804-${MONGO_VERSION}/bin/* $INSTALL_DIR/
rm -rf mongodb-linux-x86_64-ubuntu1804-${MONGO_VERSION}*

echo "[+] Lade und kompiliere OpenSSL $OPENSSL_VERSION..."
cd $OPENSSL_DIR
wget -q https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz
tar -xvzf openssl-$OPENSSL_VERSION.tar.gz
cd openssl-$OPENSSL_VERSION
./config --prefix=$OPENSSL_DIR
make -j$(nproc)
make install_sw

echo "[+] Erstelle MongoDB-Konfigurationsdatei..."
cat <<EOF > /etc/mongodb.conf
storage:
  dbPath: $DBPATH
systemLog:
  destination: file
  path: /var/log/mongodb/mongod.log
  logAppend: true
net:
  bindIp: 127.0.0.1
  port: 27017
EOF

echo "[+] Erstelle systemd-Dienst..."
cat <<EOF > /etc/systemd/system/mongodb.service
[Unit]
Description=MongoDB (ohne AVX, OpenSSL $OPENSSL_VERSION)
After=network.target

[Service]
ExecStart=$INSTALL_DIR/mongod --dbpath $DBPATH --config /etc/mongodb.conf
Environment=LD_LIBRARY_PATH=$OPENSSL_DIR/lib
Restart=always
User=root
LimitNOFILE=64000

[Install]
WantedBy=multi-user.target
EOF

echo "[+] Lade systemd neu und starte MongoDB..."
systemctl daemon-reload
systemctl enable mongodb
systemctl start mongodb

echo "[✓] Fertig! MongoDB läuft jetzt als Dienst."
echo "    Überprüfen mit: systemctl status mongodb"
