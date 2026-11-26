-- a notebook for you · Supabase setup
-- Supabase → SQL Editor → New query → dán toàn bộ file này → Run. Chạy một lần là đủ.

-- File này chạy lại bao nhiêu lần cũng được (không mất dữ liệu cũ).

-- 1) Bảng: nhật ký, bài hát, ảnh, dạo này
create table if not exists public.diary (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  who text not null check (who in ('me','them')),
  text text not null check (char_length(text) between 1 and 2000)
);

create table if not exists public.songs (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  who text not null check (who in ('me','them')),
  title text not null check (char_length(title) between 1 and 80),
  artist text check (char_length(artist) <= 80),
  why text check (char_length(why) <= 200),
  link text check (char_length(link) <= 300)
);

create table if not exists public.photos (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  src text not null check (char_length(src) <= 500),
  path text check (char_length(path) <= 200),
  cap text check (char_length(cap) <= 80)
);

create table if not exists public.updates (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  who text not null check (who in ('me','them')),
  text text not null check (char_length(text) between 1 and 300),
  tag text check (char_length(tag) <= 30)
);

-- Mọi nội dung soạn sẵn khác (lời cổ vũ, điều sẽ sửa, kỷ niệm, lá thư, ID game, MBTI...)
create table if not exists public.items (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  section text not null check (char_length(section) between 1 and 30),
  who text check (who in ('me','them')),
  a text not null check (char_length(a) between 1 and 4000),
  b text check (char_length(b) <= 2000)
);

-- Những nơi đã đi (ghim trên bản đồ)
create table if not exists public.places (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  who text check (who in ('me','them')),
  name text not null check (char_length(name) between 1 and 80),
  lat double precision not null check (lat between -90 and 90),
  lng double precision not null check (lng between -180 and 180),
  visited text check (char_length(visited) <= 30),
  note text check (char_length(note) <= 300),
  src text check (char_length(src) <= 500),
  path text check (char_length(path) <= 200)
);

-- Cho phép "vì sao bài này" dài tới 5000 ký tự
alter table public.songs drop constraint if exists songs_why_check;
alter table public.songs add constraint songs_why_check check (char_length(why) <= 5000);

-- 2) Quyền: ai mở trang cũng đọc, thêm, sửa và xoá được (trang chỉ hai đứa biết link)
-- Cho trang (vai anon) dùng được các bảng qua Data API.
-- Cần dòng này khi lúc tạo project KHÔNG tick "Grant API access to new tables automatically".
grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on public.diary, public.songs, public.photos, public.updates, public.items, public.places to anon, authenticated;

alter table public.diary  enable row level security;
alter table public.songs  enable row level security;
alter table public.photos enable row level security;
alter table public.updates enable row level security;
alter table public.items  enable row level security;
alter table public.places enable row level security;

do $$
declare tb text;
begin
  foreach tb in array array['diary','songs','photos','updates','items','places'] loop
    execute format('drop policy if exists "notebook read" on public.%I', tb);
    execute format('drop policy if exists "notebook add" on public.%I', tb);
    execute format('drop policy if exists "notebook delete" on public.%I', tb);
    execute format('drop policy if exists "notebook edit" on public.%I', tb);
    execute format('create policy "notebook read" on public.%I for select to anon, authenticated using (true)', tb);
    execute format('create policy "notebook add" on public.%I for insert to anon, authenticated with check (true)', tb);
    execute format('create policy "notebook delete" on public.%I for delete to anon, authenticated using (true)', tb);
    execute format('create policy "notebook edit" on public.%I for update to anon, authenticated using (true) with check (true)', tb);
  end loop;
end $$;

-- 3) Realtime: một người thêm gì, người kia thấy ngay
do $$
begin
  begin alter publication supabase_realtime add table public.diary;  exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.songs;  exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.photos; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.updates; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.items;  exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.places; exception when duplicate_object then null; end;
end $$;

-- 4) Kho ảnh (public, mỗi ảnh tối đa 3 MB, chỉ JPEG vì trang tự nén ảnh sang JPEG)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('photos', 'photos', true, 3145728, array['image/jpeg'])
on conflict (id) do nothing;

drop policy if exists "notebook photos read" on storage.objects;
drop policy if exists "notebook photos add" on storage.objects;
drop policy if exists "notebook photos delete" on storage.objects;
create policy "notebook photos read"   on storage.objects for select to anon, authenticated using (bucket_id = 'photos');
create policy "notebook photos add"    on storage.objects for insert to anon, authenticated with check (bucket_id = 'photos');
create policy "notebook photos delete" on storage.objects for delete to anon, authenticated using (bucket_id = 'photos');
