-- Fix Supabase critical lint: enable RLS on challenge_state with explicit policies.
-- Run once in Supabase Dashboard -> SQL Editor.
--
-- Your scoreboard is ONE shared row (id = 1), no user logins. Host phones and the
-- projector use the anon key. These policies document that intent and clear the lint.
-- award_team / adjust_team_score are SECURITY DEFINER and keep working as before.

ALTER TABLE public.challenge_state ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "challenge_state_public_read" ON public.challenge_state;
DROP POLICY IF EXISTS "challenge_state_public_update" ON public.challenge_state;
DROP POLICY IF EXISTS "challenge_state_public_insert" ON public.challenge_state;

-- Projector + hosts: read live scores
CREATE POLICY "challenge_state_public_read"
ON public.challenge_state
FOR SELECT
TO anon, authenticated
USING (id = 1);

-- Timer ticks, reset, and other direct table updates
CREATE POLICY "challenge_state_public_update"
ON public.challenge_state
FOR UPDATE
TO anon, authenticated
USING (id = 1)
WITH CHECK (id = 1);

-- First-time bootstrap if the row does not exist yet
CREATE POLICY "challenge_state_public_insert"
ON public.challenge_state
FOR INSERT
TO anon, authenticated
WITH CHECK (id = 1);

-- No DELETE policy = deletes are blocked (scores reset uses UPDATE, not DELETE)
