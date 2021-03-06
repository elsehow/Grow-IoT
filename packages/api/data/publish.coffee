# Should rename to device data points?
new PublishEndpoint 'Data.points', (deviceUuid) ->
  # TODO: Do better checks.
  check deviceUuid, Match.NonEmptyString

  device = Device.documents.findOne
    'uuid': deviceUuid
    'owner._id': this.userId
  ,
    fields:
      _id: 1

  throw new Meteor.Error 'not-found', "Device '#{deviceUuid}' cannot be found." unless device

  # TODO: refine query to remove events.
  Data.documents.find
    'device._id': device._id
  ,
    'sort':
      'insertedAt': -1
    'limit': 100

new PublishEndpoint 'Data.pointsByType', (deviceUuid, type) ->
  # TODO: Do better checks.
  check deviceUuid, Match.NonEmptyString
  check type, Match.NonEmptyString

  device = Device.documents.findOne
    'uuid': deviceUuid
  ,
    fields:
      _id: 1

  throw new Meteor.Error 'not-found', "Device '#{deviceUuid}' cannot be found." unless device

  # TODO: refine query to remove events.
  Data.documents.find
    'device._id': device._id
    'data.type': type
    'event':
      $exists: false
  ,
    'sort':
      'insertedAt': -1
    'limit': 100


new PublishEndpoint 'Data.events', (deviceUuid) ->
  check deviceUuid, Match.NonEmptyString

  device = Device.documents.findOne
    'uuid': deviceUuid
    'owner._id': this.userId
  ,
    fields:
      _id: 1

  throw new Meteor.Error 'not-found', "Device '#{deviceUuid}' cannot be found." unless device

  # Return data documents with an event field.
  Data.documents.find
    'device._id': device._id
    'event':
      $exists: true
  ,
    'sort':
      'insertedAt': -1
