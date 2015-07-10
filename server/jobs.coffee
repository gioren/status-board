@FailJob = (jobData) ->
  jobData.lastCheck = new Date()
  jobData.isUp = false
  Services.upsert {name: jobData.name}, jobData
  ServiceStatus.insert
    name: jobData.name
    date: jobData.lastCheck
    isUp: jobData.isUp

@SucceedJob = (jobData) ->
  jobData.lastCheck = new Date()
  jobData.isUp = true
  Services.upsert {name: jobData.name}, jobData
  ServiceStatus.insert
    name: jobData.name
    date: jobData.lastCheck
    isUp: jobData.isUp

Meteor.startup ->
  JobsCollection  = JobCollection 'jobs'
  JobsCollection.remove {}

  HttpStatusJob.create JobsCollection, 'App Control', 'http://iqtservices.isd.org:8080/'
  HttpStatusJob.create JobsCollection, 'ETCD', 'http://docker1.rni.org:4001/v2/keys/'
  HttpStatusJob.create JobsCollection, 'Discourse', 'http://iqtservices.isd.org:8181/'
  HttpStatusJob.create JobsCollection, 'Owncloud', 'http://iqtservices.isd.org:81/owncloud/'

  SshJob.create JobsCollection, 'Node21', '10.19.88.21', 'core', '~/.ssh/id_rsa', 'ls'
  SshJob.create JobsCollection, 'Node22', '10.19.88.22', 'core', '~/.ssh/id_rsa', 'ls'
  SshJob.create JobsCollection, 'Node23', '10.19.88.23', 'core', '~/.ssh/id_rsa', 'ls'
  SshJob.create JobsCollection, 'Node24', '10.19.88.24', 'core', '~/.ssh/id_rsa', 'ls'


  HttpStatusJob.process JobsCollection
  SshJob.process JobsCollection

  JobsCollection.startJobServer()
