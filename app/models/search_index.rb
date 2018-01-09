class SearchIndex

  include SolrConnect

  @@batch_size = 50

  def self.wipe_index
    @solr = RSolr.connect :url => @@solr_url
    @solr.delete_by_query '*:*'
    @solr.commit
  end


  def self.update_record(record)
    @solr = RSolr.connect :url => @@solr_url
    doc = record.solr_doc_data
    @solr.add doc
    @solr.commit
  end


  def self.delete_record(record)
    @solr = RSolr.connect :url => @@solr_url
    @solr.delete_by_query "id:#{ record.solr_id }"
    @solr.commit
  end


  def self.execute_full
    @solr = RSolr.connect :url => @@solr_url
    update_batch = Proc.new do |records|
      batch = []
      records.each { |r| batch << r.solr_doc_data }
      if @solr.add batch
        print '.'
      end
      @solr.commit
    end

    classes = [Order, Item, User, Location, AccessSession]
    classes.each do |c|
      if c == Order
        c.where(deleted: false).find_in_batches(batch_size: @@batch_size) do |records|
          update_batch.call(records)
        end
      else
        c.find_in_batches(batch_size: @@batch_size) do |records|
          update_batch.call(records)
        end
      end
    end
  end


  def self.execute_clean
    wipe_index
    execute_full
  end


  private


  def update_batch(records)
    batch = []
    records.each { |r| batch << r.solr_doc_data }
    if @solr.add batch
      print '.'
    end
    @solr.commit
  end


end
