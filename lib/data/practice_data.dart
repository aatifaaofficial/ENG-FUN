import 'package:englishfun/models/practice_model.dart';

final List<PracticeQuestion> dailyPracticeQuestions = [
  const PracticeQuestion(
    id: 1,
    question: 'Choose the correct answer. What is the opposite of "happy"?',
    options: ['Sad', 'Angry', 'Fast', 'Strong'],
    correctAnswer: 'Sad',
    explanation: 'Happy and sad are opposites.',
    xpReward: 10,
  ),
  const PracticeQuestion(
    id: 2,
    question: 'Choose the best option: "I ___ a book every night."',
    options: ['read', 'reads', 'reading', 'reads'],
    correctAnswer: 'read',
    explanation: 'Use “read” with the pronoun “I.”',
    xpReward: 10,
  ),
  const PracticeQuestion(
    id: 3,
    question: 'Which sentence is correct?',
    options: [
      'She go to school.',
      'She goes to school.',
      'She going school.',
      'She gone school.'
    ],
    correctAnswer: 'She goes to school.',
    explanation: 'Use “goes” with “she.”',
    xpReward: 10,
  ),
  const PracticeQuestion(
    id: 4,
    question: 'Which word means “very small”?',
    options: ['Huge', 'Tiny', 'Lazy', 'Noisy'],
    correctAnswer: 'Tiny',
    explanation: 'Tiny describes something extremely small.',
    xpReward: 10,
  ),
  const PracticeQuestion(
    id: 5,
    question: 'What is the past form of "eat"?',
    options: ['Eated', 'Eating', 'Ate', 'Eats'],
    correctAnswer: 'Ate',
    explanation: '“Ate” is the simple past tense of “eat.”',
    xpReward: 10,
  ),
  const PracticeQuestion(
    id: 6,
    question: 'Choose the correct article: "I saw ___ elephant at the zoo."',
    options: ['a', 'an', 'the', 'no article'],
    correctAnswer: 'an',
    explanation: 'Use “an” before a vowel sound.',
    xpReward: 10,
  ),
  const PracticeQuestion(
    id: 7,
    question: 'Which word is a synonym for “happy”?',
    options: ['Joyful', 'Tired', 'Silent', 'Weak'],
    correctAnswer: 'Joyful',
    explanation: 'Joyful means full of happiness.',
    xpReward: 10,
  ),
  const PracticeQuestion(
    id: 8,
    question: 'Choose the correct sentence.',
    options: [
      'They is happy.',
      'They are happy.',
      'They am happy.',
      'They be happy.'
    ],
    correctAnswer: 'They are happy.',
    explanation: 'Use “are” with the pronoun “they.”',
    xpReward: 10,
  ),
  const PracticeQuestion(
    id: 9,
    question: 'Which word means “a person who learns”?',
    options: ['Student', 'Doctor', 'Teacher', 'Driver'],
    correctAnswer: 'Student',
    explanation: 'A student is someone who learns or studies.',
    xpReward: 10,
  ),
  const PracticeQuestion(
    id: 10,
    question: 'Complete the sentence: "She is ___ than her sister."',
    options: ['more tall', 'tallest', 'taller', 'most tall'],
    correctAnswer: 'taller',
    explanation: 'We add “-er” for the comparative form of a short adjective.',
    xpReward: 15,
  ),
];
