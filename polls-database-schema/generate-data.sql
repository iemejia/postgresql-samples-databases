-- =============================================================================
-- Data Generation Script for the Polls Database
-- =============================================================================
-- Inserts realistic sample data into all tables while respecting foreign key
-- constraints and unique indexes. Insert order follows dependency chain:
--   users -> poll -> poll_meta -> poll_question -> poll_answer
--
-- Generates:
--   10 users (3 are hosts)
--   6  polls
--   12 poll_meta entries
--   18 poll_questions
--   54 poll_answers
-- =============================================================================

BEGIN;

-- -------------------------------------------------------------------------
-- 1. Users
-- -------------------------------------------------------------------------
INSERT INTO users (id, firstName, lastName, email, passwordHash, host, registeredAt, lastLogin, intro, displayName) VALUES
  (NEXTVAL('users_seq'), 'Alice',   'Morgan',   'alice.morgan@example.com',   'e99a18c428cb38d5f260853678922e03', 1, '2024-01-05 09:15:00', '2025-03-18 14:22:00', 'Survey researcher with 10 years of experience in public opinion polling.', 'Alice M.'),
  (NEXTVAL('users_seq'), 'Bob',     'Chen',     'bob.chen@example.com',       '5f4dcc3b5aa765d61d8327deb882cf99', 0, '2024-02-10 11:30:00', '2025-03-15 09:45:00', NULL, 'Bob C.'),
  (NEXTVAL('users_seq'), 'Carol',   'Williams', 'carol.williams@example.com', '25d55ad283aa400af464c76d713c07ad', 1, '2024-02-18 08:00:00', '2025-03-19 16:00:00', 'Community organizer passionate about civic engagement.', 'Carol W.'),
  (NEXTVAL('users_seq'), 'David',   'Patel',    'david.patel@example.com',    'e10adc3949ba59abbe56e057f20f883e', 0, '2024-03-01 14:20:00', '2025-02-28 18:30:00', NULL, NULL),
  (NEXTVAL('users_seq'), 'Emma',    'Johnson',  'emma.johnson@example.com',   'd8578edf8458ce06fbc5bb76a58c5ca4', 0, '2024-03-15 10:45:00', '2025-03-10 12:00:00', 'Student at State University studying political science.', 'Emma J.'),
  (NEXTVAL('users_seq'), 'Frank',   'Okafor',   'frank.okafor@example.com',   '96e79218965eb72c92a549dd5a330112', 1, '2024-04-02 07:30:00', '2025-03-20 08:15:00', 'Product manager running customer feedback surveys.', 'Frank O.'),
  (NEXTVAL('users_seq'), 'Grace',   'Kim',      'grace.kim@example.com',      '827ccb0eea8a706c4c34a16891f84e7b', 0, '2024-04-20 13:00:00', '2025-03-12 11:30:00', NULL, 'Grace'),
  (NEXTVAL('users_seq'), 'Hector',  'Rivera',   'hector.rivera@example.com',  'e99a18c428cb38d5f260853678922e03', 0, '2024-05-10 16:45:00', NULL, NULL, NULL),
  (NEXTVAL('users_seq'), 'Irene',   'Novak',    'irene.novak@example.com',    '5f4dcc3b5aa765d61d8327deb882cf99', 0, '2024-06-01 09:00:00', '2025-01-20 10:00:00', 'Data analyst interested in survey methodology.', 'Irene N.'),
  (NEXTVAL('users_seq'), 'James',   'Thompson', 'james.thompson@example.com', '25d55ad283aa400af464c76d713c07ad', 0, '2024-07-15 12:30:00', '2025-03-01 15:45:00', NULL, 'James T.');

-- Capture user IDs for referencing below.  The sequence started at 1 and we
-- inserted 10 rows, so IDs are 1-10.  Hosts are users 1 (Alice), 3 (Carol),
-- and 6 (Frank).

-- -------------------------------------------------------------------------
-- 2. Polls  (hosted by users with host = 1)
-- -------------------------------------------------------------------------
INSERT INTO poll (id, surveyHostId, title, metaTitle, summary, type, published, createdAt, updatedAt, publishedAt, startsAt, endsAt, content) VALUES
  -- Alice's polls
  (NEXTVAL('poll_seq'), 1, 'Favorite Programming Languages 2025',
    'Programming Language Preferences Survey',
    'A survey to understand which programming languages developers prefer in 2025.',
    1, 1,
    '2025-01-10 10:00:00', '2025-01-12 08:00:00', '2025-01-12 08:00:00',
    '2025-01-15 00:00:00', '2025-02-15 23:59:59',
    'Help us learn about developer language preferences and trends.'),

  (NEXTVAL('poll_seq'), 1, 'Remote Work Satisfaction',
    'Remote Work Employee Satisfaction Poll',
    'Gauge how employees feel about remote and hybrid work arrangements.',
    1, 1,
    '2025-01-20 09:00:00', '2025-01-22 14:30:00', '2025-01-22 14:30:00',
    '2025-02-01 00:00:00', '2025-03-01 23:59:59',
    'We want to understand your experience with remote work over the past year.'),

  -- Carol's polls
  (NEXTVAL('poll_seq'), 3, 'Community Park Improvements',
    'Neighborhood Park Improvement Survey',
    'What improvements would residents like to see in the community park?',
    0, 1,
    '2025-02-05 08:00:00', '2025-02-06 11:00:00', '2025-02-06 11:00:00',
    '2025-02-10 00:00:00', '2025-03-10 23:59:59',
    'Share your thoughts on how we can make our community park better for everyone.'),

  (NEXTVAL('poll_seq'), 3, 'Local Election Issues Priority',
    'Election Issues Priority Ranking',
    'Rank the issues that matter most to you for the upcoming local election.',
    1, 0,
    '2025-03-01 10:00:00', NULL, NULL,
    '2025-04-01 00:00:00', '2025-05-01 23:59:59',
    'Help us understand which policy issues are most important to the community.'),

  -- Frank's polls
  (NEXTVAL('poll_seq'), 6, 'Product Feature Feedback Q1 2025',
    'Q1 2025 Product Feature Survey',
    'Tell us which new features you value and what we should build next.',
    1, 1,
    '2025-02-15 07:30:00', '2025-02-16 09:00:00', '2025-02-16 09:00:00',
    '2025-02-20 00:00:00', '2025-03-20 23:59:59',
    'Your feedback directly shapes our product roadmap. Let us know what matters.'),

  (NEXTVAL('poll_seq'), 6, 'Customer Support Experience',
    'Support Experience Satisfaction Poll',
    'Rate your recent experience with our customer support team.',
    0, 1,
    '2025-03-05 12:00:00', '2025-03-06 10:00:00', '2025-03-06 10:00:00',
    '2025-03-10 00:00:00', '2025-04-10 23:59:59',
    'We strive to provide excellent support. Please share your honest feedback.');

-- Poll IDs: 1-6

-- -------------------------------------------------------------------------
-- 3. Poll Meta  (key-value metadata per poll, unique on pollId + key)
-- -------------------------------------------------------------------------
INSERT INTO poll_meta (id, pollId, key, content) VALUES
  (NEXTVAL('poll_meta_seq'), 1, 'target_audience',  'Software developers and engineering managers'),
  (NEXTVAL('poll_meta_seq'), 1, 'estimated_time',   '5 minutes'),
  (NEXTVAL('poll_meta_seq'), 2, 'target_audience',  'Full-time employees who have worked remotely'),
  (NEXTVAL('poll_meta_seq'), 2, 'estimated_time',   '8 minutes'),
  (NEXTVAL('poll_meta_seq'), 3, 'target_audience',  'Residents within 2 miles of Greenfield Park'),
  (NEXTVAL('poll_meta_seq'), 3, 'estimated_time',   '3 minutes'),
  (NEXTVAL('poll_meta_seq'), 4, 'target_audience',  'Registered voters in the district'),
  (NEXTVAL('poll_meta_seq'), 4, 'estimated_time',   '10 minutes'),
  (NEXTVAL('poll_meta_seq'), 5, 'target_audience',  'Active product users with accounts created before 2025'),
  (NEXTVAL('poll_meta_seq'), 5, 'estimated_time',   '6 minutes'),
  (NEXTVAL('poll_meta_seq'), 6, 'target_audience',  'Customers who contacted support in the last 90 days'),
  (NEXTVAL('poll_meta_seq'), 6, 'estimated_time',   '4 minutes');

-- -------------------------------------------------------------------------
-- 4. Poll Questions  (3 questions per poll = 18 total)
-- -------------------------------------------------------------------------
INSERT INTO poll_question (id, pollId, type, active, createdAt, updatedAt, content) VALUES
  -- Poll 1: Favorite Programming Languages 2025
  (NEXTVAL('poll_question_seq'), 1, 'single_choice',   1, '2025-01-10 10:05:00', NULL,
    'What is your primary programming language?'),
  (NEXTVAL('poll_question_seq'), 1, 'multiple_choice',  1, '2025-01-10 10:10:00', NULL,
    'Which languages have you used professionally in the past year?'),
  (NEXTVAL('poll_question_seq'), 1, 'open_ended',       1, '2025-01-10 10:15:00', NULL,
    'What language are you most excited to learn next, and why?'),

  -- Poll 2: Remote Work Satisfaction
  (NEXTVAL('poll_question_seq'), 2, 'single_choice',   1, '2025-01-20 09:10:00', NULL,
    'How many days per week do you currently work remotely?'),
  (NEXTVAL('poll_question_seq'), 2, 'rating_scale',     1, '2025-01-20 09:15:00', NULL,
    'On a scale of 1-10, how satisfied are you with your remote work setup?'),
  (NEXTVAL('poll_question_seq'), 2, 'open_ended',       1, '2025-01-20 09:20:00', NULL,
    'What is the biggest challenge you face while working remotely?'),

  -- Poll 3: Community Park Improvements
  (NEXTVAL('poll_question_seq'), 3, 'multiple_choice',  1, '2025-02-05 08:10:00', NULL,
    'Which improvements would you like to see? (Select all that apply)'),
  (NEXTVAL('poll_question_seq'), 3, 'single_choice',    1, '2025-02-05 08:15:00', NULL,
    'How often do you visit the community park?'),
  (NEXTVAL('poll_question_seq'), 3, 'open_ended',       1, '2025-02-05 08:20:00', NULL,
    'Do you have any additional suggestions for the park?'),

  -- Poll 4: Local Election Issues Priority
  (NEXTVAL('poll_question_seq'), 4, 'ranking',          0, '2025-03-01 10:05:00', NULL,
    'Rank the following issues by importance: housing, education, transit, public safety, environment.'),
  (NEXTVAL('poll_question_seq'), 4, 'single_choice',    0, '2025-03-01 10:10:00', NULL,
    'Which single issue would most influence your vote?'),
  (NEXTVAL('poll_question_seq'), 4, 'open_ended',       0, '2025-03-01 10:15:00', NULL,
    'Is there an issue not listed above that you care about? Please describe.'),

  -- Poll 5: Product Feature Feedback Q1 2025
  (NEXTVAL('poll_question_seq'), 5, 'rating_scale',     1, '2025-02-15 07:40:00', NULL,
    'How would you rate the new dashboard redesign? (1-5)'),
  (NEXTVAL('poll_question_seq'), 5, 'multiple_choice',  1, '2025-02-15 07:45:00', NULL,
    'Which upcoming features are you most interested in?'),
  (NEXTVAL('poll_question_seq'), 5, 'open_ended',       1, '2025-02-15 07:50:00', NULL,
    'What is the one feature you wish our product had?'),

  -- Poll 6: Customer Support Experience
  (NEXTVAL('poll_question_seq'), 6, 'rating_scale',     1, '2025-03-05 12:10:00', NULL,
    'How satisfied were you with the response time? (1-5)'),
  (NEXTVAL('poll_question_seq'), 6, 'single_choice',    1, '2025-03-05 12:15:00', NULL,
    'Was your issue resolved?'),
  (NEXTVAL('poll_question_seq'), 6, 'open_ended',       1, '2025-03-05 12:20:00', NULL,
    'How can we improve our support experience?');

-- Question IDs: 1-18

-- -------------------------------------------------------------------------
-- 5. Poll Answers  (3 answer options per question = 54 total)
--    Each answer references both its poll and its question.
-- -------------------------------------------------------------------------
INSERT INTO poll_answer (id, pollId, questionId, active, createdAt, updatedAt, content) VALUES
  -- Q1 (poll 1): What is your primary programming language?
  (NEXTVAL('poll_answer_seq'), 1,  1, 1, '2025-01-10 10:06:00', NULL, 'Python'),
  (NEXTVAL('poll_answer_seq'), 1,  1, 1, '2025-01-10 10:06:00', NULL, 'JavaScript / TypeScript'),
  (NEXTVAL('poll_answer_seq'), 1,  1, 1, '2025-01-10 10:06:00', NULL, 'Go'),

  -- Q2 (poll 1): Which languages have you used professionally?
  (NEXTVAL('poll_answer_seq'), 1,  2, 1, '2025-01-10 10:11:00', NULL, 'Python'),
  (NEXTVAL('poll_answer_seq'), 1,  2, 1, '2025-01-10 10:11:00', NULL, 'Java'),
  (NEXTVAL('poll_answer_seq'), 1,  2, 1, '2025-01-10 10:11:00', NULL, 'Rust'),

  -- Q3 (poll 1): What language are you most excited to learn next?
  (NEXTVAL('poll_answer_seq'), 1,  3, 1, '2025-01-10 10:16:00', NULL, 'Rust — I want to explore systems programming with memory safety.'),
  (NEXTVAL('poll_answer_seq'), 1,  3, 1, '2025-01-10 10:16:00', NULL, 'Zig — it looks like a promising alternative to C.'),
  (NEXTVAL('poll_answer_seq'), 1,  3, 1, '2025-01-10 10:16:00', NULL, 'Elixir — concurrency and fault tolerance appeal to me.'),

  -- Q4 (poll 2): How many days per week do you work remotely?
  (NEXTVAL('poll_answer_seq'), 2,  4, 1, '2025-01-20 09:11:00', NULL, '5 days (fully remote)'),
  (NEXTVAL('poll_answer_seq'), 2,  4, 1, '2025-01-20 09:11:00', NULL, '3-4 days (hybrid, mostly remote)'),
  (NEXTVAL('poll_answer_seq'), 2,  4, 1, '2025-01-20 09:11:00', NULL, '1-2 days (hybrid, mostly on-site)'),

  -- Q5 (poll 2): Satisfaction with remote work setup (1-10)
  (NEXTVAL('poll_answer_seq'), 2,  5, 1, '2025-01-20 09:16:00', NULL, '9'),
  (NEXTVAL('poll_answer_seq'), 2,  5, 1, '2025-01-20 09:16:00', NULL, '7'),
  (NEXTVAL('poll_answer_seq'), 2,  5, 1, '2025-01-20 09:16:00', NULL, '4'),

  -- Q6 (poll 2): Biggest challenge working remotely?
  (NEXTVAL('poll_answer_seq'), 2,  6, 1, '2025-01-20 09:21:00', NULL, 'Isolation and lack of spontaneous collaboration.'),
  (NEXTVAL('poll_answer_seq'), 2,  6, 1, '2025-01-20 09:21:00', NULL, 'Difficulty separating work and personal life.'),
  (NEXTVAL('poll_answer_seq'), 2,  6, 1, '2025-01-20 09:21:00', NULL, 'Unreliable internet and home office ergonomics.'),

  -- Q7 (poll 3): Which improvements would you like to see?
  (NEXTVAL('poll_answer_seq'), 3,  7, 1, '2025-02-05 08:11:00', NULL, 'New playground equipment for children'),
  (NEXTVAL('poll_answer_seq'), 3,  7, 1, '2025-02-05 08:11:00', NULL, 'Better lighting and walking paths'),
  (NEXTVAL('poll_answer_seq'), 3,  7, 1, '2025-02-05 08:11:00', NULL, 'Community garden and picnic area'),

  -- Q8 (poll 3): How often do you visit the community park?
  (NEXTVAL('poll_answer_seq'), 3,  8, 1, '2025-02-05 08:16:00', NULL, 'Multiple times a week'),
  (NEXTVAL('poll_answer_seq'), 3,  8, 1, '2025-02-05 08:16:00', NULL, 'A few times a month'),
  (NEXTVAL('poll_answer_seq'), 3,  8, 1, '2025-02-05 08:16:00', NULL, 'Rarely or never'),

  -- Q9 (poll 3): Additional suggestions?
  (NEXTVAL('poll_answer_seq'), 3,  9, 1, '2025-02-05 08:21:00', NULL, 'Add a dog park section with fencing.'),
  (NEXTVAL('poll_answer_seq'), 3,  9, 1, '2025-02-05 08:21:00', NULL, 'Install more benches near the pond.'),
  (NEXTVAL('poll_answer_seq'), 3,  9, 1, '2025-02-05 08:21:00', NULL, 'Host monthly community events at the pavilion.'),

  -- Q10 (poll 4): Rank issues by importance
  (NEXTVAL('poll_answer_seq'), 4, 10, 0, '2025-03-01 10:06:00', NULL, 'Housing > Education > Transit > Environment > Public Safety'),
  (NEXTVAL('poll_answer_seq'), 4, 10, 0, '2025-03-01 10:06:00', NULL, 'Education > Public Safety > Housing > Transit > Environment'),
  (NEXTVAL('poll_answer_seq'), 4, 10, 0, '2025-03-01 10:06:00', NULL, 'Environment > Transit > Education > Housing > Public Safety'),

  -- Q11 (poll 4): Which single issue influences your vote most?
  (NEXTVAL('poll_answer_seq'), 4, 11, 0, '2025-03-01 10:11:00', NULL, 'Affordable housing'),
  (NEXTVAL('poll_answer_seq'), 4, 11, 0, '2025-03-01 10:11:00', NULL, 'Public school funding'),
  (NEXTVAL('poll_answer_seq'), 4, 11, 0, '2025-03-01 10:11:00', NULL, 'Climate and environment policy'),

  -- Q12 (poll 4): Any unlisted issue?
  (NEXTVAL('poll_answer_seq'), 4, 12, 0, '2025-03-01 10:16:00', NULL, 'Mental health services are underfunded in our district.'),
  (NEXTVAL('poll_answer_seq'), 4, 12, 0, '2025-03-01 10:16:00', NULL, 'We need more bike lanes and pedestrian infrastructure.'),
  (NEXTVAL('poll_answer_seq'), 4, 12, 0, '2025-03-01 10:16:00', NULL, 'Small business support and local economic development.'),

  -- Q13 (poll 5): Rate the new dashboard redesign (1-5)
  (NEXTVAL('poll_answer_seq'), 5, 13, 1, '2025-02-15 07:41:00', NULL, '5'),
  (NEXTVAL('poll_answer_seq'), 5, 13, 1, '2025-02-15 07:41:00', NULL, '3'),
  (NEXTVAL('poll_answer_seq'), 5, 13, 1, '2025-02-15 07:41:00', NULL, '2'),

  -- Q14 (poll 5): Which upcoming features interest you?
  (NEXTVAL('poll_answer_seq'), 5, 14, 1, '2025-02-15 07:46:00', NULL, 'AI-powered analytics'),
  (NEXTVAL('poll_answer_seq'), 5, 14, 1, '2025-02-15 07:46:00', NULL, 'Team collaboration tools'),
  (NEXTVAL('poll_answer_seq'), 5, 14, 1, '2025-02-15 07:46:00', NULL, 'Advanced export and reporting'),

  -- Q15 (poll 5): One feature you wish the product had?
  (NEXTVAL('poll_answer_seq'), 5, 15, 1, '2025-02-15 07:51:00', NULL, 'A mobile app with offline support.'),
  (NEXTVAL('poll_answer_seq'), 5, 15, 1, '2025-02-15 07:51:00', NULL, 'Integration with Slack and Microsoft Teams.'),
  (NEXTVAL('poll_answer_seq'), 5, 15, 1, '2025-02-15 07:51:00', NULL, 'Customizable notification preferences.'),

  -- Q16 (poll 6): Satisfaction with response time (1-5)
  (NEXTVAL('poll_answer_seq'), 6, 16, 1, '2025-03-05 12:11:00', NULL, '5'),
  (NEXTVAL('poll_answer_seq'), 6, 16, 1, '2025-03-05 12:11:00', NULL, '3'),
  (NEXTVAL('poll_answer_seq'), 6, 16, 1, '2025-03-05 12:11:00', NULL, '1'),

  -- Q17 (poll 6): Was your issue resolved?
  (NEXTVAL('poll_answer_seq'), 6, 17, 1, '2025-03-05 12:16:00', NULL, 'Yes, fully resolved'),
  (NEXTVAL('poll_answer_seq'), 6, 17, 1, '2025-03-05 12:16:00', NULL, 'Partially resolved'),
  (NEXTVAL('poll_answer_seq'), 6, 17, 1, '2025-03-05 12:16:00', NULL, 'No, still unresolved'),

  -- Q18 (poll 6): How can we improve support?
  (NEXTVAL('poll_answer_seq'), 6, 18, 1, '2025-03-05 12:21:00', NULL, 'Offer live chat during weekends.'),
  (NEXTVAL('poll_answer_seq'), 6, 18, 1, '2025-03-05 12:21:00', NULL, 'Provide more self-service documentation.'),
  (NEXTVAL('poll_answer_seq'), 6, 18, 1, '2025-03-05 12:21:00', NULL, 'Follow up after tickets are closed to confirm resolution.');

COMMIT;
