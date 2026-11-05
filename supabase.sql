-- Run in Supabase SQL Editor after creating a project.
-- Public anonymous users may SUBMIT a pending wish, but only approved wishes are publicly readable.
create table if not exists public.wishes (
 id uuid primary key default gen_random_uuid(),
 content text not null check (char_length(trim(content)) between 4 and 120),
 approved boolean not null default false,
 created_at timestamptz not null default now()
);
create index if not exists wishes_approved_recent on public.wishes (approved, created_at desc);
alter table public.wishes enable row level security;
revoke all on public.wishes from anon, authenticated;
grant select (content, created_at) on public.wishes to anon, authenticated;
grant insert (content) on public.wishes to anon, authenticated;
create policy "public reads approved wishes" on public.wishes
 for select to anon, authenticated using (approved = true);
create policy "anonymous submits pending wishes" on public.wishes
 for insert to anon, authenticated with check (approved = false);
-- Important: add captcha/rate limiting and manual moderation before promoting a public wall.
-- Approve in Supabase dashboard: set approved=true only after reviewing content.
