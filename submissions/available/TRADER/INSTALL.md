# INSTALL

1. Please use Ubuntu 16.04 or 18.04, 64bit version
2. Install [Docker](https://www.docker.com)

   ```bash
   apt-get install -y uidmap
   curl -fsSL https://get.docker.com/rootless | sh
   ```
   Make sure the following environment variables are set:

   ```bash
   export PATH=/home/$USER/bin:$PATH
   export DOCKER_HOST=unix:///run/user/1002/docker.sock
   ```

3. Start docker

   ```bash
   systemctl --user start docker
   ```

4. Pull our docker image

   ```bash
   docker pull traderrnn/trader
   ```

5. Start the container

   ```bash
   docker run -it --rm traderrnn/trader bash
   ```
