module RequestSupport
  def json
    JSON.parse(response.body)
  end
end
