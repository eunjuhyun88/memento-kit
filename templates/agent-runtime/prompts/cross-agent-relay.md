# Cross-Agent Relay Prompt

Normalize relay messages so other agents receive:

- sender
- intended recipients
- source channel or room
- plain message body
- loop-prevention rule

Do not relay a message that already starts with the configured no-relay prefix.
