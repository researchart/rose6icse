## Installation


#### Docker Installation

Docker version: 19.03.3

[Docker for Mac](https://docs.docker.com/docker-for-mac/install/)

[Docker for Linux](https://docs.docker.com/install/linux/docker-ce/ubuntu/)

[Docker for Window](https://docs.docker.com/docker-for-windows/install/)


#### Clone the Repository

- `git clone --branch 1.0.0 https://Li_Sui@bitbucket.org/Li_Sui/recall-study-artefact.git`

#### Build the Docker Image

- `docker build -t recall .`

### Run the Docker Container

- `docker run -i -v $(realpath ./data):/recall/data -t recall`
