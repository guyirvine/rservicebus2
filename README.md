# rservicebus2

Use the examples directory as the starting point.

## General Approach

1. Convention over Configuration
2. Configuration via Environment Variables
3. Working examples provided for configuration

## General Config

### APPNAME
1. Name of process
2. Doubles as default queueName
3. Defaults to directory name

### MAX_RETRIES
1. If an exception is generated while processing a message, the message can be
retried. This allows the number of retries to be set.
2. Defaults to 5

### ERROR_QUEUE_NAME
1. If an exception is generated while processing a message, the message can be
retried. Once all retries are exhausted, the message will be put in the error queue.
2. This allows the name of the queue to be set.
3. Defaults to error

### WORKING_DIR
1. Where message handlers are looked for.
2. Defaults to current directory

### VERBOSE
1. Send out more logging to track message processing

### AUDIT_QUEUE_NAME
1. When set, a copy of all messages sent and received will be add to this queue

### RSBCRON_[msg name]
1. An empty message will be created and sent based on the cron string

## RSBMQ - Message queue
1. Environment Variable Name: RSBMQ

### Beanstalk

### Redis

### SQS
RSBMQ=aws://[region]/[queue_name]
