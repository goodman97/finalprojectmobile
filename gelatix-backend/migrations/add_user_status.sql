-- Create ENUM type for user status
CREATE TYPE user_status AS ENUM ('active', 'suspended');

-- Add status column to users table
ALTER TABLE users
ADD COLUMN status user_status DEFAULT 'active';

-- Update suspended users to have suspended status
UPDATE users SET status = 'suspended' WHERE is_suspended = true;
