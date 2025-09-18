# ⛓️ Appchain Layer - Keiko DApp

El Appchain Layer implementa **Keikochain**, una Starknet Appchain personalizada construida con **Madara** que proporciona la infraestructura blockchain para la Keiko DApp. Keikochain maneja el almacenamiento inmutable, el consenso y la verificación de Proof-of-Humanity con zkProofs.

## 🎯 ¿Qué es una Appchain?

Una **Appchain** es una blockchain construida para un propósito específico. A diferencia de las blockchains de propósito general, Keikochain está optimizada para:

- **Proof-of-Humanity**: Verificación única de humanos usando datos biométricos
- **Life Learning Passport**: Gestión de credenciales educativas
- **Reputación Descentralizada**: Sistema de reputación basado en aprendizaje
- **Gobernanza**: Procesos de votación y toma de decisiones
- **Marketplace**: Intercambio de credenciales y servicios

Keikochain se ejecuta sobre **Starknet** y liquida sus transacciones allí para mayor seguridad, siguiendo el modelo de [Madara Appchains](https://docs.madara.build/quickstart/run_appchain).

## 🏗️ Arquitectura de Keikochain

### Componentes Principales

#### 1. **Madara Sequencer**
- **Función**: Nodo principal que recibe transacciones y construye bloques
- **Puerto**: 9944 (P2P), 9945 (RPC), 9946 (WebSocket)
- **Responsabilidades**:
  - Procesamiento de transacciones Cairo
  - Construcción de bloques
  - Sincronización con la red

#### 2. **Orchestrator**
- **Función**: Gestiona comunicaciones desde el sequencer
- **Puerto**: 8080
- **Responsabilidades**:
  - Coordinación entre componentes
  - Gestión de eventos
  - Comunicación con servicios externos

#### 3. **Mock Prover**
- **Función**: Genera pruebas mock para los bloques
- **Puerto**: 8081
- **Responsabilidades**:
  - Generación de STARK proofs
  - Verificación de transacciones
  - Preparación para settlement

#### 4. **Ethereum Local**
- **Función**: Blockchain local para settlement
- **Puerto**: 8545
- **Responsabilidades**:
  - Settlement de transacciones
  - Verificación de proofs
  - Seguridad de la Appchain

## 📁 Estructura del Proyecto

```
appchain/
├── contracts/                           # Contratos Cairo inteligentes
│   ├── proof_of_humanity.cairo          # Contrato de Proof-of-Humanity
│   ├── learning_interactions.cairo      # Contrato de interacciones de aprendizaje
│   ├── life_learning_passport.cairo     # Contrato de LLP
│   ├── reputation_system.cairo          # Contrato de sistema de reputación
│   ├── governance.cairo                 # Contrato de gobernanza
│   └── marketplace.cairo                # Contrato de marketplace
├── config/                              # Configuraciones de la Appchain
│   └── keikochain.toml                 # Configuración principal
├── tests/                               # Tests de contratos
│   ├── proof_of_humanity_test.cairo
│   ├── learning_test.cairo
│   └── reputation_test.cairo
├── docs/                                # Documentación técnica
│   ├── architecture.md                 # Arquitectura detallada
│   ├── contracts.md                    # Documentación de contratos
│   └── deployment.md                   # Guía de despliegue
├── madara-cli/                          # Cliente Madara CLI (instalado automáticamente)
├── setup-devnet-podman-interactive.sh  # 🎯 Setup principal (Podman + WSL2)
├── setup-devnet-wsl.sh                 # 🔄 Setup alternativo (WSL2 + Starknet Devnet)
├── start-devnet-simple.sh              # 🚀 Inicio principal (simple y confiable)
├── start-devnet-podman.sh              # 🔄 Inicio alternativo (con docker-compose)
├── quick-start.sh                      # ⚡ Setup legacy (genérico)
├── stop-devnet.sh                      # 🛑 Detener devnet
├── check-devnet-status.sh              # 📊 Verificar estado
├── fix-podman-mounts.sh                # 🔧 Solucionar problemas de montaje
└── README.md                           # Este archivo
```

## 🚀 Configuración Rápida

### Prerrequisitos

Asegúrate de tener instalados:
- **Rust** (última versión estable)
- **Git** para clonar repositorios
- **Podman** (recomendado para WSL2) o **Docker** (alternativo)
- **Herramientas de build** (gcc, make, pkg-config)

### Scripts de Configuración Disponibles

#### 🎯 **Scripts Principales (Recomendados)**

##### 1. **Setup Inicial - Podman (Recomendado para WSL2)**
```bash
cd appchain
./setup-devnet-podman-interactive.sh
```
**Características:**
- ✅ **Interactivo** - Te guía paso a paso
- ✅ **Maneja permisos sudo** correctamente
- ✅ **Optimizado para WSL2/Ubuntu**
- ✅ **Instala Podman automáticamente**
- ✅ **Configuración robusta y confiable**

##### 2. **Setup Inicial - WSL2 (Alternativo)**
```bash
cd appchain
./setup-devnet-wsl.sh
```
**Características:**
- ✅ **Alternativa si Podman falla**
- ✅ **Configura Starknet Devnet como backup**
- ✅ **Maneja problemas de Docker en WSL2**
- ✅ **Proporciona múltiples opciones**

#### 🚀 **Scripts de Inicio**

##### 1. **Iniciar Devnet - Simple (Recomendado)**
```bash
cd appchain
./start-devnet-simple.sh
```
**Características:**
- ✅ **Más simple y confiable**
- ✅ **No depende de docker-compose**
- ✅ **Múltiples métodos de fallback**
- ✅ **Menos puntos de falla**

##### 2. **Iniciar Devnet - Podman (Alternativo)**
```bash
cd appchain
./start-devnet-podman.sh
```
**Características:**
- ✅ **Usa Podman con docker-compose**
- ✅ **Configuración más completa**
- ✅ **Mejor para entornos complejos**

#### ⚡ **Script de Configuración Rápida (Genérico)**
```bash
cd appchain
./quick-start.sh
```
**Características:**
- ✅ **Script completo** - Instala todo de una vez
- ✅ **Multiplataforma** - Funciona en diferentes sistemas
- ✅ **Configuración automática** - No requiere interacción
- ✅ **Perfecto para empezar** - Ideal para la primera configuración

### 🎯 **Guía de Inicio Rápido**

#### **Opción 1: Configuración Completa (Recomendada para empezar)**
```bash
cd appchain
./quick-start.sh
```
Este script hace todo automáticamente:
- ✅ Instala dependencias del sistema
- ✅ Instala Rust si es necesario
- ✅ Clona y compila Madara CLI
- ✅ Inicia la devnet
- ✅ Verifica el estado
- ✅ Crea scripts de utilidad

#### **Opción 2: Configuración Paso a Paso (Para WSL2/Podman)**
```bash
cd appchain
./setup-devnet-podman-interactive.sh  # Configuración inicial
./start-devnet-simple.sh              # Iniciar devnet
./check-devnet-status.sh              # Verificar estado
```

#### **Conectar a la Devnet**
Una vez ejecutado cualquiera de los scripts anteriores:
- **RPC Endpoint**: `http://127.0.0.1:9945`
- **WebSocket**: `ws://127.0.0.1:9946`
- **P2P**: `127.0.0.1:9944`

### 🔄 **Alternativas si hay Problemas**

#### **Si Podman falla:**
```bash
./setup-devnet-wsl.sh
```
Este script configurará Starknet Devnet como alternativa.

#### **Si necesitas docker-compose:**
```bash
./start-devnet-podman.sh
```
Usa este script en lugar del simple si necesitas funcionalidades avanzadas.

### Instalación Manual

Si prefieres instalar manualmente:

1. **Instalar Rust**:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   source ~/.cargo/env
   ```

2. **Clonar Madara CLI**:
   ```bash
   git clone https://github.com/madara-alliance/madara-cli.git
   cd madara-cli
   cargo build --release
   ```

3. **Crear Appchain**:
   ```bash
   cargo run --release create app-chain
   ```

4. **Esperar configuración** (aproximadamente 10 minutos)

## 🔧 Configuración

### Archivo de Configuración

El archivo `config/keikochain.toml` contiene la configuración principal:

```toml
[appchain]
name = "keikochain"
description = "Keiko DApp - Starknet Appchain para Proof-of-Humanity y Life Learning Passport"
version = "0.1.0"

[sequencer]
host = "127.0.0.1"
port = 9944
rpc_port = 9945
ws_port = 9946

[orchestrator]
host = "127.0.0.1"
port = 8080

[prover]
type = "mock"
host = "127.0.0.1"
port = 8081

[settlement]
chain = "ethereum"
rpc_url = "http://127.0.0.1:8545"

[consensus]
algorithm = "proof_of_stake"
block_time = 2
finality_threshold = 1
```

### Variables de Entorno

```bash
# Configuración de logging
export RUST_LOG=info

# Configuración de la Appchain
export APPCHAIN_NAME=keikochain
export SEQUENCER_HOST=127.0.0.1
export SEQUENCER_PORT=9945
export WS_PORT=9946
```

## 🛠️ Desarrollo

### Contratos Cairo

Keikochain utiliza contratos inteligentes escritos en **Cairo** para implementar la lógica de negocio:

#### Proof-of-Humanity Contract
```cairo
#[contract]
mod proof_of_humanity {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    
    #[storage]
    struct Storage {
        humanity_proofs: Map<ContractAddress, felt252>,
        verified_humans: Map<ContractAddress, bool>,
    }
    
    #[abi(embed_v0)]
    impl IProofOfHumanity of IProofOfHumanityTrait {
        fn register_humanity_proof(
            ref self: ContractState,
            humanity_proof: felt252,
            stark_proof: felt252
        ) -> bool {
            // Lógica de registro de Proof-of-Humanity
        }
        
        fn verify_humanity(
            ref self: ContractState,
            human_address: ContractAddress
        ) -> bool {
            // Verificación de humanidad
        }
    }
}
```

### Comandos Útiles

#### 🔧 **Scripts de Gestión de Devnet**

```bash
# Verificar estado de la devnet
./check-devnet-status.sh

# Detener la devnet
./stop-devnet.sh

# Iniciar devnet (después del setup inicial)
./start-devnet-simple.sh        # Recomendado
./start-devnet-podman.sh        # Alternativo

# Ver logs de contenedores
podman logs <container_name>     # Con Podman
docker logs <container_name>     # Con Docker
```

#### 🛠️ **Scripts de Desarrollo**

```bash
# Compilar contratos Cairo
scarb build

# Ejecutar tests de contratos
snforge test

# Desplegar contratos
starknet deploy --contract contracts/proof_of_humanity.cairo

# Verificar puertos activos
netstat -tuln | grep -E ":(9944|9945|9946) "
```

#### 🔄 **Scripts de Mantenimiento**

```bash
# Reiniciar devnet
./stop-devnet.sh && ./start-devnet-simple.sh

# Limpiar contenedores
podman stop $(podman ps -q) && podman rm $(podman ps -aq)

# Verificar dependencias
./setup-devnet-podman-interactive.sh  # Verifica e instala dependencias
```

### Interacción con la Appchain

#### Conexión RPC
```bash
# Verificar estado de la cadena
curl -X POST http://127.0.0.1:9945 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"starknet_blockNumber","params":[],"id":1}'
```

#### Conexión WebSocket
```javascript
const ws = new WebSocket('ws://127.0.0.1:9946');
ws.onopen = function() {
    console.log('Conectado a Keikochain');
};
```

## 📊 Monitoreo

### Métricas de la Appchain

- **Block Height**: Altura actual del bloque
- **Transaction Count**: Número de transacciones por bloque
- **Gas Usage**: Uso de gas por transacción
- **Finality Time**: Tiempo de finalización de bloques
- **Network Latency**: Latencia de la red

### Logs y Debugging

```bash
# Ver logs del sequencer
tail -f madara-cli/logs/sequencer.log

# Ver logs del orchestrator
tail -f madara-cli/logs/orchestrator.log

# Ver logs del prover
tail -f madara-cli/logs/prover.log
```

### Health Checks

```bash
# Verificar puertos activos
netstat -tuln | grep -E ":(9944|9945|9946|8080|8081) "

# Verificar procesos
ps aux | grep -E "(madara|app-chain)" | grep -v grep

# Verificar conectividad
curl -f http://127.0.0.1:9945/health || echo "RPC no disponible"
```

## 🔒 Seguridad

### Proof-of-Humanity

Keikochain implementa un sistema robusto de Proof-of-Humanity:

1. **Registro Biométrico**: Iris y datos genómicos procesados off-chain
2. **STARK Proofs**: Verificación criptográfica de unicidad
3. **Ed25519 Signatures**: Firmas para interacciones de aprendizaje
4. **Anti-Sybil**: Prevención de múltiples identidades

### Validación de Transacciones

- **Signature Verification**: Verificación de firmas Ed25519
- **Proof Verification**: Verificación de STARK proofs
- **Humanity Check**: Verificación de Proof-of-Humanity
- **Rate Limiting**: Limitación de transacciones por usuario

## 🚀 Despliegue

### Desarrollo Local

```bash
# Iniciar Keikochain local
./quick-start.sh

# Desplegar contratos
./scripts/deploy-contracts.sh

# Ejecutar tests
./scripts/test-contracts.sh
```

### Testing

```bash
# Tests unitarios de contratos
snforge test

# Tests de integración
cargo test --package appchain-tests

# Tests de rendimiento
cargo test --package appchain-benchmarks
```

### Producción

Para despliegue en producción:

1. **Configurar nodos validadores**
2. **Implementar prover real** (no mock)
3. **Configurar settlement en Ethereum mainnet**
4. **Implementar monitoreo y alertas**
5. **Configurar backup y recovery**

## 📚 Documentación Adicional

- [Documentación de Madara](https://docs.madara.build/)
- [Madara CLI GitHub](https://github.com/madara-alliance/madara-cli)
- [Documentación de Starknet](https://docs.starknet.io/)
- [Cairo Book](https://book.cairo-lang.org/)
- [Documento de Diseño de Keiko DApp](../../.kiro/specs/01-keiko-dapp/design.md)
- [Principios de Arquitectura](../../.kiro/steering/microservices-arquitecture-principles.md)

## 🤝 Contribución

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver el archivo [LICENSE](../../LICENSE) para más detalles.

## 🆘 Soporte

Si tienes problemas:

### 🔍 **Diagnóstico Rápido**
1. **Verifica el estado**: `./check-devnet-status.sh`
2. **Verifica los logs**: `podman logs <container_name>` o `docker logs <container_name>`
3. **Verifica puertos**: `netstat -tuln | grep -E ":(9944|9945|9946) "`

### 🔄 **Soluciones Comunes**

#### **Problemas con Podman:**
```bash
# Solucionar problemas de montaje
./fix-podman-mounts.sh

# Reiniciar con script simple
./stop-devnet.sh && ./start-devnet-simple.sh
```

#### **Problemas con Docker en WSL2:**
```bash
# Usar alternativa WSL2
./setup-devnet-wsl.sh
```

#### **Problemas de permisos:**
```bash
# Usar script interactivo
./setup-devnet-podman-interactive.sh
```

### 📚 **Recursos Adicionales**
- **Documentación Madara**: [Madara Docs](https://docs.madara.build/)
- **Madara CLI GitHub**: [Madara CLI](https://github.com/madara-alliance/madara-cli)
- **Podman Docs**: [Podman Documentation](https://docs.podman.io/)
- **Starknet Docs**: [Starknet Documentation](https://docs.starknet.io/)

### 🐛 **Reportar Problemas**
Si los pasos anteriores no resuelven el problema:
1. **Abre un issue** en el repositorio
2. **Incluye logs** de `./check-devnet-status.sh`
3. **Especifica tu entorno** (WSL2, Ubuntu, etc.)
4. **Describe los pasos** que llevaron al problema

---

**¡Keikochain está lista para revolucionar el aprendizaje descentralizado con Proof-of-Humanity!** 🚀✨
