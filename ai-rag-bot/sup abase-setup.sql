-- Run this once in Supabase SQL Editor before importing the n8n workflows.


-- NOTE: This schema is a starting template, not fixed. It can be customized
-- per client/consumer needs — for example: additional metadata fields
-- (category, date, author, availability), a different embedding dimension if a different
-- Voyage model is used, tighter or looser similarity thresholds in
-- match_documents(), or splitting into multiple tables if client needs
-- separate knowledge bases per product line or department.


-- 1. Enable the vector extension
create extension if not exists vector;

-- 2. Table to hold your knowledge base chunks
create table if not exists documents (
  id bigserial primary key,
  content text not null,
  metadata jsonb default '{}'::jsonb,   -- e.g. { "source": "pricing.pdf", "section": "packages" }
  embedding vector(1024),               -- 1024 = voyage-4-lite dimension
  created_at timestamptz default now()
);

-- 3. Index for fast similarity search
create index if not exists documents_embedding_idx
  on documents using ivfflat (embedding vector_cosine_ops)
  with (lists = 100);

-- 4. Function n8n will call to do the actual similarity search
create or replace function match_documents (
  query_embedding vector(1024),
  match_count int default 4
)
returns table (
  id bigint,
  content text,
  metadata jsonb,
  similarity float
)
language sql stable
as $$
  select
    documents.id,
    documents.content,
    documents.metadata,
    1 - (documents.embedding <=> query_embedding) as similarity
  from documents
  order by documents.embedding <=> query_embedding
  limit match_count;
$$;
