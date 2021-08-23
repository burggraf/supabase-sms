# supabase-sms
Send and receive sms messages from Supabase / PostgreSQL using a Transactional SMS Provider

## Features
- Send an SMS message using the API of a Transactional SMS Provider 
  - [Twilio](https://twilio.com)
  - [SignalWire](https://signalwire.com)
  - [Nexmo](https://dashboard.nexmo.com) / Vonage
- Create and store an outgoing sms messages in a PostgreSQL table

## Requirements
- Supabase account (free tier is fine)
  - Sending messages should work with any PostgreSQL database (no Supabase account required)
- A Transactional SMS Provider account
  - supported providers: Twilio, SignalWire, Nexmo (Vonage)

## Setup for SMS Providers:

See: [Twilio Setup](./SMS_Providers/Twilio.md)
See: [SignalWire Setup](./SMS_Providers/SignalWire.md)
See: [Nexmo Setup](./SMS_Providers/Nexmo.md) / Vonage
