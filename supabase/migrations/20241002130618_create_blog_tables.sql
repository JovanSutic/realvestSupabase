CREATE TABLE IF NOT EXISTS "public"."blogs" (
"id"  serial primary key NOT NULL,
"name" varchar(256),
"description" text,
"slug" varchar(256),
"media_link" varchar(256),
"date_created" date,
"language" varchar(10)
);

CREATE TABLE IF NOT EXISTS "public"."blogs_content" (
"id"  serial primary key NOT NULL,
"type" varchar(20),
"sequence" int,
"content" text,
"blog_id" bigint,
constraint "blog_id"
     foreign key ("blog_id") 
     REFERENCES "blogs" ("id")
)