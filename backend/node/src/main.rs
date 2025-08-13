// Business Source License 1.1
//
// Licensed Work: keiko-dapp Version 0.0.1 or later.
// The Licensed Work is (c) 2025 Luis Andrés Peña Castillo
//
// For full license terms, see LICENSE file in the repository root.

//! Keiko parachain node implementation.

#![warn(missing_docs)]

mod chain_spec;
mod cli;
mod command;
mod rpc;
mod service;

fn main() -> sc_cli::Result<()> {
    command::run()
}
