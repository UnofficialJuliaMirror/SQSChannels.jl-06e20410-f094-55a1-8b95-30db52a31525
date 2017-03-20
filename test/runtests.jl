using SQSChannels

queueName = "testSQSChannel"
c = SQSChannel( queueName )

println("test purge queue ...")
empty!(c)

testmsg = "test message"

println("test put! single message ...")
put!(c, testmsg)

println("test fetch message ...")
handle, message = fetch(c)
println("fetched message: $(message)")
@assert message == testmsg

println("test take message ...")
put!(c, testmsg)
message = take!(c)
@assert message == testmsg

println("test batch sending of a collection of messages")
msgCollection = Set("$i" for i in 1:5)

println("test put! a collection of messages ...")
put!(c, msgCollection)

for i in 1:5
    msg = take!(c)
    @show msg
    @assert msg in msgCollection
end
