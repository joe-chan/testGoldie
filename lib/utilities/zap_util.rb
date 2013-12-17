module ZapUtil
  def extract_datasource_root_object(doc, object_name)
    # Get all attributes that are not objects
    partial_doc = doc.keys.sort.reject {|key|
      doc[key].class == BSON::OrderedHash
    }
    eval("@#{object_name} = []")
    partial_doc.each {|key|
      eval("@#{object_name} << {:key => \"#{key}\", :value => \"#{doc[key]}\"}")
    }

  end

  def extract_datasource_object(doc, object_name)
    partial_doc = doc[object_name]
    self.extract_object(partial_doc, object_name) if partial_doc
  end

  def extract_object(doc, object_name)
    eval("@#{object_name} = []")
    doc.keys.sort.each {|key|
      eval("@#{object_name} << {:key => \"#{key}\", :value => \"#{doc[key]}\"}")
    }
  end
  
end