# using supabase-sms with Twilio

## Step 1:  Setup your private keys

Execute the following code in a SQL Query window:

```sql
INSERT INTO private.keys (key, value) values ('TWILIO_ACCOUNT_SID', 'aaaaaaaaaa');

INSERT INTO private.keys (key, value) values ('TWILIO_AUTH_TOKEN', 'bbbbbbbbbb');

-- This is optional
INSERT INTO private.keys (key, value) values ('TWILIO_SENDER_NUMBER', '+1cccccccccc');

```
Where:
`aaaaaaaaaa` is your Twilio Account SID Key
`bbbbbbbbbb` is your Twilio Auth Token
`+1cccccccccc` is your Twilio Sender Phone Number

NOTE:  if you don't provide a secret key for `TWILIO_SENDER_NUMBER`, then you must pass `message.sender` to `send_sms_message()`.  This allows you to use multiple sender numbers within a single application.

## Step 2: Create the `send_sms_message` function

Run the `SQL` code contained in [02_send_sms_message.sql](02_send_sms_message.sql) in a query window to create the PostgreSQL function.  NOTE:  You may need to modify this function for Twilio.  See the line:
```sql
sms_provider text := 'twilio';
```

## Step 2A: Create the `send_sms_twilio` function
Run the `SQL` code contained in [02A_send_sms_twilio.sql](../02A_send_sms_twilio.sql) in a query window to create the PostgreSQL function. 

## Send a test message

You can send a test message from a query window like this:

```sql
select send_sms_message('{
  "recipient": "+14155551234",
  "body": "Hello, world, from from supabase-sms."
}');
```

Or, if you have not set a key for `TWILIO_SENDER_NUMBER`, use:
```sql
select send_sms_message('{
  "recipient": "+14155551234",
  "body": "Hello, world, from from supabase-sms.",
  "sender": "+4155555678"
}');
```

If you've got everything setup correctly, you'll get a JSON object back with the Provider's response, such as:
```
201
```

At this point, you have everything you need to send messages.  If you want to track your sms messages, read on.

## Step 3: (Optional) Create the sms_messages table (for tracking sms messages)

Run the `SQL` code from [03_setup_sms_messages_table.sql](../03_setup_sms_messages_table.sql) in a query window to create the table that will store your email messages.  When the `send_sms_message` function senses that this table exists, it will store your sms messages in this table automatically when you send them.

