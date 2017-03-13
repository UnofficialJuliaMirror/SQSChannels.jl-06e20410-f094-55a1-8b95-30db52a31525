module SQSChannels

using AWS
using AWS.SQS
using Retry

global const DEFAULT_REPEAT_TIMES = 10

include("types.jl")
include("base.jl")
include("utils.jl")

end # end of module
