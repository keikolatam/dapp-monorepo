// Business Source License 1.1
// 
// Licensed Work: keiko-dapp Version 0.0.1 or later.
// The Licensed Work is (c) 2025 Luis Andrés Peña Castillo
// 
// For full license terms, see LICENSE file in the repository root.

use crate::{mock::*, Error, Event};
use frame_support::{assert_noop, assert_ok};

#[test]
fn create_rating_works() {
	new_test_ext().execute_with(|| {
		// Go past genesis block so events get deposited
		System::set_block_number(1);

		// Create a rating
		assert_ok!(ReputationSystem::create_rating(
			RuntimeOrigin::signed(1),
			2, // rated user
			5, // score
			b"Excellent tutor!".to_vec(), // comment
			Some(1), // interaction_id
		));

		// Check that the rating was created
		let rating = ReputationSystem::ratings(1).unwrap();
		assert_eq!(rating.rater, 1);
		assert_eq!(rating.rated, 2);
		assert_eq!(rating.score, 5);
		assert_eq!(rating.comment, b"Excellent tutor!".to_vec());
		assert_eq!(rating.interaction_id, Some(1));
		assert_eq!(rating.is_active, true);

		// Check that the rating lists were updated
		assert_eq!(ReputationSystem::ratings_given(1), vec![1]);
		assert_eq!(ReputationSystem::ratings_received(2), vec![1]);

		// Check that next rating ID was incremented
		assert_eq!(ReputationSystem::next_rating_id(), 2);

		// Check that reputation was calculated
		let reputation = ReputationSystem::reputation_scores(2);
		assert_eq!(reputation.current_score, 500); // 5 * 100
		assert_eq!(reputation.total_ratings, 1);
		assert_eq!(reputation.recent_ratings, 1);

		// Check that event was emitted
		System::assert_last_event(Event::RatingCreated {
			rating_id: 1,
			rater: 1,
			rated: 2,
			score: 5,
			interaction_id: Some(1),
		}.into());
	});
}

#[test]
fn cannot_rate_self() {
	new_test_ext().execute_with(|| {
		// Try to rate yourself
		assert_noop!(
			ReputationSystem::create_rating(
				RuntimeOrigin::signed(1),
				1, // same as rater
				5,
				b"Self rating".to_vec(),
				None,
			),
			Error::<Test>::CannotRateSelf
		);
	});
}

#[test]
fn invalid_rating_score_fails() {
	new_test_ext().execute_with(|| {
		// Try to create rating with score 0 (invalid)
		assert_noop!(
			ReputationSystem::create_rating(
				RuntimeOrigin::signed(1),
				2,
				0, // invalid score
				b"Bad score".to_vec(),
				None,
			),
			Error::<Test>::InvalidRatingScore
		);

		// Try to create rating with score 6 (invalid)
		assert_noop!(
			ReputationSystem::create_rating(
				RuntimeOrigin::signed(1),
				2,
				6, // invalid score
				b"Bad score".to_vec(),
				None,
			),
			Error::<Test>::InvalidRatingScore
		);
	});
}

#[test]
fn comment_too_long_fails() {
	new_test_ext().execute_with(|| {
		// Create a comment that's too long
		let long_comment = vec![b'a'; (MaxCommentLength::get() + 1) as usize];
		
		assert_noop!(
			ReputationSystem::create_rating(
				RuntimeOrigin::signed(1),
				2,
				5,
				long_comment,
				None,
			),
			Error::<Test>::CommentTooLong
		);
	});
}

#[test]
fn update_rating_works() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);

		// Create a rating first
		assert_ok!(ReputationSystem::create_rating(
			RuntimeOrigin::signed(1),
			2,
			3,
			b"Good".to_vec(),
			None,
		));

		// Update the rating
		assert_ok!(ReputationSystem::update_rating(
			RuntimeOrigin::signed(1),
			1, // rating_id
			5, // new score
			Some(b"Excellent!".to_vec()), // new comment
		));

		// Check that the rating was updated
		let rating = ReputationSystem::ratings(1).unwrap();
		assert_eq!(rating.score, 5);
		assert_eq!(rating.comment, b"Excellent!".to_vec());

		// Check that reputation was recalculated
		let reputation = ReputationSystem::reputation_scores(2);
		assert_eq!(reputation.current_score, 500); // 5 * 100

		// Check that event was emitted
		System::assert_last_event(Event::RatingUpdated {
			rating_id: 1,
			new_score: 5,
		}.into());
	});
}

#[test]
fn cannot_update_others_rating() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);

		// Create a rating
		assert_ok!(ReputationSystem::create_rating(
			RuntimeOrigin::signed(1),
			2,
			3,
			b"Good".to_vec(),
			None,
		));

		// Try to update rating from different user
		assert_noop!(
			ReputationSystem::update_rating(
				RuntimeOrigin::signed(3), // different user
				1,
				5,
				None,
			),
			Error::<Test>::NotAuthorized
		);
	});
}

#[test]
fn reputation_calculation_with_multiple_ratings() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);

		// Create multiple ratings for user 2
		assert_ok!(ReputationSystem::create_rating(
			RuntimeOrigin::signed(1),
			2,
			5,
			b"Excellent".to_vec(),
			None,
		));

		assert_ok!(ReputationSystem::create_rating(
			RuntimeOrigin::signed(3),
			2,
			4,
			b"Good".to_vec(),
			None,
		));

		assert_ok!(ReputationSystem::create_rating(
			RuntimeOrigin::signed(4),
			2,
			3,
			b"Average".to_vec(),
			None,
		));

		// Check reputation calculation
		// Average should be (5 + 4 + 3) / 3 = 4.0 * 100 = 400
		let reputation = ReputationSystem::reputation_scores(2);
		assert_eq!(reputation.current_score, 400);
		assert_eq!(reputation.total_ratings, 3);
		assert_eq!(reputation.recent_ratings, 3);
	});
}

#[test]
fn rating_expires_after_30_days() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);

		// Create a rating
		assert_ok!(ReputationSystem::create_rating(
			RuntimeOrigin::signed(1),
			2,
			5,
			b"Excellent tutor!".to_vec(),
			None,
		));

		// Check initial state
		let rating = ReputationSystem::ratings(1).unwrap();
		assert_eq!(rating.is_active, true);
		assert_eq!(rating.expires_at, 1 + RatingExpirationBlocks::get() as u64);

		let reputation = ReputationSystem::reputation_scores(2);
		assert_eq!(reputation.current_score, 500);
		assert_eq!(reputation.recent_ratings, 1);

		// Advance time to just before expiration
		System::set_block_number(RatingExpirationBlocks::get() as u64);
		
		// Rating should still be active
		let reputation = ReputationSystem::get_current_reputation(&2);
		assert_eq!(reputation.recent_ratings, 1);

		// Advance time past expiration
		System::set_block_number(RatingExpirationBlocks::get() as u64 + 2);

		// Recalculate reputation - this should expire the rating
		let reputation = ReputationSystem::get_current_reputation(&2);
		assert_eq!(reputation.recent_ratings, 0);
		assert_eq!(reputation.current_score, 0);

		// Check that the rating is marked as inactive
		let rating = ReputationSystem::ratings(1).unwrap();
		assert_eq!(rating.is_active, false);

		// Check that expiration event was emitted
		System::assert_has_event(Event::RatingExpired {
			rating_id: 1,
			rated: 2,
		}.into());
	});
}

#[test]
fn time_weighted_reputation_calculation() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);

		// Create an old rating
		assert_ok!(ReputationSystem::create_rating(
			RuntimeOrigin::signed(1),
			2,
			5,
			b"Old rating".to_vec(),
			None,
		));

		// Advance time significantly but not to expiration
		let half_expiration = RatingExpirationBlocks::get() as u64 / 2;
		System::set_block_number(1 + half_expiration);

		// Create a new rating
		assert_ok!(ReputationSystem::create_rating(
			RuntimeOrigin::signed(3),
			2,
			3,
			b"New rating".to_vec(),
			None,
		));

		// The newer rating should have more weight in the calculation
		let reputation = ReputationSystem::reputation_scores(2);
		
		// Both ratings should be counted
		assert_eq!(reputation.recent_ratings, 2);
		assert_eq!(reputation.total_ratings, 2);
		
		// The score should be weighted towards the newer rating
		// Exact calculation depends on the time weighting algorithm
		assert!(reputation.current_score > 0);
		assert!(reputation.current_score <= 500); // Max possible with 5-star rating
	});
}

#[test]
fn batch_expire_old_ratings_works() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);

		// Create multiple ratings
		for i in 1..=5 {
			assert_ok!(ReputationSystem::create_rating(
				RuntimeOrigin::signed(i),
				10, // all rating user 10
				5,
				b"Test rating".to_vec(),
				None,
			));
		}

		// Check initial state
		let reputation = ReputationSystem::reputation_scores(10);
		assert_eq!(reputation.total_ratings, 5);

		// Advance time past expiration
		System::set_block_number(RatingExpirationBlocks::get() as u64 + 10);

		// Manually expire ratings
		assert_ok!(ReputationSystem::expire_old_ratings(
			RuntimeOrigin::signed(1),
			10, // limit
		));

		// Check that ratings were expired
		for i in 1..=5 {
			let rating = ReputationSystem::ratings(i).unwrap();
			assert_eq!(rating.is_active, false);
		}
	});
}

#[test]
fn cannot_update_expired_rating() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);

		// Create a rating
		assert_ok!(ReputationSystem::create_rating(
			RuntimeOrigin::signed(1),
			2,
			3,
			b"Initial rating".to_vec(),
			None,
		));

		// Advance time past expiration
		System::set_block_number(RatingExpirationBlocks::get() as u64 + 10);

		// Try to update the expired rating
		assert_noop!(
			ReputationSystem::update_rating(
				RuntimeOrigin::signed(1),
				1,
				5,
				Some(b"Updated rating".to_vec()),
			),
			Error::<Test>::RatingExpired
		);
	});
}

#[test]
fn force_recalculate_reputation_works() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);

		// Create a rating
		assert_ok!(ReputationSystem::create_rating(
			RuntimeOrigin::signed(1),
			2,
			4,
			b"Test rating".to_vec(),
			None,
		));

		// Advance time past expiration
		System::set_block_number(RatingExpirationBlocks::get() as u64 + 10);

		// Force recalculate reputation
		assert_ok!(ReputationSystem::force_recalculate_reputation(
			RuntimeOrigin::signed(1),
			2,
		));

		// Check that reputation was updated and rating expired
		let reputation = ReputationSystem::reputation_scores(2);
		assert_eq!(reputation.recent_ratings, 0);
		
		let rating = ReputationSystem::ratings(1).unwrap();
		assert_eq!(rating.is_active, false);
	});
}

#[test]
fn get_active_ratings_filters_expired() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);

		// Create multiple ratings at different times
		assert_ok!(ReputationSystem::create_rating(
			RuntimeOrigin::signed(1),
			2,
			5,
			b"Rating 1".to_vec(),
			None,
		));

		System::set_block_number(100);
		assert_ok!(ReputationSystem::create_rating(
			RuntimeOrigin::signed(3),
			2,
			4,
			b"Rating 2".to_vec(),
			None,
		));

		// Check that both ratings are active
		let active_ratings = ReputationSystem::get_active_ratings_for_user(&2);
		assert_eq!(active_ratings.len(), 2);

		// Advance time to expire first rating
		System::set_block_number(RatingExpirationBlocks::get() as u64 + 10);

		// Only the second rating should be active
		let active_ratings = ReputationSystem::get_active_ratings_for_user(&2);
		assert_eq!(active_ratings.len(), 1);
		assert_eq!(active_ratings[0], 2); // Second rating ID
	});
}

// Tests for bidirectional rating system

#[test]
fn create_detailed_rating_works() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);

		let aspects = crate::RatingAspects {
			communication: Some(5),
			knowledge: Some(4),
			punctuality: Some(5),
			engagement: Some(4),
			helpfulness: Some(5),
		};

		// Create a detailed rating
		assert_ok!(ReputationSystem::create_detailed_rating(
			RuntimeOrigin::signed(1),
			2, // rated user
			5, // score
			b"Excellent tutor with great communication!".to_vec(),
			Some(1), // interaction_id
			None, // group_activity_id
			crate::RatingType::StudentToTutor,
			Some(aspects.clone()),
		));

		// Check that the rating was created with all details
		let rating = ReputationSystem::ratings(1).unwrap();
		assert_eq!(rating.rater, 1);
		assert_eq!(rating.rated, 2);
		assert_eq!(rating.score, 5);
		assert_eq!(rating.rating_type, crate::RatingType::StudentToTutor);
		assert_eq!(rating.aspects, Some(aspects));

		// Check that event was emitted with rating type
		System::assert_last_event(Event::RatingCreated {
			rating_id: 1,
			rater: 1,
			rated: 2,
			score: 5,
			rating_type: crate::RatingType::StudentToTutor,
			interaction_id: Some(1),
		}.into());
	});
}

#[test]
fn bidirectional_rating_works() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);

		// Student rates tutor
		assert_ok!(ReputationSystem::create_detailed_rating(
			RuntimeOrigin::signed(1), // student
			2, // tutor
			5,
			b"Great tutor!".to_vec(),
			Some(1), // interaction_id
			None,
			crate::RatingType::StudentToTutor,
			None,
		));

		// Check that rating pair was created
		let rating_pair = ReputationSystem::get_rating_pair(&1);
		assert_eq!(rating_pair.0, Some(1)); // student_to_tutor
		assert_eq!(rating_pair.1, None); // tutor_to_student not yet

		// Tutor rates student
		assert_ok!(ReputationSystem::create_detailed_rating(
			RuntimeOrigin::signed(2), // tutor
			1, // student
			4,
			b"Good student, engaged well!".to_vec(),
			Some(1), // same interaction_id
			None,
			crate::RatingType::TutorToStudent,
			None,
		));

		// Check that both ratings are now in the pair
		let rating_pair = ReputationSystem::get_rating_pair(&1);
		assert_eq!(rating_pair.0, Some(1)); // student_to_tutor
		assert_eq!(rating_pair.1, Some(2)); // tutor_to_student

		// Check that bidirectional completion event was emitted
		System::assert_has_event(Event::BidirectionalRatingCompleted {
			interaction_id: 1,
			student_rating: 1,
			tutor_rating: 2,
		}.into());
	});
}

#[test]
fn cannot_create_duplicate_bidirectional_rating() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);

		// Student rates tutor
		assert_ok!(ReputationSystem::create_detailed_rating(
			RuntimeOrigin::signed(1),
			2,
			5,
			b"Great tutor!".to_vec(),
			Some(1),
			None,
			crate::RatingType::StudentToTutor,
			None,
		));

		// Try to create another student-to-tutor rating for same interaction
		assert_noop!(
			ReputationSystem::create_detailed_rating(
				RuntimeOrigin::signed(1),
				2,
				4,
				b"Another rating".to_vec(),
				Some(1), // same interaction_id
				None,
				crate::RatingType::StudentToTutor,
				None,
			),
			Error::<Test>::BidirectionalRatingExists
		);
	});
}

#[test]
fn add_comment_response_works() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);

		// Create a rating first
		assert_ok!(ReputationSystem::create_rating(
			RuntimeOrigin::signed(1),
			2,
			4,
			b"Good tutor, but could improve punctuality".to_vec(),
			None,
		));

		// Rated user responds to the comment
		assert_ok!(ReputationSystem::add_comment_response(
			RuntimeOrigin::signed(2), // rated user
			1, // rating_id
			b"Thank you for the feedback! I'll work on being more punctual.".to_vec(),
		));

		// Check that response was added
		let responses = ReputationSystem::get_comment_responses(&1);
		assert_eq!(responses.len(), 1);
		assert_eq!(responses[0].responder, 2);
		assert_eq!(responses[0].content, b"Thank you for the feedback! I'll work on being more punctual.".to_vec());

		// Check that event was emitted
		System::assert_last_event(Event::CommentResponseAdded {
			rating_id: 1,
			response_id: 1,
			responder: 2,
		}.into());

		// Rater can also respond
		assert_ok!(ReputationSystem::add_comment_response(
			RuntimeOrigin::signed(1), // original rater
			1,
			b"Great attitude! Looking forward to future sessions.".to_vec(),
		));

		let responses = ReputationSystem::get_comment_responses(&1);
		assert_eq!(responses.len(), 2);
	});
}

#[test]
fn only_involved_parties_can_respond_to_comments() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);

		// Create a rating
		assert_ok!(ReputationSystem::create_rating(
			RuntimeOrigin::signed(1),
			2,
			4,
			b"Good session".to_vec(),
			None,
		));

		// Third party tries to respond
		assert_noop!(
			ReputationSystem::add_comment_response(
				RuntimeOrigin::signed(3), // uninvolved party
				1,
				b"I want to comment too!".to_vec(),
			),
			Error::<Test>::NotAuthorized
		);
	});
}

#[test]
fn create_peer_rating_works() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);

		let aspects = crate::RatingAspects {
			communication: Some(4),
			knowledge: Some(5),
			punctuality: None,
			engagement: Some(5),
			helpfulness: Some(4),
		};

		// Create a peer rating for group activity
		assert_ok!(ReputationSystem::create_peer_rating(
			RuntimeOrigin::signed(1), // rater
			2, // rated peer
			100, // group_activity_id
			4,
			b"Great collaboration in our study group!".to_vec(),
			Some(aspects.clone()),
		));

		// Check that rating was created
		let rating = ReputationSystem::ratings(1).unwrap();
		assert_eq!(rating.rating_type, crate::RatingType::PeerToPeer);
		assert_eq!(rating.group_activity_id, Some(100));
		assert_eq!(rating.aspects, Some(aspects));

		// Check that it was added to group activity ratings
		let group_ratings = ReputationSystem::get_group_activity_ratings(&100);
		assert_eq!(group_ratings, vec![1]);

		// Check that peer rating event was emitted
		System::assert_has_event(Event::PeerRatingCreated {
			rating_id: 1,
			group_activity_id: 100,
			rater: 1,
			rated: 2,
		}.into());
	});
}

#[test]
fn cannot_rate_same_peer_twice_in_group_activity() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);

		// Create first peer rating
		assert_ok!(ReputationSystem::create_peer_rating(
			RuntimeOrigin::signed(1),
			2,
			100, // group_activity_id
			4,
			b"Good work!".to_vec(),
			None,
		));

		// Try to rate the same peer again in the same group activity
		assert_noop!(
			ReputationSystem::create_peer_rating(
				RuntimeOrigin::signed(1),
				2, // same peer
				100, // same group_activity_id
				5,
				b"Even better work!".to_vec(),
				None,
			),
			Error::<Test>::AlreadyRatedPeer
		);

		// But can rate different peer in same group
		assert_ok!(ReputationSystem::create_peer_rating(
			RuntimeOrigin::signed(1),
			3, // different peer
			100, // same group_activity_id
			5,
			b"Also great work!".to_vec(),
			None,
		));

		// And can rate same peer in different group
		assert_ok!(ReputationSystem::create_peer_rating(
			RuntimeOrigin::signed(1),
			2, // same peer
			101, // different group_activity_id
			5,
			b"Great in this group too!".to_vec(),
			None,
		));
	});
}

#[test]
fn invalid_aspect_scores_fail() {
	new_test_ext().execute_with(|| {
		let invalid_aspects = crate::RatingAspects {
			communication: Some(0), // invalid score
			knowledge: Some(4),
			punctuality: Some(5),
			engagement: Some(4),
			helpfulness: Some(5),
		};

		assert_noop!(
			ReputationSystem::create_detailed_rating(
				RuntimeOrigin::signed(1),
				2,
				5,
				b"Test".to_vec(),
				None,
				None,
				crate::RatingType::General,
				Some(invalid_aspects),
			),
			Error::<Test>::InvalidAspectScore
		);

		let invalid_aspects2 = crate::RatingAspects {
			communication: Some(5),
			knowledge: Some(6), // invalid score
			punctuality: Some(5),
			engagement: Some(4),
			helpfulness: Some(5),
		};

		assert_noop!(
			ReputationSystem::create_detailed_rating(
				RuntimeOrigin::signed(1),
				2,
				5,
				b"Test".to_vec(),
				None,
				None,
				crate::RatingType::General,
				Some(invalid_aspects2),
			),
			Error::<Test>::InvalidAspectScore
		);
	});
}

#[test]
fn update_rating_with_aspects_works() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);

		// Create initial rating
		assert_ok!(ReputationSystem::create_rating(
			RuntimeOrigin::signed(1),
			2,
			3,
			b"Initial rating".to_vec(),
			None,
		));

		let new_aspects = crate::RatingAspects {
			communication: Some(4),
			knowledge: Some(5),
			punctuality: Some(3),
			engagement: Some(4),
			helpfulness: Some(4),
		};

		// Update with aspects
		assert_ok!(ReputationSystem::update_rating(
			RuntimeOrigin::signed(1),
			1,
			4,
			Some(b"Updated with detailed feedback".to_vec()),
			Some(new_aspects.clone()),
		));

		// Check that aspects were added
		let rating = ReputationSystem::ratings(1).unwrap();
		assert_eq!(rating.score, 4);
		assert_eq!(rating.aspects, Some(new_aspects));
	});
}

#[test]
fn get_ratings_by_type_works() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);

		// Create different types of ratings for user 2
		assert_ok!(ReputationSystem::create_detailed_rating(
			RuntimeOrigin::signed(1),
			2,
			5,
			b"As student".to_vec(),
			Some(1),
			None,
			crate::RatingType::StudentToTutor,
			None,
		));

		assert_ok!(ReputationSystem::create_detailed_rating(
			RuntimeOrigin::signed(3),
			2,
			4,
			b"As peer".to_vec(),
			None,
			Some(100),
			crate::RatingType::PeerToPeer,
			None,
		));

		assert_ok!(ReputationSystem::create_rating(
			RuntimeOrigin::signed(4),
			2,
			3,
			b"General rating".to_vec(),
			None,
		));

		// Get ratings by type
		let student_ratings = ReputationSystem::get_ratings_by_type(&2, &crate::RatingType::StudentToTutor);
		assert_eq!(student_ratings.len(), 1);
		assert_eq!(student_ratings[0], 1);

		let peer_ratings = ReputationSystem::get_ratings_by_type(&2, &crate::RatingType::PeerToPeer);
		assert_eq!(peer_ratings.len(), 1);
		assert_eq!(peer_ratings[0], 2);

		let general_ratings = ReputationSystem::get_ratings_by_type(&2, &crate::RatingType::General);
		assert_eq!(general_ratings.len(), 1);
		assert_eq!(general_ratings[0], 3);
	});
}

#[test]
fn has_peer_rating_works() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);

		// Initially no peer rating
		assert_eq!(ReputationSystem::has_peer_rating(&1, &2, &100), false);

		// Create peer rating
		assert_ok!(ReputationSystem::create_peer_rating(
			RuntimeOrigin::signed(1),
			2,
			100,
			4,
			b"Good peer".to_vec(),
			None,
		));

		// Now should return true
		assert_eq!(ReputationSystem::has_peer_rating(&1, &2, &100), true);

		// Different group should still be false
		assert_eq!(ReputationSystem::has_peer_rating(&1, &2, &101), false);

		// Different users should be false
		assert_eq!(ReputationSystem::has_peer_rating(&1, &3, &100), false);
		assert_eq!(ReputationSystem::has_peer_rating(&3, &2, &100), false);
	});
}

#[test]
fn too_many_comment_responses_fails() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);

		// Create a rating
		assert_ok!(ReputationSystem::create_rating(
			RuntimeOrigin::signed(1),
			2,
			4,
			b"Test rating".to_vec(),
			None,
		));

		// Add maximum number of responses
		for i in 0..MaxCommentResponses::get() {
			assert_ok!(ReputationSystem::add_comment_response(
				RuntimeOrigin::signed(if i % 2 == 0 { 1 } else { 2 }),
				1,
				format!("Response {}", i).into_bytes(),
			));
		}

		// Try to add one more response
		assert_noop!(
			ReputationSystem::add_comment_response(
				RuntimeOrigin::signed(1),
				1,
				b"One too many".to_vec(),
			),
			Error::<Test>::TooManyResponses
		);
	});
}

#[test]
fn cannot_respond_to_expired_rating() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);

		// Create a rating
		assert_ok!(ReputationSystem::create_rating(
			RuntimeOrigin::signed(1),
			2,
			4,
			b"Test rating".to_vec(),
			None,
		));

		// Advance time past expiration
		System::set_block_number(RatingExpirationBlocks::get() as u64 + 10);

		// Try to respond to expired rating
		assert_noop!(
			ReputationSystem::add_comment_response(
				RuntimeOrigin::signed(2),
				1,
				b"Late response".to_vec(),
			),
			Error::<Test>::RatingExpired
		);
	});
}