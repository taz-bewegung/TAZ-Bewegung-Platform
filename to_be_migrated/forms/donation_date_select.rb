class Forms::DonationDateSelect < ActiveRecord::BaseWithoutTable
  
  column :starts_on, :date  
  column :ends_on, :date

end