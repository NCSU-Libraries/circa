module NcsuDigitalImagesUtilities

  require 'net/http'

  def resource_identifier_from_url(url)

    if !url.match(/\//)
      url
    else
      path_segs = url.split('/')
      index_before = path_segs.index('catalog')
      if index_before
        id_seg = path_segs[index_before + 1]
        id_seg_split = id_seg.split(/[\#\?]+/)
        id_seg_split[0]
      else
        nil
      end
    end

  end


  def manifest_url(resource_identifier)
    "https://d.lib.ncsu.edu/collections/catalog/#{resource_identifier}/manifest"
  end


  def get_iiif_manifest(resource_identifier)
    url = manifest_url(resource_identifier)
    if ( response = Net::HTTP.get_response(URI(url)) )
      JSON.parse(response.body)
    end
  end

end
