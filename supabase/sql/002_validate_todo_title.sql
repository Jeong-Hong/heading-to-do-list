-- 트랜잭션 시작
begin;

-- 제목 길이를 코드 포인트 기준 1~100자로 제한
alter table public.todos -- 이미 존재하는 todos 테이블의 설정을 변경
add constraint todos_title_length_check -- 테이블에 제약 조건을 추가 'todos_title_length_check' 는 제약 이름
check (char_length(title) between 1 and 100); -- 제목 길이를 1~100자로 제한

-- JavaScript trim() 기준의 앞뒤 공백이 남은 제목을 차단
alter table public.todos
add constraint todos_title_trim_check
check (
    title = btrim(
        title,
        U&'\0009\000A\000B\000C\000D\0020\00A0\1680'
        || U&'\2000\2001\2002\2003\2004\2005\2006\2007'
        || U&'\2008\2009\200A\2028\2029\202F\205F\3000\FEFF'
    )
);

-- 트랜잭션의 변경을 확정
commit;