

function Base.fetch( c::SQSChannel )
    msg = fetchSQSmessage( c.queueURL )
end
