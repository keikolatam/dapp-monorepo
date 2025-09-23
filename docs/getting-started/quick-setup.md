# ⚡ Configuración Rápida de Keiko Latam

Esta guía te permitirá tener Keiko Latam funcionando en tu entorno local en menos de 10 minutos.

## 🎯 Objetivo

Configurar un entorno de desarrollo completo de Keiko Latam con:
- ✅ Keikochain (Starknet Appchain) funcionando
- ✅ gRPC Gateway configurado
- ✅ Backend monolítico modular en Rust
- ✅ Bases de datos PostgreSQL y Redis
- ✅ Entorno Python para Proof-of-Humanity

---

## 🚀 Instalación en 3 Pasos

### Paso 1: Clonar y Configurar

```bash
# Clonar el repositorio
git clone https://github.com/keikolatam/dapp-monorepo.git
cd dapp-monorepo

# Hacer ejecutables los scripts
chmod +x scripts/*.sh

# Configurar GitFlow
./scripts/gitflow-setup.sh configure
```

### Paso 2: Configuración Automática

```bash
# Ejecutar configuración completa (recomendado)
make dev-setup

# O paso a paso si prefieres control
make install-deps    # Instalar dependencias del sistema
make infra-setup     # Configurar Podman y servicios
make db-setup        # Configurar PostgreSQL y Redis
make poh-setup       # Configurar entorno Python
```

### Paso 3: Verificar Instalación

```bash
# Verificar que todo funciona
make verify-setup

# Ver estado de todos los componentes
make status
```

---

## 🎛️ Comandos Make Disponibles

### Configuración Inicial
```bash
make dev-setup           # Configuración completa
make install-deps        # Instalar dependencias
make infra-setup         # Configurar infraestructura
make db-setup           # Configurar bases de datos
make poh-setup          # Configurar Proof-of-Humanity
```

### Desarrollo
```bash
make appchain-start      # Iniciar Keikochain
make grpc-gateway-start  # Iniciar gRPC Gateway
make backend-start       # Iniciar Backend
make frontend-start      # Iniciar Frontend
```

### Utilidades
```bash
make status              # Ver estado de componentes
make logs                # Ver logs de todos los servicios
make clean               # Limpiar contenedores y volúmenes
make test-all            # Ejecutar todos los tests
```

### GitFlow
```bash
make gitflow-setup       # Configurar GitFlow
make gitflow-status      # Ver estado GitFlow
make create-release VERSION=1.0.0  # Crear release
make create-hotfix NAME=critical   # Crear hotfix
```

---

## 🔧 Configuración por Componente

### 🌐 Keikochain (Starknet Appchain)

```bash
# Configuración automática
./scripts/appchain-quick-start.sh --non-interactive

# Configuración manual
cd appchain
podman-compose up -d || docker-compose up -d
cargo run --release create devnet
```

**Verificar:**
```bash
curl -X POST http://localhost:9944 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"system_health","params":[],"id":1}'
```

### 🔗 gRPC Gateway

```bash
# Configuración automática
./scripts/grpc-gateway-quick-start.sh

# Configuración manual
cd grpc-gateway
cargo build --release
./target/release/grpc-gateway
```

**Verificar:**
```bash
grpcurl -plaintext localhost:50051 list
```

### 🖥️ Backend Monolítico

```bash
# Configuración automática
./scripts/backend-quick-start.sh

# Configuración manual
cd backend
cargo build
cargo run
```

**Verificar:**
```bash
curl http://localhost:8080/health
```

### 🗄️ Bases de Datos

```bash
# PostgreSQL
pg_isready -h localhost -p 5432
psql -h localhost -U keiko_user -d keiko_identity -c "SELECT version();"

# Redis
redis-cli ping
redis-cli info server
```

---

## 🐍 Entorno Python (Proof-of-Humanity)

### Activar Entorno Virtual

```bash
# Activar entorno
source .venv/bin/activate

# Verificar dependencias
python -c "import cv2, Bio, cairo_lang; print('✅ Dependencias OK')"
```

### Ejemplos de Proof-of-Humanity

```bash
# Ejecutar ejemplos
make poh-examples

# Generar humanity_proof_key
make poh-key-gen
```

**Ejemplo manual:**
```python
# Activar entorno
source .venv/bin/activate

# Ejecutar ejemplo
python - << 'EOF'
import hashlib, os, numpy as np
import cv2
from Bio import SeqIO

# Simular procesamiento de iris
img = np.random.randint(0, 255, (128,128), dtype=np.uint8)
kernel = cv2.getGaborKernel((21, 21), 5, 0, 10, 0.5, 0, ktype=cv2.CV_32F)
feat = cv2.filter2D(img, cv2.CV_32F, kernel)
iris_hash = hashlib.sha256(feat.tobytes()).digest()

# Simular procesamiento de genoma
genome_hash = hashlib.sha256(os.urandom(32)).digest()
salt = os.urandom(16)

# Generar humanity_proof_key
composite = iris_hash + genome_hash + salt
humanity_proof_key = hashlib.sha256(composite).hexdigest()

print(f'humanity_proof_key: {humanity_proof_key}')
EOF
```

---

## 🌐 URLs de Acceso

Una vez configurado, puedes acceder a:

| Servicio | URL | Descripción |
|----------|-----|-------------|
| **Keikochain** | `http://localhost:9944` | RPC de Starknet Appchain |
| **gRPC Gateway** | `localhost:50051` | gRPC Gateway |
| **Backend** | `http://localhost:8080` | Backend monolítico |
| **API Gateway** | `http://localhost:3000` | GraphQL API |
| **Frontend** | `http://localhost:3001` | Aplicación Flutter |
| **PostgreSQL** | `localhost:5432` | Base de datos |
| **Redis** | `localhost:6379` | Cache y eventos |

---

## 🧪 Tests Rápidos

### Test de Conectividad

```bash
# Test completo del sistema
curl -f http://localhost:8080/health && \
curl -f http://localhost:3000/graphql && \
redis-cli ping && \
pg_isready -h localhost -p 5432
```

### Test de Keikochain

```bash
# Test de conexión a Keikochain
curl -X POST http://localhost:9944 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"system_health","params":[],"id":1}' | \
  jq '.result'
```

### Test de Proof-of-Humanity

```bash
# Test del entorno Python
source .venv/bin/activate
python -c "
import cv2, numpy as np
from Bio import SeqIO
import hashlib
print('✅ Proof-of-Humanity OK')
"
```

---

## 🐛 Resolución de Problemas Rápidos

### ❌ Error: "make: command not found"

```bash
# Instalar make
sudo apt install make  # Ubuntu/Debian
brew install make      # macOS
```

### ❌ Error: "Podman not running"

```bash
# Iniciar Podman
sudo systemctl start podman  # Linux
podman machine start        # macOS (si usa máquina virtual)

# O si prefieres Docker
sudo systemctl start docker  # Linux
open -a Docker              # macOS
```

### ❌ Error: "Port already in use"

```bash
# Verificar puertos en uso
sudo netstat -tulpn | grep :5432
sudo netstat -tulpn | grep :6379

# Matar procesos si es necesario
sudo kill -9 $(sudo lsof -t -i:5432)
sudo kill -9 $(sudo lsof -t -i:6379)
```

### ❌ Error: "Permission denied"

```bash
# Hacer ejecutables los scripts
chmod +x scripts/*.sh
chmod +x appchain/quick-start.sh
chmod +x grpc-gateway/quick-start.sh
chmod +x backend/quick-start.sh
```

---

## 📊 Verificar Estado Completo

```bash
# Ver estado de todos los componentes
make status

# Ver logs en tiempo real
make logs

# Verificar conectividad
make verify-setup
```

**Salida esperada:**
```
🎓 Estado de Keiko Latam
========================

✅ Keikochain: Activo (puerto 9944)
✅ gRPC Gateway: Activo (puerto 50051)
✅ Backend: Activo (puerto 8080)
✅ PostgreSQL: Activo (puerto 5432)
✅ Redis: Activo (puerto 6379)
✅ Python PoH: Activo (.venv)
✅ Docker: Activo
✅ GitFlow: Configurado
```

---

## 🎉 ¡Listo para Desarrollar!

Una vez completada la configuración rápida:

1. **Explorar el código**: Navega por la estructura del proyecto
2. **Leer la documentación**: Consulta [docs/](../index.md)
3. **Hacer tu primera contribución**: Sigue la [guía de contribución](../development/contributing.md)
4. **Unirse a la comunidad**: Únete a nuestro [Discord](https://discord.gg/keikolatam)

### Próximos Pasos

- 📖 **Documentación completa**: [Instalación detallada](installation.md)
- 🚀 **Primeros pasos**: [Guía de primeros pasos](first-steps.md)
- 🔧 **Desarrollo**: [Configuración de desarrollo](../development/local-setup.md)
- 🤝 **Contribuir**: [Guía de contribución](../development/contributing.md)

---

## 🆘 Soporte Rápido

Si algo no funciona:

1. **Ejecutar**: `make status` para ver el estado
2. **Revisar logs**: `make logs` para ver errores
3. **Limpiar y reiniciar**: `make clean && make dev-setup`
4. **Pedir ayuda**: [Discord](https://discord.gg/keikolatam) o [GitHub Issues](https://github.com/keikolatam/dapp-monorepo/issues)

---

*Tiempo estimado de configuración: 5-10 minutos* ⏱️
