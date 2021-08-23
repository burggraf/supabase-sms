/************************************************************
 *
 * Function:  send_sms_message
 * 
 * low level function to send sms message
 *
 * Parameters:
 *  body // text message content
 *  recipient // cell number of recipient
 *  (OPTIONAL) sender // cell number of sender
 *
 *  If sender is not specified, the default sender will be used from private.keys: 
 *   [PROVIDER]_SENDER_NUMBER
 ************************************************************/
CREATE EXTENSION IF NOT EXISTS HTTP;
drop function send_sms_message;
CREATE OR REPLACE FUNCTION public.send_sms_message (message JSONB)
  RETURNS json
  LANGUAGE plpgsql
  -- SECURITY DEFINER -- required in order to read keys in the private schema
  -- Set a secure search_path: trusted schema(s), then 'pg_temp'.
  -- SET search_path = admin, pg_temp;
  AS $$
DECLARE
  -- variable declaration
  sms_provider text := 'twilio'; -- 'twilio'
  retval json;
  messageid text;
BEGIN


  IF message->'body' IS NULL THEN RAISE 'message.body is required'; END IF;  

  IF message->'recipient' IS NULL THEN RAISE 'message.recipient is required'; END IF;

  IF message->'messageid' IS NULL AND (SELECT to_regclass('public.sms_messages')) IS NOT NULL THEN
    -- messages table exists, so save this message in the messages table
    INSERT INTO public.sms_messages(recipient, sender, body, status, log)
    VALUES (message->'recipient', message->'sender', message->'body', 'ready', '[]'::jsonb) RETURNING id INTO messageid;
    select message || jsonb_build_object('messageid',messageid) into message;
  END IF;

  EXECUTE 'SELECT send_sms_' || sms_provider || '($1)' INTO retval USING message;
  -- SELECT send_email_mailgun(message) INTO retval;
  -- SELECT send_email_sendgrid(message) INTO retval;

  RETURN retval;
END;
$$;
-- Do not allow this function to be called by public users (or called at all from the client)
REVOKE EXECUTE on function public.send_sms_message FROM PUBLIC;

-- To allow, say, authenticated users to call this function, you would use:
-- GRANT EXECUTE ON FUNCTION public.send_sms_message TO authenticated;


