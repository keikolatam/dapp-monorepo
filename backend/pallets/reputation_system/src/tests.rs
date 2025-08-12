// Business Source License 1.1
// 
// Licensed Work: keiko-dapp Version 0.0.1 or later.
// The Licensed Work is (c) 2025 Luis Andrés Peña Castillo
// 
// For full license terms, see LICENSE file in the repository root.

use crate::{mock::*, Error, Event};
use frame_support::{assert_noop, assert_ok, traits::Get};

#[test]
fn it_works_for_default_value() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);
		assert_ok!(ReputationSystem::do_something(RuntimeOrigin::signed(1), 42));
		assert_eq!(ReputationSystem::something(), Some(42));
		System::assert_last_event(Event::SomethingStored { something: 42, who: 1 }.into());
	});
}