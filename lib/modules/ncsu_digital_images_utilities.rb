module NcsuDigitalImagesUtilities

  require 'net/http'

  def image_id_from_url(url)
    if url.match(/^\d*$/)
      url
    else
      path_segs = url.split('/')
      index_before = path_segs.index('catalog')
      if index_before
        id_seg = path_segs[index_before + 1]
        id_seg.gsub(/[^\d].*/,'')
      else
        nil
      end
    end
  end


  def manifest_url(image_id)
    "https://d.lib.ncsu.edu/collections/catalog/#{image_id}/manifest"
  end


  def get_iiif_manifest(image_id)
    url = manifest_url(image_id)
    if ( response = Net::HTTP.get_response(URI(url)) )
      JSON.parse(response.body)
    end
  end

end
