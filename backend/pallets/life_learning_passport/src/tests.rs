// Business Source License 1.1
// 
// Licensed Work: keiko-dapp Version 0.0.1 or later.
// The Licensed Work is (c) 2025 Luis Andrés Peña Castillo
// 
// For full license terms, see LICENSE file in the repository root.

use crate::{Error, Event, PrivacySettings, LearningProfile, LearningStyle, LearningPreferences};
use frame_support::{assert_noop, assert_ok, traits::Get};

// Minimal test that doesn't require full mock setup
#[test]
fn data_structures_compile() {
	// Test that our data structures can be created and used
	let privacy = PrivacySettings::default();
	assert_eq!(privacy.public_visibility, false);
	
	let learning_style = LearningStyle::default();
	assert_eq!(learning_style.visual + learning_style.auditory + learning_style.kinesthetic + learning_style.reading, 100);
	
	let profile = LearningProfile::default();
	assert_eq!(profile.auto_update_enabled, true);
	assert_eq!(profile.adaptive_history.len(), 0);
}

// Include mock-based tests only if we can compile them
#[cfg(test)]
mod mock_tests {
	use super::*;
	
	// We'll conditionally include the mock if it compiles
	#[cfg(feature = "mock-tests")]
	mod with_mock {
		use crate::mock::*;

		#[test]
		fn create_passport_works() {
			new_test_ext().execute_with(|| {
				System::set_block_number(1);
				
				// Create a new passport
				assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
				
				// Verify the passport was created
				let passport = LifeLearningPassport::passports(1).unwrap();
				assert_eq!(passport.owner, 1);
				assert_eq!(passport.interactions.len(), 0);
				assert_eq!(passport.learning_profile, None);
				assert_eq!(passport.version, 1);
				
				// Verify event was emitted
				System::assert_last_event(Event::PassportCreated { owner: 1 }.into());
			});
		}

		#[test]
		fn create_passport_fails_if_already_exists() {
			new_test_ext().execute_with(|| {
				System::set_block_number(1);
				
				// Create first passport
				assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
				
				// Try to create another passport for the same account
				assert_noop!(
					LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)),
					Error::<Test>::PassportAlreadyExists
				);
			});
		}

		#[test]
		fn update_privacy_settings_works() {
			new_test_ext().execute_with(|| {
				System::set_block_number(1);
				
				// Create passport first
				assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
				
				// Update privacy settings
				let new_privacy = PrivacySettings {
					public_visibility: true,
					interactions_visible: true,
					profile_visible: false,
					achievements_visible: true,
					trusted_accounts: Vec::new(),
				};
				
				assert_ok!(LifeLearningPassport::update_privacy_settings(
					RuntimeOrigin::signed(1),
					new_privacy.clone()
				));
				
				// Verify settings were updated
				let passport = LifeLearningPassport::passports(1).unwrap();
				assert_eq!(passport.privacy_settings, new_privacy);
				
				// Verify event was emitted
				System::assert_last_event(Event::PrivacySettingsUpdated { owner: 1 }.into());
			});
		}

		#[test]
		fn add_interaction_works() {
			new_test_ext().execute_with(|| {
				System::set_block_number(1);
				
				// Create passport first
				assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
				
				// Add an interaction
				let interaction_id = 42u64;
				assert_ok!(LifeLearningPassport::add_interaction(
					RuntimeOrigin::signed(1),
					interaction_id
				));
				
				// Verify interaction was added
				let passport = LifeLearningPassport::passports(1).unwrap();
				assert_eq!(passport.interactions.len(), 1);
				assert_eq!(passport.interactions[0], interaction_id);
				
				// Verify event was emitted
				System::assert_last_event(Event::InteractionAdded { 
					owner: 1, 
					interaction_id 
				}.into());
			});
		}
		
		#[test]
		fn passport_queries_work() {
			new_test_ext().execute_with(|| {
				System::set_block_number(1);
				
				// Create passport
				assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
				
				// Test helper queries
				assert!(LifeLearningPassport::has_passport(&1));
				assert!(!LifeLearningPassport::has_passport(&2));
				
				assert_eq!(LifeLearningPassport::get_interaction_count(&1), 0);
				assert_eq!(LifeLearningPassport::get_passport_version(&1), Some(1));
				assert!(!LifeLearningPassport::is_passport_public(&1)); // Default is private
				
				// Add interaction and verify count
				assert_ok!(LifeLearningPassport::add_interaction(RuntimeOrigin::signed(1), 42));
				assert_eq!(LifeLearningPassport::get_interaction_count(&1), 1);
			});
		}
		
		#[test]
		fn privacy_respects_settings() {
			new_test_ext().execute_with(|| {
				System::set_block_number(1);
				
				// Create passport
				assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
				assert_ok!(LifeLearningPassport::add_interaction(RuntimeOrigin::signed(1), 42));
				
				// By default, passport should not be publicly accessible
				let public_data = LifeLearningPassport::get_passport_data(&1, Some(&2));
				assert!(public_data.is_some());
				let data = public_data.unwrap();
				assert_eq!(data.interactions.len(), 0); // Should be filtered out
				
				// Owner should see all data
				let owner_data = LifeLearningPassport::get_passport_data(&1, Some(&1));
				assert!(owner_data.is_some());
				let data = owner_data.unwrap();
				assert_eq!(data.interactions.len(), 1); // Owner sees everything
				
				// Make passport public
				let public_privacy = PrivacySettings {
					public_visibility: true,
					interactions_visible: true,
					profile_visible: true,
					achievements_visible: true,
					trusted_accounts: Vec::new(),
				};
				assert_ok!(LifeLearningPassport::update_privacy_settings(
					RuntimeOrigin::signed(1),
					public_privacy
				));
				
				// Now external users should see interactions
				let public_data = LifeLearningPassport::get_passport_data(&1, Some(&2));
				assert!(public_data.is_some());
				let data = public_data.unwrap();
				assert_eq!(data.interactions.len(), 1); // Now visible
			});
		}
		
		#[test]
		fn shareable_links_work() {
			new_test_ext().execute_with(|| {
				System::set_block_number(1);
				
				// Create passport
				assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
				assert_ok!(LifeLearningPassport::add_interaction(RuntimeOrigin::signed(1), 42));
				
				// Create shareable link
				let permissions = SharePermissions {
					view_basic: true,
					view_interactions: true,
					view_profile: false,
					view_achievements: true,
					verify_authenticity: true,
				};
				
				assert_ok!(LifeLearningPassport::create_shareable_link(
					RuntimeOrigin::signed(1),
					permissions.clone(),
					Some(100) // Expires in 100 blocks
				));
				
				// Verify link was created (we'd need to check events in a real test)
				// For now, just verify the function doesn't error
			});
		}
		
		#[test]
		fn passport_verification_works() {
			new_test_ext().execute_with(|| {
				System::set_block_number(1);
				
				// Create passport
				assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
				
				let passport = LifeLearningPassport::passports(1).unwrap();
				
				// Verify authentic passport
				assert!(LifeLearningPassport::verify_passport_authenticity(&1, &passport));
				
				// Create modified passport (should fail verification)
				let mut fake_passport = passport.clone();
				fake_passport.version = 999;
				assert!(!LifeLearningPassport::verify_passport_authenticity(&1, &fake_passport));
			});
		}
		
		#[test]
		fn learning_profile_updates_work() {
			new_test_ext().execute_with(|| {
				System::set_block_number(1);
				
				// Create passport
				assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
				
				// Initially no profile
				let passport = LifeLearningPassport::passports(1).unwrap();
				assert!(passport.learning_profile.is_none());
				
				// Update a skill (should create profile)
				assert_ok!(LifeLearningPassport::update_skill(
					RuntimeOrigin::signed(1),
					b"mathematics".to_vec(),
					75,
					80,
					true // is_strength
				));
				
				// Verify profile was created with skill
				let passport = LifeLearningPassport::passports(1).unwrap();
				assert!(passport.learning_profile.is_some());
				let profile = passport.learning_profile.unwrap();
				assert_eq!(profile.strengths.len(), 1);
				assert_eq!(profile.strengths[0].domain, b"mathematics".to_vec());
				assert_eq!(profile.strengths[0].level, 75);
				assert_eq!(profile.strengths[0].confidence, 80);
			});
		}
		
		#[test]
		fn learning_style_validation_works() {
			new_test_ext().execute_with(|| {
				System::set_block_number(1);
				
				// Create passport
				assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
				
				// Create invalid learning style (doesn't sum to 100)
				let invalid_style = LearningStyle {
					visual: 30,
					auditory: 30,
					kinesthetic: 30,
					reading: 30, // Total = 120, should fail
				};
				
				let invalid_profile = LearningProfile {
					learning_style: invalid_style,
					preferences: LearningPreferences::default(),
					strengths: Vec::new(),
					areas_for_improvement: Vec::new(),
					last_assessment: 1,
					assessment_version: b"test".to_vec(),
					auto_update_enabled: true,
					adaptive_history: Vec::new(),
				};
				
				// Should fail validation
				assert_noop!(
					LifeLearningPassport::update_learning_profile(
						RuntimeOrigin::signed(1),
						invalid_profile
					),
					Error::<Test>::InvalidLearningStyle
				);
				
				// Create valid learning style
				let valid_style = LearningStyle {
					visual: 25,
					auditory: 25,
					kinesthetic: 25,
					reading: 25, // Total = 100, should work
				};
				
				let valid_profile = LearningProfile {
					learning_style: valid_style,
					preferences: LearningPreferences::default(),
					strengths: Vec::new(),
					areas_for_improvement: Vec::new(),
					last_assessment: 1,
					assessment_version: b"test".to_vec(),
					auto_update_enabled: true,
					adaptive_history: Vec::new(),
				};
				
				// Should succeed
				assert_ok!(LifeLearningPassport::update_learning_profile(
					RuntimeOrigin::signed(1),
					valid_profile
				));
			});
		}
		
		#[test]
		fn skill_level_validation_works() {
			new_test_ext().execute_with(|| {
				System::set_block_number(1);
				
				// Create passport
				assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
				
				// Try to add skill with invalid level
				assert_noop!(
					LifeLearningPassport::update_skill(
						RuntimeOrigin::signed(1),
						b"test".to_vec(),
						150, // Invalid level > 100
						50,
						true
					),
					Error::<Test>::InvalidSkillLevel
				);
				
				// Try to add skill with invalid confidence
				assert_noop!(
					LifeLearningPassport::update_skill(
						RuntimeOrigin::signed(1),
						b"test".to_vec(),
						50,
						150, // Invalid confidence > 100
						true
					),
					Error::<Test>::InvalidSkillLevel
				);
				
				// Valid skill should work
				assert_ok!(LifeLearningPassport::update_skill(
					RuntimeOrigin::signed(1),
					b"test".to_vec(),
					75,
					80,
					true
				));
			});
		}
		
		#[test]
		fn auto_update_toggle_works() {
			new_test_ext().execute_with(|| {
				System::set_block_number(1);
				
				// Create passport
				assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
				
				// Toggle auto update (should create profile with default settings)
				assert_ok!(LifeLearningPassport::toggle_auto_update(
					RuntimeOrigin::signed(1),
					false
				));
				
				// Verify profile was created and auto_update is disabled
				let passport = LifeLearningPassport::passports(1).unwrap();
				assert!(passport.learning_profile.is_some());
				let profile = passport.learning_profile.unwrap();
				assert!(!profile.auto_update_enabled);
				
				// Toggle back to enabled
				assert_ok!(LifeLearningPassport::toggle_auto_update(
					RuntimeOrigin::signed(1),
					true
				));
				
				let passport = LifeLearningPassport::passports(1).unwrap();
				let profile = passport.learning_profile.unwrap();
				assert!(profile.auto_update_enabled);
			});
		}
	}
}

#[test]
fn update_learning_profile_works() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);
		
		// Create passport first
		assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
		
		// Create a valid learning profile
		let profile = crate::LearningProfile {
			learning_style: crate::LearningStyle {
				visual: 40,
				auditory: 30,
				kinesthetic: 20,
				reading: 10,
			},
			preferences: crate::LearningPreferences::default(),
			strengths: vec![crate::Skill {
				domain: b"mathematics".to_vec(),
				level: 85,
				confidence: 90,
				last_updated: 1,
			}],
			areas_for_improvement: vec![crate::Skill {
				domain: b"writing".to_vec(),
				level: 60,
				confidence: 70,
				last_updated: 1,
			}],
			last_assessment: 1,
			assessment_version: b"v1.0".to_vec(),
		};
		
		assert_ok!(LifeLearningPassport::update_learning_profile(
			RuntimeOrigin::signed(1),
			profile.clone()
		));
		
		// Verify profile was updated
		let passport = LifeLearningPassport::passports(1).unwrap();
		assert_eq!(passport.learning_profile, Some(profile));
		
		// Verify event was emitted
		System::assert_last_event(Event::LearningProfileUpdated { owner: 1 }.into());
	});
}

#[test]
fn update_learning_profile_fails_with_invalid_style() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);
		
		// Create passport first
		assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
		
		// Create profile with invalid learning style (doesn't sum to 100)
		let profile = crate::LearningProfile {
			learning_style: crate::LearningStyle {
				visual: 40,
				auditory: 30,
				kinesthetic: 20,
				reading: 20, // Total = 110, should be 100
			},
			preferences: crate::LearningPreferences::default(),
			strengths: Vec::new(),
			areas_for_improvement: Vec::new(),
			last_assessment: 1,
			assessment_version: b"v1.0".to_vec(),
		};
		
		assert_noop!(
			LifeLearningPassport::update_learning_profile(RuntimeOrigin::signed(1), profile),
			Error::<Test>::InvalidLearningStyle
		);
	});
}

#[test]
fn update_learning_profile_fails_with_invalid_skill_level() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);
		
		// Create passport first
		assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
		
		// Create profile with invalid skill level
		let profile = crate::LearningProfile {
			learning_style: crate::LearningStyle {
				visual: 25,
				auditory: 25,
				kinesthetic: 25,
				reading: 25,
			},
			preferences: crate::LearningPreferences::default(),
			strengths: vec![crate::Skill {
				domain: b"mathematics".to_vec(),
				level: 150, // Invalid: > 100
				confidence: 90,
				last_updated: 1,
			}],
			areas_for_improvement: Vec::new(),
			last_assessment: 1,
			assessment_version: b"v1.0".to_vec(),
		};
		
		assert_noop!(
			LifeLearningPassport::update_learning_profile(RuntimeOrigin::signed(1), profile),
			Error::<Test>::InvalidSkillLevel
		);
	});
}

#[test]
fn get_passport_data_respects_privacy() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);
		
		// Create passport
		assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
		
		// Add interaction
		assert_ok!(LifeLearningPassport::add_interaction(RuntimeOrigin::signed(1), 42));
		
		// Set privacy to private
		let private_settings = PrivacySettings {
			public_visibility: false,
			interactions_visible: false,
			profile_visible: false,
			achievements_visible: false,
			trusted_accounts: Vec::new(),
		};
		assert_ok!(LifeLearningPassport::update_privacy_settings(
			RuntimeOrigin::signed(1),
			private_settings
		));
		
		// Owner can see their own data
		let owner_data = LifeLearningPassport::get_passport_data(&1, Some(&1)).unwrap();
		assert_eq!(owner_data.interactions.len(), 1);
		
		// External user cannot see private data
		let external_data = LifeLearningPassport::get_passport_data(&1, Some(&2)).unwrap();
		assert_eq!(external_data.interactions.len(), 0);
	});
}

#[test]
fn get_passport_data_allows_public_access() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);
		
		// Create passport
		assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
		
		// Add interaction
		assert_ok!(LifeLearningPassport::add_interaction(RuntimeOrigin::signed(1), 42));
		
		// Set privacy to public
		let public_settings = PrivacySettings {
			public_visibility: true,
			interactions_visible: true,
			profile_visible: true,
			achievements_visible: true,
			trusted_accounts: Vec::new(),
		};
		assert_ok!(LifeLearningPassport::update_privacy_settings(
			RuntimeOrigin::signed(1),
			public_settings
		));
		
		// External user can see public data
		let external_data = LifeLearningPassport::get_passport_data(&1, Some(&2)).unwrap();
		assert_eq!(external_data.interactions.len(), 1);
		assert_eq!(external_data.interactions[0], 42);
	});
}

#[test]
fn helper_functions_work() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);
		
		// Initially no passport
		assert!(!LifeLearningPassport::has_passport(&1));
		assert_eq!(LifeLearningPassport::get_interaction_count(&1), 0);
		assert_eq!(LifeLearningPassport::get_passport_creation_time(&1), None);
		
		// Create passport
		assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
		
		// Now passport exists
		assert!(LifeLearningPassport::has_passport(&1));
		assert_eq!(LifeLearningPassport::get_interaction_count(&1), 0);
		assert_eq!(LifeLearningPassport::get_passport_creation_time(&1), Some(1));
		
		// Add interactions
		assert_ok!(LifeLearningPassport::add_interaction(RuntimeOrigin::signed(1), 42));
		assert_ok!(LifeLearningPassport::add_interaction(RuntimeOrigin::signed(1), 43));
		
		// Check interaction count
		assert_eq!(LifeLearningPassport::get_interaction_count(&1), 2);
	});
}

#[test]
fn create_shareable_link_works() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);
		
		// Create passport first
		assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
		
		// Create shareable link
		let permissions = crate::SharePermissions {
			view_basic: true,
			view_interactions: true,
			view_profile: false,
			view_achievements: true,
			verify_authenticity: true,
		};
		
		assert_ok!(LifeLearningPassport::create_shareable_link(
			RuntimeOrigin::signed(1),
			permissions.clone(),
			Some(100) // expires in 100 blocks
		));
		
		// Verify link was created (we can't easily test the exact link_id without knowing the hash)
		// But we can verify the event was emitted
		let events = System::events();
		assert!(events.iter().any(|e| matches!(
			e.event,
			RuntimeEvent::LifeLearningPassport(Event::ShareableLinkCreated { owner: 1, .. })
		)));
	});
}

#[test]
fn create_shareable_link_fails_without_passport() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);
		
		let permissions = crate::SharePermissions::default();
		
		assert_noop!(
			LifeLearningPassport::create_shareable_link(
				RuntimeOrigin::signed(1),
				permissions,
				None
			),
			Error::<Test>::PassportNotFound
		);
	});
}

#[test]
fn revoke_shareable_link_works() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);
		
		// Create passport and link
		assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
		
		let permissions = crate::SharePermissions::default();
		assert_ok!(LifeLearningPassport::create_shareable_link(
			RuntimeOrigin::signed(1),
			permissions,
			Some(100)
		));
		
		// Get the link_id from the event
		let events = System::events();
		let link_created_event = events.iter().find(|e| matches!(
			e.event,
			RuntimeEvent::LifeLearningPassport(Event::ShareableLinkCreated { .. })
		)).unwrap();
		
		if let RuntimeEvent::LifeLearningPassport(Event::ShareableLinkCreated { link_id, .. }) = &link_created_event.event {
			// Revoke the link
			assert_ok!(LifeLearningPassport::revoke_shareable_link(
				RuntimeOrigin::signed(1),
				link_id.clone()
			));
			
			// Verify revocation event was emitted
			System::assert_last_event(Event::ShareableLinkRevoked { 
				owner: 1, 
				link_id: link_id.clone() 
			}.into());
		}
	});
}

#[test]
fn verify_passport_authenticity_works() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);
		
		// Create passport
		assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
		
		let passport = LifeLearningPassport::passports(1).unwrap();
		
		// Authentic passport should verify
		assert!(LifeLearningPassport::verify_passport_authenticity(&1, &passport));
		
		// Modified passport should not verify
		let mut fake_passport = passport.clone();
		fake_passport.created_at = 999;
		assert!(!LifeLearningPassport::verify_passport_authenticity(&1, &fake_passport));
		
		// Non-existent user should not verify
		assert!(!LifeLearningPassport::verify_passport_authenticity(&2, &passport));
	});
}

#[test]
fn get_passport_via_link_respects_permissions() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);
		
		// Create passport with data
		assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
		assert_ok!(LifeLearningPassport::add_interaction(RuntimeOrigin::signed(1), 42));
		
		// Create profile
		let profile = crate::LearningProfile::default();
		assert_ok!(LifeLearningPassport::update_learning_profile(
			RuntimeOrigin::signed(1),
			profile
		));
		
		// Create link with limited permissions
		let permissions = crate::SharePermissions {
			view_basic: true,
			view_interactions: false, // Don't allow viewing interactions
			view_profile: true,
			view_achievements: true,
			verify_authenticity: true,
		};
		
		assert_ok!(LifeLearningPassport::create_shareable_link(
			RuntimeOrigin::signed(1),
			permissions,
			Some(100)
		));
		
		// Get the link_id from the event
		let events = System::events();
		let link_created_event = events.iter().find(|e| matches!(
			e.event,
			RuntimeEvent::LifeLearningPassport(Event::ShareableLinkCreated { .. })
		)).unwrap();
		
		if let RuntimeEvent::LifeLearningPassport(Event::ShareableLinkCreated { link_id, .. }) = &link_created_event.event {
			// Get passport via link
			let shared_passport = LifeLearningPassport::get_passport_via_link(link_id).unwrap();
			
			// Should have profile but no interactions due to permissions
			assert!(shared_passport.learning_profile.is_some());
			assert_eq!(shared_passport.interactions.len(), 0);
		}
	});
}

#[test]
fn update_skill_works() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);
		
		// Create passport
		assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
		
		// Update a skill as strength
		assert_ok!(LifeLearningPassport::update_skill(
			RuntimeOrigin::signed(1),
			b"mathematics".to_vec(),
			85,
			90,
			true // is_strength
		));
		
		// Verify skill was added
		let passport = LifeLearningPassport::passports(1).unwrap();
		let profile = passport.learning_profile.unwrap();
		assert_eq!(profile.strengths.len(), 1);
		assert_eq!(profile.strengths[0].domain, b"mathematics".to_vec());
		assert_eq!(profile.strengths[0].level, 85);
		assert_eq!(profile.strengths[0].confidence, 90);
		
		// Update the same skill
		assert_ok!(LifeLearningPassport::update_skill(
			RuntimeOrigin::signed(1),
			b"mathematics".to_vec(),
			90,
			95,
			true
		));
		
		// Verify skill was updated, not duplicated
		let passport = LifeLearningPassport::passports(1).unwrap();
		let profile = passport.learning_profile.unwrap();
		assert_eq!(profile.strengths.len(), 1);
		assert_eq!(profile.strengths[0].level, 90);
		assert_eq!(profile.strengths[0].confidence, 95);
	});
}

#[test]
fn update_skill_fails_with_invalid_level() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);
		
		// Create passport
		assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
		
		// Try to update skill with invalid level
		assert_noop!(
			LifeLearningPassport::update_skill(
				RuntimeOrigin::signed(1),
				b"mathematics".to_vec(),
				150, // Invalid: > 100
				90,
				true
			),
			Error::<Test>::InvalidSkillLevel
		);
	});
}

#[test]
fn toggle_auto_update_works() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);
		
		// Create passport
		assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
		
		// Toggle auto-update off
		assert_ok!(LifeLearningPassport::toggle_auto_update(
			RuntimeOrigin::signed(1),
			false
		));
		
		// Verify auto-update is disabled
		let passport = LifeLearningPassport::passports(1).unwrap();
		let profile = passport.learning_profile.unwrap();
		assert!(!profile.auto_update_enabled);
		
		// Toggle back on
		assert_ok!(LifeLearningPassport::toggle_auto_update(
			RuntimeOrigin::signed(1),
			true
		));
		
		// Verify auto-update is enabled
		let passport = LifeLearningPassport::passports(1).unwrap();
		let profile = passport.learning_profile.unwrap();
		assert!(profile.auto_update_enabled);
	});
}

#[test]
fn record_adaptive_action_works() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);
		
		// Create passport
		assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
		
		// Record adaptive action
		assert_ok!(LifeLearningPassport::record_adaptive_action(
			RuntimeOrigin::signed(2), // Different user recording the action
			1, // Target user
			b"low_engagement".to_vec(),
			b"content_adjustment".to_vec(),
			75
		));
		
		// Verify action was recorded
		let passport = LifeLearningPassport::passports(1).unwrap();
		let profile = passport.learning_profile.unwrap();
		assert_eq!(profile.adaptive_history.len(), 1);
		assert_eq!(profile.adaptive_history[0].trigger, b"low_engagement".to_vec());
		assert_eq!(profile.adaptive_history[0].action, b"content_adjustment".to_vec());
		assert_eq!(profile.adaptive_history[0].effectiveness, 75);
	});
}

#[test]
fn update_profile_from_interaction_works() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);
		
		// Create passport with auto-update enabled
		assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
		
		// Update profile from interaction
		assert_ok!(LifeLearningPassport::update_profile_from_interaction(
			&1,
			b"mathematics",
			Some(85), // Good success rate
			Some(70)  // Medium difficulty
		));
		
		// Verify skill was added to areas for improvement
		let passport = LifeLearningPassport::passports(1).unwrap();
		let profile = passport.learning_profile.unwrap();
		assert_eq!(profile.areas_for_improvement.len(), 1);
		assert_eq!(profile.areas_for_improvement[0].domain, b"mathematics".to_vec());
		assert_eq!(profile.areas_for_improvement[0].level, 85);
	});
}

#[test]
fn get_learning_recommendations_works() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);
		
		// Create passport with skills
		assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
		
		// Add a weak skill (should be recommended for improvement)
		assert_ok!(LifeLearningPassport::update_skill(
			RuntimeOrigin::signed(1),
			b"writing".to_vec(),
			60, // Low level
			65,
			false // area for improvement
		));
		
		// Add a strong skill (should get advanced recommendation)
		assert_ok!(LifeLearningPassport::update_skill(
			RuntimeOrigin::signed(1),
			b"mathematics".to_vec(),
			85, // High level
			90,
			true // strength
		));
		
		// Get recommendations
		let recommendations = LifeLearningPassport::get_learning_recommendations(&1);
		
		// Should recommend working on writing and advanced mathematics
		assert_eq!(recommendations.len(), 2);
		assert!(recommendations.contains(&b"writing".to_vec()));
		assert!(recommendations.contains(&b"Advanced mathematics".to_vec()));
	});
}

#[test]
fn calculate_learning_progress_works() {
	new_test_ext().execute_with(|| {
		System::set_block_number(1);
		
		// Create passport
		assert_ok!(LifeLearningPassport::create_passport(RuntimeOrigin::signed(1)));
		
		// Initially no progress
		assert_eq!(LifeLearningPassport::calculate_learning_progress(&1), 0);
		
		// Add skills
		assert_ok!(LifeLearningPassport::update_skill(
			RuntimeOrigin::signed(1),
			b"mathematics".to_vec(),
			80,
			85,
			true
		));
		
		assert_ok!(LifeLearningPassport::update_skill(
			RuntimeOrigin::signed(1),
			b"writing".to_vec(),
			60,
			65,
			false
		));
		
		// Calculate progress (should be average: (80 + 60) / 2 = 70)
		assert_eq!(LifeLearningPassport::calculate_learning_progress(&1), 70);
	});
}