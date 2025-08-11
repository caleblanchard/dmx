# DMX Development Setup with VS Code Remote Debugging

This guide will help you set up VS Code to remotely debug the DMX container running on your Ubuntu server at `100.112.108.68`.

## Prerequisites

1. **VS Code Extensions** (install these in VS Code):
   - Remote - SSH
   - Remote - Containers
   - Go (for Go language support)
   - Docker (optional, for local development)

2. **SSH Access** to your Ubuntu server with Docker installed

## Setup Options

You have three options for remote development:

### Option 1: Remote SSH + Docker (Recommended)

1. **Configure SSH in VS Code**:
   - Open VS Code
   - Press `F1` and run "Remote-SSH: Connect to Host..."
   - Add your server: `ssh://your-username@100.112.108.68`
   - Connect to the server

2. **Clone/Sync the Repository** on the server:
   ```bash
   # On the Ubuntu server
   git clone <your-repo-url> ~/dmx
   cd ~/dmx
   ```

3. **Build and Run Development Container**:
   ```bash
   # Build the development image
   docker build -f Dockerfile.dev -t dmx-dev .
   
   # Run with debugging enabled
   docker-compose -f docker-compose.dev.yml up -d dmx-dev
   ```

4. **Attach VS Code to Remote**:
   - In VS Code, open the folder on the remote server
   - Use `F5` and select "Attach to DMX Container"

### Option 2: Dev Container (Alternative)

1. **SSH to Server and Open in VS Code**:
   ```bash
   # Connect to server via SSH in VS Code
   # Then open the project folder
   ```

2. **Reopen in Container**:
   - Press `F1` → "Dev Containers: Reopen in Container"
   - VS Code will build and attach to the development container

### Option 3: Direct Remote Debugging

1. **Run DMX with Debugger** on the server:
   ```bash
   docker run -d \
     --name dmx-debug \
     -p 8000:8000 \
     -p 2345:2345 \
     -v $(pwd)/config:/etc/qmsk-dmx:ro \
     dmx-dev
   ```

2. **Connect from Local VS Code**:
   - Use the "Attach to DMX Container" launch configuration
   - Set breakpoints and debug remotely

## Launch Configurations

The `.vscode/launch.json` file includes three configurations:

### 1. Debug DMX (Remote)
For debugging when VS Code is connected to the remote server.

### 2. Debug DMX (Local) 
For local development and testing.

### 3. Attach to DMX Container
For attaching to a running container with Delve debugger.

## Usage Instructions

### Starting Debug Session

1. **Start the Development Container**:
   ```bash
   # On the Ubuntu server
   cd ~/dmx
   docker-compose -f docker-compose.dev.yml up -d dmx-dev
   ```

2. **Connect VS Code**:
   - SSH to server or use dev container
   - Open the project folder
   - Press `F5` or go to Run and Debug
   - Select appropriate launch configuration

3. **Set Breakpoints**:
   - Click in the gutter next to line numbers
   - Breakpoints will be hit when the code executes

### Accessing the Application

- **Web UI**: http://100.112.108.68:8000
- **Debug Port**: 100.112.108.68:2345

### Development Workflow

1. **Make Code Changes**: Edit files in VS Code
2. **Rebuild Container**: 
   ```bash
   docker-compose -f docker-compose.dev.yml up -d --build dmx-dev
   ```
3. **Restart Debug Session**: Press `F5` again in VS Code

### Useful Commands

```bash
# View container logs
docker-compose -f docker-compose.dev.yml logs -f dmx-dev

# Stop development container
docker-compose -f docker-compose.dev.yml down

# Rebuild and restart
docker-compose -f docker-compose.dev.yml up -d --build

# Run production version alongside
docker-compose -f docker-compose.dev.yml up -d dmx-prod
```

## Port Configuration

| Service | Port | Description |
|---------|------|-------------|
| Web UI (Dev) | 8000 | Development web interface |
| Debugger | 2345 | Delve debugger port |
| Web UI (Prod) | 8080 | Production web interface |

## Troubleshooting

### Cannot Connect to Debugger
- Ensure port 2345 is open in firewall
- Check container is running: `docker ps`
- Verify logs: `docker-compose logs dmx-dev`

### Breakpoints Not Hit
- Ensure you're using the development build (with `-gcflags="all=-N -l"`)
- Check that source paths match between local and remote

### Container Won't Start
- Check config directory exists: `ls ./config/`
- Verify Docker Compose syntax: `docker-compose config`
- Check available ports: `netstat -tlnp | grep :8000`

## Production vs Development

The setup includes both development and production containers:

- **Development (`dmx-dev`)**: Includes debugger, runs on port 8000
- **Production (`dmx-prod`)**: Optimized build, runs on port 8080

You can run both simultaneously for comparison testing.