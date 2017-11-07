using Base.Test
using SQSChannels

@testset "test sqs channel" begin 
    queueName = "testSQSChannel"
    c = SQSChannel( queueName )
    
    println("test purge queue ...")
    empty!(c)

    testmsg = "test message"

    println("test batch mode of put! ...")
    msgs = repeat([testmsg], outer = 24)
    put!(c, msgs)

    println("test put! a set of messages ...")
    msgCollection = Set("$i" for i in 1:5)
    put!(c, msgCollection)
    for i in 1:5
        msg = take!(c)
    end

    println("test put! a single message ...")
    put!(c, testmsg)
    sleep(10)

    println("test fetch message ...")
    handle, message = fetch(c)
    println("fetched message: $(message)")
    @test message == testmsg
end 
