// Business Source License 1.1
// 
// Licensed Work: keiko-dapp Version 0.0.1 or later.
// The Licensed Work is (c) 2025 Luis Andrés Peña Castillo
// 
// For full license terms, see LICENSE file in the repository root.

use crate::{mock::*, Error, Event};
use frame_support::{assert_noop, assert_ok, traits::Get};

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