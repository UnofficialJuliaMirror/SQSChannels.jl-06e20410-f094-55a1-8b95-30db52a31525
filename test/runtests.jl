using SQSChannels

queueName = "testSQSChannel"
c = SQSChannel( queueName )

put!(c, "test message")

handle, message = fetch(c)
