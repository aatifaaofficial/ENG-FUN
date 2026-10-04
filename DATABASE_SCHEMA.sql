-- EnglishFun Database Schema for Supabase
-- Run this SQL in Supabase SQL Editor to create all tables

-- Users Table
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  avatar TEXT DEFAULT '👤',
  totalWordsLearned INTEGER DEFAULT 0,
  dailyStreak INTEGER DEFAULT 0,
  accuracy DOUBLE PRECISION DEFAULT 0.0,
  totalXP INTEGER DEFAULT 0,
  createdAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updatedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Vocabulary Table
CREATE TABLE IF NOT EXISTS vocabulary (
  id TEXT PRIMARY KEY,
  word TEXT NOT NULL UNIQUE,
  partOfSpeech TEXT NOT NULL,
  meaning TEXT NOT NULL,
  bangla TEXT NOT NULL,
  synonyms TEXT[] DEFAULT ARRAY[]::TEXT[],
  examples TEXT[] DEFAULT ARRAY[]::TEXT[],
  level TEXT NOT NULL CHECK (level IN ('Beginner', 'Intermediate')),
  createdAt TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Practice Questions Table
CREATE TABLE IF NOT EXISTS practice_questions (
  id TEXT PRIMARY KEY,
  type TEXT NOT NULL CHECK (type IN ('sentenceArrangement', 'fillBlank', 'spelling')),
  question TEXT NOT NULL,
  options TEXT[] NOT NULL,
  correctAnswer TEXT NOT NULL,
  explanation TEXT NOT NULL,
  level TEXT NOT NULL CHECK (level IN ('Beginner', 'Intermediate')),
  vocabularyId TEXT NOT NULL REFERENCES vocabulary(id) ON DELETE CASCADE,
  createdAt TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Daily Streaks Table
CREATE TABLE IF NOT EXISTS daily_streaks (
  id TEXT PRIMARY KEY,
  userId UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  streakCount INTEGER DEFAULT 0,
  lastPracticeDate TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  createdAt TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User Progress Table
CREATE TABLE IF NOT EXISTS user_progress (
  id TEXT PRIMARY KEY,
  userId UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  vocabularyId TEXT NOT NULL REFERENCES vocabulary(id) ON DELETE CASCADE,
  attempts INTEGER DEFAULT 0,
  correct INTEGER DEFAULT 0,
  mastered BOOLEAN DEFAULT FALSE,
  lastAttempt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(userId, vocabularyId)
);

-- User Favorites Table
CREATE TABLE IF NOT EXISTS user_favorites (
  id TEXT PRIMARY KEY,
  userId UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  vocabularyId TEXT NOT NULL REFERENCES vocabulary(id) ON DELETE CASCADE,
  createdAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(userId, vocabularyId)
);

-- Practice Attempts Table
CREATE TABLE IF NOT EXISTS practice_attempts (
  id TEXT PRIMARY KEY,
  userId UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  questionId TEXT NOT NULL REFERENCES practice_questions(id) ON DELETE CASCADE,
  userAnswer TEXT NOT NULL,
  isCorrect BOOLEAN DEFAULT FALSE,
  xpGained INTEGER DEFAULT 0,
  attemptedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Quiz Results Table
CREATE TABLE IF NOT EXISTS quiz_results (
  id TEXT PRIMARY KEY,
  userId UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  score INTEGER DEFAULT 0,
  totalQuestions INTEGER NOT NULL,
  accuracy DOUBLE PRECISION DEFAULT 0.0,
  completedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Indexes for Performance
CREATE INDEX idx_vocabulary_level ON vocabulary(level);
CREATE INDEX idx_practice_questions_type ON practice_questions(type);
CREATE INDEX idx_practice_questions_level ON practice_questions(level);
CREATE INDEX idx_practice_questions_vocabulary ON practice_questions(vocabularyId);
CREATE INDEX idx_daily_streaks_user ON daily_streaks(userId);
CREATE INDEX idx_user_progress_user ON user_progress(userId);
CREATE INDEX idx_user_progress_vocabulary ON user_progress(vocabularyId);
CREATE INDEX idx_user_favorites_user ON user_favorites(userId);
CREATE INDEX idx_practice_attempts_user ON practice_attempts(userId);
CREATE INDEX idx_quiz_results_user ON quiz_results(userId);

-- Enable Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE vocabulary ENABLE ROW LEVEL SECURITY;
ALTER TABLE practice_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_streaks ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE practice_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_results ENABLE ROW LEVEL SECURITY;

-- RLS Policies (users can only access their own data)
CREATE POLICY users_policy ON users
  FOR ALL USING (auth.uid() = id);

CREATE POLICY vocabulary_policy ON vocabulary
  FOR SELECT USING (true);

CREATE POLICY practice_questions_policy ON practice_questions
  FOR SELECT USING (true);

CREATE POLICY daily_streaks_policy ON daily_streaks
  FOR ALL USING (auth.uid() = userId);

CREATE POLICY user_progress_policy ON user_progress
  FOR ALL USING (auth.uid() = userId);

CREATE POLICY user_favorites_policy ON user_favorites
  FOR ALL USING (auth.uid() = userId);

CREATE POLICY practice_attempts_policy ON practice_attempts
  FOR ALL USING (auth.uid() = userId);

CREATE POLICY quiz_results_policy ON quiz_results
  FOR ALL USING (auth.uid() = userId);
