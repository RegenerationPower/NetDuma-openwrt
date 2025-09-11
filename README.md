# NetDuma test task

For a detailed list of the core OpenWrt commands used for patching and development (such as make, quilt, etc.), please refer to the steps.txt file in this repository.

## Features

-   **Isolated**: Uses Docker so no useless tools are installed on your host machine.
-   **Automated**: Makefile and scripts handle setup, building, and cleaning.
-   **Permissions Solved**: Automatically syncs user permissions to avoid file access errors in Docker volume.
-   **Efficient**: The Docker image is kept small; large SDKs are downloaded separately and only once.

---

## Prerequisites

-   [Docker](https://docs.docker.com/get-docker/)
-   [Docker Compose](https://docs.docker.com/compose/install/) (V2, included with modern Docker installations)
-   A Linux-based host system (or WSL2 on Windows)
-   Make

---

## Usage with make

This project is controlled via a simple `Makefile`. For a full list of available commands and their descriptions, run:

```bash
make help
```

## First-Time Setup without make

Follow these steps to initialize the project for the first time.

### Configure Local Environment

This project requires a local `.env` file to correctly map your user permissions into the container.

Copy the provided template:

```bash
cp .env.example .env
```

The default values (UID=1000, GID=1000) are common, but you should verify them by running `id` in your terminal. If your values are different, update the .env file accordingly.

### Download the OpenWrt SDKs

Run the setup script to download and extract the MIPS and x86 SDK toolchains.

```bash
./setup-sdks.sh
```

#### Why a Separate Script for SDKs?

While it's possible to download the SDKs directly within the Dockerfile, this project uses a separate helper script. This is a deliberate design choice that follows professional best practices for several key reasons:
- Efficiency: The Docker image remains small and lightweight. This means rebuilding the environment (e.g., after adding a new tool to the Dockerfile) is nearly instantaneous, instead of requiring a multi-megabyte re-download.
- Flexibility: It decouples the development environment (the tools in the container) from the toolchain (the SDKs). This makes it trivial to switch to a different SDK version in the future without rebuilding the entire Docker image.
- One-Time Download: The large SDKs are downloaded only once and stored in your project folder. The script is smart and will not re-download them on subsequent runs.

This separation of concerns leads to a faster and more maintainable development workflow.
  
### Daily Workflow

To build the Docker image (if it doesn't exist) and enter an interactive shell inside the container, run:

```bash
docker compose run --rm openwrt
```

Run the main build script:

```bash
./build.sh
```

Or if you want to apply changes only run:
```bash
./apply_changes.sh <sdk_name>
```
