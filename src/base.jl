
function Base.put!(c::SQSChannel, messageBody::String)
    msgAttributes = MessageAttributeType[]
    resp = SendMessage(c.awsEnv;
                        queueUrl    = c.queueUrl,
                        delaySeconds= 0,
                        messageBody = messageBody,
                        messageAttributeSet=msgAttributes)
    if resp.http_code < 299
    	println("Sended a message: $(messageBody)")
    else
    	warn("Test for Send Message Failed")
    end
end

"""
    Base.put!( c::SQSChannel,
        messageCollection::Union{Set{String}, Vector{String}} )
put a collection of messages to SQS queue.
Note that this could be implemented using BatchSendMessage function
to it speedup and enhance the internet stability.
"""
function Base.put!( c::SQSChannel,
        messageCollection::Union{Set{String}, Vector{String}} )
    for msg in messageCollection
        put!(c, msg)
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
        # println("Test for Purge Queue Passed")
        return true
    else
        return false
        # println("Test for Purge Queue Failed")
    end
end
