-- Migration: Update event timestamps to use timezone
-- Date: 2026-05-05

ALTER TABLE events
ALTER COLUMN start_date TYPE TIMESTAMP WITH TIME ZONE,
ALTER COLUMN end_date TYPE TIMESTAMP WITH TIME ZONE;

-- Verify the changes
-- SELECT column_name, data_type FROM information_schema.columns
-- WHERE table_name = 'events' AND column_name IN ('start_date', 'end_date');
