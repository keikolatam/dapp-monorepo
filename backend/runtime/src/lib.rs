// Business Source License 1.1
// 
// Licensed Work: keiko-dapp Version 0.0.1 or later.
// The Licensed Work is (c) 2025 Luis Andrés Peña Castillo
// 
// For full license terms, see LICENSE file in the repository root.

#![cfg_attr(not(feature = "std"), no_std)]
// `construct_runtime!` does a lot of recursion and requires us to increase the limit to 256.
#![recursion_limit = "256"]

// Make the WASM binary available.
#[cfg(feature = "std")]
include!(concat!(env!("OUT_DIR"), "/wasm_binary.rs"));

use smallvec::smallvec;
use sp_api::impl_runtime_apis;
use sp_core::{crypto::KeyTypeId, OpaqueMetadata};
use sp_runtime::{
	create_runtime_str, generic, impl_opaque_keys,
	traits::{
		AccountIdLookup, BlakeTwo256, Block as BlockT, IdentifyAccount, Verify, IdentityLookup,
	},
	transaction_validity::{TransactionSource, TransactionValidity},
	ApplyExtrinsicResult, MultiSignature,
};

use sp_std::prelude::*;
#[cfg(feature = "std")]
use sp_version::NativeVersion;
use sp_version::RuntimeVersion;

use frame_executive::Executive;
use frame_support::{
	construct_runtime,
	dispatch::DispatchClass,
	parameter_types,
	traits::{ConstU128, ConstU32, ConstU64, ConstU8, Everything, Nothing},
	weights::{
		constants::WEIGHT_REF_TIME_PER_SECOND, ConstantMultiplier, Weight, WeightToFeeCoefficient,
		WeightToFeeCoefficients, WeightToFeePolynomial,
	},
	PalletId,
};
use frame_system::{
	limits::{BlockLength, BlockWeights},
	EnsureRoot,
};
pub use sp_consensus_aura::sr25519::AuthorityId as AuraId;
pub use sp_runtime::{MultiAddress, Perbill, Permill};

#[cfg(any(feature = "std", test))]
pub use sp_runtime::BuildStorage;

// Polkadot imports
use polkadot_runtime_common::{BlockHashCount, SlowAdjustingFeeUpdate};

use xcm_config::{XcmConfig, XcmOriginToTransactDispatchOrigin};

// XCM Imports
use staging_xcm::latest::prelude::BodyId;
use staging_xcm_executor::XcmExecutor;

/// Alias to 512-bit hash when used in the context of a transaction signature on the chain.
pub type Signature = MultiSignature;

/// Some way of identifying an account on the chain. We intentionally make it equivalent
/// to the public key of our transaction signing scheme.
pub type AccountId = <<Signature as Verify>::Signer as IdentifyAccount>::AccountId;

/// Balance of an account.
pub type Balance = u128;

/// Index of a transaction in the chain.
pub type Index = u32;

/// A hash of some data used by the chain.
pub type Hash = sp_core::H256;

/// An index to a block.
pub type BlockNumber = u32;

/// The address format for describing accounts.
pub type Address = MultiAddress<AccountId, ()>;

/// Block header type as expected by this runtime.
pub type Header = generic::Header<BlockNumber, BlakeTwo256>;

/// Block type as expected by this runtime.
pub type Block = generic::Block<Header, UncheckedExtrinsic>;

/// A Block signed with a Justification
pub type SignedBlock = generic::SignedBlock<Block>;

/// BlockId type as expected by this runtime.
pub type BlockId = generic::BlockId<Block>;

/// The SignedExtension to the basic transaction logic.
pub type SignedExtra = (
	frame_system::CheckNonZeroSender<Runtime>,
	frame_system::CheckSpecVersion<Runtime>,
	frame_system::CheckTxVersion<Runtime>,
	frame_system::CheckGenesis<Runtime>,
	frame_system::CheckEra<Runtime>,
	frame_system::CheckNonce<Runtime>,
	frame_system::CheckWeight<Runtime>,
	pallet_transaction_payment::ChargeTransactionPayment<Runtime>,
);

/// Unchecked extrinsic type as expected by this runtime.
pub type UncheckedExtrinsic =
	generic::UncheckedExtrinsic<Address, RuntimeCall, Signature, SignedExtra>;

/// Extrinsic type that has already been checked.
pub type CheckedExtrinsic = generic::CheckedExtrinsic<AccountId, RuntimeCall, SignedExtra>;

/// Executive: handles dispatch to the various modules.
pub type Executive = frame_executive::Executive<
	Runtime,
	Block,
	frame_system::ChainContext<Runtime>,
	Runtime,
	AllPalletsWithSystem,
>;

/// Handles converting a weight scalar to a fee value, based on the scale and granularity of the
/// node's balance type.
///
/// This should typically create a mapping between the following ranges:
///   - `[0, MAXIMUM_BLOCK_WEIGHT]`
///   - `[Balance::min, Balance::max]`
///
/// Yet, it can be used for any other sort of change to weight-fee. Some examples being:
///   - Setting it to `0` will essentially disable the weight fee.
///   - Setting it to `1` will cause the literal `#[weight = x]` values to be charged.
pub struct WeightToFee;
impl WeightToFeePolynomial for WeightToFee {
	type Balance = Balance;
	fn polynomial() -> WeightToFeeCoefficients<Self::Balance> {
		// in Rococo, extrinsic base weight (smallest non-zero weight) is mapped to 1 MILLIUNIT:
		// in our template, we map to 1/10 of that, or 1/10 MILLIUNIT
		let p = MILLIUNIT / 10;
		let q = 100 * Balance::from(ExtrinsicBaseWeight::get().ref_time());
		smallvec![WeightToFeeCoefficient {
			degree: 1,
			negative: false,
			coeff_frac: Perbill::from_rational(p % q, q),
			coeff_integer: p / q,
		}]
	}
}

/// Opaque types. These are used by the CLI to instantiate machinery that don't need to know
/// the specifics of the runtime. They can then be made to be agnostic over specific formats
/// of data like extrinsics, allowing for them to continue syncing the network through upgrades
/// to even the core data structures.
pub mod opaque {
	use super::*;
	use sp_runtime::{generic, traits::BlakeTwo256};

	pub use sp_runtime::OpaqueExtrinsic as UncheckedExtrinsic;
	/// Opaque block header type.
	pub type Header = generic::Header<BlockNumber, BlakeTwo256>;
	/// Opaque block type.
	pub type Block = generic::Block<Header, UncheckedExtrinsic>;
	/// Opaque block identifier type.
	pub type BlockId = generic::BlockId<Block>;
}

impl_opaque_keys! {
	pub struct SessionKeys {
		pub aura: Aura,
	}
}

#[sp_version::runtime_version]
pub const VERSION: RuntimeVersion = RuntimeVersion {
	spec_name: create_runtime_str!("keiko"),
	impl_name: create_runtime_str!("keiko"),
	authoring_version: 1,
	spec_version: 1,
	impl_version: 0,
	apis: RUNTIME_API_VERSIONS,
	transaction_version: 1,
	state_version: 1,
};

/// This determines the average expected block time that we are targeting.
/// Blocks will be produced at a minimum duration defined by `SLOT_DURATION`.
/// `SLOT_DURATION` is picked up by `pallet_timestamp` which is in turn picked
/// up by `pallet_aura` to implement `fn slot_duration()`.
///
/// Change this to adjust the block time.
pub const MILLISECS_PER_BLOCK: u64 = 12000;

// NOTE: Currently it is not possible to change the slot duration after the chain has started.
//       Attempting to do so will brick block production.
pub const SLOT_DURATION: u64 = MILLISECS_PER_BLOCK;

// Time is measured by number of blocks.
pub const MINUTES: BlockNumber = 60_000 / (MILLISECS_PER_BLOCK as BlockNumber);
pub const HOURS: BlockNumber = MINUTES * 60;
pub const DAYS: BlockNumber = HOURS * 24;

// Unit = the base number of indivisible units for balances
pub const UNIT: Balance = 1_000_000_000_000;
pub const MILLIUNIT: Balance = 1_000_000_000;
pub const MICROUNIT: Balance = 1_000_000;

/// The existential deposit. Set to 1/10 of the Connected Relay Chain.
pub const EXISTENTIAL_DEPOSIT: Balance = MILLIUNIT;

/// We assume that ~5% of the block weight is consumed by `on_initialize` handlers. This is
/// used to limit the maximal weight of a single extrinsic.
const AVERAGE_ON_INITIALIZE_RATIO: Perbill = Perbill::from_percent(5);

/// We allow `Normal` extrinsics to fill up the block up to 75%, the rest can be used by
/// `Operational` extrinsics.
const NORMAL_DISPATCH_RATIO: Perbill = Perbill::from_percent(75);

/// We allow for 0.5 of a second of compute with a 12 second average block time.
const MAXIMUM_BLOCK_WEIGHT: Weight = Weight::from_parts(
	WEIGHT_REF_TIME_PER_SECOND.saturating_div(2),
	cumulus_primitives_core::relay_chain::MAX_POV_SIZE as u64,
);

/// Safe XCM version for genesis configuration
const SAFE_XCM_VERSION: u32 = xcm::prelude::XCM_VERSION;

/// The version information used to identify this runtime when compiled natively.
#[cfg(feature = "std")]
pub fn native_version() -> NativeVersion {
	NativeVersion { runtime_version: VERSION, can_author_with: Default::default() }
}

parameter_types! {
	pub const Version: RuntimeVersion = VERSION;

	// This part is copied from Substrate's `bin/node/runtime/src/lib.rs`.
	//  The `RuntimeBlockLength` and `RuntimeBlockWeights` exist here because the
	// `DeletionWeightLimit` and `DeletionQueueDepth` depend on those to parameterize
	// the lazy contract deletion.
	pub RuntimeBlockLength: BlockLength =
		BlockLength::max_with_normal_ratio(5 * 1024 * 1024, NORMAL_DISPATCH_RATIO);
	pub RuntimeBlockWeights: BlockWeights = BlockWeights::builder()
		.base_block(BlockExecutionWeight::get())
		.for_class(DispatchClass::all(), |weights| {
			weights.base_extrinsic = ExtrinsicBaseWeight::get();
		})
		.for_class(DispatchClass::Normal, |weights| {
			weights.max_total = Some(NORMAL_DISPATCH_RATIO * MAXIMUM_BLOCK_WEIGHT);
		})
		.for_class(DispatchClass::Operational, |weights| {
			weights.max_total = Some(MAXIMUM_BLOCK_WEIGHT);
			// Operational transactions have some extra reserved space, so that they
			// are included even if block reached `MAXIMUM_BLOCK_WEIGHT`.
			weights.reserved = Some(
				MAXIMUM_BLOCK_WEIGHT - NORMAL_DISPATCH_RATIO * MAXIMUM_BLOCK_WEIGHT
			);
		})
		.avg_block_initialization(AVERAGE_ON_INITIALIZE_RATIO)
		.build_or_panic();
	pub const SS58Prefix: u16 = 42;
}

// Configure FRAME pallets to include in runtime.

impl frame_system::Config for Runtime {
	/// The identifier used to distinguish between accounts.
	type AccountId = AccountId;
	/// The aggregated dispatch type that is available for extrinsics.
	type RuntimeCall = RuntimeCall;
	/// The lookup mechanism to get account ID from whatever is passed in dispatchers.
	type Lookup = AccountIdLookup<AccountId, ()>;
	/// The index type for storing how many extrinsics an account has signed.
	type Index = Index;
	/// The index type for blocks.
	type BlockNumber = BlockNumber;
	/// The type for hashing blocks and tries.
	type Hash = Hash;
	/// The hashing algorithm used.
	type Hashing = BlakeTwo256;
	/// The header type.
	type Header = Header;
	/// The ubiquitous event type.
	type RuntimeEvent = RuntimeEvent;
	/// The ubiquitous origin type.
	type RuntimeOrigin = RuntimeOrigin;
	/// Maximum number of block number to block hash mappings to keep (oldest pruned first).
	type BlockHashCount = BlockHashCount;
	/// Runtime version.
	type Version = Version;
	/// Converts a module to an index of this module in the runtime.
	type PalletInfo = PalletInfo;
	/// The data to be stored in an account.
	type AccountData = pallet_balances::AccountData<Balance>;
	/// What to do if a new account is created.
	type OnNewAccount = ();
	/// What to do if an account is fully reaped from the system.
	type OnKilledAccount = ();
	/// The weight of database operations that the runtime can invoke.
	type DbWeight = RocksDbWeight;
	/// The basic call filter to use in dispatchable.
	type BaseCallFilter = Everything;
	/// Weight information for the extrinsics of this pallet.
	type SystemWeightInfo = ();
	/// Block & extrinsics weights: base values and limits.
	type BlockWeights = RuntimeBlockWeights;
	/// The maximum length of a block (in bytes).
	type BlockLength = RuntimeBlockLength;
	/// This is used as an identifier of the chain. 42 is the generic substrate prefix.
	type SS58Prefix = SS58Prefix;
	/// The action to take on a Runtime Upgrade
	type OnSetCode = cumulus_pallet_parachain_system::ParachainSetCode<Self>;
	type MaxConsumers = ConstU32<16>;
}

parameter_types! {
	pub const MinimumPeriod: u64 = SLOT_DURATION / 2;
}

impl pallet_timestamp::Config for Runtime {
	/// A timestamp: milliseconds since the unix epoch.
	type Moment = u64;
	type OnTimestampSet = Aura;
	type MinimumPeriod = MinimumPeriod;
	type WeightInfo = ();
}

parameter_types! {
	pub const ExistentialDeposit: Balance = EXISTENTIAL_DEPOSIT;
}

impl pallet_balances::Config for Runtime {
	type MaxLocks = ConstU32<50>;
	/// The type for recording an account's balance.
	type Balance = Balance;
	/// The ubiquitous event type.
	type RuntimeEvent = RuntimeEvent;
	type DustRemoval = ();
	type ExistentialDeposit = ExistentialDeposit;
	type AccountStore = System;
	type WeightInfo = pallet_balances::weights::SubstrateWeight<Runtime>;
	type MaxReserves = ConstU32<50>;
	type ReserveIdentifier = [u8; 8];
	type HoldIdentifier = ();
	type FreezeIdentifier = ();
	type MaxHolds = ConstU32<0>;
	type MaxFreezes = ConstU32<0>;
}

parameter_types! {
	/// Relay Chain `TransactionByteFee` / 10
	pub const TransactionByteFee: Balance = 10 * MICROUNIT;
	pub const OperationalFeeMultiplier: u8 = 5;
}

impl pallet_transaction_payment::Config for Runtime {
	type RuntimeEvent = RuntimeEvent;
	type OnChargeTransaction = pallet_transaction_payment::CurrencyAdapter<Balances, ()>;
	type WeightToFee = WeightToFee;
	type LengthToFee = ConstantMultiplier<Balance, TransactionByteFee>;
	type FeeMultiplierUpdate = SlowAdjustingFeeUpdate<Self>;
	type OperationalFeeMultiplier = OperationalFeeMultiplier;
}

impl pallet_authorship::Config for Runtime {
	type FindAuthor = pallet_session::FindAccountFromAuthorIndex<Self, Aura>;
	type EventHandler = (CollatorSelection,);
}

parameter_types! {
	pub const SessionPeriod: u32 = 6 * HOURS;
	pub const SessionOffset: u32 = 0;
}

impl pallet_session::Config for Runtime {
	type RuntimeEvent = RuntimeEvent;
	type ValidatorId = <Self as frame_system::Config>::AccountId;
	// we don't have stash and controller, thus we don't need the convert as well.
	type ValidatorIdOf = pallet_collator_selection::IdentityCollator;
	type ShouldEndSession = pallet_session::PeriodicSessions<SessionPeriod, SessionOffset>;
	type NextSessionRotation = pallet_session::PeriodicSessions<SessionPeriod, SessionOffset>;
	type SessionManager = CollatorSelection;
	// Essentially just Aura, but let's be pedantic.
	type SessionHandler = <SessionKeys as sp_runtime::traits::OpaqueKeys>::KeyTypeIdProviders;
	type Keys = SessionKeys;
	type WeightInfo = ();
}

impl pallet_aura::Config for Runtime {
	type AuthorityId = AuraId;
	type DisabledValidators = ();
	type MaxAuthorities = ConstU32<100_000>;
}

parameter_types! {
	pub const PotId: PalletId = PalletId(*b"PotStake");
	pub const MaxCandidates: u32 = 1000;
	pub const MinCandidates: u32 = 5;
	pub const SessionLength: BlockNumber = 6 * HOURS;
	pub const MaxInvulnerables: u32 = 100;
	pub const ExecutiveBody: BodyId = BodyId::Executive;
}

// We allow root only to execute privileged collator selection operations.
pub type CollatorSelectionUpdateOrigin = EnsureRoot<AccountId>;

impl pallet_collator_selection::Config for Runtime {
	type RuntimeEvent = RuntimeEvent;
	type Currency = Balances;
	type UpdateOrigin = CollatorSelectionUpdateOrigin;
	type PotId = PotId;
	type MaxCandidates = MaxCandidates;
	type MinEligibleCollators = MinCandidates;
	type MaxInvulnerables = MaxInvulnerables;
	// should be a multiple of session or things will get inconsistent
	type KickThreshold = SessionPeriod;
	type ValidatorId = <Self as frame_system::Config>::AccountId;
	type ValidatorIdOf = pallet_collator_selection::IdentityCollator;
	type ValidatorRegistration = Session;
	type WeightInfo = ();
}

impl pallet_sudo::Config for Runtime {
	type RuntimeEvent = RuntimeEvent;
	type RuntimeCall = RuntimeCall;
}

parameter_types! {
	pub const ReservedXcmpWeight: Weight = MAXIMUM_BLOCK_WEIGHT.saturating_div(4);
	pub const ReservedDmpWeight: Weight = MAXIMUM_BLOCK_WEIGHT.saturating_div(4);
}

impl cumulus_pallet_parachain_system::Config for Runtime {
	type RuntimeEvent = RuntimeEvent;
	type OnSystemEvent = ();
	type SelfParaId = staging_parachain_info::Pallet<Runtime>;
	type OutboundXcmpMessageSource = XcmpQueue;
	type DmpMessageHandler = DmpQueue;
	type ReservedDmpWeight = ReservedDmpWeight;
	type XcmpMessageHandler = XcmpQueue;
	type ReservedXcmpWeight = ReservedXcmpWeight;
	type CheckAssociatedRelayNumber = cumulus_pallet_parachain_system::RelayNumberStrictlyIncreases;
}

impl staging_parachain_info::Config for Runtime {}

impl cumulus_pallet_aura_ext::Config for Runtime {}

impl cumulus_pallet_xcmp_queue::Config for Runtime {
	type RuntimeEvent = RuntimeEvent;
	type XcmExecutor = XcmExecutor<XcmConfig>;
	type ChannelInfo = ParachainSystem;
	type VersionWrapper = PolkadotXcm;
	type ExecuteOverweightOrigin = EnsureRoot<AccountId>;
	type ControllerOrigin = EnsureRoot<AccountId>;
	type ControllerOriginConverter = XcmOriginToTransactDispatchOrigin;
	type WeightInfo = ();
	type PriceForSiblingDelivery = polkadot_runtime_common::xcm_sender::NoPriceForSiblingDelivery<ParaId>;
}

impl cumulus_pallet_dmp_queue::Config for Runtime {
	type RuntimeEvent = RuntimeEvent;
	type XcmExecutor = XcmExecutor<XcmConfig>;
	type ExecuteOverweightOrigin = EnsureRoot<AccountId>;
}

parameter_types! {
	pub const Period: u32 = 6 * HOURS;
	pub const Offset: u32 = 0;
}

impl pallet_xcm::Config for Runtime {
	type RuntimeEvent = RuntimeEvent;
	type SendXcmOrigin = xcm_builder::EnsureXcmOrigin<RuntimeOrigin, LocalOriginToLocation>;
	type XcmRouter = XcmRouter;
	type ExecuteXcmOrigin = xcm_builder::EnsureXcmOrigin<RuntimeOrigin, LocalOriginToLocation>;
	type XcmExecuteFilter = Nothing;
	type XcmExecutor = XcmExecutor<XcmConfig>;
	type XcmTeleportFilter = Everything;
	type XcmReserveTransferFilter = Nothing;
	type Weigher = xcm_builder::FixedWeightBounds<UnitWeightCost, RuntimeCall, MaxInstructions>;
	type UniversalLocation = UniversalLocation;
	type RuntimeOrigin = RuntimeOrigin;
	type RuntimeCall = RuntimeCall;
	const VERSION_DISCOVERY_QUEUE_SIZE: u32 = 100;
	type AdvertisedXcmVersion = pallet_xcm::CurrentXcmVersion;
	type Currency = Balances;
	type CurrencyMatcher = ();
	type TrustedLockers = ();
	type SovereignAccountOf = LocationToAccountId;
	type MaxLockers = ConstU32<8>;
	type WeightInfo = pallet_xcm::weights::SubstrateWeight<Runtime>;
	#[cfg(feature = "runtime-benchmarks")]
	type ReachableDest = ReachableDest;
	type AdminOrigin = EnsureRoot<AccountId>;
	type MaxRemoteLockConsumers = ConstU32<0>;
	type RemoteLockConsumerIdentifier = ();
}

impl cumulus_pallet_xcm::Config for Runtime {
	type RuntimeEvent = RuntimeEvent;
	type XcmExecutor = XcmExecutor<XcmConfig>;
}

// Create the runtime by composing the FRAME pallets that were previously configured.
construct_runtime!(
	pub enum Runtime where
		Block = Block,
		NodeBlock = opaque::Block,
		UncheckedExtrinsic = UncheckedExtrinsic,
	{
		// System support stuff.
		System: frame_system::{Pallet, Call, Config, Storage, Event<T>} = 0,
		ParachainSystem: cumulus_pallet_parachain_system::{
			Pallet, Call, Config, Storage, Inherent, Event<T>, ValidateUnsigned,
		} = 1,
		Timestamp: pallet_timestamp::{Pallet, Call, Storage, Inherent} = 2,
		ParachainInfo: staging_parachain_info::{Pallet, Storage, Config} = 3,

		// Monetary stuff.
		Balances: pallet_balances::{Pallet, Call, Storage, Config<T>, Event<T>} = 10,
		TransactionPayment: pallet_transaction_payment::{Pallet, Storage, Event<T>} = 11,

		// Authorship and session.
		Authorship: pallet_authorship::{Pallet, Storage} = 20,
		CollatorSelection: pallet_collator_selection::{Pallet, Call, Storage, Event<T>, Config<T>} = 21,
		Session: pallet_session::{Pallet, Call, Storage, Event, Config<T>} = 22,
		Aura: pallet_aura::{Pallet, Storage, Config<T>} = 23,
		AuraExt: cumulus_pallet_aura_ext::{Pallet, Storage, Config} = 24,

		// XCM helpers.
		XcmpQueue: cumulus_pallet_xcmp_queue::{Pallet, Call, Storage, Event<T>} = 30,
		PolkadotXcm: pallet_xcm::{Pallet, Call, Event<T>, Origin, Config} = 31,
		CumulusXcm: cumulus_pallet_xcm::{Pallet, Event<T>, Origin} = 32,
		DmpQueue: cumulus_pallet_dmp_queue::{Pallet, Call, Storage, Event<T>} = 33,

		// Handy utilities.
		Sudo: pallet_sudo::{Pallet, Call, Config<T>, Storage, Event<T>} = 40,

		// Keiko custom pallets.
		LearningInteractions: pallet_learning_interactions::{Pallet, Call, Storage, Event<T>} = 50,
		LifeLearningPassport: pallet_life_learning_passport::{Pallet, Call, Storage, Event<T>} = 51,
		ReputationSystem: pallet_reputation_system::{Pallet, Call, Storage, Event<T>} = 52,
	}
);

#[cfg(feature = "runtime-benchmarks")]
#[macro_use]
extern crate frame_benchmarking;

#[cfg(feature = "runtime-benchmarks")]
mod benches {
	define_benchmarks!(
		[frame_system, SystemBench::<Runtime>]
		[pallet_balances, Balances]
		[pallet_session, SessionBench::<Runtime>]
		[pallet_timestamp, Timestamp]
		[pallet_collator_selection, CollatorSelection]
		[cumulus_pallet_xcmp_queue, XcmpQueue]
		[pallet_learning_interactions, LearningInteractions]
		[pallet_life_learning_passport, LifeLearningPassport]
		[pallet_reputation_system, ReputationSystem]
	);
}

impl_runtime_apis! {
	impl sp_consensus_aura::AuraApi<Block, AuraId> for Runtime {
		fn slot_duration() -> sp_consensus_aura::SlotDuration {
			sp_consensus_aura::SlotDuration::from_millis(Aura::slot_duration())
		}

		fn authorities() -> Vec<AuraId> {
			Aura::authorities().into_inner()
		}
	}

	impl sp_api::Core<Block> for Runtime {
		fn version() -> RuntimeVersion {
			VERSION
		}

		fn execute_block(block: Block) {
			Executive::execute_block(block)
		}

		fn initialize_block(header: &<Block as BlockT>::Header) {
			Executive::initialize_block(header)
		}
	}

	impl sp_api::Metadata<Block> for Runtime {
		fn metadata() -> OpaqueMetadata {
			OpaqueMetadata::new(Runtime::metadata().into())
		}

		fn metadata_at_version(version: u32) -> Option<OpaqueMetadata> {
			Runtime::metadata_at_version(version)
		}

		fn metadata_versions() -> sp_std::vec::Vec<u32> {
			Runtime::metadata_versions()
		}
	}

	impl sp_block_builder::BlockBuilder<Block> for Runtime {
		fn apply_extrinsic(extrinsic: <Block as BlockT>::Extrinsic) -> ApplyExtrinsicResult {
			Executive::apply_extrinsic(extrinsic)
		}

		fn finalize_block() -> <Block as BlockT>::Header {
			Executive::finalize_block()
		}

		fn inherent_extrinsics(data: sp_inherents::InherentData) -> Vec<<Block as BlockT>::Extrinsic> {
			data.create_extrinsics()
		}

		fn check_inherents(
			block: Block,
			data: sp_inherents::InherentData,
		) -> sp_inherents::CheckInherentsResult {
			data.check_extrinsics(&block)
		}
	}

	impl sp_transaction_pool::runtime_api::TaggedTransactionQueue<Block> for Runtime {
		fn validate_transaction(
			source: TransactionSource,
			tx: <Block as BlockT>::Extrinsic,
			block_hash: <Block as BlockT>::Hash,
		) -> TransactionValidity {
			Executive::validate_transaction(source, tx, block_hash)
		}
	}

	impl sp_offchain::OffchainWorkerApi<Block> for Runtime {
		fn offchain_worker(header: &<Block as BlockT>::Header) {
			Executive::offchain_worker(header)
		}
	}

	impl sp_session::SessionKeys<Block> for Runtime {
		fn generate_session_keys(seed: Option<Vec<u8>>) -> Vec<u8> {
			SessionKeys::generate(seed)
		}

		fn decode_session_keys(
			encoded: Vec<u8>,
		) -> Option<Vec<(Vec<u8>, KeyTypeId)>> {
			SessionKeys::decode_into_raw_public_keys(&encoded)
		}
	}

	impl frame_system_rpc_runtime_api::AccountNonceApi<Block, AccountId, Index> for Runtime {
		fn account_nonce(account: AccountId) -> Index {
			System::account_nonce(account)
		}
	}

	impl pallet_transaction_payment_rpc_runtime_api::TransactionPaymentApi<Block, Balance> for Runtime {
		fn query_info(
			uxt: <Block as BlockT>::Extrinsic,
			len: u32,
		) -> pallet_transaction_payment_rpc_runtime_api::RuntimeDispatchInfo<Balance> {
			TransactionPayment::query_info(uxt, len)
		}
		fn query_fee_details(
			uxt: <Block as BlockT>::Extrinsic,
			len: u32,
		) -> pallet_transaction_payment::FeeDetails<Balance> {
			TransactionPayment::query_fee_details(uxt, len)
		}
		fn query_weight_to_fee(weight: Weight) -> Balance {
			TransactionPayment::weight_to_fee(weight)
		}
		fn query_length_to_fee(length: u32) -> Balance {
			TransactionPayment::length_to_fee(length)
		}
	}

	impl cumulus_primitives_core::CollectCollationInfo<Block> for Runtime {
		fn collect_collation_info(header: &<Block as BlockT>::Header) -> cumulus_primitives_core::CollationInfo {
			ParachainSystem::collect_collation_info(header)
		}
	}

	#[cfg(feature = "try-runtime")]
	impl frame_try_runtime::TryRuntime<Block> for Runtime {
		fn on_runtime_upgrade(checks: frame_try_runtime::UpgradeCheckSelect) -> (Weight, Weight) {
			// NOTE: intentional unwrap: we don't want to propagate the error backwards, and want to
			// have a backtrace here. If any of the pre/post migration checks fail, we shall stop
			// right here and right now.
			let weight = Executive::try_runtime_upgrade(checks).unwrap();
			(weight, RuntimeBlockWeights::get().max_block)
		}

		fn execute_block(
			block: Block,
			state_root_check: bool,
			signature_check: bool,
			select: frame_try_runtime::TryStateSelect
		) -> Weight {
			// NOTE: intentional unwrap: we don't want to propagate the error backwards, and want to
			// have a backtrace here.
			Executive::try_execute_block(block, state_root_check, signature_check, select).expect("execute-block failed")
		}
	}

	#[cfg(feature = "runtime-benchmarks")]
	impl frame_benchmarking::Benchmark<Block> for Runtime {
		fn benchmark_metadata(extra: bool) -> (
			Vec<frame_benchmarking::BenchmarkList>,
			Vec<frame_support::traits::StorageInfo>,
		) {
			use frame_benchmarking::{baseline, Benchmarking, BenchmarkList};
			use frame_support::traits::StorageInfoTrait;
			use frame_system_benchmarking::Pallet as SystemBench;
			use cumulus_pallet_session_benchmarking::Pallet as SessionBench;

			let mut list = Vec::<BenchmarkList>::new();
			list_benchmarks!(list, extra);

			let storage_info = AllPalletsWithSystem::storage_info();

			(list, storage_info)
		}

		fn dispatch_benchmark(
			config: frame_benchmarking::BenchmarkConfig
		) -> Result<Vec<frame_benchmarking::BenchmarkBatch>, sp_runtime::RuntimeString> {
			use frame_benchmarking::{baseline, Benchmarking, BenchmarkBatch, TrackedStorageKey};

			use frame_system_benchmarking::Pallet as SystemBench;
			impl frame_system_benchmarking::Config for Runtime {}

			use cumulus_pallet_session_benchmarking::Pallet as SessionBench;
			impl cumulus_pallet_session_benchmarking::Config for Runtime {}

			use frame_support::traits::WhitelistedStorageKeys;
			let whitelist: Vec<TrackedStorageKey> = AllPalletsWithSystem::whitelisted_storage_keys();

			let mut batches = Vec::<BenchmarkBatch>::new();
			let params = (&config, &whitelist);
			add_benchmarks!(params, batches);

			Ok(batches)
		}
	}
}

struct CheckInherents;

impl cumulus_pallet_parachain_system::CheckInherents<Block> for CheckInherents {
	fn check_inherents(
		block: &Block,
		relay_state_proof: &cumulus_pallet_parachain_system::RelayChainStateProof,
	) -> sp_inherents::CheckInherentsResult {
		let relay_chain_slot = relay_state_proof
			.read_slot()
			.expect("Could not read the relay chain slot from the proof");

		let inherent_data =
			cumulus_primitives_timestamp::InherentDataProvider::from_relay_chain_slot_and_duration(
				relay_chain_slot,
				sp_std::time::Duration::from_secs(6),
			)
			.create_inherent_data()
			.expect("Could not create the timestamp inherent data");

		inherent_data.check_extrinsics(block)
	}
}

cumulus_pallet_parachain_system::register_validate_block! {
	Runtime = Runtime,
	BlockExecutor = cumulus_pallet_aura_ext::BlockExecutor::<Runtime, Executive>,
	CheckInherents = CheckInherents,
}

// XCM configuration
mod xcm_config {
	use super::*;
	use frame_support::{
		match_types, parameter_types,
		traits::{Everything, Nothing},
		weights::Weight,
	};
	use staging_xcm::latest::prelude::*;
	use staging_xcm_builder::{
		AccountId32Aliases, AllowExplicitUnpaidExecutionFrom, AllowTopLevelPaidExecutionFrom,
		CurrencyAdapter, EnsureXcmOrigin, FixedWeightBounds, IsConcrete, LocationInverter,
		NativeAsset, ParentAsSuperuser, ParentIsPreset, RelayChainAsNative, SiblingParachainAsNative,
		SiblingParachainConvertsVia, SignedAccountId32AsNative, SignedToAccountId32,
		SovereignSignedViaLocation, TakeWeightCredit, UsingComponents, WithComputedOrigin,
	};
	use staging_xcm_executor::XcmExecutor;

	parameter_types! {
		pub const RelayLocation: MultiLocation = MultiLocation::parent();
		pub const RelayNetwork: Option<NetworkId> = None;
		pub RelayChainOrigin: RuntimeOrigin = cumulus_pallet_xcm::Origin::Relay.into();
		pub UniversalLocation: InteriorMultiLocation =
			X2(GlobalConsensus(RelayNetwork::get().unwrap_or(NetworkId::Polkadot)), Parachain(ParachainInfo::parachain_id().into()));
	}

	/// Type for specifying how a `MultiLocation` can be converted into an `AccountId`. This is used
	/// when determining ownership of accounts for asset transacting and when attempting to use XCM
	/// `Transact` in order to determine the dispatch Origin.
	pub type LocationToAccountId = (
		// The parent (Relay-chain) origin converts to the parent `AccountId`.
		ParentIsPreset<AccountId>,
		// Sibling parachain origins convert to AccountId via the `ParaId::into`.
		SiblingParachainConvertsVia<polkadot_parachain_primitives::primitives::Sibling, AccountId>,
		// Straight up local `AccountId32` origins just alias directly to `AccountId`.
		AccountId32Aliases<RelayNetwork, AccountId>,
	);

	/// Means for transacting assets on this chain.
	pub type CurrencyTransactor = CurrencyAdapter<
		// Use this currency:
		Balances,
		// Use this currency when it is a fungible asset matching the given location or name:
		IsConcrete<RelayLocation>,
		// Do a simple punn to convert an AccountId32 MultiLocation into a native chain account ID:
		LocationToAccountId,
		// Our chain's account ID type (we can't get away without mentioning it explicitly):
		AccountId,
		// We don't track any teleports.
		(),
	>;

	/// This is the type we use to convert an (incoming) XCM origin into a local `Origin` instance,
	/// ready for dispatching a transaction with Xcm's `Transact`. There is an `OriginKind` which can
	/// biases the kind of local `Origin` it will become.
	pub type XcmOriginToTransactDispatchOrigin = (
		// Sovereign account converter; this attempts to derive an `AccountId` from the origin location
		// using `LocationToAccountId` and then turn that into the usual `Signed` origin. Useful for
		// foreign chains who want to have a local sovereign account on this chain which they control.
		SovereignSignedViaLocation<LocationToAccountId, RuntimeOrigin>,
		// Native converter for Relay-chain (Parent) location; will converts to a `Relay` origin when
		// recognized.
		RelayChainAsNative<RelayChainOrigin, RuntimeOrigin>,
		// Native converter for sibling Parachains; will convert to a `SiblingPara` origin when
		// recognized.
		SiblingParachainAsNative<cumulus_pallet_xcm::Origin, RuntimeOrigin>,
		// Superuser converter for the Relay-chain (Parent) location. This will allow it to issue a
		// transaction from the Root origin.
		ParentAsSuperuser<RuntimeOrigin>,
		// Native signed account converter; this just converts an `AccountId32` origin into a normal
		// `RuntimeOrigin::Signed` origin of the same 32-byte value.
		SignedAccountId32AsNative<RelayNetwork, RuntimeOrigin>,
		// Xcm origins can be represented natively under the Xcm pallet's Xcm origin.
		XcmPassthrough<RuntimeOrigin>,
	);

	parameter_types! {
		// One XCM operation is 1_000_000_000 weight - almost certainly a conservative estimate.
		pub UnitWeightCost: Weight = Weight::from_parts(1_000_000_000, 64 * 1024);
		pub const MaxInstructions: u32 = 100;
		pub const MaxAssetsIntoHolding: u32 = 64;
	}

	match_types! {
		pub type ParentOrParentsExecutivePlurality: impl Contains<MultiLocation> = {
			MultiLocation { parents: 1, interior: Here } |
			MultiLocation { parents: 1, interior: X1(Plurality { id: BodyId::Executive, .. }) }
		};
	}

	//TODO: move DenyThenTry to polkadot's xcm module.
	/// Deny executing the xcm message if it matches any of the Deny filter regardless of anything else.
	/// If it passes the Deny, and matches one of the Allow cases then it is let through.
	pub struct DenyThenTry<Deny, Allow>(sp_std::marker::PhantomData<Deny>, sp_std::marker::PhantomData<Allow>)
	where
		Deny: ShouldExecute,
		Allow: ShouldExecute;

	impl<Deny, Allow> ShouldExecute for DenyThenTry<Deny, Allow>
	where
		Deny: ShouldExecute,
		Allow: ShouldExecute,
	{
		fn should_execute<RuntimeCall>(
			origin: &MultiLocation,
			message: &mut [Instruction<RuntimeCall>],
			max_weight: Weight,
			weight_credit: &mut Weight,
		) -> Result<(), ProcessMessageError> {
			Deny::should_execute(origin, message, max_weight, weight_credit)?;
			Allow::should_execute(origin, message, max_weight, weight_credit)
		}
	}

	// See issue #5233
	pub struct DenyReserveTransferToRelayChain;
	impl ShouldExecute for DenyReserveTransferToRelayChain {
		fn should_execute<RuntimeCall>(
			origin: &MultiLocation,
			message: &mut [Instruction<RuntimeCall>],
			_max_weight: Weight,
			_weight_credit: &mut Weight,
		) -> Result<(), ProcessMessageError> {
			if message.iter().any(|inst| {
				matches!(
					inst,
					InitiateReserveWithdraw {
						reserve: MultiLocation { parents: 1, interior: Here }, ..
					} |
					DepositReserveAsset {
						dest: MultiLocation { parents: 1, interior: Here }, ..
					} |
					TransferReserveAsset {
						dest: MultiLocation { parents: 1, interior: Here }, ..
					}
				)
			}) {
				return Err(ProcessMessageError::Yield)
			}

			// Permit everything else
			Ok(())
		}
	}

	pub type Barrier = DenyThenTry<
		DenyReserveTransferToRelayChain,
		(
			TakeWeightCredit,
			WithComputedOrigin<
				(
					AllowTopLevelPaidExecutionFrom<Everything>,
					AllowExplicitUnpaidExecutionFrom<ParentOrParentsExecutivePlurality>,
					// ^^^ Parent and its exec plurality get free execution
				),
				UniversalLocation,
				ConstU32<8>,
			>,
		),
	>;

	pub struct XcmConfig;
	impl staging_xcm_executor::Config for XcmConfig {
		type RuntimeCall = RuntimeCall;
		type XcmSender = XcmRouter;
		// How to withdraw and deposit an asset.
		type AssetTransactor = CurrencyTransactor;
		type OriginConverter = XcmOriginToTransactDispatchOrigin;
		type IsReserve = NativeAsset;
		type IsTeleporter = (); // Teleporting is disabled.
		type UniversalLocation = UniversalLocation;
		type Barrier = Barrier;
		type Weigher = FixedWeightBounds<UnitWeightCost, RuntimeCall, MaxInstructions>;
		type Trader =
			UsingComponents<WeightToFee, RelayLocation, AccountId, Balances, ToStakingPot<Runtime>>;
		type ResponseHandler = PolkadotXcm;
		type AssetTrap = PolkadotXcm;
		type AssetClaims = PolkadotXcm;
		type SubscriptionService = PolkadotXcm;
		type PalletInstancesInfo = AllPalletsWithSystem;
		type MaxAssetsIntoHolding = MaxAssetsIntoHolding;
		type AssetLocker = ();
		type AssetExchanger = ();
		type FeeManager = ();
		type MessageExporter = ();
		type UniversalAliases = Nothing;
		type CallDispatcher = RuntimeCall;
		type SafeCallFilter = Everything;
		type Aliasers = Nothing;
	}

	/// No local origins on this chain are allowed to dispatch XCM sends/executions.
	pub type LocalOriginToLocation = SignedToAccountId32<RuntimeOrigin, AccountId, RelayNetwork>;

	/// The means for routing XCM messages which are not for local execution into the right message
	/// queues.
	pub type XcmRouter = WithUniqueTopic<(
		// Two routers - use UMP to communicate with the relay chain:
		cumulus_primitives_utility::ParentAsUmp<ParachainSystem, (), ()>,
		// ..and XCMP to communicate with the sibling chains.
		XcmpQueue,
	)>;

	#[cfg(feature = "runtime-benchmarks")]
	parameter_types! {
		pub ReachableDest: Option<MultiLocation> = Some(Parent.into());
	}

	impl pallet_xcm::Config for Runtime {
		type RuntimeEvent = RuntimeEvent;
		type SendXcmOrigin = EnsureXcmOrigin<RuntimeOrigin, LocalOriginToLocation>;
		type XcmRouter = XcmRouter;
		type ExecuteXcmOrigin = EnsureXcmOrigin<RuntimeOrigin, LocalOriginToLocation>;
		type XcmExecuteFilter = Nothing;
		type XcmExecutor = XcmExecutor<XcmConfig>;
		type XcmTeleportFilter = Everything;
		type XcmReserveTransferFilter = Nothing;
		type Weigher = FixedWeightBounds<UnitWeightCost, RuntimeCall, MaxInstructions>;
		type UniversalLocation = UniversalLocation;
		type RuntimeOrigin = RuntimeOrigin;
		type RuntimeCall = RuntimeCall;

		const VERSION_DISCOVERY_QUEUE_SIZE: u32 = 100;
		// ^ Override for AdvertisedXcmVersion default
		type AdvertisedXcmVersion = pallet_xcm::CurrentXcmVersion;
		type Currency = Balances;
		type CurrencyMatcher = ();
		type TrustedLockers = ();
		type SovereignAccountOf = LocationToAccountId;
		type MaxLockers = ConstU32<8>;
		type WeightInfo = pallet_xcm::weights::SubstrateWeight<Runtime>;
		#[cfg(feature = "runtime-benchmarks")]
		type ReachableDest = ReachableDest;
		type AdminOrigin = EnsureRoot<AccountId>;
		type MaxRemoteLockConsumers = ConstU32<0>;
		type RemoteLockConsumerIdentifier = ();
	}

	use frame_support::traits::tokens::ConversionToAssetBalance;
	use xcm_builder::WithUniqueTopic;

	pub struct ToStakingPot<R>(sp_std::marker::PhantomData<R>);
	impl<R> ConversionToAssetBalance<Balance, MultiLocation, Balance> for ToStakingPot<R>
	where
		R: pallet_balances::Config<Balance = Balance>,
		R::AccountId: Into<AccountId> + From<AccountId>,
	{
		type Error = ();
		fn to_asset_balance(balance: Balance, _asset_location: MultiLocation) -> Result<Balance, ()> {
			Ok(balance)
		}
	}
}

use xcm_config::*;

/// Runtime genesis configuration
#[derive(Default)]
pub struct RuntimeGenesisConfig {
	pub system: frame_system::GenesisConfig,
	pub balances: pallet_balances::GenesisConfig<Runtime>,
	pub parachain_info: parachain_info::GenesisConfig,
	pub collator_selection: pallet_collator_selection::GenesisConfig<Runtime>,
	pub session: pallet_session::GenesisConfig<Runtime>,
	pub aura: pallet_aura::GenesisConfig<Runtime>,
	pub parachain_system: cumulus_pallet_parachain_system::GenesisConfig,
	pub polkadot_xcm: pallet_xcm::GenesisConfig<Runtime>,
}

impl BuildStorage for RuntimeGenesisConfig {
	fn build_storage(&self) -> Result<sp_runtime::Storage, String> {
		let mut storage = frame_system::GenesisConfig::default().build_storage::<Runtime>()?;
		
		// Initialize balances
		pallet_balances::GenesisConfig::<Runtime> {
			balances: vec![],
		}.assimilate_storage(&mut storage)?;
		
		// Initialize parachain info
		staging_parachain_info::GenesisConfig {
			parachain_id: 1000.into(), // Default test parachain ID
		}.assimilate_storage(&mut storage)?;
		
		// Initialize collator selection
		pallet_collator_selection::GenesisConfig::<Runtime> {
			invulnerables: vec![],
			candidacy_bond: EXISTENTIAL_DEPOSIT * 16,
			..Default::default()
		}.assimilate_storage(&mut storage)?;
		
		// Initialize session
		pallet_session::GenesisConfig::<Runtime> {
			keys: vec![],
		}.assimilate_storage(&mut storage)?;
		
		// Initialize aura
		pallet_aura::GenesisConfig::<Runtime> {
			authorities: vec![],
		}.assimilate_storage(&mut storage)?;
		
		// Initialize parachain system
		cumulus_pallet_parachain_system::GenesisConfig::default()
			.assimilate_storage(&mut storage)?;
		
		// Initialize XCM
		pallet_xcm::GenesisConfig::<Runtime> {
			safe_xcm_version: Some(SAFE_XCM_VERSION),
		}.assimilate_storage(&mut storage)?;
		
		Ok(storage)
	}
}

#[cfg(test)]
mod tests;