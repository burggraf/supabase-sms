/************************************************************
*  Create the sms_messages table
************************************************************/
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE TABLE if not exists public.sms_messages
(
    id uuid primary key default uuid_generate_v4(),
    recipient text,
    sender text,
    body text,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    status text,
    deliveryresult jsonb,
    deliverysignature jsonb,
    log jsonb
);
ALTER TABLE public.sms_messages OWNER TO supabase_admin;
ALTER TABLE public.sms_messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "sms_messages delete policy" ON public.messages FOR DELETE USING (false);
CREATE POLICY "sms_messages insert policy" ON public.messages FOR INSERT WITH CHECK (false);
CREATE POLICY "sms_messages select policy" ON public.messages FOR SELECT USING (false);
CREATE POLICY "sms_messages update policy" ON public.messages FOR UPDATE USING (false) WITH CHECK (false);

