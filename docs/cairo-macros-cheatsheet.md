# Cairo Macros Cheat Sheet para Starknet

## 📋 Macros Principales

### **Contrato y Módulos**

**Macros principales:**
- `#[contract]` - Define un módulo como contrato inteligente
- `#[starknet::interface]` - Define una interfaz de contrato
- `#[abi]` - Genera automáticamente el ABI del contrato

**Ejemplo de uso:**
```cairo
#[starknet::interface]
trait ITokenContract<TContractState> {
    fn transfer(ref self: TContractState, to: felt252, amount: u256);
    fn get_balance(self: @TContractState, account: felt252) -> u256;
}

#[contract]
mod TokenContract {
    use super::ITokenContract;
    
    #[storage]
    struct Storage {
        owner: felt252,
        total_supply: u256,
        balances: Map<felt252, u256>,
    }
    
    #[abi]
    impl TokenContractImpl of ITokenContract<ContractState> {
        fn transfer(ref self: ContractState, to: felt252, amount: u256) {
            let caller = get_caller_address();
            let balance = self.balances.read(caller);
            assert(balance >= amount, 'Insufficient balance');
            self.balances.write(caller, balance - amount);
            self.balances.write(to, self.balances.read(to) + amount);
        }
        
        fn get_balance(self: @ContractState, account: felt252) -> u256 {
            self.balances.read(account)
        }
    }
    
    #[constructor]
    fn constructor(ref self: ContractState, initial_owner: felt252, initial_supply: u256) {
        self.owner.write(initial_owner);
        self.total_supply.write(initial_supply);
        self.balances.write(initial_owner, initial_supply);
    }
}
```

**💡 Para principiantes:** Un contrato en Cairo es como una clase en programación orientada a objetos, pero vive en la blockchain. 
- `#[starknet::interface]` define el "contrato" o especificación de qué funciones públicas tendrá tu contrato
- `#[contract]` le dice al compilador que este módulo debe ser tratado como un contrato inteligente desplegable
- `#[abi]` genera automáticamente el ABI (Application Binary Interface) que permite que otros contratos y aplicaciones interactúen con el tuyo

### **Almacenamiento**

**Macros de almacenamiento:**
- `#[storage]` - Define la estructura de almacenamiento
- `#[substorage(v0)]` - Define sub-almacenamiento (versión 0)

**Ejemplo:**
```cairo
#[storage]
struct Storage {
    owner: felt252,
    balances: Map<felt252, u256>,
    total_supply: u256,
}
```

**💡 Para principiantes:** El almacenamiento es donde tu contrato guarda datos permanentemente en la blockchain. `felt252` es el tipo básico de Cairo (como un string o número), `Map` es como un diccionario que asocia claves con valores, y `u256` es un número entero de 256 bits. Todo lo que declares aquí persiste entre transacciones.

### **Funciones del Contrato**

**Macros de funciones:**
- `#[external]` - Función pública que puede modificar estado
- `#[view]` - Función pública de solo lectura
- `#[constructor]` - Función que se ejecuta al desplegar
- `#[l1_handler]` - Función que maneja mensajes L1→L2

**Ejemplo:**
```cairo
#[constructor]
fn constructor(initial_owner: felt252) {
    owner::write(initial_owner);
}

#[external]
fn transfer(to: felt252, amount: u256) {
    // Lógica de transferencia
}

#[view]
fn get_balance(account: felt252) -> u256 {
    balances::read(account)
}
```

**💡 Para principiantes:** 
- `#[constructor]` se ejecuta UNA SOLA VEZ cuando despliegas el contrato (como inicializar variables)
- `#[external]` son funciones que cualquiera puede llamar y que pueden cambiar el estado del contrato (como transferir tokens)
- `#[view]` son funciones de solo lectura que no cuestan gas y no cambian nada (como consultar un balance)
- `#[l1_handler]` maneja mensajes que vienen de Ethereum (L1) hacia Starknet (L2)

### **Eventos**

**Macros de eventos:**
- `#[event]` - Define un evento del contrato
- `#[derive(Drop, Serde)]` - Genera implementaciones automáticas

**Ejemplo:**
```cairo
#[event]
#[derive(Drop, Serde)]
struct Transfer {
    from: felt252,
    to: felt252,
    amount: u256,
}

// Emitir evento
Transfer { from, to, amount }.emit();
```

**💡 Para principiantes:** Los eventos son como "notificaciones" que tu contrato envía cuando algo importante sucede. Son útiles para que las aplicaciones frontend sepan cuándo actualizar la interfaz. Por ejemplo, cuando alguien transfiere tokens, emites un evento `Transfer` para que las wallets y exploradores puedan mostrar la transacción.

### **Serialización y Deserialización**

**Macros derive:**
- `#[derive(Serde)]` - Genera serialización/deserialización
- `#[derive(Drop)]` - Genera implementación de Drop
- `#[derive(Copy)]` - Genera implementación de Copy
- `#[derive(PartialEq)]` - Genera comparación de igualdad

**Ejemplo:**
```cairo
#[derive(Serde, Drop, Copy, PartialEq)]
struct UserData {
    name: felt252,
    age: u8,
    is_active: bool,
}
```

**💡 Para principiantes:** Los macros `derive` generan código automáticamente para ti:
- `Serde` permite convertir tu estructura a/desde bytes (necesario para guardar en storage)
- `Drop` permite que la estructura se "destruya" automáticamente cuando no se necesite
- `Copy` permite copiar la estructura fácilmente
- `PartialEq` permite comparar si dos estructuras son iguales con `==`

### **Configuración de Compilación**

**Macros de configuración:**
- `#[cfg(target_os = "starknet")]` - Solo compilar para Starknet
- `#[cfg(test)]` - Solo en tests
- `#[cfg(feature = "std")]` - Solo con feature std

**💡 Para principiantes:** Estos macros controlan cuándo se incluye código en la compilación final. Por ejemplo, `#[cfg(test)]` significa que ese código solo se compila cuando ejecutas tests, no en el contrato final. Es útil para tener código de prueba separado del código de producción.

## 🔧 Macros para Testing

**Macros de testing:**
- `#[test]` - Marca una función como test
- `#[available_gas(20000000)]` - Limita gas para tests

**Ejemplo:**
```cairo
#[test]
#[available_gas(20000000)]
fn test_transfer() {
    // Código de test
}
```

**💡 Para principiantes:** Los tests son fundamentales en desarrollo de contratos inteligentes. `#[test]` marca una función como test, y `#[available_gas(20000000)]` le da a tu test un límite de gas específico para simular condiciones reales. Siempre prueba tus contratos antes de desplegarlos en mainnet.

## 🛡️ Macros de Seguridad

**Macros de optimización:**
- `#[inline(always)]` - Fuerza inline de función
- `#[inline(never)]` - Evita inline de función
- `#[cold]` - Marca función como "fría" (poco usada)

**💡 Para principiantes:** Estos macros optimizan el rendimiento de tu contrato. `inline` significa que el compilador copia el código de la función directamente donde se llama, en lugar de hacer una llamada separada. Esto puede hacer el código más rápido pero más grande. Úsalos solo cuando tengas problemas de rendimiento específicos.

## 📦 Macros de Importación

**Importaciones comunes:**
- `use starknet::ContractAddress` - Para direcciones de contrato
- `use starknet::get_caller_address` - Para obtener la dirección del llamador
- `use starknet::get_contract_address` - Para obtener la dirección del contrato
- `use starknet::storage::{Map, LegacyMap, Vec, VecMapped}` - Para estructuras de almacenamiento

**💡 Para principiantes:** Las importaciones te dan acceso a funcionalidades pre-construidas. `get_caller_address()` es muy importante para seguridad - te dice quién está llamando tu función. `Map` es como un diccionario para guardar datos asociados, y `Vec` es como una lista dinámica.

## 🚀 Patrones Comunes

### **Constructor con Validación**

```cairo
#[constructor]
fn constructor(initial_owner: felt252) {
    assert(initial_owner != 0, 'Invalid owner');
    owner::write(initial_owner);
}
```

**💡 Para principiantes:** Siempre valida los parámetros en el constructor. `assert()` detiene la ejecución si la condición es falsa. Aquí verificamos que el owner no sea 0 (dirección inválida) antes de guardarlo. Es mejor fallar al desplegar que tener un contrato con datos incorrectos.

### **Función con Verificación de Propietario**

```cairo
#[external]
fn admin_function() {
    let caller = get_caller_address();
    assert(caller == owner::read(), 'Not owner');
    
    // Lógica administrativa
}
```

**💡 Para principiantes:** Este es un patrón de seguridad fundamental. Siempre verifica quién está llamando tu función antes de permitir acciones administrativas. `get_caller_address()` te da la dirección de quien hizo la transacción, y lo comparas con el owner guardado en storage. Sin esto, cualquiera podría ejecutar funciones administrativas.

### **Función con Verificación de Permisos**

```cairo
#[external]
fn restricted_function() {
    let caller = get_caller_address();
    assert(is_authorized(caller), 'Not authorized');
    
    // Lógica restringida
}
```

**💡 Para principiantes:** Este patrón es más flexible que verificar solo el owner. `is_authorized()` puede ser una función que verifica si el caller tiene permisos específicos (como ser un moderador, tener un rol especial, etc.). Te permite tener múltiples niveles de acceso en tu contrato.

### **Función con Manejo de Errores**

```cairo
#[external]
fn safe_function(value: u256) {
    assert(value > 0, 'Value must be positive');
    assert(value < MAX_VALUE, 'Value too large');
    
    // Lógica segura
}
```

**💡 Para principiantes:** Siempre valida los inputs de tus funciones. Los usuarios pueden enviar cualquier valor, y sin validación tu contrato puede comportarse de manera inesperada. Aquí verificamos que el valor esté en un rango válido antes de procesarlo. Los mensajes de error deben ser claros para ayudar con el debugging.

## 📚 Macros de Utilidades

### **Estructuras de Datos Comunes**

```cairo
#[derive(Serde, Drop, Copy, PartialEq)]
struct User {
    id: u256,
    name: felt252,
    balance: u256,
    is_active: bool,
}

#[derive(Serde, Drop, Copy, PartialEq)]
struct Transaction {
    id: u256,
    from: felt252,
    to: felt252,
    amount: u256,
    timestamp: u64,
}
```

**💡 Para principiantes:** Las estructuras te permiten agrupar datos relacionados. `User` podría representar un usuario en tu sistema con su ID, nombre, balance y estado. `Transaction` representa una transacción con todos sus detalles. Usa `u256` para IDs y cantidades grandes, `felt252` para direcciones y texto, y `bool` para estados simples.

### **Funciones de Validación**

```cairo
// Macros para manejo de errores
#[inline(always)]
fn assert_positive(value: u256) {
    assert(value > 0, 'Value must be positive');
}

#[inline(always)]
fn assert_authorized(caller: felt252) {
    assert(is_authorized(caller), 'Not authorized');
}

#[inline(always)]
fn assert_sufficient_balance(account: felt252, amount: u256) {
    let balance = balances::read(account);
    assert(balance >= amount, 'Insufficient balance');
}
```

**💡 Para principiantes:** Crear funciones de validación reutilizables es una excelente práctica. En lugar de repetir la misma lógica de validación en múltiples lugares, creas una función que puedes llamar. `#[inline(always)]` hace que estas funciones pequeñas sean más eficientes. Esto hace tu código más limpio y fácil de mantener.

## 🔄 Patrones de Estado

### **Máquina de Estados**

```cairo
#[derive(Serde, Drop, Copy, PartialEq)]
enum ContractState {
    Initialized,
    Active,
    Paused,
    Terminated,
}

#[storage]
struct Storage {
    state: ContractState,
    // otros campos...
}

#[external]
fn pause() {
    assert(state::read() == ContractState::Active, 'Not active');
    state::write(ContractState::Paused);
}
```

**💡 Para principiantes:** Una máquina de estados controla en qué fase está tu contrato. Por ejemplo, un contrato puede estar `Active` (funcionando normalmente), `Paused` (temporalmente detenido), o `Terminated` (cerrado permanentemente). Esto es útil para pausar operaciones en caso de emergencia o para implementar lógica de negocio específica.

### **Contador con Límites**

```cairo
#[storage]
struct Storage {
    count: u256,
    max_count: u256,
}

#[external]
fn increment() {
    let current = count::read();
    let max = max_count::read();
    assert(current < max, 'Maximum count reached');
    count::write(current + 1);
}
```

**💡 Para principiantes:** Este patrón es útil para limitar operaciones. Por ejemplo, podrías limitar el número de tokens que se pueden mintear, o el número de votos que puede emitir una dirección. Siempre lee el valor actual, verifica que no exceda el límite, y luego actualiza. Sin esta verificación, el contador podría desbordarse.

## 🎯 Patrones de Eventos

### **Eventos con Índices**

```cairo
#[event]
#[derive(Drop, Serde)]
struct UserRegistered {
    #[key]
    user: felt252,
    timestamp: u64,
    user_type: UserType,
}

#[event]
#[derive(Drop, Serde)]
struct BalanceUpdated {
    #[key]
    account: felt252,
    old_balance: u256,
    new_balance: u256,
    timestamp: u64,
}
```

**💡 Para principiantes:** El atributo `#[key]` marca campos importantes para indexación. Esto hace que sea más fácil buscar eventos específicos. Por ejemplo, con `#[key] user: felt252`, puedes buscar fácilmente todos los eventos de registro para un usuario específico. Los índices mejoran el rendimiento de las consultas de eventos.

### **Eventos de Error**

```cairo
#[event]
#[derive(Drop, Serde)]
struct ErrorOccurred {
    error_code: u256,
    error_message: felt252,
    timestamp: u64,
    caller: felt252,
}
```

**💡 Para principiantes:** Los eventos de error son útiles para debugging y monitoreo. Cuando algo sale mal en tu contrato, puedes emitir un evento con detalles del error, incluyendo quién lo causó y cuándo. Esto te ayuda a rastrear problemas y mejorar tu contrato. Es mejor emitir eventos de error que simplemente fallar silenciosamente.

## 📖 Referencias

- [Cairo Book - Macros](https://book.cairo-lang.org/ch03-05-control-flow.html)
- [Starknet Book - Smart Contracts](https://book.starknet.io/chapter_1/introduction.html)
- [Cairo Reference](https://cairo-lang.org/docs/)
- [Keiko Cairo Contracts](keiko-cairo-contracts.md) - Contratos específicos para Keiko

---

**💡 Tip:** Usa `#[cfg(test)]` para código que solo debe compilar en tests y `#[inline(always)]` para funciones críticas de rendimiento.

**📝 Nota:** Para casos de uso específicos de Keiko (Proof-of-Humanity, Learning Interactions), consulta el documento [keiko-cairo-contracts.md](keiko-cairo-contracts.md).

---

## 🎓 Guía para Principiantes

### **Conceptos Básicos de Cairo**

**¿Qué es Cairo?** Cairo es un lenguaje de programación diseñado específicamente para crear pruebas de conocimiento cero (zero-knowledge proofs) y contratos inteligentes en Starknet. Es más seguro y eficiente que Solidity para ciertos tipos de aplicaciones.

**¿Qué es Starknet?** Starknet es una red de capa 2 (L2) construida sobre Ethereum que usa tecnología de pruebas de conocimiento cero para hacer las transacciones más rápidas y baratas, manteniendo la seguridad de Ethereum.

**Tipos de datos importantes:**
- `felt252`: El tipo básico de Cairo, puede representar números, direcciones, o texto
- `u256`: Números enteros de 256 bits (muy grandes)
- `bool`: Verdadero o falso
- `Map<K, V>`: Como un diccionario que asocia claves con valores

**Flujo de desarrollo típico:**
1. Escribe tu contrato en Cairo
2. Compila con `scarb build`
3. Prueba con `scarb test`
4. Despliega en Starknet testnet
5. Prueba en testnet
6. Despliega en mainnet

**Mejores prácticas de seguridad:**
- Siempre valida inputs de usuario
- Verifica permisos antes de ejecutar funciones administrativas
- Usa eventos para logging y debugging
- Prueba exhaustivamente antes de desplegar
- Considera usar auditorías para contratos importantes