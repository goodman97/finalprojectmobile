-- Migration: Add timezone preference to users table
-- Date: 2026-05-05

ALTER TABLE users
ADD COLUMN IF NOT EXISTS timezone VARCHAR(50) DEFAULT 'Asia/Jakarta';

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_users_timezone ON users(timezone);

-- Common timezones reference:
-- Asia/Jakarta (UTC+7)
-- Asia/Bangkok (UTC+7)
-- Asia/Manila (UTC+8)
-- Asia/Singapore (UTC+8)
-- Asia/Hong_Kong (UTC+8)
-- Asia/Tokyo (UTC+9)
-- UTC (UTC+0)
-- Asia/Kolkata (UTC+5:30)
-- Asia/Dubai (UTC+4)
