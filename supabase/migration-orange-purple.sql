-- Run in Supabase SQL Editor AFTER the first migration (adds orange + purple).

ALTER TABLE challenge_state
  ADD COLUMN IF NOT EXISTS orange int NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS purple int NOT NULL DEFAULT 0;

CREATE OR REPLACE FUNCTION award_team(p_team text, p_points int DEFAULT 3)
RETURNS SETOF challenge_state
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF p_team NOT IN ('red', 'blue', 'green', 'yellow', 'orange', 'purple') THEN
    RAISE EXCEPTION 'invalid team: %', p_team;
  END IF;
  RETURN QUERY
  UPDATE challenge_state SET
    red    = CASE WHEN p_team = 'red'    THEN red    + p_points ELSE red    END,
    blue   = CASE WHEN p_team = 'blue'   THEN blue   + p_points ELSE blue   END,
    green  = CASE WHEN p_team = 'green'  THEN green  + p_points ELSE green  END,
    yellow = CASE WHEN p_team = 'yellow' THEN yellow + p_points ELSE yellow END,
    orange = CASE WHEN p_team = 'orange' THEN orange + p_points ELSE orange END,
    purple = CASE WHEN p_team = 'purple' THEN purple + p_points ELSE purple END,
    round  = round + 1,
    updated_at = now()
  WHERE id = 1
  RETURNING *;
END;
$$;

CREATE OR REPLACE FUNCTION adjust_team_score(p_team text, p_delta int)
RETURNS SETOF challenge_state
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF p_team NOT IN ('red', 'blue', 'green', 'yellow', 'orange', 'purple') THEN
    RAISE EXCEPTION 'invalid team: %', p_team;
  END IF;
  RETURN QUERY
  UPDATE challenge_state SET
    red    = CASE WHEN p_team = 'red'    THEN GREATEST(0, red    + p_delta) ELSE red    END,
    blue   = CASE WHEN p_team = 'blue'   THEN GREATEST(0, blue   + p_delta) ELSE blue   END,
    green  = CASE WHEN p_team = 'green'  THEN GREATEST(0, green  + p_delta) ELSE green  END,
    yellow = CASE WHEN p_team = 'yellow' THEN GREATEST(0, yellow + p_delta) ELSE yellow END,
    orange = CASE WHEN p_team = 'orange' THEN GREATEST(0, orange + p_delta) ELSE orange END,
    purple = CASE WHEN p_team = 'purple' THEN GREATEST(0, purple + p_delta) ELSE purple END,
    updated_at = now()
  WHERE id = 1
  RETURNING *;
END;
$$;
