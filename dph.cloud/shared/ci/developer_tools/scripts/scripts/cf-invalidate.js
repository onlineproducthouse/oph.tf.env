'use strict'

const aws = require('aws-sdk')
const cf = new aws.CloudFront()

// Required Environment Variable
//
// S3_WEBSITE_ENDPOINT

const cfListDistributionsAsync = () => {
    return new Promise(resolve => cf.listDistributions({}, (error, result) => {
        if (error)
            throw error

        return resolve(result)
    }))
}

const getTargetOriginId = cfListDistributions => {
    let id = ""

    for (let i = 0; i < cfListDistributions.length; i++) {
        if (cfListDistributions[i].DefaultCacheBehavior.TargetOriginId === process.env.S3_WEBSITE_ENDPOINT) {
            id = cfListDistributions[i].DefaultCacheBehavior.TargetOriginId
            break
        }
    }

    return id
}

const cfCreateInvalidation = DistributionId => {
    if (DistributionId === "")
        return console.log("DistributionId Not Set")

    const params = {
        DistributionId,
        InvalidationBatch: {
            CallerReference: (new Date).toString(),
            Paths: { Items: ['/index.html'], Quantity: 1, }
        }
    }

    return new Promise(resolve => cf.createInvalidation(params, (error, result) => {
        if (error)
            throw error

        return resolve(result)
    }))
}

const run = async() => {
    try {
        const cfListDistributions = await cfListDistributionsAsync()
        const cfCreateInvalidationResult = await cfCreateInvalidation(getTargetOriginId(cfListDistributions))

        console.log("Invalidation Result")
        console.log(cfCreateInvalidationResult)
    } catch (error) {
        console.log("Error")
        console.log(error)
    }
}

run().then(console.log).catch(console.log)