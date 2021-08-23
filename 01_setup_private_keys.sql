CREATE SCHEMA IF NOT EXISTS private;
CREATE TABLE IF NOT EXISTS private.keys (
    key text primary key not null,
    value text
);
REVOKE ALL ON TABLE private.keys FROM PUBLIC;

/*******************************************************
*  IMPORTANT:  INSERT YOUR KEYS IN THE COMMANDS BELOW  *
********************************************************

-- [TWILIO_ACCOUNT_SID]
-- [TWILIO_AUTH_TOKEN]

(optional)
-- [TWILIO_SENDER_NUMBER]

**************************************************************/

INSERT INTO private.keys (key, value) values ('TWILIO_ACCOUNT_SID', '[TWILIO_ACCOUNT_SID]');

INSERT INTO private.keys (key, value) values ('TWILIO_AUTH_TOKEN', '[TWILIO_AUTH_TOKEN]');

-- INSERT INTO private.keys (key, value) values ('TWILIO_SENDER_NUMBER', '[TWILIO_SENDER_NUMBER]');