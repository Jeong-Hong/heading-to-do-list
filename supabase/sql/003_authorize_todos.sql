-- 트랜잭션 시작
begin;

-- 회원 역할에 public 스키마의 사용 권한을 부여
-- authenticated: 로그인한 회원
-- 'GRANT'는 권한을 부여한다는 뜻
-- 'REVOKE'는 권한을 회수한다는 뜻
grant usage on schema public to authenticated;

-- 회원 역할에 조회와 삭제 권한을 부여
grant select, delete
on table public.todos
to authenticated;

-- 회원 식별자와 제목만 입력하도록 제한
grant insert (user_id, title)
on table public.todos
to authenticated;

-- 제목과 완료 여부만 수정하도록 제한
grant update (title, completed)
on table public.todos
to authenticated;

-- 자기 소유의 할 일만 조회하도록 허용
-- 'CREATE POLICY'는 행 단위 접근 정책을 생성 (RLS: Row Level Security)
-- 'todos_select_own'는 정책의 이름
-- 'for select'는 조회 정책
-- 'to authenticated'는 인증된 회원에게만 허용
-- 'using'은 조건을 지정
create policy todos_select_own
on public.todos
for select
to authenticated
using ((select auth.uid()) = user_id);

-- 자기 소유의 할 일만 등록하도록 허용
-- 'todos_insert_own'는 정책의 이름
-- 'for insert'는 삽입 정책
-- 'to authenticated'는 인증된 회원에게만 허용
-- 'with check'는 조건을 지정
create policy todos_insert_own
on public.todos
for insert
to authenticated
with check ((select auth.uid()) = user_id);

-- 수정 전후 모두 자기 소유인 할 일만 수정하도록 허용
-- 'using'은 수정 전 데이터를 검사 (기존 할 일이 내 소유인지)
-- 'with check'는 수정 후 데이터를 검사 (수정 후에도 내 소유인지)
-- 수정은 'using'과 'with check'가 모두 필요
-- why?: 수정 전후 데이터 모두 권한을 검사하기 때문
create policy todos_update_own
on public.todos
for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

-- 자기 소유의 할 일만 삭제하도록 허용
-- 삭제는 'with check'가 필요 없음
-- why?: 삭제 전 데이터에 대해 권한 검사하기 때문
create policy todos_delete_own
on public.todos
for delete
to authenticated
using ((select auth.uid()) = user_id);

-- 트랜잭션의 변경사항을 확정
commit;