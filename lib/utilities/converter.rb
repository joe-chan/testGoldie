class Converter
  def self.convert(data)
    db=data[Metas::TID]
    data_type=data[Metas::TYPE]
    metas=Metas::M
    meta = metas.item(data_type)

    doc={}

    value = data[Metas::VALUE]

    value.each do |key,v|
      targetFieldDef = meta.field_def_by_map_field(key)
      if targetFieldDef then
        innerMeta=metas.item(targetFieldDef['type'])
        f_name=targetFieldDef['field_name']
        if not innerMeta then
          doc[f_name] = Converter.convert_value(v,targetFieldDef)
        else
          #"billToContact" : {"field":"billTo","mapping":"contact"}
          doc[f_name] = Converter.convert_embedded(v,innerMeta)
        end

      elsif
        if not v.instance_of? Hash # if custom field which doesn't have mapping at all
          doc[key] = v
        end
      end
    end

    result={}
    result["db"] = db
    result['type'] = meta.name
    result['doc'] = doc
    result['operation'] = data[Metas::OP]
    return result
  end

  def self.convert_value(value,fieldDefinition)
    type = fieldDefinition['type']
    result = nil
    if not(value and value.size()>0) then
      return nil
    end
    if type=='String' then
      #convert to String
      result = value
    elsif type=='Integer' then
      # convert to Integer
      result = value.to_i
    elsif type=='Date' then
      #convert to Date
      result = DateTime.strptime(value,'%m/%d/%Y').to_time.utc
    elsif type=='BigDecimal' then
      # convert to BigDecimal
      result = Float(value)
    elsif type=='Boolean' then
      # convert to Boolean
      result = value
    end

    return result
  end

  def self.convert_embedded(value,meta)
    doc={}
    value.each do |key,v|
      targetFieldDef = meta.field_def_by_map_field(key)
      if targetFieldDef then
        f_name=targetFieldDef['field_name']
        doc[f_name] = Converter.convert_value(v,targetFieldDef)
      elsif
        doc[key] = v
      end
    end
    return doc
  end
end