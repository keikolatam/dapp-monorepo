# Contratos Cairo para Keiko

## 🎯 Casos de Uso Específicos para Keiko

Este documento contiene los contratos Cairo específicos para el proyecto Keiko, incluyendo Proof-of-Humanity y Learning Interactions.

## 🔐 Proof-of-Humanity Contract

### **Contrato Principal**

```cairo
#[contract]
mod ProofOfHumanity {
    use starknet::{
        get_caller_address, get_contract_address, get_block_timestamp,
        ContractAddress
    };
    use starknet::crypto::{sha256, verify_signature};
    use starknet::storage::{Map, LegacyMap};
    
    #[storage]
    struct Storage {
        // Almacena humanity_proof_key por cuenta
        humanity_proof_keys: Map<felt252, felt252>,
        // Almacena pasaportes de aprendizaje por cuenta
        learning_passport: Map<felt252, LegacyMap<felt252, felt252>>,
        // Contador de humanos verificados
        verified_humans_count: u256,
        // Mapeo de humanity_proof_key a cuenta (para recuperación)
        key_to_account: Map<felt252, felt252>,
    }
    
    #[event]
    #[derive(Drop, Serde)]
    struct HumanityVerified {
        account: felt252,
        humanity_proof_key: felt252,
        timestamp: u64,
    }
    
    #[event]
    #[derive(Drop, Serde)]
    struct IdentityRecovered {
        old_account: felt252,
        new_account: felt252,
        humanity_proof_key: felt252,
        timestamp: u64,
    }
    
    #[constructor]
    fn constructor() {
        verified_humans_count::write(0);
    }
    
    #[external]
    fn verify_humanity(proof: felt252, humanity_proof_key: felt252) {
        // Verificar que la prueba STARK es válida
        assert(verify_stark_proof(proof, humanity_proof_key), 'Invalid proof');
        
        let caller = get_caller_address();
        let timestamp = get_block_timestamp();
        
        // Verificar si ya existe una cuenta con esta humanity_proof_key
        let existing_account = key_to_account::read(humanity_proof_key);
        
        if (existing_account != 0) {
            // Recuperación de identidad
            let old_account = existing_account;
            
            // Transferir historial de aprendizaje
            transfer_learning_history(old_account, caller);
            
            // Actualizar mapeo
            key_to_account::write(humanity_proof_key, caller);
            humanity_proof_keys::write(caller, humanity_proof_key);
            
            IdentityRecovered {
                old_account,
                new_account: caller,
                humanity_proof_key,
                timestamp,
            }.emit();
        } else {
            // Nueva verificación de humanidad
            humanity_proof_keys::write(caller, humanity_proof_key);
            key_to_account::write(humanity_proof_key, caller);
            verified_humans_count::write(verified_humans_count::read() + 1);
            
            HumanityVerified {
                account: caller,
                humanity_proof_key,
                timestamp,
            }.emit();
        }
    }
    
    #[view]
    fn get_humanity_proof_key(account: felt252) -> felt252 {
        humanity_proof_keys::read(account)
    }
    
    #[view]
    fn is_verified_human(account: felt252) -> bool {
        humanity_proof_keys::read(account) != 0
    }
    
    #[view]
    fn get_verified_humans_count() -> u256 {
        verified_humans_count::read()
    }
    
    // Función interna para transferir historial de aprendizaje
    #[internal]
    fn transfer_learning_history(from_account: felt252, to_account: felt252) {
        // Implementar lógica de transferencia de historial
        // Esto se conectaría con el contrato de Learning Interactions
    }
    
    // Función interna para verificar pruebas STARK
    #[internal]
    fn verify_stark_proof(proof: felt252, humanity_proof_key: felt252) -> bool {
        // Implementar verificación de prueba STARK
        // Esta función se conectaría con el sistema de verificación STARK
        true // Placeholder
    }
}
```

## 📚 Learning Interactions Contract

### **Contrato de Interacciones de Aprendizaje**

```cairo
#[contract]
mod LearningInteractions {
    use starknet::{
        get_caller_address, get_block_timestamp, get_block_number,
        ContractAddress
    };
    use starknet::crypto::verify_signature;
    use starknet::storage::{Map, Vec, VecMapped};
    
    #[storage]
    struct Storage {
        // Interacciones por usuario
        interactions: Map<felt252, Vec<Interaction>>,
        // Contador global de interacciones
        interaction_count: u256,
        // Mapeo de ID de interacción a datos
        interaction_data: Map<u256, Interaction>,
        // Sesiones tutoriales por usuario
        tutorial_sessions: Map<felt252, Vec<TutorialSession>>,
        // Contador de sesiones
        session_count: u256,
    }
    
    #[derive(Serde, Drop, Copy, PartialEq)]
    struct Interaction {
        id: u256,
        data: felt252,
        timestamp: u64,
        user: felt252,
        session_id: Option<u256>,
        interaction_type: InteractionType,
    }
    
    #[derive(Serde, Drop, Copy, PartialEq)]
    enum InteractionType {
        Question,
        Answer,
        Exercise,
        Discussion,
        Evaluation,
        Individual,
    }
    
    #[derive(Serde, Drop, Copy, PartialEq)]
    struct TutorialSession {
        id: u256,
        user: felt252,
        tutor: felt252,
        start_time: u64,
        end_time: Option<u64>,
        interactions_count: u256,
        session_type: SessionType,
    }
    
    #[derive(Serde, Drop, Copy, PartialEq)]
    enum SessionType {
        HumanTutor,
        AITutor,
        GroupStudy,
        IndividualStudy,
    }
    
    #[event]
    #[derive(Drop, Serde)]
    struct InteractionCreated {
        user: felt252,
        interaction_id: u256,
        session_id: Option<u256>,
        interaction_type: InteractionType,
        timestamp: u64,
    }
    
    #[event]
    #[derive(Drop, Serde)]
    struct TutorialSessionStarted {
        session_id: u256,
        user: felt252,
        tutor: felt252,
        session_type: SessionType,
        timestamp: u64,
    }
    
    #[event]
    #[derive(Drop, Serde)]
    struct TutorialSessionEnded {
        session_id: u256,
        user: felt252,
        interactions_count: u256,
        duration: u64,
        timestamp: u64,
    }
    
    #[constructor]
    fn constructor() {
        interaction_count::write(0);
        session_count::write(0);
    }
    
    #[external]
    fn create_interaction(
        data: felt252, 
        signature: felt252,
        session_id: Option<u256>,
        interaction_type: InteractionType
    ) {
        let caller = get_caller_address();
        
        // Verificar que el usuario es un humano verificado
        let humanity_proof_key = get_humanity_proof_key(caller);
        assert(humanity_proof_key != 0, 'Not verified human');
        
        // Verificar firma Ed25519
        assert(
            verify_signature(humanity_proof_key, data, signature), 
            'Invalid signature'
        );
        
        let interaction_id = interaction_count::read();
        let timestamp = get_block_timestamp();
        
        let interaction = Interaction {
            id: interaction_id,
            data,
            timestamp,
            user: caller,
            session_id,
            interaction_type,
        };
        
        // Almacenar interacción
        interactions::append(caller, interaction);
        interaction_data::write(interaction_id, interaction);
        interaction_count::write(interaction_id + 1);
        
        // Si es parte de una sesión, actualizar contador
        if (session_id.is_some()) {
            let session_id_value = session_id.unwrap();
            update_session_interaction_count(session_id_value);
        }
        
        InteractionCreated {
            user: caller,
            interaction_id,
            session_id,
            interaction_type,
            timestamp,
        }.emit();
    }
    
    #[external]
    fn start_tutorial_session(
        tutor: felt252,
        session_type: SessionType
    ) -> u256 {
        let caller = get_caller_address();
        let session_id = session_count::read();
        let timestamp = get_block_timestamp();
        
        let session = TutorialSession {
            id: session_id,
            user: caller,
            tutor,
            start_time: timestamp,
            end_time: Option::None,
            interactions_count: 0,
            session_type,
        };
        
        tutorial_sessions::append(caller, session);
        session_count::write(session_id + 1);
        
        TutorialSessionStarted {
            session_id,
            user: caller,
            tutor,
            session_type,
            timestamp,
        }.emit();
        
        session_id
    }
    
    #[external]
    fn end_tutorial_session(session_id: u256) {
        let caller = get_caller_address();
        let timestamp = get_block_timestamp();
        
        // Buscar y actualizar la sesión
        let sessions = tutorial_sessions::read(caller);
        let mut updated_sessions = Vec::new();
        
        let mut i = 0;
        loop {
            if (i >= sessions.len()) {
                break;
            }
            let session = *sessions.at(i);
            if (session.id == session_id) {
                let updated_session = TutorialSession {
                    id: session.id,
                    user: session.user,
                    tutor: session.tutor,
                    start_time: session.start_time,
                    end_time: Option::Some(timestamp),
                    interactions_count: session.interactions_count,
                    session_type: session.session_type,
                };
                updated_sessions.append(updated_session);
            } else {
                updated_sessions.append(session);
            }
            i += 1;
        }
        
        tutorial_sessions::write(caller, updated_sessions);
        
        TutorialSessionEnded {
            session_id,
            user: caller,
            interactions_count: get_session_interactions_count(session_id),
            duration: timestamp - get_session_start_time(session_id),
            timestamp,
        }.emit();
    }
    
    #[view]
    fn get_user_interactions(user: felt252) -> Vec<Interaction> {
        interactions::read(user)
    }
    
    #[view]
    fn get_interaction_by_id(interaction_id: u256) -> Interaction {
        interaction_data::read(interaction_id)
    }
    
    #[view]
    fn get_user_sessions(user: felt252) -> Vec<TutorialSession> {
        tutorial_sessions::read(user)
    }
    
    #[view]
    fn get_total_interactions() -> u256 {
        interaction_count::read()
    }
    
    // Funciones internas
    #[internal]
    fn get_humanity_proof_key(account: felt252) -> felt252 {
        // Esta función se conectaría con el contrato ProofOfHumanity
        0 // Placeholder
    }
    
    #[internal]
    fn update_session_interaction_count(session_id: u256) {
        // Implementar lógica para actualizar contador de interacciones en sesión
    }
    
    #[internal]
    fn get_session_interactions_count(session_id: u256) -> u256 {
        // Implementar lógica para obtener contador de interacciones
        0 // Placeholder
    }
    
    #[internal]
    fn get_session_start_time(session_id: u256) -> u64 {
        // Implementar lógica para obtener tiempo de inicio de sesión
        0 // Placeholder
    }
}
```

## 🛠️ Macros de Utilidades para Keiko

### **Estructuras de Datos**

```cairo
#[derive(Serde, Drop, Copy, PartialEq)]
struct Interaction {
    id: u256,
    data: felt252,
    timestamp: u64,
    user: felt252,
    session_id: Option<u256>,
    interaction_type: InteractionType,
}

#[derive(Serde, Drop, Copy, PartialEq)]
struct TutorialSession {
    id: u256,
    user: felt252,
    tutor: felt252,
    start_time: u64,
    end_time: Option<u64>,
    interactions_count: u256,
    session_type: SessionType,
}

#[derive(Serde, Drop, Copy, PartialEq)]
enum InteractionType {
    Question,
    Answer,
    Exercise,
    Discussion,
    Evaluation,
    Individual,
}

#[derive(Serde, Drop, Copy, PartialEq)]
enum SessionType {
    HumanTutor,
    AITutor,
    GroupStudy,
    IndividualStudy,
}
```

### **Funciones de Validación**

```cairo
// Macros para manejo de errores específicos de Keiko
#[inline(always)]
fn assert_humanity_proof(proof: felt252, key: felt252) {
    assert(verify_stark_proof(proof, key), 'Invalid humanity proof');
}

#[inline(always)]
fn assert_valid_signature(data: felt252, signature: felt252, key: felt252) {
    assert(verify_signature(key, data, signature), 'Invalid signature');
}

#[inline(always)]
fn assert_verified_human(account: felt252) {
    let humanity_proof_key = get_humanity_proof_key(account);
    assert(humanity_proof_key != 0, 'Not verified human');
}

#[inline(always)]
fn assert_valid_session(session_id: u256, user: felt252) {
    // Implementar validación de sesión
    assert(session_id < get_total_sessions(), 'Invalid session ID');
}
```

## 🚀 Patrones Específicos para Keiko

### **Constructor con Validación de Humanidad**

```cairo
#[constructor]
fn constructor(initial_owner: felt252, humanity_proof_key: felt252) {
    assert(initial_owner != 0, 'Invalid owner');
    assert(humanity_proof_key != 0, 'Invalid humanity proof key');
    
    owner::write(initial_owner);
    humanity_proof_keys::write(initial_owner, humanity_proof_key);
    verified_humans_count::write(1);
}
```

### **Función con Verificación de Humanidad**

```cairo
#[external]
fn human_only_function(data: felt252, signature: felt252) {
    let caller = get_caller_address();
    
    // Verificar que es un humano verificado
    assert_verified_human(caller);
    
    // Verificar firma
    let humanity_proof_key = get_humanity_proof_key(caller);
    assert_valid_signature(data, signature, humanity_proof_key);
    
    // Lógica solo para humanos verificados
    process_human_interaction(caller, data);
}
```

### **Función con Recuperación de Identidad**

```cairo
#[external]
fn recover_identity(proof: felt252, humanity_proof_key: felt252) {
    let caller = get_caller_address();
    
    // Verificar prueba STARK
    assert_humanity_proof(proof, humanity_proof_key);
    
    // Verificar si ya existe una cuenta con esta humanity_proof_key
    let existing_account = key_to_account::read(humanity_proof_key);
    
    if (existing_account != 0) {
        // Transferir historial de aprendizaje
        transfer_learning_history(existing_account, caller);
        
        // Actualizar mapeos
        key_to_account::write(humanity_proof_key, caller);
        humanity_proof_keys::write(caller, humanity_proof_key);
        
        // Emitir evento de recuperación
        IdentityRecovered {
            old_account: existing_account,
            new_account: caller,
            humanity_proof_key,
            timestamp: get_block_timestamp(),
        }.emit();
    }
}
```

## 📖 Referencias

- [Cairo Book - Smart Contracts](https://book.cairo-lang.org/ch99-01-01-introduction.html)
- [Starknet Book - Smart Contracts](https://book.starknet.io/chapter_1/introduction.html)
- [Keiko Requirements](../.kiro/specs/01-keiko-dapp/requirements.md)

---

**💡 Tip:** Estos contratos están diseñados específicamente para la arquitectura híbrida de Keiko y se integran con el sistema de proof-of-humanity y las interacciones de aprendizaje xAPI.
