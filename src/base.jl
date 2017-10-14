
function Base.show( io::IO, c::SQSChannel )
    show(c.queueUrl)
end

function Base.put!(c::SQSChannel, messageBody::AbstractString)
    msgAttributes = MessageAttributeType[]
    resp = SendMessage(c.awsEnv;
                        queueUrl    = c.queueUrl,
                        delaySeconds= 0,
                        messageBody = messageBody,
                        messageAttributeSet=msgAttributes)
    if resp.http_code < 299
    	println("Sended a message: $(messageBody)")
    else
    	warn("Sending Message Failed")
    end
end

function Base.put!(c::SQSChannel, messageCollection::Set)
    put!(c, [messageCollection...])
end 

"""
    Base.put!( c::SQSChannel,
        messageCollection::Union{Set{String}, Vector{String}} )
put a collection of messages to SQS queue.
Note that this could be implemented using BatchSendMessage function
to it speedup and enhance the internet stability.
"""
function Base.put!( c::SQSChannel,
        messageCollection::Vector )

    # the maximum number of batched messages is 10!
    # http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-client-side-buffering-request-batching.html
    for x in 1:10:length(messageCollection)
        entrySet = Vector{SendMessageBatchRequestEntryType}()
        for y in 1:10
            id = x + y - 1
            if id < length(messageCollection)
                msg = messageCollection[id]
                push!(entrySet, 
                      SendMessageBatchRequestEntryType(; 
                            id="$(id)-$(randstring())",
                            messageBody = String(msg)))
            end 
        end  
        sendMessageBatchType = SendMessageBatchType(; 
            sendMessageBatchRequestEntrySet = entrySet, queueUrl = c.queueUrl)
        resp = SendMessageBatch(c.awsEnv, sendMessageBatchType)
        if resp.http_code < 299
            println("sended a batch of messages. ID from $x")
        else
            error("sending a batch of messages failed: $(resp)")
        end 
    end 
end

function Base.fetch( c::SQSChannel )
    local resp
    @repeat DEFAULT_REPEAT_TIMES try
        resp=ReceiveMessage(c.awsEnv; queueUrl=c.queueUrl,
                attributeNameSet=["All"], messageAttributeNameSet=["All"])
    catch e
        @show e
    end
    msg = resp.obj.messageSet[1]
    return msg.receiptHandle, msg.body
end

function Base.delete!(c::SQSChannel, handle::String)
    DeleteMessage(c.awsEnv; queueUrl = c.queueUrl,
                        receiptHandle = handle)
end

function Base.take!( c::SQSChannel )
    handle, body = fetch(c)
    delete!( c, handle )
    return body
end

function Base.isempty( c::SQSChannel )
    error("not implemented")
end

function Base.empty!( c::SQSChannel )
    resp = PurgeQueue(c.awsEnv; queueUrl=c.queueUrl)
    if resp.http_code < 299
        println("Purge Queue Passed")
    else
        error("Purge Queue Failed: $resp")
    end
end

function Base.start( c::SQSChannel )
    error("unimplemented")
end

function Base.next( c::SQSChannel )
    error("unimplemented")
end

function Base.done( c::SQSChannel )
    error("unimplemented")
end
