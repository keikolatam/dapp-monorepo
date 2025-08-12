// Business Source License 1.1
// 
// Licensed Work: keiko-dapp Version 0.0.1 or later.
// The Licensed Work is (c) 2025 Luis Andrés Peña Castillo
// 
// For full license terms, see LICENSE file in the repository root.

//! Benchmarking setup for pallet-reputation-system

use super::*;

#[allow(unused)]
use crate::Pallet as ReputationSystem;
use frame_benchmarking::v2::*;
use frame_system::RawOrigin;

#[benchmarks]
mod benchmarks {
	use super::*;

	#[benchmark]
	fn create_rating() {
		let rater: T::AccountId = whitelisted_caller();
		let rated: T::AccountId = account("rated", 0, 0);
		let comment = vec![b'a'; T::MaxCommentLength::get() as usize];

		#[extrinsic_call]
		_(RawOrigin::Signed(rater), rated, 5u8, comment, None);

		assert_eq!(NextRatingId::<T>::get(), 2);
	}

	#[benchmark]
	fn update_rating() {
		let rater: T::AccountId = whitelisted_caller();
		let rated: T::AccountId = account("rated", 0, 0);
		let comment = vec![b'a'; 100];

		// Create a rating first
		assert!(ReputationSystem::<T>::create_rating(
			RawOrigin::Signed(rater.clone()).into(),
			rated,
			3u8,
			comment.clone(),
			None
		).is_ok());

		let new_comment = vec![b'b'; T::MaxCommentLength::get() as usize];

		#[extrinsic_call]
		_(RawOrigin::Signed(rater), 1u64, 5u8, Some(new_comment));

		assert!(Ratings::<T>::get(1).is_some());
	}

	impl_benchmark_test_suite!(ReputationSystem, crate::mock::new_test_ext(), crate::mock::Test);
}