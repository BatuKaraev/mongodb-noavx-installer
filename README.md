# MongoDB 4.4 Installer for AVX-less CPUs (Debian 11/12)

🛠 This script installs MongoDB 4.4.18 on Debian 11 or 12 — **without AVX**, **without Docker**, and with proper `systemd` integration.

## ❓ Why?

Because MongoDB 5.0+ requires AVX CPU instructions. Many VPS, older machines, and embedded systems (like Raspberry Pi) don’t support AVX. This installer solves that problem.

## ✅ What This Script Does

- Downloads and installs MongoDB 4.4.18 binaries
- Compiles OpenSSL 1.1.1o from source (required for compatibility)
- Sets up `mongod` as a `systemd` service
- Avoids Docker and all AVX dependencies

## 🚀 Usage

```bash
chmod +x install-mongo-noavx.sh
sudo ./install-mongo-noavx.sh
```

Check if MongoDB is running:

```bash
systemctl status mongodb
```

## 📦 Requirements

- Debian 11 or 12
- Root privileges
- No AVX required
- ~400MB free space

## ⚠️ Warnings

- MongoDB will bind to `localhost` only (secure by default)
- To allow remote connections, change `--bind_ip` or use `--bind_ip_all` in the systemd unit

## 👨‍💻 Author

[@BatuKaraev](https://github.com/BatuKaraev)

If this helped you — leave a ⭐ star, or send a PR!
