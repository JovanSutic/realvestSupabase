CREATE TABLE IF NOT EXISTS public.user_roles (
  id        serial primary key,
  user_id   uuid references auth.users on delete cascade not null,
  role      varchar(50) not null,
  unique (user_id, role)
);