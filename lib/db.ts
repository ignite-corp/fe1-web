/**
 * 데이터베이스 클라이언트 (통합 모듈)
 *
 * Supabase를 기본 DB로 사용하지만, 환경변수만 변경하면
 * Supabase 호환 API를 제공하는 다른 서비스로 교체 가능합니다.
 *
 * 필수 환경변수:
 *   NEXT_PUBLIC_DB_URL        - DB URL (브라우저/서버 공용)
 *   NEXT_PUBLIC_DB_ANON_KEY   - 익명 키 (브라우저용)
 *   DB_SERVICE_ROLE_KEY       - 서비스 롤 키 (서버용, 선택)
 *
 * 하위 호환:
 *   기존 SUPABASE_* 환경변수도 자동 인식됩니다.
 */
import { createClient } from '@supabase/supabase-js';

const dbUrl =
  process.env.NEXT_PUBLIC_DB_URL ||
  process.env.NEXT_PUBLIC_SUPABASE_URL!;

const dbAnonKey =
  process.env.NEXT_PUBLIC_DB_ANON_KEY ||
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

const dbServiceKey =
  process.env.DB_SERVICE_ROLE_KEY ||
  process.env.SUPABASE_SERVICE_ROLE_KEY ||
  dbAnonKey;

/** 클라이언트용 DB (브라우저에서 사용, 익명 키) */
export const db = createClient(dbUrl, dbAnonKey);

/** 서버용 DB (API Routes / 배치에서 사용, 서비스 롤 키) */
export const dbServer = createClient(dbUrl, dbServiceKey);
