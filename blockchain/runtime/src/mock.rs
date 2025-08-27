// Business Source License 1.1
// 
// Licensed Work: keiko-dapp Version 0.0.1 or later.
// The Licensed Work is (c) 2025 Luis Andrés Peña Castillo
// 
// For full license terms, see LICENSE file in the repository root.

//! Test utilities for the Keiko runtime.

use super::*;
use frame_support::traits::{OnFinalize, OnInitialize};
use sp_io::TestExternalities;
use sp_runtime::BuildStorage;

/// Build new test externalities.
pub fn new_test_ext() -> TestExternalities {
	let t = frame_system::GenesisConfig::<Runtime>::default().build_storage().unwrap();
	let mut ext = TestExternalities::new(t);
	ext.execute_with(|| System::set_block_number(1));
	ext
}

/// Run to block
pub fn run_to_block(n: BlockNumber) {
	while System::block_number() < n {
		if System::block_number() > 1 {
			System::on_finalize(System::block_number());
		}
		System::set_block_number(System::block_number() + 1);
		System::on_initialize(System::block_number());
		Timestamp::on_initialize(System::block_number());
	}
}
