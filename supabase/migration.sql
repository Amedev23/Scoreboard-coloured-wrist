-- Run in Supabase Dashboard -> SQL Editor (once before the event).

ALTER TABLE challenge_state
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

UPDATE challenge_state SET updated_at = now() WHERE updated_at IS NULL;

CREATE OR REPLACE FUNCTION award_team(p_team text, p_points int DEFAULT 3)
RETURNS SETOF challenge_state
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF p_team NOT IN ('red', 'blue', 'green', 'yellow') THEN
    RAISE EXCEPTION 'invalid team: %', p_team;
  END IF;
  RETURN QUERY
  UPDATE challenge_state SET
    red    = CASE WHEN p_team = 'red'    THEN red    + p_points ELSE red    END,
    blue   = CASE WHEN p_team = 'blue'   THEN blue   + p_points ELSE blue   END,
    green  = CASE WHEN p_team = 'green'  THEN green  + p_points ELSE green  END,
    yellow = CASE WHEN p_team = 'yellow' THEN yellow + p_points ELSE yellow END,
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
  IF p_team NOT IN ('red', 'blue', 'green', 'yellow') THEN
    RAISE EXCEPTION 'invalid team: %', p_team;
  END IF;
  RETURN QUERY
  UPDATE challenge_state SET
    red    = CASE WHEN p_team = 'red'    THEN GREATEST(0, red    + p_delta) ELSE red    END,
    blue   = CASE WHEN p_team = 'blue'   THEN GREATEST(0, blue   + p_delta) ELSE blue   END,
    green  = CASE WHEN p_team = 'green'  THEN GREATEST(0, green  + p_delta) ELSE green  END,
    yellow = CASE WHEN p_team = 'yellow' THEN GREATEST(0, yellow + p_delta) ELSE yellow END,
    updated_at = now()
  WHERE id = 1
  RETURNING *;
END;
$$;

GRANT EXECUTE ON FUNCTION award_team(text, int) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION adjust_team_score(text, int) TO anon, authenticated;
