-- 트랜잭션을 시작
begin;

-- 회원별 할 일을 저장
create table public.todos (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users (id),
    title text not null,
    completed boolean not null default false,
    created_at timestamptz not null default now()
);

-- 행 단위 접근 검사를 활성화
alter table public.todos enable row level security;

-- 권한 구성을 마칠 때까지 일반 요청의 접근을 차단
revoke all privileges on table public.todos
from public, anon, authenticated;

-- 트랜잭션의 변경을 확정
commit;