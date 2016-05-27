Template['edit-http-service'].events
  'submit form': (e, tpl) ->
    e.preventDefault()
    jobData =
      name: e.target.serviceName.value
      group: e.target.groupName.value
      url: e.target.url.value
      regex: e.target.regex.value
      apiVersionUrl: e.target.getVersionUrl.value
      versionField: e.target.versionField.value.toLowerCase()

    if @service
      Meteor.call 'updateHttpService', @service._id, jobData
    else
      Meteor.call 'addHttpService', jobData
