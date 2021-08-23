CREATE SCHEMA IF NOT EXISTS private;
CREATE TABLE IF NOT EXISTS private.keys (
    key text primary key not null,
    value text
);
REVOKE ALL ON TABLE private.keys FROM PUBLIC;

/*******************************************************
*  IMPORTANT:  INSERT YOUR KEYS IN THE COMMANDS BELOW  *
********************************************************

Twilio:
-- [TWILIO_ACCOUNT_SID]
-- [TWILIO_AUTH_TOKEN]

(optional)
-- [TWILIO_SENDER_NUMBER]

SignalWire:
-- [SIGNALWIRE_PROJECT_ID]
-- [SIGNALWIRE_AUTH_TOKEN]
-- [SIGNALWIRE_SPACE_ID] // i.e. https://your-space.signalwire.com

(optional)
-- [SIGNALWIRE_SENDER_NUMBER]

Nexmo/Vonage:
-- [NEXMO_API_KEY]
-- [NEXMO_API_SECRET]

(optional)
-- [NEXMO_SENDER_NUMBER]


**************************************************************/

INSERT INTO private.keys (key, value) values ('TWILIO_ACCOUNT_SID', '[TWILIO_ACCOUNT_SID]');
INSERT INTO private.keys (key, value) values ('TWILIO_AUTH_TOKEN', '[TWILIO_AUTH_TOKEN]');
INSERT INTO private.keys (key, value) values ('TWILIO_SENDER_NUMBER', '[TWILIO_SENDER_NUMBER]');

INSERT INTO private.keys (key, value) values ('SIGNALWIRE_PROJECT_ID', '[SIGNALWIRE_PROJECT_ID]');
INSERT INTO private.keys (key, value) values ('SIGNALWIRE_AUTH_TOKEN', '[SIGNALWIRE_AUTH_TOKEN]');
INSERT INTO private.keys (key, value) values ('SIGNALWIRE_SPACE_ID', '[SIGNALWIRE_SPACE_ID]');
INSERT INTO private.keys (key, value) values ('SIGNALWIRE_SENDER_NUMBER', '[SIGNALWIRE_SENDER_NUMBER]');

INSERT INTO private.keys (key, value) values ('NEXMO_API_KEY', '[NEXMO_API_KEY]');
INSERT INTO private.keys (key, value) values ('NEXMO_API_SECRET', '[NEXMO_API_SECRET]');
-- NOTE: Do not include the + at the beginning of NEXMO_SENDER_NUMBER
INSERT INTO private.keys (key, value) values ('NEXMO_SENDER_NUMBER', '[NEXMO_SENDER_NUMBER]');
