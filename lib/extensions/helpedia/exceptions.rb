module Helpedia
  
  class UserIsNotOrganisation < StandardError
  end
  
  class UserIsNotUser < StandardError
  end  
  
  class ItemNotVisible < StandardError    
  end
  
  class PageNotAvailableAnymore < StandardError
  end
  
  class ComingSoon < StandardError
  end  
  
  class InvalidApiAuthentication < StandardError
  end
  
end