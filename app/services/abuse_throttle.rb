class AbuseThrottle
  ABUSE_LIMIT = 20
  ABUSE_PAUSE = 30.seconds

  def under_abuse_limit(&_block)
    throttle_for_abuse_limit do
      catch_abuse_error do
        yield
      end
    end
  end

  def throttle_for_abuse_limit(&_block)
    @abuse_count ||= 0
    if @abuse_count >= ABUSE_LIMIT
      Rails.logger.info 'sleeping for abuse count…'
      sleep ABUSE_PAUSE
      @abuse_count = 0
    end

    yield

    @abuse_count += 1
  end

  def catch_abuse_error(&_block)
    yield
  rescue Github::Error::Forbidden
    Rails.logger.info 'caught abuse error'
    sleep ABUSE_PAUSE
    retry
  end
end
