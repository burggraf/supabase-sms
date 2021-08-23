CREATE OR REPLACE FUNCTION public.send_sms_nexmo (message JSONB)
  RETURNS json
  LANGUAGE plpgsql
  SECURITY DEFINER -- required in order to read keys in the private schema
  -- Set a secure search_path: trusted schema(s), then 'pg_temp'.
  -- SET search_path = admin, pg_temp;
  AS $$
DECLARE
  retval json;
  NEXMO_API_KEY text;
  NEXMO_API_SECRET text;
  NEXMO_SENDER_NUMBER text;
BEGIN
  
  /*
  INSERT INTO private.keys (key, value) values ('NEXMO_API_KEY', '[NEXMO_API_KEY]');
INSERT INTO private.keys (key, value) values ('NEXMO_API_SECRET', '[NEXMO_API_SECRET]');
INSERT INTO private.keys (key, value) values ('NEXMO_SENDER_NUMBER', '[NEXMO_SENDER_NUMBER]');

  */
  SELECT value::text INTO NEXMO_API_KEY FROM private.keys WHERE key = 'NEXMO_API_KEY';
  IF NOT found THEN RAISE 'missing entry in private.keys: NEXMO_API_KEY'; END IF;
  SELECT value::text INTO NEXMO_API_SECRET FROM private.keys WHERE key = 'NEXMO_API_SECRET';
  IF NOT found THEN RAISE 'missing entry in private.keys: NEXMO_API_SECRET'; END IF;

  IF message->'sender' IS NOT NULL THEN 
    SELECT message->>'sender' INTO NEXMO_SENDER_NUMBER;
  ELSE
    SELECT value::text INTO NEXMO_SENDER_NUMBER FROM private.keys WHERE key = 'NEXMO_SENDER_NUMBER';
    IF NOT found THEN RAISE 'missing entry in private.keys: NEXMO_SENDER_NUMBER'; END IF;
  END IF;

/*
curl -X "POST" "https://rest.nexmo.com/sms/json" \
  -d "from=18885551212" \
  -d "text=A text message sent using the Vonage SMS API" \
  -d "to=14155551212" \
  -d "api_key=xxxxxxxx" \
  -d "api_secret=yyyyyyyyyyyyyyyy"
*/

  SELECT
    * INTO retval
  FROM
    http (('POST', 
      'https://rest.nexmo.com/sms/json', 
      NULL,
      'application/json', 
        json_build_object(
            'from', NEXMO_SENDER_NUMBER,
            'to', message->>'recipient',
            'text', message->>'body',
            'api_key', NEXMO_API_KEY,
            'api_secret', NEXMO_API_SECRET
        )::text
    ));
      -- if the sms_messages table exists, 
      -- and the response from the sms server contains an id
      -- mark this sms as 'queued' in our sms_messages table, otherwise leave it as 'ready'

      IF  (SELECT to_regclass('public.sms_messages')) IS NOT NULL AND 
          retval::text = '200' THEN
        UPDATE public.sms_messages SET status = 'queued', sender = NEXMO_SENDER_NUMBER WHERE id = (message->>'messageid')::UUID;
      END IF;

  RETURN retval;
END;
$$;
-- Do not allow this function to be called by public users (or called at all from the client)
REVOKE EXECUTE on function public.send_sms_nexmo FROM PUBLIC;
