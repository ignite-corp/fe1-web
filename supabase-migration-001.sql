-- =============================================
-- Migration 001: projects 테이블에 jira_instance 컬럼 추가
-- Supabase SQL Editor에서 실행하세요
-- =============================================

ALTER TABLE projects ADD COLUMN IF NOT EXISTS jira_instance TEXT NOT NULL DEFAULT 'ignite' CHECK (jira_instance IN ('ignite', 'hmg'));

-- 기존 데이터 업데이트: AUTOWAY는 HMG Jira
UPDATE projects SET jira_instance = 'hmg' WHERE name = 'AUTOWAY';
