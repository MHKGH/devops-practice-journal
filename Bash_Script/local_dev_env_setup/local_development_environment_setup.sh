#!/bin/bash

set -e  # Exit on any error

# Script configuration
SYSTEM_TOOLS=("git" "curl" "python3" "maven" "postgresql-client")
DISTRO=$(lsb_release -cs)
ARCH=$(dpkg --print-architecture)
DOCKER_GPG="/etc/apt/keyrings/docker.gpg"

# PostgreSQL configuration - consider moving to environment variables or config file
POSTGRES_CONTAINER="postgres-db"
POSTGRES_PORT=5432
POSTGRES_USER="admin"
POSTGRES_PASSWORD="adminpass"  # Consider using a generated password or prompt
POSTGRES_DB="mydb"
POSTGRES_DATA_DIR="$HOME/postgres-data"  # For data persistence

# Detect shell configuration file
detect_shell_rc() {
  if [[ -n "$ZSH_VERSION" ]]; then
    echo "$HOME/.zshrc"
  elif [[ -n "$BASH_VERSION" ]]; then
    echo "$HOME/.bashrc"
  else
    echo "$HOME/.profile"
  fi
}

SHELL_RC=$(detect_shell_rc)

### === LOGGING === ###
log_info()  { echo -e "\e[34m[INFO]  $(date '+%Y-%m-%d %H:%M:%S') - $*\e[0m"; }
log_ok()    { echo -e "\e[32m[+] $*\e[0m"; }
log_error() { echo -e "\e[31m[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $*\e[0m" >&2; }
log_warn()  { echo -e "\e[33m[WARN]  $(date '+%Y-%m-%d %H:%M:%S') - $*\e[0m"; }

# Check for sudo privileges
check_sudo() {
  if ! sudo -v; then
    log_error "This script requires sudo privileges. Please run with a user that has sudo access."
    exit 1
  fi
}

# Cleanup function for trap
cleanup() {
  EXIT_CODE=$?
  if [ $EXIT_CODE -ne 0 ]; then
    log_error "Script failed with exit code $EXIT_CODE"
    log_info "You may need to manually clean up any partial installations"
  fi
  exit $EXIT_CODE
}

# Set trap for cleanup
trap cleanup EXIT INT TERM

update_package_index() {
  log_info "Updating APT package index..."
  sudo apt update
}

install_system_tools() {
    log_info "Installing System Tools"
    for TOOL in "${SYSTEM_TOOLS[@]}"; do
        log_info "Installing $TOOL"
        if ! dpkg -l | grep -q "^ii  $TOOL"; then
            sudo apt install $TOOL -y && log_ok "$TOOL" || log_error "$TOOL"
        else
            log_info "$TOOL is already installed"
        fi
    done
    log_info "System Tools Installed"
}

install_prerequisites() {
  log_info "Installing prerequisites..."
  sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    apt-transport-https
  log_ok "Prerequisites installed."
}

add_docker_gpg_key() {
  log_info "Adding Docker GPG key..."
  sudo mkdir -p /etc/apt/keyrings
  if [ ! -f "$DOCKER_GPG" ]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
      sudo gpg --dearmor -o "$DOCKER_GPG"
    sudo chmod a+r "$DOCKER_GPG"
    log_ok "Docker GPG key added."
  else
    log_info "Docker GPG key already exists."
  fi
}

add_docker_repo() {
  log_info "Adding Docker APT repository..."
  REPO_FILE="/etc/apt/sources.list.d/docker.list"
  if [ ! -f "$REPO_FILE" ]; then
    echo "deb [arch=$ARCH signed-by=$DOCKER_GPG] \
https://download.docker.com/linux/ubuntu $DISTRO stable" | \
    sudo tee "$REPO_FILE" > /dev/null
    log_ok "Docker repository added."
  else
    log_info "Docker repository already configured."
  fi
}

install_docker() {
  log_info "Installing Docker Engine and Compose plugin..."
  sudo apt update
  sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
  log_ok "Docker and Compose installed."
  
  log_info "Ensuring Docker daemon is running..."
  sudo systemctl enable docker
  sudo systemctl start docker
}

post_install() {
  log_info "Adding user '$USER' to docker group..."
  sudo usermod -aG docker "$USER"
  log_ok "Post-install configuration done."
}

verify_docker() {
  log_info "Verifying Docker installation..."
  # Use sudo for verification since user might not be in docker group yet
  sudo docker --version && sudo docker compose version && sudo docker run --rm hello-world
  log_ok "Docker verified successfully."
}

add_to_shell_rc() {
  local LINE="$1"
  grep -qxF "$LINE" "$SHELL_RC" || echo "$LINE" >> "$SHELL_RC"
}

install_pyenv() {
  log_info "Installing pyenv dependencies..."
  sudo apt install -y \
    make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
    libffi-dev liblzma-dev git

  if [ ! -d "$HOME/.pyenv" ]; then
    log_info "Cloning pyenv..."
    git clone https://github.com/pyenv/pyenv.git ~/.pyenv
  else
    log_info "Pyenv already installed, updating..."
    cd ~/.pyenv && git pull && cd -
  fi

  log_info "Adding pyenv to $SHELL_RC"
  add_to_shell_rc 'export PYENV_ROOT="$HOME/.pyenv"'
  add_to_shell_rc 'export PATH="$PYENV_ROOT/bin:$PATH"'
  add_to_shell_rc 'eval "$(pyenv init --path)"'
  add_to_shell_rc 'eval "$(pyenv init -)"'
}

install_nvm() {
  log_info "Installing NVM..."
  if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  else
    log_info "NVM already installed"
  fi

  log_info "Adding NVM to $SHELL_RC"
  add_to_shell_rc 'export NVM_DIR="$HOME/.nvm"'
  add_to_shell_rc '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
}

start_postgres_container() {
  log_info "Setting up PostgreSQL container..."

  # Create data directory for persistence if it doesn't exist
  mkdir -p "$POSTGRES_DATA_DIR"

  # Check if container already exists
  if sudo docker ps -a --format '{{.Names}}' | grep -q "^$POSTGRES_CONTAINER$"; then
    log_info "Container '$POSTGRES_CONTAINER' already exists. Starting it..."
    sudo docker start "$POSTGRES_CONTAINER"
  else
    log_info "Creating and starting new PostgreSQL container..."
    sudo docker run -d \
      --name "$POSTGRES_CONTAINER" \
      -e POSTGRES_USER="$POSTGRES_USER" \
      -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
      -e POSTGRES_DB="$POSTGRES_DB" \
      -v "$POSTGRES_DATA_DIR:/var/lib/postgresql/data" \
      -p "$POSTGRES_PORT:5432" \
      --restart unless-stopped \
      postgres:16
  fi

  # Wait for PostgreSQL to be ready
  log_info "Waiting for PostgreSQL to be ready..."
  sleep 5
  
  # Check if PostgreSQL is running
  if ! sudo docker exec "$POSTGRES_CONTAINER" pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"; then
    log_error "PostgreSQL container is not ready. Please check the logs with: docker logs $POSTGRES_CONTAINER"
    return 1
  fi
  
  log_ok "PostgreSQL container is up and running on port $POSTGRES_PORT."
}

load_postgres_schema() {
  log_info "Loading schema and test data into PostgreSQL..."

  SQL_FILE="./init.sql"
  
  if [[ ! -f "$SQL_FILE" ]]; then
    log_error "SQL file not found at $SQL_FILE"
    return 1
  fi

  sudo docker cp "$SQL_FILE" "$POSTGRES_CONTAINER":/tmp/init.sql

  # Use the same user for execution as defined in the container
  sudo docker exec "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /tmp/init.sql \
    && log_ok "Schema/test data loaded successfully." \
    || log_error "Failed to load schema/test data."
}

# Main execution flow
main() {
  check_sudo
  update_package_index
  install_system_tools
  install_prerequisites
  add_docker_gpg_key
  add_docker_repo
  install_docker
  verify_docker
  post_install
  install_pyenv
  install_nvm
  start_postgres_container
  load_postgres_schema

  log_ok "✅ Development environment setup completed successfully."
  log_info "🔁 Please logout/login OR run 'newgrp docker' to apply group changes."
  log_info "🔄 Please restart your terminal or run: source $SHELL_RC"
  log_info "📌 This will activate pyenv, nvm, and other environment changes."
}

# Run the main function
main
