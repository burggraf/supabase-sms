# using supabase-sms with SignalWire

## Step 1:  Setup your private keys

Execute the following code in a SQL Query window:

```sql
INSERT INTO private.keys (key, value) values ('SIGNALWIRE_PROJECT_ID', 'aaaaaaaaaa');
INSERT INTO private.keys (key, value) values ('SIGNALWIRE_AUTH_TOKEN', 'bbbbbbbbbb');
INSERT INTO private.keys (key, value) values ('SIGNALWIRE_SPACE_ID', 'cccccccccc');
-- This is optional
INSERT INTO private.keys (key, value) values ('SIGNALWIRE_SENDER_NUMBER', '+1dddddddddd');
```
Where:
`aaaaaaaaaa` is your SignalWire Project ID
`bbbbbbbbbb` is your SignalWire Auth Token
`bbbbbbbbbb` is your SignalWire Space ID, i.e. https://[SPACE-ID].signalwire.com
`+1dddddddddd` is your SignalWire Sender Phone Number

NOTE:  if you don't provide a secret key for `SIGNALWIRE_SENDER_NUMBER`, then you must pass `message.sender` to `send_sms_message()`.  This allows you to use multiple sender numbers within a single application.

## Step 2: Create the `send_sms_message` function

Run the `SQL` code contained in [02_send_sms_message.sql](02_send_sms_message.sql) in a query window to create the PostgreSQL function.  NOTE:  You must modify this function for SignalWire.  See the line:
```sql
sms_provider text := 'signalwire';
```

## Step 2A: Create the `send_sms_signalwire` function
Run the `SQL` code contained in [02B_send_sms_signalwire.sql](../02B_send_sms_signalwire.sql) in a query window to create the PostgreSQL function. 

## Send a test message

You can send a test message from a query window like this:

```sql
select send_sms_message('{
  "recipient": "+14155551234",
  "body": "Hello, world, from from supabase-sms."
}');
```

Or, if you have not set a key for `SIGNALWIRE_SENDER_NUMBER`, use:
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

