-- =============================================
-- Migration 002: projects 테이블에 board_id 컬럼 추가
-- Supabase SQL Editor에서 실행하세요
-- =============================================

ALTER TABLE projects ADD COLUMN IF NOT EXISTS board_id INTEGER;

-- 기존 데이터 업데이트
UPDATE projects SET board_id = 251 WHERE name = 'FEHG';
UPDATE projects SET board_id = 20 WHERE name = 'KQ';
UPDATE projects SET board_id = 350 WHERE name = 'HB';
UPDATE projects SET board_id = 37 WHERE name = 'HDD';
UPDATE projects SET board_id = 521 WHERE name = 'AUTOWAY';
