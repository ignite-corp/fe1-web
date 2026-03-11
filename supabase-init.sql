-- =============================================
-- FE1 Ignite 관리 시스템 초기 스키마
-- Supabase SQL Editor에서 실행하세요
-- =============================================

-- 1. 팀 테이블
CREATE TABLE teams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  source_project_id UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. 프로젝트 테이블
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  jira_project_id TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. 사용자 테이블
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  team_id UUID REFERENCES teams(id) ON DELETE SET NULL,
  ignite_account_id TEXT NOT NULL DEFAULT '',
  ignite_jira_email TEXT NOT NULL DEFAULT '',
  ignite_jira_api_token TEXT NOT NULL DEFAULT '',
  hmg_account_id TEXT NOT NULL DEFAULT '',
  hmg_jira_email TEXT NOT NULL DEFAULT '',
  hmg_jira_api_token TEXT NOT NULL DEFAULT '',
  hmg_user_id TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. 팀 ↔ 동기화 대상 프로젝트
CREATE TABLE team_target_projects (
  team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  PRIMARY KEY (team_id, project_id)
);

-- 5. 프로젝트 ↔ 팀 연결
CREATE TABLE project_teams (
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  PRIMARY KEY (project_id, team_id)
);

-- 6. teams.source_project_id FK
ALTER TABLE teams
  ADD CONSTRAINT fk_teams_source_project
  FOREIGN KEY (source_project_id) REFERENCES projects(id) ON DELETE SET NULL;

-- 7. updated_at 자동 갱신 트리거
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_teams_updated_at
  BEFORE UPDATE ON teams FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_projects_updated_at
  BEFORE UPDATE ON projects FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- 8. 인덱스
CREATE INDEX idx_users_team_id ON users(team_id);
CREATE INDEX idx_team_target_projects_team ON team_target_projects(team_id);
CREATE INDEX idx_team_target_projects_project ON team_target_projects(project_id);
CREATE INDEX idx_project_teams_project ON project_teams(project_id);
CREATE INDEX idx_project_teams_team ON project_teams(team_id);

-- 9. RLS + 개발용 전체 허용
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE team_target_projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_teams ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all for teams" ON teams FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for projects" ON projects FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for users" ON users FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for team_target_projects" ON team_target_projects FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for project_teams" ON project_teams FOR ALL USING (true) WITH CHECK (true);

-- =============================================
-- 초기 데이터
-- =============================================

-- 프로젝트
INSERT INTO projects (id, name, jira_project_id) VALUES
  ('a0000000-0000-0000-0000-000000000001', 'FEHG',    '10247'),
  ('a0000000-0000-0000-0000-000000000002', 'KQ',      '10109'),
  ('a0000000-0000-0000-0000-000000000003', 'HB',      '10411'),
  ('a0000000-0000-0000-0000-000000000004', 'HDD',     '10135'),
  ('a0000000-0000-0000-0000-000000000005', 'AUTOWAY', '10363');

-- 팀 (source = FEHG)
INSERT INTO teams (id, name, source_project_id) VALUES
  ('b0000000-0000-0000-0000-000000000001', 'FE1', 'a0000000-0000-0000-0000-000000000001');

-- 동기화 대상
INSERT INTO team_target_projects (team_id, project_id) VALUES
  ('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000002'),
  ('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000003'),
  ('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000004'),
  ('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000005');

-- 프로젝트-팀 연결
INSERT INTO project_teams (project_id, team_id) VALUES
  ('a0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001'),
  ('a0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000001'),
  ('a0000000-0000-0000-0000-000000000003', 'b0000000-0000-0000-0000-000000000001'),
  ('a0000000-0000-0000-0000-000000000004', 'b0000000-0000-0000-0000-000000000001'),
  ('a0000000-0000-0000-0000-000000000005', 'b0000000-0000-0000-0000-000000000001');

-- 사용자
INSERT INTO users (name, team_id, ignite_account_id, hmg_account_id, hmg_user_id) VALUES
  ('한준호', 'b0000000-0000-0000-0000-000000000001', '712020:f4f9e56c-4b40-41ac-af83-5d2f774a72d5', '712020:92f069fc-d884-4de8-bb47-0cf495905085', 'ZS17249'),
  ('손현지', 'b0000000-0000-0000-0000-000000000001', '639a6767f1346f4a290c4ab9', '712020:2ef63d63-dc9c-4b5e-a7ef-84c0b8fc20d8', 'ZS17262'),
  ('김가빈', 'b0000000-0000-0000-0000-000000000001', '637426199e48cf7fb37d7e6c', '712020:82e68050-6f5b-445e-b1f2-33c2feb44ce5', 'ZS16891'),
  ('박성찬', 'b0000000-0000-0000-0000-000000000001', '638d49155fce9bfde8a42f8d', '712020:0bbba3a1-2a2d-4f9e-acf6-5c3001649f79', 'ZS17174'),
  ('서성주', 'b0000000-0000-0000-0000-000000000001', '639fa03f2c70aae1e6f79806', '712020:a314415b-f3a0-4a33-b8d9-d1e98ca5dd01', 'ZS11262'),
  ('김찬영', 'b0000000-0000-0000-0000-000000000001', '712020:11fff4cb-7073-44eb-88fb-7fa52c5ee711', '712020:d5e0a8ab-acbf-4ad2-ba53-6da23b92e2d5', 'ZS17315'),
  ('조한빈', 'b0000000-0000-0000-0000-000000000001', '712020:403a306e-58c5-4b95-8aa4-b3f6441690e3', '', ''),
  ('이미진', 'b0000000-0000-0000-0000-000000000001', '712020:96cf8ab5-d5c5-46da-a0b5-e6bb6f76e0e1', '', '');
