export set_message_visibility_timeout, listQueueUrls

"""
    listQueues( c::SQSChannel )
get the list of queue url links
"""
function listQueueUrls( c::SQSChannel )
    queues = SQS.ListQueues( c.awsEnv )
    queues.obj.queueUrlSet
end

function set_message_visibility_timeout( c::SQSChannel, messageHandle::String;
                                        timeout::Int = 300 )
    changeMessageVisibilityType = ChangeMessageVisibilityType(;
            queueUrl            = c.queueUrl,
            receiptHandle       = messageHandle,
            visibilityTimeout   = timeout )
    resp = ChangeMessageVisibility(c.awsEnv, changeMessageVisibilityType)
    if resp.http_code < 299
    	println("Changed Message Visibility timeout to $timeout")
    else
    	warn("Change Message Visibility Failed")
    end
end
