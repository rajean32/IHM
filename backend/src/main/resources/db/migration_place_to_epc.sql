-- Migration: Move pricing/status fields from PLACE to EVENEMENT_PLACE_CONFIG
-- Run this manually against your PostgreSQL database
-- Hibernate ddl-auto=update will create the new columns, but data migration
-- and NOT NULL constraints must be done manually.

-- Step 1: Add new columns to EVENEMENT_PLACE_CONFIG (if not already created by Hibernate)
ALTER TABLE EVENEMENT_PLACE_CONFIG ADD COLUMN IF NOT EXISTS typePlace VARCHAR(50);
ALTER TABLE EVENEMENT_PLACE_CONFIG ADD COLUMN IF NOT EXISTS prix DECIMAL(10,2);
ALTER TABLE EVENEMENT_PLACE_CONFIG ADD COLUMN IF NOT EXISTS "range" VARCHAR(10);
ALTER TABLE EVENEMENT_PLACE_CONFIG ADD COLUMN IF NOT EXISTS statut VARCHAR(20);

-- Step 2: Migrate data from PLACE to EVENEMENT_PLACE_CONFIG
-- For each existing EPC row, copy the master values from PLACE if the EPC values are null
UPDATE EVENEMENT_PLACE_CONFIG epc
SET typePlace = COALESCE(epc.typePlace, p.typePlace),
    prix = COALESCE(epc.prix, p.prix),
    "range" = COALESCE(epc."range", p."range"),
    statut = COALESCE(epc.statut, p.statut)
FROM PLACE p
WHERE epc.NumeroPlace = p.NumeroPlace;

-- Step 3: For any EPC rows that still have NULL (e.g. place had no data), set defaults
UPDATE EVENEMENT_PLACE_CONFIG
SET typePlace = COALESCE(typePlace, 'Standard'),
    prix = COALESCE(prix, 0),
    "range" = COALESCE("range", '?'),
    statut = COALESCE(statut, 'DISPONIBLE');

-- Step 4: Drop old columns from PLACE
ALTER TABLE PLACE DROP COLUMN IF EXISTS prix;
ALTER TABLE PLACE DROP COLUMN IF EXISTS statut;
ALTER TABLE PLACE DROP COLUMN IF EXISTS typePlace;
ALTER TABLE PLACE DROP COLUMN IF EXISTS "range";
ALTER TABLE PLACE DROP COLUMN IF EXISTS date_mise_en_attente;

-- Step 5: Rename old override columns in EVENEMENT_PLACE_CONFIG (if Hibernate didn't already)
-- Only needed if migrating from old schema with prixOverride/typePlaceOverride/statutPlace
ALTER TABLE EVENEMENT_PLACE_CONFIG DROP COLUMN IF EXISTS prixOverride;
ALTER TABLE EVENEMENT_PLACE_CONFIG DROP COLUMN IF EXISTS typePlaceOverride;
ALTER TABLE EVENEMENT_PLACE_CONFIG DROP COLUMN IF EXISTS statutPlace;

-- Step 6: Set NOT NULL constraints on EVENEMENT_PLACE_CONFIG
ALTER TABLE EVENEMENT_PLACE_CONFIG ALTER COLUMN typePlace SET NOT NULL;
ALTER TABLE EVENEMENT_PLACE_CONFIG ALTER COLUMN prix SET NOT NULL;
ALTER TABLE EVENEMENT_PLACE_CONFIG ALTER COLUMN "range" SET NOT NULL;
ALTER TABLE EVENEMENT_PLACE_CONFIG ALTER COLUMN statut SET NOT NULL;
