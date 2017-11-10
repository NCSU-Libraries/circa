# Provides valid paths to records in your local installation of ArchivesSpace, as well as corrsponding attribute values.
# Because much of the functionality in this app requires interaction with ArchivesSpace,
#   providing these sample paths is necessary for testing.

module AspaceApiSpecSupport

  def archivesspace_api_values
    [
      {
        repository_uri: '/repositories/2',
        resource_uri: '/repositories/2/resources/23',
        resource_title: 'Daniel Harvey Hill (1859 - 1924) Papers',
        resource_identifier: 'MC 00022',
        archival_object_uri: '/repositories/2/archival_objects/3004',
        # item_uri corresponds to values returned from archival_object uri above
        item_uri: '/repositories/2/top_containers/758',
        location_uri: '/locations/5960',
        location_title: 'Satellite [Range: 06, Section: E, Shelf: 09]'
      },
      {
        repository_uri: '/repositories/2',
        resource_uri: '/repositories/2/resources/23',
        archival_object_uri: '/repositories/2/archival_objects/3002',
        # item_uri corresponds to values returned from archival_object uri above
        item_uri: '/repositories/2/top_containers/756',
        location_uri: '/locations/5044',
        location_title: 'Satellite [Range: 06, Section: E, Shelf: 05]'
      },
      {
        repository_uri: '/repositories/2',
        resource_uri: '/repositories/2/resources/23',
        archival_object_uri: '/repositories/2/archival_objects/3027',
        # item_uri corresponds to values returned from archival_object uri above
        item_uri: '/repositories/2/top_containers/760',
        location_uri: '/locations/5960',
        location_title: 'Satellite [Range: 06, Section: E, Shelf: 09]'
      }
    ]
  end


  def archivesspace_same_box_api_values
    [
      {
        repository_uri: '/repositories/2',
        resource_uri: '/repositories/2/resources/23',
        archival_object_uri: '/repositories/2/archival_objects/3002',
        # item_uri corresponds to values returned from archival_object uri above
        item_uri: '/repositories/2/top_containers/756'
      },
      {
        repository_uri: '/repositories/2',
        resource_uri: '/repositories/2/resources/23',
        archival_object_uri: '/repositories/2/archival_objects/3003',
        # item_uri corresponds to values returned from archival_object uri above
        item_uri: '/repositories/2/top_containers/756'
      }
    ]
  end


  def archivesspace_digital_object_api_values
    {
      repository_uri: '/repositories/2',
      resource_uri: '/repositories/2/resources/1308',
      archival_object_uri: '/repositories/2/archival_objects/536895',
      # item_uri corresponds to values returned from archival_object uri above
      item_uri: '/repositories/2/digital_objects/5625'
    }
  end


  def archivesspace_multiple_digital_object_api_values
    {
      repository_uri: '/repositories/2',
      resource_uri: '/repositories/2/resources/1308',
      archival_object_uri: '/repositories/2/archival_objects/5185',
      # item_uri corresponds to values returned from archival_object uri above
      item_uris: [
        '/repositories/2/digital_objects/834',
        '/repositories/2/digital_objects/832',
        '/repositories/2/digital_objects/833'
      ]
    }
  end

end
