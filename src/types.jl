const DEFAUL_TIMEOUT = 


immutable SQSChannel <: AbstractChannel
    awsEnv      ::AWSEnv
    queueURL    ::String
    timeout     ::Int       # unit is seconds
end

"""
    SQSChannel(queueURL::String)
construct a SQSChannel, the queueURL can also be a queue name
"""
function SQSChannel(queueURL::String; timeout = )
    if !contains(queueURL, "https://sqs.")
        # this is a queue name
        queueURL = get_qurl( queueURL )
    end
    awsEnv = AWS.AWSEnv()
    SQSChannel( awsEnv, queueURL )
end
