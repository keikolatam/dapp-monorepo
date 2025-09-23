# Cairo Quick Reference para Keiko

## 🚀 Macros Esenciales

| Macro | Propósito | Ejemplo |
|-------|-----------|---------|
| `#[contract]` | Define contrato inteligente | `#[contract] mod MyContract` |
| `#[storage]` | Estructura de almacenamiento | `#[storage] struct Storage` |
| `#[external]` | Función pública (modifica estado) | `#[external] fn transfer()` |
| `#[view]` | Función de solo lectura | `#[view] fn get_balance()` |
| `#[constructor]` | Función de inicialización | `#[constructor] fn constructor()` |
| `#[event]` | Define evento | `#[event] struct Transfer` |
| `#[derive(Serde)]` | Serialización automática | `#[derive(Serde, Drop)]` |

## 🔧 Imports Comunes

```cairo
use starknet::{
    ContractAddress, get_caller_address, get_contract_address,
    get_block_timestamp, get_block_number
};
use starknet::crypto::{sha256, verify_signature};
use starknet::storage::{Map, LegacyMap, Vec};
```

## 📝 Estructura Básica de Contrato

```cairo
#[contract]
mod MyContract {
    use starknet::get_caller_address;
    
    #[storage]
    struct Storage {
        owner: felt252,
        data: Map<felt252, felt252>,
    }
    
    #[constructor]
    fn constructor(initial_owner: felt252) {
        owner::write(initial_owner);
    }
    
    #[external]
    fn set_data(key: felt252, value: felt252) {
        data::write(key, value);
    }
    
    #[view]
    fn get_data(key: felt252) -> felt252 {
        data::read(key)
    }
}
```

## 🎯 Para Keiko - Proof of Humanity

```cairo
#[contract]
mod ProofOfHumanity {
    #[storage]
    struct Storage {
        humanity_proof_keys: Map<felt252, felt252>,
    }
    
    #[external]
    fn verify_humanity(proof: felt252, humanity_proof_key: felt252) {
        // Verificar prueba STARK
        let caller = get_caller_address();
        humanity_proof_keys::write(caller, humanity_proof_key);
    }
}
```

## ⚡ Comandos Útiles

```bash
# Compilar contrato
scarb build

# Ejecutar tests
scarb test

# Declarar contrato
starknet declare --contract target/dev/MyContract.sierra.json

# Desplegar contrato
starknet deploy --class-hash <class_hash>
```

## 🐛 Debugging

```cairo
// Usar assert para validaciones
assert(condition, 'Error message');

// Verificar caller
let caller = get_caller_address();
assert(caller == expected_address, 'Unauthorized');
```
