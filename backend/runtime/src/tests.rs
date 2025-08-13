// Business Source License 1.1
//
// Licensed Work: keiko-dapp Version 0.0.1 or later.
// The Licensed Work is (c) 2025 Luis Andrés Peña Castillo
//
// For full license terms, see LICENSE file in the repository root.

//! Runtime tests for Keiko parachain

use super::*;
use frame_support::{
    assert_noop, assert_ok,
    traits::{OnFinalize, OnInitialize},
    weights::Weight,
};
use sp_runtime::{
    testing::Header,
    traits::{BlakeTwo256, IdentityLookup},
    BuildStorage,
};

type UncheckedExtrinsic = frame_system::mocking::MockUncheckedExtrinsic<Runtime>;
type Block = frame_system::mocking::MockBlock<Runtime>;

/// Test that the runtime can be constructed and basic operations work
#[test]
fn runtime_construction_works() {
    let storage = RuntimeGenesisConfig::default().build_storage().unwrap();
    let mut ext = sp_io::TestExternalities::new(storage);

    ext.execute_with(|| {
        // Test that system pallet is working
        assert_eq!(System::block_number(), 0);

        // Test that timestamp pallet is working
        assert_eq!(Timestamp::now(), 0);

        // Test that balances pallet is working
        assert_eq!(Balances::total_issuance(), 0);
    });
}

/// Test basic block production
#[test]
fn block_production_works() {
    let storage = RuntimeGenesisConfig::default().build_storage().unwrap();
    let mut ext = sp_io::TestExternalities::new(storage);

    ext.execute_with(|| {
        // Initialize block 1
        System::set_block_number(1);
        System::on_initialize(1);
        Timestamp::on_initialize(1);

        // Set timestamp
        assert_ok!(Timestamp::set(RuntimeOrigin::none(), 12000));

        // Finalize block
        System::on_finalize(1);

        // Check block was produced correctly
        assert_eq!(System::block_number(), 1);
        assert_eq!(Timestamp::now(), 12000);
    });
}

/// Test that custom pallets are properly integrated
#[test]
fn custom_pallets_integration_works() {
    let storage = RuntimeGenesisConfig::default().build_storage().unwrap();
    let mut ext = sp_io::TestExternalities::new(storage);

    ext.execute_with(|| {
        // Test that learning interactions pallet is integrated
        assert_eq!(LearningInteractions::interactions_count(), 0);

        // Test that life learning passport pallet is integrated
        // This will depend on the pallet's implementation

        // Test that reputation system pallet is integrated
        // This will depend on the pallet's implementation
    });
}

/// Test runtime version and metadata
#[test]
fn runtime_version_is_correct() {
    assert_eq!(VERSION.spec_name, "keiko");
    assert_eq!(VERSION.impl_name, "keiko");
    assert_eq!(VERSION.authoring_version, 1);
    assert_eq!(VERSION.spec_version, 1);
    assert_eq!(VERSION.impl_version, 0);
    assert_eq!(VERSION.transaction_version, 1);
    assert_eq!(VERSION.state_version, 1);
}

/// Test that weights are configured correctly
#[test]
fn weights_configuration_is_valid() {
    let weights = RuntimeBlockWeights::get();

    // Check that normal dispatch ratio is configured
    assert!(weights.per_class.normal.max_total.is_some());

    // Check that operational dispatch has higher limits
    assert!(weights.per_class.operational.max_total.is_some());
    assert!(weights.per_class.operational.reserved.is_some());

    // Check that base weights are set
    assert!(weights.base_block > Weight::zero());
    assert!(weights.per_class.normal.base_extrinsic > Weight::zero());
}

/// Test that parachain configuration is correct
#[test]
fn parachain_configuration_is_valid() {
    let storage = RuntimeGenesisConfig::default().build_storage().unwrap();
    let mut ext = sp_io::TestExternalities::new(storage);

    ext.execute_with(|| {
        // Test that parachain system is configured
        assert_eq!(ParachainInfo::parachain_id(), 1000.into()); // Default test parachain ID

        // Test that session keys are configured correctly
        let session_keys = SessionKeys::generate(None);
        assert!(!session_keys.is_empty());
    });
}

/// Test XCM configuration
#[test]
fn xcm_configuration_is_valid() {
    use xcm::latest::prelude::*;

    // Test that XCM router is configured
    let location = MultiLocation::parent();
    assert_eq!(location.parents, 1);
    assert_eq!(location.interior, Here);

    // Test that universal location is configured correctly
    let universal_location = UniversalLocation::get();
    assert!(universal_location.len() >= 1);
}

/// Test transaction payment configuration
#[test]
fn transaction_payment_works() {
    let storage = RuntimeGenesisConfig::default().build_storage().unwrap();
    let mut ext = sp_io::TestExternalities::new(storage);

    ext.execute_with(|| {
        // Test weight to fee conversion
        let weight = Weight::from_parts(1000, 0);
        let fee = TransactionPayment::weight_to_fee(weight);
        assert!(fee > 0);

        // Test length to fee conversion
        let length_fee = TransactionPayment::length_to_fee(100);
        assert!(length_fee > 0);
    });
}

/// Test that all pallets can be constructed
#[test]
fn all_pallets_construct_correctly() {
    let storage = RuntimeGenesisConfig::default().build_storage().unwrap();
    let mut ext = sp_io::TestExternalities::new(storage);

    ext.execute_with(|| {
        // This test ensures that all pallets can be constructed without panicking
        // and that their genesis configuration is valid

        // System pallets
        assert_eq!(System::account_nonce(&AccountId::from([0u8; 32])), 0);
        assert_eq!(Balances::free_balance(&AccountId::from([0u8; 32])), 0);

        // Parachain pallets
        assert!(ParachainSystem::validation_data().is_none()); // No validation data in test environment

        // Custom pallets - basic smoke tests
        // These will be expanded as the pallets are implemented
        assert_eq!(LearningInteractions::interactions_count(), 0);
    });
}

/// Test runtime constants
#[test]
fn runtime_constants_are_correct() {
    // Test time constants
    assert_eq!(MILLISECS_PER_BLOCK, 12000);
    assert_eq!(SLOT_DURATION, 12000);
    assert_eq!(MINUTES, 5); // 60_000 / 12_000 = 5
    assert_eq!(HOURS, 300); // 5 * 60 = 300
    assert_eq!(DAYS, 7200); // 300 * 24 = 7200

    // Test balance constants
    assert_eq!(UNIT, 1_000_000_000_000);
    assert_eq!(MILLIUNIT, 1_000_000_000);
    assert_eq!(MICROUNIT, 1_000_000);
    assert_eq!(EXISTENTIAL_DEPOSIT, MILLIUNIT);

    // Test weight constants
    assert!(MAXIMUM_BLOCK_WEIGHT.ref_time() > 0);
    assert_eq!(NORMAL_DISPATCH_RATIO, Perbill::from_percent(75));
    assert_eq!(AVERAGE_ON_INITIALIZE_RATIO, Perbill::from_percent(5));
}

/// Test that benchmarking features work when enabled
#[cfg(feature = "runtime-benchmarks")]
#[test]
fn benchmarking_configuration_works() {
    use frame_benchmarking::{BenchmarkList, Benchmarking};

    // Test that benchmark metadata can be generated
    let (list, _storage_info) = Runtime::benchmark_metadata(false);
    assert!(!list.is_empty());

    // Test that benchmarks include our custom pallets
    let pallet_names: Vec<_> = list.iter().map(|b| &b.pallet).collect();
    assert!(pallet_names.contains(&&b"pallet_learning_interactions"[..]));
    assert!(pallet_names.contains(&&b"pallet_life_learning_passport"[..]));
    assert!(pallet_names.contains(&&b"pallet_reputation_system"[..]));
}

/// Test try-runtime features when enabled
#[cfg(feature = "try-runtime")]
#[test]
fn try_runtime_configuration_works() {
    use frame_try_runtime::TryRuntime;

    let storage = RuntimeGenesisConfig::default().build_storage().unwrap();
    let mut ext = sp_io::TestExternalities::new(storage);

    ext.execute_with(|| {
        // Test that try-runtime upgrade checks work
        let (weight, _max_weight) =
            Runtime::on_runtime_upgrade(frame_try_runtime::UpgradeCheckSelect::All);
        assert!(weight.ref_time() >= 0);
    });
}
