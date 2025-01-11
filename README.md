# Sentinel Dockerfiles for Testnet & Mainnet

**Credits**  
- **TrinityStake** for the great supporting guides.  
- **Busurnode** for script shells and testnet support.  
- **Misfits (The Expanse)** for authoring this README (10 JAN 2025).

## Table of Contents
- [Overview](#overview)  
- [Important Notes](#important-notes)  
- [Dockerfiles Overview](#dockerfiles-overview)  
- [Building the Docker Images](#building-the-docker-images)  
- [Mount a Volume](#mount-a-volume)  
- [Contact](#contact)

---

## Overview

This repository contains four Dockerfiles for running a **Sentinel** node/validator on both **mainnet** (`sentinelhub-2`) and **testnet** (`bluenet-2-1`). Each network includes versions with and without **Cosmovisor**. Please ensure you have Docker installed and running before proceeding.

---

## Important Notes

1. **No `ufw` or `systemd`**  
   - These Dockerfiles do not use `ufw` or `systemd`. Therefore, you must manually start the node sentinelhub core after restarting or redeploying the container.
   - Use one of the following commands inside the container:  
     ```bash
     ./state-script.sh
     nohup sentinelhub start &
     nohup cosmovisor run start &
     ```
   - **Reminder**: Docker containers do not persist changes when redeployed. If you need to retain changes, modify the Dockerfile itself.

2. **Performance Tweaks**  
   - The Dockerfiles optimize certain parameters in `config.toml` and `app.toml`:  
     - Indexer is **off**  
     - Prometheus is **on**  
     - State-sync is **on**  
     - Pruning is **custom** (every 1000 blocks, keep last 2 snapshots)  
   - Testnet seeds and peers are limited due to the newer network.

3. **Stability**  
   - Containers have been tested on both Sentinel mainnet and testnet for 3 days and appear stable, assuming adequate hardware.

4. **Additional Efforts**  
   - Prometheus container with Cloud Grafana  
   - TMKMS container (currently in testing)

5. **Support**  
   - For questions or assistance, reach out on Telegram: [@MisfitsCrypto](https://t.me/MisfitsCrypto).

---

## Dockerfiles Overview

- **Sentinel Mainnet** (`sentinelhub-2`)
- **Sentinel Testnet** (`bluenet-2-1`)
- **Sentinel Mainnet Cosmovisor** (`sentinelhub-2`)
- **Sentinel Testnet Cosmovisor** (`bluenet-2-1`)

---

## Building the Docker Images

1. **Clone or copy** the Dockerfiles and any state-sync scripts into a local directory.  
2. **Navigate** to that directory.  
3. **Build** your image:
   ```bash
   docker build -t <image-tag> -f /path/to/dockerfile .
   ```
   **Example:**
   ```bash
   docker build -t sentinel:mainnet -f dockerfile_sentinel_main .
   ```

4. **Run** a container from your newly built image:
   ```bash
   docker run -dit --name <container-name> <image-tag>
   ```
   **Example:**
   ```bash
   docker run -dit --name sentinel_mainnet sentinel:mainnet
   ```

5. **Exec** into your running container:
   ```bash
   docker exec -it <container-name> bash
   ```
   **Example:**
   ```bash
   docker exec -it sentinel_mainnet bash
   ```
   
6. **State-Sync** (once inside the container):
   ```bash
   ./state-sync.sh
   ```
   - This script may have a slightly different name for testnet and cosmovisor variants
   - Run `cat nohup` to view script output

7. **Change Passwords**  
   - `chpasswd root`  
   - `chpasswd sentinel`

8. **Transaction Setup**  
   - Import your node key (e.g., `sentinelhub keys add ...`).  
   - If you are a validator, copy your validator private key JSON into the container (see [Mount a Volume](#mount-a-volume) below).  
   - A TMKMS Docker image is in testing and will be released soon.

---

## Mount a Volume

Mounting a volume allows you to transfer files between the host and the container.

1. **Create** an empty directory on your host:
   ```bash
   mkdir <volume-directory-name>
   ```

2. **Attach** the directory as a bind mount:
   ```bash
   docker run -dit \
     --name <container-name> \
     -v <host-path>:<container-path> \
     <image-tag>
   ```
   **Example:**
   ```bash
   docker run -dit \
     --name sentinel_mainnet \
     -v /home/mystuff:/mnt \
     sentinel:mainnet
   ```
3. Any files placed in `/home/mystuff` on your **host** will now be accessible at `/mnt` inside the **container**.

---

## Contact

For questions, troubleshooting, or general feedback, please reach out on Telegram: [@MisfitsCrypto](https://t.me/MisfitsCrypto).

--- 

**Enjoy using the Sentinel Docker containers!**
