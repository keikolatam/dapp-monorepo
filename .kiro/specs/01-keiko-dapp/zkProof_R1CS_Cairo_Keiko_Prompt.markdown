# Prompt para Implementar zkProofs R1CS con Cairo en Keikochain (App Keiko)

## Contexto
Estoy desarrollando **Keiko**, una aplicación que usa una arquitectura híbrida de 5 capas para crear un "pasaporte de aprendizajes" almacenando interacciones (e.g., "completó curso X") como extrinsics en **Keikochain**, una appchain L3 desplegada con **Karnot.xyz** sobre Starknet. Quiero usar zkProofs basados en R1CS (modelados como STARKs en Cairo) para verificar una `composite_key = sha256(iris_hash || genoma_hash || salt)` que demuestra humanidad única, sin revelar datos biométricos (`iris_hash` de Gabor filters, `genoma_hash` de SNPs en VCF/FASTA). El login inicial usa **FIDO2** (WebAuthn), y las interacciones se firman con una clave **Ed25519** derivada de la `composite_key`.

## Arquitectura de Keiko
Keiko utiliza una arquitectura híbrida de 5 capas, con Keikochain como la capa de appchain L3:

```
┌─────────────────────────────────────────────────────────────┐
│                    Frontend Layer                           │
│                   Flutter App (Web/Mobile)                 │
└─────────────────────┬───────────────────────────────────────┘
                      │ GraphQL (Queries/Mutations/Subscriptions)
┌─────────────────────▼───────────────────────────────────────┐
│                     API Layer                               │
│           API Gateway (GraphQL + Redis Streams)            │
└─────────────────────┬───────────────────────────────────────┘
                      │ gRPC + Event-driven (Redis Streams)
┌─────────────────────▼───────────────────────────────────────┐
│                   Service Layer                             │
│    Microservicios (gRPC + PostgreSQL Cache + Events)       │
└─────────────────────┬───────────────────────────────────────┘
                      │ gRPC (Rust ↔ Rust)
┌─────────────────────▼───────────────────────────────────────┐
│                  gRPC Gateway Layer                         │
│         Traductor Rust ↔ Cairo (Keikochain)               │
└─────────────────────┬───────────────────────────────────────┘
                      │ Starknet RPC + Transacciones
┌─────────────────────▼───────────────────────────────────────┐
│                  Appchain Layer                             │
│         Cairo Smart Contracts (Keikochain - Starknet Appchain) │
└─────────────────────────────────────────────────────────────┘
```

- **Frontend Layer**: Flutter app (web/móvil) que usa FIDO2 para login y envía queries/mutations/subscriptions GraphQL.
- **API Layer**: API Gateway con GraphQL para queries y Redis Streams para eventos en tiempo real.
- **Service Layer**: Microservicios en Rust que procesan datos biométricos (off-chain), generan la `composite_key`, y crean pruebas STARK.
- **gRPC Gateway Layer**: Puente Rust ↔ Cairo que traduce gRPC a transacciones Starknet.
- **Appchain Layer (Keikochain)**: Contratos Cairo en Keikochain que verifican pruebas STARK y almacenan interacciones.

## Requerimientos
1. **Modelo de zkProof en Cairo**:
   - Diseña un programa Cairo que modele constraints tipo R1CS para verificar que `composite_key = sha256(iris_hash || genoma_hash || salt)` sin exponer `iris_hash` (de Gabor filters), `genoma_hash` (de SNPs en VCF/FASTA), ni `salt`.
   - La prueba debe ser un **STARK** (nativo en Cairo/Starknet), ya que zk-SNARKs requieren un trusted setup, lo cual se evita para transparencia y seguridad.
   - Usa `starknet-crypto` para SHA-256 en Cairo.

2. **Contrato Cairo en Keikochain**:
   - Crea un contrato Cairo que:
     - Almacene la `composite_key` asociada a una cuenta.
     - Verifique la prueba STARK para confirmar que la `composite_key` es válida.
     - Permita enviar interacciones de aprendizaje firmadas con una clave Ed25519 derivada de la `composite_key`.
     - Guarde las interacciones en un storage tipo `LearningPassport: AccountId -> Vec<(Data, Timestamp)>`.
   - Optimiza para bajo costo de gas en Starknet.

3. **Integración con FIDO2**:
   - El **Frontend Layer** (Flutter) implementa FIDO2 para login inicial, generando un JWT para la sesión.
   - El JWT se envía al **API Layer** (GraphQL) para autenticar solicitudes.
   - La DApp envía la `composite_key` y la prueba STARK al contrato Cairo vía el **gRPC Gateway Layer**.

4. **Flujo entre Capas**:
   - **Frontend Layer**: Envía queries/mutations GraphQL para registrar/verificar la `composite_key` o enviar interacciones.
   - **API Layer**: Procesa requests GraphQL y emite eventos via Redis Streams (e.g., "interacción registrada").
   - **Service Layer**: Microservicios Rust procesan datos biométricos (usando OpenCV para Gabor filters, BioPython para VCF/FASTA), generan la `composite_key`, y crean pruebas STARK con `cairo-lang`.
   - **gRPC Gateway Layer**: Traduce gRPC a transacciones Starknet usando `starknet-rs`.
   - **Appchain Layer (Keikochain)**: Ejecuta el contrato Cairo para verificar pruebas y almacenar interacciones.

5. **Despliegue en Keikochain**:
   - Despliega Keikochain con Karnot.xyz, configurando una appchain L3 sobre Starknet.
   - Compila el contrato Cairo con `starknet-compile` y despliega usando el dashboard de Karnot (RPC: `wss://keikochain.karnot.xyz`).
   - Configura el **gRPC Gateway Layer** para conectar microservicios con el RPC de Starknet.

6. **Consideraciones**:
   - **Privacidad**: No almacenes datos biométricos en Keikochain; usa STARKs para verificar sin exponer inputs.
   - **Seguridad**: Protege contra ataques Sybil con la `composite_key` y STARKs.
   - **Escalabilidad**: Usa Redis Streams y PostgreSQL para caché, y ZK-rollups en Keikochain para bajo costo.
   - **UX**: FIDO2 solo para login, con JWT para sesiones sin biometría repetitiva.
   - **STARKs vs zk-SNARKs**: Prefiere STARKs para evitar trusted setup; justifica si zk-SNARKs son necesarios (e.g., pruebas más pequeñas).

7. **Entregables**:
   - Código Cairo para el contrato, incluyendo constraints R1CS (via AIR) y verificación de STARKs.
   - Microservicio Rust para procesar biometría y generar `composite_key`.
   - Código Flutter para login FIDO2 y envío de interacciones via GraphQL.
   - Configuración de gRPC Gateway (Rust ↔ Cairo).
   - Instrucciones de despliegue en Karnot.xyz.
   - Comparación de STARKs vs zk-SNARKs (pros/contras).

## Ejemplo de Código Esperado
- **Contrato Cairo (Keikochain)**:
  ```cairo
  #[contract]
  mod ProofOfHumanity {
      use starknet::get_caller_address;
      use starknet::crypto::sha256;

      #[storage]
      struct Storage {
          composite_keys: Map<felt252, felt252>,
          learning_passport: Map<felt252, LegacyMap<felt252, felt252>>,
      }

      #[external]
      fn verify_composite_key(iris_hash: felt252, genoma_hash: felt252, salt: felt252, composite_key: felt252) {
          let computed_hash = sha256(iris_hash, genoma_hash, salt);
          assert(computed_hash == composite_key, 'Invalid composite key');
          let caller = get_caller_address();
          composite_keys::write(caller, composite_key);
      }

      #[external]
      fn submit_learning_interaction(data: felt252, proof: felt252, signature: felt252) {
          let caller = get_caller_address();
          let composite_key = composite_keys::read(caller);
          assert(verify_stark_proof(proof, composite_key), 'Invalid proof');
          assert(verify_ed25519_signature(data, signature, composite_key), 'Invalid signature');
          learning_passport::write(caller, data, starknet::get_block_timestamp());
      }
  }
  ```

- **Microservicio Rust (Service Layer)**:
  ```rust
  use sha2::{Digest, Sha256};
  use grpc::ClientStub;

  fn generate_composite_key(iris_hash: &str, genoma_hash: &str, salt: &str) -> String {
      let mut hasher = Sha256::new();
      hasher.update(iris_hash);
      hasher.update(genoma_hash);
      hasher.update(salt);
      format!("{:x}", hasher.finalize())
  }

  async fn submit_to_gateway(data: Vec<u8>, proof: Vec<u8>, signature: Vec<u8>) {
      let client = StarknetGatewayClient::new("localhost:50051").await.unwrap();
      client.submit_interaction(data, proof, signature).await.unwrap();
  }
  ```

- **Frontend Flutter (FIDO2 Login)**:
  ```dart
  import 'package:web_authn/web_authn.dart';
  import 'package:http/http.dart' as http;
  import 'dart:convert';

  Future<String> loginWithFIDO2() async {
    final publicKey = PublicKeyCredentialRequestOptions(
      challenge: Uint8List.fromList(List.generate(32, (_) => Random().nextInt(256))),
      rpId: 'keiko.com',
      allowCredentials: [],
      userVerification: 'required',
    );
    final assertion = await navigator.credentials.get(publicKey: publicKey);
    final response = await http.post(
      Uri.parse('https://api.keiko.com/login'),
      body: jsonEncode({
        'signature': base64Encode(assertion.response.signature),
        'authenticatorData': base64Encode(assertion.response.authenticatorData),
      }),
    );
    return jsonDecode(response.body)['token'];
  }
  ```

- **gRPC Gateway (Rust ↔ Cairo)**:
  ```rust
  use starknet::core::types::FieldElement;

  async fn translate_to_starknet(data: Vec<u8>, proof: Vec<u8>, signature: Vec<u8>) {
      let provider = starknet::Provider::new("wss://keikochain.karnot.xyz").unwrap();
      provider.call_contract("ProofOfHumanity", "submit_learning_interaction", vec![data, proof, signature]).await.unwrap();
  }
  ```

## Instrucciones de Despliegue
1. **Desplegar Keikochain**:
   - Usa el dashboard de Karnot.xyz para crear Keikochain (appchain L3 sobre Starknet).
   - Configura settlement en Starknet, DA en Avail, y RPC endpoint (`wss://keikochain.karnot.xyz`).
2. **Compilar Contrato Cairo**:
   ```bash
   starknet-compile proof_of_humanity.cairo --output proof_of_humanity_compiled.json
   ```
3. **Desplegar Contrato**:
   ```bash
   starknet-deploy --network keikochain proof_of_humanity_compiled.json
   ```
4. **Configurar Microservicios**:
   - Despliega microservicios Rust con Docker.
   - Configura PostgreSQL para caché y Redis Streams para eventos.
5. **Conectar gRPC Gateway**:
   - Usa `starknet-rs` para conectar con el RPC de Keikochain.
   - Configura gRPC server en `localhost:50051`.
6. **Frontend**:
   - Despliega la app Flutter para web/móvil.
   - Configura GraphQL endpoint (`https://api.keiko.com`).

## Notas Adicionales
- Usa `cairo-lang` y `starknet-crypto` para SHA-256 y STARKs.
- Modela R1CS en Cairo con AIR para compatibilidad con STARKs.
- Evita zk-SNARKs por su trusted setup; STARKs son ideales para Keikochain.
- Referencias: madara.zone/docs, karnot.xyz/docs, starknet.io.