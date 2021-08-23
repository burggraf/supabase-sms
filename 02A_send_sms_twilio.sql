CREATE OR REPLACE FUNCTION public.send_sms_twilio (message JSONB)
  RETURNS json
  LANGUAGE plpgsql
  SECURITY DEFINER -- required in order to read keys in the private schema
  -- Set a secure search_path: trusted schema(s), then 'pg_temp'.
  -- SET search_path = admin, pg_temp;
  AS $$
DECLARE
  retval json;
  TWILIO_ACCOUNT_SID text;
  TWILIO_AUTH_TOKEN text;
  TWILIO_SENDER_NUMBER text;
BEGIN
  
  SELECT value::text INTO TWILIO_ACCOUNT_SID FROM private.keys WHERE key = 'TWILIO_ACCOUNT_SID';
  IF NOT found THEN RAISE 'missing entry in private.keys: TWILIO_ACCOUNT_SID'; END IF;
  SELECT value::text INTO TWILIO_AUTH_TOKEN FROM private.keys WHERE key = 'TWILIO_AUTH_TOKEN';
  IF NOT found THEN RAISE 'missing entry in private.keys: TWILIO_AUTH_TOKEN'; END IF;

  IF message->'sender' IS NOT NULL THEN 
    SELECT message->>'sender' INTO TWILIO_SENDER_NUMBER;
  ELSE
    SELECT value::text INTO TWILIO_SENDER_NUMBER FROM private.keys WHERE key = 'TWILIO_SENDER_NUMBER';
    IF NOT found THEN RAISE 'missing entry in private.keys: TWILIO_SENDER_NUMBER'; END IF;
  END IF;

  SELECT
    * INTO retval
  FROM
    http (('POST', 
      'https://api.twilio.com/2010-04-01/Accounts/' || TWILIO_ACCOUNT_SID || '/Messages.json', 
      ARRAY[http_header ('Authorization', 
      'Basic ' || regexp_replace(encode((TWILIO_ACCOUNT_SID || ':' || TWILIO_AUTH_TOKEN)::bytea, 'base64')::text, '\s', '', 'g'))], 
      'application/x-www-form-urlencoded', 
      'From=' || urlencode (TWILIO_SENDER_NUMBER) || 
      '&To=' || urlencode (message->>'recipient') || 
      '&Body=' || urlencode(message->>'body')));
      -- if the sms_messages table exists, 
      -- and the response from the sms server contains an id
      -- mark this sms as 'queued' in our sms_messages table, otherwise leave it as 'ready'

      IF  (SELECT to_regclass('public.sms_messages')) IS NOT NULL AND 
          retval::text = '201' THEN
        UPDATE public.sms_messages SET status = 'queued', sender = TWILIO_SENDER_NUMBER WHERE id = (message->>'messageid')::UUID;
      END IF;

  RETURN retval;
END;
$$;
-- Do not allow this function to be called by public users (or called at all from the client)
REVOKE EXECUTE on function public.send_sms_twilio FROM PUBLIC;
