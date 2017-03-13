
function Base.put!(c::SQSChannel, messageBody::String)
    msgAttributes = MessageAttributeType[]
    resp = SendMessage(c.awsEnv;
                        queueUrl    = c.queueUrl,
                        delaySeconds= 0,
                        messageBody = messageBody,
                        messageAttributeSet=msgAttributes)
    if resp.http_code < 299
    	println("Sended a message")
    else
    	warn("Test for Send Message Failed")
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
