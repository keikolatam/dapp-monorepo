// Business Source License 1.1
//
// Licensed Work: keiko-dapp Version 0.0.1 or later.
// The Licensed Work is (c) 2025 Luis Andrés Peña Castillo
//
// For full license terms, see LICENSE file in the repository root.

use crate::{mock::*, Error, Event, SessionType};
use frame_support::{assert_noop, assert_ok, traits::Get};
use sp_std::collections::btree_map::BTreeMap;

#[test]
fn create_course_works() {
    new_test_ext().execute_with(|| {
        // Go past genesis block so events get deposited
        System::set_block_number(1);

        let title = b"Mathematics 101".to_vec();
        let description = b"Introduction to basic mathematics".to_vec();

        // Create a course
        assert_ok!(LearningInteractions::create_course(
            RuntimeOrigin::signed(1),
            title.clone(),
            description.clone()
        ));

        // Check that the course was stored
        let course = LearningInteractions::courses(0).unwrap();
        assert_eq!(course.title, title);
        assert_eq!(course.description, description);
        assert_eq!(course.instructor, 1);
        assert_eq!(course.id, 0);

        // Check that next course ID was incremented
        assert_eq!(LearningInteractions::next_course_id(), 1);

        // Assert that the correct event was deposited
        System::assert_last_event(
            Event::CourseCreated {
                course_id: 0,
                instructor: 1,
            }
            .into(),
        );
    });
}

#[test]
fn create_class_works() {
    new_test_ext().execute_with(|| {
        System::set_block_number(1);

        let title = b"Algebra Basics".to_vec();
        let description = b"Introduction to algebraic concepts".to_vec();

        // Create a class without a course
        assert_ok!(LearningInteractions::create_class(
            RuntimeOrigin::signed(1),
            title.clone(),
            description.clone(),
            None
        ));

        // Check that the class was stored
        let class = LearningInteractions::classes(0).unwrap();
        assert_eq!(class.title, title);
        assert_eq!(class.description, description);
        assert_eq!(class.instructor, 1);
        assert_eq!(class.course_id, None);

        // Check that next class ID was incremented
        assert_eq!(LearningInteractions::next_class_id(), 1);

        // Assert that the correct event was deposited
        System::assert_last_event(
            Event::ClassCreated {
                class_id: 0,
                instructor: 1,
                course_id: None,
            }
            .into(),
        );
    });
}

#[test]
fn create_class_with_course_works() {
    new_test_ext().execute_with(|| {
        System::set_block_number(1);

        // First create a course
        assert_ok!(LearningInteractions::create_course(
            RuntimeOrigin::signed(1),
            b"Mathematics 101".to_vec(),
            b"Introduction to basic mathematics".to_vec()
        ));

        let title = b"Algebra Basics".to_vec();
        let description = b"Introduction to algebraic concepts".to_vec();

        // Create a class within the course
        assert_ok!(LearningInteractions::create_class(
            RuntimeOrigin::signed(1),
            title.clone(),
            description.clone(),
            Some(0) // course_id
        ));

        // Check that the class was stored with course reference
        let class = LearningInteractions::classes(0).unwrap();
        assert_eq!(class.course_id, Some(0));

        // Check that the course was updated with the class
        let course = LearningInteractions::courses(0).unwrap();
        assert_eq!(course.classes, vec![0]);
    });
}

#[test]
fn create_tutorial_session_works() {
    new_test_ext().execute_with(|| {
        System::set_block_number(1);

        let title = b"Algebra Tutorial".to_vec();
        let description = b"One-on-one algebra tutoring session".to_vec();

        // Create a tutorial session
        assert_ok!(LearningInteractions::create_tutorial_session(
            RuntimeOrigin::signed(1), // tutor
            title.clone(),
            description.clone(),
            2, // student
            SessionType::Human,
            None // no class
        ));

        // Check that the tutorial session was stored
        let tutorial = LearningInteractions::tutorial_sessions(0).unwrap();
        assert_eq!(tutorial.title, title);
        assert_eq!(tutorial.description, description);
        assert_eq!(tutorial.tutor, 1);
        assert_eq!(tutorial.student, 2);
        assert_eq!(tutorial.session_type, SessionType::Human);
        assert_eq!(tutorial.class_id, None);
        assert_eq!(tutorial.ended_at, None);

        // Check that next tutorial ID was incremented
        assert_eq!(LearningInteractions::next_tutorial_id(), 1);

        // Assert that the correct event was deposited
        System::assert_last_event(
            Event::TutorialSessionCreated {
                tutorial_id: 0,
                tutor: 1,
                student: 2,
            }
            .into(),
        );
    });
}

#[test]
fn end_tutorial_session_works() {
    new_test_ext().execute_with(|| {
        System::set_block_number(1);

        // Create a tutorial session first
        assert_ok!(LearningInteractions::create_tutorial_session(
            RuntimeOrigin::signed(1), // tutor
            b"Algebra Tutorial".to_vec(),
            b"One-on-one algebra tutoring session".to_vec(),
            2, // student
            SessionType::Human,
            None
        ));

        System::set_block_number(2);

        // End the tutorial session
        assert_ok!(LearningInteractions::end_tutorial_session(
            RuntimeOrigin::signed(1), // tutor can end
            0                         // tutorial_id
        ));

        // Check that the tutorial session was updated
        let tutorial = LearningInteractions::tutorial_sessions(0).unwrap();
        assert_eq!(tutorial.ended_at, Some(2));

        // Assert that the correct event was deposited
        System::assert_last_event(Event::TutorialSessionEnded { tutorial_id: 0 }.into());
    });
}

#[test]
fn text_too_long_error() {
    new_test_ext().execute_with(|| {
        System::set_block_number(1);

        // Create a title that's too long
        let long_title = vec![b'a'; 1001]; // MaxTextLength is 1000

        // Should fail with TextTooLong error
        assert_noop!(
            LearningInteractions::create_course(
                RuntimeOrigin::signed(1),
                long_title,
                b"Description".to_vec()
            ),
            Error::<Test>::TextTooLong
        );
    });
}

#[test]
fn not_authorized_error() {
    new_test_ext().execute_with(|| {
        System::set_block_number(1);

        // Create a course with user 1
        assert_ok!(LearningInteractions::create_course(
            RuntimeOrigin::signed(1),
            b"Mathematics 101".to_vec(),
            b"Introduction to basic mathematics".to_vec()
        ));

        // Try to create a class in that course with user 2 (not authorized)
        assert_noop!(
            LearningInteractions::create_class(
                RuntimeOrigin::signed(2), // different user
                b"Algebra Basics".to_vec(),
                b"Introduction to algebraic concepts".to_vec(),
                Some(0) // course_id
            ),
            Error::<Test>::NotAuthorized
        );
    });
}

#[test]
fn course_not_found_error() {
    new_test_ext().execute_with(|| {
        System::set_block_number(1);

        // Try to create a class with non-existent course
        assert_noop!(
            LearningInteractions::create_class(
                RuntimeOrigin::signed(1),
                b"Algebra Basics".to_vec(),
                b"Introduction to algebraic concepts".to_vec(),
                Some(999) // non-existent course_id
            ),
            Error::<Test>::CourseNotFound
        );
    });
}

#[test]
fn session_already_ended_error() {
    new_test_ext().execute_with(|| {
        System::set_block_number(1);

        // Create and end a tutorial session
        assert_ok!(LearningInteractions::create_tutorial_session(
            RuntimeOrigin::signed(1),
            b"Algebra Tutorial".to_vec(),
            b"One-on-one algebra tutoring session".to_vec(),
            2,
            SessionType::Human,
            None
        ));

        assert_ok!(LearningInteractions::end_tutorial_session(
            RuntimeOrigin::signed(1),
            0
        ));

        // Try to end it again
        assert_noop!(
            LearningInteractions::end_tutorial_session(RuntimeOrigin::signed(1), 0),
            Error::<Test>::SessionAlreadyEnded
        );
    });
}

#[test]
fn create_interaction_works() {
    new_test_ext().execute_with(|| {
        System::set_block_number(1);

        // Create actor
        let actor = crate::Actor {
            account: 1,
            name: Some(b"John Doe".to_vec()),
            mbox: Some(b"john@example.com".to_vec()),
        };

        // Create verb
        let verb = LearningInteractions::create_verb("experienced");

        // Create object
        let object = LearningInteractions::create_activity_object(
            "http://example.com/course/algebra",
            "Algebra Lesson",
            "Basic algebra concepts",
        );

        // Create interaction
        assert_ok!(LearningInteractions::create_interaction(
            RuntimeOrigin::signed(1),
            actor.clone(),
            verb.clone(),
            object.clone(),
            None,
            None,
            crate::InteractionCategory::Experience,
            Vec::new(),
            None,
            None
        ));

        // Check that the interaction was stored
        let interaction = LearningInteractions::interactions(0).unwrap();
        assert_eq!(interaction.actor, actor);
        assert_eq!(interaction.verb, verb);
        assert_eq!(interaction.object, object);
        assert_eq!(interaction.id, 0);

        // Check that next interaction ID was incremented
        assert_eq!(LearningInteractions::next_interaction_id(), 1);

        // Assert that the correct event was deposited
        System::assert_last_event(
            Event::InteractionCreated {
                interaction_id: 0,
                actor: 1,
                category: crate::InteractionCategory::Experience,
            }
            .into(),
        );
    });
}

#[test]
fn create_interaction_with_tutorial_works() {
    new_test_ext().execute_with(|| {
        System::set_block_number(1);

        // First create a tutorial session
        assert_ok!(LearningInteractions::create_tutorial_session(
            RuntimeOrigin::signed(1),
            b"Algebra Tutorial".to_vec(),
            b"One-on-one algebra tutoring session".to_vec(),
            2,
            SessionType::Human,
            None
        ));

        // Create actor
        let actor = crate::Actor {
            account: 2, // student
            name: Some(b"Jane Student".to_vec()),
            mbox: None,
        };

        // Create verb and object
        let verb = LearningInteractions::create_verb("asked");
        let object = LearningInteractions::create_activity_object(
            "http://example.com/question/1",
            "Question about matrices",
            "Student asked about matrix multiplication",
        );

        // Create interaction within tutorial
        assert_ok!(LearningInteractions::create_interaction(
            RuntimeOrigin::signed(2), // student creates interaction
            actor,
            verb,
            object,
            None,
            None,
            crate::InteractionCategory::Question,
            Vec::new(),
            Some(0), // tutorial_id
            None
        ));

        // Check that the tutorial was updated with the interaction
        let tutorial = LearningInteractions::tutorial_sessions(0).unwrap();
        assert_eq!(tutorial.interactions, vec![0]);

        // Check that the interaction was stored
        let interaction = LearningInteractions::interactions(0).unwrap();
        assert_eq!(interaction.actor.account, 2);
    });
}

#[test]
fn invalid_xapi_structure_error() {
    new_test_ext().execute_with(|| {
        System::set_block_number(1);

        // Create actor with empty account (invalid)
        let actor = crate::Actor {
            account: 1,
            name: Some(b"John Doe".to_vec()),
            mbox: Some(b"john@example.com".to_vec()),
        };

        // Create verb with empty id (invalid)
        let verb = crate::Verb {
            id: Vec::new(),           // empty id
            display: BTreeMap::new(), // empty display
        };

        let object = LearningInteractions::create_activity_object(
            "http://example.com/course/algebra",
            "Algebra Lesson",
            "Basic algebra concepts",
        );

        // Should fail with InvalidXAPIStructure error
        assert_noop!(
            LearningInteractions::create_interaction(
                RuntimeOrigin::signed(1),
                actor,
                verb,
                object,
                None,
                None,
                crate::InteractionCategory::Experience,
                Vec::new(),
                None,
                None
            ),
            Error::<Test>::InvalidXAPIStructure
        );
    });
}

#[test]
fn not_authorized_to_create_interaction_error() {
    new_test_ext().execute_with(|| {
        System::set_block_number(1);

        // Create actor for user 1
        let actor = crate::Actor {
            account: 1,
            name: Some(b"John Doe".to_vec()),
            mbox: Some(b"john@example.com".to_vec()),
        };

        let verb = LearningInteractions::create_verb("experienced");
        let object = LearningInteractions::create_activity_object(
            "http://example.com/course/algebra",
            "Algebra Lesson",
            "Basic algebra concepts",
        );

        // Try to create interaction as user 2 for user 1's actor
        assert_noop!(
            LearningInteractions::create_interaction(
                RuntimeOrigin::signed(2), // different user
                actor,
                verb,
                object,
                None,
                None,
                crate::InteractionCategory::Experience,
                Vec::new(),
                None,
                None
            ),
            Error::<Test>::NotAuthorized
        );
    });
}

#[test]
fn course_hierarchy_works() {
    new_test_ext().execute_with(|| {
        System::set_block_number(1);

        // Create a course
        assert_ok!(LearningInteractions::create_course(
            RuntimeOrigin::signed(1),
            b"Mathematics 101".to_vec(),
            b"Introduction to basic mathematics".to_vec()
        ));

        // Create a class within the course
        assert_ok!(LearningInteractions::create_class(
            RuntimeOrigin::signed(1),
            b"Algebra Basics".to_vec(),
            b"Introduction to algebraic concepts".to_vec(),
            Some(0) // course_id
        ));

        // Create a tutorial session within the class
        assert_ok!(LearningInteractions::create_tutorial_session(
            RuntimeOrigin::signed(1),
            b"Algebra Tutorial".to_vec(),
            b"One-on-one algebra tutoring session".to_vec(),
            2, // student
            SessionType::Human,
            Some(0) // class_id
        ));

        // Get the complete hierarchy
        let hierarchy = LearningInteractions::get_course_hierarchy(0).unwrap();
        let (course, classes_with_tutorials) = hierarchy;

        assert_eq!(course.title, b"Mathematics 101".to_vec());
        assert_eq!(classes_with_tutorials.len(), 1);

        let (class, tutorials) = &classes_with_tutorials[0];
        assert_eq!(class.title, b"Algebra Basics".to_vec());
        assert_eq!(tutorials.len(), 1);
        assert_eq!(tutorials[0].title, b"Algebra Tutorial".to_vec());
    });
}

#[test]
fn get_instructor_courses_works() {
    new_test_ext().execute_with(|| {
        System::set_block_number(1);

        // Create courses with different instructors
        assert_ok!(LearningInteractions::create_course(
            RuntimeOrigin::signed(1),
            b"Mathematics 101".to_vec(),
            b"Introduction to basic mathematics".to_vec()
        ));

        assert_ok!(LearningInteractions::create_course(
            RuntimeOrigin::signed(1),
            b"Physics 101".to_vec(),
            b"Introduction to basic physics".to_vec()
        ));

        assert_ok!(LearningInteractions::create_course(
            RuntimeOrigin::signed(2),
            b"Chemistry 101".to_vec(),
            b"Introduction to basic chemistry".to_vec()
        ));

        // Get courses for instructor 1
        let instructor1_courses = LearningInteractions::get_instructor_courses(&1);
        assert_eq!(instructor1_courses.len(), 2);

        // Get courses for instructor 2
        let instructor2_courses = LearningInteractions::get_instructor_courses(&2);
        assert_eq!(instructor2_courses.len(), 1);
        assert_eq!(instructor2_courses[0].title, b"Chemistry 101".to_vec());
    });
}

#[test]
fn update_course_works() {
    new_test_ext().execute_with(|| {
        System::set_block_number(1);

        // Create a course
        assert_ok!(LearningInteractions::create_course(
            RuntimeOrigin::signed(1),
            b"Mathematics 101".to_vec(),
            b"Introduction to basic mathematics".to_vec()
        ));

        System::set_block_number(2);

        // Update the course
        assert_ok!(LearningInteractions::update_course(
            RuntimeOrigin::signed(1),
            0, // course_id
            Some(b"Advanced Mathematics 101".to_vec()),
            Some(b"Advanced introduction to mathematics".to_vec())
        ));

        // Check that the course was updated
        let course = LearningInteractions::courses(0).unwrap();
        assert_eq!(course.title, b"Advanced Mathematics 101".to_vec());
        assert_eq!(
            course.description,
            b"Advanced introduction to mathematics".to_vec()
        );
        assert_eq!(course.updated_at, 2);
    });
}

#[test]
fn create_interaction_with_evidence_works() {
    new_test_ext().execute_with(|| {
        System::set_block_number(1);

        // Create actor
        let actor = crate::Actor {
            account: 1,
            name: Some(b"John Doe".to_vec()),
            mbox: None,
        };

        // Create verb and object
        let verb = LearningInteractions::create_verb("answered");
        let object = LearningInteractions::create_activity_object(
            "http://example.com/exercise/1",
            "Math Exercise",
            "Solve quadratic equations",
        );

        // Create evidence
        let evidence = vec![
            crate::Evidence {
                evidence_type: crate::EvidenceType::Text,
                content: b"x = 2, y = 3".to_vec(),
                description: Some(b"Solution to the exercise".to_vec()),
                mime_type: Some(b"text/plain".to_vec()),
            },
            crate::Evidence {
                evidence_type: crate::EvidenceType::Url,
                content: b"https://example.com/solution.pdf".to_vec(),
                description: Some(b"Detailed solution PDF".to_vec()),
                mime_type: Some(b"application/pdf".to_vec()),
            },
        ];

        // Create interaction with evidence
        assert_ok!(LearningInteractions::create_interaction(
            RuntimeOrigin::signed(1),
            actor,
            verb,
            object,
            None,
            None,
            crate::InteractionCategory::Exercise,
            evidence.clone(),
            None,
            None
        ));

        // Check that the interaction was stored with evidence
        let interaction = LearningInteractions::interactions(0).unwrap();
        assert_eq!(interaction.evidence.len(), 2);
        assert_eq!(interaction.evidence[0].content, b"x = 2, y = 3".to_vec());
        assert_eq!(interaction.category, crate::InteractionCategory::Exercise);

        // Check that both events were emitted
        let events = System::events();
        assert_eq!(events.len(), 2);

        // First event should be InteractionCreated
        assert!(matches!(
            events[0].event,
            RuntimeEvent::LearningInteractions(Event::InteractionCreated { .. })
        ));

        // Second event should be InteractionWithEvidenceCreated
        assert!(matches!(
            events[1].event,
            RuntimeEvent::LearningInteractions(Event::InteractionWithEvidenceCreated {
                interaction_id: 0,
                evidence_count: 2
            })
        ));
    });
}

#[test]
fn invalid_evidence_url_error() {
    new_test_ext().execute_with(|| {
        System::set_block_number(1);

        let actor = crate::Actor {
            account: 1,
            name: Some(b"John Doe".to_vec()),
            mbox: None,
        };

        let verb = LearningInteractions::create_verb("experienced");
        let object = LearningInteractions::create_activity_object(
            "http://example.com/lesson",
            "Lesson",
            "Test lesson",
        );

        // Create invalid URL evidence
        let evidence = vec![crate::Evidence {
            evidence_type: crate::EvidenceType::Url,
            content: b"invalid-url".to_vec(), // Invalid URL format
            description: None,
            mime_type: None,
        }];

        // Should fail with InvalidXAPIStructure error
        assert_noop!(
            LearningInteractions::create_interaction(
                RuntimeOrigin::signed(1),
                actor,
                verb,
                object,
                None,
                None,
                crate::InteractionCategory::Experience,
                evidence,
                None,
                None
            ),
            Error::<Test>::InvalidXAPIStructure
        );
    });
}

#[test]
fn create_question_interaction_helper_works() {
    new_test_ext().execute_with(|| {
        System::set_block_number(1);

        // Use helper function to create question interaction
        let (actor, verb, object, category, evidence) =
            LearningInteractions::create_question_interaction(
                1,
                "What is the derivative of x^2?",
                "calculus",
            );

        assert_eq!(actor.account, 1);
        assert_eq!(verb.id, b"http://adlnet.gov/expapi/verbs/asked".to_vec());
        assert_eq!(category, crate::InteractionCategory::Question);
        assert_eq!(evidence.len(), 1);
        assert_eq!(evidence[0].evidence_type, crate::EvidenceType::Text);
        assert_eq!(
            evidence[0].content,
            b"What is the derivative of x^2?".to_vec()
        );

        // Create the interaction
        assert_ok!(LearningInteractions::create_interaction(
            RuntimeOrigin::signed(1),
            actor,
            verb,
            object,
            None,
            None,
            category,
            evidence,
            None,
            None
        ));

        // Verify it was stored correctly
        let interaction = LearningInteractions::interactions(0).unwrap();
        assert_eq!(interaction.category, crate::InteractionCategory::Question);
        assert_eq!(interaction.evidence.len(), 1);
    });
}

#[test]
fn get_interactions_by_category_works() {
    new_test_ext().execute_with(|| {
        System::set_block_number(1);

        // Create different types of interactions
        let (actor1, verb1, object1, category1, evidence1) =
            LearningInteractions::create_question_interaction(1, "Question 1", "math");

        let (actor2, verb2, object2, category2, evidence2) =
            LearningInteractions::create_answer_interaction(2, "Answer 1", "q1");

        assert_ok!(LearningInteractions::create_interaction(
            RuntimeOrigin::signed(1),
            actor1,
            verb1,
            object1,
            None,
            None,
            category1,
            evidence1,
            None,
            None
        ));

        assert_ok!(LearningInteractions::create_interaction(
            RuntimeOrigin::signed(2),
            actor2,
            verb2,
            object2,
            None,
            None,
            category2,
            evidence2,
            None,
            None
        ));

        // Get interactions by category
        let questions = LearningInteractions::get_interactions_by_category(
            crate::InteractionCategory::Question,
        );
        let answers =
            LearningInteractions::get_interactions_by_category(crate::InteractionCategory::Answer);

        assert_eq!(questions.len(), 1);
        assert_eq!(answers.len(), 1);
        assert_eq!(questions[0].actor.account, 1);
        assert_eq!(answers[0].actor.account, 2);
    });
}
