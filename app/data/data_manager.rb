class CMGDataManager
  attr_reader :data

  def initialize
    path = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, true).lastObject.stringByAppendingPathComponent("graphs.plist")
    @data = []
    if File.exists?(path)
      content = NSData.alloc.initWithContentsOfFile(path)
      @data = NSPropertyListSerialization.propertyListWithData(content, options: NSPropertyListMutableContainersAndLeaves, format: nil, error: nil)
    end
  end

  def add_image(imagepath)
    @data.unshift(imagepath)
    NSNotificationCenter.defaultCenter.postNotificationName('newimage', object: self)
  end

  def save_cache
    path = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, true).lastObject.stringByAppendingPathComponent("graphs.plist")
    dir = File.dirname(path)
    unless File.exists?(dir)
      NSFileManager.defaultManager.createDirectoryAtPath(dir, withIntermediateDirectories: true, attributes: nil, error: nil)
    end
    content = NSPropertyListSerialization.dataFromPropertyList(@data, format:NSPropertyListXMLFormat_v1_0, errorDescription: nil)
    unless content.nil?
      content.writeToFile(path, atomically:true)
    end
  end
end
