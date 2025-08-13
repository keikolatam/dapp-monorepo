// Business Source License 1.1
// 
// Licensed Work: keiko-dapp Version 0.0.1 or later.
// The Licensed Work is (c) 2025 Luis Andrés Peña Castillo
// 
// For full license terms, see LICENSE file in the repository root.

#![cfg_attr(not(feature = "std"), no_std)]

/// Life learning passport pallet for Keiko parachain.
/// Manages user learning passports and profiles.
pub use pallet::*;

#[cfg(test)]
mod mock;

#[cfg(test)]
mod tests;

#[cfg(feature = "runtime-benchmarks")]
mod benchmarking;

use codec::{Decode, Encode};
use scale_info::TypeInfo;
use sp_std::{vec::Vec, collections::btree_map::BTreeMap};

/// Unique identifier for learning interactions (imported from learning_interactions pallet)
pub type InteractionId = u64;

/// Privacy settings for passport data
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub struct PrivacySettings {
	/// Whether the passport is publicly visible
	pub public_visibility: bool,
	/// Whether interactions are visible to others
	pub interactions_visible: bool,
	/// Whether learning profile is visible
	pub profile_visible: bool,
	/// Whether achievements are visible
	pub achievements_visible: bool,
	/// List of accounts that have special access
	pub trusted_accounts: Vec<u8>, // Serialized list of AccountIds
}

impl Default for PrivacySettings {
	fn default() -> Self {
		Self {
			public_visibility: false,
			interactions_visible: false,
			profile_visible: false,
			achievements_visible: true, // Achievements are public by default
			trusted_accounts: Vec::new(),
		}
	}
}

/// Learning styles with percentage weights
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub struct LearningStyle {
	/// Visual learning preference (0-100)
	pub visual: u8,
	/// Auditory learning preference (0-100)
	pub auditory: u8,
	/// Kinesthetic learning preference (0-100)
	pub kinesthetic: u8,
	/// Reading/writing learning preference (0-100)
	pub reading: u8,
}

impl Default for LearningStyle {
	fn default() -> Self {
		Self {
			visual: 25,
			auditory: 25,
			kinesthetic: 25,
			reading: 25,
		}
	}
}

/// Learning preferences
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub struct LearningPreferences {
	/// Preferred learning pace
	pub pace_preference: PacePreference,
	/// Preferred interaction style
	pub interaction_style: InteractionStyle,
	/// Preferred feedback frequency
	pub feedback_frequency: FeedbackFrequency,
	/// Preferred difficulty progression
	pub difficulty_progression: DifficultyProgression,
}

impl Default for LearningPreferences {
	fn default() -> Self {
		Self {
			pace_preference: PacePreference::Moderate,
			interaction_style: InteractionStyle::Mixed,
			feedback_frequency: FeedbackFrequency::Periodic,
			difficulty_progression: DifficultyProgression::Gradual,
		}
	}
}

/// Pace preferences
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub enum PacePreference {
	Slow,
	Moderate,
	Fast,
}

/// Interaction style preferences
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub enum InteractionStyle {
	Collaborative,
	Independent,
	Mixed,
}

/// Feedback frequency preferences
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub enum FeedbackFrequency {
	Immediate,
	Periodic,
	Final,
}

/// Difficulty progression preferences
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub enum DifficultyProgression {
	Gradual,
	Moderate,
	Challenging,
}

/// Skill representation
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub struct Skill {
	/// Skill domain (e.g., "mathematics", "programming")
	pub domain: Vec<u8>,
	/// Skill level (0-100)
	pub level: u8,
	/// Confidence level (0-100)
	pub confidence: u8,
	/// Last time this skill was updated
	pub last_updated: u64,
}

/// Adaptive action record
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub struct AdaptiveAction {
	/// When the action was taken
	pub timestamp: u64,
	/// What triggered the adaptive action
	pub trigger: Vec<u8>,
	/// What action was taken
	pub action: Vec<u8>,
	/// How effective the action was (0-100)
	pub effectiveness: u8,
}

/// Learning profile containing pedagogical assessment results
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub struct LearningProfile {
	/// Learning style preferences
	pub learning_style: LearningStyle,
	/// General learning preferences
	pub preferences: LearningPreferences,
	/// Areas of strength
	pub strengths: Vec<Skill>,
	/// Areas for improvement
	pub areas_for_improvement: Vec<Skill>,
	/// Timestamp of last pedagogical assessment
	pub last_assessment: u64,
	/// Assessment version/type used
	pub assessment_version: Vec<u8>,
	/// History of adaptive actions taken
	pub adaptive_history: Vec<AdaptiveAction>,
	/// Whether profile updates automatically based on interactions
	pub auto_update_enabled: bool,
}

impl Default for LearningProfile {
	fn default() -> Self {
		Self {
			learning_style: LearningStyle::default(),
			preferences: LearningPreferences::default(),
			strengths: Vec::new(),
			areas_for_improvement: Vec::new(),
			last_assessment: 0,
			assessment_version: b"initial".to_vec(),
			adaptive_history: Vec::new(),
			auto_update_enabled: true,
		}
	}
}

/// Main Life Learning Passport structure
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub struct LifeLearningPassport<AccountId> {
	/// Owner of the passport
	pub owner: AccountId,
	/// List of learning interaction IDs
	pub interactions: Vec<InteractionId>,
	/// Optional learning profile from pedagogical assessment
	pub learning_profile: Option<LearningProfile>,
	/// Privacy settings for this passport
	pub privacy_settings: PrivacySettings,
	/// Creation timestamp
	pub created_at: u64,
	/// Last update timestamp
	pub updated_at: u64,
	/// Passport version for future upgrades
	pub version: u32,
}

/// Shareable passport link with permissions and expiration
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub struct ShareableLink {
	/// Unique link identifier
	pub link_id: Vec<u8>,
	/// Owner of the passport being shared
	pub passport_owner: Vec<u8>, // Serialized AccountId
	/// What data can be accessed through this link
	pub permissions: SharePermissions,
	/// Link expiration timestamp
	pub expires_at: u64,
	/// Creation timestamp
	pub created_at: u64,
	/// Whether the link is still active
	pub active: bool,
}

/// Permissions for shared passport links
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub struct SharePermissions {
	/// Can view basic passport info
	pub view_basic: bool,
	/// Can view learning interactions
	pub view_interactions: bool,
	/// Can view learning profile
	pub view_profile: bool,
	/// Can view achievements
	pub view_achievements: bool,
	/// Can verify authenticity
	pub verify_authenticity: bool,
}

impl Default for SharePermissions {
	fn default() -> Self {
		Self {
			view_basic: true,
			view_interactions: false,
			view_profile: false,
			view_achievements: true,
			verify_authenticity: true,
		}
	}
}

#[frame_support::pallet]
pub mod pallet {
	use super::*;
	use frame_support::{pallet_prelude::*, traits::StorageVersion};
	use frame_system::pallet_prelude::*;

	#[pallet::pallet]
	#[pallet::storage_version(STORAGE_VERSION)]
	pub struct Pallet<T>(_);

	const STORAGE_VERSION: StorageVersion = StorageVersion::new(1);

	/// Configure the pallet by specifying the parameters and types on which it depends.
	#[pallet::config]
	pub trait Config: frame_system::Config {
		/// The overarching event type.
		type RuntimeEvent: From<Event<Self>> + IsType<<Self as frame_system::Config>::RuntimeEvent>;
		
		/// Maximum number of interactions per passport
		#[pallet::constant]
		type MaxInteractionsPerPassport: Get<u32>;
		
		/// Maximum number of skills in profile
		#[pallet::constant]
		type MaxSkillsPerProfile: Get<u32>;
		
		/// Maximum length for text fields
		#[pallet::constant]
		type MaxTextLength: Get<u32>;
		
		/// Default link expiration time in blocks (7 days)
		#[pallet::constant]
		type DefaultLinkExpiration: Get<u64>;
	}

	/// Storage for life learning passports
	#[pallet::storage]
	#[pallet::getter(fn passports)]
	pub type Passports<T: Config> = StorageMap<
		_,
		Blake2_128Concat,
		T::AccountId,
		LifeLearningPassport<T::AccountId>,
		OptionQuery,
	>;

	/// Storage for shareable links
	#[pallet::storage]
	#[pallet::getter(fn shareable_links)]
	pub type ShareableLinks<T: Config> = StorageMap<
		_,
		Blake2_128Concat,
		Vec<u8>, // link_id
		ShareableLink,
		OptionQuery,
	>;

	/// Events emitted by the pallet
	#[pallet::event]
	#[pallet::generate_deposit(pub(super) fn deposit_event)]
	pub enum Event<T: Config> {
		/// A new passport was created. [owner]
		PassportCreated { owner: T::AccountId },
		
		/// A passport was updated. [owner]
		PassportUpdated { owner: T::AccountId },
		
		/// An interaction was added to a passport. [owner, interaction_id]
		InteractionAdded { owner: T::AccountId, interaction_id: InteractionId },
		
		/// Learning profile was updated. [owner]
		LearningProfileUpdated { owner: T::AccountId },
		
		/// Privacy settings were updated. [owner]
		PrivacySettingsUpdated { owner: T::AccountId },
		
		/// A shareable link was created. [owner, link_id, expires_at]
		ShareableLinkCreated { owner: T::AccountId, link_id: Vec<u8>, expires_at: u64 },
		
		/// A shareable link was revoked. [owner, link_id]
		ShareableLinkRevoked { owner: T::AccountId, link_id: Vec<u8> },
	}

	/// Errors that can occur when using the pallet
	#[pallet::error]
	pub enum Error<T> {
		/// Passport already exists for this account
		PassportAlreadyExists,
		/// Passport does not exist for this account
		PassportNotFound,
		/// Too many interactions in passport
		TooManyInteractions,
		/// Too many skills in profile
		TooManySkills,
		/// Text field too long
		TextTooLong,
		/// Shareable link not found
		ShareableLinkNotFound,
		/// Shareable link has expired
		ShareableLinkExpired,
		/// Not authorized to access this passport
		NotAuthorized,
		/// Invalid learning style percentages (must sum to 100)
		InvalidLearningStyle,
		/// Invalid skill level (must be 0-100)
		InvalidSkillLevel,
	}

	/// Dispatchable functions (extrinsics) of the pallet
	#[pallet::call]
	impl<T: Config> Pallet<T> {
		/// Create a new life learning passport
		#[pallet::call_index(0)]
		#[pallet::weight(10_000 + T::DbWeight::get().writes(1).ref_time())]
		pub fn create_passport(origin: OriginFor<T>) -> DispatchResult {
			let who = ensure_signed(origin)?;
			
			// Ensure passport doesn't already exist
			ensure!(!Passports::<T>::contains_key(&who), Error::<T>::PassportAlreadyExists);
			
			let now = Self::current_timestamp();
			
			let passport = LifeLearningPassport {
				owner: who.clone(),
				interactions: Vec::new(),
				learning_profile: None,
				privacy_settings: PrivacySettings::default(),
				created_at: now,
				updated_at: now,
				version: 1,
			};
			
			Passports::<T>::insert(&who, passport);
			
			Self::deposit_event(Event::PassportCreated { owner: who });
			
			Ok(())
		}
		
		/// Update privacy settings for a passport
		#[pallet::call_index(1)]
		#[pallet::weight(10_000 + T::DbWeight::get().writes(1).ref_time())]
		pub fn update_privacy_settings(
			origin: OriginFor<T>,
			privacy_settings: PrivacySettings,
		) -> DispatchResult {
			let who = ensure_signed(origin)?;
			
			Passports::<T>::try_mutate(&who, |passport_opt| -> DispatchResult {
				let passport = passport_opt.as_mut().ok_or(Error::<T>::PassportNotFound)?;
				
				passport.privacy_settings = privacy_settings;
				passport.updated_at = Self::current_timestamp();
				
				Ok(())
			})?;
			
			Self::deposit_event(Event::PrivacySettingsUpdated { owner: who });
			
			Ok(())
		}
		
		/// Add a learning interaction to the passport
		#[pallet::call_index(2)]
		#[pallet::weight(10_000 + T::DbWeight::get().writes(1).ref_time())]
		pub fn add_interaction(
			origin: OriginFor<T>,
			interaction_id: InteractionId,
		) -> DispatchResult {
			let who = ensure_signed(origin)?;
			
			Passports::<T>::try_mutate(&who, |passport_opt| -> DispatchResult {
				let passport = passport_opt.as_mut().ok_or(Error::<T>::PassportNotFound)?;
				
				// Check if we're at the limit
				ensure!(
					passport.interactions.len() < T::MaxInteractionsPerPassport::get() as usize,
					Error::<T>::TooManyInteractions
				);
				
				// Add interaction if not already present
				if !passport.interactions.contains(&interaction_id) {
					passport.interactions.push(interaction_id);
					passport.updated_at = Self::current_timestamp();
				}
				
				Ok(())
			})?;
			
			Self::deposit_event(Event::InteractionAdded { owner: who, interaction_id });
			
			Ok(())
		}
		
		/// Update learning profile from pedagogical assessment
		#[pallet::call_index(3)]
		#[pallet::weight(10_000 + T::DbWeight::get().writes(1).ref_time())]
		pub fn update_learning_profile(
			origin: OriginFor<T>,
			learning_profile: LearningProfile,
		) -> DispatchResult {
			let who = ensure_signed(origin)?;
			
			// Validate learning style percentages sum to 100
			let total_style = learning_profile.learning_style.visual as u32 +
				learning_profile.learning_style.auditory as u32 +
				learning_profile.learning_style.kinesthetic as u32 +
				learning_profile.learning_style.reading as u32;
			ensure!(total_style == 100, Error::<T>::InvalidLearningStyle);
			
			// Validate skill levels are within range
			for skill in &learning_profile.strengths {
				ensure!(skill.level <= 100, Error::<T>::InvalidSkillLevel);
				ensure!(skill.confidence <= 100, Error::<T>::InvalidSkillLevel);
			}
			for skill in &learning_profile.areas_for_improvement {
				ensure!(skill.level <= 100, Error::<T>::InvalidSkillLevel);
				ensure!(skill.confidence <= 100, Error::<T>::InvalidSkillLevel);
			}
			
			// Check skills limits
			ensure!(
				learning_profile.strengths.len() <= T::MaxSkillsPerProfile::get() as usize,
				Error::<T>::TooManySkills
			);
			ensure!(
				learning_profile.areas_for_improvement.len() <= T::MaxSkillsPerProfile::get() as usize,
				Error::<T>::TooManySkills
			);
			
			Passports::<T>::try_mutate(&who, |passport_opt| -> DispatchResult {
				let passport = passport_opt.as_mut().ok_or(Error::<T>::PassportNotFound)?;
				
				passport.learning_profile = Some(learning_profile);
				passport.updated_at = Self::current_timestamp();
				
				Ok(())
			})?;
			
			Self::deposit_event(Event::LearningProfileUpdated { owner: who });
			
			Ok(())
		}
		
		/// Create a shareable link for the passport
		#[pallet::call_index(4)]
		#[pallet::weight(10_000 + T::DbWeight::get().writes(1).ref_time())]
		pub fn create_shareable_link(
			origin: OriginFor<T>,
			permissions: SharePermissions,
			expires_in_blocks: Option<u64>,
		) -> DispatchResult {
			let who = ensure_signed(origin)?;
			
			// Ensure passport exists
			ensure!(Passports::<T>::contains_key(&who), Error::<T>::PassportNotFound);
			
			let now = Self::current_timestamp();
			let expires_at = now + expires_in_blocks.unwrap_or(T::DefaultLinkExpiration::get());
			
			// Generate unique link ID using account + timestamp + nonce
			let link_id = Self::generate_link_id(&who, now);
			
			// Serialize account ID for storage
			let passport_owner = who.encode();
			
			let shareable_link = ShareableLink {
				link_id: link_id.clone(),
				passport_owner,
				permissions,
				expires_at,
				created_at: now,
				active: true,
			};
			
			ShareableLinks::<T>::insert(&link_id, shareable_link);
			
			Self::deposit_event(Event::ShareableLinkCreated { 
				owner: who, 
				link_id, 
				expires_at 
			});
			
			Ok(())
		}
		
		/// Revoke a shareable link
		#[pallet::call_index(5)]
		#[pallet::weight(10_000 + T::DbWeight::get().writes(1).ref_time())]
		pub fn revoke_shareable_link(
			origin: OriginFor<T>,
			link_id: Vec<u8>,
		) -> DispatchResult {
			let who = ensure_signed(origin)?;
			
			ShareableLinks::<T>::try_mutate(&link_id, |link_opt| -> DispatchResult {
				let link = link_opt.as_mut().ok_or(Error::<T>::ShareableLinkNotFound)?;
				
				// Decode owner from stored data
				let owner = T::AccountId::decode(&mut &link.passport_owner[..])
					.map_err(|_| Error::<T>::NotAuthorized)?;
				
				// Only the owner can revoke their links
				ensure!(who == owner, Error::<T>::NotAuthorized);
				
				link.active = false;
				
				Ok(())
			})?;
			
			Self::deposit_event(Event::ShareableLinkRevoked { owner: who, link_id });
			
			Ok(())
		}
		
		/// Update a specific skill in the learning profile
		#[pallet::call_index(6)]
		#[pallet::weight(10_000 + T::DbWeight::get().writes(1).ref_time())]
		pub fn update_skill(
			origin: OriginFor<T>,
			domain: Vec<u8>,
			level: u8,
			confidence: u8,
			is_strength: bool,
		) -> DispatchResult {
			let who = ensure_signed(origin)?;
			
			// Validate skill parameters
			ensure!(level <= 100, Error::<T>::InvalidSkillLevel);
			ensure!(confidence <= 100, Error::<T>::InvalidSkillLevel);
			ensure!(domain.len() <= T::MaxTextLength::get() as usize, Error::<T>::TextTooLong);
			
			Passports::<T>::try_mutate(&who, |passport_opt| -> DispatchResult {
				let passport = passport_opt.as_mut().ok_or(Error::<T>::PassportNotFound)?;
				
				// Initialize profile if it doesn't exist
				if passport.learning_profile.is_none() {
					passport.learning_profile = Some(LearningProfile::default());
				}
				
				let profile = passport.learning_profile.as_mut().unwrap();
				let now = Self::current_timestamp();
				
				let new_skill = Skill {
					domain: domain.clone(),
					level,
					confidence,
					last_updated: now,
				};
				
				// Update or add skill in the appropriate list
				let target_list = if is_strength {
					&mut profile.strengths
				} else {
					&mut profile.areas_for_improvement
				};
				
				// Find existing skill or add new one
				if let Some(existing_skill) = target_list.iter_mut().find(|s| s.domain == domain) {
					*existing_skill = new_skill;
				} else {
					// Check limits before adding
					ensure!(
						target_list.len() < T::MaxSkillsPerProfile::get() as usize,
						Error::<T>::TooManySkills
					);
					target_list.push(new_skill);
				}
				
				passport.updated_at = now;
				
				Ok(())
			})?;
			
			Self::deposit_event(Event::LearningProfileUpdated { owner: who });
			
			Ok(())
		}
		
		/// Toggle automatic profile updates based on interactions
		#[pallet::call_index(7)]
		#[pallet::weight(10_000 + T::DbWeight::get().writes(1).ref_time())]
		pub fn toggle_auto_update(
			origin: OriginFor<T>,
			enabled: bool,
		) -> DispatchResult {
			let who = ensure_signed(origin)?;
			
			Passports::<T>::try_mutate(&who, |passport_opt| -> DispatchResult {
				let passport = passport_opt.as_mut().ok_or(Error::<T>::PassportNotFound)?;
				
				// Initialize profile if it doesn't exist
				if passport.learning_profile.is_none() {
					passport.learning_profile = Some(LearningProfile::default());
				}
				
				let profile = passport.learning_profile.as_mut().unwrap();
				profile.auto_update_enabled = enabled;
				passport.updated_at = Self::current_timestamp();
				
				Ok(())
			})?;
			
			Self::deposit_event(Event::LearningProfileUpdated { owner: who });
			
			Ok(())
		}
		
		/// Record an adaptive action taken for a user
		#[pallet::call_index(8)]
		#[pallet::weight(10_000 + T::DbWeight::get().writes(1).ref_time())]
		pub fn record_adaptive_action(
			origin: OriginFor<T>,
			user: T::AccountId,
			trigger: Vec<u8>,
			action: Vec<u8>,
			effectiveness: u8,
		) -> DispatchResult {
			let _who = ensure_signed(origin)?; // Could add authorization check here
			
			// Validate parameters
			ensure!(effectiveness <= 100, Error::<T>::InvalidSkillLevel);
			ensure!(trigger.len() <= T::MaxTextLength::get() as usize, Error::<T>::TextTooLong);
			ensure!(action.len() <= T::MaxTextLength::get() as usize, Error::<T>::TextTooLong);
			
			Passports::<T>::try_mutate(&user, |passport_opt| -> DispatchResult {
				let passport = passport_opt.as_mut().ok_or(Error::<T>::PassportNotFound)?;
				
				// Initialize profile if it doesn't exist
				if passport.learning_profile.is_none() {
					passport.learning_profile = Some(LearningProfile::default());
				}
				
				let profile = passport.learning_profile.as_mut().unwrap();
				let now = Self::current_timestamp();
				
				let adaptive_action = AdaptiveAction {
					timestamp: now,
					trigger,
					action,
					effectiveness,
				};
				
				profile.adaptive_history.push(adaptive_action);
				
				// Keep only recent adaptive actions (last 100)
				if profile.adaptive_history.len() > 100 {
					profile.adaptive_history.remove(0);
				}
				
				passport.updated_at = now;
				
				Ok(())
			})?;
			
			Self::deposit_event(Event::LearningProfileUpdated { owner: user });
			
			Ok(())
		}
	}
	
	/// Helper functions and queries
	impl<T: Config> Pallet<T> {
		/// Get current timestamp (placeholder - should be implemented based on runtime)
		fn current_timestamp() -> u64 {
			// This should be replaced with actual timestamp from runtime
			// For now, using block number as a simple timestamp
			<frame_system::Pallet<T>>::block_number().saturated_into::<u64>()
		}
		
		/// Get passport data for a user (respects privacy settings)
		pub fn get_passport_data(
			owner: &T::AccountId,
			requester: Option<&T::AccountId>,
		) -> Option<LifeLearningPassport<T::AccountId>> {
			if let Some(passport) = Self::passports(owner) {
				// If requester is the owner, return full data
				if let Some(req) = requester {
					if req == owner {
						return Some(passport);
					}
				}
				
				// Apply privacy filters for external requests
				let mut filtered_passport = passport.clone();
				
				if !passport.privacy_settings.public_visibility {
					// If not publicly visible, only return basic info
					filtered_passport.interactions = Vec::new();
					filtered_passport.learning_profile = None;
				} else {
					// Apply granular privacy settings
					if !passport.privacy_settings.interactions_visible {
						filtered_passport.interactions = Vec::new();
					}
					
					if !passport.privacy_settings.profile_visible {
						filtered_passport.learning_profile = None;
					}
				}
				
				Some(filtered_passport)
			} else {
				None
			}
		}
		
		/// Get learning profile for a user (respects privacy)
		pub fn get_learning_profile(
			owner: &T::AccountId,
			requester: Option<&T::AccountId>,
		) -> Option<LearningProfile> {
			if let Some(passport) = Self::passports(owner) {
				// Owner can always access their own profile
				if let Some(req) = requester {
					if req == owner {
						return passport.learning_profile;
					}
				}
				
				// Check privacy settings for external access
				if passport.privacy_settings.public_visibility && 
				   passport.privacy_settings.profile_visible {
					return passport.learning_profile;
				}
			}
			
			None
		}
		
		/// Get interaction IDs for a user (respects privacy)
		pub fn get_user_interactions(
			owner: &T::AccountId,
			requester: Option<&T::AccountId>,
		) -> Vec<InteractionId> {
			if let Some(passport) = Self::passports(owner) {
				// Owner can always access their own interactions
				if let Some(req) = requester {
					if req == owner {
						return passport.interactions;
					}
				}
				
				// Check privacy settings for external access
				if passport.privacy_settings.public_visibility && 
				   passport.privacy_settings.interactions_visible {
					return passport.interactions;
				}
			}
			
			Vec::new()
		}
		
		/// Check if a user has a passport
		pub fn has_passport(owner: &T::AccountId) -> bool {
			Passports::<T>::contains_key(owner)
		}
		
		/// Get passport creation timestamp
		pub fn get_passport_creation_time(owner: &T::AccountId) -> Option<u64> {
			Self::passports(owner).map(|p| p.created_at)
		}
		
		/// Get passport last update timestamp
		pub fn get_passport_last_update(owner: &T::AccountId) -> Option<u64> {
			Self::passports(owner).map(|p| p.updated_at)
		}
		
		/// Get passport version
		pub fn get_passport_version(owner: &T::AccountId) -> Option<u32> {
			Self::passports(owner).map(|p| p.version)
		}
		
		/// Check if a user's passport is publicly visible
		pub fn is_passport_public(owner: &T::AccountId) -> bool {
			Self::passports(owner)
				.map(|p| p.privacy_settings.public_visibility)
				.unwrap_or(false)
		}
		
		/// Get privacy settings for a passport
		pub fn get_privacy_settings(owner: &T::AccountId) -> Option<PrivacySettings> {
			Self::passports(owner).map(|p| p.privacy_settings)
		}
		
		/// Get total number of interactions for a user
		pub fn get_interaction_count(owner: &T::AccountId) -> u32 {
			Self::passports(owner)
				.map(|p| p.interactions.len() as u32)
				.unwrap_or(0)
		}
		
		/// Generate a unique link ID
		fn generate_link_id(owner: &T::AccountId, timestamp: u64) -> Vec<u8> {
			use sp_runtime::traits::{BlakeTwo256, Hash};
			
			// Create a unique identifier by hashing account + timestamp + block number
			let mut data = Vec::new();
			data.extend_from_slice(&owner.encode());
			data.extend_from_slice(&timestamp.to_le_bytes());
			data.extend_from_slice(&<frame_system::Pallet<T>>::block_number().encode());
			
			BlakeTwo256::hash(&data).encode()
		}
		
		/// Check if a shareable link is valid and active
		pub fn is_link_valid(link_id: &[u8]) -> bool {
			if let Some(link) = Self::shareable_links(link_id) {
				let now = Self::current_timestamp();
				link.active && now <= link.expires_at
			} else {
				false
			}
		}
		
		/// Get link permissions if valid
		pub fn get_link_permissions(link_id: &[u8]) -> Option<SharePermissions> {
			if Self::is_link_valid(link_id) {
				Self::shareable_links(link_id).map(|link| link.permissions)
			} else {
				None
			}
		}
		
		/// Get passport data through shareable link
		pub fn get_passport_via_link(
			link_id: &[u8],
		) -> Result<LifeLearningPassport<T::AccountId>, Error<T>> {
			let link = Self::shareable_links(link_id).ok_or(Error::<T>::ShareableLinkNotFound)?;
			
			// Check if link is active
			if !link.active {
				return Err(Error::<T>::ShareableLinkNotFound);
			}
			
			// Check if link has expired
			let now = Self::current_timestamp();
			if now > link.expires_at {
				return Err(Error::<T>::ShareableLinkExpired);
			}
			
			// Decode owner
			let owner = T::AccountId::decode(&mut &link.passport_owner[..])
				.map_err(|_| Error::<T>::PassportNotFound)?;
			
			// Get passport
			let passport = Self::passports(&owner).ok_or(Error::<T>::PassportNotFound)?;
			
			// Apply permissions filter
			let mut filtered_passport = passport.clone();
			
			if !link.permissions.view_interactions {
				filtered_passport.interactions = Vec::new();
			}
			
			if !link.permissions.view_profile {
				filtered_passport.learning_profile = None;
			}
			
			// Note: achievements filtering would be implemented when achievements are added
			
			Ok(filtered_passport)
		}
		
		/// Verify the authenticity of passport data
		pub fn verify_passport_authenticity(
			owner: &T::AccountId,
			passport_data: &LifeLearningPassport<T::AccountId>,
		) -> bool {
			// Get the actual passport from storage
			if let Some(stored_passport) = Self::passports(owner) {
				// Verify basic fields match
				stored_passport.owner == passport_data.owner &&
				stored_passport.created_at == passport_data.created_at &&
				stored_passport.version == passport_data.version
				// Additional cryptographic verification could be added here
			} else {
				false
			}
		}
		
		/// Get active shareable links for a user
		pub fn get_user_shareable_links(owner: &T::AccountId) -> Vec<(Vec<u8>, ShareableLink)> {
			let mut user_links = Vec::new();
			let now = Self::current_timestamp();
			
			// This is not efficient for production - would need a reverse index
			// For now, this is a placeholder implementation
			for (link_id, link) in ShareableLinks::<T>::iter() {
				if let Ok(link_owner) = T::AccountId::decode(&mut &link.passport_owner[..]) {
					if link_owner == *owner && link.active && now <= link.expires_at {
						user_links.push((link_id, link));
					}
				}
			}
			
			user_links
		}
		
		/// Clean up expired links (should be called periodically)
		pub fn cleanup_expired_links() -> u32 {
			let now = Self::current_timestamp();
			let mut cleaned_count = 0u32;
			
			// Remove expired links
			ShareableLinks::<T>::translate(|_key, mut link: ShareableLink| {
				if now > link.expires_at {
					cleaned_count += 1;
					None // Remove the entry
				} else {
					Some(link)
				}
			});
			
			cleaned_count
		}
		
		/// Update learning profile based on interaction patterns (automatic)
		pub fn update_profile_from_interaction(
			owner: &T::AccountId,
			interaction_category: &[u8], // From learning_interactions pallet
			success_rate: Option<u8>, // 0-100 if available
			difficulty_level: Option<u8>, // 0-100 if available
		) -> DispatchResult {
			Passports::<T>::try_mutate(owner, |passport_opt| -> DispatchResult {
				let passport = passport_opt.as_mut().ok_or(Error::<T>::PassportNotFound)?;
				
				// Only update if auto-update is enabled
				if let Some(ref mut profile) = passport.learning_profile {
					if !profile.auto_update_enabled {
						return Ok(());
					}
					
					let now = Self::current_timestamp();
					
					// Simple heuristic-based updates
					// In a real implementation, this would use more sophisticated ML algorithms
					
					// Update skills based on interaction category
					let domain = interaction_category.to_vec();
					
					// Find or create skill
					let mut skill_updated = false;
					for skill in &mut profile.strengths {
						if skill.domain == domain {
							// Improve skill based on success rate
							if let Some(success) = success_rate {
								if success >= 80 {
									skill.level = (skill.level + 1).min(100);
									skill.confidence = (skill.confidence + 1).min(100);
								}
							}
							skill.last_updated = now;
							skill_updated = true;
							break;
						}
					}
					
					// If not found in strengths, check areas for improvement
					if !skill_updated {
						for skill in &mut profile.areas_for_improvement {
							if skill.domain == domain {
								// Improve skill based on success rate
								if let Some(success) = success_rate {
									if success >= 70 {
										skill.level = (skill.level + 1).min(100);
										skill.confidence = (skill.confidence + 1).min(100);
									}
								}
								skill.last_updated = now;
								skill_updated = true;
								break;
							}
						}
					}
					
					// If skill not found anywhere, add to areas for improvement
					if !skill_updated && profile.areas_for_improvement.len() < T::MaxSkillsPerProfile::get() as usize {
						let initial_level = success_rate.unwrap_or(50);
						profile.areas_for_improvement.push(Skill {
							domain,
							level: initial_level,
							confidence: initial_level,
							last_updated: now,
						});
					}
					
					passport.updated_at = now;
				}
				
				Ok(())
			})
		}
		
		/// Get learning recommendations based on profile
		pub fn get_learning_recommendations(
			owner: &T::AccountId,
		) -> Vec<Vec<u8>> {
			if let Some(passport) = Self::passports(owner) {
				if let Some(profile) = passport.learning_profile {
					let mut recommendations = Vec::new();
					
					// Recommend working on areas for improvement
					for skill in &profile.areas_for_improvement {
						if skill.level < 70 {
							recommendations.push(skill.domain.clone());
						}
					}
					
					// Recommend advanced topics for strengths
					for skill in &profile.strengths {
						if skill.level >= 80 {
							let mut advanced_topic = b"Advanced ".to_vec();
							advanced_topic.extend_from_slice(&skill.domain);
							recommendations.push(advanced_topic);
						}
					}
					
					return recommendations;
				}
			}
			
			Vec::new()
		}
		
		/// Get adaptive learning insights
		pub fn get_adaptive_insights(
			owner: &T::AccountId,
		) -> Vec<AdaptiveAction> {
			if let Some(passport) = Self::passports(owner) {
				if let Some(profile) = passport.learning_profile {
					// Return recent adaptive actions (last 10)
					let mut recent_actions = profile.adaptive_history.clone();
					recent_actions.sort_by(|a, b| b.timestamp.cmp(&a.timestamp));
					recent_actions.truncate(10);
					return recent_actions;
				}
			}
			
			Vec::new()
		}
		
		/// Calculate learning progress score
		pub fn calculate_learning_progress(
			owner: &T::AccountId,
		) -> u8 {
			if let Some(passport) = Self::passports(owner) {
				if let Some(profile) = passport.learning_profile {
					let total_skills = profile.strengths.len() + profile.areas_for_improvement.len();
					if total_skills == 0 {
						return 0;
					}
					
					let total_level: u32 = profile.strengths.iter().map(|s| s.level as u32).sum::<u32>() +
						profile.areas_for_improvement.iter().map(|s| s.level as u32).sum::<u32>();
					
					((total_level / total_skills as u32) as u8).min(100)
				} else {
					0
				}
			} else {
				0
			}
		}
		
		/// Get learning style for a user
		pub fn get_learning_style(owner: &T::AccountId) -> Option<LearningStyle> {
			Self::passports(owner)
				.and_then(|p| p.learning_profile)
				.map(|profile| profile.learning_style)
		}
		
		/// Get learning preferences for a user
		pub fn get_learning_preferences(owner: &T::AccountId) -> Option<LearningPreferences> {
			Self::passports(owner)
				.and_then(|p| p.learning_profile)
				.map(|profile| profile.preferences)
		}
		
		/// Get user's strengths
		pub fn get_user_strengths(owner: &T::AccountId) -> Vec<Skill> {
			Self::passports(owner)
				.and_then(|p| p.learning_profile)
				.map(|profile| profile.strengths)
				.unwrap_or_default()
		}
		
		/// Get user's areas for improvement
		pub fn get_areas_for_improvement(owner: &T::AccountId) -> Vec<Skill> {
			Self::passports(owner)
				.and_then(|p| p.learning_profile)
				.map(|profile| profile.areas_for_improvement)
				.unwrap_or_default()
		}
		
		/// Check if auto-update is enabled for a user
		pub fn is_auto_update_enabled(owner: &T::AccountId) -> bool {
			Self::passports(owner)
				.and_then(|p| p.learning_profile)
				.map(|profile| profile.auto_update_enabled)
				.unwrap_or(false)
		}
	}
}