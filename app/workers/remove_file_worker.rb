# encoding: utf-8

class RemoveFileWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(file)
    FileUtils.rm('.' + file)
  end
end