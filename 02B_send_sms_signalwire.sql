CREATE OR REPLACE FUNCTION public.send_sms_signalwire (message JSONB)
  RETURNS json
  LANGUAGE plpgsql
  SECURITY DEFINER -- required in order to read keys in the private schema
  -- Set a secure search_path: trusted schema(s), then 'pg_temp'.
  -- SET search_path = admin, pg_temp;
  AS $$
DECLARE
  retval json;
  SIGNALWIRE_PROJECT_ID text;
  SIGNALWIRE_AUTH_TOKEN text;
  SIGNALWIRE_SPACE_ID text;
  SIGNALWIRE_SENDER_NUMBER text;
BEGIN
  
  SELECT value::text INTO SIGNALWIRE_PROJECT_ID FROM private.keys WHERE key = 'SIGNALWIRE_PROJECT_ID';
  IF NOT found THEN RAISE 'missing entry in private.keys: SIGNALWIRE_PROJECT_ID'; END IF;
  SELECT value::text INTO SIGNALWIRE_AUTH_TOKEN FROM private.keys WHERE key = 'SIGNALWIRE_AUTH_TOKEN';
  IF NOT found THEN RAISE 'missing entry in private.keys: SIGNALWIRE_AUTH_TOKEN'; END IF;
  SELECT value::text INTO SIGNALWIRE_SPACE_ID FROM private.keys WHERE key = 'SIGNALWIRE_SPACE_ID';
  IF NOT found THEN RAISE 'missing entry in private.keys: SIGNALWIRE_SPACE_ID'; END IF;

  IF message->'sender' IS NOT NULL THEN 
    SELECT message->>'sender' INTO SIGNALWIRE_SENDER_NUMBER;
  ELSE
    SELECT value::text INTO SIGNALWIRE_SENDER_NUMBER FROM private.keys WHERE key = 'SIGNALWIRE_SENDER_NUMBER';
    IF NOT found THEN RAISE 'missing entry in private.keys: SIGNALWIRE_SENDER_NUMBER'; END IF;
  END IF;

/*
curl https://your-space.signalwire.com/api/relay/rest/sip_endpoints \
      -u 'YourProjectID:YourAuthToken'

curl https://example.signalwire.com/api/laml/2010-04-01/Accounts/{AccountSid}/Messages.json \
  -X POST \
  --data-urlencode "From=+15551234567" \
  --data-urlencode "Body=Hello World\!" \
  --data-urlencode "To=+15557654321" \
  -u "YourProjectID:YourAuthToken"

*/
  SELECT
    * INTO retval
  FROM
    http (('POST', 
      'https://' || SIGNALWIRE_SPACE_ID || '.signalwire.com/api/laml/2010-04-01/Accounts/' || SIGNALWIRE_PROJECT_ID || '/Messages.json', 
      ARRAY[http_header ('Authorization', 
      'Basic ' || regexp_replace(encode((SIGNALWIRE_PROJECT_ID || ':' || SIGNALWIRE_AUTH_TOKEN)::bytea, 'base64')::text, '\s', '', 'g'))], 
      'application/x-www-form-urlencoded', 
      'From=' || urlencode (SIGNALWIRE_SENDER_NUMBER) || 
      '&To=' || urlencode (message->>'recipient') || 
      '&Body=' || urlencode(message->>'body')));
      -- if the sms_messages table exists, 
      -- and the response from the sms server contains an id
      -- mark this sms as 'queued' in our sms_messages table, otherwise leave it as 'ready'

      IF  (SELECT to_regclass('public.sms_messages')) IS NOT NULL AND 
          retval::text = '201' THEN
        UPDATE public.sms_messages SET status = 'queued' WHERE id = (message->>'messageid')::UUID;
      END IF;

  RETURN retval;
END;
$$;
-- Do not allow this function to be called by public users (or called at all from the client)
REVOKE EXECUTE on function public.send_sms_signalwire FROM PUBLIC;
