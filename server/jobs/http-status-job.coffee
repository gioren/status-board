request = Meteor.npmRequire('hyperdirect')(10)
dotize = Meteor.npmRequire('dotize')

@HttpStatusJob =
  create: (jobData) ->
    Services.insert _.extend(jobData, {type: 'http'})

  update: (id, jobData) ->
    Services.update {_id: id}, $set: jobData

  job: (task, done) ->  @performCheck task, done, 0

  performCheck: (job, callback, retryCount) ->
    console.log 'check =>', job.data.url
    stream = request job.data.url,
      timeout: 10000

    stream.on 'error', Meteor.bindEnvironment (err) =>
      if retryCount > 2
        console.log "HTTP.Error #{job.data.url} =>", err
        FailJob job, callback
      else
        @retryJob job, callback, retryCount

    stream.on 'response', Meteor.bindEnvironment (response) =>
      if response.statusCode >= 200 and response.statusCode < 300
        HttpStatusJob.getAppVersion job if job.data.apiVersionUrl
        if job.data.regex
          result = ""
          response.on 'data', (data) -> result = result + data.toString()
          response.on 'end', Meteor.bindEnvironment =>
            if result.match new RegExp(job.data.regex, 'i')
              CompleteJob job, callback
            else
              FailJob job, callback
        else
          CompleteJob job, callback
      else
        if retryCount > 2
          console.log "HTTP.StatusCode err #{job.data.url} => #{response.statusCode}"
          FailJob job, callback
        else
          @retryJob job, callback, retryCount

  getAppVersion: (job) ->
    HTTP.get job.data.apiVersionUrl, (err, res) ->
      console.error err if err
      appVersion = (dotize.convert res)[job.data.versionField]
      Services.update {_id: job.data._id}, $set: { appVersion: appVersion }

  retryJob: (job, callback, retryCount) ->
    Meteor.setTimeout =>
      console.log 'retrying job', job.data.url
      @performCheck job, callback, retryCount+1
    , 2000
