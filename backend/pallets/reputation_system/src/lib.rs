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
    use codec::{Decode, Encode, MaxEncodedLen};
    use frame_support::{
        pallet_prelude::*,
        traits::{Get, StorageVersion},
        BoundedVec,
    };
    use frame_system::pallet_prelude::*;
    use scale_info::TypeInfo;
    use sp_runtime::traits::Saturating;
    use sp_std::vec::Vec;

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

    /// Maximum number of comment responses per rating
    pub const MAX_COMMENT_RESPONSES: u32 = 10;

    /// Maximum number of peer ratings per group activity
    pub const MAX_PEER_RATINGS: u32 = 50;

    #[pallet::config]
    pub trait Config: frame_system::Config<RuntimeEvent: From<Event<Self>>> {
        /// Maximum length for rating comments
        #[pallet::constant]
        type MaxCommentLength: Get<u32>;

        /// Rating expiration period in blocks
        #[pallet::constant]
        type RatingExpirationBlocks: Get<u32>;

        /// Maximum number of comment responses per rating
        #[pallet::constant]
        type MaxCommentResponses: Get<u32>;
    }

    /// Unique identifier for ratings
    pub type RatingId = u64;

    /// Unique identifier for interactions (from learning_interactions pallet)
    pub type InteractionId = u64;

    /// Unique identifier for comment responses
    pub type ResponseId = u64;

    /// Unique identifier for group activities
    pub type GroupActivityId = u64;

    /// Rating type to distinguish different kinds of ratings
    #[derive(Encode, Decode, Clone, PartialEq, Eq, RuntimeDebug, TypeInfo, MaxEncodedLen)]
    pub enum RatingType {
        /// Student rating tutor after session
        StudentToTutor,
        /// Tutor rating student after session
        TutorToStudent,
        /// Peer rating in group activity
        PeerToPeer,
        /// General rating (default)
        General,
    }

    impl Default for RatingType {
        fn default() -> Self {
            RatingType::General
        }
    }

    /// Comment response structure
    #[derive(Encode, Decode, Clone, PartialEq, Eq, RuntimeDebug, TypeInfo, MaxEncodedLen)]
    pub struct CommentResponse<AccountId, BlockNumber> {
        /// Unique response identifier
        pub id: ResponseId,
        /// Account that made the response
        pub responder: AccountId,
        /// Response content
        pub content: BoundedVec<u8, ConstU32<MAX_COMMENT_LENGTH>>,
        /// Block when response was created
        pub created_at: BlockNumber,
    }

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
        /// Optional reference to group activity
        pub group_activity_id: Option<GroupActivityId>,
        /// Type of rating
        pub rating_type: RatingType,
        /// Block when rating was created
        pub created_at: BlockNumber,
        /// Block when rating expires
        pub expires_at: BlockNumber,
        /// Whether this rating is still active
        pub is_active: bool,
        /// Detailed aspects of the rating (for multidimensional feedback)
        pub aspects: Option<RatingAspects>,
    }

    /// Detailed rating aspects for comprehensive feedback
    #[derive(Encode, Decode, Clone, PartialEq, Eq, RuntimeDebug, TypeInfo, MaxEncodedLen)]
    pub struct RatingAspects {
        /// Communication skills (1-5)
        pub communication: Option<u8>,
        /// Knowledge/expertise (1-5)
        pub knowledge: Option<u8>,
        /// Punctuality (1-5)
        pub punctuality: Option<u8>,
        /// Engagement/participation (1-5)
        pub engagement: Option<u8>,
        /// Helpfulness (1-5)
        pub helpfulness: Option<u8>,
    }

    /// Aggregated reputation score for a user
    #[derive(
        Encode, Decode, Clone, PartialEq, Eq, RuntimeDebug, TypeInfo, Default, MaxEncodedLen,
    )]
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

    /// Storage for comment responses to ratings
    #[pallet::storage]
    #[pallet::getter(fn comment_responses)]
    pub type CommentResponses<T: Config> = StorageMap<
        _,
        Blake2_128Concat,
        RatingId,
        BoundedVec<
            CommentResponse<T::AccountId, BlockNumberFor<T>>,
            ConstU32<MAX_COMMENT_RESPONSES>,
        >,
        ValueQuery,
    >;

    /// Next available response ID
    #[pallet::storage]
    #[pallet::getter(fn next_response_id)]
    pub type NextResponseId<T: Config> = StorageValue<_, ResponseId, ValueQuery>;

    /// Storage for group activity ratings
    #[pallet::storage]
    #[pallet::getter(fn group_activity_ratings)]
    pub type GroupActivityRatings<T: Config> = StorageMap<
        _,
        Blake2_128Concat,
        GroupActivityId,
        BoundedVec<RatingId, ConstU32<MAX_PEER_RATINGS>>,
        ValueQuery,
    >;

    /// Storage for bidirectional rating pairs (tutor-student sessions)
    #[pallet::storage]
    #[pallet::getter(fn rating_pairs)]
    pub type RatingPairs<T: Config> = StorageMap<
        _,
        Blake2_128Concat,
        InteractionId,
        (Option<RatingId>, Option<RatingId>), // (student_to_tutor, tutor_to_student)
        ValueQuery,
    >;

    #[pallet::event]
    #[pallet::generate_deposit(pub(super) fn deposit_event)]
    pub enum Event<T: Config> {
        /// A new rating was created
        RatingCreated {
            rating_id: RatingId,
            rater: T::AccountId,
            rated: T::AccountId,
            score: u8,
            rating_type: RatingType,
            interaction_id: Option<InteractionId>,
        },
        /// A rating was updated
        RatingUpdated { rating_id: RatingId, new_score: u8 },
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
        /// A response was added to a rating comment
        CommentResponseAdded {
            rating_id: RatingId,
            response_id: ResponseId,
            responder: T::AccountId,
        },
        /// A bidirectional rating pair was completed
        BidirectionalRatingCompleted {
            interaction_id: InteractionId,
            student_rating: RatingId,
            tutor_rating: RatingId,
        },
        /// A peer rating was created for group activity
        PeerRatingCreated {
            rating_id: RatingId,
            group_activity_id: GroupActivityId,
            rater: T::AccountId,
            rated: T::AccountId,
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
        /// Response not found
        ResponseNotFound,
        /// Too many responses for this rating
        TooManyResponses,
        /// Invalid rating type for this operation
        InvalidRatingType,
        /// Group activity not found
        GroupActivityNotFound,
        /// Already rated this peer in this group activity
        AlreadyRatedPeer,
        /// Invalid aspect score (must be 1-5)
        InvalidAspectScore,
        /// Bidirectional rating already exists
        BidirectionalRatingExists,
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
            Self::create_detailed_rating(
                origin,
                rated,
                score,
                comment,
                interaction_id,
                None, // group_activity_id
                RatingType::General,
                None, // aspects
            )
        }

        /// Create a detailed rating with type and aspects
        #[pallet::call_index(1)]
        #[pallet::weight(Weight::from_parts(15_000, 0).saturating_add(T::DbWeight::get().reads_writes(4, 5)))]
        pub fn create_detailed_rating(
            origin: OriginFor<T>,
            rated: T::AccountId,
            score: u8,
            comment: Vec<u8>,
            interaction_id: Option<InteractionId>,
            group_activity_id: Option<GroupActivityId>,
            rating_type: RatingType,
            aspects: Option<RatingAspects>,
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

            // Validate aspects if provided
            if let Some(ref aspects) = aspects {
                Self::validate_aspects(aspects)?;
            }

            let current_block = <frame_system::Pallet<T>>::block_number();
            let rating_id = Self::next_rating_id();
            // Ensure rating_id starts from 1, not 0
            let actual_rating_id = if rating_id == 0 { 1 } else { rating_id };
            let expires_at = current_block.saturating_add(T::RatingExpirationBlocks::get().into());

            // Convert comment to BoundedVec
            let bounded_comment: BoundedVec<u8, ConstU32<MAX_COMMENT_LENGTH>> =
                comment.try_into().map_err(|_| Error::<T>::CommentTooLong)?;

            // Create the rating
            let rating = Rating {
                id: actual_rating_id,
                rater: rater.clone(),
                rated: rated.clone(),
                score,
                comment: bounded_comment,
                interaction_id,
                group_activity_id,
                rating_type: rating_type.clone(),
                created_at: current_block,
                expires_at,
                is_active: true,
                aspects,
            };

            // Store the rating
            Ratings::<T>::insert(&actual_rating_id, &rating);

            // Update rating lists
            RatingsGiven::<T>::mutate(&rater, |ratings| {
                let _ = ratings.try_push(actual_rating_id);
            });
            RatingsReceived::<T>::mutate(&rated, |ratings| {
                let _ = ratings.try_push(actual_rating_id);
            });

            // Handle special rating types
            match rating_type {
                RatingType::PeerToPeer => {
                    if let Some(group_id) = group_activity_id {
                        GroupActivityRatings::<T>::mutate(&group_id, |ratings| {
                            let _ = ratings.try_push(actual_rating_id);
                        });

                        Self::deposit_event(Event::PeerRatingCreated {
                            rating_id: actual_rating_id,
                            group_activity_id: group_id,
                            rater: rater.clone(),
                            rated: rated.clone(),
                        });
                    }
                }
                RatingType::TutorToStudent | RatingType::StudentToTutor => {
                    if let Some(interaction_id) = interaction_id {
                        Self::handle_bidirectional_rating(
                            interaction_id,
                            actual_rating_id,
                            &rating_type,
                        )?;
                    }
                }
                _ => {}
            }

            // Update next rating ID
            NextRatingId::<T>::put(actual_rating_id + 1);

            // Recalculate reputation for the rated user
            Self::recalculate_reputation(&rated)?;

            Self::deposit_event(Event::RatingCreated {
                rating_id: actual_rating_id,
                rater,
                rated,
                score,
                rating_type,
                interaction_id,
            });

            Ok(())
        }

        /// Update an existing rating (only by the original rater)
        #[pallet::call_index(2)]
        #[pallet::weight(Weight::from_parts(10_000, 0).saturating_add(T::DbWeight::get().reads_writes(2, 2)))]
        pub fn update_rating(
            origin: OriginFor<T>,
            rating_id: RatingId,
            new_score: u8,
            new_comment: Option<Vec<u8>>,
            new_aspects: Option<RatingAspects>,
        ) -> DispatchResult {
            let who = ensure_signed(origin)?;

            // Validate score
            ensure!(
                new_score >= MIN_RATING_SCORE && new_score <= MAX_RATING_SCORE,
                Error::<T>::InvalidRatingScore
            );

            // Validate aspects if provided
            if let Some(ref aspects) = new_aspects {
                Self::validate_aspects(aspects)?;
            }

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
            if new_aspects.is_some() {
                rating.aspects = new_aspects;
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

        /// Add a response to a rating comment
        #[pallet::call_index(3)]
        #[pallet::weight(Weight::from_parts(10_000, 0).saturating_add(T::DbWeight::get().reads_writes(3, 2)))]
        pub fn add_comment_response(
            origin: OriginFor<T>,
            rating_id: RatingId,
            response_content: Vec<u8>,
        ) -> DispatchResult {
            let responder = ensure_signed(origin)?;

            // Validate response content length
            ensure!(
                response_content.len() <= T::MaxCommentLength::get() as usize,
                Error::<T>::CommentTooLong
            );

            // Verify rating exists and is active
            let rating = Self::ratings(&rating_id).ok_or(Error::<T>::RatingNotFound)?;
            ensure!(rating.is_active, Error::<T>::RatingExpired);

            let current_block = <frame_system::Pallet<T>>::block_number();
            ensure!(current_block < rating.expires_at, Error::<T>::RatingExpired);

            // Only the rated user or the rater can respond to comments
            ensure!(
                responder == rating.rated || responder == rating.rater,
                Error::<T>::NotAuthorized
            );

            // Check if we can add more responses
            let current_responses = Self::comment_responses(&rating_id);
            ensure!(
                current_responses.len() < T::MaxCommentResponses::get() as usize,
                Error::<T>::TooManyResponses
            );

            // Generate response ID
            let response_id = Self::next_response_id();
            let actual_response_id = if response_id == 0 { 1 } else { response_id };

            // Convert response content to BoundedVec
            let bounded_content: BoundedVec<u8, ConstU32<MAX_COMMENT_LENGTH>> = response_content
                .try_into()
                .map_err(|_| Error::<T>::CommentTooLong)?;

            // Create response
            let response = CommentResponse {
                id: actual_response_id,
                responder: responder.clone(),
                content: bounded_content,
                created_at: current_block,
            };

            // Add response to storage
            CommentResponses::<T>::mutate(&rating_id, |responses| {
                let _ = responses.try_push(response);
            });

            // Update next response ID
            NextResponseId::<T>::put(actual_response_id + 1);

            Self::deposit_event(Event::CommentResponseAdded {
                rating_id,
                response_id: actual_response_id,
                responder,
            });

            Ok(())
        }

        /// Create a peer rating for group activity
        #[pallet::call_index(4)]
        #[pallet::weight(Weight::from_parts(12_000, 0).saturating_add(T::DbWeight::get().reads_writes(4, 4)))]
        pub fn create_peer_rating(
            origin: OriginFor<T>,
            rated: T::AccountId,
            group_activity_id: GroupActivityId,
            score: u8,
            comment: Vec<u8>,
            aspects: Option<RatingAspects>,
        ) -> DispatchResult {
            let rater = ensure_signed(origin)?;

            // Check if already rated this peer in this group activity
            let existing_ratings = Self::group_activity_ratings(&group_activity_id);
            for rating_id in existing_ratings.iter() {
                if let Some(rating) = Self::ratings(rating_id) {
                    if rating.rater == rater && rating.rated == rated {
                        return Err(Error::<T>::AlreadyRatedPeer.into());
                    }
                }
            }

            Self::create_detailed_rating(
                OriginFor::<T>::from(Some(rater).into()),
                rated,
                score,
                comment,
                None, // interaction_id
                Some(group_activity_id),
                RatingType::PeerToPeer,
                aspects,
            )
        }

        /// Manually expire old ratings (can be called by anyone to help maintain the system)
        #[pallet::call_index(5)]
        #[pallet::weight(Weight::from_parts(10_000, 0).saturating_add(T::DbWeight::get().reads_writes(*limit as u64, *limit as u64)))]
        pub fn expire_old_ratings(origin: OriginFor<T>, limit: u32) -> DispatchResult {
            let _who = ensure_signed(origin)?;

            // Limit the number of ratings processed in one call to prevent excessive gas usage
            let max_limit = 100u32;
            let actual_limit = limit.min(max_limit);

            Self::expire_old_ratings_batch(actual_limit)?;

            Ok(())
        }

        /// Force recalculate reputation for a user (useful for maintenance)
        #[pallet::call_index(6)]
        #[pallet::weight(Weight::from_parts(10_000, 0).saturating_add(T::DbWeight::get().reads_writes(3, 2)))]
        pub fn force_recalculate_reputation(
            origin: OriginFor<T>,
            user: T::AccountId,
        ) -> DispatchResult {
            let _who = ensure_signed(origin)?;

            Self::recalculate_reputation(&user)?;

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
            let mut expired_ratings = Vec::new();

            for rating_id in ratings.iter() {
                if let Some(mut rating) = Self::ratings(rating_id) {
                    // Check if rating has expired
                    if current_block >= rating.expires_at && rating.is_active {
                        rating.is_active = false;
                        Ratings::<T>::insert(rating_id, &rating);
                        expired_ratings.push(*rating_id);

                        Self::deposit_event(Event::RatingExpired {
                            rating_id: *rating_id,
                            rated: user.clone(),
                        });
                        continue;
                    }

                    if rating.is_active {
                        // Add to historical totals
                        total_score = total_score.saturating_add(rating.score as u32 * 100);
                        total_ratings = total_ratings.saturating_add(1);

                        // Check if rating is recent (within expiration period)
                        let age = current_block.saturating_sub(rating.created_at);
                        let expiration_blocks: BlockNumberFor<T> =
                            T::RatingExpirationBlocks::get().into();
                        if age < expiration_blocks {
                            // Apply time-based weighting: newer ratings have more weight
                            // Convert to u32 for calculation
                            let age_u32: u32 = age.try_into().unwrap_or(u32::MAX);
                            let expiration_u32: u32 = T::RatingExpirationBlocks::get();
                            let time_weight = Self::calculate_time_weight(age_u32, expiration_u32);
                            let weighted_score = (rating.score as u32 * 100 * time_weight) / 100;

                            recent_score = recent_score.saturating_add(weighted_score);
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

        /// Calculate time-based weight for ratings (newer ratings get higher weight)
        /// Returns a weight between 50 and 100 (50% to 100% weight)
        fn calculate_time_weight(age: u32, max_age: u32) -> u32 {
            if max_age == 0 {
                return 100;
            }

            // Linear decay from 100% (new) to 50% (about to expire)
            let decay_factor = (age * 50) / max_age;
            100u32.saturating_sub(decay_factor).max(50)
        }

        /// Expire old ratings for a specific user (called during reputation recalculation)
        pub fn expire_ratings_for_user(user: &T::AccountId) -> DispatchResult {
            Self::recalculate_reputation(user)
        }

        /// Batch expire old ratings (should be called periodically via hooks or governance)
        pub fn expire_old_ratings_batch(limit: u32) -> DispatchResult {
            let current_block = <frame_system::Pallet<T>>::block_number();
            let mut processed = 0u32;

            // Get the current rating ID to iterate through existing ratings
            let max_rating_id = Self::next_rating_id();

            // Start from 1 since rating IDs start from 1
            for rating_id in 1..max_rating_id {
                if processed >= limit {
                    break;
                }

                if let Some(mut rating) = Self::ratings(&rating_id) {
                    if rating.is_active && current_block >= rating.expires_at {
                        rating.is_active = false;
                        Ratings::<T>::insert(&rating_id, &rating);

                        Self::deposit_event(Event::RatingExpired {
                            rating_id,
                            rated: rating.rated.clone(),
                        });

                        processed = processed.saturating_add(1);
                    }
                }
            }

            Ok(())
        }

        /// Get active ratings for a user (non-expired)
        pub fn get_active_ratings_for_user(user: &T::AccountId) -> Vec<RatingId> {
            let current_block = <frame_system::Pallet<T>>::block_number();
            let ratings = Self::ratings_received(user);

            ratings
                .iter()
                .filter_map(|rating_id| {
                    Self::ratings(rating_id).and_then(|rating| {
                        if rating.is_active && current_block < rating.expires_at {
                            Some(*rating_id)
                        } else {
                            None
                        }
                    })
                })
                .collect()
        }

        /// Get reputation score with automatic expiration check
        pub fn get_current_reputation(user: &T::AccountId) -> ReputationScore<BlockNumberFor<T>> {
            // This will automatically expire old ratings and recalculate
            let _ = Self::recalculate_reputation(user);
            Self::reputation_scores(user)
        }

        /// Validate rating aspects scores
        fn validate_aspects(aspects: &RatingAspects) -> DispatchResult {
            if let Some(score) = aspects.communication {
                ensure!(
                    score >= MIN_RATING_SCORE && score <= MAX_RATING_SCORE,
                    Error::<T>::InvalidAspectScore
                );
            }
            if let Some(score) = aspects.knowledge {
                ensure!(
                    score >= MIN_RATING_SCORE && score <= MAX_RATING_SCORE,
                    Error::<T>::InvalidAspectScore
                );
            }
            if let Some(score) = aspects.punctuality {
                ensure!(
                    score >= MIN_RATING_SCORE && score <= MAX_RATING_SCORE,
                    Error::<T>::InvalidAspectScore
                );
            }
            if let Some(score) = aspects.engagement {
                ensure!(
                    score >= MIN_RATING_SCORE && score <= MAX_RATING_SCORE,
                    Error::<T>::InvalidAspectScore
                );
            }
            if let Some(score) = aspects.helpfulness {
                ensure!(
                    score >= MIN_RATING_SCORE && score <= MAX_RATING_SCORE,
                    Error::<T>::InvalidAspectScore
                );
            }
            Ok(())
        }

        /// Handle bidirectional rating logic for tutor-student sessions
        fn handle_bidirectional_rating(
            interaction_id: InteractionId,
            rating_id: RatingId,
            rating_type: &RatingType,
        ) -> DispatchResult {
            let mut rating_pair = Self::rating_pairs(&interaction_id);

            match rating_type {
                RatingType::StudentToTutor => {
                    ensure!(
                        rating_pair.0.is_none(),
                        Error::<T>::BidirectionalRatingExists
                    );
                    rating_pair.0 = Some(rating_id);
                }
                RatingType::TutorToStudent => {
                    ensure!(
                        rating_pair.1.is_none(),
                        Error::<T>::BidirectionalRatingExists
                    );
                    rating_pair.1 = Some(rating_id);
                }
                _ => return Err(Error::<T>::InvalidRatingType.into()),
            }

            RatingPairs::<T>::insert(&interaction_id, &rating_pair);

            // Check if both ratings are now complete
            if let (Some(student_rating), Some(tutor_rating)) = rating_pair {
                Self::deposit_event(Event::BidirectionalRatingCompleted {
                    interaction_id,
                    student_rating,
                    tutor_rating,
                });
            }

            Ok(())
        }

        /// Get all ratings for a group activity
        pub fn get_group_activity_ratings(group_activity_id: &GroupActivityId) -> Vec<RatingId> {
            Self::group_activity_ratings(group_activity_id).into_inner()
        }

        /// Get bidirectional rating pair for an interaction
        pub fn get_rating_pair(
            interaction_id: &InteractionId,
        ) -> (Option<RatingId>, Option<RatingId>) {
            Self::rating_pairs(interaction_id)
        }

        /// Get all responses for a rating comment
        pub fn get_comment_responses(
            rating_id: &RatingId,
        ) -> Vec<CommentResponse<T::AccountId, BlockNumberFor<T>>> {
            Self::comment_responses(rating_id).into_inner()
        }

        /// Check if a user has already rated another user in a specific group activity
        pub fn has_peer_rating(
            rater: &T::AccountId,
            rated: &T::AccountId,
            group_activity_id: &GroupActivityId,
        ) -> bool {
            let ratings = Self::group_activity_ratings(group_activity_id);
            for rating_id in ratings.iter() {
                if let Some(rating) = Self::ratings(rating_id) {
                    if rating.rater == *rater && rating.rated == *rated {
                        return true;
                    }
                }
            }
            false
        }

        /// Get ratings by type for a user
        pub fn get_ratings_by_type(user: &T::AccountId, rating_type: &RatingType) -> Vec<RatingId> {
            let ratings = Self::ratings_received(user);
            ratings
                .iter()
                .filter_map(|rating_id| {
                    Self::ratings(rating_id).and_then(|rating| {
                        if rating.rating_type == *rating_type && rating.is_active {
                            Some(*rating_id)
                        } else {
                            None
                        }
                    })
                })
                .collect()
        }

        /// Calculate reputation score considering rating types
        /// Different types may have different weights in the future
        pub fn calculate_weighted_reputation(
            user: &T::AccountId,
        ) -> ReputationScore<BlockNumberFor<T>> {
            // For now, all rating types have equal weight
            // In the future, we might want to weight peer ratings differently
            Self::get_current_reputation(user)
        }
    }
}
