
export SQSChannel

immutable SQSChannel <: AbstractChannel{Any}
    awsEnv              ::AWSEnv
    queueUrl            ::String
    # visibilityTimeout   ::Int       # unit is seconds
end

"""
    SQSChannel(queueUrl::String)
construct a SQSChannel, the queueUrl can also be a queue name
"""
function SQSChannel(queueUrl::String;
                    awsEnv = AWS.AWSEnv())
    if !contains(queueUrl, "https://sqs")
        # this is a queue name
        resp = SQS.GetQueueUrl( awsEnv; queueName = queueUrl )
        queueUrl = resp.obj.queueUrl
    end
    SQSChannel( awsEnv, queueUrl )
end
