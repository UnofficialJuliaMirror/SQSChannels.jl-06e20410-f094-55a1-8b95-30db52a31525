SQSChannels.jl
===============
[![Build Status](https://travis-ci.org/seung-lab/SQSChannels.jl.svg?branch=master)](https://travis-ci.org/seung-lab/SQSChannels.jl)

use AWS SQS as a Julia RemoteChannel

Note: this package was deprecated in favor of AWSSQSMessages in [AWSSQS.jl](https://github.com/samoconnor/AWSSQS.jl). 

## Installation
    Pkg.add("SQSChannels")

## Usage
```
using SQSChannels

queueName = "testSQSChannel"
c = SQSChannel( queueName )

println("test purge queue ...")
empty!(c)

testmsg = "test message"

println("test put! single message ...")
put!(c, testmsg)

println("test fetch message ...")
handle, message = fetch(c)
println("fetched message: $(message)")
@assert message == testmsg

println("test take message ...")
put!(c, testmsg)
message = take!(c)
@assert message == testmsg
println("test batch sending of a collection of messages")
msgCollection = Set("$i" for i in 1:5)

println("test put! a collection of messages using Batch mode ...")
put!(c, msgCollection)
```
