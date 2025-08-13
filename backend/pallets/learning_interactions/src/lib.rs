// Business Source License 1.1
// 
// Licensed Work: keiko-dapp Version 0.0.1 or later.
// The Licensed Work is (c) 2025 Luis Andrés Peña Castillo
// 
// For full license terms, see LICENSE file in the repository root.

#![cfg_attr(not(feature = "std"), no_std)]

/// Learning interactions pallet for Keiko parachain.
/// Handles atomic learning interactions compatible with xAPI standard.
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

/// Unique identifier for learning interactions
pub type InteractionId = u64;
/// Unique identifier for courses
pub type CourseId = u64;
/// Unique identifier for classes
pub type ClassId = u64;
/// Unique identifier for tutorial sessions
pub type TutorialId = u64;

/// xAPI Actor representation
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub struct Actor<AccountId> {
	/// Account ID of the actor
	pub account: AccountId,
	/// Optional display name
	pub name: Option<Vec<u8>>,
	/// Optional email (mbox)
	pub mbox: Option<Vec<u8>>,
}

/// xAPI Verb representation
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub struct Verb {
	/// Verb IRI identifier
	pub id: Vec<u8>,
	/// Display name in different languages
	pub display: BTreeMap<Vec<u8>, Vec<u8>>,
}

/// xAPI Object representation
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub struct Object {
	/// Object type (Activity, Agent, Group, etc.)
	pub object_type: ObjectType,
	/// Object identifier
	pub id: Vec<u8>,
	/// Optional activity definition
	pub definition: Option<ActivityDefinition>,
}

/// xAPI Object types
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub enum ObjectType {
	Activity,
	Agent,
	Group,
	SubStatement,
	StatementRef,
}

/// xAPI Activity definition
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub struct ActivityDefinition {
	/// Activity name
	pub name: Option<BTreeMap<Vec<u8>, Vec<u8>>>,
	/// Activity description
	pub description: Option<BTreeMap<Vec<u8>, Vec<u8>>>,
	/// Activity type IRI
	pub activity_type: Option<Vec<u8>>,
}

/// xAPI Result representation
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub struct Result {
	/// Score achieved
	pub score: Option<Score>,
	/// Success indicator
	pub success: Option<bool>,
	/// Completion indicator
	pub completion: Option<bool>,
	/// Response text
	pub response: Option<Vec<u8>>,
	/// Duration in seconds
	pub duration: Option<u64>,
}

/// xAPI Score representation
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub struct Score {
	/// Scaled score (-1.0 to 1.0)
	pub scaled: Option<i32>, // Stored as fixed point * 1000
	/// Raw score
	pub raw: Option<i32>,
	/// Minimum possible score
	pub min: Option<i32>,
	/// Maximum possible score
	pub max: Option<i32>,
}

/// xAPI Context representation
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub struct Context {
	/// Registration UUID
	pub registration: Option<Vec<u8>>,
	/// Instructor information
	pub instructor: Option<Vec<u8>>,
	/// Team information
	pub team: Option<Vec<u8>>,
	/// Context activities
	pub context_activities: Option<ContextActivities>,
	/// Language tag
	pub language: Option<Vec<u8>>,
}

/// xAPI Context activities
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub struct ContextActivities {
	/// Parent activities
	pub parent: Option<Vec<Vec<u8>>>,
	/// Grouping activities
	pub grouping: Option<Vec<Vec<u8>>>,
	/// Category activities
	pub category: Option<Vec<Vec<u8>>>,
	/// Other activities
	pub other: Option<Vec<Vec<u8>>>,
}

/// Evidence or attachment reference
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub struct Evidence {
	/// Evidence type (file, url, text, etc.)
	pub evidence_type: EvidenceType,
	/// Content or reference
	pub content: Vec<u8>,
	/// Optional description
	pub description: Option<Vec<u8>>,
	/// MIME type for files
	pub mime_type: Option<Vec<u8>>,
}

/// Types of evidence that can be attached to interactions
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub enum EvidenceType {
	/// Text-based evidence
	Text,
	/// URL reference
	Url,
	/// File hash (IPFS or similar)
	FileHash,
	/// Image data
	Image,
	/// Audio data
	Audio,
	/// Video data
	Video,
}

/// Interaction categories for better organization
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub enum InteractionCategory {
	/// Question asked by student
	Question,
	/// Answer provided by tutor or student
	Answer,
	/// Exercise or assignment
	Exercise,
	/// Discussion or comment
	Discussion,
	/// Evaluation or assessment
	Evaluation,
	/// Feedback provided
	Feedback,
	/// General experience
	Experience,
}

/// Main learning interaction structure (xAPI Statement)
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub struct LearningInteraction<AccountId> {
	/// Unique identifier
	pub id: InteractionId,
	/// The actor (learner)
	pub actor: Actor<AccountId>,
	/// The verb (action performed)
	pub verb: Verb,
	/// The object (what was acted upon)
	pub object: Object,
	/// Optional result of the interaction
	pub result: Option<Result>,
	/// Optional context information
	pub context: Option<Context>,
	/// Timestamp when interaction occurred
	pub timestamp: u64,
	/// Authority that recorded this statement
	pub authority: Option<Vec<u8>>,
	/// xAPI version
	pub version: Vec<u8>,
	/// Category of interaction for better organization
	pub category: InteractionCategory,
	/// Evidence or attachments
	pub evidence: Vec<Evidence>,
}

/// Course structure for educational hierarchy
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub struct Course<AccountId> {
	/// Unique course identifier
	pub id: CourseId,
	/// Course title
	pub title: Vec<u8>,
	/// Course description
	pub description: Vec<u8>,
	/// Course instructor
	pub instructor: AccountId,
	/// List of class IDs in this course
	pub classes: Vec<ClassId>,
	/// Creation timestamp
	pub created_at: u64,
	/// Last update timestamp
	pub updated_at: u64,
}

/// Class structure for educational hierarchy
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub struct Class<AccountId> {
	/// Unique class identifier
	pub id: ClassId,
	/// Optional parent course ID
	pub course_id: Option<CourseId>,
	/// Class title
	pub title: Vec<u8>,
	/// Class description
	pub description: Vec<u8>,
	/// Class instructor
	pub instructor: AccountId,
	/// List of tutorial session IDs
	pub tutorials: Vec<TutorialId>,
	/// Direct learning interactions in this class
	pub interactions: Vec<InteractionId>,
	/// Creation timestamp
	pub created_at: u64,
	/// Last update timestamp
	pub updated_at: u64,
}

/// Tutorial session types
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub enum SessionType {
	/// Human tutor session
	Human,
	/// AI tutor session
	AI,
	/// Group session
	Group,
	/// Self-study session
	SelfStudy,
}

/// Tutorial session structure
#[derive(Encode, Decode, Clone, PartialEq, Eq, Debug, TypeInfo)]
pub struct TutorialSession<AccountId> {
	/// Unique tutorial session identifier
	pub id: TutorialId,
	/// Optional parent class ID
	pub class_id: Option<ClassId>,
	/// Session title
	pub title: Vec<u8>,
	/// Session description
	pub description: Vec<u8>,
	/// Tutor account
	pub tutor: AccountId,
	/// Student account
	pub student: AccountId,
	/// Type of session
	pub session_type: SessionType,
	/// Learning interactions in this session
	pub interactions: Vec<InteractionId>,
	/// Session start timestamp
	pub started_at: u64,
	/// Optional session end timestamp
	pub ended_at: Option<u64>,
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
		
		/// Maximum length for text fields (titles, descriptions, etc.)
		#[pallet::constant]
		type MaxTextLength: Get<u32>;
		
		/// Maximum number of interactions per session
		#[pallet::constant]
		type MaxInteractionsPerSession: Get<u32>;
		
		/// Maximum number of classes per course
		#[pallet::constant]
		type MaxClassesPerCourse: Get<u32>;
	}

	/// Storage for learning interactions
	#[pallet::storage]
	#[pallet::getter(fn interactions)]
	pub type Interactions<T: Config> = StorageMap<
		_,
		Blake2_128Concat,
		InteractionId,
		LearningInteraction<T::AccountId>,
		OptionQuery,
	>;

	/// Storage for courses
	#[pallet::storage]
	#[pallet::getter(fn courses)]
	pub type Courses<T: Config> = StorageMap<
		_,
		Blake2_128Concat,
		CourseId,
		Course<T::AccountId>,
		OptionQuery,
	>;

	/// Storage for classes
	#[pallet::storage]
	#[pallet::getter(fn classes)]
	pub type Classes<T: Config> = StorageMap<
		_,
		Blake2_128Concat,
		ClassId,
		Class<T::AccountId>,
		OptionQuery,
	>;

	/// Storage for tutorial sessions
	#[pallet::storage]
	#[pallet::getter(fn tutorial_sessions)]
	pub type TutorialSessions<T: Config> = StorageMap<
		_,
		Blake2_128Concat,
		TutorialId,
		TutorialSession<T::AccountId>,
		OptionQuery,
	>;

	/// Next available interaction ID
	#[pallet::storage]
	#[pallet::getter(fn next_interaction_id)]
	pub type NextInteractionId<T: Config> = StorageValue<_, InteractionId, ValueQuery>;

	/// Next available course ID
	#[pallet::storage]
	#[pallet::getter(fn next_course_id)]
	pub type NextCourseId<T: Config> = StorageValue<_, CourseId, ValueQuery>;

	/// Next available class ID
	#[pallet::storage]
	#[pallet::getter(fn next_class_id)]
	pub type NextClassId<T: Config> = StorageValue<_, ClassId, ValueQuery>;

	/// Next available tutorial session ID
	#[pallet::storage]
	#[pallet::getter(fn next_tutorial_id)]
	pub type NextTutorialId<T: Config> = StorageValue<_, TutorialId, ValueQuery>;

	/// Events emitted by the pallet
	#[pallet::event]
	#[pallet::generate_deposit(pub(super) fn deposit_event)]
	pub enum Event<T: Config> {
		/// A learning interaction was created. [interaction_id, actor, category]
		InteractionCreated {
			interaction_id: InteractionId,
			actor: T::AccountId,
			category: InteractionCategory,
		},
		/// A course was created. [course_id, instructor]
		CourseCreated {
			course_id: CourseId,
			instructor: T::AccountId,
		},
		/// A class was created. [class_id, instructor, course_id]
		ClassCreated {
			class_id: ClassId,
			instructor: T::AccountId,
			course_id: Option<CourseId>,
		},
		/// A tutorial session was created. [tutorial_id, tutor, student]
		TutorialSessionCreated {
			tutorial_id: TutorialId,
			tutor: T::AccountId,
			student: T::AccountId,
		},
		/// A tutorial session was ended. [tutorial_id]
		TutorialSessionEnded {
			tutorial_id: TutorialId,
		},
		/// An interaction with evidence was created. [interaction_id, evidence_count]
		InteractionWithEvidenceCreated {
			interaction_id: InteractionId,
			evidence_count: u32,
		},
	}

	/// Errors that can occur in the pallet
	#[pallet::error]
	pub enum Error<T> {
		/// Interaction not found
		InteractionNotFound,
		/// Course not found
		CourseNotFound,
		/// Class not found
		ClassNotFound,
		/// Tutorial session not found
		TutorialSessionNotFound,
		/// Text field too long
		TextTooLong,
		/// Too many interactions in session
		TooManyInteractions,
		/// Too many classes in course
		TooManyClasses,
		/// Invalid xAPI structure
		InvalidXAPIStructure,
		/// Tutorial session already ended
		SessionAlreadyEnded,
		/// Not authorized to perform this action
		NotAuthorized,
	}

	/// Dispatchable functions for the pallet
	#[pallet::call]
	impl<T: Config> Pallet<T> {
		/// Create a new learning interaction (xAPI statement)
		#[pallet::call_index(4)]
		#[pallet::weight(10_000 + T::DbWeight::get().writes(2).ref_time())]
		pub fn create_interaction(
			origin: OriginFor<T>,
			actor: Actor<T::AccountId>,
			verb: Verb,
			object: Object,
			result: Option<Result>,
			context: Option<Context>,
			category: InteractionCategory,
			evidence: Vec<Evidence>,
			tutorial_id: Option<TutorialId>,
			class_id: Option<ClassId>,
		) -> DispatchResult {
			let who = ensure_signed(origin)?;

			// Validate xAPI structure
			Self::validate_xapi_statement(&actor, &verb, &object)?;

			// Validate evidence
			Self::validate_evidence(&evidence)?;

			// Ensure the caller is authorized to create interactions for this actor
			ensure!(actor.account == who, Error::<T>::NotAuthorized);

			let interaction_id = Self::next_interaction_id();
			let now = Self::current_timestamp();

			let interaction = LearningInteraction {
				id: interaction_id,
				actor,
				verb,
				object,
				result,
				context,
				timestamp: now,
				authority: Some(b"keiko-parachain".to_vec()),
				version: b"1.0.3".to_vec(),
				category,
				evidence,
			};

			// Store the interaction
			Interactions::<T>::insert(&interaction_id, &interaction);
			NextInteractionId::<T>::put(interaction_id + 1);

			// Update tutorial session if provided
			if let Some(tid) = tutorial_id {
				let mut tutorial = Self::tutorial_sessions(&tid)
					.ok_or(Error::<T>::TutorialSessionNotFound)?;
				
				ensure!(
					tutorial.interactions.len() < T::MaxInteractionsPerSession::get() as usize,
					Error::<T>::TooManyInteractions
				);

				tutorial.interactions.push(interaction_id);
				TutorialSessions::<T>::insert(&tid, &tutorial);
			}

			// Update class if provided
			if let Some(cid) = class_id {
				let mut class = Self::classes(&cid)
					.ok_or(Error::<T>::ClassNotFound)?;
				
				class.interactions.push(interaction_id);
				class.updated_at = now;
				Classes::<T>::insert(&cid, &class);
			}

			Self::deposit_event(Event::InteractionCreated {
				interaction_id,
				actor: who.clone(),
				category: category.clone(),
			});

			// Emit additional event if evidence is present
			if !evidence.is_empty() {
				Self::deposit_event(Event::InteractionWithEvidenceCreated {
					interaction_id,
					evidence_count: evidence.len() as u32,
				});
			}

			Ok(())
		}
		/// Create a new course
		#[pallet::call_index(0)]
		#[pallet::weight(10_000 + T::DbWeight::get().writes(1).ref_time())]
		pub fn create_course(
			origin: OriginFor<T>,
			title: Vec<u8>,
			description: Vec<u8>,
		) -> DispatchResult {
			let who = ensure_signed(origin)?;

			// Validate input lengths
			ensure!(
				title.len() <= T::MaxTextLength::get() as usize,
				Error::<T>::TextTooLong
			);
			ensure!(
				description.len() <= T::MaxTextLength::get() as usize,
				Error::<T>::TextTooLong
			);

			let course_id = Self::next_course_id();
			let now = Self::current_timestamp();

			let course = Course {
				id: course_id,
				title,
				description,
				instructor: who.clone(),
				classes: Vec::new(),
				created_at: now,
				updated_at: now,
			};

			Courses::<T>::insert(&course_id, &course);
			NextCourseId::<T>::put(course_id + 1);

			Self::deposit_event(Event::CourseCreated {
				course_id,
				instructor: who,
			});

			Ok(())
		}

		/// Create a new class
		#[pallet::call_index(1)]
		#[pallet::weight(10_000 + T::DbWeight::get().writes(2).ref_time())]
		pub fn create_class(
			origin: OriginFor<T>,
			title: Vec<u8>,
			description: Vec<u8>,
			course_id: Option<CourseId>,
		) -> DispatchResult {
			let who = ensure_signed(origin)?;

			// Validate input lengths
			ensure!(
				title.len() <= T::MaxTextLength::get() as usize,
				Error::<T>::TextTooLong
			);
			ensure!(
				description.len() <= T::MaxTextLength::get() as usize,
				Error::<T>::TextTooLong
			);

			// If course_id is provided, validate it exists and check authorization
			if let Some(cid) = course_id {
				let mut course = Self::courses(&cid).ok_or(Error::<T>::CourseNotFound)?;
				ensure!(course.instructor == who, Error::<T>::NotAuthorized);
				ensure!(
					course.classes.len() < T::MaxClassesPerCourse::get() as usize,
					Error::<T>::TooManyClasses
				);

				let class_id = Self::next_class_id();
				course.classes.push(class_id);
				course.updated_at = Self::current_timestamp();
				Courses::<T>::insert(&cid, &course);
			}

			let class_id = Self::next_class_id();
			let now = Self::current_timestamp();

			let class = Class {
				id: class_id,
				course_id,
				title,
				description,
				instructor: who.clone(),
				tutorials: Vec::new(),
				interactions: Vec::new(),
				created_at: now,
				updated_at: now,
			};

			Classes::<T>::insert(&class_id, &class);
			NextClassId::<T>::put(class_id + 1);

			Self::deposit_event(Event::ClassCreated {
				class_id,
				instructor: who,
				course_id,
			});

			Ok(())
		}

		/// Create a new tutorial session
		#[pallet::call_index(2)]
		#[pallet::weight(10_000 + T::DbWeight::get().writes(2).ref_time())]
		pub fn create_tutorial_session(
			origin: OriginFor<T>,
			title: Vec<u8>,
			description: Vec<u8>,
			student: T::AccountId,
			session_type: SessionType,
			class_id: Option<ClassId>,
		) -> DispatchResult {
			let who = ensure_signed(origin)?;

			// Validate input lengths
			ensure!(
				title.len() <= T::MaxTextLength::get() as usize,
				Error::<T>::TextTooLong
			);
			ensure!(
				description.len() <= T::MaxTextLength::get() as usize,
				Error::<T>::TextTooLong
			);

			// If class_id is provided, validate it exists and update it
			if let Some(cid) = class_id {
				let mut class = Self::classes(&cid).ok_or(Error::<T>::ClassNotFound)?;
				let tutorial_id = Self::next_tutorial_id();
				class.tutorials.push(tutorial_id);
				class.updated_at = Self::current_timestamp();
				Classes::<T>::insert(&cid, &class);
			}

			let tutorial_id = Self::next_tutorial_id();
			let now = Self::current_timestamp();

			let tutorial = TutorialSession {
				id: tutorial_id,
				class_id,
				title,
				description,
				tutor: who.clone(),
				student: student.clone(),
				session_type,
				interactions: Vec::new(),
				started_at: now,
				ended_at: None,
			};

			TutorialSessions::<T>::insert(&tutorial_id, &tutorial);
			NextTutorialId::<T>::put(tutorial_id + 1);

			Self::deposit_event(Event::TutorialSessionCreated {
				tutorial_id,
				tutor: who,
				student,
			});

			Ok(())
		}

		/// End a tutorial session
		#[pallet::call_index(3)]
		#[pallet::weight(10_000 + T::DbWeight::get().writes(1).ref_time())]
		pub fn end_tutorial_session(
			origin: OriginFor<T>,
			tutorial_id: TutorialId,
		) -> DispatchResult {
			let who = ensure_signed(origin)?;

			let mut tutorial = Self::tutorial_sessions(&tutorial_id)
				.ok_or(Error::<T>::TutorialSessionNotFound)?;

			// Check authorization (tutor or student can end session)
			ensure!(
				tutorial.tutor == who || tutorial.student == who,
				Error::<T>::NotAuthorized
			);

			// Check if session is already ended
			ensure!(tutorial.ended_at.is_none(), Error::<T>::SessionAlreadyEnded);

			tutorial.ended_at = Some(Self::current_timestamp());
			TutorialSessions::<T>::insert(&tutorial_id, &tutorial);

			Self::deposit_event(Event::TutorialSessionEnded { tutorial_id });

			Ok(())
		}

		/// Update course information
		#[pallet::call_index(5)]
		#[pallet::weight(10_000 + T::DbWeight::get().writes(1).ref_time())]
		pub fn update_course(
			origin: OriginFor<T>,
			course_id: CourseId,
			title: Option<Vec<u8>>,
			description: Option<Vec<u8>>,
		) -> DispatchResult {
			let who = ensure_signed(origin)?;

			let mut course = Self::courses(&course_id).ok_or(Error::<T>::CourseNotFound)?;
			ensure!(course.instructor == who, Error::<T>::NotAuthorized);

			if let Some(new_title) = title {
				ensure!(
					new_title.len() <= T::MaxTextLength::get() as usize,
					Error::<T>::TextTooLong
				);
				course.title = new_title;
			}

			if let Some(new_description) = description {
				ensure!(
					new_description.len() <= T::MaxTextLength::get() as usize,
					Error::<T>::TextTooLong
				);
				course.description = new_description;
			}

			course.updated_at = Self::current_timestamp();
			Courses::<T>::insert(&course_id, &course);

			Ok(())
		}

		/// Update class information
		#[pallet::call_index(6)]
		#[pallet::weight(10_000 + T::DbWeight::get().writes(1).ref_time())]
		pub fn update_class(
			origin: OriginFor<T>,
			class_id: ClassId,
			title: Option<Vec<u8>>,
			description: Option<Vec<u8>>,
		) -> DispatchResult {
			let who = ensure_signed(origin)?;

			let mut class = Self::classes(&class_id).ok_or(Error::<T>::ClassNotFound)?;
			ensure!(class.instructor == who, Error::<T>::NotAuthorized);

			if let Some(new_title) = title {
				ensure!(
					new_title.len() <= T::MaxTextLength::get() as usize,
					Error::<T>::TextTooLong
				);
				class.title = new_title;
			}

			if let Some(new_description) = description {
				ensure!(
					new_description.len() <= T::MaxTextLength::get() as usize,
					Error::<T>::TextTooLong
				);
				class.description = new_description;
			}

			class.updated_at = Self::current_timestamp();
			Classes::<T>::insert(&class_id, &class);

			Ok(())
		}
	}

	impl<T: Config> Pallet<T> {
		/// Get current timestamp
		fn current_timestamp() -> u64 {
			// In a real implementation, this would get the current block timestamp
			// For now, we'll use block number as a simple timestamp
			<frame_system::Pallet<T>>::block_number().saturated_into::<u64>()
		}

		/// Validate xAPI statement structure
		fn validate_xapi_statement(
			actor: &Actor<T::AccountId>,
			verb: &Verb,
			object: &Object,
		) -> DispatchResult {
			// Validate actor
			ensure!(!actor.account.encode().is_empty(), Error::<T>::InvalidXAPIStructure);

			// Validate verb
			ensure!(!verb.id.is_empty(), Error::<T>::InvalidXAPIStructure);
			ensure!(!verb.display.is_empty(), Error::<T>::InvalidXAPIStructure);

			// Validate object
			ensure!(!object.id.is_empty(), Error::<T>::InvalidXAPIStructure);

			Ok(())
		}

		/// Validate evidence attachments
		fn validate_evidence(evidence: &Vec<Evidence>) -> DispatchResult {
			for item in evidence {
				// Ensure content is not empty
				ensure!(!item.content.is_empty(), Error::<T>::InvalidXAPIStructure);
				
				// Validate content length based on type
				match item.evidence_type {
					EvidenceType::Text => {
						ensure!(
							item.content.len() <= T::MaxTextLength::get() as usize,
							Error::<T>::TextTooLong
						);
					},
					EvidenceType::Url => {
						// Basic URL validation - should start with http/https
						let content_str = sp_std::str::from_utf8(&item.content)
							.map_err(|_| Error::<T>::InvalidXAPIStructure)?;
						ensure!(
							content_str.starts_with("http://") || content_str.starts_with("https://"),
							Error::<T>::InvalidXAPIStructure
						);
					},
					EvidenceType::FileHash => {
						// File hashes should be reasonable length (e.g., IPFS hash)
						ensure!(
							item.content.len() >= 32 && item.content.len() <= 128,
							Error::<T>::InvalidXAPIStructure
						);
					},
					_ => {
						// For other types, just ensure reasonable size limits
						ensure!(
							item.content.len() <= 1024 * 1024, // 1MB limit
							Error::<T>::TextTooLong
						);
					}
				}
			}
			Ok(())
		}

		/// Get interactions by tutorial session
		pub fn get_interactions_by_tutorial(tutorial_id: TutorialId) -> Vec<LearningInteraction<T::AccountId>> {
			if let Some(tutorial) = Self::tutorial_sessions(tutorial_id) {
				tutorial.interactions
					.iter()
					.filter_map(|&id| Self::interactions(id))
					.collect()
			} else {
				Vec::new()
			}
		}

		/// Get interactions by class
		pub fn get_interactions_by_class(class_id: ClassId) -> Vec<LearningInteraction<T::AccountId>> {
			if let Some(class) = Self::classes(class_id) {
				class.interactions
					.iter()
					.filter_map(|&id| Self::interactions(id))
					.collect()
			} else {
				Vec::new()
			}
		}

		/// Get all interactions for a user
		pub fn get_user_interactions(user: &T::AccountId) -> Vec<LearningInteraction<T::AccountId>> {
			let mut interactions = Vec::new();
			let next_id = Self::next_interaction_id();
			
			for id in 0..next_id {
				if let Some(interaction) = Self::interactions(id) {
					if interaction.actor.account == *user {
						interactions.push(interaction);
					}
				}
			}
			
			interactions
		}

		/// Create common xAPI verbs
		pub fn create_verb(verb_type: &str) -> Verb {
			let mut display = BTreeMap::new();
			
			match verb_type {
				"experienced" => {
					display.insert(b"en".to_vec(), b"experienced".to_vec());
					display.insert(b"es".to_vec(), b"experimentó".to_vec());
					Verb {
						id: b"http://adlnet.gov/expapi/verbs/experienced".to_vec(),
						display,
					}
				},
				"completed" => {
					display.insert(b"en".to_vec(), b"completed".to_vec());
					display.insert(b"es".to_vec(), b"completó".to_vec());
					Verb {
						id: b"http://adlnet.gov/expapi/verbs/completed".to_vec(),
						display,
					}
				},
				"answered" => {
					display.insert(b"en".to_vec(), b"answered".to_vec());
					display.insert(b"es".to_vec(), b"respondió".to_vec());
					Verb {
						id: b"http://adlnet.gov/expapi/verbs/answered".to_vec(),
						display,
					}
				},
				"asked" => {
					display.insert(b"en".to_vec(), b"asked".to_vec());
					display.insert(b"es".to_vec(), b"preguntó".to_vec());
					Verb {
						id: b"http://adlnet.gov/expapi/verbs/asked".to_vec(),
						display,
					}
				},
				_ => {
					display.insert(b"en".to_vec(), verb_type.as_bytes().to_vec());
					Verb {
						id: format!("http://keiko.network/verbs/{}", verb_type).as_bytes().to_vec(),
						display,
					}
				}
			}
		}

		/// Create common xAPI objects
		pub fn create_activity_object(activity_id: &str, name: &str, description: &str) -> Object {
			let mut name_map = BTreeMap::new();
			name_map.insert(b"en".to_vec(), name.as_bytes().to_vec());
			
			let mut desc_map = BTreeMap::new();
			desc_map.insert(b"en".to_vec(), description.as_bytes().to_vec());

			Object {
				object_type: ObjectType::Activity,
				id: activity_id.as_bytes().to_vec(),
				definition: Some(ActivityDefinition {
					name: Some(name_map),
					description: Some(desc_map),
					activity_type: Some(b"http://adlnet.gov/expapi/activities/lesson".to_vec()),
				}),
			}
		}

		/// Create a question interaction
		pub fn create_question_interaction(
			student: T::AccountId,
			question_text: &str,
			topic: &str,
		) -> (Actor<T::AccountId>, Verb, Object, InteractionCategory, Vec<Evidence>) {
			let actor = Actor {
				account: student,
				name: None,
				mbox: None,
			};

			let verb = Self::create_verb("asked");
			let object = Self::create_activity_object(
				&format!("http://keiko.network/question/{}", topic),
				&format!("Question about {}", topic),
				question_text,
			);

			let evidence = vec![Evidence {
				evidence_type: EvidenceType::Text,
				content: question_text.as_bytes().to_vec(),
				description: Some(b"Student question".to_vec()),
				mime_type: Some(b"text/plain".to_vec()),
			}];

			(actor, verb, object, InteractionCategory::Question, evidence)
		}

		/// Create an answer interaction
		pub fn create_answer_interaction(
			responder: T::AccountId,
			answer_text: &str,
			question_id: &str,
		) -> (Actor<T::AccountId>, Verb, Object, InteractionCategory, Vec<Evidence>) {
			let actor = Actor {
				account: responder,
				name: None,
				mbox: None,
			};

			let verb = Self::create_verb("answered");
			let object = Self::create_activity_object(
				&format!("http://keiko.network/answer/{}", question_id),
				"Answer to question",
				answer_text,
			);

			let evidence = vec![Evidence {
				evidence_type: EvidenceType::Text,
				content: answer_text.as_bytes().to_vec(),
				description: Some(b"Answer provided".to_vec()),
				mime_type: Some(b"text/plain".to_vec()),
			}];

			(actor, verb, object, InteractionCategory::Answer, evidence)
		}

		/// Create an exercise interaction
		pub fn create_exercise_interaction(
			student: T::AccountId,
			exercise_name: &str,
			result: Option<Result>,
		) -> (Actor<T::AccountId>, Verb, Object, InteractionCategory, Vec<Evidence>) {
			let actor = Actor {
				account: student,
				name: None,
				mbox: None,
			};

			let verb = Self::create_verb("completed");
			let object = Self::create_activity_object(
				&format!("http://keiko.network/exercise/{}", exercise_name),
				exercise_name,
				&format!("Exercise: {}", exercise_name),
			);

			(actor, verb, object, InteractionCategory::Exercise, Vec::new())
		}

		/// Get interactions by category
		pub fn get_interactions_by_category(category: InteractionCategory) -> Vec<LearningInteraction<T::AccountId>> {
			let mut interactions = Vec::new();
			let next_id = Self::next_interaction_id();
			
			for id in 0..next_id {
				if let Some(interaction) = Self::interactions(id) {
					if interaction.category == category {
						interactions.push(interaction);
					}
				}
			}
			
			interactions
		}

		/// Get interactions with evidence
		pub fn get_interactions_with_evidence() -> Vec<LearningInteraction<T::AccountId>> {
			let mut interactions = Vec::new();
			let next_id = Self::next_interaction_id();
			
			for id in 0..next_id {
				if let Some(interaction) = Self::interactions(id) {
					if !interaction.evidence.is_empty() {
						interactions.push(interaction);
					}
				}
			}
			
			interactions
		}

		/// Get complete course hierarchy with all classes and tutorials
		pub fn get_course_hierarchy(course_id: CourseId) -> Option<(Course<T::AccountId>, Vec<(Class<T::AccountId>, Vec<TutorialSession<T::AccountId>>)>)> {
			if let Some(course) = Self::courses(course_id) {
				let mut classes_with_tutorials = Vec::new();
				
				for &class_id in &course.classes {
					if let Some(class) = Self::classes(class_id) {
						let mut tutorials = Vec::new();
						for &tutorial_id in &class.tutorials {
							if let Some(tutorial) = Self::tutorial_sessions(tutorial_id) {
								tutorials.push(tutorial);
							}
						}
						classes_with_tutorials.push((class, tutorials));
					}
				}
				
				Some((course, classes_with_tutorials))
			} else {
				None
			}
		}

		/// Get all courses for an instructor
		pub fn get_instructor_courses(instructor: &T::AccountId) -> Vec<Course<T::AccountId>> {
			let mut courses = Vec::new();
			let next_id = Self::next_course_id();
			
			for id in 0..next_id {
				if let Some(course) = Self::courses(id) {
					if course.instructor == *instructor {
						courses.push(course);
					}
				}
			}
			
			courses
		}

		/// Get all classes for an instructor
		pub fn get_instructor_classes(instructor: &T::AccountId) -> Vec<Class<T::AccountId>> {
			let mut classes = Vec::new();
			let next_id = Self::next_class_id();
			
			for id in 0..next_id {
				if let Some(class) = Self::classes(id) {
					if class.instructor == *instructor {
						classes.push(class);
					}
				}
			}
			
			classes
		}

		/// Get all tutorial sessions for a user (as tutor or student)
		pub fn get_user_tutorials(user: &T::AccountId) -> Vec<TutorialSession<T::AccountId>> {
			let mut tutorials = Vec::new();
			let next_id = Self::next_tutorial_id();
			
			for id in 0..next_id {
				if let Some(tutorial) = Self::tutorial_sessions(id) {
					if tutorial.tutor == *user || tutorial.student == *user {
						tutorials.push(tutorial);
					}
				}
			}
			
			tutorials
		}

		/// Get learning path for a student (chronological view of all learning activities)
		pub fn get_student_learning_path(student: &T::AccountId) -> Vec<(u64, String, Vec<InteractionId>)> {
			let mut path = Vec::new();
			
			// Get all tutorials where user is a student
			let tutorials = Self::get_user_tutorials(student);
			for tutorial in tutorials {
				if tutorial.student == *student {
					let title = String::from_utf8_lossy(&tutorial.title).to_string();
					path.push((tutorial.started_at, format!("Tutorial: {}", title), tutorial.interactions));
				}
			}
			
			// Get all classes where user has direct interactions
			let next_class_id = Self::next_class_id();
			for id in 0..next_class_id {
				if let Some(class) = Self::classes(id) {
					let user_interactions: Vec<InteractionId> = class.interactions
						.iter()
						.filter_map(|&interaction_id| {
							Self::interactions(interaction_id).and_then(|interaction| {
								if interaction.actor.account == *student {
									Some(interaction_id)
								} else {
									None
								}
							})
						})
						.collect();
					
					if !user_interactions.is_empty() {
						let title = String::from_utf8_lossy(&class.title).to_string();
						path.push((class.created_at, format!("Class: {}", title), user_interactions));
					}
				}
			}
			
			// Sort by timestamp
			path.sort_by(|a, b| a.0.cmp(&b.0));
			path
		}

		/// Get statistics for a course
		pub fn get_course_stats(course_id: CourseId) -> Option<(u32, u32, u32)> {
			if let Some(course) = Self::courses(course_id) {
				let num_classes = course.classes.len() as u32;
				let mut num_tutorials = 0u32;
				let mut num_interactions = 0u32;
				
				for &class_id in &course.classes {
					if let Some(class) = Self::classes(class_id) {
						num_tutorials += class.tutorials.len() as u32;
						num_interactions += class.interactions.len() as u32;
						
						for &tutorial_id in &class.tutorials {
							if let Some(tutorial) = Self::tutorial_sessions(tutorial_id) {
								num_interactions += tutorial.interactions.len() as u32;
							}
						}
					}
				}
				
				Some((num_classes, num_tutorials, num_interactions))
			} else {
				None
			}
		}
	}
}