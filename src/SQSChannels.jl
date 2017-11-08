module SQSChannels
using AWSCore 
using AWSSQS
#using Retry

global const DEFAULT_REPEAT_TIMES = 3

export SQSChannel

export set_message_visibility_timeout, list_queue_urls

struct SQSChannel <: AbstractChannel
    queue               ::AWSSQS.AWSQueue
    # visibilityTimeout   ::Int       # unit is seconds
end

"""
    SQSChannel(queueUrl::String)
construct a SQSChannel, the queueUrl can also be a queue name
"""
function SQSChannel(queueName::String;
                    awsCre::Dict{Symbol, Any} = AWSCore.aws_config())
    queue = sqs_get_queue(awsCre, queueName)
    SQSChannel( queue )
end

function Base.show( io::IO, c::SQSChannel )
    show(io, c.queue)
end

function Base.put!(c::SQSChannel, messageBody::AbstractString)
    sqs_send_message(c.queue, messageBody) 
end

function Base.put!(c::SQSChannel, messageCollection::Set)
    put!(c, [messageCollection...])
end 

"""
    Base.put!( c::SQSChannel, messageCollection::Vector{String} )
put a collection of messages to SQS queue.
Note that this could be implemented using BatchSendMessage function
to it speedup and enhance the internet stability.
"""
function Base.put!( c::SQSChannel, messageCollection::Vector )
    # the maximum number of batched messages is 10!
    # http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-client-side-buffering-request-batching.html
    for x in 1:10:length(messageCollection)
        @show messageCollection[x:min( x+9, length(messageCollection)) ]
        sqs_send_message_batch(c.queue, messageCollection[x:min( x+9, length(messageCollection)) ])
    end 
end

function Base.fetch( c::SQSChannel )
    m = sqs_receive_message( c.queue )
    return m, m[:message]
end

function Base.delete!(c::SQSChannel, m)
    sqs_delete_message(c.queue, m)
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
    sqs_flush(c.queue)
end

function Base.start( c::SQSChannel ) nothing end

function Base.next( c::SQSChannel )
    sqs_receive_message(c.queue), nothing
end

function Base.done( c::SQSChannel ) false end

########################## utils ##########################

function set_message_visibility_timeout( c::SQSChannel, messageHandle::String;
                                        timeout::Int = 300 )
    error("unimplemented")
end

end # end of module
