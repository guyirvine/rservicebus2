#Req

##What
This is the starting point for RServiceBus

A single client, using the agent to send a message

A single message handler, running inside rservicebus which receives 
the message and sends a reply

The client then picks up the reply

##How
make sure beanstalk is running, then

run the
  ./run

command in one terminal

in a second terminal, run
  ruby client.rb


