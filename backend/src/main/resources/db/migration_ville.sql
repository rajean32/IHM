-- ============================================================
-- Migration: Create VILLE table and migrate existing ville data
-- The app seeds ~76 Madagascar cities on startup via @PostConstruct.
-- Run this to migrate existing data (old VARCHAR columns) to FK.
-- ============================================================

-- 1. Create VILLE table (if not already created by Hibernate ddl-auto=update)
CREATE TABLE IF NOT EXISTS ville (
    code VARCHAR(20) PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    region VARCHAR(100),
    actif BOOLEAN DEFAULT TRUE
);

-- 2. Generate codes from existing UTILISATEUR.ville with collision handling
INSERT INTO ville (code, nom)
SELECT DISTINCT
    CASE
        WHEN LOWER(TRIM(ville)) = 'antananarivo' THEN 'TNR'
        WHEN LOWER(TRIM(ville)) = 'toamasina' THEN 'TMA'
        WHEN LOWER(TRIM(ville)) = 'antsirabe' THEN 'ATB'
        ELSE UPPER(LEFT(REGEXP_REPLACE(TRIM(ville), '[^a-zA-Z]', '', 'g'), 3))
    END,
    TRIM(ville)
FROM utilisateur
WHERE ville IS NOT NULL AND TRIM(ville) != ''
ON CONFLICT (code) DO NOTHING;

-- 3. From LIEU too
INSERT INTO ville (code, nom)
SELECT DISTINCT
    CASE
        WHEN LOWER(TRIM(ville)) = 'antananarivo' THEN 'TNR'
        WHEN LOWER(TRIM(ville)) = 'toamasina' THEN 'TMA'
        WHEN LOWER(TRIM(ville)) = 'antsirabe' THEN 'ATB'
        ELSE UPPER(LEFT(REGEXP_REPLACE(TRIM(ville), '[^a-zA-Z]', '', 'g'), 3))
    END,
    TRIM(ville)
FROM lieu
WHERE ville IS NOT NULL AND TRIM(ville) != ''
ON CONFLICT (code) DO NOTHING;

-- 4. Handle code collisions: add suffix to duplicates
UPDATE ville SET code = code || '1'
WHERE code IN (
    SELECT code FROM ville GROUP BY code HAVING COUNT(*) > 1
    AND code NOT IN ('TNR', 'TMA', 'ATB')
);

-- 5. Add FK column to UTILISATEUR
ALTER TABLE utilisateur ADD COLUMN IF NOT EXISTS code_ville VARCHAR(20);

UPDATE utilisateur u
SET code_ville = v.code
FROM ville v
WHERE LOWER(TRIM(u.ville)) = LOWER(TRIM(v.nom));

ALTER TABLE utilisateur ADD CONSTRAINT fk_utilisateur_ville
    FOREIGN KEY (code_ville) REFERENCES ville(code);

-- 6. Add FK column to LIEU
ALTER TABLE lieu ADD COLUMN IF NOT EXISTS code_ville VARCHAR(20);

UPDATE lieu l
SET code_ville = v.code
FROM ville v
WHERE LOWER(TRIM(l.ville)) = LOWER(TRIM(v.nom));

ALTER TABLE lieu ADD CONSTRAINT fk_lieu_ville
    FOREIGN KEY (code_ville) REFERENCES ville(code);

-- 7. Drop old VARCHAR columns (no longer needed; FK is now used)
ALTER TABLE utilisateur DROP COLUMN IF EXISTS ville;
ALTER TABLE lieu DROP COLUMN IF EXISTS ville;

-- ============================================================
-- Rollback script (if needed):
-- ALTER TABLE utilisateur ADD COLUMN ville VARCHAR(100);
-- UPDATE utilisateur SET ville = v.nom FROM ville v WHERE v.code = code_ville;
-- ALTER TABLE lieu ADD COLUMN ville VARCHAR(100);
-- UPDATE lieu SET ville = v.nom FROM ville v WHERE v.code = code_ville;
-- ALTER TABLE utilisateur DROP CONSTRAINT fk_utilisateur_ville;
-- ALTER TABLE lieu DROP CONSTRAINT fk_lieu_ville;
-- ALTER TABLE utilisateur DROP COLUMN code_ville;
-- ALTER TABLE lieu DROP COLUMN code_ville;
-- DROP TABLE ville;
-- ============================================================
