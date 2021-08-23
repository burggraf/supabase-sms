# supabase-sms
Send and receive sms messages from Supabase / PostgreSQL using a Transactional SMS Provider

## Features
- Send an SMS message using the API of a Transactional SMS Provider 
  - [Twilio](https://twilio.com)
- Create and store an outgoing sms messages in a PostgreSQL table
- Other providers coming soon...

## Requirements
- Supabase account (free tier is fine)
  - Sending messages should work with any PostgreSQL database (no Supabase account required)
- A Transactional SMS Provider account
  - supported providers: Twilio

## Setup for SMS Providers:

See: [Twilio Setup](./SMS_Providers/Twilio.md)
