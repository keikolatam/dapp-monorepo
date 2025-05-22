# Keiko

**Keiko** es una red social educativa descentralizada (DApp) construida sobre **Substrate**, el framework modular para crear blockchains personalizadas en **Rust**. Su propósito es convertir el aprendizaje en capital humano verificable e interoperable en tiempo real, a través de **interacciones de aprendizaje** registradas en una cadena de bloques pública.

## ¿Qué es Keiko?

Keiko permite a cualquier individuo construir y demostrar su **Pasaporte de Aprendizaje de Vida (LifeLearningPassport)** en blockchain, mediante una sucesión de **interacciones de aprendizaje atómicas (LearningInteractions)** compatibles con el estándar [xAPI (Tin Can)](https://xapi.com/). Estos datos pueden ser enviados desde cualquier **LRS** (Learning Record Store) como [Learning Locker](https://learninglocker.net/) y almacenados mediante un **pallet personalizado** de Substrate.

El objetivo principal de Keiko es reemplazar las certificaciones tradicionales con evidencia infalsificable de aprendizaje, evaluada por múltiples actores y almacenada de forma descentralizada.

## Principios pedagógicos y políticos

Keiko se basa en cuatro pilares:

1. **Libertad económica de tutores y mentores**: Los educadores pueden monetizar sesiones individuales o grupales sin intermediarios.
2. **Democracia participativa de los educandos**: Los aprendices califican la calidad del conocimiento adquirido y de sus pares.
3. **Descentralización de la gestión de calidad**: Las comunidades regulan sus propios estándares y métodos de validación.
4. **Auto-determinación de las comunidades**: Cada red o nodo puede establecer su propia gobernanza educativa.

## ¿Por qué "Keiko" (稽古)?

El nombre **Keiko** significa "practicar para adquirir conocimiento" y también "pensar y estudiar el pasado", un concepto que refleja la idea de digitalizar y conservar la historia del aprendizaje de cada persona en una cadena de bloques, garantizando la validez y trazabilidad de ese conocimiento. Más sobre este concepto en [Lexicon Keiko – Renshinjuku](http://www.renshinjuku.nl/2012/10/lexicon-keiko/).

Además, la organización que aloja este repositorio en GitHub se llama **Keiko (稽古)**, inspirada en la filosofía del **Aikido**, donde *Keiko* es la práctica disciplinada y consciente, que busca no solo la perfección técnica, sino el crecimiento personal y la armonía entre mente y cuerpo. Esta visión del aprendizaje constante y reflexivo es fundamental para el proyecto. Más información sobre el término y su vínculo con el Aikido en [aikido-argentina.com.ar](https://aikido-argentina.com.ar/tag/keiko/).

En suma, el nombre Keiko simboliza la importancia de practicar y reflexionar sobre el aprendizaje a lo largo del tiempo, lo cual se materializa en la plataforma como un pasaporte digital de vida y aprendizaje, descentralizado e infalsificable.

## Características técnicas

- **Framework base:** [Substrate](https://substrate.io/)
- **Lenguaje:** Rust
- **Estándar de datos:** [xAPI / Tin Can API (JSON)](https://xapi.com/)
- **LRS compatible:** [Learning Locker](https://learninglocker.net/), con soporte para integración local vía Docker
- **Pallet personalizado:** `learning_interactions` para almacenar `LearningInteraction` por usuario en el mapa `LifeLearningPassport`
- **Middleware opcional:** Lectura desde LRS y envío on-chain via extrinsics

## Casos de uso

- Validación de aprendizajes no formales e informales
- Trazabilidad de conocimiento en comunidades autónomas
- Reputación educativa para economías de aprendizaje descentralizadas
- Portabilidad internacional de credenciales sin certificados físicos

## Roadmap (resumen)

- [x] Diseño del esquema JSON de interacciones xAPI
- [x] Implementación del pallet en Substrate
- [ ] Middleware para puente con Learning Locker
- [ ] Frontend para visualizar el pasaporte de aprendizaje
- [ ] Módulo de reputación y calificación entre pares
- [ ] Gobernanza educativa comunitaria

## Contribuyentes

- **Andrés Peña** — Arquitectura y desarrollo principal (Substrate, Rust, xAPI)

## Licencia

Refiérase al archivo LICENSE.md