// Business Source License 1.1
// 
// Licensed Work: keiko-dapp Version 0.0.1 or later.
// The Licensed Work is (c) 2025 Luis Andrés Peña Castillo
// 
// For full license terms, see LICENSE file in the repository root.

#![cfg_attr(not(feature = "std"), no_std)]

/// Reputation system pallet for Keiko parachain.
/// Manages dynamic reputation scores with expiring ratings.
pub use pallet::*;

#[cfg(test)]
mod mock;

#[cfg(test)]
mod tests;

#[cfg(feature = "runtime-benchmarks")]
mod benchmarking;

#[frame_support::pallet]
pub mod pallet {
	use frame_support::{
		pallet_prelude::*,
		traits::{StorageVersion, Get},
	};
	use frame_system::pallet_prelude::*;
	use sp_std::vec::Vec;
	use codec::{Encode, Decode, MaxEncodedLen};
	use scale_info::TypeInfo;
	use sp_runtime::traits::Saturating;
	use frame_support::BoundedVec;

	#[pallet::pallet]
	#[pallet::storage_version(STORAGE_VERSION)]
	pub struct Pallet<T>(_);

	const STORAGE_VERSION: StorageVersion = StorageVersion::new(1);

	/// Rating expiration period in blocks (30 days assuming 6 second blocks)
	/// 30 days * 24 hours * 60 minutes * 60 seconds / 6 seconds per block = 432,000 blocks
	pub const RATING_EXPIRATION_BLOCKS: u32 = 432_000;

	/// Maximum rating score (1-5 scale)
	pub const MAX_RATING_SCORE: u8 = 5;

	/// Minimum rating score (1-5 scale)
	pub const MIN_RATING_SCORE: u8 = 1;

	/// Maximum comment length in bytes
	pub const MAX_COMMENT_LENGTH: u32 = 500;

	/// Maximum number of ratings per user
	pub const MAX_RATINGS_PER_USER: u32 = 1000;

	#[pallet::config]
	pub trait Config: frame_system::Config {
		/// Maximum length for rating comments
		#[pallet::constant]
		type MaxCommentLength: Get<u32>;

		/// Rating expiration period in blocks
		#[pallet::constant]
		type RatingExpirationBlocks: Get<u32>;
	}

	/// Unique identifier for ratings
	pub type RatingId = u64;

	/// Unique identifier for interactions (from learning_interactions pallet)
	pub type InteractionId = u64;

	/// Individual rating structure with expiration
	#[derive(Encode, Decode, Clone, PartialEq, Eq, RuntimeDebug, TypeInfo, MaxEncodedLen)]
	pub struct Rating<AccountId, BlockNumber> {
		/// Unique rating identifier
		pub id: RatingId,
		/// Account that gave the rating
		pub rater: AccountId,
		/// Account that received the rating
		pub rated: AccountId,
		/// Rating score (1-5)
		pub score: u8,
		/// Optional comment
		pub comment: BoundedVec<u8, ConstU32<MAX_COMMENT_LENGTH>>,
		/// Optional reference to learning interaction
		pub interaction_id: Option<InteractionId>,
		/// Block when rating was created
		pub created_at: BlockNumber,
		/// Block when rating expires
		pub expires_at: BlockNumber,
		/// Whether this rating is still active
		pub is_active: bool,
	}

	/// Aggregated reputation score for a user
	#[derive(Encode, Decode, Clone, PartialEq, Eq, RuntimeDebug, TypeInfo, Default, MaxEncodedLen)]
	pub struct ReputationScore<BlockNumber> {
		/// Current weighted reputation score
		pub current_score: u32, // Using u32 to avoid floating point, multiply by 100 for precision
		/// Historical reputation score (all time)
		pub historical_score: u32,
		/// Total number of ratings received
		pub total_ratings: u32,
		/// Number of recent ratings (within expiration period)
		pub recent_ratings: u32,
		/// Block when reputation was last updated
		pub last_updated: BlockNumber,
	}

	/// Storage for individual ratings
	#[pallet::storage]
	#[pallet::getter(fn ratings)]
	pub type Ratings<T: Config> = StorageMap<
		_,
		Blake2_128Concat,
		RatingId,
		Rating<T::AccountId, BlockNumberFor<T>>,
		OptionQuery,
	>;

	/// Storage for user reputation scores
	#[pallet::storage]
	#[pallet::getter(fn reputation_scores)]
	pub type ReputationScores<T: Config> = StorageMap<
		_,
		Blake2_128Concat,
		T::AccountId,
		ReputationScore<BlockNumberFor<T>>,
		ValueQuery,
	>;

	/// Storage for ratings given by a user
	#[pallet::storage]
	#[pallet::getter(fn ratings_given)]
	pub type RatingsGiven<T: Config> = StorageMap<
		_,
		Blake2_128Concat,
		T::AccountId,
		BoundedVec<RatingId, ConstU32<MAX_RATINGS_PER_USER>>,
		ValueQuery,
	>;

	/// Storage for ratings received by a user
	#[pallet::storage]
	#[pallet::getter(fn ratings_received)]
	pub type RatingsReceived<T: Config> = StorageMap<
		_,
		Blake2_128Concat,
		T::AccountId,
		BoundedVec<RatingId, ConstU32<MAX_RATINGS_PER_USER>>,
		ValueQuery,
	>;

	/// Next available rating ID
	#[pallet::storage]
	#[pallet::getter(fn next_rating_id)]
	pub type NextRatingId<T: Config> = StorageValue<_, RatingId, ValueQuery>;

	#[pallet::event]
	#[pallet::generate_deposit(pub(super) fn deposit_event)]
	pub enum Event<T: Config> {
		/// A new rating was created
		RatingCreated {
			rating_id: RatingId,
			rater: T::AccountId,
			rated: T::AccountId,
			score: u8,
			interaction_id: Option<InteractionId>,
		},
		/// A rating was updated
		RatingUpdated {
			rating_id: RatingId,
			new_score: u8,
		},
		/// A rating expired
		RatingExpired {
			rating_id: RatingId,
			rated: T::AccountId,
		},
		/// Reputation score was recalculated
		ReputationUpdated {
			user: T::AccountId,
			new_score: u32,
			total_ratings: u32,
		},
		/// A comment was added to a rating
		CommentAdded {
			rating_id: RatingId,
			commenter: T::AccountId,
		},
	}

	#[pallet::error]
	pub enum Error<T> {
		/// Rating not found
		RatingNotFound,
		/// Invalid rating score (must be 1-5)
		InvalidRatingScore,
		/// Comment too long
		CommentTooLong,
		/// Cannot rate yourself
		CannotRateSelf,
		/// Rating already exists for this interaction
		RatingAlreadyExists,
		/// Not authorized to update this rating
		NotAuthorized,
		/// Rating has expired
		RatingExpired,
		/// Interaction not found
		InteractionNotFound,
		/// Arithmetic overflow
		ArithmeticOverflow,
		/// Too many ratings from same user
		TooManyRatings,
	}

	#[pallet::call]
	impl<T: Config> Pallet<T> {
		/// Create a new rating for a user
		#[pallet::call_index(0)]
		#[pallet::weight(Weight::from_parts(10_000, 0).saturating_add(T::DbWeight::get().reads_writes(3, 4)))]
		pub fn create_rating(
			origin: OriginFor<T>,
			rated: T::AccountId,
			score: u8,
			comment: Vec<u8>,
			interaction_id: Option<InteractionId>,
		) -> DispatchResult {
			let rater = ensure_signed(origin)?;

			// Validate inputs
			ensure!(rater != rated, Error::<T>::CannotRateSelf);
			ensure!(
				score >= MIN_RATING_SCORE && score <= MAX_RATING_SCORE,
				Error::<T>::InvalidRatingScore
			);
			ensure!(
				comment.len() <= T::MaxCommentLength::get() as usize,
				Error::<T>::CommentTooLong
			);

			let current_block = <frame_system::Pallet<T>>::block_number();
			let rating_id = Self::next_rating_id();
			let expires_at = current_block.saturating_add(T::RatingExpirationBlocks::get().into());

			// Convert comment to BoundedVec
			let bounded_comment: BoundedVec<u8, ConstU32<MAX_COMMENT_LENGTH>> = 
				comment.try_into().map_err(|_| Error::<T>::CommentTooLong)?;

			// Create the rating
			let rating = Rating {
				id: rating_id,
				rater: rater.clone(),
				rated: rated.clone(),
				score,
				comment: bounded_comment,
				interaction_id,
				created_at: current_block,
				expires_at,
				is_active: true,
			};

			// Store the rating
			Ratings::<T>::insert(&rating_id, &rating);

			// Update rating lists
			RatingsGiven::<T>::mutate(&rater, |ratings| {
				let _ = ratings.try_push(rating_id);
			});
			RatingsReceived::<T>::mutate(&rated, |ratings| {
				let _ = ratings.try_push(rating_id);
			});

			// Update next rating ID
			NextRatingId::<T>::put(rating_id + 1);

			// Recalculate reputation for the rated user
			Self::recalculate_reputation(&rated)?;

			Self::deposit_event(Event::RatingCreated {
				rating_id,
				rater,
				rated,
				score,
				interaction_id,
			});

			Ok(())
		}

		/// Update an existing rating (only by the original rater)
		#[pallet::call_index(1)]
		#[pallet::weight(Weight::from_parts(10_000, 0).saturating_add(T::DbWeight::get().reads_writes(2, 2)))]
		pub fn update_rating(
			origin: OriginFor<T>,
			rating_id: RatingId,
			new_score: u8,
			new_comment: Option<Vec<u8>>,
		) -> DispatchResult {
			let who = ensure_signed(origin)?;

			// Validate score
			ensure!(
				new_score >= MIN_RATING_SCORE && new_score <= MAX_RATING_SCORE,
				Error::<T>::InvalidRatingScore
			);

			// Get and validate rating
			let mut rating = Self::ratings(&rating_id).ok_or(Error::<T>::RatingNotFound)?;
			ensure!(rating.rater == who, Error::<T>::NotAuthorized);
			ensure!(rating.is_active, Error::<T>::RatingExpired);

			let current_block = <frame_system::Pallet<T>>::block_number();
			ensure!(current_block < rating.expires_at, Error::<T>::RatingExpired);

			// Update rating
			rating.score = new_score;
			if let Some(comment) = new_comment {
				// Validate and convert comment to BoundedVec
				let bounded_comment: BoundedVec<u8, ConstU32<MAX_COMMENT_LENGTH>> = 
					comment.try_into().map_err(|_| Error::<T>::CommentTooLong)?;
				rating.comment = bounded_comment;
			}

			Ratings::<T>::insert(&rating_id, &rating);

			// Recalculate reputation for the rated user
			Self::recalculate_reputation(&rating.rated)?;

			Self::deposit_event(Event::RatingUpdated {
				rating_id,
				new_score,
			});

			Ok(())
		}
	}

	impl<T: Config> Pallet<T> {
		/// Recalculate reputation score for a user
		pub fn recalculate_reputation(user: &T::AccountId) -> DispatchResult {
			let current_block = <frame_system::Pallet<T>>::block_number();
			let ratings = Self::ratings_received(user);
			
			let mut total_score = 0u32;
			let mut total_ratings = 0u32;
			let mut recent_score = 0u32;
			let mut recent_ratings = 0u32;

			for rating_id in ratings.iter() {
				if let Some(rating) = Self::ratings(rating_id) {
					if rating.is_active && current_block < rating.expires_at {
						total_score = total_score.saturating_add(rating.score as u32 * 100);
						total_ratings = total_ratings.saturating_add(1);

						// Check if rating is recent (within expiration period)
						let age = current_block.saturating_sub(rating.created_at);
						let expiration_blocks: BlockNumberFor<T> = T::RatingExpirationBlocks::get().into();
						if age < expiration_blocks {
							recent_score = recent_score.saturating_add(rating.score as u32 * 100);
							recent_ratings = recent_ratings.saturating_add(1);
						}
					}
				}
			}

			// Calculate weighted averages (multiplied by 100 for precision)
			let current_score = if recent_ratings > 0 {
				recent_score / recent_ratings
			} else {
				0
			};

			let historical_score = if total_ratings > 0 {
				total_score / total_ratings
			} else {
				0
			};

			let reputation = ReputationScore {
				current_score,
				historical_score,
				total_ratings,
				recent_ratings,
				last_updated: current_block,
			};

			ReputationScores::<T>::insert(user, &reputation);

			Self::deposit_event(Event::ReputationUpdated {
				user: user.clone(),
				new_score: current_score,
				total_ratings,
			});

			Ok(())
		}

		/// Expire old ratings (should be called periodically)
		pub fn expire_old_ratings() -> DispatchResult {
			let current_block = <frame_system::Pallet<T>>::block_number();
			
			// This is a simplified version - in production, you'd want to iterate
			// through ratings more efficiently, possibly using a separate storage
			// for ratings by expiration date
			
			Ok(())
		}
	}
}