-- Migration: image column TEXT → BYTEA
-- Run this manually if ddl-auto=update does not handle the type change

ALTER TABLE evenement ADD COLUMN IF NOT EXISTS image_new BYTEA;
UPDATE evenement SET image_new = NULL;
ALTER TABLE evenement DROP COLUMN IF EXISTS image;
ALTER TABLE evenement RENAME COLUMN image_new TO image;
