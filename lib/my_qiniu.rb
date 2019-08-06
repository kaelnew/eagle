class MyQiniu
  class << self
    def upload!(file_path, file_name, tag)
      bucket = Setting.qiniu['bucket']
      file_name = "#{tag}/#{Time.now.strftime('%Y%m%d')}/#{file_name}"
      put_policy = Qiniu::Auth::PutPolicy.new(bucket, file_name, 3600)
      uptoken = Qiniu::Auth.generate_uptoken(put_policy)
      code, result, response_headers = Qiniu::Storage.upload_with_token_2(uptoken, file_path, file_name, nil, bucket: bucket)
      if code != 200
        Rails.logger.info "Code: #{code.inspect}"
        Rails.logger.info "Result: #{result.inspect}"
        Rails.logger.info "Headers: #{response_headers.inspect}"
        return false
      end
      [file_name, URI.encode(Setting.qiniu['url_prefix'] + file_name)]
    end


    def rename!(src_name, dst_name)
      bucket = Setting.qiniu['bucket']
      code, result, response_headers = Qiniu::Storage.move(bucket, src_name, bucket, dst_name)
      if code != 200
        Rails.logger.info "Code: #{code.inspect}"
        Rails.logger.info "Result: #{result.inspect}"
        Rails.logger.info "Headers: #{response_headers.inspect}"
        return false
      end
      true
    end
  end
end