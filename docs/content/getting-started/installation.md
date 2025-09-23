# 🚀 Instalación de Keiko Latam

Esta guía te ayudará a instalar y configurar el entorno de desarrollo completo de Keiko Latam en tu sistema local.

## 📋 Prerrequisitos

### Sistema Operativo
- **Linux**: Ubuntu 20.04+ o equivalente
- **WSL2**: Windows Subsystem for Linux 2 con Ubuntu 24.04 LTS
- **macOS**: 10.15+ (Catalina o superior)

### Hardware Mínimo
- **RAM**: 8GB (16GB recomendado)
- **Almacenamiento**: 20GB de espacio libre
- **CPU**: 4 cores (8 cores recomendado)

---

## 🔧 Instalación de Dependencias

### 1. Instalación de Rust

```bash
# Instalar Rust con rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env

# Instalar toolchain nightly para Cairo
rustup toolchain install nightly
rustup default stable
rustup target add wasm32-unknown-unknown --toolchain nightly
```

=== "🐧 Ubuntu/Debian"

    ```bash
    # Actualizar paquetes
    sudo apt update && sudo apt upgrade -y
    
    # Instalar dependencias del sistema
    sudo apt install -y \
        build-essential \
        pkg-config \
        libssl-dev \
        libudev-dev \
        libclang-dev \
        cmake \
        git \
        curl \
        wget \
        unzip \
        python3 \
        python3-pip \
        python3-venv \
        docker.io \
        docker-compose \
        postgresql-client \
        redis-tools
    ```

=== "🍎 macOS"

    ```bash
    # Instalar Homebrew si no está instalado
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Instalar dependencias
    brew install \
        pkg-config \
        openssl \
        cmake \
        git \
        curl \
        wget \
        python3 \
        docker \
        docker-compose \
        postgresql \
        redis
    ```

### 2. Instalación de Cairo y Starknet

```bash
# Instalar asdf (version manager)
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1
echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc
source ~/.bashrc

# Instalar Scarb (package manager de Cairo)
curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh

# Instalar Starknet Foundry
curl -L https://raw.githubusercontent.com/foundry-rs/starknet-foundry/master/scripts/install.sh | sh

# Verificar instalación
scarb --version
snforge --version
```

### 3. Instalación de Flutter

```bash
# Clonar Flutter
git clone https://github.com/flutter/flutter.git -b stable ~/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Verificar instalación
flutter doctor
flutter --version
```

### 4. Instalación de GitFlow

=== "🐧 Ubuntu/Debian"

    ```bash
    sudo apt install -y git-flow
    ```

=== "🍎 macOS"

    ```bash
    brew install git-flow
    ```

=== "🔧 Instalación Manual"

    ```bash
    # Descargar e instalar git-flow
    wget --no-check-certificate -q https://raw.github.com/nvie/gitflow/develop/contrib/gitflow-installer.sh
    chmod +x gitflow-installer.sh
    sudo ./gitflow-installer.sh
    ```

---

## 🐳 Configuración de Podman

### 1. Instalar Podman

=== "🐧 Ubuntu/Debian"

    ```bash
    # Instalar Podman
    sudo apt install -y podman podman-compose
    
    # Verificar instalación
    podman --version
    podman-compose --version
    ```

=== "🍎 macOS"

    ```bash
    # Instalar Podman con Homebrew
    brew install podman podman-compose
    
    # Inicializar máquina virtual (macOS)
    podman machine init
    podman machine start
    ```

=== "🐳 Docker (Alternativa)"

    ```bash
    # Si prefieres usar Docker en lugar de Podman
    # En Windows, instalar Docker Desktop para WSL2
    docker context use wsl
    ```

### 2. Configurar Podman Compose

```bash
# Crear red para Keiko
podman network create keiko-network

# Verificar configuración
podman --version
podman-compose --version

# Configurar alias para compatibilidad (opcional)
echo "alias docker=podman" >> ~/.bashrc
echo "alias docker-compose=podman-compose" >> ~/.bashrc
source ~/.bashrc
```

---

## 🗄️ Configuración de Bases de Datos

### 1. PostgreSQL

```bash
# Instalar PostgreSQL (Ubuntu)
sudo apt install -y postgresql postgresql-contrib

# Crear usuario y bases de datos
sudo -u postgres psql << EOF
CREATE USER keiko_user WITH PASSWORD 'keiko_password';
CREATE DATABASE keiko_identity OWNER keiko_user;
CREATE DATABASE keiko_learning OWNER keiko_user;
CREATE DATABASE keiko_reputation OWNER keiko_user;
CREATE DATABASE keiko_passport OWNER keiko_user;
CREATE DATABASE keiko_governance OWNER keiko_user;
CREATE DATABASE keiko_marketplace OWNER keiko_user;
GRANT ALL PRIVILEGES ON DATABASE keiko_identity TO keiko_user;
GRANT ALL PRIVILEGES ON DATABASE keiko_learning TO keiko_user;
GRANT ALL PRIVILEGES ON DATABASE keiko_reputation TO keiko_user;
GRANT ALL PRIVILEGES ON DATABASE keiko_passport TO keiko_user;
GRANT ALL PRIVILEGES ON DATABASE keiko_governance TO keiko_user;
GRANT ALL PRIVILEGES ON DATABASE keiko_marketplace TO keiko_user;
\q
EOF
```

### 2. Redis

```bash
# Instalar Redis
sudo apt install -y redis-server

# Configurar Redis para desarrollo
sudo systemctl enable redis-server
sudo systemctl start redis-server

# Verificar conexión
redis-cli ping
```

---

## 🐍 Configuración del Entorno Python

### 1. Crear Entorno Virtual

```bash
# Crear entorno virtual
python3 -m venv .venv
source .venv/bin/activate

# Actualizar pip
pip install --upgrade pip
```

### 2. Instalar Dependencias Python

```bash
# Instalar dependencias para Proof-of-Humanity
pip install \
    opencv-python \
    biopython \
    cairo-lang \
    numpy \
    scipy \
    matplotlib \
    pillow \
    cryptography \
    pyjwt \
    requests \
    python-dotenv
```

---

## 🚀 Configuración Rápida con Scripts

### 1. Clonar Repositorio

```bash
# Clonar el repositorio
git clone https://github.com/keikolatam/dapp-monorepo.git
cd dapp-monorepo

# Configurar GitFlow
./scripts/gitflow-setup.sh configure
```

### 2. Configuración Automática

```bash
# Ejecutar configuración completa
make dev-setup

# O configuración paso a paso
make install-deps    # Instalar dependencias
make infra-setup     # Configurar infraestructura
make db-setup        # Configurar bases de datos
make poh-setup       # Configurar Proof-of-Humanity
```

---

## ✅ Verificación de la Instalación

### 1. Verificar Componentes

```bash
# Ejecutar verificación completa
make verify-setup

# O verificar individualmente
./scripts/verify-rust.sh
./scripts/verify-cairo.sh
./scripts/verify-flutter.sh
./scripts/verify-docker.sh
```

### 2. Tests de Conectividad

```bash
# Verificar conectividad de red
ping -c 1 github.com
ping -c 1 starknet.io

# Verificar servicios locales
pg_isready -h localhost -p 5432
redis-cli ping
```

---

## 🔧 Configuración de Variables de Entorno

### 1. Crear Archivo .env

```bash
# Copiar plantilla
cp .env.example .env

# Editar configuración
nano .env
```

### 2. Variables Importantes

```bash
# Base de datos
DATABASE_URL=postgresql://keiko_user:keiko_password@localhost:5432
REDIS_URL=redis://localhost:6379

# Keikochain
KEIKOCHAIN_RPC_URL=wss://keikochain.karnot.xyz
KEIKOCHAIN_CHAIN_ID=0x534e5f4d41494e

# JWT
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRATION=24h

# Proof-of-Humanity
HUMANITY_SALT=your-humanity-proof-salt
```

---

## 🐛 Resolución de Problemas

### Problemas Comunes

=== "❌ Error de permisos Podman"

    ```bash
    # Configurar Podman para usuario rootless
    podman system migrate
    
    # O agregar usuario al grupo podman (si es necesario)
    sudo usermod -aG podman $USER
    newgrp podman
    
    # Reiniciar servicio (si usa systemd)
    sudo systemctl restart podman
    ```

=== "❌ Error de conexión PostgreSQL"

    ```bash
    # Verificar estado del servicio
    sudo systemctl status postgresql
    
    # Reiniciar servicio
    sudo systemctl restart postgresql
    
    # Verificar configuración
    sudo -u postgres psql -c "SELECT version();"
    ```

=== "❌ Error de Cairo/Scarb"

    ```bash
    # Reinstalar Cairo
    asdf uninstall cairo 1.0.0
    asdf install cairo 1.0.0
    
    # Verificar PATH
    echo $PATH | grep -o '[^:]*cairo[^:]*'
    ```

=== "❌ Error de Flutter"

    ```bash
    # Ejecutar doctor
    flutter doctor
    
    # Instalar dependencias faltantes
    flutter doctor --android-licenses
    ```

---

## 📚 Próximos Pasos

Una vez completada la instalación:

1. **Configuración rápida**: Sigue la [guía de configuración rápida](quick-setup.md)
2. **Primeros pasos**: Explora los [primeros pasos](first-steps.md)
3. **Desarrollo**: Consulta la [guía de desarrollo](../development/local-setup.md)
4. **Contribuir**: Lee la [guía de contribución](../development/contributing.md)

---

## 🆘 Soporte

Si encuentras problemas durante la instalación:

- 📖 **Documentación**: Revisa la [documentación completa](../index.md)
- 🐛 **Issues**: Reporta problemas en [GitHub Issues](https://github.com/keikolatam/dapp-monorepo/issues)
- 💬 **Discord**: Únete a nuestro [Discord](https://discord.gg/keikolatam)
- 📧 **Email**: Contacta a [soporte@keikolatam.app](mailto:soporte@keikolatam.app)

---

*Última actualización: {{ git_revision_date_localized }}*
